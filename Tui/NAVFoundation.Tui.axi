PROGRAM_NAME='NAVFoundation.Tui'

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


#IF_NOT_DEFINED __NAV_FOUNDATION_TUI__
#DEFINE __NAV_FOUNDATION_TUI__ 'NAVFoundation.Tui'

#include 'NAVFoundation.Tui.h.axi'
#include 'NAVFoundation.Core.h.axi'


/**
 * Generates an ANSI escape sequence by prepending the escape character
 * @param {char[]} color - The ANSI color/formatting code
 * @returns {char[]} The complete ANSI escape sequence
 */
define_function char[NAV_MAX_CHARS] NAVGetColor(char color[]) {
    return "NAV_ESC, color"
}


/**
 * Applies bright red foreground color to text
 * @param {char[]} value - The text to color
 * @returns {char[]} The colored text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVColorRed(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_RED), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


/**
 * Applies bright green foreground color to text
 * @param {char[]} value - The text to color
 * @returns {char[]} The colored text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVColorGreen(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_GREEN), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


/**
 * Applies bright yellow foreground color to text
 * @param {char[]} value - The text to color
 * @returns {char[]} The colored text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVColorYellow(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_YELLOW), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


/**
 * Applies bright blue foreground color to text
 * @param {char[]} value - The text to color
 * @returns {char[]} The colored text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVColorBlue(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_BLUE), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


/**
 * Applies bright magenta foreground color to text
 * @param {char[]} value - The text to color
 * @returns {char[]} The colored text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVColorMagenta(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_MAGENTA), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


/**
 * Applies bright cyan foreground color to text
 * @param {char[]} value - The text to color
 * @returns {char[]} The colored text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVColorCyan(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_CYAN), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


/**
 * Applies bright white foreground color to text
 * @param {char[]} value - The text to color
 * @returns {char[]} The colored text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVColorWhite(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_WHITE), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


/**
 * Applies bright black foreground color to text
 * @param {char[]} value - The text to color
 * @returns {char[]} The colored text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVColorBlack(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_FOREGROUND_BRIGHT_BLACK), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


/////////////////////////////////////////////////////////////
// Cursor Movement Functions
/////////////////////////////////////////////////////////////

/**
 * Moves the cursor up by the specified number of lines
 * @param {integer} lines - Number of lines to move up
 * @returns {char[]} ANSI escape sequence for cursor movement
 */
define_function char[NAV_MAX_CHARS] NAVCursorUp(integer lines) {
    return "NAV_ESC, '[', itoa(lines), 'A'"
}

/**
 * Moves the cursor down by the specified number of lines
 * @param {integer} lines - Number of lines to move down
 * @returns {char[]} ANSI escape sequence for cursor movement
 */
define_function char[NAV_MAX_CHARS] NAVCursorDown(integer lines) {
    return "NAV_ESC, '[', itoa(lines), 'B'"
}

/**
 * Moves the cursor forward (right) by the specified number of columns
 * @param {integer} columns - Number of columns to move forward
 * @returns {char[]} ANSI escape sequence for cursor movement
 */
define_function char[NAV_MAX_CHARS] NAVCursorForward(integer columns) {
    return "NAV_ESC, '[', itoa(columns), 'C'"
}

/**
 * Moves the cursor backward (left) by the specified number of columns
 * @param {integer} columns - Number of columns to move backward
 * @returns {char[]} ANSI escape sequence for cursor movement
 */
define_function char[NAV_MAX_CHARS] NAVCursorBack(integer columns) {
    return "NAV_ESC, '[', itoa(columns), 'D'"
}

/**
 * Moves the cursor to the specified row and column position
 * @param {integer} row - Row number (1-based)
 * @param {integer} column - Column number (1-based)
 * @returns {char[]} ANSI escape sequence for cursor positioning
 */
define_function char[NAV_MAX_CHARS] NAVCursorPosition(integer row, integer column) {
    return "NAV_ESC, '[', itoa(row), ';', itoa(column), 'H'"
}

/**
 * Moves the cursor to the home position (1,1)
 * @returns {char[]} ANSI escape sequence for cursor home
 */
define_function char[NAV_MAX_CHARS] NAVCursorHome() {
    return "NAV_ESC, '[H'"
}

/**
 * Hides the cursor
 * @returns {char[]} ANSI escape sequence to hide cursor
 */
define_function char[NAV_MAX_CHARS] NAVCursorHide() {
    return "NAV_ESC, NAV_ANSI_CURSOR_HIDE"
}

/**
 * Shows the cursor
 * @returns {char[]} ANSI escape sequence to show cursor
 */
define_function char[NAV_MAX_CHARS] NAVCursorShow() {
    return "NAV_ESC, NAV_ANSI_CURSOR_SHOW"
}


/////////////////////////////////////////////////////////////
// Screen Clearing Functions
/////////////////////////////////////////////////////////////

/**
 * Clears the entire screen
 * @returns {char[]} ANSI escape sequence to clear screen
 */
define_function char[NAV_MAX_CHARS] NAVClearScreen() {
    return "NAV_ESC, '[2J'"
}

/**
 * Clears the screen from the cursor position to the end of the screen
 * @returns {char[]} ANSI escape sequence to clear screen from cursor
 */
define_function char[NAV_MAX_CHARS] NAVClearScreenFromCursor() {
    return "NAV_ESC, '[0J'"
}

/**
 * Clears the screen from the beginning to the cursor position
 * @returns {char[]} ANSI escape sequence to clear screen to cursor
 */
define_function char[NAV_MAX_CHARS] NAVClearScreenToCursor() {
    return "NAV_ESC, '[1J'"
}

/**
 * Clears the entire current line
 * @returns {char[]} ANSI escape sequence to clear line
 */
define_function char[NAV_MAX_CHARS] NAVClearLine() {
    return "NAV_ESC, '[2K'"
}

/**
 * Clears the line from the cursor position to the end of the line
 * @returns {char[]} ANSI escape sequence to clear line from cursor
 */
define_function char[NAV_MAX_CHARS] NAVClearLineFromCursor() {
    return "NAV_ESC, '[0K'"
}

/**
 * Clears the line from the beginning to the cursor position
 * @returns {char[]} ANSI escape sequence to clear line to cursor
 */
define_function char[NAV_MAX_CHARS] NAVClearLineToCursor() {
    return "NAV_ESC, '[1K'"
}


/////////////////////////////////////////////////////////////
// Text Formatting Functions
/////////////////////////////////////////////////////////////

/**
 * Applies bold formatting to text
 * @param {char[]} value - The text to format
 * @returns {char[]} The formatted text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVTextBold(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_BOLD), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}

/**
 * Applies underline formatting to text
 * @param {char[]} value - The text to format
 * @returns {char[]} The formatted text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVTextUnderline(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_UNDERLINE), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}

/**
 * Applies reverse video (swap foreground/background colors) to text
 * @param {char[]} value - The text to format
 * @returns {char[]} The formatted text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVTextReverse(char value[]) {
    return "NAVGetColor(NAV_ANSI_SGR_REVERSE_VIDEO), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


/////////////////////////////////////////////////////////////
// Color Functions (RGB)
/////////////////////////////////////////////////////////////

/**
 * Sets the foreground color using RGB values (true color)
 * @param {integer} r - Red component (0-255)
 * @param {integer} g - Green component (0-255)
 * @param {integer} b - Blue component (0-255)
 * @returns {char[]} ANSI escape sequence for RGB foreground color
 */
define_function char[NAV_MAX_CHARS] NAVSetForegroundRGB(integer r, integer g, integer b) {
    return "NAV_ESC, NAV_ANSI_SET_COLOR_RGB, itoa(r), ';', itoa(g), ';', itoa(b), 'm'"
}

/**
 * Sets the background color using RGB values (true color)
 * @param {integer} r - Red component (0-255)
 * @param {integer} g - Green component (0-255)
 * @param {integer} b - Blue component (0-255)
 * @returns {char[]} ANSI escape sequence for RGB background color
 */
define_function char[NAV_MAX_CHARS] NAVSetBackgroundRGB(integer r, integer g, integer b) {
    return "NAV_ESC, NAV_ANSI_SET_BACKGROUND_COLOR_RGB, itoa(r), ';', itoa(g), ';', itoa(b), 'm'"
}

/**
 * Applies RGB foreground color to text
 * @param {char[]} value - The text to color
 * @param {integer} r - Red component (0-255)
 * @param {integer} g - Green component (0-255)
 * @param {integer} b - Blue component (0-255)
 * @returns {char[]} The colored text with reset sequence
 */
define_function char[NAV_MAX_BUFFER] NAVColorRGB(char value[], integer r, integer g, integer b) {
    return "NAVSetForegroundRGB(r, g, b), value, NAVGetColor(NAV_ANSI_SGR_RESET)"
}


/////////////////////////////////////////////////////////////
// Utility Functions
/////////////////////////////////////////////////////////////

/**
 * Resets all text formatting to default
 * @returns {char[]} ANSI escape sequence to reset formatting
 */
define_function char[NAV_MAX_CHARS] NAVResetFormatting() {
    return "NAV_ESC, NAV_ANSI_SGR_RESET"
}

/**
 * Saves the current cursor position
 * @returns {char[]} ANSI escape sequence to save cursor position
 */
define_function char[NAV_MAX_CHARS] NAVSaveCursorPosition() {
    return "NAV_ESC, '[s'"
}

/**
 * Restores the previously saved cursor position
 * @returns {char[]} ANSI escape sequence to restore cursor position
 */
define_function char[NAV_MAX_CHARS] NAVRestoreCursorPosition() {
    return "NAV_ESC, '[u'"
}


/////////////////////////////////////////////////////////////
// UI Element Functions
/////////////////////////////////////////////////////////////

/**
 * Draws a horizontal line using box drawing characters
 * @param {integer} length - Length of the horizontal line
 * @returns {char[]} String containing the horizontal line
 */
define_function char[NAV_MAX_BUFFER] NAVDrawHorizontalLine(integer length) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    result = ''
    for (i = 1; i <= length; i++) {
        result = "result, NAV_BOX_HORIZONTAL"
    }

    return result
}

/**
 * Draws a box using box drawing characters
 * @param {integer} width - Width of the box
 * @param {integer} height - Height of the box
 * @returns {char[]} Multi-line string containing the box
 */
define_function char[NAV_MAX_BUFFER] NAVDrawBox(integer width, integer height) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    // Top border
    result = "NAV_BOX_TOP_LEFT, NAVDrawHorizontalLine(width - 2), NAV_BOX_TOP_RIGHT, NAV_CR, NAV_LF"

    // Middle lines
    for (i = 1; i <= height - 2; i++) {
        result = "result, NAV_BOX_VERTICAL, NAVRepeatChar(' ', width - 2), NAV_BOX_VERTICAL, NAV_CR, NAV_LF"
    }

    // Bottom border
    result = "result, NAV_BOX_BOTTOM_LEFT, NAVDrawHorizontalLine(width - 2), NAV_BOX_BOTTOM_RIGHT"

    return result
}

/**
 * Centers text within a specified width by adding padding spaces
 * @param {char[]} text - The text to center
 * @param {integer} width - The total width to center within
 * @returns {char[]} The centered text with padding
 */
define_function char[NAV_MAX_BUFFER] NAVCenterText(char text[], integer width) {
    stack_var integer textLength
    stack_var integer padding

    textLength = length_string(text)
    if (textLength >= width) {
        return left_string(text, width)
    }

    padding = (width - textLength) / 2
    return "NAVRepeatChar(' ', padding), text, NAVRepeatChar(' ', width - textLength - padding)"
}


/////////////////////////////////////////////////////////////
// Helper Functions
/////////////////////////////////////////////////////////////

/**
 * Repeats a character a specified number of times
 * @param {char} ch - The character to repeat
 * @param {integer} count - Number of times to repeat the character
 * @returns {char[]} String containing the repeated character
 */
define_function char[NAV_MAX_CHARS] NAVRepeatChar(char ch, integer count) {
    stack_var char result[NAV_MAX_CHARS]
    stack_var integer i

    result = ''
    for (i = 1; i <= count; i++) {
        result = "result, ch"
    }

    return result
}


#END_IF // __NAV_FOUNDATION_TUI__
