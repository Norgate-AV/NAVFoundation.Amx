PROGRAM_NAME='NAVFoundation.JsonParser'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_JSON_PARSER__
#DEFINE __NAV_FOUNDATION_JSON_PARSER__ 'NAVFoundation.JsonParser'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.JsonLexer.axi'
#include 'NAVFoundation.JsonParser.h.axi'


/**
 * @function NAVJsonGetNode
 * @private
 * @description Internal function to get a JSON node by its index.
 *
 * This function provides low-level access to nodes in the parsed JSON tree.
 * Public navigation functions wrap this to provide a cleaner API.
 *
 * @param {_NAVJson} json - The parsed JSON structure
 * @param {integer} nodeIndex - Index of the node to retrieve (1-based)
 * @param {_NAVJsonNode} node - Output parameter to receive the node data
 *
 * @returns {char} True (1) if node exists, False (0) if invalid index
 */
define_function char NAVJsonGetNode(_NAVJson json, integer nodeIndex, _NAVJsonNode node) {
    // Validate node index
    if (nodeIndex < 1 || nodeIndex > json.nodeCount) {
        return false
    }

    // Copy node data to output parameter
    node = json.nodes[nodeIndex]

    return true
}


/**
 * @function NAVJsonParserInit
 * @private
 * @description Initialize a JSON parser with an array of tokens.
 *
 * @param {_NAVJsonParser} parser - The parser structure to initialize
 * @param {_NAVJsonToken[]} tokens - The array of tokens to parse
 *
 * @returns {void}
 */
define_function NAVJsonParserInit(_NAVJsonParser parser, _NAVJsonToken tokens[]) {
    parser.tokens = tokens
    parser.tokenCount = length_array(tokens)
    parser.cursor = 1
    parser.depth = 0
}


/**
 * @function NAVJsonParserHasMoreTokens
 * @private
 * @description Check if the parser has more tokens to process.
 *
 * @param {_NAVJsonParser} parser - The parser to check
 *
 * @returns {char} True (1) if more tokens are available, False (0) if all consumed
 */
define_function char NAVJsonParserHasMoreTokens(_NAVJsonParser parser) {
    return parser.cursor <= parser.tokenCount
}


/**
 * @function NAVJsonParserCurrentToken
 * @private
 * @description Get the current token without advancing the cursor.
 *
 * @param {_NAVJsonParser} parser - The parser instance
 * @param {_NAVJsonToken} token - Output parameter to receive the current token
 *
 * @returns {char} True (1) if token retrieved, False (0) if no more tokens
 */
define_function char NAVJsonParserCurrentToken(_NAVJsonParser parser, _NAVJsonToken token) {
    if (!NAVJsonParserHasMoreTokens(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor]
    return true
}


/**
 * @function NAVJsonParserAdvance
 * @private
 * @description Advance the parser cursor to the next token.
 *
 * @param {_NAVJsonParser} parser - The parser structure
 *
 * @returns {void}
 */
define_function NAVJsonParserAdvance(_NAVJsonParser parser) {
    parser.cursor++
}


/**
 * @function NAVJsonParserCanPeek
 * @private
 * @description Check if the parser can peek at the next token.
 *
 * @param {_NAVJsonParser} parser - The parser to check
 *
 * @returns {char} True (1) if peek is possible, False (0) if at or beyond last token
 */
define_function char NAVJsonParserCanPeek(_NAVJsonParser parser) {
    return parser.cursor < parser.tokenCount
}


/**
 * @function NAVJsonParserPeek
 * @private
 * @description Peek at the next token without consuming it.
 *
 * @param {_NAVJsonParser} parser - The parser structure
 * @param {_NAVJsonToken} token - Output parameter to receive the next token
 *
 * @returns {char} True (1) if peek succeeded, False (0) if unable to peek
 */
define_function char NAVJsonParserPeek(_NAVJsonParser parser, _NAVJsonToken token) {
    if (!NAVJsonParserCanPeek(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor + 1]
    return true
}


/**
 * @function NAVJsonParserExpect
 * @private
 * @description Verify the current token matches the expected type and advance.
 *
 * @param {_NAVJsonParser} parser - The parser instance
 * @param {integer} expectedType - The expected token type
 * @param {_NAVJson} json - The JSON structure for error reporting
 *
 * @returns {char} True (1) if token matches, False (0) on mismatch
 */
define_function char NAVJsonParserExpect(_NAVJsonParser parser, integer expectedType, _NAVJson json) {
    stack_var _NAVJsonToken token

    if (!NAVJsonParserCurrentToken(parser, token)) {
        json.error = "'Unexpected end of tokens, expected ', NAVJsonLexerGetTokenType(expectedType)"
        return false
    }

    if (token.type != expectedType) {
        json.error = "'Expected ', NAVJsonLexerGetTokenType(expectedType), ', got ', NAVJsonLexerGetTokenType(token.type)"
        json.errorLine = token.line
        json.errorColumn = token.column
        return false
    }

    NAVJsonParserAdvance(parser)
    return true
}


/**
 * @function NAVJsonAllocateNode
 * @private
 * @description Allocate a new node from the node pool.
 *
 * @param {_NAVJson} json - The JSON structure
 *
 * @returns {integer} Index of the allocated node (1-based), or 0 if pool exhausted
 */
define_function integer NAVJsonAllocateNode(_NAVJson json) {
    if (json.nodeCount >= NAV_JSON_PARSER_MAX_NODES) {
        json.error = "'Node pool exhausted (max: ', itoa(NAV_JSON_PARSER_MAX_NODES), ')'"
        return 0
    }

    json.nodeCount++
    return json.nodeCount
}


/**
 * @function NAVJsonParserLinkChild
 * @private
 * @description Link a child node to its parent.
 *
 * @param {_NAVJson} json - The JSON structure
 * @param {integer} parentIndex - Index of the parent node
 * @param {integer} childIndex - Index of the child node to link
 *
 * @returns {void}
 */
define_function NAVJsonParserLinkChild(_NAVJson json, integer parentIndex, integer childIndex) {
    stack_var integer lastSibling

    if (parentIndex == 0) {
        return
    }

    json.nodes[childIndex].parent = parentIndex
    json.nodes[parentIndex].childCount++

    // If parent has no children yet, this becomes the first child
    if (json.nodes[parentIndex].firstChild == 0) {
        json.nodes[parentIndex].firstChild = childIndex
        return
    }

    // Otherwise, append to the end of the sibling chain
    lastSibling = json.nodes[parentIndex].firstChild

    while (json.nodes[lastSibling].nextSibling != 0) {
        lastSibling = json.nodes[lastSibling].nextSibling
    }

    json.nodes[lastSibling].nextSibling = childIndex
}


/**
 * @function NAVJsonParserSetError
 * @private
 * @description Set an error message with location information from a token.
 *
 * @param {_NAVJson} json - The JSON structure
 * @param {_NAVJsonToken} token - The token where the error occurred
 * @param {char[]} message - The error message
 *
 * @returns {void}
 */
define_function NAVJsonParserSetError(_NAVJson json, _NAVJsonToken token, char message[]) {
    json.error = message
    json.errorLine = token.line
    json.errorColumn = token.column
}


/**
 * @function NAVJsonParserUnescapeString
 * @private
 * @description Unescape a JSON string by processing escape sequences.
 *
 * @param {char[]} value - The string token value (including quotes)
 *
 * @returns {char[NAV_JSON_PARSER_MAX_STRING_LENGTH]} The unescaped string with quotes removed
 */
define_function char[NAV_JSON_PARSER_MAX_STRING_LENGTH] NAVJsonParserUnescapeString(char value[]) {
    stack_var integer i
    stack_var integer len
    stack_var char result[NAV_JSON_PARSER_MAX_STRING_LENGTH]
    stack_var char ch

    len = length_array(value)

    // Remove surrounding quotes
    if (len >= 2 && value[1] == '"' && value[len] == '"') {
        value = NAVStringSlice(value, 2, len)
        len = length_array(value)
    }

    result = ''
    i = 1

    while (i <= len) {
        ch = value[i]

        if (ch == '\') {
            i++
            if (i > len) {
                break
            }

            ch = value[i]

            switch (ch) {
                case '"':  { result = "result, '"'" }
                case '\':  { result = "result, '\'" }
                case '/':  { result = "result, '/'" }
                case 'b':  { result = "result, $08" }  // Backspace
                case 'f':  { result = "result, $0C" }  // Form feed
                case 'n':  { result = "result, $0A" }  // Line feed
                case 'r':  { result = "result, $0D" }  // Carriage return
                case 't':  { result = "result, $09" }  // Tab
                case 'u':  {
                    // Unicode escape sequence \uXXXX
                    // For now, just skip the sequence (full implementation would convert to UTF-8)
                    i = i + 4
                }
                default: {
                    result = "result, ch"
                }
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
 * @function NAVJsonParserParseString
 * @private
 * @description Parse a string value token into a node.
 *
 * @param {_NAVJsonParser} parser - The parser instance
 * @param {_NAVJson} json - The JSON structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for array elements)
 *
 * @returns {integer} Index of created node, or 0 on error
 */
define_function integer NAVJsonParserParseString(_NAVJsonParser parser, _NAVJson json, integer parentIndex, char key[]) {
    stack_var _NAVJsonToken token
    stack_var integer nodeIndex

    if (!NAVJsonParserCurrentToken(parser, token)) {
        return 0
    }

    nodeIndex = NAVJsonAllocateNode(json)
    if (nodeIndex == 0) {
        return 0
    }

    json.nodes[nodeIndex].type = NAV_JSON_VALUE_TYPE_STRING
    json.nodes[nodeIndex].key = key
    json.nodes[nodeIndex].value = NAVJsonParserUnescapeString(token.value)

    NAVJsonParserLinkChild(json, parentIndex, nodeIndex)
    NAVJsonParserAdvance(parser)

    return nodeIndex
}


/**
 * @function NAVJsonParserParseNumber
 * @private
 * @description Parse a number value token into a node.
 *
 * @param {_NAVJsonParser} parser - The parser instance
 * @param {_NAVJson} json - The JSON structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for array elements)
 *
 * @returns {integer} Index of created node, or 0 on error
 */
define_function integer NAVJsonParserParseNumber(_NAVJsonParser parser, _NAVJson json, integer parentIndex, char key[]) {
    stack_var _NAVJsonToken token
    stack_var integer nodeIndex

    if (!NAVJsonParserCurrentToken(parser, token)) {
        return 0
    }

    nodeIndex = NAVJsonAllocateNode(json)
    if (nodeIndex == 0) {
        return 0
    }

    json.nodes[nodeIndex].type = NAV_JSON_VALUE_TYPE_NUMBER
    json.nodes[nodeIndex].key = key
    json.nodes[nodeIndex].value = token.value

    NAVJsonParserLinkChild(json, parentIndex, nodeIndex)
    NAVJsonParserAdvance(parser)

    return nodeIndex
}


/**
 * @function NAVJsonParserParseTrue
 * @private
 * @description Parse a true literal token into a node.
 *
 * @param {_NAVJsonParser} parser - The parser instance
 * @param {_NAVJson} json - The JSON structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for array elements)
 *
 * @returns {integer} Index of created node, or 0 on error
 */
define_function integer NAVJsonParserParseTrue(_NAVJsonParser parser, _NAVJson json, integer parentIndex, char key[]) {
    stack_var integer nodeIndex

    nodeIndex = NAVJsonAllocateNode(json)
    if (nodeIndex == 0) {
        return 0
    }

    json.nodes[nodeIndex].type = NAV_JSON_VALUE_TYPE_TRUE
    json.nodes[nodeIndex].key = key
    json.nodes[nodeIndex].value = 'true'

    NAVJsonParserLinkChild(json, parentIndex, nodeIndex)
    NAVJsonParserAdvance(parser)

    return nodeIndex
}


/**
 * @function NAVJsonParserParseFalse
 * @private
 * @description Parse a false literal token into a node.
 *
 * @param {_NAVJsonParser} parser - The parser instance
 * @param {_NAVJson} json - The JSON structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for array elements)
 *
 * @returns {integer} Index of created node, or 0 on error
 */
define_function integer NAVJsonParserParseFalse(_NAVJsonParser parser, _NAVJson json, integer parentIndex, char key[]) {
    stack_var integer nodeIndex

    nodeIndex = NAVJsonAllocateNode(json)
    if (nodeIndex == 0) {
        return 0
    }

    json.nodes[nodeIndex].type = NAV_JSON_VALUE_TYPE_FALSE
    json.nodes[nodeIndex].key = key
    json.nodes[nodeIndex].value = 'false'

    NAVJsonParserLinkChild(json, parentIndex, nodeIndex)
    NAVJsonParserAdvance(parser)

    return nodeIndex
}


/**
 * @function NAVJsonParserParseNull
 * @private
 * @description Parse a null literal token into a node.
 *
 * @param {_NAVJsonParser} parser - The parser instance
 * @param {_NAVJson} json - The JSON structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for array elements)
 *
 * @returns {integer} Index of created node, or 0 on error
 */
define_function integer NAVJsonParserParseNull(_NAVJsonParser parser, _NAVJson json, integer parentIndex, char key[]) {
    stack_var integer nodeIndex

    nodeIndex = NAVJsonAllocateNode(json)
    if (nodeIndex == 0) {
        return 0
    }

    json.nodes[nodeIndex].type = NAV_JSON_VALUE_TYPE_NULL
    json.nodes[nodeIndex].key = key

    NAVJsonParserLinkChild(json, parentIndex, nodeIndex)
    NAVJsonParserAdvance(parser)

    return nodeIndex
}


/**
 * @function NAVJsonParserParseValue
 * @private
 * @description Parse a JSON value (dispatch to appropriate type parser).
 *
 * @param {_NAVJsonParser} parser - The parser instance
 * @param {_NAVJson} json - The JSON structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for array elements)
 *
 * @returns {integer} Index of created node, or 0 on error
 */
define_function integer NAVJsonParserParseValue(_NAVJsonParser parser, _NAVJson json, integer parentIndex, char key[]) {
    stack_var _NAVJsonToken token

    if (!NAVJsonParserCurrentToken(parser, token)) {
        json.error = 'Unexpected end of tokens while parsing value'
        return 0
    }

    switch (token.type) {
        case NAV_JSON_TOKEN_TYPE_LEFT_BRACE: {
            return NAVJsonParserParseObject(parser, json, parentIndex, key)
        }
        case NAV_JSON_TOKEN_TYPE_LEFT_BRACKET: {
            return NAVJsonParserParseArray(parser, json, parentIndex, key)
        }
        case NAV_JSON_TOKEN_TYPE_STRING: {
            return NAVJsonParserParseString(parser, json, parentIndex, key)
        }
        case NAV_JSON_TOKEN_TYPE_NUMBER: {
            return NAVJsonParserParseNumber(parser, json, parentIndex, key)
        }
        case NAV_JSON_TOKEN_TYPE_TRUE: {
            return NAVJsonParserParseTrue(parser, json, parentIndex, key)
        }
        case NAV_JSON_TOKEN_TYPE_FALSE: {
            return NAVJsonParserParseFalse(parser, json, parentIndex, key)
        }
        case NAV_JSON_TOKEN_TYPE_NULL: {
            return NAVJsonParserParseNull(parser, json, parentIndex, key)
        }
        default: {
            NAVJsonParserSetError(json, token, "'Unexpected token: ', token.value")
            return 0
        }
    }
}


/**
 * @function NAVJsonParserParseArray
 * @private
 * @description Parse a JSON array into a node with children.
 *
 * @param {_NAVJsonParser} parser - The parser instance
 * @param {_NAVJson} json - The JSON structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for array elements)
 *
 * @returns {integer} Index of created array node, or 0 on error
 */
define_function integer NAVJsonParserParseArray(_NAVJsonParser parser, _NAVJson json, integer parentIndex, char key[]) {
    stack_var integer arrayIndex
    stack_var _NAVJsonToken token
    stack_var integer childIndex

    // Check depth limit
    parser.depth++
    if (parser.depth > NAV_JSON_PARSER_MAX_DEPTH) {
        parser.depth--
        json.error = "'Maximum nesting depth exceeded (', itoa(NAV_JSON_PARSER_MAX_DEPTH), ')'"
        return 0
    }

    // Consume '['
    if (!NAVJsonParserExpect(parser, NAV_JSON_TOKEN_TYPE_LEFT_BRACKET, json)) {
        parser.depth--
        return 0
    }

    // Allocate array node
    arrayIndex = NAVJsonAllocateNode(json)
    if (arrayIndex == 0) {
        parser.depth--
        return 0
    }

    json.nodes[arrayIndex].type = NAV_JSON_VALUE_TYPE_ARRAY
    json.nodes[arrayIndex].key = key

    NAVJsonParserLinkChild(json, parentIndex, arrayIndex)

    // Check for empty array
    if (NAVJsonParserCurrentToken(parser, token)) {
        if (token.type == NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET) {
            NAVJsonParserAdvance(parser)
            parser.depth--
            return arrayIndex
        }
    }

    // Parse array elements
    while (true) {
        childIndex = NAVJsonParserParseValue(parser, json, arrayIndex, '')
        if (childIndex == 0) {
            parser.depth--
            return 0
        }

        if (!NAVJsonParserCurrentToken(parser, token)) {
            json.error = 'Unexpected end of tokens in array'
            parser.depth--
            return 0
        }

        if (token.type == NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET) {
            NAVJsonParserAdvance(parser)
            break
        }

        if (token.type == NAV_JSON_TOKEN_TYPE_COMMA) {
            NAVJsonParserAdvance(parser)
            continue
        }

        NAVJsonParserSetError(json, token, "'Expected "," or "]", got ', token.value")
        parser.depth--
        return 0
    }

    parser.depth--
    return arrayIndex
}


/**
 * @function NAVJsonParserParseObject
 * @private
 * @description Parse a JSON object into a node with children.
 *
 * @param {_NAVJsonParser} parser - The parser instance
 * @param {_NAVJson} json - The JSON structure
 * @param {integer} parentIndex - Index of parent node
 * @param {char[]} key - Property key (empty for array elements)
 *
 * @returns {integer} Index of created object node, or 0 on error
 */
define_function integer NAVJsonParserParseObject(_NAVJsonParser parser, _NAVJson json, integer parentIndex, char key[]) {
    stack_var integer objectIndex
    stack_var _NAVJsonToken token
    stack_var char propertyKey[NAV_JSON_PARSER_MAX_KEY_LENGTH]
    stack_var integer childIndex

    // Check depth limit
    parser.depth++
    if (parser.depth > NAV_JSON_PARSER_MAX_DEPTH) {
        parser.depth--
        json.error = "'Maximum nesting depth exceeded (', itoa(NAV_JSON_PARSER_MAX_DEPTH), ')'"
        return 0
    }

    // Consume '{'
    if (!NAVJsonParserExpect(parser, NAV_JSON_TOKEN_TYPE_LEFT_BRACE, json)) {
        parser.depth--
        return 0
    }

    // Allocate object node
    objectIndex = NAVJsonAllocateNode(json)
    if (objectIndex == 0) {
        parser.depth--
        return 0
    }

    json.nodes[objectIndex].type = NAV_JSON_VALUE_TYPE_OBJECT
    json.nodes[objectIndex].key = key

    NAVJsonParserLinkChild(json, parentIndex, objectIndex)

    // Check for empty object
    if (NAVJsonParserCurrentToken(parser, token)) {
        if (token.type == NAV_JSON_TOKEN_TYPE_RIGHT_BRACE) {
            NAVJsonParserAdvance(parser)
            parser.depth--
            return objectIndex
        }
    }

    // Parse object properties
    while (true) {
        // Expect property key (string)
        if (!NAVJsonParserCurrentToken(parser, token)) {
            json.error = 'Unexpected end of tokens in object'
            parser.depth--
            return 0
        }

        if (token.type != NAV_JSON_TOKEN_TYPE_STRING) {
            NAVJsonParserSetError(json, token, "'Expected property key (string), got ', token.value")
            parser.depth--
            return 0
        }

        propertyKey = NAVJsonParserUnescapeString(token.value)
        NAVJsonParserAdvance(parser)

        // Expect colon
        if (!NAVJsonParserExpect(parser, NAV_JSON_TOKEN_TYPE_COLON, json)) {
            parser.depth--
            return 0
        }

        // Parse property value
        childIndex = NAVJsonParserParseValue(parser, json, objectIndex, propertyKey)
        if (childIndex == 0) {
            parser.depth--
            return 0
        }

        // Check for comma or closing brace
        if (!NAVJsonParserCurrentToken(parser, token)) {
            json.error = 'Unexpected end of tokens in object'
            parser.depth--
            return 0
        }

        if (token.type == NAV_JSON_TOKEN_TYPE_RIGHT_BRACE) {
            NAVJsonParserAdvance(parser)
            break
        }

        if (token.type == NAV_JSON_TOKEN_TYPE_COMMA) {
            NAVJsonParserAdvance(parser)
            continue
        }

        NAVJsonParserSetError(json, token, "'Expected "," or "}", got ', token.value")
        parser.depth--
        return 0
    }

    parser.depth--
    return objectIndex
}


/**
 * @function NAVJsonGetNodeType
 * @public
 * @description Get the string representation of a JSON node type.
 *
 * @param {integer} type - The node type constant (NAV_JSON_VALUE_TYPE_*\)
 *
 * @returns {char[]} String representation of the type ("object", "array", "string", "number", "true", "false", "null", "none")
 */
define_function char[16] NAVJsonGetNodeType(integer type) {
    switch (type) {
        case NAV_JSON_VALUE_TYPE_OBJECT:    { return 'object' }
        case NAV_JSON_VALUE_TYPE_ARRAY:     { return 'array' }
        case NAV_JSON_VALUE_TYPE_STRING:    { return 'string' }
        case NAV_JSON_VALUE_TYPE_NUMBER:    { return 'number' }
        case NAV_JSON_VALUE_TYPE_TRUE:      { return 'true' }
        case NAV_JSON_VALUE_TYPE_FALSE:     { return 'false' }
        case NAV_JSON_VALUE_TYPE_NULL:      { return 'null' }
        default:                            { return 'none' }
    }
}


// ===========================================================================
// TYPE CHECKING FUNCTIONS
// ===========================================================================

/**
 * @function NAVJsonIsObject
 * @public
 * @description Check if a node is an object.
 *
 * @param {_NAVJsonNode} node - The node to check
 *
 * @returns {char} true if node is an object, false otherwise
 */
define_function char NAVJsonIsObject(_NAVJsonNode node) {
    return node.type == NAV_JSON_VALUE_TYPE_OBJECT
}


/**
 * @function NAVJsonIsArray
 * @public
 * @description Check if a node is an array.
 *
 * @param {_NAVJsonNode} node - The node to check
 *
 * @returns {char} true if node is an array, false otherwise
 */
define_function char NAVJsonIsArray(_NAVJsonNode node) {
    return node.type == NAV_JSON_VALUE_TYPE_ARRAY
}


/**
 * @function NAVJsonIsString
 * @public
 * @description Check if a node is a string.
 *
 * @param {_NAVJsonNode} node - The node to check
 *
 * @returns {char} true if node is a string, false otherwise
 */
define_function char NAVJsonIsString(_NAVJsonNode node) {
    return node.type == NAV_JSON_VALUE_TYPE_STRING
}


/**
 * @function NAVJsonIsNumber
 * @public
 * @description Check if a node is a number.
 *
 * @param {_NAVJsonNode} node - The node to check
 *
 * @returns {char} true if node is a number, false otherwise
 */
define_function char NAVJsonIsNumber(_NAVJsonNode node) {
    return node.type == NAV_JSON_VALUE_TYPE_NUMBER
}


/**
 * @function NAVJsonIsBoolean
 * @public
 * @description Check if a node is a boolean (true or false).
 *
 * @param {_NAVJsonNode} node - The node to check
 *
 * @returns {char} true if node is a boolean, false otherwise
 */
define_function char NAVJsonIsBoolean(_NAVJsonNode node) {
    return (node.type == NAV_JSON_VALUE_TYPE_TRUE || node.type == NAV_JSON_VALUE_TYPE_FALSE)
}


/**
 * @function NAVJsonIsTrue
 * @public
 * @description Check if a node is the true literal.
 *
 * @param {_NAVJsonNode} node - The node to check
 *
 * @returns {char} true if node is true literal, false otherwise
 */
define_function char NAVJsonIsTrue(_NAVJsonNode node) {
    return node.type == NAV_JSON_VALUE_TYPE_TRUE
}


/**
 * @function NAVJsonIsFalse
 * @public
 * @description Check if a node is the false literal.
 *
 * @param {_NAVJsonNode} node - The node to check
 *
 * @returns {char} true if node is false literal, false otherwise
 */
define_function char NAVJsonIsFalse(_NAVJsonNode node) {
    return node.type == NAV_JSON_VALUE_TYPE_FALSE
}


/**
 * @function NAVJsonIsNull
 * @public
 * @description Check if a node is null.
 *
 * @param {_NAVJsonNode} node - The node to check
 *
 * @returns {char} true if node is null, false otherwise
 */
define_function char NAVJsonIsNull(_NAVJsonNode node) {
    return node.type == NAV_JSON_VALUE_TYPE_NULL
}


// ===========================================================================
// VALUE GETTER FUNCTIONS
// ===========================================================================

/**
 * @function NAVJsonGetString
 * @public
 * @description Safely get the string value from a node.
 *
 * @param {_NAVJsonNode} node - The node to get value from
 * @param {char[]} result - Output parameter for the string value
 *
 * @returns {char} true if successful (node is a string), false otherwise
 */
define_function char NAVJsonGetString(_NAVJsonNode node, char result[]) {
    if (node.type != NAV_JSON_VALUE_TYPE_STRING) {
        result = ''
        return false
    }

    result = node.value
    return true
}


/**
 * @function NAVJsonGetNumber
 * @public
 * @description Safely get the numeric value from a node.
 *
 * @param {_NAVJsonNode} node - The node to get value from
 * @param {float} result - Output parameter for the numeric value
 *
 * @returns {char} true if successful (node is a number), false otherwise
 */
define_function char NAVJsonGetNumber(_NAVJsonNode node, float result) {
    if (node.type != NAV_JSON_VALUE_TYPE_NUMBER) {
        result = 0.0
        return false
    }

    return NAVParseFloat(node.value, result)
}


/**
 * @function NAVJsonGetBoolean
 * @public
 * @description Safely get the boolean value from a node.
 *
 * @param {_NAVJsonNode} node - The node to get value from
 * @param {char} result - Output parameter for the boolean value
 *
 * @returns {char} true if successful (node is true or false), false otherwise
 */
define_function char NAVJsonGetBoolean(_NAVJsonNode node, char result) {
    if (node.type != NAV_JSON_VALUE_TYPE_TRUE && node.type != NAV_JSON_VALUE_TYPE_FALSE) {
        result = false
        return false
    }

    result = (node.value == 'true')
    return true
}


/**
 * @function NAVJsonGetKey
 * @public
 * @description Get the key name of a node (for object properties).
 *
 * @param {_NAVJsonNode} node - The node to get key from
 *
 * @returns {char[]} The key name, or empty string if node has no key
 */
define_function char[NAV_JSON_PARSER_MAX_KEY_LENGTH] NAVJsonGetKey(_NAVJsonNode node) {
    return node.key
}


// ===========================================================================
// TREE NAVIGATION FUNCTIONS
// ===========================================================================

/**
 * @function NAVJsonGetRootNode
 * @public
 * @description Get the root node of the JSON document.
 *
 * @param {_NAVJson} json - The parsed JSON structure
 * @param {_NAVJsonNode} node - Output parameter to receive the root node
 *
 * @returns {char} true if root node exists, false otherwise
 *
 * @example
 * stack_var _NAVJson json
 * stack_var _NAVJsonNode root
 *
 * if (NAVJsonParse('{"name":"John"}', json)) {
 *     if (NAVJsonGetRootNode(json, root)) {
 *         send_string 0, "'Root type: ', itoa(root.type)"
 *     }
 * }
 */
define_function char NAVJsonGetRootNode(_NAVJson json, _NAVJsonNode node) {
    if (json.rootIndex == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_JSON_PARSER__,
                                    'NAVJsonGetRootNode',
                                    'No root node available')
        return false
    }

    return NAVJsonGetNode(json, json.rootIndex, node)
}


/**
 * @function NAVJsonGetNextNode
 * @public
 * @description Get the next sibling node in the JSON tree.
 *
 * This function retrieves the next sibling of the current node by following
 * the nextSibling link. Returns false if there are no more siblings.
 *
 * @param {_NAVJson} json - The parsed JSON structure
 * @param {_NAVJsonNode} currentNode - The current node
 * @param {_NAVJsonNode} nextNode - Output parameter to receive the next sibling node
 *
 * @returns {char} true if next sibling exists, false if no more siblings
 *
 * @example
 * stack_var _NAVJson json
 * stack_var _NAVJsonNode root, child
 *
 * NAVJsonParse('[1,2,3]', json)
 * NAVJsonGetRootNode(json, root)
 *
 * // Iterate array elements
 * if (NAVJsonGetFirstChild(json, root, child)) {
 *     do {
 *         send_string 0, "'Value: ', child.value"
 *     } while (NAVJsonGetNextNode(json, child, child))
 * }
 */
define_function char NAVJsonGetNextNode(_NAVJson json, _NAVJsonNode currentNode, _NAVJsonNode nextNode) {
    if (currentNode.nextSibling == 0) {
        return false
    }

    return NAVJsonGetNode(json, currentNode.nextSibling, nextNode)
}


/**
 * @function NAVJsonGetFirstChild
 * @public
 * @description Get the first child node of a parent node.
 *
 * This function retrieves the first child of the given parent node. Use this to
 * begin iterating over the children of an object or array. Returns false if the
 * parent has no children.
 *
 * @param {_NAVJson} json - The parsed JSON structure
 * @param {_NAVJsonNode} parentNode - The parent node
 * @param {_NAVJsonNode} childNode - Output parameter to receive the first child node
 *
 * @returns {char} true if parent has children, false if no children
 *
 * @example
 * stack_var _NAVJson json
 * stack_var _NAVJsonNode root, child
 *
 * NAVJsonParse('{"name":"John","age":30}', json)
 * NAVJsonGetRootNode(json, root)
 *
 * // Iterate all properties
 * if (NAVJsonGetFirstChild(json, root, child)) {
 *     do {
 *         send_string 0, "child.key, ': ', child.value"
 *     } while (NAVJsonGetNextNode(json, child, child))
 * }
 */
define_function char NAVJsonGetFirstChild(_NAVJson json, _NAVJsonNode parentNode, _NAVJsonNode childNode) {
    if (parentNode.firstChild == 0) {
        return false
    }

    return NAVJsonGetNode(json, parentNode.firstChild, childNode)
}


// ===========================================================================
// OBJECT/ARRAY HELPER FUNCTIONS
// ===========================================================================

/**
 * @function NAVJsonGetPropertyByKey
 * @public
 * @description Find a child node by its key name (for object properties).
 *
 * @param {_NAVJson} json - The JSON document
 * @param {_NAVJsonNode} parentNode - The parent object node
 * @param {char[]} key - The property key to search for
 * @param {_NAVJsonNode} result - Output parameter for the found node
 *
 * @returns {char} true if property found, false otherwise
 */
define_function char NAVJsonGetPropertyByKey(_NAVJson json, _NAVJsonNode parentNode, char key[], _NAVJsonNode result) {
    stack_var _NAVJsonNode child

    if (parentNode.type != NAV_JSON_VALUE_TYPE_OBJECT) {
        return false
    }

    if (!NAVJsonGetFirstChild(json, parentNode, child)) {
        return false
    }

    while (true) {
        if (child.key == key) {
            result = child
            return true
        }

        if (!NAVJsonGetNextNode(json, child, child)) {
            break
        }
    }

    return false
}


/**
 * @function NAVJsonHasProperty
 * @public
 * @description Check if an object has a property with the given key.
 *
 * @param {_NAVJson} json - The JSON document
 * @param {_NAVJsonNode} parentNode - The parent object node
 * @param {char[]} key - The property key to check for
 *
 * @returns {char} true if property exists, false otherwise
 */
define_function char NAVJsonHasProperty(_NAVJson json, _NAVJsonNode parentNode, char key[]) {
    stack_var _NAVJsonNode result
    return NAVJsonGetPropertyByKey(json, parentNode, key, result)
}


/**
 * @function NAVJsonGetArrayElement
 * @public
 * @description Get an array element by its index (0-based).
 *
 * @param {_NAVJson} json - The JSON document
 * @param {_NAVJsonNode} arrayNode - The array node
 * @param {integer} index - The element index (0-based)
 * @param {_NAVJsonNode} result - Output parameter for the element node
 *
 * @returns {char} true if element found, false otherwise
 */
define_function char NAVJsonGetArrayElement(_NAVJson json, _NAVJsonNode arrayNode, integer index, _NAVJsonNode result) {
    stack_var _NAVJsonNode child
    stack_var integer currentIndex

    if (arrayNode.type != NAV_JSON_VALUE_TYPE_ARRAY) {
        return false
    }

    if (index < 0 || index >= arrayNode.childCount) {
        return false
    }

    if (!NAVJsonGetFirstChild(json, arrayNode, child)) {
        return false
    }

    currentIndex = 0

    while (true) {
        if (currentIndex == index) {
            result = child
            return true
        }

        currentIndex++

        if (!NAVJsonGetNextNode(json, child, child)) {
            break
        }
    }

    return false
}


/**
 * @function NAVJsonGetChildCount
 * @public
 * @description Get the number of children for an object or array node.
 *
 * @param {_NAVJsonNode} node - The node to check
 *
 * @returns {integer} The number of children, or 0 if not an object/array
 */
define_function integer NAVJsonGetChildCount(_NAVJsonNode node) {
    return node.childCount
}


// ===========================================================================
// VALIDATION/ERROR FUNCTIONS
// ===========================================================================

/**
 * @function NAVJsonIsValid
 * @public
 * @description Check if the JSON document was parsed successfully.
 *
 * @param {_NAVJson} json - The JSON document to check
 *
 * @returns {char} true if parse succeeded (no errors), false otherwise
 */
define_function char NAVJsonIsValid(_NAVJson json) {
    return length_array(json.error) == 0
}


/**
 * @function NAVJsonGetError
 * @public
 * @description Get the error message from a failed parse.
 *
 * @param {_NAVJson} json - The JSON document
 *
 * @returns {char[]} The error message, or empty string if no error
 */
define_function char[NAV_JSON_PARSER_MAX_ERROR_LENGTH] NAVJsonGetError(_NAVJson json) {
    return json.error
}


/**
 * @function NAVJsonGetErrorLine
 * @public
 * @description Get the line number where a parse error occurred.
 *
 * @param {_NAVJson} json - The JSON document
 *
 * @returns {integer} The line number (1-based), or 0 if no error
 */
define_function integer NAVJsonGetErrorLine(_NAVJson json) {
    return json.errorLine
}


/**
 * @function NAVJsonGetErrorColumn
 * @public
 * @description Get the column number where a parse error occurred.
 *
 * @param {_NAVJson} json - The JSON document
 *
 * @returns {integer} The column number (1-based), or 0 if no error
 */
define_function integer NAVJsonGetErrorColumn(_NAVJson json) {
    return json.errorColumn
}


// ===========================================================================
// TREE INFORMATION FUNCTIONS
// ===========================================================================

/**
 * @function NAVJsonGetNodeCount
 * @public
 * @description Get the total number of nodes in the JSON document.
 *
 * @param {_NAVJson} json - The JSON document
 *
 * @returns {integer} The total number of nodes
 */
define_function integer NAVJsonGetNodeCount(_NAVJson json) {
    return json.nodeCount
}


/**
 * @function NAVJsonGetMaxDepth
 * @public
 * @description Calculate the maximum depth of the JSON tree.
 *              Root node is at depth 0.
 *
 * @param {_NAVJson} json - The JSON document
 *
 * @returns {sinteger} The maximum depth, or -1 if empty/invalid
 */
define_function sinteger NAVJsonGetMaxDepth(_NAVJson json) {
    stack_var _NAVJsonNode root

    if (!NAVJsonGetRootNode(json, root)) {
        return -1
    }

    return NAVJsonGetMaxDepthRecursive(json, root, 0)
}


/**
 * @function NAVJsonGetMaxDepthRecursive
 * @private
 * @description Recursively calculate maximum depth.
 *
 * @param {_NAVJson} json - The JSON document
 * @param {_NAVJsonNode} node - Current node
 * @param {integer} currentDepth - Current depth level
 *
 * @returns {sinteger} Maximum depth from this node
 */
define_function sinteger NAVJsonGetMaxDepthRecursive(_NAVJson json, _NAVJsonNode node, integer currentDepth) {
    stack_var _NAVJsonNode child
    stack_var sinteger maxDepth
    stack_var sinteger childDepth

    maxDepth = type_cast(currentDepth)

    if (node.childCount > 0) {
        if (NAVJsonGetFirstChild(json, node, child)) {
            while (true) {
                childDepth = NAVJsonGetMaxDepthRecursive(json, child, currentDepth + 1)

                if (childDepth > maxDepth) {
                    maxDepth = childDepth
                }

                if (!NAVJsonGetNextNode(json, child, child)) {
                    break
                }
            }
        }
    }

    return maxDepth
}


#END_IF // __NAV_FOUNDATION_JSON_PARSER__
