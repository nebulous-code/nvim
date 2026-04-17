vim.g.mapleader = " "

-- keymap

-- Window: <leader>w 
vim.keymap.set("n", "<leader>w|", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>w-", ":split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Nav. window left" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Nav. window right" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Nav. window down" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Nav. window up" })
vim.keymap.set("n", "<leader>wd", ":close<CR>", { desc = "Window close" })

-- Diagnostics/Debug
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader>da", vim.diagnostic.setloclist, { desc = "Show all diagnostic" })
vim.keymap.set("n", "<leader>d]", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>d[", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })

-- Plugins
vim.keymap.set("n", "<leader>pl", ":Lazy<CR>", { desc = "Lazy menu"})
vim.keymap.set("n", "<leader>pm", ":Mason<CR>", { desc = "Mason menu"})

-- tab settings
vim.opt.tabstop = 2        -- how wide a tab character looks
vim.opt.shiftwidth = 2     -- how wide >> and auto-indent indent
vim.opt.expandtab = true   -- use spaces instead of tab characters
vim.opt.smartindent = true -- auto-indent based on language syntax

-- line numbers
vim.opt.number = true           -- shows actual line number on current line
vim.opt.relativenumber = true   -- shows relative numbers on all other lines

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
