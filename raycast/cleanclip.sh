#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Clean Clip
# @raycast.mode silent
#
# Optional parameters:
# @raycast.icon ✂️
# @raycast.packageName Clipboard Utilities
#
# Documentation:
# @raycast.description Remove all new lines from clipboard contents and copy the cleaned text back to clipboard.

# Ensure pyperclip is installed for the current Python environment
python3 -c "import pyperclip" 2>/dev/null
if [ $? -ne 0 ]; then
  python3 -m pip install --user pyperclip
fi

# Run the Python code
python3 <<'EOF'
import pyperclip
import re

def clean_newlines(text: str) -> str:
    """
    Sanitizes extra whitespace & newlines from clipboard text.
    Used in conjunction with an OCR screenshot tool like TRex library.
    https://github.com/amebalabs/TRex
    """
    cleaned = re.sub(r'\s*\n\s*', ' ', text)
    cleaned = re.sub(r'\s+', ' ', cleaned)
    return cleaned.strip()

def main():
    txt = pyperclip.paste()
    if not txt:
        print("Clipboard is empty or does not contain text.")
        return

    clean_txt = clean_newlines(txt)
    pyperclip.copy(clean_txt)
    print("Cleaned text copied to clipboard.")

if __name__ == "__main__":
    main()
EOF
