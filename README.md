# Vim-table

## Introduction

Vi-shing-table ("Wishing table") is a plugin to edit tabular data with the power of vim.
For some reason spreadsheets have taken over and there wasn't anything out there specifically for tables. Visidata and Sc-im are powerful tools, but often I
just want to organise information, without all that spreadsheet clobber.

vi-shing-table let's you

- move cells around with H,J,K,L
- size column widths with <LEFT>,<RIGHT>
- hide the overhang of lines to fit the column width with `>>`
- move whole rows/columns with <UP>,<DOWN>,<S-LEFT>,<S-RIGHT>
- In insert mode <ENTER> can auto advances in rows or columns
- auto populate sequential numbers

*File-type* Files ending in `.tab` are autodetected. Alternatively use `:set ft=tab`

*Delimiter* The default delimiter is <TAB>. If the header line contains no <TAB>, but it does contain a comma, all commas are replaced with tabs. To convert back to `csv` use *<leader>,* before saving. To continue/revert to <TAB> functionality use *:edit* .

|TabCollapse| shortens the content of a cell and replaces the end of the
enrtry with `<123` (concealed as `…`), where `<` indicates that the entry has been truncated and
`123` is a sequential number by which the file containing the remainder of the
cell can be uniquely identified. The filename is the same as the remaining
cell content with a leading `.` to hide it. When the cell is expanded, this
file is deleted.

WARNING
When saving the file with collapsed cells, the hidden files must be kept with
the main file for the content to be restored. It is advisable to |TabExpand|
all cells before saving the file.

NOTE
Prior to V2.0 the shortening of cells was achieved with Conceal characters.
However, these were unreliable for consistent tabular widths.

## Key bindings

Key (normal)
-------------
| Key         | Action                               |
| ----------- | ------------                         |
| <TAB>       |  next col |
| <S-TAB>     |  prev col |
| <RIGHT>     |  widen col |
| <LEFT>      |  narrow col |
| <S-RIGHT>   |  move col right |
| <S-LEFT>    |  move col left |
| <UP>        |  move row up |
| <DOWN>      |  move row down |
| <S-ENTER>   |  open in visa data |
| <leader>p   |  create markdown |
| <leader>,   |  turn into csv |
| *<C-..>*    |    |TabExpand| Expand all cells |
| *<C-,,>*    |    |TabCollapse| Collapse all cells |
| `>>`        |    toggle collapse/expand cell |
| `H`         |    move cell left |
| `L`         |    move cell right |
| `K`         |    move cell up |
| `J`         |    move cell down |
| `++`        |    fill column with incremental numbers |
| `==`        |    insert the sum of all numerical values in column above this row |

Key (insert mode)
-------------

| Key         | Action                             |
| ----------- | ------------                       |
| `<ENTER>`   | next col/row (see Right/Down mode) |
| `<S-ENTER>` | add new row                        |


## Commands

| Command     | Action                                                 |
| ----------- | ------------                                           |
| *Help*      | open this file in split view                           |
| *Increment* | fill column with incremental numbers                   |
| *Sum*       |  insert the sum of all numerical values in column above this row |
| *Avg*       |  insert the average of all numerical values in column above this row |
| *Fit*       | size columns to longest element                        |
| *Fix*       | size columns to 10 wide                                |
| *TabExpand*   |  Expand all cells to display their full content |
| *TabCollapse* | Shorten all cells to fit within their columns |
| *Visidata*  | open this file in visidata                             |
| *Right*     | `<ENTER>` advances to the next column (in insert mode) |
| *Down*      | `<ENTER>` advances to the next row (in insert mode)    |

## Revision history

| Date      | Ver.  | Author         | Updates                       |
| ----      | ----- | ------         | --                            |
| 04 May 23 | v2.0  | Phil Grunewald | Save hidden text to hidden files              |
| 22 Apr 23 | v1.1  | Phil Grunewald | Column sums / avg             |
| 21 Apr 23 | v1.0  | Phil Grunewald | Auto comma conversion         |
| 20 Apr 23 | v0.1  | Phil Grunewald | Initial version with helpfile |
