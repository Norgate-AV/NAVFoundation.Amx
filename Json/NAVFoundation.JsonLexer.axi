PROGRAM_NAME='NAVFoundation.JsonLexer'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_JSON_LEXER__
#DEFINE __NAV_FOUNDATION_JSON_LEXER__ 'NAVFoundation.JsonLexer'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.JsonLexer.h.axi'


// =============================================================================
// LEXER CORE FUNCTIONS
// =============================================================================

/**
 * @function NAVJsonLexerInit
 * @private
 * @description Initialize a JSON lexer with source text.
 *
 * @param {_NAVJsonLexer} lexer - The lexer structure to initialize
 * @param {char[]} source - The source text to tokenize
 *
 * @returns {void}
 */
define_function NAVJsonLexerInit(_NAVJsonLexer lexer, char source[]) {
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
 * @function NAVJsonLexerSetError
 * @private
 * @description Set an error state on the lexer.
 *
 * @param {_NAVJsonLexer} lexer - The lexer structure
 * @param {char[]} message - Error message
 *
 * @returns {void}
 */
define_function NAVJsonLexerSetError(_NAVJsonLexer lexer, char message[]) {
    lexer.hasError = true
    lexer.error = message

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                __NAV_FOUNDATION_JSON_LEXER__,
                                'NAVJsonLexer',
                                "message, ' at line ', itoa(lexer.line), ', column ', itoa(lexer.column)")
}


/**
 * @function NAVJsonLexerEmitToken
 * @private
 * @description Emit a token of the specified type with the current lexer position.
 *
 * @param {_NAVJsonLexer} lexer - The lexer structure
 * @param {integer} type - The token type to emit
 *
 * @returns {char} True (1) if token emitted successfully, False (0) if token limit reached
 */
define_function char NAVJsonLexerEmitToken(_NAVJsonLexer lexer, integer type) {
    if (!NAVJsonLexerCanAddToken(lexer)) {
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = type
    lexer.tokens[lexer.tokenCount].value = NAVStringSlice(lexer.source, lexer.start, lexer.cursor)
    lexer.tokens[lexer.tokenCount].start = lexer.start
    lexer.tokens[lexer.tokenCount].end = lexer.cursor - 1
    lexer.tokens[lexer.tokenCount].line = lexer.line
    lexer.tokens[lexer.tokenCount].column = lexer.column - (lexer.cursor - lexer.start)
    set_length_array(lexer.tokens, lexer.tokenCount)

    lexer.start = lexer.cursor

    return true
}


/**
 * @function NAVJsonLexerIgnore
 * @private
 * @description Ignore the current token by advancing the start position to the cursor.
 *
 * @param {_NAVJsonLexer} lexer - The lexer structure
 *
 * @returns {char} Always returns True (1)
 */
define_function char NAVJsonLexerIgnore(_NAVJsonLexer lexer) {
    lexer.start = lexer.cursor

    return true
}


/**
 * @function NAVJsonLexerIsEOF
 * @private
 * @description Check if the lexer has reached the end of the source text.
 *
 * @param {_NAVJsonLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if at end of file, False (0) otherwise
 */
define_function char NAVJsonLexerIsEOF(_NAVJsonLexer lexer) {
    return lexer.cursor > length_array(lexer.source)
}


/**
 * @function NAVJsonLexerNext
 * @private
 * @description Advance the cursor by one character, tracking line/column.
 *
 * @param {_NAVJsonLexer} lexer - The lexer structure
 *
 * @returns {char} The consumed character, or 0 if EOF
 */
define_function char NAVJsonLexerNext(_NAVJsonLexer lexer) {
    stack_var char ch

    if (NAVJsonLexerIsEOF(lexer)) {
        return 0
    }

    ch = lexer.source[lexer.cursor]
    lexer.cursor++
    lexer.column++

    // Track newlines
    if (ch == NAV_LF || ch == NAV_CR) {
        lexer.line++
        lexer.column = 1

        // Handle CRLF
        if (ch == NAV_CR && !NAVJsonLexerIsEOF(lexer) && lexer.source[lexer.cursor] == NAV_LF) {
            lexer.cursor++
        }
    }

    return ch
}


/**
 * @function NAVJsonLexerConsume
 * @private
 * @description Consume a specific string from the lexer source if it matches.
 *
 * @param {_NAVJsonLexer} lexer - The lexer structure
 * @param {char[]} value - The string to consume
 *
 * @returns {char} True (1) if the value was consumed successfully, False (0) if no match or EOF
 */
define_function char NAVJsonLexerConsume(_NAVJsonLexer lexer, char value[]) {
    stack_var integer length
    stack_var integer i

    length = length_array(value)

    if (!length) {
        return false
    }

    for (i = 1; i <= length; i++) {
        if (NAVJsonLexerIsEOF(lexer) ||
            lexer.source[lexer.cursor] != value[i]) {
            return false
        }

        NAVJsonLexerNext(lexer)
    }

    return true
}


/**
 * @function NAVJsonLexerIsWhitespaceChar
 * @private
 * @description Check if a character is a JSON whitespace character.
 * JSON defines whitespace as: space, tab, newline, carriage return
 *
 * @param {char} value - The character to check
 *
 * @returns {char} True (1) if the character is whitespace, False (0) otherwise
 */
define_function char NAVJsonLexerIsWhitespaceChar(char value) {
    return value == ' ' || value == NAV_TAB || value == NAV_LF || value == NAV_CR
}


/**
 * @function NAVJsonLexerCanPeek
 * @private
 * @description Check if the lexer can peek at the next character.
 *
 * @param {_NAVJsonLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if peek is possible, False (0) if at or near end of source
 */
define_function char NAVJsonLexerCanPeek(_NAVJsonLexer lexer) {
    return lexer.cursor + 1 <= length_array(lexer.source)
}


/**
 * @function NAVJsonLexerPeek
 * @private
 * @description Peek at the next character in the source without consuming it.
 *
 * @param {_NAVJsonLexer} lexer - The lexer structure
 *
 * @returns {char} The next character, or 0 if unable to peek
 */
define_function char NAVJsonLexerPeek(_NAVJsonLexer lexer) {
    if (!NAVJsonLexerCanPeek(lexer)) {
        return 0
    }

    return lexer.source[lexer.cursor + 1]
}


/**
 * @function NAVJsonLexerCanAddToken
 * @private
 * @description Check if the lexer can accept another token without exceeding the maximum limit.
 *
 * @param {_NAVJsonLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if token can be added, False (0) if limit reached
 */
define_function char NAVJsonLexerCanAddToken(_NAVJsonLexer lexer) {
    if (lexer.tokenCount >= NAV_JSON_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JSON_LEXER__,
                                    'NAVJsonLexerCanAddToken',
                                    "'Exceeded maximum token limit (', itoa(NAV_JSON_LEXER_MAX_TOKENS), ')'")
        return false
    }

    return true
}


/**
 * @function NAVJsonLexerTokenize
 * @public
 * @description Tokenize the source JSON text into an array of tokens.
 *
 * @param {_NAVJsonLexer} lexer - The lexer instance
 * @param {char[]} source - The source text to tokenize
 *
 * @returns {char} True (1) if tokenization succeeded, False (0) if failed
 */
define_function char NAVJsonLexerTokenize(_NAVJsonLexer lexer, char source[]) {
    NAVJsonLexerInit(lexer, source)

    if (!length_array(lexer.source)) {
        // Empty source, emit EOF token
        if (!NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_EOF)) {
            return false
        }

        #IF_DEFINED JSON_LEXER_DEBUG
        NAVLog("'[ JsonLexerTokenize ]: Tokenization complete. Total tokens: ', itoa(lexer.tokenCount)")
        NAVJsonLexerPrintTokens(lexer)
        #END_IF

        return true
    }

    while (!NAVJsonLexerIsEOF(lexer)) {
        stack_var char ch

        if (!NAVJsonLexerCanAddToken(lexer)) {
            return false
        }

        ch = lexer.source[lexer.cursor]

        #IF_DEFINED JSON_LEXER_DEBUG
        NAVLog("'[ JsonLexerTokenize ]: cursor=', itoa(lexer.cursor), ' char=', ch, ' (', itoa(type_cast(ch)), ')'")
        #END_IF

        // Skip whitespace (JSON whitespace is not significant outside strings)
        if (NAVJsonLexerIsWhitespaceChar(ch)) {
            NAVJsonLexerNext(lexer)
            lexer.start = lexer.cursor
            continue
        }

        switch (ch) {
            case '{': {
                NAVJsonLexerNext(lexer)
                if (!NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_LEFT_BRACE)) {
                    return false
                }
            }
            case '}': {
                NAVJsonLexerNext(lexer)
                if (!NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_RIGHT_BRACE)) {
                    return false
                }
            }
            case '[': {
                NAVJsonLexerNext(lexer)
                if (!NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_LEFT_BRACKET)) {
                    return false
                }
            }
            case ']': {
                NAVJsonLexerNext(lexer)
                if (!NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET)) {
                    return false
                }
            }
            case ':': {
                NAVJsonLexerNext(lexer)
                if (!NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_COLON)) {
                    return false
                }
            }
            case ',': {
                NAVJsonLexerNext(lexer)
                if (!NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_COMMA)) {
                    return false
                }
            }
            case '"': {
                if (!NAVJsonLexerConsumeString(lexer)) {
                    return false
                }
            }
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
                if (!NAVJsonLexerConsumeNumber(lexer)) {
                    return false
                }
            }
            case 't': {
                if (!NAVJsonLexerConsumeTrue(lexer)) {
                    return false
                }
            }
            case 'f': {
                if (!NAVJsonLexerConsumeFalse(lexer)) {
                    return false
                }
            }
            case 'n': {
                if (!NAVJsonLexerConsumeNull(lexer)) {
                    return false
                }
            }
            default: {
                NAVJsonLexerSetError(lexer, "'Unexpected character: ', ch, ' (', itoa(type_cast(ch)), ')'")
                return false
            }
        }
    }

    if (!NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_EOF)) {
        return false
    }

    #IF_DEFINED JSON_LEXER_DEBUG
    NAVLog("'[ JsonLexerTokenize ]: Tokenization complete. Total tokens: ', itoa(lexer.tokenCount)")
    NAVJsonLexerPrintTokens(lexer)
    #END_IF

    return true
}


// =============================================================================
// JSON-SPECIFIC CONSUME FUNCTIONS
// =============================================================================

/**
 * @function NAVJsonLexerConsumeString
 * @private
 * @description Consume a JSON string token with proper escape sequence handling.
 *
 * @param {_NAVJsonLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if string consumed successfully, False (0) if failed
 */
define_function char NAVJsonLexerConsumeString(_NAVJsonLexer lexer) {
    // Consume opening quote
    NAVJsonLexerNext(lexer) // "

    while (!NAVJsonLexerIsEOF(lexer)) {
        stack_var char ch

        ch = lexer.source[lexer.cursor]

        if (ch == '"') {
            // Closing quote found
            NAVJsonLexerNext(lexer)
            return NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_STRING)
        }
        else if (ch == '\') {
            // Escape sequence
            NAVJsonLexerNext(lexer) // consume backslash

            if (NAVJsonLexerIsEOF(lexer)) {
                NAVJsonLexerSetError(lexer, 'Unterminated string (EOF in escape sequence)')
                return false
            }

            ch = lexer.source[lexer.cursor]

            // Valid JSON escape sequences: \" \\ \/ \b \f \n \r \t \uXXXX
            switch (ch) {
                case '"':
                case '\':
                case '/':
                case 'b':
                case 'f':
                case 'n':
                case 'r':
                case 't': {
                    NAVJsonLexerNext(lexer)
                }
                case 'u': {
                    // Unicode escape: \uXXXX (4 hex digits)
                    NAVJsonLexerNext(lexer) // consume 'u'

                    if (!NAVJsonLexerConsumeHexDigits(lexer, 4)) {
                        NAVJsonLexerSetError(lexer, 'Invalid unicode escape sequence')
                        return false
                    }
                }
                default: {
                    NAVJsonLexerSetError(lexer, "'Invalid escape sequence: \', ch")
                    return false
                }
            }
        }
        else if (ch < ' ') {
            // Control characters must be escaped in JSON
            NAVJsonLexerSetError(lexer, "'Unescaped control character in string: ', itoa(type_cast(ch))")
            return false
        }
        else {
            NAVJsonLexerNext(lexer)
        }
    }

    NAVJsonLexerSetError(lexer, 'Unterminated string')
    return false
}


/**
 * @function NAVJsonLexerConsumeHexDigits
 * @private
 * @description Consume a specified number of hexadecimal digits.
 *
 * @param {_NAVJsonLexer} lexer - The lexer instance
 * @param {integer} count - Number of hex digits to consume
 *
 * @returns {char} True (1) if consumed successfully, False (0) otherwise
 */
define_function char NAVJsonLexerConsumeHexDigits(_NAVJsonLexer lexer, integer count) {
    stack_var integer i

    for (i = 1; i <= count; i++) {
        if (NAVJsonLexerIsEOF(lexer)) {
            return false
        }

        if (!NAVIsHexDigit(lexer.source[lexer.cursor])) {
            return false
        }

        NAVJsonLexerNext(lexer)
    }

    return true
}


/**
 * @function NAVJsonLexerConsumeNumber
 * @private
 * @description Consume a JSON number token following RFC 8259 grammar.
 * Grammar: number = [ minus ] int [ frac ] [ exp ]
 *
 * @param {_NAVJsonLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if number consumed successfully, False (0) otherwise
 */
define_function char NAVJsonLexerConsumeNumber(_NAVJsonLexer lexer) {
    // Optional minus
    if (lexer.source[lexer.cursor] == '-') {
        NAVJsonLexerNext(lexer)
    }

    if (NAVJsonLexerIsEOF(lexer)) {
        NAVJsonLexerSetError(lexer, 'Invalid number: unexpected EOF')
        return false
    }

    // Integer part
    if (lexer.source[lexer.cursor] == '0') {
        // Leading zero must not be followed by another digit
        NAVJsonLexerNext(lexer)

        // Check that next character is not a digit (RFC 8259: no leading zeros allowed)
        if (!NAVJsonLexerIsEOF(lexer) && NAVIsDigit(lexer.source[lexer.cursor])) {
            NAVJsonLexerSetError(lexer, 'Invalid number: leading zeros are not allowed')
            return false
        }
    }
    else if (NAVIsDigit(lexer.source[lexer.cursor])) {
        // 1-9 followed by any digits
        NAVJsonLexerNext(lexer)

        while (!NAVJsonLexerIsEOF(lexer) && NAVIsDigit(lexer.source[lexer.cursor])) {
            NAVJsonLexerNext(lexer)
        }
    }
    else {
        NAVJsonLexerSetError(lexer, "'Invalid number: expected digit, got ', lexer.source[lexer.cursor]")
        return false
    }

    // Optional fractional part
    if (!NAVJsonLexerIsEOF(lexer) && lexer.source[lexer.cursor] == '.') {
        NAVJsonLexerNext(lexer) // consume '.'

        if (NAVJsonLexerIsEOF(lexer) || !NAVIsDigit(lexer.source[lexer.cursor])) {
            NAVJsonLexerSetError(lexer, 'Invalid number: digit required after decimal point')
            return false
        }

        while (!NAVJsonLexerIsEOF(lexer) && NAVIsDigit(lexer.source[lexer.cursor])) {
            NAVJsonLexerNext(lexer)
        }
    }

    // Optional exponent part
    if (!NAVJsonLexerIsEOF(lexer) && (lexer.source[lexer.cursor] == 'e' || lexer.source[lexer.cursor] == 'E')) {
        NAVJsonLexerNext(lexer) // consume 'e' or 'E'

        if (NAVJsonLexerIsEOF(lexer)) {
            NAVJsonLexerSetError(lexer, 'Invalid number: unexpected EOF in exponent')
            return false
        }

        // Optional sign
        if (lexer.source[lexer.cursor] == '+' || lexer.source[lexer.cursor] == '-') {
            NAVJsonLexerNext(lexer)
        }

        if (NAVJsonLexerIsEOF(lexer) || !NAVIsDigit(lexer.source[lexer.cursor])) {
            NAVJsonLexerSetError(lexer, 'Invalid number: digit required in exponent')
            return false
        }

        while (!NAVJsonLexerIsEOF(lexer) && NAVIsDigit(lexer.source[lexer.cursor])) {
            NAVJsonLexerNext(lexer)
        }
    }

    return NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_NUMBER)
}


/**
 * @function NAVJsonLexerConsumeTrue
 * @private
 * @description Consume the 'true' literal.
 *
 * @param {_NAVJsonLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if consumed successfully, False (0) otherwise
 */
define_function char NAVJsonLexerConsumeTrue(_NAVJsonLexer lexer) {
    if (!NAVJsonLexerConsume(lexer, 'true')) {
        NAVJsonLexerSetError(lexer, 'Invalid literal: expected "true"')
        return false
    }

    return NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_TRUE)
}


/**
 * @function NAVJsonLexerConsumeFalse
 * @private
 * @description Consume the 'false' literal.
 *
 * @param {_NAVJsonLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if consumed successfully, False (0) otherwise
 */
define_function char NAVJsonLexerConsumeFalse(_NAVJsonLexer lexer) {
    if (!NAVJsonLexerConsume(lexer, 'false')) {
        NAVJsonLexerSetError(lexer, 'Invalid literal: expected "false"')
        return false
    }

    return NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_FALSE)
}


/**
 * @function NAVJsonLexerConsumeNull
 * @private
 * @description Consume the 'null' literal.
 *
 * @param {_NAVJsonLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if consumed successfully, False (0) otherwise
 */
define_function char NAVJsonLexerConsumeNull(_NAVJsonLexer lexer) {
    if (!NAVJsonLexerConsume(lexer, 'null')) {
        NAVJsonLexerSetError(lexer, 'Invalid literal: expected "null"')
        return false
    }

    return NAVJsonLexerEmitToken(lexer, NAV_JSON_TOKEN_TYPE_NULL)
}


// =============================================================================
// HELPER AND DEBUG FUNCTIONS
// =============================================================================

/**
 * @function NAVJsonLexerGetTokenType
 * @public
 * @description Get the string representation of a token type.
 *
 * @param {integer} type - The token type constant
 *
 * @returns {char[NAV_MAX_CHARS]} String representation of the token type
 */
define_function char[NAV_MAX_CHARS] NAVJsonLexerGetTokenType(integer type) {
    switch (type) {
        case NAV_JSON_TOKEN_TYPE_LEFT_BRACE:    { return 'LEFT_BRACE' }     // {
        case NAV_JSON_TOKEN_TYPE_RIGHT_BRACE:   { return 'RIGHT_BRACE' }    // }
        case NAV_JSON_TOKEN_TYPE_LEFT_BRACKET:  { return 'LEFT_BRACKET' }   // [
        case NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET: { return 'RIGHT_BRACKET' }  // ]
        case NAV_JSON_TOKEN_TYPE_COLON:         { return 'COLON' }          // :
        case NAV_JSON_TOKEN_TYPE_COMMA:         { return 'COMMA' }          // ,
        case NAV_JSON_TOKEN_TYPE_STRING:        { return 'STRING' }         // "string"
        case NAV_JSON_TOKEN_TYPE_NUMBER:        { return 'NUMBER' }         // 123, -45.67
        case NAV_JSON_TOKEN_TYPE_TRUE:          { return 'TRUE' }           // true
        case NAV_JSON_TOKEN_TYPE_FALSE:         { return 'FALSE' }          // false
        case NAV_JSON_TOKEN_TYPE_NULL:          { return 'NULL' }           // null
        case NAV_JSON_TOKEN_TYPE_EOF:           { return 'EOF' }            // End of input
        case NAV_JSON_TOKEN_TYPE_ERROR:         { return 'ERROR' }          // Error token
        default:                                { return 'UNKNOWN' }
    }
}


/**
 * @function NAVJsonLexerTokenSerialize
 * @public
 * @description Serialize a token to a JSON-like string representation for debugging.
 *
 * @param {_NAVJsonToken} token - The token to serialize
 *
 * @returns {char[NAV_MAX_BUFFER]} JSON-like string representation of the token
 */
define_function char[NAV_MAX_BUFFER] NAVJsonLexerTokenSerialize(_NAVJsonToken token) {
    return "'{ "type": "', NAVJsonLexerGetTokenType(token.type), '", "value": "', token.value, '", "line": ', itoa(token.line), ', "column": ', itoa(token.column), ' }'"
}


/**
 * @function NAVJsonLexerPrintTokens
 * @public
 * @description Print all tokens in the lexer for debugging purposes.
 *
 * @param {_NAVJsonLexer} lexer - The lexer structure containing tokens
 *
 * @returns {void}
 */
define_function NAVJsonLexerPrintTokens(_NAVJsonLexer lexer) {
    stack_var integer i
    stack_var char message[255]

    if (lexer.tokenCount <= 0) {
        NAVLog('[]')
        return
    }

    NAVLog('JSON Lexer Tokens:')

    for (i = 1; i <= lexer.tokenCount; i++) {
        message = "'  [', itoa(i), '] ', NAVJsonLexerGetTokenType(lexer.tokens[i].type)"
        message = "message, ' @ L', itoa(lexer.tokens[i].line), ':C', itoa(lexer.tokens[i].column)"

        if (lexer.tokens[i].type != NAV_JSON_TOKEN_TYPE_EOF) {
            message = "message, ' = "', lexer.tokens[i].value, '"'"
        }

        NAVLog(message)
    }
}


#END_IF // __NAV_FOUNDATION_JSON_LEXER__

