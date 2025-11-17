PROGRAM_NAME='NAVFoundation.SnapiLexer.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_SNAPI_LEXER_H__
#DEFINE __NAV_FOUNDATION_SNAPI_LEXER_H__ 'NAVFoundation.SnapiLexer.h'


DEFINE_CONSTANT

/**
 * Maximum number of tokens that can be produced by the lexer.
 * Increase this value if parsing commands with many parameters.
 * @default 100
 */
#IF_NOT_DEFINED NAV_SNAPI_LEXER_MAX_TOKENS
constant integer NAV_SNAPI_LEXER_MAX_TOKENS           = 100
#END_IF

/**
 * Maximum length of a single token value (in characters).
 * This limits the size of headers, parameters, and quoted strings.
 * @default 255
 */
#IF_NOT_DEFINED NAV_SNAPI_LEXER_MAX_TOKEN_LENGTH
constant integer NAV_SNAPI_LEXER_MAX_TOKEN_LENGTH     = 255
#END_IF

/**
 * Maximum length of the source input string to tokenize (in characters).
 * @default 1024
 */
#IF_NOT_DEFINED NAV_SNAPI_LEXER_MAX_SOURCE
constant long NAV_SNAPI_LEXER_MAX_SOURCE              = 1024
#END_IF

/**
 * Token type: Comma separator between parameters.
 * Character: `,`
 */
constant integer NAV_SNAPI_TOKEN_TYPE_COMMA           = 1

/**
 * Token type: Dash separator between header and parameters.
 * Character: `-`
 * Note: First `-` in command is separator; subsequent `-` are content.
 */
constant integer NAV_SNAPI_TOKEN_TYPE_DASH            = 2

/**
 * Token type: Question mark for query commands.
 * Character: `?`
 * Note: Only special at command start; otherwise treated as content.
 */
constant integer NAV_SNAPI_TOKEN_TYPE_QUESTIONMARK    = 3

/**
 * Token type: Identifier token (unquoted alphanumeric sequences).
 * Includes letters, digits, and special characters except `,` and `-`.
 */
constant integer NAV_SNAPI_TOKEN_TYPE_IDENTIFIER      = 4

/**
 * Token type: Quoted string parameter.
 * Enclosed in double-quotes with `""` escaping for internal quotes.
 */
constant integer NAV_SNAPI_TOKEN_TYPE_STRING          = 5

/**
 * Token type: Whitespace (spaces or tabs).
 * Preserved in parameters to maintain exact spacing.
 */
constant integer NAV_SNAPI_TOKEN_TYPE_WHITESPACE      = 6

/**
 * Token type: End of input marker.
 * Signals completion of tokenization.
 */
constant integer NAV_SNAPI_TOKEN_TYPE_EOF             = 7


DEFINE_TYPE

/**
 * @struct _NAVSnapiToken
 * @description Represents a single lexical token produced by the SNAPI lexer.
 *              Tokens are the atomic units of a SNAPI command, such as separators,
 *              identifiers, strings, or whitespace.
 *
 * @property {integer} type - Token type identifier (NAV_SNAPI_TOKEN_TYPE_)
 * @property {char[]} value - The actual text content of the token
 * @property {integer} start - Starting position in source string (1-based index)
 * @property {integer} end - Ending position in source string (1-based index, inclusive)
 */
struct _NAVSnapiToken {
    integer type
    char value[NAV_SNAPI_LEXER_MAX_TOKEN_LENGTH]
    integer start
    integer end
}


/**
 * @struct _NAVSnapiLexer
 * @description Lexer state machine for tokenizing SNAPI command strings.
 *              Maintains the source input, current position, and accumulated tokens.
 *
 * @property {char[]} source - The input string being tokenized
 * @property {integer} start - Starting position of current token being processed
 * @property {integer} cursor - Current read position in source string
 * @property {_NAVSnapiToken[]} tokens - Array of tokens produced during tokenization
 * @property {integer} tokenCount - Number of tokens currently in the tokens array
 */
struct _NAVSnapiLexer {
    char source[NAV_SNAPI_LEXER_MAX_SOURCE]
    integer start
    integer cursor

    _NAVSnapiToken tokens[NAV_SNAPI_LEXER_MAX_TOKENS]
    integer tokenCount
}


#END_IF // __NAV_FOUNDATION_SNAPI_LEXER_H__
