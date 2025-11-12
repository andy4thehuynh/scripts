#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Start Voicenote
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🚀
#
# Documentation:
# @raycast.description Toggles between start and stop states for Voicenotes AI macOS app.

# NOTE: Ensure hotkeys are enabled with default shortcuts

echo "Starting Voicenotes..."

osascript <<EOF
tell application "System Events"
  if not exists (process "Voicenotes") then
    log "⚠️ Voicenotes is not running"
    return
  end if

  tell process "Voicenotes"
    # "m" will start or resume recording
    keystroke "m" using option down
    delay 0.5

    keystroke "h" using option down
    log "Voicenotes"
  end tell
end tell
EOF
