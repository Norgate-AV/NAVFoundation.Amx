PROGRAM_NAME='NAVFoundation.IniFileParser.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_INIFILE_PARSER_H__
#DEFINE __NAV_FOUNDATION_INIFILE_PARSER_H__ 'NAVFoundation.IniFileParser.h'

#include 'NAVFoundation.IniFileLexer.h.axi'


DEFINE_CONSTANT

#IF_NOT_DEFINED NAV_INI_PARSER_MAX_SECTIONS
constant integer NAV_INI_PARSER_MAX_SECTIONS            = 100
#END_IF

#IF_NOT_DEFINED NAV_INI_PARSER_MAX_PROPERTIES
constant integer NAV_INI_PARSER_MAX_PROPERTIES          = 100
#END_IF

#IF_NOT_DEFINED NAV_INI_PARSER_MAX_KEY_LENGTH
constant integer NAV_INI_PARSER_MAX_KEY_LENGTH          = 64
#END_IF

#IF_NOT_DEFINED NAV_INI_PARSER_MAX_VALUE_LENGTH
constant integer NAV_INI_PARSER_MAX_VALUE_LENGTH        = 255
#END_IF

#IF_NOT_DEFINED NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH
constant integer NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH = 64
#END_IF


DEFINE_TYPE

struct _NAVIniProperty {
    char key[NAV_INI_PARSER_MAX_KEY_LENGTH]
    char value[NAV_INI_PARSER_MAX_VALUE_LENGTH]
}


struct _NAVIniSection {
    char name[NAV_INI_PARSER_MAX_SECTION_NAME_LENGTH]
    _NAVIniProperty properties[NAV_INI_PARSER_MAX_PROPERTIES]
    integer propertyCount
}


struct _NAVIniFile {
    _NAVIniSection sections[NAV_INI_PARSER_MAX_SECTIONS]
    integer sectionCount
}


struct _NAVIniParser {
    _NAVIniToken tokens[NAV_INI_LEXER_MAX_TOKENS]
    long tokenCount
    long cursor
}


#END_IF // __NAV_FOUNDATION_INIFILE_PARSER_H__
