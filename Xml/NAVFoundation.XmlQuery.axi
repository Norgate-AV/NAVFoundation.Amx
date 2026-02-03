PROGRAM_NAME='NAVFoundation.XmlQuery'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_XML_QUERY__
#DEFINE __NAV_FOUNDATION_XML_QUERY__ 'NAVFoundation.XmlQuery'

#include 'NAVFoundation.XmlParser.axi'
#include 'NAVFoundation.XmlQuery.h.axi'


(***********************************************************)
(*               QUERY LEXER FUNCTIONS                     *)
(***********************************************************)

/**
 * @function NAVXmlQueryLexer
 * @private
 * @description Tokenizes an XML query string into tokens for parsing.
 * Converts a query string into a sequence of tokens representing dots, identifiers,
 * brackets, and numbers.
 *
 * @param {char[]} query - The query string to tokenize (e.g., ".root.child", ".items[1]")
 * @param {_NAVXmlQueryToken[]} tokens - Array to store the resulting tokens
 *
 * @returns {integer} Number of tokens generated, or 0 on error
 *
 * @example
 * stack_var _NAVXmlQueryToken tokens[NAV_XML_QUERY_MAX_TOKENS]
 * stack_var integer count
 * count = NAVXmlQueryLexer('.root.child[1]', tokens)
 */
define_function integer NAVXmlQueryLexer(char query[], _NAVXmlQueryToken tokens[]) {
    stack_var integer pos
    stack_var integer tokenCount
    stack_var char ch
    stack_var integer queryLength

    pos = 1
    tokenCount = 0
    queryLength = length_array(query)

    while (pos <= queryLength) {
        ch = query[pos]

        // Skip whitespace
        if (NAVIsWhitespace(ch)) {
            pos++
            continue
        }

        // Check token limit
        if (tokenCount >= NAV_XML_QUERY_MAX_TOKENS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_XML_QUERY__,
                                        'NAVXmlQueryLexer',
                                        "'Too many tokens in query (max: ', itoa(NAV_XML_QUERY_MAX_TOKENS), ')'")
            return 0
        }

        tokenCount++

        select {
            // DOT
            active (ch == '.'): {
                tokens[tokenCount].type = NAV_XML_QUERY_TOKEN_DOT
                pos++
            }

            // LEFT_BRACKET
            active (ch == '['): {
                tokens[tokenCount].type = NAV_XML_QUERY_TOKEN_LEFT_BRACKET
                pos++
            }

            // RIGHT_BRACKET
            active (ch == ']'): {
                tokens[tokenCount].type = NAV_XML_QUERY_TOKEN_RIGHT_BRACKET
                pos++
            }

            // AT
            active (ch == '@'): {
                tokens[tokenCount].type = NAV_XML_QUERY_TOKEN_AT
                pos++
            }

            // NUMBER
            active (NAVIsDigit(ch)): {
                stack_var char numStr[20]
                stack_var integer startPos

                startPos = pos

                while (pos <= queryLength && NAVIsDigit(query[pos])) {
                    pos++
                }

                numStr = NAVStringSubstring(query, startPos, pos - startPos)
                tokens[tokenCount].type = NAV_XML_QUERY_TOKEN_NUMBER
                tokens[tokenCount].number = atoi(numStr)
            }

            // IDENTIFIER
            active (NAVIsAlpha(ch) || ch == '_'): {
                stack_var integer startPos

                startPos = pos

                while (pos <= queryLength) {
                    ch = query[pos]
                    if (NAVIsAlphaNumeric(ch) || ch == '_' || ch == '-') {
                        pos++
                    }
                    else {
                        break
                    }
                }

                tokens[tokenCount].type = NAV_XML_QUERY_TOKEN_IDENTIFIER
                tokens[tokenCount].identifier = NAVStringSubstring(query, startPos, pos - startPos)
            }

            // Unknown character
            active (1): {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_XML_QUERY__,
                                            'NAVXmlQueryLexer',
                                            "'Unexpected character: ', ch, ' (', itoa(ch), ') at position ', itoa(pos)")
                return 0
            }
        }
    }

    return tokenCount
}


(***********************************************************)
(*               QUERY PARSER FUNCTIONS                    *)
(***********************************************************)

/**
 * @function NAVXmlQueryParser
 * @private
 * @description Parses tokens into executable path steps.
 * Validates token sequence and converts tokens into navigation steps that can be
 * executed against an XML tree.
 *
 * @param {_NAVXmlQueryToken[]} tokens - Array of tokens from the lexer
 * @param {integer} tokenCount - Number of tokens
 * @param {_NAVXmlQueryPathStep[]} steps - Array to store the resulting path steps
 *
 * @returns {integer} Number of steps generated, or 0 on error
 *
 * @example
 * stack_var _NAVXmlQueryPathStep steps[NAV_XML_QUERY_MAX_PATH_STEPS]
 * stack_var integer stepCount
 * stepCount = NAVXmlQueryParser(tokens, tokenCount, steps)
 */
define_function integer NAVXmlQueryParser(_NAVXmlQueryToken tokens[], integer tokenCount, _NAVXmlQueryPathStep steps[]) {
    stack_var integer pos
    stack_var integer stepCount

    pos = 1
    stepCount = 0

    // Query must start with DOT
    if (tokenCount == 0 || tokens[pos].type != NAV_XML_QUERY_TOKEN_DOT) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_XML_QUERY__,
                                    'NAVXmlQueryParser',
                                    "'Query must start with . (dot)'")
        return 0
    }

    pos++ // Skip initial DOT

    // Check if query is just "." (root)
    if (pos > tokenCount) {
        stepCount++
        steps[stepCount].type = NAV_XML_QUERY_STEP_ROOT
        return stepCount
    }

    while (pos <= tokenCount) {
        if (stepCount >= NAV_XML_QUERY_MAX_PATH_STEPS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_XML_QUERY__,
                                        'NAVXmlQueryParser',
                                        "'Too many path steps (max: ', itoa(NAV_XML_QUERY_MAX_PATH_STEPS), ')'")
            return 0
        }

        stepCount++

        select {
            // Attribute access: @name
            active (tokens[pos].type == NAV_XML_QUERY_TOKEN_AT): {
                pos++

                if (pos > tokenCount || tokens[pos].type != NAV_XML_QUERY_TOKEN_IDENTIFIER) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_XML_QUERY__,
                                                'NAVXmlQueryParser',
                                                'Expected attribute name after @')
                    return 0
                }

                steps[stepCount].type = NAV_XML_QUERY_STEP_ATTRIBUTE
                steps[stepCount].elementName = tokens[pos].identifier
                pos++
            }

            // Element access
            active (tokens[pos].type == NAV_XML_QUERY_TOKEN_IDENTIFIER): {
                steps[stepCount].type = NAV_XML_QUERY_STEP_ELEMENT
                steps[stepCount].elementName = tokens[pos].identifier
                pos++

                // Check for array index following element: [NUMBER]
                if (pos <= tokenCount && tokens[pos].type == NAV_XML_QUERY_TOKEN_LEFT_BRACKET) {
                    pos++

                    if (pos > tokenCount || tokens[pos].type != NAV_XML_QUERY_TOKEN_NUMBER) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_XML_QUERY__,
                                                    'NAVXmlQueryParser',
                                                    "'Expected number after ['")
                        return 0
                    }

                    stepCount++
                    steps[stepCount].type = NAV_XML_QUERY_STEP_ARRAY_INDEX
                    steps[stepCount].arrayIndex = tokens[pos].number
                    pos++

                    if (pos > tokenCount || tokens[pos].type != NAV_XML_QUERY_TOKEN_RIGHT_BRACKET) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_XML_QUERY__,
                                                    'NAVXmlQueryParser',
                                                    "'Expected ] after array index'")
                        return 0
                    }

                    pos++
                }

                // Check for continuation with DOT
                if (pos <= tokenCount && tokens[pos].type == NAV_XML_QUERY_TOKEN_DOT) {
                    pos++
                }
            }

            // Direct array access: [NUMBER]
            active (tokens[pos].type == NAV_XML_QUERY_TOKEN_LEFT_BRACKET): {
                pos++

                if (pos > tokenCount || tokens[pos].type != NAV_XML_QUERY_TOKEN_NUMBER) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_XML_QUERY__,
                                                'NAVXmlQueryParser',
                                                "'Expected number after ['")
                    return 0
                }

                steps[stepCount].type = NAV_XML_QUERY_STEP_ARRAY_INDEX
                steps[stepCount].arrayIndex = tokens[pos].number
                pos++

                if (pos > tokenCount || tokens[pos].type != NAV_XML_QUERY_TOKEN_RIGHT_BRACKET) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_XML_QUERY__,
                                                'NAVXmlQueryParser',
                                                "'Expected ] after array index'")
                    return 0
                }

                pos++

                // Check for continuation with DOT
                if (pos <= tokenCount && tokens[pos].type == NAV_XML_QUERY_TOKEN_DOT) {
                    pos++
                }
            }

            active (1): {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_XML_QUERY__,
                                            'NAVXmlQueryParser',
                                            "'Unexpected token type: ', itoa(tokens[pos].type)")
                return 0
            }
        }
    }

    return stepCount
}


(***********************************************************)
(*               QUERY EXECUTION FUNCTIONS                 *)
(***********************************************************)

/**
 * @function NAVXmlGetNodeTextContent
 * @private
 * @description Get the concatenated text content of a node and its descendants.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} nodeIndex - Index of the node
 * @param {char[]} result - Output parameter for text content
 *
 * @returns {void}
 */
define_function NAVXmlGetNodeTextContent(_NAVXml xml, integer nodeIndex, char result[]) {
    stack_var integer childIndex

    // If this is a text or CDATA node, return its value
    if (xml.nodes[nodeIndex].type == NAV_XML_TYPE_TEXT ||
        xml.nodes[nodeIndex].type == NAV_XML_TYPE_CDATA) {
        result = "result, xml.nodes[nodeIndex].value"
        return
    }

    // Otherwise, recursively collect text from children
    childIndex = xml.nodes[nodeIndex].firstChild

    while (childIndex > 0) {
        NAVXmlGetNodeTextContent(xml, childIndex, result)
        childIndex = xml.nodes[childIndex].nextSibling
    }
}


/**
 * @function NAVXmlGetAttributeValue
 * @private
 * @description Get the value of an attribute on a node.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} nodeIndex - Index of the element node
 * @param {char[]} attrName - Name of the attribute
 * @param {char[]} result - Output parameter for attribute value
 *
 * @returns {char} True (1) if attribute found, False (0) otherwise
 */
define_function char NAVXmlGetAttributeValue(_NAVXml xml, integer nodeIndex, char attrName[], char result[]) {
    stack_var integer attrIndex

    if (xml.nodes[nodeIndex].type != NAV_XML_TYPE_ELEMENT) {
        return false
    }

    attrIndex = xml.nodes[nodeIndex].firstAttr

    while (attrIndex > 0) {
        if (xml.attributes[attrIndex].name == attrName) {
            result = xml.attributes[attrIndex].value
            return true
        }

        attrIndex = xml.attributes[attrIndex].nextAttr
    }

    return false
}


/**
 * @function NAVXmlFindDescendant
 * @private
 * @description Find a descendant element by name at any depth.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {integer} startIndex - Index of node to start search from
 * @param {char[]} name - Name of element to find
 *
 * @returns {integer} Index of found node, or 0 if not found
 */
define_function integer NAVXmlFindDescendant(_NAVXml xml, integer startIndex, char name[]) {
    stack_var integer childIndex
    stack_var integer result

    // Check children
    childIndex = xml.nodes[startIndex].firstChild

    while (childIndex > 0) {
        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT && xml.nodes[childIndex].name == name) {
            return childIndex
        }

        // Recursively search this child's descendants
        result = NAVXmlFindDescendant(xml, childIndex, name)
        if (result > 0) {
            return result
        }

        childIndex = xml.nodes[childIndex].nextSibling
    }

    return 0
}


/**
 * @function NAVXmlQueryExecuteIndex
 * @private
 * @description Execute a query path against an XML tree and return the node index.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {_NAVXmlQueryPathStep[]} steps - Array of path steps to execute
 * @param {integer} stepCount - Number of steps
 *
 * @returns {integer} Node index if query succeeded, 0 if path not found
 */
define_function integer NAVXmlQueryExecuteIndex(_NAVXml xml, _NAVXmlQueryPathStep steps[], integer stepCount) {
    stack_var integer currentIndex
    stack_var integer i

    // Handle root query
    if (stepCount == 1 && steps[1].type == NAV_XML_QUERY_STEP_ROOT) {
        return xml.rootIndex
    }

    // Start from root
    if (xml.rootIndex == 0) {
        return 0
    }
    currentIndex = xml.rootIndex

    // Execute each step
    for (i = 1; i <= stepCount; i++) {
        select {
            active (steps[i].type == NAV_XML_QUERY_STEP_ELEMENT): {
                stack_var integer childIndex
                stack_var integer count
                stack_var char found
                stack_var char hasArrayIndex

                // Check if next step is an array index
                hasArrayIndex = (i < stepCount && steps[i + 1].type == NAV_XML_QUERY_STEP_ARRAY_INDEX)

                found = false
                count = 0
                childIndex = xml.nodes[currentIndex].firstChild

                if (hasArrayIndex) {
                    #IF_DEFINED XML_QUERY_DEBUG
                    NAVLog("'[ XmlQueryExecute ]: Looking for element[', itoa(steps[i + 1].arrayIndex), '] name="', steps[i].elementName, '"'")
                    #END_IF

                    // Find the Nth element with the specified name
                    while (childIndex > 0) {
                        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT) {
                            #IF_DEFINED XML_QUERY_DEBUG
                            NAVLog("'[ XmlQueryExecute ]: Found element="', xml.nodes[childIndex].name, '" (looking for "', steps[i].elementName, '")'")
                            #END_IF

                            if (xml.nodes[childIndex].name == steps[i].elementName) {
                                count++

                                #IF_DEFINED XML_QUERY_DEBUG
                                NAVLog("'[ XmlQueryExecute ]: Matched! count=', itoa(count), ' target=', itoa(steps[i + 1].arrayIndex)")
                                #END_IF

                                if (count == steps[i + 1].arrayIndex) {
                                    currentIndex = childIndex
                                    found = true

                                    #IF_DEFINED XML_QUERY_DEBUG
                                    NAVLog("'[ XmlQueryExecute ]: Found target element at index ', itoa(steps[i + 1].arrayIndex)")
                                    #END_IF

                                    break
                                }
                            }
                        }

                        childIndex = xml.nodes[childIndex].nextSibling
                    }

                    // Skip the array index step since we handled it here (whether found or not)
                    i++
                }
                else {
                    // Find the first element with the specified name
                    while (childIndex > 0) {
                        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT &&
                            xml.nodes[childIndex].name == steps[i].elementName) {
                            currentIndex = childIndex
                            found = true
                            break
                        }

                        childIndex = xml.nodes[childIndex].nextSibling
                    }
                }

                if (!found) {
                    return 0
                }
            }

            active (steps[i].type == NAV_XML_QUERY_STEP_ARRAY_INDEX): {
                stack_var integer childIndex
                stack_var integer count
                stack_var char found

                found = false
                count = 0
                childIndex = xml.nodes[currentIndex].firstChild

                while (childIndex > 0) {
                    if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT) {
                        count++
                        if (count == steps[i].arrayIndex) {
                            currentIndex = childIndex
                            found = true
                            break
                        }
                    }

                    childIndex = xml.nodes[childIndex].nextSibling
                }

                if (!found) {
                    return 0
                }
            }

            active (steps[i].type == NAV_XML_QUERY_STEP_ATTRIBUTE): {
                // Attributes don't have indices in the node array
                // Return 0 to indicate this path doesn't lead to a node
                // The caller will need to handle attributes specially
                return 0
            }
        }
    }

    return currentIndex
}


/**
 * @function NAVXmlQueryExecute
 * @private
 * @description Execute a query path against an XML tree.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {_NAVXmlQueryPathStep[]} steps - Array of path steps to execute
 * @param {integer} stepCount - Number of steps
 * @param {_NAVXmlNode} result - Output parameter for result node
 *
 * @returns {char} True (1) if query succeeded, False (0) if path not found
 */
define_function char NAVXmlQueryExecute(_NAVXml xml, _NAVXmlQueryPathStep steps[], integer stepCount, _NAVXmlNode result) {
    stack_var integer nodeIndex
    stack_var integer attrIndex

    // Handle attribute queries specially
    if (stepCount > 0 && steps[stepCount].type == NAV_XML_QUERY_STEP_ATTRIBUTE) {
        // Get the parent node
        if (stepCount == 1) {
            nodeIndex = xml.rootIndex
        }
        else {
            nodeIndex = NAVXmlQueryExecuteIndex(xml, steps, stepCount - 1)
        }

        if (nodeIndex == 0 || xml.nodes[nodeIndex].type != NAV_XML_TYPE_ELEMENT) {
            return false
        }

        // Find the attribute
        attrIndex = xml.nodes[nodeIndex].firstAttr

        while (attrIndex > 0) {
            if (xml.attributes[attrIndex].name == steps[stepCount].elementName) {
                // Create a pseudo-node to hold the attribute value
                result.type = NAV_XML_TYPE_TEXT
                result.value = xml.attributes[attrIndex].value
                return true
            }

            attrIndex = xml.attributes[attrIndex].nextAttr
        }

        return false
    }

    // Normal node query
    nodeIndex = NAVXmlQueryExecuteIndex(xml, steps, stepCount)

    if (nodeIndex == 0) {
        return false
    }

    result = xml.nodes[nodeIndex]
    return true
}


/**
 * @function NAVXmlQuery
 * @public
 * @description Queries an XML structure using a jq-like query syntax.
 * Main entry point for querying XML data using simple dot notation.
 *
 * Supports:
 * - `.` (root node)
 * - `.element` (child element access)
 * - `.[index]` (indexed child access, 1-based indexing)
 * - `.element.nested` (chained element access)
 * - `.element[index]` (mixed access)
 * - `.element.@attribute` (attribute access)
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {char[]} query - The query string (e.g., ".root.child", ".items[1]", ".root.@id")
 * @param {_NAVXmlNode} result - Output parameter for the result node
 *
 * @returns {char} True (1) if query succeeded, False (0) if path not found or error
 *
 * @example
 * stack_var _NAVXmlNode node
 * if (NAVXmlQuery(xml, '.config.server.host', node)) {
 *     // Use node
 * }
 */
define_function char NAVXmlQuery(_NAVXml xml, char query[], _NAVXmlNode result) {
    stack_var _NAVXmlQueryToken tokens[NAV_XML_QUERY_MAX_TOKENS]
    stack_var _NAVXmlQueryPathStep steps[NAV_XML_QUERY_MAX_PATH_STEPS]
    stack_var integer tokenCount
    stack_var integer stepCount

    // Tokenize query
    tokenCount = NAVXmlQueryLexer(query, tokens)
    if (tokenCount == 0) {
        return false
    }

    // Parse tokens into steps
    stepCount = NAVXmlQueryParser(tokens, tokenCount, steps)
    if (stepCount == 0) {
        return false
    }

    // Execute query
    return NAVXmlQueryExecute(xml, steps, stepCount, result)
}


/**
 * @function NAVXmlQueryString
 * @public
 * @description Query for text content as a string.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {char[]} query - The query string (e.g., ".config.name")
 * @param {char[]} result - Output parameter for the text content
 *
 * @returns {char} True (1) if query succeeded, False (0) otherwise
 */
define_function char NAVXmlQueryString(_NAVXml xml, char query[], char result[]) {
    stack_var _NAVXmlQueryToken tokens[NAV_XML_QUERY_MAX_TOKENS]
    stack_var _NAVXmlQueryPathStep steps[NAV_XML_QUERY_MAX_PATH_STEPS]
    stack_var integer tokenCount
    stack_var integer stepCount
    stack_var integer nodeIndex

    // Tokenize query
    tokenCount = NAVXmlQueryLexer(query, tokens)
    if (tokenCount == 0) {
        return false
    }

    // Parse tokens into steps
    stepCount = NAVXmlQueryParser(tokens, tokenCount, steps)
    if (stepCount == 0) {
        return false
    }

    // Handle attribute queries
    if (stepCount > 0 && steps[stepCount].type == NAV_XML_QUERY_STEP_ATTRIBUTE) {
        stack_var _NAVXmlNode node
        if (!NAVXmlQueryExecute(xml, steps, stepCount, node)) {
            return false
        }
        result = node.value
        return true
    }

    // Execute query to get node index
    nodeIndex = NAVXmlQueryExecuteIndex(xml, steps, stepCount)
    if (nodeIndex == 0) {
        return false
    }

    // Get text content from the specific node
    result = ''
    NAVXmlGetNodeTextContent(xml, nodeIndex, result)
    return true
}


/**
 * @function NAVXmlQueryInteger
 * @public
 * @description Query for numeric content as an unsigned integer.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {char[]} query - The query string (e.g., ".config.port")
 * @param {integer} result - Output parameter for the integer value
 *
 * @returns {char} True (1) if query succeeded and value is valid, False (0) otherwise
 */
define_function char NAVXmlQueryInteger(_NAVXml xml, char query[], integer result) {
    stack_var char value[255]
    stack_var integer parsedValue

    if (!NAVXmlQueryString(xml, query, value)) {
        return false
    }

    if (!NAVParseInteger(value, parsedValue)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_XML_QUERY__,
                                    'NAVXmlQueryInteger',
                                    "'Failed to parse integer: ', value")
        return false
    }

    result = parsedValue
    return true
}


/**
 * @function NAVXmlQueryFloat
 * @public
 * @description Query for numeric content as a float.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {char[]} query - The query string (e.g., ".config.temperature")
 * @param {float} result - Output parameter for the float value
 *
 * @returns {char} True (1) if query succeeded and value is valid, False (0) otherwise
 */
define_function char NAVXmlQueryFloat(_NAVXml xml, char query[], float result) {
    stack_var char value[255]
    stack_var float parsedValue

    if (!NAVXmlQueryString(xml, query, value)) {
        return false
    }

    if (!NAVParseFloat(value, parsedValue)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_XML_QUERY__,
                                    'NAVXmlQueryFloat',
                                    "'Failed to parse float: ', value")
        return false
    }

    result = parsedValue
    return true
}


/**
 * @function NAVXmlQueryLong
 * @public
 * @description Query for numeric content as a long integer.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {char[]} query - The query string (e.g., ".config.timestamp")
 * @param {long} result - Output parameter for the long value
 *
 * @returns {char} True (1) if query succeeded and value is valid, False (0) otherwise
 */
define_function char NAVXmlQueryLong(_NAVXml xml, char query[], long result) {
    stack_var char value[255]
    stack_var long parsedValue

    if (!NAVXmlQueryString(xml, query, value)) {
        return false
    }

    if (!NAVParseLong(value, parsedValue)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_XML_QUERY__,
                                    'NAVXmlQueryLong',
                                    "'Failed to parse long: ', value")
        return false
    }

    result = parsedValue
    return true
}


/**
 * @function NAVXmlQueryBoolean
 * @public
 * @description Query for boolean content.
 * Accepts "true"/"false", "1"/"0", "yes"/"no", "on"/"off" (case-insensitive).
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {char[]} query - The query string (e.g., ".config.enabled")
 * @param {char} result - Output parameter for the boolean value (1 = true, 0 = false)
 *
 * @returns {char} True (1) if query succeeded and value is valid boolean, False (0) otherwise
 */
define_function char NAVXmlQueryBoolean(_NAVXml xml, char query[], char result) {
    stack_var char value[255]
    stack_var char lowerValue[255]

    if (!NAVXmlQueryString(xml, query, value)) {
        return false
    }

    lowerValue = lower_string(value)

    select {
        active (lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes' || lowerValue == 'on'): {
            result = true
            return true
        }
        active (lowerValue == 'false' || lowerValue == '0' || lowerValue == 'no' || lowerValue == 'off'): {
            result = false
            return true
        }
        active (1): {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_XML_QUERY__,
                                        'NAVXmlQueryBoolean',
                                        "'Invalid boolean value: ', value")
            return false
        }
    }
}


(***********************************************************)
(*          ARRAY CONVERSION HELPER FUNCTIONS              *)
(***********************************************************)

/**
 * @function NAVXmlToStringArray
 * @public
 * @description Converts an XML element's children to a string array.
 * Extracts text content from all child elements.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {_NAVXmlNode} parentNode - The parent element node
 * @param {char[][]} result - The resulting string array (output parameter)
 *
 * @returns {char} True if successful, False otherwise
 */
define_function char NAVXmlToStringArray(_NAVXml xml, _NAVXmlNode parentNode, char result[][]) {
    stack_var integer count
    stack_var integer i
    stack_var integer childIndex
    stack_var char textContent[NAV_XML_PARSER_MAX_TEXT_LENGTH]

    if (parentNode.type != NAV_XML_TYPE_ELEMENT) {
        return false
    }

    count = NAVXmlGetElementChildCount(xml, parentNode)

    if (count == 0) {
        set_length_array(result, 0)
        return true
    }

    // Extract text content from each child
    i = 1
    childIndex = parentNode.firstChild

    while (childIndex > 0) {
        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT) {
            textContent = ''
            NAVXmlGetNodeTextContent(xml, childIndex, textContent)
            result[i] = textContent
            i++
        }

        childIndex = xml.nodes[childIndex].nextSibling
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVXmlToIntegerArray
 * @public
 * @description Converts an XML element's children to an integer array (unsigned 16-bit: 0-65535).
 * All child elements must contain valid integer text content.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {_NAVXmlNode} parentNode - The parent element node
 * @param {integer[]} result - The resulting integer array (output parameter)
 *
 * @returns {char} True if successful, False if parsing fails
 */
define_function char NAVXmlToIntegerArray(_NAVXml xml, _NAVXmlNode parentNode, integer result[]) {
    stack_var integer count
    stack_var integer i
    stack_var integer childIndex
    stack_var char textContent[NAV_XML_PARSER_MAX_TEXT_LENGTH]

    if (parentNode.type != NAV_XML_TYPE_ELEMENT) {
        return false
    }

    count = NAVXmlGetElementChildCount(xml, parentNode)

    if (count == 0) {
        set_length_array(result, 0)
        return true
    }

    // Extract and parse integer values
    i = 1
    childIndex = parentNode.firstChild

    while (childIndex > 0) {
        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT) {
            stack_var integer value

            textContent = ''
            NAVXmlGetNodeTextContent(xml, childIndex, textContent)

            if (!NAVParseInteger(textContent, value)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_XML_QUERY__,
                                            'NAVXmlToIntegerArray',
                                            "'Failed to parse element ', itoa(i), ': ', textContent")
                return false
            }

            result[i] = value
            i++
        }

        childIndex = xml.nodes[childIndex].nextSibling
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVXmlToLongArray
 * @public
 * @description Converts an XML element's children to a long array (unsigned 32-bit: 0-4294967295).
 * All child elements must contain valid long integer text content.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {_NAVXmlNode} parentNode - The parent element node
 * @param {long[]} result - The resulting long array (output parameter)
 *
 * @returns {char} True if successful, False if parsing fails
 */
define_function char NAVXmlToLongArray(_NAVXml xml, _NAVXmlNode parentNode, long result[]) {
    stack_var integer count
    stack_var integer i
    stack_var integer childIndex
    stack_var char textContent[NAV_XML_PARSER_MAX_TEXT_LENGTH]

    if (parentNode.type != NAV_XML_TYPE_ELEMENT) {
        return false
    }

    count = NAVXmlGetElementChildCount(xml, parentNode)

    if (count == 0) {
        set_length_array(result, 0)
        return true
    }

    // Extract and parse long values
    i = 1
    childIndex = parentNode.firstChild

    while (childIndex > 0) {
        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT) {
            stack_var long value

            textContent = ''
            NAVXmlGetNodeTextContent(xml, childIndex, textContent)

            if (!NAVParseLong(textContent, value)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_XML_QUERY__,
                                            'NAVXmlToLongArray',
                                            "'Failed to parse element ', itoa(i), ': ', textContent")
                return false
            }

            result[i] = value
            i++
        }

        childIndex = xml.nodes[childIndex].nextSibling
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVXmlToFloatArray
 * @public
 * @description Converts an XML element's children to a float array.
 * All child elements must contain valid numeric text content.
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {_NAVXmlNode} parentNode - The parent element node
 * @param {float[]} result - The resulting float array (output parameter)
 *
 * @returns {char} True if successful, False if parsing fails
 */
define_function char NAVXmlToFloatArray(_NAVXml xml, _NAVXmlNode parentNode, float result[]) {
    stack_var integer count
    stack_var integer i
    stack_var integer childIndex
    stack_var char textContent[NAV_XML_PARSER_MAX_TEXT_LENGTH]

    if (parentNode.type != NAV_XML_TYPE_ELEMENT) {
        return false
    }

    count = NAVXmlGetElementChildCount(xml, parentNode)

    if (count == 0) {
        set_length_array(result, 0)
        return true
    }

    // Extract and parse float values
    i = 1
    childIndex = parentNode.firstChild

    while (childIndex > 0) {
        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT) {
            stack_var float value

            textContent = ''
            NAVXmlGetNodeTextContent(xml, childIndex, textContent)

            if (!NAVParseFloat(textContent, value)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_XML_QUERY__,
                                            'NAVXmlToFloatArray',
                                            "'Failed to parse element ', itoa(i), ': ', textContent")
                return false
            }

            result[i] = value
            i++
        }

        childIndex = xml.nodes[childIndex].nextSibling
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVXmlToBooleanArray
 * @public
 * @description Converts an XML element's children to a boolean array.
 * All child elements must contain valid boolean text content (true/false, 1/0, yes/no, on/off).
 *
 * @param {_NAVXml} xml - The XML structure
 * @param {_NAVXmlNode} parentNode - The parent element node
 * @param {char[]} result - The resulting boolean array (output parameter)
 *
 * @returns {char} True if successful, False if any element contains invalid boolean value
 */
define_function char NAVXmlToBooleanArray(_NAVXml xml, _NAVXmlNode parentNode, char result[]) {
    stack_var integer count
    stack_var integer i
    stack_var integer childIndex
    stack_var char textContent[NAV_XML_PARSER_MAX_TEXT_LENGTH]

    if (parentNode.type != NAV_XML_TYPE_ELEMENT) {
        return false
    }

    count = NAVXmlGetElementChildCount(xml, parentNode)

    if (count == 0) {
        set_length_array(result, 0)
        return true
    }

    // Extract and parse boolean values
    i = 1
    childIndex = parentNode.firstChild

    while (childIndex > 0) {
        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT) {
            textContent = ''

            NAVXmlGetNodeTextContent(xml, childIndex, textContent)
            textContent = lower_string(textContent)

            select {
                active (textContent == 'true' || textContent == '1' || textContent == 'yes' || textContent == 'on'): {
                    result[i] = true
                }
                active (textContent == 'false' || textContent == '0' || textContent == 'no' || textContent == 'off'): {
                    result[i] = false
                }
                active (1): {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_XML_QUERY__,
                                                'NAVXmlToBooleanArray',
                                                "'Invalid boolean value in element ', itoa(i), ': ', textContent")
                    return false
                }
            }

            i++
        }

        childIndex = xml.nodes[childIndex].nextSibling
    }

    set_length_array(result, count)
    return true
}


(***********************************************************)
(*            TYPE-SPECIFIC ARRAY QUERY FUNCTIONS          *)
(***********************************************************)

/**
 * @function NAVXmlQueryStringArray
 * @public
 * @description Queries for a string array at the specified path.
 * Extracts text content from all child elements of the queried element.
 *
 * @param {_NAVXml} xml - The XML structure to query
 * @param {char[]} query - The query string (e.g., ".items")
 * @param {char[][]} result - The resulting string array (output parameter)
 *
 * @returns {char} True if successful, False otherwise
 *
 * @example
 * stack_var char names[50][64]
 * if (NAVXmlQueryStringArray(xml, '.users.user', names)) {
 *     // Use names array
 * }
 */
define_function char NAVXmlQueryStringArray(_NAVXml xml, char query[], char result[][]) {
    stack_var _NAVXmlNode node

    if (!NAVXmlQuery(xml, query, node)) {
        return false
    }

    return NAVXmlToStringArray(xml, node, result)
}


/**
 * @function NAVXmlQueryIntegerArray
 * @public
 * @description Queries for an integer array at the specified path.
 * Parses text content from all child elements as integers.
 *
 * @param {_NAVXml} xml - The XML structure to query
 * @param {char[]} query - The query string (e.g., ".config.ports.port")
 * @param {integer[]} result - The resulting integer array (output parameter)
 *
 * @returns {char} True if successful, False otherwise
 *
 * @example
 * stack_var integer ports[50]
 * if (NAVXmlQueryIntegerArray(xml, '.config.ports', ports)) {
 *     // Use ports array
 * }
 */
define_function char NAVXmlQueryIntegerArray(_NAVXml xml, char query[], integer result[]) {
    stack_var _NAVXmlNode node

    if (!NAVXmlQuery(xml, query, node)) {
        return false
    }

    return NAVXmlToIntegerArray(xml, node, result)
}


/**
 * @function NAVXmlQueryLongArray
 * @public
 * @description Queries for a long array at the specified path.
 * Parses text content from all child elements as long integers.
 *
 * @param {_NAVXml} xml - The XML structure to query
 * @param {char[]} query - The query string (e.g., ".data.timestamps.timestamp")
 * @param {long[]} result - The resulting long array (output parameter)
 *
 * @returns {char} True if successful, False otherwise
 *
 * @example
 * stack_var long timestamps[100]
 * if (NAVXmlQueryLongArray(xml, '.log.entries', timestamps)) {
 *     // Use timestamps array
 * }
 */
define_function char NAVXmlQueryLongArray(_NAVXml xml, char query[], long result[]) {
    stack_var _NAVXmlNode node

    if (!NAVXmlQuery(xml, query, node)) {
        return false
    }

    return NAVXmlToLongArray(xml, node, result)
}


/**
 * @function NAVXmlQueryFloatArray
 * @public
 * @description Queries for a float array at the specified path.
 * Parses text content from all child elements as floats.
 *
 * @param {_NAVXml} xml - The XML structure to query
 * @param {char[]} query - The query string (e.g., ".sensors.temperature")
 * @param {float[]} result - The resulting float array (output parameter)
 *
 * @returns {char} True if successful, False otherwise
 *
 * @example
 * stack_var float temperatures[100]
 * if (NAVXmlQueryFloatArray(xml, '.sensors', temperatures)) {
 *     // Use temperatures array
 * }
 */
define_function char NAVXmlQueryFloatArray(_NAVXml xml, char query[], float result[]) {
    stack_var _NAVXmlNode node

    if (!NAVXmlQuery(xml, query, node)) {
        return false
    }

    return NAVXmlToFloatArray(xml, node, result)
}


/**
 * @function NAVXmlQueryBooleanArray
 * @public
 * @description Queries for a boolean array at the specified path.
 * Parses text content from all child elements as booleans.
 *
 * @param {_NAVXml} xml - The XML structure to query
 * @param {char[]} query - The query string (e.g., ".settings.flags.flag")
 * @param {char[]} result - The resulting boolean array (output parameter)
 *
 * @returns {char} True if successful, False otherwise
 *
 * @example
 * stack_var char flags[50]
 * if (NAVXmlQueryBooleanArray(xml, '.settings.flags', flags)) {
 *     // Use flags array
 * }
 */
define_function char NAVXmlQueryBooleanArray(_NAVXml xml, char query[], char result[]) {
    stack_var _NAVXmlNode node

    if (!NAVXmlQuery(xml, query, node)) {
        return false
    }

    return NAVXmlToBooleanArray(xml, node, result)
}


/**
 * @function NAVXmlQueryAttribute
 * @public
 * @description Query for an attribute value.
 *
 * @param {_NAVXml} xml - The parsed XML document
 * @param {char[]} elementQuery - Query path to the element (e.g., ".config.server")
 * @param {char[]} attrName - Name of the attribute
 * @param {char[]} result - Output parameter for the attribute value
 *
 * @returns {char} True (1) if attribute found, False (0) otherwise
 */
define_function char NAVXmlQueryAttribute(_NAVXml xml, char elementQuery[], char attrName[], char result[]) {
    stack_var _NAVXmlNode node
    stack_var integer i

    if (!NAVXmlQuery(xml, elementQuery, node)) {
        return false
    }

    // Find the node in the tree
    for (i = 1; i <= xml.nodeCount; i++) {
        if (xml.nodes[i].type == node.type &&
            xml.nodes[i].name == node.name) {
            return NAVXmlGetAttributeValue(xml, i, attrName, result)
        }
    }

    return false
}


/**
 * @function NAVXmlQuerySignedInteger
 * @public
 * @description Queries for a signed integer value (signed 16-bit: -32768 to 32767) at the specified path.
 *
 * @param {_NAVXml} xml - The XML structure to query
 * @param {char[]} query - The query string
 * @param {sinteger} result - The resulting signed integer value (output parameter)
 *
 * @returns {char} true if successful and result is a valid signed integer, false otherwise
 *
 * @example
 * stack_var sinteger offset
 * if (NAVXmlQuerySignedInteger(xml, '.data.offset', offset)) {
 *     // Use offset
 * }
 */
define_function char NAVXmlQuerySignedInteger(_NAVXml xml, char query[], sinteger result) {
    stack_var char value[255]
    stack_var sinteger parsedValue

    if (!NAVXmlQueryString(xml, query, value)) {
        return false
    }

    if (!NAVParseSignedInteger(value, parsedValue)) {
        return false
    }

    result = parsedValue
    return true
}


/**
 * @function NAVXmlQuerySignedLong
 * @public
 * @description Queries for a signed long value (signed 32-bit: -2147483648 to 2147483647) at the specified path.
 *
 * @param {_NAVXml} xml - The XML structure to query
 * @param {char[]} query - The query string
 * @param {slong} result - The resulting signed long value (output parameter)
 *
 * @returns {char} true if successful and result is a valid signed long, false otherwise
 *
 * @example
 * stack_var slong signedValue
 * if (NAVXmlQuerySignedLong(xml, '.data.value', signedValue)) {
 *     // Use signedValue
 * }
 */
define_function char NAVXmlQuerySignedLong(_NAVXml xml, char query[], slong result) {
    stack_var char value[255]
    stack_var slong parsedValue

    if (!NAVXmlQueryString(xml, query, value)) {
        return false
    }

    if (!NAVParseSignedLong(value, parsedValue)) {
        return false
    }

    result = parsedValue
    return true
}


/**
 * @function NAVXmlQuerySignedIntegerArray
 * @public
 * @description Queries for a signed integer array (signed 16-bit: -32768 to 32767) at the specified path.
 *
 * @param {_NAVXml} xml - The XML structure to query
 * @param {char[]} query - The query string
 * @param {sinteger[]} result - The resulting signed integer array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var sinteger offsets[100]
 * if (NAVXmlQuerySignedIntegerArray(xml, '.data.offsets', offsets)) {
 *     // Use offsets array
 * }
 */
define_function char NAVXmlQuerySignedIntegerArray(_NAVXml xml, char query[], sinteger result[]) {
    stack_var _NAVXmlNode node
    stack_var integer count
    stack_var integer i
    stack_var integer childIndex
    stack_var char textContent[NAV_XML_PARSER_MAX_TEXT_LENGTH]

    if (!NAVXmlQuery(xml, query, node)) {
        return false
    }

    if (node.type != NAV_XML_TYPE_ELEMENT) {
        return false
    }

    count = NAVXmlGetElementChildCount(xml, node)

    if (count == 0) {
        set_length_array(result, 0)
        return true
    }

    // Extract and parse signed integer values
    i = 1
    childIndex = node.firstChild

    while (childIndex > 0) {
        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT) {
            stack_var sinteger value

            textContent = ''
            NAVXmlGetNodeTextContent(xml, childIndex, textContent)

            if (!NAVParseSignedInteger(textContent, value)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_XML_QUERY__,
                                            'NAVXmlQuerySignedIntegerArray',
                                            "'Failed to parse element ', itoa(i), ': ', textContent")
                return false
            }

            result[i] = value
            i++
        }

        childIndex = xml.nodes[childIndex].nextSibling
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVXmlQuerySignedLongArray
 * @public
 * @description Queries for a signed long array (signed 32-bit: -2147483648 to 2147483647) at the specified path.
 *
 * @param {_NAVXml} xml - The XML structure to query
 * @param {char[]} query - The query string
 * @param {slong[]} result - The resulting signed long array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var slong values[100]
 * if (NAVXmlQuerySignedLongArray(xml, '.data.values', values)) {
 *     // Use values array
 * }
 */
define_function char NAVXmlQuerySignedLongArray(_NAVXml xml, char query[], slong result[]) {
    stack_var _NAVXmlNode node
    stack_var integer count
    stack_var integer i
    stack_var integer childIndex
    stack_var char textContent[NAV_XML_PARSER_MAX_TEXT_LENGTH]

    if (!NAVXmlQuery(xml, query, node)) {
        return false
    }

    if (node.type != NAV_XML_TYPE_ELEMENT) {
        return false
    }

    count = NAVXmlGetElementChildCount(xml, node)

    if (count == 0) {
        set_length_array(result, 0)
        return true
    }

    // Extract and parse signed long values
    i = 1
    childIndex = node.firstChild

    while (childIndex > 0) {
        if (xml.nodes[childIndex].type == NAV_XML_TYPE_ELEMENT) {
            stack_var slong value

            textContent = ''
            NAVXmlGetNodeTextContent(xml, childIndex, textContent)

            if (!NAVParseSignedLong(textContent, value)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_XML_QUERY__,
                                            'NAVXmlQuerySignedLongArray',
                                            "'Failed to parse element ', itoa(i), ': ', textContent")
                return false
            }

            result[i] = value
            i++
        }

        childIndex = xml.nodes[childIndex].nextSibling
    }

    set_length_array(result, count)
    return true
}


#END_IF // __NAV_FOUNDATION_XML_QUERY__
