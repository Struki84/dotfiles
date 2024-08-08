return {
  -- first key is the mode
  n = {
    -- normal mode mappings
    
    -- Half page movement with centering
    ["<M-J>"] = { "<C-d>zz", desc = "Move half page down and center" },
    ["<M-K>"] = { "<C-u>zz", desc = "Move half page up and center" },
    
    -- Beginning and end of line
    ["<M-H>"] = { "^", desc = "Go to beginning of line" },
    ["<M-L>"] = { "$", desc = "Go to end of line" },
  },
  i = {
    -- insert mode mappings
  },
  v = {
    -- visual mode mappings

    ["<M-J>"] = { "<C-d>zz", desc = "Move half page down and center" },
    ["<M-K>"] = { "<C-u>zz", desc = "Move half page up and center" },
    ["<M-H>"] = { "^", desc = "Go to beginning of line" },
    ["<M-l>"] = { "$", desc = "Go to end of line" },
  },
  t = {
    -- terminal mode mappings
  },
  -- add more modes as needed
}
