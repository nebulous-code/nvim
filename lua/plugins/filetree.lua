return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
	require("nvim-tree").setup({
    	actions = {
			  open_file = {
				  window_picker = {
					  enable = false,
				},
			},
		},
    renderer = {
      icons = {
        glyphs = {
          git = {
            unstaged = "~",
            staged = "✓",
            unmerged = "⌥",
            renamed = "➜",
            untracked = "?",
            deleted = "✗",
            ignored = "◌",
          }
        }
      }
    }
	})
    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
  end,
}
