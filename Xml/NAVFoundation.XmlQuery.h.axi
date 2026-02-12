PROGRAM_NAME='NAVFoundation.XmlQuery.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_XML_QUERY_H__
#DEFINE __NAV_FOUNDATION_XML_QUERY_H__ 'NAVFoundation.XmlQuery.h'


DEFINE_CONSTANT

/**
 * @constant NAV_XML_QUERY_MAX_TOKENS
 * @description Maximum number of tokens that can be produced by the query lexer.
 * Each component in a query path (dots, identifiers, brackets) requires one token.
 * Increase this value if working with very long query paths.
 * @default 50
 */
constant integer NAV_XML_QUERY_MAX_TOKENS = 50

/**
 * @constant NAV_XML_QUERY_MAX_IDENTIFIER_LENGTH
 * @description Maximum length of an identifier (element name) in a query path.
 * @default 64
 */
constant integer NAV_XML_QUERY_MAX_IDENTIFIER_LENGTH = 64

/**
 * @constant NAV_XML_QUERY_MAX_PATH_STEPS
 * @description Maximum number of path steps in a query.
 * Each navigation step (element access or array index) requires one path step.
 * @default 25
 */
constant integer NAV_XML_QUERY_MAX_PATH_STEPS = 25

// =============================================================================
// Query Token Types
// =============================================================================

/**
 * @constant NAV_XML_QUERY_TOKEN_DOT
 * @description Token type for the dot operator (.) in query syntax.
 * Used to access element properties and navigate the XML tree.
 * @example .root.child
 */
constant integer NAV_XML_QUERY_TOKEN_DOT = 1

/**
 * @constant NAV_XML_QUERY_TOKEN_IDENTIFIER
 * @description Token type for identifiers (element names) in query syntax.
 * @example .root or .root.child
 */
constant integer NAV_XML_QUERY_TOKEN_IDENTIFIER = 2

/**
 * @constant NAV_XML_QUERY_TOKEN_LEFT_BRACKET
 * @description Token type for left bracket ([) in query syntax.
 * Used to begin array index access.
 * @example .[1]
 */
constant integer NAV_XML_QUERY_TOKEN_LEFT_BRACKET = 3

/**
 * @constant NAV_XML_QUERY_TOKEN_RIGHT_BRACKET
 * @description Token type for right bracket (]) in query syntax.
 * Used to end array index access.
 * @example .[1]
 */
constant integer NAV_XML_QUERY_TOKEN_RIGHT_BRACKET = 4

/**
 * @constant NAV_XML_QUERY_TOKEN_NUMBER
 * @description Token type for numeric indices in query syntax.
 * @example .items[2]
 */
constant integer NAV_XML_QUERY_TOKEN_NUMBER = 5

/**
 * @constant NAV_XML_QUERY_TOKEN_AT
 * @description Token type for the at sign (@) in query syntax.
 * Used as prefix for attribute access.
 * @example .root.@id
 */
constant integer NAV_XML_QUERY_TOKEN_AT = 6

// =============================================================================
// Query Path Step Types
// =============================================================================

/**
 * @constant NAV_XML_QUERY_STEP_ROOT
 * @description Path step type representing the root of the document.
 * Used when the query is just "." with no further navigation.
 * @example .
 */
constant integer NAV_XML_QUERY_STEP_ROOT = 1

/**
 * @constant NAV_XML_QUERY_STEP_ELEMENT
 * @description Path step type for child element access.
 * Navigates to a child element by name.
 * @example .root.child
 */
constant integer NAV_XML_QUERY_STEP_ELEMENT = 2

/**
 * @constant NAV_XML_QUERY_STEP_ARRAY_INDEX
 * @description Path step type for indexed element access.
 * Navigates to a specific child by index (1-based).
 * @example .items[2]
 */
constant integer NAV_XML_QUERY_STEP_ARRAY_INDEX = 3

/**
 * @constant NAV_XML_QUERY_STEP_ATTRIBUTE
 * @description Path step type for attribute access.
 * Accesses an attribute value.
 * @example .root.@id
 */
constant integer NAV_XML_QUERY_STEP_ATTRIBUTE = 4


DEFINE_TYPE

/**
 * @struct _NAVXmlQueryToken
 * @description Represents a single token produced by the query lexer.
 * Used internally to parse jq-like query syntax into executable steps.
 *
 * @property {integer} type - The token type (NAV_XML_QUERY_TOKEN_*\)
 * @property {char[]} identifier - Element or attribute name for IDENTIFIER tokens
 * @property {integer} number - Array index for NUMBER tokens
 *
 * @example
 * // Query ".root.child[2]" produces tokens:
 * // DOT, IDENTIFIER("root"), DOT, IDENTIFIER("child"), LEFT_BRACKET, NUMBER(2), RIGHT_BRACKET
 */
struct _NAVXmlQueryToken {
    integer type
    char identifier[NAV_XML_QUERY_MAX_IDENTIFIER_LENGTH]
    integer number
}

/**
 * @struct _NAVXmlQueryPathStep
 * @description Represents a single step in a query execution path.
 *
 * Each step describes one navigation operation in the query.
 *
 * @property {integer} type - The step type (NAV_XML_QUERY_STEP_*\)
 * @property {char[]} elementName - Element or attribute name
 * @property {integer} arrayIndex - Array index for indexed access (1-based)
 *
 * @example
 * // Query ".root.child[2]" produces steps:
 * // 1. STEP_ELEMENT(elementName="root")
 * // 2. STEP_ELEMENT(elementName="child")
 * // 3. STEP_ARRAY_INDEX(arrayIndex=2)
 */
struct _NAVXmlQueryPathStep {
    integer type
    char elementName[NAV_XML_QUERY_MAX_IDENTIFIER_LENGTH]
    integer arrayIndex
}


#END_IF // __NAV_FOUNDATION_XML_QUERY_H__
