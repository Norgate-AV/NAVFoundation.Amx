PROGRAM_NAME='NAVFoundation.Jsmn'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_JSMN__
#DEFINE __NAV_FOUNDATION_JSMN__ 'NAVFoundation.Jsmn'

#include 'NAVFoundation.Jsmn.h.axi'
#include 'NAVFoundation.JsmnEx.axi'


/**
 * Allocates a fresh unused token from the token pull.
 */
define_function sinteger jsmn_alloc_token(JsmnParser parser, JsmnToken tokens[],
                                          integer num_tokens) {
    if (parser.toknext >= num_tokens) {
        #IF_DEFINED JSMN_DEBUG
        jsmnex_print_error('jsmn_alloc_token', JSMN_ERROR_NOMEM)
        #END_IF

        return JSMN_ERROR_NOMEM
    }

    tokens[parser.toknext].start = -1
    tokens[parser.toknext].end = -1
    tokens[parser.toknext].size = 0
    #IF_DEFINED JSMN_PARENT_LINKS
    tokens[parser.toknext].parent = -1
    #END_IF

    parser.toknext++

    return type_cast(parser.toknext - 1)
}


/**
 * Fills token type and boundaries.
 */
define_function jsmn_fill_token(JsmnToken token, integer type,
                                sinteger start, sinteger end) {
    token.type = type
    token.start = start
    token.end = end
    token.size = 0
}


/**
 * Fills next available token with JSON primitive.
 */
define_function sinteger jsmn_parse_primitive(JsmnParser parser, char js[],
                                              integer length, JsmnToken tokens[],
                                              integer num_tokens) {
    stack_var sinteger token
    stack_var sinteger start

    start = type_cast(parser.pos)

    // NetLinx: parser.pos is 1-based, so we use <= length instead of < length
    for (; parser.pos <= length && parser.pos <= length_array(js); parser.pos++) {
        switch (js[parser.pos]) {
            #IF_NOT_DEFINED JSMN_STRICT
            // In strict mode primitive must be followed by "," or "}" or "]"
            case ':':
            #END_IF

            case $09:
            case $0D:
            case $0A:
            case ' ':
            case ',':
            case ']':
            case '}': {
                token = jsmn_alloc_token(parser, tokens, num_tokens)

                if(token < 0){
                    parser.pos = type_cast(start)

                    #IF_DEFINED JSMN_DEBUG
                    jsmnex_print_error('jsmn_parse_primitive', JSMN_ERROR_NOMEM)
                    #END_IF

                    return JSMN_ERROR_NOMEM
                }

                jsmn_fill_token(tokens[type_cast(token)], JSMN_TYPE_PRIMITIVE, start, type_cast(parser.pos))

                #IF_DEFINED JSMN_PARENT_LINKS
                tokens[type_cast(token)].parent = parser.toksuper
                #END_IF

                parser.pos--

                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_parser('jsmn_parse_primitive', parser, js)
                #END_IF

                return 0
            }
            default: {
                break
            }

            if(js[parser.pos] < 32 || js[parser.pos] >= 127) {
                parser.pos = type_cast(start)

                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_error('jsmn_parse_primitive', JSMN_ERROR_INVAL)
                #END_IF

                return JSMN_ERROR_INVAL
            }
        }
    }

    #IF_DEFINED JSMN_STRICT
    // In strict mode primitive must be followed by a comma/object/array
    parser.pos = type_cast(start)

    #IF_DEFINED JSMN_DEBUG
    jsmnex_print_error('jsmn_parse_primitive', JSMN_ERROR_PART)
    #END_IF

    return JSMN_ERROR_PART
    #ELSE
    // In non-strict mode, reaching end of string is okay - allocate the token
    // (This replicates the C code's fall-through to "found:" label)
    token = jsmn_alloc_token(parser, tokens, num_tokens)

    if(token < 0){
        parser.pos = type_cast(start)
        #IF_DEFINED JSMN_DEBUG
        jsmnex_print_error('jsmn_parse_primitive', JSMN_ERROR_NOMEM)
        #END_IF

        return JSMN_ERROR_NOMEM
    }

    jsmn_fill_token(tokens[type_cast(token)], JSMN_TYPE_PRIMITIVE, start, type_cast(parser.pos))

    #IF_DEFINED JSMN_PARENT_LINKS
    tokens[type_cast(token)].parent = parser.toksuper
    #END_IF

    parser.pos--
    return 0
    #END_IF
}


/**
 * Fills next token with JSON string.
 */
define_function sinteger jsmn_parse_string(JsmnParser parser, char js[],
                                           integer length, JsmnToken tokens[],
                                           integer num_tokens) {
    stack_var sinteger token
    stack_var sinteger start

    start = type_cast(parser.pos)

    parser.pos++

    // NetLinx: parser.pos is 1-based, so we use <= length instead of < length
    for (; parser.pos <= length && parser.pos <= length_array(js); parser.pos++) {
        stack_var char c

        c = js[parser.pos]

        // Quote: end of string
        if(c == '"'){
            token = jsmn_alloc_token(parser, tokens, num_tokens)

            if(token < 0) {
                parser.pos = type_cast(start)

                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_error('jsmn_parse_string', JSMN_ERROR_NOMEM)
                #END_IF

                return JSMN_ERROR_NOMEM
            }

            jsmn_fill_token(tokens[type_cast(token)], JSMN_TYPE_STRING, start + 1, type_cast(parser.pos))

            #IF_DEFINED JSMN_PARENT_LINKS
            tokens[type_cast(token)].parent = parser.toksuper
            #END_IF

            return 0
        }

        if(c == '\' && parser.pos + 1 < length) {
            stack_var integer i

            parser.pos++

            switch(js[parser.pos]) {
                case '"':
                case '/':
                case '\':
                case 'b':
                case 'f':
                case 'r':
                case 'n':
                case 't': {
                    break
                }

                // Allows escaped symbol \uXXXX
                case 'u': {
                    parser.pos++

                    // NetLinx: Use <= instead of < for 1-based array indexing
                    for (i = 0; i < 4 && parser.pos <= length && parser.pos <= length_array(js); i++) {
                        // If it isn't a hex character we have an error
                        if (!((js[parser.pos] >= 48 && js[parser.pos] <= 57) ||     // 0-9
                              (js[parser.pos] >= 65 && js[parser.pos] <= 70) ||     // A-F
                              (js[parser.pos] >= 97 && js[parser.pos] <= 102))) {   // a-f
                            parser.pos = type_cast(start)

                            #IF_DEFINED JSMN_DEBUG
                            jsmnex_print_error('jsmn_parse_string', JSMN_ERROR_INVAL)
                            #END_IF

                            return JSMN_ERROR_INVAL
                        }

                        parser.pos++
                    }

                    parser.pos--
                    break
                }

                default: {
                    parser.pos = type_cast(start)

                    #IF_DEFINED JSMN_DEBUG
                    jsmnex_print_error('jsmn_parse_string', JSMN_ERROR_INVAL)
                    #END_IF

                    return JSMN_ERROR_INVAL
                }
            }
        }
    }

    parser.pos = type_cast(start)

    #IF_DEFINED JSMN_DEBUG
    jsmnex_print_error('jsmn_parse_string', JSMN_ERROR_PART)
    #END_IF

    return JSMN_ERROR_PART
}


/**
 * Parse JSON string and fill tokens.
 */
define_function sinteger jsmn_parse(JsmnParser parser, char js[], integer length,
                                    JsmnToken tokens[], integer num_tokens) {
    stack_var sinteger r
    stack_var integer i
    stack_var sinteger token
    stack_var sinteger count

    // NetLinx: toknext starts at 1, but count should start at 0 (like C)
    count = type_cast(parser.toknext - 1)

    // NetLinx: parser.pos is 1-based, so we use <= length instead of < length
    for (; parser.pos <= length && parser.pos <= length_array(js); parser.pos++) {
        stack_var char c
        stack_var integer type

        c = js[parser.pos]

        switch (c) {
            case '{':
            case '[': {
                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_parser('jsmn_parse (open type)', parser, js)
                #END_IF

                count++
                token = jsmn_alloc_token(parser, tokens, num_tokens)

                if (token <= 0) {
                    #IF_DEFINED JSMN_DEBUG
                    jsmnex_print_error('jsmn_parse', JSMN_ERROR_NOMEM)
                    #END_IF

                    return JSMN_ERROR_NOMEM
                }

                if (parser.toksuper != -1) {
                    #IF_DEFINED JSMN_STRICT
                    // In strict mode an object or array can't become a key
                    if (tokens[type_cast(parser.toksuper)].type == JSMN_TYPE_OBJECT) {
                        #IF_DEFINED JSMN_DEBUG
                        jsmnex_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                        #END_IF

                        return JSMN_ERROR_INVAL
                    }
                    #END_IF

                    tokens[type_cast(parser.toksuper)].size++

                    #IF_DEFINED JSMN_PARENT_LINKS
                    tokens[type_cast(token)].parent = parser.toksuper
                    #END_IF
                }

                if (c == '{') {
                    tokens[type_cast(token)].type = JSMN_TYPE_OBJECT
                }
                else {
                    tokens[type_cast(token)].type = JSMN_TYPE_ARRAY
                }

                tokens[type_cast(token)].start = type_cast(parser.pos)
                parser.toksuper = type_cast(parser.toknext - 1)

                break
            }

            case '}':
            case ']': {
                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_parser('jsmn_parse (close type)', parser, js )
                #END_IF

                if (c == '}') {
                    type = JSMN_TYPE_OBJECT
                }
                else {
                    type = JSMN_TYPE_ARRAY
                }

                #IF_DEFINED JSMN_PARENT_LINKS
                if (parser.toknext < 2) {
                    #IF_DEFINED JSMN_DEBUG
                    jsmnex_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                    #END_IF

                    return JSMN_ERROR_INVAL
                }

                token = type_cast(parser.toknext - 1)
                for (;;) {
                    if (tokens[type_cast(token)].start != -1 && tokens[type_cast(token)].end == -1) {
                        if (tokens[type_cast(token)].type != type) {
                            #IF_DEFINED JSMN_DEBUG
                            jsmnex_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                            #END_IF

                            return JSMN_ERROR_INVAL
                        }

                        tokens[type_cast(token)].end = type_cast(parser.pos + 1)
                        parser.toksuper = tokens[type_cast(token)].parent
                        break
                    }

                    if (tokens[type_cast(token)].parent == -1) {
                        // Reached a root-level token. Check for mismatched type or
                        // if parser.toksuper == -1 (indicates trying to close an already-closed root)
                        if (tokens[type_cast(token)].type != type || parser.toksuper == -1) {
                            #IF_DEFINED JSMN_DEBUG
                            jsmnex_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                            #END_IF

                            return JSMN_ERROR_INVAL
                        }

                        break
                    }

                    token = tokens[type_cast(token)].parent
                }
                #ELSE
                for (i = parser.toknext - 1; i > 0; i--){
                    token = type_cast(i)

                    if (tokens[type_cast(token)].start != -1 && tokens[type_cast(token)].end == -1) {
                        if (tokens[type_cast(token)].type != type) {
                            #IF_DEFINED JSMN_DEBUG
                            jsmnex_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                            #END_IF

                            return JSMN_ERROR_INVAL
                        }

                        parser.toksuper = -1
                        tokens[type_cast(token)].end = type_cast(parser.pos + 1)
                        break
                    }
                }

                /* Error if unmatched closing bracket */
                #IF_DEFINED JSMN_DEBUG
                send_string 0, "'DEBUG: After close brace search, i=', itoa(i), ', toknext=', itoa(parser.toknext)"
                #END_IF

                if (i == 0) {
                    #IF_DEFINED JSMN_DEBUG
                    jsmnex_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                    #END_IF

                    return JSMN_ERROR_INVAL
                }

                for (; i > 0; i--){
                    token = type_cast(i)

                    if (tokens[type_cast(token)].start != -1 && tokens[type_cast(token)].end == -1) {
                        parser.toksuper = type_cast(i)
                        break
                    }
                }
                #END_IF

                break
            }

            case '"': {
                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_parser('jsmn_parse (string)', parser, js)
                #END_IF

                r = jsmn_parse_string(parser, js, length, tokens, num_tokens)

                if (r < 0) {
                    return r
                }

                count++
                if (parser.toksuper != -1) {
                    tokens[type_cast(parser.toksuper)].size++
                }

                break
            }

            case $09:
            case $0D:
            case $0A:
            case ' ': {
                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_parser('jsmn_parse (whitespace)', parser, js)
                #END_IF

                break
            }

            case ':': {
                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_parser('jsmn_parse (colon)', parser, js)
                #END_IF

                parser.toksuper = type_cast(parser.toknext - 1)
                break
            }

            case ',': {
                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_parser('jsmn_parse (whitespace)', parser, js)
                #END_IF

                if (
                       parser.toksuper != -1
                    && tokens[type_cast(parser.toksuper)].type != JSMN_TYPE_ARRAY
                    && tokens[type_cast(parser.toksuper)].type != JSMN_TYPE_OBJECT
                ) {
                    #IF_DEFINED JSMN_PARENT_LINKS
                    parser.toksuper = tokens[type_cast(parser.toksuper)].parent
                    #ELSE
                    for (i = parser.toknext - 1; i > 0; i--) {
                        if (tokens[type_cast(i)].type == JSMN_TYPE_ARRAY || tokens[type_cast(i)].type == JSMN_TYPE_OBJECT) {
                            if (tokens[type_cast(i)].start != -1 && tokens[type_cast(i)].end == -1) {
                                parser.toksuper = type_cast(i)
                                break
                            }
                        }
                    }
                    #END_IF
                }

                break
            }

            #IF_DEFINED JSMN_STRICT
            /* In strict mode primitives are: numbers and booleans */
            case '-':
            case '0':
            case '1':
            case '2':
            case '3':
            case '4':
            case '5':
            case '6':
            case '7':
            case '8':
            case '9':
            case 't':
            case 'f':
            case 'n': {
                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_parser('jsmn_parse (primitive)', parser, js)
                #END_IF

                /* And they must not be keys of the object */
                if (parser.toksuper != -1) {
                    if (tokens[type_cast(parser.toksuper)].type == JSMN_TYPE_OBJECT ||
                        (tokens[type_cast(parser.toksuper)].type == JSMN_TYPE_STRING && tokens[type_cast(parser.toksuper)].size != 0)) {
                        #IF_DEFINED JSMN_DEBUG
                        jsmnex_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                        #END_IF

                        return JSMN_ERROR_INVAL
                    }
                }

                r = jsmn_parse_primitive(parser, js, length, tokens, num_tokens)

                if (r < 0) {
                    return r
                }

                count++
                if (parser.toksuper != -1) {
                    tokens[type_cast(type_cast(parser.toksuper))].size++
                }

                break
            }
            #ELSE
            /* In non-strict mode every unquoted value is a primitive */
            default: {
                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_parser('jsmn_parse (primitive)', parser, js)
                #END_IF

                r = jsmn_parse_primitive(parser, js, length, tokens, num_tokens)

                if (r < 0) {
                    return r
                }

                count++
                if (parser.toksuper != -1) {
                    tokens[type_cast(parser.toksuper)].size++
                }

                break
            }
            #END_IF

            #IF_DEFINED JSMN_STRICT
            /* Unexpected char in strict mode */
            default: {
                #IF_DEFINED JSMN_DEBUG
                jsmnex_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                #END_IF

                return JSMN_ERROR_INVAL
            }
            #END_IF
        }
    }

    for (i = parser.toknext - 1; i > 0; i--) {
        /* Unmatched opened object or array */
        if (tokens[i].start != -1 && tokens[i].end == -1) {
            #IF_DEFINED JSMN_DEBUG
            jsmnex_print_error('jsmn_parse', JSMN_ERROR_PART)
            #END_IF

            return JSMN_ERROR_PART
        }
    }

    return count
}


/**
 * Creates a new parser based over a given  buffer with an array of tokens
 * available.
 *
 * Note: NetLinx arrays are 1-based, so parser.toknext starts at 1 (not 0 like C).
 * However, parser.toksuper uses -1 for "no parent" (same as C) for compatibility
 * with error detection logic. Actual token indices range from 1..n in NetLinx vs 0..n-1 in C.
 */
define_function jsmn_init(JsmnParser parser) {
    parser.pos = 1        // Start at character position 1 (NetLinx 1-based)
    parser.toknext = 1    // Next token will be at index 1 (NetLinx 1-based arrays)
    parser.toksuper = -1  // No parent token (-1 means "no parent", same as C)
}


#END_IF // __NAV_FOUNDATION_JSMN__
