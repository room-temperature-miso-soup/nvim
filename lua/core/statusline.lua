-- lua/core/statusline.lua
-- Enhanced statusline with better design and additional features

local M = {}

-- Configuration
local config = {
  show_git = true,
  show_diagnostics = true,
  show_file_info = true,
  show_encoding = false, -- Can be toggled
  separators = {
    left = '',
    right = '',
    thin_left = '│',
    thin_right = '│',
  },
  icons = {
    git = '',
    modified = '●',
    readonly = '',
    error = '',
    warn = '',
    info = '',
    hint = '',
    file = '',
    folder = '',
  }
}

-- Color scheme for different components
local function setup_highlights()
  local highlights = {
    -- Mode highlights
    StatusLineModeNormal = { bg = '#7aa2f7', fg = '#1f2335', bold = true },
    StatusLineModeInsert = { bg = '#9ece6a', fg = '#1f2335', bold = true },
    StatusLineModeVisual = { bg = '#bb9af7', fg = '#1f2335', bold = true },
    StatusLineModeCommand = { bg = '#e0af68', fg = '#1f2335', bold = true },
    StatusLineModeReplace = { bg = '#f7768e', fg = '#1f2335', bold = true },
    StatusLineModeTerminal = { bg = '#7dcfff', fg = '#1f2335', bold = true },
    
    -- Component highlights
    StatusLineGit = { bg = '#3b4261', fg = '#7aa2f7', bold = false },
    StatusLineFile = { bg = '#24283b', fg = '#c0caf5', bold = false },
    StatusLineModified = { bg = '#24283b', fg = '#f7768e', bold = true },
    StatusLineReadonly = { bg = '#24283b', fg = '#e0af68', bold = true },
    StatusLinePosition = { bg = '#3b4261', fg = '#c0caf5', bold = false },
    StatusLinePercent = { bg = '#414868', fg = '#c0caf5', bold = false },
    StatusLineInactive = { bg = '#1f2335', fg = '#565f89', bold = false },
    
    -- Diagnostic highlights
    StatusLineDiagnosticError = { bg = '#24283b', fg = '#f7768e', bold = false },
    StatusLineDiagnosticWarn = { bg = '#24283b', fg = '#e0af68', bold = false },
    StatusLineDiagnosticInfo = { bg = '#24283b', fg = '#7dcfff', bold = false },
    StatusLineDiagnosticHint = { bg = '#24283b', fg = '#1abc9c', bold = false },
  }
  
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
end

-- Enhanced git branch function with status indicators
local function git_branch()
  if not config.show_git then return '' end
  
  local branch = vim.fn.trim(vim.fn.system('git branch --show-current 2>/dev/null'))
  if branch == '' then return '' end
  
  -- Get git status for additional info
  local status = vim.fn.system('git status --porcelain 2>/dev/null')
  local status_indicator = ''
  
  if status ~= '' then
    local lines = vim.split(status, '\n')
    local modified = 0
    local staged = 0
    local untracked = 0
    
    for _, line in ipairs(lines) do
      if line ~= '' then
        local status_char = line:sub(1, 1)
        local work_char = line:sub(2, 2)
        
        if status_char == 'A' or status_char == 'M' or status_char == 'D' then
          staged = staged + 1
        end
        if work_char == 'M' or work_char == 'D' then
          modified = modified + 1
        end
        if status_char == '?' then
          untracked = untracked + 1
        end
      end
    end
    
    if staged > 0 then status_indicator = status_indicator .. '+' .. staged end
    if modified > 0 then status_indicator = status_indicator .. '~' .. modified end
    if untracked > 0 then status_indicator = status_indicator .. '?' .. untracked end
    
    if status_indicator ~= '' then
      status_indicator = ' [' .. status_indicator .. ']'
    end
  end
  
  return '%#StatusLineGit#' .. config.separators.left .. ' ' .. config.icons.git .. ' ' .. branch .. status_indicator .. ' ' .. config.separators.right
end

-- Enhanced mode function with better icons and colors
local function mode_info()
  local mode_map = {
    n = { text = 'NORMAL', hl = 'StatusLineModeNormal' },
    i = { text = 'INSERT', hl = 'StatusLineModeInsert' },
    v = { text = 'VISUAL', hl = 'StatusLineModeVisual' },
    V = { text = 'V-LINE', hl = 'StatusLineModeVisual' },
    ['\22'] = { text = 'V-BLOCK', hl = 'StatusLineModeVisual' },
    c = { text = 'COMMAND', hl = 'StatusLineModeCommand' },
    R = { text = 'REPLACE', hl = 'StatusLineModeReplace' },
    t = { text = 'TERMINAL', hl = 'StatusLineModeTerminal' },
    s = { text = 'SELECT', hl = 'StatusLineModeVisual' },
    S = { text = 'S-LINE', hl = 'StatusLineModeVisual' },
  }
  
  local current_mode = vim.fn.mode()
  local mode_info = mode_map[current_mode] or { text = current_mode:upper(), hl = 'StatusLineModeNormal' }
  
  return '%#' .. mode_info.hl .. '#' .. config.separators.left .. ' ' .. mode_info.text .. ' ' .. config.separators.right
end

-- File information with better formatting
local function file_info()
  local file_name = vim.fn.expand('%:t')
  local file_path = vim.fn.expand('%:~:.:h')
  local modified = vim.bo.modified
  local readonly = vim.bo.readonly
  
  if file_name == '' then
    file_name = '[No Name]'
  end
  
  local result = '%#StatusLineFile#'
  
  -- Add file path if not in current directory
  if file_path ~= '.' and file_path ~= '' then
    result = result .. ' ' .. file_path .. '/'
  else
    result = result .. ' '
  end
  
  -- Add file icon based on extension (basic implementation)
  local extension = file_name:match('%.([^%.]+)$')
  if extension then
    result = result .. config.icons.file .. ' '
  end
  
  result = result .. file_name
  
  -- Add modified indicator
  if modified then
    result = result .. ' %#StatusLineModified#' .. config.icons.modified
  end
  
  -- Add readonly indicator
  if readonly then
    result = result .. ' %#StatusLineReadonly#' .. config.icons.readonly
  end
  
  return result
end

-- LSP diagnostics information
local function diagnostics()
  if not config.show_diagnostics then return '' end
  
  local diagnostics = vim.diagnostic.get(0)
  local counts = { error = 0, warn = 0, info = 0, hint = 0 }
  
  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      counts.error = counts.error + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      counts.warn = counts.warn + 1
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      counts.info = counts.info + 1
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      counts.hint = counts.hint + 1
    end
  end
  
  local result = ''
  
  if counts.error > 0 then
    result = result .. '%#StatusLineDiagnosticError# ' .. config.icons.error .. ' ' .. counts.error
  end
  if counts.warn > 0 then
    result = result .. '%#StatusLineDiagnosticWarn# ' .. config.icons.warn .. ' ' .. counts.warn
  end
  if counts.info > 0 then
    result = result .. '%#StatusLineDiagnosticInfo# ' .. config.icons.info .. ' ' .. counts.info
  end
  if counts.hint > 0 then
    result = result .. '%#StatusLineDiagnosticHint# ' .. config.icons.hint .. ' ' .. counts.hint
  end
  
  return result
end

-- File encoding and format (optional)
local function file_encoding()
  if not config.show_encoding then return '' end
  
  local encoding = vim.bo.fileencoding
  if encoding == '' then
    encoding = vim.o.encoding
  end
  
  local format = vim.bo.fileformat
  return '%#StatusLinePosition# ' .. encoding:upper() .. '[' .. format:upper() .. '] '
end

-- Enhanced position information
local function position_info()
  local line = vim.fn.line('.')
  local col = vim.fn.col('.')
  local total_lines = vim.fn.line('$')
  
  return '%#StatusLinePosition#' .. config.separators.left .. ' ' .. line .. ':' .. col .. ' ' .. config.separators.right
end

-- Percentage through file
local function file_percentage()
  return '%#StatusLinePercent#' .. config.separators.left .. ' %P ' .. config.separators.right
end

-- LSP status
local function lsp_status()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return '' end
  
  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
  end
  
  return '%#StatusLinePosition# LSP[' .. table.concat(client_names, ',') .. '] '
end

-- Build the complete statusline
local function build_statusline(is_active)
  if not is_active then
    return '%#StatusLineInactive# %f %= %l:%c '
  end
  
  local parts = {
    mode_info(),
    file_info(),
    diagnostics(),
    '%=', -- Right align everything after this
    lsp_status(),
    git_branch(),
    file_encoding(),
    position_info(),
    file_percentage(),
  }
  
  return table.concat(parts, '')
end

-- Setup function to initialize the statusline
function M.setup(user_config)
  -- Merge user config with defaults
  if user_config then
    config = vim.tbl_deep_extend('force', config, user_config)
  end
  
  -- Setup highlights
  setup_highlights()
  
  -- Make functions global so statusline expressions can find them
  _G.statusline_build = build_statusline
  _G.statusline_mode_info = mode_info
  _G.statusline_git_branch = git_branch
  _G.statusline_file_info = file_info
  _G.statusline_diagnostics = diagnostics
  _G.statusline_position = position_info
  
  -- Set up autocommands for active/inactive statuslines
  local statusline_group = vim.api.nvim_create_augroup('CustomStatusline', { clear = true })
  
  vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    group = statusline_group,
    pattern = '*',
    callback = function()
      vim.opt_local.statusline = '%{%v:lua.statusline_build(v:true)%}'
    end,
  })
  
  vim.api.nvim_create_autocmd({ 'WinLeave', 'BufLeave' }, {
    group = statusline_group,
    pattern = '*',
    callback = function()
      vim.opt_local.statusline = '%{%v:lua.statusline_build(v:false)%}'
    end,
  })
  
  -- Update statusline when diagnostics change
  vim.api.nvim_create_autocmd('DiagnosticChanged', {
    group = statusline_group,
    callback = function()
      vim.cmd('redrawstatus')
    end,
  })
  
  -- Update statusline when LSP attaches/detaches
  vim.api.nvim_create_autocmd('LspAttach', {
    group = statusline_group,
    callback = function()
      vim.cmd('redrawstatus')
    end,
  })
  
  vim.api.nvim_create_autocmd('LspDetach', {
    group = statusline_group,
    callback = function()
      vim.cmd('redrawstatus')
    end,
  })
end

-- Toggle functions for configuration
function M.toggle_git()
  config.show_git = not config.show_git
  vim.cmd('redrawstatus')
  vim.notify('Git info: ' .. (config.show_git and 'enabled' or 'disabled'))
end

function M.toggle_diagnostics()
  config.show_diagnostics = not config.show_diagnostics
  vim.cmd('redrawstatus')
  vim.notify('Diagnostics: ' .. (config.show_diagnostics and 'enabled' or 'disabled'))
end

function M.toggle_encoding()
  config.show_encoding = not config.show_encoding
  vim.cmd('redrawstatus')
  vim.notify('Encoding info: ' .. (config.show_encoding and 'enabled' or 'disabled'))
end

-- Initialize the statusline
M.setup()

-- Create user commands for toggling features
vim.api.nvim_create_user_command('StatuslineToggleGit', M.toggle_git, { desc = 'Toggle git info in statusline' })
vim.api.nvim_create_user_command('StatuslineToggleDiagnostics', M.toggle_diagnostics, { desc = 'Toggle diagnostics in statusline' })
vim.api.nvim_create_user_command('StatuslineToggleEncoding', M.toggle_encoding, { desc = 'Toggle encoding info in statusline' })

return M
