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
        // NAVLog("'[', itoa(lexer.cursor), '] ', ch")

        switch (ch) {
            case ',': {
                // NAVLog("'Encountered comma'")
                lexer.tokenCount++
                lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_COMMA
                lexer.tokens[lexer.tokenCount].value = "ch"
            }
            case NAV_LF: {
                // NAVLog("'Encountered newline LF'")
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

                // NAVLog("'Encountered newline CR or CRLF'")

                lexer.tokenCount++
                lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_NEWLINE
                lexer.tokens[lexer.tokenCount].value = value
            }
            case NAV_TAB:
            case ' ': {
                // NAVLog("'Encountered whitespace'")
                NAVCsvLexerConsumeWhitespace(lexer)
            }
            case '"': {
                // NAVLog("'Encountered string'")
                NAVCsvLexerConsumeString(lexer)
            }
            default: {
                if (NAVCsvLexerIsIdentifierChar(ch)) {
                    // NAVLog("'Encountered identifier'")
                    NAVCsvLexerConsumeIdentifier(lexer)
                }
            }
        }
    }

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

    // NAVLog("'Consuming identifier starting with: ', lexer.source[lexer.cursor]")

    value = "lexer.source[lexer.cursor]"

    while (NAVCsvLexerHasMoreTokens(lexer) &&
            NAVCsvLexerIsIdentifierChar(lexer.source[lexer.cursor + 1])) {
        if (!NAVCsvLexerAdvanceCursor(lexer)) {
            return
        }

        // NAVLog("'Appending to identifier: ', lexer.source[lexer.cursor]")
        value = "value, lexer.source[lexer.cursor]"
    }

    if (lexer.tokenCount >= NAV_CSV_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSV_LEXER__,
                                    'NAVCsvLexerConsumeIdentifier',
                                    "'Exceeded maximum token limit'")
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

    // NAVLog("'Consuming string'")

    while (NAVCsvLexerHasMoreTokens(lexer)) {
        stack_var char ch

        // Advance past the opening quote
        if (!NAVCsvLexerAdvanceCursor(lexer)) {
            return
        }

        ch = lexer.source[lexer.cursor]
        // NAVLog("'Processing string char: ', ch")

        switch (ch) {
            case '"': {
                // NAVLog("'Encountered double quote'")

                if (NAVCsvLexerHasMoreTokens(lexer)) {
                    stack_var char next

                    next = lexer.source[lexer.cursor + 1]

                    switch (next) {
                        case '"': {
                            if (!NAVCsvLexerAdvanceCursor(lexer)) {
                                return
                            }

                            value = "value, ch"
                            // NAVLog("'Escaped quote found, appending to string'")
                            continue
                        }
                    }
                }

                // Closing quote
                // NAVLog("'Closing quote found, ending string consumption'")
                break
            }
            default: {
                value = "value, ch"
                // NAVLog("'Appending to string: ', ch")
            }
        }

        // If we hit a closing quote, break out of the loop now
        if (ch == '"') {
            break
        }
    }

    if (lexer.tokenCount >= NAV_CSV_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSV_LEXER__,
                                    'NAVCsvLexerConsumeString',
                                    "'Exceeded maximum token limit'")
        return
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = NAV_CSV_TOKEN_TYPE_STRING
    lexer.tokens[lexer.tokenCount].value = value
}


define_function NAVCsvLexerConsumeWhitespace(_NAVCsvLexer lexer) {
    stack_var char value[NAV_CSV_LEXER_MAX_TOKEN_LENGTH]

    // NAVLog("'Consuming whitespace starting with: ', lexer.source[lexer.cursor]")

    value = "lexer.source[lexer.cursor]"

    while (NAVCsvLexerHasMoreTokens(lexer) &&
            (lexer.source[lexer.cursor + 1] == ' ' ||
             lexer.source[lexer.cursor + 1] == NAV_TAB)) {
        if (!NAVCsvLexerAdvanceCursor(lexer)) {
            return
        }

        // NAVLog("'Appending to whitespace: ', lexer.source[lexer.cursor]")
        value = "value, lexer.source[lexer.cursor]"
    }

    if (lexer.tokenCount >= NAV_CSV_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSV_LEXER__,
                                    'NAVCsvLexerConsumeWhitespace',
                                    "'Exceeded maximum token limit'")
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
