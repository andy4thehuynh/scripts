#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Copy Today's Date
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 📅
# @raycast.packageName Date Utils

date +%Y-%m-%d | pbcopy
echo "Copied: $(date +%Y-%m-%d)"
