PROGRAM_NAME='NAVFoundation.XmlParser'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_XML_PARSER__
#DEFINE __NAV_FOUNDATION_XML_PARSER__ 'NAVFoundation.XmlParser'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.XmlLexer.axi'
#include 'NAVFoundation.XmlParser.h.axi'


// =============================================================================
// PARSER INITIALIZATION AND STATE
// =============================================================================

/**
 * @function NAVXmlParserInit
 * @private
 * @description Initialize an XML parser with an array of tokens.
 *
 * @param {_NAVXmlParser} parser - The parser structure to initialize
 * @param {_NAVXmlToken[]} tokens - The array of tokens to parse
 *
 * @returns {void}
 */
define_function NAVXmlParserInit(_NAVXmlParser parser, _NAVXmlToken tokens[]) {
    parser.tokens = tokens
    parser.tokenCount = length_array(tokens)
    parser.cursor = 1
    parser.depth = 0
}


/**
 * @function NAVXmlParserHasMoreTokens
 * @private
 * @description Check if the parser has more tokens to process.
 *
 * @param {_NAVXmlParser} parser - The parser to check
 *
 * @returns {char} True (1) if more tokens are available, False (0) if all consumed
 */
define_function char NAVXmlParserHasMoreTokens(_NAVXmlParser parser) {
    return parser.cursor <= parser.tokenCount
}


/**
 * @function NAVXmlParserCurrentToken
 * @private
 * @description Get the current token without advancing the cursor.
 *
 * @param {_NAVXmlParser} parser - The parser instance
 * @param {_NAVXmlToken} token - Output parameter to receive the current token
 *
 * @returns {char} True (1) if token retrieved, False (0) if no more tokens
 */
define_function char NAVXmlParserCurrentToken(_NAVXmlParser parser, _NAVXmlToken token) {
    if (!NAVXmlParserHasMoreTokens(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor]
    return true
}


/**
 * @function NAVXmlParserAdvance
 * @private
 * @description Advance the parser cursor to the next token.
 *
 * @param {_NAVXmlParser} parser - The parser structure
 *
 * @returns {void}
 */
define_function NAVXmlParserAdvance(_NAVXmlParser parser) {
    parser.cursor++
}


/**
 * @function NAVXmlParserPeek
 * @private
 * @description Peek at the next token without consuming it.
 *
 * @param {_NAVXmlParser} parser - The parser structure
 * @param {_NAVXmlToken} token - Output parameter to receive the next token
 *
 * @returns {char} True (1) if peek succeeded, False (0) if unable to peek
 */
define_function char NAVXmlParserPeek(_NAVXmlParser parser, _NAVXmlToken token) {
    if (parser.cursor >= parser.tokenCount) {
        return false
    }

    token = parser.tokens[parser.cursor + 1]
    return true
}


/**
 * @function NAVXmlParserExpect
 * @private
 * @description Verify the current token matches the expected type and advance.
 *
 * @param {_NAVXmlParser} parser - The parser instance
 * @param {integer} expectedType - The expected token type
 * @param {_NAVXml} xml - The XML structure for error reporting
 *
 * @returns {char} True (1) if token matches, False (0) on mismatch
 */
define_function char NAVXmlParserExpect(_NAVXmlParser parser, integer expectedType, _NAVXml xml) {
    stack_var _NAVXmlToken token

    if (!NAVXmlParserCurrentToken(parser, token)) {
        xml.error = "'Unexpected end of tokens, expected ', NAVXmlLexerGetTokenType(expectedType)"
        return false
    }

    if (token.type != expectedType) {
        xml.error = "'Expected ', NAVXmlLexerGetTokenType(expectedType), ', got ', NAVXmlLexerGetTokenType(token.type)"
        xml.errorLine = token.line
        xml.errorColumn = token.column
        return false
    }

    NAVXmlParserAdvance(parser)
    return true
}


// =============================================================================
// NODE MANAGEMENT
// =============================================================================

/**
 * @function NAVXmlAllocateNode
 * @private
 * @description Allocate a new node in the XML tree.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} type - The node type
 *
 * @returns {integer} The index of the new node, or 0 if allocation failed
 */
define_function integer NAVXmlAllocateNode(_NAVXml xml, integer type) {
    if (xml.nodeCount >= NAV_XML_PARSER_MAX_NODES) {
        xml.error = "'Node limit reached (', itoa(NAV_XML_PARSER_MAX_NODES), ')'"
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_XML_PARSER__,
                                    'NAVXmlAllocateNode',
                                    xml.error)
        return 0
    }

    xml.nodeCount++
    xml.nodes[xml.nodeCount].type = type
    xml.nodes[xml.nodeCount].parent = 0
    xml.nodes[xml.nodeCount].firstChild = 0
    xml.nodes[xml.nodeCount].nextSibling = 0
    xml.nodes[xml.nodeCount].name = ''
    xml.nodes[xml.nodeCount].value = ''
    xml.nodes[xml.nodeCount].namespace = ''
    xml.nodes[xml.nodeCount].prefix = ''
    xml.nodes[xml.nodeCount].firstAttr = 0
    xml.nodes[xml.nodeCount].childCount = 0

    return xml.nodeCount
}


/**
 * @function NAVXmlAllocateAttribute
 * @private
 * @description Allocate a new attribute in the XML structure.
 *
 * @param {_NAVXml} xml - The XML structure
 *
 * @returns {integer} The index of the new attribute, or 0 if allocation failed
 */
define_function integer NAVXmlAllocateAttribute(_NAVXml xml) {
    if (xml.attrCount >= NAV_XML_PARSER_MAX_ATTRIBUTES) {
        xml.error = "'Attribute limit reached (', itoa(NAV_XML_PARSER_MAX_ATTRIBUTES), ')'"
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_XML_PARSER__,
                                    'NAVXmlAllocateAttribute',
                                    xml.error)
        return 0
    }

    xml.attrCount++
    xml.attributes[xml.attrCount].name = ''
    xml.attributes[xml.attrCount].value = ''
    xml.attributes[xml.attrCount].namespace = ''
    xml.attributes[xml.attrCount].prefix = ''
    xml.attributes[xml.attrCount].nextAttr = 0

    return xml.attrCount
}


/**
 * @function NAVXmlAppendChild
 * @private
 * @description Append a child node to a parent node.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} parentIndex - Index of the parent node
 * @param {integer} childIndex - Index of the child node to append
 *
 * @returns {void}
 */
define_function NAVXmlAppendChild(_NAVXml xml, integer parentIndex, integer childIndex) {
    stack_var integer lastSibling

    xml.nodes[childIndex].parent = parentIndex
    xml.nodes[parentIndex].childCount++

    // If parent has no children, this is the first child
    if (xml.nodes[parentIndex].firstChild == 0) {
        xml.nodes[parentIndex].firstChild = childIndex
        return
    }

    // Otherwise, find the last sibling and append
    lastSibling = xml.nodes[parentIndex].firstChild

    while (xml.nodes[lastSibling].nextSibling != 0) {
        lastSibling = xml.nodes[lastSibling].nextSibling
    }

    xml.nodes[lastSibling].nextSibling = childIndex
}


/**
 * @function NAVXmlAddAttribute
 * @private
 * @description Add an attribute to an element node.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} nodeIndex - Index of the element node
 * @param {char[]} name - Attribute name
 * @param {char[]} value - Attribute value
 *
 * @returns {char} True (1) if attribute added, False (0) on error
 */
define_function char NAVXmlAddAttribute(_NAVXml xml, integer nodeIndex, char name[], char value[]) {
    stack_var integer attrIndex
    stack_var char prefix[NAV_XML_PARSER_MAX_PREFIX]
    stack_var char localName[NAV_XML_PARSER_MAX_ATTR_NAME]

    attrIndex = NAVXmlAllocateAttribute(xml)
    if (attrIndex == 0) {
        return false
    }

    // Split name into prefix:localName if present
    if (NAVContains(name, ':')) {
        stack_var integer colonPos

        colonPos = NAVIndexOf(name, ':', 1)
        prefix = NAVStringSubstring(name, 1, colonPos - 1)
        localName = NAVStringSubstring(name, colonPos + 1, length_array(name) - colonPos)
    } else {
        prefix = ''
        localName = name
    }

    xml.attributes[attrIndex].name = localName
    xml.attributes[attrIndex].value = value
    xml.attributes[attrIndex].prefix = prefix
    xml.attributes[attrIndex].namespace = ''  // Resolved later if needed

    // Link attribute to element
    if (xml.nodes[nodeIndex].firstAttr == 0) {
        xml.nodes[nodeIndex].firstAttr = attrIndex
    } else {
        // Find last attribute and append
        stack_var integer lastAttr

        lastAttr = xml.nodes[nodeIndex].firstAttr

        while (xml.attributes[lastAttr].nextAttr != 0) {
            lastAttr = xml.attributes[lastAttr].nextAttr
        }

        xml.attributes[lastAttr].nextAttr = attrIndex
    }

    return true
}


// =============================================================================
// PARSING FUNCTIONS
// =============================================================================

/**
 * @function NAVXmlParseProcessingInstruction
 * @private
 * @description Parse a processing instruction (already tokenized as PI).
 *
 * @param {_NAVXmlParser} parser - The parser instance
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} parentIndex - Index of parent node (0 for root level)
 *
 * @returns {integer} Index of the created PI node, or 0 on error
 */
define_function integer NAVXmlParseProcessingInstruction(_NAVXmlParser parser, _NAVXml xml, integer parentIndex) {
    stack_var _NAVXmlToken token
    stack_var integer nodeIndex

    if (!NAVXmlParserCurrentToken(parser, token)) {
        xml.error = 'Unexpected end of tokens in processing instruction'
        return 0
    }

    if (token.type != NAV_XML_TOKEN_TYPE_PI) {
        xml.error = "'Expected processing instruction, got ', NAVXmlLexerGetTokenType(token.type)"
        return 0
    }

    // Create PI node
    nodeIndex = NAVXmlAllocateNode(xml, NAV_XML_TYPE_PI)
    if (nodeIndex == 0) {
        return 0
    }

    // Extract PI target name (part before first space) and data (part after)
    {
        stack_var integer spacePos

        spacePos = NAVIndexOf(token.value, ' ', 1)

        if (spacePos > 0) {
            xml.nodes[nodeIndex].name = NAVStringSubstring(token.value, 1, spacePos - 1)
            xml.nodes[nodeIndex].value = NAVStringSubstring(token.value, spacePos + 1, length_array(token.value))
        }
        else {
            xml.nodes[nodeIndex].name = token.value
            xml.nodes[nodeIndex].value = ''
        }
    }

    #IF_DEFINED XML_PARSER_DEBUG
    NAVLog("'[ XmlParser ]: Created PI node[', itoa(nodeIndex), ']: \"', token.value, '\"'")
    #END_IF

    NAVXmlParserAdvance(parser)

    // Check for XML declaration (<?xml version="1.0"?>)
    if (NAVStringStartsWith(token.value, 'xml ')) {
        // Extract version and encoding if present
        if (NAVContains(token.value, 'version=')) {
            stack_var integer versionStart
            stack_var integer versionEnd

            versionStart = NAVIndexOf(token.value, 'version="', 1) + 9
            versionEnd = NAVIndexOf(NAVStringSubstring(token.value, versionStart, length_array(token.value)), '"', 1) + versionStart - 1
            xml.version = NAVStringSubstring(token.value, versionStart, versionEnd - versionStart)
        }

        if (NAVContains(token.value, 'encoding=')) {
            stack_var integer encodingStart
            stack_var integer encodingEnd

            encodingStart = NAVIndexOf(token.value, 'encoding="', 1) + 10
            encodingEnd = NAVIndexOf(NAVStringSubstring(token.value, encodingStart, length_array(token.value)), '"', 1) + encodingStart - 1
            xml.encoding = NAVStringSubstring(token.value, encodingStart, encodingEnd - encodingStart)
        }
    }

    // Append to parent if specified
    if (parentIndex > 0) {
        NAVXmlAppendChild(xml, parentIndex, nodeIndex)
    }

    return nodeIndex
}


/**
 * @function NAVXmlParseComment
 * @private
 * @description Parse a comment (already tokenized as COMMENT).
 *
 * @param {_NAVXmlParser} parser - The parser instance
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} parentIndex - Index of parent node (0 for root level)
 *
 * @returns {integer} Index of the created comment node, or 0 on error
 */
define_function integer NAVXmlParseComment(_NAVXmlParser parser, _NAVXml xml, integer parentIndex) {
    stack_var _NAVXmlToken token
    stack_var integer nodeIndex

    if (!NAVXmlParserCurrentToken(parser, token)) {
        xml.error = 'Unexpected end of tokens in comment'
        return 0
    }

    if (token.type != NAV_XML_TOKEN_TYPE_COMMENT) {
        xml.error = "'Expected comment, got ', NAVXmlLexerGetTokenType(token.type)"
        return 0
    }

    // Create comment node
    nodeIndex = NAVXmlAllocateNode(xml, NAV_XML_TYPE_COMMENT)
    if (nodeIndex == 0) {
        return 0
    }

    xml.nodes[nodeIndex].value = token.value

    #IF_DEFINED XML_PARSER_DEBUG
    NAVLog("'[ XmlParser ]: Created comment node[', itoa(nodeIndex), ']'")
    #END_IF

    NAVXmlParserAdvance(parser)

    // Append to parent if specified
    if (parentIndex > 0) {
        NAVXmlAppendChild(xml, parentIndex, nodeIndex)
    }

    return nodeIndex
}


/**
 * @function NAVXmlParseCDATA
 * @private
 * @description Parse a CDATA section (already tokenized as CDATA).
 *
 * @param {_NAVXmlParser} parser - The parser instance
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} parentIndex - Index of parent node
 *
 * @returns {integer} Index of the created CDATA node, or 0 on error
 */
define_function integer NAVXmlParseCDATA(_NAVXmlParser parser, _NAVXml xml, integer parentIndex) {
    stack_var _NAVXmlToken token
    stack_var integer nodeIndex

    if (!NAVXmlParserCurrentToken(parser, token)) {
        xml.error = 'Unexpected end of tokens in CDATA'
        return 0
    }

    if (token.type != NAV_XML_TOKEN_TYPE_CDATA) {
        xml.error = "'Expected CDATA, got ', NAVXmlLexerGetTokenType(token.type)"
        return 0
    }

    // Create CDATA node
    nodeIndex = NAVXmlAllocateNode(xml, NAV_XML_TYPE_CDATA)
    if (nodeIndex == 0) {
        return 0
    }

    xml.nodes[nodeIndex].value = token.value

    #IF_DEFINED XML_PARSER_DEBUG
    NAVLog("'[ XmlParser ]: Created CDATA node[', itoa(nodeIndex), ']'")
    #END_IF

    NAVXmlParserAdvance(parser)

    // Append to parent
    if (parentIndex > 0) {
        NAVXmlAppendChild(xml, parentIndex, nodeIndex)
    }

    return nodeIndex
}


/**
 * @function NAVXmlParseText
 * @private
 * @description Parse text content (already tokenized as TEXT).
 *
 * @param {_NAVXmlParser} parser - The parser instance
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} parentIndex - Index of parent node
 *
 * @returns {integer} Index of the created text node, or 0 on error
 */
define_function integer NAVXmlParseText(_NAVXmlParser parser, _NAVXml xml, integer parentIndex) {
    stack_var _NAVXmlToken token
    stack_var integer nodeIndex

    if (!NAVXmlParserCurrentToken(parser, token)) {
        xml.error = 'Unexpected end of tokens in text'
        return 0
    }

    if (token.type != NAV_XML_TOKEN_TYPE_TEXT) {
        xml.error = "'Expected text, got ', NAVXmlLexerGetTokenType(token.type)"
        return 0
    }

    // Skip whitespace-only text nodes (newlines, spaces, tabs)
    if (NAVTrimString(token.value) == '') {
        NAVXmlParserAdvance(parser)
        return 0  // Not an error, just skip
    }

    // Create text node
    nodeIndex = NAVXmlAllocateNode(xml, NAV_XML_TYPE_TEXT)
    if (nodeIndex == 0) {
        return 0
    }

    xml.nodes[nodeIndex].value = token.value

    #IF_DEFINED XML_PARSER_DEBUG
    NAVLog("'[ XmlParser ]: Created text node[', itoa(nodeIndex), ']: "', token.value, '"'")
    #END_IF

    NAVXmlParserAdvance(parser)

    // Append to parent
    if (parentIndex > 0) {
        NAVXmlAppendChild(xml, parentIndex, nodeIndex)
    }

    return nodeIndex
}


/**
 * @function NAVXmlParseAttributes
 * @private
 * @description Parse attributes for an element.
 *
 * @param {_NAVXmlParser} parser - The parser instance
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} elementIndex - Index of the element node
 *
 * @returns {char} True (1) if attributes parsed successfully, False (0) on error
 */
define_function char NAVXmlParseAttributes(_NAVXmlParser parser, _NAVXml xml, integer elementIndex) {
    stack_var _NAVXmlToken token

    while (NAVXmlParserCurrentToken(parser, token)) {
        stack_var char attrName[NAV_XML_PARSER_MAX_ATTR_NAME]
        stack_var char attrValue[NAV_XML_PARSER_MAX_ATTR_VALUE]

        // Check for end of attributes
        if (token.type == NAV_XML_TOKEN_TYPE_TAG_CLOSE ||
            token.type == NAV_XML_TOKEN_TYPE_SLASH) {
            return true
        }

        // Expect attribute name
        if (token.type != NAV_XML_TOKEN_TYPE_IDENTIFIER) {
            xml.error = "'Expected attribute name, got ', NAVXmlLexerGetTokenType(token.type)"
            xml.errorLine = token.line
            xml.errorColumn = token.column
            return false
        }

        attrName = token.value
        NAVXmlParserAdvance(parser)

        // Expect =
        if (!NAVXmlParserExpect(parser, NAV_XML_TOKEN_TYPE_EQUALS, xml)) {
            return false
        }

        // Expect attribute value
        if (!NAVXmlParserCurrentToken(parser, token)) {
            xml.error = 'Expected attribute value'
            return false
        }

        if (token.type != NAV_XML_TOKEN_TYPE_STRING) {
            xml.error = "'Expected attribute value, got ', NAVXmlLexerGetTokenType(token.type)"
            xml.errorLine = token.line
            xml.errorColumn = token.column
            return false
        }

        attrValue = token.value
        NAVXmlParserAdvance(parser)

        // Add attribute to element
        if (!NAVXmlAddAttribute(xml, elementIndex, attrName, attrValue)) {
            return false
        }
    }

    return true
}


/**
 * @function NAVXmlParseElement
 * @private
 * @description Parse an XML element (opening tag, children, closing tag).
 *
 * @param {_NAVXmlParser} parser - The parser instance
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} parentIndex - Index of parent node (0 for root element)
 *
 * @returns {integer} Index of the created element node, or 0 on error
 */
define_function integer NAVXmlParseElement(_NAVXmlParser parser, _NAVXml xml, integer parentIndex) {
    stack_var _NAVXmlToken token
    stack_var integer elementIndex
    stack_var char elementName[NAV_XML_PARSER_MAX_ELEMENT_NAME]
    stack_var char prefix[NAV_XML_PARSER_MAX_PREFIX]
    stack_var char localName[NAV_XML_PARSER_MAX_ELEMENT_NAME]
    stack_var char isSelfClosing

    // Check depth limit
    parser.depth++
    if (parser.depth > NAV_XML_PARSER_MAX_DEPTH) {
        xml.error = "'Maximum nesting depth exceeded (', itoa(NAV_XML_PARSER_MAX_DEPTH), ')'"
        return 0
    }

    #IF_DEFINED XML_PARSER_DEBUG
    NAVLog("'[ XmlParser ]: Parsing element at depth ', itoa(parser.depth)")
    #END_IF

    // Expect <
    if (!NAVXmlParserExpect(parser, NAV_XML_TOKEN_TYPE_TAG_OPEN, xml)) {
        return 0
    }

    // Expect element name
    if (!NAVXmlParserCurrentToken(parser, token)) {
        xml.error = 'Expected element name'
        return 0
    }

    if (token.type != NAV_XML_TOKEN_TYPE_IDENTIFIER) {
        xml.error = "'Expected element name, got ', NAVXmlLexerGetTokenType(token.type)"
        xml.errorLine = token.line
        xml.errorColumn = token.column
        return 0
    }

    elementName = token.value
    NAVXmlParserAdvance(parser)

    #IF_DEFINED XML_PARSER_DEBUG
    NAVLog("'[ XmlParser ]: Element name: "', elementName, '"'")
    #END_IF

    // Split into prefix:localName if present
    if (NAVContains(elementName, ':')) {
        stack_var integer colonPos

        colonPos = NAVIndexOf(elementName, ':', 1)
        prefix = NAVStringSubstring(elementName, 1, colonPos - 1)
        localName = NAVStringSubstring(elementName, colonPos + 1, length_array(elementName) - colonPos)

        #IF_DEFINED XML_PARSER_DEBUG
        NAVLog("'[ XmlParser ]: Split into prefix="', prefix, '" localName="', localName, '"'")
        #END_IF
    } else {
        prefix = ''
        localName = elementName
    }

    // Create element node
    elementIndex = NAVXmlAllocateNode(xml, NAV_XML_TYPE_ELEMENT)
    if (elementIndex == 0) {
        return 0
    }

    xml.nodes[elementIndex].name = localName
    xml.nodes[elementIndex].prefix = prefix

    #IF_DEFINED XML_PARSER_DEBUG
    NAVLog("'[ XmlParser ]: Created element node[', itoa(elementIndex), ']: name="', localName, '" prefix="', prefix, '"'")
    #END_IF

    // Parse attributes
    if (!NAVXmlParseAttributes(parser, xml, elementIndex)) {
        return 0
    }

    // Check for self-closing tag
    if (!NAVXmlParserCurrentToken(parser, token)) {
        xml.error = 'Unexpected end of tokens'
        return 0
    }

    isSelfClosing = false
    if (token.type == NAV_XML_TOKEN_TYPE_SLASH) {
        isSelfClosing = true
        NAVXmlParserAdvance(parser)
    }

    // Expect >
    if (!NAVXmlParserExpect(parser, NAV_XML_TOKEN_TYPE_TAG_CLOSE, xml)) {
        return 0
    }

    // If not self-closing, parse children and closing tag
    if (!isSelfClosing) {
        // Parse children
        while (NAVXmlParserCurrentToken(parser, token)) {
            select {
                // Closing tag
                active (token.type == NAV_XML_TOKEN_TYPE_TAG_OPEN): {
                    stack_var _NAVXmlToken nextToken
                    stack_var integer childIndex

                    if (NAVXmlParserPeek(parser, nextToken)) {
                        if (nextToken.type == NAV_XML_TOKEN_TYPE_SLASH) {
                            // This is a closing tag
                            break
                        }
                    }

                    // Child element
                    childIndex = NAVXmlParseElement(parser, xml, elementIndex)
                    if (childIndex == 0) {
                        return 0
                    }
                }

                // Text content
                active (token.type == NAV_XML_TOKEN_TYPE_TEXT): {
                    stack_var integer textIndex

                    textIndex = NAVXmlParseText(parser, xml, elementIndex)
                    if (textIndex == 0 && xml.error != '') {
                        return 0
                    }
                }

                // CDATA
                active (token.type == NAV_XML_TOKEN_TYPE_CDATA): {
                    stack_var integer cdataIndex

                    cdataIndex = NAVXmlParseCDATA(parser, xml, elementIndex)
                    if (cdataIndex == 0) {
                        return 0
                    }
                }

                // Comment
                active (token.type == NAV_XML_TOKEN_TYPE_COMMENT): {
                    stack_var integer commentIndex

                    commentIndex = NAVXmlParseComment(parser, xml, elementIndex)
                    if (commentIndex == 0) {
                        return 0
                    }
                }

                // Processing instruction
                active (token.type == NAV_XML_TOKEN_TYPE_PI): {
                    stack_var integer piIndex

                    piIndex = NAVXmlParseProcessingInstruction(parser, xml, elementIndex)
                    if (piIndex == 0) {
                        return 0
                    }
                }

                // End of children
                active (1): {
                    break
                }
            }
        }

        // Parse closing tag
        if (!NAVXmlParserExpect(parser, NAV_XML_TOKEN_TYPE_TAG_OPEN, xml)) {
            return 0
        }

        if (!NAVXmlParserExpect(parser, NAV_XML_TOKEN_TYPE_SLASH, xml)) {
            return 0
        }

        if (!NAVXmlParserCurrentToken(parser, token)) {
            xml.error = 'Expected closing tag name'
            return 0
        }

        if (token.type != NAV_XML_TOKEN_TYPE_IDENTIFIER) {
            xml.error = "'Expected closing tag name, got ', NAVXmlLexerGetTokenType(token.type)"
            xml.errorLine = token.line
            xml.errorColumn = token.column
            return 0
        }

        // Verify closing tag matches opening tag
        if (token.value != elementName) {
            xml.error = "'Mismatched closing tag: expected </', elementName, '>, got </', token.value, '>'"
            xml.errorLine = token.line
            xml.errorColumn = token.column
            return 0
        }

        NAVXmlParserAdvance(parser)

        if (!NAVXmlParserExpect(parser, NAV_XML_TOKEN_TYPE_TAG_CLOSE, xml)) {
            return 0
        }
    }

    // Append to parent if specified
    if (parentIndex > 0) {
        NAVXmlAppendChild(xml, parentIndex, elementIndex)
    }

    parser.depth--
    return elementIndex
}


/**
 * @function NAVXmlParseDocument
 * @public
 * @description Parse a complete XML document from tokens.
 *
 * @param {_NAVXmlParser} parser - The parser instance
 * @param {_NAVXml} xml - The XML structure to populate
 *
 * @returns {char} True (1) if parsing succeeded, False (0) on error
 */
define_function char NAVXmlParseDocument(_NAVXmlParser parser, _NAVXml xml) {
    stack_var _NAVXmlToken token

    #IF_DEFINED XML_PARSER_DEBUG
    NAVLog("'[ XmlParser ]: Starting document parse, token count: ', itoa(parser.tokenCount)")
    #END_IF

    // Initialize XML structure
    xml.nodeCount = 0
    xml.attrCount = 0
    xml.rootIndex = 0
    xml.version = '1.0'
    xml.encoding = 'UTF-8'
    xml.error = ''
    xml.errorLine = 0
    xml.errorColumn = 0

    // Parse prolog (optional PI, comments, DOCTYPE)
    while (NAVXmlParserCurrentToken(parser, token)) {
        select {
            active (token.type == NAV_XML_TOKEN_TYPE_PI): {
                NAVXmlParseProcessingInstruction(parser, xml, 0)
            }
            active (token.type == NAV_XML_TOKEN_TYPE_COMMENT): {
                NAVXmlParseComment(parser, xml, 0)
            }
            active (token.type == NAV_XML_TOKEN_TYPE_DOCTYPE): {
                // Skip DOCTYPE for now
                NAVXmlParserAdvance(parser)
            }
            active (token.type == NAV_XML_TOKEN_TYPE_TAG_OPEN): {
                // Found root element
                break
            }
            active (1): {
                xml.error = "'Unexpected token in prolog: ', NAVXmlLexerGetTokenType(token.type)"
                xml.errorLine = token.line
                xml.errorColumn = token.column
                return false
            }
        }
    }

    // Parse root element
    #IF_DEFINED XML_PARSER_DEBUG
    NAVLog("'[ XmlParser ]: Parsing root element'")
    #END_IF

    xml.rootIndex = NAVXmlParseElement(parser, xml, 0)
    if (xml.rootIndex == 0) {
        return false
    }

    #IF_DEFINED XML_PARSER_DEBUG
    NAVLog("'[ XmlParser ]: Root element parsed, index=', itoa(xml.rootIndex), ', total nodes=', itoa(xml.nodeCount)")
    #END_IF

    // Parse epilog (optional PIs and comments)
    while (NAVXmlParserCurrentToken(parser, token)) {
        select {
            active (token.type == NAV_XML_TOKEN_TYPE_PI): {
                NAVXmlParseProcessingInstruction(parser, xml, 0)
            }
            active (token.type == NAV_XML_TOKEN_TYPE_COMMENT): {
                NAVXmlParseComment(parser, xml, 0)
            }
            active (token.type == NAV_XML_TOKEN_TYPE_EOF): {
                break
            }
            active (1): {
                xml.error = "'Unexpected token after root element: ', NAVXmlLexerGetTokenType(token.type)"
                xml.errorLine = token.line
                xml.errorColumn = token.column
                return false
            }
        }
    }

    return true
}


/**
 * @function NAVXmlGetChildCount
 * @public
 * @description Get the number of child nodes (includes all types: elements, text, comments, etc.).
 *
 * @param {_NAVXmlNode} node - The parent node
 *
 * @returns {integer} Number of all children
 */
define_function integer NAVXmlGetChildCount(_NAVXmlNode node) {
    return node.childCount
}


/**
 * @function NAVXmlGetElementChildCount
 * @public
 * @description Get the number of element child nodes only (excludes text, comment, etc.).
 * Use this for array operations where you only want element children.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {_NAVXmlNode} node - The parent node
 *
 * @returns {integer} Number of element children
 */
define_function integer NAVXmlGetElementChildCount(_NAVXml xml, _NAVXmlNode node) {
    stack_var integer count
    stack_var integer childIndex

    count = 0
    childIndex = node.firstChild

    while (childIndex > 0) {
        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT) {
            count++
        }

        childIndex = xml.nodes[childIndex].nextSibling
    }

    return count
}


/**
 * @function NAVXmlParserUnescapeString
 * @public
 * @description Unescape XML entity references in a string.
 *
 * @param {char[]} input - The string with XML entities
 *
 * @returns {char[]} The unescaped string with entities converted to characters
 */
define_function char[NAV_MAX_BUFFER] NAVXmlParserUnescapeString(char input[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer len

    result = ''
    len = length_array(input)
    i = 1

    while (i <= len) {
        if (input[i] == '&') {
            // Check for entities
            if (NAVStartsWith(mid_string(input, i, 4), '&lt;')) {
                result = "result, '<'"
                i = i + 4
            }
            else if (NAVStartsWith(mid_string(input, i, 4), '&gt;')) {
                result = "result, '>'"
                i = i + 4
            }
            else if (NAVStartsWith(mid_string(input, i, 5), '&amp;')) {
                result = "result, '&'"
                i = i + 5
            }
            else if (NAVStartsWith(mid_string(input, i, 6), '&quot;')) {
                result = "result, '"'"
                i = i + 6
            }
            else if (NAVStartsWith(mid_string(input, i, 6), '&apos;')) {
                result = "result, ''''"
                i = i + 6
            }
            else {
                // Unknown entity, keep as-is
                result = "result, input[i]"
                i++
            }
        }
        else {
            result = "result, input[i]"
            i++
        }
    }

    return result
}


#END_IF // __NAV_FOUNDATION_XML_PARSER__
