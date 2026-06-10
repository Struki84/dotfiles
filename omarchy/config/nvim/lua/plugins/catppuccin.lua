---@type LazySpec
return {
  "catppuccin/nvim",
  name = "catppuccin",
  opts = {
    transparent_background = true,
    term_colors = true, -- fixes lazygit/terminal borders inside nvim
    integrations = {
      snacks = true,
      native_lsp = { enabled = true },
      treesitter = true,
      neotree = true,
      mason = true,
      gitsigns = true,
      which_key = true,
      markdown = true,
      cmp = true,
      lazygit = true,
      telescope = { enabled = true },
    },
  },
}
