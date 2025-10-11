# NAVFoundation.Tui

A comprehensive Text User Interface (TUI) library for NetLinx that provides ANSI escape code support for creating terminal-based user interfaces.

## Overview

The NAVFoundation.Tui library enables developers to create rich terminal user interfaces using ANSI escape sequences. It supports text coloring, cursor movement, screen clearing, text formatting, and basic UI elements like boxes and lines.

## Features

- **Text Coloring**: Support for 16 basic colors and true color (RGB) support
- **Cursor Control**: Move cursor, hide/show cursor, save/restore position
- **Screen Management**: Clear screen, clear lines, scroll operations
- **Text Formatting**: Bold, underline, italic, reverse video
- **UI Elements**: Box drawing characters, horizontal lines, centered text
- **Terminal Modes**: Control cursor blinking, auto-wrap, mouse tracking
- **Window Management**: Terminal window control (title, size, position)

## Installation

Include the TUI library in your NetLinx project:

```netlinx
#include 'NAVFoundation.Tui.axi'
```

## Constants

### Basic Colors (SGR Codes)

- `NAV_ANSI_SGR_RESET` - Reset all formatting
- `NAV_ANSI_SGR_BOLD` - Bold text
- `NAV_ANSI_SGR_UNDERLINE` - Underlined text
- `NAV_ANSI_SGR_REVERSE_VIDEO` - Reverse video (swap fg/bg colors)
- Foreground colors: `NAV_ANSI_SGR_FOREGROUND_RED`, `NAV_ANSI_SGR_FOREGROUND_GREEN`, etc.
- Background colors: `NAV_ANSI_SGR_BACKGROUND_RED`, `NAV_ANSI_SGR_BACKGROUND_GREEN`, etc.
- Bright variants available for all colors

### Cursor Movement

- `NAV_ANSI_CURSOR_UP` - Move cursor up
- `NAV_ANSI_CURSOR_DOWN` - Move cursor down
- `NAV_ANSI_CURSOR_FORWARD` - Move cursor right
- `NAV_ANSI_CURSOR_BACK` - Move cursor left
- `NAV_ANSI_CURSOR_POSITION` - Set cursor position
- `NAV_ANSI_CURSOR_HIDE` - Hide cursor
- `NAV_ANSI_CURSOR_SHOW` - Show cursor

### Screen Clearing

- `NAV_ANSI_ERASE_DISPLAY` - Clear entire screen
- `NAV_ANSI_ERASE_LINE` - Clear current line

### Terminal Modes

- `NAV_ANSI_MODE_AUTO_WRAP` - Enable auto-wrap
- `NAV_ANSI_MODE_NO_AUTO_WRAP` - Disable auto-wrap
- `NAV_ANSI_MODE_CURSOR_BLINK` - Enable cursor blinking
- `NAV_ANSI_MODE_CURSOR_NO_BLINK` - Disable cursor blinking
- `NAV_ANSI_MODE_MOUSE_TRACKING` - Enable mouse tracking

### Box Drawing Characters

- `NAV_BOX_HORIZONTAL` - ─
- `NAV_BOX_VERTICAL` - │
- `NAV_BOX_TOP_LEFT` - ┌
- `NAV_BOX_TOP_RIGHT` - ┐
- `NAV_BOX_BOTTOM_LEFT` - └
- `NAV_BOX_BOTTOM_RIGHT` - ┘
- `NAV_BOX_CROSS` - ┼
- And more intersection characters

### Common Terminal Dimensions

- `NAV_TERMINAL_WIDTH_DEFAULT` - 80 columns
- `NAV_TERMINAL_HEIGHT_DEFAULT` - 24 rows
- `NAV_TERMINAL_WIDTH_WIDE` - 132 columns
- `NAV_TERMINAL_HEIGHT_WIDE` - 43 rows

### RGB Color Values

Predefined RGB values for common colors:
- `NAV_COLOR_RED_RGB` - '255;0;0'
- `NAV_COLOR_GREEN_RGB` - '0;255;0'
- `NAV_COLOR_BLUE_RGB` - '0;0;255'
- And many more...

## Functions

### Text Coloring

```netlinx
// Basic bright colors
coloredText = NAVColorRed('Error message')
coloredText = NAVColorGreen('Success message')
coloredText = NAVColorBlue('Info message')
coloredText = NAVColorYellow('Warning message')

// RGB true color
coloredText = NAVColorRGB('Custom color text', 255, 128, 0)  // Orange
```

### Cursor Movement

```netlinx
// Move cursor
send_string 0, NAVCursorUp(5)        // Move up 5 lines
send_string 0, NAVCursorDown(3)      // Move down 3 lines
send_string 0, NAVCursorPosition(10, 20)  // Move to row 10, column 20
send_string 0, NAVCursorHome()       // Move to top-left (1,1)

// Cursor visibility
send_string 0, NAVCursorHide()
send_string 0, NAVCursorShow()
```

### Screen Clearing

```netlinx
// Clear operations
send_string 0, NAVClearScreen()           // Clear entire screen
send_string 0, NAVClearScreenFromCursor() // Clear from cursor to end
send_string 0, NAVClearLine()              // Clear current line
```

### Text Formatting

```netlinx
// Text styles
boldText = NAVTextBold('Important text')
underlineText = NAVTextUnderline('Underlined text')
reverseText = NAVTextReverse('Highlighted text')
```

### RGB Color Control

```netlinx
// Set colors directly
send_string 0, NAVSetForegroundRGB(255, 0, 0)  // Set foreground to red
send_string 0, NAVSetBackgroundRGB(0, 0, 255)  // Set background to blue
send_string 0, NAVResetFormatting()             // Reset to defaults
```

### UI Elements

```netlinx
// Draw basic elements
horizontalLine = NAVDrawHorizontalLine(20)  // ────────────────────
box = NAVDrawBox(30, 10)                  // Draw a 30x10 box
centeredText = NAVCenterText('Hello World', 40)  // Center in 40 chars
```

### Utility Functions

```netlinx
// Cursor position management
send_string 0, NAVSaveCursorPosition()     // Save current position
// ... do some operations ...
send_string 0, NAVRestoreCursorPosition()  // Return to saved position

// Reset formatting
send_string 0, NAVResetFormatting()
```

## Complete Example

```netlinx
PROGRAM_NAME='TuiExample'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Tui.axi'

DEFINE_DEVICE
dvTP = 0:1:0

DEFINE_FUNCTION CreateWelcomeScreen()
{
    // Clear screen and hide cursor
    send_string dvTP, NAVClearScreen()
    send_string dvTP, NAVCursorHide()

    // Draw a border
    send_string dvTP, NAVCursorPosition(1, 1)
    send_string dvTP, NAVDrawBox(50, 12)

    // Add title
    send_string dvTP, NAVCursorPosition(2, 2)
    send_string dvTP, NAVTextBold('Welcome to NAVFoundation TUI Demo')

    // Add colored messages
    send_string dvTP, NAVCursorPosition(4, 2)
    send_string dvTP, NAVColorGreen('✓ System initialized successfully')

    send_string dvTP, NAVCursorPosition(5, 2)
    send_string dvTP, NAVColorYellow('⚠ Some features may require terminal support')

    send_string dvTP, NAVCursorPosition(7, 2)
    send_string dvTP, NAVColorCyan('Available commands:')
    send_string dvTP, NAVCursorPosition(8, 4)
    send_string dvTP, NAVColorWhite('• help - Show available commands')
    send_string dvTP, NAVCursorPosition(9, 4)
    send_string dvTP, NAVColorWhite('• clear - Clear the screen')
    send_string dvTP, NAVCursorPosition(10, 4)
    send_string dvTP, NAVColorWhite('• exit - Exit the application')

    // Position cursor for input
    send_string dvTP, NAVCursorPosition(12, 2)
    send_string dvTP, NAVColorMagenta('> ')
    send_string dvTP, NAVCursorShow()
}

DEFINE_START
{
    CreateWelcomeScreen()
}
```

## Terminal Compatibility

This library uses standard ANSI escape sequences that are supported by most modern terminals:

- **Windows**: Windows Terminal, Windows Console (Windows 10+), ConEmu
- **macOS**: Terminal.app, iTerm2
- **Linux**: GNOME Terminal, Konsole, xterm
- **Other**: Any VT100/ANSI-compatible terminal

Some advanced features like true color (RGB) may require terminal-specific support.

## Contributing

Contributions are welcome! Please ensure all functions include JSDoc-style documentation and follow the existing code style.

## License

MIT License - see the header files for full license text.
