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

#IF_NOT_DEFINED NAV_SNAPI_LEXER_MAX_TOKENS
constant integer NAV_SNAPI_LEXER_MAX_TOKENS           = 100
#END_IF

#IF_NOT_DEFINED NAV_SNAPI_LEXER_MAX_TOKEN_LENGTH
constant integer NAV_SNAPI_LEXER_MAX_TOKEN_LENGTH     = 255
#END_IF

#IF_NOT_DEFINED NAV_SNAPI_LEXER_MAX_SOURCE
constant long NAV_SNAPI_LEXER_MAX_SOURCE              = 1024
#END_IF

constant integer NAV_SNAPI_TOKEN_TYPE_COMMA           = 1     // ,
constant integer NAV_SNAPI_TOKEN_TYPE_DASH            = 2     // -
constant integer NAV_SNAPI_TOKEN_TYPE_QUESTIONMARK    = 3     // ?
constant integer NAV_SNAPI_TOKEN_TYPE_IDENTIFIER      = 4     // Alphanumeric strings
constant integer NAV_SNAPI_TOKEN_TYPE_STRING          = 5     // Quoted strings or unquoted values
constant integer NAV_SNAPI_TOKEN_TYPE_WHITESPACE      = 6     // Spaces or tabs
constant integer NAV_SNAPI_TOKEN_TYPE_EOF             = 7     // End of file/input


DEFINE_TYPE

struct _NAVSnapiToken {
    integer type
    char value[NAV_SNAPI_LEXER_MAX_TOKEN_LENGTH]
    integer start
    integer end
}


struct _NAVSnapiLexer {
    char source[NAV_SNAPI_LEXER_MAX_SOURCE]
    integer start
    integer cursor

    _NAVSnapiToken tokens[NAV_SNAPI_LEXER_MAX_TOKENS]
    integer tokenCount
}


#END_IF // __NAV_FOUNDATION_SNAPI_LEXER_H__
