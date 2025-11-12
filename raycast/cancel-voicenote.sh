#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Cancel Voicenote
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon ❌
#
# Documentation:
# @raycast.description Cancels an active Voicenote recording

# NOTE: Ensure hotkeys are enabled with default shortcuts.
# WARN: If canceling past 10sec, must manually confirm cancellation in menu bar app

echo "Starting Voicenotes..."

osascript <<EOF
tell application "System Events"
  if not exists (process "Voicenotes") then
    log "🚨 Voicenotes not running"
    return
  end if

  tell process "Voicenotes"
    # "c" cancels the active recording
    keystroke "c" using option down
    delay 0.5

    keystroke return

    keystroke "h" using option down
    log "Voicenotes"
  end tell
end tell
EOF
