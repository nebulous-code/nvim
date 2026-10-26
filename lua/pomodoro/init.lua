-- Pomodoro display and controls on top of pomo.nvim
--
-- pomo.nvim clamps its countdown at zero (math.max(..., 0)), then closes the
-- timer and removes it from its registry, so a statusline built on the plugin
-- alone goes blank the moment a session ends. This records when a timer
-- finished so the statusline can keep counting upward until the next one
-- starts. The notifier below is also what keeps pomo silent: it replaces the
-- default pop-up notifier and displays nothing itself.

local M = {}

local uv = vim.uv or vim.loop

M.config = {
  work = "50m",
  rest = "10m",
  icon = "", -- nerd font clock
}

local state = {
  finished_at = nil, -- uv.now() in ms, when the last timer hit zero
  name = nil,
}

local function format(seconds)
  seconds = math.max(math.floor(seconds), 0)
  return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

--- The pomo.nvim notifier -----------------------------------------------------

---Built by pomo via `init(timer, opts)`. Methods are called with `:` so each
---one receives self; none of them need it.
---@param timer table pomo.Timer
function M.notifier(timer)
  return {
    start = function()
      state.finished_at = nil
      state.name = timer.name
    end,
    tick = function() end,
    done = function()
      state.finished_at = uv.now()
      state.name = timer.name
    end,
    stop = function()
      state.finished_at = nil
      state.name = nil
    end,
    hide = function() end,
    show = function() end,
  }
end

--- Statusline ----------------------------------------------------------------

---Counting down while a timer runs, counting up once it is over, empty when
---nothing is active.
---@return string
function M.statusline()
  local ok, pomo = pcall(require, "pomo")
  if not ok then
    return ""
  end

  local timer = pomo.get_first_to_finish()
  if timer ~= nil then
    local remaining = timer:time_remaining()
    if remaining ~= nil then
      return M.config.icon .. " " .. format(remaining) .. (timer.paused and " held" or "")
    end
  end

  if state.finished_at ~= nil then
    return M.config.icon .. " +" .. format((uv.now() - state.finished_at) / 1000)
  end

  return ""
end

--- Controls ------------------------------------------------------------------

---@param duration string e.g. "50m"
---@param name string
local function start(duration, name)
  local pomo = require "pomo"
  local seconds = require("pomo.util").parse_time(duration)
  if not seconds or seconds <= 0 then
    vim.notify("Could not read duration: " .. tostring(duration), vim.log.levels.ERROR)
    return
  end
  -- Only one session at a time, so clear anything already running
  if pomo.num_active_timers() > 0 then
    pcall(pomo.stop_timer)
  end
  pomo.start_timer(seconds, { name = name })
end

function M.work()
  start(M.config.work, "Work")
end

function M.rest()
  start(M.config.rest, "Break")
end

function M.custom()
  vim.ui.input({ prompt = "Timer duration (e.g. 50m, 1h30m): " }, function(input)
    if input and input ~= "" then
      start(input, "Timer")
    end
  end)
end

---Pause a running timer, or resume a held one.
function M.toggle_pause()
  local pomo = require "pomo"
  local timer = pomo.get_first_to_finish()
  if timer == nil then
    vim.notify("No timer running", vim.log.levels.INFO)
    return
  end
  if timer.paused then
    pomo.resume_timer(timer)
  else
    pomo.pause_timer(timer)
  end
end

---Stop the timer and clear any overtime from the statusline.
function M.stop()
  local pomo = require "pomo"
  if pomo.num_active_timers() > 0 then
    pomo.stop_timer()
  end
  state.finished_at = nil
  state.name = nil
end

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
end

return M
