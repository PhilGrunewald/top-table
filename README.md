Vim plugin for simple table navigation and editing

CONTENTS
========

    1. Introduction ......... |top-table-intro|
    2. Key bindings ......... |top-table-keys|
    3. Commands ............. |top-table-commands|
    4. Revision history ..... |top-table-revisions|


# 1. Introduction


Edit tabular data with the power of vim.
This is not a spreadsheet (|^1|) plugin. It's a tool to navigate and organise
tables with maximum efficiency.

Top-table let's you

- |MoveCells|, |MoveRow| and |MoveColumn|
- |ResizeColumn|
- |CollapseCells| to fit columns
- Edit |Multiline| cells
- Nest and access tables with |SplitView|
  Export to |MarkdownTable| or |PdfTable| or |DocTable|
- |Increment| columns with sequential numbers
- |Sum| columns

*^1* see Visidata and Sc-im for spreadsheet tools


*MoveCells*
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
(normal mode)

Normal `hjkl` with `<Ctrl>` moves (bubbles) rows up/down and columns left/right.

            `<C-k>`
             up

   `<C-h>`  `Row/Column`  `<C-l>`
   left               right
            `<C-j>`
            down

*ResizeColumn*
(normal mode)

   <S-Left>    `Column`    <S-Right>
   narrower                wider

*Collapse* long cells to column width

A Cell that is wider than the column can be truncated.

| R1C1   |  R1C2  |  R1C3 |
| ______ | _______ | ______ |
| R2C1   |  Col2 with much to say |  R2C3 |

becomes

| R1C1   | R1C2   | R1C3 |
| ______ | ______ | ______ |
| R2C1   | Col2 … | R2C3 |


*CellToggle*     `>>`     toggle this cell
*CollapseCells*  `<C-,,>` (Ctrl <<) collapse all cells
*ExpandCells*    `<C-..>` (Ctrl >>) open all cells

|CollapseCells| shortens the content of all cell and replaces the end of the
enrtry with `<123` (concealed as `…`), where `<` indicates that the entry has
been collapsed and `123` is a sequential number by which the file containing
the full content of the cell can be uniquely identified. The filename is the
same as the remaining cell content with a leading `.` to hide it. When the
cell is expanded, this file is deleted.

Cells are automatically expanded when entered normal mode or when switching to
insert mode with `i`.

When opening a cell in a `different column` all cells in other columns are
closed.

*Multiline*

A `;` inside a cell denotes a line break. The semicolons will become line
breaks when the cell is displayed in |SplitView| with `<S-Enter>`. When
collapsing a multiline cell, only the text up to the first semicolon is kept
as the label.


R1C1   >  R1C2  >  R1C3
_______________________
R2C1   >  Row; with much; to say >  R2C3

This toggles to:

R1C1   >  R1C2  >  R1C3
_______________________
R2C1   >  Row  …>  R2C3

*SplitView*                                                         *<S-Enter>*

Expanding a cell with `<S-Enter>` opens splits on the right to display the
text over multiple lines for easy editing.

R1C1   >  R1C2  >  R1C3  | Row
_______________________  | with much
R2C1   >  Row  …>  R2C3  | to say

If the cell happens to end in `.tab`, it is treated as a link. The
corresponding `.tab` file is opened (or created) in a split to the right.

R1C1   >  R1C2           ||  T2C1     >  T2C2
____________________     ||  Nested   >  table
R2C1   >  subtable≫      ||  with     >  optional back reference
                         ||  # master≫

To keep a back reference to the file from which this table was opened, add a
`#` to the start of the last line and toggle the cell. Next time the file name
is added, such that it, too, can be used as a link back with `<S-Enter>`

*LineBreaks*                                                               *;;*

With `<Enter>` being mapped to advance through cells in insert mode, it cannot
be used to "break" a line into two. Strictly speaking, that shouldn't be
necessary and one could delete the remainder of a line, add a line below and
paste (`Do<ESC>p`). To make it a bit quicker, there is a `;;` mapping for
that. (Turns out I use that more than I thought I would)


*Increment*  `++`     insert sequential numbers for all columns 
                  below the current one. If a numeric value is present,
                  the sequence starts with that number.

*Sum*        `==`     Adds all numerical values above this cell
                  Inserts the result.

CONVENTIONS

*File-type* Files ending in `.tab` are autodetected. Alternatively use `:set ft=tab`

*Delimiter* The default delimiter is <TAB>. If the header line contains no
<TAB>, but it does contain a comma, all commas are replaced with tabs. To
convert back to `csv` use *<leader>,* before saving. To continue/revert to
<TAB> functionality use *:edit* .

Every line should end with a <Tab>. These are automatically added if not
entered manually.

WARNING
When saving the file with collapsed cells, the hidden files must be kept with
the main file for the content to be restored. It is advisable to |ExpandCells|
before saving the file (see |Backup|).
The file behind a collapsed cell is cleaned up (deleted) when the cell is
expanded. To avoid inadvertent data loss, the `undolevels` history is reset
(collapsing the cell again via `undo` could not restore that file).


# 2. Key bindings

Key (normal)
-------------
  `<TAB>`          next col
  `<S-TAB>`        prev col
  `<S-Enter>`      |SplitView| display content in right split

  `cl`             |MoveCells| right
  `ch`             |MoveCells| left
  `ck`             |MoveCells| up
  `cj`             |MoveCells| down

  `yc`             yank cell
  `dc`             delete cell content
                 yank register includes trailing <Tab>

  `dd`             delete row
  `DD`             |DeleteColumn|
  `<C-i>`          |InsertColumn| left
  `<C-I>`          |AddColumn| right
  `O`              insert row above
  `o`              insert row below

  `<C-l>`          |MoveColumn| right
  `<C-h>`          |MoveColumn| left
  `<C-k>`          |MoveRow| up
  `<C-j>`          |MoveRow| down

  `>>`             |CellToggle| full width / column width
  `<C-..>`         |ExpandCells| Expand all cells
  `<C-,,>`         |CollapseCells| Collapse all cells

  `<S-Right>`      widen col
  `<S-Left>`       narrow col

  `<leader>p`      export to markdown and pdf
  `<leader>,`      turn into csv
  `++`             fill column with incremental numbers
  `==`             insert the sum of all numerical values in column above this row

Key (insert)
-------------
  `<Enter>`        Advance to next row/column (see |Entry-mode|)
  `;;`             Split line (what `<Enter>` would normally do)
  `;`              Gets treated as `\n` (looks neater and avoids escaping)


# 3. Commands

- *Help*           open this file in split view
- *Backup*         save a fully expanded copy with `.table` extension
- *Header*         split window to show header row fixed to top
- *InsertColumn*   Insert a blank column left of the current column
- *AddColumn*      Insert a blank column to the right
- *DeleteColumn*   Delete current column

- |Increment|      add incremental numbers for all cells below this one
- |Sum|            insert the sum of all numerical values above this cell
- *Avg*            insert the average of all numerical values in column above this row
- *Fit*            size columns to longest element
- *Fix*            size columns to 10 wide
- |ExpandCells|    Expand all cells to display their full content
- |CollapseCells|  Shorten all cells to fit within their columns

- *MarkdownTable*  Export to markdown for rendering with pandoc
  +multiline_table
- *PdfTable*       Export to PDF file
- *DocTable*       Export to Word .docx file
                 Each export creates the intermediate markdown file

- *Entry-mode* (in insert mode)
- *ColWise*        <ENTER> advances to the next column
- *RowWise*        <ENTER> advances to the next row

# 4. Revision history

21 May 23   v3.3   Phil Grunewald

    - Open multiline cells or nested tables in split views (`S-Enter`)
    - No more mutiline expansion - use `;` instead - much cleaner
      implementation and no issues with lines that don't end with a tab
    - moved all funcitons into `plugin` folder (avoids function
      redefinition when opening .tab split view
    - Export to Markdown, PDF and Word
    - |LineBreak| with `;;`

11 May 23   v3.2   Phil Grunewald

    - |InsertColumn| / |DeleteColumn|
    - undo reset
    - first pieces of error handling (missing end <Tab>)
    - fix line breaks with NextCell
    - fix |Fit| end of row recognition

10 May 23   v3.1   Phil Grunewald

    - Undo block when expanding, otherwise the removed file is
    - EnterDown alignment fix
    - Cursor column highlighting
    - neater NextCol
    - Header split as command
    - Backup command

09 May 23   v3.0   Phil Grunewald      Multi-line support and bug fixes

05 May 23   v2.1   Phil Grunewald      LeftRight with <S> and <C> to save buffer cycling behaviour

04 May 23   v2.0   Phil Grunewald      Save hidden text to hidden files

22 Apr 23   v1.1   Phil Grunewald      Column sums / avg

21 Apr 23   v1.0   Phil Grunewald      Auto comma conversion

20 Apr 23   v0.1   Phil Grunewald      Initial version with helpfile
