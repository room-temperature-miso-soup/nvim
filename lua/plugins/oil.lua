return {
  'stevearc/oil.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' }, -- optional for file icons
  config = function()
    require('oil').setup({
      -- Oil will take over the default Netrw file browser
      default_file_explorer = true,
      -- Keymaps in oil buffer
      keymaps = {
        ['<C-h>'] = 'actions.select_split', -- Open in horizontal split
        ['<C-v>'] = 'actions.select_vsplit', -- Open in vertical split
        ['<C-t>'] = 'actions.select_tab', -- Open in new tab
      },
    })

    -- Open parent directory in oil
    vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
  end,
}
