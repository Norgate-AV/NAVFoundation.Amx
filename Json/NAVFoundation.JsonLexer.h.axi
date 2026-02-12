PROGRAM_NAME='NAVFoundation.JsonLexer.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_JSON_LEXER_H__
#DEFINE __NAV_FOUNDATION_JSON_LEXER_H__ 'NAVFoundation.JsonLexer.h'


DEFINE_CONSTANT

// =============================================================================
// Configuration Constants
// =============================================================================

/**
 * Maximum number of tokens that can be produced by the lexer.
 * Increase this value if parsing large JSON documents with many tokens.
 * @default 1000
 */
#IF_NOT_DEFINED NAV_JSON_LEXER_MAX_TOKENS
constant integer NAV_JSON_LEXER_MAX_TOKENS           = 1000
#END_IF

/**
 * Maximum length of a single token value (in characters).
 * This limits the size of string values, numbers, and literals.
 * @default 255
 */
#IF_NOT_DEFINED NAV_JSON_LEXER_MAX_TOKEN_LENGTH
constant integer NAV_JSON_LEXER_MAX_TOKEN_LENGTH     = 255
#END_IF

/**
 * Maximum length of the source input string to tokenize (in characters).
 * @default 4096
 */
#IF_NOT_DEFINED NAV_JSON_LEXER_MAX_SOURCE
constant long NAV_JSON_LEXER_MAX_SOURCE              = 4096
#END_IF


// =============================================================================
// JSON Token Types
// =============================================================================
// Based on yyjson's type system, we define token types that the lexer will emit
// during the scanning phase. These tokens represent the syntactic elements found
// in the JSON source text.

/**
 * Token type for structural characters (delimiters)
 */
constant integer NAV_JSON_TOKEN_TYPE_LEFT_BRACE        = 1   // {
constant integer NAV_JSON_TOKEN_TYPE_RIGHT_BRACE       = 2   // }
constant integer NAV_JSON_TOKEN_TYPE_LEFT_BRACKET      = 3   // [
constant integer NAV_JSON_TOKEN_TYPE_RIGHT_BRACKET     = 4   // ]
constant integer NAV_JSON_TOKEN_TYPE_COLON             = 5   // :
constant integer NAV_JSON_TOKEN_TYPE_COMMA             = 6   // ,

/**
 * Token types for JSON values
 */
constant integer NAV_JSON_TOKEN_TYPE_STRING            = 7   // "string"
constant integer NAV_JSON_TOKEN_TYPE_NUMBER            = 8   // 1234, -56.78, 1.23e-4
constant integer NAV_JSON_TOKEN_TYPE_TRUE              = 9   // true literal
constant integer NAV_JSON_TOKEN_TYPE_FALSE             = 10  // false literal
constant integer NAV_JSON_TOKEN_TYPE_NULL              = 11  // null literal

/**
 * Special tokens
 */
constant integer NAV_JSON_TOKEN_TYPE_EOF               = 12  // End of input
constant integer NAV_JSON_TOKEN_TYPE_ERROR             = 13  // Lexical error

// =============================================================================
// Lexer Error Codes
// =============================================================================

/**
 * Error codes for lexical analysis
 */
constant integer NAV_JSON_LEXER_ERROR_NONE             = 0   // No error
constant integer NAV_JSON_LEXER_ERROR_UNEXPECTED_CHAR  = 1   // Unexpected character
constant integer NAV_JSON_LEXER_ERROR_INVALID_STRING   = 2   // Invalid string literal
constant integer NAV_JSON_LEXER_ERROR_INVALID_NUMBER   = 3   // Invalid number literal
constant integer NAV_JSON_LEXER_ERROR_INVALID_ESCAPE   = 4   // Invalid escape sequence
constant integer NAV_JSON_LEXER_ERROR_UNTERMINATED_STR = 5   // Unterminated string
constant integer NAV_JSON_LEXER_ERROR_TOKEN_LIMIT      = 6   // Exceeded token limit
constant integer NAV_JSON_LEXER_ERROR_TOKEN_TOO_LONG   = 7   // Token exceeds max length

// =============================================================================
// JSON Value Types (for parser/value representation)
// =============================================================================
// These types mirror yyjson's type system and are used after parsing to
// represent the actual JSON value types in the document object model.

/**
 * Type of a JSON value (3-bit aligned)
 * These correspond to the fundamental JSON types defined in RFC 8259
 */
constant integer NAV_JSON_TYPE_NONE                    = 0   // Invalid/uninitialized
constant integer NAV_JSON_TYPE_NULL                    = 1   // null literal
constant integer NAV_JSON_TYPE_BOOL                    = 2   // true or false
constant integer NAV_JSON_TYPE_NUM                     = 3   // number (integer or real)
constant integer NAV_JSON_TYPE_STR                     = 4   // string
constant integer NAV_JSON_TYPE_ARR                     = 5   // array []
constant integer NAV_JSON_TYPE_OBJ                     = 6   // object {}

/**
 * Subtype of a JSON value
 * Provides additional type information for certain value types
 */
// Boolean subtypes
constant integer NAV_JSON_SUBTYPE_NONE                 = 0   // No subtype
constant integer NAV_JSON_SUBTYPE_FALSE                = 0   // false literal
constant integer NAV_JSON_SUBTYPE_TRUE                 = 1   // true literal

// Number subtypes
constant integer NAV_JSON_SUBTYPE_UINT                 = 0   // Unsigned integer
constant integer NAV_JSON_SUBTYPE_SINT                 = 1   // Signed integer
constant integer NAV_JSON_SUBTYPE_REAL                 = 2   // Real number (float)

// String subtypes
constant integer NAV_JSON_SUBTYPE_STR_NORMAL           = 0   // String with possible escapes
constant integer NAV_JSON_SUBTYPE_STR_NOESC            = 1   // String with no escape sequences (optimization)


// =============================================================================
// JSON Value Types (for parser node representation)
// =============================================================================
// These are used by the parser to identify node types in the parse tree.
// They align with the JSON value types but are distinct from token types.

constant integer NAV_JSON_VALUE_TYPE_NONE              = 0   // Invalid/uninitialized
constant integer NAV_JSON_VALUE_TYPE_NULL              = 1   // null literal
constant integer NAV_JSON_VALUE_TYPE_TRUE              = 2   // true literal
constant integer NAV_JSON_VALUE_TYPE_FALSE             = 3   // false literal
constant integer NAV_JSON_VALUE_TYPE_NUMBER            = 4   // number (integer or real)
constant integer NAV_JSON_VALUE_TYPE_STRING            = 5   // string
constant integer NAV_JSON_VALUE_TYPE_ARRAY             = 6   // array []
constant integer NAV_JSON_VALUE_TYPE_OBJECT            = 7   // object {}


DEFINE_TYPE

// =============================================================================
// JSON Lexer Token Structure
// =============================================================================

/**
 * Represents a single token produced by the lexer.
 *
 * @field type - The token type (NAV_JSON_TOKEN_TYPE_*\)
 * @field value - The string value of the token (raw text from source)
 * @field start - Start position in the source string (1-based)
 * @field end - End position in the source string (1-based, inclusive)
 * @field line - Line number where the token appears (1-based)
 * @field column - Column number where the token starts (1-based)
 */
struct _NAVJsonToken {
    integer type
    char value[NAV_JSON_LEXER_MAX_TOKEN_LENGTH]
    integer start
    integer end
    integer line
    integer column
}

// =============================================================================
// JSON Lexer State Structure
// =============================================================================

/**
 * Represents the state of the JSON lexer.
 *
 * @field source - The source JSON text being lexed
 * @field start - Start position of the current token being scanned
 * @field cursor - Current position in the source string (1-based)
 * @field line - Current line number (1-based)
 * @field column - Current column number (1-based)
 * @field tokens - Array of tokens produced by the lexer
 * @field tokenCount - Number of tokens in the tokens array
 * @field hasError - Flag indicating if a lexical error occurred
 * @field error - Error message if hasError is true
 */
struct _NAVJsonLexer {
    char source[NAV_JSON_LEXER_MAX_SOURCE]
    integer start
    integer cursor
    integer line
    integer column

    _NAVJsonToken tokens[NAV_JSON_LEXER_MAX_TOKENS]
    integer tokenCount

    char hasError
    char error[255]
}


#END_IF // __NAV_FOUNDATION_JSON_LEXER_H__
