---- lua/core/statusline.lua
-- Simplified statusline with date/time and unsaved changes indicator

local M = {}

-- Configuration
local config = {
  separators = {
    left = '',
    right = '',
  },
}

-- Setup highlights for various components
local function setup_highlights()
  local highlights = {
    StatusLineModeNormal = { bg = '#268bd2', fg = '#fdf6e3', bold = true },
    StatusLineModeInsert = { bg = '#2aa198', fg = '#fdf6e3', bold = true },
    StatusLineModeVisual = { bg = '#b58900', fg = '#fdf6e3', bold = true },
    StatusLineModeCommand = { bg = '#d33682', fg = '#fdf6e3', bold = true },
    StatusLineModeReplace = { bg = '#cb4b16', fg = '#fdf6e3', bold = true },
    StatusLineModeTerminal = { bg = '#2aa198', fg = '#fdf6e3', bold = true },
    StatusLineDate= { bg = '#00568a', fg = '#fb8800', bold = true },
    StatusLineFile = { bg = '#000000', fg = '#d33682', bold = false },
    StatusLineWordCount = { bg = '#b58900', fg = '#000000', bold = false },
    StatusLineInactive = { bg = '#1f2335', fg = '#565f89', bold = false },
    -- Highlights for unsaved changes indicator
    UnsavedChangesRed = {  bg = '#000000', fg = '#ff0000' },
    UnsavedChangesGreen = {  bg = '#000000', fg = '#00ff00' },
  }
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Mode info with colors
local function mode_info()
  local mode_map = {
    n = { text = 'NORMAL', hl = 'StatusLineModeNormal' },
    i = { text = 'INSERT', hl = 'StatusLineModeInsert' },
    v = { text = 'VISUAL', hl = 'StatusLineModeVisual' },
    V = { text = 'V-LINE', hl = 'StatusLineModeVisual' },
    ['\22'] = { text = 'V-BLOCK', hl = 'StatusLineModeVisual' },
    c = { text = 'COMMAND', hl = 'StatusLineModeCommand' },
    R = { text = 'REPLACE', hl = 'StatusLineModeReplace' },
    s = { text = 'SELECT', hl = 'StatusLineModeVisual' },
    S = { text = 'S-LINE', hl = 'StatusLineModeVisual' },
    t = { text = 'TERMINAL', hl = 'StatusLineModeTerminal' },
    o = { text = 'OP-PENDING', hl = 'StatusLineModeNormal' },
  }
  local current_mode = vim.fn.mode()
  local mode_info = mode_map[current_mode] or { text = current_mode:upper(), hl = 'StatusLineModeNormal' }
  return '%#' .. mode_info.hl .. '#' .. config.separators.left .. ' ' .. mode_info.text .. ' ' .. config.separators.right
end

-- File info with path
local function file_info()
  local file_name = vim.fn.expand('%:t')
  local file_path= vim.fn.expand('%:~:.:h')

  if vim.bo.filetype == 'oil' then
    file_name = ''
  end

  if file_name == '' then
    file_name = '[No Name]'
  end

  local result = '%#StatusLineFile#'
  if file_path ~= '.' and file_path ~= '' then
    result = result .. ' ' .. file_path .. '/'
  else
    result = result .. ' '
  end
  result = result .. file_name
  return result
end

-- Word count
local function word_count()
  local count = vim.fn.wordcount().words
  return '%#StatusLineWordCount#' .. config.separators.left .. ' WORD COUNT: ' .. count .. ' ' .. config.separators.right
end

-- Date and time in MM/DD/YYYY HH:MM AM/PM format
local function datetime_info()
  local datetime = os.date(" %m/%d/%Y %I:%M %p")
  return '%#StatusLineDate#' .. config.separators.left .. datetime .. config.separators.right
end

-- Unsaved changes indicator with colored circles
local function unsaved_changes_indicator()
  if vim.bo.modified then
    -- Red circle for unsaved changes
    return '%#UnsavedChangesRed#' .. ' ●'
  else
    -- Green circle for no unsaved changes
    return '%#UnsavedChangesGreen#' .. ' ●'
  end
end

-- Build the complete statusline
local function build_statusline(is_active)
  if not is_active then
    return '%#StatusLineInactive# %f %= '
  end

  local parts = {
    mode_info(),
    file_info(),
    '%=', -- Right align everything after this
     -- Unsaved changes indicator
    unsaved_changes_indicator(),
    -- Date and time
    datetime_info(),
   word_count(),
  }

  return table.concat(parts, ' ')
end

-- Timer for statusline updates
local update_timer = nil

-- Function to update the statusline
local function update_statusline()
  vim.opt_local.statusline = '%{%v:lua.statusline_build(v:true)%}'
  vim.cmd('redrawstatus')
end

-- Setup function
function M.setup()
  setup_highlights()

  -- Make build_statusline accessible globally
  _G.statusline_build = build_statusline

  -- Autocommands for active/inactive statuslines
  local statusline_group = vim.api.nvim_create_augroup('CustomStatusline', { clear = true })

  vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    group = statusline_group,
    pattern = '*',
    callback = function()
      if update_timer then
        update_timer:stop()
      end
      update_statusline()
      update_timer = vim.loop.new_timer()
      update_timer:start(1000, 1000, vim.schedule_wrap(update_statusline))
    end,
  })

  vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
    group = statusline_group,
    pattern = '*',
    callback = function()
      if update_timer then
        update_timer:stop()
        update_timer = nil
      end
      vim.opt_local.statusline = '%#StatusLineInactive# %f %='
    end,
  })
end

-- Initialize
M.setup()

return M
