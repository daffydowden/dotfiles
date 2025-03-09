local prefix = "<leader>ap"
return {
  {
    "frankroeder/parrot.nvim",
    dependencies = { "ibhagwan/fzf-lua", "nvim-lua/plenary.nvim" },
    -- optionally include "rcarriga/nvim-notify" for beautiful notifications
    keys = {
      { prefix .. "c", "<cmd>PrtChatToggle<cr>", desc = "Open Parrot Chat" },
      { prefix .. "r", "<cmd>PrtChatRespond<cr>", desc = "Respond to Parrot Chat" },
      { prefix .. "s", "<cmd>PrtChatStop<cr>", desc = "Interrupt ongoing Parrot respond" },
      { prefix .. "d", "<cmd>PrtChatDelete<cr>", desc = "Delete the current chat file" },
      { prefix .. "p", "<cmd>PrtProvider<cr>", desc = "Change the current Provider" },
      { prefix .. "m", "<cmd>PrtModel<cr>", desc = "Change the current Model" },
      { prefix .. "a", ":PrtAppend ", desc = "Use Parrot to append code", mode = { "v" } },
      { prefix .. "r", ":PrtRewrite ", desc = "Use Parrot to rewrite code", mode = { "v" } },
      { prefix .. "p", ":PrtPrepend", desc = "Use Parrot to prepend code", mode = { "v" } },
      {
        prefix .. "d",
        ":PrtPrepend write docs for this function or type<cr>",
        desc = "🦜 Use Parrot to write docs for function or type",
        mode = { "v" },
      },
    },
    config = function()
      require("parrot").setup({
        -- Providers must be explicitly added to make them available.
        providers = {
          anthropic = {
            api_key = os.getenv("ANTHROPIC_API_KEY"),
          },
          gemini = {
            api_key = os.getenv("GOOGLE_AI_API_KEY"),
          },
          groq = {
            api_key = os.getenv("GROQ_API_KEY"),
          },
          -- mistral = {
          --   api_key = os.getenv "MISTRAL_API_KEY",
          -- },
          -- pplx = {
          --   api_key = os.getenv "PERPLEXITY_API_KEY",
          -- },
          -- provide an empty list to make provider available (no API key required)
          -- ollama = {},
          openai = {
            api_key = os.getenv("OPENAI_API_KEY"),
          },
          github = {
            api_key = os.getenv("GITHUB_TOKEN"),
          },
          -- nvidia = {
          --   api_key = os.getenv "NVIDIA_API_KEY",
          -- },
          -- xai = {
          --   api_key = os.getenv "XAI_API_KEY",
          -- },
        },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { prefix, group = "Parrot", icon = "🦜", mode = { "n", "v" } },
      },
    },
  },
}
