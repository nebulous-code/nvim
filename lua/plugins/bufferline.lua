return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup()
    vim.keymap.set("n", "<leader>bl", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
    vim.keymap.set("n", "<leader>bh", ":BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
  end,
}
