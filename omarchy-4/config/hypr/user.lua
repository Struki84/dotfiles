-- Personal Hyprland overrides for Omarchy 4 (Lua config).
--
-- Loaded after Omarchy's defaults via `require("hypr.user")` in
-- ~/.config/hypr/hyprland.lua, so everything here wins over the defaults.
--
-- Validate after changes:  hyprctl reload && hyprctl configerrors
-- See current bindings:    omarchy menu keybindings --print

local home = os.getenv("HOME")

-- ENVIRONMENT ----------------------------------------------------------------

hl.env("OMARCHY_SCREENSHOT_DIR", home .. "/Pictures/Screenshots")
hl.env("OMARCHY_SCREENRECORD_DIR", home .. "/Videos/ScreenRecordings")

-- AUTOSTART ------------------------------------------------------------------

o.launch_on_start("radiotray-ng")
o.launch_on_start("torrent-sentry")
o.launch_on_start("1password")

-- NAVIGATION & SHORTCUTS -----------------------------------------------------
-- Alt is the primary modifier for my own bindings; SUPER stays with Omarchy.

-- Launcher (Walker was replaced by omarchy-shell in v4; this is the Apps menu).
o.bind("ALT + SPACE", "Launcher", "omarchy-menu toggle apps")

-- Workspace navigation on the home row.
for index, key in ipairs({ "A", "S", "D", "F" }) do
  local workspace = tostring(index)
  o.bind("ALT + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = workspace }))
  o.bind(
    "ALT + SHIFT + " .. key,
    "Move window silently to workspace " .. workspace,
    hl.dsp.window.move({ workspace = workspace, follow = false })
  )
end

-- Launch-or-focus my main apps.
o.bind("ALT + 1", "Brave", { focus = "Brave-browser", launch = "brave" })
o.bind("ALT + 2", "Terminal", { focus = "Alacritty", launch = "alacritty" })
o.bind("ALT + 3", "Ferdium", { focus = "Ferdium", launch = "ferdium" })
o.bind("ALT + 4", "Notion", { focus = "Notion", launch = "notion-app" })

-- Close window.
o.bind("ALT + Q", "Close window", hl.dsp.window.close())

-- Terminal opens straight into tmux ("Dev" session).
hl.unbind("SUPER + RETURN")       -- was: Terminal
hl.unbind("SUPER + ALT + RETURN") -- was: Tmux ("Work" session)
o.bind("SUPER + RETURN", "Tmux", "omarchy-launch-terminal bash -c 'tmux attach || tmux new -s Dev'")

-- Toggle radiotray-ng stream (works while locked).
o.bind(
  "SHIFT + XF86AudioPause",
  "Radio stop",
  "dbus-send --session --type=method_call --dest=com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.stop",
  { locked = true }
)
o.bind(
  "SHIFT + XF86AudioPlay",
  "Radio play",
  "dbus-send --session --type=method_call --dest=com.github.radiotray_ng /com/github/radiotray_ng com.github.radiotray_ng.play",
  { locked = true }
)

-- Already Omarchy 4 defaults, so not repeated here:
--   SUPER + SPACE            -> omarchy-menu
--   ALT + TAB / ALT + SHIFT + TAB -> cycle windows
--   SUPER + mouse:272/273    -> move / resize window

-- Apple keyboard variant (SUPER instead of ALT). Uncomment to use.
-- hl.unbind("SUPER + S") -- was: Toggle scratchpad
-- hl.unbind("SUPER + F") -- was: Full screen
-- hl.unbind("SUPER + ALT + S") -- was: Move window to scratchpad
-- for index, key in ipairs({ "A", "S", "D", "F" }) do
--   local workspace = tostring(index)
--   o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, hl.dsp.focus({ workspace = workspace }))
--   o.bind("SUPER + SHIFT + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = false }))
-- end
-- for index = 1, 4 do
--   hl.unbind("SUPER + code:" .. tostring(index + 9)) -- was: Switch to workspace N
-- end
-- o.bind("SUPER + 1", "Brave", { focus = "Brave-browser", launch = "brave" })
-- o.bind("SUPER + 2", "Terminal", { focus = "Alacritty", launch = "alacritty" })
-- o.bind("SUPER + 3", "Ferdium", { focus = "Ferdium", launch = "ferdium" })
-- o.bind("SUPER + 4", "Notion", { focus = "Notion", launch = "notion-app" })

-- LOOK AND FEEL --------------------------------------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 8,
    border_size = 1,
    resize_on_border = true,
  },

  decoration = {
    rounding = 4,
    -- active_opacity = 1.0,
    -- inactive_opacity = 0.7,
    fullscreen_opacity = 1,

    blur = {
      enabled = true,
      size = 2,
      passes = 3,
      special = true,
      brightness = 0.70,
      contrast = 0.85,
      -- new_optimizations = true,
      -- ignore_opacity = true,
      -- xray = false,
      -- popups = true,
      -- vibrancy = 0.1696,
    },
  },
})

-- Blur the omarchy-shell layers (v4 replaced waybar/walker/mako with these).
-- May need visual tuning: Quickshell surfaces render differently than waybar did.
-- Layers: bar, root menu, notifications, OSD, and the bar panels (audio,
-- bluetooth, network, clock, power...) which live on "omarchy-keyboard-panel"
-- as a fullscreen transparent overlay with the card drawn inside; ignore_alpha
-- keeps the transparent area unblurred.
hl.layer_rule({
  match = { namespace = "^(omarchy-bar|omarchy-menu|omarchy-notifications|omarchy-osd|omarchy-keyboard-panel|omarchy-emojis|omarchy-clipboard|omarchy-polkit|omarchy-image-selector|omarchy-reminders|omarchy-network-qr)$" },
  blur = true,
  blur_popups = true, -- bar tooltips are xdg popups of the bar layer, not their own layer
  ignore_alpha = 0.1,
})

-- WINDOW RULES ---------------------------------------------------------------
-- https://wiki.hypr.land/Configuring/Basics/Window-Rules/

o.window("org.omarchy.nettui", { tag = "+floating-window" })

o.window("net.lutris.Lutris", {
  float = true,
  center = true,
  size = { 1000, 700 },
})

-- Battle.net via Lutris/Proton. Omarchy ships its own rules for the Steam
-- variant (class steam_app_battlenet); this title match covers Lutris too.
o.window({ title = "Battle.net" }, {
  float = true,
  center = true,
  size = { 1000, 700 },
})
-- o.window({ title = "Diablo IV" }, { fullscreen = true })

-- MONITORS -------------------------------------------------------------------
-- hyprctl monitors all

hl.monitor({ output = "DP-1", mode = "3440x1440@180", position = "0x0", scale = 1 })
