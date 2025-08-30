local prefix = "<leader>ac"
return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
    },
    -- opts = {},
    config = function()
      require("codecompanion").setup({
        display = {
          action_palette = {
            provider = "snacks",
          },
          chat = {
            show_settings = false, -- Irritatingly, blocks changing adapters
            render_headers = true,
            show_token_count = true,
          },
        },
        strategies = {
          inline = {
            adapter = "anthropic",
          },
          chat = {
            adapter = "anthropic",
            opts = {
              completion_provider = "blink", -- Set blink as completion provider
            },
            tools = {
              ["mcp"] = {
                callback = require("mcphub.extensions.codecompanion"),
                description = "Call tools and resources from the MCP Servers",
                opts = {
                  requires_approval = true,
                },
              },
            },
          },
        },
      })

      -- Command-line alias: expand 'cc' to 'CodeCompanion'
      vim.cmd([[cab cc CodeCompanion]])
    end,
    keys = {
      { prefix .. "a", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "Action Palette" },
      { prefix .. "c", "<cmd>CodeCompanionChat<cr>", mode = { "n", "v" }, desc = "New Chat" },
      { prefix .. "A", "<cmd>CodeCompanionAdd<cr>", mode = "v", desc = "Add Code" },
      { prefix .. "i", "<cmd>CodeCompanion<cr>", mode = "n", desc = "Inline Prompt" },
      { prefix .. "C", "<cmd>CodeCompanionChat Toggle<cr>", mode = "n", desc = "Toggle Chat" },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { prefix, group = "CodeCompanion", mode = { "n", "v" } },
      },
    },
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
    },
    build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
    config = function()
      require("mcphub").setup({
        -- Required options
        port = 5050, -- Port for MCP Hub server
        config = vim.fn.expand("~/mcpservers.json"), -- Absolute path to config file

        -- Optional options
        on_ready = function(hub)
          -- Called when hub is ready
        end,
        on_error = function(err)
          -- Called on errors
        end,
        shutdown_delay = 0, -- Wait 0ms before shutting down server after last client exits
        log = {
          level = vim.log.levels.WARN,
          to_file = false,
          file_path = nil,
          prefix = "MCPHub",
        },
      })
    end,
  },
}
