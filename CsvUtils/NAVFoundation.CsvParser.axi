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
 * @function NAVCsvParserParse
 * @public
 * @description Parse the tokens into an INI file structure.
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

        switch (token.type) {
            case NAV_CSV_TOKEN_TYPE_IDENTIFIER: {
                if (!NAVCsvParserParseIdentifier(parser, data)) {
                    return false
                }
            }
            case NAV_CSV_TOKEN_TYPE_STRING: {
                if (!NAVCsvParserParseQuoatedIdentifier(parser, data)) {
                    return false
                }
            }
            case NAV_CSV_TOKEN_TYPE_NEWLINE: {
                // If we encounter a newline token then we increment the row count
                parser.rowCount++
                parser.columnCount = 0
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

    // Consume all tokens until newline
    while (NAVCsvParserHasMoreTokens(parser)) {
        stack_var _NAVCsvToken token

        if (!NAVCsvParserAdvanceCursor(parser)) {
            return false
        }

        token = parser.tokens[parser.cursor]

        if (token.type == NAV_CSV_TOKEN_TYPE_NEWLINE) {
            break
        }

        if (token.type == NAV_CSV_TOKEN_TYPE_IDENTIFIER) {
            if (length_array(value) > 0) {
                value = "value, ' ', token.value"  // Add space between tokens
                continue
            }

            value = token.value
        }
    }

    parser.columnCount++
    data[parser.rowCount][parser.columnCount] = value
    set_length_array(data[parser.rowCount], parser.columnCount)

    return true
}


/**
 * @function NAVCsvParserParseQuoatedIdentifier
 * @private
 * @description Parse a CSV quoted identifier (cell value).
 *
 * @param {_NAVCsvParser} parser - The parser instance
 * @param {char[][][]} data - The output 2D array to hold parsed CSV data
 *
 * @returns {char} True (1) if property was parsed successfully, False (0) on error
 */
define_function char NAVCsvParserParseQuoatedIdentifier(_NAVCsvParser parser, char data[][][]) {
    stack_var _NAVCsvToken token

    if (!NAVCsvParserAdvanceCursor(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor]

    parser.columnCount++
    data[parser.rowCount][parser.columnCount] = token.value
    set_length_array(data[parser.rowCount], parser.columnCount)
}


#END_IF // __NAV_FOUNDATION_CSV_PARSER__
