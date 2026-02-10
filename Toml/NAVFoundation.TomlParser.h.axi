PROGRAM_NAME='NAVFoundation.TomlParser.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TOML_PARSER_H__
#DEFINE __NAV_FOUNDATION_TOML_PARSER_H__ 'NAVFoundation.TomlParser.h'

#include 'NAVFoundation.TomlLexer.h.axi'


DEFINE_CONSTANT

/**
 * Maximum number of TOML nodes that can be parsed.
 * Each TOML value (table, array, string, number, etc.) requires one node.
 * @default 2000
 */
#IF_NOT_DEFINED NAV_TOML_PARSER_MAX_NODES
constant integer NAV_TOML_PARSER_MAX_NODES          = 2000
#END_IF

/**
 * Maximum length of a key (or dotted key path).
 * @default 128
 */
#IF_NOT_DEFINED NAV_TOML_PARSER_MAX_KEY_LENGTH
constant integer NAV_TOML_PARSER_MAX_KEY_LENGTH     = 128
#END_IF

/**
 * Maximum length of a string value.
 * @default 512
 */
#IF_NOT_DEFINED NAV_TOML_PARSER_MAX_STRING_LENGTH
constant integer NAV_TOML_PARSER_MAX_STRING_LENGTH  = 512
#END_IF

/**
 * Maximum nesting depth for TOML structures.
 * Prevents stack overflow from deeply nested tables/arrays.
 * @default 32
 */
#IF_NOT_DEFINED NAV_TOML_PARSER_MAX_DEPTH
constant integer NAV_TOML_PARSER_MAX_DEPTH          = 32
#END_IF

/**
 * Maximum length for error messages during parsing.
 * @default 255
 */
#IF_NOT_DEFINED NAV_TOML_PARSER_MAX_ERROR_LENGTH
constant integer NAV_TOML_PARSER_MAX_ERROR_LENGTH   = 255
#END_IF

/**
 * Maximum number of components in a dotted key path.
 * Example: a.b.c.d has 4 components
 * @default 16
 */
#IF_NOT_DEFINED NAV_TOML_PARSER_MAX_KEY_COMPONENTS
constant integer NAV_TOML_PARSER_MAX_KEY_COMPONENTS = 16
#END_IF


// =============================================================================
// TOML Node Value Types
// =============================================================================
// These types are used to identify node types in the parse tree.

constant integer NAV_TOML_VALUE_TYPE_NONE           = 0   // Invalid/uninitialized
constant integer NAV_TOML_VALUE_TYPE_STRING         = 1   // string
constant integer NAV_TOML_VALUE_TYPE_INTEGER        = 2   // integer
constant integer NAV_TOML_VALUE_TYPE_FLOAT          = 3   // float
constant integer NAV_TOML_VALUE_TYPE_BOOLEAN        = 4   // boolean
constant integer NAV_TOML_VALUE_TYPE_DATETIME       = 5   // datetime
constant integer NAV_TOML_VALUE_TYPE_DATE           = 6   // local date
constant integer NAV_TOML_VALUE_TYPE_TIME           = 7   // local time
constant integer NAV_TOML_VALUE_TYPE_ARRAY          = 8   // array []
constant integer NAV_TOML_VALUE_TYPE_TABLE          = 9   // table (standard or inline)
constant integer NAV_TOML_VALUE_TYPE_INLINE_TABLE   = 10  // inline table { }
constant integer NAV_TOML_VALUE_TYPE_TABLE_ARRAY    = 11  // array of tables [[table]]


// =============================================================================
// TOML Node Type Aliases (for backward compatibility)
// =============================================================================
// These are aliases for the VALUE_TYPE constants used by test files.

constant integer NAV_TOML_NODE_TYPE_NONE            = NAV_TOML_VALUE_TYPE_NONE
constant integer NAV_TOML_NODE_TYPE_STRING          = NAV_TOML_VALUE_TYPE_STRING
constant integer NAV_TOML_NODE_TYPE_INTEGER         = NAV_TOML_VALUE_TYPE_INTEGER
constant integer NAV_TOML_NODE_TYPE_FLOAT           = NAV_TOML_VALUE_TYPE_FLOAT
constant integer NAV_TOML_NODE_TYPE_BOOLEAN         = NAV_TOML_VALUE_TYPE_BOOLEAN
constant integer NAV_TOML_NODE_TYPE_DATETIME        = NAV_TOML_VALUE_TYPE_DATETIME
constant integer NAV_TOML_NODE_TYPE_DATE            = NAV_TOML_VALUE_TYPE_DATE
constant integer NAV_TOML_NODE_TYPE_TIME            = NAV_TOML_VALUE_TYPE_TIME
constant integer NAV_TOML_NODE_TYPE_ARRAY           = NAV_TOML_VALUE_TYPE_ARRAY
constant integer NAV_TOML_NODE_TYPE_TABLE           = NAV_TOML_VALUE_TYPE_TABLE
constant integer NAV_TOML_NODE_TYPE_INLINE_TABLE    = NAV_TOML_VALUE_TYPE_INLINE_TABLE
constant integer NAV_TOML_NODE_TYPE_TABLE_ARRAY     = NAV_TOML_VALUE_TYPE_TABLE_ARRAY


DEFINE_TYPE

/**
 * @struct _NAVTomlNode
 * @public
 * @description Represents a single node in the TOML tree structure.
 *
 * Each node can be a table, array, string, number, boolean, datetime, or other TOML value.
 * Nodes are organized in a tree using indices rather than pointers.
 *
 * All values are stored as their original string representation and parsed on-demand
 * by getter and query functions. This preserves precision for large integers and
 * simplifies the structure.
 *
 * @property {integer} type - The value type (NAV_TOML_VALUE_TYPE_*\)
 * @property {integer} parent - Index of parent node (0 if root)
 * @property {integer} firstChild - Index of first child for tables/arrays (0 if none)
 * @property {integer} nextSibling - Index of next sibling in parent's children (0 if last)
 * @property {char[]} key - Property key for table members (empty for array elements)
 * @property {char[]} value - String representation of the value (parsed on-demand by type)
 * @property {char[]} tablePath - Full dotted table path (e.g., "database.server")
 * @property {integer} childCount - Cached count of children for arrays/tables
 * @property {char} isArrayTable - True if this is an array of tables element
 * @property {integer} subtype - Subtype information (e.g., string type, number base)
 */
struct _NAVTomlNode {
    integer type

    integer parent
    integer firstChild
    integer nextSibling

    char key[NAV_TOML_PARSER_MAX_KEY_LENGTH]

    char value[NAV_TOML_PARSER_MAX_STRING_LENGTH]

    char tablePath[NAV_TOML_PARSER_MAX_KEY_LENGTH]

    integer childCount

    char isArrayTable

    integer subtype
}


/**
 * @struct _NAVToml
 * @public
 * @description The main TOML structure containing the parsed node tree.
 *
 * This structure holds all parsed TOML nodes in a pre-allocated array.
 * Nodes reference each other using array indices (1-based, 0 = none).
 *
 * @property {_NAVTomlNode[]} nodes - Pre-allocated array of TOML nodes
 * @property {integer} nodeCount - Current number of nodes in use
 * @property {integer} rootIndex - Index of the root node (1-based)
 * @property {char[]} error - Error message if parsing failed
 * @property {integer} errorLine - Line number where error occurred
 * @property {integer} errorColumn - Column number where error occurred
 * @property {char[]} source - Original source text (for reference)
 */
struct _NAVToml {
    _NAVTomlNode nodes[NAV_TOML_PARSER_MAX_NODES]
    integer nodeCount
    integer rootIndex
    char error[NAV_TOML_PARSER_MAX_ERROR_LENGTH]
    integer errorLine
    integer errorColumn
    char source[NAV_TOML_LEXER_MAX_SOURCE]
}


/**
 * @struct _NAVTomlParser
 * @private
 * @description Internal parser state for processing TOML token streams.
 *
 * This structure maintains the parser's current position in the token array
 * and tracks the current table context for proper key resolution.
 *
 * @property {_NAVTomlToken[]} tokens - Array of tokens to parse
 * @property {long} tokenCount - Total number of tokens
 * @property {long} cursor - Current position in token array (1-based)
 * @property {integer} depth - Current nesting depth
 * @property {integer} currentTableIndex - Index of the current table node
 * @property {char[]} currentTablePath - Full path of the current table
 */
struct _NAVTomlParser {
    _NAVTomlToken tokens[NAV_TOML_LEXER_MAX_TOKENS]
    long tokenCount
    long cursor
    integer depth

    integer currentTableIndex
    char currentTablePath[NAV_TOML_PARSER_MAX_KEY_LENGTH]
}


#END_IF // __NAV_FOUNDATION_TOML_PARSER_H__
