-- This file is for autocommands

-- Define augroups to organize autocommands.
local augroup = vim.api.nvim_create_augroup('UserGeneral', { clear = true })
local large_file_group = vim.api.nvim_create_augroup('LargeFileHandler', { clear = true })

-- Define the size limit for large files (1 MB).
local MAX_FILESIZE = 1 * 1024 * 1024

-- ===================================================================
--  General User Experience Autocommands
-- ===================================================================

-- 1. Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ timeout = 200 })
  end,
  desc = 'Highlight yanked text',
})

-- 2. Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup,
  pattern = '*',
  callback = function()
    if vim.bo.buftype ~= '' then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)

    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
  desc = 'Go to last edit position',
})

-- 3. Set filetype-specific indentation
vim.api.nvim_create_autocmd('FileType', {
  group = augroup,
  pattern = { 'python', 'go' },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
  desc = 'Set indentation for Python and Go',
})

-- ===================================================================
--  Performance Autocommand for Large Files
-- ===================================================================

-- 4. Disable slow features for files larger than 1MB
vim.api.nvim_create_autocmd('BufReadPost', {
  group = large_file_group,
  pattern = '*',
  callback = function(args)
    local bufnr = args.buf
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))

    if ok and stats and stats.size > MAX_FILESIZE then
      vim.notify_once(
        ('Performance mode activated for large file (>%.1f MB)'):format(MAX_FILESIZE / 1024 / 1024),
        vim.log.levels.WARN,
        { title = 'Large File' }
      )
      vim.wo.foldmethod = 'manual'
      vim.wo.spell = false
      vim.wo.relativenumber = false
    end
  end,
  desc = 'Disable slow features for files larger than 1MB',
})
