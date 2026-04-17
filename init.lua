vim.g.mapleader = " "

-- keymap

vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

-- Window: <leader>w 
vim.keymap.set("n", "<leader>w\\", ":vsplit<CR>", { desc = "Vertical split" })
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

-- Terminal mappings
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode"})

-- Window navigation from terminal mode
vim.keymap.set("t", "<leader>wh", "<C-\\><C-n><C-w>h", { desc = "Nav. window left" })
vim.keymap.set("t", "<leader>wl", "<C-\\><C-n><C-w>l", { desc = "Nav. window right" })
vim.keymap.set("t", "<leader>wj", "<C-\\><C-n><C-w>j", { desc = "Nav. window down" })
vim.keymap.set("t", "<leader>wk", "<C-\\><C-n><C-w>k", { desc = "Nav. window up" })

-- Buffer
vim.keymap.set("n", "<leader>bn", ":enew<CR>", { desc = "New buffer" })
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "Delete buffer" })

-- tab (file tabs) settings
vim.opt.tabstop = 2        -- how wide a tab character looks
vim.opt.shiftwidth = 2     -- how wide >> and auto-indent indent
vim.opt.expandtab = true   -- use spaces instead of tab characters
vim.opt.smartindent = true -- auto-indent based on language syntax

-- line numbers
vim.opt.number = true           -- shows actual line number on current line
vim.opt.relativenumber = true   -- shows relative numbers on all other lines

-- shell settings
vim.opt.shell = "pwsh"
vim.opt.shellcmdflag = "-NoLogo -NoProfile -Command"
vim.opt.shellquote = ""
vim.opt.shellxquote = ""

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Window Transparency
vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
vim.api.nvim_set_hl(0, "NormalFloat", {bg = "none"})
vim.api.nvim_set_hl(0, "Normal", {bg = "none"})


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
