PROGRAM_NAME='NAVFoundation.Jsmn.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_JSMN_H__
#DEFINE __NAV_FOUNDATION_JSMN_H__ 'NAVFoundation.Jsmn.h'

/**
 * JSMN_DEBUG
 *
 * Enables debug output messages during JSON parsing. When defined, the parser
 * will print error messages to help diagnose parsing failures, including error
 * codes and their meanings.
 *
 * Usage: Uncomment the line below to enable debug messages.
 */
// #DEFINE JSMN_DEBUG

/**
 * JSMN_STRICT
 *
 * Enables strict JSON parsing mode. When defined, the parser enforces stricter
 * JSON compliance rules:
 * - Rejects primitives (numbers, booleans, null) as root elements
 * - Requires object keys to be quoted strings
 * - Rejects primitives as object keys
 * - Rejects objects and arrays as object keys
 * - Reports unexpected characters as errors instead of ignoring them
 *
 * When disabled, the parser operates in lenient mode, accepting a wider range
 * of JSON-like inputs that may not conform to strict JSON standards.
 *
 * Usage: Uncomment the line below to enable strict mode.
 */
// #DEFINE JSMN_STRICT

/**
 * JSMN_PARENT_LINKS
 *
 * Enables parent token tracking in the JsmnToken structure. When defined, each
 * token includes a 'parent' field that references the index of its parent token
 * in the token array. This allows for easier traversal of the token tree structure.
 *
 * - Root tokens have parent = -1 (no parent)
 * - Child tokens store the array index of their parent token
 * - Adds memory overhead (one sinteger per token)
 *
 * When disabled, tokens do not track parent relationships, reducing memory usage
 * but requiring alternative methods to determine token hierarchy.
 *
 * Usage: Uncomment the line below to enable parent links.
 */
// #DEFINE JSMN_PARENT_LINKS


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

    #IF_DEFINED JSMN_PARENT_LINKS
    sinteger parent
    #END_IF
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


#END_IF // __NAV_FOUNDATION_JSMN_H__
