return {
  colorscheme = "catppuccin",
  icons = require("user.icons"),
  heirline = require("user.heirline"),
  plugins = require("user.plugins"),

  polish = function()
    require("user.transparent_bg").setup()

    -- Apply transparency immediately
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
        vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")
        vim.cmd("hi NormalFloat guibg=NONE ctermbg=NONE")
        vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE")
        vim.cmd("hi NeoTreeNormal guibg=NONE ctermbg=NONE")
        vim.cmd("hi NeoTreeNormalNC guibg=NONE ctermbg=NONE")
      end,
    })
  end,
}
