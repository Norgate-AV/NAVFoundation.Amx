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


#END_IF // __NAV_FOUNDATION_JSON__
