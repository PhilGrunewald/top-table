set listchars=tab:▸\       "show tabs as little arrows ,eol:¬

" ====================
"  Global variables
" ====================

" status line sections
let sl1 = "%f%="
let sl2 = ''
let sl3 = ''
" column widths
let cols = []

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
endfunction


function! Status()
  " update statusline with row/col info
  let g:sl2 = expand('r'.line('.').'(\%L)×c'.GetCurCol().'('.len(g:cols).')')
  execute expand('setlocal statusline='.g:sl1.'\\ '.g:sl2.'\\ '.g:sl3)
endfunction


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


function! GetCellContent(row,colNo)
  let line = getline(a:row)
  let i   = 0
  let tab = 0
  while i < a:colNo
      let i += 1
      let tab += stridx(line[tab:], "\t")+1
  endwhile
  let content = line[tab:]
  let tab = stridx(content, "\t")
  return content[:tab]
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
  let line = substitute(line, '/', '\\\\/', 'g')
  execute expand(a:row."s/.*/".line)
endfunction


function! SwapCell(direction)
  let row = getcurpos()[1]
  let col = getcurpos()[4]
  let colNo = GetCurCol()
  let c1 = GetCellContent(row,colNo)
  if a:direction == 'up' && row > 1
    let c2 = GetCellContent(row+1,colNo)
    call SetCellContent(row  ,colNo,c2)
    call SetCellContent(row-1,colNo,c1)
    execute expand(col.','.row)
    normal k
  endif
  if a:direction == 'down' && row < line('$')
    let c2 = GetCellContent(row+1,colNo)
    call SetCellContent(row  ,colNo,c2)
    call SetCellContent(row+1,colNo,c1)
    execute expand(col.','.row)
    normal j
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


function! GetCurCol()
    "return the column number of current cursor
    let col = getcurpos()[4] "[4] > one char (unlike [2])
    let colRight = 0
    let colNo    = 0
    for width in g:cols
        let colRight += width
        if (colRight < col)
            let colNo += 1
        endif
    endfor
    return colNo
endfunction


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
      if tab == 0
        let header = spacer.header
      else
        let header = header[:tab-1].spacer.header[tab:]
      endif
      let g:cols[colNo] += diff
    else
      if header[tab-diff:tab-1] == spacer
        if tab-diff == 0
          let header = header[diff:]
        else
          let header = header[:tab-diff-1].header[tab:]
        endif
      endif
      if g:cols[colNo] > 2*diff
        let g:cols[colNo] -= diff
      endif
    endif

    " apply new var-tab-stops, replace header and return
    execute expand('set vartabstop='.ArrayString(g:cols))
    execute expand("1s/.*/".header)
    execute expand(col.','.row)
    echo expand('Column '.(colNo+1)." now ".g:cols[colNo]." wide")
    set syntax=tab
endfunction


function! PrevCol()
  " find tab on left. Stop at col 0
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
  call Status()
endfunction


function! NextCol()
  " find next tab or loop to col 0
  let line = getline('.')
  let col = getcurpos()[2]-1
  let tab = stridx(line[col:], "\t")+1
  if tab > 0
    execute expand('normal '.tab.'l')
  else
    execute expand('normal '.tab)
  endif
  call Status()
endfunction


function! EnterDown()
    " go down one row or add when at bottom
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
endfunction


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

" ==============
"  Commands
" ==============

command! Help     :h vim-table

" Entry mode: downwards or sidewards
command! InCols   :call EnterCols()
command! InRows   :call EnterRows()

" Column sizing
command! Fit      :call FitColumns()
command! Fix      :call FixColumns()

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

nnoremap <TAB>   :call NextCol()<CR>
nnoremap <S-TAB> :call PrevCol()<CR>

" Row swapping (bubble up/down
nnoremap <Up> ddkP
nnoremap <Down> ddp
vnoremap <Up> xkP`[V`]
vnoremap <Down> xp`[V`]

" Column swapping
nnoremap <buffer><S-RIGHT>  :call SwapCol(0)<CR>
nnoremap <buffer><S-LEFT>   :call SwapCol(-1)<CR>

" Cell swapping
nnoremap <buffer>K  :call SwapCell('up')<CR>
nnoremap <buffer>J  :call SwapCell('down')<CR>
nnoremap <buffer>H  :call SwapCell('left')<CR>
nnoremap <buffer>L  :call SwapCell('right')<CR>

" Column sizing
nnoremap <buffer><RIGHT>  :call ColWidth('+')<CR>
nnoremap <buffer><LEFT>   :call ColWidth('-')<CR>

" Fill with incremental values
nnoremap ++        :call Increment()<CR>
nnoremap ==        :call Calc('sum')<CR>


" Turn to markdown
nnoremap <buffer><leader>p  :!pandoc % -f tsv -t markdown -o %:r.md<CR>
nnoremap <buffer><leader>,  :%s/\t/,/g<CR>
nnoremap <buffer><S-ENTER>  :terminal visidata %<CR>

call Init()
