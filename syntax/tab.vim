hi CursorLine    ctermbg=235 cterm=none
hi CursorColumn  ctermbg=17
hi OpenEnd       ctermbg=238

hi Conceal     ctermfg=green  ctermbg=none
hi NonText     ctermfg=black  ctermbg=none
hi SpareSpace  ctermfg=black  cterm=underline
hi Header      ctermfg=white  cterm=bold,underline

" syn match Header     /\%1l.*/
syn match CellCollapsed  /\zs<\d\+\ze\t/ conceal cchar=…
syn match SpareSpace / \+\t/
syn match OpenEnd /[^\t]\+$/
syn match TableTag    "\.tab" conceal cchar=≫
syn match TSVTag      "\.tsv" conceal cchar=≫
