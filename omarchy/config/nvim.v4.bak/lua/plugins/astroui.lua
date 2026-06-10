local map = {
  ["catppuccin"]       = "catppuccin",
  ["catppuccin-latte"] = "catppuccin-latte",
  ["tokyo-night"]      = "tokyonight-night",
  ["gruvbox"]          = "gruvbox",
  ["kanagawa"]         = "kanagawa",
  ["nord"]             = "nord",
  ["rose-pine"]        = "rose-pine-dawn",
  ["everforest"]       = "everforest",
  ["flexoki-light"]    = "flexoki-light",
  ["matte-black"]      = "matteblack",
  ["osaka-jade"]       = "bamboo",
  ["ristretto"]        = "monokai-pro",
  ["miasma"]           = "miasma",
  ["retro-82"]         = "retro-82",
  ["lumon"]            = "lumon",
  ["ethereal"]         = "ethereal",
  ["hackerman"]        = "hackerman",
  ["last-horizon"]     = "aether",
  ["vantablack"]       = "vantablack",
  ["white"]            = "white",
}

local function omarchy_colorscheme()
  local ok, lines = pcall(vim.fn.readfile, vim.fn.expand("~/.config/omarchy/current/theme.name"))
  local name = ok and lines[1] and vim.trim(lines[1]) or ""
  return map[name] or "catppuccin"
end

-- Per-scheme highlight overrides. Add more schemes as needed.
local highlights = {
  catppuccin = function()
    local c = require("catppuccin.palettes").get_palette()
    return {
      FloatBorder        = { fg = c.blue },
      NeoTreeFloatBorder = { fg = c.blue },
      NeoTreeFloatTitle  = { fg = c.base, bg = c.blue, bold = true },
      NeoTreeTitleBar    = { fg = c.base, bg = c.blue, bold = true },
      WinSeparator       = { fg = c.blue },
    }
  end,
}

local function apply_highlights()
  local scheme = vim.g.colors_name or ""
  -- match "catppuccin", "catppuccin-mocha", etc. against the highlights keys
  for key, fn in pairs(highlights) do
    if scheme == key or scheme:match("^" .. key) then
      local ok, groups = pcall(fn)
      if ok then
        for group, val in pairs(groups) do
          vim.api.nvim_set_hl(0, group, val)
        end
      end
    end
  end
end

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = omarchy_colorscheme(),
      highlights = highlights,
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

      -- Re-apply our overrides whenever a colorscheme loads (covers startup,
      -- Omarchy live theme switches, and OmarchyReloadTheme below).
      vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_highlights })
      apply_highlights()

      vim.api.nvim_create_user_command("OmarchyReloadTheme", function()
        pcall(vim.cmd.colorscheme, omarchy_colorscheme())
      end, {})
    end,
  },
  {
    "rcarriga/nvim-notify",
    opts = {
      top_down = false,
    },
  },
}
