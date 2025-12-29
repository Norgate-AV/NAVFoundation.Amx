PROGRAM_NAME='NAVFoundation.CsvUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_CSVUTILS__
#DEFINE __NAV_FOUNDATION_CSVUTILS__ 'NAVFoundation.CsvUtils'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.CsvLexer.axi'
#include 'NAVFoundation.CsvParser.axi'


(***********************************************************)
(*                    UTILITY FUNCTIONS                   *)
(***********************************************************)

/**
 * @function NAVCsvParse
 * @public
 * @description Simple high-level function to parse CSV from string data.
 *
 * @param {char[]} data - The CSV data as a string
 * @param {char[][][]} csv - The output 2D array to hold parsed CSV data
 *
 * @returns {char} True (1) if parsing succeeded, False (0) if failed
 *
 * @example
 * stack_var char data[2048]
 * stack_var char csv[100][100][255]  // Adjust size as needed
 *
 * data = ReadFile('data.csv')  // However you read the file
 * if (NAVCsvParse(data, csv)) {
 *     csv[1][1]  // Access first row, first column
 *     csv[2][3]  // Access second row, third column
 * }
 */
define_function char NAVCsvParse(char data[], char csv[][][]) {
    stack_var _NAVCsvLexer lexer
    stack_var _NAVCsvParser parser

    if (!length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSVUTILS__,
                                    'NAVCsvParse',
                                    "'Input data is empty'")
        return false
    }

    // Initialize the lexer with the input data
    NAVCsvLexerInit(lexer, data)

    // Tokenize the input
    if (!NAVCsvLexerTokenize(lexer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSVUTILS__,
                                    'NAVCsvParse',
                                    "'Error tokenizing CSV data'")
        return false
    }

    // Initialize the parser with the tokens
    NAVCsvParserInit(parser, lexer.tokens)

    // Parse the tokens
    if (!NAVCsvParserParse(parser, csv)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSVUTILS__,
                                    'NAVCsvParse',
                                    "'Error parsing CSV data'")
        return false
    }

    return true
}


/**
 * @function NAVCsvSerialize
 * @public
 * @description Serializes a 2D array of strings into CSV format.
 *
 * @param {char[][][]} data - The 2D array of strings to serialize
 * @param {char[]} result - The output string to hold the serialized CSV data
 *
 * @returns {char} True (1) if serialization succeeded, False (0) if failed
 *
 * @example
 * stack_var char data[3][3][255]
 * stack_var char result[2048]
 *
 * data[1][1] = 'Name'
 * data[1][2] = 'Age'
 * data[1][3] = 'City'
 * data[2][1] = 'Alice'
 * data[2][2] = '30'
 * data[2][3] = 'New York'
 * data[3][1] = 'Bob'
 * data[3][2] = '25'
 * data[3][3] = 'Los Angeles'
 *
 * if (NAVCsvSerialize(data, result)) {
 *     WriteFile('output.csv', result)  // However you write the file
 * }
 */
define_function char NAVCsvSerialize(char data[][][], char result[]) {
    stack_var integer i

    if (!length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_CSVUTILS__,
                                    'NAVCsvSerialize',
                                    "'Input data is empty'")
        return false
    }

    result = ''

    for (i = 1; i <= length_array(data); i++) {
        stack_var integer j
        stack_var char line[NAV_MAX_BUFFER]

        if (!length_array(data[i])) {
            // Empty row - output blank line with CRLF
            result = "result, NAV_CR, NAV_LF"
            continue
        }

        line = ''

        for (j = 1; j <= length_array(data[i]); j++) {
            stack_var char field[NAV_MAX_BUFFER]

            if (j > 1) {
                line = "line, ','"
            }

            field = "data[i][j]"

            // RFC 4180: Quote field if it contains comma, quote, CR, or LF
            if (NAVContains(field, ',') ||
                NAVContains(field, '"') ||
                NAVContains(field, "NAV_CR") ||
                NAVContains(field, "NAV_LF")) {

                // Escape internal quotes by doubling them (RFC 4180)
                field = NAVFindAndReplace(field, '"', '""')

                // Wrap field in quotes
                line = "line, '"', field, '"'"
            }
            else {
                // No quoting needed
                line = "line, field"
            }
        }

        // Add line to result with CRLF (RFC 4180 standard)
        result = "result, line, NAV_CR, NAV_LF"
    }

    return true
}


#END_IF // __NAV_FOUNDATION_CSVUTILS__
