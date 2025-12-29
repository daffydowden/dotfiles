local prefix = "<leader>ac"
return {
  {
    "olimorris/codecompanion.nvim",
    event = "VeryLazy", -- Load after startup to ensure proper initialization
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
            show_token_count = true,
            show_reasoning = true, -- Show reasoning tokens
            show_context = true, -- Show context information
            fold_context = true, -- Auto-fold context sections
            fold_reasoning = true, -- Auto-fold reasoning sections
            auto_scroll = true, -- Auto-scroll behavior
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
            -- In-chat keymaps using localleader (,)
            keymaps = {
              send = {
                modes = { n = { "<CR>", "<C-s>" }, i = "<C-s>" },
                index = 2,
                callback = "keymaps.send",
                description = "[Request] Send response",
              },
              close = {
                modes = { n = "<C-c>", i = "<C-c>" },
                index = 4,
                callback = "keymaps.close",
                description = "[Chat] Close",
              },
              stop = {
                modes = { n = "<LocalLeader>q" },
                index = 5,
                callback = "keymaps.stop",
                description = "[Request] Stop",
              },
              change_adapter = {
                modes = { n = "<LocalLeader>a" },
                index = 15,
                callback = "keymaps.change_adapter",
                description = "[Adapter] Change adapter",
              },
              buffer_sync_all = {
                modes = { n = "<LocalLeader>ba" },
                index = 9,
                callback = "keymaps.buffer_sync_all",
                description = "[Chat] Sync entire buffer",
              },
              buffer_sync_diff = {
                modes = { n = "<LocalLeader>bd" },
                index = 10,
                callback = "keymaps.buffer_sync_diff",
                description = "[Chat] Sync buffer diff",
              },
              codeblock = {
                modes = { n = "<LocalLeader>c" },
                index = 7,
                callback = "keymaps.codeblock",
                description = "[Chat] Insert codeblock",
              },
              debug = {
                modes = { n = "<LocalLeader>d" },
                index = 16,
                callback = "keymaps.debug",
                description = "[Chat] View debug info",
              },
              super_diff = {
                modes = { n = "<LocalLeader>D" },
                index = 23,
                callback = "keymaps.super_diff",
                description = "[Tools] Show Super Diff",
              },
              fold_code = {
                modes = { n = "<LocalLeader>f" },
                index = 15,
                callback = "keymaps.fold_code",
                description = "[Chat] Fold code",
              },
              regenerate = {
                modes = { n = "<LocalLeader>r" },
                index = 3,
                callback = "keymaps.regenerate",
                description = "[Request] Regenerate",
              },
              goto_file_under_cursor = {
                modes = { n = "<LocalLeader>R" },
                index = 21,
                callback = "keymaps.goto_file_under_cursor",
                description = "[Chat] Open file",
              },
              rules = {
                modes = { n = "<LocalLeader>M" },
                index = 18,
                callback = "keymaps.clear_rules",
                description = "[Chat] Clear Rules",
              },
              system_prompt = {
                modes = { n = "<LocalLeader>s" },
                index = 17,
                callback = "keymaps.toggle_system_prompt",
                description = "[Chat] Toggle system prompt",
              },
              copilot_stats = {
                modes = { n = "<LocalLeader>S" },
                index = 22,
                callback = "keymaps.copilot_stats",
                description = "[Adapter] Copilot stats",
              },
              yolo_mode = {
                modes = { n = "<LocalLeader>ty" },
                index = 20,
                callback = "keymaps.yolo_mode",
                description = "[Tools] Toggle YOLO mode",
              },
              clear = {
                modes = { n = "<LocalLeader>x" },
                index = 6,
                callback = "keymaps.clear",
                description = "[Chat] Clear",
              },
              yank_code = {
                modes = { n = "<LocalLeader>y" },
                index = 8,
                callback = "keymaps.yank_code",
                description = "[Chat] Yank code",
              },
              next_header = {
                modes = { n = "]]" },
                index = 13,
                callback = "keymaps.next_header",
                description = "[Nav] Next header",
              },
              previous_header = {
                modes = { n = "[[" },
                index = 14,
                callback = "keymaps.previous_header",
                description = "[Nav] Previous header",
              },
              next_chat = {
                modes = { n = "}" },
                index = 11,
                callback = "keymaps.next_chat",
                description = "[Nav] Next chat",
              },
              previous_chat = {
                modes = { n = "{" },
                index = 12,
                callback = "keymaps.previous_chat",
                description = "[Nav] Previous chat",
              },
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
        adapters = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = {
                api_key = "cmd:echo $ANTHROPIC_API_KEY",
              },
            })
          end,
          -- Claude Code agent integration via ACP (optional)
          -- Requires: npm install -g @zed-industries/claude-code-acp
          -- claude_code = function()
          --   return require("codecompanion.adapters").extend("claude_code", {
          --     env = {
          --       ANTHROPIC_API_KEY = "cmd:echo $ANTHROPIC_API_KEY",
          --     },
          --   })
          -- end,
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
