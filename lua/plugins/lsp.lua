-- lua/plugins/lsp.lua

return {
  { 'williamboman/mason.nvim', config = function() require('mason').setup() end },
  { 'williamboman/mason-lspconfig.nvim' },
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')
      local mason_lspconfig = require('mason-lspconfig')

      -- ===================================================================
      -- == DIAGNOSTIC LEVEL CYCLER
      -- ===================================================================
      -- We define our diagnostic levels
      local diagnostic_levels = {
        { 'Error', vim.diagnostic.severity.ERROR },
        { 'Error & Warn', vim.diagnostic.severity.WARN },
        { 'All', vim.diagnostic.severity.HINT },
      }
      local current_level_index = 1 -- Start at "Error" only

      local function cycle_diagnostic_level()
        -- Move to the next level, or loop back to the first
        current_level_index = (current_level_index % #diagnostic_levels) + 1
        
        local level_name = diagnostic_levels[current_level_index][1]
        local min_severity = diagnostic_levels[current_level_index][2]
        
        -- This is the key: we filter diagnostics by minimum severity
        vim.diagnostic.config({
          severity_sort = true,
          virtual_text = { severity = min_severity },
          signs = { severity = min_severity },
          underline = { severity = min_severity },
        })
        
        vim.notify("Diagnostic level set to: " .. level_name, vim.log.levels.INFO, { title = "Diagnostics" })
      end

      -- Use the same keymap as before, but now it's a cycler
      vim.keymap.set('n', '<leader>dt', cycle_diagnostic_level, { desc = 'Cycle diagnostic level' })
      -- ===================================================================

      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, remap = false, silent = true }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous Diagnostic' })
        vim.keymap.set({ 'n', 'v' }, '<leader>fm', function() vim.lsp.buf.format({ async = true }) end, { buffer = bufnr, desc = 'Format file with LSP' })
      end

      -- ===================================================================
      -- == INITIAL DIAGNOSTIC CONFIGURATION
      -- ===================================================================
      -- Set the initial, default state to "Error" only.
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = false, -- We still keep inline text off by default
        signs = {
          severity = vim.diagnostic.severity.ERROR, -- Only show signs for Errors
          text = {
            [vim.diagnostic.severity.ERROR] = 'E',
            [vim.diagnostic.severity.WARN]  = 'W',
            [vim.diagnostic.severity.INFO]  = 'I',
            [vim.diagnostic.severity.HINT]  = 'H',
          },
        },
        underline = { severity = vim.diagnostic.severity.ERROR }, -- Only underline for Errors
      })
      -- ===================================================================

      -- Setup LSP servers
      mason_lspconfig.setup({
        ensure_installed = { 'pyright', 'gopls', 'lua_ls', 'bashls' },
      })

      mason_lspconfig.setup_handlers({
        function(server_name) -- Default handler
          lspconfig[server_name].setup({ on_attach = on_attach })
        end,
      })
    end,
  },
}
