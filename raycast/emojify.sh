#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Emojify
# @raycast.mode fullOutput
#
# Optional parameters:
# @raycast.icon 🎨
# @raycast.packageName AI Tools
#
# Documentation:
# @raycast.description Takes clipboard text and returns 10 relevant emojis.

# Ensure required Python packages are installed
python3 -c "import pyperclip" 2>/dev/null
python3 -c "import openai" 2>/dev/null
python3 -c "import python-dotenv" 2>/dev/null
if [ $? -ne 0 ]; then
  python3 -m pip install --user pyperclip openai python-dotenv >/dev/null 2>&1
fi

# Run the Python script
python3 - <<EOF
from openai import OpenAI
import pyperclip
import os
import sys
from dotenv import load_dotenv

# Load environment variables from .env file
script_dir = os.getcwd()
env_path = os.path.join(script_dir, ".env")
load_dotenv(dotenv_path=env_path)

API_KEY = os.getenv("OPENAI_API_KEY")
if not API_KEY:
    print("🚫 Error: OPENAI_API_KEY is not set.")
    sys.exit(1)

os.environ["OPENAI_API_KEY"] = API_KEY
client = OpenAI()

text = pyperclip.paste()

if not text.strip():
    print("📋 Clipboard is empty.")
    sys.exit(0)

prompt = f"Suggest 10 emojis that represent the meaning of this text, with the most relevant first:\n\n\"\"\"\n{text.strip()}\n\"\"\"\n\nRespond with just the emojis, separated by a space."

try:
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are an assistant that outputs only emojis."},
            {"role": "user", "content": prompt}
        ],
        max_tokens=50,
        temperature=0.7
    )
    result = response.choices[0].message.content.strip()
    print(result)

except Exception as e:
    print(f"❌ Error: {e}")
    sys.exit(1)

EOF
