-- lua/plugins/treesitter.lua

return {
  'nvim-treesitter/nvim-treesitter',
  -- The build command is essential for Treesitter to work.
  -- It compiles the language parsers.
  build = ':TSUpdate',

  config = function()
    require('nvim-treesitter.configs').setup({

      -- A list of parser names, or "all" for all supported languages.
      -- This is where you specify the languages you want.
      ensure_installed = {
        -- Your requested languages
        'go',
        'python',
        'lua',
        'bash',

        -- Other highly recommended languages for configuration and documentation
        'json',
        'markdown',
        'markdown_inline', -- For code blocks inside markdown
        'query',           -- For writing Treesitter queries
        'vim',             -- For Vimscript
        'vimdoc',          -- For Neovim's help files
      },

      -- Install parsers synchronously (blocks UI until finished)
      -- Set to `true` if you want to be sure parsers are installed before you start working
      sync_install = false,

      -- Automatically install missing parsers when entering a buffer
      -- This is a great feature to have on.
      auto_install = true,

      -- The main feature of Treesitter. Enables better syntax highlighting.
      highlight = {
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some highlighting flicker.
        -- Most users should leave this disabled.
        additional_vim_regex_highlighting = false,
      },

      -- Enables Treesitter-based indentation, which is generally more accurate.
      indent = {
        enable = true,
      },
    })
  end,
}
