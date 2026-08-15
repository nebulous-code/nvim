-- Recently-read tracking for epub.nvim
--
-- epub.nvim remembers a last chapter per book, but only writes it on ]c / [c,
-- keys its file by basename (so two books named the same collide), and never
-- records where you were inside a chapter. This module keeps its own store,
-- keyed by absolute path, holding chapter + cursor line, and hands the chapter
-- back to the plugin at open time so a resume lands in the right place.

local M = {}

local config = {
  library = nil,
  limit = 5,
  store = vim.fn.stdpath("data") .. "/reading/recents.json",
}

-- The book currently open in the reader
local state = {
  bufnr = nil,
  path = nil,
  chapter = nil,
}

-- Captured before we wrap it, so our own opens don't recurse
local plugin_open = nil

--- Our recents store -------------------------------------------------------

local function read_store()
  if vim.fn.filereadable(config.store) == 0 then
    return {}
  end
  local lines = vim.fn.readfile(config.store)
  if vim.tbl_isempty(lines) then
    return {}
  end
  local ok, data = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok or type(data) ~= "table" then
    return {}
  end
  return data
end

local function write_store(entries)
  vim.fn.mkdir(vim.fn.fnamemodify(config.store, ":h"), "p")
  vim.fn.writefile({ vim.json.encode(entries) }, config.store)
end

--- Move a book to the front of the list, trimming to the limit
local function record(path, chapter, line)
  local abs = vim.fn.fnamemodify(path, ":p")
  local kept = {}
  for _, entry in ipairs(read_store()) do
    if entry.path ~= abs then
      kept[#kept + 1] = entry
    end
  end
  table.insert(kept, 1, {
    path = abs,
    title = vim.fn.fnamemodify(abs, ":t:r"),
    chapter = chapter,
    line = line,
    opened_at = os.time(),
  })
  while #kept > config.limit do
    table.remove(kept)
  end
  write_store(kept)
end

--- The plugin's own per-book file ------------------------------------------

local function plugin_data_file(path)
  local epub = require("epub")
  local data_dir = epub.options and epub.options.data_dir
    or (vim.fn.stdpath("data") .. "/epub_reader")
  return data_dir .. "/" .. vim.fn.fnamemodify(path, ":t:r") .. ".json"
end

local function read_plugin_chapter(path)
  local file = plugin_data_file(path)
  if vim.fn.filereadable(file) == 0 then
    return nil
  end
  local ok, data = pcall(vim.json.decode, vim.fn.readfile(file)[1] or "")
  if ok and type(data) == "table" then
    return data.last_chapter
  end
  return nil
end

-- Seed the plugin's file so its own restore lands on our chapter
local function write_plugin_chapter(path, chapter)
  local file = plugin_data_file(path)
  vim.fn.mkdir(vim.fn.fnamemodify(file, ":h"), "p")
  vim.fn.writefile({ vim.json.encode({ last_chapter = chapter }) }, file)
end

--- Position ----------------------------------------------------------------

local function current_line()
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    local win = vim.fn.bufwinid(state.bufnr)
    if win ~= -1 then
      return vim.api.nvim_win_get_cursor(win)[1]
    end
  end
  return nil
end

local function save_position()
  if not state.path then
    return
  end
  local chapter = state.chapter or read_plugin_chapter(state.path)
  record(state.path, chapter, current_line())
end

local function restore_line(line)
  if not line or line <= 1 then
    return
  end
  vim.schedule(function()
    if not (state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr)) then
      return
    end
    local win = vim.fn.bufwinid(state.bufnr)
    if win == -1 then
      return
    end
    local count = vim.api.nvim_buf_line_count(state.bufnr)
    vim.api.nvim_win_set_cursor(win, { math.min(line, count), 0 })
  end)
end

local function attach_autocmds()
  local group = vim.api.nvim_create_augroup("ReadingRecents", { clear = true })
  if state.bufnr then
    vim.api.nvim_create_autocmd({ "BufLeave", "BufWinLeave" }, {
      group = group,
      buffer = state.bufnr,
      callback = save_position,
    })
  end
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = save_position,
  })
end

--- Keeping our chapter in step with the reader ------------------------------

-- next_chapter / prev_chapter write the plugin's file, so we can just read it
-- back. show_toc does not, so we read the index out of the ToC selection.
local function wrap_navigation()
  local view = require("epub.view")
  if view.__reading_wrapped then
    return
  end
  view.__reading_wrapped = true

  for _, name in ipairs({ "next_chapter", "prev_chapter" }) do
    local original = view[name]
    view[name] = function(...)
      original(...)
      if state.path then
        state.chapter = read_plugin_chapter(state.path) or state.chapter
      end
      save_position()
    end
  end

  local show_toc = view.show_toc
  if not show_toc then
    return
  end
  view.show_toc = function(...)
    local select = vim.ui.select
    -- Borrow vim.ui.select for this one call to learn which entry was picked
    vim.ui.select = function(items, opts, on_choice)
      vim.ui.select = select
      select(items, opts, function(choice, idx)
        local n = choice and tonumber(tostring(choice):match("^(%d+)"))
        if n then
          state.chapter = n
        end
        if on_choice then
          on_choice(choice, idx)
        end
        save_position()
      end)
    end
    local ok, err = pcall(show_toc, ...)
    vim.ui.select = select
    if not ok then
      vim.notify("Table of contents failed: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

--- Public ------------------------------------------------------------------

---Open a book, optionally resuming a stored chapter and line.
---@param path string
---@param opts table|nil { chapter = number, line = number }
function M.open(path, opts)
  opts = opts or {}
  local abs = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  if vim.fn.filereadable(abs) == 0 then
    vim.notify("No such epub: " .. abs, vim.log.levels.ERROR)
    return
  end

  if opts.chapter then
    write_plugin_chapter(abs, opts.chapter)
  end

  -- Requiring first lets lazy load the plugin, which runs setup() and fills
  -- plugin_open -- otherwise we would call our own wrapper and recurse.
  local epub = require("epub")
  local open = plugin_open or epub.open_epub
  open(abs)

  state.bufnr = vim.api.nvim_get_current_buf()
  state.path = abs
  state.chapter = opts.chapter or read_plugin_chapter(abs) or 1

  restore_line(opts.line)
  record(abs, state.chapter, opts.line)
  attach_autocmds()
end

---Reopen the most recently read book where you left off.
function M.resume()
  local entry = read_store()[1]
  if not entry then
    vim.notify("No recent books yet", vim.log.levels.INFO)
    return
  end
  M.open(entry.path, { chapter = entry.chapter, line = entry.line })
end

---Pick from the recent list.
function M.pick_recent()
  local entries = read_store()
  if vim.tbl_isempty(entries) then
    vim.notify("No recent books yet", vim.log.levels.INFO)
    return
  end
  local items = {}
  for i, entry in ipairs(entries) do
    items[i] = string.format("%s  (chapter %s)", entry.title, entry.chapter or "?")
  end
  vim.ui.select(items, { prompt = "Recent books:" }, function(_, idx)
    if idx then
      local entry = entries[idx]
      M.open(entry.path, { chapter = entry.chapter, line = entry.line })
    end
  end)
end

---Ask for a path. Fallback when telescope is unavailable.
function M.prompt_open()
  vim.ui.input({ prompt = "Open epub: ", completion = "file" }, function(input)
    if input and input ~= "" then
      M.open(input)
    end
  end)
end

-- The library holds thousands of non-epub files plus macOS "._" stubs,
-- so the picker filters rather than listing everything.
local function find_command()
  for _, fd in ipairs({ "fd", "fdfind" }) do
    if vim.fn.executable(fd) == 1 then
      return { fd, "--type", "f", "--extension", "epub", "--exclude", "._*" }
    end
  end
  if vim.fn.executable("rg") == 1 then
    return { "rg", "--files", "--glob", "*.epub", "--glob", "!._*" }
  end
  return { "find", ".", "-type", "f", "-iname", "*.epub", "-not", "-name", "._*" }
end

---Fuzzy-find a book in the configured library.
function M.pick_library()
  if not config.library or vim.fn.isdirectory(config.library) == 0 then
    vim.notify("No book library configured", vim.log.levels.WARN)
    return M.prompt_open()
  end
  local ok, builtin = pcall(require, "telescope.builtin")
  if not ok then
    return M.prompt_open()
  end

  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  builtin.find_files({
    prompt_title = "Books",
    cwd = config.library,
    find_command = find_command(),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry then
          return
        end
        local path = entry.path or entry.value
        if not path:match("^/") then
          path = config.library .. "/" .. path
        end
        M.open(path)
      end)
      return true
    end,
  })
end

function M.setup(opts)
  config = vim.tbl_extend("force", config, opts or {})

  -- Route :EpubOpen and any direct API call through our bookkeeping
  local epub = require("epub")
  if not plugin_open then
    plugin_open = epub.open_epub
    epub.open_epub = function(path)
      M.open(path)
    end
  end

  wrap_navigation()
end

return M
