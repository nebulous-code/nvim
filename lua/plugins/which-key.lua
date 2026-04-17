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
      { "<leader>p", group = "plugins" },
      { "<leader>b", group = "buffer" },
      { "<leader>t", group = "tabs" },
		})
  end,
}
