return {
  {
      'saghen/blink.cmp',
      dependencies = {
          'Kaiser-Yang/blink-cmp-avante',
      },
      opts = {
          sources = {
              -- Add 'avante' to the list
              default = { 'avante', 'lsp', 'path', 'luasnip', 'buffer' },
              providers = {
                  avante = {
                      module = 'blink-cmp-avante',
                      name = 'Avante',
                      opts = {
                          -- options for blink-cmp-avante
                      }
                  }
              },
          }
      }
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = function()
      return {
        provider = "claude",
        providers = {
          claude = {
            endpoint = "https://api.anthropic.com",
            -- Note: Model name updated to "claude-sonnet-4-20250514" as per your example.
            -- If you wish to keep your original model, change this back to "claude-3-7-sonnet-20250219".
            model = "claude-sonnet-4-20250514",
            timeout = 30000, -- Timeout in milliseconds
            extra_request_body = {
              temperature = 0, -- Original temperature
              max_tokens = 4096, -- Original max_tokens
            },
          },
          openai = {
            endpoint = "https://api.openai.com/v1",
            model = "o3-mini",
            timeout = 30000, -- Timeout in milliseconds
            extra_request_body = {
              temperature = 0, -- Original temperature
              max_tokens = 4096, -- Original max_tokens
            },
          },
        },
        file_selector = {
          provider = "snacks",
        },
        custom_tools = {
          require("mcphub.extensions.avante").mcp_tool("planning", function()
            return require("avante.utils").get_project_root()
          end),
        },
      }
    end,
    build = "make",
    -- keys = {
    -- {"<leader>a", "<cmd>AvanteAsk<cr>", mode = { "n", "v", desc = "Avante: Ask"}}
    -- Leaderaa	show sidebar
    -- Leaderat	toggle sidebar visibility
    -- Leaderar	refresh sidebar
    -- Leaderaf	switch sidebar focus
    -- Leadera?	select model
    -- Leaderae	edit selected blocks
    -- },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      -- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      -- "zbirenbaum/copilot.lua", -- for providers='copilot'
      "ravitemer/mcphub.nvim",
      -- "takeshid/avante-status.nvim", https://github.com/takeshiD/avante-status.nvim
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "ai", icon = "󱚦 ", mode = { "n", "v" } },
      },
    },
  },
}
