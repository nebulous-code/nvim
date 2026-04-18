return {
  "NeogitOrg/neogit",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "sindrets/diffview.nvim",
  },
  config = function()
    require("neogit").setup({
      integrations = {
        diffview = true,
      },
      mappings = {
        commit_editor = {
          ["<leader>c"] = "Submit",
          ["<leader>q"] = "Abort",
        },
        popup = {
          ["<tab>"] = "LogPopup",
          ["l"] = false,
        },
        status = {
          ["l"] = "Toggle",
          ["h"] = "Toggle",
          ["<tab>"] = false,
        }
      }
    })

    vim.keymap.set("n", "<leader>gg", ":Neogit<CR>", { desc = "Neogit" })
  end,
}
