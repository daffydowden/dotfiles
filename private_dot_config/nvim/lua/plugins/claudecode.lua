local prefix = "<leader>C"

return {
  {
    "coder/claudecode.nvim",
    dependencies = {
      "folke/snacks.nvim", -- Required for terminal support
    },
    opts = {
      -- Terminal configuration
      terminal = {
        provider = "snacks", -- Use snacks terminal (you already have it configured)
        split_side = "right", -- Open on right side (options: "left", "right")
        split_width_percentage = 0.4, -- 40% of screen width (must be between 0 and 1)
        auto_close = true, -- Auto-close terminal when Claude Code exits
      },

      -- Port range for WebSocket server
      port_range = { min = 10000, max = 65535 },

      -- Logging level (for debugging)
      -- log_level = vim.log.levels.DEBUG,

      -- Selection tracking
      selection = {
        enabled = true,
        delay = 100, -- Delay in ms before sending selection updates
      },

      -- Working directory provider
      -- Uses git repository root if available
      cwd_provider = function()
        local git_root = vim.fs.root(0, ".git")
        return git_root or vim.fn.getcwd()
      end,

      -- Diff window configuration
      diff = {
        auto_close = false, -- Keep diff window open after accept/reject
        show_line_numbers = true,
      },
    },
    keys = {
      -- Core commands
      { prefix, "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code", mode = "n" },
      { prefix .. "f", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude Code", mode = "n" },
      { prefix .. "r", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude", mode = "n" },
      { prefix .. "m", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Model", mode = "n" },
      { prefix .. "?", "<cmd>ClaudeCodeStatus<cr>", desc = "Status", mode = "n" },

      -- Send context to Claude Code
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

      -- Diff management
      { prefix .. "y", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Diff", mode = "n" },
      { prefix .. "n", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Diff", mode = "n" },
    },
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
