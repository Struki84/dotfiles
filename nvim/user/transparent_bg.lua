local M = {}

function M.setup()
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
end

return M
