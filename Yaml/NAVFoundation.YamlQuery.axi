PROGRAM_NAME='NAVFoundation.YamlQuery'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_YAML_QUERY__
#DEFINE __NAV_FOUNDATION_YAML_QUERY__ 'NAVFoundation.YamlQuery'

#include 'NAVFoundation.YamlQuery.h.axi'
#include 'NAVFoundation.YamlParser.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.Math.axi'
#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


(***********************************************************)
(*               QUERY LEXER FUNCTIONS                     *)
(***********************************************************)

/**
 * @function NAVYamlQueryLexer
 * @private
 * @description Tokenizes a YAML query string into tokens for parsing.
 * Converts a query string into a sequence of tokens representing dots, identifiers,
 * brackets, and numbers.
 *
 * @param {char[]} query - The query string to tokenize (e.g., ".user.name", ".items[0]")
 * @param {_NAVYamlQueryToken[]} tokens - Array to store the resulting tokens
 *
 * @returns {integer} Number of tokens generated, or 0 on error
 */
define_function integer NAVYamlQueryLexer(char query[], _NAVYamlQueryToken tokens[]) {
    stack_var integer pos
    stack_var integer tokenCount
    stack_var char ch
    stack_var integer queryLength

    #IF_DEFINED YAML_QUERY_DEBUG
    NAVLog("'[ YamlQueryLexer ]: Starting tokenization of query: ', query")
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
        if (tokenCount >= NAV_YAML_QUERY_MAX_TOKENS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_YAML_QUERY__,
                                        'NAVYamlQueryLexer',
                                        "'Too many tokens in query (max: ', itoa(NAV_YAML_QUERY_MAX_TOKENS), ')'")
            return 0
        }

        tokenCount++

        select {
            // DOT
            active (ch == '.'): {
                tokens[tokenCount].type = NAV_YAML_QUERY_TOKEN_DOT
                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryLexer ]: Token ', itoa(tokenCount), ': DOT'")
                #END_IF
                pos++
            }

            // LEFT_BRACKET
            active (ch == '['): {
                tokens[tokenCount].type = NAV_YAML_QUERY_TOKEN_LEFT_BRACKET
                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryLexer ]: Token ', itoa(tokenCount), ': LEFT_BRACKET'")
                #END_IF
                pos++
            }

            // RIGHT_BRACKET
            active (ch == ']'): {
                tokens[tokenCount].type = NAV_YAML_QUERY_TOKEN_RIGHT_BRACKET
                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryLexer ]: Token ', itoa(tokenCount), ': RIGHT_BRACKET'")
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
                tokens[tokenCount].type = NAV_YAML_QUERY_TOKEN_NUMBER
                tokens[tokenCount].value = numStr
                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryLexer ]: Token ', itoa(tokenCount), ': NUMBER = ', numStr")
                #END_IF
            }

            // IDENTIFIER
            active (NAVIsAlpha(ch) || ch == '_'): {
                stack_var integer startPos

                startPos = pos

                while (pos <= queryLength) {
                    ch = query[pos]
                    if (NAVIsAlphaNumeric(ch)) {
                        pos++
                    }
                    else {
                        break
                    }
                }

                tokens[tokenCount].type = NAV_YAML_QUERY_TOKEN_IDENTIFIER
                tokens[tokenCount].value = NAVStringSubstring(query, startPos, pos - startPos)
                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryLexer ]: Token ', itoa(tokenCount), ': IDENTIFIER = ', tokens[tokenCount].value")
                #END_IF
            }

            // Unknown character
            active (true): {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_YAML_QUERY__,
                                            'NAVYamlQueryLexer',
                                            "'Unexpected character: ', ch, ' (', itoa(ch), ') at position ', itoa(pos)")
                return 0
            }
        }
    }

    #IF_DEFINED YAML_QUERY_DEBUG
    NAVLog("'[ YamlQueryLexer ]: Tokenization complete. Token count: ', itoa(tokenCount)")
    #END_IF

    return tokenCount
}


(***********************************************************)
(*               QUERY PARSER FUNCTIONS                    *)
(***********************************************************)

/**
 * @function NAVYamlQueryParser
 * @private
 * @description Parses tokens into executable path steps.
 * Validates token sequence and converts tokens into navigation steps that can be
 * executed against a YAML tree.
 *
 * @param {_NAVYamlQueryToken[]} tokens - Array of tokens from the lexer
 * @param {integer} tokenCount - Number of tokens
 * @param {_NAVYamlQueryStep[]} steps - Array to store the resulting path steps
 *
 * @returns {integer} Number of steps generated, or 0 on error
 */
define_function integer NAVYamlQueryParser(_NAVYamlQueryToken tokens[], integer tokenCount, _NAVYamlQueryStep steps[]) {
    stack_var integer pos
    stack_var integer stepCount

    #IF_DEFINED YAML_QUERY_DEBUG
    NAVLog("'[ YamlQueryParser ]: Starting parsing. Token count: ', itoa(tokenCount)")
    #END_IF

    pos = 1
    stepCount = 0

    // Query must start with DOT
    if (tokenCount == 0 || tokens[pos].type != NAV_YAML_QUERY_TOKEN_DOT) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_YAML_QUERY__,
                                    'NAVYamlQueryParser',
                                    "'Query must start with . (dot)'")
        return 0
    }

    pos++ // Skip initial DOT

    // Check if query is just "." (root)
    if (pos > tokenCount) {
        #IF_DEFINED YAML_QUERY_DEBUG
        NAVLog("'[ YamlQueryParser ]: Root query detected (no steps)'")
        #END_IF
        // Root query - no steps needed, will return root node
        return 0
    }

    while (pos <= tokenCount) {
        if (stepCount >= NAV_YAML_QUERY_MAX_PATH_STEPS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_YAML_QUERY__,
                                        'NAVYamlQueryParser',
                                        "'Too many path steps (max: ', itoa(NAV_YAML_QUERY_MAX_PATH_STEPS), ')'")
            return 0
        }

        stepCount++

        select {
            // Property access: IDENTIFIER
            active (tokens[pos].type == NAV_YAML_QUERY_TOKEN_IDENTIFIER): {
                steps[stepCount].type = NAV_YAML_QUERY_STEP_PROPERTY
                steps[stepCount].property = tokens[pos].value

                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryParser ]: Step ', itoa(stepCount), ': PROPERTY = ', steps[stepCount].property")
                #END_IF

                pos++

                // Check for array index following property: [NUMBER]
                if (pos <= tokenCount && tokens[pos].type == NAV_YAML_QUERY_TOKEN_LEFT_BRACKET) {
                    pos++

                    if (pos > tokenCount || tokens[pos].type != NAV_YAML_QUERY_TOKEN_NUMBER) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_YAML_QUERY__,
                                                    'NAVYamlQueryParser',
                                                    "'Expected number after ['")
                        return 0
                    }

                    stepCount++
                    steps[stepCount].type = NAV_YAML_QUERY_STEP_INDEX
                    steps[stepCount].index = atoi(tokens[pos].value)

                    #IF_DEFINED YAML_QUERY_DEBUG
                    NAVLog("'[ YamlQueryParser ]: Step ', itoa(stepCount), ': INDEX = ', itoa(steps[stepCount].index)")
                    #END_IF

                    pos++

                    if (pos > tokenCount || tokens[pos].type != NAV_YAML_QUERY_TOKEN_RIGHT_BRACKET) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_YAML_QUERY__,
                                                    'NAVYamlQueryParser',
                                                    "'Expected ] after array index'")
                        return 0
                    }
                    pos++
                }

                // Check for continuation with DOT
                if (pos <= tokenCount && tokens[pos].type == NAV_YAML_QUERY_TOKEN_DOT) {
                    pos++
                }
            }

            // Direct array access: [NUMBER]
            active (tokens[pos].type == NAV_YAML_QUERY_TOKEN_LEFT_BRACKET): {
                pos++

                if (pos > tokenCount || tokens[pos].type != NAV_YAML_QUERY_TOKEN_NUMBER) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_YAML_QUERY__,
                                                'NAVYamlQueryParser',
                                                "'Expected number after ['")
                    return 0
                }

                steps[stepCount].type = NAV_YAML_QUERY_STEP_INDEX
                steps[stepCount].index = atoi(tokens[pos].value)

                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryParser ]: Step ', itoa(stepCount), ': INDEX = ', itoa(steps[stepCount].index)")
                #END_IF

                pos++

                if (pos > tokenCount || tokens[pos].type != NAV_YAML_QUERY_TOKEN_RIGHT_BRACKET) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_YAML_QUERY__,
                                                'NAVYamlQueryParser',
                                                "'Expected ] after array index'")
                    return 0
                }
                pos++

                // Check for continuation with DOT
                if (pos <= tokenCount && tokens[pos].type == NAV_YAML_QUERY_TOKEN_DOT) {
                    pos++
                }
            }

            active (true): {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_YAML_QUERY__,
                                            'NAVYamlQueryParser',
                                            "'Unexpected token type: ', itoa(tokens[pos].type)")
                return 0
            }
        }
    }

    #IF_DEFINED YAML_QUERY_DEBUG
    NAVLog("'[ YamlQueryParser ]: Parsing complete. Step count: ', itoa(stepCount)")
    #END_IF

    return stepCount
}


(***********************************************************)
(*          YAML TREE NAVIGATION HELPERS                   *)
(***********************************************************)

/**
 * @function NAVYamlGetRootNode
 * @public
 * @description Get the root node of the YAML document.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {_NAVYamlNode} node - Output parameter for the root node
 *
 * @returns {char} True if successful
 */
define_function char NAVYamlGetRootNode(_NAVYaml yaml, _NAVYamlNode node) {
    if (yaml.rootIndex < 1 || yaml.rootIndex > yaml.nodeCount) {
        return false
    }

    node = yaml.nodes[yaml.rootIndex]
    return true
}


/**
 * @function NAVYamlGetPropertyByKey
 * @public
 * @description Get a property from a mapping node by key name.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {_NAVYamlNode} parentNode - The parent mapping node
 * @param {char[]} key - The property key to find
 * @param {_NAVYamlNode} result - Output parameter for the found node
 *
 * @returns {char} True if property found
 */
define_function char NAVYamlGetPropertyByKey(_NAVYaml yaml, _NAVYamlNode parentNode, char key[], _NAVYamlNode result) {
    stack_var integer childIndex

    if (!NAVYamlIsMapping(parentNode)) {
        return false
    }

    if (parentNode.firstChild == 0) {
        return false
    }

    childIndex = parentNode.firstChild

    while (childIndex != 0) {
        if (childIndex > yaml.nodeCount) {
            return false
        }

        result = yaml.nodes[childIndex]

        if (result.key == key) {
            return true
        }

        childIndex = result.nextSibling
    }

    return false
}


/**
 * @function NAVYamlGetSequenceElement
 * @public
 * @description Get an element from a sequence node by index.
 *
 * @param {_NAVYaml} yaml - The YAML structure
 * @param {_NAVYamlNode} sequenceNode - The parent sequence node
 * @param {integer} index - The element index (0-based)
 * @param {_NAVYamlNode} result - Output parameter for the found node
 *
 * @returns {char} True if element found
 */
define_function char NAVYamlGetSequenceElement(_NAVYaml yaml, _NAVYamlNode sequenceNode, integer index, _NAVYamlNode result) {
    stack_var integer childIndex
    stack_var integer currentIndex

    if (!NAVYamlIsSequence(sequenceNode)) {
        return false
    }

    if (sequenceNode.firstChild == 0) {
        return false
    }

    if (index < 0 || index >= sequenceNode.childCount) {
        return false
    }

    childIndex = sequenceNode.firstChild
    currentIndex = 0

    while (childIndex != 0) {
        if (childIndex > yaml.nodeCount) {
            return false
        }

        if (currentIndex == index) {
            result = yaml.nodes[childIndex]
            return true
        }

        result = yaml.nodes[childIndex]
        childIndex = result.nextSibling
        currentIndex++
    }

    return false
}


(***********************************************************)
(*               QUERY EXECUTOR FUNCTIONS                  *)
(***********************************************************)

/**
 * @function NAVYamlQueryExecute
 * @private
 * @description Executes a parsed query path against a YAML tree.
 * Navigates through the YAML tree following the path steps to find the target node.
 *
 * @param {_NAVYaml} yaml - The YAML structure to query
 * @param {_NAVYamlQueryStep[]} steps - Array of path steps to execute
 * @param {integer} stepCount - Number of steps
 * @param {_NAVYamlNode} result - The resulting node (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 */
define_function char NAVYamlQueryExecute(_NAVYaml yaml, _NAVYamlQueryStep steps[], integer stepCount, _NAVYamlNode result) {
    stack_var _NAVYamlNode current
    stack_var integer i

    #IF_DEFINED YAML_QUERY_DEBUG
    NAVLog("'[ YamlQueryExecute ]: Starting execution. Step count: ', itoa(stepCount)")
    #END_IF

    // Handle root query (just ".")
    if (stepCount == 0) {
        #IF_DEFINED YAML_QUERY_DEBUG
        NAVLog("'[ YamlQueryExecute ]: Returning root node'")
        #END_IF
        return NAVYamlGetRootNode(yaml, result)
    }

    // Start from root
    if (!NAVYamlGetRootNode(yaml, current)) {
        return false
    }

    // Execute each step
    for (i = 1; i <= stepCount; i++) {
        #IF_DEFINED YAML_QUERY_DEBUG
        NAVLog("'[ YamlQueryExecute ]: Executing step ', itoa(i), ' of ', itoa(stepCount)")
        #END_IF

        select {
            active (steps[i].type == NAV_YAML_QUERY_STEP_PROPERTY): {
                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryExecute ]: Looking for property: ', steps[i].property")
                #END_IF

                if (!NAVYamlGetPropertyByKey(yaml, current, steps[i].property, current)) {
                    #IF_DEFINED YAML_QUERY_DEBUG
                    NAVLog("'[ YamlQueryExecute ]: Property not found: ', steps[i].property")
                    #END_IF
                    return false
                }

                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryExecute ]: Property found: ', steps[i].property, ' (type=', itoa(current.type), ')'")
                #END_IF
            }

            active (steps[i].type == NAV_YAML_QUERY_STEP_INDEX): {
                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryExecute ]: Looking for sequence element at index: ', itoa(steps[i].index), ' (1-based)'")
                #END_IF

                // Queries use 1-based indexing (matching YAML conventions and NetLinx arrays)
                // Convert to 0-based for internal API
                if (!NAVYamlGetSequenceElement(yaml, current, steps[i].index - 1, current)) {
                    #IF_DEFINED YAML_QUERY_DEBUG
                    NAVLog("'[ YamlQueryExecute ]: Sequence element not found at index: ', itoa(steps[i].index)")
                    #END_IF
                    return false
                }

                #IF_DEFINED YAML_QUERY_DEBUG
                NAVLog("'[ YamlQueryExecute ]: Sequence element found at index: ', itoa(steps[i].index), ' (type=', itoa(current.type), ')'")
                #END_IF
            }
        }
    }

    #IF_DEFINED YAML_QUERY_DEBUG
    NAVLog("'[ YamlQueryExecute ]: Execution complete. Result type: ', itoa(current.type)")
    #END_IF

    result = current
    return true
}


(***********************************************************)
(*                  CORE QUERY FUNCTION                    *)
(***********************************************************)

/**
 * @function NAVYamlQuery
 * @public
 * @description Queries a YAML structure using a yq-like query syntax.
 * Main entry point for querying YAML data using a simple dot notation.
 *
 * Supports:
 * - `.` (root node)
 * - `.property` (mapping property access)
 * - `.[index]` (sequence element access, 1-based indexing)
 * - `.property.nested` (chained property access)
 * - `.property[index]` (mixed access)
 *
 * @param {_NAVYaml} yaml - The YAML structure to query
 * @param {char[]} query - The query string (e.g., ".user.name", ".items[1]")
 * @param {_NAVYamlNode} result - The resulting node (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var _NAVYamlNode node
 * if (NAVYamlQuery(yaml, '.user.name', node)) {
 *     // Use node
 * }
 */
define_function char NAVYamlQuery(_NAVYaml yaml, char query[], _NAVYamlNode result) {
    stack_var _NAVYamlQueryToken tokens[NAV_YAML_QUERY_MAX_TOKENS]
    stack_var _NAVYamlQueryStep steps[NAV_YAML_QUERY_MAX_PATH_STEPS]
    stack_var integer tokenCount
    stack_var integer stepCount

    #IF_DEFINED YAML_QUERY_DEBUG
    NAVLog("'[ YamlQuery ]: Query string: ', query")
    #END_IF

    // Tokenize
    tokenCount = NAVYamlQueryLexer(query, tokens)
    if (tokenCount == 0) {
        return false
    }

    // Parse
    stepCount = NAVYamlQueryParser(tokens, tokenCount, steps)
    if (stepCount < 0) {
        return false
    }

    // Execute
    return NAVYamlQueryExecute(yaml, steps, stepCount, result)
}


/**
 * @function NAVYamlQueryString
 * @public
 * @description Query for a string value at the specified path.
 * Returns false if the path doesn't exist or the value is not a string type.
 * The query function is type-safe and will not attempt implicit type conversion.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path (e.g., '.user.name', '.items[1].title')
 * @param {char[]} result - Output string value
 *
 * @returns {char} True if query succeeded and value is a string, False otherwise
 *
 * @example
 * stack_var char name[255]
 * if (NAVYamlQueryString(yaml, '.user.name', name)) {
 *     send_string 0, "'Name: ', name"
 * }
 */
define_function char NAVYamlQueryString(_NAVYaml yaml, char queryString[], char result[]) {
    stack_var _NAVYamlNode node

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    if (!NAVYamlIsString(node)) {
        return false
    }

    result = node.value
    return true
}


/**
 * @function NAVYamlQueryInteger
 * @public
 * @description Query for an unsigned 16-bit integer value (0-65535).
 * Returns false if the path doesn't exist or the value is not a numeric type.
 * The query function is type-safe and will not accept non-numeric nodes.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path (e.g., '.config.port', '.items[2].count')
 * @param {integer} result - Output integer value (unsigned 16-bit: 0-65535)
 *
 * @returns {char} True if query succeeded and value is numeric, False otherwise
 *
 * @example
 * stack_var integer port
 * if (NAVYamlQueryInteger(yaml, '.server.port', port)) {
 *     send_string 0, "'Port: ', itoa(port)"
 * }
 */
define_function char NAVYamlQueryInteger(_NAVYaml yaml, char queryString[], integer result) {
    stack_var _NAVYamlNode node
    stack_var integer value

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    if (!NAVYamlIsNumber(node)) {
        return false
    }

    if (!NAVParseInteger(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVYamlQuerySignedInteger
 * @public
 * @description Query for a signed 16-bit integer value (-32768 to 32767).
 * Returns false if the path doesn't exist or the value is not a numeric type.
 * Use this when values may be negative.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path
 * @param {sinteger} result - Output signed integer value (-32768 to 32767)
 *
 * @returns {char} True if query succeeded and value is numeric, False otherwise
 *
 * @example
 * stack_var sinteger temperature
 * if (NAVYamlQuerySignedInteger(yaml, '.sensor.temperature', temperature)) {
 *     send_string 0, "'Temperature: ', itoa(temperature), '°C'"
 * }
 */
define_function char NAVYamlQuerySignedInteger(_NAVYaml yaml, char queryString[], sinteger result) {
    stack_var _NAVYamlNode node
    stack_var sinteger value

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    if (!NAVYamlIsNumber(node)) {
        return false
    }

    if (!NAVParseSignedInteger(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVYamlQueryLong
 * @public
 * @description Query for an unsigned 32-bit long integer value (0-4294967295).
 * Returns false if the path doesn't exist or the value is not a numeric type.
 * Use this for large unsigned values that exceed the 16-bit integer range.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path
 * @param {long} result - Output long integer value (unsigned 32-bit: 0-4294967295)
 *
 * @returns {char} True if query succeeded and value is numeric, False otherwise
 *
 * @example
 * stack_var long timestamp
 * if (NAVYamlQueryLong(yaml, '.event.timestamp', timestamp)) {
 *     send_string 0, "'Timestamp: ', itoa(timestamp)"
 * }
 */
define_function char NAVYamlQueryLong(_NAVYaml yaml, char queryString[], long result) {
    stack_var _NAVYamlNode node

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    if (!NAVYamlIsNumber(node)) {
        return false
    }

    if (!NAVParseLong(node.value, result)) {
        return false
    }

    return true
}


/**
 * @function NAVYamlQuerySignedLong
 * @public
 * @description Query for a signed 32-bit long integer value (-2147483648 to 2147483647).
 * Returns false if the path doesn't exist or the value is not a numeric type.
 * Use this for large signed values that may be negative.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path
 * @param {slong} result - Output signed long integer value (-2147483648 to 2147483647)
 *
 * @returns {char} True if query succeeded and value is numeric, False otherwise
 *
 * @example
 * stack_var slong offset
 * if (NAVYamlQuerySignedLong(yaml, '.config.timeOffset', offset)) {
 *     send_string 0, "'Time offset: ', itoa(offset), ' seconds'"
 * }
 */
define_function char NAVYamlQuerySignedLong(_NAVYaml yaml, char queryString[], slong result) {
    stack_var _NAVYamlNode node

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    if (!NAVYamlIsNumber(node)) {
        return false
    }

    if (!NAVParseSignedLong(node.value, result)) {
        return false
    }

    return true
}


/**
 * @function NAVYamlQueryFloat
 * @public
 * @description Query for a floating-point value.
 * Returns false if the path doesn't exist or the value is not a numeric type.
 * Use this for decimal numbers and floating-point arithmetic.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path
 * @param {float} result - Output float value
 *
 * @returns {char} True if query succeeded and value is numeric, False otherwise
 *
 * @example
 * stack_var float temperature
 * if (NAVYamlQueryFloat(yaml, '.sensor.temperature', temperature)) {
 *     send_string 0, "'Temperature: ', ftoa(temperature), '°C'"
 * }
 */
define_function char NAVYamlQueryFloat(_NAVYaml yaml, char queryString[], float result) {
    stack_var _NAVYamlNode node
    stack_var float value

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    if (!NAVYamlIsNumber(node)) {
        return false
    }

    if (!NAVParseFloat(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVYamlQueryBoolean
 * @public
 * @description Query for a boolean value.
 * Returns false if the path doesn't exist or the value is not a boolean type.
 * Recognizes YAML boolean variations: true/false, yes/no, on/off (case-insensitive).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path
 * @param {char} result - Output boolean value (true=1/false=0)
 *
 * @returns {char} True if query succeeded and value is boolean, False otherwise
 *
 * @example
 * stack_var char enabled
 * if (NAVYamlQueryBoolean(yaml, '.feature.enabled', enabled)) {
 *     if (enabled) {
 *         send_string 0, "'Feature is enabled'"
 *     }
 * }
 */
define_function char NAVYamlQueryBoolean(_NAVYaml yaml, char queryString[], char result) {
    stack_var _NAVYamlNode node
    stack_var char value

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    if (!NAVYamlIsBoolean(node)) {
        return false
    }

    if (!NAVParseBoolean(node.value, value)) {
        return false
    }

    result = value
    return true
}


// =============================================================================
// Array Query Functions
// =============================================================================

/**
 * @function NAVYamlQueryStringArray
 * @public
 * @description Query for a homogeneous array of string values.
 * Returns false if the path doesn't exist, isn't a sequence, or contains non-string elements.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path to a sequence
 * @param {char[][]} result - Output string array
 *
 * @returns {char} True if query succeeded and all elements are strings, False otherwise
 *
 * @example
 * stack_var char names[10][128]
 * if (NAVYamlQueryStringArray(yaml, '.users', names)) {
 *     stack_var integer i
 *     for (i = 1; i <= length_array(names); i++) {
 *         send_string 0, "'User: ', names[i]"
 *     }
 * }
 */
define_function char NAVYamlQueryStringArray(_NAVYaml yaml, char queryString[], char result[][]) {
    stack_var _NAVYamlNode node

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    return NAVYamlToStringArray(yaml, node, result)
}


/**
 * @function NAVYamlQueryIntegerArray
 * @public
 * @description Query for a homogeneous array of unsigned 16-bit integer values (0-65535).
 * Returns false if the path doesn't exist, isn't a sequence, or contains non-numeric elements.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path to a sequence
 * @param {integer[]} result - Output integer array (unsigned 16-bit: 0-65535)
 *
 * @returns {char} True if query succeeded and all elements are numeric, False otherwise
 *
 * @example
 * stack_var integer ports[20]
 * if (NAVYamlQueryIntegerArray(yaml, '.config.ports', ports)) {
 *     stack_var integer i
 *     for (i = 1; i <= length_array(ports); i++) {
 *         send_string 0, "'Port: ', itoa(ports[i])"
 *     }
 * }
 */
define_function char NAVYamlQueryIntegerArray(_NAVYaml yaml, char queryString[], integer result[]) {
    stack_var _NAVYamlNode node

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    return NAVYamlToIntegerArray(yaml, node, result)
}


/**
 * @function NAVYamlQueryFloatArray
 * @public
 * @description Query for a homogeneous array of floating-point values.
 * Returns false if the path doesn't exist, isn't a sequence, or contains non-numeric elements.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path to a sequence
 * @param {float[]} result - Output float array
 *
 * @returns {char} True if query succeeded and all elements are numeric, False otherwise
 *
 * @example
 * stack_var float temperatures[50]
 * if (NAVYamlQueryFloatArray(yaml, '.sensor.readings', temperatures)) {
 *     stack_var integer i
 *     stack_var float average
 *     for (i = 1; i <= length_array(temperatures); i++) {
 *         average = average + temperatures[i]
 *     }
 *     average = average / length_array(temperatures)
 * }
 */
define_function char NAVYamlQueryFloatArray(_NAVYaml yaml, char queryString[], float result[]) {
    stack_var _NAVYamlNode node

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    return NAVYamlToFloatArray(yaml, node, result)
}


/**
 * @function NAVYamlQueryBooleanArray
 * @public
 * @description Query for a homogeneous array of boolean values.
 * Returns false if the path doesn't exist, isn't a sequence, or contains non-boolean elements.
 * Recognizes YAML boolean variations: true/false, yes/no, on/off (case-insensitive).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path to a sequence
 * @param {char[]} result - Output boolean array (each element true=1/false=0)
 *
 * @returns {char} True if query succeeded and all elements are boolean, False otherwise
 *
 * @example
 * stack_var char flags[8]
 * if (NAVYamlQueryBooleanArray(yaml, '.features.enabled', flags)) {
 *     stack_var integer i
 *     for (i = 1; i <= length_array(flags); i++) {
 *         send_string 0, "'Feature ', itoa(i), ': ', itoa(flags[i])"
 *     }
 * }
 */
define_function char NAVYamlQueryBooleanArray(_NAVYaml yaml, char queryString[], char result[]) {
    stack_var _NAVYamlNode node

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    return NAVYamlToBooleanArray(yaml, node, result)
}


// =============================================================================
// Helper Functions: Convert YAML Node to NetLinx Arrays
// =============================================================================

/**
 * @function NAVYamlToStringArray
 * @public
 * @description Converts a YAML sequence node to a NetLinx string array.
 * All sequence elements must be strings (homogeneous arrays only).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} sequenceNode - The sequence node to convert
 * @param {char[][]} result - The resulting string array (output parameter)
 *
 * @returns {char} true if successful, false if not a sequence or contains non-string elements
 */
define_function char NAVYamlToStringArray(_NAVYaml yaml, _NAVYamlNode sequenceNode, char result[][]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVYamlNode element

    if (!NAVYamlIsSequence(sequenceNode)) {
        return false
    }

    count = NAVYamlGetChildCount(sequenceNode)

    // Validate all elements are strings
    for (i = 1; i <= count; i++) {
        if (!NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)) {
            return false
        }

        if (!NAVYamlIsString(element)) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)
        result[i] = element.value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVYamlToFloatArray
 * @public
 * @description Converts a YAML sequence node to a NetLinx float array.
 * All sequence elements must be numbers (homogeneous arrays only).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} sequenceNode - The sequence node to convert
 * @param {float[]} result - The resulting float array (output parameter)
 *
 * @returns {char} true if successful, false if not a sequence or contains non-number elements
 */
define_function char NAVYamlToFloatArray(_NAVYaml yaml, _NAVYamlNode sequenceNode, float result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVYamlNode element

    if (!NAVYamlIsSequence(sequenceNode)) {
        return false
    }

    count = NAVYamlGetChildCount(sequenceNode)

    // Validate all elements are numbers
    for (i = 1; i <= count; i++) {
        if (!NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)) {
            return false
        }

        if (!NAVYamlIsNumber(element)) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        stack_var float value

        NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)

        if (!NAVParseFloat(element.value, value)) {
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVYamlToIntegerArray
 * @public
 * @description Converts a YAML sequence node to a NetLinx integer array (unsigned 16-bit: 0-65535).
 * All sequence elements must be numbers (homogeneous arrays only).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} sequenceNode - The sequence node to convert
 * @param {integer[]} result - The resulting integer array (output parameter)
 *
 * @returns {char} true if successful, false if not a sequence or contains non-number elements
 */
define_function char NAVYamlToIntegerArray(_NAVYaml yaml, _NAVYamlNode sequenceNode, integer result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVYamlNode element

    if (!NAVYamlIsSequence(sequenceNode)) {
        return false
    }

    count = NAVYamlGetChildCount(sequenceNode)

    // Validate all elements are numbers
    for (i = 1; i <= count; i++) {
        if (!NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)) {
            return false
        }

        if (!NAVYamlIsNumber(element)) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        stack_var integer value

        NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)

        if (!NAVParseInteger(element.value, value)) {
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVYamlToSignedIntegerArray
 * @public
 * @description Converts a YAML sequence node to a NetLinx signed integer array.
 * All sequence elements must be numbers (homogeneous arrays only).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} sequenceNode - The sequence node to convert
 * @param {sinteger[]} result - The resulting signed integer array (output parameter)
 *
 * @returns {char} true if successful, false if not a sequence or contains non-number elements
 */
define_function char NAVYamlToSignedIntegerArray(_NAVYaml yaml, _NAVYamlNode sequenceNode, sinteger result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVYamlNode element

    if (!NAVYamlIsSequence(sequenceNode)) {
        return false
    }

    count = NAVYamlGetChildCount(sequenceNode)

    // Validate all elements are numbers
    for (i = 1; i <= count; i++) {
        if (!NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)) {
            return false
        }

        if (!NAVYamlIsNumber(element)) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        stack_var sinteger value

        NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)

        if (!NAVParseSignedInteger(element.value, value)) {
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVYamlToLongArray
 * @public
 * @description Converts a YAML sequence node to a NetLinx long array (unsigned 32-bit).
 * All sequence elements must be numbers (homogeneous arrays only).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} sequenceNode - The sequence node to convert
 * @param {long[]} result - The resulting long array (output parameter)
 *
 * @returns {char} true if successful, false if not a sequence or contains non-number elements
 */
define_function char NAVYamlToLongArray(_NAVYaml yaml, _NAVYamlNode sequenceNode, long result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVYamlNode element

    if (!NAVYamlIsSequence(sequenceNode)) {
        return false
    }

    count = NAVYamlGetChildCount(sequenceNode)

    // Validate all elements are numbers
    for (i = 1; i <= count; i++) {
        if (!NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)) {
            return false
        }

        if (!NAVYamlIsNumber(element)) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        stack_var long value

        NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)

        if (!NAVParseLong(element.value, value)) {
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVYamlToSignedLongArray
 * @public
 * @description Converts a YAML sequence node to a NetLinx signed long array.
 * All sequence elements must be numbers (homogeneous arrays only).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} sequenceNode - The sequence node to convert
 * @param {slong[]} result - The resulting signed long array (output parameter)
 *
 * @returns {char} true if successful, false if not a sequence or contains non-number elements
 */
define_function char NAVYamlToSignedLongArray(_NAVYaml yaml, _NAVYamlNode sequenceNode, slong result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVYamlNode element

    if (!NAVYamlIsSequence(sequenceNode)) {
        return false
    }

    count = NAVYamlGetChildCount(sequenceNode)

    // Validate all elements are numbers
    for (i = 1; i <= count; i++) {
        if (!NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)) {
            return false
        }

        if (!NAVYamlIsNumber(element)) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        stack_var slong value

        NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)

        if (!NAVParseSignedLong(element.value, value)) {
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVYamlToBooleanArray
 * @public
 * @description Converts a YAML sequence node to a NetLinx boolean array.
 * All sequence elements must be booleans (homogeneous arrays only).
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {_NAVYamlNode} sequenceNode - The sequence node to convert
 * @param {char[]} result - The resulting boolean array (output parameter)
 *
 * @returns {char} true if successful, false if not a sequence or contains non-boolean elements
 */
define_function char NAVYamlToBooleanArray(_NAVYaml yaml, _NAVYamlNode sequenceNode, char result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVYamlNode element
    stack_var char value

    if (!NAVYamlIsSequence(sequenceNode)) {
        return false
    }

    count = NAVYamlGetChildCount(sequenceNode)

    // Validate all elements are booleans
    for (i = 1; i <= count; i++) {
        if (!NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)) {
            return false
        }

        if (!NAVYamlIsBoolean(element)) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        NAVYamlGetSequenceElement(yaml, sequenceNode, i - 1, element)

        if (!NAVParseBoolean(element.value, value)) {
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


// =============================================================================
// Query Array Functions (Missing Type-Specific Variants)
// =============================================================================

/**
 * @function NAVYamlQuerySignedIntegerArray
 * @public
 * @description Query for an array of signed integers.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path to a sequence
 * @param {sinteger[]} result - Output signed integer array
 * @return {char} True if query succeeded and value is a homogeneous number sequence
 */
define_function char NAVYamlQuerySignedIntegerArray(_NAVYaml yaml, char queryString[], sinteger result[]) {
    stack_var _NAVYamlNode node

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    return NAVYamlToSignedIntegerArray(yaml, node, result)
}


/**
 * @function NAVYamlQueryLongArray
 * @public
 * @description Query for an array of unsigned longs.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path to a sequence
 * @param {long[]} result - Output long array
 * @return {char} True if query succeeded and value is a homogeneous number sequence
 */
define_function char NAVYamlQueryLongArray(_NAVYaml yaml, char queryString[], long result[]) {
    stack_var _NAVYamlNode node

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    return NAVYamlToLongArray(yaml, node, result)
}


/**
 * @function NAVYamlQuerySignedLongArray
 * @public
 * @description Query for an array of signed longs.
 *
 * @param {_NAVYaml} yaml - The YAML document
 * @param {char[]} queryString - The query path to a sequence
 * @param {slong[]} result - Output signed long array
 * @return {char} True if query succeeded and value is a homogeneous number sequence
 */
define_function char NAVYamlQuerySignedLongArray(_NAVYaml yaml, char queryString[], slong result[]) {
    stack_var _NAVYamlNode node

    if (!NAVYamlQuery(yaml, queryString, node)) {
        return false
    }

    return NAVYamlToSignedLongArray(yaml, node, result)
}


#END_IF // __NAV_FOUNDATION_YAML_QUERY__
