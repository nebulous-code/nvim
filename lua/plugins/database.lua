-- Postgres (and friends) from inside nvim: a query buffer and a result buffer,
-- the way pgAdmin or SSMS do it. dadbod shells out to psql, so it uses the
-- client and credentials already on the machine.
--
-- Connections live in lua/local/databases.lua, which is gitignored so
-- passwords never land in this repo. See that file for the shape.

return {
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "mysql", "plsql" },
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod", "kristijanhusak/vim-dadbod-completion" },
    cmd = { "DBUI", "DBUIToggle", "DBUIClose", "DBUIAddConnection", "DBUIFindBuffer", "DB" },
    ft = { "sql", "mysql", "plsql" },
    keys = {
      { "<leader>ss", "<cmd>DBUIToggle<CR>", desc = "Toggle database drawer" },
      { "<leader>sf", "<cmd>DBUIFindBuffer<CR>", desc = "Find database buffer" },
      { "<leader>sa", "<cmd>DBUIAddConnection<CR>", desc = "Add connection" },
    },
    init = function()
      -- These have to be set before the plugin loads
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_win_position = "left"
      vim.g.db_ui_winwidth = 35
      vim.g.db_ui_save_location = vim.fn.stdpath("data") .. "/db_ui"

      -- Saving a buffer would otherwise run it against the database, which is
      -- a nasty surprise when the buffer holds a DELETE. Execute deliberately.
      vim.g.db_ui_execute_on_save = 0

      -- The sql-buffer defaults claim <Leader>W, which is WritingLayout here.
      -- Own mappings are set up below instead.
      vim.g.db_ui_disable_mappings_sql = 1

      local ok, databases = pcall(require, "local.databases")
      if ok and type(databases) == "table" then
        vim.g.dbs = databases
      end

      -- g:dbs is read once at startup, and the drawer caches connections after
      -- that, so editing lua/local/databases.lua does nothing until a restart.
      -- This re-reads the file and rebuilds the drawer in place. The close has
      -- to happen before the reset or the cached state survives.
      vim.api.nvim_create_user_command("DBReload", function()
        package.loaded["local.databases"] = nil
        local reloaded, databases = pcall(require, "local.databases")
        if not reloaded or type(databases) ~= "table" then
          vim.notify("Could not read lua/local/databases.lua", vim.log.levels.ERROR)
          return
        end
        vim.g.dbs = databases
        pcall(vim.cmd, "DBUIClose")
        pcall(vim.fn["db_ui#reset_state"])
        vim.cmd("DBUI")
        vim.notify("Reloaded " .. #databases .. " database connection(s)", vim.log.levels.INFO)
      end, { desc = "Reload database connections from lua/local/databases.lua" })

      -- The real run/save/params mappings are buffer-local to sql buffers, so
      -- which-key would not list them anywhere else. These global stand-ins
      -- keep all six visible under <leader>s; the buffer-local ones take
      -- precedence inside a sql buffer, so these only fire out of context.
      local hints = {
        ["<leader>sr"] = "Run query",
        ["<leader>sw"] = "Save query",
        ["<leader>sp"] = "Edit bind parameters",
      }
      for lhs, desc in pairs(hints) do
        vim.keymap.set({ "n", "x" }, lhs, function()
          vim.notify(desc .. " works inside a .sql buffer -- open one with <leader>ss", vim.log.levels.INFO)
        end, { desc = desc })
      end
    end,
    config = function()
      local function attach(buf)
        local map = function(mode, lhs, plug, desc)
          vim.keymap.set(mode, lhs, plug, { buffer = buf, desc = desc })
        end
        -- Normal mode runs the whole buffer, visual runs the selection
        map({ "n", "x" }, "<leader>sr", "<Plug>(DBUI_ExecuteQuery)", "Run query")
        map("n", "<leader>sw", "<Plug>(DBUI_SaveQuery)", "Save query")
        map("n", "<leader>sp", "<Plug>(DBUI_EditBindParameters)", "Edit bind parameters")

        -- Table and column completion from the live connection
        local cmp_ok, cmp = pcall(require, "cmp")
        if cmp_ok then
          cmp.setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("DadbodSql", { clear = true }),
        pattern = { "sql", "mysql", "plsql" },
        callback = function(ev)
          attach(ev.buf)
        end,
      })

      -- The buffer that triggered the load has already fired its FileType
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local ft = vim.bo[buf].filetype
        if ft == "sql" or ft == "mysql" or ft == "plsql" then
          attach(buf)
        end
      end
    end,
  },
}
