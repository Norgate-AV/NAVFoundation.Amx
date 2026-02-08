PROGRAM_NAME='NAVFoundation.YamlLexer'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_YAML_LEXER__
#DEFINE __NAV_FOUNDATION_YAML_LEXER__ 'NAVFoundation.YamlLexer'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.YamlLexer.h.axi'


// =============================================================================
// LEXER CORE FUNCTIONS
// =============================================================================

/**
 * @function NAVYamlLexerInit
 * @private
 * @description Initialize a YAML lexer with source text.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure to initialize
 * @param {char[]} source - The source text to tokenize
 *
 * @returns {void}
 */
define_function NAVYamlLexerInit(_NAVYamlLexer lexer, char source[]) {
    lexer.source = source
    lexer.cursor = 1
    lexer.start = 1
    lexer.line = 1
    lexer.column = 1
    lexer.tokenCount = 0
    lexer.hasError = false
    lexer.error = ''

    // Initialize indent stack with 0 (base indentation)
    lexer.indentStack[1] = 0
    lexer.indentStackSize = 1

    // Initialize block scalar tracking
    lexer.inBlockScalar = false
    lexer.blockScalarIndent = 0
}


/**
 * @function NAVYamlLexerSetError
 * @private
 * @description Set an error state on the lexer.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure
 * @param {char[]} message - Error message
 *
 * @returns {void}
 */
define_function NAVYamlLexerSetError(_NAVYamlLexer lexer, char message[]) {
    lexer.hasError = true
    lexer.error = message

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                __NAV_FOUNDATION_YAML_LEXER__,
                                'NAVYamlLexer',
                                "message, ' at line ', itoa(lexer.line), ', column ', itoa(lexer.column)")
}


/**
 * @function NAVYamlLexerEmitToken
 * @private
 * @description Emit a token of the specified type with the current lexer position.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure
 * @param {integer} type - The token type to emit
 *
 * @returns {char} True (1) if token emitted successfully, False (0) if token limit reached
 */
define_function char NAVYamlLexerEmitToken(_NAVYamlLexer lexer, integer type) {
    stack_var integer currentIndent

    if (!NAVYamlLexerCanAddToken(lexer)) {
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = type
    lexer.tokens[lexer.tokenCount].value = NAVStringSlice(lexer.source, lexer.start, lexer.cursor)
    lexer.tokens[lexer.tokenCount].line = lexer.line
    lexer.tokens[lexer.tokenCount].column = lexer.column - (lexer.cursor - lexer.start)

    // Get current indentation level from stack
    if (lexer.indentStackSize > 0) {
        currentIndent = lexer.indentStack[lexer.indentStackSize]
    }
    else {
        currentIndent = 0
    }

    lexer.tokens[lexer.tokenCount].indent = currentIndent
    lexer.tokens[lexer.tokenCount].quoteType = NAV_YAML_QUOTE_TYPE_NONE
    set_length_array(lexer.tokens, lexer.tokenCount)

    lexer.start = lexer.cursor

    return true
}


/**
 * @function NAVYamlLexerIgnore
 * @private
 * @description Ignore the current token by advancing the start position to the cursor.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure
 *
 * @returns {char} Always returns True (1)
 */
define_function char NAVYamlLexerIgnore(_NAVYamlLexer lexer) {
    lexer.start = lexer.cursor
    return true
}


/**
 * @function NAVYamlLexerIsEOF
 * @private
 * @description Check if the lexer has reached the end of the source text.
 *
 * @param {_NAVYamlLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if at end of file, False (0) otherwise
 */
define_function char NAVYamlLexerIsEOF(_NAVYamlLexer lexer) {
    return lexer.cursor > length_array(lexer.source)
}


/**
 * @function NAVYamlLexerNext
 * @private
 * @description Advance the cursor by one character, tracking line/column.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure
 *
 * @returns {char} The consumed character, or 0 if EOF
 */
define_function char NAVYamlLexerNext(_NAVYamlLexer lexer) {
    stack_var char ch

    if (NAVYamlLexerIsEOF(lexer)) {
        return 0
    }

    ch = lexer.source[lexer.cursor]
    lexer.cursor++
    lexer.column++

    // Track newlines
    switch (ch) {
        case NAV_LF: {
            lexer.line++
            lexer.column = 1
        }
        case NAV_CR: {
            lexer.line++
            lexer.column = 1

            // Handle CRLF
            if (!NAVYamlLexerIsEOF(lexer) && lexer.source[lexer.cursor] == NAV_LF) {
                lexer.cursor++
            }
        }
    }

    return ch
}


/**
 * @function NAVYamlLexerConsume
 * @private
 * @description Consume a specific string from the lexer source if it matches.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure
 * @param {char[]} value - The string to consume
 *
 * @returns {char} True (1) if the value was consumed successfully, False (0) if no match or EOF
 */
define_function char NAVYamlLexerConsume(_NAVYamlLexer lexer, char value[]) {
    stack_var integer length
    stack_var integer i

    length = length_array(value)

    if (!length) {
        return false
    }

    for (i = 1; i <= length; i++) {
        if (NAVYamlLexerIsEOF(lexer) ||
            lexer.source[lexer.cursor] != value[i]) {
            return false
        }

        NAVYamlLexerNext(lexer)
    }

    return true
}


/**
 * @function NAVYamlLexerIsWhitespaceChar
 * @private
 * @description Check if a character is a YAML whitespace character (space or tab).
 *
 * @param {char} value - The character to check
 *
 * @returns {char} True (1) if the character is whitespace, False (0) otherwise
 */
define_function char NAVYamlLexerIsWhitespaceChar(char value) {
    return value == ' ' || value == NAV_TAB
}


/**
 * @function NAVYamlLexerIsLineBreak
 * @private
 * @description Check if a character is a line break.
 *
 * @param {char} value - The character to check
 *
 * @returns {char} True (1) if line break, False (0) otherwise
 */
define_function char NAVYamlLexerIsLineBreak(char value) {
    return value == NAV_LF || value == NAV_CR
}


/**
 * @function NAVYamlLexerCanPeek
 * @private
 * @description Check if the lexer can peek at the next character.
 *
 * @param {_NAVYamlLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if peek is possible, False (0) if at or near end of source
 */
define_function char NAVYamlLexerCanPeek(_NAVYamlLexer lexer) {
    return lexer.cursor <= length_array(lexer.source)
}


/**
 * @function NAVYamlLexerPeek
 * @private
 * @description Peek at the current character in the source without consuming it.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure
 *
 * @returns {char} The current character, or 0 if unable to peek
 */
define_function char NAVYamlLexerPeek(_NAVYamlLexer lexer) {
    if (!NAVYamlLexerCanPeek(lexer)) {
        return 0
    }

    return lexer.source[lexer.cursor]
}


/**
 * @function NAVYamlLexerCanAddToken
 * @private
 * @description Check if the lexer can accept another token without exceeding the maximum limit.
 *
 * @param {_NAVYamlLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if token can be added, False (0) if limit reached
 */
define_function char NAVYamlLexerCanAddToken(_NAVYamlLexer lexer) {
    if (lexer.tokenCount >= NAV_YAML_LEXER_MAX_TOKENS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_YAML_LEXER__,
                                    'NAVYamlLexerCanAddToken',
                                    "'Exceeded maximum token limit (', itoa(NAV_YAML_LEXER_MAX_TOKENS), ')'")
        return false
    }

    return true
}


// =============================================================================
// YAML-SPECIFIC HELPER FUNCTIONS
// =============================================================================

/**
 * @function NAVYamlLexerPushIndent
 * @private
 * @description Push an indentation level onto the stack.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure
 * @param {integer} indent - Indentation level to push
 *
 * @returns {char} True (1) if pushed successfully, False (0) if stack full
 */
define_function char NAVYamlLexerPushIndent(_NAVYamlLexer lexer, integer indent) {
    if (lexer.indentStackSize >= NAV_YAML_LEXER_MAX_INDENT_LEVEL) {
        NAVYamlLexerSetError(lexer, 'Maximum indentation depth exceeded')
        return false
    }

    lexer.indentStackSize++
    lexer.indentStack[lexer.indentStackSize] = indent

    return true
}


/**
 * @function NAVYamlLexerPopIndent
 * @private
 * @description Pop an indentation level from the stack.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure
 *
 * @returns {integer} The popped indentation level, or 0 if stack empty
 */
define_function integer NAVYamlLexerPopIndent(_NAVYamlLexer lexer) {
    stack_var integer result

    if (lexer.indentStackSize <= 1) {
        return 0
    }

    result = lexer.indentStack[lexer.indentStackSize]
    lexer.indentStackSize--

    return result
}


/**
 * @function NAVYamlLexerGetCurrentIndent
 * @private
 * @description Get the current indentation level from the stack.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure
 *
 * @returns {integer} Current indentation level
 */
define_function integer NAVYamlLexerGetCurrentIndent(_NAVYamlLexer lexer) {
    if (lexer.indentStackSize <= 0) {
        return 0
    }

    return lexer.indentStack[lexer.indentStackSize]
}


/**
 * @function NAVYamlLexerMeasureIndent
 * @private
 * @description Measure indentation at current position (spaces only).
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure
 *
 * @returns {integer} Number of spaces at current position
 */
define_function integer NAVYamlLexerMeasureIndent(_NAVYamlLexer lexer) {
    stack_var integer count

    count = 0

    while (!NAVYamlLexerIsEOF(lexer) && lexer.source[lexer.cursor] == ' ') {
        count++
        lexer.cursor++
        lexer.column++
    }

    return count
}


/**
 * @function NAVYamlLexerConsumeString
 * @private
 * @description Consume a quoted YAML string (single or double quoted).
 *
 * @param {_NAVYamlLexer} lexer - The lexer instance
 * @param {char} quoteChar - Quote character (single or double quote)
 *
 * @returns {char} True (1) if string consumed successfully, False (0) if failed
 */
define_function char NAVYamlLexerConsumeString(_NAVYamlLexer lexer, char quoteChar) {
    // Consume opening quote
    NAVYamlLexerNext(lexer)

    while (!NAVYamlLexerIsEOF(lexer)) {
        stack_var char ch

        ch = lexer.source[lexer.cursor]

        select {
            active (ch == quoteChar): {
                // Check for escaped quote in single-quoted strings
                if (quoteChar == '''' && NAVYamlLexerCanPeek(lexer)) {
                    stack_var integer nextPos

                    nextPos = lexer.cursor + 1

                    if (nextPos <= length_array(lexer.source) && lexer.source[nextPos] == '''') {
                        // Escaped single quote: ''
                        NAVYamlLexerNext(lexer) // consume first '
                        NAVYamlLexerNext(lexer) // consume second '
                        continue
                    }
                }

                // Closing quote found
                NAVYamlLexerNext(lexer)
                return NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_STRING)
            }
            active (quoteChar == '"' && ch == '\'): {  // backslash
                // Escape sequence in double-quoted string
                NAVYamlLexerNext(lexer) // consume backslash

                if (NAVYamlLexerIsEOF(lexer)) {
                    NAVYamlLexerSetError(lexer, 'Unterminated string (EOF in escape sequence)')
                    return false
                }

                // Just consume the escaped character
                NAVYamlLexerNext(lexer)
            }
            active (true): {
                NAVYamlLexerNext(lexer)
            }
        }
    }

    NAVYamlLexerSetError(lexer, 'Unterminated string')
    return false
}


/**
 * @function NAVYamlLexerConsumePlainScalar
 * @private
 * @description Consume a plain (unquoted) scalar value.
 *
 * @param {_NAVYamlLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if consumed successfully, False (0) otherwise
 */
define_function char NAVYamlLexerConsumePlainScalar(_NAVYamlLexer lexer) {
    while (!NAVYamlLexerIsEOF(lexer)) {
        stack_var char ch

        ch = lexer.source[lexer.cursor]

        // Plain scalars end at line break or comment
        if (NAVYamlLexerIsLineBreak(ch) || ch == '#') {
            break
        }

        // Check for ': ' or ':\n' which indicates this might be a key
        if (ch == ':') {
            stack_var integer nextPos
            stack_var char nextCh

            nextPos = lexer.cursor + 1
            if (nextPos <= length_array(lexer.source)) {
                nextCh = lexer.source[nextPos]
                if (NAVYamlLexerIsWhitespaceChar(nextCh) || NAVYamlLexerIsLineBreak(nextCh)) {
                    break
                }
            }
            else {
                break
            }
        }

        // In flow context, stop at flow indicators
        if (ch == ',' || ch == ']' || ch == '}') {
            break
        }

        NAVYamlLexerNext(lexer)
    }

    return NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR)
}


/**
 * @function NAVYamlLexerConsumeBlockScalarIndicators
 * @private
 * @description Parse optional block scalar indicators after | or >.
 *
 * Block scalar indicators can be:
 * - Chomping: '+' (keep), '-' (strip), or implicit '|' (clip)
 * - Indentation: digit 1-9 for explicit indent level
 * - Combined: order can be either chomping+indent or indent+chomping
 *
 * Examples: |, |+, |-, |2, |2+, |+2, >3-, >-3
 *
 * The indicators are stored in lexer.source from start to cursor for
 * the token emission. Token value will contain the indicators (e.g., "2+", "-", "")
 *
 * @param {_NAVYamlLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if valid, False (0) for invalid indicators
 */
define_function char NAVYamlLexerConsumeBlockScalarIndicators(_NAVYamlLexer lexer) {
    stack_var char ch
    stack_var char hasIndent
    stack_var char hasChomping

    hasIndent = false
    hasChomping = false

    // Check for indicators (in any order: chomping+indent or indent+chomping)
    while (!NAVYamlLexerIsEOF(lexer)) {
        ch = lexer.source[lexer.cursor]

        // Chomping indicators: + (keep) or - (strip)
        if ((ch == '+' || ch == '-') && !hasChomping) {
            hasChomping = true
            NAVYamlLexerNext(lexer)
            continue
        }

        // Indentation indicator: digit 1-9
        if (ch >= '1' && ch <= '9' && !hasIndent) {
            hasIndent = true
            NAVYamlLexerNext(lexer)
            continue
        }

        // Stop at anything else (whitespace, newline, comment)
        break
    }

    return true
}


/**
 * @function NAVYamlLexerConsumeAnchorName
 * @private
 * @description Consume an anchor or alias name (identifier only).
 *
 * Anchor and alias names are restricted to identifier characters:
 * letters, digits, underscore, and hyphen. Stops at whitespace or special chars.
 *
 * @param {_NAVYamlLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if consumed successfully, False (0) otherwise
 */
define_function char NAVYamlLexerConsumeAnchorName(_NAVYamlLexer lexer) {
    while (!NAVYamlLexerIsEOF(lexer)) {
        stack_var char ch

        ch = lexer.source[lexer.cursor]

        // Anchor names: alphanumeric, underscore, hyphen only
        if (NAVIsAlphaNumeric(ch) ||
            ch == '_' || ch == '-') {
            NAVYamlLexerNext(lexer)
        }
        else {
            // Stop at any other character (whitespace, special chars, etc.)
            break
        }
    }

    return NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR)
}


/**
 * @function NAVYamlLexerConsumeTagName
 * @private
 * @description Consume a tag name (after ! or !!).
 *
 * Tag names can contain alphanumeric characters, hyphens, and certain
 * URI-safe characters. Stops at whitespace or special YAML indicators.
 *
 * @param {_NAVYamlLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if consumed successfully, False (0) otherwise
 */
define_function char NAVYamlLexerConsumeTagName(_NAVYamlLexer lexer) {
    while (!NAVYamlLexerIsEOF(lexer)) {
        stack_var char ch

        ch = lexer.source[lexer.cursor]

        // Tag names: alphanumeric, underscore, hyphen, colon, slash
        // Allow URI-safe characters for tag names
        if (NAVIsAlphaNumeric(ch) ||
            ch == '_' || ch == '-' || ch == ':' || ch == '/' || ch == '.') {
            NAVYamlLexerNext(lexer)
        }
        else {
            // Stop at whitespace, newlines, or other special characters
            break
        }
    }

    return NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_TAG)
}


/**
 * @function NAVYamlLexerConsumeVerbatimTag
 * @private
 * @description Consume a verbatim tag (!<...>).
 *
 * Verbatim tags are enclosed in angle brackets and can contain any URI characters.
 *
 * @param {_NAVYamlLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if consumed successfully, False (0) otherwise
 */
define_function char NAVYamlLexerConsumeVerbatimTag(_NAVYamlLexer lexer) {
    // Skip the opening '<'
    NAVYamlLexerNext(lexer)

    while (!NAVYamlLexerIsEOF(lexer)) {
        stack_var char ch

        ch = lexer.source[lexer.cursor]

        select {
            active (ch == '>'): {
                // Found closing >, consume it and emit
                NAVYamlLexerNext(lexer)
                return NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_TAG)
            }
            active (NAVYamlLexerIsLineBreak(ch)): {
                // Verbatim tags cannot span lines
                NAVYamlLexerSetError(lexer, 'Unterminated verbatim tag (line break before >)')
                return false
            }
            active (true): {
                // Consume any character (tags can contain most URI characters)
                NAVYamlLexerNext(lexer)
            }
        }
    }

    NAVYamlLexerSetError(lexer, 'Unterminated verbatim tag (EOF before >)')
    return false
}


/**
 * @function NAVYamlLexerSkipComment
 * @private
 * @description Skip a comment (from # to end of line).
 *
 * @param {_NAVYamlLexer} lexer - The lexer instance
 *
 * @returns {void}
 */
define_function NAVYamlLexerSkipComment(_NAVYamlLexer lexer) {
    // Skip the #
    if (!NAVYamlLexerIsEOF(lexer) && lexer.source[lexer.cursor] == '#') {
        NAVYamlLexerNext(lexer)
    }

    // Skip to end of line
    while (!NAVYamlLexerIsEOF(lexer) && !NAVYamlLexerIsLineBreak(lexer.source[lexer.cursor])) {
        NAVYamlLexerNext(lexer)
    }

    NAVYamlLexerIgnore(lexer)
}


/**
 * @function NAVYamlLexerConsumeDirective
 * @private
 * @description Consume a YAML directive line (starts with %).
 *              Directives like %YAML 1.2 or %TAG ! tag:yaml.org,2002:
 *
 * @param {_NAVYamlLexer} lexer - The lexer instance
 *
 * @returns {char} True (1) if consumed successfully, False (0) if error
 */
define_function char NAVYamlLexerConsumeDirective(_NAVYamlLexer lexer) {
    // Skip the %
    if (!NAVYamlLexerIsEOF(lexer) && lexer.source[lexer.cursor] == '%') {
        NAVYamlLexerNext(lexer)
    }

    // Consume directive content to end of line
    while (!NAVYamlLexerIsEOF(lexer) && !NAVYamlLexerIsLineBreak(lexer.source[lexer.cursor])) {
        NAVYamlLexerNext(lexer)
    }

    // Emit the directive token (without the %)
    return NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_DIRECTIVE)
}


/**
 * @function NAVYamlLexerHandleIndentation
 * @private
 * @description Handle indentation changes and emit INDENT/DEDENT tokens.
 *
 * @param {_NAVYamlLexer} lexer - The lexer instance
 * @param {integer} newIndent - The new indentation level
 *
 * @returns {char} True (1) if handled successfully, False (0) if error
 */
define_function char NAVYamlLexerHandleIndentation(_NAVYamlLexer lexer, integer newIndent) {
    stack_var integer currentIndent
    stack_var integer indentIncrement
    stack_var integer expectedIncrement

    currentIndent = NAVYamlLexerGetCurrentIndent(lexer)

    if (newIndent > currentIndent) {
        // Increased indentation
        indentIncrement = newIndent - currentIndent

        #IF_DEFINED YAML_LEXER_DEBUG
        NAVLog("'[ HandleIndentation ]: newIndent=', itoa(newIndent), ' currentIndent=', itoa(currentIndent), ' increment=', itoa(indentIncrement), ' stackSize=', itoa(lexer.indentStackSize)")
        #END_IF

        // Validate that indentation increment is even (helps catch tab/space mixing)
        if ((indentIncrement % 2) != 0) {
            NAVYamlLexerSetError(lexer, "'Invalid indentation: increment must be an even number of spaces (got ', itoa(indentIncrement), ')'")
            return false
        }

        // Validate consistent indentation: check if this increment matches existing pattern
        // If we have multiple indent levels, check that the increment is consistent
        if (lexer.indentStackSize > 1) {
            // Calculate the expected increment from previous levels
            expectedIncrement = lexer.indentStack[2] - lexer.indentStack[1]

            #IF_DEFINED YAML_LEXER_DEBUG
            NAVLog("'[ HandleIndentation ]: Validating indent: expected=', itoa(expectedIncrement), ' got=', itoa(indentIncrement)")
            #END_IF

            if (indentIncrement != expectedIncrement) {
                NAVYamlLexerSetError(lexer, "'Inconsistent indentation: expected increment of ', itoa(expectedIncrement), ' spaces, but got ', itoa(indentIncrement)")
                return false
            }
        }

        if (!NAVYamlLexerPushIndent(lexer, newIndent)) {
            return false
        }

        return NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_INDENT)
    }
    else if (newIndent < currentIndent) {
        // Decreased indentation - may need multiple DEDENTs
        while (NAVYamlLexerGetCurrentIndent(lexer) > newIndent) {
            NAVYamlLexerPopIndent(lexer)

            if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_DEDENT)) {
                return false
            }
        }

        // Check for improper dedent
        if (NAVYamlLexerGetCurrentIndent(lexer) != newIndent) {
            NAVYamlLexerSetError(lexer, 'Invalid indentation: does not match any previous indentation level')
            return false
        }

        // Exit block scalar mode if we dedented to or below the block scalar's starting indent
        if (lexer.inBlockScalar && newIndent <= lexer.blockScalarIndent) {
            lexer.inBlockScalar = false
            lexer.blockScalarIndent = 0
        }
    }

    return true
}


/**
 * @function NAVYamlLexerTokenize
 * @public
 * @description Tokenize the source YAML text into an array of tokens.
 *
 * @param {_NAVYamlLexer} lexer - The lexer instance
 * @param {char[]} source - The source text to tokenize
 *
 * @returns {char} True (1) if tokenization succeeded, False (0) if failed
 */
define_function char NAVYamlLexerTokenize(_NAVYamlLexer lexer, char source[]) {
    stack_var char atLineStart
    stack_var integer flowDepth

    NAVYamlLexerInit(lexer, source)

    if (!length_array(lexer.source)) {
        // Empty source, emit EOF token
        if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_EOF)) {
            return false
        }

        #IF_DEFINED YAML_LEXER_DEBUG
        NAVLog("'[ YamlLexerTokenize ]: Tokenization complete. Total tokens: ', itoa(lexer.tokenCount)")
        #END_IF

        return true
    }

    atLineStart = true

    while (!NAVYamlLexerIsEOF(lexer)) {
        stack_var char ch
        stack_var integer indent

        if (!NAVYamlLexerCanAddToken(lexer)) {
            return false
        }

        ch = lexer.source[lexer.cursor]

        #IF_DEFINED YAML_LEXER_DEBUG
        NAVLog("'[ YamlLexerTokenize ]: cursor=', itoa(lexer.cursor), ' char=', ch, ' (', itoa(type_cast(ch)), ')'")
        #END_IF

        // Handle indentation at start of line (only in block context)
        if (atLineStart && flowDepth == 0) {
            ch = lexer.source[lexer.cursor]

            // In block scalar mode, check for blank lines BEFORE indentation handling
            // This prevents blank lines (indent=0) from causing premature exit from block scalar mode
            if (lexer.inBlockScalar && NAVYamlLexerIsLineBreak(ch)) {
                NAVYamlLexerNext(lexer)

                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_NEWLINE)) {
                    return false
                }

                atLineStart = true
                continue
            }

            indent = NAVYamlLexerMeasureIndent(lexer)
            lexer.start = lexer.cursor

            // Handle indentation changes
            if (!NAVYamlLexerHandleIndentation(lexer, indent)) {
                return false
            }

            atLineStart = false

            // Skip if we're at end, blank line or comment
            if (NAVYamlLexerIsEOF(lexer)) {
                break
            }

            ch = lexer.source[lexer.cursor]

            if (NAVYamlLexerIsLineBreak(ch)) {
                // Outside block scalars, skip blank lines
                NAVYamlLexerNext(lexer)
                NAVYamlLexerIgnore(lexer)
                atLineStart = true
                continue
            }

            if (ch == '#') {
                NAVYamlLexerSkipComment(lexer)
                atLineStart = true
                continue
            }
        }

        // Skip whitespace (except at line start where it's significant)
        if (!atLineStart && NAVYamlLexerIsWhitespaceChar(ch)) {
            NAVYamlLexerNext(lexer)
            NAVYamlLexerIgnore(lexer)
            continue
        }

        // Handle line breaks
        if (NAVYamlLexerIsLineBreak(ch)) {
            NAVYamlLexerNext(lexer)

            if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_NEWLINE)) {
                return false
            }

            atLineStart = true
            continue
        }

        // Handle comments
        if (ch == '#') {
            NAVYamlLexerSkipComment(lexer)
            continue
        }

        // Handle directives (must start at column 1)
        if (ch == '%' && lexer.column == 1) {
            if (!NAVYamlLexerConsumeDirective(lexer)) {
                return false
            }

            continue
        }

        // Handle specific characters
        switch (ch) {
            case '-': {
                // Could be: document start (---), sequence item (-), or part of plain scalar
                if (NAVYamlLexerCanPeek(lexer)) {
                    stack_var integer pos2
                    stack_var integer pos3

                    pos2 = lexer.cursor + 1
                    pos3 = lexer.cursor + 2

                    // Check for document marker ---
                    if (pos2 <= length_array(lexer.source) &&
                        pos3 <= length_array(lexer.source) &&
                        lexer.source[pos2] == '-' &&
                        lexer.source[pos3] == '-') {

                        NAVYamlLexerNext(lexer)
                        NAVYamlLexerNext(lexer)
                        NAVYamlLexerNext(lexer)

                        if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_DOCUMENT_START)) {
                            return false
                        }

                        continue
                    }

                    // Check for sequence item (- followed by space)
                    if (pos2 <= length_array(lexer.source)) {
                        stack_var char nextCh

                        nextCh = lexer.source[pos2]

                        if (NAVYamlLexerIsWhitespaceChar(nextCh) || NAVYamlLexerIsLineBreak(nextCh) || pos2 > length_array(lexer.source)) {
                            NAVYamlLexerNext(lexer)

                            if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_DASH)) {
                                return false
                            }

                            continue
                        }
                    }
                }

                // Otherwise part of plain scalar
                if (!NAVYamlLexerConsumePlainScalar(lexer)) {
                    return false
                }
            }

            case '.': {
                // Could be: document end (...) or part of number
                if (NAVYamlLexerCanPeek(lexer)) {
                    stack_var integer pos2
                    stack_var integer pos3

                    pos2 = lexer.cursor + 1
                    pos3 = lexer.cursor + 2

                    // Check for document end marker ...
                    if (pos2 <= length_array(lexer.source) &&
                        pos3 <= length_array(lexer.source) &&
                        lexer.source[pos2] == '.' &&
                        lexer.source[pos3] == '.') {

                        NAVYamlLexerNext(lexer)
                        NAVYamlLexerNext(lexer)
                        NAVYamlLexerNext(lexer)

                        if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_DOCUMENT_END)) {
                            return false
                        }

                        continue
                    }
                }

                // Otherwise part of plain scalar
                if (!NAVYamlLexerConsumePlainScalar(lexer)) {
                    return false
                }
            }

            case ':': {
                NAVYamlLexerNext(lexer)
                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_COLON)) {
                    return false
                }
            }

            case ',': {
                NAVYamlLexerNext(lexer)
                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_COMMA)) {
                    return false
                }
            }

            case '[': {
                NAVYamlLexerNext(lexer)
                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_LEFT_BRACKET)) {
                    return false
                }

                flowDepth++
            }

            case ']': {
                NAVYamlLexerNext(lexer)
                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET)) {
                    return false
                }

                if (flowDepth > 0) {
                    flowDepth--
                }
            }

            case '{': {
                NAVYamlLexerNext(lexer)
                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_LEFT_BRACE)) {
                    return false
                }

                flowDepth++
            }

            case '}': {
                NAVYamlLexerNext(lexer)
                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_RIGHT_BRACE)) {
                    return false
                }

                if (flowDepth > 0) {
                    flowDepth--
                }
            }

            case '''': {
                // Single-quoted string
                if (!NAVYamlLexerConsumeString(lexer, '''')) {
                    return false
                }
            }

            case '"': {
                // Double-quoted string
                if (!NAVYamlLexerConsumeString(lexer, '"')) {
                    return false
                }
            }

            case '!': {
                // Type tag (!tag, !!tag, or !<verbatim>)
                NAVYamlLexerNext(lexer) // consume first '!'

                if (NAVYamlLexerCanPeek(lexer)) {
                    stack_var char nextCh

                    nextCh = lexer.source[lexer.cursor]

                    // Check for !! (named tag)
                    switch (nextCh) {
                        case '!': {
                            NAVYamlLexerNext(lexer) // consume second '!'

                            // Emit TAG token with value '!!'
                            if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_TAG)) {
                                return false
                            }

                            // Consume the tag name (e.g., str, int, map)
                            if (!NAVYamlLexerConsumeTagName(lexer)) {
                                return false
                            }
                        }
                        // Check for !< (verbatim tag)
                        case '<': {
                            // Emit TAG token with value '!<'
                            if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_TAG)) {
                                return false
                            }

                            // Consume verbatim tag content up to '>'
                            if (!NAVYamlLexerConsumeVerbatimTag(lexer)) {
                                return false
                            }
                        }
                        // Local tag (e.g., !mytag)
                        default: {
                            // Emit TAG token with value '!'
                            if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_TAG)) {
                                return false
                            }

                            // Consume the local tag name
                            if (!NAVYamlLexerConsumeTagName(lexer)) {
                                return false
                            }
                        }
                    }
                }
                else {
                    // Just '!' at EOF
                    if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_TAG)) {
                        return false
                    }
                }
            }

            case '&': {
                // Anchor definition (&anchor)
                NAVYamlLexerNext(lexer)
                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_ANCHOR)) {
                    return false
                }

                // Immediately consume the anchor name (identifier only)
                if (!NAVYamlLexerConsumeAnchorName(lexer)) {
                    return false
                }
            }

            case '*': {
                // Alias reference (*anchor)
                NAVYamlLexerNext(lexer)
                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_ALIAS)) {
                    return false
                }

                // Immediately consume the alias name (identifier only)
                if (!NAVYamlLexerConsumeAnchorName(lexer)) {
                    return false
                }
            }

            case '|': {
                // Literal block scalar (preserves newlines)
                NAVYamlLexerNext(lexer)

                // Parse optional chomping indicator (+/-) and/or indentation digit
                if (!NAVYamlLexerConsumeBlockScalarIndicators(lexer)) {
                    return false
                }

                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_LITERAL)) {
                    return false
                }

                // Enter block scalar mode
                lexer.inBlockScalar = true
                lexer.blockScalarIndent = indent
            }

            case '>': {
                // Folded block scalar (folds newlines to spaces)
                NAVYamlLexerNext(lexer)

                // Parse optional chomping indicator (+/-) and/or indentation digit
                if (!NAVYamlLexerConsumeBlockScalarIndicators(lexer)) {
                    return false
                }

                if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_FOLDED)) {
                    return false
                }

                // Enter block scalar mode
                lexer.inBlockScalar = true
                lexer.blockScalarIndent = indent
            }

            case '?': {
                // Explicit key marker (? followed by space/newline)
                // Must be followed by whitespace to distinguish from plain scalar
                if (NAVYamlLexerCanPeek(lexer)) {
                    stack_var char nextCh

                    nextCh = lexer.source[lexer.cursor + 1]

                    if (NAVYamlLexerIsWhitespaceChar(nextCh) || NAVYamlLexerIsLineBreak(nextCh) ||
                        (lexer.cursor + 1) > length_array(lexer.source)) {
                        // This is an explicit key marker
                        NAVYamlLexerNext(lexer)

                        if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_KEY)) {
                            return false
                        }

                        continue
                    }
                }

                // Otherwise, part of plain scalar
                if (!NAVYamlLexerConsumePlainScalar(lexer)) {
                    return false
                }
            }

            default: {
                // Plain scalar (unquoted value or key)
                if (!NAVYamlLexerConsumePlainScalar(lexer)) {
                    return false
                }
            }
        }
    }

    // Emit remaining DEDENTs to return to base level
    while (NAVYamlLexerGetCurrentIndent(lexer) > 0) {
        NAVYamlLexerPopIndent(lexer)
        if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_DEDENT)) {
            return false
        }
    }

    // Exit block scalar mode at end of document
    if (lexer.inBlockScalar) {
        lexer.inBlockScalar = false
        lexer.blockScalarIndent = 0
    }

    // Emit EOF token
    if (!NAVYamlLexerEmitToken(lexer, NAV_YAML_TOKEN_TYPE_EOF)) {
        return false
    }

    #IF_DEFINED YAML_LEXER_DEBUG
    NAVLog("'[ YamlLexerTokenize ]: Tokenization complete. Total tokens: ', itoa(lexer.tokenCount)")
    NAVYamlLexerPrintTokens(lexer)
    #END_IF

    return true
}


// =============================================================================
// LEXER UTILITY FUNCTIONS
// =============================================================================

/**
 * @function NAVYamlLexerGetTokenType
 * @public
 * @description Get the string representation of a token type.
 *
 * @param {integer} type - The token type constant
 *
 * @returns {char[NAV_MAX_CHARS]} String representation of the token type
 */
define_function char[NAV_MAX_CHARS] NAVYamlLexerGetTokenType(integer type) {
    switch (type) {
        case NAV_YAML_TOKEN_TYPE_DOCUMENT_START:    { return 'DOCUMENT_START' }    // ---
        case NAV_YAML_TOKEN_TYPE_DOCUMENT_END:      { return 'DOCUMENT_END' }      // ...
        case NAV_YAML_TOKEN_TYPE_KEY:               { return 'KEY' }               // Mapping key
        case NAV_YAML_TOKEN_TYPE_VALUE:             { return 'VALUE' }             // Scalar value
        case NAV_YAML_TOKEN_TYPE_COLON:             { return 'COLON' }             // :
        case NAV_YAML_TOKEN_TYPE_DASH:              { return 'DASH' }              // -
        case NAV_YAML_TOKEN_TYPE_COMMA:             { return 'COMMA' }             // ,
        case NAV_YAML_TOKEN_TYPE_LEFT_BRACKET:      { return 'LEFT_BRACKET' }      // [
        case NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET:     { return 'RIGHT_BRACKET' }     // ]
        case NAV_YAML_TOKEN_TYPE_LEFT_BRACE:        { return 'LEFT_BRACE' }        // {
        case NAV_YAML_TOKEN_TYPE_RIGHT_BRACE:       { return 'RIGHT_BRACE' }       // }
        case NAV_YAML_TOKEN_TYPE_STRING:            { return 'STRING' }            // "string"
        case NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR:      { return 'PLAIN_SCALAR' }      // unquoted
        case NAV_YAML_TOKEN_TYPE_LITERAL:           { return 'LITERAL' }           // | block
        case NAV_YAML_TOKEN_TYPE_FOLDED:            { return 'FOLDED' }            // > block
        case NAV_YAML_TOKEN_TYPE_ANCHOR:            { return 'ANCHOR' }            // &anchor
        case NAV_YAML_TOKEN_TYPE_ALIAS:             { return 'ALIAS' }             // *anchor
        case NAV_YAML_TOKEN_TYPE_TAG:               { return 'TAG' }               // !!type
        case NAV_YAML_TOKEN_TYPE_TRUE:              { return 'TRUE' }              // true
        case NAV_YAML_TOKEN_TYPE_FALSE:             { return 'FALSE' }             // false
        case NAV_YAML_TOKEN_TYPE_NULL:              { return 'NULL' }              // null
        case NAV_YAML_TOKEN_TYPE_NEWLINE:           { return 'NEWLINE' }           // \n
        case NAV_YAML_TOKEN_TYPE_INDENT:            { return 'INDENT' }            // Indentation
        case NAV_YAML_TOKEN_TYPE_DEDENT:            { return 'DEDENT' }            // Dedentation
        case NAV_YAML_TOKEN_TYPE_COMMENT:           { return 'COMMENT' }           // # comment
        case NAV_YAML_TOKEN_TYPE_DIRECTIVE:         { return 'DIRECTIVE' }         // %YAML or %TAG
        case NAV_YAML_TOKEN_TYPE_EOF:               { return 'EOF' }               // End of input
        default:                                    { return 'UNKNOWN' }
    }
}


/**
 * @function NAVYamlLexerPrintTokens
 * @public
 * @description Print all tokens in the lexer for debugging purposes.
 *
 * @param {_NAVYamlLexer} lexer - The lexer structure containing tokens
 *
 * @returns {void}
 */
define_function NAVYamlLexerPrintTokens(_NAVYamlLexer lexer) {
    stack_var integer i
    stack_var char message[NAV_MAX_CHARS]

    if (lexer.tokenCount <= 0) {
        NAVLog('[]')
        return
    }

    NAVLog('YAML Lexer Tokens:')

    for (i = 1; i <= lexer.tokenCount; i++) {
        message = "'  [', itoa(i), '] ', NAVYamlLexerGetTokenType(lexer.tokens[i].type)"
        message = "message, ' @ L', itoa(lexer.tokens[i].line), ':C', itoa(lexer.tokens[i].column)"

        if (lexer.tokens[i].type != NAV_YAML_TOKEN_TYPE_EOF &&
            lexer.tokens[i].type != NAV_YAML_TOKEN_TYPE_NEWLINE &&
            lexer.tokens[i].type != NAV_YAML_TOKEN_TYPE_INDENT &&
            lexer.tokens[i].type != NAV_YAML_TOKEN_TYPE_DEDENT) {
            message = "message, ' = "', lexer.tokens[i].value, '"'"
        }

        NAVLog(message)
    }
}


#END_IF // __NAV_FOUNDATION_YAML_LEXER__
