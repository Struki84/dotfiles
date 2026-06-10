---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  version = false,
  opts = {
    ensure_installed = {
      -- editor / treesitter hygiene
      "lua",
      "vim",
      "vimdoc",
      "query",
      -- languages
      "go",
      "javascript",
      "python",
      "bash",
      -- config / data
      "json",
      "yaml",
      "toml",
      "dockerfile",
      "hyprlang",
      -- docs / git
      "markdown",
      "markdown_inline",
      "gitcommit",
      "gitignore",
    },
  },
}
