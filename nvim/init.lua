return {

  plugins = {

    {
      'Exafunction/codeium.vim',
      event = 'BufEnter'
    },
    "AstroNvim/astrocommunity",
    { import = "astrocommunity.colorscheme.catppuccin" },
    { import = "astrocommunity.colorscheme.iceberg-vim" },
    {
      "nvim-neo-tree/neo-tree.nvim",
      opts = {
        window = {
          position = "right",
        },
      },
    }
  },

  colorscheme = "catppuccin"
}
