PROGRAM_NAME='NAVFoundation.IniFileLexer'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_INIFILE_LEXER__
#DEFINE __NAV_FOUNDATION_INIFILE_LEXER__ 'NAVFoundation.IniFileLexer'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.IniFileLexer.h.axi'


/**
 * @function NAVIniLexerInit
 * @public
 * @description Initialize an INI lexer with source text.
 *
 * @param {_IniLexer} lexer - The lexer structure to initialize
 * @param {char[]} source - The source text to tokenize
 *
 * @returns {void}
 */
define_function NAVIniLexerInit(_NAVIniLexer lexer, char source[]) {
    lexer.source = source
    lexer.cursor = 0
    lexer.tokenCount = 0
}


/**
 * @function NAVIniLexerHasMoreTokens
 * @private
 * @description Check if there are more characters to tokenize in the source.
 *
 * @param {_IniLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if more characters exist, False (0) otherwise
 */
define_function char NAVIniLexerHasMoreTokens(_NAVIniLexer lexer) {
    return lexer.cursor < length_array(lexer.source)
}


/**
 * @function NAVIniLexerCursorIsOutOfBounds
 * @private
 * @description Check if the lexer's cursor is out of bounds.
 *
 * @param {_IniLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if cursor is out of bounds, False (0) otherwise
 */
define_function char NAVIniLexerCursorIsOutOfBounds(_NAVIniLexer lexer) {
    return lexer.cursor <= 0 || lexer.cursor > length_array(lexer.source)
}


/**
 * @function NAVIniLexerAdvanceCursor
 * @private
 * @description Advance the lexer's cursor by one position.
 *
 * @param {_IniLexer} lexer - The lexer to advance
 *
 * @returns {char} True (1) if cursor advanced successfully, False (0) if out of bounds
 */
define_function char NAVIniLexerAdvanceCursor(_NAVIniLexer lexer) {
    lexer.cursor++

    if (NAVIniLexerCursorIsOutOfBounds(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_LEXER__,
                                    'NAVIniLexerAdvanceCursor',
                                    "'Lexer cursor out of bounds: ', itoa(lexer.cursor)")
        return false
    }


    return true
}


/**
 * @function NAVIniLexerTokenize
 * @public
 * @description Tokenize the source text into an array of tokens.
 *
 * @param {_IniLexer} lexer - The initialized lexer
 *
 * @returns {char} True (1) if tokenization succeeded, False (0) if failed
 */
define_function char NAVIniLexerTokenize(_NAVIniLexer lexer) {
    while (NAVIniLexerHasMoreTokens(lexer)) {
        stack_var char ch

        if (lexer.tokenCount == NAV_INI_LEXER_MAX_TOKENS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_INIFILE_LEXER__,
                                        'NAVIniLexerTokenize',
                                        "'Exceeded maximum token limit'")
            return false
        }

        if (!NAVIniLexerAdvanceCursor(lexer)) {
            return false
        }

        ch = lexer.source[lexer.cursor]

        switch (ch) {
            case '[': {
                lexer.tokenCount++
                lexer.tokens[lexer.tokenCount].type = NAV_INI_TOKEN_TYPE_LBRACKET
                lexer.tokens[lexer.tokenCount].value = "ch"
            }
            case ']': {
                lexer.tokenCount++
                lexer.tokens[lexer.tokenCount].type = NAV_INI_TOKEN_TYPE_RBRACKET
                lexer.tokens[lexer.tokenCount].value = "ch"
            }
            case '=': {
                lexer.tokenCount++
                lexer.tokens[lexer.tokenCount].type = NAV_INI_TOKEN_TYPE_EQUALS
                lexer.tokens[lexer.tokenCount].value = "ch"
            }
            case ';':
            case '#':{
                NAVIniLexerConsumeComment(lexer)
            }
            case NAV_LF: {
                // Unix style newline \n
                lexer.tokenCount++
                lexer.tokens[lexer.tokenCount].type = NAV_INI_TOKEN_TYPE_NEWLINE
                lexer.tokens[lexer.tokenCount].value = "ch"
            }
            case NAV_CR: {
                // Windows style newline \r\n
                stack_var char value[2]

                value = "ch"

                if (NAVIniLexerHasMoreTokens(lexer) &&
                    lexer.source[lexer.cursor + 1] == NAV_LF) {
                    if (!NAVIniLexerAdvanceCursor(lexer)) {
                        return false
                    }
                    value = "value, lexer.source[lexer.cursor]"
                }

                lexer.tokenCount++
                lexer.tokens[lexer.tokenCount].type = NAV_INI_TOKEN_TYPE_NEWLINE
                lexer.tokens[lexer.tokenCount].value = value
            }
            case NAV_TAB:
            case ' ': {
                // Ignore whitespace
            }
            case '"':
            case $27: {
                NAVIniLexerConsumeString(lexer, ch)
            }
            default: {
                if (NAVIniLexerIsIdentifierChar(ch)) {
                    NAVIniLexerConsumeIdentifier(lexer)
                }
            }
        }
    }

    set_length_array(lexer.tokens, lexer.tokenCount)

    return true
}


/**
 * @function NAVIniLexerIsIdentifierChar
 * @private
 * @description Check if a character is valid for use in an identifier.
 *
 * @param {char} value - The character to check
 *
 * @returns {char} True (1) if character is valid for identifiers, False (0) otherwise
 */
define_function char NAVIniLexerIsIdentifierChar(char value) {
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
 * @function NAVIniLexerConsumeComment
 * @private
 * @description Consume a comment token from the lexer input.
 *
 * @param {_IniLexer} lexer - The lexer instance
 *
 * @returns {void}
 */
define_function NAVIniLexerConsumeComment(_NAVIniLexer lexer) {
    stack_var char value[NAV_INI_LEXER_MAX_TOKEN_LENGTH]

    value = "lexer.source[lexer.cursor]"

    while (NAVIniLexerHasMoreTokens(lexer) &&
           lexer.source[lexer.cursor + 1] != NAV_CR &&
           lexer.source[lexer.cursor + 1] != NAV_LF) {
        if (!NAVIniLexerAdvanceCursor(lexer)) {
            return
        }
        value = "value, lexer.source[lexer.cursor]"
    }

    if (lexer.tokenCount >= NAV_INI_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_LEXER__,
                                    'NAVIniLexerConsumeComment',
                                    "'Exceeded maximum token limit'")
        return
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = NAV_INI_TOKEN_TYPE_COMMENT
    lexer.tokens[lexer.tokenCount].value = value
}


/**
 * @function NAVIniLexerConsumeIdentifier
 * @private
 * @description Consume an identifier token from the lexer input.
 *
 * @param {_IniLexer} lexer - The lexer instance
 *
 * @returns {void}
 */
define_function NAVIniLexerConsumeIdentifier(_NAVIniLexer lexer) {
    stack_var char value[NAV_INI_LEXER_MAX_TOKEN_LENGTH]

    value = "lexer.source[lexer.cursor]"

    while (NAVIniLexerHasMoreTokens(lexer) &&
            NAVIniLexerIsIdentifierChar(lexer.source[lexer.cursor + 1])) {
        if (!NAVIniLexerAdvanceCursor(lexer)) {
            return
        }
        value = "value, lexer.source[lexer.cursor]"
    }

    if (lexer.tokenCount >= NAV_INI_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_LEXER__,
                                    'NAVIniLexerConsumeIdentifier',
                                    "'Exceeded maximum token limit'")
        return
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    lexer.tokens[lexer.tokenCount].value = value
}


/**
 * @function NAVIniLexerConsumeString
 * @private
 * @description Consume a quoted string token from the lexer input.
 *
 * @param {_IniLexer} lexer - The lexer instance
 * @param {char} quote - The quote character that started the string (single or double quote)
 *
 * @returns {void}
 */
define_function NAVIniLexerConsumeString(_NAVIniLexer lexer, char quote) {
    stack_var char value[NAV_INI_LEXER_MAX_TOKEN_LENGTH]
    stack_var char raw

    raw = (quote == $27)    // Treat single quoted strings as raw (no escape sequences)

    while (NAVIniLexerHasMoreTokens(lexer)) {
        stack_var char ch

        // Advance past the opening quote
        if (!NAVIniLexerAdvanceCursor(lexer)) {
            return
        }

        ch = lexer.source[lexer.cursor]

        if (ch == quote) {
            // Closing quote
            break
        }

        if (raw) {
            // Raw string - treat everything literally until closing quote
            value = "value, ch"
            continue
        }

        switch (ch) {
            case '\': {
                // Escape sequence
                if (NAVIniLexerHasMoreTokens(lexer)) {
                    stack_var char next

                    next = lexer.source[lexer.cursor + 1]

                    switch (next) {
                        case 'n': {
                            if (!NAVIniLexerAdvanceCursor(lexer)) {
                                return
                            }
                            value = "value, NAV_LF"
                        }
                        case 'r': {
                            if (!NAVIniLexerAdvanceCursor(lexer)) {
                                return
                            }
                            value = "value, NAV_CR"
                        }
                        case 't': {
                            if (!NAVIniLexerAdvanceCursor(lexer)) {
                                return
                            }
                            value = "value, NAV_TAB"
                        }
                        case '\': {
                            if (!NAVIniLexerAdvanceCursor(lexer)) {
                                return
                            }
                            value = "value, '\'"
                        }
                        case '"': {
                            if (quote == '"') {
                                if (!NAVIniLexerAdvanceCursor(lexer)) {
                                    return
                                }
                                value = "value, quote"
                                break
                            }

                            value = "value, ch"
                        }
                        case $27: {
                            if (quote == $27) {
                                if (!NAVIniLexerAdvanceCursor(lexer)) {
                                    return
                                }
                                value = "value, quote"
                                break
                            }

                            value = "value, ch"
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
    }

    if (lexer.tokenCount >= NAV_INI_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INIFILE_LEXER__,
                                    'NAVIniLexerConsumeString',
                                    "'Exceeded maximum token limit'")
        return
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = NAV_INI_TOKEN_TYPE_STRING
    lexer.tokens[lexer.tokenCount].value = value
}


/**
 * @function NAVIniLexerTokenSerialize
 * @public
 * @description Serialize a token to a JSON-like string representation for debugging.
 *
 * @param {_NAVIniToken} token - The token to serialize
 *
 * @returns {char[NAV_MAX_BUFFER]} JSON-like string representation of the token
 */
define_function char[NAV_MAX_BUFFER] NAVIniLexerTokenSerialize(_NAVIniToken token) {
    return "'{ "type": "', NAVIniLexerGetTokenType(token.type), '", "value": "', token.value, '" }'"
}


/**
 * @function NAVIniLexerGetTokenType
 * @public
 * @description Get the string representation of a token type.
 *
 * @param {integer} type - The token type constant
 *
 * @returns {char[NAV_MAX_CHARS]} String representation of the token type
 */
define_function char[NAV_MAX_CHARS] NAVIniLexerGetTokenType(integer type) {
    switch (type) {
        case NAV_INI_TOKEN_TYPE_LBRACKET:   { return 'LBRACKET' }       // [
        case NAV_INI_TOKEN_TYPE_RBRACKET:   { return 'RBRACKET' }       // ]
        case NAV_INI_TOKEN_TYPE_EQUALS:     { return 'EQUALS' }         // =
        case NAV_INI_TOKEN_TYPE_IDENTIFIER: { return 'IDENTIFIER' }     // Alphanumeric strings (keys, section names)
        case NAV_INI_TOKEN_TYPE_STRING:     { return 'STRING' }         // Quoted strings or unquoted values
        case NAV_INI_TOKEN_TYPE_COMMENT:    { return 'COMMENT' }        // Comments starting with ; or #
        case NAV_INI_TOKEN_TYPE_NEWLINE:    { return 'NEWLINE' }        // Newline characters
        case NAV_INI_TOKEN_TYPE_EOF:        { return 'EOF' }            // End of file/input
        case NAV_INI_TOKEN_TYPE_WHITESPACE: { return 'WHITESPACE' }     // Spaces or tabs
        case NAV_INI_TOKEN_TYPE_ERROR:      { return 'ERROR' }          // Error token for unrecognized characters
        default:                    { return 'UNKNOWN' }
    }
}


#END_IF // __NAV_FOUNDATION_INIFILE_LEXER__
