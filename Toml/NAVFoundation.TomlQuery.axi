PROGRAM_NAME='NAVFoundation.TomlQuery'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TOML_QUERY__
#DEFINE __NAV_FOUNDATION_TOML_QUERY__ 'NAVFoundation.TomlQuery'

#include 'NAVFoundation.TomlParser.axi'
#include 'NAVFoundation.TomlQuery.h.axi'


(***********************************************************)
(*               QUERY LEXER FUNCTIONS                     *)
(***********************************************************)

/**
 * @function NAVTomlQueryLexer
 * @private
 * @description Tokenizes a TOML query string into tokens for parsing.
 * Converts a query string into a sequence of tokens representing dots, identifiers,
 * brackets, and numbers.
 *
 * @param {char[]} query - The query string to tokenize (e.g., ".database.server", ".ports[0]")
 * @param {_NAVTomlQueryToken[]} tokens - Array to store the resulting tokens
 *
 * @returns {integer} Number of tokens generated, or 0 on error
 *
 * @example
 * stack_var _NAVTomlQueryToken tokens[NAV_TOML_QUERY_MAX_TOKENS]
 * stack_var integer count
 * count = NAVTomlQueryLexer('.database.server', tokens)
 */
define_function integer NAVTomlQueryLexer(char query[], _NAVTomlQueryToken tokens[]) {
    stack_var integer pos
    stack_var integer tokenCount
    stack_var char ch
    stack_var integer queryLength

    #IF_DEFINED TOML_QUERY_DEBUG
    NAVLog("'[ TomlQueryLexer ]: Starting tokenization of query: ', query")
    #END_IF

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
        if (tokenCount >= NAV_TOML_QUERY_MAX_TOKENS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_TOML_QUERY__,
                                        'NAVTomlQueryLexer',
                                        "'Too many tokens in query (max: ', itoa(NAV_TOML_QUERY_MAX_TOKENS), ')'")
            return 0
        }

        tokenCount++

        select {
            // DOT
            active (ch == '.'): {
                tokens[tokenCount].type = NAV_TOML_QUERY_TOKEN_DOT

                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryLexer ]: Token ', itoa(tokenCount), ': ', NAVTomlQueryTokenTypeToString(tokens[tokenCount].type)")
                #END_IF

                pos++
            }

            // LEFT_BRACKET
            active (ch == '['): {
                tokens[tokenCount].type = NAV_TOML_QUERY_TOKEN_LEFT_BRACKET

                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryLexer ]: Token ', itoa(tokenCount), ': ', NAVTomlQueryTokenTypeToString(tokens[tokenCount].type)")
                #END_IF

                pos++
            }

            // RIGHT_BRACKET
            active (ch == ']'): {
                tokens[tokenCount].type = NAV_TOML_QUERY_TOKEN_RIGHT_BRACKET

                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryLexer ]: Token ', itoa(tokenCount), ': ', NAVTomlQueryTokenTypeToString(tokens[tokenCount].type)")
                #END_IF

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
                tokens[tokenCount].type = NAV_TOML_QUERY_TOKEN_NUMBER
                tokens[tokenCount].number = atoi(numStr)

                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryLexer ]: Token ', itoa(tokenCount), ': ', NAVTomlQueryTokenTypeToString(tokens[tokenCount].type), ' = ', numStr")
                #END_IF
            }

            // IDENTIFIER
            active (NAVIsAlpha(ch) || ch == '_' || ch == '-'): {
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

                tokens[tokenCount].type = NAV_TOML_QUERY_TOKEN_IDENTIFIER
                tokens[tokenCount].identifier = NAVStringSubstring(query, startPos, pos - startPos)

                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryLexer ]: Token ', itoa(tokenCount), ': ', NAVTomlQueryTokenTypeToString(tokens[tokenCount].type), ' = ', tokens[tokenCount].identifier")
                #END_IF
            }

            // Unknown character
            active (1): {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_TOML_QUERY__,
                                            'NAVTomlQueryLexer',
                                            "'Unexpected character: ', ch, ' (', itoa(ch), ') at position ', itoa(pos)")
                return 0
            }
        }
    }

    #IF_DEFINED TOML_QUERY_DEBUG
    NAVLog("'[ TomlQueryLexer ]: Tokenization complete. Token count: ', itoa(tokenCount)")
    #END_IF

    return tokenCount
}


/**
 * @function NAVTomlQueryTokenTypeToString
 * @private
 * @description Converts a token type constant to its string name for debugging.
 *
 * @param {integer} tokenType - The token type constant
 *
 * @returns {char[]} The string name of the token type
 */
define_function char[20] NAVTomlQueryTokenTypeToString(integer tokenType) {
    switch (tokenType) {
        case NAV_TOML_QUERY_TOKEN_DOT:            return 'DOT'
        case NAV_TOML_QUERY_TOKEN_IDENTIFIER:     return 'IDENTIFIER'
        case NAV_TOML_QUERY_TOKEN_LEFT_BRACKET:   return 'LEFT_BRACKET'
        case NAV_TOML_QUERY_TOKEN_RIGHT_BRACKET:  return 'RIGHT_BRACKET'
        case NAV_TOML_QUERY_TOKEN_NUMBER:         return 'NUMBER'
        default:                                  return 'UNKNOWN'
    }
}


(***********************************************************)
(*               QUERY PARSER FUNCTIONS                    *)
(***********************************************************)

/**
 * @function NAVTomlQueryParser
 * @private
 * @description Parses tokens into executable path steps.
 * Validates token sequence and converts tokens into navigation steps that can be
 * executed against a TOML tree.
 *
 * @param {_NAVTomlQueryToken[]} tokens - Array of tokens from the lexer
 * @param {integer} tokenCount - Number of tokens
 * @param {_NAVTomlQueryPathStep[]} steps - Array to store the resulting path steps
 *
 * @returns {integer} Number of steps generated, or 0 on error
 *
 * @example
 * stack_var _NAVTomlQueryPathStep steps[NAV_TOML_QUERY_MAX_PATH_STEPS]
 * stack_var integer stepCount
 * stepCount = NAVTomlQueryParser(tokens, tokenCount, steps)
 */
define_function integer NAVTomlQueryParser(_NAVTomlQueryToken tokens[], integer tokenCount, _NAVTomlQueryPathStep steps[]) {
    stack_var integer pos
    stack_var integer stepCount

    #IF_DEFINED TOML_QUERY_DEBUG
    NAVLog("'[ TomlQueryParser ]: Starting parsing. Token count: ', itoa(tokenCount)")
    #END_IF

    pos = 1
    stepCount = 0

    // Query must start with DOT
    if (tokenCount == 0 || tokens[pos].type != NAV_TOML_QUERY_TOKEN_DOT) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_TOML_QUERY__,
                                    'NAVTomlQueryParser',
                                    "'Query must start with . (dot)'")
        return 0
    }

    pos++ // Skip initial DOT

    // Check if query is just "." (root)
    if (pos > tokenCount) {
        #IF_DEFINED TOML_QUERY_DEBUG
        NAVLog("'[ TomlQueryParser ]: Root query detected (no steps)'")
        #END_IF

        stepCount++
        steps[stepCount].type = NAV_TOML_QUERY_STEP_ROOT
        return stepCount
    }

    while (pos <= tokenCount) {
        if (stepCount >= NAV_TOML_QUERY_MAX_PATH_STEPS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_TOML_QUERY__,
                                        'NAVTomlQueryParser',
                                        "'Too many path steps (max: ', itoa(NAV_TOML_QUERY_MAX_PATH_STEPS), ')'")
            return 0
        }

        stepCount++

        select {
            // Property access: IDENTIFIER
            active (tokens[pos].type == NAV_TOML_QUERY_TOKEN_IDENTIFIER): {
                steps[stepCount].type = NAV_TOML_QUERY_STEP_PROPERTY
                steps[stepCount].propertyKey = tokens[pos].identifier

                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryParser ]: Step ', itoa(stepCount), ': PROPERTY = ', steps[stepCount].propertyKey")
                #END_IF

                pos++

                // Check for array index following property: [NUMBER]
                if (pos <= tokenCount && tokens[pos].type == NAV_TOML_QUERY_TOKEN_LEFT_BRACKET) {
                    pos++

                    if (pos > tokenCount || tokens[pos].type != NAV_TOML_QUERY_TOKEN_NUMBER) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_TOML_QUERY__,
                                                    'NAVTomlQueryParser',
                                                    "'Expected number after ['")
                        return 0
                    }

                    stepCount++
                    steps[stepCount].type = NAV_TOML_QUERY_STEP_ARRAY_INDEX
                    steps[stepCount].arrayIndex = tokens[pos].number

                    #IF_DEFINED TOML_QUERY_DEBUG
                    NAVLog("'[ TomlQueryParser ]: Step ', itoa(stepCount), ': INDEX = ', itoa(steps[stepCount].arrayIndex)")
                    #END_IF

                    pos++

                    if (pos > tokenCount || tokens[pos].type != NAV_TOML_QUERY_TOKEN_RIGHT_BRACKET) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_TOML_QUERY__,
                                                    'NAVTomlQueryParser',
                                                    "'Expected ] after array index'")
                        return 0
                    }
                    pos++
                }

                // Check for continuation with DOT
                if (pos <= tokenCount && tokens[pos].type == NAV_TOML_QUERY_TOKEN_DOT) {
                    pos++
                }
            }

            // Direct array access: [NUMBER]
            active (tokens[pos].type == NAV_TOML_QUERY_TOKEN_LEFT_BRACKET): {
                pos++

                if (pos > tokenCount || tokens[pos].type != NAV_TOML_QUERY_TOKEN_NUMBER) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_TOML_QUERY__,
                                                'NAVTomlQueryParser',
                                                "'Expected number after ['")
                    return 0
                }

                steps[stepCount].type = NAV_TOML_QUERY_STEP_ARRAY_INDEX
                steps[stepCount].arrayIndex = tokens[pos].number

                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryParser ]: Step ', itoa(stepCount), ': INDEX = ', itoa(steps[stepCount].arrayIndex)")
                #END_IF

                pos++

                if (pos > tokenCount || tokens[pos].type != NAV_TOML_QUERY_TOKEN_RIGHT_BRACKET) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_TOML_QUERY__,
                                                'NAVTomlQueryParser',
                                                "'Expected ] after array index'")
                    return 0
                }
                pos++

                // Check for continuation with DOT
                if (pos <= tokenCount && tokens[pos].type == NAV_TOML_QUERY_TOKEN_DOT) {
                    pos++
                }
            }

            active (1): {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_TOML_QUERY__,
                                            'NAVTomlQueryParser',
                                            "'Unexpected token type: ', itoa(tokens[pos].type)")
                return 0
            }
        }
    }

    #IF_DEFINED TOML_QUERY_DEBUG
    NAVLog("'[ TomlQueryParser ]: Parsing complete. Step count: ', itoa(stepCount)")
    #END_IF

    return stepCount
}


(***********************************************************)
(*          NAVIGATION AND ACCESSOR FUNCTIONS              *)
(***********************************************************)

/**
 * @function NAVTomlGetNode
 * @private
 * @description Internal function to get a TOML node by its index.
 *
 * @param {_NAVToml} toml - The parsed TOML structure
 * @param {integer} nodeIndex - Index of the node to retrieve (1-based)
 * @param {_NAVTomlNode} node - Output parameter to receive the node data
 *
 * @returns {char} True (1) if node exists, False (0) if invalid index
 */
define_function char NAVTomlGetNode(_NAVToml toml, integer nodeIndex, _NAVTomlNode node) {
    // Validate node index
    if (nodeIndex < 1 || nodeIndex > toml.nodeCount) {
        return false
    }

    // Copy node data to output parameter
    node = toml.nodes[nodeIndex]

    return true
}


/**
 * @function NAVTomlGetRootNode
 * @public
 * @description Get the root node of the TOML document.
 *
 * @param {_NAVToml} toml - The parsed TOML structure
 * @param {_NAVTomlNode} node - Output parameter to receive the root node
 *
 * @returns {char} True (1) if successful, False (0) otherwise
 */
define_function char NAVTomlGetRootNode(_NAVToml toml, _NAVTomlNode node) {
    return NAVTomlGetNode(toml, toml.rootIndex, node)
}


/**
 * @function NAVTomlGetPropertyByKey
 * @public
 * @description Get a child node by key name from a table node.
 *
 * @param {_NAVToml} toml - The parsed TOML structure
 * @param {_NAVTomlNode} parentNode - The parent table node
 * @param {char[]} key - The key to search for
 * @param {_NAVTomlNode} result - Output parameter to receive the found node
 *
 * @returns {char} True (1) if found, False (0) if not found
 */
define_function char NAVTomlGetPropertyByKey(_NAVToml toml, _NAVTomlNode parentNode, char key[], _NAVTomlNode result) {
    stack_var integer childIndex
    stack_var _NAVTomlNode childNode

    #IF_DEFINED TOML_QUERY_DEBUG
    NAVLog("'[ TomlGetPropertyByKey ]: Searching for key="', key, '" in parent node type=', itoa(parentNode.type)")
    #END_IF

    // Parent must be a table
    if (parentNode.type != NAV_TOML_VALUE_TYPE_TABLE &&
        parentNode.type != NAV_TOML_VALUE_TYPE_INLINE_TABLE) {
        return false
    }

    childIndex = parentNode.firstChild

    while (childIndex != 0) {
        if (!NAVTomlGetNode(toml, childIndex, childNode)) {
            return false
        }

        #IF_DEFINED TOML_QUERY_DEBUG
        NAVLog("'[ TomlGetPropertyByKey ]: Checking child key="', childNode.key, '"'")
        #END_IF

        if (childNode.key == key) {
            result = childNode
            return true
        }

        childIndex = childNode.nextSibling
    }

    return false
}


/**
 * @function NAVTomlGetArrayElement
 * @public
 * @description Get an element from an array by index (0-based).
 *
 * @param {_NAVToml} toml - The parsed TOML structure
 * @param {_NAVTomlNode} arrayNode - The array node
 * @param {integer} index - The index (0-based)
 * @param {_NAVTomlNode} result - Output parameter to receive the element
 *
 * @returns {char} True (1) if found, False (0) if out of bounds
 */
define_function char NAVTomlGetArrayElement(_NAVToml toml, _NAVTomlNode arrayNode, integer index, _NAVTomlNode result) {
    stack_var integer childIndex
    stack_var integer currentIndex
    stack_var _NAVTomlNode childNode

    // Node must be an array or array of tables
    if (arrayNode.type != NAV_TOML_VALUE_TYPE_ARRAY &&
        arrayNode.type != NAV_TOML_VALUE_TYPE_TABLE_ARRAY) {
        return false
    }

    // Check bounds
    if (index < 0 || index >= arrayNode.childCount) {
        return false
    }

    childIndex = arrayNode.firstChild
    currentIndex = 0

    while (childIndex != 0) {
        if (currentIndex == index) {
            return NAVTomlGetNode(toml, childIndex, result)
        }

        if (!NAVTomlGetNode(toml, childIndex, childNode)) {
            return false
        }

        currentIndex++
        childIndex = childNode.nextSibling
    }

    return false
}


/**
 * @function NAVTomlGetParentNode
 * @public
 * @description Get the parent node of the current node.
 *
 * @param {_NAVToml} toml - The parsed TOML structure
 * @param {_NAVTomlNode} currentNode - The current node
 * @param {_NAVTomlNode} parentNode - Output parameter to receive the parent node
 *
 * @returns {char} True (1) if parent exists, False (0) if at root
 */
define_function char NAVTomlGetParentNode(_NAVToml toml, _NAVTomlNode currentNode, _NAVTomlNode parentNode) {
    if (currentNode.parent == 0) {
        return false
    }

    return NAVTomlGetNode(toml, currentNode.parent, parentNode)
}


/**
 * @function NAVTomlGetFirstChild
 * @public
 * @description Get the first child node of a parent node.
 *
 * This function retrieves the first child of the given parent node. Use this to
 * begin iterating over the children of a table or array. Returns false if the
 * parent has no children.
 *
 * @param {_NAVToml} toml - The parsed TOML structure
 * @param {_NAVTomlNode} parentNode - The parent node
 * @param {_NAVTomlNode} childNode - Output parameter to receive the first child node
 *
 * @returns {char} True (1) if parent has children, False (0) if no children
 *
 * @example
 * stack_var _NAVToml toml
 * stack_var _NAVTomlNode root, child
 *
 * NAVTomlParse('[server]\nhost = "localhost"', toml)
 * NAVTomlGetRootNode(toml, root)
 *
 * // Iterate all properties
 * if (NAVTomlGetFirstChild(toml, root, child)) {
 *     do {
 *         send_string 0, "child.key, ': ', child.value"
 *     } while (NAVTomlGetNextNode(toml, child, child))
 * }
 */
define_function char NAVTomlGetFirstChild(_NAVToml toml, _NAVTomlNode parentNode, _NAVTomlNode childNode) {
    if (parentNode.firstChild == 0) {
        return false
    }

    return NAVTomlGetNode(toml, parentNode.firstChild, childNode)
}


/**
 * @function NAVTomlGetNextNode
 * @public
 * @description Get the next sibling node of the current node.
 *
 * This function retrieves the next sibling of the given node. Use this to
 * iterate through all children of a parent node. Returns false if there are
 * no more siblings.
 *
 * @param {_NAVToml} toml - The parsed TOML structure
 * @param {_NAVTomlNode} currentNode - The current node
 * @param {_NAVTomlNode} nextNode - Output parameter to receive the next sibling node
 *
 * @returns {char} True (1) if next sibling exists, False (0) if no more siblings
 *
 * @example
 * stack_var _NAVToml toml
 * stack_var _NAVTomlNode root, child
 *
 * NAVTomlParse('numbers = [1, 2, 3]', toml)
 * NAVTomlGetRootNode(toml, root)
 *
 * // Iterate array elements
 * if (NAVTomlGetFirstChild(toml, root, child)) {
 *     if (NAVTomlGetFirstChild(toml, child, child)) {
 *         do {
 *             send_string 0, "'Value: ', child.value"
 *         } while (NAVTomlGetNextNode(toml, child, child))
 *     }
 * }
 */
define_function char NAVTomlGetNextNode(_NAVToml toml, _NAVTomlNode currentNode, _NAVTomlNode nextNode) {
    if (currentNode.nextSibling == 0) {
        return false
    }

    return NAVTomlGetNode(toml, currentNode.nextSibling, nextNode)
}


(***********************************************************)
(*               QUERY EXECUTOR FUNCTIONS                  *)
(***********************************************************)

/**
 * @function NAVTomlQueryExecute
 * @private
 * @description Executes a parsed query path against a TOML tree.
 * Navigates through the TOML tree following the path steps to find the target node.
 *
 * @param {_NAVToml} toml - The TOML structure to query
 * @param {_NAVTomlQueryPathStep[]} steps - Array of path steps to execute
 * @param {integer} stepCount - Number of steps
 * @param {_NAVTomlNode} result - The resulting node (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var _NAVTomlNode result
 * if (NAVTomlQueryExecute(toml, steps, stepCount, result)) {
 *     // Use result
 * }
 */
define_function char NAVTomlQueryExecute(_NAVToml toml, _NAVTomlQueryPathStep steps[], integer stepCount, _NAVTomlNode result) {
    stack_var _NAVTomlNode current
    stack_var integer i

    #IF_DEFINED TOML_QUERY_DEBUG
    NAVLog("'[ TomlQueryExecute ]: Starting execution. Step count: ', itoa(stepCount)")
    #END_IF

    // Handle root query
    if (stepCount == 1 && steps[1].type == NAV_TOML_QUERY_STEP_ROOT) {
        #IF_DEFINED TOML_QUERY_DEBUG
        NAVLog("'[ TomlQueryExecute ]: Returning root node'")
        #END_IF

        return NAVTomlGetRootNode(toml, result)
    }

    // Start from root
    if (!NAVTomlGetRootNode(toml, current)) {
        return false
    }

    // Execute each step
    for (i = 1; i <= stepCount; i++) {
        #IF_DEFINED TOML_QUERY_DEBUG
        NAVLog("'[ TomlQueryExecute ]: Executing step ', itoa(i), ' of ', itoa(stepCount)")
        #END_IF

        select {
            active (steps[i].type == NAV_TOML_QUERY_STEP_PROPERTY): {
                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryExecute ]: Looking for property: ', steps[i].propertyKey")
                #END_IF

                if (!NAVTomlGetPropertyByKey(toml, current, steps[i].propertyKey, current)) {
                    #IF_DEFINED TOML_QUERY_DEBUG
                    NAVLog("'[ TomlQueryExecute ]: Property not found: ', steps[i].propertyKey")
                    #END_IF

                    return false
                }

                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryExecute ]: Property found: ', steps[i].propertyKey, ' (type=', itoa(current.type), ')'")
                #END_IF
            }

            active (steps[i].type == NAV_TOML_QUERY_STEP_ARRAY_INDEX): {
                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryExecute ]: Looking for array element at index: ', itoa(steps[i].arrayIndex), ' (1-based)'")
                #END_IF

                // Convert 1-based query index to 0-based internal API index
                if (!NAVTomlGetArrayElement(toml, current, steps[i].arrayIndex - 1, current)) {
                    #IF_DEFINED TOML_QUERY_DEBUG
                    NAVLog("'[ TomlQueryExecute ]: Array element not found at index: ', itoa(steps[i].arrayIndex)")
                    #END_IF

                    return false
                }

                #IF_DEFINED TOML_QUERY_DEBUG
                NAVLog("'[ TomlQueryExecute ]: Array element found at index: ', itoa(steps[i].arrayIndex), ' (type=', itoa(current.type), ')'")
                #END_IF
            }
        }
    }

    #IF_DEFINED TOML_QUERY_DEBUG
    NAVLog("'[ TomlQueryExecute ]: Execution complete. Result type: ', itoa(current.type)")
    #END_IF

    result = current
    return true
}


(***********************************************************)
(*                  CORE QUERY FUNCTION                    *)
(***********************************************************)

/**
 * @function NAVTomlQuery
 * @public
 * @description Queries a TOML structure using a JQ-like query syntax.
 * Main entry point for querying TOML data using a simple dot notation.
 *
 * Supports:
 * - `.` (root node)
 * - `.property` (table property access)
 * - `.[index]` (array element access, 1-based indexing)
 * - `.property.nested` (chained property access)
 * - `.property[index]` (mixed access)
 *
 * @param {_NAVToml} toml - The TOML structure to query
 * @param {char[]} query - The query string (e.g., ".database.server", ".ports[1]")
 * @param {_NAVTomlNode} result - The resulting node (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var _NAVTomlNode node
 * if (NAVTomlQuery(toml, '.database.server', node)) {
 *     // Use node
 * }
 */
define_function char NAVTomlQuery(_NAVToml toml, char query[], _NAVTomlNode result) {
    stack_var _NAVTomlQueryToken tokens[NAV_TOML_QUERY_MAX_TOKENS]
    stack_var _NAVTomlQueryPathStep steps[NAV_TOML_QUERY_MAX_PATH_STEPS]
    stack_var integer tokenCount
    stack_var integer stepCount

    // Tokenize
    tokenCount = NAVTomlQueryLexer(query, tokens)
    if (tokenCount == 0) {
        return false
    }

    // Parse
    stepCount = NAVTomlQueryParser(tokens, tokenCount, steps)
    if (stepCount == 0) {
        return false
    }

    // Execute
    return NAVTomlQueryExecute(toml, steps, stepCount, result)
}


(***********************************************************)
(*              VALUE GETTER FUNCTIONS                     *)
(***********************************************************)

/**
 * @function NAVTomlQuery String
 * @public
 * @description Query a TOML structure and return string value.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {char[]} query - The query string
 * @param {char[]} result - Output string value
 *
 * @returns {char} True if successful, false otherwise
 */
define_function char NAVTomlQueryString(_NAVToml toml, char query[], char result[]) {
    stack_var _NAVTomlNode node

    result = ''

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    if (node.type != NAV_TOML_VALUE_TYPE_STRING) {
        return false
    }

    result = node.value
    return true
}


/**
 * @function NAVTomlQueryInteger
 * @public
 * @description Query a TOML structure and return integer value.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {char[]} query - The query string
 * @param {integer} result - Output integer value
 *
 * @returns {char} True if successful, false otherwise
 */
define_function char NAVTomlQueryInteger(_NAVToml toml, char query[], integer result) {
    stack_var _NAVTomlNode node
    stack_var integer value

    result = 0

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    if (node.type != NAV_TOML_VALUE_TYPE_INTEGER) {
        return false
    }

    if (!NAVParseInteger(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVTomlQueryLong
 * @public
 * @description Query a TOML structure and return long integer value.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {char[]} query - The query string
 * @param {long} result - Output long value
 *
 * @returns {char} True if successful, false otherwise
 */
define_function char NAVTomlQueryLong(_NAVToml toml, char query[], long result) {
    stack_var _NAVTomlNode node
    stack_var long value

    result = 0

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    if (node.type != NAV_TOML_VALUE_TYPE_INTEGER) {
        return false
    }

    if (!NAVParseLong(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVTomlQueryFloat
 * @public
 * @description Query a TOML structure and return float value.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {char[]} query - The query string
 * @param {float} result - Output float value
 *
 * @returns {char} True if successful, false otherwise
 */
define_function char NAVTomlQueryFloat(_NAVToml toml, char query[], float result) {
    stack_var _NAVTomlNode node
    stack_var float value

    result = 0.0

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    if (node.type != NAV_TOML_VALUE_TYPE_FLOAT) {
        return false
    }

    if (!NAVParseFloat(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVTomlQueryBoolean
 * @public
 * @description Query a TOML structure and return boolean value.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {char[]} query - The query string
 * @param {char} result - Output boolean value (1=true, 0=false)
 *
 * @returns {char} True if successful, false otherwise
 */
define_function char NAVTomlQueryBoolean(_NAVToml toml, char query[], char result) {
    stack_var _NAVTomlNode node
    stack_var char value

    result = false

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    if (node.type != NAV_TOML_VALUE_TYPE_BOOLEAN) {
        return false
    }

    if (!NAVParseBoolean(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVTomlQuerySignedInteger
 * @public
 * @description Query a TOML structure and return signed integer value.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {char[]} query - The query string
 * @param {sinteger} result - Output signed integer value
 *
 * @returns {char} True if successful, false otherwise
 */
define_function char NAVTomlQuerySignedInteger(_NAVToml toml, char query[], sinteger result) {
    stack_var _NAVTomlNode node
    stack_var sinteger value

    result = 0

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    if (node.type != NAV_TOML_VALUE_TYPE_INTEGER) {
        return false
    }

    if (!NAVParseSignedInteger(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVTomlQuerySignedLong
 * @public
 * @description Query a TOML structure and return signed long integer value.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {char[]} query - The query string
 * @param {slong} result - Output signed long value
 *
 * @returns {char} True if successful, false otherwise
 */
define_function char NAVTomlQuerySignedLong(_NAVToml toml, char query[], slong result) {
    stack_var _NAVTomlNode node
    stack_var slong value

    result = 0

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    if (node.type != NAV_TOML_VALUE_TYPE_INTEGER) {
        return false
    }

    if (!NAVParseSignedLong(node.value, value)) {
        return false
    }

    result = value
    return true
}


(***********************************************************)
(*              ARRAY EXTRACTION FUNCTIONS                 *)
(***********************************************************)

/**
 * @function NAVTomlToStringArray
 * @public
 * @description Converts a TOML array node to a NetLinx string array.
 * All array elements must be strings (homogeneous arrays only).
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {_NAVTomlNode} arrayNode - The array node to convert
 * @param {char[][]} result - The resulting string array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-string elements
 *
 * @example
 * stack_var char names[100][50]
 * stack_var _NAVTomlNode arrayNode
 * if (NAVTomlQuery(toml, '.database.hosts', arrayNode)) {
 *     if (NAVTomlToStringArray(toml, arrayNode, names)) {
 *         // Use names array
 *     }
 * }
 */
define_function char NAVTomlToStringArray(_NAVToml toml, _NAVTomlNode arrayNode, char result[][]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVTomlNode element

    if (!NAVTomlIsArray(arrayNode)) {
        return false
    }

    count = NAVTomlGetChildCount(arrayNode)

    // Validate all elements are strings
    for (i = 1; i <= count; i++) {
        if (!NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)) {
            return false
        }

        if (element.type != NAV_TOML_VALUE_TYPE_STRING) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)
        result[i] = element.value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVTomlToFloatArray
 * @public
 * @description Converts a TOML array node to a NetLinx float array.
 * All array elements must be numbers (homogeneous arrays only).
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {_NAVTomlNode} arrayNode - The array node to convert
 * @param {float[]} result - The resulting float array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-number elements
 *
 * @example
 * stack_var float values[100]
 * stack_var _NAVTomlNode arrayNode
 * if (NAVTomlQuery(toml, '.data.values', arrayNode)) {
 *     if (NAVTomlToFloatArray(toml, arrayNode, values)) {
 *         // Use values array
 *     }
 * }
 */
define_function char NAVTomlToFloatArray(_NAVToml toml, _NAVTomlNode arrayNode, float result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVTomlNode element

    if (!NAVTomlIsArray(arrayNode)) {
        return false
    }

    count = NAVTomlGetChildCount(arrayNode)

    // Validate all elements are numbers
    for (i = 1; i <= count; i++) {
        if (!NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)) {
            return false
        }

        if (element.type != NAV_TOML_VALUE_TYPE_INTEGER &&
            element.type != NAV_TOML_VALUE_TYPE_FLOAT) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        stack_var float value

        NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)

        if (!NAVParseFloat(element.value, value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_TOML_QUERY__,
                                        'NAVTomlToFloatArray',
                                        "'Failed to parse element ', itoa(i), ': ', element.value")
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVTomlToIntegerArray
 * @public
 * @description Converts a TOML array node to a NetLinx integer array (unsigned 16-bit: 0-65535).
 * All array elements must be numbers (homogeneous arrays only).
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {_NAVTomlNode} arrayNode - The array node to convert
 * @param {integer[]} result - The resulting integer array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-number elements
 *
 * @example
 * stack_var integer ports[50]
 * stack_var _NAVTomlNode arrayNode
 * if (NAVTomlQuery(toml, '.server.ports', arrayNode)) {
 *     if (NAVTomlToIntegerArray(toml, arrayNode, ports)) {
 *         // Use ports array
 *     }
 * }
 */
define_function char NAVTomlToIntegerArray(_NAVToml toml, _NAVTomlNode arrayNode, integer result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVTomlNode element

    if (!NAVTomlIsArray(arrayNode)) {
        return false
    }

    count = NAVTomlGetChildCount(arrayNode)

    // Validate all elements are numbers
    for (i = 1; i <= count; i++) {
        if (!NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)) {
            return false
        }

        if (element.type != NAV_TOML_VALUE_TYPE_INTEGER &&
            element.type != NAV_TOML_VALUE_TYPE_FLOAT) {
            return false
        }
    }

    // Extract values with direct parsing
    for (i = 1; i <= count; i++) {
        stack_var integer value

        NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)

        if (!NAVParseInteger(element.value, value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_TOML_QUERY__,
                                        'NAVTomlToIntegerArray',
                                        "'Failed to parse element ', itoa(i), ': ', element.value")
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVTomlToSignedIntegerArray
 * @public
 * @description Converts a TOML array node to a NetLinx signed integer array (signed 16-bit: -32768 to 32767).
 * All array elements must be numbers (homogeneous arrays only).
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {_NAVTomlNode} arrayNode - The array node to convert
 * @param {sinteger[]} result - The resulting signed integer array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-number elements
 *
 * @example
 * stack_var sinteger offsets[100]
 * stack_var _NAVTomlNode arrayNode
 * if (NAVTomlQuery(toml, '.data.offsets', arrayNode)) {
 *     if (NAVTomlToSignedIntegerArray(toml, arrayNode, offsets)) {
 *         // Use offsets array
 *     }
 * }
 */
define_function char NAVTomlToSignedIntegerArray(_NAVToml toml, _NAVTomlNode arrayNode, sinteger result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVTomlNode element

    if (!NAVTomlIsArray(arrayNode)) {
        return false
    }

    count = NAVTomlGetChildCount(arrayNode)

    // Validate all elements are numbers
    for (i = 1; i <= count; i++) {
        if (!NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)) {
            return false
        }

        if (element.type != NAV_TOML_VALUE_TYPE_INTEGER &&
            element.type != NAV_TOML_VALUE_TYPE_FLOAT) {
            return false
        }
    }

    // Extract values with direct parsing
    for (i = 1; i <= count; i++) {
        stack_var sinteger value

        NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)

        if (!NAVParseSignedInteger(element.value, value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_TOML_QUERY__,
                                        'NAVTomlToSignedIntegerArray',
                                        "'Failed to parse element ', itoa(i), ': ', element.value")
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVTomlToLongArray
 * @public
 * @description Converts a TOML array node to a NetLinx long array (unsigned 32-bit: 0-4294967295).
 * All array elements must be numbers (homogeneous arrays only).
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {_NAVTomlNode} arrayNode - The array node to convert
 * @param {long[]} result - The resulting long array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-number elements
 *
 * @example
 * stack_var long timestamps[100]
 * stack_var _NAVTomlNode arrayNode
 * if (NAVTomlQuery(toml, '.data.timestamps', arrayNode)) {
 *     if (NAVTomlToLongArray(toml, arrayNode, timestamps)) {
 *         // Use timestamps array
 *     }
 * }
 */
define_function char NAVTomlToLongArray(_NAVToml toml, _NAVTomlNode arrayNode, long result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVTomlNode element

    if (!NAVTomlIsArray(arrayNode)) {
        return false
    }

    count = NAVTomlGetChildCount(arrayNode)

    // Validate all elements are numbers
    for (i = 1; i <= count; i++) {
        if (!NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)) {
            return false
        }

        if (element.type != NAV_TOML_VALUE_TYPE_INTEGER &&
            element.type != NAV_TOML_VALUE_TYPE_FLOAT) {
            return false
        }
    }

    // Extract values with direct parsing
    for (i = 1; i <= count; i++) {
        stack_var long value

        NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)

        if (!NAVParseLong(element.value, value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_TOML_QUERY__,
                                        'NAVTomlToLongArray',
                                        "'Failed to parse element ', itoa(i), ': ', element.value")
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVTomlToSignedLongArray
 * @public
 * @description Converts a TOML array node to a NetLinx signed long array (signed 32-bit: -2147483648 to 2147483647).
 * All array elements must be numbers (homogeneous arrays only).
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {_NAVTomlNode} arrayNode - The array node to convert
 * @param {slong[]} result - The resulting signed long array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-number elements
 *
 * @example
 * stack_var slong values[100]
 * stack_var _NAVTomlNode arrayNode
 * if (NAVTomlQuery(toml, '.data.values', arrayNode)) {
 *     if (NAVTomlToSignedLongArray(toml, arrayNode, values)) {
 *         // Use values array
 *     }
 * }
 */
define_function char NAVTomlToSignedLongArray(_NAVToml toml, _NAVTomlNode arrayNode, slong result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVTomlNode element

    if (!NAVTomlIsArray(arrayNode)) {
        return false
    }

    count = NAVTomlGetChildCount(arrayNode)

    // Validate all elements are numbers
    for (i = 1; i <= count; i++) {
        if (!NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)) {
            return false
        }

        if (element.type != NAV_TOML_VALUE_TYPE_INTEGER &&
            element.type != NAV_TOML_VALUE_TYPE_FLOAT) {
            return false
        }
    }

    // Extract values with direct parsing
    for (i = 1; i <= count; i++) {
        stack_var slong value

        NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)

        if (!NAVParseSignedLong(element.value, value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_TOML_QUERY__,
                                        'NAVTomlToSignedLongArray',
                                        "'Failed to parse element ', itoa(i), ': ', element.value")
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVTomlToBooleanArray
 * @public
 * @description Converts a TOML array node to a NetLinx boolean array.
 * All array elements must be booleans (homogeneous arrays only).
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {_NAVTomlNode} arrayNode - The array node to convert
 * @param {char[]} result - The resulting boolean array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-boolean elements
 *
 * @example
 * stack_var char flags[50]
 * stack_var _NAVTomlNode arrayNode
 * if (NAVTomlQuery(toml, '.settings.flags', arrayNode)) {
 *     if (NAVTomlToBooleanArray(toml, arrayNode, flags)) {
 *         // Use flags array
 *     }
 * }
 */
define_function char NAVTomlToBooleanArray(_NAVToml toml, _NAVTomlNode arrayNode, char result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVTomlNode element

    if (!NAVTomlIsArray(arrayNode)) {
        return false
    }

    count = NAVTomlGetChildCount(arrayNode)

    // Validate all elements are booleans
    for (i = 1; i <= count; i++) {
        if (!NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)) {
            return false
        }

        if (element.type != NAV_TOML_VALUE_TYPE_BOOLEAN) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        stack_var char value

        NAVTomlGetArrayElement(toml, arrayNode, i - 1, element)

        if (!NAVParseBoolean(element.value, value)) {
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


(***********************************************************)
(*         CONVENIENCE ARRAY QUERY FUNCTIONS               *)
(***********************************************************)

/**
 * @function NAVTomlQueryStringArray
 * @public
 * @description Queries for a string array at the specified path.
 *
 * @param {_NAVToml} toml - The TOML structure to query
 * @param {char[]} query - The query string
 * @param {char[][]} result - The resulting string array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var char hosts[100][50]
 * if (NAVTomlQueryStringArray(toml, '.database.hosts', hosts)) {
 *     // Use hosts array
 * }
 */
define_function char NAVTomlQueryStringArray(_NAVToml toml, char query[], char result[][]) {
    stack_var _NAVTomlNode node

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    return NAVTomlToStringArray(toml, node, result)
}


/**
 * @function NAVTomlQueryFloatArray
 * @public
 * @description Queries for a float array at the specified path.
 *
 * @param {_NAVToml} toml - The TOML structure to query
 * @param {char[]} query - The query string
 * @param {float[]} result - The resulting float array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var float values[100]
 * if (NAVTomlQueryFloatArray(toml, '.data.values', values)) {
 *     // Use values array
 * }
 */
define_function char NAVTomlQueryFloatArray(_NAVToml toml, char query[], float result[]) {
    stack_var _NAVTomlNode node

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    return NAVTomlToFloatArray(toml, node, result)
}


/**
 * @function NAVTomlQueryIntegerArray
 * @public
 * @description Queries for an integer array (unsigned 16-bit: 0-65535) at the specified path.
 *
 * @param {_NAVToml} toml - The TOML structure to query
 * @param {char[]} query - The query string
 * @param {integer[]} result - The resulting integer array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var integer ports[50]
 * if (NAVTomlQueryIntegerArray(toml, '.server.ports', ports)) {
 *     // Use ports array
 * }
 */
define_function char NAVTomlQueryIntegerArray(_NAVToml toml, char query[], integer result[]) {
    stack_var _NAVTomlNode node

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    return NAVTomlToIntegerArray(toml, node, result)
}


/**
 * @function NAVTomlQuerySignedIntegerArray
 * @public
 * @description Queries for a signed integer array (signed 16-bit: -32768 to 32767) at the specified path.
 *
 * @param {_NAVToml} toml - The TOML structure to query
 * @param {char[]} query - The query string
 * @param {sinteger[]} result - The resulting signed integer array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var sinteger offsets[100]
 * if (NAVTomlQuerySignedIntegerArray(toml, '.data.offsets', offsets)) {
 *     // Use offsets array
 * }
 */
define_function char NAVTomlQuerySignedIntegerArray(_NAVToml toml, char query[], sinteger result[]) {
    stack_var _NAVTomlNode node

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    return NAVTomlToSignedIntegerArray(toml, node, result)
}


/**
 * @function NAVTomlQueryLongArray
 * @public
 * @description Queries for a long array (unsigned 32-bit: 0-4294967295) at the specified path.
 *
 * @param {_NAVToml} toml - The TOML structure to query
 * @param {char[]} query - The query string
 * @param {long[]} result - The resulting long array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var long timestamps[100]
 * if (NAVTomlQueryLongArray(toml, '.data.timestamps', timestamps)) {
 *     // Use timestamps array
 * }
 */
define_function char NAVTomlQueryLongArray(_NAVToml toml, char query[], long result[]) {
    stack_var _NAVTomlNode node

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    return NAVTomlToLongArray(toml, node, result)
}


/**
 * @function NAVTomlQuerySignedLongArray
 * @public
 * @description Queries for a signed long array (signed 32-bit: -2147483648 to 2147483647) at the specified path.
 *
 * @param {_NAVToml} toml - The TOML structure to query
 * @param {char[]} query - The query string
 * @param {slong[]} result - The resulting signed long array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var slong values[100]
 * if (NAVTomlQuerySignedLongArray(toml, '.data.values', values)) {
 *     // Use values array
 * }
 */
define_function char NAVTomlQuerySignedLongArray(_NAVToml toml, char query[], slong result[]) {
    stack_var _NAVTomlNode node

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    return NAVTomlToSignedLongArray(toml, node, result)
}


/**
 * @function NAVTomlQueryBooleanArray
 * @public
 * @description Queries for a boolean array at the specified path.
 *
 * @param {_NAVToml} toml - The TOML structure to query
 * @param {char[]} query - The query string
 * @param {char[]} result - The resulting boolean array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var char flags[50]
 * if (NAVTomlQueryBooleanArray(toml, '.settings.flags', flags)) {
 *     // Use flags array
 * }
 */
define_function char NAVTomlQueryBooleanArray(_NAVToml toml, char query[], char result[]) {
    stack_var _NAVTomlNode node

    if (!NAVTomlQuery(toml, query, node)) {
        return false
    }

    return NAVTomlToBooleanArray(toml, node, result)
}


(***********************************************************)
(*                  HELPER FUNCTIONS                       *)
(***********************************************************)

/**
 * @function NAVTomlIsTable
 * @public
 * @description Check if a node is a table.
 *
 * @param {_NAVTomlNode} node - The node to check
 *
 * @returns {char} True if table, false otherwise
 */
define_function char NAVTomlIsTable(_NAVTomlNode node) {
    return node.type == NAV_TOML_VALUE_TYPE_TABLE ||
           node.type == NAV_TOML_VALUE_TYPE_INLINE_TABLE
}


/**
 * @function NAVTomlIsArray
 * @public
 * @description Check if a node is an array.
 *
 * @param {_NAVTomlNode} node - The node to check
 *
 * @returns {char} True if array, false otherwise
 */
define_function char NAVTomlIsArray(_NAVTomlNode node) {
    return node.type == NAV_TOML_VALUE_TYPE_ARRAY
}


/**
 * @function NAVTomlIsString
 * @public
 * @description Check if a node is a string.
 *
 * @param {_NAVTomlNode} node - The node to check
 *
 * @returns {char} True if string, false otherwise
 */
define_function char NAVTomlIsString(_NAVTomlNode node) {
    return node.type == NAV_TOML_VALUE_TYPE_STRING
}


/**
 * @function NAVTomlIsNumber
 * @public
 * @description Check if a node is a number (integer or float).
 *
 * @param {_NAVTomlNode} node - The node to check
 *
 * @returns {char} True if number, false otherwise
 */
define_function char NAVTomlIsNumber(_NAVTomlNode node) {
    return node.type == NAV_TOML_VALUE_TYPE_INTEGER ||
           node.type == NAV_TOML_VALUE_TYPE_FLOAT
}


/**
 * @function NAVTomlIsBoolean
 * @public
 * @description Check if a node is a boolean.
 *
 * @param {_NAVTomlNode} node - The node to check
 *
 * @returns {char} True if boolean, false otherwise
 */
define_function char NAVTomlIsBoolean(_NAVTomlNode node) {
    return node.type == NAV_TOML_VALUE_TYPE_BOOLEAN
}


/**
 * @function NAVTomlIsDateTime
 * @public
 * @description Check if a node is a datetime, date, or time value.
 *
 * @param {_NAVTomlNode} node - The node to check
 *
 * @returns {char} True if datetime type, false otherwise
 */
define_function char NAVTomlIsDateTime(_NAVTomlNode node) {
    return node.type == NAV_TOML_VALUE_TYPE_DATETIME ||
           node.type == NAV_TOML_VALUE_TYPE_DATE ||
           node.type == NAV_TOML_VALUE_TYPE_TIME
}


/**
 * @function NAVTomlGetChildCount
 * @public
 * @description Get the number of children in a table or array.
 *
 * @param {_NAVTomlNode} node - The node to check
 *
 * @returns {integer} Number of children
 */
define_function integer NAVTomlGetChildCount(_NAVTomlNode node) {
    return node.childCount
}


/**
 * @function NAVTomlGetError
 * @public
 * @description Get the error message from a failed parse.
 *
 * @param {_NAVToml} toml - The TOML structure
 *
 * @returns {char[]} Error message, or empty string if no error
 */
define_function char[NAV_TOML_PARSER_MAX_ERROR_LENGTH] NAVTomlGetError(_NAVToml toml) {
    return toml.error
}


/**
 * @function NAVTomlGetNodeType
 * @public
 * @description Get a string representation of a TOML node type.
 *
 * @param {integer} type - The node type constant (NAV_TOML_VALUE_TYPE_*\)
 *
 * @returns {char[]} String name of the type
 */
define_function char[32] NAVTomlGetNodeType(integer type) {
    switch (type) {
        case NAV_TOML_VALUE_TYPE_NONE:          { return 'NONE' }
        case NAV_TOML_VALUE_TYPE_STRING:        { return 'STRING' }
        case NAV_TOML_VALUE_TYPE_INTEGER:       { return 'INTEGER' }
        case NAV_TOML_VALUE_TYPE_FLOAT:         { return 'FLOAT' }
        case NAV_TOML_VALUE_TYPE_BOOLEAN:       { return 'BOOLEAN' }
        case NAV_TOML_VALUE_TYPE_DATETIME:      { return 'DATETIME' }
        case NAV_TOML_VALUE_TYPE_DATE:          { return 'DATE' }
        case NAV_TOML_VALUE_TYPE_TIME:          { return 'TIME' }
        case NAV_TOML_VALUE_TYPE_ARRAY:         { return 'ARRAY' }
        case NAV_TOML_VALUE_TYPE_TABLE:         { return 'TABLE' }
        case NAV_TOML_VALUE_TYPE_INLINE_TABLE:  { return 'INLINE_TABLE' }
        case NAV_TOML_VALUE_TYPE_TABLE_ARRAY:   { return 'TABLE_ARRAY' }
        default:                                { return 'UNKNOWN' }
    }
}


/**
 * @function NAVTomlGetKey
 * @public
 * @description Get the key associated with a TOML node.
 *
 * @param {_NAVTomlNode} node - The node to get the key from
 *
 * @returns {char[]} The key string (empty string if no key)
 */
define_function char[NAV_TOML_PARSER_MAX_KEY_LENGTH] NAVTomlGetKey(_NAVTomlNode node) {
    return node.key
}


/**
 * @function NAVTomlGetValue
 * @public
 * @description Get the string value of a TOML node.
 *
 * All TOML values are stored as strings and parsed on-demand by type-specific
 * query functions. This returns the raw string representation.
 *
 * @param {_NAVTomlNode} node - The node to get the value from
 *
 * @returns {char[]} The value string
 */
define_function char[NAV_TOML_PARSER_MAX_STRING_LENGTH] NAVTomlGetValue(_NAVTomlNode node) {
    return node.value
}


/**
 * @function NAVTomlGetNodeCount
 * @public
 * @description Get the total number of nodes in the TOML parse tree.
 *
 * This includes the root node and all children at any depth (tables, arrays,
 * and all scalar values).
 *
 * @param {_NAVToml} toml - The TOML structure
 *
 * @returns {integer} Total number of nodes
 */
define_function integer NAVTomlGetNodeCount(_NAVToml toml) {
    return toml.nodeCount
}


/**
 * @function NAVTomlGetMaxDepth
 * @public
 * @description Get the maximum depth of the TOML parse tree.
 *
 * Depth is measured from the root (depth 0). A simple key-value pair at the
 * root has depth 1. Nested structures increase the depth.
 *
 * @param {_NAVToml} toml - The TOML structure
 *
 * @returns {sinteger} Maximum depth of the tree (0 for empty, -1 on error)
 */
define_function sinteger NAVTomlGetMaxDepth(_NAVToml toml) {
    stack_var _NAVTomlNode rootNode
    stack_var sinteger maxDepth

    if (toml.nodeCount == 0) {
        return -1
    }

    if (!NAVTomlGetRootNode(toml, rootNode)) {
        return -1
    }

    maxDepth = NAVTomlCalculateDepth(toml, rootNode, 0)
    return maxDepth
}


/**
 * @function NAVTomlCalculateDepth
 * @private
 * @description Recursively calculate the maximum depth from a given node.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {_NAVTomlNode} node - The current node
 * @param {sinteger} currentDepth - The depth of the current node
 *
 * @returns {sinteger} Maximum depth found from this node
 */
define_function sinteger NAVTomlCalculateDepth(_NAVToml toml, _NAVTomlNode node, sinteger currentDepth) {
    stack_var sinteger maxDepth
    stack_var _NAVTomlNode child
    stack_var sinteger childDepth

    maxDepth = currentDepth

    // If this node has no children, return current depth
    if (node.childCount == 0) {
        return currentDepth
    }

    // Get first child
    if (!NAVTomlGetFirstChild(toml, node, child)) {
        return currentDepth
    }

    // Process first child
    childDepth = NAVTomlCalculateDepth(toml, child, currentDepth + 1)
    if (childDepth > maxDepth) {
        maxDepth = childDepth
    }

    // Process siblings
    while (NAVTomlGetNextNode(toml, child, child)) {
        childDepth = NAVTomlCalculateDepth(toml, child, currentDepth + 1)
        if (childDepth > maxDepth) {
            maxDepth = childDepth
        }
    }

    return maxDepth
}


/**
 * @function NAVTomlGetErrorLine
 * @public
 * @description Get the line number where a parse error occurred.
 *
 * @param {_NAVToml} toml - The TOML structure
 *
 * @returns {integer} Line number (1-based), or 0 if no error
 */
define_function integer NAVTomlGetErrorLine(_NAVToml toml) {
    return toml.errorLine
}


/**
 * @function NAVTomlGetErrorColumn
 * @public
 * @description Get the column number where a parse error occurred.
 *
 * @param {_NAVToml} toml - The TOML structure
 *
 * @returns {integer} Column number (1-based), or 0 if no error
 */
define_function integer NAVTomlGetErrorColumn(_NAVToml toml) {
    return toml.errorColumn
}


/**
 * @function NAVTomlGetNodeSubtype
 * @public
 * @description Get the subtype of a TOML node.
 *
 * Subtypes preserve formatting information from the original TOML:
 * - Integers: DECIMAL (0), HEXADECIMAL (1), OCTAL (2), BINARY (3)
 * - Floats: NORMAL (0), INF (1), NAN (2)
 * - Strings: BASIC (0), LITERAL (1), MULTILINE (2), LITERAL_ML (3)
 * - Booleans: FALSE (0), TRUE (1)
 *
 * @param {_NAVTomlNode} node - The node to inspect
 *
 * @returns {integer} The subtype constant
 *
 * @example
 * stack_var _NAVTomlNode node
 * stack_var integer subtype
 *
 * NAVTomlQuery(toml, '.hex', node)
 * subtype = NAVTomlGetNodeSubtype(node)
 * // Returns NAV_TOML_SUBTYPE_HEXADECIMAL (1)
 */
define_function integer NAVTomlGetNodeSubtype(_NAVTomlNode node) {
    return node.subtype
}


#END_IF // __NAV_FOUNDATION_TOML_QUERY__
