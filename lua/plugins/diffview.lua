return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("diffview").setup()

    vim.keymap.set("n", "<leader>gd", ":DiffviewOpen<CR>", { desc = "Diff view" })
    vim.keymap.set("n", "<leader>gh", ":DiffviewFileHistory<CR>", { desc = "File history" })
    vim.keymap.set("n", "<leader>gx", ":DiffviewClose<CR>", { desc = "Close diff view" })
  end,
}
