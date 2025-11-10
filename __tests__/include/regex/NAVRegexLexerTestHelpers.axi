PROGRAM_NAME='NAVRegexLexerTestHelpers'

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

/**
 * Regex Lexer Test Helper Functions
 *
 * Shared helper functions for validating lexer output in test files.
 * These functions provide common assertions for:
 * - Character class range validation
 * - Predefined character class flags
 * - Token value verification
 */

#IF_NOT_DEFINED __NAV_REGEX_LEXER_TEST_HELPERS__
#DEFINE __NAV_REGEX_LEXER_TEST_HELPERS__ 'NAVRegexLexerTestHelpers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'


/**
 * @function NAVAssertCharClassRange
 * @description Validate that a character class contains a specific range.
 *
 * @param {_NAVRegexCharClass} charClass - The character class to validate
 * @param {integer} rangeIndex - Which range to check (1-based)
 * @param {char} expectedStart - Expected start character of the range
 * @param {char} expectedEnd - Expected end character of the range
 *
 * @returns {char} True (1) if assertion passes, False (0) otherwise
 */
define_function char NAVAssertCharClassRange(_NAVRegexCharClass charClass,
                                               integer rangeIndex,
                                               char expectedStart,
                                               char expectedEnd) {
    stack_var char result

    result = true

    // Validate range exists
    if (!NAVAssertIntegerLessThanOrEqual("'Range index should not exceed rangeCount'",
                                            charClass.rangeCount,
                                            rangeIndex)) {
        return false
    }

    // Validate start character
    if (!NAVAssertIntegerEqual("'Range[', itoa(rangeIndex), '].start should be correct'",
                                expectedStart,
                                charClass.ranges[rangeIndex].start)) {
        result = false
    }

    // Validate end character
    if (!NAVAssertIntegerEqual("'Range[', itoa(rangeIndex), '].end should be correct'",
                                expectedEnd,
                                charClass.ranges[rangeIndex].end)) {
        result = false
    }

    return result
}


/**
 * @function NAVAssertCharClassRangeCount
 * @description Validate the number of ranges in a character class.
 *
 * @param {_NAVRegexCharClass} charClass - The character class to validate
 * @param {integer} expectedCount - Expected number of ranges
 *
 * @returns {char} True (1) if assertion passes, False (0) otherwise
 */
define_function char NAVAssertCharClassRangeCount(_NAVRegexCharClass charClass,
                                                    integer expectedCount) {
    return NAVAssertIntegerEqual('Character class should have correct range count',
                                  expectedCount,
                                  charClass.rangeCount)
}


/**
 * @function NAVAssertCharClassHasDigits
 * @description Validate that a character class has the digits flag set.
 *
 * @param {_NAVRegexCharClass} charClass - The character class to validate
 * @param {char} expectedValue - Expected value (true/false)
 *
 * @returns {char} True (1) if assertion passes, False (0) otherwise
 */
define_function char NAVAssertCharClassHasDigits(_NAVRegexCharClass charClass,
                                                   char expectedValue) {
    if (expectedValue) {
        return NAVAssertTrue('Character class should have digits flag', charClass.hasDigits)
    } else {
        return NAVAssertFalse('Character class should not have digits flag', charClass.hasDigits)
    }
}


/**
 * @function NAVAssertCharClassHasNonDigits
 * @description Validate that a character class has the non-digits flag set.
 *
 * @param {_NAVRegexCharClass} charClass - The character class to validate
 * @param {char} expectedValue - Expected value (true/false)
 *
 * @returns {char} True (1) if assertion passes, False (0) otherwise
 */
define_function char NAVAssertCharClassHasNonDigits(_NAVRegexCharClass charClass,
                                                      char expectedValue) {
    if (expectedValue) {
        return NAVAssertTrue('Character class should have non-digits flag', charClass.hasNonDigits)
    } else {
        return NAVAssertFalse('Character class should not have non-digits flag', charClass.hasNonDigits)
    }
}


/**
 * @function NAVAssertCharClassHasWordChars
 * @description Validate that a character class has the word characters flag set.
 *
 * @param {_NAVRegexCharClass} charClass - The character class to validate
 * @param {char} expectedValue - Expected value (true/false)
 *
 * @returns {char} True (1) if assertion passes, False (0) otherwise
 */
define_function char NAVAssertCharClassHasWordChars(_NAVRegexCharClass charClass,
                                                      char expectedValue) {
    if (expectedValue) {
        return NAVAssertTrue('Character class should have word chars flag', charClass.hasWordChars)
    } else {
        return NAVAssertFalse('Character class should not have word chars flag', charClass.hasWordChars)
    }
}


/**
 * @function NAVAssertCharClassHasNonWordChars
 * @description Validate that a character class has the non-word characters flag set.
 *
 * @param {_NAVRegexCharClass} charClass - The character class to validate
 * @param {char} expectedValue - Expected value (true/false)
 *
 * @returns {char} True (1) if assertion passes, False (0) otherwise
 */
define_function char NAVAssertCharClassHasNonWordChars(_NAVRegexCharClass charClass,
                                                         char expectedValue) {
    if (expectedValue) {
        return NAVAssertTrue('Character class should have non-word chars flag', charClass.hasNonWordChars)
    } else {
        return NAVAssertFalse('Character class should not have non-word chars flag', charClass.hasNonWordChars)
    }
}


/**
 * @function NAVAssertCharClassHasWhitespace
 * @description Validate that a character class has the whitespace flag set.
 *
 * @param {_NAVRegexCharClass} charClass - The character class to validate
 * @param {char} expectedValue - Expected value (true/false)
 *
 * @returns {char} True (1) if assertion passes, False (0) otherwise
 */
define_function char NAVAssertCharClassHasWhitespace(_NAVRegexCharClass charClass,
                                                       char expectedValue) {
    if (expectedValue) {
        return NAVAssertTrue('Character class should have whitespace flag', charClass.hasWhitespace)
    } else {
        return NAVAssertFalse('Character class should not have whitespace flag', charClass.hasWhitespace)
    }
}


/**
 * @function NAVAssertCharClassHasNonWhitespace
 * @description Validate that a character class has the non-whitespace flag set.
 *
 * @param {_NAVRegexCharClass} charClass - The character class to validate
 * @param {char} expectedValue - Expected value (true/false)
 *
 * @returns {char} True (1) if assertion passes, False (0) otherwise
 */
define_function char NAVAssertCharClassHasNonWhitespace(_NAVRegexCharClass charClass,
                                                          char expectedValue) {
    if (expectedValue) {
        return NAVAssertTrue('Character class should have non-whitespace flag', charClass.hasNonWhitespace)
    } else {
        return NAVAssertFalse('Character class should not have non-whitespace flag', charClass.hasNonWhitespace)
    }
}


/**
 * @function NAVAssertTokenIsNegated
 * @description Validate that a character class token has the negation flag set.
 *
 * @param {_NAVRegexToken} token - The token to validate
 * @param {char} expectedValue - Expected value (true/false)
 *
 * @returns {char} True (1) if assertion passes, False (0) otherwise
 */
define_function char NAVAssertTokenIsNegated(_NAVRegexToken token,
                                              char expectedValue) {
    if (expectedValue) {
        return NAVAssertTrue('Token should be negated', token.isNegated)
    } else {
        return NAVAssertFalse('Token should not be negated', token.isNegated)
    }
}


/**
 * @function NAVGetCharClassTokenIndex
 * @description Find the index of the first character class token in a lexer.
 *
 * Helper function to locate character class tokens for validation.
 *
 * @param {_NAVRegexLexer} lexer - The lexer to search
 *
 * @returns {integer} Token index (1-based) or 0 if not found
 */
define_function integer NAVGetCharClassTokenIndex(_NAVRegexLexer lexer) {
    stack_var integer i

    for (i = 1; i <= lexer.tokenCount; i++) {
        if (lexer.tokens[i].type == REGEX_TOKEN_CHAR_CLASS ||
            lexer.tokens[i].type == REGEX_TOKEN_INV_CHAR_CLASS) {
            return i
        }
    }

    return 0
}


/**
 * @function NAVGetCharClassTokenIndexByPosition
 * @description Find the Nth character class token in a lexer.
 *
 * Helper function to locate specific character class tokens when multiple exist.
 *
 * @param {_NAVRegexLexer} lexer - The lexer to search
 * @param {integer} position - Which character class to find (1 = first, 2 = second, etc.)
 *
 * @returns {integer} Token index (1-based) or 0 if not found
 */
define_function integer NAVGetCharClassTokenIndexByPosition(_NAVRegexLexer lexer,
                                                              integer position) {
    stack_var integer i
    stack_var integer count

    count = 0

    for (i = 1; i <= lexer.tokenCount; i++) {
        if (lexer.tokens[i].type == REGEX_TOKEN_CHAR_CLASS ||
            lexer.tokens[i].type == REGEX_TOKEN_INV_CHAR_CLASS) {
            count++
            if (count == position) {
                return i
            }
        }
    }

    return 0
}


/**
 * @function NAVAssertFlagGroupMetadata
 * @description Validate flag group metadata fields for a GROUP_START token.
 *
 * Verifies that the lexer has correctly set the flag group classification metadata
 * (isFlagGroup, isGlobalFlagGroup, isScopedFlagGroup, hasColon).
 *
 * @param {_NAVRegexToken} token - The GROUP_START token to validate
 * @param {char} expectedIsFlagGroup - Expected value for isFlagGroup
 * @param {char} expectedIsGlobalFlagGroup - Expected value for isGlobalFlagGroup
 * @param {char} expectedIsScopedFlagGroup - Expected value for isScopedFlagGroup
 * @param {char} expectedHasColon - Expected value for hasColon
 *
 * @returns {char} True (1) if all assertions pass, False (0) otherwise
 */
define_function char NAVAssertFlagGroupMetadata(_NAVRegexToken token,
                                                  char expectedIsFlagGroup,
                                                  char expectedIsGlobalFlagGroup,
                                                  char expectedIsScopedFlagGroup,
                                                  char expectedHasColon) {
    stack_var char result

    result = true

    // Validate isFlagGroup
    if (!NAVAssertIntegerEqual('isFlagGroup should be correct',
                                expectedIsFlagGroup,
                                token.groupInfo.isFlagGroup)) {
        result = false
    }

    // Validate isGlobalFlagGroup
    if (!NAVAssertIntegerEqual('isGlobalFlagGroup should be correct',
                                expectedIsGlobalFlagGroup,
                                token.groupInfo.isGlobalFlagGroup)) {
        result = false
    }

    // Validate isScopedFlagGroup
    if (!NAVAssertIntegerEqual('isScopedFlagGroup should be correct',
                                expectedIsScopedFlagGroup,
                                token.groupInfo.isScopedFlagGroup)) {
        result = false
    }

    // Validate hasColon
    if (!NAVAssertIntegerEqual('hasColon should be correct',
                                expectedHasColon,
                                token.groupInfo.hasColon)) {
        result = false
    }

    return result
}


/**
 * @function NAVAssertGlobalFlagGroup
 * @description Assert that a token is a global flag group (?i).
 *
 * Convenience wrapper that validates all metadata fields for global flag groups:
 * - isFlagGroup = true
 * - isGlobalFlagGroup = true
 * - isScopedFlagGroup = false
 * - hasColon = false
 *
 * @param {_NAVRegexToken} token - The GROUP_START token to validate
 *
 * @returns {char} True (1) if assertions pass, False (0) otherwise
 */
define_function char NAVAssertGlobalFlagGroup(_NAVRegexToken token) {
    return NAVAssertFlagGroupMetadata(token, true, true, false, false)
}


/**
 * @function NAVAssertScopedFlagGroup
 * @description Assert that a token is a scoped flag group (?i:...).
 *
 * Convenience wrapper that validates all metadata fields for scoped flag groups:
 * - isFlagGroup = true
 * - isGlobalFlagGroup = false
 * - isScopedFlagGroup = true
 * - hasColon = true
 *
 * @param {_NAVRegexToken} token - The GROUP_START token to validate
 *
 * @returns {char} True (1) if assertions pass, False (0) otherwise
 */
define_function char NAVAssertScopedFlagGroup(_NAVRegexToken token) {
    return NAVAssertFlagGroupMetadata(token, true, false, true, true)
}


/**
 * @function NAVAssertRegularGroup
 * @description Assert that a token is a regular group (not a flag group).
 *
 * Convenience wrapper that validates all flag metadata fields are false for regular groups:
 * - isFlagGroup = false
 * - isGlobalFlagGroup = false
 * - isScopedFlagGroup = false
 * - hasColon = false
 *
 * @param {_NAVRegexToken} token - The GROUP_START token to validate
 *
 * @returns {char} True (1) if assertions pass, False (0) otherwise
 */
define_function char NAVAssertRegularGroup(_NAVRegexToken token) {
    return NAVAssertFlagGroupMetadata(token, false, false, false, false)
}


#END_IF // __NAV_REGEX_LEXER_TEST_HELPERS__
