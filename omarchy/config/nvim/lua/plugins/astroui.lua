---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = "catppuccin",
      icons = {
        LSPLoading1 = "⠋",
        LSPLoading2 = "⠙",
        LSPLoading3 = "⠹",
        LSPLoading4 = "⠸",
        LSPLoading5 = "⠼",
        LSPLoading6 = "⠴",
        LSPLoading7 = "⠦",
        LSPLoading8 = "⠧",
        LSPLoading9 = "⠇",
        LSPLoading10 = "⠏",
      },
    },
    config = function(_, opts)
      require("astroui").setup(opts)
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = function()
          local groups = {
            "Normal", "NormalFloat", "SignColumn", "NeoTreeNormal", "NeoTreeNormalNC",
            "LineNr", "CursorLineNr", "TelescopeNormal", "TelescopeBorder",
          }
          for _, group in ipairs(groups) do
            vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
          end
        end,
      })
      -- Apply immediately too
      vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
      vim.cmd("hi NormalNC guibg=NONE ctermbg=NONE")
      vim.cmd("hi NormalFloat guibg=NONE ctermbg=NONE")
      vim.cmd("hi SignColumn guibg=NONE ctermbg=NONE")
      vim.cmd("hi NeoTreeNormal guibg=NONE ctermbg=NONE")
      vim.cmd("hi NeoTreeNormalNC guibg=NONE ctermbg=NONE")

      -- Add border only for LSP hover popups
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = "rounded" })  -- Change to "rounded", "double", etc., if preferred
          end, { buffer = args.buf })
        end,
      })
    end
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {},
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      top_down = false,
    },
  },
}
