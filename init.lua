vim.g.mapleader = " "
vim.keymap.set("n", "<leader>w|", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>w-", ":split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Nav. window left" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Nav. window right" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Nav. window down" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Nav. window up" })
vim.keymap.set("n", "<leader>wd", ":close<CR>", { desc = "Window close" })

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("plugins")
