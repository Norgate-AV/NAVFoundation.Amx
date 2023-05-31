PROGRAM_NAME='NAVFoundation.Regex.axi'


#IF_NOT_DEFINED __NAVFOUNDATION_REGEX_AXI__
#DEFINE __NAVFOUNDATION_REGEX_AXI__

#include 'NAVFoundation.Core.axi'


/*
*
* Mini regex-module inspired by Rob Pike's regex code described in:
*
* http://www.cs.princeton.edu/courses/archive/spr09/cos333/beautiful.html
*
*
*
* Supports:
* ---------
*   '.'        Dot, matches any character
*   '^'        Start anchor, matches beginning of string
*   '$'        End anchor, matches end of string
*   '*'        Asterisk, match zero or more (greedy)
*   '+'        Plus, match one or more (greedy)
*   '?'        Question, match zero or one (non-greedy)
*   '[abc]'    Character class, match if one of {'a', 'b', 'c'}
*   '[^abc]'   Inverted class, match if NOT one of {'a', 'b', 'c'} -- NOTE: feature is currently broken!
*   '[a-zA-Z]' Character ranges, the character set of the ranges { a-z | A-Z }
*   '\s'       Whitespace, \t \f \r \n \v and spaces
*   '\S'       Non-whitespace
*   '\w'       Alphanumeric, [a-zA-Z0-9_]
*   '\W'       Non-alphanumeric
*   '\d'       Digits, [0-9]
*   '\D'       Non-digits
*
*
*/


DEFINE_CONSTANT
constant integer MAX_REGEXP_OBJECTS      = 30    /* Max number of regex symbols in expression. */
constant integer MAX_CHAR_CLASS_LEN      = 40    /* Max length of character-class buffer in.   */


constant integer UNUSED             = 0
constant integer DOT                = 1
constant integer BEGIN              = 2
constant integer END                = 3
constant integer QUESTIONMARK       = 4
constant integer STAR               = 5
constant integer PLUS               = 6
constant integer CHAR               = 7
constant integer CHAR_CLASS         = 8
constant integer INV_CHAR_CLASS     = 9
constant integer DIGIT              = 10
constant integer NOT_DIGIT          = 11
constant integer ALPHA              = 12
constant integer NOT_ALPHA          = 13
constant integer WHITESPACE         = 14
constant integer NOT_WHITESPACE     = 15
/* BRANCH */ /* <-- not working properly */


DEFINE_TYPE

struct regex_t {
    char type   /* CHAR, STAR, etc.                      */
    // union
    // {
    //     unsigned char  ch;   /*      the character itself             */
    //     unsigned char* ccl;  /*  OR  a pointer to characters in class */
    // } u;
}


/* Public functions: */
define_function slong re_match(char pattern[], char text[], slong matchlength) {
    return re_matchp(re_compile(pattern), text, matchlength)
}


define_function slong re_matchp(re_t pattern, char text[], slong matchlength) {
    stack_var slong index

    matchlength = 0

    if (pattern[1].type == BEGIN) {
        if (matchpattern(pattern[2], text, matchlength)) {
            return 0
        }

        return -1
    }
    
    index = 0
    while (index < length_array(text)) {
        index++

        if (matchpattern(pattern, text, matchlength)) {
            return index
        }
    }

    return -1
}


define_function re_compile(char pattern[]) {   // Needs to return re_t type
    /* The sizes of the two static arrays below substantiates the static RAM usage of this module.
    MAX_REGEXP_OBJECTS is the max number of symbols in the expression.
    MAX_CHAR_CLASS_LEN determines the size of buffer for chars in all char-classes in the expression. */

    stack_var regex_t re_compiled[MAX_REGEXP_OBJECTS]
    stack_var char ccl_buf[MAX_CHAR_CLASS_LEN]
    stack_var slong ccl_bufidx

    stack_var char c        /* current char in pattern   */
    stack_var slong i       /* index into pattern        */
    stack_var slong j       /* index into re_compiled    */

    ccl_bufidx = 1

    i = 1
    j = 1

    while (i <= length_array(pattern) && (j+1 < MAX_REGEXP_OBJECTS)) {
        c = pattern[i]

        switch (c) {
            /* Meta-characters: */
            case '^': {    re_compiled[j].type = BEGIN;           } break;
            case '$': {    re_compiled[j].type = END;             } break;
            case '.': {    re_compiled[j].type = DOT;             } break;
            case '*': {    re_compiled[j].type = STAR;            } break;
            case '+': {    re_compiled[j].type = PLUS;            } break;
            case '?': {    re_compiled[j].type = QUESTIONMARK;    } break;
            /*    case '|': {    re_compiled[j].type = BRANCH;          } break; <-- not working properly */

            /* Escaped character-classes (\s \w ...): */
            case '\\': {
                if (i+1 <= length_array(pattern)) {
                    /* Skip the escape-char '\\' */
                    i++
                    /* ... and check the next */
                    switch (pattern[i]) {
                        /* Meta-character: */
                        case 'd': {    re_compiled[j].type = DIGIT;           } break
                        case 'D': {    re_compiled[j].type = NOT_DIGIT       } break
                        case 'w': {    re_compiled[j].type = ALPHA            } break
                        case 'W': {    re_compiled[j].type = NOT_ALPHA       } break
                        case 's': {    re_compiled[j].type = WHITESPACE       } break
                        case 'S': {    re_compiled[j].type = NOT_WHITESPACE   } break

                        /* Escaped character, e.g. '.' or '$' */
                        default: {
                            re_compiled[j].type = CHAR
                            re_compiled[j].u.ch = pattern[i]
                        } break;
                    }
                }
            } break;
                    /* '\\' as last char in pattern -> invalid regular expression. */
            /*
                    else
                    {
                    re_compiled[j].type = CHAR;
                    re_compiled[j].ch = pattern[i];
                    }
            */

            /* Character class: */
            case '[': {
                /* Remember where the char-buffer starts. */
                int buf_begin = ccl_bufidx

                /* Look-ahead to determine if negated */
                if (pattern[i+1] == '^') {
                    re_compiled[j].type = INV_CHAR_CLASS
                    i += 1 /* Increment i to avoid including '^' in the char-buffer */

                    if (pattern[i+1] == 0) { /* incomplete pattern, missing non-zero char after '^' */
                        return 0
                    }
                }
                else {
                    re_compiled[j].type = CHAR_CLASS
                }

                /* Copy characters inside [..] to buffer */
                while ((pattern[++i] != ']') && (pattern[i]   != '\0')) { /* Missing ] */
                    if (pattern[i] == '\\') {
                        if (ccl_bufidx >= MAX_CHAR_CLASS_LEN - 1) {
                            //fputs("exceeded internal buffer!\n", stderr);
                            return 0
                        }

                        if (pattern[i+1] == 0) { /* incomplete pattern, missing non-zero char after '\\' */
                            return 0
                        }

                        ccl_buf[ccl_bufidx++] = pattern[i++]
                    }
                    else if (ccl_bufidx >= MAX_CHAR_CLASS_LEN) {
                        //fputs("exceeded internal buffer!\n", stderr);
                        return 0;
                    }

                    ccl_buf[ccl_bufidx++] = pattern[i];
                }

                if (ccl_bufidx >= MAX_CHAR_CLASS_LEN) {
                    /* Catches cases such as [00000000000000000000000000000000000000][ */
                    //fputs("exceeded internal buffer!\n", stderr);
                    return 0;
                }

                /* Null-terminate string end */
                ccl_buf[ccl_bufidx++] = 0;
                re_compiled[j].u.ccl = &ccl_buf[buf_begin];
            } break;

            /* Other characters: */
            default: {
                re_compiled[j].type = CHAR;
                re_compiled[j].u.ch = c;
            } break;
        }

        /* no buffer-out-of-bounds access on invalid patterns - see https://github.com/kokke/tiny-regex-c/commit/1a279e04014b70b0695fba559a7c05d55e6ee90b */
        if (pattern[i] == 0) {
            return 0;
        }

        i++;
        j++;
    }
    
    /* 'UNUSED' is a sentinel used to indicate end-of-pattern */
    re_compiled[j].type = UNUSED

    return (re_t) re_compiled
}
