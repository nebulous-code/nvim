return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
  },
  config = function()
    require("neogit").setup({
      integrations = {
        diffview = true,
      },
    })

    vim.keymap.set("n", "<leader>gg", ":Neogit<CR>", { desc = "Neogit" })
  end,
}
