return {
  "arnamak/stay-centered.nvim",
  lazy = false, -- ensure loaded at startup, not deferred
  opts = {
    skip_filetypes = {},
    enabled = true,
    allow_scroll_move = true,
    disable_on_mouse = true,
  },
  -- fallback explicit (if AstroNvim/Lazy opts-handler doesn't trigger setup):
  -- config = function(_, opts) require("stay-centered").setup(opts) end,
}
