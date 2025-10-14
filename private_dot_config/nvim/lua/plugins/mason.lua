return {
  "mason-org/mason.nvim",
  opts = {
    -- Mason is used for installing non-LSP tools like formatters, linters, and DAP adapters
    -- LSP servers are handled by mason-lspconfig.nvim in lsp.lua
    ensure_installed = {
      -- Formatters
      "stylua",       -- Lua formatter
      "shfmt",        -- Shell script formatter
      -- prettier is handled by extras.formatting.prettier

      -- Linters
      "shellcheck",   -- Shell script linter
      -- eslint is handled by extras.linting.eslint

      -- Add any other non-LSP tools here:
      -- DAP adapters, additional linters/formatters, etc.
    },
  },
}
