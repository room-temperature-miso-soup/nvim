-- This file is for autocommands

local am smgroup = vim.api.nvim_create_augroup('UserConfig', { clear = true })

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
  desc = 'Highlight yanked text',
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  pattern = '*',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = 'Go to last edit position',
})

-- Set filetype-specific indentation
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'python', 'go' },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})
