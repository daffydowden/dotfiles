local prefix = "<leader>am"
return {
  {
    "dlants/magenta.nvim",
    lazy = true,
    build = "npm install --frozen-lockfile",
    opts = {
      sidebarPosition = "right",
      picker = "snacks",
    },
    keys = {
      { prefix .. "n", "<cmd>Magenta new-thread<cr>", mode = "n", desc = "Create new Magenta thread" },
      { prefix .. "c", "<cmd>Magenta clear<cr>", mode = "n", desc = "Clear Magenta state" },
      { prefix .. "a", "<cmd>Magenta abort<cr>", mode = "n", desc = "Abort current Magenta operation" },
      { prefix .. "t", "<cmd>Magenta toggle<cr>", mode = "n", desc = "Toggle Magenta window" },
      { prefix .. "i", "<cmd>Magenta start-inline-edit<cr>", mode = "n", desc = "Inline edit" },
      { prefix .. "i", "<cmd>Magenta start-inline-edit-selection<cr>", mode = "v", desc = "Inline edit selection" },
      { prefix .. "p", "<cmd>Magenta paste-selection<cr>", mode = "v", desc = "Send selection to Magenta" },
      { prefix .. "r", "<cmd>Magenta replay-inline-edit<cr>", mode = "n", desc = "Replay last inline edit" },
      { prefix .. "r", "<cmd>Magenta replay-inline-edit-selection<cr>", mode = "v", desc = "Replay last inline edit on selection" },
      { prefix .. ".", "<cmd>Magenta replay-inline-edit<cr>", mode = "n", desc = "Replay last inline edit" },
      { prefix .. ".", "<cmd>Magenta replay-inline-edit-selection<cr>", mode = "v", desc = "Replay last inline edit on selection" },
      { prefix .. "b", function() return require("magenta.actions").add_buffer_to_context() end, mode = "n", desc = "Add current buffer to Magenta context" },
      { prefix .. "f", function() return require("magenta.actions").pick_context_files() end, mode = "n", desc = "Select files to add to Magenta context" },
      { prefix .. "p", function() return require("magenta.actions").pick_provider() end, mode = "n", desc = "Select provider and model" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { prefix, group = "Magenta", mode = { "n", "v" } },
      },
    },
  },
}
