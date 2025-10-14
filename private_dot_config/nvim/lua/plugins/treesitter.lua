return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- Add parsers for languages used in this config
    -- Note: tsx, typescript already included in LazyVim defaults
    vim.list_extend(opts.ensure_installed, {
      -- Languages from astro.lua LSP config
      "astro",
      "clojure",
      "elixir",
      "hcl", -- Terraform
      "rust",
      "svelte",
    })
  end,
}
