#!/bin/bash

# -----------------------------------
# - qwq, light owo client for macos -
# -----------------------------------
# (c) slice 2018

if [[ ! -f "$HOME/.config/qwq-token" ]]; then
  echo "Error: ~/.config/qwq-token not found."
fi

# --- configurables
# directory in which to store screenshots
SCREENSHOT_DIRECTORY="$HOME/Pictures/screenshots"

# your owo token, read from ~/.config/qwq-token
TOKEN=$(tr -d "\n" < ~/.config/qwq-token)

# path to jq
JQ_PATH=/usr/local/bin/jq

# file path when screenshotting
DATE_FORMAT="%m-%d-%Y-%I:%M:%S-%p"
SAVE_PATH="$SCREENSHOT_DIRECTORY/$(date +$DATE_FORMAT).png"

# vanity url to output
VANITY="owo.sh"

USER_AGENT="qwq.sh (https://github.com/slice/qwq)"
# ---

if [[ $# != 0 ]]; then
  file=$1
  echo "Uploading..."
  OWO_OUTPUT=$(curl -s -F "files[]=@\"$file\"" https://api.awau.moe/upload/pomf?key="$TOKEN" \
                -H "User-Agent: $USER_AGENT")
  echo "Uploaded! $OWO_OUTPUT"
  FILE=$(echo "$OWO_OUTPUT" | $JQ_PATH -r ".files[0].url")
  URL="https://$VANITY/$FILE"
  echo -n "$URL" | pbcopy
  echo "Copied to clipboard: $URL"
  exit 0
fi

mkdir -p "$SCREENSHOT_DIRECTORY"

# screencap
screencapture -di "$SAVE_PATH"

# detect cancellation
if [[ "$?" == "1" ]]; then
  echo "Screencapture cancelled."
  exit 1
fi

echo "Saved to: $SAVE_PATH"

if [[ "$(uname)" == *"Darwin"* ]] && [[ -x /usr/local/bin/convert ]]; then
  # assume a 2xDPI display, and resize down to 65%
  /usr/local/bin/convert "$SAVE_PATH" -resize 65% "$SAVE_PATH"
fi

# upload
echo "Uploading..."
OWO_OUTPUT=$(curl -s -F "files[]=@\"$SAVE_PATH\";type=image/png" https://api.awau.moe/upload/pomf?key="$TOKEN" \
              -H "User-Agent: $USER_AGENT")
echo "Uploaded! $OWO_OUTPUT"

# upload to owo
FILE=$(echo "$OWO_OUTPUT" | $JQ_PATH -r ".files[0].url")
URL="https://$VANITY/$FILE"

# copy
echo -n "$URL" | pbcopy
echo "Copied to clipboard: $URL"

# notify
/usr/bin/osascript -e "display notification \"$URL\" with title \"Uploaded!\""
