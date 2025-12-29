PROGRAM_NAME='NAVFoundation.RegexLexerHelpers'

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

/**
 * Regex Lexer Helper Functions
 *
 * Contains utility functions for the Lexer phase of regex compilation.
 * These functions handle:
 * - Pattern cursor navigation
 * - Character validation
 * - Group name validation
 * - Quantifier validation
 * - Token type name lookup
 */


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_LEXER_HELPERS__
#DEFINE __NAV_FOUNDATION_REGEX_LEXER_HELPERS__ 'NAVFoundation.RegexLexerHelpers'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.RegexLexer.h.axi'
#include 'NAVFoundation.Regex.h.axi'  // For shared constants: MAX_REGEX_CHAR_RANGES, MAX_REGEX_GROUP_NAME_LENGTH


// ============================================================================
// PATTERN NAVIGATION
// ============================================================================

/**
 * @function NAVRegexLexerHasMoreChars
 * @private
 * @description Check if there are more characters to process in the pattern.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if more characters exist, False (0) otherwise
 */
define_function char NAVRegexLexerHasMoreChars(_NAVRegexLexer lexer) {
    return lexer.pattern.cursor < lexer.pattern.length
}


/**
 * @function NAVRegexLexerCanReadCurrentChar
 * @private
 * @description Check if the current cursor position is valid for reading.
 *
 * In NetLinx's 1-based indexing, cursor positions 1 through length are valid.
 * This includes the last character at position length.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if current position can be read, False (0) otherwise
 */
define_function char NAVRegexLexerCanReadCurrentChar(_NAVRegexLexer lexer) {
    return lexer.pattern.cursor <= lexer.pattern.length
}


/**
 * @function NAVRegexLexerCursorIsOutOfBounds
 * @private
 * @description Check if the pattern cursor is out of bounds.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if cursor is invalid (<= 0 or > length), False (0) otherwise
 */
define_function char NAVRegexLexerCursorIsOutOfBounds(_NAVRegexLexer lexer) {
    return lexer.pattern.cursor <= 0 || lexer.pattern.cursor > lexer.pattern.length
}


/**
 * @function NAVRegexLexerAdvanceCursor
 * @private
 * @description Advance the pattern cursor by one position.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if successful, False (0) if cursor goes out of bounds
 */
define_function char NAVRegexLexerAdvanceCursor(_NAVRegexLexer lexer) {
    return NAVRegexLexerAdvanceCursorBy(lexer, 1)
}


/**
 * @function NAVRegexLexerAdvanceCursorBy
 * @private
 * @description Advance the pattern cursor by a specified number of positions.
 *
 * This is useful when you need to skip over multiple characters at once,
 * such as when parsing multi-character sequences like '(?:' or '(?P<'.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {integer} count - Number of positions to advance
 *
 * @returns {char} True (1) if successful, False (0) if cursor goes out of bounds
 */
define_function char NAVRegexLexerAdvanceCursorBy(_NAVRegexLexer lexer, integer count) {
    // Validate count
    if (count <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerAdvanceCursorBy',
                                    "'Invalid count: ', itoa(count), ' (must be > 0)'")
        return false
    }

    lexer.pattern.cursor = lexer.pattern.cursor + count

    // Check if final position would be out of bounds
    if (NAVRegexLexerCursorIsOutOfBounds(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerAdvanceCursorBy',
                                    "'Pattern cursor out of bounds: ', itoa(lexer.pattern.cursor), ' (tried to advance by ', itoa(count), ')'")
        return false
    }

    return true
}


/**
 * @function NAVRegexLexerBacktrackCursor
 * @private
 * @description Backtrack the pattern cursor by one position.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if successful, False (0) if cursor goes out of bounds
 */
define_function char NAVRegexLexerBacktrackCursor(_NAVRegexLexer lexer) {
    return NAVRegexLexerBacktrackCursorBy(lexer, 1)
}


/**
 * @function NAVRegexLexerBacktrackCursorBy
 * @private
 * @description Backtrack the pattern cursor by a specified number of positions.
 *
 * This is useful when you need to move the cursor back multiple characters,
 * such as when re-evaluating previously read characters.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {integer} count - Number of positions to backtrack
 *
 * @returns {char} True (1) if successful, False (0) if cursor goes out of bounds
 */
define_function char NAVRegexLexerBacktrackCursorBy(_NAVRegexLexer lexer, integer count) {
    // Validate count
    if (count <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerBacktrackCursorBy',
                                    "'Invalid count: ', itoa(count), ' (must be > 0)'")
        return false
    }

    lexer.pattern.cursor = lexer.pattern.cursor - count

    // Check if final position would be out of bounds
    if (NAVRegexLexerCursorIsOutOfBounds(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerBacktrackCursorBy',
                                    "'Pattern cursor out of bounds: ', itoa(lexer.pattern.cursor), ' (tried to backtrack by ', itoa(count), ')'")
        return false
    }

    return true
}


/**
 * @function NAVRegexLexerGetCurrentChar
 * @private
 * @description Get the character at the current cursor position.
 *
 * Returns the character that the cursor is currently pointing to
 * in the pattern string.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} The character at the cursor position, or 0 if cursor is out of bounds
 */
define_function char NAVRegexLexerGetCurrentChar(_NAVRegexLexer lexer) {
    if (NAVRegexLexerCursorIsOutOfBounds(lexer)) {
        return 0
    }

    return NAVCharCodeAt(lexer.pattern.value, lexer.pattern.cursor)
}


// ============================================================================
// CHARACTER VALIDATION
// ============================================================================

/**
 * @function NAVRegexLexerIsValidEscapeChar
 * @private
 * @description Check if a character is a valid escape sequence.
 *
 * Validates both:
 * - Special character classes: \d, \w, \s, etc.
 * - Metacharacters that can be escaped: \., \*, \+, etc.
 *
 * @param {char} c - The character after the backslash
 *
 * @returns {char} True (1) if valid escape sequence, False (0) otherwise
 */
define_function char NAVRegexLexerIsValidEscapeChar(char c) {
    // Check if this is a valid escape character
    // Letters that are valid escape sequences
    switch (c) {
        case 'b':   // Word boundary
        case 'B':   // Not word boundary
        case 'd':   // Digit
        case 'D':   // Not digit
        case 'w':   // Word character
        case 'W':   // Not word character
        case 's':   // Whitespace
        case 'S':   // Not whitespace
        case 'x':   // Hex
        case 'n':   // Newline
        case 'r':   // Return
        case 't':   // Tab
        case 'f':   // Form feed
        case 'v':   // Vertical tab
        case 'a':   // Bell
        case 'e':   // Escape
        case 'k':   // Named backreference
        case '1':   // Numbered backreferences
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9':
        case 'A':   // String start anchor
        case 'Z':   // String end anchor (before final newline)
        case 'z':   // String end anchor (absolute)
        case '0': { // Octal escape
            return true
        }
    }

    // Special characters that can be escaped (literal matching)
    // These include regex metacharacters: . * + ? ^ $ { } [ ] ( ) | \
    switch (c) {
        case '.':
        case '*':
        case '+':
        case '?':
        case '^':
        case '$':
        case '{':
        case '}':
        case '[':
        case ']':
        case '(':
        case ')':
        case '|':
        case '\':
        case '/': {  // Forward slash for delimiter
            return true
        }
    }

    // If we get here, it's not a valid escape sequence
    return false
}


// ============================================================================
// GROUP NAME VALIDATION
// ============================================================================

/**
 * @function NAVRegexLexerIsValidGroupName
 * @private
 * @description Validate a group name according to regex naming rules.
 *
 * Rules:
 * - Must start with letter or underscore
 * - Can contain letters, digits, or underscores
 * - Cannot be empty
 *
 * @param {char[]} name - The group name to validate
 *
 * @returns {char} True (1) if valid, False (0) otherwise
 */
define_function char NAVRegexLexerIsValidGroupName(char name[]) {
    stack_var integer length
    stack_var integer x
    stack_var char c

    length = length_array(name)

    if (length == 0) {
        return false
    }

    // First character must be a letter or underscore
    c = NAVCharCodeAt(name, 1)
    if (!((c >= 'a' && c <= 'z') ||
            (c >= 'A' && c <= 'Z') ||
            c == '_')) {
        return false
    }

    // Remaining characters can be letters, digits, or underscores
    for (x = 2; x <= length; x++) {
        c = NAVCharCodeAt(name, x)
        if (!((c >= 'a' && c <= 'z') ||
                (c >= 'A' && c <= 'Z') ||
                (c >= '0' && c <= '9') ||
                c == '_')) {
            return false
        }
    }

    return true
}


/**
 * @function NAVRegexLexerIsGroupNameUnique
 * @private
 * @description Check if a group name is unique within the pattern.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure containing existing groups
 * @param {char[]} name - The group name to check
 *
 * @returns {char} True (1) if unique, False (0) if duplicate found
 */
define_function char NAVRegexLexerIsGroupNameUnique(_NAVRegexLexer lexer, char name[]) {
    stack_var integer x

    // Scan existing tokens for duplicate group names
    for (x = 1; x <= lexer.tokenCount; x++) {
        if (lexer.tokens[x].type == REGEX_TOKEN_GROUP_START) {
            if (lexer.tokens[x].groupInfo.isNamed) {
                if (lexer.tokens[x].groupInfo.name == name) {
                    return false  // Duplicate found
                }
            }
        }
    }

    return true
}


// ============================================================================
// QUANTIFIER VALIDATION
// ============================================================================

/**
 * @function NAVRegexLexerCanQuantify
 * @private
 * @description Check if the previous token can be quantified.
 *
 * Validates:
 * - There is a previous token
 * - Previous token is not already a quantifier
 * - Previous token is not an anchor
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if can quantify, False (0) otherwise
 */
define_function char NAVRegexLexerCanQuantify(_NAVRegexLexer lexer) {
    // Check if there's a previous token that can be quantified
    if (lexer.tokenCount == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerCanQuantify',
                                    "'Quantifier at start of pattern - nothing to quantify'")
        return false  // No previous token
    }

    // Check if previous token is already a quantifier
    // (Lazy quantifiers are identified by the isLazy flag, not separate token types)
    switch (lexer.tokens[lexer.tokenCount].type) {
        case REGEX_TOKEN_STAR:
        case REGEX_TOKEN_PLUS:
        case REGEX_TOKEN_QUESTIONMARK:
        case REGEX_TOKEN_QUANTIFIER: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerCanQuantify',
                                        "'Consecutive quantifiers - cannot quantify a quantifier'")
            return false  // Can't quantify a quantifier
        }
        case REGEX_TOKEN_BEGIN:
        case REGEX_TOKEN_END: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerCanQuantify',
                                        "'Cannot quantify an anchor (^ or $)'")
            return false  // Can't quantify anchors
        }
    }

    return true
}


// ============================================================================
// GROUP TRACKING
// ============================================================================

/**
 * @function NAVRegexLexerIncrementGroupCount
 * @private
 * @description Increment the capturing group count.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if successful, False (0) if max groups exceeded
 */
define_function char NAVRegexLexerIncrementGroupCount(_NAVRegexLexer lexer) {
    // Check if we've exceeded max groups BEFORE incrementing
    if (lexer.groupCount >= MAX_REGEX_GROUPS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerIncrementGroupCount',
                                    "'Too many capturing groups (max: ', itoa(MAX_REGEX_GROUPS), ')'")
        return false
    }

    lexer.groupCount++

    return true
}


/**
 * @function NAVRegexLexerIncrementGroupDepth
 * @private
 * @description Increment the group nesting depth.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if successful, False (0) if max depth exceeded
 */
define_function char NAVRegexLexerIncrementGroupDepth(_NAVRegexLexer lexer) {
    // Check depth before using as array index
    if (lexer.groupDepth >= MAX_REGEX_GROUPS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerIncrementGroupDepth',
                                    "'Group nesting too deep (max: ', itoa(MAX_REGEX_GROUPS), ')'")
        return false
    }

    lexer.groupDepth++

    return true
}


/**
 * @function NAVRegexLexerDecrementGroupDepth
 * @private
 * @description Decrement the group nesting depth.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if successful, False (0) if no matching opening parenthesis
 */
define_function char NAVRegexLexerDecrementGroupDepth(_NAVRegexLexer lexer) {
    // Check if we have a matching opening parenthesis
    if (lexer.groupDepth <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerDecrementGroupDepth',
                                    "'Unmatched closing parenthesis `)` in pattern'")
        return false
    }

    // Pop from stack
    lexer.groupDepth--

    return true
}


// ============================================================================
// TOKEN MANAGEMENT
// ============================================================================

/**
 * @function NAVRegexLexerCanAddToken
 * @private
 * @description Check if there is space to add another token.
 *
 * Simple check that the token count hasn't exceeded the maximum limit
 * defined by MAX_REGEX_TOKENS. Does not log errors.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if space available, False (0) if limit reached
 */
define_function char NAVRegexLexerCanAddToken(_NAVRegexLexer lexer) {
    return lexer.tokenCount < MAX_REGEX_TOKENS
}


/**
 * @function NAVRegexLexerAddToken
 * @private
 * @description Add a new token to the lexer's token array with type and value.
 *
 * Checks capacity, increments token count, and sets the token's type and value.
 * Logs an error if the maximum token limit has been reached.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {integer} type - The token type (REGEX_TOKEN_)
 * @param {char} value - The token value
 *
 * @returns {char} True (1) if token added successfully, False (0) if limit reached
 */
define_function char NAVRegexLexerAddToken(_NAVRegexLexer lexer, integer type, char value) {
    if (!NAVRegexLexerCanAddToken(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerAddToken',
                                    "'Maximum token limit reached (', itoa(MAX_REGEX_TOKENS), ')'")
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = type
    lexer.tokens[lexer.tokenCount].value = value
    set_length_array(lexer.tokens, lexer.tokenCount)

    return true
}


/**
 * @function NAVRegexLexerPeekChar
 * @private
 * @description Look ahead at a character in the pattern relative to the cursor.
 *
 * Allows lookahead in the pattern string without advancing the cursor.
 * The offset is relative to the current cursor position.
 *
 * This function silently returns 0 when peeking beyond the pattern bounds,
 * as this is expected behavior that calling code handles appropriately.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {integer} offset - The offset from current cursor position (1 = next char, 2 = char after that, etc.)
 *
 * @returns {char} The character at cursor + offset, or 0 if out of bounds
 */
define_function char NAVRegexLexerPeekChar(_NAVRegexLexer lexer, integer offset) {
    stack_var integer position

    position = lexer.pattern.cursor + offset

    if (position < 1 || position > lexer.pattern.length) {
        // Silently return 0 - peeking beyond bounds is expected and handled by callers
        return 0
    }

    return NAVCharCodeAt(lexer.pattern.value, position)
}


/**
 * @function NAVRegexLexerPeekNextChar
 * @private
 * @description Look ahead at the next character in the pattern.
 *
 * Convenience function to peek at the character immediately after
 * the current cursor position (cursor + 1).
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} The next character in the pattern, or 0 if out of bounds
 */
define_function char NAVRegexLexerPeekNextChar(_NAVRegexLexer lexer) {
    return NAVRegexLexerPeekChar(lexer, 1)
}


// ============================================================================
// TOKEN TYPE LOOKUP
// ============================================================================

/**
 * @function NAVRegexLexerGetTokenType
 * @public
 * @description Get the name of a token type for debugging and error messages.
 *
 * @param {integer} type - The token type constant
 *
 * @returns {char[NAV_MAX_CHARS]} The string name of the token type
 */
define_function char[NAV_MAX_CHARS] NAVRegexLexerGetTokenType(integer type) {
    switch (type) {
        case REGEX_TOKEN_NONE:                      { return 'NONE' }
        case REGEX_TOKEN_EOF:                       { return 'EOF' }
        case REGEX_TOKEN_DOT:                       { return 'DOT' }
        case REGEX_TOKEN_BEGIN:                     { return 'BEGIN' }
        case REGEX_TOKEN_END:                       { return 'END' }
        case REGEX_TOKEN_QUESTIONMARK:              { return 'QUESTIONMARK' }
        case REGEX_TOKEN_STAR:                      { return 'STAR' }
        case REGEX_TOKEN_PLUS:                      { return 'PLUS' }
        case REGEX_TOKEN_CHAR:                      { return 'CHAR' }
        case REGEX_TOKEN_CHAR_CLASS:                { return 'CHAR_CLASS' }
        case REGEX_TOKEN_INV_CHAR_CLASS:            { return 'INV_CHAR_CLASS' }
        case REGEX_TOKEN_DIGIT:                     { return 'DIGIT' }
        case REGEX_TOKEN_NOT_DIGIT:                 { return 'NOT_DIGIT' }
        case REGEX_TOKEN_ALPHA:                     { return 'ALPHA' }
        case REGEX_TOKEN_NOT_ALPHA:                 { return 'NOT_ALPHA' }
        case REGEX_TOKEN_WHITESPACE:                { return 'WHITESPACE' }
        case REGEX_TOKEN_NOT_WHITESPACE:            { return 'NOT_WHITESPACE' }
        case REGEX_TOKEN_ALTERNATION:               { return 'ALTERNATION' }
        case REGEX_TOKEN_GROUP:                     { return 'GROUP' }
        case REGEX_TOKEN_QUANTIFIER:                { return 'QUANTIFIER' }
        case REGEX_TOKEN_ESCAPE:                    { return 'ESCAPE' }
        case REGEX_TOKEN_EPSILON:                   { return 'EPSILON' }
        case REGEX_TOKEN_WORD_BOUNDARY:             { return 'WORD_BOUNDARY' }
        case REGEX_TOKEN_NOT_WORD_BOUNDARY:         { return 'NOT_WORD_BOUNDARY' }
        case REGEX_TOKEN_HEX:                       { return 'HEX' }
        case REGEX_TOKEN_NEWLINE:                   { return 'NEWLINE' }
        case REGEX_TOKEN_RETURN:                    { return 'RETURN' }
        case REGEX_TOKEN_TAB:                       { return 'TAB' }
        case REGEX_TOKEN_FORMFEED:                  { return 'FORMFEED' }
        case REGEX_TOKEN_VTAB:                      { return 'VTAB' }
        case REGEX_TOKEN_BELL:                      { return 'BELL' }
        case REGEX_TOKEN_ESC:                       { return 'ESC' }
        case REGEX_TOKEN_GROUP_START:               { return 'GROUP_START' }
        case REGEX_TOKEN_GROUP_END:                 { return 'GROUP_END' }
        case REGEX_TOKEN_LOOKAHEAD_POSITIVE:        { return 'LOOKAHEAD_POSITIVE' }
        case REGEX_TOKEN_LOOKAHEAD_NEGATIVE:        { return 'LOOKAHEAD_NEGATIVE' }
        case REGEX_TOKEN_LOOKBEHIND_POSITIVE:       { return 'LOOKBEHIND_POSITIVE' }
        case REGEX_TOKEN_LOOKBEHIND_NEGATIVE:       { return 'LOOKBEHIND_NEGATIVE' }
        case REGEX_TOKEN_NUMERIC_ESCAPE:            { return 'NUMERIC_ESCAPE' }
        case REGEX_TOKEN_BACKREF_NAMED:             { return 'BACKREF_NAMED' }
        case REGEX_TOKEN_STRING_START:              { return 'STRING_START' }
        case REGEX_TOKEN_STRING_END:                { return 'STRING_END' }
        case REGEX_TOKEN_STRING_END_ABSOLUTE:       { return 'STRING_END_ABSOLUTE' }
        case REGEX_TOKEN_FLAG_CASE_INSENSITIVE:     { return 'FLAG_CASE_INSENSITIVE' }
        case REGEX_TOKEN_FLAG_MULTILINE:            { return 'FLAG_MULTILINE' }
        case REGEX_TOKEN_FLAG_DOTALL:               { return 'FLAG_DOTALL' }
        case REGEX_TOKEN_FLAG_EXTENDED:             { return 'FLAG_EXTENDED' }
        case REGEX_TOKEN_COMMENT:                   { return 'COMMENT' }
        default:                                    { return "'UNKNOWN (', itoa(type), ')'" }
    }
}


// ============================================================================
// SPECIALIZED TOKEN ADD FUNCTIONS
// ============================================================================

/**
 * @function NAVRegexLexerAddQuantifierToken
 * @private
 * @description Add a quantifier token with min/max bounds.
 *
 * Used for bounded quantifiers like {n}, {n,}, or {n,m}.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {integer} tokenType - The token type (REGEX_TOKEN_QUANTIFIER)
 * @param {sinteger} minVal - Minimum repetitions
 * @param {sinteger} maxVal - Maximum repetitions (-1 = unlimited)
 *
 * @returns {char} True (1) if token added successfully, False (0) if limit reached
 */
define_function char NAVRegexLexerAddQuantifierToken(_NAVRegexLexer lexer,
                                                      integer tokenType,
                                                      sinteger minVal,
                                                      sinteger maxVal) {
    if (!NAVRegexLexerCanAddToken(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerAddQuantifierToken',
                                    "'Maximum token limit reached (', itoa(MAX_REGEX_TOKENS), ')'")
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = tokenType
    lexer.tokens[lexer.tokenCount].min = minVal
    lexer.tokens[lexer.tokenCount].max = maxVal
    set_length_array(lexer.tokens, lexer.tokenCount)

    return true
}


/**
 * @function NAVRegexLexerAddNamedBackrefToken
 * @private
 * @description Add a named backreference token.
 *
 * Used for backreferences like \k<name>.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char[]} backrefName - The group name being referenced
 * @param {char} value - The token value (usually the backslash)
 *
 * @returns {char} True (1) if token added successfully, False (0) if limit reached
 */
define_function char NAVRegexLexerAddNamedBackrefToken(_NAVRegexLexer lexer,
                                                        char backrefName[],
                                                        char value) {
    if (!NAVRegexLexerCanAddToken(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerAddNamedBackrefToken',
                                    "'Maximum token limit reached (', itoa(MAX_REGEX_TOKENS), ')'")
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = REGEX_TOKEN_BACKREF_NAMED
    lexer.tokens[lexer.tokenCount].value = value
    lexer.tokens[lexer.tokenCount].name = backrefName
    set_length_array(lexer.tokens, lexer.tokenCount)

    return true
}


/**
 * @function NAVRegexLexerAddCharClassToken
 * @private
 * @description Add a fully parsed character class token.
 *
 * Used for character classes like [abc], [a-z], or [^0-9].
 * The character class should already be parsed into ranges.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {_NAVRegexCharClass} charclass - The fully parsed character class
 * @param {char} isNegated - True for [^...], false for [...]
 *
 * @returns {char} True (1) if token added successfully, False (0) if limit reached
 */
define_function char NAVRegexLexerAddCharClassToken(_NAVRegexLexer lexer,
                                                     _NAVRegexCharClass charclass,
                                                     char isNegated) {
    if (!NAVRegexLexerCanAddToken(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerAddCharClassToken',
                                    "'Maximum token limit reached (', itoa(MAX_REGEX_TOKENS), ')'")
        return false
    }

    lexer.tokenCount++

    // Set token type and negation flag
    if (isNegated) {
        lexer.tokens[lexer.tokenCount].type = REGEX_TOKEN_INV_CHAR_CLASS
        lexer.tokens[lexer.tokenCount].isNegated = true
    }
    else {
        lexer.tokens[lexer.tokenCount].type = REGEX_TOKEN_CHAR_CLASS
        lexer.tokens[lexer.tokenCount].isNegated = false
    }

    // Copy the entire parsed character class
    lexer.tokens[lexer.tokenCount].charclass = charclass
    set_length_array(lexer.tokens, lexer.tokenCount)

    return true
}


/**
 * @function NAVRegexLexerAddNumericEscapeToken
 * @private
 * @description Add a numeric escape token (ambiguous octal/backreference).
 *
 * This function handles escape sequences like \1, \10, \101, \377 which
 * could be either octal escapes or backreferences depending on context.
 * The lexer stores the digit string and metadata; the parser will decide
 * the final interpretation based on the number of capturing groups.
 *
 * Disambiguation rules (applied by parser):
 * - If digits start with 0 (\0...), always treat as octal
 * - If value ≤ group count, treat as backreference
 * - Otherwise, treat as octal (if valid)
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char[]} digitStr - The digit string (e.g., "1", "10", "101")
 * @param {char} leadingZero - True if sequence started with \0
 *
 * @returns {char} True (1) if token added successfully, False (0) if limit reached
 */
define_function char NAVRegexLexerAddNumericEscapeToken(_NAVRegexLexer lexer,
                                                         char digitStr[],
                                                         char leadingZero) {
    if (!NAVRegexLexerCanAddToken(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerAddNumericEscapeToken',
                                    "'Maximum token limit reached (', itoa(MAX_REGEX_TOKENS), ')'")
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = REGEX_TOKEN_NUMERIC_ESCAPE
    lexer.tokens[lexer.tokenCount].numericEscapeDigits = digitStr
    lexer.tokens[lexer.tokenCount].numericEscapeLeadingZero = leadingZero
    set_length_array(lexer.tokens, lexer.tokenCount)

    return true
}


/**
 * @function NAVRegexLexerIsHexDigit
 * @private
 * @description Check if a character is a valid hexadecimal digit (0-9, A-F, a-f).
 *
 * @param {char} c - The character to check
 *
 * @returns {char} True (1) if valid hex digit, False (0) otherwise
 */
define_function char NAVRegexLexerIsHexDigit(char c) {
    // Check if character is 0-9
    if (c >= '0' && c <= '9') {
        return true
    }

    // Check if character is A-F
    if (c >= 'A' && c <= 'F') {
        return true
    }

    // Check if character is a-f
    if (c >= 'a' && c <= 'f') {
        return true
    }

    return false
}


/**
 * @function NAVRegexLexerHexCharToValue
 * @private
 * @description Convert a hex character to its numeric value.
 *
 * @param {char} c - The hex character (0-9, A-F, a-f)
 *
 * @returns {integer} The numeric value (0-15)
 */
define_function integer NAVRegexLexerHexCharToValue(char c) {
    // 0-9
    if (c >= '0' && c <= '9') {
        return c - '0'
    }

    // A-F
    if (c >= 'A' && c <= 'F') {
        return (c - 'A') + 10
    }

    // a-f
    if (c >= 'a' && c <= 'f') {
        return (c - 'a') + 10
    }

    return 0
}


/**
 * @function NAVRegexLexerAddHexToken
 * @private
 * @description Add a hex escape token.
 *
 * Used for hex escapes like \xNN where NN is a 2-digit hex value.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {integer} hexValue - The hex character code (decimal value)
 *
 * @returns {char} True (1) if token added successfully, False (0) if limit reached
 */
define_function char NAVRegexLexerAddHexToken(_NAVRegexLexer lexer,
                                               integer hexValue) {
    if (!NAVRegexLexerCanAddToken(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerAddHexToken',
                                    "'Maximum token limit reached (', itoa(MAX_REGEX_TOKENS), ')'")
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = REGEX_TOKEN_HEX

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ AddHexToken ]: hexValue (integer)=', itoa(hexValue), ', about to type_cast to char'")
    #END_IF

    lexer.tokens[lexer.tokenCount].value = type_cast(hexValue)

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ AddHexToken ]: After type_cast, token.value=', itoa(lexer.tokens[lexer.tokenCount].value)")
    #END_IF

    set_length_array(lexer.tokens, lexer.tokenCount)

    return true
}


/**
 * @function NAVRegexLexerAddFlagToken
 * @private
 * @description Add an inline flag token.
 *
 * Used for inline flags like (?i), (?m), (?s), (?x).
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {integer} tokenType - The token type (REGEX_TOKEN_FLAG_)
 * @param {char} enabled - True to enable flag, False to disable (for (?-i) syntax)
 * @param {char} value - The token value (usually the opening parenthesis)
 *
 * @returns {char} True (1) if token added successfully, False (0) if limit reached
 */
define_function char NAVRegexLexerAddFlagToken(_NAVRegexLexer lexer,
                                                integer tokenType,
                                                char enabled,
                                                char value) {
    if (!NAVRegexLexerCanAddToken(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerAddFlagToken',
                                    "'Maximum token limit reached (', itoa(MAX_REGEX_TOKENS), ')'")
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = tokenType
    lexer.tokens[lexer.tokenCount].flagEnabled = enabled
    lexer.tokens[lexer.tokenCount].value = value
    set_length_array(lexer.tokens, lexer.tokenCount)

    return true
}


/**
 * @function NAVRegexLexerAddCommentToken
 * @private
 * @description Add a comment token.
 *
 * Used for inline comments like (?#comment). Comment tokens are purely
 * informational and don't affect pattern matching or NFA construction.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char[]} comment - The comment text (not stored, just validated)
 * @param {char} value - The token value (usually the opening parenthesis)
 *
 * @returns {char} True (1) if token added successfully, False (0) if limit reached
 */
define_function char NAVRegexLexerAddCommentToken(_NAVRegexLexer lexer,
                                                   char comment[],
                                                   char value) {
    if (!NAVRegexLexerCanAddToken(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerAddCommentToken',
                                    "'Maximum token limit reached (', itoa(MAX_REGEX_TOKENS), ')'")
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = REGEX_TOKEN_COMMENT
    lexer.tokens[lexer.tokenCount].value = value
    // Note: comment text is not stored as it's not needed for NFA construction
    set_length_array(lexer.tokens, lexer.tokenCount)

    return true
}


// ============================================================================
// CHARACTER CLASS AND QUANTIFIER PARSING
// ============================================================================

/**
 * @function NAVRegexLexerConsumeGroupName
 * @private
 * @description Parse a group name from a named group construct.
 *
 * Parses the name portion of named groups:
 * - Python style: (?P<name>)
 * - .NET/PCRE style: (?<name>) or (?'name')
 *
 * Validates:
 * - Name is not empty
 * - Name starts with letter or underscore
 * - Name contains only alphanumeric characters and underscores
 * - Name is unique (no duplicate group names)
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char[]} groupName - Output: the parsed group name
 *
 * @returns {char} True (1) if parsing succeeded, False (0) if failed
 */
define_function char NAVRegexLexerConsumeGroupName(_NAVRegexLexer lexer, char groupName[]) {
    return NAVRegexLexerConsumeGroupNameWithDelimiter(lexer, groupName, '>')
}


/**
 * @function NAVRegexLexerConsumeGroupNameWithDelimiter
 * @private
 * @description Parse a group name with a specified delimiter character.
 *
 * Used for named groups with different delimiter styles:
 * - Angle bracket: (?<name>) uses '>' delimiter
 * - Single quote: (?'name') uses "'" delimiter
 *
 * Validates:
 * - Name is not empty
 * - Name starts with letter or underscore
 * - Name contains only alphanumeric characters and underscores
 * - Name is unique (no duplicate group names)
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char[]} groupName - Output: the parsed group name
 * @param {char} delimiter - The delimiter character to search for
 *
 * @returns {char} True (1) if parsing succeeded, False (0) if failed
 */
define_function char NAVRegexLexerConsumeGroupNameWithDelimiter(_NAVRegexLexer lexer,
                                                                  char groupName[],
                                                                  char delimiter) {
    stack_var char buffer[MAX_REGEX_GROUP_NAME_LENGTH]
    stack_var char c

    buffer = ''

    while (NAVRegexLexerHasMoreChars(lexer)) {
        c = NAVRegexLexerGetCurrentChar(lexer)

        if (c == delimiter) {
            break  // Found end of name
        }

        if (length_array(buffer) >= max_length_array(groupName)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerConsumeGroupNameWithDelimiter',
                                        "'Group name too long (max ', itoa(max_length_array(groupName)), ' characters)'")
            return false
        }

        buffer = "buffer, c"

        if (!NAVRegexLexerAdvanceCursor(lexer)) {
            return false
        }
    }

    if (c != delimiter) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeGroupNameWithDelimiter',
                                    "'Missing closing delimiter `', delimiter, '` in named group'")
        return false
    }

    if (!length_array(buffer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeGroupNameWithDelimiter',
                                    "'Empty group name'")
        return false
    }

    groupName = buffer

    // Validate name
    if (!NAVRegexLexerIsValidGroupName(groupName)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeGroupNameWithDelimiter',
                                    "'Invalid group name: ', groupName, ' (must start with letter/underscore, contain only alphanumeric/underscore)'")
        return false
    }

    // Check for uniqueness
    if (!NAVRegexLexerIsGroupNameUnique(lexer, groupName)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeGroupNameWithDelimiter',
                                    "'Duplicate group name: ', groupName")
        return false
    }

    return true
}


/**
 * @function NAVRegexLexerConsumeBoundedQuantifier
 * @private
 * @description Parse a bounded quantifier from the pattern.
 *
 * Parses quantifiers in the form {n}, {n,}, or {n,m} and validates:
 * - Both values are non-negative
 * - Maximum is >= minimum
 * - Contains valid digits and comma only
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if parsing succeeded, False (0) if failed
 */
define_function char NAVRegexLexerConsumeBoundedQuantifier(_NAVRegexLexer lexer) {
    stack_var char buffer[20]
    stack_var integer length
    stack_var integer commaPos
    stack_var char minStr[10]
    stack_var char maxStr[10]
    stack_var sinteger minVal
    stack_var sinteger maxVal

    // Start after the opening '{'
    if (!NAVRegexLexerAdvanceCursor(lexer)) {
        return false
    }

    // Collect digits and comma until we hit '}'
    buffer = ''

    while (NAVRegexLexerHasMoreChars(lexer)) {
        stack_var char c

        c = NAVRegexLexerGetCurrentChar(lexer)

        if (c == '}') {
            break
        }

        if ((c >= '0' && c <= '9') || c == ',' || c == ' ') {
            if (c != ' ') {  // Skip spaces
                buffer = "buffer, c"
            }

            if (!NAVRegexLexerAdvanceCursor(lexer)) {
                return false
            }
        }
        else {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerConsumeBoundedQuantifier',
                                        "'Invalid character in bounded quantifier: ', c")
            return false
        }
    }

    if (NAVRegexLexerGetCurrentChar(lexer) != '}') {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeBoundedQuantifier',
                                    "'Missing closing brace in bounded quantifier'")
        return false
    }

    length = length_array(buffer)
    if (!length) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeBoundedQuantifier',
                                    "'Empty bounded quantifier'")
        return false
    }

    // Parse the quantifier: {n}, {n,}, or {n,m}
    commaPos = NAVIndexOf(buffer, ',', 1)

    select {
        active (commaPos == 0): {
            // No comma, just {n}
            minVal = atoi(buffer)
            maxVal = minVal
        }
        active (commaPos == 1): {
            // Starts with comma: {,m} is invalid (missing minimum)
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerConsumeBoundedQuantifier',
                                        "'Missing minimum value in bounded quantifier'")
            return false
        }
        active (commaPos == length): {
            // Ends with comma: {n,} means n or more (unlimited)
            minStr = left_string(buffer, commaPos - 1)
            minVal = atoi(minStr)
            maxVal = -1  // -1 means unlimited
        }
        active (true): {
            // Has comma in middle: {n,m}
            minStr = left_string(buffer, commaPos - 1)
            maxStr = right_string(buffer, length - commaPos)
            minVal = atoi(minStr)
            maxVal = atoi(maxStr)

            if (maxVal < minVal) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                            'NAVRegexLexerConsumeBoundedQuantifier',
                                            "'Maximum must be >= minimum in bounded quantifier'")
                return false
            }
        }
    }

    if (minVal < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeBoundedQuantifier',
                                    "'Minimum must be >= 0 in bounded quantifier'")
        return false
    }

    // Add the quantifier token
    if (!NAVRegexLexerAddQuantifierToken(lexer, REGEX_TOKEN_QUANTIFIER, minVal, maxVal)) {
        return false
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ Lexer ]: Bounded quantifier {', itoa(minVal), ',', itoa(maxVal), '}'")
    #END_IF

    return true
}


/**
 * @function NAVRegexLexerConsumeCharacterClass
 * @private
 * @description Parse a character class from the pattern into ranges.
 *
 * Fully parses character classes into a structured format ready for NFA construction:
 * - Normal character classes: [abc] -> ranges [a-a, b-b, c-c]
 * - Negated character classes: [^abc] -> isNegated=true, ranges [a-a, b-b, c-c]
 * - Character ranges: [a-z] -> ranges [a-z]
 * - Predefined classes: [\d\w] -> hasDigits=true, hasWordChars=true
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if parsing succeeded, False (0) if failed
 */
define_function char NAVRegexLexerConsumeCharacterClass(_NAVRegexLexer lexer) {
    stack_var _NAVRegexCharClass charclass
    stack_var integer i
    stack_var char prevChar
    stack_var char currentChar
    stack_var char nextChar
    stack_var char isNegated

    // Initialize character class
    charclass.rangeCount = 0
    charclass.hasDigits = false
    charclass.hasNonDigits = false
    charclass.hasWordChars = false
    charclass.hasNonWordChars = false
    charclass.hasWhitespace = false
    charclass.hasNonWhitespace = false

    isNegated = false

    // Check for negation
    if (NAVRegexLexerPeekNextChar(lexer) == '^') {
        isNegated = true

        if (!NAVRegexLexerAdvanceCursor(lexer)) {
            return false
        }

        if (NAVRegexLexerPeekNextChar(lexer) == 0) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerConsumeCharacterClass',
                                        "'Incomplete pattern. Missing non-zero character after ^'")
            return false
        }
    }

    // Advance to first character in the class
    if (!NAVRegexLexerAdvanceCursor(lexer)) {
        return false
    }

    // Special case: If the first character is ']', it could be:
    // 1. An empty character class /[]/ - just close immediately
    // 2. A literal ']' at start /[]]/ or /[]a-z]/ - treat as literal and continue
    // To distinguish: peek ahead. If next char is also ']' or more content exists, it's literal.
    currentChar = NAVRegexLexerGetCurrentChar(lexer)
    if (currentChar == ']') {
        // Check if there's a next character
        if (lexer.pattern.cursor + 1 <= length_array(lexer.pattern.value)) {
            stack_var char peekChar
            peekChar = lexer.pattern.value[lexer.pattern.cursor + 1]

            // If next char is ']' OR anything other than end of pattern,
            // treat this first ']' as a literal character
            // Examples: /[]]/ → literal ']' then close
            //           /[]a/ → literal ']' then 'a'
            if (peekChar != 0) {
                // Add ']' as a literal character in the class
                if (charclass.rangeCount >= MAX_REGEX_CHAR_RANGES) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                'NAVRegexLexerConsumeCharacterClass',
                                                "'Too many character ranges in character class'")
                    return false
                }

                charclass.rangeCount++
                charclass.ranges[charclass.rangeCount].start = ']'
                charclass.ranges[charclass.rangeCount].end = ']'

                // Advance past this literal ']'
                if (!NAVRegexLexerAdvanceCursor(lexer)) {
                    return false
                }
            }
            // else: just /[]/ - empty class, will close immediately below
        }
        // else: /[]/ at end of pattern - empty class, will close immediately below
    }

    // Parse character class content
    while (NAVRegexLexerCanReadCurrentChar(lexer)) {
        currentChar = NAVRegexLexerGetCurrentChar(lexer)

        // Check for closing bracket
        if (currentChar == ']') {
            break
        }

        // Handle escape sequences
        if (currentChar == '\') {
            stack_var char isPredefinedClass
            isPredefinedClass = false

            if (!NAVRegexLexerAdvanceCursor(lexer)) {
                return false
            }

            currentChar = NAVRegexLexerGetCurrentChar(lexer)

            if (currentChar == 0) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                            'NAVRegexLexerConsumeCharacterClass',
                                            "'Incomplete pattern. Missing non-zero character after \'")
                return false
            }

            // Check for predefined character classes
            switch (currentChar) {
                case 'd': {  // \d - digits
                    charclass.hasDigits = true
                    isPredefinedClass = true
                }
                case 'D': {  // \D - non-digits
                    charclass.hasNonDigits = true
                    isPredefinedClass = true
                }
                case 'w': {  // \w - word characters
                    charclass.hasWordChars = true
                    isPredefinedClass = true
                }
                case 'W': {  // \W - non-word characters
                    charclass.hasNonWordChars = true
                    isPredefinedClass = true
                }
                case 's': {  // \s - whitespace
                    charclass.hasWhitespace = true
                    isPredefinedClass = true
                }
                case 'S': {  // \S - non-whitespace
                    charclass.hasNonWhitespace = true
                    isPredefinedClass = true
                }
                case 'x': {
                    // Hex escape: \xHH (exactly 2 hex digits)
                    // Uses same logic as NAVRegexLexerConsumeEscape() case 'x'
                    stack_var char hexStr[3]
                    stack_var integer hexValue
                    stack_var integer digitCount
                    stack_var char hexNextChar

                    hexStr = ''
                    digitCount = 0

                    // Read exactly 2 hex digits (0-9, A-F, a-f)
                    while (digitCount < 2) {
                        if ((lexer.pattern.cursor + 1) > lexer.pattern.length) {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                        'NAVRegexLexerConsumeCharacterClass',
                                                        "'Incomplete hex escape - expected 2 hex digits'")
                            return false
                        }

                        hexNextChar = NAVRegexLexerPeekNextChar(lexer)

                        if (!NAVRegexLexerIsHexDigit(hexNextChar)) {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                        'NAVRegexLexerConsumeCharacterClass',
                                                        "'Invalid hex digit in escape sequence: ', hexNextChar")
                            return false
                        }

                        if (!NAVRegexLexerAdvanceCursor(lexer)) {
                            return false
                        }

                        hexStr = "hexStr, hexNextChar"
                        digitCount++
                    }

                    // Convert hex string to integer (same logic as outside char class)
                    hexValue = 0
                    {
                        stack_var integer hexIdx
                        for (hexIdx = 1; hexIdx <= length_array(hexStr); hexIdx++) {
                            stack_var char hexChar
                            hexChar = NAVCharCodeAt(hexStr, hexIdx)
                            hexValue = (hexValue * 16) + NAVRegexLexerHexCharToValue(hexChar)
                        }
                    }

                    // In character class context, convert to character immediately
                    currentChar = type_cast(hexValue)

                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Hex escape in char class: \x', hexStr, ' = ', itoa(hexValue)")
                    #END_IF

                    // Continue to range-checking logic below
                }
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                case '8':
                case '9': {
                    // Octal escape in character class: \0 to \377 (decimal 0-255)
                    // In character classes, numeric escapes are ALWAYS interpreted as octal
                    // (backreferences are not valid in character classes)
                    //
                    // Rules:
                    // 1. Greedily consume up to 3 octal digits (0-7)
                    // 2. Stop at first non-octal digit (8 or 9)
                    // 3. Stop if value would exceed 377 (decimal 255)
                    //
                    // Examples:
                    //   [\101]   → 0x41 = 'A' (octal 101 fully consumed)
                    //   [\1012]  → 0x41 = 'A' + literal '2' (101 consumed, 2 remains)
                    //   [\128]   → 0x0A (octal 12) + literal '8' (8 not octal)
                    //   [\400]   → 0x20 (octal 40) + literal '0' (would exceed 255)

                    stack_var char octalStr[4]
                    stack_var integer octalValue
                    stack_var char octalNextChar
                    stack_var integer digitCount

                    octalStr = "currentChar"
                    octalValue = currentChar - '0'  // Convert first digit
                    digitCount = 1

                    // Greedily consume up to 2 more octal digits (max 3 total)
                    while (digitCount < 3) {
                        if ((lexer.pattern.cursor + 1) > lexer.pattern.length) {
                            break  // End of pattern
                        }

                        octalNextChar = NAVRegexLexerPeekNextChar(lexer)

                        // Stop if not an octal digit (0-7)
                        if (octalNextChar < '0' || octalNextChar > '7') {
                            break
                        }

                        // Check if adding this digit would exceed 255
                        {
                            stack_var integer testValue
                            testValue = (octalValue * 8) + (octalNextChar - '0')
                            if (testValue > 255) {
                                break  // Would exceed max value
                            }
                            octalValue = testValue
                        }

                        // Consume the digit
                        if (!NAVRegexLexerAdvanceCursor(lexer)) {
                            return false
                        }

                        octalStr = "octalStr, octalNextChar"
                        digitCount++
                    }

                    currentChar = type_cast(octalValue)

                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Octal escape in char class: \', octalStr, ' = ', itoa(octalValue), ' (0x', format('%02X', octalValue), ')'")
                    #END_IF

                    // Continue to range-checking logic below
                }
                default: {
                    // Regular escaped character
                    // Handle common escapes
                    switch (currentChar) {
                        case 'n': currentChar = $0A  // newline
                        case 'r': currentChar = $0D  // carriage return
                        case 't': currentChar = $09  // tab
                        case 'f': currentChar = $0C  // form feed
                        case 'v': currentChar = $0B  // vertical tab
                        case 'a': currentChar = $07  // bell
                        case 'e': currentChar = $1B  // escape
                        // For other escapes like \-, \], \^, use the literal character
                    }

                    // Continue to range-checking logic below
                }
            }

            // For predefined classes (\d, \w, \s, etc.), skip range checking
            if (isPredefinedClass) {
                // Advance to next character
                if (!NAVRegexLexerAdvanceCursor(lexer)) {
                    return false
                }
                continue  // Skip range-checking, go to next iteration
            }

            // For all other escapes (hex, octal, \n, \t, \r, etc.),
            // fall through to regular character range-checking logic below
        }

        // Regular character OR escaped character (after conversion)
        // Check if it's part of a range
        nextChar = NAVRegexLexerPeekNextChar(lexer)

        if (nextChar == '-') {
            stack_var char rangeEndChar

            // This is the start of a range
            if (!NAVRegexLexerAdvanceCursor(lexer)) {  // Skip current char
                return false
            }

            if (!NAVRegexLexerAdvanceCursor(lexer)) {  // Skip '-'
                return false
            }

            rangeEndChar = NAVRegexLexerGetCurrentChar(lexer)

            if (rangeEndChar == ']') {
                // The '-' was at the end of the class, treat it as literal
                // Add the current char as a single char range
                if (charclass.rangeCount >= MAX_REGEX_CHAR_RANGES) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                'NAVRegexLexerConsumeCharacterClass',
                                                "'Too many character ranges in character class'")
                    return false
                }

                charclass.rangeCount++
                charclass.ranges[charclass.rangeCount].start = currentChar
                charclass.ranges[charclass.rangeCount].end = currentChar

                // Add '-' as a single char range
                charclass.rangeCount++
                charclass.ranges[charclass.rangeCount].start = '-'
                charclass.ranges[charclass.rangeCount].end = '-'

                break  // We hit the closing bracket
            }
            else if (rangeEndChar == 0) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                            'NAVRegexLexerConsumeCharacterClass',
                                            "'Incomplete range in character class'")
                return false
            }
            else if (rangeEndChar == '\') {
                // Range end is an escape sequence - process it
                if (!NAVRegexLexerAdvanceCursor(lexer)) {
                    return false
                }

                rangeEndChar = NAVRegexLexerGetCurrentChar(lexer)

                if (rangeEndChar == 0) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                'NAVRegexLexerConsumeCharacterClass',
                                                "'Incomplete pattern. Missing non-zero character after \'")
                    return false
                }

                // Handle common escapes for range end
                switch (rangeEndChar) {
                    case 'n': rangeEndChar = $0A  // newline
                    case 'r': rangeEndChar = $0D  // carriage return
                    case 't': rangeEndChar = $09  // tab
                    case 'f': rangeEndChar = $0C  // form feed
                    case 'v': rangeEndChar = $0B  // vertical tab
                    case 'a': rangeEndChar = $07  // bell
                    case 'e': rangeEndChar = $1B  // escape
                    case 'x': {
                        // Hex escape in range end: \xHH
                        stack_var char hexStrEnd[3]
                        stack_var integer hexValueEnd
                        stack_var integer digitCountEnd
                        stack_var char hexNextCharEnd

                        hexStrEnd = ''
                        digitCountEnd = 0

                        while (digitCountEnd < 2) {
                            if ((lexer.pattern.cursor + 1) > lexer.pattern.length) {
                                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                            'NAVRegexLexerConsumeCharacterClass',
                                                            "'Incomplete hex escape - expected 2 hex digits'")
                                return false
                            }

                            hexNextCharEnd = NAVRegexLexerPeekNextChar(lexer)

                            if (!NAVRegexLexerIsHexDigit(hexNextCharEnd)) {
                                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                            'NAVRegexLexerConsumeCharacterClass',
                                                            "'Invalid hex digit in escape sequence: ', hexNextCharEnd")
                                return false
                            }

                            if (!NAVRegexLexerAdvanceCursor(lexer)) {
                                return false
                            }

                            hexStrEnd = "hexStrEnd, hexNextCharEnd"
                            digitCountEnd++
                        }

                        hexValueEnd = 0
                        {
                            stack_var integer hexIdxEnd
                            for (hexIdxEnd = 1; hexIdxEnd <= length_array(hexStrEnd); hexIdxEnd++) {
                                stack_var char hexCharEnd
                                hexCharEnd = NAVCharCodeAt(hexStrEnd, hexIdxEnd)
                                hexValueEnd = (hexValueEnd * 16) + NAVRegexLexerHexCharToValue(hexCharEnd)
                            }
                        }

                        rangeEndChar = type_cast(hexValueEnd)
                    }
                    case '0':
                    case '1':
                    case '2':
                    case '3':
                    case '4':
                    case '5':
                    case '6':
                    case '7':
                    case '8':
                    case '9': {
                        // Octal escape in range end: \0 to \377
                        stack_var char octalStrEnd[4]
                        stack_var integer octalValueEnd
                        stack_var char octalNextCharEnd
                        stack_var integer digitCountEnd

                        octalStrEnd = "rangeEndChar"
                        octalValueEnd = rangeEndChar - '0'  // Convert first digit
                        digitCountEnd = 1

                        // Greedily consume up to 2 more octal digits (max 3 total)
                        while (digitCountEnd < 3) {
                            if ((lexer.pattern.cursor + 1) > lexer.pattern.length) {
                                break  // End of pattern
                            }

                            octalNextCharEnd = NAVRegexLexerPeekNextChar(lexer)

                            // Stop if not an octal digit (0-7)
                            if (octalNextCharEnd < '0' || octalNextCharEnd > '7') {
                                break
                            }

                            // Check if adding this digit would exceed 255
                            {
                                stack_var integer testValueEnd
                                testValueEnd = (octalValueEnd * 8) + (octalNextCharEnd - '0')
                                if (testValueEnd > 255) {
                                    break  // Would exceed max value
                                }
                                octalValueEnd = testValueEnd
                            }

                            // Consume the digit
                            if (!NAVRegexLexerAdvanceCursor(lexer)) {
                                return false
                            }

                            octalStrEnd = "octalStrEnd, octalNextCharEnd"
                            digitCountEnd++
                        }

                        rangeEndChar = type_cast(octalValueEnd)
                    }
                    // For other escapes like \-, \], use literal character
                    // default: rangeEndChar remains as-is
                }
            }

            // After processing rangeEndChar (whether escaped or not), create the range
            // Valid range: currentChar-rangeEndChar
            if (currentChar > rangeEndChar) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                            'NAVRegexLexerConsumeCharacterClass',
                                            "'Invalid range in character class: start > end'")
                return false
            }

            if (charclass.rangeCount >= MAX_REGEX_CHAR_RANGES) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                            'NAVRegexLexerConsumeCharacterClass',
                                            "'Too many character ranges in character class'")
                return false
            }

            charclass.rangeCount++
            charclass.ranges[charclass.rangeCount].start = currentChar
            charclass.ranges[charclass.rangeCount].end = rangeEndChar
        }
        else {
            // Single character (not part of a range)
            if (charclass.rangeCount >= MAX_REGEX_CHAR_RANGES) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                            'NAVRegexLexerConsumeCharacterClass',
                                            "'Too many character ranges in character class'")
                return false
            }

            charclass.rangeCount++
            charclass.ranges[charclass.rangeCount].start = currentChar
            charclass.ranges[charclass.rangeCount].end = currentChar
        }

        // Advance to next character
        if (!NAVRegexLexerAdvanceCursor(lexer)) {
            return false
        }
    }

    // Verify we found the closing bracket
    if (NAVRegexLexerGetCurrentChar(lexer) != ']') {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeCharacterClass',
                                    "'Unclosed character class - missing `]`'")
        return false
    }

    // Add the fully parsed character class token
    if (!NAVRegexLexerAddCharClassToken(lexer, charclass, isNegated)) {
        return false
    }

    return true
}


// ============================================================================
// REPEATED PATTERN HELPERS
// ============================================================================

/**
 * @function NAVRegexLexerHandleLazyModifier
 * @private
 * @description Check for and handle lazy quantifier modifier (?).
 *
 * Instead of creating separate lazy token types, this sets the isLazy
 * flag on the most recently added quantifier token.
 *
 * Used for *, +, ?, and {n,m} quantifiers.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {integer} normalTokenType - Token type for normal version (e.g., REGEX_TOKEN_STAR)
 * @param {char} c - Current character
 * @param {char} shouldContinue - Output: set to true if lazy quantifier was found and caller should continue
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerHandleLazyModifier(_NAVRegexLexer lexer,
                                                      integer normalTokenType,
                                                      char c,
                                                      char shouldContinue) {
    shouldContinue = false

    if (NAVRegexLexerPeekNextChar(lexer) == '?') {
        // Add the base quantifier token first
        if (!NAVRegexLexerAddToken(lexer, normalTokenType, c)) {
            return false
        }

        // Advance past the '?'
        if (!NAVRegexLexerAdvanceCursor(lexer)) {
            return false
        }

        // Mark it as lazy
        lexer.tokens[lexer.tokenCount].isLazy = true

        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ Lexer ]: Lazy quantifier ', NAVRegexLexerGetTokenType(normalTokenType), '? detected'")
        #END_IF

        shouldContinue = true
        return true
    }

    return NAVRegexLexerAddToken(lexer, normalTokenType, c)
}


/**
 * @function NAVRegexLexerAddSpecialGroupToken
 * @private
 * @description Handle simple special group syntax (lookaround, flags).
 *
 * This helper eliminates code duplication for lookaround and flag token creation.
 * Used for (?=...), (?!...), (?<=...), (?<!...), (?i), (?m), (?s), (?x).
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {integer} advanceCount - Number of characters to advance past the special syntax
 * @param {integer} tokenType - Token type to add
 * @param {char} c - Current character (usually '(')
 * @param {char[]} debugMessage - Debug message to log
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerAddSpecialGroupToken(_NAVRegexLexer lexer,
                                                        integer advanceCount,
                                                        integer tokenType,
                                                        char c,
                                                        char debugMessage[NAV_MAX_CHARS]) {
    if (!NAVRegexLexerAdvanceCursorBy(lexer, advanceCount)) {
        return false
    }

    if (!NAVRegexLexerAddToken(lexer, tokenType, c)) {
        return false
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    if (length_array(debugMessage) > 0) {
        NAVLog("'[ Lexer ]: ', debugMessage")
    }
    #END_IF

    return true
}


/**
 * @function NAVRegexLexerConsumeEscape
 * @private
 * @description Handle backslash escape sequences.
 *
 * Processes all escape sequences including character classes (\d, \w, \s),
 * boundaries (\b, \B), anchors (\A, \Z, \z), backreferences (\1-\9, \k<name>),
 * octal escapes (\0nn), and escaped literals.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} backslashChar - The backslash character
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerConsumeEscape(_NAVRegexLexer lexer, char backslashChar) {
    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ Lexer ]: Backslash case - cursor=', itoa(lexer.pattern.cursor), ' checking (cursor+1) <= length: (', itoa(lexer.pattern.cursor + 1), ') <= (', itoa(lexer.pattern.length), ') = ', itoa((lexer.pattern.cursor + 1) <= lexer.pattern.length)")
    #END_IF

    if (NAVRegexLexerHasMoreChars(lexer)) {
        // Increment cursor to look at the character after the backslash
        if (!NAVRegexLexerAdvanceCursor(lexer)) {
            return false
        }

        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ Lexer ]: Backslash processing - cursor now=', itoa(lexer.pattern.cursor), ' char is: ', NAVRegexLexerGetCurrentChar(lexer)")
        #END_IF

        // Validate that this is a supported escape sequence
        if (!NAVRegexLexerIsValidEscapeChar(NAVRegexLexerGetCurrentChar(lexer))) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerConsumeEscape',
                                        "'Invalid escape sequence: \', NAVRegexLexerGetCurrentChar(lexer)")
            return false
        }

        switch (NAVRegexLexerGetCurrentChar(lexer)) {
            case 'b': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_WORD_BOUNDARY, 0)) {  // Zero-width assertion
                    return false
                }
            }
            case 'B': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_NOT_WORD_BOUNDARY, 0)) {  // Zero-width assertion
                    return false
                }
            }
            case 'd': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_DIGIT, 0)) {  // Character class shortcut
                    return false
                }
            }
            case 'D': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_NOT_DIGIT, 0)) {  // Character class shortcut
                    return false
                }
            }
            case 'w': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_ALPHA, 0)) {  // Character class shortcut
                    return false
                }
            }
            case 'W': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_NOT_ALPHA, 0)) {  // Character class shortcut
                    return false
                }
            }
            case 's': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_WHITESPACE, 0)) {  // Character class shortcut
                    return false
                }
            }
            case 'S': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_NOT_WHITESPACE, 0)) {  // Character class shortcut
                    return false
                }
            }
            case 'x': {
                // Hex escape: \xHH (exactly 2 hex digits)
                stack_var char hexStr[3]
                stack_var integer hexValue
                stack_var integer digitCount
                stack_var char nextChar

                hexStr = ''
                digitCount = 0

                // Read exactly 2 hex digits (0-9, A-F, a-f)
                while (digitCount < 2) {
                    if ((lexer.pattern.cursor + 1) > lexer.pattern.length) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                    'NAVRegexLexerConsumeEscape',
                                                    "'Incomplete hex escape - expected 2 hex digits'")
                        return false
                    }

                    nextChar = NAVRegexLexerPeekNextChar(lexer)

                    if (!NAVRegexLexerIsHexDigit(nextChar)) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                    'NAVRegexLexerConsumeEscape',
                                                    "'Invalid hex digit in escape sequence: ', nextChar")
                        return false
                    }

                    if (!NAVRegexLexerAdvanceCursor(lexer)) {
                        return false
                    }

                    hexStr = "hexStr, nextChar"
                    digitCount++
                }

                // Convert hex string to integer
                hexValue = 0
                {
                    stack_var integer i
                    for (i = 1; i <= length_array(hexStr); i++) {
                        stack_var char hexChar
                        hexChar = NAVCharCodeAt(hexStr, i)
                        hexValue = (hexValue * 16) + NAVRegexLexerHexCharToValue(hexChar)
                    }
                }

                if (!NAVRegexLexerAddHexToken(lexer, hexValue)) {
                    return false
                }

                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: Hex escape detected: \x', hexStr, ' = ', itoa(hexValue)")
                #END_IF
            }
            case 'n': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_NEWLINE, $0A)) {  // Newline = ASCII 10
                    return false
                }
            }
            case 'r': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_RETURN, $0D)) {  // Carriage return = ASCII 13
                    return false
                }
            }
            case 't': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_TAB, $09)) {  // Tab = ASCII 9
                    return false
                }
            }
            case 'f': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_FORMFEED, $0C)) {  // Form feed = ASCII 12
                    return false
                }
            }
            case 'v': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_VTAB, $0B)) {  // Vertical tab = ASCII 11
                    return false
                }
            }
            case 'a': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_BELL, $07)) {  // Bell = ASCII 7
                    return false
                }
            }
            case 'e': {
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_ESC, $1B)) {  // Escape = ASCII 27
                    return false
                }
            }
            case 'k': {
                // Named backreference: \k<name>
                stack_var char nextChar
                stack_var char backrefName[MAX_REGEX_GROUP_NAME_LENGTH]
                stack_var integer i

                // Check for < after k
                if ((lexer.pattern.cursor + 1) > lexer.pattern.length) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                'NAVRegexLexerConsumeEscape',
                                                "'Invalid named backreference - incomplete \k pattern'")
                    return false
                }

                // Move to next char
                if (!NAVRegexLexerAdvanceCursor(lexer)) {
                    return false
                }

                nextChar = NAVRegexLexerGetCurrentChar(lexer)

                if (nextChar != '<') {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                'NAVRegexLexerConsumeEscape',
                                                "'Invalid named backreference - \k must be followed by <'")
                    return false
                }

                // Move to first char of name
                if (!NAVRegexLexerAdvanceCursor(lexer)) {
                    return false
                }

                // Read group name until we hit >
                backrefName = ''
                i = 0

                while (NAVRegexLexerHasMoreChars(lexer)) {
                    nextChar = NAVRegexLexerGetCurrentChar(lexer)

                    if (nextChar == '>') {
                        break
                    }

                    if (i >= max_length_array(backrefName)) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                    'NAVRegexLexerConsumeEscape',
                                                    "'Backreference name too long (max ', itoa(max_length_array(backrefName)), ' characters)'")
                        return false
                    }

                    backrefName = "backrefName, nextChar"
                    i++

                    if (!NAVRegexLexerAdvanceCursor(lexer)) {
                        return false
                    }
                }

                if (NAVRegexLexerGetCurrentChar(lexer) != '>') {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                'NAVRegexLexerConsumeEscape',
                                                "'Invalid named backreference - missing closing >'")
                    return false
                }

                if (length_array(backrefName) == 0) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                'NAVRegexLexerConsumeEscape',
                                                "'Invalid named backreference - empty name'")
                    return false
                }

                if (!NAVRegexLexerAddNamedBackrefToken(lexer, backrefName, backslashChar)) {
                    return false
                }

                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: Named backreference detected: \k<', backrefName, '>'")
                #END_IF
            }
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9': {
                // Numeric escape: could be octal or backreference
                // Lexer collects ALL consecutive digits without any interpretation or limits
                // Parser will validate and disambiguate based on context
                stack_var char digitStr[10]  // Allow larger strings for parser validation
                stack_var char firstDigit
                stack_var char nextChar
                stack_var char leadingZero

                firstDigit = NAVRegexLexerGetCurrentChar(lexer)
                leadingZero = (firstDigit == '0')
                digitStr = "firstDigit"

                // Consume ALL consecutive digits - no limits, no validation
                while (NAVRegexLexerHasMoreChars(lexer)) {
                    if ((lexer.pattern.cursor + 1) > lexer.pattern.length) {
                        break
                    }

                    nextChar = NAVRegexLexerPeekNextChar(lexer)

                    // Check if next char is a digit
                    if (nextChar < '0' || nextChar > '9') {
                        break  // Not a digit, stop here
                    }

                    // Advance and add the digit
                    if (!NAVRegexLexerAdvanceCursor(lexer)) {
                        return false
                    }

                    digitStr = "digitStr, nextChar"
                }

                // Add the numeric escape token with raw digit string
                // Parser will decide if it's valid octal, backreference, or error
                if (!NAVRegexLexerAddNumericEscapeToken(lexer, digitStr, leadingZero)) {
                    return false
                }

                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: Numeric escape: \', digitStr, ' (leadingZero=', itoa(leadingZero), ')'")
                #END_IF
            }
            case 'A': {
                // String start anchor \A (zero-width assertion)
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_STRING_START, 0)) {
                    return false
                }

                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: String start anchor \A detected'")
                #END_IF
            }
            case 'Z': {
                // String end anchor \Z (before final newline, zero-width assertion)
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_STRING_END, 0)) {
                    return false
                }

                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: String end anchor \Z detected'")
                #END_IF
            }
            case 'z': {
                // String end anchor \z (absolute, zero-width assertion)
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_STRING_END_ABSOLUTE, 0)) {
                    return false
                }

                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: String end anchor \z detected'")
                #END_IF
            }
            default: {
                // Escaped literal character
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_CHAR, NAVRegexLexerGetCurrentChar(lexer))) {
                    return false
                }
            }
        }
    }
    else {
        // Trailing backslash with nothing after it
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeEscape',
                                    "'Trailing backslash - incomplete escape sequence'")
        return false
    }

    return true
}


/**
 * @function NAVRegexLexerConsumeLookbehindOrNamedGroup
 * @private
 * @description Handle (?< syntax - either lookbehind or .NET-style named group.
 *
 * Disambiguates between:
 * - Positive lookbehind: (?<=...)
 * - Negative lookbehind: (?<!...)
 * - .NET named group: (?<name>...)
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} openParenChar - The opening parenthesis character
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerConsumeLookbehindOrNamedGroup(_NAVRegexLexer lexer, char openParenChar) {
    stack_var char thirdChar
    stack_var char groupName[MAX_REGEX_GROUP_NAME_LENGTH]

    // Could be lookbehind or named group - check third character
    if ((lexer.pattern.cursor + 3) <= lexer.pattern.length) {
        thirdChar = NAVRegexLexerPeekChar(lexer, 3)

        switch (thirdChar) {
            case '=': {
                // Positive lookbehind (?<=...)
                // Advance past '(?<='
                if (!NAVRegexLexerAdvanceCursorBy(lexer, 3)) {
                    return false
                }

                // Increment total group count
                lexer.groupTotal++

                if (lexer.groupTotal > MAX_REGEX_GROUPS) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                'NAVRegexLexerConsumeLookbehindOrNamedGroup',
                                                "'Too many groups (max: ', itoa(MAX_REGEX_GROUPS), ')'")
                    return false
                }

                // Increment nesting depth
                if (!NAVRegexLexerIncrementGroupDepth(lexer)) {
                    return false
                }

                // Track group on stack
                lexer.groupStack[lexer.groupDepth] = lexer.groupTotal

                // Add lookbehind token
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_LOOKBEHIND_POSITIVE, openParenChar)) {
                    return false
                }

                // Populate group info (lookaround groups are non-capturing)
                lexer.tokens[lexer.tokenCount].groupInfo.number = 0  // Non-capturing
                lexer.tokens[lexer.tokenCount].groupInfo.name = ''
                lexer.tokens[lexer.tokenCount].groupInfo.isNamed = false
                lexer.tokens[lexer.tokenCount].groupInfo.isCapturing = false
                lexer.tokens[lexer.tokenCount].groupInfo.startToken = lexer.tokenCount

                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: Positive lookbehind detected (?<=...) at depth ', itoa(lexer.groupDepth)")
                #END_IF

                return true
            }
            case '!': {
                // Negative lookbehind (?<!...)
                // Advance past '(?<!'
                if (!NAVRegexLexerAdvanceCursorBy(lexer, 3)) {
                    return false
                }

                // Increment total group count
                lexer.groupTotal++

                if (lexer.groupTotal > MAX_REGEX_GROUPS) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                                'NAVRegexLexerConsumeLookbehindOrNamedGroup',
                                                "'Too many groups (max: ', itoa(MAX_REGEX_GROUPS), ')'")
                    return false
                }

                // Increment nesting depth
                if (!NAVRegexLexerIncrementGroupDepth(lexer)) {
                    return false
                }

                // Track group on stack
                lexer.groupStack[lexer.groupDepth] = lexer.groupTotal

                // Add lookbehind token
                if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_LOOKBEHIND_NEGATIVE, openParenChar)) {
                    return false
                }

                // Populate group info (lookaround groups are non-capturing)
                lexer.tokens[lexer.tokenCount].groupInfo.number = 0  // Non-capturing
                lexer.tokens[lexer.tokenCount].groupInfo.name = ''
                lexer.tokens[lexer.tokenCount].groupInfo.isNamed = false
                lexer.tokens[lexer.tokenCount].groupInfo.isCapturing = false
                lexer.tokens[lexer.tokenCount].groupInfo.startToken = lexer.tokenCount

                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: Negative lookbehind detected (?<!...) at depth ', itoa(lexer.groupDepth)")
                #END_IF

                return true
            }
            default: {
                // .NET-style named group (?<name>...)

                // Advance past '(?<'
                if (!NAVRegexLexerAdvanceCursorBy(lexer, 3)) {
                    return false
                }

                // Parse the group name
                if (!NAVRegexLexerConsumeGroupName(lexer, groupName)) {
                    return false
                }

                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: Named group detected (.NET style): ', groupName")
                #END_IF

                // Finalize as named capturing group
                return NAVRegexLexerFinalizeGroupStart(lexer, openParenChar, true, true, groupName)
            }
        }
    }
    else {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeLookbehindOrNamedGroup',
                                    "'Invalid group syntax - incomplete (?< pattern'")
        return false
    }
}


/**
 * @function NAVRegexLexerConsumePythonNamedGroup
 * @private
 * @description Handle Python-style named groups: (?P<name>...).
 *
 * Validates syntax, extracts group name, and finalizes the group.
 * This is a complete handler that returns immediately.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} openParenChar - The opening parenthesis character
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerConsumePythonNamedGroup(_NAVRegexLexer lexer, char openParenChar) {
    stack_var char groupName[MAX_REGEX_GROUP_NAME_LENGTH]

    // Python-style named group (?P<name>...)
    // Validate we have enough characters for (?P<
    if ((lexer.pattern.cursor + 3) <= lexer.pattern.length) {
        if (NAVRegexLexerPeekChar(lexer, 3) == '<') {
            // Advance past '(?P<'
            if (!NAVRegexLexerAdvanceCursorBy(lexer, 4)) {
                return false
            }

            // Parse the group name
            if (!NAVRegexLexerConsumeGroupName(lexer, groupName)) {
                return false
            }

            #IF_DEFINED REGEX_LEXER_DEBUG
            NAVLog("'[ Lexer ]: Named group detected (Python style): ', groupName")
            #END_IF

            // Finalize as named capturing group
            return NAVRegexLexerFinalizeGroupStart(lexer, openParenChar, true, true, groupName)
        }
        else {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerConsumePythonNamedGroup',
                                        "'Invalid group syntax - (?P requires < after P'")
            return false
        }
    }
    else {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumePythonNamedGroup',
                                    "'Invalid group syntax - incomplete (?P pattern'")
        return false
    }
}


/**
 * @function NAVRegexLexerConsumePythonNamedBackref
 * @private
 * @description Handle Python-style named backreferences: (?P=name).
 *
 * Validates syntax, extracts backreference name, and adds named backref token.
 * This provides consistency with Python-style named groups (?P<name>...).
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} openParenChar - The opening parenthesis character (not used but kept for consistency)
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerConsumePythonNamedBackref(_NAVRegexLexer lexer, char openParenChar) {
    stack_var char backrefName[MAX_REGEX_GROUP_NAME_LENGTH]
    stack_var char nextChar
    stack_var integer i

    // Python-style named backreference (?P=name)
    // Validate we have enough characters for (?P=
    if ((lexer.pattern.cursor + 3) > lexer.pattern.length) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumePythonNamedBackref',
                                    "'Invalid named backreference - incomplete (?P= pattern'")
        return false
    }

    // We already validated third char is '=' in the caller
    // Advance past '(?P='
    if (!NAVRegexLexerAdvanceCursorBy(lexer, 4)) {
        return false
    }

    // Read group name until we hit )
    backrefName = ''
    i = 0

    while (NAVRegexLexerHasMoreChars(lexer)) {
        nextChar = NAVRegexLexerGetCurrentChar(lexer)

        if (nextChar == ')') {
            break
        }

        if (i >= max_length_array(backrefName)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerConsumePythonNamedBackref',
                                        "'Backreference name too long (max ', itoa(max_length_array(backrefName)), ' characters)'")
            return false
        }

        backrefName = "backrefName, nextChar"
        i++

        if (!NAVRegexLexerAdvanceCursor(lexer)) {
            return false
        }
    }

    if (NAVRegexLexerGetCurrentChar(lexer) != ')') {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumePythonNamedBackref',
                                    "'Invalid named backreference - missing closing )'")
        return false
    }

    if (length_array(backrefName) == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumePythonNamedBackref',
                                    "'Invalid named backreference - empty name'")
        return false
    }

    if (!NAVRegexLexerAddNamedBackrefToken(lexer, backrefName, openParenChar)) {
        return false
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ Lexer ]: Python-style named backreference detected: (?P=', backrefName, ')'")
    #END_IF

    return true
}


/**
 * @function NAVRegexLexerConsumeQuotedNamedGroup
 * @private
 * @description Handle .NET-style single-quote named groups: (?'name'...).
 *
 * Validates syntax, extracts group name, and finalizes the group.
 * This is an alternative .NET syntax using single quotes instead of angle brackets.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} openParenChar - The opening parenthesis character
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerConsumeQuotedNamedGroup(_NAVRegexLexer lexer, char openParenChar) {
    stack_var char groupName[MAX_REGEX_GROUP_NAME_LENGTH]

    // .NET-style single-quote named group (?'name'...)
    // Advance past "(?'"
    if (!NAVRegexLexerAdvanceCursorBy(lexer, 3)) {
        return false
    }

    // Parse the group name (using single quote as delimiter)
    if (!NAVRegexLexerConsumeGroupNameWithDelimiter(lexer, groupName, '''')) {
        return false
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ Lexer ]: Named group detected (.NET single-quote style): ', groupName")
    #END_IF

    // Finalize as named capturing group
    return NAVRegexLexerFinalizeGroupStart(lexer, openParenChar, true, true, groupName)
}


/**
 * @function NAVRegexLexerFinalizeGroupStart
 * @private
 * @description Finalize group setup and emit GROUP_START token.
 *
 * Common logic for all group types after specific group syntax is parsed.
 * Increments counters, validates limits, stores group info, and emits token.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} openParenChar - The opening parenthesis character
 * @param {char} isCapturing - Whether this is a capturing group
 * @param {char} isNamed - Whether this is a named group
 * @param {char[]} groupName - The group name (empty string if not named)
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerFinalizeGroupStart(_NAVRegexLexer lexer,
                                                      char openParenChar,
                                                      char isCapturing,
                                                      char isNamed,
                                                      char groupName[]) {
    // Increment total group count (for all types)
    lexer.groupTotal++

    if (lexer.groupTotal > MAX_REGEX_GROUPS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerFinalizeGroupStart',
                                    "'Too many groups (max: ', itoa(MAX_REGEX_GROUPS), ')'")
        return false
    }

    // Only increment capturing group count if this is a capturing group
    if (isCapturing) {
        if (!NAVRegexLexerIncrementGroupCount(lexer)) {
            return false
        }
    }

    // Increment nesting depth (for all group types)
    if (!NAVRegexLexerIncrementGroupDepth(lexer)) {
        return false
    }

    // Add token FIRST so we know its index
    if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_GROUP_START, openParenChar)) {
        return false
    }

    // Track GROUP_START token index on stack for matching with GROUP_END
    // CRITICAL: Store the ACTUAL token index, not groupTotal!
    lexer.groupStack[lexer.groupDepth] = lexer.tokenCount

    // Populate embedded group info directly in the token
    lexer.tokens[lexer.tokenCount].groupInfo.number = lexer.groupCount
    lexer.tokens[lexer.tokenCount].groupInfo.name = groupName
    lexer.tokens[lexer.tokenCount].groupInfo.isNamed = isNamed
    lexer.tokens[lexer.tokenCount].groupInfo.isCapturing = isCapturing
    lexer.tokens[lexer.tokenCount].groupInfo.startToken = lexer.tokenCount  // Current token index
    // endToken will be set when GROUP_END is processed

    // NEW: Initialize flag group metadata (regular groups are not flag groups)
    lexer.tokens[lexer.tokenCount].groupInfo.isFlagGroup = false
    lexer.tokens[lexer.tokenCount].groupInfo.isGlobalFlagGroup = false
    lexer.tokens[lexer.tokenCount].groupInfo.isScopedFlagGroup = false
    lexer.tokens[lexer.tokenCount].groupInfo.hasColon = false

    #IF_DEFINED REGEX_LEXER_DEBUG
    if (isCapturing) {
        if (isNamed) {
            NAVLog("'[ Lexer ]: GROUP_START - Named group #', itoa(lexer.groupCount), ' (', groupName, ') at depth ', itoa(lexer.groupDepth)")
        }
        else {
            NAVLog("'[ Lexer ]: GROUP_START - Group #', itoa(lexer.groupCount), ' at depth ', itoa(lexer.groupDepth)")
        }
    }
    else {
        NAVLog("'[ Lexer ]: GROUP_START - Non-capturing at depth ', itoa(lexer.groupDepth)")
    }
    #END_IF

    return true
}


/**
 * @function NAVRegexLexerEmitFlagTokens
 * @private
 * @description Emit flag tokens based on which flags are enabled.
 *
 * Helper to reduce code duplication in flag group handling.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} openParenChar - The opening parenthesis character
 * @param {integer[4]} hasFlags - Array indicating which flags are present [i, m, s, x]
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerEmitFlagTokens(_NAVRegexLexer lexer,
                                                  char openParenChar,
                                                  integer hasFlags[]) {
    // Emit case-insensitive flag if present
    if (hasFlags[1]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_CASE_INSENSITIVE, true, openParenChar)) {
            return false
        }
    }

    // Emit multiline flag if present
    if (hasFlags[2]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_MULTILINE, true, openParenChar)) {
            return false
        }
    }

    // Emit dotall flag if present
    if (hasFlags[3]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_DOTALL, true, openParenChar)) {
            return false
        }
    }

    // Emit extended flag if present
    if (hasFlags[4]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_EXTENDED, true, openParenChar)) {
            return false
        }
    }

    return true
}


/**
 * @function NAVRegexLexerConsumeComment
 * @private
 * @description Handle inline comment groups: (?#comment text).
 *
 * Comments are ignored during matching and serve as documentation within patterns.
 * They are consumed and a token is emitted, but the comment text itself is not
 * stored as it's not needed for NFA construction.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} openParenChar - The opening parenthesis character
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerConsumeComment(_NAVRegexLexer lexer, char openParenChar) {
    stack_var char commentText[100]
    stack_var integer commentLength

    // Advance past '(?#'
    if (!NAVRegexLexerAdvanceCursorBy(lexer, 3)) {
        return false
    }

    commentText = ''
    commentLength = 0

    // Read until closing ) or end of pattern
    while (NAVRegexLexerHasMoreChars(lexer)) {
        stack_var char commentChar
        commentChar = NAVRegexLexerGetCurrentChar(lexer)

        if (commentChar == ')') {
            // End of comment - don't include the )
            break
        }

        if (commentLength < 100) {
            commentText = "commentText, commentChar"
            commentLength++
        }

        if (!NAVRegexLexerAdvanceCursor(lexer)) {
            return false
        }
    }

    // Verify we found closing )
    if (NAVRegexLexerGetCurrentChar(lexer) != ')') {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeComment',
                                    "'Unclosed comment - expected )'")
        return false
    }

    if (!NAVRegexLexerAddCommentToken(lexer, commentText, openParenChar)) {
        return false
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ Lexer ]: Comment detected: (?#', commentText, ')'")
    #END_IF

    return true
}


/**
 * @function NAVRegexLexerConsumeInlineFlags
 * @private
 * @description Handle inline flag groups: (?i), (?m), (?s), (?x), and combinations.
 *
 * Processes both global flags (?i) and scoped flags (?i:pattern).
 * Handles flag combinations like (?ims:pattern).
 *
 * Global flags apply to the rest of the pattern after the flag group.
 * Scoped flags only apply within the flag group.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} openParenChar - The opening parenthesis character
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerConsumeInlineFlags(_NAVRegexLexer lexer, char openParenChar) {
    stack_var char flagChar
    stack_var integer isGlobalFlag
    stack_var integer hasFlags[4]  // Track which flags we found to enable: [i, m, s, x]
    stack_var integer disableFlags[4]  // Track which flags we found to disable: [i, m, s, x]
    stack_var char foundDash  // Track if we've encountered the dash separator
    stack_var integer i

    // Initialize flags arrays
    for (i = 1; i <= 4; i++) {
        hasFlags[i] = false
        disableFlags[i] = false
    }

    isGlobalFlag = false
    foundDash = false

    // Advance past '(?'
    if (!NAVRegexLexerAdvanceCursorBy(lexer, 2)) {
        return false
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ Lexer ]: Starting flag collection loop at cursor=', itoa(lexer.pattern.cursor), ' length=', itoa(lexer.pattern.length)")
    #END_IF

    // First pass: collect which flags are present
    while (NAVRegexLexerHasMoreChars(lexer)) {
        flagChar = NAVRegexLexerGetCurrentChar(lexer)

        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ Lexer ]: Flag loop - cursor=', itoa(lexer.pattern.cursor), ' char=', flagChar, ' (', itoa(flagChar), ')'")
        #END_IF

        switch (flagChar) {
            case 'i': {
                if (foundDash) {
                    disableFlags[1] = true
                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Case-insensitive flag (i) to disable'")
                    #END_IF
                } else {
                    hasFlags[1] = true
                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Case-insensitive flag (i) to enable'")
                    #END_IF
                }
            }
            case 'm': {
                if (foundDash) {
                    disableFlags[2] = true
                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Multiline flag (m) to disable'")
                    #END_IF
                } else {
                    hasFlags[2] = true
                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Multiline flag (m) to enable'")
                    #END_IF
                }
            }
            case 's': {
                if (foundDash) {
                    disableFlags[3] = true
                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Dotall flag (s) to disable'")
                    #END_IF
                } else {
                    hasFlags[3] = true
                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Dotall flag (s) to enable'")
                    #END_IF
                }
            }
            case 'x': {
                if (foundDash) {
                    disableFlags[4] = true
                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Extended flag (x) to disable'")
                    #END_IF
                } else {
                    hasFlags[4] = true
                    #IF_DEFINED REGEX_LEXER_DEBUG
                    NAVLog("'[ Lexer ]: Extended flag (x) to enable'")
                    #END_IF
                }
            }
            case '-': {
                foundDash = true
                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: Dash separator detected - following flags will be disabled'")
                #END_IF
            }
            default: {
                // Invalid character in flag sequence
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                            'NAVRegexLexerConsumeInlineFlags',
                                            "'Invalid flag character: ', flagChar")
                return false
            }
        }

        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ Lexer ]: About to advance cursor from ', itoa(lexer.pattern.cursor)")
        #END_IF

        // Advance to next character
        if (!NAVRegexLexerAdvanceCursor(lexer)) {
            return false
        }

        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ Lexer ]: Advanced to cursor=', itoa(lexer.pattern.cursor), ' HasMoreChars()=', itoa(NAVRegexLexerHasMoreChars(lexer))")
        #END_IF

        // After advancing, check if we're at ) or : to avoid loop exit on HasMoreChars()
        // Use cursor <= length instead of HasMoreChars() because we need to read the last character
        if (lexer.pattern.cursor <= lexer.pattern.length) {
            stack_var char peekChar
            peekChar = NAVRegexLexerGetCurrentChar(lexer)

            #IF_DEFINED REGEX_LEXER_DEBUG
            NAVLog("'[ Lexer ]: Peeking at cursor=', itoa(lexer.pattern.cursor), ' char=', peekChar, ' (', itoa(peekChar), ')'")
            #END_IF

            if (peekChar == ')') {
                // Global flags: (?i) - flags apply for rest of pattern
                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: Global flag group - flags apply globally'")
                #END_IF

                isGlobalFlag = true
                break
            }
            else if (peekChar == ':') {
                // Scoped flags: (?i:...) - flags only apply within this group
                #IF_DEFINED REGEX_LEXER_DEBUG
                NAVLog("'[ Lexer ]: Scoped flag group - flags apply within group'")
                #END_IF

                break
            }
        }
        else {
            #IF_DEFINED REGEX_LEXER_DEBUG
            NAVLog("'[ Lexer ]: Cursor beyond pattern length - cannot peek'")
            #END_IF
        }
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ Lexer ]: Exited flag loop - cursor=', itoa(lexer.pattern.cursor), ' isGlobalFlag=', itoa(isGlobalFlag)")
    #END_IF

    // For global flags (?i), emit GROUP_START and flag tokens
    // Leave the cursor AT the ')' so the main tokenizer can handle GROUP_END naturally
    if (isGlobalFlag) {
        // Increment total group count
        lexer.groupTotal++

        if (lexer.groupTotal > MAX_REGEX_GROUPS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerConsumeInlineFlags',
                                        "'Too many groups (max: ', itoa(MAX_REGEX_GROUPS), ')'")
            return false
        }

        // Increment nesting depth (for all group types)
        if (!NAVRegexLexerIncrementGroupDepth(lexer)) {
            return false
        }

        // Track group on stack
        lexer.groupStack[lexer.groupDepth] = lexer.groupTotal

        // 1. Add GROUP_START token
        if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_GROUP_START, openParenChar)) {
            return false
        }

        // Populate group info (flag groups are non-capturing)
        lexer.tokens[lexer.tokenCount].groupInfo.number = 0  // Non-capturing
        lexer.tokens[lexer.tokenCount].groupInfo.name = ''
        lexer.tokens[lexer.tokenCount].groupInfo.isNamed = false
        lexer.tokens[lexer.tokenCount].groupInfo.isCapturing = false
        lexer.tokens[lexer.tokenCount].groupInfo.startToken = lexer.tokenCount

        // NEW: Set flag group metadata for global flag groups
        lexer.tokens[lexer.tokenCount].groupInfo.isFlagGroup = true
        lexer.tokens[lexer.tokenCount].groupInfo.isGlobalFlagGroup = true
        lexer.tokens[lexer.tokenCount].groupInfo.isScopedFlagGroup = false
        lexer.tokens[lexer.tokenCount].groupInfo.hasColon = false

        // 2. Add flag tokens - emit enabled flags first, then disabled flags
        // Emit enabled flags (hasFlags[] with enabled=true)
        if (hasFlags[1]) {
            if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_CASE_INSENSITIVE, true, openParenChar)) {
                return false
            }
        }
        if (hasFlags[2]) {
            if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_MULTILINE, true, openParenChar)) {
                return false
            }
        }
        if (hasFlags[3]) {
            if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_DOTALL, true, openParenChar)) {
                return false
            }
        }
        if (hasFlags[4]) {
            if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_EXTENDED, true, openParenChar)) {
                return false
            }
        }

        // Emit disabled flags (disableFlags[] with enabled=false)
        if (disableFlags[1]) {
            if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_CASE_INSENSITIVE, false, openParenChar)) {
                return false
            }
        }
        if (disableFlags[2]) {
            if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_MULTILINE, false, openParenChar)) {
                return false
            }
        }
        if (disableFlags[3]) {
            if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_DOTALL, false, openParenChar)) {
                return false
            }
        }
        if (disableFlags[4]) {
            if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_EXTENDED, false, openParenChar)) {
                return false
            }
        }

        #IF_DEFINED REGEX_LEXER_DEBUG
        NAVLog("'[ Lexer ]: GROUP_START - Global flag group #', itoa(lexer.groupTotal), ' (cursor left before closing paren)'")
        #END_IF

        // 3. Move cursor back by 1 so it's BEFORE the ')'
        // The main tokenizer loop will advance to ')' and call ConsumeGroupEnd()
        if (!NAVRegexLexerBacktrackCursor(lexer)) {
            return false
        }

        return true
    }

    // For scoped flags (?i:...), emit GROUP_START and flags
    // Then return to let the main tokenizer handle the content and closing paren

    // Increment total group count
    lexer.groupTotal++

    if (lexer.groupTotal > MAX_REGEX_GROUPS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeInlineFlags',
                                    "'Too many groups (max: ', itoa(MAX_REGEX_GROUPS), ')'")
        return false
    }

    // Increment nesting depth (for all group types)
    if (!NAVRegexLexerIncrementGroupDepth(lexer)) {
        return false
    }

    // Track group on stack
    lexer.groupStack[lexer.groupDepth] = lexer.groupTotal

    // 1. Add GROUP_START token
    if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_GROUP_START, openParenChar)) {
        return false
    }

    // Populate group info (scoped flag groups are non-capturing)
    lexer.tokens[lexer.tokenCount].groupInfo.number = 0  // Non-capturing
    lexer.tokens[lexer.tokenCount].groupInfo.name = ''
    lexer.tokens[lexer.tokenCount].groupInfo.isNamed = false
    lexer.tokens[lexer.tokenCount].groupInfo.isCapturing = false
    lexer.tokens[lexer.tokenCount].groupInfo.startToken = lexer.tokenCount

    // NEW: Set flag group metadata for scoped flag groups
    lexer.tokens[lexer.tokenCount].groupInfo.isFlagGroup = true
    lexer.tokens[lexer.tokenCount].groupInfo.isGlobalFlagGroup = false
    lexer.tokens[lexer.tokenCount].groupInfo.isScopedFlagGroup = true
    lexer.tokens[lexer.tokenCount].groupInfo.hasColon = true

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ Lexer ]: GROUP_START - Scoped flag group #', itoa(lexer.groupTotal)")
    #END_IF

    // 2. Add flag tokens - emit enabled flags first, then disabled flags
    // Emit enabled flags (hasFlags[] with enabled=true)
    if (hasFlags[1]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_CASE_INSENSITIVE, true, openParenChar)) {
            return false
        }
    }
    if (hasFlags[2]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_MULTILINE, true, openParenChar)) {
            return false
        }
    }
    if (hasFlags[3]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_DOTALL, true, openParenChar)) {
            return false
        }
    }
    if (hasFlags[4]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_EXTENDED, true, openParenChar)) {
            return false
        }
    }

    // Emit disabled flags (disableFlags[] with enabled=false)
    if (disableFlags[1]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_CASE_INSENSITIVE, false, openParenChar)) {
            return false
        }
    }
    if (disableFlags[2]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_MULTILINE, false, openParenChar)) {
            return false
        }
    }
    if (disableFlags[3]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_DOTALL, false, openParenChar)) {
            return false
        }
    }
    if (disableFlags[4]) {
        if (!NAVRegexLexerAddFlagToken(lexer, REGEX_TOKEN_FLAG_EXTENDED, false, openParenChar)) {
            return false
        }
    }

    #IF_DEFINED REGEX_LEXER_DEBUG
    NAVLog("'[ Lexer ]: Scoped flags emitted, cursor left at colon'")
    #END_IF

    // Cursor is currently AT the colon (:).
    // The main tokenizer loop will advance past it on the next iteration,
    // then process the first content character.
    return true
}


/**
 * @function NAVRegexLexerConsumeGroup
 * @private
 * @description Handle opening parenthesis and group start.
 *
 * This is the main entry point for processing all group types. It detects
 * the group type and delegates to specialized handlers for complex cases.
 *
 * **Group Types Handled:**
 * - Simple capturing: `(pattern)` → finalize directly
 * - Non-capturing: `(?:pattern)` → finalize directly
 * - Python named: `(?P<name>pattern)` → delegate to NAVRegexLexerConsumePythonNamedGroup
 * - .NET named: `(?<name>pattern)` → delegate to NAVRegexLexerConsumeLookbehindOrNamedGroup
 * - Lookahead: `(?=...)` or `(?!...)` → add special token, return
 * - Lookbehind: `(?<=...)` or `(?<!...)` → delegate to NAVRegexLexerConsumeLookbehindOrNamedGroup
 * - Inline flags: `(?i)`, `(?im:...)` → delegate to NAVRegexLexerConsumeInlineFlags
 * - Comments: `(?#text)` → delegate to NAVRegexLexerConsumeComment
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} openParenChar - The opening parenthesis character
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerConsumeGroup(_NAVRegexLexer lexer, char openParenChar) {
    stack_var char isCapturing
    stack_var char isNamed
    stack_var char groupName[MAX_REGEX_GROUP_NAME_LENGTH]
    stack_var char secondChar

    isCapturing = true  // Default to capturing group
    isNamed = false
    groupName = ''

    // If no special syntax (?...), handle as simple capturing group
    if (!NAVRegexLexerHasMoreChars(lexer)) {
        // Simple capturing group at end of pattern
        return NAVRegexLexerFinalizeGroupStart(lexer, openParenChar, isCapturing, isNamed, groupName)
    }

    if (NAVRegexLexerPeekNextChar(lexer) != '?') {
        // Simple capturing group (pattern)
        return NAVRegexLexerFinalizeGroupStart(lexer, openParenChar, isCapturing, isNamed, groupName)
    }

    // We have special syntax (? - check what type
    secondChar = NAVRegexLexerPeekChar(lexer, 2)

    if (!secondChar) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeGroup',
                                    "'Invalid group syntax - incomplete (? pattern'")
        return false
    }

    switch (secondChar) {
        case ':': {
            // Non-capturing group (?:...)
            isCapturing = false

            // Advance past '(?:'
            if (!NAVRegexLexerAdvanceCursorBy(lexer, 2)) {
                return false
            }

            #IF_DEFINED REGEX_LEXER_DEBUG
            NAVLog("'[ Lexer ]: Non-capturing group detected'")
            #END_IF

            // Fall through to finalization
            return NAVRegexLexerFinalizeGroupStart(lexer, openParenChar, isCapturing, isNamed, groupName)
        }
        case 'P': {
            // Python-style syntax - could be named group (?P<name>...) or named backreference (?P=name)
            stack_var char thirdChar

            // Check the third character to determine which type
            thirdChar = NAVRegexLexerPeekChar(lexer, 3)

            if (thirdChar == '<') {
                // Python-style named group (?P<name>...)
                return NAVRegexLexerConsumePythonNamedGroup(lexer, openParenChar)
            }
            else if (thirdChar == '=') {
                // Python-style named backreference (?P=name)
                return NAVRegexLexerConsumePythonNamedBackref(lexer, openParenChar)
            }
            else {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                            'NAVRegexLexerConsumeGroup',
                                            "'Invalid group syntax - (?P requires < or = after P'")
                return false
            }
        }
        case '=': {
            // Positive lookahead (?=...)
            // Advance past '(?='
            if (!NAVRegexLexerAdvanceCursorBy(lexer, 2)) {
                return false
            }

            // Increment total group count
            lexer.groupTotal++

            if (lexer.groupTotal > MAX_REGEX_GROUPS) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                            'NAVRegexLexerConsumeGroup',
                                            "'Too many groups (max: ', itoa(MAX_REGEX_GROUPS), ')'")
                return false
            }

            // Increment nesting depth
            if (!NAVRegexLexerIncrementGroupDepth(lexer)) {
                return false
            }

            // Track group on stack
            lexer.groupStack[lexer.groupDepth] = lexer.groupTotal

            // Add lookahead token
            if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_LOOKAHEAD_POSITIVE, openParenChar)) {
                return false
            }

            // Populate group info (lookaround groups are non-capturing)
            lexer.tokens[lexer.tokenCount].groupInfo.number = 0  // Non-capturing
            lexer.tokens[lexer.tokenCount].groupInfo.name = ''
            lexer.tokens[lexer.tokenCount].groupInfo.isNamed = false
            lexer.tokens[lexer.tokenCount].groupInfo.isCapturing = false
            lexer.tokens[lexer.tokenCount].groupInfo.startToken = lexer.tokenCount

            #IF_DEFINED REGEX_LEXER_DEBUG
            NAVLog("'[ Lexer ]: Positive lookahead detected (?=...) at depth ', itoa(lexer.groupDepth)")
            #END_IF

            return true
        }
        case '!': {
            // Negative lookahead (?!...)
            // Advance past '(?!'
            if (!NAVRegexLexerAdvanceCursorBy(lexer, 2)) {
                return false
            }

            // Increment total group count
            lexer.groupTotal++

            if (lexer.groupTotal > MAX_REGEX_GROUPS) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                            'NAVRegexLexerConsumeGroup',
                                            "'Too many groups (max: ', itoa(MAX_REGEX_GROUPS), ')'")
                return false
            }

            // Increment nesting depth
            if (!NAVRegexLexerIncrementGroupDepth(lexer)) {
                return false
            }

            // Track group on stack
            lexer.groupStack[lexer.groupDepth] = lexer.groupTotal

            // Add lookahead token
            if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_LOOKAHEAD_NEGATIVE, openParenChar)) {
                return false
            }

            // Populate group info (lookaround groups are non-capturing)
            lexer.tokens[lexer.tokenCount].groupInfo.number = 0  // Non-capturing
            lexer.tokens[lexer.tokenCount].groupInfo.name = ''
            lexer.tokens[lexer.tokenCount].groupInfo.isNamed = false
            lexer.tokens[lexer.tokenCount].groupInfo.isCapturing = false
            lexer.tokens[lexer.tokenCount].groupInfo.startToken = lexer.tokenCount

            #IF_DEFINED REGEX_LEXER_DEBUG
            NAVLog("'[ Lexer ]: Negative lookahead detected (?!...) at depth ', itoa(lexer.groupDepth)")
            #END_IF

            return true
        }
        case '<': {
            // Lookbehind assertions or .NET-style named group
            return NAVRegexLexerConsumeLookbehindOrNamedGroup(lexer, openParenChar)
        }
        case '''': {
            // .NET-style named group with single quotes (?'name'...)
            return NAVRegexLexerConsumeQuotedNamedGroup(lexer, openParenChar)
        }
        case '-':
        case 'i':
        case 'm':
        case 's':
        case 'x': {
            // Inline flags: (?i), (?m), (?s), (?x), (?-i), (?i-m), or combinations like (?im:...)
            return NAVRegexLexerConsumeInlineFlags(lexer, openParenChar)
        }
        case '#': {
            // Comment (?#...)
            return NAVRegexLexerConsumeComment(lexer, openParenChar)
        }
        default: {
            // Invalid (? pattern
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                        'NAVRegexLexerConsumeGroup',
                                        "'Invalid group syntax - (? must be followed by :, P<, <, '', =, !, i, m, s, x, -, or #'")
            return false
        }
    }
}


/**
 * @function NAVRegexLexerConsumeGroupEnd
 * @private
 * @description Handle closing parenthesis and group end.
 *
 * Validates matching opening parenthesis and updates group info.
 * The parser will handle matching quantifiers to groups.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure
 * @param {char} closeParenChar - The closing parenthesis character
 *
 * @returns {char} True (1) if successful, False (0) on error
 */
define_function char NAVRegexLexerConsumeGroupEnd(_NAVRegexLexer lexer, char closeParenChar) {
    stack_var integer groupIndex
    stack_var integer groupStartToken

    // First check if we have a matching opening parenthesis
    if (lexer.groupDepth <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_LEXER_HELPERS__,
                                    'NAVRegexLexerConsumeGroupEnd',
                                    "'Unmatched closing parenthesis `)` in pattern'")
        return false
    }

    // Get the GROUP_START token index from the stack
    groupStartToken = lexer.groupStack[lexer.groupDepth]

    // Add GROUP_END token
    if (!NAVRegexLexerAddToken(lexer, REGEX_TOKEN_GROUP_END, closeParenChar)) {
        return false
    }

    // Copy groupInfo from matching GROUP_START token to GROUP_END token
    lexer.tokens[lexer.tokenCount].groupInfo = lexer.tokens[groupStartToken].groupInfo

    // Update the endToken field to point to this GROUP_END token
    lexer.tokens[lexer.tokenCount].groupInfo.endToken = lexer.tokenCount

    // CRITICAL: Also update the GROUP_START token's endToken to point to this GROUP_END
    // This creates bidirectional linkage between GROUP_START and GROUP_END tokens
    lexer.tokens[groupStartToken].groupInfo.endToken = lexer.tokenCount

    #IF_DEFINED REGEX_LEXER_DEBUG
    if (lexer.tokens[lexer.tokenCount].groupInfo.isCapturing) {
        if (lexer.tokens[lexer.tokenCount].groupInfo.isNamed) {
            NAVLog("'[ Lexer ]: GROUP_END - Named group #', itoa(lexer.tokens[lexer.tokenCount].groupInfo.number), ' (', lexer.tokens[lexer.tokenCount].groupInfo.name, ') at depth ', itoa(lexer.groupDepth)")
        }
        else {
            NAVLog("'[ Lexer ]: GROUP_END - Group #', itoa(lexer.tokens[lexer.tokenCount].groupInfo.number), ' at depth ', itoa(lexer.groupDepth)")
        }
    }
    else {
        NAVLog("'[ Lexer ]: GROUP_END - Non-capturing at depth ', itoa(lexer.groupDepth)")
    }
    #END_IF

    // Decrement nesting depth
    lexer.groupDepth--

    return true
}


// ============================================================================
// DEBUG OUTPUT
// ============================================================================

/**
 * @function NAVRegexLexerPrintTokens
 * @public
 * @description Print all tokens in the lexer for debugging purposes.
 *
 * Outputs a formatted list of all tokens with their types and values.
 * Useful for debugging tokenization issues.
 *
 * @param {_NAVRegexLexer} lexer - The lexer structure containing tokens
 *
 * @returns {void}
 */
define_function NAVRegexLexerPrintTokens(_NAVRegexLexer lexer) {
    stack_var integer i
    stack_var integer j
    stack_var char c
    stack_var char message[255]

    if (lexer.tokenCount <= 0) {
        NAVLog('[]')
        return
    }

    for (i = 1; i <= lexer.tokenCount; i++) {
        message = "'  [', itoa(i), '] ', NAVRegexLexerGetTokenType(lexer.tokens[i].type)"

        // Show character value
        if (lexer.tokens[i].type == REGEX_TOKEN_CHAR) {
            message = "message, ' value="', lexer.tokens[i].value, '"'"
        }

        // Show flag enabled/disabled state
        if (lexer.tokens[i].type == REGEX_TOKEN_FLAG_CASE_INSENSITIVE ||
            lexer.tokens[i].type == REGEX_TOKEN_FLAG_MULTILINE ||
            lexer.tokens[i].type == REGEX_TOKEN_FLAG_DOTALL ||
            lexer.tokens[i].type == REGEX_TOKEN_FLAG_EXTENDED) {
            if (lexer.tokens[i].flagEnabled) {
                message = "message, ' [ENABLE]'"
            }
            else {
                message = "message, ' [DISABLE]'"
            }
        }

        // Show group information
        if (lexer.tokens[i].type == REGEX_TOKEN_GROUP_START ||
            lexer.tokens[i].type == REGEX_TOKEN_GROUP_END) {
            if (lexer.tokens[i].groupInfo.isCapturing) {
                message = "message, ' (capturing #', itoa(lexer.tokens[i].groupInfo.number), ')'"
            }
            else {
                message = "message, ' (non-capturing)'"
            }

            if (lexer.tokens[i].groupInfo.isNamed) {
                message = "message, ' name="', lexer.tokens[i].groupInfo.name, '"'"
            }

            // NEW: Show flag group metadata
            if (lexer.tokens[i].groupInfo.isFlagGroup) {
                if (lexer.tokens[i].groupInfo.isGlobalFlagGroup) {
                    message = "message, ' [GLOBAL_FLAGS]'"
                }
                else if (lexer.tokens[i].groupInfo.isScopedFlagGroup) {
                    message = "message, ' [SCOPED_FLAGS]'"
                }
            }
        }

        // Show quantifier bounds
        if (lexer.tokens[i].type == REGEX_TOKEN_QUANTIFIER) {
            message = "message, ' {', itoa(lexer.tokens[i].min), ','"
            if (lexer.tokens[i].max < 0) {
                message = "message, 'inf}'"
            }
            else {
                message = "message, itoa(lexer.tokens[i].max), '}'"
            }
        }

        // Show lazy modifier
        if (lexer.tokens[i].isLazy) {
            message = "message, ' (lazy)'"
        }

        // Show negation flag
        if (lexer.tokens[i].isNegated) {
            message = "message, ' [NEGATED]'"
        }

        // Show named backreference
        if (lexer.tokens[i].type == REGEX_TOKEN_BACKREF_NAMED) {
            message = "message, ' name="', lexer.tokens[i].name, '"'"
        }

        // Show numeric escape metadata
        if (lexer.tokens[i].type == REGEX_TOKEN_NUMERIC_ESCAPE) {
            message = "message, ' digits="', lexer.tokens[i].numericEscapeDigits, '"'"
            if (lexer.tokens[i].numericEscapeLeadingZero) {
                message = "message, ' (leading zero)'"
            }
        }

        // Show character class details
        if (lexer.tokens[i].type == REGEX_TOKEN_CHAR_CLASS ||
            lexer.tokens[i].type == REGEX_TOKEN_INV_CHAR_CLASS) {
            message = "message, ' ranges=', itoa(lexer.tokens[i].charclass.rangeCount)"

            if (lexer.tokens[i].charclass.hasDigits) {
                message = "message, ' +\d'"
            }

            if (lexer.tokens[i].charclass.hasWordChars) {
                message = "message, ' +\w'"
            }

            if (lexer.tokens[i].charclass.hasWhitespace) {
                message = "message, ' +\s'"
            }
        }

        NAVLog(message)
    }
}


#END_IF // __NAV_FOUNDATION_REGEX_LEXER_HELPERS__
