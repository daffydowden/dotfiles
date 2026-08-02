return {
  { "catppuccin/nvim", lazy = true },
  { "neanias/everforest-nvim", lazy = true },
  { "navarasu/onedark.nvim", lazy = true },
  { "sainnhe/sonokai", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "shaunsingh/nord.nvim", lazy = true },
  {
    "EdenEast/nightfox.nvim",
    priority = 1000, -- Make sure it loads first
    opts = {
      options = {
        -- Optional: Change other nightfox options if desired
        dim_inactive = true,
        styles = {
          comments = "italic",
          keywords = "bold",
          functions = "italic,bold",
        },
      },
      groups = {
        duskfox = {
          -- Change window split color in duskfox
          WinSeparator = { fg = "#555180" }, -- Using a purple from duskfox palette
          VertSplit = { link = "WinSeparator" }, -- For compatibility
        },
      },
    },
  },
  { "rose-pine/neovim", name = "rose-pine", lazy = true },
}
