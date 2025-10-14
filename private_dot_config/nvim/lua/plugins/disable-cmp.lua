-- Disable nvim-cmp and related plugins
-- LazyVim 14.x+ uses blink.cmp by default, but this ensures
-- no old nvim-cmp plugins are loaded if you're migrating from an older setup

return {
  -- Disable all nvim-cmp plugins
  { "hrsh7th/nvim-cmp", enabled = false },
  { "hrsh7th/cmp-buffer", enabled = false },
  { "hrsh7th/cmp-path", enabled = false },
  { "hrsh7th/cmp-nvim-lsp", enabled = false },
  { "hrsh7th/cmp-cmdline", enabled = false },
  { "saadparwaiz1/cmp_luasnip", enabled = false },

  -- Note: LuaSnip and friendly-snippets are used by blink.cmp
  -- They are configured in blink.lua, not disabled here
}