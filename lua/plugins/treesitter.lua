return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  branch = "main",
  config = function()
    require("nvim-treesitter.config").setup({
      ensure_installed = {
        "lua", "python", "javascript", "typescript",
        "rust", "markdown", "markdown_inline", "bash"
      },
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
