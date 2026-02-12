PROGRAM_NAME='NAVFoundation.TomlParser'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TOML_PARSER__
#DEFINE __NAV_FOUNDATION_TOML_PARSER__ 'NAVFoundation.TomlParser'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.TomlLexer.axi'
#include 'NAVFoundation.TomlParser.h.axi'


// =============================================================================
// PARSER CORE FUNCTIONS
// =============================================================================

/**
 * @function NAVTomlParserInit
 * @private
 * @description Initialize a TOML parser with an array of tokens.
 *
 * @param {_NAVTomlParser} parser - The parser structure to initialize
 * @param {_NAVTomlToken[]} tokens - The array of tokens to parse
 *
 * @returns {void}
 */
define_function NAVTomlParserInit(_NAVTomlParser parser, _NAVTomlToken tokens[]) {
    parser.tokens = tokens
    parser.tokenCount = length_array(tokens)
    parser.cursor = 1
    parser.depth = 0
    parser.currentTableIndex = 0
    parser.currentTablePath = ''
}


/**
 * @function NAVTomlParserHasMoreTokens
 * @private
 * @description Check if the parser has more tokens to process.
 *
 * @param {_NAVTomlParser} parser - The parser to check
 *
 * @returns {char} True (1) if more tokens are available, False (0) if all consumed
 */
define_function char NAVTomlParserHasMoreTokens(_NAVTomlParser parser) {
    return parser.cursor <= parser.tokenCount
}


/**
 * @function NAVTomlParserCurrentToken
 * @private
 * @description Get the current token without advancing the cursor.
 *
 * @param {_NAVTomlParser} parser - The parser instance
 * @param {_NAVTomlToken} token - Output parameter to receive the current token
 *
 * @returns {char} True (1) if token retrieved, False (0) if no more tokens
 */
define_function char NAVTomlParserCurrentToken(_NAVTomlParser parser, _NAVTomlToken token) {
    if (!NAVTomlParserHasMoreTokens(parser)) {
        return false
    }

    token = parser.tokens[parser.cursor]
    return true
}


/**
 * @function NAVTomlParserAdvance
 * @private
 * @description Advance the parser cursor to the next token.
 *
 * @param {_NAVTomlParser} parser - The parser structure
 *
 * @returns {void}
 */
define_function NAVTomlParserAdvance(_NAVTomlParser parser) {
    parser.cursor++
}


/**
 * @function NAVTomlParserSkipNewlines
 * @private
 * @description Skip any newline tokens at the current position.
 *
 * @param {_NAVTomlParser} parser - The parser structure
 *
 * @returns {void}
 */
define_function NAVTomlParserSkipNewlines(_NAVTomlParser parser) {
    stack_var _NAVTomlToken token

    while (NAVTomlParserCurrentToken(parser, token)) {
        if (token.type == NAV_TOML_TOKEN_TYPE_NEWLINE) {
            NAVTomlParserAdvance(parser)
        }
        else {
            break
        }
    }
}


/**
 * @function NAVTomlParserSetError
 * @private
 * @description Set an error message with location information from a token.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {_NAVTomlToken} token - The token where the error occurred
 * @param {char[]} message - The error message
 *
 * @returns {void}
 */
define_function NAVTomlParserSetError(_NAVToml toml, _NAVTomlToken token, char message[]) {
    toml.error = message
    toml.errorLine = token.line
    toml.errorColumn = token.column

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                __NAV_FOUNDATION_TOML_PARSER__,
                                'NAVTomlParser',
                                "message, ' at line ', itoa(token.line), ', column ', itoa(token.column)")
}


/**
 * @function NAVTomlAllocateNode
 * @private
 * @description Allocate a new node from the node pool.
 *
 * @param {_NAVToml} toml - The TOML structure
 *
 * @returns {integer} Index of the allocated node (1-based), or 0 if pool exhausted
 */
define_function integer NAVTomlAllocateNode(_NAVToml toml) {
    if (toml.nodeCount >= NAV_TOML_PARSER_MAX_NODES) {
        toml.error = "'Node pool exhausted (max: ', itoa(NAV_TOML_PARSER_MAX_NODES), ')'"
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_TOML_PARSER__,
                                    'NAVTomlAllocateNode',
                                    toml.error)
        return 0
    }

    toml.nodeCount++
    return toml.nodeCount
}


/**
 * @function NAVTomlParserLinkChild
 * @private
 * @description Link a child node to its parent.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {integer} parentIndex - Index of the parent node
 * @param {integer} childIndex - Index of the child node to link
 *
 * @returns {void}
 */
define_function NAVTomlParserLinkChild(_NAVToml toml, integer parentIndex, integer childIndex) {
    stack_var integer lastSibling

    if (parentIndex == 0) {
        return
    }

    toml.nodes[childIndex].parent = parentIndex
    toml.nodes[parentIndex].childCount++

    // If parent has no children yet, this becomes the first child
    if (toml.nodes[parentIndex].firstChild == 0) {
        toml.nodes[parentIndex].firstChild = childIndex
        return
    }

    // Otherwise, append to the end of the sibling chain
    lastSibling = toml.nodes[parentIndex].firstChild

    while (toml.nodes[lastSibling].nextSibling != 0) {
        lastSibling = toml.nodes[lastSibling].nextSibling
    }

    toml.nodes[lastSibling].nextSibling = childIndex
}


/**
 * @function NAVTomlParserUnescapeString
 * @private
 * @description Unescape a TOML string by processing escape sequences.
 * Supports TOML 1.1.0 escape sequences including \e (ESC) and \xHH (hex bytes).
 *
 * @param {char[]} value - The string token value (including quotes)
 * @param {integer} tokenType - The token type (basic or literal)
 *
 * @returns {char[NAV_TOML_PARSER_MAX_STRING_LENGTH]} The unescaped string with quotes removed
 */
define_function char[NAV_TOML_PARSER_MAX_STRING_LENGTH] NAVTomlParserUnescapeString(char value[], integer tokenType) {
    stack_var integer i
    stack_var integer length
    stack_var char result[NAV_TOML_PARSER_MAX_STRING_LENGTH]
    stack_var char ch

    length = length_array(value)
    result = ''

    // Multiline strings
    if (tokenType == NAV_TOML_TOKEN_TYPE_MULTILINE_STRING) {
        // Check if it's basic (""") or literal (''')
        if (length >= 6 && left_string(value, 3) == '"""') {
            // Remove """..." quotes (NAVStringSlice has exclusive end)
            value = NAVStringSlice(value, 4, length - 2)

            // TOML spec: trim a newline immediately following opening delimiter
            length = length_array(value)
            if (length >= 2 && value[1] == $0D && value[2] == $0A) {
                // Trim CRLF (NAVStringSlice has exclusive end, so length+1)
                value = NAVStringSlice(value, 3, length + 1)
            }
            else if (length >= 1 && (value[1] == $0A || value[1] == $0D)) {
                // Trim LF or CR (NAVStringSlice has exclusive end, so length+1)
                value = NAVStringSlice(value, 2, length + 1)
            }

            // TOML spec: trim a newline immediately preceding closing delimiter
            length = length_array(value)
            if (length >= 2 && value[length-1] == $0D && value[length] == $0A) {
                // Trim trailing CRLF
                value = NAVStringSlice(value, 1, length - 1)
            }
            else if (length >= 1 && (value[length] == $0A || value[length] == $0D)) {
                // Trim trailing LF or CR
                value = NAVStringSlice(value, 1, length)
            }

            // Process escape sequences
            length = length_array(value)
            i = 1

            while (i <= length) {
                ch = value[i]

                if (ch == '\') {
                    i++
                    if (i > length) {
                        break
                    }

                    ch = value[i]

                    // TOML spec: line-ending backslash trims all whitespace and newlines
                    if (ch == $0A || ch == $0D || ch == ' ' || ch == $09) {
                        // Skip all following whitespace and newlines
                        while (i <= length && (value[i] == $0A || value[i] == $0D || value[i] == ' ' || value[i] == $09)) {
                            i++
                        }

                        i-- // Adjust because main loop will increment
                        // Don't add anything to result (backslash and whitespace are removed)
                    }
                    else {
                        // Regular escape sequence
                        switch (ch) {
                            case '"':  { result = "result, '"'" }
                            case '\':  { result = "result, '\'" }
                            case 'b':  { result = "result, $08" }
                            case 't':  { result = "result, $09" }
                            case 'n':  { result = "result, $0A" }
                            case 'f':  { result = "result, $0C" }
                            case 'r':  { result = "result, $0D" }
                            case 'e':  { result = "result, $1B" } // TOML 1.1.0: Escape character
                            case 'x': {
                                // TOML 1.1.0: Hex byte escape \xHH (2 hex digits for bytes 0-255)
                                stack_var integer hexValue
                                stack_var char hex1, hex2

                                i++
                                if (i > length) { break }
                                hex1 = value[i]
                                if (!NAVIsHexDigit(hex1)) { break }

                                i++
                                if (i > length) { break }
                                hex2 = value[i]
                                if (!NAVIsHexDigit(hex2)) { break }

                                // Convert two hex digits to byte value
                                hexValue = (hextoi("hex1") * 16) + hextoi("hex2")
                                result = "result, hexValue"
                            }
                            case 'u': {
                                // Unicode escape \uXXXX - preserve as-is (4 hex digits)
                                stack_var integer j

                                result = "result, '\u'"

                                for (j = 1; j <= 4; j++) {
                                    i++
                                    if (i <= length) {
                                        result = "result, value[i]"
                                    }
                                }
                            }
                            case 'U': {
                                // Unicode escape \UXXXXXXXX - preserve as-is (8 hex digits)
                                stack_var integer j

                                result = "result, '\U'"

                                for (j = 1; j <= 8; j++) {
                                    i++
                                    if (i <= length) {
                                        result = "result, value[i]"
                                    }
                                }
                            }
                            default:   { result = "result, ch" }
                        }
                    }
                }
                else {
                    result = "result, ch"
                }

                i++
            }
        }
        else if (length >= 6 && left_string(value, 3) == '''''''') {
            // Remove '''...' quotes - no escape processing for literal strings (NAVStringSlice has exclusive end)
            value = NAVStringSlice(value, 4, length - 2)

            // TOML spec: trim a newline immediately following opening delimiter
            length = length_array(value)
            if (length >= 2 && value[1] == $0D && value[2] == $0A) {
                // Trim CRLF (NAVStringSlice has exclusive end, so length+1)
                value = NAVStringSlice(value, 3, length + 1)
            }
            else if (length >= 1 && (value[1] == $0A || value[1] == $0D)) {
                // Trim LF or CR (NAVStringSlice has exclusive end, so length+1)
                value = NAVStringSlice(value, 2, length + 1)
            }

            result = value
        }

        return result
    }

    // Single-line strings
    // Check for basic string "..."
    if (length >= 2 && value[1] == '"' && value[length] == '"') {
        // Remove quotes
        value = NAVStringSlice(value, 2, length)
        length = length_array(value)

        // Process escape sequences
        i = 1

        while (i <= length) {
            ch = value[i]

            if (ch == '\') {
                i++
                if (i > length) {
                    break
                }

                ch = value[i]

                switch (ch) {
                    case '"':  { result = "result, '"'" }
                    case '\':  { result = "result, '\'" }
                    case 'b':  { result = "result, $08" }
                    case 't':  { result = "result, $09" }
                    case 'n':  { result = "result, $0A" }
                    case 'f':  { result = "result, $0C" }
                    case 'r':  { result = "result, $0D" }
                    case 'e':  { result = "result, $1B" } // TOML 1.1.0: Escape character
                    case 'x': {
                        // TOML 1.1.0: Hex byte escape \xHH (2 hex digits for bytes 0-255)
                        stack_var integer hexValue
                        stack_var char hex1, hex2

                        i++
                        if (i > length) { break }
                        hex1 = value[i]
                        if (!NAVIsHexDigit(hex1)) { break }

                        i++
                        if (i > length) { break }
                        hex2 = value[i]
                        if (!NAVIsHexDigit(hex2)) { break }

                        // Convert two hex digits to byte value
                        hexValue = (hextoi("hex1") * 16) + hextoi("hex2")
                        result = "result, hexValue"
                    }
                    case 'u': {
                        // Unicode escape \uXXXX - preserve as-is (4 hex digits)
                        stack_var integer j

                        result = "result, '\u'"

                        for (j = 1; j <= 4; j++) {
                            i++
                            if (i <= length) {
                                result = "result, value[i]"
                            }
                        }
                    }
                    case 'U': {
                        // Unicode escape \UXXXXXXXX - preserve as-is (8 hex digits)
                        stack_var integer j

                        result = "result, '\U'"

                        for (j = 1; j <= 8; j++) {
                            i++
                            if (i <= length) {
                                result = "result, value[i]"
                            }
                        }
                    }
                    default:   { result = "result, ch" }
                }
            }
            else {
                result = "result, ch"
            }

            i++
        }

        return result
    }

    // Check for literal string '...'
    if (length >= 2 && value[1] == '''' && value[length] == '''') {
        // Remove quotes - no escape processing
        value = NAVStringSlice(value, 2, length)
        return value
    }

    // Return as-is if no quotes found
    return value
}


/**
 * @function NAVTomlParserCheckDuplicateKey
 * @private
 * @description Check if a key already exists among a parent's children.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {integer} parentIndex - Index of the parent node
 * @param {char[]} key - The key to check for duplicates
 *
 * @returns {char} True (1) if duplicate found, False (0) otherwise
 */
define_function char NAVTomlParserCheckDuplicateKey(_NAVToml toml, integer parentIndex, char key[]) {
    stack_var integer childIndex

    if (parentIndex == 0 || key == '') {
        return false
    }

    childIndex = toml.nodes[parentIndex].firstChild

    while (childIndex != 0) {
        if (toml.nodes[childIndex].key == key) {
            return true  // Duplicate found
        }

        childIndex = toml.nodes[childIndex].nextSibling
    }

    return false
}


/**
 * @function NAVTomlParserFindOrCreateTable
 * @private
 * @description Find an existing table by path, or create it if it doesn't exist.
 *
 * @param {_NAVToml} toml - The TOML structure
 * @param {char[]} tablePath - The dotted path to the table (e.g., "database.server")
 * @param {integer} parentIndex - Parent node index (0 for root)
 * @param {char} isArrayTable - True if creating an array of tables element
 * @param {integer} errorLine - Line number for error reporting
 * @param {integer} errorColumn - Column number for error reporting
 *
 * @returns {integer} Index of the table node, or 0 on error
 */
define_function integer NAVTomlParserFindOrCreateTable(_NAVToml toml, char tablePath[], integer parentIndex, char isArrayTable, integer errorLine, integer errorColumn) {
    stack_var integer i
    stack_var integer tableIndex
    stack_var integer currentParent
    stack_var char keyComponents[NAV_TOML_PARSER_MAX_KEY_COMPONENTS][NAV_TOML_PARSER_MAX_KEY_LENGTH]
    stack_var integer componentCount
    stack_var char currentPath[NAV_TOML_PARSER_MAX_KEY_LENGTH]

    #IF_DEFINED TOML_PARSER_DEBUG
    NAVLog("'[ TomlParserFindOrCreateTable ]: path=', tablePath, ' parent=', itoa(parentIndex), ' isArrayTable=', itoa(isArrayTable)")
    #END_IF

    if (tablePath == '') {
        return parentIndex
    }

    // Split path into components
    componentCount = NAVSplitString(tablePath, '.', keyComponents)

    if (componentCount == 0) {
        return parentIndex
    }

    currentParent = parentIndex
    if (currentParent == 0) {
        currentParent = toml.rootIndex
    }

    currentPath = ''

    // Navigate/create each level
    for (i = 1; i <= componentCount; i++) {
        stack_var char foundChild
        stack_var integer childIndex

        if (currentPath == '') {
            currentPath = keyComponents[i]
        }
        else {
            currentPath = "currentPath, '.', keyComponents[i]"
        }

        foundChild = false
        childIndex = toml.nodes[currentParent].firstChild

        // Look for existing child with this key
        while (childIndex != 0) {
            if (toml.nodes[childIndex].key == keyComponents[i]) {
                foundChild = true
                currentParent = childIndex

                // Validate table conflicts
                // 1. Cannot define [table] after [[table]] (same name)
                if (!isArrayTable && i == componentCount &&
                    toml.nodes[childIndex].type == NAV_TOML_VALUE_TYPE_TABLE_ARRAY) {
                    toml.error = "'Cannot define table [', tablePath, '] after array of tables [[', tablePath, ']]'"
                    toml.errorLine = errorLine
                    toml.errorColumn = errorColumn
                    return 0
                }

                // 2. Cannot redefine existing value key as table
                if (i == componentCount &&
                    toml.nodes[childIndex].type != NAV_TOML_VALUE_TYPE_TABLE &&
                    toml.nodes[childIndex].type != NAV_TOML_VALUE_TYPE_TABLE_ARRAY) {
                    toml.error = "'Cannot redefine existing key ', keyComponents[i], ' as table'"
                    toml.errorLine = errorLine
                    toml.errorColumn = errorColumn
                    return 0
                }

                break
            }

            childIndex = toml.nodes[childIndex].nextSibling
        }

        // Create if not found
        if (!foundChild) {
            stack_var integer newTableIndex

            newTableIndex = NAVTomlAllocateNode(toml)
            if (newTableIndex == 0) {
                return 0
            }

            // Set node type based on whether this is an array table
            if (isArrayTable && i == componentCount) {
                toml.nodes[newTableIndex].type = NAV_TOML_VALUE_TYPE_TABLE_ARRAY
            }
            else {
                toml.nodes[newTableIndex].type = NAV_TOML_VALUE_TYPE_TABLE
            }

            toml.nodes[newTableIndex].key = keyComponents[i]
            toml.nodes[newTableIndex].tablePath = currentPath
            toml.nodes[newTableIndex].isArrayTable = false

            NAVTomlParserLinkChild(toml, currentParent, newTableIndex)

            currentParent = newTableIndex

            #IF_DEFINED TOML_PARSER_DEBUG
            NAVLog("'[ TomlParserFindOrCreateTable ]: Created table node ', itoa(newTableIndex), ' key=', keyComponents[i], ' path=', currentPath")
            #END_IF
        }
    }

    // If this is an array of tables, create a new array element
    if (isArrayTable) {
        stack_var integer arrayElementIndex

        arrayElementIndex = NAVTomlAllocateNode(toml)
        if (arrayElementIndex == 0) {
            return 0
        }

        toml.nodes[arrayElementIndex].type = NAV_TOML_VALUE_TYPE_TABLE
        toml.nodes[arrayElementIndex].key = ''
        toml.nodes[arrayElementIndex].tablePath = tablePath
        toml.nodes[arrayElementIndex].isArrayTable = true

        NAVTomlParserLinkChild(toml, currentParent, arrayElementIndex)

        #IF_DEFINED TOML_PARSER_DEBUG
        NAVLog("'[ TomlParserFindOrCreateTable ]: Created array table element ', itoa(arrayElementIndex)")
        #END_IF

        return arrayElementIndex
    }

    return currentParent
}


/**
 * @function NAVTomlParserParseKey
 * @private
 * @description Parse a key (bare or quoted) from the token stream.
 *
 * @param {_NAVTomlParser} parser - The parser instance
 * @param {_NAVToml} toml - The TOML structure
 * @param {char[]} key - Output parameter for the parsed key
 *
 * @returns {char} True (1) if success, False (0) on error
 */
define_function char NAVTomlParserParseKey(_NAVTomlParser parser, _NAVToml toml, char key[]) {
    stack_var _NAVTomlToken token

    if (!NAVTomlParserCurrentToken(parser, token)) {
        toml.error = 'Unexpected end of input while parsing key'
        return false
    }

    if (token.type == NAV_TOML_TOKEN_TYPE_BARE_KEY) {
        key = token.value
        NAVTomlParserAdvance(parser)
        return true
    }
    else if (token.type == NAV_TOML_TOKEN_TYPE_STRING) {
        // Quoted key
        key = NAVTomlParserUnescapeString(token.value, token.type)
        NAVTomlParserAdvance(parser)
        return true
    }
    else {
        NAVTomlParserSetError(toml, token, "'Expected key, got ', NAVTomlLexerGetTokenType(token.type)")
        return false
    }
}


/**
 * @function NAVTomlParserParseDottedKey
 * @private
 * @description Parse a dotted key path (e.g., a.b.c).
 *
 * @param {_NAVTomlParser} parser - The parser instance
 * @param {_NAVToml} toml - The TOML structure
 * @param {char[]} keyPath - Output parameter for the full dotted key path
 *
 * @returns {char} True (1) if success, False (0) on error
 */
define_function char NAVTomlParserParseDottedKey(_NAVTomlParser parser, _NAVToml toml, char keyPath[]) {
    stack_var _NAVTomlToken token
    stack_var char component[NAV_TOML_PARSER_MAX_KEY_LENGTH]

    keyPath = ''

    // Parse first key component
    if (!NAVTomlParserParseKey(parser, toml, component)) {
        return false
    }

    keyPath = component

    // Parse any additional components separated by dots
    while (NAVTomlParserCurrentToken(parser, token)) {
        if (token.type == NAV_TOML_TOKEN_TYPE_DOT) {
            NAVTomlParserAdvance(parser)

            if (!NAVTomlParserParseKey(parser, toml, component)) {
                return false
            }

            keyPath = "keyPath, '.', component"
        }
        else {
            break
        }
    }

    return true
}


/**
 * @function NAVTomlParserParseValue
 * @private
 * @description Parse a value (string, number, boolean, datetime, array, inline table).
 *
 * @param {_NAVTomlParser} parser - The parser instance
 * @param {_NAVToml} toml - The TOML structure
 *
 * @returns {integer} Index of the created value node, or 0 on error
 */
define_function integer NAVTomlParserParseValue(_NAVTomlParser parser, _NAVToml toml) {
    stack_var _NAVTomlToken token
    stack_var integer nodeIndex

    if (!NAVTomlParserCurrentToken(parser, token)) {
        toml.error = 'Unexpected end of input while parsing value'
        return 0
    }

    nodeIndex = NAVTomlAllocateNode(toml)
    if (nodeIndex == 0) {
        return 0
    }

    #IF_DEFINED TOML_PARSER_DEBUG
    NAVLog("'[ TomlParserParseValue ]: token type=', NAVTomlLexerGetTokenType(token.type), ' value="', token.value, '"'")
    #END_IF

    switch (token.type) {
        case NAV_TOML_TOKEN_TYPE_STRING: {
            toml.nodes[nodeIndex].type = NAV_TOML_VALUE_TYPE_STRING
            toml.nodes[nodeIndex].value = NAVTomlParserUnescapeString(token.value, token.type)
            // Detect string subtype based on quote style
            if (length_array(token.value) >= 2) {
                if (token.value[1] == '"') {
                    toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_STRING_BASIC
                }
                else if (token.value[1] == '''') {
                    toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_STRING_LITERAL
                }
            }

            NAVTomlParserAdvance(parser)
        }

        case NAV_TOML_TOKEN_TYPE_MULTILINE_STRING: {
            toml.nodes[nodeIndex].type = NAV_TOML_VALUE_TYPE_STRING
            toml.nodes[nodeIndex].value = NAVTomlParserUnescapeString(token.value, token.type)
            // Detect multiline string subtype from original source
            if (token.start >= 1 && token.start <= length_array(toml.source)) {
                if (toml.source[token.start] == '"') {
                    toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_STRING_MULTILINE
                }
                else {
                    toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_STRING_LITERAL_ML
                }
            }

            NAVTomlParserAdvance(parser)
        }

        case NAV_TOML_TOKEN_TYPE_INTEGER: {
            toml.nodes[nodeIndex].type = NAV_TOML_VALUE_TYPE_INTEGER
            toml.nodes[nodeIndex].value = token.value
            // Detect integer subtype (base) from prefix
            if (length_array(token.value) >= 2) {
                if (NAVStringStartsWith(token.value, '0x') || NAVStringStartsWith(token.value, '0X')) {
                    toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_HEXADECIMAL
                }
                else if (NAVStringStartsWith(token.value, '0o') || NAVStringStartsWith(token.value, '0O')) {
                    toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_OCTAL
                }
                else if (NAVStringStartsWith(token.value, '0b') || NAVStringStartsWith(token.value, '0B')) {
                    toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_BINARY
                }
                else {
                    toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_DECIMAL
                }
            }
            else {
                toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_DECIMAL
            }
            NAVTomlParserAdvance(parser)
        }

        case NAV_TOML_TOKEN_TYPE_FLOAT: {
            toml.nodes[nodeIndex].type = NAV_TOML_VALUE_TYPE_FLOAT
            toml.nodes[nodeIndex].value = token.value
            // Detect float subtype (inf, nan, or normal)
            if (token.value == 'inf' || token.value == '+inf' || token.value == '-inf') {
                toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_FLOAT_INF
            }
            else if (token.value == 'nan' || token.value == '+nan' || token.value == '-nan') {
                toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_FLOAT_NAN
            }
            else {
                toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_FLOAT_NORMAL
            }

            NAVTomlParserAdvance(parser)
        }

        case NAV_TOML_TOKEN_TYPE_BOOLEAN: {
            toml.nodes[nodeIndex].type = NAV_TOML_VALUE_TYPE_BOOLEAN
            toml.nodes[nodeIndex].value = token.value
            // Set boolean subtype
            if (token.value == 'true') {
                toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_TRUE
            }
            else {
                toml.nodes[nodeIndex].subtype = NAV_TOML_SUBTYPE_FALSE
            }

            NAVTomlParserAdvance(parser)
        }

        case NAV_TOML_TOKEN_TYPE_DATETIME: {
            toml.nodes[nodeIndex].type = NAV_TOML_VALUE_TYPE_DATETIME
            toml.nodes[nodeIndex].value = token.value
            NAVTomlParserAdvance(parser)
        }

        case NAV_TOML_TOKEN_TYPE_DATE: {
            toml.nodes[nodeIndex].type = NAV_TOML_VALUE_TYPE_DATE
            toml.nodes[nodeIndex].value = token.value
            NAVTomlParserAdvance(parser)
        }

        case NAV_TOML_TOKEN_TYPE_TIME: {
            toml.nodes[nodeIndex].type = NAV_TOML_VALUE_TYPE_TIME
            toml.nodes[nodeIndex].value = token.value
            NAVTomlParserAdvance(parser)
        }

        case NAV_TOML_TOKEN_TYPE_LEFT_BRACKET: {
            // Array
            if (!NAVTomlParserParseArray(parser, toml, nodeIndex)) {
                return 0
            }
        }

        case NAV_TOML_TOKEN_TYPE_LEFT_BRACE: {
            // Inline table
            if (!NAVTomlParserParseInlineTable(parser, toml, nodeIndex)) {
                return 0
            }
        }

        default: {
            NAVTomlParserSetError(toml, token, "'Unexpected token while parsing value: ', NAVTomlLexerGetTokenType(token.type)")
            return 0
        }
    }

    return nodeIndex
}


/**
 * @function NAVTomlParserParseArray
 * @private
 * @description Parse an array [ ... ].
 *
 * @param {_NAVTomlParser} parser - The parser instance
 * @param {_NAVToml} toml - The TOML structure
 * @param {integer} arrayIndex - Index of the array node to populate
 *
 * @returns {char} True (1) if success, False (0) on error
 */
define_function char NAVTomlParserParseArray(_NAVTomlParser parser, _NAVToml toml, integer arrayIndex) {
    stack_var _NAVTomlToken token
    stack_var integer firstElementType
    stack_var char firstElementSet

    toml.nodes[arrayIndex].type = NAV_TOML_VALUE_TYPE_ARRAY
    firstElementType = 0
    firstElementSet = false

    // Skip opening bracket
    NAVTomlParserAdvance(parser)
    NAVTomlParserSkipNewlines(parser)

    #IF_DEFINED TOML_PARSER_DEBUG
    NAVLog("'[ TomlParserParseArray ]: Starting array parsing'")
    #END_IF

    // Check for empty array
    if (NAVTomlParserCurrentToken(parser, token) && token.type == NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET) {
        NAVTomlParserAdvance(parser)
        return true
    }

    // Parse array elements
    while (NAVTomlParserCurrentToken(parser, token)) {
        stack_var integer valueIndex

        // Parse value
        valueIndex = NAVTomlParserParseValue(parser, toml)
        if (valueIndex == 0) {
            return false
        }

        // Validate array homogeneity (TOML spec requirement)
        if (!firstElementSet) {
            // Record the type of the first element
            firstElementType = toml.nodes[valueIndex].type
            firstElementSet = true
        }
        else {
            // Check subsequent elements match the first element's type
            if (toml.nodes[valueIndex].type != firstElementType) {
                NAVTomlParserSetError(toml, token, "'Arrays must be homogeneous: expected type ', itoa(firstElementType), ', got type ', itoa(toml.nodes[valueIndex].type)")
                return false
            }
        }

        NAVTomlParserLinkChild(toml, arrayIndex, valueIndex)

        NAVTomlParserSkipNewlines(parser)

        // Check for comma or closing bracket
        if (!NAVTomlParserCurrentToken(parser, token)) {
            toml.error = 'Unexpected end of input in array'
            return false
        }

        if (token.type == NAV_TOML_TOKEN_TYPE_COMMA) {
            NAVTomlParserAdvance(parser)
            NAVTomlParserSkipNewlines(parser)

            // Check for trailing comma
            if (NAVTomlParserCurrentToken(parser, token) && token.type == NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET) {
                NAVTomlParserAdvance(parser)
                return true
            }
        }
        else if (token.type == NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET) {
            NAVTomlParserAdvance(parser)
            return true
        }
        else {
            NAVTomlParserSetError(toml, token, "'Expected comma or ] in array, got ', NAVTomlLexerGetTokenType(token.type)")
            return false
        }
    }

    toml.error = 'Unexpected end of input in array'
    return false
}


/**
 * @function NAVTomlParserParseInlineTable
 * @private
 * @description Parse an inline table { ... }.
 * Supports TOML 1.1.0 multiline inline tables with newlines and trailing commas.
 *
 * @param {_NAVTomlParser} parser - The parser instance
 * @param {_NAVToml} toml - The TOML structure
 * @param {integer} tableIndex - Index of the table node to populate
 *
 * @returns {char} True (1) if success, False (0) on error
 */
define_function char NAVTomlParserParseInlineTable(_NAVTomlParser parser, _NAVToml toml, integer tableIndex) {
    stack_var _NAVTomlToken token

    toml.nodes[tableIndex].type = NAV_TOML_VALUE_TYPE_INLINE_TABLE

    // Skip opening brace
    NAVTomlParserAdvance(parser)
    NAVTomlParserSkipNewlines(parser)

    #IF_DEFINED TOML_PARSER_DEBUG
    NAVLog("'[ TomlParserParseInlineTable ]: Starting inline table parsing'")
    #END_IF

    // Check for empty table
    if (NAVTomlParserCurrentToken(parser, token) && token.type == NAV_TOML_TOKEN_TYPE_RIGHT_BRACE) {
        NAVTomlParserAdvance(parser)
        return true
    }

    // Parse key-value pairs
    while (NAVTomlParserCurrentToken(parser, token)) {
        stack_var char key[NAV_TOML_PARSER_MAX_KEY_LENGTH]
        stack_var integer valueIndex

        // Parse key
        if (!NAVTomlParserParseKey(parser, toml, key)) {
            return false
        }

        // Expect equals
        if (!NAVTomlParserCurrentToken(parser, token) || token.type != NAV_TOML_TOKEN_TYPE_EQUALS) {
            NAVTomlParserSetError(toml, token, 'Expected = after key in inline table')
            return false
        }

        NAVTomlParserAdvance(parser)

        // Parse value
        valueIndex = NAVTomlParserParseValue(parser, toml)
        if (valueIndex == 0) {
            return false
        }

        toml.nodes[valueIndex].key = key
        NAVTomlParserLinkChild(toml, tableIndex, valueIndex)

        NAVTomlParserSkipNewlines(parser)

        // Check for comma or closing brace
        if (!NAVTomlParserCurrentToken(parser, token)) {
            toml.error = 'Unexpected end of input in inline table'
            return false
        }

        if (token.type == NAV_TOML_TOKEN_TYPE_COMMA) {
            NAVTomlParserAdvance(parser)
            NAVTomlParserSkipNewlines(parser)

            // Check for trailing comma (TOML 1.1.0 feature)
            if (NAVTomlParserCurrentToken(parser, token) && token.type == NAV_TOML_TOKEN_TYPE_RIGHT_BRACE) {
                NAVTomlParserAdvance(parser)
                return true
            }
        }
        else if (token.type == NAV_TOML_TOKEN_TYPE_RIGHT_BRACE) {
            NAVTomlParserAdvance(parser)
            return true
        }
        else {
            NAVTomlParserSetError(toml, token, "'Expected comma or } in inline table, got ', NAVTomlLexerGetTokenType(token.type)")
            return false
        }
    }

    toml.error = 'Unexpected end of input in inline table'
    return false
}


/**
 * @function NAVTomlParserParseKeyValue
 * @private
 * @description Parse a key-value pair (key = value).
 *
 * @param {_NAVTomlParser} parser - The parser instance
 * @param {_NAVToml} toml - The TOML structure
 * @param {integer} parentTableIndex - Index of the parent table
 *
 * @returns {char} True (1) if success, False (0) on error
 */
define_function char NAVTomlParserParseKeyValue(_NAVTomlParser parser, _NAVToml toml, integer parentTableIndex) {
    stack_var char keyPath[NAV_TOML_PARSER_MAX_KEY_LENGTH]
    stack_var _NAVTomlToken token
    stack_var _NAVTomlToken keyToken
    stack_var integer valueIndex
    stack_var char keyComponents[NAV_TOML_PARSER_MAX_KEY_COMPONENTS][NAV_TOML_PARSER_MAX_KEY_LENGTH]
    stack_var integer componentCount
    stack_var integer targetTableIndex
    stack_var integer i

    #IF_DEFINED TOML_PARSER_DEBUG
    NAVLog("'[ TomlParserParseKeyValue ]: parentTable=', itoa(parentTableIndex)")
    #END_IF

    // Save current token for error reporting
    NAVTomlParserCurrentToken(parser, keyToken)

    // Parse dotted key
    if (!NAVTomlParserParseDottedKey(parser, toml, keyPath)) {
        return false
    }

    // Expect equals
    if (!NAVTomlParserCurrentToken(parser, token) || token.type != NAV_TOML_TOKEN_TYPE_EQUALS) {
        NAVTomlParserSetError(toml, token, 'Expected = after key')
        return false
    }
    NAVTomlParserAdvance(parser)

    // Handle dotted keys (create intermediate tables if needed)
    componentCount = NAVSplitString(keyPath, '.', keyComponents)

    if (componentCount == 0) {
        toml.error = 'Invalid key path'
        return false
    }

    targetTableIndex = parentTableIndex

    // Create intermediate tables for all but the last component
    if (componentCount > 1) {
        stack_var char intermediatePath[NAV_TOML_PARSER_MAX_KEY_LENGTH]

        intermediatePath = ''

        for (i = 1; i < componentCount; i++) {
            if (intermediatePath == '') {
                intermediatePath = keyComponents[i]
            }
            else {
                intermediatePath = "intermediatePath, '.', keyComponents[i]"
            }

            // Find or create intermediate table
            targetTableIndex = NAVTomlParserFindOrCreateTable(toml, intermediatePath, parentTableIndex, false, keyToken.line, keyToken.column)

            if (targetTableIndex == 0) {
                return false
            }
        }
    }

    // Parse value
    valueIndex = NAVTomlParserParseValue(parser, toml)
    if (valueIndex == 0) {
        return false
    }

    // Set the key to the last component
    toml.nodes[valueIndex].key = keyComponents[componentCount]

    // Check for duplicate key
    if (NAVTomlParserCheckDuplicateKey(toml, targetTableIndex, keyComponents[componentCount])) {
        toml.error = "'Duplicate key: ', keyComponents[componentCount]"
        toml.errorLine = keyToken.line
        toml.errorColumn = keyToken.column
        return false
    }

    NAVTomlParserLinkChild(toml, targetTableIndex, valueIndex)

    #IF_DEFINED TOML_PARSER_DEBUG
    NAVLog("'[ TomlParserParseKeyValue ]: Created value node ', itoa(valueIndex), ' key=', toml.nodes[valueIndex].key")
    #END_IF

    return true
}


/**
 * @function NAVTomlParserParse
 * @public
 * @description Parse a TOML token stream into a node tree.
 *
 * @param {_NAVTomlParser} parser - The parser instance
 * @param {_NAVToml} toml - The TOML structure to populate
 *
 * @returns {char} True (1) if parsing succeeded, False (0) on error
 */
define_function char NAVTomlParserParse(_NAVTomlParser parser, _NAVToml toml) {
    stack_var _NAVTomlToken token
    stack_var char tablePath[NAV_TOML_PARSER_MAX_KEY_LENGTH]

    #IF_DEFINED TOML_PARSER_DEBUG
    NAVLog("'[ TomlParserParse ]: Starting parse, ', itoa(parser.tokenCount), ' tokens'")
    #END_IF

    // Create root table
    toml.rootIndex = NAVTomlAllocateNode(toml)
    if (toml.rootIndex == 0) {
        return false
    }

    toml.nodes[toml.rootIndex].type = NAV_TOML_VALUE_TYPE_TABLE
    toml.nodes[toml.rootIndex].key = ''
    toml.nodes[toml.rootIndex].tablePath = ''

    parser.currentTableIndex = toml.rootIndex
    parser.currentTablePath = ''

    // Skip leading newlines
    NAVTomlParserSkipNewlines(parser)

    // Parse document
    while (NAVTomlParserCurrentToken(parser, token)) {
        if (token.type == NAV_TOML_TOKEN_TYPE_EOF) {
            break
        }

        switch (token.type) {
            case NAV_TOML_TOKEN_TYPE_NEWLINE:
            case NAV_TOML_TOKEN_TYPE_COMMENT: {
                // Skip newlines and comments
                NAVTomlParserAdvance(parser)
                continue
            }
            case NAV_TOML_TOKEN_TYPE_TABLE_HEADER: {
                // Parse table header [table.name]
                tablePath = token.value

                // Remove brackets
                if (length_array(tablePath) >= 2) {
                    tablePath = NAVStringSlice(tablePath, 2, length_array(tablePath))
                }

                #IF_DEFINED TOML_PARSER_DEBUG
                NAVLog("'[ TomlParserParse ]: Table header: ', tablePath")
                #END_IF

                parser.currentTableIndex = NAVTomlParserFindOrCreateTable(toml, tablePath, toml.rootIndex, false, token.line, token.column)

                if (parser.currentTableIndex == 0) {
                    return false
                }

                parser.currentTablePath = tablePath

                NAVTomlParserAdvance(parser)
                NAVTomlParserSkipNewlines(parser)
            }

            case NAV_TOML_TOKEN_TYPE_ARRAY_TABLE: {
                // Parse array of tables [[array.table]]
                tablePath = token.value

                // Remove [[ and ]]
                if (length_array(tablePath) >= 4) {
                    tablePath = NAVStringSlice(tablePath, 3, length_array(tablePath) - 1)
                }

                #IF_DEFINED TOML_PARSER_DEBUG
                NAVLog("'[ TomlParserParse ]: Array table header: ', tablePath")
                #END_IF

                parser.currentTableIndex = NAVTomlParserFindOrCreateTable(toml, tablePath, toml.rootIndex, true, token.line, token.column)

                if (parser.currentTableIndex == 0) {
                    return false
                }

                parser.currentTablePath = tablePath

                NAVTomlParserAdvance(parser)
                NAVTomlParserSkipNewlines(parser)
            }

            case NAV_TOML_TOKEN_TYPE_BARE_KEY:
            case NAV_TOML_TOKEN_TYPE_STRING: {
                // Parse key-value pair
                if (!NAVTomlParserParseKeyValue(parser, toml, parser.currentTableIndex)) {
                    return false
                }

                NAVTomlParserSkipNewlines(parser)
            }

            default: {
                NAVTomlParserSetError(toml, token, "'Unexpected token at document level: ', NAVTomlLexerGetTokenType(token.type)")
                return false
            }
        }
    }

    #IF_DEFINED TOML_PARSER_DEBUG
    NAVLog("'[ TomlParserParse ]: Parse complete, ', itoa(toml.nodeCount), ' nodes created'")
    #END_IF

    return true
}


#END_IF // __NAV_FOUNDATION_TOML_PARSER__
