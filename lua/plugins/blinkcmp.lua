return {
  'saghen/blink.cmp',
  dependencies = { 'rafamadriz/friendly-snippets' },
  version = '1.*',
  event = 'InsertEnter',
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = 'default' },
    appearance = {
      nerd_font_variant = 'mono'
    },
    completion = { 
      documentation = { auto_show = false },
      menu = {
        draw = {
          treesitter = { 'lsp' },
        },
      },
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      per_filetype = {
        lua = { 'lsp', 'path', 'snippets', 'buffer' },
        python = { 'lsp', 'path', 'snippets', 'buffer' },
        go = { 'lsp', 'path', 'snippets', 'buffer' },
        gitcommit = { 'buffer' },
        markdown = { 'path', 'snippets', 'buffer' },
      },
      providers = {
        lsp = {
          score_offset = 90,
        },
        snippets = {
          score_offset = 85,
        },
        buffer = {
          score_offset = 5,
        },
      }
    },
    fuzzy = { 
      implementation = "prefer_rust_with_warning",
      sorts = { 'score', 'sort_text' },
    }
  },
  opts_extend = { "sources.default" }
}
