return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("harpoon").setup()
  end,
  keys = {
    { "<leader>A", function() require("harpoon"):list():add() end,  desc = "harpoon file", },
    {
      "<leader>a",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "harpoon quick menu",
    },
    { "<C-M-k>",   function() require("harpoon"):list():prev() end, desc = "harpoon prev", },
    { "<C-M-j>",   function() require("harpoon"):list():next() end, desc = "harpoon next", },
  },
}
