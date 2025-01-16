local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'Catppuccin Mocha (Gogh)'
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.95

config.window_padding = {
  left = 5,
  right = 5,
  top = 5,
  bottom = 0,
}

-- Set font size based on OS
if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
  config.font_size = 12
  config.window_decorations = "RESIZE" -- Removes title bar on macOS

  local border_color = 'rgb(49, 50, 68)'

  -- Add these lines to your config
  config.window_frame = {
    border_left_width = '2px',
    border_right_width = '2px',
    border_bottom_height = '2px',
    border_top_height = '2px',
    border_left_color = border_color, -- Dark border color that matches Catppuccin Mocha
    border_right_color = border_color,
    border_bottom_color = border_color,
    border_top_color = border_color,
  }
else
  config.font_size = 10 -- Or whatever size you prefer for other systems
end

local mux = wezterm.mux

local cache_dir = os.getenv('HOME') .. '/.cache/wezterm/'
local window_size_cache_path = cache_dir .. 'window_size_cache.txt'

wezterm.on('gui-startup', function()
  os.execute('mkdir ' .. cache_dir)

  local window_size_cache_file = io.open(window_size_cache_path, 'r')
  if window_size_cache_file ~= nil then
    _, _, width, height = string.find(window_size_cache_file:read(), '(%d+),(%d+)')
    mux.spawn_window { width = tonumber(width), height = tonumber(height) }
    window_size_cache_file:close()
  else
    local tab, pane, window = mux.spawn_window {}
    window:gui_window():maximize()
  end
end)

wezterm.on('window-resized', function(window, pane)
  local window_size_cache_file = io.open(window_size_cache_path, 'r')
  if window_size_cache_file == nil then
    local tab_size = pane:tab():get_size()
    cols = tab_size['cols']
    rows = tab_size['rows'] + 2 -- Without adding the 2 here, the window doesn't maximize
    contents = string.format('%d,%d', cols, rows)
    window_size_cache_file = assert(io.open(window_size_cache_path, 'w'))
    window_size_cache_file:write(contents)
    window_size_cache_file:close()
  end
end)

return config
