return {
  'nvim-treesitter/nvim-treesitter',
  -- The build command is essential for Treesitter to work.
  -- It compiles the language parsers.
  build = ':TSUpdate',
  -- Defer loading of the plugin until a file is opened
  event = { 'BufReadPost', 'BufNewFile' },

  config = function()
    -- =================================================================
    --  Setup: Toggle and Large File Handling
    -- =================================================================

    -- Set the initial state of the Treesitter toggle
    -- This global variable will be used to enable/disable Treesitter session-wide.
    vim.g.treesitter_enabled = true

    -- Define the function that checks whether to disable Treesitter for a buffer.
    -- It checks both the global toggle and the file size.
    local function should_disable_treesitter(lang, bufnr)
      -- 1. Check the global toggle
      if not vim.g.treesitter_enabled then
        return true
      end

      -- 2. Check if the file is too large
      local max_filesize = 1 * 1024 * 1024 -- 1 MB
      local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
      if ok and stats and stats.size > max_filesize then
        -- Notify the user that Treesitter is disabled for this large file
        vim.notify_once(
          ('Treesitter disabled for this file (size > %.1f MB)'):format(max_filesize / 1024 / 1024),
          vim.log.levels.WARN
        )
        return true
      end

      -- If neither condition is met, enable Treesitter
      return false
    end

    -- =================================================================
    --  Treesitter Main Configuration
    -- =================================================================
    require('nvim-treesitter.configs').setup({
      -- A list of parser names, or "all" for all supported languages.
      ensure_installed = {
        'go',
        'python',
        'lua',
        'bash',
        'json',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      },

      -- Install parsers synchronously (blocks UI until finished)
      -- `false` is better for performance, as it installs in the background.
      sync_install = false,

      -- Automatically install missing parsers when entering a buffer.
      auto_install = true,

      -- The main feature of Treesitter. Enables better syntax highlighting.
      highlight = {
        enable = true,
        -- This is the key for our performance improvements.
        -- It runs the function for each buffer to decide whether to activate highlighting.
        disable = should_disable_treesitter,

        -- Using `additional_vim_regex_highlighting = false` is a good performance choice.
        -- It prevents running two highlighting engines simultaneously.
        additional_vim_regex_highlighting = false,
      },

      -- Enables Treesitter-based indentation, which is generally more accurate.
      indent = {
        enable = true,
        -- We use the same disable function for indentation to keep it consistent.
        disable = should_disable_treesitter,
      },

      -- Other useful modules can be configured here
      -- For example, `incremental_selection` for smart visual selection expansion.
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<c-backspace>',
        },
      },
    })

    -- =================================================================
    --  User Command for Toggling Treesitter
    -- =================================================================
    vim.api.nvim_create_user_command('ToggleTreesitter', function()
      -- Flip the global toggle variable
      vim.g.treesitter_enabled = not vim.g.treesitter_enabled

      if vim.g.treesitter_enabled then
        -- When enabling, re-enable highlighting and indent for all buffers
        -- Note: This won't override the large file check.
        vim.cmd('bufdo TSEnable highlight')
        vim.cmd('bufdo TSEnable indent')
        vim.notify('Treesitter enabled', vim.log.levels.INFO)
      else
        -- When disabling, turn off highlighting and indent for all buffers
        vim.cmd('bufdo TSDisable highlight')
        vim.cmd('bufdo TSDisable indent')
        vim.notify('Treesitter disabled', vim.log.levels.WARN)
      end
    end, {
      desc = 'Toggle Treesitter highlighting and indentation on/off globally',
    })
  end,
}
