return {
  -- Add blink.cmp (nvim-cmp disabled in disable-cmp.lua)
  {
    "saghen/blink.cmp",
    lazy = false, -- lazy loading handled internally
    dependencies = {
      "rafamadriz/friendly-snippets",
      "Kaiser-Yang/blink-cmp-avante",
      "L3MON4D3/LuaSnip",
    },
    version = "1.*", -- Use correct version constraint
    opts = {
      keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<C-y>"] = { "select_and_accept" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { 'avante', 'lsp', 'path', 'snippets', 'buffer' },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
        providers = {
            avante = {
                module = 'blink-cmp-avante',
                name = 'Avante',
                opts = {
                    -- options for blink-cmp-avante
                }
            },
            codecompanion = {
                name = 'CodeCompanion',
                module = 'codecompanion.providers.completion.blink',
            }
        },
      },
      snippets = { 
        preset = 'luasnip' 
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
      },
    },
    opts_extend = { "sources.default" },
  },
}
