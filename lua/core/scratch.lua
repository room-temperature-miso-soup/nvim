-- lua/core/scratch.lua
-- This module contains all logic for the persistent scratch buffer.
local M = {}

-- Configuration
local SCRATCH_FILE = vim.fn.stdpath('data') .. '/scratch_buffer.md'

-- Helper function to find our existing scratch buffer
local function find_scratch_buffer()
  for _, buf in ipairs(vim.fn.getbufinfo({ buflisted = true })) do
    if vim.b[buf.bufnr].is_scratch then
      return buf.bufnr
    end
  end
  return nil
end

-- Save scratch buffer content to file (enhanced with error handling)
local function save_scratch_content(buf_id)
  if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then 
    return false
  end
  
  local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
  local content = table.concat(lines, '\n')
  
  -- Create directory if it doesn't exist
  local dir = vim.fn.fnamemodify(SCRATCH_FILE, ':h')
  local ok = vim.fn.mkdir(dir, 'p')
  if ok == 0 then
    vim.notify("Failed to create scratch directory: " .. dir, vim.log.levels.ERROR)
    return false
  end
  
  -- Write content to file
  local file, err = io.open(SCRATCH_FILE, 'w')
  if not file then
    vim.notify("Failed to open scratch file for writing: " .. (err or "unknown error"), vim.log.levels.ERROR)
    return false
  end
  
  local write_ok = file:write(content)
  file:close()
  
  if not write_ok then
    vim.notify("Failed to write to scratch file", vim.log.levels.ERROR)
    return false
  end
  
  return true
end

-- Load scratch buffer content from file
local function load_scratch_content(buf_id)
  if not vim.fn.filereadable(SCRATCH_FILE) then 
    return 
  end
  
  local file, err = io.open(SCRATCH_FILE, 'r')
  if not file then
    vim.notify("Failed to open scratch file for reading: " .. (err or "unknown error"), vim.log.levels.WARN)
    return
  end
  
  local content = file:read('*all')
  file:close()
  
  if content and content ~= '' then
    local lines = vim.split(content, '\n')
    vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  end
end

-- Setup auto-save for scratch buffer (enhanced with more triggers)
local function setup_scratch_autosave(buf_id)
  local group = vim.api.nvim_create_augroup('ScratchBuffer_' .. buf_id, { clear = true })
  
  -- Auto-save on text changes
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = group, 
    buffer = buf_id, 
    callback = function() 
      save_scratch_content(buf_id) 
    end,
  })
  
  -- Save when leaving buffer
  vim.api.nvim_create_autocmd('BufLeave', {
    group = group, 
    buffer = buf_id, 
    callback = function() 
      save_scratch_content(buf_id) 
    end,
  })
  
  -- Save when buffer is hidden
  vim.api.nvim_create_autocmd('BufHidden', {
    group = group, 
    buffer = buf_id, 
    callback = function() 
      save_scratch_content(buf_id) 
    end,
  })
  
  -- Save when focus is lost
  vim.api.nvim_create_autocmd('FocusLost', {
    group = group, 
    callback = function() 
      save_scratch_content(buf_id) 
    end,
  })
end

-- Global save function that finds and saves any active scratch buffer
local function save_active_scratch()
  local scratch_buf = find_scratch_buffer()
  if scratch_buf then
    save_scratch_content(scratch_buf)
  end
end

-- Setup global exit handlers (called once when module is loaded)
local function setup_global_exit_handlers()
  local group = vim.api.nvim_create_augroup('ScratchBufferGlobal', { clear = true })
  
  -- Multiple exit events to catch different shutdown scenarios
  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group, 
    callback = save_active_scratch,
  })
  
  vim.api.nvim_create_autocmd('VimLeave', {
    group = group, 
    callback = save_active_scratch,
  })
  
  vim.api.nvim_create_autocmd('ExitPre', {
    group = group, 
    callback = save_active_scratch,
  })
end

-- The main toggle function, now part of our module
function M.toggle()
  local scratch_buf = find_scratch_buffer()
  
  if scratch_buf then
    vim.cmd.buffer(scratch_buf)
  else
    vim.cmd.enew()
    local buf_id = vim.api.nvim_get_current_buf()
    
    -- Configure buffer settings
    vim.bo.buftype = 'nofile'
    vim.bo.bufhidden = 'hide'
    vim.bo.swapfile = false
    vim.bo.filetype = 'markdown'
    vim.b.is_scratch = true -- Mark the buffer
    
    -- Load previous content
    load_scratch_content(buf_id)
    
    -- Setup auto-save for this buffer
    setup_scratch_autosave(buf_id)
    
    -- Buffer-specific keymaps
    vim.keymap.set('n', 'q', function() 
      save_scratch_content(buf_id)
      vim.cmd('bdelete!') 
    end, { silent = true, buffer = true, desc = 'Close scratch buffer' })
    
    vim.keymap.set('n', '<leader>ss', function() 
      if save_scratch_content(buf_id) then
        vim.notify("Scratch buffer saved!", vim.log.levels.INFO, { title = "Scratch" })
      end
    end, { silent = true, buffer = true, desc = 'Save scratch buffer' })
    
    vim.notify("Scratch buffer ready (auto-saves, 'q' to close)", vim.log.levels.INFO, { title = "Scratch" })
  end
end

-- Manual save function for external use
function M.save()
  save_active_scratch()
end

-- Debug function to check file status
function M.debug()
  local scratch_buf = find_scratch_buffer()
  print("Scratch buffer ID:", scratch_buf)
  print("Scratch file path:", SCRATCH_FILE)
  print("File exists:", vim.fn.filereadable(SCRATCH_FILE) == 1)
  if vim.fn.filereadable(SCRATCH_FILE) == 1 then
    print("File size:", vim.fn.getfsize(SCRATCH_FILE))
  end
end

-- Create the user command
vim.api.nvim_create_user_command('ScratchClear', function()
  if vim.fn.filereadable(SCRATCH_FILE) then
    vim.fn.delete(SCRATCH_FILE)
    vim.notify("Scratch file cleared!", vim.log.levels.INFO, { title = "Scratch" })
  else
    vim.notify("No scratch file to clear", vim.log.levels.INFO, { title = "Scratch" })
  end
end, { desc = 'Clear persistent scratch buffer file' })

-- Add debug command
vim.api.nvim_create_user_command('ScratchDebug', M.debug, { desc = 'Debug scratch buffer status' })

-- Add manual save command
vim.api.nvim_create_user_command('ScratchSave', M.save, { desc = 'Manually save scratch buffer' })

-- Setup global handlers when module is loaded
setup_global_exit_handlers()

return M
