return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
	  local wk = require("which-key")
	  wk.setup()
	  wk.add({
      { "<leader>b", group = "buffer" },
      { "<leader>d", group = "debug" },
		  { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>m", group = "markdown" },
      { "<leader>P", group = "plugins" },
      { "<leader>p", group = "put with newline" },
		  { "<leader>w", group = "windows" },
		})
  end,
}
