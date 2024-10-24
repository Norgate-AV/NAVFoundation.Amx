PROGRAM_NAME='NAVFoundation.IniParser.h'

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


#IF_NOT_DEFINED __NAV_FOUNDATION_INI_PARSER_H__
#DEFINE __NAV_FOUNDATION_INI_PARSER_H__ 'NAVFoundation.IniParser.h'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Lexer.axi'


DEFINE_CONSTANT

constant char NAV_INI_TOKEN_TYPE_NULL[] = 'NULL'
constant char NAV_INI_TOKEN_TYPE_BRACKET_OPEN[] = 'BRACKET_OPEN'
constant char NAV_INI_TOKEN_TYPE_BRACKET_CLOSE[] = 'BRACKET_CLOSE'
constant char NAV_INI_TOKEN_TYPE_TRUE[] = 'TRUE'
constant char NAV_INI_TOKEN_TYPE_FALSE[] = 'FALSE'
constant char NAV_INI_TOKEN_TYPE_NUMBER[] = 'NUMBER'
constant char NAV_INI_TOKEN_TYPE_IDENTIFIER[] = 'IDENTIFIER'
constant char NAV_INI_TOKEN_TYPE_ASSIGNMENT_OPERATOR[] = 'ASSIGNMENT_OPERATOR'
constant char NAV_INI_TOKEN_TYPE_STRING[] = 'STRING'

constant char NAV_INI_TOKEN_SPEC[][][100] = {
    // End of file
    { '\Z', 'EOF' },

    // Whitespace
    { '^;.*', 'NULL' },
    { '^#.*', 'NULL' },

    // Symbols
    { '^\[', 'BRACKET_OPEN' },
    { '^\]', 'BRACKET_CLOSE' },

    // Boolean
    { '^\btrue\b', 'TRUE' },
    { '^\bfalse\b', 'FALSE' },

    // Numbers
    { '^\d+', 'NUMBER' },

    // Identifiers
    { '^[_a-zA-Z]\w*', 'IDENTIFIER' },

    // Assignment operator
    { '^=', 'ASSIGNMENT_OPERATOR' },

    // Strings
    { '^"[^"]*"', 'STRING' }
}


DEFINE_TYPE

struct _NAVIniSection {
    char id[255]
    _NAVStringKeyValuePair kvp[255]
}


struct _NAVIniFile {
    integer count
    _NAVIniSection sections[255]
}


struct _NAVIniParser {
    _NAVLexer lexer

    char source[NAV_MAX_BUFFER * 2]
    _NAVLexerToken lookahead
}


#END_IF // __NAV_FOUNDATION_INI_PARSER_H__
