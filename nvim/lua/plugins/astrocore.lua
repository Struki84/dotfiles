---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["<M-J>"] = { "<C-d>zz", desc = "Move half page down and center" },
        ["<M-K>"] = { "<C-u>zz", desc = "Move half page up and center" },
        ["<M-H>"] = { "^", desc = "Go to beginning of line" },
        ["<M-L>"] = { "$", desc = "Go to end of line" },
      },
      v = {
        ["<M-J>"] = { "<C-d>zz", desc = "Move half page down and center" },
        ["<M-K>"] = { "<C-u>zz", desc = "Move half page up and center" },
        ["<M-H>"] = { "^", desc = "Go to beginning of line" },
        ["<M-L>"] = { "$", desc = "Go to end of line" },
      },
    },
  },
}
