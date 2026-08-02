return {
  {
    "Olical/conjure",
    event = function()
      return {}
    end,
    ft = { "clojure" },
    dependencies = { "m00qek/baleia.nvim" },
  },
  {
    "julienvincent/nvim-paredit",
    event = function()
      return {}
    end,
    ft = { "clojure" },
  },
  {
    "m00qek/baleia.nvim",
    lazy = true,
  },
  {
    "windwp/nvim-ts-autotag",
    event = function()
      return {}
    end,
    ft = {
      "astro",
      "blade",
      "dot",
      "elixir",
      "eruby",
      "glimmer",
      "handlebars",
      "hbs",
      "heex",
      "html",
      "htmlangular",
      "htmldjango",
      "javascript",
      "javascript.glimmer",
      "javascript.jsx",
      "javascriptreact",
      "liquid",
      "markdown",
      "php",
      "rescript",
      "rust",
      "svelte",
      "templ",
      "twig",
      "typescript",
      "typescript.glimmer",
      "typescript.tsx",
      "typescriptreact",
      "vento",
      "vue",
      "xml",
    },
  },
}
