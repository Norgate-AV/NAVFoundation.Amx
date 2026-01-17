PROGRAM_NAME='NAVFoundation.Figlet'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_FIGLET__
#DEFINE __NAV_FOUNDATION_FIGLET__ 'NAVFoundation.Figlet'

#include 'NAVFoundation.Figlet.h.axi'
#include 'NAVFoundation.FigletStandardFont.axi'
#include 'NAVFoundation.StringUtils.axi'

/**
 * Gets the visual width of a character in the Figlet font
 *
 * Dispatches to font-specific implementation based on the current font type.
 *
 * @param c The character to get the width for (ASCII 32-126)
 * @param font The font type to use
 * @return The width of the character in columns, or 2 for unknown characters
 */
define_function integer NAVFigletGetCharWidth(char c, integer font) {
    switch(font) {
        case NAV_FIGLET_FONT_STANDARD: return NAVFigletStandardGetCharWidth(c)
        // Future fonts: add cases here
        default: return NAVFigletStandardGetCharWidth(c)  // Fallback to Standard
    }
}

/**
 * Gets a specific line of a character from the Figlet font
 *
 * Dispatches to font-specific implementation based on the current font type.
 *
 * @param c The character to get the line for (ASCII 32-126)
 * @param line The line number (1-6) to retrieve
 * @param font The font type to use
 * @return The character's line representation, or '  ' for unknown characters
 */
define_function char[NAV_FIGLET_MAX_CHAR_WIDTH] NAVFigletGetCharLine(char c, integer line, integer font) {
    switch(font) {
        case NAV_FIGLET_FONT_STANDARD: return NAVFigletStandardGetCharLine(c, line)
        // Future fonts: add cases here
        default: return NAVFigletStandardGetCharLine(c, line)  // Fallback to Standard
    }
}

/**
 * Checks if two characters can smush according to Rule 1: Equal Character Smushing
 *
 * Two sub-characters are smushed into a single sub-character if they are the same.
 *
 * @param ch1 First character
 * @param ch2 Second character
 * @return true if characters can smush, false if not
 */
define_function char NAVFigletCanSmushRule1(char ch1, char ch2) {
    // Equal characters (except spaces) can smush
    if (ch1 = ch2 && ch1 != ' ') {
        return ch1
    }

    return false
}

/**
 * Checks if two characters can smush according to Rule 2: Underscore Smushing
 *
 * An underscore ("_") will be replaced by any of: "|", "/", "\", "[", "]", "{", "}", "(", ")", "<" or ">".
 *
 * @param ch1 First character
 * @param ch2 Second character
 * @return true if characters can smush, false if not
 */
define_function char NAVFigletCanSmushRule2(char ch1, char ch2) {
    stack_var char rule2Chars[11]

    rule2Chars = '|/\[]{}()<>'

    if (ch1 = '_') {
        if (find_string(rule2Chars, "ch2", 1)) {
            return ch2
        }
    }
    else if (ch2 = '_') {
        if (find_string(rule2Chars, "ch1", 1)) {
            return ch1
        }
    }

    return false
}

/**
 * Checks if two characters can smush according to Rule 3: Hierarchy Smushing
 *
 * A hierarchy of classes is used: "|", "/\", "[]", "{}", "()", and "<>".
 * When two smushing sub-characters are from different classes,
 * the one from the latter class will be used.
 *
 * @param ch1 First character
 * @param ch2 Second character
 * @return true if characters can smush, false if not
 */
define_function char NAVFigletCanSmushRule3(char ch1, char ch2) {
    stack_var integer pos1
    stack_var integer pos2
    stack_var char hierarchy[14]

    hierarchy = '| /\ [] {} () <>'

    pos1 = find_string(hierarchy, "ch1", 1)
    pos2 = find_string(hierarchy, "ch2", 1)

    // Both must be in hierarchy
    if (pos1 > 0 && pos2 > 0) {
        // Must be different positions and not adjacent
        if (pos1 != pos2) {
            // Check if they're from different pairs (not adjacent)
            if (abs_value(pos1 - pos2) > 1) {
                return true
            }
        }
    }

    return false
}

/**
 * Gets the smushed character for Rule 3: Hierarchy Smushing
 *
 * Returns the character from the latter (higher) class in the hierarchy.
 *
 * @param ch1 First character
 * @param ch2 Second character
 * @return The character from the higher class
 */
define_function char NAVFigletGetSmushRule3Char(char ch1, char ch2) {
    stack_var integer pos1
    stack_var integer pos2
    stack_var char hierarchy[14]

    hierarchy = '| /\ [] {} () <>'

    pos1 = find_string(hierarchy, "ch1", 1)
    pos2 = find_string(hierarchy, "ch2", 1)

    // Return character from higher position (latter class)
    if (pos1 > pos2) {
        return ch1
    }
    else {
        return ch2
    }
}

/**
 * Checks if two characters can smush according to Rule 4: Opposite Pair Smushing
 *
 * Smushes opposing brackets ("[]" or "]["), braces ("{}" or "}{")
 * and parentheses ("()" or ")(") together, replacing any such pair with a vertical bar ("|").
 *
 * @param ch1 First character
 * @param ch2 Second character
 * @return true if characters can smush, false if not
 */
define_function char NAVFigletCanSmushRule4(char ch1, char ch2) {
    // Check for opposing bracket pairs
    if ((ch1 = '[' && ch2 = ']') || (ch1 = ']' && ch2 = '[')) {
        return '|'
    }

    if ((ch1 = '{' && ch2 = '}') || (ch1 = '}' && ch2 = '{')) {
        return '|'
    }

    if ((ch1 = '(' && ch2 = ')') || (ch1 = ')' && ch2 = '(')) {
        return '|'
    }

    return false
}

/**
 * Universal smushing - used when at least one character is a space
 * or as a fallback when no specific smush rule applies.
 *
 * Rules:
 * - If right character is space, use left character
 * - Otherwise, use right character
 *
 * This matches the TypeScript uni_Smush function behavior.
 *
 * @param ch1 First character (left)
 * @param ch2 Second character (right)
 * @return The character to use at this position
 */
define_function char NAVFigletUniSmush(char ch1, char ch2) {
    if (ch2 = ' ' || ch2 = 0) {
        return ch1
    }
    else {
        return ch2
    }
}

/**
 * Checks if two characters can smush according to enabled smushing rules
 *
 * Standard font uses rules 1-4:
 * - Rule 1: Equal character smushing
 * - Rule 2: Underscore smushing
 * - Rule 3: Hierarchy smushing
 * - Rule 4: Opposite pair smushing
 *
 * @param ch1 First character
 * @param ch2 Second character
 * @return true if characters can smush, false if not
 */
define_function char NAVFigletCanSmush(char ch1, char ch2) {
    // Try each smushing rule
    if (NAVFigletCanSmushRule1(ch1, ch2)) {
        return true
    }

    if (NAVFigletCanSmushRule2(ch1, ch2)) {
        return true
    }

    if (NAVFigletCanSmushRule3(ch1, ch2)) {
        return true
    }

    if (NAVFigletCanSmushRule4(ch1, ch2)) {
        return true
    }

    return false
}

/**
 * Calculates the maximum overlap distance for a single line without collision.
 *
 * This helper function determines how much a new character can overlap with
 * the existing content on a single line. Uses CONTROLLED_SMUSHING mode with
 * rules 1-4 to match the Standard font behavior.
 *
 * @param currentLine The current content of this line
 * @param charLine The line content of the character to add
 * @param charWidth The width of the character being added
 * @return The maximum overlap distance (0 if no overlap possible)
 */
define_function integer NAVFigletCalculateLineOverlap(char currentLine[], char charLine[], integer charWidth) {
    stack_var integer currentLen
    stack_var integer maxDist
    stack_var integer curDist
    stack_var integer j
    stack_var char ch1
    stack_var char ch2
    stack_var char breakAfter
    stack_var char validSmush

    currentLen = length_array(currentLine)

    if (currentLen = 0) {
        return 0
    }

    // maxDist is how far we could possibly overlap
    maxDist = min_value(currentLen, charWidth)

    // Start from distance 1 and increase until we hit a collision
    curDist = 1
    while (curDist <= maxDist) {
        breakAfter = false

        // Check all positions in the overlap region, but only up to the new character's width
        for (j = 1; j <= min_value(curDist, charWidth); j++) {
            // Position in current line: from end going back
            ch1 = currentLine[currentLen - curDist + j]
            // Position in new character: from start going forward
            ch2 = charLine[j]

            // If both are non-space, check if they can smush
            if (ch1 != ' ' && ch2 != ' ') {
                // We know we need to break, but check if smushing rules allow overlap
                breakAfter = true

                // Check if these characters can smush according to our rules
                validSmush = NAVFigletCanSmush(ch1, ch2)

                if (!validSmush) {
                    // Cannot smush - back off by one and return
                    return curDist - 1
                }
            }
        }

        // If we found a smushable collision, stop here
        if (breakAfter) {
            return curDist
        }

        curDist = curDist + 1
    }

    // No non-space collision found - can overlap by maxDist
    return maxDist
}

/**
 * Calculates the optimal overlap for a character across all lines.
 *
 * Uses the FITTING layout algorithm to determine how much a character
 * can overlap with existing content. Takes the minimum overlap across
 * all lines to ensure consistent alignment.
 *
 * @param lines Array of current line contents
 * @param c The character to calculate overlap for
 * @param font The font type to use
 * @return The overlap distance (0 for no overlap)
 */
define_function integer NAVFigletCalculateCharacterOverlap(char lines[][2048], char c, integer font) {
    stack_var integer line
    stack_var integer minOverlap
    stack_var integer lineOverlap
    stack_var char charLine[12]
    stack_var integer charWidth

    charWidth = NAVFigletGetCharWidth(c, font)

    // Space character always overlaps by 1 to maintain proper word spacing
    if (c = 32) {
        return 1
    }

    minOverlap = 10000  // Sentinel value for minimum tracking

    // Calculate overlap for each line and take the minimum
    for (line = 1; line <= NAV_FIGLET_FONT_HEIGHT; line++) {
        charLine = NAVFigletGetCharLine(c, line, font)
        // Trim to actual character width (removes excess padding beyond charWidth)
        charLine = NAVStringSubstring(charLine, 1, charWidth)
        lineOverlap = NAVFigletCalculateLineOverlap(lines[line], charLine, charWidth)

        if (lineOverlap < minOverlap) {
            minOverlap = lineOverlap
        }
    }

    // Return the minimum overlap (or 0 if no overlap calculated)
    if (minOverlap = 10000) {
        return 0
    }

    return minOverlap
}

/**
 * Adds a character to all lines with the specified overlap.
 *
 * Overlays the new character with the existing content, using smushing rules
 * to determine which character to keep at each overlapping position.
 *
 * @param lines Array of line contents to modify (passed by reference)
 * @param c The character to add
 * @param overlap Amount of overlap to apply
 * @param font The font type to use
 */
define_function NAVFigletAddCharacterToLines(char lines[][2048], char c, integer overlap, integer font) {
    stack_var integer line
    stack_var char charLine[12]
    stack_var integer charWidth
    stack_var integer existingLen
    stack_var integer i
    stack_var char leftChar
    stack_var char rightChar
    stack_var char smushedChar

    charWidth = NAVFigletGetCharWidth(c, font)

    for (line = 1; line <= NAV_FIGLET_FONT_HEIGHT; line++) {
        charLine = NAVFigletGetCharLine(c, line, font)
        charLine = NAVStringSubstring(charLine, 1, charWidth)
        existingLen = length_array(lines[line])

        if (overlap > 0 && existingLen > 0) {
            // Overlay the overlapping region, using smush rules to combine characters
            for (i = 1; i <= overlap; i++) {
                leftChar = lines[line][existingLen - overlap + i]

                // Get right character - if beyond charWidth, treat as space
                if (i <= charWidth) {
                    rightChar = charLine[i]
                }
                else {
                    rightChar = ' '
                }

                // Determine which character to keep at this position
                if (leftChar != ' ' && rightChar != ' ') {
                    // Both non-space - try smush rules first
                    smushedChar = NAVFigletCanSmushRule1(leftChar, rightChar)

                    if (!smushedChar) {
                        smushedChar = NAVFigletCanSmushRule2(leftChar, rightChar)
                    }

                    if (!smushedChar) {
                        if (NAVFigletCanSmushRule3(leftChar, rightChar)) {
                            smushedChar = NAVFigletGetSmushRule3Char(leftChar, rightChar)
                        }
                    }

                    if (!smushedChar) {
                        smushedChar = NAVFigletCanSmushRule4(leftChar, rightChar)
                    }

                    if (!smushedChar) {
                        // No specific rule applies - use universal smushing
                        smushedChar = NAVFigletUniSmush(leftChar, rightChar)
                    }
                }
                else {
                    // At least one is a space - use universal smushing
                    smushedChar = NAVFigletUniSmush(leftChar, rightChar)
                }

                // Update the character at this overlapping position
                lines[line][existingLen - overlap + i] = smushedChar
            }

            // Append the non-overlapping part of the new character
            if (charWidth > overlap) {
                lines[line] = "lines[line], NAVStringSubstring(charLine, overlap + 1, charWidth - overlap)"
            }
        }
        else {
            // No overlap - just append
            lines[line] = "lines[line], charLine"
        }
    }
}

/**
 * Combines multiple lines into a single string with line breaks.
 *
 * @param lines Array of line contents
 * @return Combined string with CR/LF line breaks (no trailing CRLF)
 */
define_function char[2048] NAVFigletCombineLines(char lines[][2048]) {
    stack_var integer line
    stack_var char result[2048]
    stack_var char trimmedLine[2048]

    // Trim trailing spaces from each line before combining
    result = NAVTrimStringRight(lines[1])
    for (line = 2; line <= NAV_FIGLET_FONT_HEIGHT; line++) {
        trimmedLine = NAVTrimStringRight(lines[line])
        // Only add CRLF and line if not the last line or if last line has content
        if (line < NAV_FIGLET_FONT_HEIGHT || length_array(trimmedLine) > 0) {
            result = "result, $0D, $0A, trimmedLine"
        }
    }

    return result
}

/**
 * Converts text into Figlet ASCII art format using the default font
 *
 * This function takes any text string and converts it into large ASCII art characters
 * using the Standard Figlet font. The output is 6 lines tall and only supports
 * printable ASCII characters (32-126).
 *
 * This is a convenience wrapper around NAVFigletWithFont() that uses the default font.
 *
 * @param text The text to convert to Figlet format
 * @return A multi-line string containing the Figlet representation of the input text,
 *         or an empty string if the input is empty
 *
 * @example
 * ```netlinx
 * // Convert "Hi" to Figlet
 * char result[2048]
 * result = NAVFiglet('Hi')
 * // Result will be a 6-line ASCII art representation of "Hi"
 * ```
 *
 * @see NAVFigletWithFont
 */
define_function char[2048] NAVFiglet(char text[]) {
    return NAVFigletWithFont(text, NAV_FIGLET_FONT_DEFAULT)
}

/**
 * Converts text into Figlet ASCII art format using a specific font
 *
 * This is the main Figlet conversion function that supports multiple font types.
 * Currently only the Standard font is implemented, but the architecture supports
 * adding additional fonts in the future.
 *
 * The Standard font uses CONTROLLED_SMUSHING layout mode with rules 1-4:
 * - Rule 1: Equal character smushing (e.g., '|' + '|' = '|')
 * - Rule 2: Underscore smushing (e.g., '_' + '|' = '|')
 * - Rule 3: Hierarchy smushing (e.g., different character classes)
 * - Rule 4: Opposite pair smushing (e.g., '[]', '{}', '()')
 *
 * @param text The text to convert to Figlet format
 * @param font The font type to use (currently only NAV_FIGLET_FONT_STANDARD is supported)
 * @return A multi-line string containing the Figlet representation of the input text,
 *         or an empty string if the input is empty
 *
 * @example
 * ```netlinx
 * // Convert "Hello" to Figlet using Standard font
 * char result[2048]
 * result = NAVFigletWithFont('Hello', NAV_FIGLET_FONT_STANDARD)
 * ```
 *
 * @see NAVFiglet
 */
define_function char[2048] NAVFigletWithFont(char text[], integer font) {
    stack_var integer i
    stack_var integer line
    stack_var integer charIndex
    stack_var integer overlap
    stack_var char lines[NAV_FIGLET_FONT_HEIGHT][2048]

    // Validate font parameter - currently only Standard font is supported
    if (font != NAV_FIGLET_FONT_STANDARD) {
        font = NAV_FIGLET_FONT_STANDARD
    }

    // Handle empty string
    if (!length_array(text)) {
        return ''
    }

    // Initialize all lines to empty
    for (line = 1; line <= NAV_FIGLET_FONT_HEIGHT; line++) {
        lines[line] = ''
    }

    // Process each character
    for (i = 1; i <= length_array(text); i++) {
        charIndex = text[i]

        // Only process printable ASCII characters (32-126)
        if (charIndex >= 32 && charIndex <= 126) {
            // Calculate overlap (first character has no overlap)
            if (i = 1) {
                overlap = 0
            }
            else {
                // If previous character was a space, next character should not overlap to preserve word spacing
                if (i > 1 && text[i-1] = 32) {
                    overlap = 0
                }
                else {
                    overlap = NAVFigletCalculateCharacterOverlap(lines, type_cast(charIndex), font)
                }
            }

            // Add character to all lines with calculated overlap
            NAVFigletAddCharacterToLines(lines, type_cast(charIndex), overlap, font)
        }
    }

    // Combine lines and return
    return NAVFigletCombineLines(lines)
}


define_function NAVFigletLog(char text[]) {
    stack_var char lines[10][255]
    stack_var integer count
    stack_var integer i

    if (!length_array(text)) {
        return
    }

    count = NAVSplitString(text, "$0D, $0A", lines)
    if (!count) {
        return
    }

    for (i = 1; i <= count; i++) {
        NAVLog(lines[i])
    }
}

#END_IF // __NAV_FOUNDATION_FIGLET__
