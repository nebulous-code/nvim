return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Define highlight groups for custom icons
    vim.api.nvim_set_hl(0, "BufferIconClaude",   { fg = "#DA8548" })
    vim.api.nvim_set_hl(0, "BufferIconApi",      { fg = "#6d8086" })
    vim.api.nvim_set_hl(0, "BufferIconFrontend", { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "BufferIconTerminal", { fg = "#6d8086" })

    require("bufferline").setup({
      options = {
        get_element_icon = function(buf)
          if not buf then
            return "", "#6d8086"
          end
          -- for terminals, extract the buffer name from the path
          local name = (buf.name or buf.path or ""):lower()
          if name:match("claude.term") then
            return "", "BufferIconClaude"
          elseif name:match("api.term") then
            return "󰒍", "BufferIconApi"
          elseif name:match("frontend.term") then
            return "󰖟", "BufferIconFrontend"
          elseif name:match(".term") then
            return "", "BufferIconTerminal"
          end
          local icon, color = require("nvim-web-devicons").get_icon(buf.name, buf.extension)
          return icon, color
        end,
      },
    })

    vim.keymap.set("n", "<leader>bl", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
    vim.keymap.set("n", "<leader>bh", ":BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
  end,
}
