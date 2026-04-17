return {
  "gbprod/yanky.nvim",
  config = function()
    require("yanky").setup()

    vim.keymap.set({"n","x"}, "p", "<Plug>(YankyPutAfter)", { desc = "Put after" })
    vim.keymap.set({"n","x"}, "P", "<Plug>(YankyPutBefore)", { desc = "Put before" })
    vim.keymap.set("n", "<leader>y", ":YankyRingHistory<CR>", { desc = "Yank history" })
    vim.keymap.set("n", "<C-[>", "<Plug>(YankyCycleForward)", { desc = "Cycle yank forward" })
    vim.keymap.set("n", "<C-]>", "<Plug>(YankyCycleBackward)", { desc = "Cycle yank backward" })
  end,
}
