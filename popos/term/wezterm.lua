local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'Catppuccin Mocha (Gogh)'
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.95
config.window_decorations = "RESIZE"

config.window_padding = {
  left = 2,
  right = 0,
  top = 2,
  bottom = 0,
}

if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
  -- mac os
  config.font_size = 12
  local border_color = 'rgb(49, 50, 68)'

  config.window_frame = {
    border_left_width = '2px',
    border_right_width = '2px',
    border_bottom_height = '2px',
    border_top_height = '2px',
    border_left_color = border_color,
    border_right_color = border_color,
    border_bottom_color = border_color,
    border_top_color = border_color,
  }
else
  -- pop os
  config.font_size = 10
end

return config
