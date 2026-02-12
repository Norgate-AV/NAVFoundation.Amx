PROGRAM_NAME='NAVFoundation.Json'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_JSON__
#DEFINE __NAV_FOUNDATION_JSON__ 'NAVFoundation.Json'

#include 'NAVFoundation.JsonLexer.axi'
#include 'NAVFoundation.JsonParser.axi'
#include 'NAVFoundation.JsonQuery.axi'


/**
 * @function NAVJsonParse
 * @public
 * @description Parse a JSON string into a node tree structure.
 *
 * @param {char[]} input - The JSON string to parse
 * @param {_NAVJson} json - Output parameter to receive the parsed structure
 *
 * @returns {char} True (1) if parsing succeeded, False (0) on error
 *
 * @example
 * stack_var _NAVJson json
 * if (NAVJsonParse('{"name":"John","age":30}', json)) {
 *     // Success - json.rootIndex points to root object node
 *     // Navigate via json.nodes[].firstChild and json.nodes[].nextSibling
 * } else {
 *     // Error - check json.error for details
 *     send_string 0, "'Parse error: ', json.error"
 * }
 */
define_function char NAVJsonParse(char input[], _NAVJson json) {
    stack_var _NAVJsonLexer lexer
    stack_var _NAVJsonParser parser

    // Initialize JSON structure
    json.nodeCount = 0
    json.rootIndex = 0
    json.error = ''
    json.errorLine = 0
    json.errorColumn = 0

    // Tokenize the input
    if (!NAVJsonLexerTokenize(lexer, input)) {
        json.error = lexer.error
        json.errorLine = lexer.line
        json.errorColumn = lexer.column
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JSON_PARSER__,
                                    'NAVJsonParse',
                                    "'Failed to tokenize input: ', lexer.error")
        return false
    }

    // Initialize parser
    NAVJsonParserInit(parser, lexer.tokens)

    // Parse the root value
    json.rootIndex = NAVJsonParserParseValue(parser, json, 0, '')
    if (json.rootIndex == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JSON_PARSER__,
                                    'NAVJsonParse',
                                    "'Failed to parse JSON: ', json.error")
        return false
    }

    // Verify we consumed all tokens (except EOF)
    if (!NAVJsonParserHasMoreTokens(parser)) {
        return true
    }

    {
        stack_var _NAVJsonToken token

        if (!NAVJsonParserCurrentToken(parser, token)) {
            return true
        }

        if (token.type == NAV_JSON_TOKEN_TYPE_EOF) {
            return true
        }

        NAVJsonParserSetError(json, token, "'Unexpected token after root value: ', token.value")
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JSON_PARSER__,
                                    'NAVJsonParse',
                                    "'Unexpected token after root value: ', token.value")
    }

    return false
}


/**
 * @function NAVJsonGetParentNode
 * @public
 * @description Get the parent node of the current node.
 *
 * This function retrieves the parent of the given node. Returns false if the
 * node has no parent (i.e., it is the root node).
 *
 * @param {_NAVJson} json - The parsed JSON structure
 * @param {_NAVJsonNode} currentNode - The current node
 * @param {_NAVJsonNode} parentNode - Output parameter to receive the parent node
 *
 * @returns {char} True (1) if parent exists, False (0) if at root
 *
 * @example
 * stack_var _NAVJson json
 * stack_var _NAVJsonNode current, parent
 *
 * // Walk back up to root
 * NAVJsonGetNode(json, someDeepNodeIndex, current)
 * while (NAVJsonGetParentNode(json, current, parent)) {
 *     send_string 0, "'Parent type: ', itoa(parent.type)"
 *     current = parent
 * }
 */
define_function char NAVJsonGetParentNode(_NAVJson json, _NAVJsonNode currentNode, _NAVJsonNode parentNode) {
    if (currentNode.parent == 0) {
        return false
    }

    return NAVJsonGetNode(json, currentNode.parent, parentNode)
}


/**
 * @function NAVJsonEscapeString
 * @public
 * @description Escape a string for use in JSON by adding escape sequences for special characters.
 *
 * This function converts special characters to their JSON escape sequences according to the JSON spec:
 * - Quotation mark (") -> \"
 * - Backslash (\) -> \\
 * - Forward slash (/) -> \/
 * - Backspace -> \b
 * - Form feed -> \f
 * - Line feed/newline -> \n
 * - Carriage return -> \r
 * - Tab -> \t
 * - Control characters (0x00-0x1F) -> \uXXXX
 *
 * This is useful when serializing data to JSON format to ensure special characters
 * are properly escaped.
 *
 * @param {char[]} value - The string to escape
 *
 * @returns {char[NAV_JSON_PARSER_MAX_STRING_LENGTH]} The escaped string
 *
 * @example
 * stack_var char escaped[512]
 * escaped = NAVJsonEscapeString('Hello "World"')  // Returns: Hello \"World\"
 * escaped = NAVJsonEscapeString('Line1', $0A, 'Line2')  // Returns: Line1\nLine2
 */
define_function char[NAV_JSON_PARSER_MAX_STRING_LENGTH] NAVJsonEscapeString(char value[]) {
    stack_var integer i
    stack_var integer len
    stack_var char result[NAV_JSON_PARSER_MAX_STRING_LENGTH]
    stack_var char ch

    len = length_array(value)
    result = ''

    for (i = 1; i <= len; i++) {
        ch = value[i]

        switch (ch) {
            case '"':  { result = "result, '\"'" }   // Quotation mark
            case '\':  { result = "result, '\\'" }    // Backslash
            case '/':  { result = "result, '\/'" }    // Forward slash
            case $08:  { result = "result, '\b'" }    // Backspace
            case $0C:  { result = "result, '\f'" }    // Form feed
            case $0A:  { result = "result, '\n'" }    // Line feed (newline)
            case $0D:  { result = "result, '\r'" }    // Carriage return
            case $09:  { result = "result, '\t'" }    // Tab
            default: {
                // Check for other control characters (0x00-0x1F)
                if (ch < $20) {
                    // Escape as \uXXXX (unicode escape with lowercase hex)
                    result = "result, '\u', format('%04x', ch)"
                }
                else {
                    result = "result, ch"
                }
            }
        }
    }

    return result
}


/**
 * @function NAVJsonSerializeIndent
 * @private
 * @description Generate indentation string for pretty printing.
 *
 * @param {integer} level - The indentation level
 * @param {integer} spacesPerLevel - Number of spaces per indentation level
 *
 * @returns {char[255]} The indentation string
 */
define_function char[255] NAVJsonSerializeIndent(integer level, integer spacesPerLevel) {
    stack_var integer i
    stack_var char result[255]

    result = ''

    if (spacesPerLevel == 0) {
        return result
    }

    for (i = 1; i <= (level * spacesPerLevel); i++) {
        result = "result, ' '"
    }

    return result
}


/**
 * @function NAVJsonSerializeNode
 * @private
 * @description Recursively serialize a JSON node and its children.
 *
 * @param {_NAVJson} json - The parsed JSON structure
 * @param {integer} nodeIndex - Index of the node to serialize
 * @param {integer} indent - Number of spaces per indent level (0 = no pretty print)
 * @param {integer} level - Current indentation level
 * @param {char[]} result - Output buffer (modified in place)
 *
 * @returns {void}
 */
define_function NAVJsonSerializeNode(_NAVJson json, integer nodeIndex, integer indent, integer level, char result[]) {
    stack_var _NAVJsonNode node
    stack_var integer childIndex
    stack_var char needsComma
    stack_var char newline[2]
    stack_var char space[1]

    if (!NAVJsonGetNode(json, nodeIndex, node)) {
        return
    }

    // Setup pretty-print characters
    if (indent > 0) {
        newline = "$0D, $0A"
        space = ' '
    }
    else {
        newline = ''
        space = ''
    }

    switch (node.type) {
        case NAV_JSON_VALUE_TYPE_OBJECT: {
            result = "result, '{'"

            if (node.firstChild != 0) {
                if (indent > 0) {
                    result = "result, newline"
                }

                childIndex = node.firstChild
                needsComma = false

                while (childIndex != 0) {
                    stack_var _NAVJsonNode child

                    if (needsComma) {
                        result = "result, ','"
                        if (indent > 0) {
                            result = "result, newline"
                        }
                    }

                    if (!NAVJsonGetNode(json, childIndex, child)) {
                        break
                    }

                    // Print indentation for property
                    if (indent > 0) {
                        result = "result, NAVJsonSerializeIndent(level + 1, indent)"
                    }

                    // Print key
                    result = "result, '"', NAVJsonEscapeString(child.key), '":', space"

                    // Print value
                    NAVJsonSerializeNode(json, childIndex, indent, level + 1, result)

                    childIndex = child.nextSibling
                    needsComma = true
                }

                if (indent > 0) {
                    result = "result, newline, NAVJsonSerializeIndent(level, indent)"
                }
            }

            result = "result, '}'"
        }

        case NAV_JSON_VALUE_TYPE_ARRAY: {
            result = "result, '['"

            if (node.firstChild != 0) {
                if (indent > 0) {
                    result = "result, newline"
                }

                childIndex = node.firstChild
                needsComma = false

                while (childIndex != 0) {
                    stack_var _NAVJsonNode child

                    if (needsComma) {
                        result = "result, ','"
                        if (indent > 0) {
                            result = "result, newline"
                        }
                    }

                    if (!NAVJsonGetNode(json, childIndex, child)) {
                        break
                    }

                    // Print indentation for element
                    if (indent > 0) {
                        result = "result, NAVJsonSerializeIndent(level + 1, indent)"
                    }

                    // Print value
                    NAVJsonSerializeNode(json, childIndex, indent, level + 1, result)

                    childIndex = child.nextSibling
                    needsComma = true
                }

                if (indent > 0) {
                    result = "result, newline, NAVJsonSerializeIndent(level, indent)"
                }
            }

            result = "result, ']'"
        }

        case NAV_JSON_VALUE_TYPE_STRING: {
            result = "result, '"', NAVJsonEscapeString(node.value), '"'"
        }

        case NAV_JSON_VALUE_TYPE_NUMBER: {
            result = "result, node.value"
        }

        case NAV_JSON_VALUE_TYPE_TRUE: {
            result = "result, 'true'"
        }

        case NAV_JSON_VALUE_TYPE_FALSE: {
            result = "result, 'false'"
        }

        case NAV_JSON_VALUE_TYPE_NULL: {
            result = "result, 'null'"
        }
    }
}


/**
 * @function NAVJsonSerialize
 * @public
 * @description Serialize a JSON structure to a JSON string.
 *
 * This function walks the JSON tree and serializes it back to JSON format.
 * Supports both compact (single-line) and pretty-printed (multi-line with indentation) output.
 *
 * @param {_NAVJson} json - The parsed JSON structure to serialize
 * @param {integer} indent - Number of spaces per indent level (0 = compact, no pretty print)
 * @param {char[]} output - Output buffer to receive the JSON string (modified in place)
 *
 * @returns {char} True (1) if successful, False (0) if no valid root node
 *
 * @example
 * stack_var _NAVJson json
 * stack_var char output[4096]
 *
 * NAVJsonParse('{"name":"John","age":30}', json)
 *
 * // Compact output (no pretty print)
 * NAVJsonSerialize(json, 0, output)
 * // Returns: {"name":"John","age":30}
 *
 * // Pretty print with 2 spaces per indent
 * NAVJsonSerialize(json, 2, output)
 * // Returns:
 * // {
 * //   "name": "John",
 * //   "age": 30
 * // }
 *
 * // Pretty print with 4 spaces per indent
 * NAVJsonSerialize(json, 4, output)
 */
define_function char NAVJsonSerialize(_NAVJson json, integer indent, char output[]) {
    output = ''

    // Check if we have a valid root node
    if (json.rootIndex == 0 || json.nodeCount == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JSON__,
                                    'NAVJsonSerialize',
                                    'No valid JSON structure to serialize')
        return false
    }

    // Serialize the root node recursively
    NAVJsonSerializeNode(json, json.rootIndex, indent, 0, output)

    return true
}


/**
 * @function NAVJsonLog
 * @public
 * @description Log a JSON structure to the console for debugging.
 *
 * This function serializes the JSON structure with 4-space indentation and outputs it
 * to the console using NAVLog. Each line is logged separately for better readability.
 *
 * @param {_NAVJson} json - The parsed JSON structure to log
 *
 * @example
 * stack_var _NAVJson json
 *
 * NAVJsonParse('{"name":"John","age":30,"active":true}', json)
 *
 * // Log pretty-printed JSON
 * NAVJsonLog(json)
 * // Output:
 * // {
 * //     "name": "John",
 * //     "age": 30,
 * //     "active": true
 * // }
 */
define_function NAVJsonLog(_NAVJson json) {
    stack_var char output[8192]
    stack_var char lines[256][255]
    stack_var integer lineCount
    stack_var integer i

    // Serialize the JSON with 4-space indent
    if (!NAVJsonSerialize(json, 4, output)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_JSON__,
                                    'NAVJsonLog',
                                    'Failed to serialize JSON for logging')
        return
    }

    // Split by newlines and log each line
    lineCount = NAVSplitString(output, "$0D, $0A", lines)

    for (i = 1; i <= lineCount; i++) {
        NAVLog(lines[i])
    }
}


#END_IF // __NAV_FOUNDATION_JSON__
