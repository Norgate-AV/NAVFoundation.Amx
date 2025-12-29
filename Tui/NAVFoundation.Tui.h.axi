PROGRAM_NAME='NAVFoundation.Tui.h'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


#IF_NOT_DEFINED __NAV_FOUNDATION_TUI_H__
#DEFINE __NAV_FOUNDATION_TUI_H__ 'NAVFoundation.Tui.h'


DEFINE_CONSTANT

/////////////////////////////////////////////////////////////
// Ansi Escape Codes
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SGR_RESET[]                      = '[0m'  // Reset / Normal
constant char NAV_ANSI_SGR_BOLD[]                       = '[1m'  // Bold or increased intensity
constant char NAV_ANSI_SGR_FAINT[]                      = '[2m'  // Faint (decreased intensity)
constant char NAV_ANSI_SGR_ITALIC[]                     = '[3m'  // Italic
constant char NAV_ANSI_SGR_UNDERLINE[]                  = '[4m'  // Underline
constant char NAV_ANSI_SGR_SLOW_BLINK[]                 = '[5m'  // Slow blink
constant char NAV_ANSI_SGR_RAPID_BLINK[]                = '[6m'  // Rapid blink
constant char NAV_ANSI_SGR_REVERSE_VIDEO[]              = '[7m'  // Reverse video (exchange foreground and background colors)
constant char NAV_ANSI_SGR_CONCEAL[]                    = '[8m'  // Conceal (useful for passwords)
constant char NAV_ANSI_SGR_CROSSED_OUT[]                = '[9m'  // Crossed out
constant char NAV_ANSI_SGR_DEFAULT_FONT[]               = '[10m' // Default font
constant char NAV_ANSI_SGR_ALTERNATIVE_FONT_1[]         = '[11m' // Alternative font 1
constant char NAV_ANSI_SGR_ALTERNATIVE_FONT_2[]         = '[12m' // Alternative font 2
constant char NAV_ANSI_SGR_ALTERNATIVE_FONT_3[]         = '[13m' // Alternative font 3
constant char NAV_ANSI_SGR_ALTERNATIVE_FONT_4[]         = '[14m' // Alternative font 4
constant char NAV_ANSI_SGR_ALTERNATIVE_FONT_5[]         = '[15m' // Alternative font 5
constant char NAV_ANSI_SGR_ALTERNATIVE_FONT_6[]         = '[16m' // Alternative font 6
constant char NAV_ANSI_SGR_ALTERNATIVE_FONT_7[]         = '[17m' // Alternative font 7
constant char NAV_ANSI_SGR_ALTERNATIVE_FONT_8[]         = '[18m' // Alternative font 8
constant char NAV_ANSI_SGR_ALTERNATIVE_FONT_9[]         = '[19m' // Alternative font 9
constant char NAV_ANSI_SGR_FRAKTUR[]                    = '[20m' // Fraktur (rarely supported)
constant char NAV_ANSI_SGR_BOLD_OFF[]                   = '[21m' // Bold off or Double Underline
constant char NAV_ANSI_SGR_NORMAL_COLOR[]               = '[22m' // Normal color (neither bold nor faint)
constant char NAV_ANSI_SGR_ITALIC_OFF[]                 = '[23m' // Italic off
constant char NAV_ANSI_SGR_UNDERLINE_OFF[]              = '[24m' // Underline off
constant char NAV_ANSI_SGR_BLINK_OFF[]                  = '[25m' // Blink off
constant char NAV_ANSI_SGR_INVERSE_OFF[]                = '[27m' // Inverse off
constant char NAV_ANSI_SGR_CONCEAL_OFF[]                = '[28m' // Conceal off
constant char NAV_ANSI_SGR_CROSSED_OUT_OFF[]            = '[29m' // Crossed out off
constant char NAV_ANSI_SGR_FOREGROUND_BLACK[]           = '[30m' // Foreground black
constant char NAV_ANSI_SGR_FOREGROUND_RED[]             = '[31m' // Foreground red
constant char NAV_ANSI_SGR_FOREGROUND_GREEN[]           = '[32m' // Foreground green
constant char NAV_ANSI_SGR_FOREGROUND_YELLOW[]          = '[33m' // Foreground yellow
constant char NAV_ANSI_SGR_FOREGROUND_BLUE[]            = '[34m' // Foreground blue
constant char NAV_ANSI_SGR_FOREGROUND_MAGENTA[]         = '[35m' // Foreground magenta
constant char NAV_ANSI_SGR_FOREGROUND_CYAN[]            = '[36m' // Foreground cyan
constant char NAV_ANSI_SGR_FOREGROUND_WHITE[]           = '[37m' // Foreground white
constant char NAV_ANSI_SGR_FOREGROUND_DEFAULT[]         = '[39m' // Foreground default
constant char NAV_ANSI_SGR_BACKGROUND_BLACK[]           = '[40m' // Background black
constant char NAV_ANSI_SGR_BACKGROUND_RED[]             = '[41m' // Background red
constant char NAV_ANSI_SGR_BACKGROUND_GREEN[]           = '[42m' // Background green
constant char NAV_ANSI_SGR_BACKGROUND_YELLOW[]          = '[43m' // Background yellow
constant char NAV_ANSI_SGR_BACKGROUND_BLUE[]            = '[44m' // Background blue
constant char NAV_ANSI_SGR_BACKGROUND_MAGENTA[]         = '[45m' // Background magenta
constant char NAV_ANSI_SGR_BACKGROUND_CYAN[]            = '[46m' // Background cyan
constant char NAV_ANSI_SGR_BACKGROUND_WHITE[]           = '[47m' // Background white
constant char NAV_ANSI_SGR_BACKGROUND_DEFAULT[]         = '[49m' // Background default
constant char NAV_ANSI_SGR_FOREGROUND_BRIGHT_BLACK[]    = '[90m' // Foreground bright black
constant char NAV_ANSI_SGR_FOREGROUND_BRIGHT_RED[]      = '[91m' // Foreground bright red
constant char NAV_ANSI_SGR_FOREGROUND_BRIGHT_GREEN[]    = '[92m' // Foreground bright green
constant char NAV_ANSI_SGR_FOREGROUND_BRIGHT_YELLOW[]   = '[93m' // Foreground bright yellow
constant char NAV_ANSI_SGR_FOREGROUND_BRIGHT_BLUE[]     = '[94m' // Foreground bright blue
constant char NAV_ANSI_SGR_FOREGROUND_BRIGHT_MAGENTA[]  = '[95m' // Foreground bright magenta
constant char NAV_ANSI_SGR_FOREGROUND_BRIGHT_CYAN[]     = '[96m' // Foreground bright cyan
constant char NAV_ANSI_SGR_FOREGROUND_BRIGHT_WHITE[]    = '[97m' // Foreground bright white
constant char NAV_ANSI_SGR_BACKGROUND_BRIGHT_BLACK[]    = '[100m' // Background bright black
constant char NAV_ANSI_SGR_BACKGROUND_BRIGHT_RED[]      = '[101m' // Background bright red
constant char NAV_ANSI_SGR_BACKGROUND_BRIGHT_GREEN[]    = '[102m' // Background bright green
constant char NAV_ANSI_SGR_BACKGROUND_BRIGHT_YELLOW[]   = '[103m' // Background bright yellow
constant char NAV_ANSI_SGR_BACKGROUND_BRIGHT_BLUE[]     = '[104m' // Background bright blue
constant char NAV_ANSI_SGR_BACKGROUND_BRIGHT_MAGENTA[]  = '[105m' // Background bright magenta
constant char NAV_ANSI_SGR_BACKGROUND_BRIGHT_CYAN[]     = '[106m' // Background bright cyan
constant char NAV_ANSI_SGR_BACKGROUND_BRIGHT_WHITE[]    = '[107m' // Background bright white

/////////////////////////////////////////////////////////////
// Cursor Movement
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_CURSOR_UP[]                      = '[A'   // Cursor up
constant char NAV_ANSI_CURSOR_DOWN[]                    = '[B'   // Cursor down
constant char NAV_ANSI_CURSOR_FORWARD[]                 = '[C'   // Cursor forward
constant char NAV_ANSI_CURSOR_BACK[]                    = '[D'   // Cursor back
constant char NAV_ANSI_CURSOR_NEXT_LINE[]               = '[E'   // Cursor next line
constant char NAV_ANSI_CURSOR_PREVIOUS_LINE[]           = '[F'   // Cursor previous line
constant char NAV_ANSI_CURSOR_HORIZONTAL_ABSOLUTE[]     = '[G'   // Cursor horizontal absolute
constant char NAV_ANSI_CURSOR_POSITION[]                = '[H'   // Cursor position
constant char NAV_ANSI_ERASE_DISPLAY[]                  = '[J'   // Erase display
constant char NAV_ANSI_ERASE_LINE[]                     = '[K'   // Erase line
constant char NAV_ANSI_SCROLL_UP[]                      = '[S'   // Scroll up
constant char NAV_ANSI_SCROLL_DOWN[]                    = '[T'   // Scroll down
constant char NAV_ANSI_CURSOR_HIDE[]                    = '[?25l' // Hide cursor
constant char NAV_ANSI_CURSOR_SHOW[]                    = '[?25h' // Show cursor

/////////////////////////////////////////////////////////////
// Window Management
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_WINDOW_TITLE[]                   = '[2;4t' // Window title
constant char NAV_ANSI_WINDOW_ICON[]                    = '[1t'   // Window icon
constant char NAV_ANSI_WINDOW_POSITION[]                = '[3;4t' // Window position
constant char NAV_ANSI_WINDOW_SIZE[]                    = '[8;4t' // Window size
constant char NAV_ANSI_WINDOW_MAXIMIZE[]                = '[9t'   // Window maximize
constant char NAV_ANSI_WINDOW_FULL_SCREEN[]             = '[10t'  // Window full screen

/////////////////////////////////////////////////////////////
// Terminal Modes
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_MODE_SCREEN[]                    = '[?5h'  // Screen mode
constant char NAV_ANSI_MODE_INSERT[]                    = '[4h'   // Insert mode
constant char NAV_ANSI_MODE_REPLACE[]                   = '[4l'   // Replace mode
constant char NAV_ANSI_MODE_AUTO_WRAP[]                 = '[?7h'  // Auto wrap mode
constant char NAV_ANSI_MODE_NO_AUTO_WRAP[]              = '[?7l'  // No auto wrap mode
constant char NAV_ANSI_MODE_CURSOR_BLINK[]              = '[?12h' // Cursor blink mode
constant char NAV_ANSI_MODE_CURSOR_NO_BLINK[]           = '[?12l' // No cursor blink mode
constant char NAV_ANSI_MODE_CURSOR_SHOW[]               = '[?25h' // Cursor show mode
constant char NAV_ANSI_MODE_CURSOR_HIDE[]               = '[?25l' // Cursor hide mode
constant char NAV_ANSI_MODE_MOUSE_TRACKING[]            = '[?1000h' // Mouse tracking mode
constant char NAV_ANSI_MODE_MOUSE_NO_TRACKING[]         = '[?1000l' // No mouse tracking mode
constant char NAV_ANSI_MODE_MOUSE_BUTTON_TRACKING[]     = '[?1002h' // Mouse button tracking mode
constant char NAV_ANSI_MODE_MOUSE_BUTTON_NO_TRACKING[]  = '[?1002l' // No mouse button tracking mode
constant char NAV_ANSI_MODE_MOUSE_ANY_EVENT_TRACKING[]  = '[?1003h' // Mouse any event tracking mode
constant char NAV_ANSI_MODE_MOUSE_ANY_EVENT_NO_TRACKING[] = '[?1003l' // No mouse any event tracking mode
constant char NAV_ANSI_MODE_ALT_SCREEN_BUFFER[]         = '[?1049h' // Alt screen buffer mode
constant char NAV_ANSI_MODE_ALT_SCREEN_BUFFER_OFF[]     = '[?1049l' // Alt screen buffer off mode

/////////////////////////////////////////////////////////////
// Device Status
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_DEVICE_STATUS[]                  = '[5n'   // Device status
constant char NAV_ANSI_DEVICE_STATUS_REPORT[]           = '[6n'   // Device status report
constant char NAV_ANSI_DEVICE_STATUS_REPORT_POSITION[]  = '[?6n'  // Device status report position
constant char NAV_ANSI_DEVICE_STATUS_REPORT_CURSOR[]    = '[?15n' // Device status report cursor
constant char NAV_ANSI_DEVICE_STATUS_REPORT_COLOR[]     = '[?25n' // Device status report color

/////////////////////////////////////////////////////////////
// Device Attributes
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_DEVICE_ATTRIBUTES[]              = '[c'    // Device attributes
constant char NAV_ANSI_DEVICE_ATTRIBUTES_EXTENDED[]     = '[>c'   // Device attributes extended
constant char NAV_ANSI_DEVICE_ATTRIBUTES_EXTENDED2[]    = '[=c'   // Device attributes extended 2
constant char NAV_ANSI_DEVICE_ATTRIBUTES_EXTENDED3[]    = '[?c'   // Device attributes extended 3

/////////////////////////////////////////////////////////////
// Reset Commands
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SOFT_RESET[]                     = '[!p'   // Soft reset
constant char NAV_ANSI_HARD_RESET[]                     = '[!^'   // Hard reset

/////////////////////////////////////////////////////////////
// Mode Control
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_MODE[]                       = '[?h'   // Set mode
constant char NAV_ANSI_RESET_MODE[]                     = '[?l'   // Reset mode

/////////////////////////////////////////////////////////////
// 256-Color Palette
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR[]                      = '[38;5;' // Set color
constant char NAV_ANSI_SET_BACKGROUND_COLOR[]           = '[48;5;' // Set background color

/////////////////////////////////////////////////////////////
// True Color (RGB)
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_RGB[]                  = '[38;2;' // Set color RGB
constant char NAV_ANSI_SET_BACKGROUND_COLOR_RGB[]       = '[48;2;' // Set background color RGB

/////////////////////////////////////////////////////////////
// Box Drawing
/////////////////////////////////////////////////////////////
constant char NAV_BOX_HORIZONTAL[]                       = '─'    // Horizontal line
constant char NAV_BOX_VERTICAL[]                         = '│'    // Vertical line
constant char NAV_BOX_TOP_LEFT[]                         = '┌'    // Top left corner
constant char NAV_BOX_TOP_RIGHT[]                        = '┐'    // Top right corner
constant char NAV_BOX_BOTTOM_LEFT[]                      = '└'    // Bottom left corner
constant char NAV_BOX_BOTTOM_RIGHT[]                     = '┘'    // Bottom right corner
constant char NAV_BOX_CROSS[]                            = '┼'    // Cross intersection
constant char NAV_BOX_T_TOP[]                            = '┬'    // T intersection (top)
constant char NAV_BOX_T_BOTTOM[]                         = '┴'    // T intersection (bottom)
constant char NAV_BOX_T_LEFT[]                           = '├'    // T intersection (left)
constant char NAV_BOX_T_RIGHT[]                          = '┤'    // T intersection (right)

/////////////////////////////////////////////////////////////
// Common Terminal Dimensions
/////////////////////////////////////////////////////////////
constant integer NAV_TERMINAL_WIDTH_DEFAULT             = 80     // Default terminal width
constant integer NAV_TERMINAL_HEIGHT_DEFAULT            = 24     // Default terminal height
constant integer NAV_TERMINAL_WIDTH_WIDE                = 132    // Wide terminal width
constant integer NAV_TERMINAL_HEIGHT_WIDE               = 43     // Wide terminal height

/////////////////////////////////////////////////////////////
// Common Colors (RGB values for true color)
/////////////////////////////////////////////////////////////
constant char NAV_COLOR_RED_RGB[]                        = '255;0;0'      // Pure red
constant char NAV_COLOR_GREEN_RGB[]                      = '0;255;0'      // Pure green
constant char NAV_COLOR_BLUE_RGB[]                       = '0;0;255'      // Pure blue
constant char NAV_COLOR_YELLOW_RGB[]                     = '255;255;0'    // Pure yellow
constant char NAV_COLOR_MAGENTA_RGB[]                    = '255;0;255'    // Pure magenta
constant char NAV_COLOR_CYAN_RGB[]                       = '0;255;255'    // Pure cyan
constant char NAV_COLOR_WHITE_RGB[]                      = '255;255;255'  // Pure white
constant char NAV_COLOR_BLACK_RGB[]                      = '0;0;0'        // Pure black
constant char NAV_COLOR_GRAY_RGB[]                       = '128;128;128'  // Medium gray
constant char NAV_COLOR_LIGHT_GRAY_RGB[]                 = '211;211;211'  // Light gray
constant char NAV_COLOR_DARK_GRAY_RGB[]                  = '169;169;169'  // Dark gray
constant char NAV_COLOR_BROWN_RGB[]                      = '165;42;42'    // Brown
constant char NAV_COLOR_OLIVE_RGB[]                     = '128;128;0'    // Olive
constant char NAV_COLOR_PURPLE_RGB[]                    = '128;0;128'    // Purple
constant char NAV_COLOR_TEAL_RGB[]                      = '0;128;128'    // Teal
constant char NAV_COLOR_NAVY_RGB[]                      = '0;0;128'      // Navy

#END_IF // __NAV_FOUNDATION_TUI_H__
