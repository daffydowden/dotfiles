local prefix = "<leader>a"
return {{
  "0xrusowsky/nvim-ctx-ingest",
  dependencies = {
    "nvim-web-devicons", -- required for file icons
  },
  config = function()
    require("nvim-ctx-ingest").setup({
      -- your config options here
    })
  end,
  keys = {
    { prefix .. "C", "<cmd>CtxIngest<cr>", mode = { "n" }, desc = "Create context for LLM" },
  }
}}
