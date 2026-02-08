PROGRAM_NAME='NAVFoundation.YamlParser'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_YAML_PARSER__
#DEFINE __NAV_FOUNDATION_YAML_PARSER__ 'NAVFoundation.YamlParser'

#include 'NAVFoundation.YamlParser.h.axi'
#include 'NAVFoundation.YamlLexer.axi'
#include 'NAVFoundation.StringUtils.axi'

// Uncomment to enable parser debug logging
// #DEFINE YAML_PARSER_DEBUG

/**
 * Helper function to get token type name for debug logging and error messages
 */
define_function char[50] NAVYamlGetTokenTypeName(integer tokenType) {
    switch (tokenType) {
        case NAV_YAML_TOKEN_TYPE_NEWLINE:           { return 'NEWLINE' }
        case NAV_YAML_TOKEN_TYPE_INDENT:            { return 'INDENT' }
        case NAV_YAML_TOKEN_TYPE_DEDENT:            { return 'DEDENT' }
        case NAV_YAML_TOKEN_TYPE_DASH:              { return 'DASH' }
        case NAV_YAML_TOKEN_TYPE_COLON:             { return 'COLON' }
        case NAV_YAML_TOKEN_TYPE_COMMA:             { return 'COMMA' }
        case NAV_YAML_TOKEN_TYPE_LEFT_BRACKET:      { return 'LEFT_BRACKET' }
        case NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET:     { return 'RIGHT_BRACKET' }
        case NAV_YAML_TOKEN_TYPE_LEFT_BRACE:        { return 'LEFT_BRACE' }
        case NAV_YAML_TOKEN_TYPE_RIGHT_BRACE:       { return 'RIGHT_BRACE' }
        case NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR:      { return 'PLAIN_SCALAR' }
        case NAV_YAML_TOKEN_TYPE_STRING:            { return 'STRING' }
        case NAV_YAML_TOKEN_TYPE_NULL:              { return 'NULL' }
        case NAV_YAML_TOKEN_TYPE_TRUE:              { return 'TRUE' }
        case NAV_YAML_TOKEN_TYPE_FALSE:             { return 'FALSE' }
        case NAV_YAML_TOKEN_TYPE_COMMENT:           { return 'COMMENT' }
        case NAV_YAML_TOKEN_TYPE_DOCUMENT_START:    { return 'DOCUMENT_START' }
        case NAV_YAML_TOKEN_TYPE_DOCUMENT_END:      { return 'DOCUMENT_END' }
        case NAV_YAML_TOKEN_TYPE_ANCHOR:            { return 'ANCHOR' }
        case NAV_YAML_TOKEN_TYPE_ALIAS:             { return 'ALIAS' }
        case NAV_YAML_TOKEN_TYPE_LITERAL:           { return 'LITERAL' }
        case NAV_YAML_TOKEN_TYPE_FOLDED:            { return 'FOLDED' }
        case NAV_YAML_TOKEN_TYPE_DIRECTIVE:         { return 'DIRECTIVE' }
        case NAV_YAML_TOKEN_TYPE_EOF:               { return 'EOF' }
        default:                                    { return 'UNKNOWN' }
    }
}


/**
 * @function NAVYamlParserInit
 * @private
 * @description Initialize a YAML parser with an array of tokens.
 *
 * @param {_NAVYamlParser} parser - The parser structure to initialize
 * @param {_NAVYamlToken[]} tokens - The array of tokens to parse
 *
 * @returns {void}
 */
define_function NAVYamlParserInit(_NAVYamlParser parser, _NAVYamlToken tokens[]) {
    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ YamlParserInit ]: Initializing with ', itoa(length_array(tokens)), ' tokens'")
    #END_IF

    parser.tokens = tokens
    parser.tokenCount = length_array(tokens)
    parser.cursor = 1
    parser.depth = 0
}


/**
 * @function NAVYamlFindAnchor
 * @private
 * @description Find a node by its anchor name.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} anchorName - The anchor name to find
 *
 * @returns {integer} Node index, or 0 if not found
 */
define_function integer NAVYamlFindAnchor(_NAVYaml yaml, char anchorName[]) {
    stack_var integer i

    for (i = 1; i <= yaml.nodeCount; i++) {
        if (yaml.nodes[i].anchor == anchorName && length_array(anchorName) > 0) {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ FindAnchor ]: Found anchor=', anchorName, ' at node=', itoa(i)")
            #END_IF

            return i
        }
    }

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ FindAnchor ]: Anchor not found: ', anchorName")
    #END_IF

    return 0
}


/**
 * @function NAVYamlParserCopyNode
 * @private
 * @description Create a deep copy of a node and its subtree for alias resolution.
 *
 * @param {_NAVYamlParser} parser - The parser instance
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} sourceIndex - Index of node to copy
 * @param {integer} parentIndex - Index of parent for the copy
 * @param {char[]} key - Property key for the copy
 *
 * @returns {integer} Index of copied node, or 0 on error
 */
define_function integer NAVYamlParserCopyNode(_NAVYamlParser parser, _NAVYaml yaml, integer sourceIndex, integer parentIndex, char key[]) {
    stack_var integer copyIndex
    stack_var _NAVYamlNode sourceNode
    stack_var _NAVYamlNode childNode
    stack_var integer childCopyIndex
    stack_var integer childIndex

    if (sourceIndex == 0 || sourceIndex > yaml.nodeCount) {
        return 0
    }

    sourceNode = yaml.nodes[sourceIndex]

    // Allocate new node
    copyIndex = NAVYamlAllocateNode(yaml)
    if (copyIndex == 0) {
        return 0
    }

    // Copy node properties
    yaml.nodes[copyIndex].type = sourceNode.type
    yaml.nodes[copyIndex].key = key
    yaml.nodes[copyIndex].value = sourceNode.value
    yaml.nodes[copyIndex].tag = sourceNode.tag
    // Note: Don't copy anchor - aliases reference the original

    // Link to parent
    NAVYamlParserLinkChild(yaml, parentIndex, copyIndex)

    // Recursively copy children
    childIndex = sourceNode.firstChild
    if (sourceNode.childCount > 0 && childIndex > 0) {
        while (true) {
            childNode = yaml.nodes[childIndex]
            childCopyIndex = NAVYamlParserCopyNode(parser, yaml, childIndex, copyIndex, childNode.key)
            if (childCopyIndex == 0) {
                return 0
            }

            childIndex = childNode.nextSibling
            if (childIndex == 0) {
                break
            }
        }
    }

    return copyIndex
}


/**
 * @function NAVYamlParserParseBlockScalar
 * @private
 * @description Parse a block scalar (literal | or folded >).
 *
 * @param {_NAVYamlParser} parser - The parser instance
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key
 * @param {integer} scalarType - Token type (LITERAL or FOLDED)
 *
 * @returns {integer} Index of created node, or 0 on error
 */
define_function integer NAVYamlParserParseBlockScalar(_NAVYamlParser parser, _NAVYaml yaml, integer parentIndex, char key[], integer scalarType) {
    stack_var integer nodeIndex
    stack_var _NAVYamlToken token
    stack_var _NAVYamlToken scalarToken
    stack_var char content[NAV_YAML_PARSER_MAX_VALUE_LENGTH]
    stack_var char line[NAV_YAML_PARSER_MAX_VALUE_LENGTH]
    stack_var integer lineCount
    stack_var integer baseIndent
    stack_var char hasContent
    stack_var char isLiteral
    stack_var char indicators[10]
    stack_var char chompingIndicator
    stack_var integer explicitIndent
    stack_var integer i
    stack_var char ch
    stack_var integer trailingNewlines

    isLiteral = (scalarType == NAV_YAML_TOKEN_TYPE_LITERAL)

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ ParseBlockScalar ]: type=', NAVYamlGetTokenTypeName(scalarType), ' key=', key")
    #END_IF

    // Get the current token to access indicators
    if (!NAVYamlParserCurrentToken(parser, scalarToken)) {
        yaml.error = 'Unexpected end of tokens in block scalar'
        return 0
    }

    // Parse indicators from token value
    // Format: "", "+"," -", "2", "2+", "+2", "3-", "-3", etc.
    indicators = scalarToken.value
    chompingIndicator = 0   // 0 = clip (default), '+' = keep, '-' = strip
    explicitIndent = 0      // 0 = auto-detect

    for (i = 1; i <= length_array(indicators); i++) {
        ch = indicators[i]

        if (ch == '+' || ch == '-') {
            chompingIndicator = ch
        }
        else if (ch >= '1' && ch <= '9') {
            explicitIndent = ch - '0'
        }
    }

    #IF_DEFINED YAML_PARSER_DEBUG
    if (length_array(indicators) > 0) {
        NAVLog("'[ ParseBlockScalar ]: Indicators: chomping=', chompingIndicator, ' indent=', itoa(explicitIndent)")
    }
    #END_IF

    // Skip the | or > token
    NAVYamlParserAdvance(parser)

    // Skip NEWLINE after block scalar indicator
    if (NAVYamlParserCurrentToken(parser, token) && token.type == NAV_YAML_TOKEN_TYPE_NEWLINE) {
        NAVYamlParserAdvance(parser)
    }

    // Check if we have an INDENT (content) or just NEWLINE/EOF (empty block)
    hasContent = false

    if (NAVYamlParserCurrentToken(parser, token) && token.type == NAV_YAML_TOKEN_TYPE_INDENT) {
        hasContent = true

        // Use explicit indentation if provided, otherwise auto-detect from first content line
        if (explicitIndent > 0) {
            baseIndent = scalarToken.indent + explicitIndent
        }
        else {
            baseIndent = token.indent
        }

        NAVYamlParserAdvance(parser)
    }

    // Collect content and/or trailing newlines
    content = ''
    lineCount = 0
    trailingNewlines = 0

    while (NAVYamlParserCurrentToken(parser, token)) {
        if (token.type == NAV_YAML_TOKEN_TYPE_DEDENT) {
            // Check if this is followed by INDENT (indicates blank line continuation)
            stack_var _NAVYamlToken peekToken

            if (NAVYamlParserCanPeek(parser)) {
                NAVYamlParserPeek(parser, peekToken)

                if (peekToken.type == NAV_YAML_TOKEN_TYPE_INDENT) {
                    // This is a blank line followed by continuation
                    // Skip the DEDENT and let INDENT handling continue the block
                    NAVYamlParserAdvance(parser)
                    continue
                }
            }

            // True end of block scalar
            break
        }

        select {
            active (token.type == NAV_YAML_TOKEN_TYPE_NEWLINE): {
                // For both literal and folded: preserve newlines
                // For folded, intermediate newlines will become spaces, but trailing ones stay
                content = "content, 13, 10"  // Add CRLF
                trailingNewlines++

                lineCount++
                NAVYamlParserAdvance(parser)
            }
            active (token.type == NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR ||
                    token.type == NAV_YAML_TOKEN_TYPE_STRING): {
                // For folded scalars, convert preceding newlines to spaces
                if (!isLiteral && trailingNewlines > 0) {
                    // Remove the CRLFs we just added
                    set_length_string(content, length_array(content) - (trailingNewlines * 2))
                    // Add a single space instead (unless this is the first content)
                    if (length_array(content) > 0) {
                        content = "content, ' '"
                    }
                }

                // Add line content
                if (length_array(content) + length_array(token.value) < NAV_YAML_PARSER_MAX_VALUE_LENGTH) {
                    content = "content, token.value"
                    trailingNewlines = 0  // Reset when we have content
                }

                NAVYamlParserAdvance(parser)
            }
            active (token.type == NAV_YAML_TOKEN_TYPE_INDENT): {
                // INDENT within block scalar indicates continuation after blank line
                NAVYamlParserAdvance(parser)
            }
            active (true): {
                // Skip other tokens
                NAVYamlParserAdvance(parser)
            }
        }
    }

    // Apply chomping indicator to trailing newlines
    // Default (clip): Keep exactly one final newline
    // Strip (-): Remove all trailing newlines
    // Keep (+): Preserve all trailing newlines

    // Handle empty blocks specially
    if (length_array(content) == 0) {
        // For empty blocks, apply chomping rules
        if (chompingIndicator == '-') {
            // Strip: Remain empty
            content = ''
        }
        else if (chompingIndicator == '+') {
            // Keep: For empty blocks, add trailing newlines to represent preserved empty lines
            // YAML spec says keep preserves all trailing empty lines, minimum 2 for empty blocks
            content = "$0D,$0A,$0D,$0A"
        }
        else {
            // Clip (default): Add single trailing newline for empty block
            content = "$0D,$0A"
        }
    }
    else {
        // Non-empty blocks: apply chomping to collected content
        if (chompingIndicator == '-') {
            // Strip: Remove all trailing newlines (bounds-safe)
            while (length_array(content) >= 2 &&
                   content[length_array(content) - 1] == 13 &&
                   content[length_array(content)] == 10) {
                set_length_string(content, length_array(content) - 2)
            }
        }
        else if (chompingIndicator != '+') {
            // Clip (default): Keep exactly one trailing newline
            // Remove extra trailing newlines beyond the first (bounds-safe)
            while (length_array(content) >= 4 &&
                   content[length_array(content) - 3] == 13 &&
                   content[length_array(content) - 2] == 10 &&
                   content[length_array(content) - 1] == 13 &&
                   content[length_array(content)] == 10) {
                set_length_string(content, length_array(content) - 2)
            }
        }

        // Keep (+): Do nothing, preserve all trailing newlines
    }

    // Skip DEDENT
    if (NAVYamlParserCurrentToken(parser, token) && token.type == NAV_YAML_TOKEN_TYPE_DEDENT) {
        NAVYamlParserAdvance(parser)
    }

    // Create node with collected content
    nodeIndex = NAVYamlAllocateNode(yaml)
    if (nodeIndex == 0) {
        return 0
    }

    yaml.nodes[nodeIndex].type = NAV_YAML_VALUE_TYPE_STRING
    yaml.nodes[nodeIndex].key = key
    yaml.nodes[nodeIndex].value = content

    NAVYamlParserLinkChild(yaml, parentIndex, nodeIndex)

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ ParseBlockScalar ]: Complete node=', itoa(nodeIndex), ' length=', itoa(length_array(content))")
    #END_IF

    return nodeIndex
}


/**
 * Get a string representation of a YAML node type.
 *
 * @param {integer} type - The node type constant
 * @return {char[]} The type name as a string
 */
define_function char[32] NAVYamlGetNodeType(integer type) {
    switch (type) {
        case NAV_YAML_VALUE_TYPE_MAPPING:   return 'MAPPING'
        case NAV_YAML_VALUE_TYPE_SEQUENCE:  return 'SEQUENCE'
        case NAV_YAML_VALUE_TYPE_STRING:    return 'STRING'
        case NAV_YAML_VALUE_TYPE_NUMBER:    return 'NUMBER'
        case NAV_YAML_VALUE_TYPE_BOOLEAN:   return 'BOOLEAN'
        case NAV_YAML_VALUE_TYPE_NULL:      return 'NULL'
        case NAV_YAML_VALUE_TYPE_TIMESTAMP: return 'TIMESTAMP'
        case NAV_YAML_VALUE_TYPE_BINARY:    return 'BINARY'
        default:                            return 'UNKNOWN'
    }
}


/**
 * @function NAVYamlIsMapping
 * @public
 * @description Check if a node is a mapping (object/dictionary).
 * Mappings contain key-value pairs.
 *
 * @param {_NAVYamlNode} node - The node to check
 *
 * @returns {char} True if node is a mapping (object), False otherwise
 *
 * @example
 * if (NAVYamlIsMapping(node)) {
 *     send_string 0, "'Node is a mapping with ', itoa(NAVYamlGetChildCount(node)), ' properties'"
 * }
 */
define_function char NAVYamlIsMapping(_NAVYamlNode node) {
    return (node.type == NAV_YAML_VALUE_TYPE_MAPPING)
}


/**
 * @function NAVYamlIsSequence
 * @public
 * @description Check if a node is a sequence (array/list).
 * Sequences contain ordered elements.
 *
 * @param {_NAVYamlNode} node - The node to check
 *
 * @returns {char} True if node is a sequence (array), False otherwise
 *
 * @example
 * if (NAVYamlIsSequence(node)) {
 *     send_string 0, "'Node is a sequence with ', itoa(NAVYamlGetChildCount(node)), ' elements'"
 * }
 */
define_function char NAVYamlIsSequence(_NAVYamlNode node) {
    return (node.type == NAV_YAML_VALUE_TYPE_SEQUENCE)
}


/**
 * @function NAVYamlIsString
 * @public
 * @description Check if a node is a string scalar.
 * String nodes contain text values.
 *
 * @param {_NAVYamlNode} node - The node to check
 *
 * @returns {char} True if node is a string scalar, False otherwise
 *
 * @example
 * if (NAVYamlIsString(node)) {
 *     send_string 0, "'Node is a string: ', NAVYamlGetValue(node)"
 * }
 */
define_function char NAVYamlIsString(_NAVYamlNode node) {
    return (node.type == NAV_YAML_VALUE_TYPE_STRING)
}


/**
 * @function NAVYamlIsNumber
 * @public
 * @description Check if a node is a numeric scalar.
 * Numeric nodes contain integer or floating-point values.
 *
 * @param {_NAVYamlNode} node - The node to check
 *
 * @returns {char} True if node is a number, False otherwise
 *
 * @example
 * if (NAVYamlIsNumber(node)) {
 *     send_string 0, "'Node is a number: ', NAVYamlGetValue(node)"
 * }
 */
define_function char NAVYamlIsNumber(_NAVYamlNode node) {
    return (node.type == NAV_YAML_VALUE_TYPE_NUMBER)
}


/**
 * @function NAVYamlIsBoolean
 * @public
 * @description Check if a node is a boolean scalar.
 * Boolean nodes contain true/false values (or YAML equivalents: yes/no, on/off).
 *
 * @param {_NAVYamlNode} node - The node to check
 *
 * @returns {char} True if node is a boolean, False otherwise
 *
 * @example
 * if (NAVYamlIsBoolean(node)) {
 *     send_string 0, "'Node is a boolean: ', NAVYamlGetValue(node)"
 * }
 */
define_function char NAVYamlIsBoolean(_NAVYamlNode node) {
    return (node.type == NAV_YAML_VALUE_TYPE_BOOLEAN)
}


/**
 * @function NAVYamlIsNull
 * @public
 * @description Check if a node is null.
 * Null nodes represent the absence of a value.
 *
 * @param {_NAVYamlNode} node - The node to check
 *
 * @returns {char} True if node is null, False otherwise
 *
 * @example
 * if (NAVYamlIsNull(node)) {
 *     send_string 0, "'Node is null'"
 * }
 */
define_function char NAVYamlIsNull(_NAVYamlNode node) {
    return (node.type == NAV_YAML_VALUE_TYPE_NULL)
}


/**
 * @function NAVYamlIsTimestamp
 * @public
 * @description Check if a node is a timestamp.
 * Timestamp nodes should contain ISO 8601 formatted date/time strings.
 *
 * @param {_NAVYamlNode} node - The node to check
 *
 * @returns {char} True if node is tagged as timestamp, False otherwise
 *
 * @example
 * if (NAVYamlIsTimestamp(node)) {
 *     send_string 0, "'Node is a timestamp: ', NAVYamlGetValue(node)"
 * }
 */
define_function char NAVYamlIsTimestamp(_NAVYamlNode node) {
    return (node.type == NAV_YAML_VALUE_TYPE_TIMESTAMP)
}


/**
 * @function NAVYamlGetChildCount
 * @public
 * @description Get the number of child nodes for a mapping or sequence.
 * Returns 0 for scalar nodes or empty collections.
 *
 * @param {_NAVYamlNode} node - The node
 *
 * @returns {integer} Number of children (0 for scalars or empty collections)
 *
 * @example
 * stack_var integer count
 * count = NAVYamlGetChildCount(node)
 * send_string 0, "'Node has ', itoa(count), ' children'"
 */
define_function integer NAVYamlGetChildCount(_NAVYamlNode node) {
    return node.childCount
}


/**
 * @function NAVYamlGetKey
 * @public
 * @description Get the key name for a mapping entry.
 * Returns empty string for sequence items or nodes without keys.
 *
 * @param {_NAVYamlNode} node - The node
 *
 * @returns {char[]} The key name (empty for sequence items)
 *
 * @example
 * stack_var char key[NAV_YAML_PARSER_MAX_KEY_LENGTH]
 * key = NAVYamlGetKey(node)
 * if (length_array(key) > 0) {
 *     send_string 0, "'Key: ', key"
 * }
 */
define_function char[NAV_YAML_PARSER_MAX_KEY_LENGTH] NAVYamlGetKey(_NAVYamlNode node) {
    return node.key
}


/**
 * @function NAVYamlGetValue
 * @public
 * @description Get the string value of a scalar node.
 * All scalar values are stored as strings and can be converted to other types using
 * type-specific query functions or NetLinx conversion functions (atoi, atof, etc.).
 *
 * @param {_NAVYamlNode} node - The node
 *
 * @returns {char[]} The value as a string (empty for mappings/sequences)
 *
 * @example
 * stack_var char value[NAV_YAML_PARSER_MAX_VALUE_LENGTH]
 * value = NAVYamlGetValue(node)
 * send_string 0, "'Value: ', value"
 */
define_function char[NAV_YAML_PARSER_MAX_VALUE_LENGTH] NAVYamlGetValue(_NAVYamlNode node) {
    return node.value
}


/**
 * @function NAVYamlGetTag
 * @public
 * @description Get the explicit type tag for a node.
 * Tags specify type information (e.g., "!!str", "!!int", "!!bool", "!custom").
 * Returns empty string if node has no explicit tag.
 *
 * @param {_NAVYamlNode} node - The node
 *
 * @returns {char[]} The type tag (e.g., "!!str", "!!int"), or empty string if no tag
 *
 * @example
 * stack_var char tag[NAV_YAML_PARSER_MAX_TAG_LENGTH]
 * tag = NAVYamlGetTag(node)
 * if (length_array(tag) > 0) {
 *     send_string 0, "'Tag: ', tag"
 * }
 */
define_function char[NAV_YAML_PARSER_MAX_TAG_LENGTH] NAVYamlGetTag(_NAVYamlNode node) {
    return node.tag
}


/**
 * @function NAVYamlGetAnchor
 * @public
 * @description Get the anchor name for a node.
 * Anchors allow nodes to be referenced elsewhere in the document using aliases.
 * Returns empty string if node has no anchor.
 *
 * @param {_NAVYamlNode} node - The node
 *
 * @returns {char[]} The anchor name (empty if no anchor, e.g., "defaults", "base")
 *
 * @example
 * stack_var char anchor[NAV_YAML_PARSER_MAX_ANCHOR_LENGTH]
 * anchor = NAVYamlGetAnchor(node)
 * if (length_array(anchor) > 0) {
 *     send_string 0, "'Anchor: ', anchor"
 * }
 */
define_function char[NAV_YAML_PARSER_MAX_ANCHOR_LENGTH] NAVYamlGetAnchor(_NAVYamlNode node) {
    return node.anchor
}


/**
 * @function NAVYamlGetRoot
 * @public
 * @description Get the root node of the YAML document.
 * The root node is the top-level value (typically a mapping or sequence).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} node - Output parameter for the root node
 *
 * @returns {char} True if successful, False if document is empty or invalid
 *
 * @example
 * stack_var _NAVYamlNode root
 * if (NAVYamlGetRoot(yaml, root)) {
 *     send_string 0, "'Root type: ', NAVYamlGetNodeType(root.type)"
 * }
 */
define_function char NAVYamlGetRoot(_NAVYaml yaml, _NAVYamlNode node) {
    if (yaml.rootIndex < 1 || yaml.rootIndex > yaml.nodeCount) {
        return false
    }

    node = yaml.nodes[yaml.rootIndex]
    return true
}


/**
 * @function NAVYamlGetFirstChild
 * @public
 * @description Get the first child node of a mapping or sequence.
 * Returns false if the parent has no children or is a scalar type.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} parent - The parent node (must be mapping or sequence)
 * @param {_NAVYamlNode} child - Output parameter for the first child
 *
 * @returns {char} True if parent has children, False otherwise
 *
 * @example
 * stack_var _NAVYamlNode child
 * if (NAVYamlGetFirstChild(yaml, parentNode, child)) {
 *     send_string 0, "'First child key: ', NAVYamlGetKey(child)"
 * }
 */
define_function char NAVYamlGetFirstChild(_NAVYaml yaml, _NAVYamlNode parent, _NAVYamlNode child) {
    if (parent.firstChild < 1 || parent.firstChild > yaml.nodeCount) {
        return false
    }

    child = yaml.nodes[parent.firstChild]
    return true
}


/**
 * @function NAVYamlGetNextSibling
 * @public
 * @description Get the next sibling node at the same level.
 * Use this to iterate through children of a mapping or sequence.
 * Returns false if this is the last sibling.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} node - The current node
 * @param {_NAVYamlNode} sibling - Output parameter for the next sibling
 *
 * @returns {char} True if node has a next sibling, False if this is the last child
 *
 * @example
 * stack_var _NAVYamlNode sibling
 * sibling = firstChild
 * while (true) {
 *     // Process sibling
 *     if (!NAVYamlGetNextSibling(yaml, sibling, sibling)) break
 * }
 */
define_function char NAVYamlGetNextSibling(_NAVYaml yaml, _NAVYamlNode node, _NAVYamlNode sibling) {
    if (node.nextSibling < 1 || node.nextSibling > yaml.nodeCount) {
        return false
    }

    sibling = yaml.nodes[node.nextSibling]
    return true
}


/**
 * @function NAVYamlGetParent
 * @public
 * @description Get the parent node of the current node.
 * Returns false if node is the root node (which has no parent).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} node - The current node
 * @param {_NAVYamlNode} parent - Output parameter for the parent
 *
 * @returns {char} True if node has a parent, False if node is root
 *
 * @example
 * stack_var _NAVYamlNode parent
 * if (NAVYamlGetParent(yaml, currentNode, parent)) {
 *     send_string 0, "'Parent type: ', NAVYamlGetNodeType(parent.type)"
 * }
 */
define_function char NAVYamlGetParent(_NAVYaml yaml, _NAVYamlNode node, _NAVYamlNode parent) {
    if (node.parent < 1 || node.parent > yaml.nodeCount) {
        return false
    }

    parent = yaml.nodes[node.parent]
    return true
}


// =============================================================================
// PARSER HELPER FUNCTIONS
// =============================================================================

/**
 * @function NAVYamlParserHasMoreTokens
 * @private
 * @description Check if the parser has more tokens to process.
 *
 * @param {_NAVYamlParser} parser - The parser to check
 *
 * @returns {char} True if more tokens are available
 */
define_function char NAVYamlParserHasMoreTokens(_NAVYamlParser parser) {
    return parser.cursor <= parser.tokenCount
}


/**
 * @function NAVYamlParserCurrentToken
 * @private
 * @description Get the current token without advancing the cursor.
 *
 * @param {_NAVYamlParser} parser - The parser instance
 * @param {_NAVYamlToken} token - Output parameter to receive the current token
 *
 * @returns {char} True if token retrieved, False if no more tokens
 */
define_function char NAVYamlParserCurrentToken(_NAVYamlParser parser, _NAVYamlToken token) {
    if (!NAVYamlParserHasMoreTokens(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor]
    return true
}


/**
 * @function NAVYamlParserAdvance
 * @private
 * @description Advance the parser cursor to the next token.
 *
 * @param {_NAVYamlParser} parser - The parser structure
 *
 * @returns {void}
 */
define_function NAVYamlParserAdvance(_NAVYamlParser parser) {
    parser.cursor++
}


/**
 * @function NAVYamlParserCanPeek
 * @private
 * @description Check if the parser can peek at the next token.
 *
 * @param {_NAVYamlParser} parser - The parser to check
 *
 * @returns {char} True if peek is possible
 */
define_function char NAVYamlParserCanPeek(_NAVYamlParser parser) {
    return parser.cursor < parser.tokenCount
}


/**
 * @function NAVYamlParserPeek
 * @private
 * @description Peek at the next token without consuming it.
 *
 * @param {_NAVYamlParser} parser - The parser structure
 * @param {_NAVYamlToken} token - Output parameter to receive the next token
 *
 * @returns {char} True if peek succeeded
 */
define_function char NAVYamlParserPeek(_NAVYamlParser parser, _NAVYamlToken token) {
    if (!NAVYamlParserCanPeek(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor + 1]
    return true
}


/**
 * @function NAVYamlAllocateNode
 * @private
 * @description Allocate a new node from the node pool.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 *
 * @returns {integer} Index of the allocated node (1-based), or 0 if pool exhausted
 */
define_function integer NAVYamlAllocateNode(_NAVYaml yaml) {
    if (yaml.nodeCount >= NAV_YAML_PARSER_MAX_NODES) {
        yaml.error = "'Node pool exhausted (max: ', itoa(NAV_YAML_PARSER_MAX_NODES), ')'"
        return 0
    }

    yaml.nodeCount++
    return yaml.nodeCount
}


/**
 * @function NAVYamlParserLinkChild
 * @private
 * @description Link a child node to its parent.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} parentIndex - Index of the parent node
 * @param {integer} childIndex - Index of the child node to link
 *
 * @returns {void}
 */
define_function NAVYamlParserLinkChild(_NAVYaml yaml, integer parentIndex, integer childIndex) {
    stack_var integer lastSibling

    if (parentIndex == 0) {
        return
    }

    yaml.nodes[childIndex].parent = parentIndex
    yaml.nodes[parentIndex].childCount++

    // If parent has no children yet, this becomes the first child
    if (yaml.nodes[parentIndex].firstChild == 0) {
        yaml.nodes[parentIndex].firstChild = childIndex
        return
    }

    // Otherwise, append to the end of the sibling chain
    lastSibling = yaml.nodes[parentIndex].firstChild

    while (yaml.nodes[lastSibling].nextSibling != 0) {
        lastSibling = yaml.nodes[lastSibling].nextSibling
    }

    yaml.nodes[lastSibling].nextSibling = childIndex
}


/**
 * @function NAVYamlParserSetError
 * @private
 * @description Set an error message with location information from a token.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {_NAVYamlToken} token - The token where the error occurred
 * @param {char[]} message - The error message
 *
 * @returns {void}
 */
define_function NAVYamlParserSetError(_NAVYaml yaml, _NAVYamlToken token, char message[]) {
    yaml.error = message
    yaml.errorLine = token.line
    yaml.errorColumn = token.column
}


/**
 * @function NAVYamlParserParseHexDigit
 * @private
 * @description Convert a hexadecimal character to its numeric value.
 *
 * @param {char} ch - The hex character ('0'-'9', 'A'-'F', 'a'-'f')
 *
 * @returns {sinteger} The numeric value (0-15), or -1 if invalid
 */
define_function sinteger NAVYamlParserParseHexDigit(char ch) {
    select {
        active (NAVIsDigit(ch)): {
            return ch - '0'
        }
        active (ch >= 'A' && ch <= 'F'): {
            return ch - 'A' + 10
        }
        active (ch >= 'a' && ch <= 'f'): {
            return ch - 'a' + 10
        }
    }

    return -1
}


/**
 * @function NAVYamlParserParseUnicodeEscape
 * @private
 * @description Parse a Unicode escape sequence (\u#### or \U########) and convert to UTF-8.
 *
 * @param {char[]} value - The string containing the escape sequence
 * @param {integer} index - Current position (should be at 'u' or 'U')
 * @param {integer} digitCount - Number of hex digits to parse (4 or 8)
 *
 * @returns {char[10]} The UTF-8 encoded bytes, or empty string if invalid
 */
define_function char[10] NAVYamlParserParseUnicodeEscape(char value[], integer index, integer digitCount) {
    stack_var long codePoint
    stack_var integer i
    stack_var sinteger digit
    stack_var char result[10]

    codePoint = 0
    result = ''

    // Parse hex digits
    for (i = 1; i <= digitCount; i++) {
        if (index + i > length_array(value)) {
            return ''  // Not enough digits
        }

        digit = NAVYamlParserParseHexDigit(value[index + i])
        if (digit < 0) {
            return ''  // Invalid hex digit
        }

        codePoint = (codePoint * 16) + type_cast(digit)
    }

    // Convert Unicode code point to UTF-8
    if (codePoint <= $7F) {
        // 1-byte UTF-8: 0xxxxxxx
        result = "codePoint"
    }
    else if (codePoint <= $7FF) {
        // 2-byte UTF-8: 110xxxxx 10xxxxxx
        result = "($C0 | (codePoint >> 6)), ($80 | (codePoint & $3F))"
    }
    else if (codePoint <= $FFFF) {
        // 3-byte UTF-8: 1110xxxx 10xxxxxx 10xxxxxx
        result = "($E0 | (codePoint >> 12)), ($80 | ((codePoint >> 6) & $3F)), ($80 | (codePoint & $3F))"
    }
    else if (codePoint <= $10FFFF) {
        // 4-byte UTF-8: 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
        result = "($F0 | (codePoint >> 18)), ($80 | ((codePoint >> 12) & $3F)), ($80 | ((codePoint >> 6) & $3F)), ($80 | (codePoint & $3F))"
    }

    return result
}


/**
 * @function NAVYamlParserUnescapeString
 * @private
 * @description Unescape a YAML string by processing escape sequences.
 *
 * @param {char[]} value - The string token value (including quotes if present)
 *
 * @returns {char[NAV_YAML_PARSER_MAX_VALUE_LENGTH]} The unescaped string
 */
define_function char[NAV_YAML_PARSER_MAX_VALUE_LENGTH] NAVYamlParserUnescapeString(char value[]) {
    stack_var integer i
    stack_var integer length
    stack_var char result[NAV_YAML_PARSER_MAX_VALUE_LENGTH]
    stack_var char ch
    stack_var char quote

    length = length_array(value)
    result = ''

    // Check if string is quoted
    if (length >= 2) {
        quote = value[1]
        if ((quote == '"' || quote == $27) && value[length] == quote) {
            // Remove surrounding quotes
            value = NAVStringSlice(value, 2, length)
            length = length_array(value)
        }
    }

    i = 1

    while (i <= length) {
        ch = value[i]

        if (ch == $5C) {  // Backslash
            i++
            if (i > length) {
                break
            }

            ch = value[i]

            switch (ch) {
                case '0':  { result = "result, $00" }  // Null
                case 'a':  { result = "result, $07" }  // Bell
                case 'b':  { result = "result, $08" }  // Backspace
                case 't':  { result = "result, $09" }  // Tab
                case 'n':  { result = "result, $0A" }  // Line feed
                case 'v':  { result = "result, $0B" }  // Vertical tab
                case 'f':  { result = "result, $0C" }  // Form feed
                case 'r':  { result = "result, $0D" }  // Carriage return
                case 'e':  { result = "result, $1B" }  // Escape
                case ' ':  { result = "result, ' '" }  // Space
                case '"':  { result = "result, '"'" }  // Double quote
                case $27:  { result = "result, $27" }  // Single quote
                case $5C:  { result = "result, $5C" }  // Backslash
                case '/':  { result = "result, '/'" }  // Forward slash

                // Hex escape sequences
                case 'x': {
                    // \x## - 8-bit hex (2 hex digits)
                    stack_var sinteger digit1
                    stack_var sinteger digit2
                    stack_var char hexByte

                    if (i + 2 <= length) {
                        digit1 = NAVYamlParserParseHexDigit(value[i + 1])
                        digit2 = NAVYamlParserParseHexDigit(value[i + 2])

                        if (digit1 >= 0 && digit2 >= 0) {
                            hexByte = type_cast(digit1 * 16) + type_cast(digit2)
                            result = "result, hexByte"
                            i = i + 2  // Skip the 2 hex digits
                        }
                        else {
                            // Invalid hex escape, keep literal
                            result = "result, ch"
                        }
                    }
                    else {
                        // Not enough characters, keep literal
                        result = "result, ch"
                    }
                }

                // Unicode escape sequences
                case 'u': {
                    // \u#### - 16-bit Unicode (4 hex digits)
                    stack_var char utf8[10]

                    utf8 = NAVYamlParserParseUnicodeEscape(value, i, 4)

                    if (length_array(utf8) > 0) {
                        result = "result, utf8"
                        i = i + 4  // Skip the 4 hex digits
                    }
                    else {
                        // Invalid Unicode escape, keep literal
                        result = "result, ch"
                    }
                }
                case 'U': {
                    // \U######## - 32-bit Unicode (8 hex digits)
                    stack_var char utf8[10]

                    utf8 = NAVYamlParserParseUnicodeEscape(value, i, 8)

                    if (length_array(utf8) > 0) {
                        result = "result, utf8"
                        i = i + 8  // Skip the 8 hex digits
                    }
                    else {
                        // Invalid Unicode escape, keep literal
                        result = "result, ch"
                    }
                }

                // Specialized whitespace escapes
                case '_': {
                    // Non-breaking space (U+00A0)
                    result = "result, $C2, $A0"
                }
                case 'N': {
                    // Next line (U+0085)
                    result = "result, $C2, $85"
                }
                case 'L': {
                    // Line separator (U+2028)
                    result = "result, $E2, $80, $A8"
                }
                case 'P': {
                    // Paragraph separator (U+2029)
                    result = "result, $E2, $80, $A9"
                }

                default: {
                    result = "result, ch"
                }
            }
        }
        else if (quote == $27 && ch == $27) {  // Single quote escape: ''
            i++
            if (i <= length && value[i] == $27) {
                result = "result, $27"
            }
            else {
                result = "result, $27"
                i--
            }
        }
        else {
            result = "result, ch"
        }

        i++
    }

    return result
}


/**
 * @function NAVYamlParserMergeProperties
 * @private
 * @description Merge properties from source mapping into target mapping.
 *              Implements merge key (<<) semantics where existing properties
 *              in the target are NOT overwritten (local keys win).
 *
 * @param {_NAVYamlParser} parser - The parser instance
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} targetIndex - Index of target mapping node
 * @param {integer} sourceIndex - Index of source mapping/alias node
 *
 * @returns {char} True (1) if merge succeeded, False (0) if failed
 */
define_function char NAVYamlParserMergeProperties(_NAVYamlParser parser, _NAVYaml yaml, integer targetIndex, integer sourceIndex) {
    stack_var integer sourceChild
    stack_var integer targetChild
    stack_var char sourceKey[NAV_YAML_PARSER_MAX_KEY_LENGTH]
    stack_var char keyExists
    stack_var integer newChildIndex

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ MergeProperties ]: target=', itoa(targetIndex), ' source=', itoa(sourceIndex)")
    #END_IF

    // Validate that source is a mapping
    if (yaml.nodes[sourceIndex].type != NAV_YAML_VALUE_TYPE_MAPPING) {
        #IF_DEFINED YAML_PARSER_DEBUG
        NAVLog("'[ MergeProperties ]: Source is not a mapping, type=', itoa(yaml.nodes[sourceIndex].type)")
        #END_IF
        return false
    }

    // Iterate through all children of source mapping
    sourceChild = yaml.nodes[sourceIndex].firstChild
    while (sourceChild > 0) {
        sourceKey = yaml.nodes[sourceChild].key

        #IF_DEFINED YAML_PARSER_DEBUG
        NAVLog("'[ MergeProperties ]: Checking source key: ', sourceKey")
        #END_IF

        // Check if this key already exists in target
        keyExists = false
        targetChild = yaml.nodes[targetIndex].firstChild
        while (targetChild > 0) {
            if (yaml.nodes[targetChild].key == sourceKey) {
                keyExists = true
                #IF_DEFINED YAML_PARSER_DEBUG
                NAVLog("'[ MergeProperties ]: Key ', sourceKey, ' already exists in target, skipping'")
                #END_IF
                break
            }

            targetChild = yaml.nodes[targetChild].nextSibling
        }

        // If key doesn't exist in target, copy it
        if (!keyExists) {
            newChildIndex = NAVYamlParserCopyNode(parser, yaml, sourceChild, targetIndex, sourceKey)
            if (newChildIndex == 0) {
                return false
            }

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ MergeProperties ]: Copied key ', sourceKey, ' to target as node ', itoa(newChildIndex)")
            #END_IF
        }

        sourceChild = yaml.nodes[sourceChild].nextSibling
    }

    return true
}


/**
 * @function NAVYamlParserValidatePlainScalar
 * @private
 * @description Validate that a plain scalar does not contain structural
 *              characters in positions that would make it ambiguous.
 *
 * @param {char[]} value - The plain scalar value to validate
 *
 * @returns {char} true if valid, false if invalid
 */
define_function char NAVYamlParserValidatePlainScalar(char value[]) {
    stack_var integer i
    stack_var integer length
    stack_var char ch

    length = length_array(value)

    if (length == 0) {
        return true
    }

    // Check for dash at start not followed by whitespace, digit, or dot
    // This makes it ambiguous with sequence indicator
    // Allow: negative numbers (-123), special floats (-.inf), proper sequences (- item)
    if (value[1] == '-' && length > 1) {
        ch = value[2]
        // If not a digit, not a space/tab, and not a dot, it's invalid
        if (!NAVIsDigit(ch) && ch != ' ' && ch != NAV_TAB && ch != '.') {
            return false
        }
    }

    // Check for ambiguous colon usage that could be confused with mapping syntax.
    // Only reject if colon appears in "key position" (first ~20 chars) without
    // proper spacing, which suggests user intended "key:value" but forgot the space.
    // This allows URLs like "http://example.com" while catching "name:value".
    for (i = 1; i <= length && i <= 20; i++) {
        if (value[i] == ':') {
            ch = value[i + 1]
            // Colon must be followed by space, tab, end, or path separator
            if (ch != 0 && ch != ' ' && ch != NAV_TAB && ch != '/') {
                return false
            }
        }
    }

    return true
}


/**
 * @function NAVYamlParserInferType
 * @private
 * @description Infer the type of a plain scalar value.
 *
 * @param {char[]} value - The scalar value
 *
 * @returns {integer} The inferred type (NAV_YAML_VALUE_TYPE_*\)
 */
define_function integer NAVYamlParserInferType(char value[]) {
    stack_var char lower[NAV_YAML_PARSER_MAX_VALUE_LENGTH]
    stack_var integer i
    stack_var char ch
    stack_var char hasDigit
    stack_var char hasDot
    stack_var char hasSign

    lower = lower_string(value)

    // Check for null
    if (lower == 'null' || lower == '~' || length_array(value) == 0) {
        return NAV_YAML_VALUE_TYPE_NULL
    }

    // Check for boolean
    if (lower == 'true' || lower == 'false' ||
        lower == 'yes' || lower == 'no' ||
        lower == 'on' || lower == 'off') {
        return NAV_YAML_VALUE_TYPE_BOOLEAN
    }

    // Check for number (simple numeric validation)
    hasDigit = false
    hasDot = false
    hasSign = false

    for (i = 1; i <= length_array(value); i++) {
        ch = value[i]

        if (ch >= '0' && ch <= '9') {
            hasDigit = true
        }
        else if (ch == '.' && !hasDot) {
            hasDot = true
        }
        else if ((ch == '+' || ch == '-') && i == 1 && !hasSign) {
            hasSign = true
        }
        else if (ch != ' ') {
            // Invalid character for number
            return NAV_YAML_VALUE_TYPE_STRING
        }
    }

    if (hasDigit) {
        return NAV_YAML_VALUE_TYPE_NUMBER
    }

    // Default to string
    return NAV_YAML_VALUE_TYPE_STRING
}


// =============================================================================
// PARSING FUNCTIONS
// =============================================================================

/**
 * @function NAVYamlParserParseScalar
 * @private
 * @description Parse a scalar value token into a node.
 *
 * @param {_NAVYamlParser} parser - The parser instance
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for sequence items)
 * @param {integer} tokenType - The type of token being parsed
 *
 * @returns {integer} Index of created node, or 0 on error
 */
define_function integer NAVYamlParserParseScalar(_NAVYamlParser parser, _NAVYaml yaml, integer parentIndex, char key[], integer tokenType) {
    stack_var integer nodeIndex
    stack_var _NAVYamlToken token
    stack_var integer valueType
    stack_var char value[NAV_YAML_PARSER_MAX_VALUE_LENGTH]

    if (!NAVYamlParserCurrentToken(parser, token)) {
        yaml.error = 'Unexpected end of tokens while parsing scalar'
        return 0
    }

    // Allocate node
    nodeIndex = NAVYamlAllocateNode(yaml)
    if (nodeIndex == 0) {
        return 0
    }

    // Determine value and type based on token type
    switch (tokenType) {
        case NAV_YAML_TOKEN_TYPE_STRING: {
            value = NAVYamlParserUnescapeString(token.value)
            valueType = NAV_YAML_VALUE_TYPE_STRING
        }
        case NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR: {
            value = token.value

            // Validate plain scalar doesn't contain structural characters
            // in ambiguous positions
            if (!NAVYamlParserValidatePlainScalar(value)) {
                NAVYamlParserSetError(yaml, token, "'Invalid plain scalar: contains structural character without proper spacing'")
                return 0
            }

            valueType = NAVYamlParserInferType(value)
        }
        case NAV_YAML_TOKEN_TYPE_NULL: {
            value = ''
            valueType = NAV_YAML_VALUE_TYPE_NULL
        }
        case NAV_YAML_TOKEN_TYPE_TRUE:
        case NAV_YAML_TOKEN_TYPE_FALSE: {
            value = token.value
            valueType = NAV_YAML_VALUE_TYPE_BOOLEAN
        }
        default: {
            value = token.value
            valueType = NAV_YAML_VALUE_TYPE_STRING
        }
    }

    yaml.nodes[nodeIndex].type = valueType
    yaml.nodes[nodeIndex].key = key
    yaml.nodes[nodeIndex].value = value

    NAVYamlParserLinkChild(yaml, parentIndex, nodeIndex)
    NAVYamlParserAdvance(parser)

    return nodeIndex
}


/**
 * @function NAVYamlParserSkipWhitespace
 * @private
 * @description Skip newlines, indents, and dedents.
 *
 * @param {_NAVYamlParser} parser - The parser instance
 *
 * @returns {void}
 */
define_function NAVYamlParserSkipWhitespace(_NAVYamlParser parser) {
    stack_var _NAVYamlToken token
    stack_var integer skippedCount

    skippedCount = 0
    while (NAVYamlParserCurrentToken(parser, token)) {
        // Skip whitespace and comments, but NOT DEDENT (it's a structural token)
        if (token.type != NAV_YAML_TOKEN_TYPE_NEWLINE &&
            token.type != NAV_YAML_TOKEN_TYPE_INDENT &&
            token.type != NAV_YAML_TOKEN_TYPE_COMMENT) {
            #IF_DEFINED YAML_PARSER_DEBUG
            if (skippedCount > 0) {
                NAVLog("'[ SkipWhitespace ]: Skipped ', itoa(skippedCount), ' tokens'")
            }
            #END_IF

            return
        }

        #IF_DEFINED YAML_PARSER_DEBUG
        NAVLog("'[ SkipWhitespace ]: Skipping token=', NAVYamlGetTokenTypeName(token.type), ' cursor=', itoa(parser.cursor)")
        #END_IF

        NAVYamlParserAdvance(parser)
        skippedCount++
    }
}


/**
 * @function NAVYamlParserParseFlowSequence
 * @private
 * @description Parse a flow sequence [item1, item2, ...].
 *
 * @param {_NAVYamlParser} parser - The parser instance
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for sequence items)
 *
 * @returns {integer} Index of created sequence node, or 0 on error
 */
define_function integer NAVYamlParserParseFlowSequence(_NAVYamlParser parser, _NAVYaml yaml, integer parentIndex, char key[]) {
    stack_var integer sequenceIndex
    stack_var _NAVYamlToken token
    stack_var integer childIndex

    // Check depth limit
    parser.depth++
    if (parser.depth > NAV_YAML_PARSER_MAX_DEPTH) {
        parser.depth--
        yaml.error = "'Maximum nesting depth exceeded (', itoa(NAV_YAML_PARSER_MAX_DEPTH), ')'"
        return 0
    }

    // Consume '['
    NAVYamlParserAdvance(parser)

    // Allocate sequence node
    sequenceIndex = NAVYamlAllocateNode(yaml)
    if (sequenceIndex == 0) {
        parser.depth--
        return 0
    }

    yaml.nodes[sequenceIndex].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    yaml.nodes[sequenceIndex].key = key

    NAVYamlParserLinkChild(yaml, parentIndex, sequenceIndex)

    NAVYamlParserSkipWhitespace(parser)

    // Check for empty sequence
    if (NAVYamlParserCurrentToken(parser, token)) {
        if (token.type == NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET) {
            NAVYamlParserAdvance(parser)
            parser.depth--
            return sequenceIndex
        }
    }

    // Parse sequence elements
    while (true) {
        childIndex = NAVYamlParserParseValue(parser, yaml, sequenceIndex, '')
        if (childIndex == 0) {
            parser.depth--
            return 0
        }

        NAVYamlParserSkipWhitespace(parser)

        if (!NAVYamlParserCurrentToken(parser, token)) {
            yaml.error = 'Unexpected end of tokens in flow sequence'
            parser.depth--
            return 0
        }

        if (token.type == NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET) {
            NAVYamlParserAdvance(parser)
            break
        }

        if (token.type == NAV_YAML_TOKEN_TYPE_COMMA) {
            NAVYamlParserAdvance(parser)
            NAVYamlParserSkipWhitespace(parser)
            continue
        }

        NAVYamlParserSetError(yaml, token, "'Expected "," or "]", got ', token.value")
        parser.depth--
        return 0
    }

    parser.depth--
    return sequenceIndex
}


/**
 * @function NAVYamlParserParseFlowMapping
 * @private
 * @description Parse a flow mapping {key1: value1, key2: value2, ...}.
 *
 * @param {_NAVYamlParser} parser - The parser instance
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for sequence items)
 *
 * @returns {integer} Index of created mapping node, or 0 on error
 */
define_function integer NAVYamlParserParseFlowMapping(_NAVYamlParser parser, _NAVYaml yaml, integer parentIndex, char key[]) {
    stack_var integer mappingIndex
    stack_var _NAVYamlToken token
    stack_var char propertyKey[NAV_YAML_PARSER_MAX_KEY_LENGTH]
    stack_var integer childIndex

    // Check depth limit
    parser.depth++
    if (parser.depth > NAV_YAML_PARSER_MAX_DEPTH) {
        parser.depth--
        yaml.error = "'Maximum nesting depth exceeded (', itoa(NAV_YAML_PARSER_MAX_DEPTH), ')'"
        return 0
    }

    // Consume '{'
    NAVYamlParserAdvance(parser)

    // Allocate mapping node
    mappingIndex = NAVYamlAllocateNode(yaml)
    if (mappingIndex == 0) {
        parser.depth--
        return 0
    }

    yaml.nodes[mappingIndex].type = NAV_YAML_VALUE_TYPE_MAPPING
    yaml.nodes[mappingIndex].key = key

    NAVYamlParserLinkChild(yaml, parentIndex, mappingIndex)

    NAVYamlParserSkipWhitespace(parser)

    // Check for empty mapping
    if (NAVYamlParserCurrentToken(parser, token)) {
        if (token.type == NAV_YAML_TOKEN_TYPE_RIGHT_BRACE) {
            NAVYamlParserAdvance(parser)
            parser.depth--
            return mappingIndex
        }
    }

    // Parse mapping entries
    while (true) {
        NAVYamlParserSkipWhitespace(parser)

        // Get key
        if (!NAVYamlParserCurrentToken(parser, token)) {
            yaml.error = 'Unexpected end of tokens in flow mapping'
            parser.depth--
            return 0
        }

        if (token.type == NAV_YAML_TOKEN_TYPE_KEY) {
            NAVYamlParserAdvance(parser)
            NAVYamlParserSkipWhitespace(parser)
            if (!NAVYamlParserCurrentToken(parser, token)) {
                yaml.error = 'Expected key after "?" marker'
                parser.depth--
                return 0
            }
        }

        if (token.type == NAV_YAML_TOKEN_TYPE_STRING ||
            token.type == NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR) {
            propertyKey = token.value
            NAVYamlParserAdvance(parser)
        }
        else {
            NAVYamlParserSetError(yaml, token, "'Expected mapping key, got ', token.value")
            parser.depth--
            return 0
        }

        NAVYamlParserSkipWhitespace(parser)

        // Expect colon
        if (!NAVYamlParserCurrentToken(parser, token)) {
            yaml.error = 'Expected ":" after mapping key'
            parser.depth--
            return 0
        }

        if (token.type != NAV_YAML_TOKEN_TYPE_COLON) {
            NAVYamlParserSetError(yaml, token, "'Expected ":", got ', token.value")
            parser.depth--
            return 0
        }

        NAVYamlParserAdvance(parser)
        NAVYamlParserSkipWhitespace(parser)

        // Parse value
        childIndex = NAVYamlParserParseValue(parser, yaml, mappingIndex, propertyKey)
        if (childIndex == 0) {
            parser.depth--
            return 0
        }

        NAVYamlParserSkipWhitespace(parser)

        if (!NAVYamlParserCurrentToken(parser, token)) {
            yaml.error = 'Unexpected end of tokens in flow mapping'
            parser.depth--
            return 0
        }

        if (token.type == NAV_YAML_TOKEN_TYPE_RIGHT_BRACE) {
            NAVYamlParserAdvance(parser)
            break
        }

        if (token.type == NAV_YAML_TOKEN_TYPE_COMMA) {
            NAVYamlParserAdvance(parser)
            continue
        }

        NAVYamlParserSetError(yaml, token, "'Expected "," or "}", got ', token.value")
        parser.depth--
        return 0
    }

    parser.depth--
    return mappingIndex
}


/**
 * @function NAVYamlParserParseBlockSequence
 * @private
 * @description Parse a block sequence (items starting with -).
 *
 * @param {_NAVYamlParser} parser - The parser instance
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for sequence items)
 *
 * @returns {integer} Index of created sequence node, or 0 on error
 */
define_function integer NAVYamlParserParseBlockSequence(_NAVYamlParser parser, _NAVYaml yaml, integer parentIndex, char key[]) {
    stack_var integer sequenceIndex
    stack_var _NAVYamlToken token
    stack_var integer childIndex
    stack_var integer itemCount

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ ParseBlockSequence ]: depth=', itoa(parser.depth), ' parent=', itoa(parentIndex), ' key=', key")
    #END_IF

    // Check depth limit
    parser.depth++
    if (parser.depth > NAV_YAML_PARSER_MAX_DEPTH) {
        parser.depth--
        yaml.error = "'Maximum nesting depth exceeded (', itoa(NAV_YAML_PARSER_MAX_DEPTH), ')'"
        return 0
    }

    // Allocate sequence node
    sequenceIndex = NAVYamlAllocateNode(yaml)
    if (sequenceIndex == 0) {
        parser.depth--
        return 0
    }

    yaml.nodes[sequenceIndex].type = NAV_YAML_VALUE_TYPE_SEQUENCE
    yaml.nodes[sequenceIndex].key = key

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ ParseBlockSequence ]: Created node=', itoa(sequenceIndex), ' type=SEQUENCE'")
    #END_IF

    NAVYamlParserLinkChild(yaml, parentIndex, sequenceIndex)

    itemCount = 0

    // Parse sequence items
    while (NAVYamlParserCurrentToken(parser, token)) {
        #IF_DEFINED YAML_PARSER_DEBUG
        NAVLog("'[ ParseBlockSequence ]: Loop iteration cursor=', itoa(parser.cursor), ' token=', NAVYamlGetTokenTypeName(token.type), ' value=', token.value")
        #END_IF

        // Stop if we hit dedent or end tokens
        // DEDENT means we're returning to parent indentation level, so stop
        if (token.type == NAV_YAML_TOKEN_TYPE_DEDENT ||
            token.type == NAV_YAML_TOKEN_TYPE_DOCUMENT_END ||
            token.type == NAV_YAML_TOKEN_TYPE_EOF) {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseBlockSequence ]: Stopping (ended by ', NAVYamlGetTokenTypeName(token.type), '), items=', itoa(itemCount)")
            #END_IF

            break
        }

        // Stop if not a dash
        if (token.type != NAV_YAML_TOKEN_TYPE_DASH) {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseBlockSequence ]: Stopping (not DASH), items=', itoa(itemCount)")
            #END_IF

            break
        }

        itemCount++
        #IF_DEFINED YAML_PARSER_DEBUG
        NAVLog("'[ ParseBlockSequence ]: Parsing item=', itoa(itemCount)")
        #END_IF

        NAVYamlParserAdvance(parser)
        NAVYamlParserSkipWhitespace(parser)

        childIndex = NAVYamlParserParseValue(parser, yaml, sequenceIndex, '')
        if (childIndex == 0) {
            parser.depth--
            return 0
        }

        #IF_DEFINED YAML_PARSER_DEBUG
        NAVLog("'[ ParseBlockSequence ]: Item=', itoa(itemCount), ' created node=', itoa(childIndex)")
        #END_IF

        // If child stopped at DEDENT, skip it (child has returned to our level)
        if (NAVYamlParserCurrentToken(parser, token) && token.type == NAV_YAML_TOKEN_TYPE_DEDENT) {
            NAVYamlParserAdvance(parser)
        }

        NAVYamlParserSkipWhitespace(parser)
    }

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ ParseBlockSequence ]: Complete items=', itoa(itemCount), ' node=', itoa(sequenceIndex)")
    #END_IF

    parser.depth--
    return sequenceIndex
}


/**
 * @function NAVYamlParserParseBlockMapping
 * @private
 * @description Parse a block mapping (key: value pairs).
 *
 * @param {_NAVYamlParser} parser - The parser instance
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for sequence items)
 *
 * @returns {integer} Index of created mapping node, or 0 on error
 */
define_function integer NAVYamlParserParseBlockMapping(_NAVYamlParser parser, _NAVYaml yaml, integer parentIndex, char key[]) {
    stack_var integer mappingIndex
    stack_var _NAVYamlToken token
    stack_var char propertyKey[NAV_YAML_PARSER_MAX_KEY_LENGTH]
    stack_var integer childIndex
    stack_var integer keyCount

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ ParseBlockMapping ]: depth=', itoa(parser.depth), ' parent=', itoa(parentIndex), ' key=', key")
    #END_IF

    // Check depth limit
    parser.depth++
    if (parser.depth > NAV_YAML_PARSER_MAX_DEPTH) {
        parser.depth--
        yaml.error = "'Maximum nesting depth exceeded (', itoa(NAV_YAML_PARSER_MAX_DEPTH), ')'"
        return 0
    }

    // Allocate mapping node
    mappingIndex = NAVYamlAllocateNode(yaml)
    if (mappingIndex == 0) {
        parser.depth--
        return 0
    }

    yaml.nodes[mappingIndex].type = NAV_YAML_VALUE_TYPE_MAPPING
    yaml.nodes[mappingIndex].key = key

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ ParseBlockMapping ]: Created node=', itoa(mappingIndex), ' type=MAPPING'")
    #END_IF

    NAVYamlParserLinkChild(yaml, parentIndex, mappingIndex)

    keyCount = 0

    // Parse mapping entries
    while (NAVYamlParserCurrentToken(parser, token)) {
        #IF_DEFINED YAML_PARSER_DEBUG
        NAVLog("'[ ParseBlockMapping ]: Loop iteration cursor=', itoa(parser.cursor), ' token=', NAVYamlGetTokenTypeName(token.type), ' value=', token.value")
        #END_IF

        // Stop if we hit dedent or end tokens
        // DEDENT means we're returning to parent indentation level, so stop
        if (token.type == NAV_YAML_TOKEN_TYPE_DEDENT ||
            token.type == NAV_YAML_TOKEN_TYPE_DOCUMENT_END ||
            token.type == NAV_YAML_TOKEN_TYPE_EOF) {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseBlockMapping ]: Stopping (ended by ', NAVYamlGetTokenTypeName(token.type), '), keys=', itoa(keyCount)")
            #END_IF

            break
        }

        // Skip structural tokens
        if (token.type == NAV_YAML_TOKEN_TYPE_NEWLINE ||
            token.type == NAV_YAML_TOKEN_TYPE_COMMENT) {
            NAVYamlParserAdvance(parser)
            continue
        }

        // Stop if we hit a dash (sequence marker at same level)
        if (token.type == NAV_YAML_TOKEN_TYPE_DASH) {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseBlockMapping ]: Stopping (DASH), keys=', itoa(keyCount)")
            #END_IF

            break
        }

        // Handle explicit key marker
        if (token.type == NAV_YAML_TOKEN_TYPE_KEY) {
            stack_var char complexKeyStr[NAV_YAML_PARSER_MAX_KEY_LENGTH]
            stack_var integer bracketDepth
            stack_var char openChar

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseBlockMapping ]: Detected explicit key marker (?)'")
            #END_IF

            NAVYamlParserAdvance(parser)
            NAVYamlParserSkipWhitespace(parser)

            if (!NAVYamlParserCurrentToken(parser, token)) {
                yaml.error = 'Expected key after "?" marker'
                parser.depth--
                return 0
            }

            // Check if this is a complex key (flow sequence or mapping)
            if (token.type == NAV_YAML_TOKEN_TYPE_LEFT_BRACKET ||
                token.type == NAV_YAML_TOKEN_TYPE_LEFT_BRACE) {

                #IF_DEFINED YAML_PARSER_DEBUG
                NAVLog("'[ ParseBlockMapping ]: Complex explicit key detected'")
                #END_IF

                // Parse the complex key as a temporary value
                // Store its string representation
                // For sequences: [a, b] -> "[a, b]"
                // For mappings: {k: v} -> "{k: v}"

                // Simple approach: concatenate token values until closing bracket/brace
                complexKeyStr = ''
                bracketDepth = 0
                openChar = token.value[1]

                complexKeyStr = "complexKeyStr, token.value"
                NAVYamlParserAdvance(parser)

                if (openChar == '[') { bracketDepth++ }
                else if (openChar == '{') { bracketDepth++ }

                // Consume tokens until we close the complex key
                while (NAVYamlParserCurrentToken(parser, token) && bracketDepth > 0) {
                    if (token.type == NAV_YAML_TOKEN_TYPE_LEFT_BRACKET ||
                        token.type == NAV_YAML_TOKEN_TYPE_LEFT_BRACE) {
                        bracketDepth++
                    }
                    else if (token.type == NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET ||
                             token.type == NAV_YAML_TOKEN_TYPE_RIGHT_BRACE) {
                        bracketDepth--
                    }

                    // Append token value with appropriate spacing
                    if (token.type == NAV_YAML_TOKEN_TYPE_COMMA) {
                        complexKeyStr = "complexKeyStr, ', '"
                    }
                    else if (token.type == NAV_YAML_TOKEN_TYPE_COLON) {
                        complexKeyStr = "complexKeyStr, ': '"
                    }
                    else if (length_array(complexKeyStr) > 0 &&
                             token.type != NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET &&
                             token.type != NAV_YAML_TOKEN_TYPE_RIGHT_BRACE) {
                        complexKeyStr = "complexKeyStr, ' ', token.value"
                    }
                    else {
                        complexKeyStr = "complexKeyStr, token.value"
                    }

                    NAVYamlParserAdvance(parser)
                }

                propertyKey = complexKeyStr
                keyCount++

                #IF_DEFINED YAML_PARSER_DEBUG
                NAVLog("'[ ParseBlockMapping ]: Complex key=', propertyKey")
                #END_IF

                // Skip any whitespace/newlines before colon
                NAVYamlParserSkipWhitespace(parser)

                // Now expect the value marker (:)
                if (!NAVYamlParserCurrentToken(parser, token)) {
                    yaml.error = 'Expected ":" after complex key'
                    parser.depth--
                    return 0
                }

                if (token.type != NAV_YAML_TOKEN_TYPE_COLON) {
                    yaml.error = 'Expected ":" after complex key'
                    parser.depth--
                    return 0
                }

                NAVYamlParserAdvance(parser)
                NAVYamlParserSkipWhitespace(parser)

                // Parse the value
                childIndex = NAVYamlParserParseValue(parser, yaml, mappingIndex, propertyKey)
                if (childIndex == 0) {
                    parser.depth--
                    return 0
                }

                #IF_DEFINED YAML_PARSER_DEBUG
                NAVLog("'[ ParseBlockMapping ]: Complex key=', propertyKey, ' value node=', itoa(childIndex)")
                #END_IF

                // Continue to next iteration
                continue
            }

            // Otherwise, it's a simple explicit key - use the token we already have
            if (token.type == NAV_YAML_TOKEN_TYPE_STRING ||
                token.type == NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR) {
                propertyKey = token.value
                keyCount++

                #IF_DEFINED YAML_PARSER_DEBUG
                NAVLog("'[ ParseBlockMapping ]: Simple explicit key=', propertyKey")
                #END_IF

                NAVYamlParserAdvance(parser)
                NAVYamlParserSkipWhitespace(parser)

                // Expect colon
                if (!NAVYamlParserCurrentToken(parser, token)) {
                    yaml.error = 'Expected ":" after explicit key'
                    parser.depth--
                    return 0
                }

                if (token.type != NAV_YAML_TOKEN_TYPE_COLON) {
                    yaml.error = 'Expected ":" after explicit key'
                    parser.depth--
                    return 0
                }
            }
            // Handle empty explicit key (? immediately followed by :)
            else if (token.type == NAV_YAML_TOKEN_TYPE_COLON) {
                propertyKey = ''
                keyCount++

                #IF_DEFINED YAML_PARSER_DEBUG
                NAVLog("'[ ParseBlockMapping ]: Empty explicit key'")
                #END_IF
                // Don't advance yet - COLON handling code below will do it
            }
            else {
                yaml.error = 'Expected key after "?" marker'
                parser.depth--
                return 0
            }

            // Advance past colon and parse value (shared for all explicit key types)
            NAVYamlParserAdvance(parser)
            NAVYamlParserSkipWhitespace(parser)

            // Parse value
            childIndex = NAVYamlParserParseValue(parser, yaml, mappingIndex, propertyKey)
            if (childIndex == 0) {
                parser.depth--
                return 0
            }

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseBlockMapping ]: Explicit key=', propertyKey, ' value node=', itoa(childIndex)")
            #END_IF

            // Skip DEDENT if present
            if (NAVYamlParserCurrentToken(parser, token) && token.type == NAV_YAML_TOKEN_TYPE_DEDENT) {
                NAVYamlParserAdvance(parser)
            }

            NAVYamlParserSkipWhitespace(parser)
            continue
        }

        // Skip INDENT tokens
        if (token.type == NAV_YAML_TOKEN_TYPE_INDENT) {
            NAVYamlParserAdvance(parser)
            continue
        }

        // Get the key
        if (token.type == NAV_YAML_TOKEN_TYPE_STRING ||
            token.type == NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR) {
            propertyKey = token.value
            keyCount++
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseBlockMapping ]: Parsing key=', itoa(keyCount), ' name=', propertyKey")
            #END_IF

            NAVYamlParserAdvance(parser)
        }
        else {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseBlockMapping ]: Stopping (invalid key token=', NAVYamlGetTokenTypeName(token.type), ')'")
            #END_IF

            // Not a valid key, stop parsing this mapping
            break
        }

        NAVYamlParserSkipWhitespace(parser)

        // Check for merge key (<<)
        if (propertyKey == '<<') {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseBlockMapping ]: Detected merge key (<<)'")
            #END_IF

            // Expect colon
            if (!NAVYamlParserCurrentToken(parser, token)) {
                yaml.error = 'Expected ":" after merge key'
                parser.depth--
                return 0
            }

            if (token.type != NAV_YAML_TOKEN_TYPE_COLON) {
                NAVYamlParserSetError(yaml, token, "'Expected ":" after merge key, got ', token.value")
                parser.depth--
                return 0
            }

            NAVYamlParserAdvance(parser)
            NAVYamlParserSkipWhitespace(parser)

            // The value should be an alias (*anchor) or array of aliases ([*a, *b])
            if (!NAVYamlParserCurrentToken(parser, token)) {
                yaml.error = 'Expected alias after merge key'
                parser.depth--
                return 0
            }

            // Handle single alias merge OR array of aliases
            if (token.type == NAV_YAML_TOKEN_TYPE_ALIAS) {
                // Single merge: <<: *anchor
                stack_var integer aliasNodeIndex

                aliasNodeIndex = NAVYamlParserParseValue(parser, yaml, mappingIndex, '')
                if (aliasNodeIndex == 0) {
                    parser.depth--
                    return 0
                }

                // Now merge properties from aliasNodeIndex into mappingIndex
                if (!NAVYamlParserMergeProperties(parser, yaml, mappingIndex, aliasNodeIndex)) {
                    yaml.error = 'Failed to merge properties (merge key requires mapping)'
                    parser.depth--
                    return 0
                }

                #IF_DEFINED YAML_PARSER_DEBUG
                NAVLog("'[ ParseBlockMapping ]: Merged single alias into node=', itoa(mappingIndex)")
                #END_IF
            }
            else if (token.type == NAV_YAML_TOKEN_TYPE_LEFT_BRACKET) {
                // Array merge: <<: [*a, *b, *c]
                stack_var integer mergeSequenceIndex
                stack_var integer mergeItemIndex
                stack_var integer i

                mergeSequenceIndex = NAVYamlParserParseValue(parser, yaml, parentIndex, '')
                if (mergeSequenceIndex == 0) {
                    parser.depth--
                    return 0
                }

                // Iterate through sequence items and merge each
                mergeItemIndex = yaml.nodes[mergeSequenceIndex].firstChild
                while (mergeItemIndex > 0) {
                    if (!NAVYamlParserMergeProperties(parser, yaml, mappingIndex, mergeItemIndex)) {
                        yaml.error = 'Failed to merge properties from array (requires mappings)'
                        parser.depth--
                        return 0
                    }

                    #IF_DEFINED YAML_PARSER_DEBUG
                    NAVLog("'[ ParseBlockMapping ]: Merged array item ', itoa(mergeItemIndex), ' into node=', itoa(mappingIndex)")
                    #END_IF

                    mergeItemIndex = yaml.nodes[mergeItemIndex].nextSibling
                }
            }
            else {
                NAVYamlParserSetError(yaml, token, "'Merge key must be followed by alias or array, got ', NAVYamlGetTokenTypeName(token.type)")
                parser.depth--
                return 0
            }

            // Skip DEDENT if present after merge
            if (NAVYamlParserCurrentToken(parser, token) && token.type == NAV_YAML_TOKEN_TYPE_DEDENT) {
                NAVYamlParserAdvance(parser)
            }

            NAVYamlParserSkipWhitespace(parser)
            continue
        }

        // Normal key-value pair (not a merge key)
        NAVYamlParserSkipWhitespace(parser)

        // Expect colon
        if (!NAVYamlParserCurrentToken(parser, token)) {
            yaml.error = 'Expected ":" after mapping key'
            parser.depth--
            return 0
        }

        if (token.type != NAV_YAML_TOKEN_TYPE_COLON) {
            NAVYamlParserSetError(yaml, token, "'Expected ":", got ', token.value")
            parser.depth--
            return 0
        }

        NAVYamlParserAdvance(parser)
        NAVYamlParserSkipWhitespace(parser)

        // Parse value
        childIndex = NAVYamlParserParseValue(parser, yaml, mappingIndex, propertyKey)
        if (childIndex == 0) {
            parser.depth--
            return 0
        }

        #IF_DEFINED YAML_PARSER_DEBUG
        NAVLog("'[ ParseBlockMapping ]: Key=', propertyKey, ' value node=', itoa(childIndex)")
        #END_IF

        // If child stopped at DEDENT, skip it (child has returned to our level)
        if (NAVYamlParserCurrentToken(parser, token) && token.type == NAV_YAML_TOKEN_TYPE_DEDENT) {
            NAVYamlParserAdvance(parser)
        }

        NAVYamlParserSkipWhitespace(parser)
    }

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ ParseBlockMapping ]: Complete keys=', itoa(keyCount), ' node=', itoa(mappingIndex)")
    #END_IF

    parser.depth--
    return mappingIndex
}


/**
 * @function NAVYamlParserParseValue
 * @private
 * @description Parse any YAML value (scalar, mapping, or sequence).
 *
 * @param {_NAVYamlParser} parser - The parser instance
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for sequence items)
 *
 * @returns {integer} Index of created node, or 0 on error
 */
define_function integer NAVYamlParserParseValue(_NAVYamlParser parser, _NAVYaml yaml, integer parentIndex, char key[]) {
    stack_var _NAVYamlToken token
    stack_var _NAVYamlToken nextToken

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ ParseValue ]: depth=', itoa(parser.depth), ' parent=', itoa(parentIndex), ' key=', key")
    #END_IF

    if (!NAVYamlParserCurrentToken(parser, token)) {
        yaml.error = 'Unexpected end of tokens while parsing value'
        return 0
    }

    #IF_DEFINED YAML_PARSER_DEBUG
    NAVLog("'[ ParseValue ]: cursor=', itoa(parser.cursor), ' token=', NAVYamlGetTokenTypeName(token.type), ' value=', token.value")
    #END_IF

    switch (token.type) {
        case NAV_YAML_TOKEN_TYPE_KEY: {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Detected explicit key (? marker)'")
            #END_IF

            return NAVYamlParserParseBlockMapping(parser, yaml, parentIndex, key)
        }
        case NAV_YAML_TOKEN_TYPE_LEFT_BRACKET: {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Detected flow sequence'")
            #END_IF

            return NAVYamlParserParseFlowSequence(parser, yaml, parentIndex, key)
        }
        case NAV_YAML_TOKEN_TYPE_LEFT_BRACE: {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Detected flow mapping'")
            #END_IF

            return NAVYamlParserParseFlowMapping(parser, yaml, parentIndex, key)
        }
        case NAV_YAML_TOKEN_TYPE_DASH: {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Detected block sequence'")
            #END_IF

            return NAVYamlParserParseBlockSequence(parser, yaml, parentIndex, key)
        }
        case NAV_YAML_TOKEN_TYPE_LITERAL:
        case NAV_YAML_TOKEN_TYPE_FOLDED: {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Detected block scalar'")
            #END_IF

            return NAVYamlParserParseBlockScalar(parser, yaml, parentIndex, key, token.type)
        }
        case NAV_YAML_TOKEN_TYPE_ANCHOR: {
            stack_var char anchorName[NAV_YAML_PARSER_MAX_ANCHOR_LENGTH]
            stack_var integer anchoredNodeIndex

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Detected anchor'")
            #END_IF

            // Skip the & token, next token should be the anchor name (as PLAIN_SCALAR)
            NAVYamlParserAdvance(parser)

            if (!NAVYamlParserCurrentToken(parser, token) || token.type != NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR) {
                yaml.error = 'Expected anchor name after &'
                return 0
            }

            anchorName = token.value
            NAVYamlParserAdvance(parser)

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Anchor name=', anchorName")
            #END_IF

            // Skip whitespace before the anchored value
            NAVYamlParserSkipWhitespace(parser)

            // Parse the actual value that gets anchored
            anchoredNodeIndex = NAVYamlParserParseValue(parser, yaml, parentIndex, key)
            if (anchoredNodeIndex == 0) {
                return 0
            }

            // Store anchor name in the node
            yaml.nodes[anchoredNodeIndex].anchor = anchorName

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Anchored node=', itoa(anchoredNodeIndex), ' as ', anchorName")
            #END_IF

            return anchoredNodeIndex
        }
        case NAV_YAML_TOKEN_TYPE_TAG: {
            stack_var char tagPrefix[NAV_YAML_PARSER_MAX_TAG_LENGTH]
            stack_var char tagName[NAV_YAML_PARSER_MAX_TAG_LENGTH]
            stack_var char fullTag[NAV_YAML_PARSER_MAX_TAG_LENGTH]
            stack_var integer taggedNodeIndex

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Detected tag'")
            #END_IF

            // Get the tag prefix (!, !!, or !<)
            tagPrefix = token.value
            NAVYamlParserAdvance(parser)

            // Get the tag name/URI (if present)
            if (NAVYamlParserCurrentToken(parser, token) && token.type == NAV_YAML_TOKEN_TYPE_TAG) {
                tagName = token.value
                NAVYamlParserAdvance(parser)
            }

            // Construct full tag string
            if (length_array(tagName) > 0) {
                fullTag = "tagPrefix, tagName"
            }
            else {
                fullTag = tagPrefix
            }

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Tag=', fullTag")
            #END_IF

            // Skip whitespace before the tagged value
            NAVYamlParserSkipWhitespace(parser)

            // Special case: !!null tag can stand alone without a value
            if (NAVYamlParserCurrentToken(parser, token)) {
                if (fullTag == '!!null' && (token.type == NAV_YAML_TOKEN_TYPE_NEWLINE ||
                                           token.type == NAV_YAML_TOKEN_TYPE_DEDENT ||
                                           token.type == NAV_YAML_TOKEN_TYPE_DOCUMENT_END ||
                                           token.type == NAV_YAML_TOKEN_TYPE_EOF ||
                                           token.type == NAV_YAML_TOKEN_TYPE_COMMA ||
                                           token.type == NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET ||
                                           token.type == NAV_YAML_TOKEN_TYPE_RIGHT_BRACE)) {
                    // Create implicit null scalar node
                    taggedNodeIndex = NAVYamlAllocateNode(yaml)
                    if (taggedNodeIndex == 0) {
                        return 0
                    }

                    yaml.nodes[taggedNodeIndex].type = NAV_YAML_VALUE_TYPE_NULL
                    yaml.nodes[taggedNodeIndex].key = key
                    yaml.nodes[taggedNodeIndex].value = ''
                    yaml.nodes[taggedNodeIndex].tag = fullTag

                    NAVYamlParserLinkChild(yaml, parentIndex, taggedNodeIndex)

                    #IF_DEFINED YAML_PARSER_DEBUG
                    NAVLog("'[ ParseValue ]: Created implicit null node with !!null tag'")
                    #END_IF

                    return taggedNodeIndex
                }
            }

            // Parse the actual value that gets tagged
            taggedNodeIndex = NAVYamlParserParseValue(parser, yaml, parentIndex, key)
            if (taggedNodeIndex == 0) {
                return 0
            }

            // Apply the tag to the node
            yaml.nodes[taggedNodeIndex].tag = fullTag

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Tagged node=', itoa(taggedNodeIndex), ' with ', fullTag")
            #END_IF

            return taggedNodeIndex
        }
        case NAV_YAML_TOKEN_TYPE_ALIAS: {
            stack_var char aliasName[NAV_YAML_PARSER_MAX_ANCHOR_LENGTH]
            stack_var integer referencedNodeIndex
            stack_var integer aliasNodeIndex

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Detected alias'")
            #END_IF

            // Skip the * token, next token should be the alias name (as PLAIN_SCALAR)
            NAVYamlParserAdvance(parser)

            if (!NAVYamlParserCurrentToken(parser, token) || token.type != NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR) {
                yaml.error = 'Expected alias name after *'
                return 0
            }

            aliasName = token.value
            NAVYamlParserAdvance(parser)

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Alias name=', aliasName")
            #END_IF

            // Find the referenced anchor
            referencedNodeIndex = NAVYamlFindAnchor(yaml, aliasName)
            if (referencedNodeIndex == 0) {
                yaml.error = "'Undefined anchor: ', aliasName"
                return 0
            }

            // Copy the referenced node (deep copy)
            aliasNodeIndex = NAVYamlParserCopyNode(parser, yaml, referencedNodeIndex, parentIndex, key)
            if (aliasNodeIndex == 0) {
                return 0
            }

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Alias resolved node=', itoa(aliasNodeIndex)")
            #END_IF

            return aliasNodeIndex
        }
        case NAV_YAML_TOKEN_TYPE_STRING:
        case NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR:
        case NAV_YAML_TOKEN_TYPE_NULL:
        case NAV_YAML_TOKEN_TYPE_TRUE:
        case NAV_YAML_TOKEN_TYPE_FALSE: {
            // Check if this is a key for a block mapping
            if (NAVYamlParserCanPeek(parser)) {
                NAVYamlParserPeek(parser, nextToken)
                if (nextToken.type == NAV_YAML_TOKEN_TYPE_COLON) {
                    #IF_DEFINED YAML_PARSER_DEBUG
                    NAVLog("'[ ParseValue ]: Detected block mapping (key followed by colon)'")
                    #END_IF

                    return NAVYamlParserParseBlockMapping(parser, yaml, parentIndex, key)
                }
            }

            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Parsing scalar'")
            #END_IF

            return NAVYamlParserParseScalar(parser, yaml, parentIndex, key, token.type)
        }
        case NAV_YAML_TOKEN_TYPE_INDENT: {
            #IF_DEFINED YAML_PARSER_DEBUG
            NAVLog("'[ ParseValue ]: Skipping INDENT and continuing'")
            #END_IF

            // Skip indent and continue parsing
            NAVYamlParserAdvance(parser)
            return NAVYamlParserParseValue(parser, yaml, parentIndex, key)
        }
        default: {
            NAVYamlParserSetError(yaml, token, "'Unexpected token: ', token.value")
            return 0
        }
    }
}


/**
 * Parse YAML tokens into a node tree.
 *
 * @param {_NAVYamlParser} parser - The parser with tokens
 * @param {_NAVYaml} yaml - Output YAML document structure
 * @return {char} True if parsing succeeded
 */
define_function char NAVYamlParserParse(_NAVYamlParser parser, _NAVYaml yaml) {
    stack_var _NAVYamlToken token

    yaml.nodeCount = 0
    yaml.rootIndex = 0
    yaml.error = ''
    yaml.errorLine = 0
    yaml.errorColumn = 0

    // Skip leading whitespace, directives, comments, and document markers
    while (NAVYamlParserCurrentToken(parser, token)) {
        if (token.type != NAV_YAML_TOKEN_TYPE_NEWLINE &&
            token.type != NAV_YAML_TOKEN_TYPE_COMMENT &&
            token.type != NAV_YAML_TOKEN_TYPE_DIRECTIVE &&
            token.type != NAV_YAML_TOKEN_TYPE_DOCUMENT_START) {
            break
        }

        NAVYamlParserAdvance(parser)
    }

    // Check if document is empty
    if (!NAVYamlParserCurrentToken(parser, token)) {
        yaml.error = 'Empty YAML document'
        return false
    }

    if (token.type == NAV_YAML_TOKEN_TYPE_EOF) {
        yaml.error = 'Empty YAML document'
        return false
    }

    // Parse the root value
    yaml.rootIndex = NAVYamlParserParseValue(parser, yaml, 0, '')
    if (yaml.rootIndex == 0) {
        return false
    }

    return true
}


/**
 * @function NAVYamlGetMaxDepth
 * @public
 * @description Calculate the maximum depth of the YAML tree.
 *              Root node is at depth 0.
 *
 * @param {_NAVYaml} yaml - The YAML document
 *
 * @returns {sinteger} The maximum depth, or -1 if empty/invalid
 *
 * @example
 * stack_var sinteger maxDepth
 * maxDepth = NAVYamlGetMaxDepth(yaml)
 * send_string 0, "'Maximum depth: ', itoa(maxDepth)"
 */
define_function sinteger NAVYamlGetMaxDepth(_NAVYaml yaml) {
    stack_var _NAVYamlNode root

    if (!NAVYamlGetRoot(yaml, root)) {
        return -1
    }

    return NAVYamlGetMaxDepthRecursive(yaml, root, 0)
}


/**
 * @function NAVYamlGetMaxDepthRecursive
 * @private
 * @description Recursively calculate maximum depth.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} node - Current node
 * @param {integer} currentDepth - Current depth level
 *
 * @returns {sinteger} Maximum depth from this node
 */
define_function sinteger NAVYamlGetMaxDepthRecursive(_NAVYaml yaml, _NAVYamlNode node, integer currentDepth) {
    stack_var _NAVYamlNode child
    stack_var sinteger maxDepth
    stack_var sinteger childDepth

    maxDepth = type_cast(currentDepth)

    if (node.childCount > 0) {
        if (NAVYamlGetFirstChild(yaml, node, child)) {
            while (true) {
                childDepth = NAVYamlGetMaxDepthRecursive(yaml, child, currentDepth + 1)

                if (childDepth > maxDepth) {
                    maxDepth = childDepth
                }

                if (!NAVYamlGetNextSibling(yaml, child, child)) {
                    break
                }
            }
        }
    }

    return maxDepth
}


#END_IF // __NAV_FOUNDATION_YAML_PARSER__
