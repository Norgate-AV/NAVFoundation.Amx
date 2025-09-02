PROGRAM_NAME='NAVFoundation.Tui.h'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

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
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_WINDOW_TITLE[]                   = '[2;4t' // Window title
constant char NAV_ANSI_WINDOW_ICON[]                    = '[1t'   // Window icon
constant char NAV_ANSI_WINDOW_POSITION[]                = '[3;4t' // Window position
constant char NAV_ANSI_WINDOW_SIZE[]                    = '[8;4t' // Window size
constant char NAV_ANSI_WINDOW_MAXIMIZE[]                = '[9t'   // Window maximize
constant char NAV_ANSI_WINDOW_FULL_SCREEN[]             = '[10t'  // Window full screen

/////////////////////////////////////////////////////////////
// Terminal Window
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
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_DEVICE_STATUS[]                  = '[5n'   // Device status
constant char NAV_ANSI_DEVICE_STATUS_REPORT[]           = '[6n'   // Device status report
constant char NAV_ANSI_DEVICE_STATUS_REPORT_POSITION[]  = '[?6n'  // Device status report position
constant char NAV_ANSI_DEVICE_STATUS_REPORT_CURSOR[]    = '[?15n' // Device status report cursor
constant char NAV_ANSI_DEVICE_STATUS_REPORT_COLOR[]     = '[?25n' // Device status report color

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_DEVICE_ATTRIBUTES[]              = '[c'    // Device attributes
constant char NAV_ANSI_DEVICE_ATTRIBUTES_EXTENDED[]     = '[>c'   // Device attributes extended
constant char NAV_ANSI_DEVICE_ATTRIBUTES_EXTENDED2[]    = '[=c'   // Device attributes extended 2
constant char NAV_ANSI_DEVICE_ATTRIBUTES_EXTENDED3[]    = '[?c'   // Device attributes extended 3

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SOFT_RESET[]                     = '[!p'   // Soft reset
constant char NAV_ANSI_HARD_RESET[]                     = '[!^'   // Hard reset

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_MODE[]                       = '[?h'   // Set mode
constant char NAV_ANSI_RESET_MODE[]                     = '[?l'   // Reset mode

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR[]                      = '[38;5;' // Set color
constant char NAV_ANSI_SET_BACKGROUND_COLOR[]           = '[48;5;' // Set background color

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_RGB[]                  = '[38;2;' // Set color RGB
constant char NAV_ANSI_SET_BACKGROUND_COLOR_RGB[]       = '[48;2;' // Set background color RGB

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HSL[]                  = '[38;3;' // Set color HSL
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HSL[]       = '[48;3;' // Set background color HSL

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_CMYK[]                 = '[38;4;' // Set color CMYK
constant char NAV_ANSI_SET_BACKGROUND_COLOR_CMYK[]      = '[48;4;' // Set background color CMYK

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HSV[]                  = '[38;6;' // Set color HSV
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HSV[]       = '[48;6;' // Set background color HSV

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HSB[]                  = '[38;7;' // Set color HSB
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HSB[]       = '[48;7;' // Set background color HSB

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HSI[]                  = '[38;8;' // Set color HSI
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HSI[]       = '[48;8;' // Set background color HSI

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HCL[]                  = '[38;9;' // Set color HCL
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HCL[]       = '[48;9;' // Set background color HCL

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_LAB[]                  = '[38;10;' // Set color LAB
constant char NAV_ANSI_SET_BACKGROUND_COLOR_LAB[]       = '[48;10;' // Set background color LAB

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_LCH[]                  = '[38;11;' // Set color LCH
constant char NAV_ANSI_SET_BACKGROUND_COLOR_LCH[]       = '[48;11;' // Set background color LCH

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_LUV[]                  = '[38;12;' // Set color LUV
constant char NAV_ANSI_SET_BACKGROUND_COLOR_LUV[]       = '[48;12;' // Set background color LUV

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_LCHUV[]                = '[38;13;' // Set color LCHUV
constant char NAV_ANSI_SET_BACKGROUND_COLOR_LCHUV[]     = '[48;13;' // Set background color LCHUV

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HSVK[]                 = '[38;14;' // Set color HSVK
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HSVK[]      = '[48;14;' // Set background color HSVK

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HSLUV[]                = '[38;15;' // Set color HSLUV
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HSLUV[]     = '[48;15;' // Set background color HSLUV

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HPLUV[]                = '[38;16;' // Set color HPLUV
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HPLUV[]     = '[48;16;' // Set background color HPLUV

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HSLCH[]                = '[38;17;' // Set color HSLCH
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HSLCH[]     = '[48;17;' // Set background color HSLCH

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HPLCH[]                = '[38;18;' // Set color HPLCH
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HPLCH[]     = '[48;18;' // Set background color HPLCH

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HSLCHUV[]              = '[38;19;' // Set color HSLCHUV
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HSLCHUV[]   = '[48;19;' // Set background color HSLCHUV

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HPLCHUV[]              = '[38;20;' // Set color HPLCHUV
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HPLCHUV[]   = '[48;20;' // Set background color HPLCHUV

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HSVL[]                 = '[38;21;' // Set color HSVL
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HSVL[]      = '[48;21;' // Set background color HSVL

/////////////////////////////////////////////////////////////
// Terminal Window
/////////////////////////////////////////////////////////////
constant char NAV_ANSI_SET_COLOR_HSLCHAB[]              = '[38;22;' // Set color HSLCHAB
constant char NAV_ANSI_SET_BACKGROUND_COLOR_HSLCHAB[]   = '[48;22;' // Set background color HSLCHAB

/////////////////////////////////////////////////////////////
// Box Drawing
/////////////////////////////////////////////////////////////



#END_IF // __NAV_FOUNDATION_TUI_H__
