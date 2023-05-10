# Top Table

Vim plugin for simple table organisation

CONTENTS                                          *top-table-contents*
====================================================================

    1. Introduction ......... |top-table-intro|
    2. Key bindings ......... |top-table-keys|
    3. Commands ............. |top-table-commands|
    4. Revision history ..... |top-table-revisions|


1. Introduction                                      *top-table-intro*
====================================================================

Edit tabular data with the power of vim.
This is not a spreadsheet (|x|) plugin, but a tool to navigate and organise tables with maximum efficiency.


Top-table let's you

- |MoveCells|
- |MoveRow| and |MoveColumn|
- |ResizeColumn|
- |CollapseCells| to fit columns
- Enter |Multiline| cells
- |Increment| columns with sequential numbers
- |Sum| columns

*x* see Visidata and Sc-im for full blown spreadsheet features



*MoveCells*
-----------

(normal mode)

Normal `hjkl` preceded with a `c` swaps the cell with its neighbour
left,below,above or right. The cursor stays with the cell as it moves.

             `ck`
             up

       `ch`   `CELL`   `cl`
      left        right
             `cj`
            down


*MoveRow* and *MoveColumn*
--------------------------

(normal mode)

Normal `hjkl` with <Carl> moves (bubbles) rows up/down and columns left/right.

            <C-k>
             up

   <C-h>  `Row/Column`  <C-l>
   left               right
            <C-j>
            down

*ResizeColumn*
--------------

(normal mode)

   <S-Left>    `Column`    <S-Right>
   narrower                wider

*Collapse* long cells to column width

A Cell that is wider than the column can be truncated.

R1C1   >  R1C2  >  R1C3
_______________________
R2C1   >  Col2 with much to say >  R2C3

becomes

R1C1   >  R1C2  >  R1C3
_______________________
R2C1   >  Col2 …>  R2C3


*CellToggle*     `>>`     toggle this cell

*CollapseCells*  `<C-,,>` (Ctrl <<) collapse all cells

*ExpandCells*    `<C-..>` (Ctrl >>) open all cells

|CollapseCells| shortens the content of all cell and replaces the end of the
enrtry with `<123` (concealed as `…`), where `<` indicates that the entry has been collapsed and
`123` is a sequential number by which the file containing the full content of the
cell can be uniquely identified. The filename is the same as the remaining
cell content with a leading `.` to hide it. When the cell is expanded, this
file is deleted.

Cells are automatically expanded when entered normal mode or when switching to insert mode with `i`.

When opening a cell in a `different column` all cells in other columns are
closed.

*Multiline*
-----------

Line breaks can be put into a cell with `<S-Enter>` or with a `;`. The
semicolons will be expanded into multiple lines on |CellToggle|. |ExpandCells|
turns all line breaks into semicolon separated single line entries.


R1C1   >  R1C2  >  R1C3
_______________________
R2C1   >  Row2 with much
          to say >  R2C3

This toggles to:

R1C1   >  R1C2  >  R1C3
_______________________
R2C1   >  Row2 …>  R2C3

With |ExpandCells| semicolons keep everything on single rows:

R1C1   >  R1C2  >  R1C3
_______________________
R2C1   >  Row2 with much; to say >  R2C3


NOTE Only one column can be opened at any one time.
Otherwise mulitiline entries also need delimiters - possible, but we want to keep things simple.

*Increment*  `++`     insert sequential numbers for all columns 
                       below the current one. If a numeric value is present,
                       the sequence starts with that number.

*Sum*             `==`     Adds all numerical values above this cell
                       Inserts the result.

CONVENTIONS
-----------

*File-type* Files ending in `.tab` are autodetected. Alternatively use `:set ft=tab`

*Delimiter* The default delimiter is <TAB>. If the header line contains no <TAB>, but it does contain a comma, all commas are replaced with tabs. To convert back to `csv` use *<leader>,* before saving. To continue/revert to <TAB> functionality use *:edit* .

WARNING
-------

When saving the file with collapsed cells, the hidden files must be kept with
the main file for the content to be restored. It is advisable to |TabExpand|
all cells before saving the file.

NOTE
----

Prior to V2.0 the shortening of cells was achieved with Conceal characters.
However, these were unreliable for consistent tabular widths.


====================================================================
2. Key bindings                                       *top-table-keys*

Key (normal)
-------------

-  `<TAB>`          next col
-  `<S-TAB>`        prev col
-  `<S-Enter>`      |Mulitiline| entry

-  `cl`             |MoveCells| right
-  `ch`             |MoveCells| left
-  `ck`             |MoveCells| up
-  `cj`             |MoveCells| down

-  `yc`             yank cell
-  `dc`             delete cell content
                    yank register includes trailing <Tab>

-  `<C-l>`          |MoveColumn| right
-  `<C-h>`          |MoveColumn| left
-  `<C-k>`          |MoveRow| up
-  `<C-j>`          |MoveRow| down

-  `>>`             |CellToggle| full width / column width
-  `<C-..>`         |ExpandCells| Expand all cells
-  `<C-,,>`         |CollapseCells| Collapse all cells

-  `<S-Right>`      widen col
-  `<S-Left>`       narrow col

-  `<leader>p`      create markdown (requires pandoc)
-  `<leader>,`      turn into csv
-  `++`             fill column with incremental numbers
-  `==`             insert the sum of all numerical values in column above this row

Key (insert)
-------------

  `<Enter>`        Advance to next row/column (see |Entry-mode|)


3. Commands                                       *top-table-commands*
====================================================================

- *Help*           open this file in split view
- |Increment|      fill column with incremental numbers
- |Sum|            insert the sum of all numerical values in column above this row
- *Avg*            insert the average of all numerical values in column above this row
- *Fit*            size columns to longest element
- *Fix*            size columns to 10 wide
- |ExpandCells|    Expand all cells to display their full content
- |CollapseCells|  Shorten all cells to fit within their columns

- *Entry-mode* (in insert mode)
- *ColWise*        <ENTER> advances to the next column
- *RowWise*        <ENTER> advances to the next row

4. Revision history                              *top-table-revisions*
====================================================================

- 09 May 23   v3.0   Phil Grunewald      Multi-line support and bug fixes
- 05 May 23   v2.1   Phil Grunewald      LeftRight with <S> and <C> to save
- buffer cycling behaviour
- 04 May 23   v2.0   Phil Grunewald      Save hidden text to hidden files
- 22 Apr 23   v1.1   Phil Grunewald      Column sums / avg
- 21 Apr 23   v1.0   Phil Grunewald      Auto comma conversion
- 20 Apr 23   v0.1   Phil Grunewald      Initial version with helpfile
