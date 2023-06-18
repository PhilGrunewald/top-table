" add *.tsv, *.csv as desired
au BufRead,BufNewFile *.tab set filetype=tab
au BufRead,BufNewFile *.tsv set filetype=tab

" switch to local directory (store and retrieve files locally)
au BufEnter *.tab lcd %:p:h
au BufEnter *.tsv lcd %:p:h
