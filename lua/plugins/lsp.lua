return {
  -- Mason: installs language servers
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Bridges mason and the new vim.lsp.config API
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",         -- TypeScript/JavaScript
          "pyright",       -- Python
          "lua_ls",        -- Lua
          "rust_analyzer", -- Rust
        },
      })
    end,
  },

  -- nvim-lspconfig: still needed to provide server definitions
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.config("ts_ls", {})
      vim.lsp.config("pyright", {})
      vim.lsp.config("lua_ls", {})
      vim.lsp.config("rust_analyzer", {})

      vim.lsp.enable("ts_ls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("rust_analyzer")

      -- Key mappings that work when LSP is active
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover docs" })
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
    end,
  },
}
