PROGRAM_NAME='NAVFoundation.SnapiParser.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SNAPI_PARSER_H__
#DEFINE __NAV_FOUNDATION_SNAPI_PARSER_H__ 'NAVFoundation.SnapiParser.h'

#include 'NAVFoundation.SnapiLexer.h.axi'

DEFINE_CONSTANT

DEFINE_TYPE

struct _NAVSnapiParser {
    integer cursor
    _NAVSnapiToken tokens[NAV_SNAPI_LEXER_MAX_TOKENS]
}

/**
 * @struct _NAVSnapiMessage
 * @description Represents a parsed SNAPI protocol message with header and parameters
 *
 * @property {char[NAV_MAX_BUFFER]} Header - Command name or message type
 * @property {char[][]} Parameter - Array of message parameters (up to NAV_MAX_SNAPI_MESSAGE_PARAMETERS)
 * @property {integer} ParameterCount - Number of parameters in the message
 *
 * @note Use NAVParseSnapiMessage to populate this structure from a raw SNAPI message
 * @see NAVParseSnapiMessage
 */
// struct _NAVSnapiMessage {
//     char Header[NAV_MAX_BUFFER]
//     char Parameter[NAV_MAX_SNAPI_MESSAGE_PARAMETERS][255]
//     integer ParameterCount
// }


#END_IF // __NAV_FOUNDATION_SNAPI_PARSER_H__
