return {
  { "catppuccin/nvim" },
  { "neanias/everforest-nvim" },
  { "navarasu/onedark.nvim" },
  { "sainnhe/sonokai" },
  { "ellisonleao/gruvbox.nvim" },
  { "shaunsingh/nord.nvim" },
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
  { "rose-pine/neovim", name = "rose-pine" },
}
