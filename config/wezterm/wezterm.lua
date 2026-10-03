-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 13
config.color_scheme = 'Everforest Dark (Gogh)'

-- Frameless: no title bar, but the window can still be resized from its edges.
config.window_decorations = 'RESIZE'

-- Toggle between normal size and filling the screen (no native fullscreen) with Cmd+Enter.
local maximized = {}
config.keys = {
  {
    key = 'Enter',
    mods = 'CMD',
    action = wezterm.action_callback(function(window, pane)
      local id = window:window_id()
      if maximized[id] then
        window:restore()
        maximized[id] = false
      else
        window:maximize()
        maximized[id] = true
      end
    end),
  },
  -- Cmd+Backspace: delete to start of line (Ctrl+U), like macOS text fields.
  {
    key = 'Backspace',
    mods = 'CMD',
    action = wezterm.action.SendString '\x15',
  },
}

-- Finally, return the configuration to wezterm:
return config
