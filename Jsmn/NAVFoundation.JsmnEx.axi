PROGRAM_NAME='NAVFoundation.JsmnEx'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_JSMNEX__
#DEFINE __NAV_FOUNDATION_JSMNEX__ 'NAVFoundation.JsmnEx'

// Include strategy: When included from main file, only include header to avoid
// circular dependency. When built standalone (e.g., CI syntax validation),
// include full implementation to get all required functions.
#IF_NOT_DEFINED __NAV_FOUNDATION_JSMN__
#include 'NAVFoundation.Jsmn.axi'
#ELSE
#include 'NAVFoundation.Jsmn.h.axi'
#END_IF
#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.StringUtils.axi'


/**
 * JSMN Extended Functions
 *
 * This file provides helper functions and extensions to the core JSMN parser API,
 * making it easier to work with JSON data in NetLinx. It includes convenience
 * functions for parsing, token manipulation, debugging, and error handling.
 */


/**
 * Parse a JSON string and fill token array.
 *
 * This is a convenience wrapper around jsmn_parse() that automatically uses
 * the full length of the JSON string and token array.
 *
 * @param parser    The JSMN parser instance (will be modified during parsing)
 * @param js        The JSON string to parse
 * @param tokens    Array to store parsed tokens
 * @return          Number of tokens parsed on success, negative error code on failure:
 *                  - JSMN_ERROR_NOMEM (-3): Not enough tokens provided
 *                  - JSMN_ERROR_INVAL (-2): Invalid JSON syntax
 *                  - JSMN_ERROR_PART (-1): Incomplete JSON string
 *
 * @example
 *   JsmnParser parser
 *   JsmnToken tokens[10]
 *   sinteger result
 *
 *   jsmn_init(parser)
 *   result = jsmnex_parse(parser, '{"key":"value"}', tokens)
 *   if (result > 0) {
 *       // Successfully parsed, result contains token count
 *   }
 */
define_function sinteger jsmnex_parse(JsmnParser parser, char js[], JsmnToken tokens[]) {
    return jsmn_parse(parser, js, length_array(js), tokens, max_length_array(tokens))
}


/**
 * Print parser state for debugging.
 *
 * Logs the current state of the JSMN parser including position in the JSON string,
 * current character, next token index, and parent token index.
 *
 * @param call_site  String identifying where this function was called from
 * @param parser     The JSMN parser instance to inspect
 * @param json       The JSON string being parsed
 */
define_function jsmnex_print_parser(char call_site[], JsmnParser parser, char json[]) {
    NAVLog("'{', call_site, '} parser [position (character) / next token / super token] :: ', itoa(parser.pos), ', (', json[parser.pos], '), ', itoa(parser.toknext), ', ', itoa(parser.toksuper)")
}


/**
 * Convert JSMN token type constant to string representation.
 *
 * Converts the numeric token type constants (JSMN_TYPE_*\) into human-readable
 * string representations for logging and debugging purposes.
 *
 * @param type  The token type constant (JSMN_TYPE_UNDEFINED, JSMN_TYPE_OBJECT, etc.)
 * @return      String representation of the token type:
 *              - 'undefined' for JSMN_TYPE_UNDEFINED
 *              - 'object' for JSMN_TYPE_OBJECT
 *              - 'array' for JSMN_TYPE_ARRAY
 *              - 'string' for JSMN_TYPE_STRING
 *              - 'primitive' for JSMN_TYPE_PRIMITIVE
 */
define_function char[NAV_MAX_CHARS] jsmnex_token_type_to_string(integer type) {
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
            return jsmnex_token_type_to_string(JSMN_TYPE_UNDEFINED)
        }
    }
}


/**
 * Extract the string value from a JSON token.
 *
 * Returns the substring from the original JSON data corresponding to the token's
 * start and end positions. This does NOT decode escape sequences - the raw JSON
 * text is returned including any backslash escapes.
 *
 * @param data   The original JSON string that was parsed
 * @param token  The token whose value should be extracted
 * @return       The substring from the JSON data for this token
 *
 * @note For strings, this includes the surrounding quotes. For primitives,
 *       this returns the raw text (true, false, null, or number).
 * @note Escape sequences like \n, \t, \", etc. are NOT decoded.
 *
 * @example
 *   // JSON: {"name":"John\nDoe"}
 *   // For the string token, returns: "John\nDoe" (with literal backslash-n)
 */
define_function char[NAV_MAX_BUFFER] jsmnex_get_token_value(char data[], JsmnToken token) {
    return NAVStringSlice(data, type_cast(token.start), type_cast(token.end))
}


/**
 * Print detailed information about a single token for debugging.
 *
 * Logs the token's type, start position, end position, size (number of child tokens),
 * and the actual string content from the JSON data.
 *
 * @param call_site  String identifying where this function was called from
 * @param token      The token to inspect
 * @param json       The original JSON string
 */
define_function jsmnex_print_token(char call_site[], JsmnToken token, char json[]) {
    stack_var char token_type[NAV_MAX_CHARS]

    token_type = jsmnex_token_type_to_string(token.type)

    NAVLog("'{', call_site, '} token [ type / start / end / size / content ] :: ', token_type, ', ', itoa(token.start), ', ', itoa(token.end), ', ', itoa(token.size), ', ', jsmnex_get_token_value(json, token)")
}


/**
 * Print information about multiple tokens for debugging.
 *
 * Iterates through an array of tokens and logs detailed information about each one.
 * Useful for debugging parser output and understanding token structure.
 *
 * @param call_site   String identifying where this function was called from
 * @param tokens      Array of tokens to inspect
 * @param num_tokens  Number of tokens to print (1-based count)
 * @param json        The original JSON string
 */
define_function jsmnex_print_tokens(char call_site[], JsmnToken tokens[], integer num_tokens, char json[]) {
    stack_var integer i

    for (i = 1; i <= num_tokens; i++) {
        jsmnex_print_token(call_site, tokens[i], json)
    }
}


/**
 * Print human-readable error message for JSMN error codes.
 *
 * Converts JSMN error codes into descriptive error messages and logs them
 * with the calling location for debugging purposes.
 *
 * @param call_site   String identifying where the error occurred
 * @param error_code  The JSMN error code (negative value):
 *                    - JSMN_ERROR_NOMEM (-3): Not enough tokens provided
 *                    - JSMN_ERROR_INVAL (-2): Invalid JSON syntax
 *                    - JSMN_ERROR_PART (-1): Incomplete JSON string
 */
define_function jsmnex_print_error(char call_site[], sinteger error_code) {
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
        default: {
            error_message = 'Unknown error'
            break
        }
    }

    NAVLog("'{', call_site, '} error [ code / message ] :: ', itoa(error_code), ', ', error_message")
}


/**
 * Check if a token's value matches a target string.
 *
 * Compares the token's extracted value against a target string without
 * needing to extract the value separately first. More efficient than
 * calling jsmnex_get_token_value() when you only need to check equality.
 *
 * @param json       The original JSON string that was parsed
 * @param token      The token to check
 * @param value      The target value to compare against
 * @return           TRUE if the token's value matches, FALSE otherwise
 *
 * @note This works for all token types (STRING, PRIMITIVE, OBJECT, ARRAY)
 * @note For STRING tokens, include the quotes in the comparison value
 *
 * @example
 *   // Check if a token is a specific key
 *   if (jsmnex_token_equals(json, tokens[i], '"name"')) {
 *       // Found the "name" key
 *   }
 *
 *   // Check if a primitive token is true
 *   if (jsmnex_token_equals(json, tokens[i], 'true')) {
 *       // Boolean true value
 *   }
 */
define_function char jsmnex_token_equals(char json[], JsmnToken token, char value[]) {
    stack_var integer length

    if (!length_array(json)) {
        return false
    }

    length = type_cast(token.end - token.start)

    // Quick length check first (most efficient rejection)
    if (length_array(value) != length) {
        return false
    }

    // Compare the actual content
    return jsmnex_get_token_value(json, token) == value
}


#END_IF // __NAV_FOUNDATION_JSMNEX__
