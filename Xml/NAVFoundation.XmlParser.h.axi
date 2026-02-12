PROGRAM_NAME='NAVFoundation.XmlParser.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_XML_PARSER_H__
#DEFINE __NAV_FOUNDATION_XML_PARSER_H__ 'NAVFoundation.XmlParser.h'

#include 'NAVFoundation.XmlLexer.h.axi'


DEFINE_CONSTANT

/**
 * XML Node Types
 * NOTE: Node type constants are defined in NAVFoundation.XmlLexer.h.axi as NAV_XML_TYPE_*
 * Use NAV_XML_TYPE_ELEMENT, NAV_XML_TYPE_TEXT, NAV_XML_TYPE_CDATA, etc.
 */

/**
 * Maximum number of XML nodes that can be parsed.
 * Each element, text node, CDATA, comment, and PI requires one node.
 * @default 1000
 */
#IF_NOT_DEFINED NAV_XML_PARSER_MAX_NODES
constant integer NAV_XML_PARSER_MAX_NODES          = 1000
#END_IF

/**
 * Maximum number of attributes across all elements.
 * @default 500
 */
#IF_NOT_DEFINED NAV_XML_PARSER_MAX_ATTRIBUTES
constant integer NAV_XML_PARSER_MAX_ATTRIBUTES     = 500
#END_IF

/**
 * Maximum length of an element name.
 * @default 128
 */
#IF_NOT_DEFINED NAV_XML_PARSER_MAX_ELEMENT_NAME
constant integer NAV_XML_PARSER_MAX_ELEMENT_NAME   = 128
#END_IF

/**
 * Maximum length of text content, CDATA, or comment.
 * @default 512
 */
#IF_NOT_DEFINED NAV_XML_PARSER_MAX_TEXT_LENGTH
constant integer NAV_XML_PARSER_MAX_TEXT_LENGTH    = 512
#END_IF

/**
 * Maximum length of an attribute name.
 * @default 64
 */
#IF_NOT_DEFINED NAV_XML_PARSER_MAX_ATTR_NAME
constant integer NAV_XML_PARSER_MAX_ATTR_NAME      = 64
#END_IF

/**
 * Maximum length of an attribute value.
 * @default 255
 */
#IF_NOT_DEFINED NAV_XML_PARSER_MAX_ATTR_VALUE
constant integer NAV_XML_PARSER_MAX_ATTR_VALUE     = 255
#END_IF

/**
 * Maximum length of a namespace URI.
 * @default 128
 */
#IF_NOT_DEFINED NAV_XML_PARSER_MAX_NAMESPACE
constant integer NAV_XML_PARSER_MAX_NAMESPACE      = 128
#END_IF

/**
 * Maximum length of a namespace prefix.
 * @default 32
 */
#IF_NOT_DEFINED NAV_XML_PARSER_MAX_PREFIX
constant integer NAV_XML_PARSER_MAX_PREFIX         = 32
#END_IF

/**
 * Maximum nesting depth for XML structures.
 * Prevents stack overflow from deeply nested elements.
 * @default 32
 */
#IF_NOT_DEFINED NAV_XML_PARSER_MAX_DEPTH
constant integer NAV_XML_PARSER_MAX_DEPTH          = 32
#END_IF

/**
 * Maximum length for error messages during parsing.
 * @default 255
 */
#IF_NOT_DEFINED NAV_XML_PARSER_MAX_ERROR_LENGTH
constant integer NAV_XML_PARSER_MAX_ERROR_LENGTH   = 255
#END_IF


DEFINE_TYPE

/**
 * @struct _NAVXmlAttribute
 * @public
 * @description Represents an attribute on an XML element.
 *
 * Attributes are stored in a linked list structure, with each attribute
 * pointing to the next attribute on the same element.
 *
 * @property {char[]} name - Attribute name (local name without prefix)
 * @property {char[]} value - Attribute value
 * @property {char[]} namespace - Namespace URI (empty if no namespace)
 * @property {char[]} prefix - Namespace prefix (empty if no prefix)
 * @property {integer} nextAttr - Index of next attribute (0 if last)
 */
struct _NAVXmlAttribute {
    char name[NAV_XML_PARSER_MAX_ATTR_NAME]
    char value[NAV_XML_PARSER_MAX_ATTR_VALUE]
    char namespace[NAV_XML_PARSER_MAX_NAMESPACE]
    char prefix[NAV_XML_PARSER_MAX_PREFIX]
    integer nextAttr
}


/**
 * @struct _NAVXmlNode
 * @public
 * @description Represents a single node in the XML tree structure.
 *
 * Each node can be an element, text, CDATA, comment, or processing instruction.
 * Nodes are organized in a tree using indices rather than pointers.
 *
 * @property {integer} type - The node type (NAV_XML_TYPE_*\)
 * @property {integer} parent - Index of parent node (0 if root)
 * @property {integer} firstChild - Index of first child node (0 if none)
 * @property {integer} nextSibling - Index of next sibling in parent's children (0 if last)
 * @property {char[]} name - Element name (for element nodes)
 * @property {char[]} value - Text content (for text/CDATA/comment/PI nodes)
 * @property {char[]} namespace - Namespace URI (for element nodes)
 * @property {char[]} prefix - Namespace prefix (for element nodes)
 * @property {integer} firstAttr - Index of first attribute (0 if none)
 * @property {integer} childCount - Cached count of children
 */
struct _NAVXmlNode {
    integer type

    integer parent
    integer firstChild
    integer nextSibling

    char name[NAV_XML_PARSER_MAX_ELEMENT_NAME]
    char value[NAV_XML_PARSER_MAX_TEXT_LENGTH]

    char namespace[NAV_XML_PARSER_MAX_NAMESPACE]
    char prefix[NAV_XML_PARSER_MAX_PREFIX]

    integer firstAttr

    integer childCount
}


/**
 * @struct _NAVXml
 * @public
 * @description The main XML structure containing the parsed node tree.
 *
 * This structure holds all parsed XML nodes and attributes in pre-allocated arrays.
 * Nodes reference each other using array indices (1-based, 0 = none).
 *
 * @property {_NAVXmlNode[]} nodes - Pre-allocated array of XML nodes
 * @property {_NAVXmlAttribute[]} attributes - Pre-allocated array of attributes
 * @property {integer} nodeCount - Current number of nodes in use
 * @property {integer} attrCount - Current number of attributes in use
 * @property {integer} rootIndex - Index of the root element node (1-based)
 * @property {char[]} version - XML version (e.g., "1.0")
 * @property {char[]} encoding - Character encoding (e.g., "UTF-8")
 * @property {char[]} error - Error message if parsing failed
 * @property {integer} errorLine - Line number where error occurred
 * @property {integer} errorColumn - Column number where error occurred
 */
struct _NAVXml {
    _NAVXmlNode nodes[NAV_XML_PARSER_MAX_NODES]
    _NAVXmlAttribute attributes[NAV_XML_PARSER_MAX_ATTRIBUTES]
    integer nodeCount
    integer attrCount
    integer rootIndex
    char version[10]
    char encoding[32]
    char error[NAV_XML_PARSER_MAX_ERROR_LENGTH]
    integer errorLine
    integer errorColumn
}


/**
 * @struct _NAVXmlParser
 * @private
 * @description Internal parser state structure.
 *
 * Maintains the parser's current position in the token stream and tracks
 * nesting depth for validation.
 *
 * @property {_NAVXmlToken[]} tokens - Array of tokens from the lexer
 * @property {integer} tokenCount - Number of tokens
 * @property {integer} cursor - Current token position (1-based)
 * @property {integer} depth - Current nesting depth
 */
struct _NAVXmlParser {
    _NAVXmlToken tokens[NAV_XML_LEXER_MAX_TOKENS]
    integer tokenCount
    integer cursor
    integer depth
}


/**
 * @struct _NAVXmlNamespace
 * @private
 * @description Namespace mapping entry.
 *
 * Used internally to track namespace prefix-to-URI mappings during parsing.
 *
 * @property {char[]} prefix - Namespace prefix
 * @property {char[]} uri - Namespace URI
 */
struct _NAVXmlNamespace {
    char prefix[NAV_XML_PARSER_MAX_PREFIX]
    char uri[NAV_XML_PARSER_MAX_NAMESPACE]
}


#END_IF // __NAV_FOUNDATION_XML_PARSER_H__
