return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    diagnostics = {
      virtual_text = false,
      signs = true,
      underline = false,
      update_in_insert = false,
    },
  },
}
