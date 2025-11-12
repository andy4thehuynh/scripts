#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Generate Youtube Transcript
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 🎥

# Documentation:
# @raycast.description Generates a transcript from the YT URL in your clipboard and copies it to your clipboard
# @raycast.author Andy Huynh
# @raycast.authorURL https://github.com/andy4thehuynh

PATH=$(echo $PATH)

youtube_url=$(pbpaste)

is_valid_youtube_url() {
  local url="$1"
  if [[ "$url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
    return 0
  else
    return 1
  fi
}

if command -v fabric-ai >/dev/null 2>&1 && is_valid_youtube_url "$youtube_url"; then
  echo "🦄 Fetching: $youtube_url"
  fabric-ai -y "$youtube_url" --yt-dlp-args="--format best" | pbcopy
  echo "✅ Transcript copied to clipboard!"
elif ! command -v fabric-ai >/dev/null 2>&1; then
  echo "❌ Error: fabric-ai command not found in PATH: $PATH"
  exit 1
else
  echo "❌ Error: Clipboard does not contain a valid YouTube URL: $youtube_url"
  exit 1
fi
