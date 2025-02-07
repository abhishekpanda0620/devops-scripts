#!/bin/bash

# Get the Repository Directory
REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Define the Release Notes Directory
RELEASES_DIR="$REPO_DIR/releases"

# Ensure releases directory exists
mkdir -p "$RELEASES_DIR"

# Get the Current Git Branch, escaping any special characters (like /)
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
SANITIZED_BRANCH=$(echo "$CURRENT_BRANCH" | sed 's|/|_|g')

# Convert Branch Name to Uppercase
UPPERCASE_BRANCH=$(echo "$SANITIZED_BRANCH" | tr '[:lower:]' '[:upper:]')

# Define the Release Note File Path
RELEASE_NOTE_FILE="$RELEASES_DIR/${UPPERCASE_BRANCH}-RELEASE-NOTES.md"

# Get the Current Date and Time
CURRENT_DATETIME=$(date "+%Y-%m-%d %H:%M:%S")

# Prompt the User for Release Note
echo "Enter the release note:"
read -e RELEASE_NOTE

# Insert content at the beginning
if [ -s "$RELEASE_NOTE_FILE" ]; then
  # If file is not empty use ed command to insert content at the beginning of the file
  ed -s "$RELEASE_NOTE_FILE" <<EOF
1i
### $CURRENT_DATETIME
$RELEASE_NOTE

.
wq
EOF
else
  # File is empty, append content to the file
  echo -e "### $CURRENT_DATETIME\n$RELEASE_NOTE" > "$RELEASE_NOTE_FILE"
fi

# Confirmation Message
echo "Release note added successfully to $RELEASE_NOTE_FILE."

