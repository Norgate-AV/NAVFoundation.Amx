PROGRAM_NAME='NAVFoundation.JsonQuery'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_JSON_QUERY__
#DEFINE __NAV_FOUNDATION_JSON_QUERY__ 'NAVFoundation.JsonQuery'

#include 'NAVFoundation.JsonParser.axi'
#include 'NAVFoundation.JsonQuery.h.axi'


(***********************************************************)
(*               QUERY LEXER FUNCTIONS                     *)
(***********************************************************)

/**
 * @function NAVJsonQueryLexer
 * @private
 * @description Tokenizes a JSON query string into tokens for parsing.
 * Converts a query string into a sequence of tokens representing dots, identifiers,
 * brackets, and numbers.
 *
 * @param {char[]} query - The query string to tokenize (e.g., ".user.name", ".items[0]")
 * @param {_NAVJsonQueryToken[]} tokens - Array to store the resulting tokens
 *
 * @returns {integer} Number of tokens generated, or 0 on error
 *
 * @example
 * stack_var _NAVJsonQueryToken tokens[NAV_JSON_QUERY_MAX_TOKENS]
 * stack_var integer count
 * count = NAVJsonQueryLexer('.user.name', tokens)
 */
define_function integer NAVJsonQueryLexer(char query[], _NAVJsonQueryToken tokens[]) {
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
        if (tokenCount >= NAV_JSON_QUERY_MAX_TOKENS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JSON_QUERY__,
                                        'NAVJsonQueryLexer',
                                        "'Too many tokens in query (max: ', itoa(NAV_JSON_QUERY_MAX_TOKENS), ')'")
            return 0
        }

        tokenCount++

        select {
            // DOT
            active (ch == '.'): {
                tokens[tokenCount].type = NAV_JSON_QUERY_TOKEN_DOT
                pos++
            }

            // LEFT_BRACKET
            active (ch == '['): {
                tokens[tokenCount].type = NAV_JSON_QUERY_TOKEN_LEFT_BRACKET
                pos++
            }

            // RIGHT_BRACKET
            active (ch == ']'): {
                tokens[tokenCount].type = NAV_JSON_QUERY_TOKEN_RIGHT_BRACKET
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
                tokens[tokenCount].type = NAV_JSON_QUERY_TOKEN_NUMBER
                tokens[tokenCount].number = atoi(numStr)
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

                tokens[tokenCount].type = NAV_JSON_QUERY_TOKEN_IDENTIFIER
                tokens[tokenCount].identifier = NAVStringSubstring(query, startPos, pos - startPos)
            }

            // Unknown character
            active (1): {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_JSON_QUERY__,
                                            'NAVJsonQueryLexer',
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
 * @function NAVJsonQueryParser
 * @private
 * @description Parses tokens into executable path steps.
 * Validates token sequence and converts tokens into navigation steps that can be
 * executed against a JSON tree.
 *
 * @param {_NAVJsonQueryToken[]} tokens - Array of tokens from the lexer
 * @param {integer} tokenCount - Number of tokens
 * @param {_NAVJsonQueryPathStep[]} steps - Array to store the resulting path steps
 *
 * @returns {integer} Number of steps generated, or 0 on error
 *
 * @example
 * stack_var _NAVJsonQueryPathStep steps[NAV_JSON_QUERY_MAX_PATH_STEPS]
 * stack_var integer stepCount
 * stepCount = NAVJsonQueryParser(tokens, tokenCount, steps)
 */
define_function integer NAVJsonQueryParser(_NAVJsonQueryToken tokens[], integer tokenCount, _NAVJsonQueryPathStep steps[]) {
    stack_var integer pos
    stack_var integer stepCount

    pos = 1
    stepCount = 0

    // Query must start with DOT
    if (tokenCount == 0 || tokens[pos].type != NAV_JSON_QUERY_TOKEN_DOT) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JSON_QUERY__,
                                    'NAVJsonQueryParser',
                                    "'Query must start with . (dot)'")
        return 0
    }

    pos++ // Skip initial DOT

    // Check if query is just "." (root)
    if (pos > tokenCount) {
        stepCount++
        steps[stepCount].type = NAV_JSON_QUERY_STEP_ROOT
        return stepCount
    }

    while (pos <= tokenCount) {
        if (stepCount >= NAV_JSON_QUERY_MAX_PATH_STEPS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JSON_QUERY__,
                                        'NAVJsonQueryParser',
                                        "'Too many path steps (max: ', itoa(NAV_JSON_QUERY_MAX_PATH_STEPS), ')'")
            return 0
        }

        stepCount++

        select {
            // Property access: IDENTIFIER
            active (tokens[pos].type == NAV_JSON_QUERY_TOKEN_IDENTIFIER): {
                steps[stepCount].type = NAV_JSON_QUERY_STEP_PROPERTY
                steps[stepCount].propertyKey = tokens[pos].identifier
                pos++

                // Check for array index following property: [NUMBER]
                if (pos <= tokenCount && tokens[pos].type == NAV_JSON_QUERY_TOKEN_LEFT_BRACKET) {
                    pos++

                    if (pos > tokenCount || tokens[pos].type != NAV_JSON_QUERY_TOKEN_NUMBER) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_JSON_QUERY__,
                                                    'NAVJsonQueryParser',
                                                    "'Expected number after ['")
                        return 0
                    }

                    stepCount++
                    steps[stepCount].type = NAV_JSON_QUERY_STEP_ARRAY_INDEX
                    steps[stepCount].arrayIndex = tokens[pos].number
                    pos++

                    if (pos > tokenCount || tokens[pos].type != NAV_JSON_QUERY_TOKEN_RIGHT_BRACKET) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_JSON_QUERY__,
                                                    'NAVJsonQueryParser',
                                                    "'Expected ] after array index'")
                        return 0
                    }
                    pos++
                }

                // Check for continuation with DOT
                if (pos <= tokenCount && tokens[pos].type == NAV_JSON_QUERY_TOKEN_DOT) {
                    pos++
                }
            }

            // Direct array access: [NUMBER]
            active (tokens[pos].type == NAV_JSON_QUERY_TOKEN_LEFT_BRACKET): {
                pos++

                if (pos > tokenCount || tokens[pos].type != NAV_JSON_QUERY_TOKEN_NUMBER) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_JSON_QUERY__,
                                                'NAVJsonQueryParser',
                                                "'Expected number after ['")
                    return 0
                }

                steps[stepCount].type = NAV_JSON_QUERY_STEP_ARRAY_INDEX
                steps[stepCount].arrayIndex = tokens[pos].number
                pos++

                if (pos > tokenCount || tokens[pos].type != NAV_JSON_QUERY_TOKEN_RIGHT_BRACKET) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_JSON_QUERY__,
                                                'NAVJsonQueryParser',
                                                "'Expected ] after array index'")
                    return 0
                }
                pos++

                // Check for continuation with DOT
                if (pos <= tokenCount && tokens[pos].type == NAV_JSON_QUERY_TOKEN_DOT) {
                    pos++
                }
            }

            active (1): {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_JSON_QUERY__,
                                            'NAVJsonQueryParser',
                                            "'Unexpected token type: ', itoa(tokens[pos].type)")
                return 0
            }
        }
    }

    return stepCount
}


(***********************************************************)
(*               QUERY EXECUTOR FUNCTIONS                  *)
(***********************************************************)

/**
 * @function NAVJsonQueryExecute
 * @private
 * @description Executes a parsed query path against a JSON tree.
 * Navigates through the JSON tree following the path steps to find the target node.
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {_NAVJsonQueryPathStep[]} steps - Array of path steps to execute
 * @param {integer} stepCount - Number of steps
 * @param {_NAVJsonNode} result - The resulting node (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var _NAVJsonNode result
 * if (NAVJsonQueryExecute(json, steps, stepCount, result)) {
 *     // Use result
 * }
 */
define_function char NAVJsonQueryExecute(_NAVJson json, _NAVJsonQueryPathStep steps[], integer stepCount, _NAVJsonNode result) {
    stack_var _NAVJsonNode current
    stack_var integer i

    // Handle root query
    if (stepCount == 1 && steps[1].type == NAV_JSON_QUERY_STEP_ROOT) {
        return NAVJsonGetRootNode(json, result)
    }

    // Start from root
    if (!NAVJsonGetRootNode(json, current)) {
        return false
    }

    // Execute each step
    for (i = 1; i <= stepCount; i++) {
        select {
            active (steps[i].type == NAV_JSON_QUERY_STEP_PROPERTY): {
                if (!NAVJsonGetPropertyByKey(json, current, steps[i].propertyKey, current)) {
                    return false
                }
            }

            active (steps[i].type == NAV_JSON_QUERY_STEP_ARRAY_INDEX): {
                // Convert 1-based query index to 0-based internal API index
                if (!NAVJsonGetArrayElement(json, current, steps[i].arrayIndex - 1, current)) {
                    return false
                }
            }
        }
    }

    result = current
    return true
}


(***********************************************************)
(*                  CORE QUERY FUNCTION                    *)
(***********************************************************)

/**
 * @function NAVJsonQuery
 * @public
 * @description Queries a JSON structure using a JQ-like query syntax.
 * Main entry point for querying JSON data using a simple dot notation.
 *
 * Supports:
 * - `.` (root node)
 * - `.property` (object property access)
 * - `.[index]` (array element access, 1-based indexing)
 * - `.property.nested` (chained property access)
 * - `.property[index]` (mixed access)
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string (e.g., ".user.name", ".items[1]")
 * @param {_NAVJsonNode} result - The resulting node (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var _NAVJsonNode node
 * if (NAVJsonQuery(json, '.user.name', node)) {
 *     // Use node
 * }
 */
define_function char NAVJsonQuery(_NAVJson json, char query[], _NAVJsonNode result) {
    stack_var _NAVJsonQueryToken tokens[NAV_JSON_QUERY_MAX_TOKENS]
    stack_var _NAVJsonQueryPathStep steps[NAV_JSON_QUERY_MAX_PATH_STEPS]
    stack_var integer tokenCount
    stack_var integer stepCount

    // Tokenize
    tokenCount = NAVJsonQueryLexer(query, tokens)
    if (tokenCount == 0) {
        return false
    }

    // Parse
    stepCount = NAVJsonQueryParser(tokens, tokenCount, steps)
    if (stepCount == 0) {
        return false
    }

    // Execute
    return NAVJsonQueryExecute(json, steps, stepCount, result)
}


(***********************************************************)
(*            CONVENIENCE QUERY FUNCTIONS                  *)
(***********************************************************)

/**
 * @function NAVJsonQueryString
 * @public
 * @description Queries for a string value at the specified path.
 * Returns false if the value is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {char[]} result - The resulting string value (output parameter)
 *
 * @returns {char} true if successful and result is a string, false otherwise (including null values)
 *
 * @example
 * stack_var char name[100]
 * if (NAVJsonQueryString(json, '.user.name', name)) {
 *     // Use name
 * }
 */
define_function char NAVJsonQueryString(_NAVJson json, char query[], char result[]) {
    stack_var _NAVJsonNode node

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    if (NAVJsonIsNull(node)) {
        return false
    }

    return NAVJsonGetString(node, result)
}


/**
 * @function NAVJsonQueryFloat
 * @public
 * @description Queries for a float value at the specified path.
 * Returns false if the value is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {float} result - The resulting float value (output parameter)
 *
 * @returns {char} true if successful and result is a number, false otherwise (including null values)
 *
 * @example
 * stack_var float temperature
 * if (NAVJsonQueryFloat(json, '.data.temperature', temperature)) {
 *     // Use temperature
 * }
 */
define_function char NAVJsonQueryFloat(_NAVJson json, char query[], float result) {
    stack_var _NAVJsonNode node

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    if (NAVJsonIsNull(node)) {
        return false
    }

    return NAVJsonGetNumber(node, result)
}


/**
 * @function NAVJsonQueryInteger
 * @public
 * @description Queries for an integer value (unsigned 16-bit: 0-65535) at the specified path.
 * Returns false if the value is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {integer} result - The resulting integer value (output parameter)
 *
 * @returns {char} true if successful and result is a valid integer, false otherwise (including null values)
 *
 * @example
 * stack_var integer count
 * if (NAVJsonQueryInteger(json, '.data.count', count)) {
 *     // Use count
 * }
 */
define_function char NAVJsonQueryInteger(_NAVJson json, char query[], integer result) {
    stack_var _NAVJsonNode node
    stack_var integer value

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    if (NAVJsonIsNull(node)) {
        return false
    }

    if (!NAVJsonIsNumber(node)) {
        return false
    }

    if (!NAVParseInteger(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVJsonQuerySignedInteger
 * @public
 * @description Queries for a signed integer value (signed 16-bit: -32768 to 32767) at the specified path.
 * Returns false if the value is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {sinteger} result - The resulting signed integer value (output parameter)
 *
 * @returns {char} true if successful and result is a valid signed integer, false otherwise (including null values)
 *
 * @example
 * stack_var sinteger offset
 * if (NAVJsonQuerySignedInteger(json, '.data.offset', offset)) {
 *     // Use offset
 * }
 */
define_function char NAVJsonQuerySignedInteger(_NAVJson json, char query[], sinteger result) {
    stack_var _NAVJsonNode node
    stack_var sinteger value

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    if (NAVJsonIsNull(node)) {
        return false
    }

    if (!NAVJsonIsNumber(node)) {
        return false
    }

    if (!NAVParseSignedInteger(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVJsonQueryLong
 * @public
 * @description Queries for a long value (unsigned 32-bit: 0-4294967295) at the specified path.
 * Returns false if the value is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {long} result - The resulting long value (output parameter)
 *
 * @returns {char} true if successful and result is a valid long, false otherwise (including null values)
 *
 * @example
 * stack_var long timestamp
 * if (NAVJsonQueryLong(json, '.data.timestamp', timestamp)) {
 *     // Use timestamp
 * }
 */
define_function char NAVJsonQueryLong(_NAVJson json, char query[], long result) {
    stack_var _NAVJsonNode node
    stack_var long value

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    if (NAVJsonIsNull(node)) {
        return false
    }

    if (!NAVJsonIsNumber(node)) {
        return false
    }

    if (!NAVParseLong(node.value, value)) {
        return false
    }

    result = value
    return true
}


/**
 * @function NAVJsonQuerySignedLong
 * @public
 * @description Queries for a signed long value (signed 32-bit: -2147483648 to 2147483647) at the specified path.
 * Returns false if the value is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {slong} result - The resulting signed long value (output parameter)
 *
 * @returns {char} true if successful and result is a valid signed long, false otherwise (including null values)
 *
 * @example
 * stack_var slong signedValue
 * if (NAVJsonQuerySignedLong(json, '.data.value', signedValue)) {
 *     // Use signedValue
 * }
 */
define_function char NAVJsonQuerySignedLong(_NAVJson json, char query[], slong result) {
    stack_var _NAVJsonNode node
    stack_var slong value

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    if (NAVJsonIsNull(node)) {
        return false
    }

    if (!NAVJsonIsNumber(node)) {
        return false
    }

    if (!NAVParseSignedLong(node.value, value)) {
        return false
    }

    result = value
    return true
}



/**
 * @function NAVJsonQueryBoolean
 * @public
 * @description Queries for a boolean value at the specified path.
 * Returns false if the value is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {char} result - The resulting boolean value (output parameter)
 *
 * @returns {char} true if successful and result is a boolean, false otherwise (including null values)
 *
 * @example
 * stack_var char isEnabled
 * if (NAVJsonQueryBoolean(json, '.settings.enabled', isEnabled)) {
 *     // Use isEnabled
 * }
 */
define_function char NAVJsonQueryBoolean(_NAVJson json, char query[], char result) {
    stack_var _NAVJsonNode node

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    if (NAVJsonIsNull(node)) {
        return false
    }

    return NAVJsonGetBoolean(node, result)
}


(***********************************************************)
(*              ARRAY EXTRACTION FUNCTIONS                 *)
(***********************************************************)

/**
 * @function NAVJsonToStringArray
 * @public
 * @description Converts a JSON array node to a NetLinx string array.
 * All array elements must be strings (homogeneous arrays only).
 * Returns false if any element is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure
 * @param {_NAVJsonNode} arrayNode - The array node to convert
 * @param {char[][]} result - The resulting string array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-string or null elements
 *
 * @example
 * stack_var char names[100][50]
 * stack_var _NAVJsonNode arrayNode
 * if (NAVJsonQuery(json, '.users', arrayNode)) {
 *     if (NAVJsonToStringArray(json, arrayNode, names)) {
 *         // Use names array
 *     }
 * }
 */
define_function char NAVJsonToStringArray(_NAVJson json, _NAVJsonNode arrayNode, char result[][]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVJsonNode element

    if (!NAVJsonIsArray(arrayNode)) {
        return false
    }

    count = NAVJsonGetChildCount(arrayNode)

    // Validate all elements are strings (not null)
    for (i = 1; i <= count; i++) {
        if (!NAVJsonGetArrayElement(json, arrayNode, i - 1, element)) {
            return false
        }

        if (NAVJsonIsNull(element)) {
            return false
        }

        if (!NAVJsonIsString(element)) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        NAVJsonGetArrayElement(json, arrayNode, i - 1, element)
        NAVJsonGetString(element, result[i])
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVJsonToFloatArray
 * @public
 * @description Converts a JSON array node to a NetLinx float array.
 * All array elements must be numbers (homogeneous arrays only).
 * Returns false if any element is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure
 * @param {_NAVJsonNode} arrayNode - The array node to convert
 * @param {float[]} result - The resulting float array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-number or null elements
 *
 * @example
 * stack_var float temperatures[100]
 * stack_var _NAVJsonNode arrayNode
 * if (NAVJsonQuery(json, '.data.temperatures', arrayNode)) {
 *     if (NAVJsonToFloatArray(json, arrayNode, temperatures)) {
 *         // Use temperatures array
 *     }
 * }
 */
define_function char NAVJsonToFloatArray(_NAVJson json, _NAVJsonNode arrayNode, float result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVJsonNode element

    if (!NAVJsonIsArray(arrayNode)) {
        return false
    }

    count = NAVJsonGetChildCount(arrayNode)

    // Validate all elements are numbers (not null)
    for (i = 1; i <= count; i++) {
        if (!NAVJsonGetArrayElement(json, arrayNode, i - 1, element)) {
            return false
        }

        if (NAVJsonIsNull(element)) {
            return false
        }

        if (!NAVJsonIsNumber(element)) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        stack_var float value

        NAVJsonGetArrayElement(json, arrayNode, i - 1, element)

        if (!NAVParseFloat(element.value, value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JSON_QUERY__,
                                        'NAVJsonToFloatArray',
                                        "'Failed to parse element ', itoa(i), ': ', element.value")
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVJsonToIntegerArray
 * @public
 * @description Converts a JSON array node to a NetLinx integer array (unsigned 16-bit: 0-65535).
 * All array elements must be numbers (homogeneous arrays only).
 * Returns false if any element is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure
 * @param {_NAVJsonNode} arrayNode - The array node to convert
 * @param {integer[]} result - The resulting integer array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-number or null elements
 *
 * @example
 * stack_var integer ports[50]
 * stack_var _NAVJsonNode arrayNode
 * if (NAVJsonQuery(json, '.config.ports', arrayNode)) {
 *     if (NAVJsonToIntegerArray(json, arrayNode, ports)) {
 *         // Use ports array
 *     }
 * }
 */
define_function char NAVJsonToIntegerArray(_NAVJson json, _NAVJsonNode arrayNode, integer result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVJsonNode element

    if (!NAVJsonIsArray(arrayNode)) {
        return false
    }

    count = NAVJsonGetChildCount(arrayNode)

    // Validate all elements are numbers (not null)
    for (i = 1; i <= count; i++) {
        if (!NAVJsonGetArrayElement(json, arrayNode, i - 1, element)) {
            return false
        }

        if (NAVJsonIsNull(element)) {
            return false
        }

        if (!NAVJsonIsNumber(element)) {
            return false
        }
    }

    // Extract values with direct parsing
    for (i = 1; i <= count; i++) {
        stack_var integer value

        NAVJsonGetArrayElement(json, arrayNode, i - 1, element)

        if (!NAVParseInteger(element.value, value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JSON_QUERY__,
                                        'NAVJsonToIntegerArray',
                                        "'Failed to parse element ', itoa(i), ': ', element.value")
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVJsonToSignedIntegerArray
 * @public
 * @description Converts a JSON array node to a NetLinx signed integer array (signed 16-bit: -32768 to 32767).
 * All array elements must be numbers (homogeneous arrays only).
 * Returns false if any element is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure
 * @param {_NAVJsonNode} arrayNode - The array node to convert
 * @param {sinteger[]} result - The resulting signed integer array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-number or null elements
 *
 * @example
 * stack_var sinteger offsets[100]
 * stack_var _NAVJsonNode arrayNode
 * if (NAVJsonQuery(json, '.data.offsets', arrayNode)) {
 *     if (NAVJsonToSignedIntegerArray(json, arrayNode, offsets)) {
 *         // Use offsets array
 *     }
 * }
 */
define_function char NAVJsonToSignedIntegerArray(_NAVJson json, _NAVJsonNode arrayNode, sinteger result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVJsonNode element

    if (!NAVJsonIsArray(arrayNode)) {
        return false
    }

    count = NAVJsonGetChildCount(arrayNode)

    // Validate all elements are numbers (not null)
    for (i = 1; i <= count; i++) {
        if (!NAVJsonGetArrayElement(json, arrayNode, i - 1, element)) {
            return false
        }

        if (NAVJsonIsNull(element)) {
            return false
        }

        if (!NAVJsonIsNumber(element)) {
            return false
        }
    }

    // Extract values with direct parsing
    for (i = 1; i <= count; i++) {
        stack_var sinteger value

        NAVJsonGetArrayElement(json, arrayNode, i - 1, element)

        if (!NAVParseSignedInteger(element.value, value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JSON_QUERY__,
                                        'NAVJsonToSignedIntegerArray',
                                        "'Failed to parse element ', itoa(i), ': ', element.value")
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVJsonToLongArray
 * @public
 * @description Converts a JSON array node to a NetLinx long array (unsigned 32-bit: 0-4294967295).
 * All array elements must be numbers (homogeneous arrays only).
 * Returns false if any element is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure
 * @param {_NAVJsonNode} arrayNode - The array node to convert
 * @param {long[]} result - The resulting long array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-number or null elements
 *
 * @example
 * stack_var long timestamps[100]
 * stack_var _NAVJsonNode arrayNode
 * if (NAVJsonQuery(json, '.data.timestamps', arrayNode)) {
 *     if (NAVJsonToLongArray(json, arrayNode, timestamps)) {
 *         // Use timestamps array
 *     }
 * }
 */
define_function char NAVJsonToLongArray(_NAVJson json, _NAVJsonNode arrayNode, long result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVJsonNode element

    if (!NAVJsonIsArray(arrayNode)) {
        return false
    }

    count = NAVJsonGetChildCount(arrayNode)

    // Validate all elements are numbers (not null)
    for (i = 1; i <= count; i++) {
        if (!NAVJsonGetArrayElement(json, arrayNode, i - 1, element)) {
            return false
        }

        if (NAVJsonIsNull(element)) {
            return false
        }

        if (!NAVJsonIsNumber(element)) {
            return false
        }
    }

    // Extract values with direct parsing
    for (i = 1; i <= count; i++) {
        stack_var long value

        NAVJsonGetArrayElement(json, arrayNode, i - 1, element)

        if (!NAVParseLong(element.value, value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JSON_QUERY__,
                                        'NAVJsonToLongArray',
                                        "'Failed to parse element ', itoa(i), ': ', element.value")
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVJsonToSignedLongArray
 * @public
 * @description Converts a JSON array node to a NetLinx signed long array (signed 32-bit: -2147483648 to 2147483647).
 * All array elements must be numbers (homogeneous arrays only).
 * Returns false if any element is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure
 * @param {_NAVJsonNode} arrayNode - The array node to convert
 * @param {slong[]} result - The resulting signed long array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-number or null elements
 *
 * @example
 * stack_var slong values[100]
 * stack_var _NAVJsonNode arrayNode
 * if (NAVJsonQuery(json, '.data.values', arrayNode)) {
 *     if (NAVJsonToSignedLongArray(json, arrayNode, values)) {
 *         // Use values array
 *     }
 * }
 */
define_function char NAVJsonToSignedLongArray(_NAVJson json, _NAVJsonNode arrayNode, slong result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVJsonNode element

    if (!NAVJsonIsArray(arrayNode)) {
        return false
    }

    count = NAVJsonGetChildCount(arrayNode)

    // Validate all elements are numbers (not null)
    for (i = 1; i <= count; i++) {
        if (!NAVJsonGetArrayElement(json, arrayNode, i - 1, element)) {
            return false
        }

        if (NAVJsonIsNull(element)) {
            return false
        }

        if (!NAVJsonIsNumber(element)) {
            return false
        }
    }

    // Extract values with direct parsing
    for (i = 1; i <= count; i++) {
        stack_var slong value

        NAVJsonGetArrayElement(json, arrayNode, i - 1, element)

        if (!NAVParseSignedLong(element.value, value)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_JSON_QUERY__,
                                        'NAVJsonToSignedLongArray',
                                        "'Failed to parse element ', itoa(i), ': ', element.value")
            return false
        }

        result[i] = value
    }

    set_length_array(result, count)
    return true
}



/**
 * @function NAVJsonToBooleanArray
 * @public
 * @description Converts a JSON array node to a NetLinx boolean array.
 * All array elements must be booleans (homogeneous arrays only).
 * Returns false if any element is null (NetLinx has no null representation).
 *
 * @param {_NAVJson} json - The JSON structure
 * @param {_NAVJsonNode} arrayNode - The array node to convert
 * @param {char[]} result - The resulting boolean array (output parameter)
 *
 * @returns {char} true if successful, false if array contains non-boolean or null elements
 *
 * @example
 * stack_var char flags[50]
 * stack_var _NAVJsonNode arrayNode
 * if (NAVJsonQuery(json, '.settings.flags', arrayNode)) {
 *     if (NAVJsonToBooleanArray(json, arrayNode, flags)) {
 *         // Use flags array
 *     }
 * }
 */
define_function char NAVJsonToBooleanArray(_NAVJson json, _NAVJsonNode arrayNode, char result[]) {
    stack_var integer count
    stack_var integer i
    stack_var _NAVJsonNode element

    if (!NAVJsonIsArray(arrayNode)) {
        return false
    }

    count = NAVJsonGetChildCount(arrayNode)

    // Validate all elements are booleans (not null)
    for (i = 1; i <= count; i++) {
        if (!NAVJsonGetArrayElement(json, arrayNode, i - 1, element)) {
            return false
        }

        if (NAVJsonIsNull(element)) {
            return false
        }

        if (!NAVJsonIsBoolean(element)) {
            return false
        }
    }

    // Extract values
    for (i = 1; i <= count; i++) {
        NAVJsonGetArrayElement(json, arrayNode, i - 1, element)
        NAVJsonGetBoolean(element, result[i])
    }

    set_length_array(result, count)
    return true
}


/**
 * @function NAVJsonQueryStringArray
 * @public
 * @description Queries for a string array at the specified path.
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {char[][]} result - The resulting string array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var char names[100][50]
 * if (NAVJsonQueryStringArray(json, '.users', names)) {
 *     // Use names array
 * }
 */
define_function char NAVJsonQueryStringArray(_NAVJson json, char query[], char result[][]) {
    stack_var _NAVJsonNode node

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    return NAVJsonToStringArray(json, node, result)
}


/**
 * @function NAVJsonQueryFloatArray
 * @public
 * @description Queries for a float array at the specified path.
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {float[]} result - The resulting float array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var float temperatures[100]
 * if (NAVJsonQueryFloatArray(json, '.data.temperatures', temperatures)) {
 *     // Use temperatures array
 * }
 */
define_function char NAVJsonQueryFloatArray(_NAVJson json, char query[], float result[]) {
    stack_var _NAVJsonNode node

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    return NAVJsonToFloatArray(json, node, result)
}


/**
 * @function NAVJsonQueryIntegerArray
 * @public
 * @description Queries for an integer array (unsigned 16-bit: 0-65535) at the specified path.
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {integer[]} result - The resulting integer array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var integer ports[50]
 * if (NAVJsonQueryIntegerArray(json, '.config.ports', ports)) {
 *     // Use ports array
 * }
 */
define_function char NAVJsonQueryIntegerArray(_NAVJson json, char query[], integer result[]) {
    stack_var _NAVJsonNode node

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    return NAVJsonToIntegerArray(json, node, result)
}


/**
 * @function NAVJsonQuerySignedIntegerArray
 * @public
 * @description Queries for a signed integer array (signed 16-bit: -32768 to 32767) at the specified path.
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {sinteger[]} result - The resulting signed integer array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var sinteger offsets[100]
 * if (NAVJsonQuerySignedIntegerArray(json, '.data.offsets', offsets)) {
 *     // Use offsets array
 * }
 */
define_function char NAVJsonQuerySignedIntegerArray(_NAVJson json, char query[], sinteger result[]) {
    stack_var _NAVJsonNode node

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    return NAVJsonToSignedIntegerArray(json, node, result)
}


/**
 * @function NAVJsonQueryLongArray
 * @public
 * @description Queries for a long array (unsigned 32-bit: 0-4294967295) at the specified path.
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {long[]} result - The resulting long array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var long timestamps[100]
 * if (NAVJsonQueryLongArray(json, '.data.timestamps', timestamps)) {
 *     // Use timestamps array
 * }
 */
define_function char NAVJsonQueryLongArray(_NAVJson json, char query[], long result[]) {
    stack_var _NAVJsonNode node

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    return NAVJsonToLongArray(json, node, result)
}


/**
 * @function NAVJsonQuerySignedLongArray
 * @public
 * @description Queries for a signed long array (signed 32-bit: -2147483648 to 2147483647) at the specified path.
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {slong[]} result - The resulting signed long array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var slong values[100]
 * if (NAVJsonQuerySignedLongArray(json, '.data.values', values)) {
 *     // Use values array
 * }
 */
define_function char NAVJsonQuerySignedLongArray(_NAVJson json, char query[], slong result[]) {
    stack_var _NAVJsonNode node

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    return NAVJsonToSignedLongArray(json, node, result)
}



/**
 * @function NAVJsonQueryBooleanArray
 * @public
 * @description Queries for a boolean array at the specified path.
 *
 * @param {_NAVJson} json - The JSON structure to query
 * @param {char[]} query - The query string
 * @param {char[]} result - The resulting boolean array (output parameter)
 *
 * @returns {char} true if successful, false otherwise
 *
 * @example
 * stack_var char flags[50]
 * if (NAVJsonQueryBooleanArray(json, '.settings.flags', flags)) {
 *     // Use flags array
 * }
 */
define_function char NAVJsonQueryBooleanArray(_NAVJson json, char query[], char result[]) {
    stack_var _NAVJsonNode node

    if (!NAVJsonQuery(json, query, node)) {
        return false
    }

    return NAVJsonToBooleanArray(json, node, result)
}


#END_IF // __NAV_FOUNDATION_JSON_QUERY__
