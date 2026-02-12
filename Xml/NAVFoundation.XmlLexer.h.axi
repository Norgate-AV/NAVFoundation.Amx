PROGRAM_NAME='NAVFoundation.XmlLexer.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_XML_LEXER_H__
#DEFINE __NAV_FOUNDATION_XML_LEXER_H__ 'NAVFoundation.XmlLexer.h'


DEFINE_CONSTANT

// =============================================================================
// Configuration Constants
// =============================================================================

/**
 * Maximum number of tokens that can be produced by the lexer.
 * Increase this value if parsing large XML documents with many tokens.
 * @default 2000
 */
#IF_NOT_DEFINED NAV_XML_LEXER_MAX_TOKENS
constant integer NAV_XML_LEXER_MAX_TOKENS           = 2000
#END_IF

/**
 * Maximum length of a single token value (in characters).
 * This limits the size of element names, attribute values, and text content.
 * @default 512
 */
#IF_NOT_DEFINED NAV_XML_LEXER_MAX_TOKEN_LENGTH
constant integer NAV_XML_LEXER_MAX_TOKEN_LENGTH     = 512
#END_IF

/**
 * Maximum length of the source input string to tokenize (in characters).
 * @default 8192
 */
#IF_NOT_DEFINED NAV_XML_LEXER_MAX_SOURCE
constant long NAV_XML_LEXER_MAX_SOURCE              = 8192
#END_IF


// =============================================================================
// XML Token Types
// =============================================================================
// Token types representing the syntactic elements found in XML source text.

/**
 * Token type for structural characters (delimiters)
 */
constant integer NAV_XML_TOKEN_TYPE_TAG_OPEN        = 1   // <
constant integer NAV_XML_TOKEN_TYPE_TAG_CLOSE       = 2   // >
constant integer NAV_XML_TOKEN_TYPE_SLASH           = 3   // /
constant integer NAV_XML_TOKEN_TYPE_EQUALS          = 4   // =
constant integer NAV_XML_TOKEN_TYPE_QUESTION        = 5   // ?

/**
 * Token types for XML values and identifiers
 */
constant integer NAV_XML_TOKEN_TYPE_IDENTIFIER      = 6   // Element/attribute names
constant integer NAV_XML_TOKEN_TYPE_STRING          = 7   // Attribute values (quoted)
constant integer NAV_XML_TOKEN_TYPE_TEXT            = 8   // Text content between elements

/**
 * Token types for special XML constructs
 */
constant integer NAV_XML_TOKEN_TYPE_COMMENT         = 9   // <!-- ... -->
constant integer NAV_XML_TOKEN_TYPE_CDATA           = 10  // <![CDATA[ ... ]]>
constant integer NAV_XML_TOKEN_TYPE_PI              = 11  // <?target data?>
constant integer NAV_XML_TOKEN_TYPE_DOCTYPE         = 12  // <!DOCTYPE ...>

/**
 * Special tokens
 */
constant integer NAV_XML_TOKEN_TYPE_EOF             = 13  // End of input
constant integer NAV_XML_TOKEN_TYPE_ERROR           = 14  // Lexical error

// =============================================================================
// Lexer Error Codes
// =============================================================================

/**
 * Error codes for lexical analysis
 */
constant integer NAV_XML_LEXER_ERROR_NONE           = 0   // No error
constant integer NAV_XML_LEXER_ERROR_UNEXPECTED_CHAR = 1  // Unexpected character
constant integer NAV_XML_LEXER_ERROR_INVALID_NAME   = 2   // Invalid element/attribute name
constant integer NAV_XML_LEXER_ERROR_INVALID_ENTITY = 3   // Invalid entity reference
constant integer NAV_XML_LEXER_ERROR_UNTERMINATED_TAG = 4 // Unterminated tag
constant integer NAV_XML_LEXER_ERROR_UNTERMINATED_STRING = 5 // Unterminated string
constant integer NAV_XML_LEXER_ERROR_UNTERMINATED_COMMENT = 6 // Unterminated comment
constant integer NAV_XML_LEXER_ERROR_UNTERMINATED_CDATA = 7 // Unterminated CDATA
constant integer NAV_XML_LEXER_ERROR_INVALID_CHAR_REF = 8 // Invalid character reference
constant integer NAV_XML_LEXER_ERROR_TOKEN_LIMIT    = 9   // Exceeded token limit
constant integer NAV_XML_LEXER_ERROR_TOKEN_TOO_LONG = 10  // Token exceeds max length

// =============================================================================
// XML Node Types (for parser/DOM representation)
// =============================================================================
// These types are used after parsing to represent the actual XML node types
// in the document object model.

/**
 * Type of an XML node
 * These correspond to the fundamental XML node types
 */
constant integer NAV_XML_TYPE_NONE                  = 0   // Invalid/uninitialized
constant integer NAV_XML_TYPE_DOCUMENT              = 1   // Document root
constant integer NAV_XML_TYPE_ELEMENT               = 2   // Element <tag>...</tag>
constant integer NAV_XML_TYPE_TEXT                  = 3   // Text content
constant integer NAV_XML_TYPE_CDATA                 = 4   // CDATA section
constant integer NAV_XML_TYPE_COMMENT               = 5   // Comment
constant integer NAV_XML_TYPE_PI                    = 6   // Processing instruction

// =============================================================================
// XML Predefined Entities
// =============================================================================

/**
 * Predefined XML entities that must be supported
 */
constant char NAV_XML_ENTITY_LT[]                   = '&lt;'     // <
constant char NAV_XML_ENTITY_GT[]                   = '&gt;'     // >
constant char NAV_XML_ENTITY_AMP[]                  = '&amp;'    // &
constant char NAV_XML_ENTITY_QUOT[]                 = '&quot;'   // "
constant char NAV_XML_ENTITY_APOS[]                 = '&apos;'   // '


DEFINE_TYPE

/**
 * @struct _NAVXmlToken
 * @description Represents a single token produced by the XML lexer.
 *
 * Each token represents a syntactic element in the XML source text,
 * including structural characters, element names, attributes, text content,
 * and special constructs like comments and CDATA sections.
 *
 * @property {integer} type - The token type (NAV_XML_TOKEN_TYPE_*\)
 * @property {char[]} value - The token's text value
 * @property {integer} start - Start position in source text (1-based)
 * @property {integer} end - End position in source text (1-based, inclusive)
 * @property {integer} line - Line number where token appears
 * @property {integer} column - Column number where token starts
 */
struct _NAVXmlToken {
    integer type
    char value[NAV_XML_LEXER_MAX_TOKEN_LENGTH]
    integer start
    integer end
    integer line
    integer column
}

/**
 * @struct _NAVXmlLexer
 * @description The XML lexer state structure.
 *
 * Maintains the lexer's current position in the source text, tracks tokens,
 * and stores error information if lexical analysis fails.
 *
 * @property {char[]} source - The source XML text being tokenized
 * @property {integer} cursor - Current position in source text (1-based)
 * @property {integer} start - Start position of current token (1-based)
 * @property {integer} line - Current line number (1-based)
 * @property {integer} column - Current column number (1-based)
 * @property {_NAVXmlToken[]} tokens - Array of produced tokens
 * @property {integer} tokenCount - Number of tokens produced
 * @property {char} hasError - True if a lexical error occurred
 * @property {char[]} error - Error message if hasError is true
 * @property {char} inTag - Track if we're inside a tag (between < and >)
 */
struct _NAVXmlLexer {
    char source[NAV_XML_LEXER_MAX_SOURCE]
    integer cursor
    integer start
    integer line
    integer column
    _NAVXmlToken tokens[NAV_XML_LEXER_MAX_TOKENS]
    integer tokenCount
    char hasError
    char error[255]
    char inTag  // Track if we're inside a tag (between < and >)
}


#END_IF // __NAV_FOUNDATION_XML_LEXER_H__
