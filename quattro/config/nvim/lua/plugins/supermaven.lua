return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  opts = {
    keymaps = {
      accept_suggestion = "<M-k>",
      clear_suggestion = "<M-j>",
      accept_word = "<M-w>",
    },
    ignore_filetypes = { "TelescopePrompt", "snacks_input" },
    log_level = "warn",
  },
}
