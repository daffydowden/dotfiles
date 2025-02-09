-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_picker = "snacks"

-- Not a fan of autoformatting
vim.g.autoformat = false

--
vim.g.maplocalleader = ","

local opt = vim.opt
opt.relativenumber = false

-- Proper spelling ol' boy
opt.spelllang = { "en_gb" }
