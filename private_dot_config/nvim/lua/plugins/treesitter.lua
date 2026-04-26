return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    -- Languages beyond LazyVim's defaults (which already include tsx, typescript, etc.)
    ensure_installed = {
      "astro",
      "clojure",
      "elixir",
      "hcl", -- Terraform
      "rust",
      "svelte",
    },
  },
}
