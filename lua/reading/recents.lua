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
  width = 80, -- text column, roughly a printed page
  margins = true,
  scrolloff = 999, -- typewriter scrolling: the reading line stays centred
  band = true, -- highlight the reading line and its neighbours
  band_rows = 1, -- rows highlighted either side of the cursor
  band_color = nil, -- background for the band; nil follows CursorLine
}

-- The book currently open in the reader
local state = {
  bufnr = nil,
  path = nil,
  chapter = nil,
  margins = {},
  opening = false,
  prev_scrolloff = nil,
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

--- Centered reading layout -------------------------------------------------

-- One scratch buffer is shared by both margin windows
local margin_bufnr = nil

local function margin_buffer()
  if margin_bufnr and vim.api.nvim_buf_is_valid(margin_bufnr) then
    return margin_bufnr
  end
  margin_bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[margin_bufnr].buftype = "nofile"
  vim.bo[margin_bufnr].bufhidden = "hide"
  vim.bo[margin_bufnr].swapfile = false
  vim.bo[margin_bufnr].modifiable = false
  return margin_bufnr
end

local function quiet_window(win)
  local opts = {
    number = false,
    relativenumber = false,
    cursorline = false,
    signcolumn = "no",
    foldcolumn = "0",
    list = false,
    spell = false,
  }
  for name, value in pairs(opts) do
    pcall(vim.api.nvim_set_option_value, name, value, { win = win })
  end
end

local function close_margins()
  for _, win in ipairs(state.margins) do
    if vim.api.nvim_win_is_valid(win) then
      pcall(vim.api.nvim_win_close, win, true)
    end
  end
  state.margins = {}
end

-- Three columns, empty margins either side of the text. The plugin wraps to
-- whichever window is current when the book opens, so the centre window has to
-- exist and be sized before we hand off -- resizing afterwards does not reflow.
local function build_layout(width)
  close_margins()
  -- The two vertical separators each take a column, so discount them or the
  -- right margin comes up short and the text sits off-centre.
  local margin = math.floor((vim.o.columns - width - 2) / 2)
  if margin < 8 then
    return false -- screen too narrow; read full width rather than pretend
  end

  local center = vim.api.nvim_get_current_win()

  vim.cmd("aboveleft vsplit")
  local left = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(left, margin_buffer())

  vim.api.nvim_set_current_win(center)
  vim.cmd("belowright vsplit")
  local right = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(right, margin_buffer())

  vim.api.nvim_set_current_win(center)
  for _, win in ipairs({ left, center, right }) do
    quiet_window(win)
  end

  -- Size the margins and let the text column take what is left. Forcing the
  -- centre width instead makes vim rob one margin to pay the other, which
  -- collapses the right side on narrower screens. equalalways off stops it
  -- re-spreading them afterwards.
  local equalalways = vim.o.equalalways
  vim.o.equalalways = false
  -- Splits inherit winfixwidth from the window they came from, so a layout
  -- built after a previous one would refuse to resize. Clear it first.
  for _, win in ipairs({ left, center, right }) do
    vim.wo[win].winfixwidth = false
  end
  -- Two passes: resizing one margin shifts the other, so a single pass leaves
  -- the text off-centre at some widths. The second pass converges.
  for _ = 1, 2 do
    vim.api.nvim_win_set_width(left, margin)
    vim.api.nvim_win_set_width(right, margin)
  end
  for _, win in ipairs({ left, center, right }) do
    vim.wo[win].winfixwidth = true
  end
  vim.o.equalalways = equalalways

  state.margins = { left, right }
  return true
end

--- Reading band -----------------------------------------------------------

local band_ns = vim.api.nvim_create_namespace("reading_band")

local function define_band_hl()
  if config.band_color then
    vim.api.nvim_set_hl(0, "ReadingBand", { bg = config.band_color })
  else
    -- default = true so a colorscheme can override it
    vim.api.nvim_set_hl(0, "ReadingBand", { link = "CursorLine", default = true })
  end
end

-- line_hl_group paints the full width of the window, so the band runs the
-- whole text column rather than stopping at the end of the text.
local function draw_band()
  if not (config.band and state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr)) then
    return
  end
  local win = vim.fn.bufwinid(state.bufnr)
  if win == -1 then
    return
  end
  vim.api.nvim_buf_clear_namespace(state.bufnr, band_ns, 0, -1)
  local count = vim.api.nvim_buf_line_count(state.bufnr)
  local cursor = vim.api.nvim_win_get_cursor(win)[1]
  local first = math.max(1, cursor - config.band_rows)
  local last = math.min(count, cursor + config.band_rows)
  for line = first, last do
    pcall(vim.api.nvim_buf_set_extmark, state.bufnr, band_ns, line - 1, 0, {
      line_hl_group = "ReadingBand",
    })
  end
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
      callback = function(ev)
        save_position()
        vim.api.nvim_buf_clear_namespace(state.bufnr, band_ns, 0, -1)
        -- Not while another book is being opened into the same layout
        if ev.event == "BufWinLeave" and not state.opening then
          close_margins()
          if state.prev_scrolloff then
            local win = vim.fn.bufwinid(state.bufnr)
            if win ~= -1 then
              vim.wo[win].scrolloff = state.prev_scrolloff
            end
            state.prev_scrolloff = nil
          end
        end
      end,
    })
  end
  if state.bufnr then
    vim.api.nvim_create_autocmd({ "CursorMoved", "BufEnter" }, {
      group = group,
      buffer = state.bufnr,
      callback = draw_band,
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

  state.opening = true
  if config.margins then
    build_layout(config.width)
  end
  local ok, err = pcall(open, abs)
  state.opening = false
  if not ok then
    vim.notify("Could not open book: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  state.bufnr = vim.api.nvim_get_current_buf()
  state.path = abs
  state.chapter = opts.chapter or read_plugin_chapter(abs) or 1

  -- Typewriter scrolling. Window-local, and restored on the way out so the
  -- window does not keep it once you are back to editing.
  if config.scrolloff then
    local win = vim.api.nvim_get_current_win()
    state.prev_scrolloff = vim.wo[win].scrolloff
    vim.wo[win].scrolloff = config.scrolloff
  end

  restore_line(opts.line)
  record(abs, state.chapter, opts.line)
  attach_autocmds()
  vim.schedule(draw_band)

  -- The contents list is on <leader>kt now, so give gt back to vim
  pcall(vim.api.nvim_buf_del_keymap, state.bufnr, "n", "gt")
end

---Show the table of contents for the open book.
function M.toc()
  if not (state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr)) then
    vim.notify("No book open", vim.log.levels.INFO)
    return
  end
  require("epub.view").show_toc()
end

---Move a chapter forward or back in the open book.
local function chapter_step(fn)
  if not (state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr)) then
    vim.notify("No book open", vim.log.levels.INFO)
    return
  end
  require("epub.view")[fn]()
end

function M.next_chapter()
  chapter_step("next_chapter")
end

function M.prev_chapter()
  chapter_step("prev_chapter")
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

  define_band_hl()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("ReadingBandHl", { clear = true }),
    callback = define_band_hl,
  })
end

return M
