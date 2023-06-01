" ====================
"  Global variables
" ====================

" status line sections
let g:sl1 = "%f%="


" ====================
"  Utility functions
" ====================

fu ArrayString(arr)
    let str = ''
    for c in a:arr
        let str = str.c.','
    endfor
    return str[:-2]
endfu

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
  let str = substitute(str,'*','\\\\*','g')
  let str = substitute(str,'[','\\\\[','g')
  let str = substitute(str,']','\\\\]','g')
  let str = substitute(str,'NEWLINE','\\\\n','g')
  " let str = substitute(str,'X','\\\\n','g')
  return str
endfu

fu Rescape(str)
  let str = a:str
  let str = substitute(str,'\','\\\\\\','g')
  let str = substitute(str,'/','\\\\\/','g')
  let str = substitute(str,'&','\\\\\&','g')
  let str = substitute(str,'|','\\\\|','g')
  let str = substitute(str,'\r',expand('; '),'g')
  return str
endfu

fu Deslash(str)
  let str = a:str
  let str = substitute(str,'\t','','g')
  let str = substitute(str,'\n','','g')
  let str = substitute(str,'\\','','g')
  let str = substitute(str,'\/','','g')
  let str = substitute(str,'&','','g')
  return str
endfu


" ====================
"      Functions
" ====================

fu! Init()
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
  exe expand('let b:cols=['.ArrayString(varcol).']')
  exe expand('set vartabstop='.ArrayString(b:cols))

  " all lines muse end with a tab
  let l = 1
  while l <= line('$')
    let line = getline(l)
    if line[-1:-1] != "\t" && line[-1:-1] != "\\" | exe l."s/$/\t/" | endif
    let l += 1
  endwhile

  call ColWise()
  call Status()
endfu

fu! Header()
  " Header split with sync scrolling
  normal mc
  highlight VertSplit   ctermfg=DarkGreen    ctermbg=black  cterm=NONE
  wincmd o
  set laststatus=3      " just one statusline
  set scrollopt=hor
  set scrollbind
  split
  set scrollbind
  wincmd k
  normal gg
  resize 1
  wincmd j
  normal ggjzt`c
endfu

fu! Status()
  " update statusline with row/col info
  let row = 'row:'.line('.')
  let col = 'col:'.GetColNo()
  exe expand('setlocal statusline='.g:sl1.'\\ '.row.'\\ '.col.'\\ '.g:TabMode)
endfu

" Column operations

fu! FixColumns()
  let i = 0
  for col in b:cols
    let b:cols[i] = 10
    let i +=1
  endfor
  exe expand('set vartabstop='.ArrayString(b:cols))
  exe expand('setlocal statusline='.g:sl1.'\\ '.g:sl2.'\\ cols@10')
  set syntax=tab
endfu

fu! FitColumns()
  " size each column to its maximum width
  let l = 1
  while l <= line('$')
    let colNo = 0
    while GoCol(colNo+1) > GoCol(colNo)
      if colNo >= len(b:cols)
        let b:cols = b:cols + [10]
      endif
      let width = len(GetCell(l,colNo))
      if width > b:cols[colNo]
        let b:cols[colNo] = width
      endif
      let colNo += 1
    endwhile
    let l += 1
  endwhile
  exe expand('set vartabstop='.ArrayString(b:cols))
endfu

fu! InsertColumn(shift)
  let colNo = GetColNo()+a:shift
  let line = 0
  while line < line('$')
    let line += 1
    exe expand("normal ".line."G")
    call GoCol(colNo)
    normal i	
  endwhile
  if colNo > 0
    let b:cols = b:cols[:colNo-1] + [5] + b:cols[colNo:]
  else
    let b:cols = [10] + b:cols
  endif
  exe expand('set vartabstop='.ArrayString(b:cols))
endfu

fu! DeleteColumn()
  let colNo = GetColNo()
  let line = 0
  while line < line('$')
    let line += 1
    exe expand("normal ".line."G")
    call GoCol(colNo)
    if getline('.')[getcurpos()[2]-1] == "\t"
      normal x
    else
      normal dt	
    endif
  endwhile
  if colNo > 0
    let b:cols = b:cols[:colNo-1]+ b:cols[colNo+1:]
  else
    let b:cols = b:cols[1:]
  endif
  exe expand('set vartabstop='.ArrayString(b:cols))
endfu

fu! GetColStart(l,col)
  " CONSIDER REPLACING with GetCell, SetCell
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
endfu

" Cell operations

fu! GetCell(row,colNo)
  " read between tabs - including the trailing TAB
  call GoRowCol(a:row,a:colNo)
  noh
  let @/="\t"
  silent! normal vn"cy
  let content = @c
  " empty cells begin with tab and would yank to next tab > cull
  if content[0] == "\t" | let content = "\t" | endif
  return content
endfu

fu! SetCell(row,colNo,content)
  " replace text between tabs with content
  let new = a:content
  let old = GetCell(a:row,a:colNo)
  if old=="\t"
    if a:colNo == 0
      exe expand(a:row."s/^\t/".new."/")
    else
      let tabs = repeat("\t[^\t]*",a:colNo-1)
      exe expand(a:row."s/".tabs."\\\\zs\\\\t\\\\t\\\\ze/\\\\t".new)
    endif
  else
    if a:colNo == 0
      exe expand(a:row."s/^".old."/".new."/")
    else
      let tabs = repeat("[^\t]*\t",a:colNo)
      exe expand(a:row."s/".tabs."\\\\zs".old."\\\\ze/".new."/")
    endif
  endif
  call GoCol(a:colNo)
endfu


fu! SwapCell(dir)
  let row = getcurpos()[1]
  let colNo = GetColNo()
  let c1 = GetCell(row,colNo)
  if a:dir == 'k' && row > 1
    let c2 = GetCell(row-1,colNo)
    call SetCell(row  ,colNo,c2)
    call SetCell(row-1,colNo,c1)
  elseif a:dir == 'j' && row < line('$')
    let c2 = GetCell(row+1,colNo)
    call SetCell(row  ,colNo,c2)
    call SetCell(row+1,colNo,c1)
  elseif a:dir == 'h' && colNo > 0
    let c2 = GetCell(row,colNo-1)
    call SetCell(row,colNo  ,c2)
    call SetCell(row,colNo-1,c1)
  elseif a:dir == 'l'
    let c2 = GetCell(row,colNo+1)
    call SetCell(row,colNo  ,c2)
    call SetCell(row,colNo+1,c1)
  endif
endfu

fu! SwapCol(offset)
  " CONSIDER REPLACING with GetCell, SetCell
  " line by line replacement of neighbouring columns
  let row = getcurpos()[1]
  let col = getcurpos()[4] "[4] > one char (unlike [2])
  let a = GetColNo()+a:offset
  let b = a + 1
  call CollapseCells()

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
    exe expand(lineNo."s/.*/".l."/")
    let lineNo += 1
  endwhile

  " return to cursor position in column
  call GoRowCol(row,b+a:offset)

  " swap column widths
  let w_a = b:cols[a]
  let w_b = b:cols[b]
  let b:cols[a] = w_b
  let b:cols[b] = w_a
  exe expand('set vartabstop='.ArrayString(b:cols))
  set syntax=tab
endfu

fu! GetColNo()
    "return the column number of current cursor
    let col   = getcurpos()[2]
    let line  = getline('.')
    " make sure every line ends with a tab (unless escaped with `\`)
    if line[-1:-1] != "\t" && line[-1:-1] != "\\" | exe "s/$/\t/" | endif
    let colNo = 0
    let c     = 1
    while c < col
      if line[c-1] == "\t" | let colNo += 1 | endif
      let c += 1
    endwhile
    return colNo
endfu


fu! ColWidth(direction)
  " add/remove spacer in header and alter vartabstops
  " Note: global 'cols' is read from header line
  let spacer = '  '
  let diff = len(spacer)

  let row = getcurpos()[1]
  let col = getcurpos()[4] "[4] > one char (unlike [2])
  let colNo = GetColNo()

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
    let b:cols[colNo] += diff
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
    if b:cols[colNo] > 2*diff
      " shorten tab
      let b:cols[colNo] -= diff
    endif
  endif
  " reset tabstops
  exe expand('set vartabstop='.ArrayString(b:cols))
  " replace the header
  exe expand("1s/.*/".header)
  " return to starting point
  exe expand(col.','.row)
  " move to next column
  echo expand('Column '.(colNo+1)." now ".b:cols[colNo]." wide")
  " redraws the conceals
  set syntax=tab
endfu

" Cell navigation

fu! GoCol(n)
  " move n tabs, return colNo or -1 if on new line
  let n = a:n
  let line = line('.')
  normal 0
  noh
  let @/="\t"
  if n > 0
    if getline('.')[0] == "\t"
      let n -= 1
    endif
    if n > 0
      silent! exe expand("normal ".n."n")
    endif
    normal l
  endif
  if line != line('.')
    return -1
  endif
  return a:n
endfu

fu! GoRowCol(row,col)
  exe expand("0,".a:row)
  call GoCol(a:col)
endfu

fu! NextCol()
  call CellCollapse()
  call GoCol(GetColNo()+1)
  call CellExpand()
  set cursorcolumn
endfu

fu! PrevCol()
  call GoCol(GetColNo()-1)
  call CellExpand()
  set cursorcolumn
endfu

" Entry mode

fu! EnterDown()
  " go down one row or add when at bottom
  if line('.') == line('$')
    normal o	
  else
    if getline('.')[getcurpos()[2]-1] == "\t"
      normal jl
    else
      normal j
    endif
  endif
  call Status()
endfu

fu EnterRight()
  " go to next column
  let col = getcurpos()[2]
  let line = getline('.')
  if col > 1 && line[col-1] == "\t"
    normal l
  endif
  call NextCol()
  call NextCol()
  normal h
  call Status()
endfu

fu! RowWise()
  " in insert mode, <ENTER> advances to the right
  inoremap <buffer><ENTER>    <ESC>:call EnterRight()<CR>i
  inoremap <buffer><S-Enter>  <ESC>:call EnterDown()<CR>i
  let g:TabMode = expand('RowWise')
  call Status()
endfu

fu! ColWise()
  " in insert mode, <ENTER> advances to the next row
  inoremap <buffer><ENTER>   <ESC>:call EnterDown()<CR>i
  inoremap <buffer><S-ENTER> <ESC>:call EnterRight()<CR>i
  let g:TabMode = expand('ColWise')
  call Status()
endfu


fu! FoldTable(lnum)
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
    endif
endfu


" ====================
"    Cell Yanking
" ====================

fu! YankCell()
  let row = getcurpos()[1]
  let colNo = GetColNo()
  let @+ = GetCell(row,colNo)
endfu

fu! ReplaceCell(content)
  " content = '': delete the cell or
  " content = '\t': empty the cell
  " let row = GetCellOrigin()
  " exe expand("normal ".row."G")
  let row = getcurpos()[1]
  let colNo = GetColNo()
  let @+ = GetCell(row,colNo)
  call SetCell(row,colNo,a:content)
  call GoCol(colNo)
endfu

" ====================
"    Text truncing
" ====================

fu! CellCollapse()
  " shorten to width and save content to file
  let row = getcurpos()[1]
  let colNo = GetColNo()
  if colNo < len(b:cols) | let width=b:cols[colNo] | else | let width=30 | endif
  let cell = GetCell(row,colNo)
  if len(cell) > width && match(cell,"<\\d\\+\\t") == -1
    " cell is too wide and not collapsed > collapse
    if width > 6 | let width = width - 4 | endif
    let i = 1
    let fname = Deslash(split(cell,"; ")[0][:width])."<"
    while filereadable(".".fname.i)
      let i+=1
    endwhile
    " Save full cell content and replace with filename
    let text = substitute(cell,'\n\s\+','\n','g')
    let text = substitute(text,'; ','\n','g')
    let text = substitute(text,'\t','','g')
    let text = split(text,"\n")
    call writefile(text,".".fname.i)
    exe expand("s/".Escape(cell)."/".fname.i."\t/")
  endif
  call GoRowCol(row,colNo)
endfu

fu! CellExpand()
  " Expand cell content from file
  let &undolevels=-1
  normal mu
  let row = getcurpos()[1]
  let colNo = GetColNo()
  let cell = GetCell(row,colNo)
  if match(cell,"<\\d\\+\\t") > -1
    let fname = ".".Deslash(cell)
    if filereadable(fname)
      let text  = join(readfile(".".Deslash(cell)),"\r")
      silent! exe expand("!rm '.".cell[:-2]."'")
      exe expand("s/".Escape(cell)."/".Rescape(text)."\t/")
    else
      echo "[top-table] WARNING: ".fname." not found"
    endif
  else
    if filereadable(".".Deslash(cell))
      " cell that was collapsed (not wide enough), but was externally edited
      let text  = join(readfile(".".Deslash(cell)),"\r")
      call SetCell(row,colNo,Rescape(text)."\t")
    endif
  endif
  normal `u
  call Status()
  set nocursorcolumn
  let &undolevels=1000
endfu


fu! ExpandCells()
  let rowNo = getcurpos()[1]
  let colNo = GetColNo()
  let row = 1
  while row <= line('$')
    exe expand("normal ".row."G")
    let col = 0
    while GoCol(col) != -1
      call CellExpand()
      let col += 1
    endwhile
    let row += 1
  endwhile
  call GoRowCol(rowNo,colNo)
endfu

fu! CollapseCells()
  let rowNo = getcurpos()[1]
  let colNo = GetColNo()
  let row = 1
  while row <= line('$')
    exe expand("normal ".row."G")
    let col = 0
    while GoCol(col) != -1
      call CellCollapse()
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
  let colNo = GetColNo()
  let width = b:cols[colNo]
  let cell = GetCell(row,colNo)
  normal `c
  if len(cell) > width
    call CellCollapse()
  else
    call CellExpand()
  endif
endf


fu SplitView()
  " Open cell conent in split view"
  let origin = expand("%:t")
  let fname = expand("<cword>")
  let width = 60
  if fname[-4:] != ".tab" && &filetype == "tab"
    call CellExpand() "update file name to latest content
    call CellCollapse()
    let row = getcurpos()[1]
    let colNo = GetColNo()
    let fname = split(GetCell(row,colNo),"\t")[0]
    let width = b:cols[colNo]
  endif
  if !filereadable(fname) && fname[0] != "." | let fname = ".".fname | endif
  let win = tabpagewinnr(1)
  wincmd l
  if win != tabpagewinnr(1)
    " a step to the right was possible, i.e. there was a free window in
    " which to create vertical splits
    exe expand("split ".fname)
  else
    " create a split to the right
    exe expand("vs ".fname)
  endif
  if !filereadable(fname)
    " this is a new file (wide col - no collapse was needed)
    " add cell content
    if fname[0] == "." | let fname = fname[1:] | endif
    exe "s/^/".fname."/"
  endif
  if getline('$')[0] == '#' && match(getline('$'),origin) == -1
    " add reference to original file
    exe "$s/$/ ".origin."/"
    normal gg
  endif
  if fname[-4:] != ".tab"
    set ft=cell
    set syntax=cell
    exe "vertical resize ".width
  endif
endfu

fu CloseCellView()
  " Close split view and update cell content (XXX update cell content if no
  " collapse needed)
  w
  bd
endfu

" ====================
"   Conversion md pdf
" ====================

fu MarkdownTable()
  " convert to markdown table
  call ExpandCells()
  let l = 1
  let separator = '  '
  let md = "--\n"
  while l <= line('$')
    let colNo = 0
    while GoCol(colNo+1) > GoCol(colNo)
      let cell = GetCell(l,colNo)
      if cell == "\t"
        let cell = ""
      else
        let cell = split(cell,"\t")[0]
      endif
      let padding = b:cols[colNo] - len(cell)
      let md .= cell.repeat(" ",padding).separator
      let colNo += 1
    endwhile
    let md .= "\n\n"
    if l == 1
      for col in b:cols
        let md .= repeat('-',col).separator
      endfor
      let md .= "-\n"
      " let separator = '\ '
    endif
    let l += 1
  endwhile
  let md .= "--\n\n"
  let  md = split(md,"\n")
  call writefile(md,expand("%:t:r").".md")
endfu

fu PdfTable()
  call MarkdownTable()
  let fname = expand("%:t:r")
  exe "!pandoc -s -f markdown+smart+multiline_tables ".fname.".md -o ".fname.".pdf"
endfu

fu DocTable()
  call MarkdownTable()
  let fname = expand("%:t:r")
  exe "!pandoc -s -f markdown+smart+multiline_tables ".fname.".md -o ".fname.".docx"
endfu

" ====================
"   Spreadsheetish
" ====================

fu! Increment()
  let row = getcurpos()[1]
  let colNo = GetColNo()
  let content = GetCell(row,colNo)
  let pretext = ""
  if content/content != 1
    let pretext = content[:-2]
  endif
  while row < line('$')
      let content += 1
      call SetCell(row,colNo,pretext.content. "\t")
      let row += 1
  endwhile
endfu

fu! Calc(operand)
  " sums up column and inserts sum / avg
  let bottomline = getcurpos()[1]
  let colNo = GetColNo()
  let sum = 0
  let cnt = 0
  let row = 1
  while row < bottomline
    let col = GetCell(row,colNo)
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
  call SetCell(row,colNo,result."\t")
  if (row-cnt-2) == 0
    echo join(["Sum:", sum, " Avg: ", sum/cnt, " Count:",cnt])
  else
    echo join(["Sum:", sum, " Avg: ", sum/cnt, " Count: ",cnt," Invalid: ", row-cnt-2])
  endif
endfu

" ====================
"     Backup
" ====================

fu! Backup()
  let original = expand("%")
  call ExpandCells()
  exe "!cp ".original." ".original."le"
  call CollapseCells()
endfu


" ==============
"  Commands
" ==============

command! Help     :h top-table-keys
command! Header   :call Header()
command! Backup   :call Backup()

" Entry mode: downwards or sidewards
command! ColWise   :call ColWise()
command! RowsWise   :call RowWise()

" Column sizing
command! Fit           :call FitColumns()
command! Fix           :call FixColumns()
command! ExpandCells   :call ExpandCells()
command! CollapseCells :call CollapseCells()
command! DeleteColumn  :call DeleteColumn()
command! InsertColumn  :call InsertColumn(0)
command! AddColumn     :call InsertColumn(1)

" Conversion

command! MarkdownTable :call MarkdownTable()
command! PdfTable      :call PdfTable()
command! DocTable      :call DocTable()

" Calculations
command! Increment     :call Increment()
command! Sum           :call Calc('sum')
command! Avg           :call Calc('avg')

inoremap ;; <Enter>
