PROGRAM_NAME='NAVFoundation.Jsmn'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Solutions Ltd

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

#include 'NAVFoundation.Core.axi'

// #DEFINE JSMN_DEBUG


DEFINE_CONSTANT

#IF_NOT_DEFINED NAV_MAX_JSMN_TOKENS
constant integer NAV_MAX_JSMN_TOKENS = 1024
#END_IF

/**
 * JSON type identifier. Basic types are:
 *     o Object
 *     o Array
 *     o String
 *     o Other primitive: number, boolean (true/false) or null
 */
constant integer JSMN_TYPE_UNDEFINED = 0
constant integer JSMN_TYPE_OBJECT = 1
constant integer JSMN_TYPE_ARRAY = 2
constant integer JSMN_TYPE_STRING = 3
constant integer JSMN_TYPE_PRIMITIVE = 4

/* Not enough tokens were provided */
constant sinteger JSMN_ERROR_NOMEM = -1

/* Invalid character inside JSON string */
constant sinteger JSMN_ERROR_INVAL = -2

/* The string is not a full JSON packet, more bytes expected */
constant sinteger JSMN_ERROR_PART = -3

constant sinteger JSMN_ERROR_OUT_OF_RANGE = -4

constant sinteger JSMN_SUCCESS = 0

constant char NAV_JSON_TEST_DATA_1[NAV_MAX_BUFFER] = '
    {
        "contacts": [
            {
                "name": "Alice",
                "age": 28,
                "phoneNumber": "01265 123456"
            },
            {
                "name": "Bob",
                "age": 32,
                "phoneNumber": "01256 345678"
            },
            {
                "name": "Charlie",
                "age": 40,
                "phoneNumber": "01432 678910"
            }
        ],
        "details": {
            "id": "abc123-abc33-fe6899-1209dd",
            "password": "secret",
            "isStupid": true
        }
    }
'
constant char NAV_JSON_TEST_DATA_2[NAV_MAX_BUFFER] = '
    {
        "name": "John",
        "age": 30,
        "cars": [
            {
                "name": "Ford",
                "models": [
                    "Fiesta",
                    "Focus",
                    "Mustang"
                ]
            },
            {
                "name": "BMW",
                "models": [
                    "320",
                    "X3",
                    "X5"
                ]
            },
            {
                "name": "Fiat",
                "models": [
                    "500",
                    "Panda"
                ]
            }
        ]
    }
'


DEFINE_TYPE

/**
 * JSON token description.
 * @param        type    type (object, array, string etc.)
 * @param        start    start position in JSON data string
 * @param        end        end position in JSON data string
 */
struct JsmnToken {
    integer type
    sinteger start
    sinteger end
    sinteger size
}

/**
 * JSON parser. Contains an array of token blocks available. Also stores
 * the string being parsed now and current position in that string
 */
struct JsmnParser {
    integer pos; /* offset in the JSON string */
    integer toknext; /* next token to allocate */
    sinteger toksuper; /* superior token node, e.g parent object or array */
}


/**
 * Creates a new parser based over a given  buffer with an array of tokens
 * available.
 */
define_function jsmn_init(JsmnParser parser) {
    parser.pos = 1
    parser.toknext = 1
    parser.toksuper = 0
}


define_function jsmn_print_parser(char call_site[], JsmnParser parser, char json[]) {
    NAVLog("'{', call_site, '} parser [position (character) / next token / super token] :: ', itoa(parser.pos), ', (', json[parser.pos], '), ', itoa(parser.toknext), ', ', itoa(parser.toksuper)")
}


define_function char[NAV_MAX_CHARS] jsmn_token_type_to_string(integer type) {
    switch (type) {
        case JSMN_TYPE_UNDEFINED: {
            return 'undefined'
        }
        case JSMN_TYPE_OBJECT: {
            return 'object'
        }
        case JSMN_TYPE_ARRAY: {
            return 'array'
        }
        case JSMN_TYPE_STRING: {
            return 'string'
        }
        case JSMN_TYPE_PRIMITIVE: {
            return 'primitive'
        }
        default: {
            return jsmn_token_type_to_string(JSMN_TYPE_UNDEFINED)
        }
    }
}


define_function integer jsmn_get_next_token_index(integer value) {
    return value + 1
}


define_function char[NAV_MAX_BUFFER] jsmn_get_token(char data[], JsmnToken token) {
    char result[NAV_MAX_BUFFER]
    integer tokenStart
    integer tokenLength

    tokenStart = type_cast(token.start)
    tokenLength = type_cast(token.end - token.start)

    result = mid_string(data, tokenStart, tokenLength)

    return result
}


define_function jsmn_copy_token(JsmnToken token1, JsmnToken token2) {
    token2.type = token1.type
    token2.start = token1.start
    token2.end = token1.end
    token2.size = token1.size
}


define_function jsmn_print_token(char call_site[], JsmnToken token, char json[]) {
    stack_var char token_type[NAV_MAX_CHARS]

    token_type = jsmn_token_type_to_string(token.type)

    NAVLog("'{', call_site, '} token [ type / start / end / size / content ] :: ', token_type, ', ', itoa(token.start), ', ', itoa(token.end), ', ', itoa(token.size), ', ', jsmn_get_token(json, token)")
}


define_function jsmn_print_tokens(char call_site[], JsmnToken tokens[], integer num_tokens, char json[]) {
    stack_var integer i

    for (i = 1; i <= num_tokens; i++) {
        jsmn_print_token(call_site, tokens[i], json)
    }
}


define_function jsmn_print_error(char call_site[], sinteger error_code) {
    stack_var char error_message[NAV_MAX_CHARS]

    switch (error_code) {
        case JSMN_ERROR_NOMEM: {
            error_message = 'Not enough tokens were provided'
            break
        }
        case JSMN_ERROR_INVAL: {
            error_message = 'Invalid character inside JSON string'
            break
        }
        case JSMN_ERROR_PART: {
            error_message = 'The string is not a full JSON packet, more bytes expected'
            break
        }
        case JSMN_ERROR_OUT_OF_RANGE: {
            error_message = 'The string is not a full JSON packet, more bytes expected'
            break
        }
        default: {
            error_message = 'Unknown error'
            break
        }
    }

    NAVLog("'{', call_site, '} error [ code / message ] :: ', itoa(error_code), ', ', error_message")
}


/**
 * Fills token type and boundaries.
 */
define_function jsmn_fill_token(JsmnToken token, integer type, sinteger start, sinteger end) {
    token.type = type
    token.start = start
    token.end = end
    token.size = 0
}


/**
 * Allocates a fresh unused token from the token pull.
 */
define_function sinteger jsmn_alloc_token(JsmnParser parser, JsmnToken tokens[], integer num_tokens) {
    if (parser.toknext >= num_tokens) {
        #IF_DEFINED JSMN_DEBUG
        jsmn_print_error('jsmn_alloc_token', JSMN_ERROR_NOMEM)
        #END_IF

        return JSMN_ERROR_NOMEM
    }

    tokens[parser.toknext].start = -1
    tokens[parser.toknext].end   = -1
    tokens[parser.toknext].size  = 0

    parser.toknext++

    return type_cast(parser.toknext - 1)
}


/**
 * Fills next token with JSON string.
 */
define_function sinteger jsmn_parse_string(JsmnParser parser, char js[], integer length, JsmnToken tokens[], integer num_tokens) {
    stack_var sinteger token
    stack_var integer start

    stack_var integer c
    stack_var integer i

    start = parser.pos

    parser.pos++

    while (parser.pos < length) {
        c = js[parser.pos]

        if(c == '"'){
            token = jsmn_alloc_token(parser, tokens, num_tokens)

            if(token < 0) {
                parser.pos = start

                #IF_DEFINED JSMN_DEBUG
                jsmn_print_error('jsmn_parse_string', JSMN_ERROR_NOMEM)
                #END_IF

                return JSMN_ERROR_NOMEM
            }

            jsmn_fill_token(tokens[type_cast(token)], JSMN_TYPE_STRING, type_cast(start + 1), type_cast(parser.pos))

            return 0
        }

        if(c == '\' && parser.pos + 1 < length) {
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

                case 'u': {
                    //
                    // Intervention time! I am not going to bother dealing with stupid unicode characters if you want know
                    // how to do this though you can take a look at the following bit of code:
                    // https://github.com/zserge/jsmn/blob/master/jsmn.c#L123
                    //
                    break
                }

                default: {
                    parser.pos = start

                    #IF_DEFINED JSMN_DEBUG
                    jsmn_print_error('jsmn_parse_string', JSMN_ERROR_INVAL)
                    #END_IF

                    return JSMN_ERROR_INVAL
                }
            }
        }

        parser.pos++
    }

    parser.pos = start

    #IF_DEFINED JSMN_DEBUG
    jsmn_print_error('jsmn_parse_string', JSMN_ERROR_PART)
    #END_IF

    return JSMN_ERROR_PART
}


/**
 * Fills next available token with JSON primitive.
 */
define_function sinteger jsmn_parse_primitive(JsmnParser parser, char js[], integer length, JsmnToken tokens[], integer num_tokens) {
    stack_var sinteger token
    stack_var integer start

    stack_var integer c

    start = parser.pos

    while (parser.pos < length) {
        c = js[parser.pos]

        switch(c) {
            case NAV_TAB:
            case NAV_CR:
            case NAV_LF:
            case ' ':
            case ',':
            case ']':
            case '}': {
                token = jsmn_alloc_token(parser, tokens, num_tokens)

                if(token < 0){
                    parser.pos = start

                    #IF_DEFINED JSMN_DEBUG
                    jsmn_print_error('jsmn_parse_primitive', JSMN_ERROR_NOMEM)
                    #END_IF

                    return JSMN_ERROR_NOMEM
                }

                jsmn_fill_token(tokens[type_cast(token)], JSMN_TYPE_PRIMITIVE, type_cast(start), type_cast(parser.pos))
                parser.pos--

                #IF_DEFINED JSMN_DEBUG
                jsmn_print_parser('jsmn_parse_primitive', parser, js)
                #END_IF

                return 0
            }

            default: {
                break
            }
        }

        if(c < 32 || c >= 127) {
            parser.pos = start

            #IF_DEFINED JSMN_DEBUG
            jsmn_print_error('jsmn_parse_primitive', JSMN_ERROR_INVAL)
            #END_IF

            return JSMN_ERROR_INVAL
        }

        parser.pos++

    }

    parser.pos = start

    #IF_DEFINED JSMN_DEBUG
    jsmn_print_error('jsmn_parse_primitive', JSMN_ERROR_PART)
    #END_IF

    return JSMN_ERROR_PART
}


/**
 * Parse JSON string and fill tokens.
 */
//int jsmn_parse(jsmn_parser *parser, const char *js, size_t len, jsmntok_t *tokens, unsigned int num_tokens) {
// define_function sinteger jsmn_parse(JsmnParser parser, char js[], integer length, JsmnToken tokens[], integer num_tokens) {
define_function sinteger jsmn_parse(JsmnParser parser, char js[], JsmnToken tokens[]) {
    stack_var integer r
    stack_var integer i
    stack_var sinteger token
    stack_var integer count

    stack_var integer c
    stack_var integer type

    stack_var integer length
    stack_var integer num_tokens

    length = length_array(js)
    num_tokens = max_length_array(tokens)

    // count = (parser.toknext - 1)
    count = 0

    while (parser.pos < length) {
        c = js[parser.pos]

        if (c == 65535) {
            #IF_DEFINED JSMN_DEBUG
            jsmn_print_error('jsmn_parse', JSMN_ERROR_OUT_OF_RANGE)
            #END_IF

            return JSMN_ERROR_OUT_OF_RANGE
        }

        switch (c) {
            case NAV_TAB:
            case NAV_CR:
            case NAV_LF:
            case ' ': {
                #IF_DEFINED JSMN_DEBUG
                jsmn_print_parser('jsmn_parse (whitespace)', parser, js)
                #END_IF

                break
            }

            case '{':
            case '[': {

                #IF_DEFINED JSMN_DEBUG
                jsmn_print_parser('jsmn_parse (open type)', parser, js)
                #END_IF

                count++

                token = jsmn_alloc_token(parser, tokens, num_tokens)

                if (token <= 0) {
                    #IF_DEFINED JSMN_DEBUG
                    jsmn_print_error('jsmn_parse', JSMN_ERROR_NOMEM)
                    #END_IF

                    return JSMN_ERROR_NOMEM
                }

                if (parser.toksuper != 0) {
                    tokens[type_cast(parser.toksuper)].size++
                }

                tokens[type_cast(token)].start = type_cast(parser.pos)
                parser.toksuper = type_cast(parser.toknext - 1)

                if (c == '{') {
                    tokens[type_cast(token)].type = JSMN_TYPE_OBJECT
                }
                else {
                    tokens[type_cast(token)].type = JSMN_TYPE_ARRAY
                }

                break
            }

            case '}':
            case ']': {
                #IF_DEFINED JSMN_DEBUG
                jsmn_print_parser('jsmn_parse (close type)', parser, js )
                #END_IF

                if (c == '}') {
                    type = JSMN_TYPE_OBJECT
                }
                else {
                    type = JSMN_TYPE_ARRAY
                }

                for (i = parser.toknext; i > 0; i--){
                    token = type_cast(i)

                    if (tokens[type_cast(token)].start != -1 && tokens[type_cast(token)].end == -1) {
                        if (tokens[type_cast(token)].type != type) {
                            #IF_DEFINED JSMN_DEBUG
                            jsmn_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                            #END_IF

                            return JSMN_ERROR_INVAL
                        }

                        parser.toksuper = 0
                        tokens[type_cast(token)].end = type_cast(parser.pos + 1)
                        break
                    }
                }

                /* Error if unmatched closing bracket */
                if (i == -1) {
                    #IF_DEFINED JSMN_DEBUG
                    jsmn_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                    #END_IF

                    return JSMN_ERROR_INVAL
                }

                for (i = i; i > 0; i--){
                    token = type_cast(i)

                    if (tokens[type_cast(token)].start != -1 && tokens[type_cast(token)].end == -1) {
                        parser.toksuper = i
                        break
                    }
                }

                break
            }

            case '"': {
                #IF_DEFINED JSMN_DEBUG
                jsmn_print_parser('jsmn_parse (string)', parser, js)
                #END_IF

                r = jsmn_parse_string(parser, js, length, tokens, num_tokens)

                if (r < 0) {
                    return type_cast(r)
                }

                count++

                if (parser.toksuper != 0) {
                    tokens[type_cast(parser.toksuper)].size++
                }

                break
            }

            case ':': {
                #IF_DEFINED JSMN_DEBUG
                jsmn_print_parser('jsmn_parse (colon)', parser, js)
                #END_IF

                parser.toksuper = type_cast(parser.toknext - 1)
                break
            }

            case ',': {
                #IF_DEFINED JSMN_DEBUG
                jsmn_print_parser('jsmn_parse (whitespace)', parser, js)
                #END_IF

                if (
                       parser.toksuper != -1
                    && tokens[parser.toksuper].type != JSMN_TYPE_ARRAY
                    && tokens[parser.toksuper].type != JSMN_TYPE_OBJECT
                ) {
                    for (i = parser.toknext - 1; i > 0; i--) {
                        if (tokens[i].type == JSMN_TYPE_ARRAY || tokens[i].type == JSMN_TYPE_OBJECT) {
                            if (tokens[i].start != -1 && tokens[i].end == -1) {
                                parser.toksuper = i
                                break
                            }
                        }
                    }
                }

                break
            }

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
                jsmn_print_parser('jsmn_parse (primitive)', parser, js)
                #END_IF

                /* And they must not be keys of the object */
                //
                // For reasons beyond me this throws off the parsing of primitives
                //
                // if( parser.toksuper != -1 ){
                //
                //     if( tokens[ parser.toksuper ].type = JSMN_TYPE_OBJECT )
                //         return ( JSMN_ERROR_INVAL )
                //
                //     if( tokens[ parser.toksuper ].type = JSMN_TYPE_STRING
                //      && tokens[ parser.toksuper ].size != 0
                //     )
                //         return ( JSMN_ERROR_INVAL )
                //
                // }

                r = jsmn_parse_primitive(parser, js, length, tokens, num_tokens)

                if (r < 0) {
                    return r
                }

                count++

                if (parser.toksuper != 0) {
                    tokens[parser.toksuper].size++
                }

                break
            }

            default: {
                #IF_DEFINED JSMN_DEBUG
                jsmn_print_error('jsmn_parse', JSMN_ERROR_INVAL)
                #END_IF

                return JSMN_ERROR_INVAL
            }
        }

        parser.pos++
    }

    for (i = parser.toknext - 1; i > 0; i--) {
        /* Unmatched opened object or array */
        if (tokens[i].start != 0 && tokens[i].end == 0) {
            #IF_DEFINED JSMN_DEBUG
            jsmn_print_error('jsmn_parse', JSMN_ERROR_PART)
            #END_IF

            return JSMN_ERROR_PART
        }
    }

    return count
}


define_function char[NAV_MAX_BUFFER] jsmn_convert_number_to_boolean(sinteger number) {
    if (number > 0) {
        return 'true'
    }

    return 'false'
}


define_function integer jsmn_convert_boolean_to_number(char boolean[]) {
    if (lower_string(boolean) == 'true') {
        return true
    }

    return false
}


define_function sinteger jsoneq(char json[], JsmnToken jsonToken, char value[]) {
    sinteger result

    result = -1

    if (jsonToken.type == JSMN_TYPE_STRING && length_array(value) == (jsonToken.end - jsonToken.start) && mid_string(json, jsonToken.start, jsonToken.end - jsonToken.start) == value) {
        result = 0
    }

    return result
}

#END_IF // __NAV_FOUNDATION_JSMN__
