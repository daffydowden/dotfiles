-- Override LazyVim's default completion plugins BEFORE they load
-- This must be in a separate file that loads early

return {
  -- Disable all LazyVim completion plugins at the source
  { "hrsh7th/nvim-cmp", enabled = false },
  { "hrsh7th/cmp-buffer", enabled = false },
  { "hrsh7th/cmp-path", enabled = false },
  { "hrsh7th/cmp-nvim-lsp", enabled = false },
  { "hrsh7th/cmp-cmdline", enabled = false },
  -- { "L3MON4D3/LuaSnip", enabled = false }, -- Re-enabled for blink.cmp
  { "saadparwaiz1/cmp_luasnip", enabled = false },
  { "rafamadriz/friendly-snippets", enabled = false }, -- We'll re-enable this in blink.lua
}