PROGRAM_NAME='NAVFoundation.JsonParser.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_JSON_PARSER_H__
#DEFINE __NAV_FOUNDATION_JSON_PARSER_H__ 'NAVFoundation.JsonParser.h'

#include 'NAVFoundation.JsonLexer.h.axi'


DEFINE_CONSTANT

/**
 * Maximum number of JSON nodes that can be parsed.
 * Each JSON value (object, array, string, number, boolean, null) requires one node.
 * @default 1000
 */
#IF_NOT_DEFINED NAV_JSON_PARSER_MAX_NODES
constant integer NAV_JSON_PARSER_MAX_NODES          = 1000
#END_IF

/**
 * Maximum length of an object key.
 * @default 64
 */
#IF_NOT_DEFINED NAV_JSON_PARSER_MAX_KEY_LENGTH
constant integer NAV_JSON_PARSER_MAX_KEY_LENGTH     = 64
#END_IF

/**
 * Maximum length of a string value.
 * @default 255
 */
#IF_NOT_DEFINED NAV_JSON_PARSER_MAX_STRING_LENGTH
constant integer NAV_JSON_PARSER_MAX_STRING_LENGTH  = 255
#END_IF

/**
 * Maximum nesting depth for JSON structures.
 * Prevents stack overflow from deeply nested objects/arrays.
 * @default 32
 */
#IF_NOT_DEFINED NAV_JSON_PARSER_MAX_DEPTH
constant integer NAV_JSON_PARSER_MAX_DEPTH          = 32
#END_IF

/**
 * Maximum length for error messages during parsing.
 *
 * @default 255
 */
#IF_NOT_DEFINED NAV_JSON_PARSER_MAX_ERROR_LENGTH
constant integer NAV_JSON_PARSER_MAX_ERROR_LENGTH   = 255
#END_IF


DEFINE_TYPE

/**
 * @struct _NAVJsonNode
 * @public
 * @description Represents a single node in the JSON tree structure.
 *
 * Each node can be an object, array, string, number, boolean, or null.
 * Nodes are organized in a tree using indices rather than pointers.
 *
 * All values are stored as their original string representation and parsed on-demand
 * by getter and query functions. This preserves precision for large integers and
 * simplifies the structure.
 *
 * @property {integer} type - The value type (NAV_JSON_VALUE_TYPE_*\)
 * @property {integer} parent - Index of parent node (0 if root)
 * @property {integer} firstChild - Index of first child for objects/arrays (0 if none)
 * @property {integer} nextSibling - Index of next sibling in parent's children (0 if last)
 * @property {char[]} key - Property key for object members (empty for array elements)
 * @property {char[]} value - String representation of the value (parsed on-demand by type)
 * @property {integer} childCount - Cached count of children for arrays/objects
 */
struct _NAVJsonNode {
    integer type

    integer parent
    integer firstChild
    integer nextSibling

    char key[NAV_JSON_PARSER_MAX_KEY_LENGTH]

    char value[NAV_JSON_PARSER_MAX_STRING_LENGTH]

    integer childCount
}


/**
 * @struct _NAVJson
 * @public
 * @description The main JSON structure containing the parsed node tree.
 *
 * This structure holds all parsed JSON nodes in a pre-allocated array.
 * Nodes reference each other using array indices (1-based, 0 = none).
 *
 * @property {_NAVJsonNode[]} nodes - Pre-allocated array of JSON nodes
 * @property {integer} nodeCount - Current number of nodes in use
 * @property {integer} rootIndex - Index of the root node (1-based)
 * @property {char[]} error - Error message if parsing failed
 * @property {integer} errorLine - Line number where error occurred
 * @property {integer} errorColumn - Column number where error occurred
 */
struct _NAVJson {
    _NAVJsonNode nodes[NAV_JSON_PARSER_MAX_NODES]
    integer nodeCount
    integer rootIndex
    char error[255]
    integer errorLine
    integer errorColumn
}


/**
 * @struct _NAVJsonParser
 * @private
 * @description Internal parser state for processing JSON token streams.
 *
 * This structure maintains the parser's current position in the token array
 * and tracks nesting depth to prevent stack overflow.
 *
 * @property {_NAVJsonToken[]} tokens - Array of tokens to parse
 * @property {integer} tokenCount - Total number of tokens
 * @property {integer} cursor - Current position in token array (1-based)
 * @property {integer} depth - Current nesting depth
 * @property {_NAVJson} json - Reference to the JSON structure being built
 *
 * @note This structure is for internal use by the parser implementation
 */
struct _NAVJsonParser {
    _NAVJsonToken tokens[NAV_JSON_LEXER_MAX_TOKENS]
    integer tokenCount
    integer cursor
    integer depth
}


#END_IF // __NAV_FOUNDATION_JSON_PARSER_H__
