#!/bin/bash
set -euo pipefail

TARGET_DIR="$HOME/bin"
SCRIPT_NAME="git-local"
SOURCE_FILE="./$SCRIPT_NAME"

# Remote deployment settings
REMOTE_HOST="dcastro.dev"
REMOTE_USER="dcastro"
REMOTE_DIR="/home/dcastro/.local/bin"

# Ensure target directory exists
mkdir -p "$TARGET_DIR"

# Copy the script locally
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

# Deploy to remote server
echo ""
echo "Deploying to remote server $REMOTE_HOST..."

if scp "$SOURCE_FILE" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/$SCRIPT_NAME" 2>/dev/null; then
    # Make executable on remote
    ssh "$REMOTE_USER@$REMOTE_HOST" "chmod +x $REMOTE_DIR/$SCRIPT_NAME" 2>/dev/null
    echo "Successfully deployed $SCRIPT_NAME to $REMOTE_HOST:$REMOTE_DIR"
else
    echo "WARNING: Failed to deploy to $REMOTE_HOST. Make sure you have SSH access."
fi
