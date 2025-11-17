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

/**
 * Maximum length of a SNAPI command header.
 * Headers are the command names (e.g., "POWER", "INPUT", "?VERSION").
 * @default 100
 */
#IF_NOT_DEFINED NAV_SNAPI_PARSER_MAX_HEADER_LENGTH
constant integer NAV_SNAPI_PARSER_MAX_HEADER_LENGTH   = 100
#END_IF

/**
 * Maximum length of a single SNAPI parameter value.
 * Parameters are accumulated during parsing from multiple tokens.
 * @default 255
 */
#IF_NOT_DEFINED NAV_SNAPI_PARSER_MAX_PARAM_LENGTH
constant integer NAV_SNAPI_PARSER_MAX_PARAM_LENGTH    = 255
#END_IF

DEFINE_TYPE

/**
 * @struct _NAVSnapiParser
 * @private
 * @description Internal parser state for processing SNAPI token streams
 *
 * @property {integer} cursor - Current position in the token array (1-based index)
 * @property {_NAVSnapiToken[]} tokens - Array of tokens to parse (up to NAV_SNAPI_LEXER_MAX_TOKENS)
 *
 * @note This structure is for internal use by the parser implementation
 * @see NAVSnapiParserParse
 */
struct _NAVSnapiParser {
    integer cursor
    _NAVSnapiToken tokens[NAV_SNAPI_LEXER_MAX_TOKENS]
}


#END_IF // __NAV_FOUNDATION_SNAPI_PARSER_H__
