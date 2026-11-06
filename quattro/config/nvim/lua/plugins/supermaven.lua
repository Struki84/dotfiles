return {
  "supermaven-inc/supermaven-nvim",
  event = "InsertEnter",
  opts = {
    keymaps = {
      accept_suggestion = "<C-l>",
      clear_suggestion = "<C-h>",
      accept_word = "<C-k>",
    },
    ignore_filetypes = { "TelescopePrompt", "snacks_input" },
    log_level = "warn",
  },
}
