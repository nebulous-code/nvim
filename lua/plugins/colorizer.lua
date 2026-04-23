return {
  "NvChad/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup({
      filetypes = { "*" },  -- enable for all file types
      user_default_options = {
        RGB      = true,   -- #RGB hex codes
        RRGGBB   = true,   -- #RRGGBB hex codes
        names    = false,  -- named colors like "blue" (can be noisy)
        css      = true,   -- css color functions rgb(), hsl()
        mode     = "background",  -- show color as background swatch
      },
    })
  end,
}
