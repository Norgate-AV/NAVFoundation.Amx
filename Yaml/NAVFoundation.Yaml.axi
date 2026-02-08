PROGRAM_NAME='NAVFoundation.Yaml'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_YAML__
#DEFINE __NAV_FOUNDATION_YAML__ 'NAVFoundation.Yaml'

#include 'NAVFoundation.YamlLexer.axi'
#include 'NAVFoundation.YamlParser.axi'
#include 'NAVFoundation.YamlQuery.axi'


/**
 * @function NAVYamlParse
 * @public
 * @description Parse a YAML string into a node tree structure.
 *
 * @param {char[]} input - The YAML string to parse
 * @param {_NAVYaml} yaml - Output parameter to receive the parsed structure
 *
 * @returns {char} True (1) if parsing succeeded, False (0) on error
 *
 * @example
 * stack_var _NAVYaml yaml
 * if (NAVYamlParse('name: John\nage: 30', yaml)) {
 *     // Successfully parsed - can now query or navigate
 * } else {
 *     send_string 0, "'Error: ', NAVYamlGetError(yaml)"
 * }
 */
define_function char NAVYamlParse(char input[], _NAVYaml yaml) {
    stack_var _NAVYamlLexer lexer
    stack_var _NAVYamlParser parser

    // Initialize YAML structure
    yaml.nodeCount = 0
    yaml.rootIndex = 0
    yaml.error = ''
    yaml.errorLine = 0
    yaml.errorColumn = 0
    yaml.source = input

    // Tokenize the input
    if (!NAVYamlLexerTokenize(lexer, input)) {
        yaml.error = lexer.error
        yaml.errorLine = lexer.line
        yaml.errorColumn = lexer.column
        return false
    }

    // Initialize parser with tokens
    NAVYamlParserInit(parser, lexer.tokens)

    // Parse tokens into tree structure
    if (!NAVYamlParserParse(parser, yaml)) {
        return false
    }

    return true
}


/**
 * @function NAVYamlGetError
 * @public
 * @description Get the error message from a failed parse.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 *
 * @returns {char[]} Error message, or empty string if no error
 *
 * @example
 * if (!NAVYamlParse(input, yaml)) {
 *     send_string 0, "'Parse failed: ', NAVYamlGetError(yaml)"
 * }
 */
define_function char[NAV_YAML_PARSER_MAX_ERROR_LENGTH] NAVYamlGetError(_NAVYaml yaml) {
    return yaml.error
}


/**
 * @function NAVYamlGetErrorLine
 * @public
 * @description Get the line number where a parse error occurred.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 *
 * @returns {integer} Line number (1-based), or 0 if no error
 *
 * @example
 * if (!NAVYamlParse(input, yaml)) {
 *     send_string 0, "'Error at line ', itoa(NAVYamlGetErrorLine(yaml))"
 * }
 */
define_function integer NAVYamlGetErrorLine(_NAVYaml yaml) {
    return yaml.errorLine
}


/**
 * @function NAVYamlGetErrorColumn
 * @public
 * @description Get the column number where a parse error occurred.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 *
 * @returns {integer} Column number (1-based), or 0 if no error
 *
 * @example
 * if (!NAVYamlParse(input, yaml)) {
 *     send_string 0, "'Error at column ', itoa(NAVYamlGetErrorColumn(yaml))"
 * }
 */
define_function integer NAVYamlGetErrorColumn(_NAVYaml yaml) {
    return yaml.errorColumn
}


/**
 * @function NAVYamlGetNodeCount
 * @public
 * @description Get the total number of nodes in the YAML tree.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 *
 * @returns {integer} Number of nodes
 *
 * @example
 * stack_var integer nodeCount
 * nodeCount = NAVYamlGetNodeCount(yaml)
 * send_string 0, "'Document has ', itoa(nodeCount), ' nodes'"
 */
define_function integer NAVYamlGetNodeCount(_NAVYaml yaml) {
    return yaml.nodeCount
}


/**
 * @function NAVYamlGetDepth
 * @public
 * @description Calculate the nesting depth of a node in the tree.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {_NAVYamlNode} node - The node to measure
 *
 * @returns {integer} Depth (root = 0)
 *
 * @example
 * stack_var _NAVYamlNode node
 * stack_var integer depth
 * if (NAVYamlQuery(yaml, '.config.server.host', node)) {
 *     depth = NAVYamlGetDepth(yaml, node)
 *     send_string 0, "'Node depth: ', itoa(depth)"
 * }
 */
define_function integer NAVYamlGetDepth(_NAVYaml yaml, _NAVYamlNode node) {
    stack_var integer depth
    stack_var _NAVYamlNode current

    depth = 0
    current = node

    while (NAVYamlGetParent(yaml, current, current)) {
        depth++
    }

    return depth
}


/**
 * @function NAVYamlCountElements
 * @public
 * @description Count the number of elements in a mapping or sequence.
 * This is an alias for NAVYamlGetChildCount.
 *
 * @param {_NAVYamlNode} node - The mapping or sequence node
 *
 * @returns {integer} Number of elements
 *
 * @example
 * stack_var _NAVYamlNode arrayNode
 * if (NAVYamlQuery(yaml, '.items', arrayNode)) {
 *     send_string 0, "'Array has ', itoa(NAVYamlCountElements(arrayNode)), ' items'"
 * }
 */
define_function integer NAVYamlCountElements(_NAVYamlNode node) {
    return NAVYamlGetChildCount(node)
}


/**
 * @function NAVYamlGetNodeTag
 * @public
 * @description Get the explicit type tag for a node by index.
 *
 * Returns the explicit type tag (e.g., "!!str", "!!int", "!custom") for a node.
 * Returns an empty string if the node has no explicit tag.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} index - The node index (1-based)
 *
 * @returns {char[]} The type tag, or empty string if no tag
 *
 * @example
 * stack_var char tag[NAV_YAML_PARSER_MAX_TAG_LENGTH]
 * stack_var integer nodeIndex
 *
 * nodeIndex = NAVYamlQueryIndex(yaml, '.value')
 * if (nodeIndex > 0) {
 *     tag = NAVYamlGetNodeTag(yaml, nodeIndex)
 *     if (length_array(tag) > 0) {
 *         send_string 0, "'Value has explicit tag: ', tag"
 *     }
 * }
 */
define_function char[NAV_YAML_PARSER_MAX_TAG_LENGTH] NAVYamlGetNodeTag(_NAVYaml yaml, integer index) {
    if (index < 1 || index > yaml.nodeCount) {
        return ''
    }

    return yaml.nodes[index].tag
}


/**
 * @function NAVYamlNodeHasTag
 * @public
 * @description Check if a node has a specific explicit type tag.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} index - The node index (1-based)
 * @param {char[]} tag - The tag to check for (e.g., "!!str", "!custom")
 *
 * @returns {char} True (1) if node has the specified tag, False (0) otherwise
 *
 * @example
 * if (NAVYamlNodeHasTag(yaml, nodeIndex, '!!int')) {
 *     send_string 0, "'Value is explicitly tagged as integer'"
 * }
 */
define_function char NAVYamlNodeHasTag(_NAVYaml yaml, integer index, char tag[]) {
    if (index < 1 || index > yaml.nodeCount) {
        return false
    }

    return yaml.nodes[index].tag == tag
}


/**
 * @function NAVYamlGetNodeAnchor
 * @public
 * @description Get the anchor name for a node by index.
 *
 * Returns the anchor name if the node has been defined with an anchor (&name).
 * Returns an empty string if the node has no anchor.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {integer} index - The node index (1-based)
 *
 * @returns {char[]} The anchor name, or empty string if no anchor
 *
 * @example
 * stack_var char anchor[NAV_YAML_PARSER_MAX_ANCHOR_LENGTH]
 * anchor = NAVYamlGetNodeAnchor(yaml, nodeIndex)
 * if (length_array(anchor) > 0) {
 *     send_string 0, "'Node has anchor: ', anchor"
 * }
 */
define_function char[NAV_YAML_PARSER_MAX_ANCHOR_LENGTH] NAVYamlGetNodeAnchor(_NAVYaml yaml, integer index) {
    if (index < 1 || index > yaml.nodeCount) {
        return ''
    }

    return yaml.nodes[index].anchor
}


#END_IF // __NAV_FOUNDATION_YAML__
