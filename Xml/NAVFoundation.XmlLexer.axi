PROGRAM_NAME='NAVFoundation.XmlLexer'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_XML_LEXER__
#DEFINE __NAV_FOUNDATION_XML_LEXER__ 'NAVFoundation.XmlLexer'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.XmlLexer.h.axi'


// =============================================================================
// LEXER CORE FUNCTIONS
// =============================================================================

/**
 * @function NAVXmlLexerInit
 * @private
 * @description Initialize an XML lexer with source text.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure to initialize
 * @param {char[]} source - The source XML text to tokenize
 *
 * @returns {void}
 */
define_function NAVXmlLexerInit(_NAVXmlLexer lexer, char source[]) {
    lexer.source = source
    lexer.cursor = 1
    lexer.start = 1
    lexer.line = 1
    lexer.column = 1
    lexer.tokenCount = 0
    lexer.hasError = false
    lexer.error = ''
    lexer.inTag = false  // Start in content mode
}


/**
 * @function NAVXmlLexerSetError
 * @private
 * @description Set an error state on the lexer.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 * @param {char[]} message - Error message
 *
 * @returns {void}
 */
define_function NAVXmlLexerSetError(_NAVXmlLexer lexer, char message[]) {
    lexer.hasError = true
    lexer.error = message

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                __NAV_FOUNDATION_XML_LEXER__,
                                'NAVXmlLexer',
                                "message, ' at line ', itoa(lexer.line), ', column ', itoa(lexer.column)")
}


/**
 * @function NAVXmlLexerCanAddToken
 * @private
 * @description Check if the lexer can add more tokens.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if token can be added, False (0) if limit reached
 */
define_function char NAVXmlLexerCanAddToken(_NAVXmlLexer lexer) {
    if (lexer.tokenCount >= NAV_XML_LEXER_MAX_TOKENS) {
        NAVXmlLexerSetError(lexer, "'Token limit reached (', itoa(NAV_XML_LEXER_MAX_TOKENS), ')'")
        return false
    }

    return true
}


/**
 * @function NAVXmlLexerEmitToken
 * @private
 * @description Emit a token of the specified type with the current lexer position.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 * @param {integer} type - The token type to emit
 *
 * @returns {char} True (1) if token emitted successfully, False (0) if token limit reached
 */
define_function char NAVXmlLexerEmitToken(_NAVXmlLexer lexer, integer type) {
    if (!NAVXmlLexerCanAddToken(lexer)) {
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = type
    lexer.tokens[lexer.tokenCount].value = NAVStringSlice(lexer.source, lexer.start, lexer.cursor)
    lexer.tokens[lexer.tokenCount].start = lexer.start
    lexer.tokens[lexer.tokenCount].end = lexer.cursor - 1
    lexer.tokens[lexer.tokenCount].line = lexer.line
    lexer.tokens[lexer.tokenCount].column = lexer.column - (lexer.cursor - lexer.start)
    set_length_array(lexer.tokens, lexer.tokenCount)

    lexer.start = lexer.cursor

    return true
}


/**
 * @function NAVXmlLexerEmitTokenWithValue
 * @private
 * @description Emit a token with a custom value (used for entity expansion).
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 * @param {integer} type - The token type to emit
 * @param {char[]} value - The custom token value
 *
 * @returns {char} True (1) if token emitted successfully, False (0) if token limit reached
 */
define_function char NAVXmlLexerEmitTokenWithValue(_NAVXmlLexer lexer, integer type, char value[]) {
    if (!NAVXmlLexerCanAddToken(lexer)) {
        return false
    }

    lexer.tokenCount++
    lexer.tokens[lexer.tokenCount].type = type
    lexer.tokens[lexer.tokenCount].value = value
    lexer.tokens[lexer.tokenCount].start = lexer.start
    lexer.tokens[lexer.tokenCount].end = lexer.cursor - 1
    lexer.tokens[lexer.tokenCount].line = lexer.line
    lexer.tokens[lexer.tokenCount].column = lexer.column - (lexer.cursor - lexer.start)
    set_length_array(lexer.tokens, lexer.tokenCount)

    lexer.start = lexer.cursor

    return true
}


/**
 * @function NAVXmlLexerIgnore
 * @private
 * @description Ignore the current token by advancing the start position to the cursor.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {void}
 */
define_function NAVXmlLexerIgnore(_NAVXmlLexer lexer) {
    lexer.start = lexer.cursor
}


/**
 * @function NAVXmlLexerIsEOF
 * @private
 * @description Check if the lexer has reached the end of the source text.
 *
 * @param {_NAVXmlLexer} lexer - The lexer to check
 *
 * @returns {char} True (1) if at end of file, False (0) otherwise
 */
define_function char NAVXmlLexerIsEOF(_NAVXmlLexer lexer) {
    return lexer.cursor > length_array(lexer.source)
}


/**
 * @function NAVXmlLexerPeek
 * @private
 * @description Peek at the current character without advancing.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {char} The current character, or 0 if EOF
 */
define_function char NAVXmlLexerPeek(_NAVXmlLexer lexer) {
    if (NAVXmlLexerIsEOF(lexer)) {
        return 0
    }

    return lexer.source[lexer.cursor]
}


/**
 * @function NAVXmlLexerNext
 * @private
 * @description Advance the cursor by one character, tracking line/column.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {char} The consumed character, or 0 if EOF
 */
define_function char NAVXmlLexerNext(_NAVXmlLexer lexer) {
    stack_var char ch

    if (NAVXmlLexerIsEOF(lexer)) {
        return 0
    }

    ch = lexer.source[lexer.cursor]
    lexer.cursor++
    lexer.column++

    // Track newlines
    if (ch == NAV_LF || ch == NAV_CR) {
        lexer.line++
        lexer.column = 1

        // Handle CRLF
        if (ch == NAV_CR && !NAVXmlLexerIsEOF(lexer) && lexer.source[lexer.cursor] == NAV_LF) {
            lexer.cursor++
        }
    }

    return ch
}


/**
 * @function NAVXmlLexerMatch
 * @private
 * @description Check if the next character matches the expected character.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 * @param {char} expected - The expected character
 *
 * @returns {char} True (1) if matched, False (0) otherwise
 */
define_function char NAVXmlLexerMatch(_NAVXmlLexer lexer, char expected) {
    if (NAVXmlLexerIsEOF(lexer)) {
        return false
    }

    if (lexer.source[lexer.cursor] != expected) {
        return false
    }

    NAVXmlLexerNext(lexer)
    return true
}


/**
 * @function NAVXmlLexerMatchString
 * @private
 * @description Check if the upcoming text matches a specific string.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 * @param {char[]} str - The string to match
 *
 * @returns {char} True (1) if matched, False (0) otherwise
 */
define_function char NAVXmlLexerMatchString(_NAVXmlLexer lexer, char str[]) {
    stack_var integer i
    stack_var integer length
    stack_var long pos

    length = length_array(str)
    pos = lexer.cursor

    for (i = 1; i <= length; i++) {
        if (pos > length_array(lexer.source)) {
            return false
        }

        if (lexer.source[pos] != str[i]) {
            return false
        }

        pos++
    }

    return true
}


/**
 * @function NAVXmlLexerConsumeString
 * @private
 * @description Consume a specific string if it matches at the current position.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 * @param {char[]} str - The string to consume
 *
 * @returns {char} True (1) if consumed, False (0) if no match
 */
define_function char NAVXmlLexerConsumeString(_NAVXmlLexer lexer, char str[]) {
    stack_var integer i
    stack_var integer length

    if (!NAVXmlLexerMatchString(lexer, str)) {
        return false
    }

    length = length_array(str)
    for (i = 1; i <= length; i++) {
        NAVXmlLexerNext(lexer)
    }

    return true
}


// =============================================================================
// XML-SPECIFIC CHARACTER CHECKS
// =============================================================================

/**
 * @function NAVXmlIsNameStartChar
 * @private
 * @description Check if a character is valid as the first character of an XML name.
 *
 * Per XML spec: NameStartChar ::= ":" | [A-Z] | "_" | [a-z]
 * (Simplified - full spec includes Unicode ranges)
 *
 * @param {char} ch - The character to check
 *
 * @returns {char} True (1) if valid name start character, False (0) otherwise
 */
define_function char NAVXmlIsNameStartChar(char ch) {
    return (NAVIsAlpha(ch) || ch == '_' || ch == ':')
}


/**
 * @function NAVXmlIsNameChar
 * @private
 * @description Check if a character is valid within an XML name.
 *
 * Per XML spec: NameChar ::= NameStartChar | "-" | "." | [0-9]
 * (Simplified - full spec includes Unicode ranges)
 *
 * @param {char} ch - The character to check
 *
 * @returns {char} True (1) if valid name character, False (0) otherwise
 */
define_function char NAVXmlIsNameChar(char ch) {
    return (NAVIsAlphaNumeric(ch) || ch == '_' || ch == ':' || ch == '-' || ch == '.')
}


// =============================================================================
// ENTITY HANDLING
// =============================================================================

/**
 * @function NAVXmlExpandEntity
 * @private
 * @description Expand a named entity reference to its character value.
 *
 * Supports the five predefined XML entities:
 * &lt; &gt; &amp; &quot; &apos;
 *
 * @param {char[]} entity - The entity reference (including & and ;)
 * @param {integer} result - Output character code
 *
 * @returns {char} True (1) if entity was expanded, False (0) if unknown entity
 */
define_function char NAVXmlExpandEntity(char entity[], integer result) {
    select {
        active (entity == '&lt;'): {
            result = '<'
            return true
        }
        active (entity == '&gt;'): {
            result = '>'
            return true
        }
        active (entity == '&amp;'): {
            result = '&'
            return true
        }
        active (entity == '&quot;'): {
            result = '"'
            return true
        }
        active (entity == '&apos;'): {
            result = ''''
            return true
        }
    }

    return false
}


/**
 * @function NAVXmlExpandCharRef
 * @private
 * @description Expand a numeric character reference to its character value.
 *
 * Supports decimal (&#65;) and hexadecimal (&#x41;) character references.
 *
 * @param {char[]} charRef - The character reference (including &# and ;)
 * @param {integer} result - Output character code
 *
 * @returns {char} True (1) if expanded, False (0) if invalid
 */
define_function char NAVXmlExpandCharRef(char charRef[], integer result) {
    stack_var char numStr[20]
    stack_var integer value
    stack_var integer i

    // Skip &#
    i = 3

    // Check for hex (&#x...)
    if (charRef[i] == 'x' || charRef[i] == 'X') {
        i++

        // Extract hex digits
        while (i < length_array(charRef) && charRef[i] != ';') {
            numStr = "numStr, charRef[i]"
            i++
        }

        value = hextoi(numStr)
    } else {
        // Extract decimal digits
        while (i < length_array(charRef) && charRef[i] != ';') {
            if (!NAVIsDigit(charRef[i])) {
                return false
            }

            numStr = "numStr, charRef[i]"
            i++
        }

        value = atoi(numStr)
    }

    // Validate value range (basic ASCII only for simplicity)
    if (value < 1 || value > 255) {
        return false
    }

    result = value
    return true
}


// =============================================================================
// TOKENIZATION FUNCTIONS
// =============================================================================

/**
 * @function NAVXmlLexerScanName
 * @private
 * @description Scan an XML name (element/attribute name).
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if name scanned, False (0) on error
 */
define_function char NAVXmlLexerScanName(_NAVXmlLexer lexer) {
    stack_var char ch

    ch = NAVXmlLexerPeek(lexer)

    // Name must start with NameStartChar
    if (!NAVXmlIsNameStartChar(ch)) {
        NAVXmlLexerSetError(lexer, "'Invalid name start character: ', ch")
        return false
    }

    NAVXmlLexerNext(lexer)

    // Continue with NameChar
    while (!NAVXmlLexerIsEOF(lexer)) {
        ch = NAVXmlLexerPeek(lexer)

        if (!NAVXmlIsNameChar(ch)) {
            break
        }

        NAVXmlLexerNext(lexer)
    }

    return NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_IDENTIFIER)
}


/**
 * @function NAVXmlLexerScanString
 * @private
 * @description Scan a quoted string (attribute value).
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if string scanned, False (0) on error
 */
define_function char NAVXmlLexerScanString(_NAVXmlLexer lexer) {
    stack_var char quote
    stack_var char ch
    stack_var char value[NAV_XML_LEXER_MAX_TOKEN_LENGTH]

    quote = NAVXmlLexerNext(lexer) // Consume opening quote
    NAVXmlLexerIgnore(lexer) // Don't include quote in token

    while (!NAVXmlLexerIsEOF(lexer)) {
        ch = NAVXmlLexerPeek(lexer)

        if (ch == quote) {
            // End of string
            NAVXmlLexerNext(lexer) // Consume closing quote

            if (!NAVXmlLexerEmitTokenWithValue(lexer, NAV_XML_TOKEN_TYPE_STRING, value)) {
                return false
            }

            NAVXmlLexerIgnore(lexer) // Don't include quote in token
            return true
        }

        if (ch == '&') {
            // Entity reference - need to expand it
            stack_var integer entityStart
            stack_var char entity[20]
            stack_var integer expandedChar

            entityStart = lexer.cursor
            NAVXmlLexerNext(lexer) // Consume &

            // Scan until ;
            while (!NAVXmlLexerIsEOF(lexer) && NAVXmlLexerPeek(lexer) != ';') {
                NAVXmlLexerNext(lexer)
            }

            if (NAVXmlLexerIsEOF(lexer)) {
                NAVXmlLexerSetError(lexer, 'Unterminated entity reference')
                return false
            }

            NAVXmlLexerNext(lexer) // Consume ;

            entity = NAVStringSlice(lexer.source, entityStart, lexer.cursor)

            // Check for character reference
            if (entity[2] == '#') {
                if (NAVXmlExpandCharRef(entity, expandedChar)) {
                    value = "value, type_cast(expandedChar)"
                } else {
                    NAVXmlLexerSetError(lexer, "'Invalid character reference: ', entity")
                    return false
                }
            } else {
                // Named entity
                if (NAVXmlExpandEntity(entity, expandedChar)) {
                    value = "value, type_cast(expandedChar)"
                } else {
                    NAVXmlLexerSetError(lexer, "'Unknown entity: ', entity")
                    return false
                }
            }
        } else {
            value = "value, ch"
            NAVXmlLexerNext(lexer)
        }
    }

    NAVXmlLexerSetError(lexer, 'Unterminated string')
    return false
}


/**
 * @function NAVXmlLexerScanText
 * @private
 * @description Scan text content between elements.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if text scanned, False (0) on error
 */
define_function char NAVXmlLexerScanText(_NAVXmlLexer lexer) {
    stack_var char ch
    stack_var char value[NAV_XML_LEXER_MAX_TOKEN_LENGTH]

    while (!NAVXmlLexerIsEOF(lexer)) {
        ch = NAVXmlLexerPeek(lexer)

        if (ch == '<') {
            // Start of next tag
            break
        }

        if (ch == '&') {
            // Entity reference
            stack_var integer entityStart
            stack_var char entity[20]
            stack_var integer expandedChar

            entityStart = lexer.cursor
            NAVXmlLexerNext(lexer) // Consume &

            // Scan until ;
            while (!NAVXmlLexerIsEOF(lexer) && NAVXmlLexerPeek(lexer) != ';') {
                NAVXmlLexerNext(lexer)
            }

            if (NAVXmlLexerIsEOF(lexer)) {
                NAVXmlLexerSetError(lexer, 'Unterminated entity reference in text')
                return false
            }

            NAVXmlLexerNext(lexer) // Consume ;

            entity = NAVStringSlice(lexer.source, entityStart, lexer.cursor)

            // Check for character reference
            if (entity[2] == '#') {
                if (NAVXmlExpandCharRef(entity, expandedChar)) {
                    value = "value, expandedChar"
                } else {
                    NAVXmlLexerSetError(lexer, "'Invalid character reference: ', entity")
                    return false
                }
            } else {
                // Named entity
                if (NAVXmlExpandEntity(entity, expandedChar)) {
                    value = "value, expandedChar"
                } else {
                    NAVXmlLexerSetError(lexer, "'Unknown entity: ', entity")
                    return false
                }
            }
        } else {
            value = "value, ch"
            NAVXmlLexerNext(lexer)
        }
    }

    // Only emit token if we have non-empty content
    if (length_array(value) > 0) {
        return NAVXmlLexerEmitTokenWithValue(lexer, NAV_XML_TOKEN_TYPE_TEXT, value)
    }

    return true
}


/**
 * @function NAVXmlLexerScanComment
 * @private
 * @description Scan an XML comment <!-- ... -->.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if comment scanned, False (0) on error
 */
define_function char NAVXmlLexerScanComment(_NAVXmlLexer lexer) {
    // Consume <!--
    if (!NAVXmlLexerConsumeString(lexer, '<!--')) {
        return false
    }

    NAVXmlLexerIgnore(lexer) // Don't include <!-- in token

    // Scan until -->
    while (!NAVXmlLexerIsEOF(lexer)) {
        if (NAVXmlLexerMatchString(lexer, '-->')) {
            if (!NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_COMMENT)) {
                return false
            }

            NAVXmlLexerConsumeString(lexer, '-->')
            NAVXmlLexerIgnore(lexer) // Don't include --> in token
            return true
        }

        NAVXmlLexerNext(lexer)
    }

    NAVXmlLexerSetError(lexer, 'Unterminated comment')
    return false
}


/**
 * @function NAVXmlLexerScanCDATA
 * @private
 * @description Scan a CDATA section <![CDATA[ ... ]]>.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if CDATA scanned, False (0) on error
 */
define_function char NAVXmlLexerScanCDATA(_NAVXmlLexer lexer) {
    // Consume <![CDATA[
    if (!NAVXmlLexerConsumeString(lexer, '<![CDATA[')) {
        return false
    }

    NAVXmlLexerIgnore(lexer) // Don't include <![CDATA[ in token

    // Scan until ]]>
    while (!NAVXmlLexerIsEOF(lexer)) {
        if (NAVXmlLexerMatchString(lexer, ']]>')) {
            if (!NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_CDATA)) {
                return false
            }

            NAVXmlLexerConsumeString(lexer, ']]>')
            NAVXmlLexerIgnore(lexer) // Don't include ]]> in token
            return true
        }

        NAVXmlLexerNext(lexer)
    }

    NAVXmlLexerSetError(lexer, 'Unterminated CDATA section')
    return false
}


/**
 * @function NAVXmlLexerScanPI
 * @private
 * @description Scan a processing instruction <?...?>.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if PI scanned, False (0) on error
 */
define_function char NAVXmlLexerScanPI(_NAVXmlLexer lexer) {
    // Consume <?
    if (!NAVXmlLexerConsumeString(lexer, '<?')) {
        return false
    }

    NAVXmlLexerIgnore(lexer) // Don't include <? in token

    // Scan until ?>
    while (!NAVXmlLexerIsEOF(lexer)) {
        if (NAVXmlLexerMatchString(lexer, '?>')) {
            if (!NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_PI)) {
                return false
            }

            NAVXmlLexerConsumeString(lexer, '?>')
            NAVXmlLexerIgnore(lexer) // Don't include ?> in token
            return true
        }

        NAVXmlLexerNext(lexer)
    }

    NAVXmlLexerSetError(lexer, 'Unterminated processing instruction')
    return false
}


/**
 * @function NAVXmlLexerScanDoctype
 * @private
 * @description Scan a DOCTYPE declaration <!DOCTYPE...>.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {char} True (1) if DOCTYPE scanned, False (0) on error
 */
define_function char NAVXmlLexerScanDoctype(_NAVXmlLexer lexer) {
    stack_var integer depth

    // Consume <!DOCTYPE
    if (!NAVXmlLexerConsumeString(lexer, '<!DOCTYPE')) {
        return false
    }

    NAVXmlLexerIgnore(lexer) // Don't include <!DOCTYPE in token

    depth = 1

    // Scan until matching >
    while (!NAVXmlLexerIsEOF(lexer) && depth > 0) {
        stack_var char ch

        ch = NAVXmlLexerNext(lexer)

        switch (ch) {
            case '<': depth++
            case '>': depth--
        }
    }

    if (depth != 0) {
        NAVXmlLexerSetError(lexer, 'Unterminated DOCTYPE')
        return false
    }

    return NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_DOCTYPE)
}


/**
 * @function NAVXmlLexerSkipWhitespace
 * @private
 * @description Skip whitespace characters.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure
 *
 * @returns {void}
 */
define_function NAVXmlLexerSkipWhitespace(_NAVXmlLexer lexer) {
    while (!NAVXmlLexerIsEOF(lexer)) {
        if (!NAVIsWhitespace(NAVXmlLexerPeek(lexer))) {
            break
        }

        NAVXmlLexerNext(lexer)
    }

    NAVXmlLexerIgnore(lexer)
}


/**
 * @function NAVXmlLexerTokenize
 * @public
 * @description Tokenize XML source text into a sequence of tokens.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure to populate
 * @param {char[]} source - The XML source text to tokenize
 *
 * @returns {char} True (1) if tokenization succeeded, False (0) on error
 */
define_function char NAVXmlLexerTokenize(_NAVXmlLexer lexer, char source[]) {
    stack_var char ch

    NAVXmlLexerInit(lexer, source)

    while (!NAVXmlLexerIsEOF(lexer)) {
        // Only skip whitespace when inside tags (for attribute parsing)
        // Text content whitespace is significant and should be preserved
        if (lexer.inTag) {
            NAVXmlLexerSkipWhitespace(lexer)
        }

        if (NAVXmlLexerIsEOF(lexer)) {
            break
        }

        ch = NAVXmlLexerPeek(lexer)

        #IF_DEFINED XML_LEXER_DEBUG
        NAVLog("'[ XmlLexerTokenize ]: cursor=', itoa(lexer.cursor), ' char=', ch, ' (', itoa(type_cast(ch)), ')'")
        #END_IF

        select {
            // Tag open or special construct
            active (ch == '<'): {
                // Check for special constructs
                select {
                    active (NAVXmlLexerMatchString(lexer, '<!--')): {
                        if (!NAVXmlLexerScanComment(lexer)) {
                            return false
                        }
                    }
                    active (NAVXmlLexerMatchString(lexer, '<![CDATA[')): {
                        if (!NAVXmlLexerScanCDATA(lexer)) {
                            return false
                        }
                    }
                    active (NAVXmlLexerMatchString(lexer, '<?')): {
                        if (!NAVXmlLexerScanPI(lexer)) {
                            return false
                        }
                    }
                    active (NAVXmlLexerMatchString(lexer, '<!DOCTYPE')): {
                        if (!NAVXmlLexerScanDoctype(lexer)) {
                            return false
                        }
                    }
                    active (true): {
                        // Regular tag open
                        NAVXmlLexerNext(lexer)
                        lexer.inTag = true  // Entering tag mode
                        if (!NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_TAG_OPEN)) {
                            return false
                        }
                    }
                }
            }

            // Tag close
            active (ch == '>'): {
                NAVXmlLexerNext(lexer)
                lexer.inTag = false  // Leaving tag mode
                if (!NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_TAG_CLOSE)) {
                    return false
                }
            }

            // Slash
            active (ch == '/'): {
                NAVXmlLexerNext(lexer)
                if (!NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_SLASH)) {
                    return false
                }
            }

            // Equals
            active (ch == '='): {
                NAVXmlLexerNext(lexer)
                if (!NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_EQUALS)) {
                    return false
                }
            }

            // Question mark (for PI)
            active (ch == '?'): {
                NAVXmlLexerNext(lexer)
                if (!NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_QUESTION)) {
                    return false
                }
            }

            // String (quoted attribute value)
            active (ch == '"' || ch == ''''): {
                if (!NAVXmlLexerScanString(lexer)) {
                    return false
                }
            }

            // Name (element/attribute name) - only in tag mode
            active (lexer.inTag && NAVXmlIsNameStartChar(ch)): {
                if (!NAVXmlLexerScanName(lexer)) {
                    return false
                }
            }

            // Text content - when not in tag mode
            active (1): {
                if (!NAVXmlLexerScanText(lexer)) {
                    return false
                }
            }
        }
    }

    // Emit EOF token
    if (!NAVXmlLexerEmitToken(lexer, NAV_XML_TOKEN_TYPE_EOF)) {
        return false
    }

    #IF_DEFINED XML_LEXER_DEBUG
    NAVLog("'[ XmlLexerTokenize ]: Tokenization complete. Total tokens: ', itoa(lexer.tokenCount)")
    NAVXmlLexerPrintTokens(lexer)
    #END_IF

    return true
}


/**
 * @function NAVXmlLexerGetTokenType
 * @public
 * @description Get a string representation of a token type (for debugging/errors).
 *
 * @param {integer} type - The token type
 *
 * @returns {char[]} String representation of the token type
 */
define_function char[32] NAVXmlLexerGetTokenType(integer type) {
    switch (type) {
        case NAV_XML_TOKEN_TYPE_TAG_OPEN:      return 'TAG_OPEN'
        case NAV_XML_TOKEN_TYPE_TAG_CLOSE:     return 'TAG_CLOSE'
        case NAV_XML_TOKEN_TYPE_SLASH:         return 'SLASH'
        case NAV_XML_TOKEN_TYPE_EQUALS:        return 'EQUALS'
        case NAV_XML_TOKEN_TYPE_QUESTION:      return 'QUESTION'
        case NAV_XML_TOKEN_TYPE_IDENTIFIER:    return 'IDENTIFIER'
        case NAV_XML_TOKEN_TYPE_STRING:        return 'STRING'
        case NAV_XML_TOKEN_TYPE_TEXT:          return 'TEXT'
        case NAV_XML_TOKEN_TYPE_COMMENT:       return 'COMMENT'
        case NAV_XML_TOKEN_TYPE_CDATA:         return 'CDATA'
        case NAV_XML_TOKEN_TYPE_PI:            return 'PI'
        case NAV_XML_TOKEN_TYPE_DOCTYPE:       return 'DOCTYPE'
        case NAV_XML_TOKEN_TYPE_EOF:           return 'EOF'
        case NAV_XML_TOKEN_TYPE_ERROR:         return 'ERROR'
        default:                               return 'UNKNOWN'
    }
}


/**
 * @function NAVXmlLexerPrintTokens
 * @public
 * @description Print all tokens in the lexer for debugging purposes.
 *
 * @param {_NAVXmlLexer} lexer - The lexer structure containing tokens
 *
 * @returns {void}
 */
define_function NAVXmlLexerPrintTokens(_NAVXmlLexer lexer) {
    stack_var integer i
    stack_var char message[255]

    if (lexer.tokenCount <= 0) {
        NAVLog('[]')
        return
    }

    NAVLog('XML Lexer Tokens:')

    for (i = 1; i <= lexer.tokenCount; i++) {
        message = "'  [', itoa(i), '] ', NAVXmlLexerGetTokenType(lexer.tokens[i].type)"
        message = "message, ' @ L', itoa(lexer.tokens[i].line), ':C', itoa(lexer.tokens[i].column)"

        if (lexer.tokens[i].type != NAV_XML_TOKEN_TYPE_EOF) {
            message = "message, ' = "', lexer.tokens[i].value, '"'"
        }

        NAVLog(message)
    }
}


#END_IF // __NAV_FOUNDATION_XML_LEXER__
