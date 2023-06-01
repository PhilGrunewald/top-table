" ====================
"   Buffer variables
" ====================

" column widths
let b:cols = []


" ====================
"     Settings
" ====================

setlocal listchars=tab:▸\       "show tabs as little arrows ,eol:¬
setlocal cursorline
setlocal iskeyword+=.       " to read filename.tab as one word

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
setlocal autoindent
setlocal nowrap
setlocal splitright          "cell content on right
setlocal splitbelow          "cell content top to bottom
setlocal conceallevel=2
setlocal concealcursor=n     "only expand in insert mode


" ====================
"     Mappings
" ====================

" ==============
"  Insert mode
" ==============

inoremap <TAB>   <TAB>

" Avoid Copilot to complete with <Tab>
imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

" ==============
"  Normal mode
" ==============

" avoid editing trimmed cells
nnoremap <buffer>i   mc:call CellExpand()<CR>`ci
nnoremap <buffer>O   O<Tab><Esc>i
nnoremap <buffer>k   k:call CellExpand()<CR>
nnoremap <buffer>j   j:call CellExpand()<CR>

nnoremap <buffer>yc  :call YankCell()<CR>
nnoremap <buffer>dc  :call ReplaceCell("\t")<CR>
nnoremap <buffer>DD      :DeleteColumn<CR>
nnoremap <buffer><C-i>   :InsertColumn<CR>
nnoremap <buffer><C-S-i> :AddColumn<CR>
nnoremap <buffer><TAB>   :call NextCol()<CR>
nnoremap <buffer><S-TAB> :call PrevCol()<CR>

" Row swapping (bubble up/down)
nnoremap <Up> ddkP
nnoremap <Down> ddp
vnoremap <Up> xkP`[V`]
vnoremap <Down> xp`[V`]

" Column/Row swapping
nnoremap <buffer><C-k>  gkmcgjddkP`cgk
nnoremap <buffer><C-j>  gjmcgkddp`cgj
nnoremap <buffer><C-l>  :call SwapCol(0)<CR>
nnoremap <buffer><C-h>   :call SwapCol(-1)<CR>

" Cell swapping
nnoremap <buffer>ck  :call SwapCell('k')<CR>
nnoremap <buffer>cj  :call SwapCell('j')<CR>
nnoremap <buffer>ch  :call SwapCell('h')<CR>
nnoremap <buffer>cl  :call SwapCell('l')<CR>

" Column sizing
nnoremap <buffer><S-Right>  :call ColWidth('+')<CR>
nnoremap <buffer><S-Left>   :call ColWidth('-')<CR>

" Fill with incremental values
nnoremap <buffer>++        :call Increment()<CR>
nnoremap <buffer>==        :call Calc('sum')<CR>

nnoremap <buffer><S-Enter> :call SplitView()<CR>

nnoremap <buffer>>>          :call CellToggle()<CR>
nnoremap <buffer><C-.><C-.>  :call ExpandCells()<CR>
nnoremap <buffer><C-,><C-,>  :call CollapseCells()<CR>

" Turn to markdown
nnoremap <buffer><leader>p  :call PdfTable()<CR>

  " execute '!pandoc -s -f markdown+smart+multiline_tables --variable urlcolor=blue --biblio '.expand('%:r').'.bib --citeproc .'.expand('%').' -o '.expand('%:r').'.pdf'
nnoremap <buffer><leader>,  :%s/\t/,/g<CR>


call Init()
