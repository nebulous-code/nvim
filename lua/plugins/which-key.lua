return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
	  local wk = require("which-key")
	  wk.setup()
	  wk.add({
		  { "<leader>f", group = "find" },
		  { "<leader>w", group = "windows" },
      { "<leader>d", group = "debug" },
      { "<leader>P", group = "plugins" },
      { "<leader>p", group = "put with newline" },
      { "<leader>b", group = "buffer" },
      { "<leader>t", group = "tabs" },
      { "<leader>g", group = "git" },
		})
  end,
}
