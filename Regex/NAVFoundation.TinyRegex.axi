PROGRAM_NAME='NAVFoundation.TinyRegex'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TINYREGEX__
#DEFINE __NAV_FOUNDATION_TINYREGEX__ 'NAVFoundation.TinyRegex'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

#IF_NOT_DEFINED MAX_REGEXP_OBJECTS
constant integer MAX_REGEXP_OBJECTS = 30
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
constant integer REGEX_TYPE_NON_DIGIT              = 12
constant integer REGEX_TYPE_ALPHA                  = 13
constant integer REGEX_TYPE_NON_ALPHA              = 14
constant integer REGEX_TYPE_WHITESPACE             = 15
constant integer REGEX_TYPE_NON_WHITESPACE         = 16
constant integer REGEX_TYPE_BRANCH                 = 17

constant char REGEX_TYPES[][50] =   {
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
                                        'BRANCH'
                                    }


DEFINE_TYPE

struct regex_t {
    char type;
    char char_value;
    char char_class[MAX_CHAR_CLASS_LENGTH];
}


// define_function sinteger re_match(char pattern[], char buffer[], integer consumed) {
//     stack_var regex_t re_compiled[MAX_REGEXP_OBJECTS]

//     re_compile(pattern, re_compiled)

//     return re_matchp(re_compiled, buffer, consumed)
// }


// define_function sinteger re_macthp(regex_t pattern[], char buffer[], integer consumed) {
//     consumed = 0;

//     if (pattern == 0) {
//         return -1
//     }

//     if (pattern[1].type == REGEX_TYPE_BEGIN) {
//         return matchpattern(pattern[1], buffer, consumed)
//     }
// }


define_function sinteger re_compile(char pattern[], regex_t re_compiled[]) {
    stack_var char char_class[MAX_CHAR_CLASS_LENGTH]
    stack_var integer index

    stack_var char c
    stack_var integer i
    stack_var integer j

    index = 1

    i = 1
    j = 1

    while (i <= length_array(pattern) && ((j + 1) < MAX_REGEXP_OBJECTS)) {
        c = pattern[i]

        switch (c) {
            case '^': { re_compiled[j].type = REGEX_TYPE_BEGIN }
            case '$': { re_compiled[j].type = REGEX_TYPE_END }
            case '.': { re_compiled[j].type = REGEX_TYPE_DOT }
            case '*': { re_compiled[j].type = REGEX_TYPE_STAR }
            case '+': { re_compiled[j].type = REGEX_TYPE_PLUS }
            case '?': { re_compiled[j].type = REGEX_TYPE_QUESTIONMARK }
            // case '|': { re_compiled[j].type = REGEX_TYPE_BRANCH }  // Not working properly

            case '\': {
                if ((i + 1) <= length_array(pattern)) {
                    i++

                    switch (pattern[i]) {
                        case 'd': { re_compiled[j].type = REGEX_TYPE_DIGIT }
                        case 'D': { re_compiled[j].type = REGEX_TYPE_NON_DIGIT }
                        case 'w': { re_compiled[j].type = REGEX_TYPE_ALPHA }
                        case 'W': { re_compiled[j].type = REGEX_TYPE_NON_ALPHA }
                        case 's': { re_compiled[j].type = REGEX_TYPE_WHITESPACE }
                        case 'S': { re_compiled[j].type = REGEX_TYPE_NON_WHITESPACE }
                        default: {
                            re_compiled[j].type = REGEX_TYPE_CHAR
                            re_compiled[j].char_value = pattern[i]
                        }
                    }
                }
            }

            case '[': {
                stack_var integer begin

                begin = index

                if (pattern[i + 1] == '^') {
                    re_compiled[j].type = REGEX_TYPE_INV_CHAR_CLASS
                    i++

                    if (pattern[i + 1] == 0) {
                        return -1
                    }
                }
                else {
                    re_compiled[j].type = REGEX_TYPE_CHAR_CLASS
                }

                i++
                while ((pattern[i] != ']') && (i <= length_array(pattern))) {
                    if (pattern[i] == '\') {
                        if (index >= (MAX_CHAR_CLASS_LENGTH - 1)) {
                            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Character class too long 1'")
                            return -1
                        }

                        if (pattern[i + 1] == 0) {
                            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Incomplete pattern. Missing non-zero char after \\'")
                            return -1
                        }

                        char_class[index] = pattern[i]
                        index++
                        i++
                    }
                    else if (index >= MAX_CHAR_CLASS_LENGTH) {
                        NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Character class too long 2'")
                        return -1
                    }

                    char_class[index] = pattern[i]
                    index++
                    i++
                }

                if (index >= MAX_CHAR_CLASS_LENGTH) {
                    NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Character class too long 3'")
                    return -1
                }

                char_class[index] = 0
                index++
                re_compiled[j].char_class = char_class
                set_length_array(re_compiled[j].char_class, index)
            }

            default: {
                re_compiled[j].type = REGEX_TYPE_CHAR
                re_compiled[j].char_value = c
            }
        }

        if (pattern[i] == 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Error 1'")
            return -1
        }

        i++
        j++
    }

    re_compiled[j].type = REGEX_TYPE_UNUSED
    set_length_array(re_compiled, j)

    return 0
}


define_function re_print(regex_t pattern[]) {
    stack_var integer i;
    stack_var integer j;
    stack_var char c;
    stack_var integer length;

    length = length_array(pattern);

    for (i = 1; i <= length; i++) {
        if (pattern[i].type == REGEX_TYPE_UNUSED) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Printed all objects'")
            break;
        }

        NAVDebugConsoleLog("'type: ', REGEX_TYPES[pattern[i].type]");

        if (pattern[i].type == REGEX_TYPE_CHAR_CLASS || pattern[i].type == REGEX_TYPE_INV_CHAR_CLASS) {
            NAVDebugConsoleLog(' [');

            for (j = 1; j <= MAX_CHAR_CLASS_LENGTH; j++) {
                c = pattern[i].char_class[j];

                if ((c == 0) || (c == ']')) {
                    break;
                }

                NAVDebugConsoleLog("c");
            }

            NAVDebugConsoleLog(']');
        }
        else if (pattern[i].type == REGEX_TYPE_CHAR) {
            NAVDebugConsoleLog("' ', pattern[i].char_value");
        }

        NAVDebugConsoleLog("13, 10");
    }
}


// define_function integer matchone(regex_t p, char c) {
//     switch (p.type) {
//         case REGEX_TYPE_DOT:            return matchdot(c);
//         case REGEX_TYPE_CHAR_CLASS:     return  matchcharclass(c, (const char*)p.u.ccl);
//         case REGEX_TYPE_INV_CHAR_CLASS: return !matchcharclass(c, (const char*)p.u.ccl);
//         case REGEX_TYPE_DIGIT:          return  matchdigit(c);
//         case REGEX_TYPE_NOT_DIGIT:      return !matchdigit(c);
//         case REGEX_TYPE_ALPHA:          return  matchalphanum(c);
//         case REGEX_TYPE_NOT_ALPHA:      return !matchalphanum(c);
//         case REGEX_TYPE_WHITESPACE:     return  matchwhitespace(c);
//         case REGEX_TYPE_NOT_WHITESPACE: return !matchwhitespace(c);
//         default:             return  (p.u.ch == c);
//     }
// }


define_function integer matchquestion(regex_t pattern1, regex_t pattern2, char buffer[], integer consumed) {
    // if (pattern1.type == REGEX_TYPE_UNUSED) {
    //     return 1
    // }

    // if (matchpattern(pattern, buffer, consumed)) {
    //     return 1
    // }

    // if (!length_array(buffer) || matchone(pattern1, buffer[1])) {
    //     return 0
    // }

    // return matchpattern(pattern2, buffer, consumed + 1)
}


// define_function integer matchpattern(regex_t pattern[], char buffer[], integer consumed) {
//     stack_var integer pre

//     pre = consumed

//     if (pattern[1].type == REGEX_TYPE_UNUSED || pattern[2].type == REGEX_TYPE_QUESTIONMARK) {
//         return matchquestion(pattern[1], pattern[2], buffer, consumed)
//     }
// }


#END_IF // __NAV_FOUNDATION_TINYREGEX__
