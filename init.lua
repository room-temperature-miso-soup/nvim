-- ~/.config/nvim/init.lua

-- Set leader key before anything else
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load core configuration
require('core.options')
require('core.keymaps')
require('core.autocmds')
require('core.statusline')

-- Setup lazy.nvim and load plugins
require('lazy').setup('plugins')

-- =======================================================
-- == APPLY THE COLORSCHEME AFTER PLUGINS ARE LOADED    ==
-- =======================================================
vim.cmd.colorscheme('solarized-osaka')
-- =======================================================
