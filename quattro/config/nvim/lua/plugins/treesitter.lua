---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      highlight = true,
      indent = true,
      auto_install = true,
      ensure_installed = {
        "lua", "vim", "vimdoc", "query",
        "go", "javascript", "python", "bash",
        "json", "yaml", "toml", "dockerfile", "hyprlang",
        "markdown", "markdown_inline",
      },
    },
  },
}
