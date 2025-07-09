-- lua/plugins/fzf.lua

return {
  'ibhagwan/fzf-lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('fzf-lua').setup({
      --=====================================================
      --== THEME & WINDOW CONFIG (USING THE MODERN METHOD)
      --=====================================================
      
      -- This single option replaces all our previous theme hacks.
      -- It intelligently inherits colors from your active colorscheme.
      fzf_colors = {
        true,
        bg = '-1',     -- Inherit background
        gutter = '-1', -- Inherit gutter background
      },
      
      -- We can still keep other window preferences, like the border style.
      winopts = {
        border = 'rounded',
        winblend = 0, -- Ensures a solid background if one is set
      },
      
      -- We can also keep the preview title enabled.
      preview = {
        title = {
          enabled = true,
        },
      },
    })

    -- This section sets up your keyboard shortcuts.
    local keymap = vim.keymap.set
    keymap('n', '<leader>ff', '<cmd>FzfLua files<CR>', { desc = 'Find Files' })
    keymap('n', '<leader>fg', '<cmd>FzfLua live_grep<CR>', { desc = 'Find Grep (text)' })
    keymap('n', '<leader>fb', '<cmd>FzfLua buffers<CR>', { desc = 'Find Buffers' })
    keymap('n', '<leader>fh', '<cmd>FzfLua help_tags<CR>', { desc = 'Find Help' })
    keymap('n', '<leader>/', '<cmd>FzfLua live_grep<CR>', { desc = 'Find Grep (Project)' })
  end,
}
