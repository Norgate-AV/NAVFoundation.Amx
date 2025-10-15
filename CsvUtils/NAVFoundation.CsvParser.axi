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

    parser.rowCount = 0
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
 * @function NAVCsvParserAddField
 * @private
 * @description Add a field with the given value to the current row.
 *              Creates a new row if this is the first field (lazy row initialization).
 *
 * @param {_NAVCsvParser} parser - The parser instance
 * @param {char[][][]} data - The output 2D array
 * @param {char[]} value - The value to add as a field
 *
 * @returns {char} True (1) if field was added successfully, False (0) if column limit exceeded
 */
define_function char NAVCsvParserAddField(_NAVCsvParser parser, char data[][][], char value[]) {
    // Lazy row initialization: if no row exists yet, create one
    if (parser.rowCount == 0) {
        if (!NAVCsvParserAddRecord(parser, data)) {
            return false
        }
    }

    // Check column limit
    if (parser.columnCount >= NAV_CSV_MAX_COLUMNS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_CSV_PARSER__,
                                            'NAVCsvParserAddField',
                                            "'Maximum column count exceeded: ', itoa(NAV_CSV_MAX_COLUMNS)")
        return false
    }

    parser.columnCount++
    data[parser.rowCount][parser.columnCount] = value
    set_length_array(data[parser.rowCount], parser.columnCount)

    return true
}


/**
 * @function NAVCsvParserAddRecord
 * @private
 * @description Add a new record to the data array.
 *
 * @param {_NAVCsvParser} parser - The parser instance
 * @param {char[][][]} data - The output 2D array
 *
 * @returns {char} True (1) if record was added successfully, False (0) on error
 */
define_function char NAVCsvParserAddRecord(_NAVCsvParser parser, char data[][][]) {
    if (parser.rowCount >= NAV_CSV_MAX_ROWS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_CSV_PARSER__,
                                            'NAVCsvParserAddRecord',
                                            "'Maximum record count exceeded: ', itoa(NAV_CSV_MAX_ROWS)")
        return false
    }

    parser.rowCount++
    parser.columnCount = 0
    set_length_array(data, parser.rowCount)

    return true
}


/**
 * @function NAVCsvParserPeekTokenType
 * @private
 * @description Peek at the type of a token at a given offset from the current cursor without advancing the cursor.
 *
 * @param {_NAVCsvParser} parser - The parser instance
 * @param {integer} offset - The offset from the current cursor to peek at
 *
 * @returns {integer} The type of the token at the specified offset, or 0 if out of bounds
 */
define_function integer NAVCsvParserPeekTokenType(_NAVCsvParser parser, integer offset) {
    if (parser.cursor + offset > parser.tokenCount) {
        return 0
    }

    return parser.tokens[parser.cursor + offset].type
}


/**
 * @function NAVCsvParserPeekNextTokenType
 * @private
 * @description Peek at the type of the next token without advancing the cursor.
 *
 * @param {_NAVCsvParser} parser - The parser instance
 *
 * @returns {integer} The type of the next token, or 0 if at end of tokens
 */
define_function integer NAVCsvParserPeekNextTokenType(_NAVCsvParser parser) {
    return NAVCsvParserPeekTokenType(parser, 1)
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
define_function char NAVCsvParserParse(_NAVCsvParser parser, char data[][][NAV_CSV_MAX_FIELD_LENGTH]) {
    stack_var char value[NAV_CSV_MAX_FIELD_LENGTH]
    stack_var char inField // Track whether we're actively parsing a field (vs whitespace-only input)

    value = '' // Initialize value to empty string
    inField = false // Not in a field yet

    while (NAVCsvParserHasMoreTokens(parser)) {
        stack_var _NAVCsvToken token

        if (!NAVCsvParserAdvanceCursor(parser)) {
            return false
        }

        token = parser.tokens[parser.cursor]

        #IF_DEFINED CSV_PARSER_DEBUG
        NAVLog("'[DEBUG] cursor=', itoa(parser.cursor), ' tokenType=', itoa(token.type), ' value=', token.value, ' rowCount=', itoa(parser.rowCount), ' columnCount=', itoa(parser.columnCount), ' inField=', itoa(inField)")
        #END_IF

        switch (token.type) {
            case NAV_CSV_TOKEN_TYPE_IDENTIFIER: {
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] Processing IDENTIFIER'")
                #END_IF

                inField = true // We're now in a field

                if (!NAVCsvParserParseField(parser, value)) {
                    return false
                }
            }
            case NAV_CSV_TOKEN_TYPE_STRING: {
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] Processing STRING'")
                #END_IF

                inField = true // We're now in a field (even if empty string)

                if (!NAVCsvParserParseQuotedField(parser, value)) {
                    return false
                }
            }
            case NAV_CSV_TOKEN_TYPE_COMMA: {
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] Processing COMMA - committing field value: ', value")
                #END_IF

                // Comma marks end of current field - commit whatever we've accumulated
                // COMMA always commits a field (even empty ones from consecutive commas like ",,")
                // After committing, we're immediately "in" the next field because comma is a separator
                if (!NAVCsvParserAddField(parser, data, value)) {
                    return false
                }

                value = '' // Reset accumulator for next field
                inField = true // After comma, we're immediately in the next field (even if it will be empty)
            }
            case NAV_CSV_TOKEN_TYPE_WHITESPACE: {
                // Check what comes next to decide how to handle whitespace
                switch (NAVCsvParserPeekNextTokenType(parser)) {
                    case NAV_CSV_TOKEN_TYPE_STRING: {
                        // Ignore whitespace before quoted string
                        #IF_DEFINED CSV_PARSER_DEBUG
                        NAVLog("'[DEBUG] Ignoring whitespace before quoted string'")
                        #END_IF

                        continue
                    }
                    case NAV_CSV_TOKEN_TYPE_EOF:
                    case NAV_CSV_TOKEN_TYPE_NEWLINE: {
                        // Only ignore truly trailing whitespace (when field is still empty AND we have data)
                        // If accumulator has content or we have fields/rows, preserve the whitespace
                        if (value == '' && (parser.rowCount == 0 || parser.columnCount == 0)) {
                            #IF_DEFINED CSV_PARSER_DEBUG
                            NAVLog("'[DEBUG] Ignoring trailing whitespace (truly trailing)'")
                            #END_IF

                            continue
                        }
                        else {
                            // This whitespace is part of field content
                            #IF_DEFINED CSV_PARSER_DEBUG
                            NAVLog("'[DEBUG] Preserving whitespace in field'")
                            #END_IF

                            value = "value, token.value"
                        }
                    }
                    default: {
                        // Whitespace is part of field content - accumulate it
                        value = "value, token.value"
                    }
                }
            }
            case NAV_CSV_TOKEN_TYPE_NEWLINE: {
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] Processing NEWLINE - committing final field of row'")
                #END_IF

                // Only commit a field if we're actively in a field OR already have fields in this row
                // This allows empty rows (a\n\nb) while preventing whitespace-only from creating rows
                if (inField || parser.columnCount > 0) {
                    if (!NAVCsvParserAddField(parser, data, value)) {
                        return false
                    }
                }

                value = ''
                inField = false // Reset for next row

                // Only add a new row if there's more data (not EOF next)
                if (NAVCsvParserPeekNextTokenType(parser) != NAV_CSV_TOKEN_TYPE_EOF) {
                    if (!NAVCsvParserAddRecord(parser, data)) {
                        return false
                    }
                }
            }
            case NAV_CSV_TOKEN_TYPE_EOF: {
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] Processing EOF - committing final field if in field'")
                #END_IF

                // Only commit a field if we're actively parsing one
                if (inField || parser.columnCount > 0 || parser.rowCount > 0) {
                    if (!NAVCsvParserAddField(parser, data, value)) {
                        return false
                    }
                }

                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] Reached EOF token - parsing complete'")
                #END_IF

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
 * @function NAVCsvParserParseField
 * @private
 * @description Parse a CSV identifier (cell value) and accumulate into value.
 *
 * @param {_NAVCsvParser} parser - The parser instance
 * @param {char[]} value - The accumulator to build the field value into (passed by reference)
 *
 * @returns {char} True (1) if property was parsed successfully, False (0) on error
 */
define_function char NAVCsvParserParseField(_NAVCsvParser parser, char value[]) {
    stack_var _NAVCsvToken token
    stack_var integer next

    // Start with the current token (already positioned by main loop)
    token = parser.tokens[parser.cursor]
    value = "value, token.value"

    #IF_DEFINED CSV_PARSER_DEBUG
    NAVLog("'[DEBUG] ParseField: starting with value=', value, ' at cursor=', itoa(parser.cursor)")
    #END_IF

    // Consume all following tokens until delimiter
    while (NAVCsvParserHasMoreTokens(parser)) {
        // Peek at next token to see if we should continue
        next = NAVCsvParserPeekNextTokenType(parser)

        if (next == NAV_CSV_TOKEN_TYPE_NEWLINE ||
            next == NAV_CSV_TOKEN_TYPE_COMMA ||
            next == NAV_CSV_TOKEN_TYPE_EOF) {
            // Next token is a delimiter - stop here
            #IF_DEFINED CSV_PARSER_DEBUG
            NAVLog("'[DEBUG] ParseField: found delimiter ahead, stopping at cursor=', itoa(parser.cursor)")
            #END_IF

            break
        }

        if (!NAVCsvParserAdvanceCursor(parser)) {
            #IF_DEFINED CSV_PARSER_DEBUG
            NAVLog("'[DEBUG] ParseField: AdvanceCursor failed'")
            #END_IF

            return false
        }

        token = parser.tokens[parser.cursor]

        #IF_DEFINED CSV_PARSER_DEBUG
        NAVLog("'[DEBUG] ParseField: advanced to cursor=', itoa(parser.cursor), ' tokenType=', itoa(token.type), ' value=', token.value")
        #END_IF

        switch (token.type) {
            case NAV_CSV_TOKEN_TYPE_IDENTIFIER:
            case NAV_CSV_TOKEN_TYPE_WHITESPACE: {
                value = "value, token.value"
            }
            default: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_CSV_PARSER__,
                                            'NAVCsvParserParseField',
                                            "'Unexpected token type: ', itoa(token.type), ' with value: ', token.value, ' at position ', itoa(parser.cursor)")
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] ParseField: unexpected token type'")
                #END_IF

                return false
            }
        }
    }

    #IF_DEFINED CSV_PARSER_DEBUG
    NAVLog("'[DEBUG] ParseField: completed, accumulated value=', value")
    #END_IF

    return true
}


/**
 * @function NAVCsvParserParseQuotedField
 * @private
 * @description Parse a CSV quoted identifier (cell value) and accumulate into value.
 *
 * @param {_NAVCsvParser} parser - The parser instance
 * @param {char[]} value - The accumulator to build the field value into (passed by reference)
 *
 * @returns {char} True (1) if property was parsed successfully, False (0) on error
 */
define_function char NAVCsvParserParseQuotedField(_NAVCsvParser parser, char value[]) {
    stack_var _NAVCsvToken token
    stack_var integer next

    // Start with the current token (should be a STRING token)
    token = parser.tokens[parser.cursor]

    if (token.type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSV_PARSER__,
                                    'NAVCsvParserParseQuotedField',
                                    "'Expected STRING token but got type: ', itoa(token.type), ' at position ', itoa(parser.cursor)")
        return false
    }

    value = "value, token.value"

    #IF_DEFINED CSV_PARSER_DEBUG
    NAVLog("'[DEBUG] ParseQuotedField: quoted value=', value, ' at cursor=', itoa(parser.cursor)")
    #END_IF

    // Consume any following whitespace or check for delimiter
    while (NAVCsvParserHasMoreTokens(parser)) {
        // Peek at next token to see if we should continue
        next = NAVCsvParserPeekNextTokenType(parser)

        if (next == NAV_CSV_TOKEN_TYPE_NEWLINE ||
            next == NAV_CSV_TOKEN_TYPE_COMMA ||
            next == NAV_CSV_TOKEN_TYPE_EOF) {
            // Next token is a delimiter - stop here
            #IF_DEFINED CSV_PARSER_DEBUG
            NAVLog("'[DEBUG] ParseQuotedField: found delimiter ahead, stopping'")
            #END_IF

            break
        }

        if (!NAVCsvParserAdvanceCursor(parser)) {
            return false
        }

        token = parser.tokens[parser.cursor]

        switch (token.type) {
            case NAV_CSV_TOKEN_TYPE_WHITESPACE: {
                // Ignore whitespace after quoted identifier
                #IF_DEFINED CSV_PARSER_DEBUG
                NAVLog("'[DEBUG] ParseQuotedField: ignoring trailing whitespace'")
                #END_IF

                continue
            }
            default: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_CSV_PARSER__,
                                            'NAVCsvParserParseQuotedField',
                                            "'Unexpected token type: ', itoa(token.type), ' with value: ', token.value, ' at position ', itoa(parser.cursor)")
                return false
            }
        }
    }

    #IF_DEFINED CSV_PARSER_DEBUG
    NAVLog("'[DEBUG] ParseQuotedField: completed, accumulated value=', value")
    #END_IF

    return true
}


#END_IF // __NAV_FOUNDATION_CSV_PARSER__
