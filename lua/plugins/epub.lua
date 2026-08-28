return {
  "CrystalDime/epub.nvim",
  cmd = "EpubOpen",
  keys = {
    {
      "<leader>kr",
      function()
        require("reading.recents").resume()
      end,
      desc = "Resume recent book",
    },
    {
      "<leader>ko",
      function()
        require("reading.recents").pick_library()
      end,
      desc = "Open book from library",
    },
    {
      "<leader>kt",
      function()
        require("reading.recents").toc()
      end,
      desc = "Table of contents",
    },
    {
      "<leader>kb",
      function()
        require("reading.recents").pick_recent()
      end,
      desc = "Browse recent books",
    },
    {
      "<leader>kl",
      function()
        require("reading.recents").next_chapter()
      end,
      desc = "Next chapter",
    },
    {
      "<leader>kh",
      function()
        require("reading.recents").prev_chapter()
      end,
      desc = "Previous chapter",
    },
  },
  config = function()
    require("epub").setup({})
    require("reading.recents").setup({
      library = "/malory/books/Calibre Library",
      limit = 5,
    })
  end,
}
