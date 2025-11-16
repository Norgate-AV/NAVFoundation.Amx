PROGRAM_NAME='NAVFoundation.SnapiLexer'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SNAPI_LEXER__
#DEFINE __NAV_FOUNDATION_SNAPI_LEXER__ 'NAVFoundation.SnapiLexer'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.SnapiLexer.h.axi'


/**
 * @function NAVSnapiLexerInit
 * @private
 * @description Initialize a SNAPI lexer with source text.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer structure to initialize
 * @param {char[]} source - The source text to tokenize
 *
 * @returns {void}
 */
define_function NAVSnapiLexerInit(_NAVSnapiLexer lexer, char source[]) {
    lexer.source = source
    lexer.cursor = 1
    lexer.start = 1
    lexer.tokenCount = 0
}


/**
 * @function NAVSnapiLexerEmitToken
 * @private
 * @description Emit a token of the specified type with the current lexer position.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer structure
 * @param {integer} type - The token type to emit
 *
 * @returns {char} True (1) if token emitted successfully, False (0) if token limit reached
 */
define_function char NAVSnapiLexerEmitToken(_NAVSnapiLexer lexer, integer type) {
    if (!NAVSnapiLexerCanAddToken(lexer)) {
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = type
    lexer.tokens[lexer.tokenCount].value = NAVStringSlice(lexer.source, lexer.start, lexer.cursor)
    lexer.tokens[lexer.tokenCount].start = lexer.start
    lexer.tokens[lexer.tokenCount].end = lexer.cursor
    set_length_array(lexer.tokens, lexer.tokenCount)

    lexer.start = lexer.cursor

    return true
}


/**
 * @function NAVSnapiLexerIgnore
 * @private
 * @description Ignore the current token by advancing the start position to the cursor.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer structure
 *
 * @returns {char} Always returns True (1)
 */
define_function char NAVSnapiLexerIgnore(_NAVSnapiLexer lexer) {
    lexer.start = lexer.cursor

    return true
}


/**
 * @function NAVSnapiLexerIsEOF
 * @private
 * @description Check if the lexer has reached the end of the source text.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if at end of file, False (0) otherwise
 */
define_function char NAVSnapiLexerIsEOF(_NAVSnapiLexer lexer) {
    return lexer.cursor > length_array(lexer.source)
}


/**
 * @function NAVSnapiLexerConsume
 * @private
 * @description Consume a specific string from the lexer source if it matches.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer structure
 * @param {char[]} value - The string to consume
 *
 * @returns {char} True (1) if the value was consumed successfully, False (0) if no match or EOF
 */
define_function char NAVSnapiLexerConsume(_NAVSnapiLexer lexer, char value[]) {
    stack_var integer length
    stack_var integer i

    length = length_array(value)

    if (!length) {
        return false
    }

    for (i = 1; i <= length; i++) {
        if (NAVSnapiLexerIsEOF(lexer) ||
            lexer.source[lexer.cursor] != value[i]) {
            return false
        }

        lexer.cursor++
    }

    return true
}


/**
 * @function NAVSnapiLexerIsWhitespaceChar
 * @private
 * @description Check if a character is a whitespace character (space or tab).
 *
 * @param {char} value - The character to check
 *
 * @returns {char} True (1) if the character is whitespace, False (0) otherwise
 */
define_function char NAVSnapiLexerIsWhitespaceChar(char value) {
    return value == ' ' || value == NAV_TAB
}


/**
 * @function NAVSnapiLexerCanPeek
 * @private
 * @description Check if the lexer can peek at the next character.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if peek is possible, False (0) if at or near end of source
 */
define_function char NAVSnapiLexerCanPeek(_NAVSnapiLexer lexer) {
    return lexer.cursor + 1 <= length_array(lexer.source)
}


/**
 * @function NAVSnapiLexerPeek
 * @private
 * @description Peek at the next character in the source without consuming it.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer structure
 *
 * @returns {char} The next character, or 0 if unable to peek
 */
define_function char NAVSnapiLexerPeek(_NAVSnapiLexer lexer) {
    if (!NAVSnapiLexerCanPeek(lexer)) {
        return 0
    }

    return lexer.source[lexer.cursor + 1]
}


/**
 * @function NAVSnapiLexerCanAddToken
 * @private
 * @description Check if the lexer can accept another token without exceeding the maximum limit.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if token can be added, False (0) if limit reached
 */
define_function char NAVSnapiLexerCanAddToken(_NAVSnapiLexer lexer) {
    if (lexer.tokenCount >= NAV_SNAPI_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SNAPI_LEXER__,
                                    'NAVSnapiLexerCanAddToken',
                                    "'Exceeded maximum token limit (', itoa(NAV_SNAPI_LEXER_MAX_TOKENS), ')'")
        return false
    }

    return true
}


/**
 * @function NAVSnapiLexerTokenize
 * @public
 * @description Tokenize the source text into an array of tokens.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer instance
 * @param {char[]} source - The source text to tokenize
 *
 * @returns {char} True (1) if tokenization succeeded, False (0) if failed
 */
define_function char NAVSnapiLexerTokenize(_NAVSnapiLexer lexer, char source[]) {
    NAVSnapiLexerInit(lexer, source)

    if (!length_array(lexer.source)) {
        // Empty source, emit EOF token
        if (!NAVSnapiLexerEmitToken(lexer, NAV_SNAPI_TOKEN_TYPE_EOF)) {
            return false
        }

        #IF_DEFINED SNAPI_LEXER_DEBUG
        // Dump all tokens
        NAVLog("'[ LexerTokenize ]: Tokenization complete. Total tokens: ', itoa(lexer.tokenCount)")
        NAVSnapiLexerPrintTokens(lexer)
        #END_IF

        return true
    }

    while (!NAVSnapiLexerIsEOF(lexer)) {
        stack_var char ch

        if (!NAVSnapiLexerCanAddToken(lexer)) {
            return false
        }

        ch = lexer.source[lexer.cursor]

        #IF_DEFINED SNAPI_LEXER_DEBUG
        NAVLog("'[ LexerTokenize ]: cursor=', itoa(lexer.cursor), ' char=', ch, ' (', itoa(type_cast(ch)), ')'")
        #END_IF

        switch (ch) {
            case '-': {
                if (!NAVSnapiLexerConsume(lexer, "ch")) {
                    return false
                }

                if (!NAVSnapiLexerEmitToken(lexer, NAV_SNAPI_TOKEN_TYPE_DASH)) {
                    return false
                }
            }
            case '?': {
                if (!NAVSnapiLexerConsume(lexer, "ch")) {
                    return false
                }

                if (!NAVSnapiLexerEmitToken(lexer, NAV_SNAPI_TOKEN_TYPE_QUESTIONMARK)) {
                    return false
                }
            }
            case ',': {
                if (!NAVSnapiLexerConsume(lexer, "ch")) {
                    return false
                }

                if (!NAVSnapiLexerEmitToken(lexer, NAV_SNAPI_TOKEN_TYPE_COMMA)) {
                    return false
                }
            }
            case NAV_TAB:
            case ' ': {
                if (!NAVSnapiLexerConsumeWhitespace(lexer)) {
                    return false
                }
            }
            case '"': {
                if (!NAVSnapiLexerConsumeString(lexer)) {
                    return false
                }
            }
            default: {
                if (!NAVSnapiLexerIsIdentifierChar(ch)) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_SNAPI_LEXER__,
                                                'NAVSnapiLexerTokenize',
                                                "'Unexpected token: ', ch, ' (', itoa(type_cast(ch)), ') at position ', itoa(lexer.cursor)")
                    return false
                }

                if (!NAVSnapiLexerConsumeIdentifier(lexer)) {
                    return false
                }
            }
        }
    }

    if (!NAVSnapiLexerEmitToken(lexer, NAV_SNAPI_TOKEN_TYPE_EOF)) {
        return false
    }

    #IF_DEFINED SNAPI_LEXER_DEBUG
    // Dump all tokens
    NAVLog("'[ LexerTokenize ]: Tokenization complete. Total tokens: ', itoa(lexer.tokenCount)")
    NAVSnapiLexerPrintTokens(lexer)
    #END_IF

    return true
}


/**
 * @function NAVSnapiLexerIsIdentifierChar
 * @private
 * @description Check if a character is valid for use in an identifier.
 *
 * @param {char} value - The character to check
 *
 * @returns {char} True (1) if character is valid for identifiers, False (0) otherwise
 */
define_function char NAVSnapiLexerIsIdentifierChar(char value) {
    return NAVIsAlphaNumeric(value) ||
            value == '_' ||
            value == '.' ||
            value == '\' ||
            value == '/' ||
            value == ':' ||
            value == '@' ||
            value == '$' ||
            value == '%' ||
            value == '~' ||
            value == '#' ||
            value == '^' ||
            value == '!' ||
            value == '&' ||
            value == '£' ||
            value == '*' ||
            value == '+' ||
            value == '=' ||
            value == '<' ||
            value == '>' ||
            value == '`' ||
            value == '?' ||
            value == '|' ||
            value == '(' ||
            value == ')' ||
            value == '{' ||
            value == '}' ||
            value == '[' ||
            value == ']' ||
            value == '~'
}


/**
 * @function NAVSnapiLexerConsumeIdentifier
 * @private
 * @description Consume an identifier token from the lexer input.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if identifier consumed successfully, False (0) if failed
 */
define_function char NAVSnapiLexerConsumeIdentifier(_NAVSnapiLexer lexer) {
    while (!NAVSnapiLexerIsEOF(lexer) &&
            NAVSnapiLexerIsIdentifierChar(lexer.source[lexer.cursor])) {
        if (!NAVSnapiLexerConsume(lexer, "lexer.source[lexer.cursor]")) {
            return false
        }
    }

    if (!NAVSnapiLexerEmitToken(lexer, NAV_SNAPI_TOKEN_TYPE_IDENTIFIER)) {
        return false
    }

    return true
}


/**
 * @function NAVSnapiLexerConsumeString
 * @private
 * @description Consume a quoted string token from the lexer input.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if string consumed successfully, False (0) if failed or unterminated
 */
define_function char NAVSnapiLexerConsumeString(_NAVSnapiLexer lexer) {
    stack_var char closed

    // Consume the opening quote
    if (!NAVSnapiLexerConsume(lexer, '"')) {
        return false
    }

    closed = false

    while (!NAVSnapiLexerIsEOF(lexer)) {
        stack_var char ch

        ch = lexer.source[lexer.cursor]

        if (ch == '"') {
            // Handle escaped quote
            if (NAVSnapiLexerPeek(lexer) == '"') {
                if (!NAVSnapiLexerConsume(lexer, '""')) {
                    return false
                }
            }
            else {
                // Closing quote
                closed = true

                if (!NAVSnapiLexerConsume(lexer, '"')) {
                    return false
                }

                if (!NAVSnapiLexerEmitToken(lexer, NAV_SNAPI_TOKEN_TYPE_STRING)) {
                    return false
                }

                break
            }
        }
        else {
            if (!NAVSnapiLexerConsume(lexer, "ch")) {
                return false
            }
        }
    }

    if (!closed) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SNAPI_LEXER__,
                                    'NAVSnapiLexerConsumeString',
                                    "'Unterminated string starting at position ', itoa(lexer.start)")
        return false
    }

    return true
}


/**
 * @function NAVSnapiLexerConsumeWhitespace
 * @private
 * @description Consume whitespace tokens (spaces and tabs) from the lexer input.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if whitespace consumed successfully, False (0) if failed
 */
define_function char NAVSnapiLexerConsumeWhitespace(_NAVSnapiLexer lexer) {
    while (!NAVSnapiLexerIsEOF(lexer) &&
            NAVSnapiLexerIsWhitespaceChar(lexer.source[lexer.cursor])) {
        if (!NAVSnapiLexerConsume(lexer, "lexer.source[lexer.cursor]")) {
            return false
        }
    }

    if (!NAVSnapiLexerEmitToken(lexer, NAV_SNAPI_TOKEN_TYPE_WHITESPACE)) {
        return false
    }

    return true
}


/**
 * @function NAVSnapiLexerTokenSerialize
 * @public
 * @description Serialize a token to a JSON-like string representation for debugging.
 *
 * @param {_NAVSnapiToken} token - The token to serialize
 *
 * @returns {char[NAV_MAX_BUFFER]} JSON-like string representation of the token
 */
define_function char[NAV_MAX_BUFFER] NAVSnapiLexerTokenSerialize(_NAVSnapiToken token) {
    return "'{ "type": "', NAVSnapiLexerGetTokenType(token.type), '", "value": "', token.value, '" }'"
}


/**
 * @function NAVSnapiLexerGetTokenType
 * @public
 * @description Get the string representation of a token type.
 *
 * @param {integer} type - The token type constant
 *
 * @returns {char[NAV_MAX_CHARS]} String representation of the token type
 */
define_function char[NAV_MAX_CHARS] NAVSnapiLexerGetTokenType(integer type) {
    switch (type) {
        case NAV_SNAPI_TOKEN_TYPE_DASH:         { return 'DASH' }           // -
        case NAV_SNAPI_TOKEN_TYPE_QUESTIONMARK: { return 'QUESTIONMARK' }   // ?
        case NAV_SNAPI_TOKEN_TYPE_COMMA:        { return 'COMMA' }          // ,
        case NAV_SNAPI_TOKEN_TYPE_IDENTIFIER:   { return 'IDENTIFIER' }     // Alphanumeric strings
        case NAV_SNAPI_TOKEN_TYPE_STRING:       { return 'STRING' }         // Quoted strings or unquoted values
        case NAV_SNAPI_TOKEN_TYPE_WHITESPACE:   { return 'WHITESPACE' }     // Spaces or tabs
        case NAV_SNAPI_TOKEN_TYPE_EOF:          { return 'EOF' }            // End of file/input
        default:                                { return 'UNKNOWN' }
    }
}


// ============================================================================
// DEBUG OUTPUT
// ============================================================================

/**
 * @function NAVSnapiLexerPrintTokens
 * @public
 * @description Print all tokens in the lexer for debugging purposes.
 *
 * Outputs a formatted list of all tokens with their types and values.
 * Useful for debugging tokenization issues.
 *
 * @param {_NAVSnapiLexer} lexer - The lexer structure containing tokens
 *
 * @returns {void}
 */
define_function NAVSnapiLexerPrintTokens(_NAVSnapiLexer lexer) {
    stack_var integer i
    stack_var char message[255]

    if (lexer.tokenCount <= 0) {
        NAVLog('[]')
        return
    }

    for (i = 1; i <= lexer.tokenCount; i++) {
        message = "'  [', itoa(i), '] ', NAVSnapiLexerGetTokenType(lexer.tokens[i].type)"

        if (lexer.tokens[i].type != NAV_SNAPI_TOKEN_TYPE_EOF) {
            message = "message, ' value="', lexer.tokens[i].value, '"'"
        }

        NAVLog(message)
    }
}


#END_IF // __NAV_FOUNDATION_SNAPI_LEXER__
