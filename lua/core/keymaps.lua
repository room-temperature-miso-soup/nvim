-- lua/core/keymaps.lua
-- This file contains all non-plugin-specific keymaps
local keymap = vim.keymap.set

-- =======================================================
-- == SCRATCH BUFFER KEYMAP
-- =======================================================
-- Load the scratch module once at the top level
local scratch = require('core.scratch')

-- Use the loaded module directly
keymap('n', '<leader>.', scratch.toggle, { desc = 'Toggle persistent scratch buffer' })

-- =======================================================
-- General Keymaps
keymap('n', '<leader>c', ':nohlsearch<CR>', { desc = 'Clear search highlights' })

-- Buffer navigation
keymap('n', '<leader>bn', ':bnext<CR>', { desc = 'Next buffer' })
keymap('n', '<leader>bp', ':bprevious<CR>', { desc = 'Previous buffer' })
keymap('n', '<leader>bd', ':bdelete<CR>', { desc = 'Close current buffer' })

-- Move lines up/down
keymap('n', '<C-A-j>', ':m .+1<CR>==', { desc = 'Move line down' })
keymap('n', '<C-A-k>', ':m .-2<CR>==', { desc = 'Move line up' })
keymap('v', '<C-A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
keymap('v', '<C-A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })

-- Better indenting in visual mode
keymap('v', '<', '<gv')
keymap('v', '>', '>gv')

-- Better J behavior
keymap('n', 'J', 'mzJ`z', { desc = 'Join lines and keep cursor position' })

-- Copy file path
keymap('n', '<leader>pa', function()
  local path = vim.fn.expand('%:p')
  vim.fn.setreg('+', path)
  print('Copied file path: ' .. path)
end, { desc = 'Copy full file path' })
