return {
  {
    "savq/melange-nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme melange")
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    -- config = function()
      -- vim.cmd("colorscheme kanagawa")
    -- end,
  },
}
