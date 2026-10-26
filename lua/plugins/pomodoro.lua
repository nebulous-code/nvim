-- Pomodoro timer. pomo.nvim owns durations, pause/resume and the timer
-- lifecycle; lua/pomodoro holds the statusline display and the overtime count.
-- The statusline component itself is wired up in lua/plugins/lualine.lua.

return {
  "epwalsh/pomo.nvim",
  version = "*",
  cmd = { "TimerStart", "TimerRepeat", "TimerSession", "TimerStop", "TimerShow", "TimerHide", "TimerPause", "TimerResume" },
  keys = {
    {
      "<leader>oo",
      function()
        require("pomodoro").work()
      end,
      desc = "Start work timer",
    },
    {
      "<leader>ob",
      function()
        require("pomodoro").rest()
      end,
      desc = "Start break timer",
    },
    {
      "<leader>oc",
      function()
        require("pomodoro").custom()
      end,
      desc = "Start custom timer",
    },
    {
      "<leader>op",
      function()
        require("pomodoro").toggle_pause()
      end,
      desc = "Pause or resume timer",
    },
    {
      "<leader>os",
      function()
        require("pomodoro").stop()
      end,
      desc = "Stop timer",
    },
  },
  init = function()
    -- Durations live here for visibility. init runs at startup, before the
    -- plugin loads, so this does not clobber a later setup() call.
    require("pomodoro").setup({
      work = "50m",
      rest = "10m",
    })
  end,
  opts = function()
    return {
      -- One silent notifier, replacing pomo's default pop-up. The config is
      -- merged with vim.tbl_extend (shallow), so this genuinely replaces the
      -- default list rather than adding to it.
      notifiers = {
        { init = require("pomodoro").notifier },
      },
      -- Table helpers and sessions keep pomo's own defaults
      timers = {},
    }
  end,
}
