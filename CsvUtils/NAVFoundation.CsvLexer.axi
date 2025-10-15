PROGRAM_NAME='NAVFoundation.CsvLexer'

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
 * NAVFoundation CSV Lexer
 *
 * RFC 4180 Compliant with Extensions
 *
 * This lexer tokenizes CSV (Comma-Separated Values) data according to RFC 4180
 * with additional convenience features for AMX development.
 *
 * Standard Escaping (RFC 4180):
 *   - Quotes within quoted fields are escaped by doubling them: ""
 *   - Example: "say ""hello""" → say "hello"
 *
 * Extended Escaping (NAVFoundation Extension):
 *   - Backslash escape sequences within quoted fields:
 *     \n  → Line Feed (LF / $0A)
 *     \r  → Carriage Return (CR / $0D)
 *     \t  → Tab (TAB / $09)
 *     \\  → Literal Backslash
 *     \"  → Literal Quote
 *   - Unknown escape sequences (e.g., \x) → Backslash is preserved literally
 *   - Examples:
 *     "line1\nline2"     → line1<LF>line2
 *     "path\\file"       → path\file
 *     "say \"hi\""       → say "hi"
 *     "test\tab\there"   → test<TAB>ab<TAB>here
 *
 * Both escaping methods can be used simultaneously:
 *   - "test""value"    → test"value  (RFC 4180 double-quote)
 *   - "test\"value"    → test"value  (NAVFoundation backslash)
 *   - Both produce identical results
 *
 * Compatibility Note:
 *   - All standard RFC 4180 CSV files remain fully compatible
 *   - Files using backslash escapes are intended for AMX-internal use
 *   - External CSV parsers may not recognize backslash escape sequences
 *
 * Token Types:
 *   - COMMA      : Field separator (,)
 *   - IDENTIFIER : Unquoted field value
 *   - STRING     : Quoted field value (quotes removed, escapes processed)
 *   - NEWLINE    : Row separator (\n or \r\n)
 *   - WHITESPACE : Spaces/tabs (preserved in context)
 *   - EOF        : End of input
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_CSV_LEXER__
#DEFINE __NAV_FOUNDATION_CSV_LEXER__ 'NAVFoundation.CsvLexer'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.CsvLexer.h.axi'


/**
 * @function NAVCsvLexerInit
 * @public
 * @description Initialize a CSV lexer with source text.
 *
 * @param {_CsvLexer} lexer - The lexer structure to initialize
 * @param {char[]} source - The source text to tokenize
 *
 * @returns {void}
 */
define_function NAVCsvLexerInit(_NAVCsvLexer lexer, char source[]) {
    lexer.source = source
    lexer.cursor = 0
    lexer.tokenCount = 0
}


/**
 * @function NAVCsvLexerHasMoreTokens
 * @private
 * @description Check if there are more characters to tokenize in the source.
 *
 * @param {_NAVCsvLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if more characters exist, False (0) otherwise
 */
define_function char NAVCsvLexerHasMoreTokens(_NAVCsvLexer lexer) {
    return lexer.cursor < length_array(lexer.source)
}


/**
 * @function NAVCsvLexerCursorIsOutOfBounds
 * @private
 * @description Check if the lexer's cursor is out of bounds.
 *
 * @param {_NAVCsvLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if cursor is out of bounds, False (0) otherwise
 */
define_function char NAVCsvLexerCursorIsOutOfBounds(_NAVCsvLexer lexer) {
    return lexer.cursor <= 0 || lexer.cursor > length_array(lexer.source)
}


/**
 * @function NAVCsvLexerAdvanceCursor
 * @private
 * @description Advance the lexer's cursor by one position.
 *
 * @param {_NAVCsvLexer} lexer - The lexer to advance
 *
 * @returns {char} True (1) if cursor advanced successfully, False (0) if out of bounds
 */
define_function char NAVCsvLexerAdvanceCursor(_NAVCsvLexer lexer) {
    lexer.cursor++

    if (NAVCsvLexerCursorIsOutOfBounds(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSV_LEXER__,
                                    'NAVCsvLexerAdvanceCursor',
                                    "'Lexer cursor out of bounds: ', itoa(lexer.cursor)")
        return false
    }

    return true
}


/**
 * @function NAVCsvLexerCanAddToken
 * @private
 * @description Check if the lexer can accept another token without exceeding the maximum limit.
 *
 * @param {_NAVCsvLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if token can be added, False (0) if limit reached
 */
define_function char NAVCsvLexerCanAddToken(_NAVCsvLexer lexer) {
    if (lexer.tokenCount >= NAV_CSV_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSV_LEXER__,
                                    'NAVCsvLexerCanAddToken',
                                    "'Exceeded maximum token limit'")
        return false
    }

    return true
}


/**
 * @function NAVCsvLexerTokenize
 * @public
 * @description Tokenize the source text into an array of tokens.
 *
 * @param {_NAVCsvLexer} lexer - The initialized lexer
 *
 * @returns {char} True (1) if tokenization succeeded, False (0) if failed
 */
define_function char NAVCsvLexerTokenize(_NAVCsvLexer lexer) {
    while (NAVCsvLexerHasMoreTokens(lexer)) {
        stack_var char ch

        if (lexer.tokenCount == NAV_CSV_LEXER_MAX_TOKENS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_CSV_LEXER__,
                                        'NAVCsvLexerTokenize',
                                        "'Exceeded maximum token limit'")
            return false
        }

        if (!NAVCsvLexerAdvanceCursor(lexer)) {
            return false
        }

        ch = lexer.source[lexer.cursor]

        switch (ch) {
            case ',': {
                lexer.tokenCount++
                lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_COMMA
                lexer.tokens[lexer.tokenCount].value = "ch"
            }
            case NAV_LF: {
                // Unix style newline \n
                lexer.tokenCount++
                lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_NEWLINE
                lexer.tokens[lexer.tokenCount].value = "ch"
            }
            case NAV_CR: {
                // Windows style newline \r\n
                stack_var char value[2]

                value = "ch"

                if (NAVCsvLexerHasMoreTokens(lexer) &&
                    lexer.source[lexer.cursor + 1] == NAV_LF) {
                    if (!NAVCsvLexerAdvanceCursor(lexer)) {
                        return false
                    }

                    value = "value, lexer.source[lexer.cursor]"
                }

                lexer.tokenCount++
                lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_NEWLINE
                lexer.tokens[lexer.tokenCount].value = value
            }
            case NAV_TAB:
            case ' ': {
                NAVCsvLexerConsumeWhitespace(lexer)
            }
            case '"': {
                NAVCsvLexerConsumeString(lexer)
            }
            default: {
                if (NAVCsvLexerIsIdentifierChar(ch)) {
                    NAVCsvLexerConsumeIdentifier(lexer)
                }
            }
        }
    }

    // Add EOF token to mark end of token stream
    if (!NAVCsvLexerCanAddToken(lexer)) {
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_EOF
    lexer.tokens[lexer.tokenCount].value = ''

    set_length_array(lexer.tokens, lexer.tokenCount)

    return true
}


/**
 * @function NAVCsvLexerIsIdentifierChar
 * @private
 * @description Check if a character is valid for use in an identifier.
 *
 * @param {char} value - The character to check
 *
 * @returns {char} True (1) if character is valid for identifiers, False (0) otherwise
 */
define_function char NAVCsvLexerIsIdentifierChar(char value) {
    return NAVIsAlphaNumeric(value) ||
            value == '-' ||
            value == '_' ||
            value == '.' ||
            value == '\' ||
            value == '/' ||
            value == ':' ||
            value == '@' ||
            value == '$' ||
            value == '%' ||
            value == '~'
}


/**
 * @function NAVCsvLexerConsumeIdentifier
 * @private
 * @description Consume an identifier token from the lexer input.
 *
 * @param {_NAVCsvLexer} lexer - The lexer instance
 *
 * @returns {void}
 */
define_function NAVCsvLexerConsumeIdentifier(_NAVCsvLexer lexer) {
    stack_var char value[NAV_CSV_LEXER_MAX_TOKEN_LENGTH]

    value = "lexer.source[lexer.cursor]"

    while (NAVCsvLexerHasMoreTokens(lexer) &&
            NAVCsvLexerIsIdentifierChar(lexer.source[lexer.cursor + 1])) {
        if (!NAVCsvLexerAdvanceCursor(lexer)) {
            return
        }

        value = "value, lexer.source[lexer.cursor]"
    }

    if (!NAVCsvLexerCanAddToken(lexer)) {
        return
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    lexer.tokens[lexer.tokenCount].value = value
}


/**
 * @function NAVCsvLexerConsumeString
 * @private
 * @description Consume a quoted string token from the lexer input.
 *
 * @param {_NAVCsvLexer} lexer - The lexer instance
 *
 * @returns {void}
 */
define_function NAVCsvLexerConsumeString(_NAVCsvLexer lexer) {
    stack_var char value[NAV_CSV_LEXER_MAX_TOKEN_LENGTH]

    while (NAVCsvLexerHasMoreTokens(lexer)) {
        stack_var char ch

        // Advance past the opening quote
        if (!NAVCsvLexerAdvanceCursor(lexer)) {
            return
        }

        ch = lexer.source[lexer.cursor]

        switch (ch) {
            case '"': {
                // Handle escaped quote
                if (NAVCsvLexerHasMoreTokens(lexer)) {
                    stack_var char next

                    next = lexer.source[lexer.cursor + 1]

                    switch (next) {
                        case '"': {
                            if (!NAVCsvLexerAdvanceCursor(lexer)) {
                                return
                            }

                            value = "value, ch"
                            continue
                        }
                    }
                }

                // Closing quote
                break
            }

            // Extension to the RFC to handle some basic \ escape sequences
            case '\': {
                if (NAVCsvLexerHasMoreTokens(lexer)) {
                    stack_var char next

                    next = lexer.source[lexer.cursor + 1]

                    switch (next) {
                        case 'n': {
                            if (!NAVCsvLexerAdvanceCursor(lexer)) {
                                return
                            }

                            value = "value, NAV_LF"
                        }
                        case 'r': {
                            if (!NAVCsvLexerAdvanceCursor(lexer)) {
                                return
                            }

                            value = "value, NAV_CR"
                        }
                        case 't': {
                            if (!NAVCsvLexerAdvanceCursor(lexer)) {
                                return
                            }

                            value = "value, NAV_TAB"
                        }
                        case '\': {
                            if (!NAVCsvLexerAdvanceCursor(lexer)) {
                                return
                            }

                            value = "value, next"
                        }
                        case '"': {
                            // Check if there's content after this quote
                            // If the quote is at the end, it's the closing delimiter, not an escape
                            if (lexer.cursor + 1 < length_array(lexer.source)) {
                                if (!NAVCsvLexerAdvanceCursor(lexer)) {
                                    return
                                }

                                value = "value, next"
                            } else {
                                // Backslash at end before closing quote - treat backslash literally
                                value = "value, ch"
                            }
                        }
                        default: {
                            // Unknown escape sequence - treat backslash literally
                            value = "value, ch"
                        }
                    }

                    continue
                }

                value = "value, ch"
            }

            default: {
                value = "value, ch"
            }
        }

        // If we hit a closing quote, break out of the loop now
        if (ch == '"') {
            break
        }
    }

    if (!NAVCsvLexerCanAddToken(lexer)) {
        return
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_STRING
    lexer.tokens[lexer.tokenCount].value = value
}


/**
 * @function NAVCsvLexerConsumeWhitespace
 * @private
 * @description Consume whitespace tokens (spaces and tabs) from the lexer input.
 *
 * @param {_NAVCsvLexer} lexer - The lexer instance
 *
 * @returns {void}
 */
define_function NAVCsvLexerConsumeWhitespace(_NAVCsvLexer lexer) {
    stack_var char value[NAV_CSV_LEXER_MAX_TOKEN_LENGTH]

    value = "lexer.source[lexer.cursor]"

    while (NAVCsvLexerHasMoreTokens(lexer) &&
            (lexer.source[lexer.cursor + 1] == ' ' ||
             lexer.source[lexer.cursor + 1] == NAV_TAB)) {
        if (!NAVCsvLexerAdvanceCursor(lexer)) {
            return
        }

        value = "value, lexer.source[lexer.cursor]"
    }

    if (!NAVCsvLexerCanAddToken(lexer)) {
        return
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    lexer.tokens[lexer.tokenCount].value = value
}


/**
 * @function NAVCsvLexerTokenSerialize
 * @public
 * @description Serialize a token to a JSON-like string representation for debugging.
 *
 * @param {_NAVCsvToken} token - The token to serialize
 *
 * @returns {char[NAV_MAX_BUFFER]} JSON-like string representation of the token
 */
define_function char[NAV_MAX_BUFFER] NAVCsvLexerTokenSerialize(_NAVCsvToken token) {
    return "'{ "type": "', NAVCsvLexerGetTokenType(token.type), '", "value": "', token.value, '" }'"
}


/**
 * @function NAVCsvLexerGetTokenType
 * @public
 * @description Get the string representation of a token type.
 *
 * @param {integer} type - The token type constant
 *
 * @returns {char[NAV_MAX_CHARS]} String representation of the token type
 */
define_function char[NAV_MAX_CHARS] NAVCsvLexerGetTokenType(integer type) {
    switch (type) {
        case NAV_CSV_TOKEN_TYPE_COMMA:      { return 'COMMA' }          // ,
        case NAV_CSV_TOKEN_TYPE_IDENTIFIER: { return 'IDENTIFIER' }     // Alphanumeric strings
        case NAV_CSV_TOKEN_TYPE_STRING:     { return 'STRING' }         // Quoted strings or unquoted values
        case NAV_CSV_TOKEN_TYPE_NEWLINE:    { return 'NEWLINE' }        // Newline characters
        case NAV_CSV_TOKEN_TYPE_EOF:        { return 'EOF' }            // End of file/input
        case NAV_CSV_TOKEN_TYPE_WHITESPACE: { return 'WHITESPACE' }     // Spaces or tabs
        case NAV_CSV_TOKEN_TYPE_ERROR:      { return 'ERROR' }          // Error token for unrecognized characters
        default:                            { return 'UNKNOWN' }
    }
}


#END_IF // __NAV_FOUNDATION_CSV_LEXER__
