-- This file is for general editor settings (vim.opt)

local opt = vim.opt

-- Basic settings
opt.number = true          -- Line numbers
opt.relativenumber = true  -- Relative line numbers
opt.cursorline = true      -- Highlight current line
opt.wrap = false           -- Don't wrap lines
opt.scrolloff = 10         -- Keep 10 lines above/below cursor
opt.sidescrolloff = 8      -- Keep 8 columns left/right of cursor

-- Indentation
opt.tabstop = 2       -- Tab width
opt.shiftwidth = 2    -- Indent width
opt.softtabstop = 2   -- Soft tab stop
opt.expandtab = true  -- Use spaces instead of tabs
opt.smartindent = true
opt.autoindent = true

-- Search settings
opt.ignorecase = true  -- Case insensitive search
opt.smartcase = true   -- Case sensitive if uppercase in search
opt.incsearch = true   -- Show matches as you type
opt.hlsearch = true    -- Highlight search results

-- Visual settings
opt.termguicolors = true   -- Enable 24-bit colors
opt.signcolumn = 'yes'     -- Always show sign column
opt.showmatch = true       -- Highlight matching brackets
opt.matchtime = 2          -- How long to show matching bracket
opt.cmdheight = 1          -- Command line height
opt.pumheight = 10         -- Popup menu height
opt.showmode = false       -- Don't show mode in command line

-- File handling
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.updatetime = 300       -- Faster completion
opt.timeoutlen = 500       -- Key timeout duration

-- Behavior
opt.hidden = true                        -- Allow hidden buffers
opt.errorbells = false                   -- No error bells
opt.mouse = 'a'                          -- Enable mouse support
opt.clipboard:append('unnamedplus')      -- Use system clipboard
opt.splitright = true                    -- New vertical splits to the right
opt.splitbelow = true                    -- New horizontal splits below


local undodir = vim.fn.stdpath('data') .. '/undodir'

if not vim.loop.fs_stat(undodir) then
  vim.fn.mkdir(undodir, 'p')
end

opt.undodir = undodir
