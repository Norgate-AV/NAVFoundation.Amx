PROGRAM_NAME='NAVFoundation.StringUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_STRINGUTILS__
#DEFINE __NAV_FOUNDATION_STRINGUTILS__ 'NAVFoundation.StringUtils'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


// #DEFINE USING_NAV_STRING_GATHER_CALLBACK
// define_function NAVStringGatherCallback(_NAVStringGatherResult args) {}


/**
 * @function NAVStripCharsFromRight
 * @public
 * @description Removes a specified number of characters from the right end of a string.
 *
 * @param {char[]} buffer - Input string to modify
 * @param {integer} count - Number of characters to remove from the right
 *
 * @returns {char[]} Modified string with characters removed
 *
 * @example
 * stack_var char text[50]
 * text = 'Hello World'
 * text = NAVStripCharsFromRight(text, 3)  // Returns 'Hello Wo'
 */
define_function char[NAV_MAX_BUFFER] NAVStripCharsFromRight(char buffer[], integer count) {
    stack_var integer length

    length = length_array(buffer)

    if (count <= 0 || !length) {
        return buffer
    }

    if (count >= length) {
        return ''
    }

    return left_string(buffer, length_array(buffer) - count)
}


/**
 * @function NAVStripRight
 * @public
 * @description Alias for NAVStripCharsFromRight. Removes characters from the right end of a string.
 *
 * @param {char[]} buffer - Input string to modify
 * @param {integer} count - Number of characters to remove from the right
 *
 * @returns {char[]} Modified string with characters removed
 *
 * @see NAVStripCharsFromRight
 */
define_function char[NAV_MAX_BUFFER] NAVStripRight(char buffer[], integer count) {
    return NAVStripCharsFromRight(buffer, count)
}


/**
 * @function NAVStripCharsFromLeft
 * @public
 * @description Removes a specified number of characters from the left end of a string.
 *
 * @param {char[]} buffer - Input string to modify
 * @param {integer} count - Number of characters to remove from the left
 *
 * @returns {char[]} Modified string with characters removed
 *
 * @example
 * stack_var char text[50]
 * text = 'Hello World'
 * text = NAVStripCharsFromLeft(text, 3)  // Returns 'lo World'
 */
define_function char[NAV_MAX_BUFFER] NAVStripCharsFromLeft(char buffer[], integer count) {
    stack_var integer length

    length = length_array(buffer)

    if (count <= 0 || !length) {
        return buffer
    }

    if (count >= length) {
        return ''
    }

    return right_string(buffer, length_array(buffer) - count)
}


/**
 * @function NAVStripLeft
 * @public
 * @description Alias for NAVStripCharsFromLeft. Removes characters from the left end of a string.
 *
 * @param {char[]} buffer - Input string to modify
 * @param {integer} count - Number of characters to remove from the left
 *
 * @returns {char[]} Modified string with characters removed
 *
 * @see NAVStripCharsFromLeft
 */
define_function char[NAV_MAX_BUFFER] NAVStripLeft(char buffer[], integer count) {
    return NAVStripCharsFromLeft(buffer, count)
}


/**
 * @function NAVRemoveStringByLength
 * @public
 * @description Removes a specified number of characters from the beginning of a string and returns them.
 * Note that the original string buffer is mutated to contain the remaining characters after removal.
 *
 * @param {char[]} buffer - Input string buffer to modify (will be mutated)
 * @param {integer} count - Number of characters to remove from the start of the buffer
 *
 * @returns {char[]} The characters that were removed from the beginning of the string
 *
 * @example
 * stack_var char buffer[50]
 * stack_var char text[50]
 * buffer = 'Hello World'
 * text = NAVRemoveStringByLength(buffer, 6)  // Returns 'Hello '
 * // text = 'Hello '
 * // buffer = 'World'
 */
define_function char[NAV_MAX_BUFFER] NAVRemoveStringByLength(char buffer[], integer count) {
    stack_var integer length

    length = length_array(buffer)

    if (count <= 0 || !length) {
        return ''
    }

    if (count >= length) {
        stack_var char result[NAV_MAX_BUFFER]

        result = buffer
        buffer = ''

        return result
    }

    return remove_string(buffer, left_string(buffer, count), 1)
}


/**
 * @function NAVStringSubstring
 * @public
 * @description Extracts a substring from a string starting at a specified position with a specified length.
 *
 * @param {char[]} buffer - Input string
 * @param {integer} start - Starting position (1-based index)
 * @param {integer} count - Number of characters to extract, or 0 for all remaining characters
 *
 * @returns {char[]} Extracted substring
 *
 * @example
 * stack_var char text[50]
 * stack_var char result[50]
 * text = 'Hello World'
 * result = NAVStringSubstring(text, 7, 5)  // Returns 'World'
 * result = NAVStringSubstring(text, 3, 0)  // Returns 'llo World'
 *
 * @note If count is 0, extracts all characters from start to the end of the string
 */
define_function char[NAV_MAX_BUFFER] NAVStringSubstring(char buffer[], integer start, integer count) {
    stack_var integer length

    length = length_array(buffer)

    if (start <= 0 || start > length) {
        return ''
    }

    if (count < 0) {
        return ''
    }

    if (count > 0) {
        return mid_string(buffer, start, count)
    }

    return mid_string(buffer, start, (length - start) + 1)
}


/**
 * @function NAVStringSlice
 * @public
 * @description Extracts a section of a string between start and end positions.
 *
 * @param {char[]} buffer - Input string
 * @param {integer} start - Starting position (1-based index, inclusive)
 * @param {integer} end - Ending position (1-based index, exclusive)
 *
 * @returns {char[]} Extracted substring
 *
 * @example
 * stack_var char text[50]
 * stack_var char result[50]
 * text = 'Hello World'
 * result = NAVStringSlice(text, 1, 6)  // Returns 'Hello'
 *
 * @note This function is similar to the slice methods in JavaScript but with 1-based indexing
 */
define_function char[NAV_MAX_BUFFER] NAVStringSlice(char buffer[], integer start, integer end) {
    if (start <= 0 || start > length_array(buffer)) {
        return ''
    }

    if (end == 0) {
        return NAVStringSubstring(buffer, start, end)
    }

    if (end < start) {
        return ''
    }

    if ((end - start) <= 0) {
        return ''
    }

    return NAVStringSubstring(buffer, start, end - start)
}


/**
 * @function NAVFindAndReplace
 * @public
 * @description Replaces all occurrences of a substring with another string.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} match - Substring to find
 * @param {char[]} value - Replacement string
 *
 * @returns {char[]} String with all replacements made
 *
 * @example
 * stack_var char text[50]
 * text = 'Hello World'
 * text = NAVFindAndReplace(text, 'o', 'X')  // Returns 'HellX WXrld'
 */
define_function char[NAV_MAX_BUFFER] NAVFindAndReplace(char buffer[], char match[], char value[]) {
    stack_var integer index
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer matchLength
    stack_var integer searchPos

    matchLength = length_array(match)

    if (!length_array(buffer) || !matchLength) {
        return buffer
    }

    result = buffer
    searchPos = 1  // Start searching from position 1

    if (!NAVContains(result, match)) {
        return result
    }

    while (true) {
        index = NAVIndexOf(result, match, searchPos)

        if (index == 0) {
            // No more matches found
            break
        }

        if (index == 1) {
            result = "value, right_string(result, length_array(result) - matchLength)"
            // Move search position past the replacement
            searchPos = length_array(value) + 1
            continue
        }

        result = "left_string(result, index - 1), value, right_string(result, (length_array(result) - (index + matchLength)) + 1)"
        // Move search position past the replacement - search from AFTER the replacement in the result string
        searchPos = (index - 1) + length_array(value) + 1
    }

    return result
}


/**
 * @function NAVStringReplace
 * @public
 * @description Alias for NAVFindAndReplace. Replaces all occurrences of a substring.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} match - Substring to find
 * @param {char[]} value - Replacement string
 *
 * @returns {char[]} String with all replacements made
 *
 * @see NAVFindAndReplace
 */
define_function char[NAV_MAX_BUFFER] NAVStringReplace(char buffer[], char match[], char value[]) {
    return NAVFindAndReplace(buffer, match, value)
}


/**
 * @function NAVStringNormalizeAndReplace
 * @public
 * @description Normalizes multiple consecutive occurrences of a substring to a single occurrence,
 * then replaces it with another string.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} match - Substring to normalize and replace
 * @param {char[]} replacement - Replacement string
 *
 * @returns {char[]} Normalized and replaced string
 *
 * @example
 * stack_var char text[50]
 * text = 'Hello  World'  // Note: double space
 * text = NAVStringNormalizeAndReplace(text, ' ', '-')  // Returns 'Hello-World'
 */
define_function char[NAV_MAX_BUFFER] NAVStringNormalizeAndReplace(char buffer[], char match[], char replacement[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var char doubleMatch[NAV_MAX_BUFFER]

    if (!length_array(buffer) || !length_array(match)) {
        return buffer
    }

    if (!NAVContains(buffer, match)) {
        return buffer
    }

    result = buffer
    doubleMatch = "match, match"

    while (NAVContains(result, doubleMatch)) {
        result = NAVStringReplace(result, doubleMatch, match)
    }

    result = NAVStringReplace(result, match, replacement)

    return result
}


/**
 * @function NAVStringCount
 * @public
 * @description Counts the number of occurrences of a substring in a string.
 *
 * @param {char[]} buffer - Input string to search in
 * @param {char[]} value - Substring to count
 * @param {integer} caseSensitivity - NAV_CASE_SENSITIVE or NAV_CASE_INSENSITIVE
 *
 * @returns {integer} Number of occurrences found
 *
 * @example
 * stack_var char text[50]
 * stack_var integer count
 * text = 'Hello World, hello universe'
 * count = NAVStringCount(text, 'hello', NAV_CASE_INSENSITIVE)  // Returns 2
 * count = NAVStringCount(text, 'hello', NAV_CASE_SENSITIVE)    // Returns 1
 */
define_function integer NAVStringCount(char buffer[], char value[], integer caseSensitivity) {
    stack_var integer index
    stack_var integer result
    stack_var char tempBuffer[65534]
    stack_var char tempValue[NAV_MAX_BUFFER]
    stack_var integer x

    result = 0

    if (!length_array(buffer) || !length_array(value)) {
        return result
    }

    tempBuffer = buffer
    tempValue = value

    if (caseSensitivity == NAV_CASE_INSENSITIVE) {
        tempBuffer = lower_string(tempBuffer)
        tempValue = lower_string(tempValue)
    }

    for (x = 1; x <= length_array(tempBuffer); x++) {
        index = NAVIndexOf(tempBuffer, tempValue, x)

        if (index == 0) {
            break
        }

        result++
        x = index + length_array(tempValue) - 1
    }

    return result
}


/**
 * @function NAVIsWhitespace
 * @public
 * @description Determines if a character is whitespace.
 *
 * @param {char} byte - Character to test
 *
 * @returns {char} True if the character is whitespace, false otherwise
 *
 * @example
 * stack_var char isSpace
 * isSpace = NAVIsWhitespace(' ')   // Returns true
 * isSpace = NAVIsWhitespace('A')   // Returns false
 *
 * @note Whitespace includes space, tab, CR, LF, VT, FF, and NULL
 */
define_function char NAVIsWhitespace(char byte) {
    return (
        (byte == NAV_NULL) ||
        (byte == NAV_TAB) ||
        (byte == NAV_LF)||
        (byte == NAV_VT) ||
        (byte == NAV_FF) ||
        (byte == NAV_CR) ||
        (byte == ' ')
    )
}


/**
 * @function NAVIsSpace
 * @public
 * @description Alias for NAVIsWhitespace. Determines if a character is whitespace.
 *
 * @param {char} byte - Character to test
 *
 * @returns {char} True if the character is whitespace, false otherwise
 *
 * @see NAVIsWhitespace
 */
define_function char NAVIsSpace(char byte) {
    return NAVIsWhitespace(byte)
}


/**
 * @function NAVIsAlpha
 * @public
 * @description Determines if a character is alphabetic (a-z or A-Z).
 *
 * @param {char} byte - Character to test
 *
 * @returns {char} True if the character is alphabetic, false otherwise
 *
 * @example
 * stack_var char isAlpha
 * isAlpha = NAVIsAlpha('A')   // Returns true
 * isAlpha = NAVIsAlpha('1')   // Returns false
 */
define_function char NAVIsAlpha(char byte) {
    return (
        ((byte >= 'a') && (byte <= 'z')) ||
        ((byte >= 'A') && (byte <= 'Z'))
    )
}


/**
 * @function NAVIsDigit
 * @public
 * @description Determines if a character is a digit (0-9).
 *
 * @param {char} byte - Character to test
 *
 * @returns {char} True if the character is a digit, false otherwise
 *
 * @example
 * stack_var char isDigit
 * isDigit = NAVIsDigit('5')   // Returns true
 * isDigit = NAVIsDigit('A')   // Returns false
 */
define_function char NAVIsDigit(char byte) {
    return ((byte >= '0') && (byte <= '9'))
}


/**
 * @function NAVIsAlphaNumeric
 * @public
 * @description Determines if a character is alphanumeric (a-z, A-Z, 0-9) or underscore.
 *
 * @param {char} byte - Character to test
 *
 * @returns {char} True if the character is alphanumeric or underscore, false otherwise
 *
 * @example
 * stack_var char isAlphaNum
 * isAlphaNum = NAVIsAlphaNumeric('A')   // Returns true
 * isAlphaNum = NAVIsAlphaNumeric('5')   // Returns true
 * isAlphaNum = NAVIsAlphaNumeric('_')   // Returns true
 * isAlphaNum = NAVIsAlphaNumeric('!')   // Returns false
 */
define_function char NAVIsAlphaNumeric(char byte) {
    return (
        NAVIsAlpha(byte) ||
        NAVIsDigit(byte) ||
        (byte == '_')
    )
}


/**
 * @function NAVIsHexDigit
 * @public
 * @description Determines if a character is a valid hexadecimal digit (0-9, A-F, a-f).
 *
 * @param {char} byte - Character to test
 *
 * @returns {char} True if the character is a valid hex digit, false otherwise
 *
 * @example
 * stack_var char isHex
 * isHex = NAVIsHexDigit('A')   // Returns true
 * isHex = NAVIsHexDigit('f')   // Returns true
 * isHex = NAVIsHexDigit('5')   // Returns true
 * isHex = NAVIsHexDigit('G')   // Returns false
 */
define_function char NAVIsHexDigit(char byte) {
    return (
        (byte >= '0' && byte <= '9') ||
        (byte >= 'A' && byte <= 'F') ||
        (byte >= 'a' && byte <= 'f')
    )
}


/**
 * @function NAVTrimStringLeft
 * @public
 * @description Removes all leading whitespace characters from a string.
 *
 * @param {char[]} buffer - Input string to trim
 *
 * @returns {char[]} String with leading whitespace removed
 *
 * @example
 * stack_var char text[50]
 * text = '   Hello World'
 * text = NAVTrimStringLeft(text)  // Returns 'Hello World'
 */
define_function char[NAV_MAX_BUFFER] NAVTrimStringLeft(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer count
    stack_var char byte

    result = buffer

    for (count = 1; count <= length_array(result); count++) {
        byte = NAVCharCodeAt(result, count)

        if (!NAVIsWhitespace(byte)) {
            break
        }
    }

    if(count > 1) {
        result = NAVStripCharsFromLeft(result, count - 1)
    }

    return result
}


/**
 * @function NAVTrimStringRight
 * @public
 * @description Removes all trailing whitespace characters from a string.
 *
 * @param {char[]} buffer - Input string to trim
 *
 * @returns {char[]} String with trailing whitespace removed
 *
 * @example
 * stack_var char text[50]
 * text = 'Hello World   '
 * text = NAVTrimStringRight(text)  // Returns 'Hello World'
 */
define_function char[NAV_MAX_BUFFER] NAVTrimStringRight(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer count
    stack_var char byte
    stack_var integer length

    result = buffer
    length = length_array(result)

    for (count = length; count >= 1; count--) {
        byte = NAVCharCodeAt(result, count)

        if (!NAVIsWhitespace(byte)) {
            break
        }
    }

    if(count < length) {
        result = NAVStripCharsFromRight(result, length - count)
    }

    return result
}


/**
 * @function NAVTrimString
 * @public
 * @description Removes all leading and trailing whitespace characters from a string.
 *
 * @param {char[]} buffer - Input string to trim
 *
 * @returns {char[]} String with leading and trailing whitespace removed
 *
 * @example
 * stack_var char text[50]
 * text = '   Hello World   '
 * text = NAVTrimString(text)  // Returns 'Hello World'
 */
define_function char[NAV_MAX_BUFFER] NAVTrimString(char buffer[]) {
    return NAVTrimStringLeft(NAVTrimStringRight(buffer))
}


/**
 * @function NAVTrimStringArray
 * @public
 * @description Trims all strings in an array, removing leading and trailing whitespace.
 *
 * @param {char[][]} array - Array of strings to trim (modified in place)
 *
 * @returns {void}
 *
 * @example
 * stack_var char texts[3][50]
 * texts[1] = '  Hello  '
 * texts[2] = ' World '
 * texts[3] = '  ! '
 * NAVTrimStringArray(texts)  // Modifies texts to ['Hello', 'World', '!']
 */
define_function NAVTrimStringArray(char array[][]) {
    stack_var integer length
    stack_var integer x

    length = length_array(array)

    for(x = 1; x <= length; x++) {
        array[x] = NAVTrimString(array[x])
    }
}


/**
 * @function NAVGetStringBefore
 * @public
 * @description Extracts the portion of a string that comes before a specified token.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} token - The token to search for
 *
 * @returns {char[]} Substring before the token, empty string if token is at the beginning, or the entire string if token not found
 *
 * @example
 * stack_var char text[50]
 * stack_var char result[50]
 * text = 'Hello World'
 * result = NAVGetStringBefore(text, ' ')  // Returns 'Hello'
 * result = NAVGetStringBefore(text, 'Hello')  // Returns ''
 */
define_function char[NAV_MAX_BUFFER] NAVGetStringBefore(char buffer[], char token[]) {
    stack_var integer index

    if (!length_array(buffer) || !length_array(token)) {
        return buffer
    }

    index = NAVIndexOf(buffer, token, 1)

    if (index == 0) {
        return buffer
    }

    if (index == 1) {
        return ''
    }

    return NAVStringSubstring(buffer, 1, index - 1)
}


/**
 * @function NAVStringBefore
 * @public
 * @description Alias for NAVGetStringBefore. Gets the substring before a token.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} token - The token to search for
 *
 * @returns {char[]} Substring before the token, or the entire string if token not found
 *
 * @see NAVGetStringBefore
 */
define_function char[NAV_MAX_BUFFER] NAVStringBefore(char buffer[], char token[]) {
    return NAVGetStringBefore(buffer, token)
}


/**
 * @function NAVGetStringAfter
 * @public
 * @description Extracts the portion of a string that comes after a specified token.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} token - The token to search for
 *
 * @returns {char[]} Substring after the token, or the entire string if token not found
 *
 * @example
 * stack_var char text[50]
 * stack_var char result[50]
 * text = 'Hello World'
 * result = NAVGetStringAfter(text, ' ')  // Returns 'World'
 */
define_function char[NAV_MAX_BUFFER] NAVGetStringAfter(char buffer[], char token[]) {
    stack_var integer index

    if (!length_array(buffer) || !length_array(token)) {
        return buffer
    }

    index = NAVIndexOf(buffer, token, 1)

    if (index == 0) {
        return buffer
    }

    return NAVStringSubstring(buffer, index + length_array(token), length_array(buffer))
}


/**
 * @function NAVStringAfter
 * @public
 * @description Alias for NAVGetStringAfter. Gets the substring after a token.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} token - The token to search for
 *
 * @returns {char[]} Substring after the token, or the entire string if token not found
 *
 * @see NAVGetStringAfter
 */
define_function char[NAV_MAX_BUFFER] NAVStringAfter(char buffer[], char token[]) {
    return NAVGetStringAfter(buffer, token)
}


/**
 * @function NAVGetStringBetween
 * @public
 * @description Extracts the portion of a string between two tokens.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} token1 - The starting token
 * @param {char[]} token2 - The ending token
 *
 * @returns {char[]} Substring between the tokens, or empty string if tokens not found
 *
 * @example
 * stack_var char text[50]
 * stack_var char result[50]
 * text = 'Hello [World] Goodbye'
 * result = NAVGetStringBetween(text, '[', ']')  // Returns 'World'
 */
define_function char[NAV_MAX_BUFFER] NAVGetStringBetween(char buffer[], char token1[], char token2[]) {
    stack_var integer tokenIndex[2]
    stack_var integer startIndex
    stack_var integer count

    if(!length_array(buffer)) {
        return ''
    }

    tokenIndex[1] = NAVIndexOf(buffer, token1, 1)

    if (!tokenIndex[1]) {
        return ''
    }

    startIndex = tokenIndex[1] + length_array(token1)
    tokenIndex[2] = NAVIndexOf(buffer, token2, startIndex)

    if (!tokenIndex[2]) {
        return ''
    }

    if (tokenIndex[1] >= tokenIndex[2]) {
        return ''
    }

    count = tokenIndex[2] - startIndex

    if (count <= 0) {
        return ''
    }

    return NAVStringSubstring(buffer, startIndex, count)
}


/**
 * @function NAVStringBetween
 * @public
 * @description Alias for NAVGetStringBetween. Gets the substring between two tokens.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} token1 - The starting token
 * @param {char[]} token2 - The ending token
 *
 * @returns {char[]} Substring between the tokens, or empty string if tokens not found
 *
 * @see NAVGetStringBetween
 */
define_function char[NAV_MAX_BUFFER] NAVStringBetween(char buffer[], char token1[], char token2[]) {
    return NAVGetStringBetween(buffer, token1, token2)
}


/**
 * @function NAVGetStringBetweenGreedy
 * @public
 * @description Extracts the portion of a string between the first occurrence of token1 and the last occurrence of token2.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} token1 - The starting token
 * @param {char[]} token2 - The ending token
 *
 * @returns {char[]} Substring between the tokens, or empty string if tokens not found
 *
 * @example
 * stack_var char text[70]
 * stack_var char result[50]
 * text = 'Hello [World] and [Universe]'
 * result = NAVGetStringBetweenGreedy(text, '[', ']')  // Returns 'World] and [Universe'
 *
 * @note This is a "greedy" match, capturing everything between the first token1 and the last token2
 */
define_function char[NAV_MAX_BUFFER] NAVGetStringBetweenGreedy(char buffer[], char token1[], char token2[]) {
    stack_var integer tokenIndex[2]
    stack_var integer startIndex
    stack_var integer count

    if(!length_array(buffer)) {
        return ''
    }

    tokenIndex[1] = NAVIndexOf(buffer, token1, 1)

    if (!tokenIndex[1]) {
        return ''
    }

    startIndex = tokenIndex[1] + length_array(token1)
    tokenIndex[2] = NAVLastIndexOf(buffer, token2)

    if (!tokenIndex[2]) {
        return ''
    }

    if (tokenIndex[1] >= tokenIndex[2]) {
        return ''
    }

    count = tokenIndex[2] - startIndex

    if (count <= 0) {
        return ''
    }

    return NAVStringSubstring(buffer, startIndex, count)
}


/**
 * @function NAVStringBetweenGreedy
 * @public
 * @description Alias for NAVGetStringBetweenGreedy. Gets the substring between first token1 and last token2.
 *
 * @param {char[]} buffer - Input string
 * @param {char[]} token1 - The starting token
 * @param {char[]} token2 - The ending token
 *
 * @returns {char[]} Substring between the tokens, or empty string if tokens not found
 *
 * @see NAVGetStringBetweenGreedy
 */
define_function char[NAV_MAX_BUFFER] NAVStringBetweenGreedy(char buffer[], char token1[], char token2[]) {
    return NAVGetStringBetweenGreedy(buffer, token1, token2)
}


/**
 * @function NAVStartsWith
 * @public
 * @description Determines whether a string begins with a specified substring.
 *
 * @param {char[]} buffer - String to check
 * @param {char[]} match - The prefix to search for
 *
 * @returns {char} True if the string starts with the prefix, false otherwise
 *
 * @example
 * stack_var char text[50]
 * stack_var char result
 * text = 'Hello World'
 * result = NAVStartsWith(text, 'Hello')  // Returns true
 * result = NAVStartsWith(text, 'World')  // Returns false
 */
define_function char NAVStartsWith(char buffer[], char match[]) {
    if (!length_array(match)) {
        return true
    }

    return (find_string(buffer, match, 1) == 1)
}


/**
 * @function NAVStringStartsWith
 * @public
 * @description Alias for NAVStartsWith. Checks if a string starts with a substring.
 *
 * @param {char[]} buffer - String to check
 * @param {char[]} match - The prefix to search for
 *
 * @returns {char} True if the string starts with the prefix, false otherwise
 *
 * @see NAVStartsWith
 */
define_function char NAVStringStartsWith(char buffer[], char match[]) {
    return NAVStartsWith(buffer, match)
}


/**
 * @function NAVContains
 * @public
 * @description Determines whether a string contains a specified substring.
 *
 * @param {char[]} buffer - String to check
 * @param {char[]} match - The substring to search for
 *
 * @returns {char} True if the string contains the substring, false otherwise
 *
 * @example
 * stack_var char text[50]
 * stack_var char result
 * text = 'Hello World'
 * result = NAVContains(text, 'World')  // Returns true
 * result = NAVContains(text, 'Moon')   // Returns false
 */
define_function char NAVContains(char buffer[], char match[]) {
    if (!length_array(match)) {
        return true
    }

    return (find_string(buffer, match, 1) > 0)
}


/**
 * @function NAVStringContains
 * @public
 * @description Alias for NAVContains. Checks if a string contains a substring.
 *
 * @param {char[]} buffer - String to check
 * @param {char[]} match - The substring to search for
 *
 * @returns {char} True if the string contains the substring, false otherwise
 *
 * @see NAVContains
 */
define_function char NAVStringContains(char buffer[], char match[]) {
    return NAVContains(buffer, match)
}


/**
 * @function NAVContainsCaseInsensitive
 * @public
 * @description Determines whether a string contains a specified substring, case-insensitively.
 *
 * @param {char[]} buffer - String to check
 * @param {char[]} match - The substring to search for
 *
 * @returns {char} True if the string contains the substring (case-insensitive), false otherwise
 *
 * @example
 * stack_var char text[50]
 * stack_var char result
 * text = 'Hello World'
 * result = NAVContainsCaseInsensitive(text, 'world')  // Returns true
 * result = NAVContainsCaseInsensitive(text, 'HELLO')  // Returns true
 * result = NAVContainsCaseInsensitive(text, 'Moon')   // Returns false
 */
define_function char NAVContainsCaseInsensitive(char buffer[], char match[]) {
    if (!length_array(match)) {
        return true
    }

    return (NAVIndexOfCaseInsensitive(buffer, match, 1) > 0)
}


/**
 * @function NAVStringContainsCaseInsensitive
 * @public
 * @description Alias for NAVContainsCaseInsensitive. Checks if a string contains a substring, case-insensitively.
 *
 * @param {char[]} buffer - String to check
 * @param {char[]} match - The substring to search for
 *
 * @returns {char} True if the string contains the substring (case-insensitive), false otherwise
 *
 * @see NAVContainsCaseInsensitive
 */
define_function char NAVStringContainsCaseInsensitive(char buffer[], char match[]) {
    return NAVContainsCaseInsensitive(buffer, match)
}


/**
 * @function NAVEndsWith
 * @public
 * @description Determines whether a string ends with a specified substring.
 *
 * @param {char[]} buffer - String to check
 * @param {char[]} match - The suffix to search for
 *
 * @returns {char} True if the string ends with the suffix, false otherwise
 *
 * @example
 * stack_var char text[50]
 * stack_var char result
 * text = 'Hello World'
 * result = NAVEndsWith(text, 'World')  // Returns true
 * result = NAVEndsWith(text, 'Hello')  // Returns false
 */
define_function char NAVEndsWith(char buffer[], char match[]) {
    return right_string(buffer, length_array(match)) == match
}


/**
 * @function NAVStringEndsWith
 * @public
 * @description Alias for NAVEndsWith. Checks if a string ends with a substring.
 *
 * @param {char[]} buffer - String to check
 * @param {char[]} match - The suffix to search for
 *
 * @returns {char} True if the string ends with the suffix, false otherwise
 *
 * @see NAVEndsWith
 */
define_function char NAVStringEndsWith(char buffer[], char match[]) {
    return NAVEndsWith(buffer, match)
}


/**
 * @function NAVIndexOf
 * @public
 * @description Finds the position of the first occurrence of a substring in a string, starting at a specified position.
 *
 * @param {char[]} buffer - String to search within
 * @param {char[]} match - Substring to search for
 * @param {integer} start - Position to start searching from (1-based index)
 *
 * @returns {integer} Position of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var char text[50]
 * stack_var integer position
 * text = 'Hello World'
 * position = NAVIndexOf(text, 'o', 1)  // Returns 5 (position of first 'o')
 * position = NAVIndexOf(text, 'o', 6)  // Returns 8 (position of second 'o')
 */
define_function integer NAVIndexOf(char buffer[], char match[], integer start) {
    if (start <= 0 || start > length_array(buffer)) {
        return 0
    }

    return find_string(buffer, match, start)
}


/**
 * @function NAVIndexOfCaseInsensitive
 * @public
 * @description Finds the position of the first occurrence of a substring in a string, case-insensitively, starting at a specified position.
 *
 * @param {char[]} buffer - String to search within
 * @param {char[]} match - Substring to search for
 * @param {integer} start - Position to start searching from (1-based index)
 *
 * @returns {integer} Position of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var char text[50]
 * stack_var integer position
 * text = 'Hello World'
 * position = NAVIndexOfCaseInsensitive(text, 'o', 1)  // Returns 5 (position of first 'o')
 * position = NAVIndexOfCaseInsensitive(text, 'O', 6)  // Returns 8 (position of second 'o', case-insensitive)
 */
define_function integer NAVIndexOfCaseInsensitive(char buffer[], char match[], integer start) {
    return NAVIndexOf(lower_string(buffer), lower_string(match), start)
}


/**
 * @function NAVLastIndexOf
 * @public
 * @description Finds the position of the last occurrence of a substring in a string.
 *
 * @param {char[]} buffer - String to search within
 * @param {char[]} match - Substring to search for
 *
 * @returns {integer} Position of the last occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var char text[50]
 * stack_var integer position
 * text = 'Hello World'
 * position = NAVLastIndexOf(text, 'o')  // Returns 8 (position of last 'o')
 */
define_function integer NAVLastIndexOf(char buffer[], char match[]) {
    stack_var integer index
    stack_var integer next

    index = NAVIndexOf(buffer, match, 1)

    if (!index) {
        return 0
    }

    while (index > 0) {
        next = NAVIndexOf(buffer, match, index + 1)

        if (!next) {
            break
        }

        index = next
    }

    return index
}


/**
 * @function NAVLastIndexOfCaseInsensitive
 * @public
 * @description Finds the position of the last occurrence of a substring in a string, case-insensitively.
 *
 * @param {char[]} buffer - String to search within
 * @param {char[]} match - Substring to search for
 *
 * @returns {integer} Position of the last occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var char text[50]
 * stack_var integer position
 * text = 'Hello World'
 * position = NAVLastIndexOfCaseInsensitive(text, 'O')  // Returns 8 (position of last 'o', case-insensitive)
 */
define_function integer NAVLastIndexOfCaseInsensitive(char buffer[], char match[]) {
    stack_var integer index
    stack_var integer next

    index = NAVIndexOfCaseInsensitive(buffer, match, 1)

    if (!index) {
        return 0
    }

    while (index > 0) {
        next = NAVIndexOfCaseInsensitive(buffer, match, index + 1)

        if (!next) {
            break
        }

        index = next
    }

    return index
}


/**
 * @function NAVSplitString
 * @public
 * @description Splits a string into an array of substrings based on a specified separator.
 *
 * @param {char[]} buffer - String to split
 * @param {char[]} separator - Separator to split on (defaults to space if empty)
 * @param {char[][]} result - Array to store the resulting substrings
 *
 * @returns {integer} Number of substrings created
 *
 * @example
 * stack_var char text[50]
 * stack_var char parts[10][20]
 * stack_var integer count
 * text = 'Hello,World,How,Are,You'
 * count = NAVSplitString(text, ',', parts)  // parts contains ['Hello', 'World', 'How', 'Are', 'You'], count = 5
 */
define_function integer NAVSplitString(char buffer[], char separator[], char result[][]) {
    stack_var char bufferCopy[NAV_MAX_BUFFER]
    stack_var integer count
    stack_var char token[NAV_MAX_BUFFER]

    count = 0

    if (!length_array(buffer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVSplitString',
                                    'Invalid argument. The provided argument "buffer" is an empty string')

        return count
    }

    if (!length_array(separator)) {
        separator = ' '
    }

    if (!NAVContains(buffer, separator)) {
        count++
        set_length_array(result, count)
        result[count] = buffer
        return count
    }

    bufferCopy = buffer

    while (NAVContains(bufferCopy, separator)) {
        token = NAVStripRight(remove_string(bufferCopy, separator, 1), length_array(separator))

        count++
        result[count] = token
    }

    // Always add the remaining buffer (even if empty, for trailing separators)
    count++
    result[count] = bufferCopy
    set_length_array(result, count)

    return count
}


/**
 * @function NAVArrayJoinString
 * @public
 * @description Joins an array of strings into a single string using a specified separator.
 *
 * @param {char[][]} array - Array of strings to join
 * @param {char[]} separator - String to use as separator between elements
 *
 * @returns {char[]} Joined string
 *
 * @example
 * stack_var char words[3][10]
 * stack_var char result[50]
 * words[1] = 'Hello'
 * words[2] = 'World'
 * words[3] = '!'
 * result = NAVArrayJoinString(words, ' ')  // Returns 'Hello World !'
 */
define_function char[NAV_MAX_BUFFER] NAVArrayJoinString(char array[][], char separator[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x

    result = ""

    length = length_array(array)

    if (!length) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVArrayJoinString',
                                    'Invalid argument. The provided argument "array" is empty array')

        return result
    }

    result = array[1]

    for (x = 2; x <= length; x++) {
        result = "result, separator, array[x]"
    }

    return result
}


/**
 * @function NAVStringToLongMilliseconds
 * @public
 * @description Converts a duration string with time unit suffix (h/m/s) to milliseconds.
 *
 * @param {char[]} duration - Duration string (e.g., '1h', '30m', '45s')
 *
 * @returns {long} Duration in milliseconds
 *
 * @example
 * stack_var long ms
 * ms = NAVStringToLongMilliseconds('1h')   // Returns 3600000
 * ms = NAVStringToLongMilliseconds('30m')  // Returns 1800000
 * ms = NAVStringToLongMilliseconds('45s')  // Returns 45000
 */
define_function long NAVStringToLongMilliseconds(char duration[]) {
    stack_var long result
    stack_var char timeFormat[1]
    stack_var integer value
    stack_var char durationCopy[NAV_MAX_CHARS]

    result = 0
    if (!length_array(duration)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVStringToLongMilliseconds',
                                    'Invalid argument. The provided argument "duration" is an empty string')

        return result
    }

    durationCopy = duration
    timeFormat = right_string(durationCopy, 1)
    durationCopy = NAVStripCharsFromRight(durationCopy, 1)

    value = atoi(durationCopy);

    switch (lower_string(timeFormat)) {
        case 'h': {
            result = value * 3600000
        }
        case 'm': {
            result = value * 60000
        }
        case 's': {
            result = value * 1000
        }
        default: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_STRINGUTILS__,
                                        'NAVStringToLongMilliseconds',
                                        "'An invalid format (', timeFormat, ') was specified. Valid format is hours (H/h), minutes (M/m), or seconds (S/s)'")
        }
    }

    return result
}


/**
 * @function NAVParseInteger
 * @public
 * @description Parses a string representation of an unsigned integer.
 *
 * Uses ATOI internally to parse the string. Validates that the parsed value
 * is within the valid NetLinx integer range (0-65535). Parses the first valid
 * number and stops at whitespace or non-digit characters after it.
 *
 * @param {char[]} data - The string to parse as an unsigned integer
 * @param {integer} result - Variable to populate with the parsed integer value
 *
 * @returns {char} true if parsing succeeded and value is in valid range, false otherwise
 *
 * @example
 * stack_var integer value
 * stack_var char result
 * result = NAVParseInteger('12345', value)
 * if (result) {
 *     // value = 12345
 * }
 *
 * result = NAVParseInteger('99999', value)     // Returns false (out of range)
 * result = NAVParseInteger('-100', value)      // Returns false (negative)
 * result = NAVParseInteger('Volume=50', value) // value = 50 (ATOF extracts first number)
 */
define_function char NAVParseInteger(char data[], integer result) {
    stack_var slong tempValue
    stack_var integer x
    stack_var integer length
    stack_var char hasDigit

    // Initialize result
    result = 0

    // Validate non-empty input
    if (!length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseInteger',
                                    'Invalid argument. The provided string is empty')
        return false
    }

    // Verify the string contains at least one digit
    // ATOI returns 0 if no valid numeric characters are found
    length = length_array(data)
    hasDigit = false

    for (x = 1; x <= length; x++) {
        if (NAVIsDigit(data[x])) {
            hasDigit = true
            break
        }
    }

    if (!hasDigit) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseInteger',
                                    "'No numeric characters found in string: ', data")
        return false
    }

    // Parse using ATOI (returns slong, ignores non-numeric characters)
    tempValue = atoi(data)

    // Validate range for unsigned integer (0-65535)
    if (tempValue < 0 || tempValue > 65535) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseInteger',
                                    "'Value out of range (0-65535): ', itoa(tempValue)")
        return false
    }

    // Success - set the result
    result = type_cast(tempValue)
    return true
}


/**
 * @function NAVParseSignedInteger
 * @public
 * @description Parses a string representation of a signed integer.
 *
 * Uses ATOI internally to parse the string. Validates that the parsed value
 * is within the valid NetLinx signed integer range (-32768 to 32767). Parses
 * the first valid number and stops at whitespace or non-digit characters after it.
 *
 * @param {char[]} data - The string to parse as a signed integer
 * @param {sinteger} result - Variable to populate with the parsed signed integer value
 *
 * @returns {char} true if parsing succeeded and value is in valid range, false otherwise
 *
 * @example
 * stack_var sinteger value
 * stack_var char result
 * result = NAVParseSignedInteger('-12345', value)
 * if (result) {
 *     // value = -12345
 * }
 *
 * result = NAVParseSignedInteger('50000', value) // Returns false (out of range)
 */
define_function char NAVParseSignedInteger(char data[], sinteger result) {
    stack_var slong tempValue
    stack_var integer x
    stack_var integer length
    stack_var char hasDigit

    // Initialize result
    result = 0

    // Validate non-empty input
    if (!length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseSignedInteger',
                                    'Invalid argument. The provided string is empty')
        return false
    }

    // Verify the string contains at least one digit
    // ATOI returns 0 if no valid numeric characters are found
    length = length_array(data)
    hasDigit = false

    for (x = 1; x <= length; x++) {
        if (NAVIsDigit(data[x])) {
            hasDigit = true
            break
        }
    }

    if (!hasDigit) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseSignedInteger',
                                    "'No numeric characters found in string: ', data")
        return false
    }

    // Parse using ATOI (returns slong, ignores non-numeric characters)
    tempValue = atoi(data)

    // Validate range for signed integer (-32768 to 32767)
    if (tempValue < -32768 || tempValue > 32767) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseSignedInteger',
                                    "'Value out of range (-32768 to 32767): ', itoa(tempValue)")
        return false
    }

    // Success - set the result
    result = type_cast(tempValue)
    return true
}


/**
 * @function NAVParseLong
 * @public
 * @description Parses a string representation of an unsigned long integer.
 *
 * Uses manual digit-by-digit parsing to handle the full LONG range (0 to 4294967295).
 * ATOI cannot be used because it returns SLONG, which maxes out at 2,147,483,647,
 * preventing proper parsing of values above that limit. Parses the first valid number
 * and stops at whitespace or non-digit characters after it (matching ATOI behavior).
 *
 * @param {char[]} data - The string to parse as an unsigned long
 * @param {long} result - Variable to populate with the parsed long value
 *
 * @returns {char} true if parsing succeeded and value is in valid range, false otherwise
 *
 * @example
 * stack_var long value
 * stack_var char result
 * result = NAVParseLong('1234567890', value)
 * if (result) {
 *     // value = 1234567890
 * }
 *
 * result = NAVParseLong('-100', value) // Returns false (negative)
 *
 * @note Manual parsing is required because ATOI returns SLONG (max 2,147,483,647),
 *       which cannot represent the full LONG range (0-4,294,967,295).
 */
define_function char NAVParseLong(char data[], long result) {
    stack_var long accumulator
    stack_var integer x
    stack_var integer length
    stack_var char hasDigit
    stack_var integer digit
    stack_var char foundNumber
    stack_var char isNegative

    // Initialize result
    result = 0
    accumulator = 0
    hasDigit = false
    foundNumber = false
    isNegative = false

    // Validate non-empty input
    if (!length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseLong',
                                    'Invalid argument. The provided string is empty')
        return false
    }

    length = length_array(data)

    // Manual digit-by-digit parsing to handle full LONG range (0 to 4294967295)
    for (x = 1; x <= length; x++) {
        select {
            active (NAVIsDigit(data[x])): {
                hasDigit = true
                foundNumber = true
                digit = data[x] - '0'

                // Check for overflow before multiplying
                // Max LONG is 4294967295, so if accumulator > 429496729, multiplication will overflow
                if (accumulator > 429496729) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_STRINGUTILS__,
                                                'NAVParseLong',
                                                "'Value out of range (0 to 4294967295): ', data")
                    return false
                }

                // Special case: if accumulator == 429496729, check if adding digit would exceed 4294967295
                if (accumulator == 429496729 && digit > 5) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_STRINGUTILS__,
                                                'NAVParseLong',
                                                "'Value out of range (0 to 4294967295): ', data")
                    return false
                }

                accumulator = accumulator * 10 + digit
            }
            active (data[x] == '-' && !foundNumber): {
                // Found negative sign before any digits
                isNegative = true
            }
            active (foundNumber): {
                // Stop parsing after we've found digits and hit a non-digit character
                // This matches ATOI behavior: '   100  200' -> 100
                break
            }
            active (true): {
                // Skip leading non-digit characters (whitespace, letters, etc.)
            }
        }
    }

    if (!hasDigit) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseLong',
                                    "'No numeric characters found in string: ', data")
        return false
    }

    // LONG is unsigned, reject negative values
    if (isNegative) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseLong',
                                    "'Value out of range (0 to 4294967295): ', data")
        return false
    }

    // Success - set the result
    result = accumulator
    return true
}


/**
 * @function NAVParseSignedLong
 * @public
 * @description Parses a string representation of a signed long integer.
 *
 * Uses manual digit-by-digit parsing to properly validate the full SLONG range
 * (-2147483648 to 2147483647) and detect overflow/underflow conditions.
 * ATOI cannot be used because it silently clamps out-of-range values to the
 * SLONG min/max instead of reporting an error, preventing proper validation.
 * Parses the first valid number and stops at whitespace or non-digit characters
 * after it (matching ATOI behavior).
 *
 * @param {char[]} data - The string to parse as a signed long
 * @param {slong} result - Variable to populate with the parsed signed long value
 *
 * @returns {char} true if parsing succeeded and value is in valid range, false otherwise
 *
 * @example
 * stack_var slong value
 * stack_var char result
 * result = NAVParseSignedLong('-1234567890', value)
 * if (result) {
 *     // value = -1234567890
 * }
 *
 * result = NAVParseSignedLong('3000000000', value) // Returns false (out of range)
 *
 * @note Manual parsing is required because ATOI silently clamps overflow values
 *       (e.g., '3000000000' returns 2,147,483,647 without error), preventing
 *       proper detection of out-of-range inputs.
 */
define_function char NAVParseSignedLong(char data[], slong result) {
    stack_var slong accumulator
    stack_var integer x
    stack_var integer length
    stack_var char hasDigit
    stack_var integer digit
    stack_var char foundNumber
    stack_var char isNegative

    // Initialize result
    result = 0
    accumulator = 0
    hasDigit = false
    foundNumber = false
    isNegative = false

    // Validate non-empty input
    if (!length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseSignedLong',
                                    'Invalid argument. The provided string is empty')
        return false
    }

    length = length_array(data)

    // Manual digit-by-digit parsing to handle full SLONG range (-2147483648 to 2147483647)
    for (x = 1; x <= length; x++) {
        select {
            active (NAVIsDigit(data[x])): {
                hasDigit = true
                foundNumber = true
                digit = data[x] - '0'

                if (isNegative) {
                    // For negative numbers, check underflow
                    // Min SLONG is -2147483648, so if accumulator < -214748364, multiplication will underflow
                    if (accumulator < -214748364) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_STRINGUTILS__,
                                                    'NAVParseSignedLong',
                                                    "'Value out of range (-2147483648 to 2147483647): ', data")
                        return false
                    }

                    // Special case: if accumulator == -214748364, check if subtracting digit would go below -2147483648
                    if (accumulator == -214748364 && digit > 8) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_STRINGUTILS__,
                                                    'NAVParseSignedLong',
                                                    "'Value out of range (-2147483648 to 2147483647): ', data")
                        return false
                    }

                    accumulator = accumulator * 10 - digit
                }
                else {
                    // For positive numbers, check overflow
                    // Max SLONG is 2147483647, so if accumulator > 214748364, multiplication will overflow
                    if (accumulator > 214748364) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_STRINGUTILS__,
                                                    'NAVParseSignedLong',
                                                    "'Value out of range (-2147483648 to 2147483647): ', data")
                        return false
                    }

                    // Special case: if accumulator == 214748364, check if adding digit would exceed 2147483647
                    if (accumulator == 214748364 && digit > 7) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_STRINGUTILS__,
                                                    'NAVParseSignedLong',
                                                    "'Value out of range (-2147483648 to 2147483647): ', data")
                        return false
                    }

                    accumulator = accumulator * 10 + digit
                }
            }
            active (data[x] == '-' && !foundNumber): {
                // Found negative sign before any digits
                isNegative = true
            }
            active (data[x] == '+' && !foundNumber): {
                // Found positive sign before any digits (explicit positive)
                // Do nothing, already positive by default
            }
            active (foundNumber): {
                // Stop parsing after we've found digits and hit a non-digit character
                // This matches ATOI behavior: '   -100  200' -> -100
                break
            }
            active (true): {
                // Skip leading non-digit characters (whitespace, letters, etc.)
            }
        }
    }

    if (!hasDigit) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseSignedLong',
                                    "'No numeric characters found in string: ', data")
        return false
    }

    // Success - set the result
    result = accumulator
    return true
}


/**
 * @function NAVParseFloat
 * @public
 * @description Parses a string representation of a floating-point number.
 *
 * Uses ATOF internally to parse the string. Accepts standard floating-point
 * notation including decimal points and scientific notation (e.g., "1.25e-3").
 * Parses the first valid number and stops at whitespace or non-digit characters
 * after it (matching ATOF behavior).
 *
 * @param {char[]} data - The string to parse as a float
 * @param {float} result - Variable to populate with the parsed float value
 *
 * @returns {char} true if parsing succeeded, false otherwise
 *
 * @example
 * stack_var float value
 * stack_var char result
 * result = NAVParseFloat('3.14159', value)
 * if (result) {
 *     // value = 3.14159
 * }
 *
 * result = NAVParseFloat('-1.25e-3', value) // value = -0.00125
 * result = NAVParseFloat('Temp=22.5', value) // value = 22.5 (extracts first number)
 */
define_function char NAVParseFloat(char data[], float result) {
    stack_var integer x
    stack_var integer length
    stack_var char hasDigit

    // Initialize result
    result = 0

    // Validate non-empty input
    if (!length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseFloat',
                                    'Invalid argument. The provided string is empty')
        return false
    }

    // Verify the string contains at least one digit
    // ATOF returns 0.0 if no valid numeric characters are found
    length = length_array(data)
    hasDigit = false

    for (x = 1; x <= length; x++) {
        if (NAVIsDigit(data[x])) {
            hasDigit = true
            break
        }
    }

    if (!hasDigit) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseFloat',
                                    "'No numeric characters found in string: ', data")
        return false
    }

    // Parse using ATOF (returns float, ignores non-numeric characters)
    result = atof(data)

    // Success
    return true
}


/**
 * @function NAVParseBoolean
 * @public
 * @description Parses and validates a string representation of a boolean value.
 *
 * Recognizes multiple boolean representations (case-insensitive):
 * - True values: "1", "true", "yes", "on"
 * - False values: "0", "false", "no", "off"
 *
 * This function validates that the input string is one of the recognized
 * boolean representations before parsing. Unlike NAVStringToBoolean which
 * defaults unrecognized values to false, this function returns false to
 * indicate parsing failure.
 *
 * @param {char[]} data - String to parse and validate
 * @param {char} result - Variable to populate with the parsed boolean value
 *
 * @returns {char} true if parsing succeeded (valid boolean string), false otherwise
 *
 * @example
 * stack_var char value
 * stack_var char result
 * result = NAVParseBoolean('true', value)    // Returns true, value = true
 * result = NAVParseBoolean('off', value)     // Returns true, value = false
 * result = NAVParseBoolean('invalid', value) // Returns false (not recognized)
 * result = NAVParseBoolean('yes', value)     // Returns true, value = true
 *
 * @see NAVStringToBoolean
 */
define_function char NAVParseBoolean(char data[], char result) {
    stack_var char normalized[NAV_MAX_BUFFER]

    // Initialize result
    result = false

    // Validate non-empty input
    if (!length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVParseBoolean',
                                    'Invalid argument. The provided string is empty')
        return false
    }

    // Normalize to lowercase for comparison
    normalized = lower_string(data)

    // Validate it's a recognized boolean value
    if (normalized == '1' || normalized == 'true' || normalized == 'yes' || normalized == 'on') {
        result = true
        return true
    }

    if (normalized == '0' || normalized == 'false' || normalized == 'no' || normalized == 'off') {
        result = false
        return true
    }

    // Not a recognized boolean value
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                __NAV_FOUNDATION_STRINGUTILS__,
                                'NAVParseBoolean',
                                "'Invalid boolean value: ', data, ' (expected: 1, true, yes, on, 0, false, no, off)'")
    return false
}


/**
 * @function NAVGetTimeSpan
 * @public
 * @description Converts a duration in milliseconds to a human-readable time span string.
 *
 * @param {double} value - Duration in milliseconds
 *
 * @returns {char[]} Human-readable time span string
 *
 * @example
 * stack_var char result[50]
 * result = NAVGetTimeSpan(3600000)  // Returns '1h 0s 0ms'
 * result = NAVGetTimeSpan(45000)    // Returns '45s 0ms'
 */
define_function char[NAV_MAX_BUFFER] NAVGetTimeSpan(double value) {
    stack_var long milliseconds
    stack_var long seconds
    stack_var long minutes
    stack_var long hours
    stack_var long years
    stack_var long months
    stack_var long days
    stack_var char result[NAV_MAX_BUFFER]

    milliseconds = type_cast(value % 1000)
    seconds = type_cast(value / 1000 % 60)
    minutes = type_cast(value / 60000 % 60)
    hours = type_cast(value / 3600000 % 24)
    days = type_cast(value / 86400000 % 30)
    months = type_cast(value / 2629746000 % 12)
    years = type_cast(value / 31556952000)

    result = "itoa(seconds), 's ', itoa(milliseconds), 'ms'"

    if (minutes > 0) {
        result = "itoa(minutes), 'm ', result"
    }

    if (hours > 0) {
        result = "itoa(hours), 'h ', result"
    }

    if (days > 0) {
        result = "itoa(days), 'd ', result"
    }

    if (months > 0) {
        result = "itoa(months), 'mo ', result"
    }

    if (years > 0) {
        result = "itoa(years), 'y ', result"
    }

    return result
}


/**
 * @function NAVStringCompare
 * @public
 * @description Compares two strings lexicographically.
 *
 * @param {char[]} string1 - First string to compare
 * @param {char[]} string2 - Second string to compare
 *
 * @returns {sinteger} Negative if string1 < string2, 0 if string1 == string2, positive if string1 > string2
 *
 * @example
 * stack_var sinteger result
 * result = NAVStringCompare('apple', 'banana')  // Returns negative value
 * result = NAVStringCompare('apple', 'apple')   // Returns 0
 * result = NAVStringCompare('banana', 'apple')  // Returns positive value
 */
define_function sinteger NAVStringCompare(char string1[], char string2[]) {
    stack_var integer x

    x = 1
    while (x <= length_array(string1)) {
        if (string1[x] != string2[x]) {
            break
        }

        x++
    }

    return string1[x] - string2[x]
}


/**
 * @function NAVStringSurroundWith
 * @public
 * @description Surrounds a string with specified left and right strings.
 *
 * @param {char[]} buffer - Input string to surround
 * @param {char[]} left - String to add to the left
 * @param {char[]} right - String to add to the right
 *
 * @returns {char[]} Surrounded string
 *
 * @example
 * stack_var char text[50]
 * stack_var char result[50]
 * text = 'World'
 * result = NAVStringSurroundWith(text, 'Hello ', '!')  // Returns 'Hello World!'
 */
define_function char[NAV_MAX_BUFFER] NAVStringSurroundWith(char buffer[], char left[], char right[]) {
    return "left, buffer, right"
}


/**
 * @function NAVStringSurround
 * @public
 * @description Alias for NAVStringSurroundWith. Surrounds a string with specified left and right strings.
 *
 * @param {char[]} buffer - Input string to surround
 * @param {char[]} left - String to add to the left
 * @param {char[]} right - String to add to the right
 *
 * @returns {char[]} Surrounded string
 *
 * @see NAVStringSurroundWith
 */
define_function char[NAV_MAX_BUFFER] NAVStringSurround(char buffer[], char left[], char right[]) {
    return "left, buffer, right"
}


/**
 * @function NAVStringGather
 * @public
 * @description Gathers strings from a buffer based on a delimiter and processes them using a callback.
 *
 * @param {_NAVRxBuffer} buffer - Buffer containing the data
 * @param {char[]} delimiter - Delimiter to split the data
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVRxBuffer buffer
 * buffer.Data = 'Hello,World,How,Are,You'
 * NAVStringGather(buffer, ',')  // Processes each word separately
 */
define_function NAVStringGather(_NAVRxBuffer buffer, char delimiter[]) {
    stack_var char data[NAV_MAX_BUFFER]

    if (buffer.Semaphore) {
        return
    }

    buffer.Semaphore = true

    while (length_array(buffer.Data) && NAVContains(buffer.Data, delimiter)) {
        data = remove_string(buffer.Data, delimiter, 1)

        if (!length_array(data)) {
            continue
        }

        #IF_DEFINED USING_NAV_STRING_GATHER_CALLBACK
        {
            stack_var _NAVStringGatherResult result

            result.Data = data
            result.Delimiter = delimiter

            NAVStringGatherCallback(result)
        }
        #END_IF
    }

    buffer.Semaphore = false
}


/**
 * @function NAVStringCapitalize
 * @public
 * @description Capitalizes the first letter of each word in a string.
 *
 * @param {char[]} buffer - Input string to capitalize
 *
 * @returns {char[]} Capitalized string
 *
 * @example
 * stack_var char text[50]
 * text = 'hello world'
 * text = NAVStringCapitalize(text)  // Returns 'Hello World'
 */
define_function char[NAV_MAX_BUFFER] NAVStringCapitalize(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var char byte

    result = buffer
    length = length_array(result)

    if (!length) {
        return result
    }

    if (NAVIsLowerCase(result[1])) {
        result[1] = result[1] - 32
    }

    for (x = 2; x <= length; x++) {
        byte = result[x]

        if (byte != $20) {
            continue
        }

        if (x + 1 <= length && NAVIsLowerCase(result[x + 1])) {
            result[x + 1] = result[x + 1] - 32
        }
    }

    return result
}


/**
 * @function NAVStringPascalCase
 * @public
 * @description Converts a string to PascalCase.
 *
 * @param {char[]} buffer - Input string to convert
 *
 * @returns {char[]} PascalCase string
 *
 * @example
 * stack_var char text[50]
 * text = 'hello world'
 * text = NAVStringPascalCase(text)  // Returns 'HelloWorld'
 */
define_function char[NAV_MAX_BUFFER] NAVStringPascalCase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var char newWord

    result = NAVInsertSpacesBeforeUppercase(buffer)
    result = NAVStringReplace(result, '-', ' ')
    result = NAVStringReplace(result, '_', ' ')
    result = NAVStringReplace(result, '.', ' ')

    while (NAVContains(result, '  ')) {
        result = NAVStringReplace(result, '  ', ' ')
    }

    length = length_array(result)
    newWord = true

    for (x = 1; x <= length; x++) {
        if (result[x] == ' ') {
            newWord = true
            continue
        }

        if (newWord && NAVIsLowerCase(result[x])) {
            result[x] = NAVCharToUpper(result[x])
            newWord = false
        }
    }

    result = NAVStringReplace(result, ' ', '')

    return result
}


/**
 * @function NAVStringCamelCase
 * @public
 * @description Converts a string to camelCase.
 *
 * @param {char[]} buffer - Input string to convert
 *
 * @returns {char[]} camelCase string
 *
 * @example
 * stack_var char text[50]
 * text = 'hello world'
 * text = NAVStringCamelCase(text)  // Returns 'helloWorld'
 */
define_function char[NAV_MAX_BUFFER] NAVStringCamelCase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]

    result = NAVStringPascalCase(buffer)

    if (length_array(result)) {
        result[1] = NAVCharToLower(result[1])
    }

    return result
}


/**
 * @function NAVStringSnakeCase
 * @public
 * @description Converts a string to snake_case.
 *
 * @param {char[]} buffer - Input string to convert
 *
 * @returns {char[]} snake_case string
 *
 * @example
 * stack_var char text[50]
 * text = 'hello world'
 * text = NAVStringSnakeCase(text)  // Returns 'hello_world'
 */
define_function char[NAV_MAX_BUFFER] NAVStringSnakeCase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]

    result = NAVInsertSpacesBeforeUppercase(buffer)

    result = NAVStringReplace(result, '-', ' ')
    result = NAVStringReplace(result, '_', ' ')
    result = NAVStringReplace(result, '.', ' ')

    while (NAVContains(result, '  ')) {
        result = NAVStringReplace(result, '  ', ' ')
    }

    result = NAVStringReplace(result, ' ', '_')

    return result
}


/**
 * @function NAVStringKebabCase
 * @public
 * @description Converts a string to kebab-case.
 *
 * @param {char[]} buffer - Input string to convert
 *
 * @returns {char[]} kebab-case string
 *
 * @example
 * stack_var char text[50]
 * text = 'hello world'
 * text = NAVStringKebabCase(text)  // Returns 'hello-world'
 */
define_function char[NAV_MAX_BUFFER] NAVStringKebabCase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]

    result = NAVStringSnakeCase(buffer)
    result = NAVStringReplace(result, '_', '-')

    return result
}


/**
 * @function NAVStringTrainCase
 * @public
 * @description Converts a string to Train-Case.
 *
 * @param {char[]} buffer - Input string to convert
 *
 * @returns {char[]} Train-Case string
 *
 * @example
 * stack_var char text[50]
 * text = 'hello world'
 * text = NAVStringTrainCase(text)  // Returns 'Hello-World'
 */
define_function char[NAV_MAX_BUFFER] NAVStringTrainCase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var char byte
    stack_var char prev

    result = NAVStringKebabCase(buffer)
    length = length_array(result)

    if (length) {
        result[1] = NAVCharToUpper(result[1])
    }

    for (x = 2; x <= length; x++) {
        byte = result[x]
        prev = result[x - 1]

        if (prev == '-') {
            result[x] = NAVCharToUpper(byte)
        }
    }

    return result
}


/**
 * @function NAVStringScreamKebabCase
 * @public
 * @description Converts a string to SCREAM-KEBAB-CASE.
 *
 * @param {char[]} buffer - Input string to convert
 *
 * @returns {char[]} SCREAM-KEBAB-CASE string
 *
 * @example
 * stack_var char text[50]
 * text = 'hello world'
 * text = NAVStringScreamKebabCase(text)  // Returns 'HELLO-WORLD'
 */
define_function char[NAV_MAX_BUFFER] NAVStringScreamKebabCase(char buffer[]) {
    return upper_string(NAVStringKebabCase(buffer))
}


/**
 * @function NAVStringReverse
 * @public
 * @description Reverses the characters in a string.
 *
 * @param {char[]} buffer - Input string to reverse
 *
 * @returns {char[]} Reversed string
 *
 * @example
 * stack_var char text[50]
 * text = 'Hello World'
 * text = NAVStringReverse(text)  // Returns 'dlroW olleH'
 */
define_function char[NAV_MAX_BUFFER] NAVStringReverse(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var integer y

    result = buffer
    length = length_array(result)

    if (!length) {
        return result
    }

    for (x = 1, y = length; x <= length; x++, y--) {
        result[x] = buffer[y]
    }

    return result
}


/**
 * @function NAVCharCodeAt
 * @public
 * @description Returns the character code at a specified position in a string.
 *
 * @param {char[]} buffer - Input string
 * @param {integer} index - Position to get the character code from (1-based index)
 *
 * @returns {char} Character code at the specified position, or 0 if out of bounds
 *
 * @example
 * stack_var char text[50]
 * stack_var char code
 * text = 'Hello'
 * code = NAVCharCodeAt(text, 1)  // Returns 'H'
 * code = NAVCharCodeAt(text, 6)  // Returns 0 (out of bounds)
 */
define_function char NAVCharCodeAt(char buffer[], integer index) {
    if (index <= 0 || index > length_array(buffer)) {
        return 0
    }

    return buffer[index]
}


/**
 * @function NAVIsUpperCase
 * @public
 * @description Determines if a character is uppercase (A-Z).
 *
 * @param {char} byte - Character to test
 *
 * @returns {char} True if the character is uppercase, false otherwise
 *
 * @example
 * stack_var char isUpper
 * isUpper = NAVIsUpperCase('A')   // Returns true
 * isUpper = NAVIsUpperCase('a')   // Returns false
 */
define_function char NAVIsUpperCase(char byte) {
    return (byte >= 'A' && byte <= 'Z')
}


/**
 * @function NAVIsLowerCase
 * @public
 * @description Determines if a character is lowercase (a-z).
 *
 * @param {char} byte - Character to test
 *
 * @returns {char} True if the character is lowercase, false otherwise
 *
 * @example
 * stack_var char isLower
 * isLower = NAVIsLowerCase('a')   // Returns true
 * isLower = NAVIsLowerCase('A')   // Returns false
 */
define_function char NAVIsLowerCase(char byte) {
    return (byte >= 'a' && byte <= 'z')
}


/**
 * @function NAVCharToLower
 * @public
 * @description Converts an uppercase character to lowercase.
 *
 * @param {char} byte - Character to convert
 *
 * @returns {char} Lowercase character, or the original character if not uppercase
 *
 * @example
 * stack_var char lower
 * lower = NAVCharToLower('A')   // Returns 'a'
 * lower = NAVCharToLower('a')   // Returns 'a'
 */
define_function char NAVCharToLower(char byte) {
    if (NAVIsUpperCase(byte)) {
        return byte + 32
    }

    return byte
}


/**
 * @function NAVCharToUpper
 * @public
 * @description Converts a lowercase character to uppercase.
 *
 * @param {char} byte - Character to convert
 *
 * @returns {char} Uppercase character, or the original character if not lowercase
 *
 * @example
 * stack_var char upper
 * upper = NAVCharToUpper('a')   // Returns 'A'
 * upper = NAVCharToUpper('A')   // Returns 'A'
 */
define_function char NAVCharToUpper(char byte) {
    if (NAVIsLowerCase(byte)) {
        return byte - 32
    }

    return byte
}


/**
 * @function NAVInsertSpacesBeforeUppercase
 * @public
 * @description Inserts spaces before uppercase letters in a string.
 *
 * @param {char[]} buffer - Input string to modify
 *
 * @returns {char[]} Modified string with spaces inserted
 *
 * @example
 * stack_var char text[50]
 * text = 'HelloWorld'
 * text = NAVInsertSpacesBeforeUppercase(text)  // Returns 'hello world'
 */
define_function char[NAV_MAX_BUFFER] NAVInsertSpacesBeforeUppercase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer x
    stack_var integer length
    stack_var char c

    length = length_array(buffer)

    if (!length) {
        return buffer
    }

    for(x = 1; x <= length; x++) {
        c = buffer[x]

        if (x == 1) {
            result = "result, NAVCharToLower(c)"
            continue
        }

        if (NAVIsUpperCase(c) && !NAVIsUpperCase(buffer[x - 1]) && buffer[x - 1] != ' ') {
            result = "result, ' '"
        }

        result = "result, NAVCharToLower(c)"
    }

    return result
}


#END_IF // __NAV_FOUNDATION_STRINGUTILS__
