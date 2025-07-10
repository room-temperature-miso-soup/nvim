-- lua/plugins/lsp.lua

return {
  { 
    'williamboman/mason.nvim', 
    config = function() 
      require('mason').setup() 
    end 
  },
  { 
    'williamboman/mason-lspconfig.nvim', 
    config = function() 
      require('mason-lspconfig').setup({
        automatic_installation = true,
      }) 
    end 
  },
  {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')

      -- ===================================================================
      -- == DIAGNOSTIC LEVEL CYCLER
      -- ===================================================================
      local diagnostic_levels = {
        { 'Error', vim.diagnostic.severity.ERROR },
        { 'Error & Warn', vim.diagnostic.severity.WARN },
        { 'All', vim.diagnostic.severity.HINT },
      }
      local current_level_index = 1

      local function cycle_diagnostic_level()
        current_level_index = (current_level_index % #diagnostic_levels) + 1
        
        local level_name = diagnostic_levels[current_level_index][1]
        local min_severity = diagnostic_levels[current_level_index][2]
        
        vim.diagnostic.config({
          severity_sort = true,
          virtual_text = { severity = min_severity },
          signs = { severity = min_severity },
          underline = { severity = min_severity },
        })
        
        vim.notify("Diagnostic level set to: " .. level_name, vim.log.levels.INFO, { title = "Diagnostics" })
      end

      vim.keymap.set('n', '<leader>dt', cycle_diagnostic_level, { desc = 'Cycle diagnostic level' })

      -- ===================================================================
      -- == LSP TOGGLE FUNCTION
      -- ===================================================================
      local lsp_enabled = true
      
      local function toggle_lsp()
        lsp_enabled = not lsp_enabled
        
        if lsp_enabled then
          vim.diagnostic.enable()
          -- Restart LSP for current buffer
          vim.cmd('LspRestart')
          vim.notify("LSP enabled", vim.log.levels.INFO, { title = "LSP" })
        else
          vim.diagnostic.disable()
          -- Stop LSP clients for current buffer
          local clients = vim.lsp.get_active_clients({ bufnr = 0 })
          for _, client in ipairs(clients) do
            vim.lsp.buf_detach_client(0, client.id)
          end
          vim.notify("LSP disabled", vim.log.levels.INFO, { title = "LSP" })
        end
      end

      vim.keymap.set('n', '<leader>lt', toggle_lsp, { desc = 'Toggle LSP' })

      -- ===================================================================
      -- == LARGE FILE OPTIMIZATION
      -- ===================================================================
      local function is_large_file(bufnr)
        local max_filesize = 100 * 1024 -- 100KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
        return ok and stats and stats.size > max_filesize
      end

      -- ===================================================================
      -- == OPTIMIZED ON_ATTACH FUNCTION
      -- ===================================================================
      local on_attach = function(client, bufnr)
        -- Disable LSP features for large files
        if is_large_file(bufnr) then
          client.server_capabilities.documentSymbolProvider = false
          client.server_capabilities.workspaceSymbolProvider = false
          client.server_capabilities.semanticTokensProvider = nil
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          vim.diagnostic.disable(bufnr)
        end

        -- Only set keymaps once per buffer, not per client
        if vim.b[bufnr].lsp_keymaps_set then
          return
        end
        vim.b[bufnr].lsp_keymaps_set = true

        local opts = { buffer = bufnr, silent = true }
        
        -- Core LSP keymaps
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        
        -- Diagnostic navigation
        vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { buffer = bufnr, desc = 'Next Diagnostic' })
        vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { buffer = bufnr, desc = 'Previous Diagnostic' })
        
        -- Formatting
        vim.keymap.set({ 'n', 'v' }, '<leader>fm', function() 
          vim.lsp.buf.format({ async = true }) 
        end, { buffer = bufnr, desc = 'Format file with LSP' })
      end

      -- ===================================================================
      -- == INITIAL DIAGNOSTIC CONFIGURATION
      -- ===================================================================
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { 
          spacing = 4, 
          prefix = '●', 
          severity = vim.diagnostic.severity.ERROR 
        },
        signs = {
          severity = vim.diagnostic.severity.ERROR,
          text = {
            [vim.diagnostic.severity.ERROR] = 'E',
            [vim.diagnostic.severity.WARN]  = 'W',
            [vim.diagnostic.severity.INFO]  = 'I',
            [vim.diagnostic.severity.HINT]  = 'H',
          },
        },
        underline = { severity = vim.diagnostic.severity.ERROR },
        update_in_insert = false, -- Don't update diagnostics in insert mode
      })

      -- ===================================================================
      -- == SERVER CONFIGURATIONS
      -- ===================================================================
      local server_configs = {
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoImportCompletions = true,
              }
            }
          }
        },
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            },
          }
        },
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              diagnostics = { globals = { 'vim' } },
              workspace = {
                library = vim.api.nvim_get_runtime_file("", true),
                checkThirdParty = false,
              },
              telemetry = { enable = false },
            },
          }
        },
        bashls = {}
      }

      -- Setup servers with optimized configuration
      for server, config in pairs(server_configs) do
        local setup_config = vim.tbl_deep_extend("force", {
          on_attach = on_attach,
          flags = {
            debounce_text_changes = 150,
          },
          capabilities = vim.lsp.protocol.make_client_capabilities(),
        }, config)
        
        lspconfig[server].setup(setup_config)
      end
    end,
  },

  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
