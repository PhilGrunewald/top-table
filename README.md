# Vim-table

## Introduction

This vim plugin was created to simply lay out and edit tables. 
For some reason spreadsheets have taken over and there wasn't 
anything out there that brought the simplicity of vim editing
to tables. Visidata and Sc-im are powerful tools, but often I
just want to list information, without fancy spreadsheet tools.

Vim-table let's you

- size column widths
- conceal long lines
- move row, columns and cells around
- auto populate sequential numbers
- <ENTER> auto advances in rows or columns


## Key bindings

Key (normal mode)
-------------
  <TAB>      ⇥   next col
  <S-TAB>   ⇧⇥   prev col
  <RIGHT>    ▶   widen col
  <LEFT>     ◄   narrow col
  <S-RIGHT> ⇧▶   move col right
  <S-LEFT>  ⇧◄   move col left
  <UP>       ▲   move row up
  <DOWN>     ▼   move row down
  <S-ENTER> ⇧⏎   open in visidata
  \p             create markdown
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

20 Apr 23   v0.1   Phil Grunewald      Initial version with helpfile
