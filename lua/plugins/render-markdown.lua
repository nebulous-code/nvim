return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  ft = { "markdown" },
  config = function()
    require("render-markdown").setup({
      -- Show rendered view in normal and command mode
      -- Raw markdown is shown in insert mode so you can edit comfortably
      render_modes = { "n", "c" },

      heading = {
        -- Clean heading style without icons
        sign = false,
        icons = { "# ", "## ", "### ", "#### ", "##### ", "###### " },
      },

      code = {
        -- Full width code blocks with language label
        sign = false,
        width = "block",
        right_pad = 1,
      },

      -- Enable checkbox completion integration
      completions = {
        lsp = { enabled = true },
      },
    })

    -- Toggle rendering on/off
    vim.keymap.set("n", "<leader>mr", ":RenderMarkdown toggle<CR>", { desc = "Toggle markdown render" })
  end,
}
