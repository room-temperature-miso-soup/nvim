-- lua/plugins/theme.lua

return {
  {
    'craftzdog/solarized-osaka.nvim',
    lazy = false,
    priority = 1000, -- Ensures it loads first
    opts = {
      -- We specify the 'dark' style here
      style = 'dark',
      -- Enable transparency
      transparent = true,
    },
  },
}
