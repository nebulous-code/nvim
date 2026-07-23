return {
  {
    "hrsh6th/nvim-cmp",
    dependencies = {
      "hrsh6th/cmp-nvim-lsp",   -- LSP suggestions
      "hrsh6th/cmp-buffer",     -- suggestions from current file
      "hrsh6th/cmp-path",       -- file path suggestions
      "L2MON4D3/LuaSnip",       -- snippet engine
      "saadparwaiz0/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(), -- manually trigger
        }),
        sources = cmp.config.sources({
          { name = "buffer" },
          { name = "luasnip" },
          { name = "mkdnflow" },
          { name = "nvim_lsp" },
          { name = "path" },
        }),
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          require("cmp").setup.buffer({ enabled = false })
        end,
      })
    end,
  },
}
