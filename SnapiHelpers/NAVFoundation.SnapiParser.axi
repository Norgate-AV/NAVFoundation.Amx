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


define_function NAVSnapiParserInit(_NAVSnapiParser parser, _NAVSnapiToken tokens[]) {
    parser.cursor = 1
    parser.tokens = tokens
}


define_function char[NAV_SNAPI_LEXER_MAX_TOKEN_LENGTH] NAVSnapiParserUnescapeString(char value[]) {
    // Remove opening and closing quotes
    value = NAVStringSubstring(value, 2, length_array(value) - 2)

    // Replace escaped quotes ("") with single quotes (")
    // Might replace this with a manual for loop if problematic
    return NAVStringReplace(value, '""', '"')
}


define_function char NAVSnapiParserHasMoreTokens(_NAVSnapiParser parser) {
    return parser.cursor <= length_array(parser.tokens)
}


define_function NAVSnapiParserAdvance(_NAVSnapiParser parser) {
    parser.cursor++
}


define_function char NAVSnapiParserCanPeek(_NAVSnapiParser parser) {
    return parser.cursor < length_array(parser.tokens)
}


define_function char NAVSnapiParserPeek(_NAVSnapiParser parser, _NAVSnapiToken token) {
    if (!NAVSnapiParserCanPeek(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor + 1]

    return true
}


define_function char NAVSnapiParserAddHeader(_NAVSnapiMessage message, char header[]) {
    message.Header = header
    return true
}


define_function char NAVSnapiParserAddParameter(_NAVSnapiMessage message, char parameter[]) {
    message.ParameterCount++
    message.Parameter[message.ParameterCount] = parameter
    set_length_array(message.Parameter, message.ParameterCount)
    return true
}


define_function char NAVSnapiParserParse(char input[], _NAVSnapiMessage message) {
    stack_var _NAVSnapiLexer lexer
    stack_var _NAVSnapiParser parser
    stack_var char parsingHeader
    stack_var char currentValue[NAV_SNAPI_LEXER_MAX_TOKEN_LENGTH]

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

    // Accumulator
    currentValue = ''

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
                if (!parsingHeader) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_SNAPI_PARSER__,
                                                'NAVSnapiParserParse',
                                                "'Unexpected dash token in parameter at position ', itoa(token.start)")
                    return false
                }

                NAVSnapiParserAddHeader(message, NAVTrimString(currentValue))
                currentValue = ''
                parsingHeader = false

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

                NAVSnapiParserAdvance(parser)
            }
            case NAV_SNAPI_TOKEN_TYPE_QUESTIONMARK: {
                // The start of a query header
                // The next token MUST be an identifier, if not it's invalid
                stack_var _NAVSnapiToken next

                if (!NAVSnapiParserPeek(parser, next)) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                        __NAV_FOUNDATION_SNAPI_PARSER__,
                        'NAVSnapiParserParse',
                        "'Unexpected end of input after ? at position ', itoa(token.start)")
                        return false
                    }

                if (next.type != NAV_SNAPI_TOKEN_TYPE_IDENTIFIER) {
                    stack_var char value[NAV_SNAPI_LEXER_MAX_TOKEN_LENGTH]

                    switch (next.type) {
                        case NAV_SNAPI_TOKEN_TYPE_STRING: {
                            value = "'"', next.value, '"'"
                        }
                        case NAV_SNAPI_TOKEN_TYPE_EOF: {
                            value = 'EOF'
                        }
                        default: {
                            value = next.value
                        }
                    }

                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_SNAPI_PARSER__,
                                                'NAVSnapiParserParse',
                                                "'Unexpected token after ?: ', value, ' at position ', itoa(next.start)")
                    return false
                }

                currentValue = "currentValue, token.value"
                NAVSnapiParserAdvance(parser)
            }
            case NAV_SNAPI_TOKEN_TYPE_STRING: {
                // Only valid in args
                stack_var char value[NAV_SNAPI_LEXER_MAX_TOKEN_LENGTH]

                value = NAVSnapiParserUnescapeString(token.value)

                if (parsingHeader) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_SNAPI_PARSER__,
                                                'NAVSnapiParserParse',
                                                "'Unexpected string token in header: "', value, '" at position ', itoa(token.start)")
                    return false
                }

                currentValue = "currentValue, value"
                NAVSnapiParserAdvance(parser)
            }

            case NAV_SNAPI_TOKEN_TYPE_IDENTIFIER:
            case NAV_SNAPI_TOKEN_TYPE_WHITESPACE: {
                currentValue = "currentValue, token.value"
                NAVSnapiParserAdvance(parser)
            }

            case NAV_SNAPI_TOKEN_TYPE_EOF: {
                // End of stream
                if (parsingHeader) {
                    NAVSnapiParserAddHeader(message, NAVTrimString(currentValue))
                }
                else {
                    if (length_array(currentValue) ||
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
