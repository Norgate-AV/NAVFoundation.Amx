PROGRAM_NAME='NAVFoundation.IniFileLexer.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_INIFILE_LEXER_H__
#DEFINE __NAV_FOUNDATION_INIFILE_LEXER_H__ 'NAVFoundation.IniFileLexer.h'


DEFINE_CONSTANT

#IF_NOT_DEFINED NAV_INI_LEXER_MAX_TOKENS
constant integer NAV_INI_LEXER_MAX_TOKENS           = 5000
#END_IF

#IF_NOT_DEFINED NAV_INI_LEXER_MAX_TOKEN_LENGTH
constant integer NAV_INI_LEXER_MAX_TOKEN_LENGTH     = 255
#END_IF

#IF_NOT_DEFINED NAV_INI_LEXER_MAX_SOURCE
constant long NAV_INI_LEXER_MAX_SOURCE              = 127500  // 125 KB
#END_IF

constant integer NAV_INI_TOKEN_TYPE_LBRACKET    = 1     // [
constant integer NAV_INI_TOKEN_TYPE_RBRACKET    = 2     // ]
constant integer NAV_INI_TOKEN_TYPE_EQUALS      = 3     // =
constant integer NAV_INI_TOKEN_TYPE_IDENTIFIER  = 4     // Alphanumeric strings (keys, section names)
constant integer NAV_INI_TOKEN_TYPE_STRING      = 5     // Quoted strings or unquoted values
constant integer NAV_INI_TOKEN_TYPE_COMMENT     = 6     // Comments starting with ; or #
constant integer NAV_INI_TOKEN_TYPE_NEWLINE     = 7     // Newline characters
constant integer NAV_INI_TOKEN_TYPE_EOF         = 8     // End of file/input
constant integer NAV_INI_TOKEN_TYPE_WHITESPACE  = 9     // Spaces or tabs
constant integer NAV_INI_TOKEN_TYPE_ERROR       = 10    // Error token for unrecognized characters


DEFINE_TYPE

struct _NAVIniToken {
    integer type
    char value[NAV_INI_LEXER_MAX_TOKEN_LENGTH]
}


struct _NAVIniLexer {
    char source[NAV_INI_LEXER_MAX_SOURCE]
    long cursor

    _NAVIniToken tokens[NAV_INI_LEXER_MAX_TOKENS]
    long tokenCount
}


#END_IF // __NAV_FOUNDATION_INIFILE_LEXER_H__
