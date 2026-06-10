---@type LazySpec
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = {
    ensure_installed = {
      "lua-language-server",
      "gopls",
      "bash-language-server",
      "json-lsp",
      "quick-lint-js",
      "vim-language-server",
      "stylua",
      "tree-sitter-cli",
    },
  },
}
