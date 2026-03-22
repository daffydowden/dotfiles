local prefix = "<leader>o"

return {
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "folke/snacks.nvim",
    },
    opts = {
      picker = "snacks",
      enable_builtin = true,
    },
    keys = {
      { prefix .. "i", "<cmd>Octo issue list<cr>", desc = "List Issues" },
      { prefix .. "p", "<cmd>Octo pr list<cr>", desc = "List PRs" },
      { prefix .. "d", "<cmd>Octo discussion list<cr>", desc = "List Discussions" },
      { prefix .. "n", "<cmd>Octo notification list<cr>", desc = "List Notifications" },
      { prefix .. "s", "<cmd>Octo search<cr>", desc = "Search GitHub" },
      { prefix .. "c", "<cmd>Octo pr create<cr>", desc = "Create PR" },
      { prefix .. "r", "<cmd>Octo review start<cr>", desc = "Start Review" },
      { prefix .. "a", "<cmd>Octo actions<cr>", desc = "Octo Actions" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { prefix, group = "Octo (GitHub)", icon = " " },
      },
    },
  },
}
