---@type LazySpec
return {
  "folke/snacks.nvim",
  opts = {
    dashboard = {
      preset = {
        header = table.concat({
          " ███    █████ ███████ █████   ████  ",
          "█   █  █         █    █    █ █    █ ",
          "█████   ████     █    █████  █    █ ",
          "█   █       █    █    █   █  █    █ ",
          "█   █  █████     █    █    █  ████  ",
          "                         ",
          " █████ █    █ █   █   ███   █████   █████ ██████ ",
          "█       █  █  ██  █  █   █  █    █ █      █      ",
          " ████    ██   █ █ █  █████  █████   ████  ████   ",
          "     █   █    █  ██  █   █  █           █ █      ",
          "█████    █    █   █  █   █  █      █████  ██████ ",
        }, "\n"),
      },
    },
    notifier = {
      top_down = true, -- newest on top; snacks notifier sits top-right by default
    },
  },
}
