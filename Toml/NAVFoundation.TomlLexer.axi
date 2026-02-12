PROGRAM_NAME='NAVFoundation.TomlLexer'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TOML_LEXER__
#DEFINE __NAV_FOUNDATION_TOML_LEXER__ 'NAVFoundation.TomlLexer'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.TomlLexer.h.axi'


// =============================================================================
// LEXER CORE FUNCTIONS
// =============================================================================

/**
 * @function NAVTomlLexerInit
 * @private
 * @description Initialize a TOML lexer with source text.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure to initialize
 * @param {char[]} source - The source text to tokenize
 *
 * @returns {void}
 */
define_function NAVTomlLexerInit(_NAVTomlLexer lexer, char source[]) {
    lexer.source = source
    lexer.cursor = 1
    lexer.start = 1
    lexer.line = 1
    lexer.column = 1
    lexer.tokenCount = 0
    lexer.hasError = false
    lexer.error = ''
}


/**
 * @function NAVTomlLexerSetError
 * @private
 * @description Set an error state on the lexer.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 * @param {char[]} message - Error message
 *
 * @returns {void}
 */
define_function NAVTomlLexerSetError(_NAVTomlLexer lexer, char message[]) {
    lexer.hasError = true
    lexer.error = message

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                __NAV_FOUNDATION_TOML_LEXER__,
                                'NAVTomlLexer',
                                "message, ' at line ', itoa(lexer.line), ', column ', itoa(lexer.column)")
}


/**
 * @function NAVTomlLexerEmitToken
 * @private
 * @description Emit a token of the specified type with the current lexer position.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 * @param {integer} type - The token type to emit
 *
 * @returns {char} True (1) if token emitted successfully, False (0) if token limit reached
 */
define_function char NAVTomlLexerEmitToken(_NAVTomlLexer lexer, integer type) {
    stack_var char tokenValue[NAV_TOML_LEXER_MAX_TOKEN_LENGTH]

    if (!NAVTomlLexerCanAddToken(lexer)) {
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = type

    // Extract the token value
    tokenValue = NAVStringSlice(lexer.source, lexer.start, lexer.cursor)

    // Strip underscores from numeric literals (TOML allows them for readability)
    if (type == NAV_TOML_TOKEN_TYPE_INTEGER || type == NAV_TOML_TOKEN_TYPE_FLOAT) {
        tokenValue = NAVStringReplace(tokenValue, '_', '')
    }

    lexer.tokens[lexer.tokenCount].value = tokenValue
    lexer.tokens[lexer.tokenCount].start = lexer.start
    lexer.tokens[lexer.tokenCount].end = lexer.cursor - 1
    lexer.tokens[lexer.tokenCount].line = lexer.line
    lexer.tokens[lexer.tokenCount].column = lexer.column - (lexer.cursor - lexer.start)
    set_length_array(lexer.tokens, lexer.tokenCount)

    lexer.start = lexer.cursor

    #IF_DEFINED TOML_LEXER_DEBUG
    NAVLog("'[ TomlLexerEmitToken ]: type=', NAVTomlLexerGetTokenType(type), ' value="', lexer.tokens[lexer.tokenCount].value, '" line=', itoa(lexer.line), ' col=', itoa(lexer.tokens[lexer.tokenCount].column)")
    #END_IF

    return true
}


/**
 * @function NAVTomlLexerIgnore
 * @private
 * @description Ignore the current token by advancing the start position to the cursor.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} Always returns True (1)
 */
define_function char NAVTomlLexerIgnore(_NAVTomlLexer lexer) {
    lexer.start = lexer.cursor

    return true
}


/**
 * @function NAVTomlLexerIsEOF
 * @private
 * @description Check if the lexer has reached the end of the source text.
 *
 * @param {_NAVTomlLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if at end of file, False (0) otherwise
 */
define_function char NAVTomlLexerIsEOF(_NAVTomlLexer lexer) {
    return type_cast(lexer.cursor > length_array(lexer.source))
}


/**
 * @function NAVTomlLexerNext
 * @private
 * @description Advance the cursor by one character, tracking line/column.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} The consumed character, or 0 if EOF
 */
define_function char NAVTomlLexerNext(_NAVTomlLexer lexer) {
    stack_var char ch

    if (NAVTomlLexerIsEOF(lexer)) {
        return 0
    }

    ch = type_cast(lexer.source[lexer.cursor])
    lexer.cursor++
    lexer.column++

    // Track newlines
    if (ch == NAV_LF) {
        lexer.line++
        lexer.column = 1
    }
    else if (ch == NAV_CR) {
        // Handle CRLF
        if (!NAVTomlLexerIsEOF(lexer) && type_cast(lexer.source[lexer.cursor]) == NAV_LF) {
            lexer.cursor++
        }

        lexer.line++
        lexer.column = 1
    }

    return ch
}


/**
 * @function NAVTomlLexerPeek
 * @private
 * @description Peek at the next character in the source without consuming it.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} The next character, or 0 if unable to peek
 */
define_function char NAVTomlLexerPeek(_NAVTomlLexer lexer) {
    if (NAVTomlLexerIsEOF(lexer)) {
        return 0
    }

    return type_cast(lexer.source[lexer.cursor])
}


/**
 * @function NAVTomlLexerPeekAhead
 * @private
 * @description Peek at a character n positions ahead without consuming.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 * @param {integer} offset - Number of positions ahead to peek (1 = next, 2 = next next, etc.)
 *
 * @returns {char} The character at the offset, or 0 if beyond bounds
 */
define_function char NAVTomlLexerPeekAhead(_NAVTomlLexer lexer, integer offset) {
    stack_var long pos

    pos = lexer.cursor + offset - 1

    if (pos < 1 || pos > length_array(lexer.source)) {
        return 0
    }

    return type_cast(lexer.source[pos])
}


/**
 * @function NAVTomlLexerCanAddToken
 * @private
 * @description Check if the lexer can accept another token without exceeding the maximum limit.
 *
 * @param {_NAVTomlLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if token can be added, False (0) if limit reached
 */
define_function char NAVTomlLexerCanAddToken(_NAVTomlLexer lexer) {
    if (lexer.tokenCount >= NAV_TOML_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_TOML_LEXER__,
                                    'NAVTomlLexerCanAddToken',
                                    "'Exceeded maximum token limit (', itoa(NAV_TOML_LEXER_MAX_TOKENS), ')'")
        return false
    }

    return true
}


/**
 * @function NAVTomlLexerIsWhitespace
 * @private
 * @description Check if a character is whitespace (space or tab only, not newline).
 * TOML defines whitespace as space (0x20) or tab (0x09).
 *
 * @param {char} ch - The character to check
 *
 * @returns {char} True (1) if whitespace, False (0) otherwise
 */
define_function char NAVTomlLexerIsWhitespace(char ch) {
    return ch == ' ' || ch == NAV_TAB
}


/**
 * @function NAVTomlLexerIsNewline
 * @private
 * @description Check if a character is a newline (LF or CR).
 *
 * @param {char} ch - The character to check
 *
 * @returns {char} True (1) if newline, False (0) otherwise
 */
define_function char NAVTomlLexerIsNewline(char ch) {
    return ch == NAV_LF || ch == NAV_CR
}


/**
 * @function NAVTomlLexerIsAlpha
 * @private
 * @description Check if a character is alphabetic (A-Z, a-z).
 *
 * @param {char} ch - The character to check
 *
 * @returns {char} True (1) if alphabetic, False (0) otherwise
 */
define_function char NAVTomlLexerIsAlpha(char ch) {
    return (ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z')
}


/**
 * @function NAVTomlLexerIsDigit
 * @private
 * @description Check if a character is a digit (0-9).
 *
 * @param {char} ch - The character to check
 *
 * @returns {char} True (1) if digit, False (0) otherwise
 */
define_function char NAVTomlLexerIsDigit(char ch) {
    return ch >= '0' && ch <= '9'
}


/**
 * @function NAVTomlLexerIsHexDigit
 * @private
 * @description Check if a character is a hexadecimal digit (0-9, A-F, a-f).
 *
 * @param {char} ch - The character to check
 *
 * @returns {char} True (1) if hex digit, False (0) otherwise
 */
define_function char NAVTomlLexerIsHexDigit(char ch) {
    return NAVTomlLexerIsDigit(ch) ||
           (ch >= 'A' && ch <= 'F') ||
           (ch >= 'a' && ch <= 'f')
}


/**
 * @function NAVTomlLexerIsBareKeyChar
 * @private
 * @description Check if a character is valid in a bare key.
 * Bare keys can contain: A-Z, a-z, 0-9, -, _
 *
 * @param {char} ch - The character to check
 *
 * @returns {char} True (1) if valid bare key character, False (0) otherwise
 */
define_function char NAVTomlLexerIsBareKeyChar(char ch) {
    return NAVTomlLexerIsAlpha(ch) ||
           NAVTomlLexerIsDigit(ch) ||
           ch == '-' ||
           ch == '_'
}


/**
 * @function NAVTomlLexerIsControlChar
 * @private
 * @description Check if a character is a control character (0x00-0x1F, 0x7F).
 * Tab (0x09) is excluded as it's allowed in TOML strings.
 *
 * @param {char} ch - The character to check
 *
 * @returns {char} True (1) if control character (excluding tab), False (0) otherwise
 */
define_function char NAVTomlLexerIsControlChar(char ch) {
    return (ch >= 0 && ch <= 31 && ch != 9) || ch == 127
}


/**
 * @function NAVTomlLexerValidateNumberUnderscores
 * @private
 * @description Validate underscore placement in a number string.
 * Rules: No leading/trailing underscores, no consecutive underscores.
 *
 * @param {char[]} numStr - The number string to validate (without sign)
 *
 * @returns {char} True (1) if valid, False (0) if invalid underscore placement
 */
define_function char NAVTomlLexerValidateNumberUnderscores(char numStr[]) {
    stack_var integer i
    stack_var integer len

    len = length_array(numStr)

    if (len == 0) {
        return true
    }

    // Check for leading underscore
    if (numStr[1] == '_') {
        return false
    }

    // Check for trailing underscore
    if (numStr[len] == '_') {
        return false
    }

    // Check for consecutive underscores
    for (i = 1; i < len; i++) {
        if (numStr[i] == '_' && numStr[i + 1] == '_') {
            return false
        }
    }

    return true
}


// =============================================================================
// WHITESPACE AND COMMENT HANDLING
// =============================================================================

/**
 * @function NAVTomlLexerSkipWhitespace
 * @private
 * @description Skip whitespace characters (space and tab only, not newlines).
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} Always returns True (1)
 */
define_function char NAVTomlLexerSkipWhitespace(_NAVTomlLexer lexer) {
    while (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerIsWhitespace(NAVTomlLexerPeek(lexer))) {
        NAVTomlLexerNext(lexer)
    }

    return NAVTomlLexerIgnore(lexer)
}


/**
 * @function NAVTomlLexerConsumeComment
 * @private
 * @description Consume a comment starting with # until end of line.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} Always returns True (1)
 */
define_function char NAVTomlLexerConsumeComment(_NAVTomlLexer lexer) {
    // Skip the # character
    NAVTomlLexerNext(lexer)

    // Consume until newline or EOF
    while (!NAVTomlLexerIsEOF(lexer) && !NAVTomlLexerIsNewline(NAVTomlLexerPeek(lexer))) {
        NAVTomlLexerNext(lexer)
    }

    #IF_DEFINED TOML_LEXER_DEBUG
    NAVLog("'[ TomlLexerConsumeComment ]: Comment consumed: "', NAVStringSlice(lexer.source, lexer.start, lexer.cursor), '"'")
    #END_IF

    // Emit comment token
    return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_COMMENT)
}


// =============================================================================
// STRING TOKENIZATION
// =============================================================================

/**
 * @function NAVTomlLexerConsumeBasicString
 * @private
 * @description Consume a basic string literal ("string").
 * Supports TOML 1.1.0 escape sequences including \e (ESC), \xHH (hex bytes), and Unicode.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if success, False (0) if unterminated or invalid
 */
define_function char NAVTomlLexerConsumeBasicString(_NAVTomlLexer lexer) {
    // Skip opening quote
    NAVTomlLexerNext(lexer)

    while (!NAVTomlLexerIsEOF(lexer)) {
        stack_var char ch

        ch = NAVTomlLexerPeek(lexer)

        if (ch == '"') {
            // Found closing quote
            NAVTomlLexerNext(lexer)
            return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_STRING)
        }
        else if (ch == '\') {
            // Escape sequence
            NAVTomlLexerNext(lexer) // Consume backslash

            if (NAVTomlLexerIsEOF(lexer)) {
                NAVTomlLexerSetError(lexer, 'Unterminated string literal')
                return false
            }

            ch = NAVTomlLexerPeek(lexer)

            // Validate escape sequence
            if (ch == 'b' || ch == 't' || ch == 'n' || ch == 'f' || ch == 'r' ||
                ch == '"' || ch == '\' || ch == 'u' || ch == 'U' || ch == 'e' || ch == 'x') {
                NAVTomlLexerNext(lexer)

                // Handle unicode escapes
                if (ch == 'u') {
                    // \uXXXX - 4 hex digits
                    stack_var integer i

                    for (i = 1; i <= 4; i++) {
                        if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsHexDigit(NAVTomlLexerPeek(lexer))) {
                            NAVTomlLexerSetError(lexer, 'Invalid unicode escape sequence')
                            return false
                        }

                        NAVTomlLexerNext(lexer)
                    }
                }
                else if (ch == 'U') {
                    // \UXXXXXXXX - 8 hex digits
                    stack_var integer j

                    for (j = 1; j <= 8; j++) {
                        if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsHexDigit(NAVTomlLexerPeek(lexer))) {
                            NAVTomlLexerSetError(lexer, 'Invalid unicode escape sequence')
                            return false
                        }

                        NAVTomlLexerNext(lexer)
                    }
                }
                else if (ch == 'x') {
                    // \xHH - exactly 2 hex digits
                    stack_var integer k

                    for (k = 1; k <= 2; k++) {
                        if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsHexDigit(NAVTomlLexerPeek(lexer))) {
                            NAVTomlLexerSetError(lexer, 'Invalid hex escape: expected 2 hex digits after \x')
                            return false
                        }

                        NAVTomlLexerNext(lexer)
                    }
                }
            }
            else {
                NAVTomlLexerSetError(lexer, "'Invalid escape sequence: \', ch")
                return false
            }
        }
        else if (NAVTomlLexerIsNewline(ch)) {
            // Unescaped newline in basic string
            NAVTomlLexerSetError(lexer, 'Newline not allowed in basic string')
            return false
        }
        else if (NAVTomlLexerIsControlChar(ch)) {
            // Control characters not allowed in basic strings
            NAVTomlLexerSetError(lexer, "'Control character not allowed in string: 0x', itoa(ch)")
            return false
        }
        else {
            NAVTomlLexerNext(lexer)
        }
    }

    NAVTomlLexerSetError(lexer, 'Unterminated string literal')
    return false
}


/**
 * @function NAVTomlLexerConsumeLiteralString
 * @private
 * @description Consume a literal string ('string').
 * No escape sequences allowed.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if success, False (0) if unterminated
 */
define_function char NAVTomlLexerConsumeLiteralString(_NAVTomlLexer lexer) {
    // Skip opening quote
    NAVTomlLexerNext(lexer)

    while (!NAVTomlLexerIsEOF(lexer)) {
        stack_var char ch

        ch = NAVTomlLexerPeek(lexer)

        if (ch == '''') {
            // Found closing quote
            NAVTomlLexerNext(lexer)
            return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_STRING)
        }
        else if (NAVTomlLexerIsNewline(ch)) {
            // Newline not allowed in literal string
            NAVTomlLexerSetError(lexer, 'Newline not allowed in literal string')
            return false
        }
        else if (NAVTomlLexerIsControlChar(ch)) {
            // Control characters not allowed in literal strings
            NAVTomlLexerSetError(lexer, "'Control character not allowed in string: 0x', itoa(ch)")
            return false
        }
        else {
            NAVTomlLexerNext(lexer)
        }
    }

    NAVTomlLexerSetError(lexer, 'Unterminated string literal')
    return false
}


/**
 * @function NAVTomlLexerConsumeMultilineBasicString
 * @private
 * @description Consume a multiline basic string ("""string""").
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if success, False (0) if unterminated
 */
define_function char NAVTomlLexerConsumeMultilineBasicString(_NAVTomlLexer lexer) {
    // Skip opening """
    NAVTomlLexerNext(lexer) // First "
    NAVTomlLexerNext(lexer) // Second "
    NAVTomlLexerNext(lexer) // Third "

    // Skip optional newline immediately after opening """
    if (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerIsNewline(NAVTomlLexerPeek(lexer))) {
        NAVTomlLexerNext(lexer)
    }

    while (!NAVTomlLexerIsEOF(lexer)) {
        stack_var char ch

        ch = NAVTomlLexerPeek(lexer)

        if (ch == '"') {
            // Check for closing """
            if (NAVTomlLexerPeekAhead(lexer, 2) == '"' && NAVTomlLexerPeekAhead(lexer, 3) == '"') {
                NAVTomlLexerNext(lexer) // First "
                NAVTomlLexerNext(lexer) // Second "
                NAVTomlLexerNext(lexer) // Third "

                return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_MULTILINE_STRING)
            }
            else {
                NAVTomlLexerNext(lexer)
            }
        }
        else if (ch == '\') {
            // Escape sequence or line-ending backslash
            NAVTomlLexerNext(lexer)

            if (!NAVTomlLexerIsEOF(lexer)) {
                ch = NAVTomlLexerPeek(lexer)

                // Line-ending backslash (escapes the newline)
                if (NAVTomlLexerIsNewline(ch) || NAVTomlLexerIsWhitespace(ch)) {
                    while (!NAVTomlLexerIsEOF(lexer) &&
                           (NAVTomlLexerIsWhitespace(NAVTomlLexerPeek(lexer)) ||
                            NAVTomlLexerIsNewline(NAVTomlLexerPeek(lexer)))) {
                        NAVTomlLexerNext(lexer)
                    }
                }
                else {
                    // Regular escape sequence (validate same as basic string)
                    if (ch == 'b' || ch == 't' || ch == 'n' || ch == 'f' || ch == 'r' ||
                        ch == '"' || ch == '\' || ch == 'u' || ch == 'U' || ch == 'e' || ch == 'x') {
                        NAVTomlLexerNext(lexer)
                    }
                    else {
                        NAVTomlLexerSetError(lexer, "'Invalid escape sequence: \', ch")
                        return false
                    }
                }
            }
        }
        else {
            NAVTomlLexerNext(lexer)
        }
    }

    NAVTomlLexerSetError(lexer, 'Unterminated multiline string')
    return false
}


/**
 * @function NAVTomlLexerConsumeMultilineLiteralString
 * @private
 * @description Consume a multiline literal string ('''string''').
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if success, False (0) if unterminated
 */
define_function char NAVTomlLexerConsumeMultilineLiteralString(_NAVTomlLexer lexer) {
    // Skip opening '''
    NAVTomlLexerNext(lexer) // First '
    NAVTomlLexerNext(lexer) // Second '
    NAVTomlLexerNext(lexer) // Third '

    // Skip optional newline immediately after opening '''
    if (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerIsNewline(NAVTomlLexerPeek(lexer))) {
        NAVTomlLexerNext(lexer)
    }

    while (!NAVTomlLexerIsEOF(lexer)) {
        stack_var char ch

        ch = NAVTomlLexerPeek(lexer)

        if (ch == '''') {
            // Check for closing '''
            if (NAVTomlLexerPeekAhead(lexer, 2) == '''' && NAVTomlLexerPeekAhead(lexer, 3) == '''') {
                NAVTomlLexerNext(lexer) // First '
                NAVTomlLexerNext(lexer) // Second '
                NAVTomlLexerNext(lexer) // Third '

                return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_MULTILINE_STRING)
            }
            else {
                NAVTomlLexerNext(lexer)
            }
        }
        else {
            NAVTomlLexerNext(lexer)
        }
    }

    NAVTomlLexerSetError(lexer, 'Unterminated multiline literal string')
    return false
}


// =============================================================================
// NUMBER TOKENIZATION
// =============================================================================

/**
 * @function NAVTomlLexerConsumeNumber
 * @private
 * @description Consume a number (integer or float).
 * Supports: decimal, hex (0x), octal (0o), binary (0b), floats, inf, nan.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if success, False (0) if invalid number format
 */
define_function char NAVTomlLexerConsumeNumber(_NAVTomlLexer lexer) {
    stack_var char ch
    stack_var char isFloat
    stack_var integer tokenType
    stack_var char hexValue[NAV_TOML_LEXER_MAX_TOKEN_LENGTH]
    stack_var integer hexStart
    stack_var char octValue[NAV_TOML_LEXER_MAX_TOKEN_LENGTH]
    stack_var integer octStart
    stack_var char binValue[NAV_TOML_LEXER_MAX_TOKEN_LENGTH]
    stack_var integer binStart
    stack_var integer intPartStart
    stack_var char intPartValue[NAV_TOML_LEXER_MAX_TOKEN_LENGTH]
    stack_var integer fracStart
    stack_var char fracValue[NAV_TOML_LEXER_MAX_TOKEN_LENGTH]
    stack_var integer expStart
    stack_var char expValue[NAV_TOML_LEXER_MAX_TOKEN_LENGTH]

    isFloat = false
    tokenType = NAV_TOML_TOKEN_TYPE_INTEGER

    ch = NAVTomlLexerPeek(lexer)

    // Check for sign
    if (ch == '+' || ch == '-') {
        NAVTomlLexerNext(lexer)
    }

    if (NAVTomlLexerIsEOF(lexer)) {
        NAVTomlLexerSetError(lexer, 'Invalid number format')
        return false
    }

    ch = NAVTomlLexerPeek(lexer)

    // Special float values: inf, nan
    if (NAVTomlLexerIsAlpha(ch)) {
        stack_var char value[10]
        stack_var integer len

        // Consume alphabetic characters
        while (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerIsAlpha(NAVTomlLexerPeek(lexer))) {
            NAVTomlLexerNext(lexer)
        }

        value = NAVStringSlice(lexer.source, type_cast(lexer.start), type_cast(lexer.cursor))
        len = length_array(value)

        // Remove sign if present
        if (value[1] == '+' || value[1] == '-') {
            value = right_string(value, len - 1)
        }

        if (value == 'inf' || value == 'nan') {
            return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_FLOAT)
        }
        else {
            NAVTomlLexerSetError(lexer, "'Invalid number format: ', value")
            return false
        }
    }

    // Check for base prefix (0x, 0o, 0b) or reject leading zeros
    if (ch == '0' && !NAVTomlLexerIsEOF(lexer)) {
        stack_var char nextCh

        nextCh = NAVTomlLexerPeekAhead(lexer, 2)

        if (nextCh == 'x' || nextCh == 'X') {
            // Hexadecimal
            NAVTomlLexerNext(lexer) // 0
            NAVTomlLexerNext(lexer) // x

            hexStart = lexer.cursor

            if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsHexDigit(NAVTomlLexerPeek(lexer))) {
                NAVTomlLexerSetError(lexer, 'Invalid hexadecimal number')
                return false
            }

            while (!NAVTomlLexerIsEOF(lexer) &&
                   (NAVTomlLexerIsHexDigit(NAVTomlLexerPeek(lexer)) || NAVTomlLexerPeek(lexer) == '_')) {
                NAVTomlLexerNext(lexer)
            }

            // Validate underscore placement
            hexValue = NAVStringSlice(lexer.source, type_cast(hexStart), type_cast(lexer.cursor))
            if (!NAVTomlLexerValidateNumberUnderscores(hexValue)) {
                NAVTomlLexerSetError(lexer, 'Invalid underscore placement in hexadecimal number')
                return false
            }

            return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_INTEGER)
        }
        else if (nextCh == 'o' || nextCh == 'O') {
            // Octal
            NAVTomlLexerNext(lexer) // 0
            NAVTomlLexerNext(lexer) // o

            octStart = lexer.cursor

            if (NAVTomlLexerIsEOF(lexer)) {
                NAVTomlLexerSetError(lexer, 'Invalid octal number')
                return false
            }

            ch = NAVTomlLexerPeek(lexer)
            if (ch < '0' || ch > '7') {
                NAVTomlLexerSetError(lexer, 'Invalid octal number')
                return false
            }

            while (!NAVTomlLexerIsEOF(lexer)) {
                ch = NAVTomlLexerPeek(lexer)
                if ((ch >= '0' && ch <= '7') || ch == '_') {
                    NAVTomlLexerNext(lexer)
                }
                else {
                    break
                }
            }

            // Validate underscore placement
            octValue = NAVStringSlice(lexer.source, type_cast(octStart), type_cast(lexer.cursor))
            if (!NAVTomlLexerValidateNumberUnderscores(octValue)) {
                NAVTomlLexerSetError(lexer, 'Invalid underscore placement in octal number')
                return false
            }

            return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_INTEGER)
        }
        else if (nextCh == 'b' || nextCh == 'B') {
            // Binary
            NAVTomlLexerNext(lexer) // 0
            NAVTomlLexerNext(lexer) // b

            binStart = lexer.cursor

            if (NAVTomlLexerIsEOF(lexer)) {
                NAVTomlLexerSetError(lexer, 'Invalid binary number')
                return false
            }

            ch = NAVTomlLexerPeek(lexer)
            if (ch != '0' && ch != '1') {
                NAVTomlLexerSetError(lexer, 'Invalid binary number')
                return false
            }

            while (!NAVTomlLexerIsEOF(lexer)) {
                ch = NAVTomlLexerPeek(lexer)
                if (ch == '0' || ch == '1' || ch == '_') {
                    NAVTomlLexerNext(lexer)
                }
                else {
                    break
                }
            }

            // Validate underscore placement
            binValue = NAVStringSlice(lexer.source, type_cast(binStart), type_cast(lexer.cursor))
            if (!NAVTomlLexerValidateNumberUnderscores(binValue)) {
                NAVTomlLexerSetError(lexer, 'Invalid underscore placement in binary number')
                return false
            }

            return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_INTEGER)
        }
        // Leading zero rejection - only '0' by itself is valid for decimal
        else if (NAVTomlLexerIsDigit(nextCh)) {
            NAVTomlLexerSetError(lexer, 'Leading zeros not allowed in decimal numbers')
            return false
        }
    }

    // Decimal number (integer or float)
    // Consume integer part
    intPartStart = lexer.cursor

    while (!NAVTomlLexerIsEOF(lexer)) {
        ch = NAVTomlLexerPeek(lexer)

        if (NAVTomlLexerIsDigit(ch) || ch == '_') {
            NAVTomlLexerNext(lexer)
        }
        else {
            break
        }
    }

    // Validate underscore placement in integer part
    intPartValue = NAVStringSlice(lexer.source, type_cast(intPartStart), type_cast(lexer.cursor))
    if (!NAVTomlLexerValidateNumberUnderscores(intPartValue)) {
        NAVTomlLexerSetError(lexer, 'Invalid underscore placement in integer')
        return false
    }

    if (NAVTomlLexerIsEOF(lexer)) {
        return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_INTEGER)
    }

    ch = NAVTomlLexerPeek(lexer)

    // Check for decimal point (float)
    if (ch == '.') {
        isFloat = true
        NAVTomlLexerNext(lexer)

        fracStart = lexer.cursor

        // Consume fractional part
        if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
            NAVTomlLexerSetError(lexer, 'Invalid float format: expected digit after decimal point')
            return false
        }

        while (!NAVTomlLexerIsEOF(lexer)) {
            ch = NAVTomlLexerPeek(lexer)

            if (NAVTomlLexerIsDigit(ch) || ch == '_') {
                NAVTomlLexerNext(lexer)
            }
            else {
                break
            }
        }

        // Validate underscore placement in fractional part
        fracValue = NAVStringSlice(lexer.source, type_cast(fracStart), type_cast(lexer.cursor))
        if (!NAVTomlLexerValidateNumberUnderscores(fracValue)) {
            NAVTomlLexerSetError(lexer, 'Invalid underscore placement in float fractional part')
            return false
        }

        if (NAVTomlLexerIsEOF(lexer)) {
            return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_FLOAT)
        }

        ch = NAVTomlLexerPeek(lexer)
    }

    // Check for exponent (float)
    if (ch == 'e' || ch == 'E') {
        isFloat = true
        NAVTomlLexerNext(lexer)

        if (NAVTomlLexerIsEOF(lexer)) {
            NAVTomlLexerSetError(lexer, 'Invalid float format: expected exponent')
            return false
        }

        ch = NAVTomlLexerPeek(lexer)

        // Optional sign in exponent
        if (ch == '+' || ch == '-') {
            NAVTomlLexerNext(lexer)
        }

        if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
            NAVTomlLexerSetError(lexer, 'Invalid float format: expected digit in exponent')
            return false
        }

        expStart = lexer.cursor

        // Consume exponent digits
        while (!NAVTomlLexerIsEOF(lexer)) {
            ch = NAVTomlLexerPeek(lexer)

            if (NAVTomlLexerIsDigit(ch) || ch == '_') {
                NAVTomlLexerNext(lexer)
            }
            else {
                break
            }
        }

        // Validate underscore placement in exponent
        expValue = NAVStringSlice(lexer.source, type_cast(expStart), type_cast(lexer.cursor))
        if (!NAVTomlLexerValidateNumberUnderscores(expValue)) {
            NAVTomlLexerSetError(lexer, 'Invalid underscore placement in exponent')
            return false
        }
    }

    if (isFloat) {
        return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_FLOAT)
    }
    else {
        return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_INTEGER)
    }
}


// =============================================================================
// DATE/TIME TOKENIZATION
// =============================================================================

/**
 * @function NAVTomlLexerConsumeDateTime
 * @private
 * @description Consume a date, time, or datetime value.
 * Supports: YYYY-MM-DD, HH:MM[:SS], YYYY-MM-DD[T| ]HH:MM[:SS]
 * TOML 1.1.0: Seconds are now optional in time values
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if success, False (0) if invalid format
 */
define_function char NAVTomlLexerConsumeDateTime(_NAVTomlLexer lexer) {
    stack_var char hasDate
    stack_var char hasTime
    stack_var integer i

    hasDate = false
    hasTime = false

    // Try to parse date part: YYYY-MM-DD
    // Check if we have YYYY-MM-DD pattern
    if (NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
        stack_var integer digitCount
        stack_var char ch

        // Consume year (4 digits)
        for (i = 1; i <= 4; i++) {
            if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
                // Not a valid date, might be a time or something else
                // Backtrack or handle as error
                NAVTomlLexerSetError(lexer, 'Invalid date/time format')
                return false
            }

            NAVTomlLexerNext(lexer)
        }

        // Check for dash
        if (NAVTomlLexerIsEOF(lexer) || NAVTomlLexerPeek(lexer) != '-') {
            NAVTomlLexerSetError(lexer, 'Invalid date format: expected - after year')
            return false
        }

        NAVTomlLexerNext(lexer) // Consume -

        // Consume month (2 digits)
        for (i = 1; i <= 2; i++) {
            if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
                NAVTomlLexerSetError(lexer, 'Invalid date format: expected month digits')
                return false
            }

            NAVTomlLexerNext(lexer)
        }

        // Check for dash
        if (NAVTomlLexerIsEOF(lexer) || NAVTomlLexerPeek(lexer) != '-') {
            NAVTomlLexerSetError(lexer, 'Invalid date format: expected - after month')
            return false
        }

        NAVTomlLexerNext(lexer) // Consume -

        // Consume day (2 digits)
        for (i = 1; i <= 2; i++) {
            if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
                NAVTomlLexerSetError(lexer, 'Invalid date format: expected day digits')
                return false
            }

            NAVTomlLexerNext(lexer)
        }

        hasDate = true

        // Check for time part (T or space separator)
        if (!NAVTomlLexerIsEOF(lexer)) {
            ch = NAVTomlLexerPeek(lexer)

            if (ch == 'T' || ch == 't' || ch == ' ') {
                NAVTomlLexerNext(lexer) // Consume separator

                // Parse time part: HH:MM:SS
                if (NAVTomlLexerIsEOF(lexer)) {
                    NAVTomlLexerSetError(lexer, 'Invalid datetime format: expected time after T')
                    return false
                }

                hasTime = NAVTomlLexerConsumeTimePartInternal(lexer)

                if (!hasTime) {
                    return false
                }
            }
        }
    }

    // Determine token type
    if (hasDate && hasTime) {
        return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_DATETIME)
    }
    else if (hasDate) {
        return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_DATE)
    }
    else {
        NAVTomlLexerSetError(lexer, 'Invalid date/time format')
        return false
    }
}


/**
 * @function NAVTomlLexerConsumeTimePartInternal
 * @private
 * @description Helper function to consume the time part: HH:MM[:SS][.fraction][Z/offset]
 * TOML 1.1.0: Seconds are now optional (defaults to :00 if omitted)
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if success, False (0) if invalid
 */
define_function char NAVTomlLexerConsumeTimePartInternal(_NAVTomlLexer lexer) {
    stack_var integer i
    stack_var char ch
    stack_var integer hourStart
    stack_var integer minuteStart
    stack_var integer secondStart
    stack_var char hourStr[2]
    stack_var char minuteStr[2]
    stack_var char secondStr[2]
    stack_var integer hourVal
    stack_var integer minuteVal
    stack_var integer secondVal

    // Remember start position for hour
    hourStart = lexer.cursor

    // Consume hour (2 digits)
    for (i = 1; i <= 2; i++) {
        if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
            NAVTomlLexerSetError(lexer, 'Invalid time format: expected hour digits')
            return false
        }

        NAVTomlLexerNext(lexer)
    }

    // Validate hour range (00-23)
    hourStr = NAVStringSlice(lexer.source, hourStart, lexer.cursor)
    hourVal = atoi(hourStr)
    if (hourVal < 0 || hourVal > 23) {
        NAVTomlLexerSetError(lexer, "'Invalid time: hour must be 0-23, got ', itoa(hourVal)")
        return false
    }

    // Check for colon
    if (NAVTomlLexerIsEOF(lexer) || NAVTomlLexerPeek(lexer) != ':') {
        NAVTomlLexerSetError(lexer, 'Invalid time format: expected : after hour')
        return false
    }

    NAVTomlLexerNext(lexer) // Consume :

    // Remember start position for minute
    minuteStart = lexer.cursor

    // Consume minute (2 digits)
    for (i = 1; i <= 2; i++) {
        if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
            NAVTomlLexerSetError(lexer, 'Invalid time format: expected minute digits')
            return false
        }

        NAVTomlLexerNext(lexer)
    }

    // Validate minute range (00-59)
    minuteStr = NAVStringSlice(lexer.source, minuteStart, lexer.cursor)
    minuteVal = atoi(minuteStr)
    if (minuteVal < 0 || minuteVal > 59) {
        NAVTomlLexerSetError(lexer, "'Invalid time: minute must be 0-59, got ', itoa(minuteVal)")
        return false
    }

    // TOML 1.1.0: Seconds are now optional
    // Check if there's a colon for seconds
    if (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerPeek(lexer) == ':') {
        NAVTomlLexerNext(lexer) // Consume :

        // Remember start position for second
        secondStart = lexer.cursor

        // Consume second (2 digits)
        for (i = 1; i <= 2; i++) {
            if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
                NAVTomlLexerSetError(lexer, 'Invalid time format: expected second digits')
                return false
            }

            NAVTomlLexerNext(lexer)
        }

        // Validate second range (00-60, 60 allowed for leap seconds)
        secondStr = NAVStringSlice(lexer.source, secondStart, lexer.cursor)
        secondVal = atoi(secondStr)
        if (secondVal < 0 || secondVal > 60) {
            NAVTomlLexerSetError(lexer, "'Invalid time: second must be 0-60, got ', itoa(secondVal)")
            return false
        }

        // Optional fractional seconds (only if seconds are present)
        if (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerPeek(lexer) == '.') {
            NAVTomlLexerNext(lexer) // Consume .

            // TOML spec requires at least 1 digit after decimal point
            if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
                NAVTomlLexerSetError(lexer, 'Invalid fractional seconds: expected digit after decimal point')
                return false
            }

            // Consume fraction digits
            while (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
                NAVTomlLexerNext(lexer)
            }
        }
    }

    // Optional timezone offset
    if (!NAVTomlLexerIsEOF(lexer)) {
        ch = NAVTomlLexerPeek(lexer)

        if (ch == 'Z' || ch == 'z') {
            NAVTomlLexerNext(lexer)
        }
        else if (ch == '+' || ch == '-') {
            // Offset: +HH:MM or -HH:MM
            NAVTomlLexerNext(lexer) // Consume sign

            // Remember start position for timezone offset hour
            hourStart = lexer.cursor

            // Hour (2 digits)
            for (i = 1; i <= 2; i++) {
                if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
                    NAVTomlLexerSetError(lexer, 'Invalid timezone offset: expected hour')
                    return false
                }

                NAVTomlLexerNext(lexer)
            }

            // Validate timezone offset hour range (00-23)
            hourStr = NAVStringSlice(lexer.source, hourStart, lexer.cursor)
            hourVal = atoi(hourStr)
            if (hourVal < 0 || hourVal > 23) {
                NAVTomlLexerSetError(lexer, "'Invalid timezone offset: hour must be 0-23, got ', itoa(hourVal)")
                return false
            }

            // Colon
            if (NAVTomlLexerIsEOF(lexer) || NAVTomlLexerPeek(lexer) != ':') {
                NAVTomlLexerSetError(lexer, 'Invalid timezone offset: expected : after hour')
                return false
            }

            NAVTomlLexerNext(lexer)

            // Remember start position for timezone offset minute
            minuteStart = lexer.cursor

            // Minute (2 digits)
            for (i = 1; i <= 2; i++) {
                if (NAVTomlLexerIsEOF(lexer) || !NAVTomlLexerIsDigit(NAVTomlLexerPeek(lexer))) {
                    NAVTomlLexerSetError(lexer, 'Invalid timezone offset: expected minute')
                    return false
                }

                NAVTomlLexerNext(lexer)
            }

            // Validate timezone offset minute range (00-59)
            minuteStr = NAVStringSlice(lexer.source, minuteStart, lexer.cursor)
            minuteVal = atoi(minuteStr)
            if (minuteVal < 0 || minuteVal > 59) {
                NAVTomlLexerSetError(lexer, "'Invalid timezone offset: minute must be 0-59, got ', itoa(minuteVal)")
                return false
            }
        }
    }

    return true
}


/**
 * @function NAVTomlLexerConsumeLocalTime
 * @private
 * @description Consume a local time value (HH:MM[:SS]).
 * TOML 1.1.0: Seconds are now optional
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if success, False (0) if invalid
 */
define_function char NAVTomlLexerConsumeLocalTime(_NAVTomlLexer lexer) {
    if (!NAVTomlLexerConsumeTimePartInternal(lexer)) {
        return false
    }

    return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_TIME)
}


// =============================================================================
// KEY AND IDENTIFIER TOKENIZATION
// =============================================================================

/**
 * @function NAVTomlLexerConsumeBareKey
 * @private
 * @description Consume a bare key (unquoted identifier).
 * Bare keys can contain: A-Z, a-z, 0-9, -, _
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if success, False (0) if invalid
 */
define_function char NAVTomlLexerConsumeBareKey(_NAVTomlLexer lexer) {
    while (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerIsBareKeyChar(NAVTomlLexerPeek(lexer))) {
        NAVTomlLexerNext(lexer)
    }

    // TOML spec: bare keys cannot be empty
    if (lexer.cursor == lexer.start) {
        NAVTomlLexerSetError(lexer, 'Bare key cannot be empty')
        return false
    }

    return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_BARE_KEY)
}


/**
 * @function NAVTomlLexerConsumeBoolean
 * @private
 * @description Check if the current bare key is a boolean literal.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 * @param {char[]} value - The value to check
 *
 * @returns {char} True (1) if boolean, False (0) otherwise
 */
define_function char NAVTomlLexerConsumeBoolean(_NAVTomlLexer lexer, char value[]) {
    if (value == 'true' || value == 'false') {
        return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_BOOLEAN)
    }

    return false
}


// =============================================================================
// TABLE HEADER TOKENIZATION
// =============================================================================

/**
 * @function NAVTomlLexerConsumeTableHeader
 * @private
 * @description Consume a table header [table.name] or array of tables [[array.table]].
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if success, False (0) if invalid
 */
define_function char NAVTomlLexerConsumeTableHeader(_NAVTomlLexer lexer) {
    stack_var char isArrayTable
    stack_var char ch

    isArrayTable = false

    // Skip first [
    NAVTomlLexerNext(lexer)

    // Check for [[
    if (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerPeek(lexer) == '[') {
        isArrayTable = true
        NAVTomlLexerNext(lexer)
    }

    // Skip whitespace
    while (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerIsWhitespace(NAVTomlLexerPeek(lexer))) {
        NAVTomlLexerNext(lexer)
    }

    // Consume table name (keys separated by dots)
    while (!NAVTomlLexerIsEOF(lexer)) {
        ch = NAVTomlLexerPeek(lexer)

        if (ch == ']') {
            break
        }
        else if (ch == '"' || ch == '''') {
            // Quoted key in table name
            if (ch == '"') {
                if (!NAVTomlLexerConsumeBasicString(lexer)) {
                    return false
                }
            }
            else {
                if (!NAVTomlLexerConsumeLiteralString(lexer)) {
                    return false
                }
            }
        }
        else if (NAVTomlLexerIsBareKeyChar(ch)) {
            // Bare key
            while (!NAVTomlLexerIsEOF(lexer) && NAVTomlLexerIsBareKeyChar(NAVTomlLexerPeek(lexer))) {
                NAVTomlLexerNext(lexer)
            }
        }
        else if (ch == '.') {
            NAVTomlLexerNext(lexer)
        }
        else if (NAVTomlLexerIsWhitespace(ch)) {
            NAVTomlLexerNext(lexer)
        }
        else if (NAVTomlLexerIsNewline(ch)) {
            NAVTomlLexerSetError(lexer, 'Invalid table header: newline not allowed')
            return false
        }
        else {
            NAVTomlLexerSetError(lexer, "'Invalid character in table header: ', ch")
            return false
        }
    }

    // Check for closing ]
    if (NAVTomlLexerIsEOF(lexer) || NAVTomlLexerPeek(lexer) != ']') {
        NAVTomlLexerSetError(lexer, 'Invalid table header: expected ]')
        return false
    }

    NAVTomlLexerNext(lexer) // Consume ]

    // If array table, check for second ]
    if (isArrayTable) {
        if (NAVTomlLexerIsEOF(lexer) || NAVTomlLexerPeek(lexer) != ']') {
            NAVTomlLexerSetError(lexer, 'Invalid array table header: expected ]]')
            return false
        }

        NAVTomlLexerNext(lexer) // Consume second ]

        return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_ARRAY_TABLE)
    }
    else {
        return NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_TABLE_HEADER)
    }
}


// =============================================================================
// MAIN TOKENIZATION FUNCTION
// =============================================================================

/**
 * @function NAVTomlLexerTokenize
 * @public
 * @description Tokenize the source TOML text into an array of tokens.
 *
 * @param {_NAVTomlLexer} lexer - The lexer instance
 * @param {char[]} source - The source text to tokenize
 *
 * @returns {char} True (1) if tokenization succeeded, False (0) if failed
 */
define_function char NAVTomlLexerTokenize(_NAVTomlLexer lexer, char source[]) {
    NAVTomlLexerInit(lexer, source)

    #IF_DEFINED TOML_LEXER_DEBUG
    NAVLog("'[ TomlLexerTokenize ]: Starting tokenization, source length=', itoa(length_array(source))")
    #END_IF

    if (!length_array(lexer.source)) {
        // Empty source, emit EOF token
        if (!NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_EOF)) {
            return false
        }

        #IF_DEFINED TOML_LEXER_DEBUG
        NAVLog("'[ TomlLexerTokenize ]: Empty source, emitted EOF'")
        #END_IF

        return true
    }

    while (!NAVTomlLexerIsEOF(lexer)) {
        stack_var char ch

        if (!NAVTomlLexerCanAddToken(lexer)) {
            return false
        }

        ch = NAVTomlLexerPeek(lexer)

        #IF_DEFINED TOML_LEXER_DEBUG
        NAVLog("'[ TomlLexerTokenize ]: cursor=', itoa(lexer.cursor), ' char=', ch, ' (', itoa(type_cast(ch)), ')'")
        #END_IF

        switch (ch) {
            // Comment
            case '#': {
                if (!NAVTomlLexerConsumeComment(lexer)) {
                    return false
                }
            }

            // Table header or array
            case '[': {
                // Check if it's a table header at start of line
                // We need context to determine if this is a table header or array start
                // For now, we'll peek ahead to see if it's followed by more brackets or keys

                // Simple heuristic: if we're at start of line or after newline, it's likely a table header
                stack_var char isTableHeader
                isTableHeader = false

                if (lexer.tokenCount == 0) {
                    isTableHeader = true
                }
                else if (lexer.tokenCount > 0 && lexer.tokens[lexer.tokenCount].type == NAV_TOML_TOKEN_TYPE_NEWLINE) {
                    isTableHeader = true
                }

                if (isTableHeader) {
                    // Likely a table header
                    if (!NAVTomlLexerConsumeTableHeader(lexer)) {
                        return false
                    }
                }
                else {
                    // Inline array start
                    NAVTomlLexerNext(lexer)
                    if (!NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_LEFT_BRACKET)) {
                        return false
                    }
                }
            }

            // Right bracket
            case ']': {
                NAVTomlLexerNext(lexer)
                if (!NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET)) {
                    return false
                }
            }

            // Left brace (inline table)
            case '{': {
                NAVTomlLexerNext(lexer)
                if (!NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_LEFT_BRACE)) {
                    return false
                }
            }

            // Right brace
            case '}': {
                NAVTomlLexerNext(lexer)
                if (!NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_RIGHT_BRACE)) {
                    return false
                }
            }

            // Equals
            case '=': {
                NAVTomlLexerNext(lexer)
                if (!NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_EQUALS)) {
                    return false
                }
            }

            // Dot
            case '.': {
                NAVTomlLexerNext(lexer)
                if (!NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_DOT)) {
                    return false
                }
            }

            // Comma
            case ',': {
                NAVTomlLexerNext(lexer)
                if (!NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_COMMA)) {
                    return false
                }
            }

            // Double-quoted strings
            case '"': {
                // Check for multiline string """
                if (NAVTomlLexerPeekAhead(lexer, 2) == '"' && NAVTomlLexerPeekAhead(lexer, 3) == '"') {
                    if (!NAVTomlLexerConsumeMultilineBasicString(lexer)) {
                        return false
                    }
                }
                else {
                    if (!NAVTomlLexerConsumeBasicString(lexer)) {
                        return false
                    }
                }
            }

            // Single-quoted strings
            case '''': {
                // Check for multiline literal string '''
                if (NAVTomlLexerPeekAhead(lexer, 2) == '''' && NAVTomlLexerPeekAhead(lexer, 3) == '''') {
                    if (!NAVTomlLexerConsumeMultilineLiteralString(lexer)) {
                        return false
                    }
                }
                else {
                    if (!NAVTomlLexerConsumeLiteralString(lexer)) {
                        return false
                    }
                }
            }

            // Numbers with optional sign
            case '+':
            case '-':
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
                stack_var char nextCh

                nextCh = NAVTomlLexerPeekAhead(lexer, 2)

                // Check if this could be a number or date/time
                // Dates start with YYYY- (4 digits then dash)
                if (NAVTomlLexerIsDigit(ch) &&
                    NAVTomlLexerIsDigit(nextCh) &&
                    NAVTomlLexerIsDigit(NAVTomlLexerPeekAhead(lexer, 3)) &&
                    NAVTomlLexerIsDigit(NAVTomlLexerPeekAhead(lexer, 4)) &&
                    NAVTomlLexerPeekAhead(lexer, 5) == '-') {
                    // This looks like a date
                    if (!NAVTomlLexerConsumeDateTime(lexer)) {
                        return false
                    }
                }
                // Check if this could be a time value (HH:MM:SS)
                else if (NAVTomlLexerIsDigit(ch) &&
                    NAVTomlLexerIsDigit(nextCh) &&
                    NAVTomlLexerPeekAhead(lexer, 3) == ':') {
                    // This looks like a time value
                    if (!NAVTomlLexerConsumeLocalTime(lexer)) {
                        return false
                    }
                }
                else if (ch == '+' || ch == '-') {
                    // Could be signed number or special float (inf, nan)
                    if (NAVTomlLexerIsDigit(nextCh)) {
                        if (!NAVTomlLexerConsumeNumber(lexer)) {
                            return false
                        }
                    }
                    else if (NAVTomlLexerIsAlpha(nextCh)) {
                        // Special float (inf, nan)
                        if (!NAVTomlLexerConsumeNumber(lexer)) {
                            return false
                        }
                    }
                    else {
                        NAVTomlLexerSetError(lexer, "'Unexpected character: ', ch")
                        return false
                    }
                }
                else {
                    if (!NAVTomlLexerConsumeNumber(lexer)) {
                        return false
                    }
                }
            }

            default: {
                // Whitespace (space, tab)
                if (NAVTomlLexerIsWhitespace(ch)) {
                    NAVTomlLexerSkipWhitespace(lexer)
                }
                // Newline
                else if (NAVTomlLexerIsNewline(ch)) {
                    NAVTomlLexerNext(lexer)
                    if (!NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_NEWLINE)) {
                        return false
                    }
                }
                // Bare keys and keywords (true, false)
                else if (NAVTomlLexerIsAlpha(ch) || ch == '_') {
                    stack_var char value[NAV_TOML_LEXER_MAX_TOKEN_LENGTH]

                    if (!NAVTomlLexerConsumeBareKey(lexer)) {
                        return false
                    }

                    // Check if it's a boolean
                    value = lexer.tokens[lexer.tokenCount].value

                    if (value == 'true' || value == 'false') {
                        // Change token type to boolean
                        lexer.tokens[lexer.tokenCount].type = NAV_TOML_TOKEN_TYPE_BOOLEAN
                    }
                    else if (value == 'inf' || value == 'nan') {
                        // Special float values
                        lexer.tokens[lexer.tokenCount].type = NAV_TOML_TOKEN_TYPE_FLOAT
                    }
                }
                else {
                    // Unexpected character
                    NAVTomlLexerSetError(lexer, "'Unexpected character: ', ch, ' (', itoa(type_cast(ch)), ')'")
                    return false
                }
            }
        }
    }

    // Emit EOF token
    if (!NAVTomlLexerEmitToken(lexer, NAV_TOML_TOKEN_TYPE_EOF)) {
        return false
    }

    #IF_DEFINED TOML_LEXER_DEBUG
    NAVLog("'[ TomlLexerTokenize ]: Tokenization complete. Total tokens: ', itoa(lexer.tokenCount)")
    NAVTomlLexerPrintTokens(lexer)
    #END_IF

    return true
}


// =============================================================================
// DEBUG AND UTILITY FUNCTIONS
// =============================================================================

/**
 * @function NAVTomlLexerGetTokenType
 * @private
 * @description Get a string representation of a token type (for debugging).
 *
 * @param {integer} type - The token type constant
 *
 * @returns {char[NAV_MAX_CHARS]} String representation of the token type
 */
define_function char[NAV_MAX_CHARS] NAVTomlLexerGetTokenType(integer type) {
    switch (type) {
        case NAV_TOML_TOKEN_TYPE_LEFT_BRACKET:      { return 'LEFT_BRACKET' }
        case NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET:     { return 'RIGHT_BRACKET' }
        case NAV_TOML_TOKEN_TYPE_LEFT_BRACE:        { return 'LEFT_BRACE' }
        case NAV_TOML_TOKEN_TYPE_RIGHT_BRACE:       { return 'RIGHT_BRACE' }
        case NAV_TOML_TOKEN_TYPE_EQUALS:            { return 'EQUALS' }
        case NAV_TOML_TOKEN_TYPE_DOT:               { return 'DOT' }
        case NAV_TOML_TOKEN_TYPE_COMMA:             { return 'COMMA' }
        case NAV_TOML_TOKEN_TYPE_TABLE_HEADER:      { return 'TABLE_HEADER' }
        case NAV_TOML_TOKEN_TYPE_ARRAY_TABLE:       { return 'ARRAY_TABLE' }
        case NAV_TOML_TOKEN_TYPE_STRING:            { return 'STRING' }
        case NAV_TOML_TOKEN_TYPE_MULTILINE_STRING:  { return 'MULTILINE_STRING' }
        case NAV_TOML_TOKEN_TYPE_INTEGER:           { return 'INTEGER' }
        case NAV_TOML_TOKEN_TYPE_FLOAT:             { return 'FLOAT' }
        case NAV_TOML_TOKEN_TYPE_BOOLEAN:           { return 'BOOLEAN' }
        case NAV_TOML_TOKEN_TYPE_DATETIME:          { return 'DATETIME' }
        case NAV_TOML_TOKEN_TYPE_DATE:              { return 'DATE' }
        case NAV_TOML_TOKEN_TYPE_TIME:              { return 'TIME' }
        case NAV_TOML_TOKEN_TYPE_BARE_KEY:          { return 'BARE_KEY' }
        case NAV_TOML_TOKEN_TYPE_QUOTED_KEY:        { return 'QUOTED_KEY' }
        case NAV_TOML_TOKEN_TYPE_NEWLINE:           { return 'NEWLINE' }
        case NAV_TOML_TOKEN_TYPE_COMMENT:           { return 'COMMENT' }
        case NAV_TOML_TOKEN_TYPE_EOF:               { return 'EOF' }
        case NAV_TOML_TOKEN_TYPE_ERROR:             { return 'ERROR' }
        default:                                    { return 'UNKNOWN' }
    }
}


/**
 * @function NAVTomlLexerPrintTokens
 * @private
 * @description Print all tokens for debugging purposes.
 *
 * @param {_NAVTomlLexer} lexer - The lexer structure
 *
 * @returns {void}
 */
define_function NAVTomlLexerPrintTokens(_NAVTomlLexer lexer) {
    stack_var long i

    NAVLog("'[ TomlLexerPrintTokens ]: Printing ', itoa(lexer.tokenCount), ' tokens:'")

    for (i = 1; i <= lexer.tokenCount; i++) {
        NAVLog("'  [', itoa(i), '] type=', NAVTomlLexerGetTokenType(lexer.tokens[i].type),
               ' value="', lexer.tokens[i].value, '"',
               ' line=', itoa(lexer.tokens[i].line),
               ' col=', itoa(lexer.tokens[i].column)")
    }
}


#END_IF // __NAV_FOUNDATION_TOML_LEXER__
