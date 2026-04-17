return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    dashboard.section.header.val = {
      "     /$$   /$$           /$$                 /$$                                       /$$$$$$                  /$$          ",
      "    | $$$ | $$          | $$                | $$                                      /$$__  $$                | $$          ",
      "    | $$$$| $$  /$$$$$$ | $$$$$$$  /$$   /$$| $$  /$$$$$$  /$$   /$$  /$$$$$$$       | $$  \\__/  /$$$$$$   /$$$$$$$  /$$$$$$ ",
      "    | $$ $$ $$ /$$__  $$| $$__  $$| $$  | $$| $$ /$$__  $$| $$  | $$ /$$_____//$$$$$$| $$       /$$__  $$ /$$__  $$ /$$__  $$",
      "    | $$  $$$$| $$$$$$$$| $$  \\ $$| $$  | $$| $$| $$  \\ $$| $$  | $$|  $$$$$$|______/| $$      | $$  \\ $$| $$  | $$| $$$$$$$$",
      "    | $$\\  $$$| $$_____/| $$  | $$| $$  | $$| $$| $$  | $$| $$  | $$ \\____  $$       | $$    $$| $$  | $$| $$  | $$| $$_____/",
      "    | $$ \\  $$|  $$$$$$$| $$$$$$$/|  $$$$$$/| $$|  $$$$$$/|  $$$$$$/ /$$$$$$$/       |  $$$$$$/|  $$$$$$/|  $$$$$$$|  $$$$$$$",
      "    |__/  \\__/ \\_______/|_______/  \\______/ |__/ \\______/  \\______/ |_______/         \\______/  \\______/  \\_______/ \\_______/",
    }

    dashboard.section.buttons.val = {
      dashboard.button("t", "  Open Terminal",    ":terminal<CR>"),
      dashboard.button("e", "  File Explorer",    ":NvimTreeToggle<CR>"),
      dashboard.button("f", "  Search Files",    ":Telescope find_files<CR>"),
      dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
      dashboard.button("g", "  Find text",    ":Telescope live_grep<CR>"),
      dashboard.button("n", "  New file",     ":enew<CR>"),
      dashboard.button("q", "  Quit",         ":qa<CR>"),
    }

    alpha.setup(dashboard.config)
  end,
}
