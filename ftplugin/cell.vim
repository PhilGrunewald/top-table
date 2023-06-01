setlocal iskeyword+=.       " to read filename.tab as one word
setlocal cursorline
setlocal wrap

nnoremap <buffer><S-Enter> :call CloseCellView()<CR>
