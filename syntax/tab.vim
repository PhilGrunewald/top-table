highlight CursorLine    ctermbg=235
highlight CursorColumn  ctermbg=17
highlight OpenEnd       ctermbg=238

highlight Conceal     ctermfg=green  ctermbg=none
highlight NonText     ctermfg=black  ctermbg=none
highlight SpareSpace  ctermfg=black  cterm=underline
highlight Header      ctermfg=white  cterm=bold,underline

" Below is very clever, as it conceals any overhang beyond the width
" of a column	
" Trouble is, the tab stopping is erratic
" let col = 0
" let tab = '[^\t]\{-}\t'
" let tabs = ''
" let charr = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
" while col < len(g:cols)
"   let cmd = 'syntax match Col'.charr[col%20].' "^'.tabs.'[^\t]\{'.expand(g:cols[col]-1).'}\zs[^\t]\{1,}\t\ze" conceal cchar=|'
"   execute cmd
"   let tabs = tabs.tab
"   let col += 1
" endwhile

" syntax match Header     /\%1l.*/
syntax match CellCollapsed  /\zs<\d\+\ze\t/ conceal cchar=…
syntax match SpareSpace / \+\t/
syntax match OpenEnd /[^\t]\+$/

