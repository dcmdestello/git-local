#!/bin/bash
set -euo pipefail

TARGET_DIR="$HOME/bin"
SCRIPT_NAME="git-local"
SOURCE_FILE="./$SCRIPT_NAME"

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Copy the script
cp "$SOURCE_FILE" "$TARGET_DIR/$SCRIPT_NAME"
chmod +x "$TARGET_DIR/$SCRIPT_NAME"

echo "Deployed $SCRIPT_NAME to $TARGET_DIR"

# Check if target is in PATH
if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
    echo ""
    echo "WARNING: $TARGET_DIR is not in your PATH."
    echo "Add this to your ~/.zshrc or ~/.bashrc:"
    echo "  export PATH=\"\$HOME/bin:\$PATH\""
else
    echo "Success! You can now use 'git local' anywhere."
fi
