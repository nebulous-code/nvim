return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
      },
      sections = {
        lualine_x = {
          {
            function()
              if vim.fn.mode():find("[vV]") then
                return vim.fn.wordcount().visual_words .. " words"
              end
              return vim.fn.wordcount().words .. " words"
            end,
            cond = function()
              return vim.bo.filetype == "markdown"
            end,
          },
          "encoding",
          "fileformat",
          "filetype",
        },
      },
    })
  end,
}
