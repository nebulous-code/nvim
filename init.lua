
vim.g.mapleader = " "

-- keymap

vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })

-- Window: <leader>w 
vim.keymap.set("n", "<leader>w\\", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>w|", ":vsplit<CR>", { desc = "Vertical split" })
vim.keymap.set("n", "<leader>w_", ":split<CR>", { desc = "Horizontal split" })
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Nav. window left" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Nav. window right" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Nav. window down" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Nav. window up" })
vim.keymap.set("n", "<leader>wd", ":close<CR>", { desc = "Window close" })
vim.keymap.set("n", "<leader>w<", "<C-w><", { desc = "Decrease width" })
vim.keymap.set("n", "<leader>w>", "<C-w>>", { desc = "Increase width" })
vim.keymap.set("n", "<leader>w-", "<C-w>-", { desc = "Decrease height" })
vim.keymap.set("n", "<leader>w+", "<C-w>+", { desc = "Increase height" })
vim.keymap.set("n", "<leader>w=", "<C-w>=", { desc = "Equal splits" })

-- Diagnostics/Debug
vim.keymap.set("n", "<leader>dd", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "<leader>da", vim.diagnostic.setloclist, { desc = "Show all diagnostic" })
vim.keymap.set("n", "<leader>d]", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>d[", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })

-- Misc
vim.keymap.set("n", "<leader>/", ":noh<CR>", { desc = "Clear search" })

-- Plugins
vim.keymap.set("n", "<leader>Pl", ":Lazy<CR>", { desc = "Lazy menu"})
vim.keymap.set("n", "<leader>Pm", ":Mason<CR>", { desc = "Mason menu"})

-- Put (with new line) 
vim.keymap.set("n", "<leader>po", "O<Esc>p", { desc = "Put on new line above"})
vim.keymap.set("n", "<leader>pp", "o<Esc>p", { desc = "Put on new line below"})


-- Terminal mappings
vim.keymap.set("n", "<leader>t", ":terminal<CR>", { desc = "Terminal"})
vim.keymap.set("t", "<leader><Esc>", "<Esc>", { desc = "Send Esc to terminal"})
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode"})

-- Buffer
vim.keymap.set("n", "<leader>bn", ":enew<CR>", { desc = "New buffer" })
vim.keymap.set("n", "<leader>b!", ":bd!<CR>", { desc = "Delete buffer (forced)" })
vim.keymap.set("n", "<leader>br", ":file ", { desc = "Rename buffer" })
vim.keymap.set("n", "<leader>bs", ":checktime<CR>:edit<CR>", { desc = "Sync buffer with disk"})
vim.keymap.set("n", "<leader>bd", function()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs > 1 then
    vim.cmd("bprevious")
  else
    vim.cmd("enew")
  end
  vim.cmd("bdelete #")
end, { desc = "Delete buffer" })

-- Macros
vim.keymap.set("n", "<leader>q", "q", { desc = "Record macro" })
vim.keymap.set("n", "q", "<Nop>", { desc = "Disable accidental macro" })
vim.keymap.set("n", "<leader>rr", "@@", { desc = "Replay last used macro" })
vim.keymap.set("n", "<leader>ra", "@a", { desc = "Play macro in register a" })
vim.keymap.set("n", "<leader>rb", "@b", { desc = "Play macro in register b" })
vim.keymap.set("n", "<leader>rq", "@q", { desc = "Play macro in register q" })


-- tab (file tabs) settings
vim.opt.tabstop = 2        -- how wide a tab character looks
vim.opt.shiftwidth = 2     -- how wide >> and auto-indent indent
vim.opt.expandtab = true   -- use spaces instead of tab characters
vim.opt.smartindent = true -- auto-indent based on language syntax

-- line numbers
vim.opt.number = true           -- shows actual line number on current line
vim.opt.relativenumber = true   -- shows relative numbers on all other lines

-- colorize
vim.opt.termguicolors = true

-- shell settings
if vim.fn.has("win32") == 1 then
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag = "-NoLogo -Command"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
elseif vim.fn.has("mac") == 1 then 
  vim.opt.shell = "zsh"
else
  vim.opt.shell = "bash"
end

-- Clipboard
vim.opt.clipboard = "unnamedplus"
vim.opt.runtimepath:append("~/.local/share/nvim/site")

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

local function open_dev_layout()
  -- Close alpha/current buffer and start fresh
  vim.cmd("enew")
    -- Open terminal as a buffer
  vim.cmd("terminal")
  vim.cmd("stopinsert")
  vim.cmd("file terminal")
  local term_buf = vim.api.nvim_get_current_buf()
  -- Open claude in buffer
  vim.cmd("terminal claude --resume")
  vim.cmd("stopinsert")
  vim.cmd("file claude.term")
  -- save claude buffer's id
  local claude_buf = vim.api.nvim_get_current_buf()

  vim.cmd("vsplit")

  -- Create the blank working buffer
  -- local work_buf = vim.api.nvim_create_buf(true, false)
  -- vim.api.nvim_set_current_buf(work_buf)

  -- Defer pinning to give bufferline time to register the buffers
  vim.defer_fn(function()
    vim.api.nvim_set_current_buf(term_buf)
    vim.cmd("BufferLineTogglePin")
    vim.api.nvim_set_current_buf(claude_buf)
    vim.cmd("BufferLineTogglePin")
    vim.cmd("enew")
    vim.cmd("NvimTreeOpen")
  end, 200)

end

vim.api.nvim_create_user_command("DevLayout", open_dev_layout, {})
vim.keymap.set("n", "<leader>D", ":DevLayout<CR>", { desc = "Open dev layout" })-- Dev environment layout

-- Setup auto loading of the buffer on focus
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  pattern = "*",
  command = "checktime",
})

-- Function for linking prose to reverse outlines
local function toggle_ro()
  local current = vim.fn.expand("%:t")
  local cwd = vim.fn.getcwd()

  local is_ro = current:match("^RO ")

  -- Extract everything before " - " as the identifier
  local identifier
  if is_ro then
    identifier = current:match("^RO (.-) %- ")
  else
    identifier = current:match("^(.-) %- ")
  end

  if not identifier then
    vim.notify("Current file doesn't match expected pattern", vim.log.levels.WARN)
    return
  end

  local target_dir, target_pattern, template_path
  if is_ro then
    target_dir = cwd .. "/Manuscript"
    target_pattern = "^" .. vim.pesc(identifier) .. " %- "
    if vim.fn.isdirectory(target_dir) == 0 then
      vim.notify("Manuscript directory not found", vim.log.levels.WARN)
      return
    end
  else
    target_dir = cwd .. "/Reverse Outline"
    target_pattern = "^RO " .. vim.pesc(identifier) .. " %- "
    template_path = target_dir .. "/RO C_ S_ - Title.md"
    if vim.fn.isdirectory(target_dir) == 0 then
      vim.notify("No Reverse Outline directory found", vim.log.levels.WARN)
      return
    end
  end

  local files = vim.fn.glob(target_dir .. "/**/*.md", false, true)
  local match = nil
  for _, f in ipairs(files) do
    local filename = vim.fn.fnamemodify(f, ":t")
    if filename:match(target_pattern) then
      match = f
      break
    end
  end

  if is_ro then
    vim.cmd("wincmd h")
    vim.cmd("wincmd h")
  else
    vim.cmd("wincmd l")
    vim.cmd("wincmd k")
  end

  if match then
    vim.cmd("edit " .. vim.fn.fnameescape(match))
  elseif not is_ro and template_path and vim.fn.filereadable(template_path) == 1 then
    local scene_title = current:match(" %- (.-)%.md")
    local new_name = "RO " .. identifier .. " - " .. (scene_title or "Untitled") .. ".md"
    local new_path = target_dir .. "/" .. new_name
    vim.fn.system({ "cp", template_path, new_path })
    vim.cmd("edit " .. vim.fn.fnameescape(new_path))
    vim.notify("Created new RO from template: " .. new_name)
  elseif is_ro then
    local scene_title = current:match(" %- (.-)%.md")
    local new_name = identifier .. " - " .. (scene_title or "Untitled") .. ".md"
    local new_path = target_dir .. "/" .. new_name
    vim.cmd("edit " .. vim.fn.fnameescape(new_path))
    vim.notify("Created new prose file: " .. new_name)
  else
    vim.notify("No matching file found and no template available", vim.log.levels.WARN)
  end
end

vim.keymap.set("n", "<leader>ro", toggle_ro, { desc = "Toggle Reverse Outline / Prose" })

-- Function for opening a writing layout view
local function open_writing_layout()
  vim.cmd("enew")

  -- Open file tree
  vim.cmd("NvimTreeOpen")
  vim.cmd("wincmd l")

  -- Create the layout: prose column on left, split right side into top/bottom
  vim.cmd("vsplit")
  vim.cmd("wincmd l")
  vim.cmd("split")

  -- Open style guide in bottom right
  vim.cmd("wincmd j")
  local style_guide = vim.fn.getcwd() .. "/Meta/Style Guide.md"
  if vim.fn.filereadable(style_guide) == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(style_guide))
  end

  -- Move to prose column (middle window) and open most recent chapter
  vim.cmd("wincmd h")
  local manuscript_dir = vim.fn.getcwd() .. "/Manuscript"
  if vim.fn.isdirectory(manuscript_dir) == 1 then
    -- Get all .md files sorted by modification time, newest first
    local files = vim.fn.glob(manuscript_dir .. "/**/*.md", false, true)
    if #files > 0 then
      table.sort(files, function(a, b)
        return vim.fn.getftime(a) > vim.fn.getftime(b)
      end)
      vim.cmd("edit " .. vim.fn.fnameescape(files[1]))
      -- Trigger RO toggle to load the matching outline in top right
      toggle_ro()
      -- Return to prose column
      vim.cmd("wincmd h")
      vim.cmd("normal! G")
    end
  end
  -- Close the file tree now that layout is set up
  vim.cmd("NvimTreeClose")
end

vim.api.nvim_create_user_command("WritingLayout", open_writing_layout, {})
vim.keymap.set("n", "<leader>W", ":WritingLayout<CR>", { desc = "Open writing layout" })

