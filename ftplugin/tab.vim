set listchars=tab:▸\       "show tabs as little arrows ,eol:¬

" ====================
"  Global variables
" ====================

" status line sections
let g:sl1 = "%f%="
let g:sl2 = ''
let g:sl3 = ''
" column widths
let g:cols = []

" Only one column can be expanded (otherwise multiline is complicated)
" To expand a different one, all others are collapsed first
let g:OpenCol = -1

" ====================
"  Utility functions
" ====================

function ArrayString(arr)
    let str = ''
    for c in a:arr
        let str = str.c.','
    endfor
    return str[:-2]
endfunction

fu! Add(list)
  let i = 0
  let sum = 0
  while i < len(a:list)-1
    let sum += a:list[i]
    let i += 1
  endwhile
  return sum
endfu


fu Escape(str)
  let str = a:str
  let str = substitute(str,'\n','NEWLINE','g')
  let str = substitute(str,'\','\\\\\\\\','g')
  let str = substitute(str,'/','\\\\/','g')
  let str = substitute(str,'[','\\\\[','g')
  let str = substitute(str,']','\\\\]','g')
  let str = substitute(str,'NEWLINE','\\\\n','g')
  " let str = substitute(str,'X','\\\\n','g')
  return str
endfu
fu Rescape(str,colNo)
  let str = a:str
  let str = substitute(str,'&','\\\\\&','g')
  let str = substitute(str,'|','\\\\|','g')
  let pad = repeat(" ",Add(g:cols[:a:colNo]))
  let str = substitute(str,'\r',expand('\\r'.pad),'g')
  return str
endfu

fu Deslash(str)
  let str = a:str
  let str = substitute(str,'\n','','g')
  let str = substitute(str,'\\','','g')
  let str = substitute(str,'\/','','g')
  let str = substitute(str,'&','','g')
  return str
endfu
" ====================
"      Functions
" ====================


function! Init()
  " set column widths
  let l1 = getline('1')
  " auto convert comma to tab delimiter (if commas, but no tabs)
  if (stridx(l1,"\t") == -1) && (stridx(l1,",") > -1)
      %s/,/\t/g
      echo "Converted to tab delimiters"
      let l1 = getline('1')
  endif
  let varcol = []
  let wcol = 0
  for l in l1
      let wcol += 1
      if l == "\t"
        if wcol < 2
            let wcol = 1
        endif
        let varcol += [wcol+1]
        let wcol = 0
      endif
  endfor
  let varcol += [20]
  execute expand('let g:cols=['.ArrayString(varcol).']')
  execute expand('set vartabstop='.ArrayString(g:cols))
  let g:sl2 = expand('\%Lr×'.len(varcol).'c')
  call EnterCols()
  call Status()
  if line('$') > 440 | call SplitHeader() | endif
endfunction

fu! SplitHeader()
  " Header split with sync scrolling
  highlight VertSplit   ctermfg=DarkGreen    ctermbg=black  cterm=NONE
  wincmd o
  set scrollbind
  split
  set scrollbind
  set scrollopt-=ver
  resize 1
  wincmd j
  " move second line to top
  normal jzt
endfu

function! Status()
  " update statusline with row/col info
  let g:sl2 = expand('r'.line('.').'(\%L)×c'.GetCurCol().'('.len(g:cols).')')
  execute expand('setlocal statusline='.g:sl1.'\\ '.g:sl2.'\\ '.g:sl3)
endfunction

" Column operations

function! FixColumns()
  let i = 0
  for col in g:cols
    let g:cols[i] = 10
    let i +=1
  endfor
  execute expand('set vartabstop='.ArrayString(g:cols))
  set conceallevel=2
  execute expand('setlocal statusline='.g:sl1.'\\ '.g:sl2.'\\ cols@10')
  set syntax=tab
endfunction

function! FitColumns()
  " size each column to its maximum width
  let l = 1
  while l <= line('$')
    let line = getline(l)
    let colNo = 0
    let wcol = 0
    for c in line
      let wcol += 1
      if c == "\t"
        if wcol > g:cols[colNo]
          let g:cols[colNo] = wcol
        endif
        let wcol   = 0
        let colNo += 1
      endif
    endfor
    let l += 1
  endwhile
  execute expand('set vartabstop='.ArrayString(g:cols))
  set conceallevel=0
endfunction

fu! GetCellOrigin()
  let row = getcurpos()[1]
  let col = getcurpos()[2]
  let line = getline(row)
  let line = line[:col]
  while stridx(line,"\t") == -1 && row > 1
    let row -= 1
    let line = getline(row)
  endwhile
  return row
endfu

function! GetColStart(l,col)
  " returns at which characters column `col` [0,1,2..] starts
  let col   = 0
  let start = 0
  for l in a:l
    if col < a:col
      let start += 1
    endif
    if l == "\t"
      let col += 1
    endif
  endfor
  return start
endfunction

" Cell operations

function! GetCellContent(row,colNo)
  " read between tabs
  call GoRowCol(a:row,a:colNo)
  noh
  let @/="\t"
  silent normal vn"cy
  return @c
endfunction


function! SetCellContent(row,colNo,content)
  " replace text between tabs with content
  let content = a:content
  let line = getline(a:row)
  let i   = 0
  let tab = 0
  while i < a:colNo
      let i += 1
      let tab += stridx(line[tab:], "\t")+1
  endwhile
  if tab == 0
      let pre = ''
      let content = content
  else
      let pre = line[:tab-1]
  endif

  let tab += stridx(line[tab+1:], "\t")+1
  if tab == 0
    let line = pre.content
  else
    let line = pre.content.line[tab+1:]
  endif
  let line = substitute(line,'\n','\\\\r','g')
  execute expand(a:row."s/.*/".line)
endfunction


function! SwapCell(direction)
  let row = getcurpos()[1]
  let col = getcurpos()[4]
  let colNo = GetCurCol()
  let c1 = GetCellContent(row,colNo)
  if a:direction == 'up' && row > 1
    let c2 = GetCellContent(row-1,colNo)
    call SetCellContent(row  ,colNo,c2)
    call SetCellContent(row-1,colNo,c1)
    execute expand(col.','.(row-1))
  endif
  if a:direction == 'down' && row < line('$')
    let c2 = GetCellContent(row+1,colNo)
    call SetCellContent(row  ,colNo,c2)
    call SetCellContent(row+1,colNo,c1)
    execute expand(col.','.(row+1))
  endif
  if a:direction == 'left' && colNo > 0
    let c2 = GetCellContent(row,colNo-1)
    call SetCellContent(row,colNo  ,c2)
    call SetCellContent(row,colNo-1,c1)
    execute expand(col.','.row)
    call PrevCol()
  endif
  if a:direction == 'right'
    let c2 = GetCellContent(row,colNo+1)
    call SetCellContent(row,colNo  ,c2)
    call SetCellContent(row,colNo+1,c1)
    execute expand(col.','.row)
    call NextCol()
  endif
endfunction

function! SwapCol(offset)
  " line by line replacement of neighbouring columns
  let row = getcurpos()[1]
  let col = getcurpos()[4] "[4] > one char (unlike [2])
  let a = GetCurCol()+a:offset
  let b = a + 1
  call CellCollapseAll()

  " linewise swap
  let lineNo = 1
  while lineNo <= line('$')
    let l = getline(lineNo)
    let leftA  = GetColStart(l,a)
    let middle = GetColStart(l,b)
    let rightB = GetColStart(l,b+1)-1
    if leftA == 0
      let l = l[middle:rightB].l[leftA:middle-1].l[rightB+1:]
    else
      let l = l[:leftA-1].l[middle:rightB].l[leftA:middle-1].l[rightB+1:]
    endif
    execute expand(lineNo."s/.*/".l."/")
    let lineNo += 1
  endwhile

  " return to cursor position in column
  execute expand(col.','.row)
  if a:offset < 0
      call PrevCol()
  else
      call NextCol()
  endif

  " swap column widths
  let w_a = g:cols[a]
  let w_b = g:cols[b]
  let g:cols[a] = w_b
  let g:cols[b] = w_a
  execute expand('set vartabstop='.ArrayString(g:cols))
  set syntax=tab
endfunction
fu! GetCurCol()
    "return the column number of current cursor
    let col   = getcurpos()[2]
    let line  = getline('.')
    let colNo = 0
    let c     = 1
    while c < col
      if line[c-1] == "\t" | let colNo += 1 | endif
      let c += 1
    endwhile
    return colNo
endfu


function! ColWidth(direction)
  " add/remove spacer in header and alter vartabstops
  " Note: global 'cols' is read from header line
  let spacer = '  '
  let diff = len(spacer)

  let row = getcurpos()[1]
  let col = getcurpos()[4] "[4] > one char (unlike [2])
  let colNo = GetCurCol()

  " get position of tab to the left 
  let header = getline('1')
  let n = 0
  let tab = 0
  while n <= colNo
    let tab += stridx(header[tab:], "\t")+1
    let n += 1
  endwhile
  let tab -= 1

  " the first line gets spaces added/removed 
  " ± global col
  if a:direction == '+'
    " expand column
    if tab == 0
      " no column label in first col
      let header = spacer.header
    else
      " insert spaces
      let header = header[:tab-1].spacer.header[tab:]
    endif
    " widen tab
    let g:cols[colNo] += diff
  else
    " reduce column
    if header[tab-diff:tab-1] == spacer
      " enough space to shorten column
      if tab-diff == 0
        " remove spaces
        let header = header[diff:]
      else
        let header = header[:tab-diff-1].header[tab:]
      endif
    endif
    if g:cols[colNo] > 2*diff
      " shorten tab
      let g:cols[colNo] -= diff
    endif
  endif
  " reset tabstops
  execute expand('set vartabstop='.ArrayString(g:cols))
  " replace the header
  execute expand("1s/.*/".header)
  " return to starting point
  execute expand(col.','.row)
  " move to next column
  echo expand('Column '.(colNo+1)." now ".g:cols[colNo]." wide")    
  " redraws the conceals
  set syntax=tab
endfunction

" Cell navigation

function! PrevCol()
  " find tab on left. Stop at col 0
  call CellTrim()
  let line = getline('.')
  normal h
  let col = col('.')-1
  while col > 0
    normal h
    let col = col('.')-1
    if line[col] == "\t"
      let col = 0
      normal l
    endif
  endwhile
  call CellUntrim()
endfunction

fu! GoCol(n)
  let line = getline('.')
  normal 0
  let c = 0
  let col = 0
  while col < a:n && col > -1
   if line[c] == "\t" | let col += 1 | endif
   let c += 1
   normal l
   if c > len(line) | let col = -1 | endif
  endwhile
  return col
endfu

fu! GoRowCol(row,col)
  execute expand("0,".a:row)
  call GoCol(a:col)
endfu

function! NextCol()
  " find next tab or loop to col 0
  call CellTrim()
  let line = getline('.')
  " ensure finishing tab to line
  if line[-1:-1] != "\t" | s/$/\t/ | endif
  let col = getcurpos()[2]-1
  let tab = stridx(line[col:], "\t")+1
  if tab > 0
    execute expand('normal '.tab.'l')
  else
    execute expand('normal '.tab)
  endif
  call CellUntrim()
  call Status()
endfunction


function! EnterDown()
  " go down one row or add when at bottom
  call CellTrim()
  if line('.') == line('$')
      normal o
  else
      if col('.') == 1
          normal j
      else
          normal lj
      endif
  endif
  call Status()
  echo "down"
endfunction

" Entry mode

function! EnterRows()
  " in insert mode, <ENTER> advances to the right
  inoremap <ENTER> <ESC>:call NextCol()<CR>a
  let g:sl3 = expand('in_rows')
  call Status()
endfunction

function! EnterCols()
  " in insert mode, <ENTER> advances to the next row
  inoremap <ENTER> <ESC>:call EnterDown()<CR>i
  let g:sl3 = expand('in_cols')
  call Status()
endfunction


function! FoldTable(lnum)
  " Fold if column 1,2 or 3 are empty
  let line = getline(a:lnum)
  if ( line =~ '^\t\t\t.*' )
      return '3'
  elseif ( line =~ '^\t\t.*' )
      return '2'
  elseif ( line =~ '^\t.*' )
      return '1'
  else
      return '0'
endfunction


" ====================
"    Text truncing
" ====================

fu! CellTrim()
  " shorten to width and save content to file
  " find start of multiline cell
  normal mc
  let row = GetCellOrigin()
  execute expand("normal ".row."G")
  let colNo = GetCurCol()
  let width = g:cols[colNo]
  let cell = GetCellContent(row,colNo)
  if len(cell) > width && match(cell,"<\\d\\+\\t") == -1
    " cell is too wide and not collapsed > collapse
    let width = width - 4
    let i = 1
    while filereadable(".".Deslash(cell[:width]).i)
      let i+=1
    endwhile
    " Save full cell content and replace with filename
    let fname = Deslash(cell[:width])."<".i
    let text = substitute(cell,'\n\s\+','\n','g')
    let text = substitute(text,'; ','\n','g')
    let text = split(text,"\n")
    call writefile(text,".".fname)
    execute expand("s/".Escape(cell)."/".fname."\t/")
  endif
  normal `c
endfu

fu! CellUntrim()
  " Expand cell content from file
  normal mu
  let row = getcurpos()[1]
  let colNo = GetCurCol()
  let cell = GetCellContent(row,colNo)
  if match(cell,"<\\d\\+\\t") > -1
    let text  = join(readfile(".".cell[:-2]),"\r")
    silent! execute expand("!rm '.".cell[:-2]."'")
    if g:OpenCol != colNo | call CellCollapseAll() | endif
    let g:OpenCol = colNo
    execute expand("s/".Escape(cell)."/".Rescape(text,colNo)."/")
    normal `u
  endif
  call Status()
endfu


fu! CellExpandAll()
  let rowNo = getcurpos()[1]
  let colNo = GetCurCol()
  let row = 1
  while row < line('$')
    let col = match(getline(row),"<\\d\\+\\t")
    while col > -1
      execute expand("normal ".row."G0".col."l")
      call CellUntrim()
      let col = match(getline(row),"<\\d\\+\\t")
    endwhile
    let row += 1
  endwhile
  call GoRowCol(rowNo,colNo)
endfu

fu! CellCollapseAll()
  let rowNo = getcurpos()[1]
  let colNo = GetCurCol()
  let row = 1
  while row < line('$')
    execute expand("normal ".row."G")
    let col = 0
    while GoCol(col) != -1
      call CellTrim()
      let col += 1
    endwhile
    let row += 1
  endwhile
  call GoRowCol(rowNo,colNo)
endfu

fu! CellToggle()
  " trim call and save content / expand cell based on that content
  normal mc
  let row = getcurpos()[1]
  let colNo = GetCurCol()
  let width = g:cols[colNo]
  let cell = GetCellContent(row,colNo)
  normal `c
  if len(cell) > width
    call CellTrim()
  else
    call CellUntrim()
  endif
endf


" ====================
"   Spreadsheetish
" ====================

function! Increment()
  let row = getcurpos()[1]
  let colNo = GetCurCol()
  let content = GetCellContent(row,colNo)
  while row < line('$')
      let row += 1
      let content += 1
      call SetCellContent(row,colNo,content. "\t")
  endwhile
endfunction

function! Calc(operand)
  " sums up column and inserts sum / avg
  let bottomline = getcurpos()[1]
  let colNo = GetCurCol()
  let sum = 0
  let cnt = 0
  let row = 1
  while row < bottomline
    let col = GetCellContent(row,colNo)
    if ((col == '0') || (str2float(col) != 0))
      let cnt = cnt + 1
      let sum += str2float(col)
    endif
    let row += 1
  endwhile
  if a:operand == 'avg'
    let result = join(['avg ',sum/cnt])
  else
    let result = join(['=',sum])
  endif
  call SetCellContent(row,colNo,result."\t")
  if (row-cnt-2) == 0
    echo join(["Sum:", sum, " Avg: ", sum/cnt, " Count:",cnt])
  else
    echo join(["Sum:", sum, " Avg: ", sum/cnt, " Count: ",cnt," Invalid: ", row-cnt-2])
  endif
endfunction

" ====================
"     Settings
" ====================

" Folding
setlocal foldexpr=FoldTable(v:lnum)
setlocal foldmethod=expr
setlocal foldenable
setlocal foldlevel=5
setlocal foldcolumn=4
setlocal shiftwidth=2


" Tabs and display
setlocal listchars=tab:\ \ \|       "tabs right bound bar
setlocal noexpandtab
setlocal softtabstop=0
setlocal nosmarttab 
setlocal breakindent
setlocal nowrap
setlocal conceallevel=2
setlocal concealcursor=n     "only expand in insert mode

" ==============
"  Commands
" ==============

command! Help     :h vi-shing-table

" Entry mode: downwards or sidewards
command! InCols   :call EnterCols()
command! InRows   :call EnterRows()

" Column sizing
command! Fit         :call FitColumns()
command! Fix         :call FixColumns()
command! TabExpand   :call CellExpandAll()<CR>
command! TabCollapse :call CellCollapseAll()<CR>

" Calculations
command! Increment :call Increment()
command! Sum      :call Calc('sum')
command! Avg      :call Calc('avg')

" Edit external
command! Visidata :terminal visidata %

" ====================
"     Mappings
" ====================

" ==============
"  Insert mode
" ==============

inoremap <TAB>   <TAB>


" ==============
"  Normal mode
" ==============

" avoid editing trimmed cells
" nnoremap i       :call CellUntrim()<CR>i
" nnoremap a       :call CellUntrim()<CR>a
"
" nnoremap <buffer>k       :call CellTrim()<CR>k:call CellUntrim()<CR>
" nnoremap <buffer>j       :call CellTrim()<CR>j:call CellUntrim()<CR>

nnoremap <buffer><TAB>   :call NextCol()<CR>
nnoremap <buffer><S-TAB> :call PrevCol()<CR>

" Row swapping (bubble up/down)
nnoremap <Up> ddkP
nnoremap <Down> ddp
vnoremap <Up> xkP`[V`]
vnoremap <Down> xp`[V`]

" Column swapping
nnoremap <buffer><C-RIGHT>  :call SwapCol(0)<CR>
nnoremap <buffer><C-LEFT>   :call SwapCol(-1)<CR>

" Cell swapping
nnoremap <buffer>K  :call SwapCell('up')<CR>
nnoremap <buffer>J  :call SwapCell('down')<CR>
nnoremap <buffer>H  :call SwapCell('left')<CR>
nnoremap <buffer>L  :call SwapCell('right')<CR>

" Column sizing
nnoremap <buffer><S-Right>  :call ColWidth('+')<CR>
nnoremap <buffer><S-Left>   :call ColWidth('-')<CR>

" Fill with incremental values
nnoremap <buffer>++        :call Increment()<CR>
nnoremap <buffer>==        :call Calc('sum')<CR>

nnoremap <buffer>>>          :call CellToggle()<CR>
nnoremap <buffer><C-.><C-.>  :call CellExpandAll()<CR>
nnoremap <buffer><C-,><C-,>  :call CellCollapseAll()<CR>

" Turn to markdown
nnoremap <buffer><leader>p  :!pandoc % -f tsv -t markdown -o %:r.md<CR>
nnoremap <buffer><leader>,  :%s/\t/,/g<CR>
" nnoremap <buffer><S-ENTER>  :terminal visidata %<CR>
inoremap <buffer><S-ENTER>  <Enter>

call Init()
