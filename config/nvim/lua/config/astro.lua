vim.filetype.add({
  extension = {
    astro = "astro",
  },
})

return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
  },
  opts = {
    ensure_installed = {
      "astro",
      "rust_analyzer",
      "clojure_lsp",
      "elixirls",
      "svelte",
      "terraformls",
      "biome",
      "eslint",
    },
  },
}
