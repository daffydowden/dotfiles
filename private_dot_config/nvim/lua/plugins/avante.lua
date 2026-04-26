-- Override the lazyvim.plugins.extras.ai.avante extra defaults.
-- The extra defaults to provider = "copilot", which requires copilot.lua/vim;
-- we use Claude directly via ANTHROPIC_API_KEY.
return {
  "yetone/avante.nvim",
  opts = {
    provider = "claude",
  },
}
