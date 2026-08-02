return {
  {
    "stevearc/oil.nvim",
    opts = {
      default_file_explorer = false,
      view_options = {
        show_hidden = true,
      },
    },
    cmd = "Oil",
    keys = {
      { "<leader>fo", "<cmd>Oil<cr>", desc = "Oil" },
    },
  },
}
