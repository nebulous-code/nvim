return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
  -- FIX:
  -- TODO:
  -- HACK:
  -- WARN:
  -- PERF: Performance
  -- NOTE:
  -- TEST:
  require("todo-comments").setup({
    highlight = {
      keyword = "wide",
    },
    colors = {
      fix =  { "#7D2A2F" },   -- error
      warn = { "#E49B5D" }, -- warning
      hack = { "#8B7449" }, -- warning
      todo = { "#422741" }, -- info 
      note = { "#233524" }, -- hint
      perf = { "#273142" }, -- default
      test = { "#253333" }, -- test
    },
    keywords = {
      FIX =  { color = "fix" },
      TODO = { color = "todo" },
      HACK = { color = "hack" },
      WARN = { color = "warn" },
      PERF = { color = "perf" },
      NOTE = { color = "note" },
      TEST = { color = "test" },
    },
  })
  -- require("todo-comments").setup()

  -- Jump between todos
  vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next todo" })
  vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Prev todo" })

  -- Search todos with Telescope
  vim.keymap.set("n", "<leader>ft", ":TodoTelescope<CR>", { desc = "Find todos" })
  end,
}
