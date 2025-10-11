#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Appearance
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🚀
# @raycast.packageName Syncs Theme & Darkreader
#
# Documentation:
# @raycast.description Toggles both macOS Appearance and Darkreader's Chrome extension (must keyboard shortcut to option+d).


osascript <<EOF
-- Get current macOS appearanace mod3
tell application "System Events"
  set isDark to dark mode of appearance preferences
end tell

log "is dark?: " & isDark

-- Toggle macOS appearance
tell application "System Events"
  tell appearance preferences
    set dark mode to not isDark
  end tell
end tell

-- Give system time to apply changes
delay 1

tell application "Google Chrome"
  activate
end tell

delay 0.5

tell application "System Events"
  key down option
  keystroke "d"
  key up option
end tell
EOF
