=====================================================
  MY NEOVIM CHEAT SHEET
=====================================================

The "Leader" key for all shortcuts is <Spacebar>.
When you see <leader>ff, it means: Press Space, then f, then f.


---------------------
-- CORE NAVIGATION --
---------------------
<leader>ff     : Find File (Fuzzy find any file in your project)
<leader>fg     : Find Grep (Search for text in all files)
<leader>/      : Find Grep (Alternative for searching text)
<leader>fb     : Find Buffers (Search your currently open files)
- (dash)       : Open File Explorer in the current directory


------------------------
-- CODE INTELLIGENCE --
------------------------
K (Shift+k)    : Hover / Show Info (Show documentation and errors for word under cursor)
gd             : Go to Definition (Jump to where a variable/function is defined)
gr             : Go to References (Show all uses of a variable/function)
]d             : Next Diagnostic (Jump to the next error/warning)
[d             : Previous Diagnostic (Jump to the previous error/warning)
<leader>dt     : Toggle Diagnostic Level (Cycle: Errors only -> Errors+Warnings -> All)
<leader>fm     : Format File (Clean up indentation and style)
<leader>rn     : Rename Symbol (Safely rename a variable everywhere)
<leader>ca     : Code Action (Show context menu, e.g., "add missing import")


------------------------
-- EDITING & WINDOWS --
------------------------
<leader>.      : Scratchpad (Open/close a floating notepad for temporary notes)
<leader>bn     : Buffer Next (Switch to the next open file)
<leader>bp     : Buffer Previous (Switch to the previous open file)
<leader>bd     : Buffer Delete (Close the current file)

-- COPY & PASTE (Uses your main system clipboard) --
yy             : Copy the whole line
dd             : Cut the whole line
v + move + y   : VISUAL MODE -> highlight text -> YANK (copy) selection
p              : Paste after the cursor

-- MOVING LINES --
Ctrl + Alt + j        : Move current line (or selection) down
Ctrl + Alt + k        : Move current line (or selection) up


-----------------
-- UTILITIES --
-----------------
<leader>c      : Clear Search Highlights (Removes the yellow highlights from '/')
<leader>sm     : Show Messages (See Neovim's internal log for debugging)
<leader>pa     : Path Absolute (Copy the full path of the current file)
