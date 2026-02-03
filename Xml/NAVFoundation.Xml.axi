PROGRAM_NAME='NAVFoundation.Xml'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_XML__
#DEFINE __NAV_FOUNDATION_XML__ 'NAVFoundation.Xml'

#include 'NAVFoundation.XmlLexer.axi'
#include 'NAVFoundation.XmlParser.axi'
#include 'NAVFoundation.XmlQuery.axi'


/**
 * @function NAVXmlParse
 * @public
 * @description Parse an XML string into a node tree structure.
 *
 * @param {char[]} input - The XML string to parse
 * @param {_NAVXml} xml - Output parameter to receive the parsed structure
 *
 * @returns {char} True (1) if parsing succeeded, False (0) on error
 *
 * @example
 * stack_var _NAVXml xml
 * stack_var char input[1024]
 * input = '<root><child>Hello World</child></root>'
 *
 * if (NAVXmlParse(input, xml)) {
 *     // Success - xml.rootIndex points to root element node
 *     // Navigate via xml.nodes[].firstChild and xml.nodes[].nextSibling
 * } else {
 *     // Error - check xml.error for details
 *     send_string 0, "'Parse error: ', xml.error"
 * }
 */
define_function char NAVXmlParse(char input[], _NAVXml xml) {
    stack_var _NAVXmlLexer lexer
    stack_var _NAVXmlParser parser

    // Initialize XML structure
    xml.nodeCount = 0
    xml.attrCount = 0
    xml.rootIndex = 0
    xml.version = '1.0'
    xml.encoding = 'UTF-8'
    xml.error = ''
    xml.errorLine = 0
    xml.errorColumn = 0

    // Tokenize the input
    if (!NAVXmlLexerTokenize(lexer, input)) {
        xml.error = lexer.error
        xml.errorLine = lexer.line
        xml.errorColumn = lexer.column
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_XML__,
                                    'NAVXmlParse',
                                    "'Failed to tokenize input: ', lexer.error")
        return false
    }

    // Initialize parser
    NAVXmlParserInit(parser, lexer.tokens)

    // Parse the document
    if (!NAVXmlParseDocument(parser, xml)) {
        // If parsing failed, reset the tree
        xml.nodeCount = 0
        xml.rootIndex = 0
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_XML__,
                                    'NAVXmlParse',
                                    "'Failed to parse XML: ', xml.error")
        return false
    }

    return true
}


(***********************************************************)
(*               ERROR HANDLING FUNCTIONS                  *)
(***********************************************************)

/**
 * @function NAVXmlGetError
 * @public
 * @description Get the error message from the last parse operation.
 *
 * @param {_NAVXml} xml - The XML structure
 *
 * @returns {char[]} The error message, or empty string if no error
 *
 * @example
 * if (!NAVXmlParse(input, xml)) {
 *     send_string 0, "'Error: ', NAVXmlGetError(xml)"
 * }
 */
define_function char[NAV_XML_PARSER_MAX_ERROR_LENGTH] NAVXmlGetError(_NAVXml xml) {
    return xml.error
}


/**
 * @function NAVXmlGetErrorLine
 * @public
 * @description Get the line number where a parse error occurred.
 *
 * @param {_NAVXml} xml - The XML structure
 *
 * @returns {integer} The line number (1-based), or 0 if no error
 */
define_function integer NAVXmlGetErrorLine(_NAVXml xml) {
    return xml.errorLine
}


/**
 * @function NAVXmlGetErrorColumn
 * @public
 * @description Get the column number where a parse error occurred.
 *
 * @param {_NAVXml} xml - The XML structure
 *
 * @returns {integer} The column number (1-based), or 0 if no error
 */
define_function integer NAVXmlGetErrorColumn(_NAVXml xml) {
    return xml.errorColumn
}


(***********************************************************)
(*               TREE NAVIGATION FUNCTIONS                 *)
(***********************************************************)

/**
 * @function NAVXmlGetRootNode
 * @public
 * @description Get the root element node of the document.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {_NAVXmlNode} node - Output parameter to receive the root node
 *
 * @returns {char} True (1) if root node exists, False (0) otherwise
 *
 * @example
 * stack_var _NAVXmlNode root
 * if (NAVXmlGetRootNode(xml, root)) {
 *     send_string 0, "'Root element: ', root.name"
 * }
 */
define_function char NAVXmlGetRootNode(_NAVXml xml, _NAVXmlNode node) {
    if (xml.rootIndex == 0 || xml.rootIndex > xml.nodeCount) {
        return false
    }

    node = xml.nodes[xml.rootIndex]
    return true
}


/**
 * @function NAVXmlGetNodeByIndex
 * @public
 * @description Get a node by its index in the node array.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {integer} index - The node index (1-based)
 * @param {_NAVXmlNode} node - Output parameter to receive the node
 *
 * @returns {char} True (1) if node exists, False (0) otherwise
 */
define_function char NAVXmlGetNodeByIndex(_NAVXml xml, integer index, _NAVXmlNode node) {
    if (index < 1 || index > xml.nodeCount) {
        return false
    }

    node = xml.nodes[index]
    return true
}


/**
 * @function NAVXmlGetFirstChild
 * @public
 * @description Get the first child node of a parent node.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {_NAVXmlNode} parent - The parent node
 * @param {_NAVXmlNode} child - Output parameter to receive the first child
 *
 * @returns {char} True (1) if child exists, False (0) if no children
 *
 * @example
 * stack_var _NAVXmlNode root
 * stack_var _NAVXmlNode child
 *
 * if (NAVXmlGetRootNode(xml, root)) {
 *     if (NAVXmlGetFirstChild(xml, root, child)) {
 *         send_string 0, "'First child: ', child.name"
 *     }
 * }
 */
define_function char NAVXmlGetFirstChild(_NAVXml xml, _NAVXmlNode parent, _NAVXmlNode child) {
    if (parent.firstChild == 0) {
        return false
    }

    return NAVXmlGetNodeByIndex(xml, parent.firstChild, child)
}


/**
 * @function NAVXmlGetNextSibling
 * @public
 * @description Get the next sibling node of a node.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {_NAVXmlNode} current - The current node
 * @param {_NAVXmlNode} sibling - Output parameter to receive the next sibling
 *
 * @returns {char} True (1) if sibling exists, False (0) if last child
 *
 * @example
 * stack_var _NAVXmlNode child
 * stack_var _NAVXmlNode sibling
 *
 * if (NAVXmlGetFirstChild(xml, root, child)) {
 *     while (NAVXmlGetNextSibling(xml, child, sibling)) {
 *         send_string 0, "'Sibling: ', sibling.name"
 *         child = sibling
 *     }
 * }
 */
define_function char NAVXmlGetNextSibling(_NAVXml xml, _NAVXmlNode current, _NAVXmlNode sibling) {
    if (current.nextSibling == 0) {
        return false
    }

    return NAVXmlGetNodeByIndex(xml, current.nextSibling, sibling)
}


/**
 * @function NAVXmlGetParentNode
 * @public
 * @description Get the parent node of a node.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {_NAVXmlNode} current - The current node
 * @param {_NAVXmlNode} parent - Output parameter to receive the parent node
 *
 * @returns {char} True (1) if parent exists, False (0) if root node
 */
define_function char NAVXmlGetParentNode(_NAVXml xml, _NAVXmlNode current, _NAVXmlNode parent) {
    if (current.parent == 0) {
        return false
    }

    return NAVXmlGetNodeByIndex(xml, current.parent, parent)
}


(***********************************************************)
(*               TYPE CHECKING FUNCTIONS                   *)
(***********************************************************)

/**
 * @function NAVXmlIsElement
 * @public
 * @description Check if a node is an element.
 *
 * @param {_NAVXmlNode} node - The node to check
 *
 * @returns {char} True (1) if element, False (0) otherwise
 */
define_function char NAVXmlIsElement(_NAVXmlNode node) {
    return node.type == NAV_XML_TYPE_ELEMENT
}


/**
 * @function NAVXmlIsTextNode
 * @public
 * @description Check if a node is a text node.
 *
 * @param {_NAVXmlNode} node - The node to check
 *
 * @returns {char} True (1) if text node, False (0) otherwise
 */
define_function char NAVXmlIsTextNode(_NAVXmlNode node) {
    return node.type == NAV_XML_TYPE_TEXT
}


/**
 * @function NAVXmlIsCDATA
 * @public
 * @description Check if a node is a CDATA section.
 *
 * @param {_NAVXmlNode} node - The node to check
 *
 * @returns {char} True (1) if CDATA, False (0) otherwise
 */
define_function char NAVXmlIsCDATA(_NAVXmlNode node) {
    return node.type == NAV_XML_TYPE_CDATA
}


/**
 * @function NAVXmlIsComment
 * @public
 * @description Check if a node is a comment.
 *
 * @param {_NAVXmlNode} node - The node to check
 *
 * @returns {char} True (1) if comment, False (0) otherwise
 */
define_function char NAVXmlIsComment(_NAVXmlNode node) {
    return node.type == NAV_XML_TYPE_COMMENT
}


/**
 * @function NAVXmlHasAttributes
 * @public
 * @description Check if an element node has attributes.
 *
 * @param {_NAVXmlNode} node - The node to check
 *
 * @returns {char} True (1) if has attributes, False (0) otherwise
 */
define_function char NAVXmlHasAttributes(_NAVXmlNode node) {
    return node.firstAttr > 0
}


/**
 * @function NAVXmlHasChildren
 * @public
 * @description Check if a node has child nodes.
 *
 * @param {_NAVXmlNode} node - The node to check
 *
 * @returns {char} True (1) if has children, False (0) otherwise
 */
define_function char NAVXmlHasChildren(_NAVXmlNode node) {
    return node.firstChild > 0
}


(***********************************************************)
(*               VALUE GETTER FUNCTIONS                    *)
(***********************************************************)

/**
 * @function NAVXmlGetElementName
 * @public
 * @description Get the name of an element node.
 *
 * @param {_NAVXmlNode} node - The element node
 *
 * @returns {char[]} The element name, or empty string if not an element
 */
define_function char[NAV_XML_PARSER_MAX_ELEMENT_NAME] NAVXmlGetElementName(_NAVXmlNode node) {
    if (node.type != NAV_XML_TYPE_ELEMENT) {
        return ''
    }

    // Return prefix:name if prefix exists, otherwise just name
    if (node.prefix != '') {
        return "node.prefix, ':', node.name"
    }

    return node.name
}


/**
 * @function NAVXmlGetTextValue
 * @public
 * @description Get the text value of a text, CDATA, or comment node.
 *
 * @param {_NAVXmlNode} node - The node
 *
 * @returns {char[]} The text value, or empty string if not a text-type node
 */
define_function char[NAV_XML_PARSER_MAX_TEXT_LENGTH] NAVXmlGetTextValue(_NAVXmlNode node) {
    if (node.type == NAV_XML_TYPE_TEXT ||
        node.type == NAV_XML_TYPE_CDATA ||
        node.type == NAV_XML_TYPE_COMMENT) {
        return node.value
    }

    return ''
}


/**
 * @function NAVXmlGetAttribute
 * @public
 * @description Get an attribute value from an element node.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {_NAVXmlNode} node - The element node
 * @param {char[]} attrName - Name of the attribute
 * @param {char[]} result - Output parameter for the attribute value
 *
 * @returns {char} True (1) if attribute exists, False (0) otherwise
 *
 * @example
 * stack_var char id[64]
 * if (NAVXmlGetAttribute(xml, node, 'id', id)) {
 *     send_string 0, "'ID: ', id"
 * }
 */
define_function char NAVXmlGetAttribute(_NAVXml xml, _NAVXmlNode node, char attrName[], char result[]) {
    stack_var integer i
    stack_var integer attrIndex

    // Find the node's index in the tree
    for (i = 1; i <= xml.nodeCount; i++) {
        if (xml.nodes[i].type == node.type &&
            xml.nodes[i].name == node.name &&
            xml.nodes[i].firstAttr == node.firstAttr) {

            attrIndex = xml.nodes[i].firstAttr

            while (attrIndex > 0) {
                if (xml.attributes[attrIndex].name == attrName) {
                    result = xml.attributes[attrIndex].value
                    return true
                }

                attrIndex = xml.attributes[attrIndex].nextAttr
            }

            return false
        }
    }

    return false
}


/**
 * @function NAVXmlGetTag
 * @public
 * @description Get the element tag name (alias for NAVXmlGetElementName for consistency with tests).
 *
 * @param {_NAVXmlNode} node - The element node
 *
 * @returns {char[]} The element tag name, or empty string if not an element
 */
define_function char[NAV_XML_PARSER_MAX_ELEMENT_NAME] NAVXmlGetTag(_NAVXmlNode node) {
    return NAVXmlGetElementName(node)
}


/**
 * @function NAVXmlGetNodeType
 * @public
 * @description Get a string representation of the node type.
 *
 * @param {integer} type - The node type constant (NAV_XML_TYPE_*\)
 *
 * @returns {char[]} String representation of the type ("element", "text", "cdata", "comment", "pi", "none")
 */
define_function char[16] NAVXmlGetNodeType(integer type) {
    switch (type) {
        case NAV_XML_TYPE_ELEMENT:      { return 'element' }
        case NAV_XML_TYPE_TEXT:         { return 'text' }
        case NAV_XML_TYPE_CDATA:        { return 'cdata' }
        case NAV_XML_TYPE_COMMENT:      { return 'comment' }
        case NAV_XML_TYPE_PI:           { return 'pi' }
        default:                        { return 'none' }
    }
}


/**
 * @function NAVXmlGetNodeCount
 * @public
 * @description Get the total number of element nodes in the XML document.
 *
 * @param {_NAVXml} xml - The parsed XML document
 *
 * @returns {integer} The number of element nodes (not including text/comment nodes)
 */
define_function integer NAVXmlGetNodeCount(_NAVXml xml) {
    stack_var integer i
    stack_var integer count

    count = 0

    for (i = 1; i <= xml.nodeCount; i++) {
        if (xml.nodes[i].type == NAV_XML_TYPE_ELEMENT) {
            count++
        }
    }

    return count
}


/**
 * @function NAVXmlGetMaxDepth
 * @public
 * @description Get the maximum depth of the XML node tree.
 *
 * @param {_NAVXml} xml - The parsed XML document
 *
 * @returns {sinteger} The maximum depth (0 for empty/root only, -1 for error)
 */
define_function sinteger NAVXmlGetMaxDepth(_NAVXml xml) {
    stack_var integer i
    stack_var sinteger maxDepth
    stack_var sinteger depth

    maxDepth = -1

    if (xml.rootIndex == 0 || xml.nodeCount == 0) {
        return 0
    }

    // Calculate depth for each element node (skip text/comment/etc)
    for (i = 1; i <= xml.nodeCount; i++) {
        stack_var integer current

        // Only count element nodes
        if (xml.nodes[i].type != NAV_XML_TYPE_ELEMENT) {
            continue
        }

        depth = 0
        current = i

        // Traverse up to root counting only element parents
        while (current > 0 && xml.nodes[current].parent > 0) {
            current = xml.nodes[current].parent
            // Only count element nodes in depth
            if (xml.nodes[current].type == NAV_XML_TYPE_ELEMENT) {
                depth++
            }
        }

        if (depth > maxDepth) {
            maxDepth = depth
        }
    }

    return maxDepth
}


/**
 * @function NAVXmlEscapeString
 * @public
 * @description Escape special XML characters in a string.
 *
 * @param {char[]} input - The string to escape
 *
 * @returns {char[]} The escaped string with &lt;, &gt;, &amp;, &quot;, &apos; entities
 */
define_function char[NAV_MAX_BUFFER] NAVXmlEscapeString(char input[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    result = ''

    for (i = 1; i <= length_array(input); i++) {
        switch (input[i]) {
            case '<':  { result = "result, '&lt;'" }
            case '>':  { result = "result, '&gt;'" }
            case '&':  { result = "result, '&amp;'" }
            case '"':  { result = "result, '&quot;'" }
            case '''':  { result = "result, '&apos;'" }
            default:   { result = "result, input[i]" }
        }
    }

    return result
}


#END_IF // __NAV_FOUNDATION_XML__
