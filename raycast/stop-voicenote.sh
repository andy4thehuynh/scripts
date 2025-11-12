#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Stop Voicenote
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon 🛑
#
# Documentation:
# @raycast.description Stops an active Voicenote recording

# NOTE: Ensure hotkeys are enabled with default shortcuts

echo "Starting Voicenotes..."

osascript <<EOF
tell application "System Events"
  if not exists (process "Voicenotes") then
    log "🚨 Voicenotes not running"
    return
  end if

  tell process "Voicenotes"
    # "s" stops the active recording
    keystroke "s" using option down
    delay 1.0

    keystroke "h" using option down
    log "Voicenotes"
  end tell
end tell
EOF
