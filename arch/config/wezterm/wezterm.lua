local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'Catppuccin Mocha (Gogh)'
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "NONE" -- No title bar, no buttons
config.enable_tab_bar = false

config.window_padding = {
  left = 0,
  right = 0,
  top = 5,
  bottom = 0,
}

config.enable_wayland = false
config.font_size = 10
config.default_prog = { '/bin/zsh', '-l' }

return config
