hi CursorLine    ctermbg=235

hi Conceal     ctermfg=green  ctermbg=none
hi NonText     ctermfg=black  ctermbg=none

syn match CellCollapsed  /\zs<\d\+\ze\t/ conceal cchar=…
syn match TableTag    "\.tab" conceal cchar=≫
