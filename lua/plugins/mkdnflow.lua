return {
  "jakewvincent/mkdnflow.nvim",
  ft = { "markdown" },
  config = function()
    require("mkdnflow").setup({
      -- Create directories referenced in links if they don't exist
      create_dirs = true,
      modules = {
        completion = true,
      },
      mappings = {
        MkdnEnter = false,
      },

      -- Custom keymaps via on_attach (fires after defaults are set)
      on_attach = function(bufnr)
        local opts = { buffer = bufnr }

        -- Go back to previous buffer
        vim.keymap.set("n", "<leader>mb", "<Cmd>MkdnGoBack<CR>", vim.tbl_extend("force", opts, { desc = "Go back" }))

        -- Create a markdown link from word under cursor or selection
        vim.keymap.set("n", "<leader>ml", "<Cmd>MkdnCreateLink<CR>", vim.tbl_extend("force", opts, { desc = "Create link" }))
        vim.keymap.set("v", "<leader>ml", "<Cmd>MkdnCreateLink<CR>", vim.tbl_extend("force", opts, { desc = "Create link from selection" }))

        -- Create link from clipboard URL
        vim.keymap.set("n", "<leader>mc", "<Cmd>MkdnCreateLinkFromClipboard<CR>", vim.tbl_extend("force", opts, { desc = "Create link from clipboard" }))

        -- Navigate between links in the file
        vim.keymap.set("n", "<Tab>", "<Cmd>MkdnNextLink<CR>", vim.tbl_extend("force", opts, { desc = "Next link" }))
        vim.keymap.set("n", "<S-Tab>", "<Cmd>MkdnPrevLink<CR>", vim.tbl_extend("force", opts, { desc = "Prev link" }))

        -- Toggle checkboxes
        vim.keymap.set("n", "<leader>mt", "<Cmd>MkdnToggleToDo<CR>", vim.tbl_extend("force", opts, { desc = "Toggle todo" }))
        vim.keymap.set("v", "<leader>mt", "<Cmd>MkdnToggleToDo<CR>", vim.tbl_extend("force", opts, { desc = "Toggle todo" }))

        -- Navigate headings
        vim.keymap.set("n", "]H", "<Cmd>MkdnNextHeading<CR>", vim.tbl_extend("force", opts, { desc = "Next heading" }))
        vim.keymap.set("n", "[H", "<Cmd>MkdnPrevHeading<CR>", vim.tbl_extend("force", opts, { desc = "Prev heading" }))

        -- Destroy link (remove brackets/parens, keep text)
        vim.keymap.set("n", "<leader>md", "<Cmd>MkdnDestroyLink<CR>", vim.tbl_extend("force", opts, { desc = "Destroy link" }))

        -- Follow link with leader+Enter
        vim.keymap.set("n", "<leader><CR>", function()
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2] + 1 -- 1-indexed

          -- Try to find a markdown link [text](path) that the cursor is inside
          local path = nil

          -- Search for all markdown links on the line
          for text_start, text_end, link_path in line:gmatch("()%[.-%]()%((.-)%)") do
            -- Find where the () part starts (right after the [])
            local paren_start = text_end + 1
            local paren_end = paren_start + #link_path + 1

            -- Check if cursor is anywhere inside [text] or (path)
            if col >= text_start and col <= paren_end then
              path = link_path
              break
            end
          end
          if path then
            -- Strip any anchor (#section) from the path
            path = path:match("^([^#]+)") or path
            -- Expand relative path from current file's directory
            local dir = vim.fn.expand("%:p:h")
            local full_path = dir .. "/" .. path
            vim.cmd("edit " .. vim.fn.fnameescape(full_path))
          else
            vim.notify("No markdown link found under cursor", vim.log.levels.WARN)
          end
          end, { desc = "Open markdown link in Neovim" })
        end,
    })
  end,
}
