return {
  "milanglacier/minuet-ai.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = "Minuet",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    provider = "codestral",
    request_timeout = 3,
    throttle = 1000,
    debounce = 300,
    n_completions = 1,
    context_window = 16000,
    notify = "warn",
    virtualtext = {
      auto_trigger_ft = { "*" },
      auto_trigger_ignore_ft = { "TelescopePrompt", "snacks_input" },
      keymap = {
        accept = "<C-l>",
        accept_line = "<C-k>",
        next = "<C-]>",
        prev = "<C-\\>",
        dismiss = "<C-e>",
      },
    },
    provider_options = {
      codestral = {
        model = "codestral-latest",
        end_point = "https://codestral.mistral.ai/v1/fim/completions",
        api_key = "CODESTRAL_API_KEY",
        stream = true,
        optional = {
          max_tokens = 128,
          stop = { "\n\n" },
        },
      },
    },
  },
}
