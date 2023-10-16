-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.maplocalleader = ","

opts = function(_, dashboard)
  local button = dashboard.button("p", " " .. " Projects", ":Telescope projects <CR>")
  button.opts.hl = "AlphaButtons"
  button.opts.hl_shortcut = "AlphaShortcut"
  table.insert(dashboard.section.buttons.val, 4, button)
end
