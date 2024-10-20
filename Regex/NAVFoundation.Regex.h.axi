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
 *  Largely based on the tiny-regex-c library by kokke
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
                                                    'NOT_WHITESPACE'
                                                    // 'BRANCH',
                                                    // 'GROUP',
                                                    // 'QUANTIFIER'
                                                }

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


// #IF_NOT_DEFINED NAV_REGEX_MAX_STATES
// constant integer NAV_REGEX_MAX_STATES = 100
// #END_IF

// #IF_NOT_DEFINED NAV_REGEX_MAX_GROUPS
// constant integer NAV_REGEX_MAX_GROUPS = 50
// #END_IF

// #IF_NOT_DEFINED NAV_REGEX_TAB_SIZE
// constant integer NAV_REGEX_TAB_SIZE = 4
// #END_IF


// constant integer NAV_REGEX_TYPE_WILDCARD        = 1
// constant integer NAV_REGEX_TYPE_CHARACTER       = 2
// constant integer NAV_REGEX_TYPE_GROUP           = 3
// constant integer NAV_REGEX_TYPE_ESCAPE          = 4
// constant integer NAV_REGEX_TYPE_START_OF_STRING = 5
// constant integer NAV_REGEX_TYPE_END_OF_STRING   = 6
// constant integer NAV_REGEX_TYPE_DIGIT           = 7
// constant integer NAV_REGEX_TYPE_NON_DIGIT       = 8
// constant integer NAV_REGEX_TYPE_WORD            = 9
// constant integer NAV_REGEX_TYPE_NON_WORD        = 10
// constant integer NAV_REGEX_TYPE_WHITESPACE      = 11
// constant integer NAV_REGEX_TYPE_NON_WHITESPACE  = 12

// constant integer NAV_REGEX_QUANTIFIER_EXACTLY_ONE  = 1
// constant integer NAV_REGEX_QUANTIFIER_ZERO_OR_MORE = 2
// constant integer NAV_REGEX_QUANTIFIER_ONE_OR_MORE  = 3
// constant integer NAV_REGEX_QUANTIFIER_ZERO_OR_ONE  = 4

// constant sinteger NAV_REGEX_ERROR_INVALID_QUANTIFIER    = -1
// constant sinteger NAV_REGEX_ERROR_INVALID_ESCAPE        = -2
// constant sinteger NAV_REGEX_ERROR_INVALID_PATTERN       = -3


DEFINE_TYPE

struct _NAVRegexState {
    char type
    char value
    char charclass[MAX_CHAR_CLASS_LENGTH]
}


// struct _NAVRegexGroupState {
//     integer type
//     integer quantifier
//     _NAVRegexState states[MAX_REGEXP_OBJECTS]
// }


struct _NAVRegexMatchResult {
    integer length
    integer start
    integer end
    char text[NAV_MAX_BUFFER]
}


// struct _NAVRegexParser {
//     integer CurrentState;
//     integer CurrentGroup;

//     integer GroupCount;
//     integer StateCount[NAV_REGEX_MAX_GROUPS]

//     _NAVRegexState State[NAV_REGEX_MAX_GROUPS][NAV_REGEX_MAX_STATES];
//     _NAVRegexGroupState GroupState[NAV_REGEX_MAX_GROUPS]
// }


#END_IF // __NAV_FOUNDATION_REGEX_H__
