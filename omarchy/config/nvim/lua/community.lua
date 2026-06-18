---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.fuzzy-finder.telescope-nvim" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.recipes.disable-tabline" },
  { import = "astrocommunity.recipes.heirline-nvchad-statusline" },
  { import = "astrocommunity.pack.python" },
  {
    "AstroNvim/astrolsp",
    opts = {
      servers = { "basedpyright" },
      handlers = {
        pyrefly = false,
        ty = false,
      },
    },
  },
}
