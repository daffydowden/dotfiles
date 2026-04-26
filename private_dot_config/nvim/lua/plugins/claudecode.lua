-- Overrides for the lazyvim.plugins.extras.ai.claudecode extra:
-- keep our preferred <leader>C prefix and right-side terminal layout,
-- and replace (not append) the extra's <leader>a* keymaps so Avante owns that prefix.
local prefix = "<leader>C"

return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = {
        provider = "snacks",
        split_side = "right",
        split_width_percentage = 0.4,
        auto_close = true,
      },
      port_range = { min = 10000, max = 65535 },
      selection = {
        enabled = true,
        delay = 100,
      },
      cwd_provider = function()
        local git_root = vim.fs.root(0, ".git")
        return git_root or vim.fn.getcwd()
      end,
      diff = {
        auto_close = false,
        show_line_numbers = true,
      },
    },
    keys = function()
      return {
        { prefix, "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code", mode = "n" },
        { prefix .. "f", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code", mode = "n" },
        { prefix .. "r", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude", mode = "n" },
        { prefix .. "m", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Model", mode = "n" },
        { prefix .. "?", "<cmd>ClaudeCodeStatus<cr>", desc = "Status", mode = "n" },
        { prefix .. "s", "<cmd>ClaudeCodeSend<cr>", desc = "Send Selection", mode = "v" },
        {
          prefix .. "s",
          "<cmd>ClaudeCodeTreeAdd<cr>",
          desc = "Add File from Tree",
          ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
        },
        {
          prefix .. "a",
          function()
            local filepath = vim.fn.expand("%")
            if filepath == "" then
              vim.notify("ClaudeCode: No file in current buffer", vim.log.levels.WARN)
              return
            end
            vim.cmd("ClaudeCodeAdd " .. filepath)
          end,
          desc = "Add Current File",
          mode = "n",
        },
        { prefix .. "y", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Diff", mode = "n" },
        { prefix .. "n", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Diff", mode = "n" },
      }
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { prefix, group = "Claude Code", icon = "󰧑 ", mode = { "n", "v" } },
      },
    },
  },
}
