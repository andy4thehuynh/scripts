#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Fetch YT Transcript
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 📡

# Documentation:
# @raycast.description Generates a transcript from the YT URL in your clipboard and copies it to your clipboard
# @raycast.author Andy Huynh
# @raycast.authorURL https://github.com/andy4thehuynh

PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/go/bin:$PATH"

youtube_url=$(pbpaste)

if command -v fabric-ai >/dev/null 2>&1; then
  echo "🦄 Fetching: $youtube_url"
  fabric-ai -y "$youtube_url" --yt-dlp-args="--format best" | pbcopy
  echo "✅ Transcript copied to clipboard!"
else
  echo "Error: fabric-ai command not found in PATH"
  echo "Current PATH: $PATH"
  exit 1
fi
