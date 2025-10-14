PROGRAM_NAME='NAVFoundation.CsvParser'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CSV_PARSER__
#DEFINE __NAV_FOUNDATION_CSV_PARSER__ 'NAVFoundation.CsvParser'

#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.CsvLexer.axi'
#include 'NAVFoundation.CsvParser.h.axi'


/**
 * @function NAVCsvParserInit
 * @public
 * @description Initialize a CSV parser with an array of tokens.
 *
 * @param {_NAVCsvParser} parser - The parser structure to initialize
 * @param {_NAVCsvToken[]} tokens - Array of tokens to parse
 *
 * @returns {void}
 */
define_function NAVCsvParserInit(_NAVCsvParser parser, _NAVCsvToken tokens[]) {
    parser.tokens = tokens
    parser.tokenCount = length_array(tokens)
    parser.cursor = 0

    parser.rowCount = 1
    parser.columnCount = 0
}


/**
 * @function NAVCsvParserHasMoreTokens
 * @private
 * @description Check if there are more tokens to parse.
 *
 * @param {_NAVCsvParser} parser - The parser to check
 *
 * @returns {char} True (1) if more tokens exist, False (0) otherwise
 */
define_function char NAVCsvParserHasMoreTokens(_NAVCsvParser parser) {
    return (parser.tokenCount > 0 && parser.cursor >= 0 && parser.cursor < parser.tokenCount)
}


/**
 * @function NAVCsvParserAdvanceCursor
 * @private
 * @description Advance the parser cursor by one position.
 *
 * @param {_NAVCsvParser} parser - The parser to advance
 *
 * @returns {char} True (1) if cursor advanced successfully, False (0) if out of bounds
 */
define_function char NAVCsvParserAdvanceCursor(_NAVCsvParser parser) {
    parser.cursor++

    if (NAVCsvParserCursorIsOutOfBounds(parser)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSV_PARSER__,
                                    'NAVCsvParserAdvanceCursor',
                                    "'Parser cursor out of bounds: ', itoa(parser.cursor), ' (tokenCount: ', itoa(parser.tokenCount), ')'")
        return false
    }

    return true
}


/**
 * @function NAVCsvParserCursorIsOutOfBounds
 * @private
 * @description Check if the parser cursor is out of valid bounds.
 *
 * @param {_NAVCsvParser} parser - The parser to check
 *
 * @returns {char} True (1) if cursor is out of bounds, False (0) otherwise
 */
define_function char NAVCsvParserCursorIsOutOfBounds(_NAVCsvParser parser) {
    return (parser.cursor <= 0 || parser.cursor > parser.tokenCount)
}


/**
 * @function NAVCsvParserIsEmptyFieldComma
 * @private
 * @description Determine if the current comma token represents an empty field.
 *
 * @param {_NAVCsvParser} parser - The parser instance
 *
 * @returns {char} True (1) if this comma indicates an empty field, False (0) if it's just a separator
 */
define_function char NAVCsvParserIsEmptyFieldComma(_NAVCsvParser parser) {
    stack_var _NAVCsvToken prev
    stack_var _NAVCsvToken next

    // At row start (no columns yet)
    if (parser.columnCount == 0) {
        #IF_DEFINED CSV_PARSER_DEBUG
        NAVLog("'[DEBUG] IsEmptyFieldComma: TRUE - at row start (columnCount=0)'")
        #END_IF
        return true
    }

    // Check if next token is EOF or NEWLINE (trailing comma)
    // Also handle case where we're at end of tokens (no EOF token present)
    if (parser.cursor + 1 > parser.tokenCount) {
        // No more tokens after this comma - it's trailing
        #IF_DEFINED CSV_PARSER_DEBUG
        NAVLog("'[DEBUG] IsEmptyFieldComma: TRUE - at end of token stream (trailing comma)'")
        #END_IF
        return true
    }

    next = parser.tokens[parser.cursor + 1]

    if (next.type == NAV_CSV_TOKEN_TYPE_EOF || next.type == NAV_CSV_TOKEN_TYPE_NEWLINE) {
        #IF_DEFINED CSV_PARSER_DEBUG
        NAVLog("'[DEBUG] IsEmptyFieldComma: TRUE - next token is EOF or NEWLINE (trailing comma)'")
        #END_IF
        return true
    }

    // Next token is also a comma (consecutive commas mean empty field)
    if (next.type == NAV_CSV_TOKEN_TYPE_COMMA) {
        #IF_DEFINED CSV_PARSER_DEBUG
        NAVLog("'[DEBUG] IsEmptyFieldComma: TRUE - next token is also COMMA'")
        #END_IF
        return true
    }

    // Previous token was a comma (second comma in consecutive pair)
    if (parser.cursor > 1) {
        prev = parser.tokens[parser.cursor - 1]

        #IF_DEFINED CSV_PARSER_DEBUG
        NAVLog("'[DEBUG] IsEmptyFieldComma: prev token type=', itoa(prev.type), ' value=', prev.value")
        #END_IF

        if (prev.type == NAV_CSV_TOKEN_TYPE_COMMA) {
            #IF_DEFINED CSV_PARSER_DEBUG
            NAVLog("'[DEBUG] IsEmptyFieldComma: TRUE - previous token was COMMA'")
            #END_IF
            return true
        }
    }

    // Otherwise, comma is just a separator between values
    #IF_DEFINED CSV_PARSER_DEBUG
    NAVLog("'[DEBUG] IsEmptyFieldComma: FALSE - comma is just a separator'")
    #END_IF
    return false
}


/**
 * @function NAVCsvParserAddEmptyField
 * @private
 * @description Add an empty field to the current row.
 *
 * @param {_NAVCsvParser} parser - The parser instance
 * @param {char[][][]} data - The output 2D array
 */
define_function NAVCsvParserAddEmptyField(_NAVCsvParser parser, char data[][][]) {
    // parser.columnCount++
    // data[parser.rowCount][parser.columnCount] = ''
    // set_length_array(data[parser.rowCount], parser.columnCount)
    NAVCsvParserAddField(parser, data, '')
}


/**
 * @function NAVCsvParserAddField
 * @private
 * @description Add a field with the given value to the current row.
 *
 * @param {_NAVCsvParser} parser - The parser instance
 * @param {char[][][]} data - The output 2D array
 * @param {char[]} value - The value to add as a field
 */
define_function NAVCsvParserAddField(_NAVCsvParser parser, char data[][][], char value[]) {
    parser.columnCount++
    data[parser.rowCount][parser.columnCount] = value
    set_length_array(data[parser.rowCount], parser.columnCount)
}


/**
 * @function NAVCsvParserParse
 * @public
 * @description Parse the tokens into a 2D array representing CSV data.
 *
 * @param {_NAVCsvParser} parser - The initialized parser
 * @param {char[][][]} data - The output 2D array to hold parsed CSV data
 *
 * @returns {char} True (1) if parsing succeeded, False (0) if failed
 */
define_function char NAVCsvParserParse(_NAVCsvParser parser, char data[][][]) {
    while (NAVCsvParserHasMoreTokens(parser)) {
        stack_var _NAVCsvToken token

        if (!NAVCsvParserAdvanceCursor(parser)) {
            return false
        }

        token = parser.tokens[parser.cursor]

        #IF_DEFINED CSV_PARSER_DEBUG
        NAVLog("'[DEBUG] cursor=', itoa(parser.cursor), ' tokenType=', itoa(token.type), ' value=', token.value, ' rowCount=', itoa(parser.rowCount), ' columnCount=', itoa(parser.columnCount)")
        #END_IF

        switch (token.type) {
            case NAV_CSV_TOKEN_TYPE_IDENTIFIER: {
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] Processing IDENTIFIER'")
                #END_IF
                if (!NAVCsvParserParseIdentifier(parser, data)) {
                    return false
                }
            }
            case NAV_CSV_TOKEN_TYPE_STRING: {
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] Processing STRING'")
                #END_IF
                if (!NAVCsvParserParseQuotedIdentifier(parser, data)) {
                    return false
                }
            }
            case NAV_CSV_TOKEN_TYPE_COMMA: {
                stack_var char isEmptyField
                isEmptyField = NAVCsvParserIsEmptyFieldComma(parser)

                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] Processing COMMA, IsEmptyField=', itoa(isEmptyField)")
                #END_IF

                if (isEmptyField) {
                    NAVCsvParserAddEmptyField(parser, data)

                    // If no more tokens, add one more field for the position after the trailing comma
                    if (!NAVCsvParserHasMoreTokens(parser)) {
                        NAVCsvParserAddEmptyField(parser, data)
                        #IF_DEFINED CSV_PARSER_DEBUG
                        NAVLog("'[DEBUG] Added field after trailing comma - parsing complete'")
                        #END_IF
                        return true
                    }
                }
            }
            case NAV_CSV_TOKEN_TYPE_WHITESPACE: {
                if (NAVCsvParserHasMoreTokens(parser)) {
                    stack_var _NAVCsvToken next

                    next = parser.tokens[parser.cursor + 1]

                    switch (next.type) {
                        case NAV_CSV_TOKEN_TYPE_IDENTIFIER: {
                            if (!NAVCsvParserParseIdentifier(parser, data)) {
                                return false
                            }
                        }
                        case NAV_CSV_TOKEN_TYPE_STRING: {
                            // Ignore whitespace before quoted identifier
                            continue
                        }
                    }
                }
                else {
                    // Whitespace is the last token - parsing complete
                    #IF_DEFINED CSV_PARSER_DEBUG
                    NAVLog("'[DEBUG] Trailing whitespace at end of input - parsing complete'")
                    #END_IF
                    return true
                }
            }
            case NAV_CSV_TOKEN_TYPE_NEWLINE: {
                // If we encounter a newline token then we increment the row count
                parser.rowCount++
                parser.columnCount = 0
            }
            case NAV_CSV_TOKEN_TYPE_EOF: {
                // EOF token indicates end of input - exit the parsing loop
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] Reached EOF token - parsing complete'")
                #END_IF
                // Exit the while loop by returning success
                return true
            }
            default: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_CSV_PARSER__,
                                            'NAVCsvFileParserParse',
                                            "'Unexpected token type: ', itoa(token.type), ' with value: ', token.value, ' at position ', itoa(parser.cursor)")
                return false
            }
        }
    }

    return true
}


/**
 * @function NAVCsvParserParseIdentifier
 * @private
 * @description Parse a CSV identifier (cell value).
 *
 * @param {_NAVCsvParser} parser - The parser instance
 * @param {char[][][]} data - The output 2D array to hold parsed CSV data
 *
 * @returns {char} True (1) if property was parsed successfully, False (0) on error
 */
define_function char NAVCsvParserParseIdentifier(_NAVCsvParser parser, char data[][][]) {
    stack_var char value[2048]
    stack_var _NAVCsvToken token

    // Start with the current token (already positioned by main loop)
    token = parser.tokens[parser.cursor]
    value = token.value

    #IF_DEFINED CSV_PARSER_DEBUG
    NAVLog("'[DEBUG] ParseIdentifier: starting with value=', value, ' at cursor=', itoa(parser.cursor)")
    #END_IF

    // Consume all following tokens until newline or comma
    while (NAVCsvParserHasMoreTokens(parser)) {
        if (!NAVCsvParserAdvanceCursor(parser)) {
            #IF_DEFINED CSV_PARSER_DEBUG
            NAVLog("'[DEBUG] ParseIdentifier: AdvanceCursor failed'")
            #END_IF
            return false
        }

        token = parser.tokens[parser.cursor]

        #IF_DEFINED CSV_PARSER_DEBUG
        NAVLog("'[DEBUG] ParseIdentifier: advanced to cursor=', itoa(parser.cursor), ' tokenType=', itoa(token.type), ' value=', token.value")
        #END_IF

        if (token.type == NAV_CSV_TOKEN_TYPE_NEWLINE ||
            token.type == NAV_CSV_TOKEN_TYPE_COMMA ||
            token.type == NAV_CSV_TOKEN_TYPE_EOF) {
            // Move cursor back one step so main loop can process delimiter/EOF
            parser.cursor--
            #IF_DEFINED CSV_PARSER_DEBUG
            NAVLog("'[DEBUG] ParseIdentifier: found delimiter/EOF, backing up to cursor=', itoa(parser.cursor)")
            #END_IF
            break
        }

        switch (token.type) {
            case NAV_CSV_TOKEN_TYPE_IDENTIFIER:
            case NAV_CSV_TOKEN_TYPE_WHITESPACE: {
                value = "value, token.value"
            }
            default: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_CSV_PARSER__,
                                            'NAVCsvParserParseIdentifier',
                                            "'Unexpected token type: ', itoa(token.type), ' with value: ', token.value, ' at position ', itoa(parser.cursor)")
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] ParseIdentifier: unexpected token type'")
                #END_IF
                return false
            }
        }
    }

    // parser.columnCount++
    // data[parser.rowCount][parser.columnCount] = value
    // set_length_array(data[parser.rowCount], parser.columnCount)
    NAVCsvParserAddField(parser, data, value)

    #IF_DEFINED CSV_PARSER_DEBUG
    NAVLog("'[DEBUG] ParseIdentifier: completed, columnCount=', itoa(parser.columnCount), ' value=', value")
    #END_IF

    return true
}


/**
 * @function NAVCsvParserParseQuotedIdentifier
 * @private
 * @description Parse a CSV quoted identifier (cell value).
 *
 * @param {_NAVCsvParser} parser - The parser instance
 * @param {char[][][]} data - The output 2D array to hold parsed CSV data
 *
 * @returns {char} True (1) if property was parsed successfully, False (0) on error
 */
define_function char NAVCsvParserParseQuotedIdentifier(_NAVCsvParser parser, char data[][][]) {
    stack_var char value[2048]
    stack_var _NAVCsvToken token

    // Start with the current token (should be a STRING token)
    token = parser.tokens[parser.cursor]

    if (token.type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSV_PARSER__,
                                    'NAVCsvParserParseQuotedIdentifier',
                                    "'Expected STRING token but got type: ', itoa(token.type), ' at position ', itoa(parser.cursor)")
        return false
    }

    value = token.value

    // Consume any following whitespace or check for delimiter
    while (NAVCsvParserHasMoreTokens(parser)) {
        if (!NAVCsvParserAdvanceCursor(parser)) {
            return false
        }

        token = parser.tokens[parser.cursor]

        if (token.type == NAV_CSV_TOKEN_TYPE_NEWLINE ||
            token.type == NAV_CSV_TOKEN_TYPE_COMMA ||
            token.type == NAV_CSV_TOKEN_TYPE_EOF) {
            // Move cursor back one step so main loop can process delimiter/EOF
            parser.cursor--
            break
        }

        switch (token.type) {
            case NAV_CSV_TOKEN_TYPE_WHITESPACE: {
                // Ignore whitespace after quoted identifier
                continue
            }
            default: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_CSV_PARSER__,
                                            'NAVCsvParserParseQuotedIdentifier',
                                            "'Unexpected token type: ', itoa(token.type), ' with value: ', token.value, ' at position ', itoa(parser.cursor)")
                return false
            }
        }
    }

    // parser.columnCount++
    // data[parser.rowCount][parser.columnCount] = value
    // set_length_array(data[parser.rowCount], parser.columnCount)
    NAVCsvParserAddField(parser, data, value)

    return true
}


#END_IF // __NAV_FOUNDATION_CSV_PARSER__
