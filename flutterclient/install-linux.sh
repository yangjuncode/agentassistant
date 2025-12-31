#!/bin/bash

# Install script for Agent Assistant Flutter Linux application

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BUNDLE_DIR="$SCRIPT_DIR/build/linux/x64/release/bundle"

# Check if bundle exists
if [ ! -d "$BUNDLE_DIR" ]; then
    echo "Error: Bundle directory not found. Please run build-linux.sh first."
    exit 1
fi

# Install desktop file
DESKTOP_FILE="$BUNDLE_DIR/agentassistant-flutter.desktop"
if [ -f "$DESKTOP_FILE" ]; then
    # Update Exec path in desktop file to use absolute path
    sed "s|Exec=agentassistant-flutter|Exec=$BUNDLE_DIR/agentassistant-flutter|g" "$DESKTOP_FILE" > /tmp/agentassistant-flutter.desktop
    
    # Update Icon path to use absolute path
    sed -i "s|Icon=agentassistant-flutter|Icon=$BUNDLE_DIR/agent-assistant-icon.png|g" /tmp/agentassistant-flutter.desktop
    
    # Install to user's local applications
    mkdir -p ~/.local/share/applications
    cp /tmp/agentassistant-flutter.desktop ~/.local/share/applications/
    chmod +x ~/.local/share/applications/agentassistant-flutter.desktop
    
    echo "Desktop file installed to ~/.local/share/applications/"
    echo "The application should now appear in your application menu."
else
    echo "Warning: Desktop file not found in bundle."
fi

# Make the binary executable
chmod +x "$BUNDLE_DIR/agentassistant-flutter"

echo ""
echo "Installation complete!"
echo "You can run the application from:"
echo "  $BUNDLE_DIR/agentassistant-flutter"
echo ""
echo "Or find it in your application menu as 'Agent Assistant'"
