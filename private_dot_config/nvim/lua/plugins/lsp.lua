return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- Disable inlay hints globally (you can enable per-language if needed)
      inlay_hints = { enabled = false },

      -- LSP-based folding is enabled by default in LazyVim 15.x
      -- Uncomment to disable if you prefer treesitter/manual folding
      -- folds = { enabled = false },

      -- Disable diagnostics by default (toggle with <leader>ud)
      -- Keep signs in gutter for visual indication
      diagnostics = {
        virtual_text = false,  -- Hide inline messages
        signs = true,          -- Show icons in gutter
        underline = false,     -- Hide underlines
        update_in_insert = false,
      },

      -- Per-server configuration (optional overrides)
      -- The language extras already configure these servers with good defaults
      -- Only add customizations here if you need to override the defaults
      servers = {
        -- Example: Customize Rust Analyzer beyond extras.lang.rust defaults
        -- rust_analyzer = {
        --   settings = {
        --     ["rust-analyzer"] = {
        --       cargo = {
        --         features = "all",
        --       },
        --       check = {
        --         command = "clippy",
        --       },
        --     },
        --   },
        -- },

        -- Example: Customize Lua LS
        -- lua_ls = {
        --   settings = {
        --     Lua = {
        --       workspace = {
        --         checkThirdParty = false,
        --       },
        --     },
        --   },
        -- },
      },
    },
  },

  -- Mason LSP Config (v2.x)
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- In v2.x, servers installed via Mason are automatically enabled by default
      -- The language extras already handle LSP server installation:
      --   - extras.lang.astro     → astro
      --   - extras.lang.clojure   → clojure_lsp
      --   - extras.lang.elixir    → elixirls
      --   - extras.lang.json      → jsonls
      --   - extras.lang.python    → pyright/basedpyright
      --   - extras.lang.rust      → rust_analyzer
      --   - extras.lang.svelte    → svelte
      --   - extras.lang.terraform → terraformls
      --   - extras.lang.typescript → vtsls
      --   - extras.linting.eslint → eslint

      -- Only add servers here that aren't covered by language extras
      ensure_installed = {
        -- Example: Add any additional LSP servers not covered by extras
        -- "biome",  -- JavaScript/TypeScript formatter/linter
      },

      -- v2.x: automatic_enable is true by default
      -- Use this to exclude servers if needed:
      -- automatic_enable = {
      --   exclude = { "rust_analyzer" }  -- e.g., if using rustaceanvim plugin
      -- },
    },
  },
}
