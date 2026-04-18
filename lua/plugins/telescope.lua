return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({})

      -- Keymaps
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fd", builtin.live_grep, { desc = "Search in file details" })
      vim.keymap.set("n", "<leader>fb", function()
        builtin.buffers({ initial_mode = "normal" })
      end, { desc = "Search buffers" })
      vim.keymap.set("n", "<leader>bf", function()
        builtin.buffers({ initial_mode = "normal" })
      end, { desc = "Search buffers" })
       vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fgs", function()
        builtin.git_status({ initial_mode = "normal" })
      end,{ desc = "Git status" })
      vim.keymap.set("n", "<leader>fgb", function()
        builtin.git_branches({ initial_mode = "normal" })
      end,{ desc = "Git branches" })
      vim.keymap.set("n", "<leader>fgc", function()
        builtin.git_commits({ initial_mode = "normal" })
      end,{ desc = "Git commits" })
      end,
  },
}
