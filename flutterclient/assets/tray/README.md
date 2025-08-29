Tray icons for AgentAssistant tray_manager

Place the following files in this directory (case-sensitive):

Required (Linux/macOS):
- green.png            # connected, idle
- red.png              # disconnected, idle
- green_blink.png      # connected, blinking state
- red_blink.png        # disconnected, blinking state

Required (Windows):
- green.ico            # connected, idle
- red.ico              # disconnected, idle
- green_blink.ico      # connected, blinking state
- red_blink.ico        # disconnected, blinking state

Recommendations:
- Sizes: 16x16, 20x20, 24x24, 32x32 (include multiple sizes in .ico); PNG at 24x24 or 32x32.
- Use solid colors with transparent background for clarity.

Behavior:
- Icon is green when WebSocket connected, red when disconnected.
- Icon blinks when there are pending MCP messages that need reply.
- Blinking stops automatically when all pending messages are handled.

This directory is registered in pubspec.yaml under `assets:` so Flutter will bundle these files.
