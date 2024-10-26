PROGRAM_NAME='NAVFoundation.Regex.h'

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

/**
 *  Largely based on the tiny-regex-c library
 *  https://github.com/kokke/tiny-regex-c
 *
 *  Adapted for use in NetLinx
 */


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_H__
#DEFINE __NAV_FOUNDATION_REGEX_H__ 'NAVFoundation.Regex.h'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

#IF_NOT_DEFINED MAX_REGEXP_OBJECTS
constant integer MAX_REGEXP_OBJECTS = 100
#END_IF

#IF_NOT_DEFINED MAX_CHAR_CLASS_LENGTH
constant integer MAX_CHAR_CLASS_LENGTH = 40
#END_IF

#IF_NOT_DEFINED NAV_REGEX_MAX_STATES
constant integer NAV_REGEX_MAX_STATES = 100
#END_IF

#IF_NOT_DEFINED NAV_REGEX_MAX_GROUPS
constant integer NAV_REGEX_MAX_GROUPS = 50
#END_IF

#IF_NOT_DEFINED NAV_REGEX_TAB_SIZE
constant integer NAV_REGEX_TAB_SIZE = 4
#END_IF

constant integer REGEX_TYPE_UNUSED                 = 1
constant integer REGEX_TYPE_DOT                    = 2
constant integer REGEX_TYPE_BEGIN                  = 3
constant integer REGEX_TYPE_END                    = 4
constant integer REGEX_TYPE_QUESTIONMARK           = 5
constant integer REGEX_TYPE_STAR                   = 6
constant integer REGEX_TYPE_PLUS                   = 7
constant integer REGEX_TYPE_CHAR                   = 8
constant integer REGEX_TYPE_CHAR_CLASS             = 9
constant integer REGEX_TYPE_INV_CHAR_CLASS         = 10
constant integer REGEX_TYPE_DIGIT                  = 11
constant integer REGEX_TYPE_NOT_DIGIT              = 12
constant integer REGEX_TYPE_ALPHA                  = 13
constant integer REGEX_TYPE_NOT_ALPHA              = 14
constant integer REGEX_TYPE_WHITESPACE             = 15
constant integer REGEX_TYPE_NOT_WHITESPACE         = 16
constant integer REGEX_TYPE_BRANCH                 = 17
constant integer REGEX_TYPE_GROUP                  = 18
constant integer REGEX_TYPE_QUANTIFIER             = 19
constant integer REGEX_TYPE_ESCAPE                 = 20
constant integer REGEX_TYPE_EPSILON                = 21
constant integer REGEX_TYPE_WORD_BOUNDARY          = 22
constant integer REGEX_TYPE_NOT_WORD_BOUNDARY      = 23
constant integer REGEX_TYPE_HEX                    = 24
constant integer REGEX_TYPE_NEWLINE                = 25
constant integer REGEX_TYPE_RETURN                 = 26
constant integer REGEX_TYPE_TAB                    = 27

constant integer NAV_REGEX_TYPE_WILDCARD        = REGEX_TYPE_DOT
constant integer NAV_REGEX_TYPE_CHARACTER       = REGEX_TYPE_CHAR
constant integer NAV_REGEX_TYPE_GROUP           = REGEX_TYPE_GROUP
constant integer NAV_REGEX_TYPE_ESCAPE          = REGEX_TYPE_ESCAPE
constant integer NAV_REGEX_TYPE_START_OF_STRING = REGEX_TYPE_BEGIN
constant integer NAV_REGEX_TYPE_END_OF_STRING   = REGEX_TYPE_END
constant integer NAV_REGEX_TYPE_DIGIT           = REGEX_TYPE_DIGIT
constant integer NAV_REGEX_TYPE_NON_DIGIT       = REGEX_TYPE_NOT_DIGIT
constant integer NAV_REGEX_TYPE_WORD            = REGEX_TYPE_ALPHA
constant integer NAV_REGEX_TYPE_NON_WORD        = REGEX_TYPE_NOT_ALPHA
constant integer NAV_REGEX_TYPE_WHITESPACE      = REGEX_TYPE_WHITESPACE
constant integer NAV_REGEX_TYPE_NON_WHITESPACE  = REGEX_TYPE_NOT_WHITESPACE

constant char REGEX_TYPES[][NAV_MAX_CHARS]  =   {
                                                    'UNUSED',
                                                    'DOT',
                                                    'BEGIN',
                                                    'END',
                                                    'QUESTIONMARK',
                                                    'STAR',
                                                    'PLUS',
                                                    'CHAR',
                                                    'CHAR_CLASS',
                                                    'INV_CHAR_CLASS',
                                                    'DIGIT',
                                                    'NOT_DIGIT',
                                                    'ALPHA',
                                                    'NOT_ALPHA',
                                                    'WHITESPACE',
                                                    'NOT_WHITESPACE',
                                                    'BRANCH',
                                                    'GROUP',
                                                    'QUANTIFIER',
                                                    'ESCAPE',
                                                    'EPSILON',
                                                    'WORD_BOUNDARY',
                                                    'NOT_WORD_BOUNDARY',
                                                    'HEX',
                                                    'NEWLINE',
                                                    'RETURN',
                                                    'TAB'
                                                }

constant integer NAV_REGEX_QUANTIFIER_EXACTLY_ONE  = 1  // '1'
constant integer NAV_REGEX_QUANTIFIER_ZERO_OR_MORE = 2  // '*'
constant integer NAV_REGEX_QUANTIFIER_ONE_OR_MORE  = 3  // '+'
constant integer NAV_REGEX_QUANTIFIER_ZERO_OR_ONE  = 4  // '?'

constant sinteger NAV_REGEX_ERROR_INVALID_QUANTIFIER    = -1
constant sinteger NAV_REGEX_ERROR_INVALID_ESCAPE        = -2
constant sinteger NAV_REGEX_ERROR_INVALID_PATTERN       = -3

constant char REGEX_CHAR_DOT            = 46    // '.'
constant char REGEX_CHAR_BEGIN          = 94    // '^'
constant char REGEX_CHAR_END            = 36    // '$'
constant char REGEX_CHAR_QUESTIONMARK   = 63    // '?'
constant char REGEX_CHAR_STAR           = 42    // '*'
constant char REGEX_CHAR_PLUS           = 43    // '+'
constant char REGEX_CHAR_ESCAPE         = 92    // '\'
constant char REGEX_CHAR_DIGIT          = 100   // 'd'
constant char REGEX_CHAR_NOT_DIGIT      = 68    // 'D'
constant char REGEX_CHAR_ALPHA          = 97    // 'a'
constant char REGEX_CHAR_NOT_ALPHA      = 65    // 'A'
constant char REGEX_CHAR_WHITESPACE     = 119   // 'w'
constant char REGEX_CHAR_NOT_WHITESPACE = 87    // 'W'
constant char REGEX_CHAR_BRANCH         = 124   // '|'
constant char REGEX_CHAR_START_CLASS    = 91    // '['
constant char REGEX_CHAR_END_CLASS      = 93    // ']'
constant char REGEX_CHAR_EPSILON        = 0     // ''
constant char REGEX_CHAR_WORD_BOUNDARY  = 98    // 'b'
constant char REGEX_CHAR_NOT_WORD_BOUNDARY = 66 // 'B'
constant char REGEX_CHAR_HEX            = 120   // 'x'
constant char REGEX_CHAR_NEWLINE        = 110   // 'n'
constant char REGEX_CHAR_RETURN         = 114   // 'r'
constant char REGEX_CHAR_TAB            = 116   // 't'


DEFINE_TYPE

struct _NAVRegexCharClass {
    char value[MAX_CHAR_CLASS_LENGTH]
    integer length
    integer cursor
}


struct _NAVRegexState {
    char type

    // char accepting

    char value
    _NAVRegexCharClass charclass

    integer quantifier

    // integer next[255]
}


struct _NAVRegexGroups {
    integer count
    integer current
    integer quantifier
    _NAVRegexState states[NAV_REGEX_MAX_GROUPS][MAX_REGEXP_OBJECTS]
}


struct _NAVRegexMatch {
    integer length
    integer start
    integer end
    char text[NAV_MAX_BUFFER]
}


struct _NAVRegexMatchResult {
    integer count

    integer current // current match index
    _NAVRegexMatch matches[255]

    char debug
}


struct _NAVRegexPattern {
    char value[255]
    integer length
    integer cursor
}


struct _NAVRegexInput {
    char value[NAV_MAX_BUFFER]
    integer length
    integer cursor
}


// struct _NAVRegexStateCollection {
//     integer count
//     _NAVRegexState states[MAX_REGEXP_OBJECTS]
// }


struct _NAVRegexOptions {
    char value[5]
    char case_insensitive
    char global
    char multiline
}


struct _NAVRegexParser {
    _NAVRegexPattern pattern

    integer count
    _NAVRegexState state[MAX_REGEXP_OBJECTS]

    _NAVRegexGroups groups

    _NAVRegexInput input

    // Should the options live here or on the pattern?
    _NAVRegexOptions options

    char debug
}


#END_IF // __NAV_FOUNDATION_REGEX_H__
