-- Conjure: Interactive evaluation for Clojure, Fennel and more
--
-- NOTE: LazyVim has an official extra at lua/lazyvim/plugins/extras/lang/clojure.lua
-- that includes Conjure with additional plugins (paredit, baleia, cmp-conjure).
-- To use the LazyVim extra instead, enable it with:
--   { import = "lazyvim.plugins.extras.lang.clojure" }
--
return {
  {
    "Olical/conjure",
    ft = { "clojure", "fennel" }, -- Only load on these filetypes
    -- Optional: Add completion support
    -- dependencies = {
    --   "PaterJason/cmp-conjure",
    -- },
    keys = {
      -- Manual load trigger
      {
        "<leader>cj",
        function()
          require("lazy").load({ plugins = { "conjure" } })
          vim.notify("Conjure loaded", vim.log.levels.INFO)
        end,
        desc = "Load Conjure",
      },
    },
    init = function()
      -- Disable diagnostics in log buffer
      vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "conjure-log-*",
        callback = function()
          vim.diagnostic.enable(false, { bufnr = vim.api.nvim_get_current_buf() })
        end,
      })

      -- Set configuration options here (before plugin loads)
      -- vim.g["conjure#debug"] = true

      -- Uncomment to customize HUD
      -- vim.g["conjure#log#hud#width"] = 0.5
      -- vim.g["conjure#log#hud#enabled"] = true

      -- Uncomment to customize inline evaluation
      -- vim.g["conjure#eval#inline_results"] = true
    end,
  },

  -- Which-key integration for Conjure mappings
  -- NOTE: This approach works by monkey-patching Conjure's mapping function
  {
    "folke/which-key.nvim",
    optional = true,
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "clojure", "fennel" },
        callback = function(event)
          local wk = require("which-key")

          -- Register descriptions for Conjure's buffer-local mappings
          -- We need to do this after a short delay to ensure Conjure has set them up
          vim.schedule(function()
            pcall(wk.add, {
              -- Groups
              { "<localleader>c", group = "connect", buffer = event.buf },
              { "<localleader>e", group = "eval", buffer = event.buf },
              { "<localleader>g", group = "goto", buffer = event.buf },
              { "<localleader>l", group = "log", buffer = event.buf },
              { "<localleader>r", group = "refresh", buffer = event.buf },
              { "<localleader>s", group = "session", buffer = event.buf },
              { "<localleader>t", group = "test", buffer = event.buf },
              { "<localleader>v", group = "view", buffer = event.buf },
            })
          end)
        end,
      })
    end,
  },
}
