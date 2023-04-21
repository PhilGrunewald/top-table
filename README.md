# Vim-table

## Introduction

This vim plugin was created to simply lay out and edit tables. 
For some reason spreadsheets have taken over and there wasn't 
anything out there that brought the simplicity of vim editing
to tables. Visidata and Sc-im are powerful tools, but often I
just want to list information, without fancy spreadsheet tools.

- move cells around with H,J,K,L
- size column widths with <LEFT>,<RIGHT>
- auto-conceal long lines to fit column width
- move whole rows/columns with <UP>,<DOWN>,<S-LEFT>,<S-RIGHT>
- In insert mode <ENTER> can auto advances in rows or columns
- auto populate sequential numbers

*Extension* Files ending in `.tab` are autodetected. Alternatively use `:set ft=tab` 

*Delimiter* The default delimiter is <TAB>. If the header line contains no <TAB>, but it does contain a comma, all commas are replaced with tabs. To convert back to `csv` use *<leader>,* before saving. To continue/revert to <TAB> functionality use *:edit* .


## Key bindings

Key (normal mode)
-------------
-

  <TAB>      ⇥   next col

  <S-TAB>   ⇧⇥   prev col

  <RIGHT>    ▶   widen col

  <LEFT>     ◄   narrow col

  <S-RIGHT> ⇧▶   move col right

  <S-LEFT>  ⇧◄   move col left

  <UP>       ▲   move row up

  <DOWN>     ▼   move row down

  <S-ENTER> ⇧⏎   open in visidata

  <leader>p      create markdown

  <leader>,      turn into csv

  H              move cell left

  L              move cell right

  K              move cell up

  J              move cell down

  ++             fill column with incremental numbers

Key (insert mode)
-------------

  <ENTER>    ⏎   next col/row (see Right/Down mode)

  <S-ENTER> ⇧⏎   add new row



## Commands

*Help*         open this file in split view

*Increment*    fill column with incremental numbers

*Fit*          size columns to longest element

*Fix*          size columns to 10 wide

*Visidata*     open this file in visidata

*Right*        <ENTER> advances to the next column 
             (when insert mode)
*Down*         <ENTER> advances to the next row
             (when insert mode)

## Revision history

21 Apr 23   v1.0   Phil Grunewald      Auto comma conversion
20 Apr 23   v0.1   Phil Grunewald      Initial version with helpfile
