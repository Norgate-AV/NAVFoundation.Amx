PROGRAM_NAME='NAVFoundation.SnapiParser'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SNAPI_PARSER__
#DEFINE __NAV_FOUNDATION_SNAPI_PARSER__ 'NAVFoundation.SnapiParser'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.SnapiLexer.axi'
#include 'NAVFoundation.SnapiParser.h.axi'
#include 'NAVFoundation.SnapiHelpers.h.axi'


/**
 * @function NAVSnapiParserInit
 * @private
 * @description Initialize a SNAPI parser with an array of tokens.
 *
 * @param {_NAVSnapiParser} parser - The parser structure to initialize
 * @param {_NAVSnapiToken[]} tokens - The array of tokens to parse
 *
 * @returns {void}
 */
define_function NAVSnapiParserInit(_NAVSnapiParser parser, _NAVSnapiToken tokens[]) {
    parser.cursor = 1
    parser.tokens = tokens
}


/**
 * @function NAVSnapiParserUnescapeString
 * @private
 * @description Unescape a SNAPI string token by removing quotes and converting escaped quotes.
 *
 * @param {char[]} value - The string token value to unescape (including surrounding quotes)
 *
 * @returns {char[NAV_SNAPI_PARSER_MAX_PARAM_LENGTH]} The unescaped string with quotes removed and "" converted to "
 */
define_function char[NAV_SNAPI_PARSER_MAX_PARAM_LENGTH] NAVSnapiParserUnescapeString(char value[]) {
    stack_var integer length

    length = length_array(value)

    // Handle empty string case: "" becomes empty
    if (length <= 2) {
        return ''
    }

    // Remove opening and closing quotes
    value = NAVStringSubstring(value, 2, length - 2)

    // Replace escaped quotes ("") with single quotes (")
    return NAVStringReplace(value, '""', '"')
}


/**
 * @function NAVSnapiParserHasMoreTokens
 * @private
 * @description Check if the parser has more tokens to process.
 *
 * @param {_NAVSnapiParser} parser - The parser to check
 *
 * @returns {char} True (1) if more tokens are available, False (0) if all tokens have been consumed
 */
define_function char NAVSnapiParserHasMoreTokens(_NAVSnapiParser parser) {
    return parser.cursor <= length_array(parser.tokens)
}


/**
 * @function NAVSnapiParserAdvance
 * @private
 * @description Advance the parser cursor to the next token.
 *
 * @param {_NAVSnapiParser} parser - The parser structure
 *
 * @returns {void}
 */
define_function NAVSnapiParserAdvance(_NAVSnapiParser parser) {
    parser.cursor++
}


/**
 * @function NAVSnapiParserCanPeek
 * @private
 * @description Check if the parser can peek at the next token without advancing.
 *
 * @param {_NAVSnapiParser} parser - The parser to check
 *
 * @returns {char} True (1) if peek is possible, False (0) if at or beyond last token
 */
define_function char NAVSnapiParserCanPeek(_NAVSnapiParser parser) {
    return parser.cursor < length_array(parser.tokens)
}


/**
 * @function NAVSnapiParserPeek
 * @private
 * @description Peek at the next token in the stream without consuming it.
 *
 * @param {_NAVSnapiParser} parser - The parser structure
 * @param {_NAVSnapiToken} token - Output parameter to receive the next token
 *
 * @returns {char} True (1) if peek succeeded and token was set, False (0) if unable to peek
 */
define_function char NAVSnapiParserPeek(_NAVSnapiParser parser, _NAVSnapiToken token) {
    if (!NAVSnapiParserCanPeek(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor + 1]

    return true
}


/**
 * @function NAVSnapiParserAddHeader
 * @private
 * @description Set the header/command name for a SNAPI message.
 *
 * @param {_NAVSnapiMessage} message - The message structure to update
 * @param {char[]} header - The header/command string to set
 *
 * @returns {char} Always returns True (1)
 */
define_function char NAVSnapiParserAddHeader(_NAVSnapiMessage message, char header[]) {
    message.Header = header
    return true
}


/**
 * @function NAVSnapiParserAddParameter
 * @private
 * @description Add a parameter to a SNAPI message.
 *
 * @param {_NAVSnapiMessage} message - The message structure to update
 * @param {char[]} parameter - The parameter value to add
 *
 * @returns {char} Always returns True (1)
 */
define_function char NAVSnapiParserAddParameter(_NAVSnapiMessage message, char parameter[]) {
    message.ParameterCount++
    message.Parameter[message.ParameterCount] = parameter
    set_length_array(message.Parameter, message.ParameterCount)
    return true
}


/**
 * @function NAVSnapiParserParse
 * @public
 * @description Parse a SNAPI command string into a structured message with header and parameters.
 *
 * @param {char[]} input - The raw SNAPI command string to parse
 * @param {_NAVSnapiMessage} message - Output parameter to receive the parsed message structure
 *
 * @returns {char} True (1) if parsing succeeded, False (0) if tokenization or parsing failed
 *
 * @example
 * // Parse a simple command
 * stack_var _NAVSnapiMessage msg
 * NAVSnapiParserParse('POWER-ON', msg)
 * // msg.Header = 'POWER'
 * // msg.Parameter[1] = 'ON'
 *
 * @example
 * // Parse a query command
 * stack_var _NAVSnapiMessage msg
 * NAVSnapiParserParse('?POWER', msg)
 * // msg.Header = '?POWER'
 *
 * @example
 * // Parse a command with string parameter
 * stack_var _NAVSnapiMessage msg
 * NAVSnapiParserParse('TEXT-"Hello World"', msg)
 * // msg.Header = 'TEXT'
 * // msg.Parameter[1] = 'Hello World'
 */
define_function char NAVSnapiParserParse(char input[], _NAVSnapiMessage message) {
    stack_var _NAVSnapiLexer lexer
    stack_var _NAVSnapiParser parser
    stack_var char parsingHeader
    stack_var char currentValue[NAV_SNAPI_PARSER_MAX_PARAM_LENGTH]
    stack_var char hasValue

    // Tokenize the input
    if (!NAVSnapiLexerTokenize(lexer, input)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_SNAPI_PARSER__,
                                    'NAVSnapiParserParse',
                                    "'Failed to tokenize input'")
        return false
    }

    // Initialize parser
    NAVSnapiParserInit(parser, lexer.tokens)

    // Accumulator for building header and parameter values from tokens
    currentValue = ''
    hasValue = false

    // Always start by parsing the header
    parsingHeader = true

    while (NAVSnapiParserHasMoreTokens(parser)) {
        stack_var _NAVSnapiToken token

        token = parser.tokens[parser.cursor]

        #IF_DEFINED SNAPI_PARSER_DEBUG
        NAVLog("'[ ParserParse ] cursor=', itoa(parser.cursor), ' tokenType=', itoa(token.type), ' value=', token.value, ' parsingHeader=', itoa(parsingHeader)")
        #END_IF

        switch (token.type) {
            case NAV_SNAPI_TOKEN_TYPE_DASH: {
                // This terminates the header
                // Although commands can be header only so we may never see this
                if (parsingHeader) {
                    NAVSnapiParserAddHeader(message, NAVTrimString(currentValue))
                    currentValue = ''
                    parsingHeader = false
                    hasValue = false
                } else {
                    currentValue = "currentValue, token.value"
                    hasValue = true
                }

                NAVSnapiParserAdvance(parser)
            }
            case NAV_SNAPI_TOKEN_TYPE_COMMA: {
                // This terminates the current parameter
                if (parsingHeader) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_SNAPI_PARSER__,
                                                'NAVSnapiParserParse',
                                                "'Unexpected comma token in header at position ', itoa(token.start)")
                    return false
                }


                NAVSnapiParserAddParameter(message, currentValue)

                currentValue = ''
                hasValue = false

                NAVSnapiParserAdvance(parser)
            }
            case NAV_SNAPI_TOKEN_TYPE_STRING: {
                // Only valid in args
                stack_var char value[NAV_SNAPI_PARSER_MAX_PARAM_LENGTH]

                value = NAVSnapiParserUnescapeString(token.value)

                if (parsingHeader) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_SNAPI_PARSER__,
                                                'NAVSnapiParserParse',
                                                "'Unexpected string token in header: "', value, '" at position ', itoa(token.start)")
                    return false
                }

                currentValue = "currentValue, value"
                hasValue = true
                NAVSnapiParserAdvance(parser)
            }

            case NAV_SNAPI_TOKEN_TYPE_QUESTIONMARK:
            case NAV_SNAPI_TOKEN_TYPE_IDENTIFIER:
            case NAV_SNAPI_TOKEN_TYPE_WHITESPACE: {
                currentValue = "currentValue, token.value"
                hasValue = true
                NAVSnapiParserAdvance(parser)
            }

            case NAV_SNAPI_TOKEN_TYPE_EOF: {
                // End of stream
                if (parsingHeader) {
                    NAVSnapiParserAddHeader(message, NAVTrimString(currentValue))
                }
                else {
                    if (hasValue ||
                        parser.tokens[parser.cursor - 1].type == NAV_SNAPI_TOKEN_TYPE_COMMA) {
                        NAVSnapiParserAddParameter(message, currentValue)
                    }
                }

                // Must still advance to exit loop
                NAVSnapiParserAdvance(parser)
            }

            default: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_SNAPI_PARSER__,
                                            'NAVSnapiParserParse',
                                            "'Unexpected token: "', token.value, '" at position ', itoa(token.start)")
                return false
            }
        }
    }

    return true
}


#END_IF // __NAV_FOUNDATION_SNAPI_PARSER__
