return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "▎" },
        topdelete    = { text = "▎" },
        changedelete = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- Navigation
        vim.keymap.set("n", "]h", gs.next_hunk, { buffer = bufnr, desc = "Next hunk" })
        vim.keymap.set("n", "[h", gs.prev_hunk, { buffer = bufnr, desc = "Prev hunk" })

        -- Staging
        vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
        vim.keymap.set("n", "<leader>gu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo stage hunk" })
        vim.keymap.set("n", "<leader>gS", gs.stage_buffer, { buffer = bufnr, desc = "Stage buffer" })
        vim.keymap.set("n", "<leader>gR", gs.reset_buffer, { buffer = bufnr, desc = "Reset buffer" })

        -- Preview
        vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })

        -- Blame
        vim.keymap.set("n", "<leader>gb", gs.blame_line, { buffer = bufnr, desc = "Blame line" })
      end,
    })
  end,
}
