local map = {
  ["catppuccin"] = "catppuccin",
  ["catppuccin-latte"] = "catppuccin-latte",
  ["tokyo-night"] = "tokyonight-night",
  ["gruvbox"] = "gruvbox",
  ["kanagawa"] = "kanagawa",
  ["nord"] = "nord",
  ["rose-pine"] = "rose-pine-dawn",
  ["everforest"] = "everforest",
  ["flexoki-light"] = "flexoki-light",
  ["matte-black"] = "matteblack",
  ["osaka-jade"] = "bamboo",
  ["ristretto"] = "monokai-pro",
  ["miasma"] = "miasma",
  ["retro-82"] = "retro-82",
  ["lumon"] = "lumon",
  ["ethereal"] = "ethereal",
  ["hackerman"] = "hackerman",
  ["last-horizon"] = "aether",
  ["vantablack"] = "vantablack",
  ["white"] = "white",
}

local function omarchy_colorscheme()
  local ok, lines = pcall(vim.fn.readfile, vim.fn.expand "~/.config/omarchy/current/theme.name")
  local name = ok and lines[1] and vim.trim(lines[1]) or ""
  return map[name] or "catppuccin"
end

---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      colorscheme = omarchy_colorscheme(),
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
    -- config = function(_, opts)
    --   require("astroui").setup(opts)
    --
    --   local function make_transparent()
    --     local groups = {
    --       "Normal",
    --       "NormalNC",
    --       "NormalFloat",
    --       "SignColumn",
    --       "NeoTreeNormal",
    --       "NeoTreeNormalNC",
    --       "LineNr",
    --       "CursorLineNr",
    --       "TelescopeNormal",
    --       "TelescopeBorder",
    --     }
    --     for _, group in ipairs(groups) do
    --       vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
    --     end
    --   end
    --   vim.api.nvim_create_autocmd("ColorScheme", { pattern = "*", callback = make_transparent })
    --   make_transparent()
    --
    --   vim.api.nvim_create_user_command("OmarchyReloadTheme", function()
    --     pcall(vim.cmd.colorscheme, omarchy_colorscheme())
    --     vim.schedule(make_transparent)
    --   end, {})
    -- end,
  },
  {
    "rcarriga/nvim-notify",
    opts = { top_down = false },
  },
} -- ---@type LazySpec
-- return {
--   "AstroNvim/astroui",
--   ---@type AstroUIOpts
--   opts = {
--     colorscheme = "catppuccin", -- hardcoded. Change to "astrodark" for stock AstroNvim, or any theme name from themes.lua
--     icons = {
--       LSPLoading1 = "⠋",
--       LSPLoading2 = "⠙",
--       LSPLoading3 = "⠹",
--       LSPLoading4 = "⠸",
--       LSPLoading5 = "⠼",
--       LSPLoading6 = "⠴",
--       LSPLoading7 = "⠦",
--       LSPLoading8 = "⠧",
--       LSPLoading9 = "⠇",
--       LSPLoading10 = "⠏",
--     },
--   },
-- }

-- local map = {
--   ["catppuccin"] = "catppuccin",
--   ["catppuccin-latte"] = "catppuccin-latte",
--   ["tokyo-night"] = "tokyonight-night",
--   ["gruvbox"] = "gruvbox",
--   ["kanagawa"] = "kanagawa",
--   ["nord"] = "nord",
--   ["rose-pine"] = "rose-pine-dawn",
--   ["everforest"] = "everforest",
--   ["flexoki-light"] = "flexoki-light",
--   ["matte-black"] = "matteblack",
--   ["osaka-jade"] = "bamboo",
--   ["ristretto"] = "monokai-pro",
--   ["miasma"] = "miasma",
--   ["retro-82"] = "retro-82",
--   ["lumon"] = "lumon",
--   ["ethereal"] = "ethereal",
--   ["hackerman"] = "hackerman",
--   ["last-horizon"] = "aether",
--   ["vantablack"] = "vantablack",
--   ["white"] = "white",
-- }
--
-- local function omarchy_colorscheme()
--   local ok, lines = pcall(vim.fn.readfile, vim.fn.expand "~/.config/omarchy/current/theme.name")
--   local name = ok and lines[1] and vim.trim(lines[1]) or ""
--   return map[name] or "catppuccin"
-- end
--
-- ---@type LazySpec
-- return {
--   {
--     "AstroNvim/astroui",
--     ---@type AstroUIOpts
--     opts = {
--       colorscheme = omarchy_colorscheme(),
--       icons = {
--         LSPLoading1 = "⠋",
--         LSPLoading2 = "⠙",
--         LSPLoading3 = "⠹",
--         LSPLoading4 = "⠸",
--         LSPLoading5 = "⠼",
--         LSPLoading6 = "⠴",
--         LSPLoading7 = "⠦",
--         LSPLoading8 = "⠧",
--         LSPLoading9 = "⠇",
--         LSPLoading10 = "⠏",
--       },
--     },
--     config = function(_, opts)
--       require("astroui").setup(opts)
--
--       vim.api.nvim_create_user_command(
--         "OmarchyReloadTheme",
--         function() pcall(vim.cmd.colorscheme, omarchy_colorscheme()) end,
--         {}
--       )
--     end,
--   },
-- }
