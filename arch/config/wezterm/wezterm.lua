local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'Catppuccin Mocha (Gogh)'
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"
config.font_size = 10

config.window_padding = {
  left = 2,
  right = 0,
  top = 2,
  bottom = 0,
}


return config
