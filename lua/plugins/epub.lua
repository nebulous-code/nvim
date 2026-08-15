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
      "<leader>kl",
      function()
        require("reading.recents").pick_recent()
      end,
      desc = "List recent books",
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
