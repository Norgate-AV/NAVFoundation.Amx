PROGRAM_NAME='NAVFoundation.YamlParser.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_YAML_PARSER_H__
#DEFINE __NAV_FOUNDATION_YAML_PARSER_H__ 'NAVFoundation.YamlParser.h'

#include 'NAVFoundation.YamlLexer.h.axi'


DEFINE_CONSTANT

/**
 * Maximum number of YAML nodes that can be parsed.
 * Each YAML value (mapping, sequence, scalar) requires one node.
 * @default 1000
 */
#IF_NOT_DEFINED NAV_YAML_PARSER_MAX_NODES
constant integer NAV_YAML_PARSER_MAX_NODES          = 1000
#END_IF

/**
 * Maximum length of a mapping key.
 * @default 64
 */
#IF_NOT_DEFINED NAV_YAML_PARSER_MAX_KEY_LENGTH
constant integer NAV_YAML_PARSER_MAX_KEY_LENGTH     = 64
#END_IF

/**
 * Maximum length of a scalar value.
 * @default 255
 */
#IF_NOT_DEFINED NAV_YAML_PARSER_MAX_VALUE_LENGTH
constant integer NAV_YAML_PARSER_MAX_VALUE_LENGTH   = 255
#END_IF

/**
 * Maximum nesting depth for YAML structures.
 * Prevents stack overflow from deeply nested mappings/sequences.
 * @default 32
 */
#IF_NOT_DEFINED NAV_YAML_PARSER_MAX_DEPTH
constant integer NAV_YAML_PARSER_MAX_DEPTH          = 32
#END_IF

/**
 * Maximum length for error messages during parsing.
 * @default 255
 */
#IF_NOT_DEFINED NAV_YAML_PARSER_MAX_ERROR_LENGTH
constant integer NAV_YAML_PARSER_MAX_ERROR_LENGTH   = 255
#END_IF

/**
 * Maximum length for YAML type tags.
 * @default 32
 */
#IF_NOT_DEFINED NAV_YAML_PARSER_MAX_TAG_LENGTH
constant integer NAV_YAML_PARSER_MAX_TAG_LENGTH     = 32
#END_IF

/**
 * Maximum length for YAML anchors.
 * @default 32
 */
#IF_NOT_DEFINED NAV_YAML_PARSER_MAX_ANCHOR_LENGTH
constant integer NAV_YAML_PARSER_MAX_ANCHOR_LENGTH  = 32
#END_IF


// =============================================================================
// YAML Value Types
// =============================================================================

constant integer NAV_YAML_VALUE_TYPE_MAPPING        = 1     // Object/dictionary
constant integer NAV_YAML_VALUE_TYPE_SEQUENCE       = 2     // Array/list
constant integer NAV_YAML_VALUE_TYPE_STRING         = 3     // String scalar
constant integer NAV_YAML_VALUE_TYPE_NUMBER         = 4     // Numeric scalar
constant integer NAV_YAML_VALUE_TYPE_BOOLEAN        = 5     // Boolean scalar
constant integer NAV_YAML_VALUE_TYPE_NULL           = 6     // Null value
constant integer NAV_YAML_VALUE_TYPE_TIMESTAMP      = 7     // ISO 8601 timestamp
constant integer NAV_YAML_VALUE_TYPE_BINARY         = 8     // Base64 binary data


// =============================================================================
// YAML Type Aliases (for convenience)
// =============================================================================

constant integer NAV_YAML_TYPE_MAP                  = NAV_YAML_VALUE_TYPE_MAPPING
constant integer NAV_YAML_TYPE_SEQ                  = NAV_YAML_VALUE_TYPE_SEQUENCE
constant integer NAV_YAML_TYPE_STR                  = NAV_YAML_VALUE_TYPE_STRING
constant integer NAV_YAML_TYPE_NUM                  = NAV_YAML_VALUE_TYPE_NUMBER
constant integer NAV_YAML_TYPE_BOOL                 = NAV_YAML_VALUE_TYPE_BOOLEAN


DEFINE_TYPE

/**
 * @struct _NAVYamlNode
 * @public
 * @description Represents a single node in the YAML tree structure.
 *
 * Each node can be a mapping, sequence, or scalar value.
 * Nodes are organized in a tree using indices rather than pointers.
 *
 * All scalar values are stored as their original string representation and parsed
 * on-demand by getter and query functions. This preserves precision for large
 * numbers and simplifies the structure.
 *
 * @property {integer} type - The value type (NAV_YAML_VALUE_TYPE_*\)
 * @property {char[]} key - The key name for mapping entries (empty for sequence items)
 * @property {char[]} value - The string representation of the scalar value
 * @property {integer} childCount - Number of child nodes (for mappings/sequences)
 * @property {integer} firstChild - Index of the first child node (0 = none)
 * @property {integer} nextSibling - Index of the next sibling node (0 = none)
 * @property {integer} parent - Index of the parent node (0 = root/none)
 * @property {char[]} tag - Explicit type tag (e.g., "!!str", "!!int")
 * @property {char[]} anchor - Anchor name (if this node has an anchor)
 */
struct _NAVYamlNode {
    integer type
    char key[NAV_YAML_PARSER_MAX_KEY_LENGTH]
    char value[NAV_YAML_PARSER_MAX_VALUE_LENGTH]
    integer childCount
    integer firstChild
    integer nextSibling
    integer parent
    char tag[NAV_YAML_PARSER_MAX_TAG_LENGTH]
    char anchor[NAV_YAML_PARSER_MAX_ANCHOR_LENGTH]
}

/**
 * @struct _NAVYaml
 * @public
 * @description Main YAML document structure containing the parsed node tree.
 *
 * This structure is returned by NAVYamlParse and passed to all query and
 * navigation functions. It maintains the complete tree of nodes and metadata.
 *
 * @property {_NAVYamlNode[]} nodes - Array of all nodes in the tree
 * @property {integer} nodeCount - Number of nodes in the tree
 * @property {char[]} source - Original YAML source text (for reference)
 * @property {char[]} error - Error message if parsing failed
 * @property {integer} errorLine - Line number where error occurred
 * @property {integer} errorColumn - Column number where error occurred
 * @property {integer} rootIndex - Index of the root node (typically 1)
 */
struct _NAVYaml {
    _NAVYamlNode nodes[NAV_YAML_PARSER_MAX_NODES]
    integer nodeCount
    char source[NAV_YAML_LEXER_MAX_SOURCE]
    char error[NAV_YAML_PARSER_MAX_ERROR_LENGTH]
    integer errorLine
    integer errorColumn
    integer rootIndex
}

/**
 * @struct _NAVYamlParser
 * @private
 * @description Internal parser state for processing YAML token streams.
 *
 * This structure maintains the parser's current position in the token array
 * and tracks nesting depth to prevent stack overflow.
 *
 * @property {_NAVYamlToken[]} tokens - Array of tokens to parse
 * @property {integer} tokenCount - Total number of tokens
 * @property {integer} cursor - Current position in token array (1-based)
 * @property {integer} depth - Current nesting depth
 *
 * @note This structure is for internal use by the parser implementation
 */
struct _NAVYamlParser {
    _NAVYamlToken tokens[NAV_YAML_LEXER_MAX_TOKENS]
    integer tokenCount
    integer cursor
    integer depth
}


#END_IF // __NAV_FOUNDATION_YAML_PARSER_H__
