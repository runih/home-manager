-- Oil.nvim — edit your filesystem like a normal Neovim buffer.
-- Added by ./nvim.nix on top of the omarchy-lazyvim base config.
return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  -- Optional dependency
  dependencies = { { "echasnovski/mini.icons", opts = {} } },
  lazy = false,
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory (Oil)" },
  },
}
