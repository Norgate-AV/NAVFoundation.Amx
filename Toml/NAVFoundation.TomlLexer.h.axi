PROGRAM_NAME='NAVFoundation.TomlLexer.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TOML_LEXER_H__
#DEFINE __NAV_FOUNDATION_TOML_LEXER_H__ 'NAVFoundation.TomlLexer.h'


DEFINE_CONSTANT

// =============================================================================
// Configuration Constants
// =============================================================================

/**
 * Maximum number of tokens that can be produced by the lexer.
 * Increase this value if parsing large TOML documents with many tokens.
 * @default 2000
 */
#IF_NOT_DEFINED NAV_TOML_LEXER_MAX_TOKENS
constant integer NAV_TOML_LEXER_MAX_TOKENS           = 2000
#END_IF

/**
 * Maximum length of a single token value (in characters).
 * This limits the size of string values, keys, and identifiers.
 * @default 255
 */
#IF_NOT_DEFINED NAV_TOML_LEXER_MAX_TOKEN_LENGTH
constant integer NAV_TOML_LEXER_MAX_TOKEN_LENGTH     = 255
#END_IF

/**
 * Maximum length of the source input string to tokenize (in characters).
 * @default 8192
 */
#IF_NOT_DEFINED NAV_TOML_LEXER_MAX_SOURCE
constant long NAV_TOML_LEXER_MAX_SOURCE              = 8192
#END_IF


// =============================================================================
// TOML Token Types
// =============================================================================
// Based on the TOML v1.1.0 specification, these tokens represent the syntactic
// elements found in TOML source text.

/**
 * Structural tokens
 */
constant integer NAV_TOML_TOKEN_TYPE_LEFT_BRACKET      = 1   // [
constant integer NAV_TOML_TOKEN_TYPE_RIGHT_BRACKET     = 2   // ]
constant integer NAV_TOML_TOKEN_TYPE_LEFT_BRACE        = 3   // {
constant integer NAV_TOML_TOKEN_TYPE_RIGHT_BRACE       = 4   // }
constant integer NAV_TOML_TOKEN_TYPE_EQUALS            = 5   // =
constant integer NAV_TOML_TOKEN_TYPE_DOT               = 6   // .
constant integer NAV_TOML_TOKEN_TYPE_COMMA             = 7   // ,

/**
 * Table and array of tables tokens
 */
constant integer NAV_TOML_TOKEN_TYPE_TABLE_HEADER      = 8   // [table]
constant integer NAV_TOML_TOKEN_TYPE_ARRAY_TABLE       = 9   // [[array.table]]

/**
 * Value tokens
 */
constant integer NAV_TOML_TOKEN_TYPE_STRING            = 10  // "string" or 'literal'
constant integer NAV_TOML_TOKEN_TYPE_MULTILINE_STRING  = 11  // """multiline"""
constant integer NAV_TOML_TOKEN_TYPE_INTEGER           = 12  // 123, -456, 0x1A, 0o755, 0b1010
constant integer NAV_TOML_TOKEN_TYPE_FLOAT             = 13  // 1.23, -4.56, 1e10, inf, nan
constant integer NAV_TOML_TOKEN_TYPE_BOOLEAN           = 14  // true, false
constant integer NAV_TOML_TOKEN_TYPE_DATETIME          = 15  // 2024-01-15T10:30:00Z
constant integer NAV_TOML_TOKEN_TYPE_DATE              = 16  // 2024-01-15
constant integer NAV_TOML_TOKEN_TYPE_TIME              = 17  // 10:30:00

/**
 * Key and identifier tokens
 */
constant integer NAV_TOML_TOKEN_TYPE_BARE_KEY          = 18  // Unquoted key (alphanumeric, -, _)
constant integer NAV_TOML_TOKEN_TYPE_QUOTED_KEY        = 19  // Quoted key "key" or 'key'

/**
 * Whitespace and control tokens
 */
constant integer NAV_TOML_TOKEN_TYPE_NEWLINE           = 20  // Line break
constant integer NAV_TOML_TOKEN_TYPE_COMMENT           = 21  // # comment

/**
 * Special tokens
 */
constant integer NAV_TOML_TOKEN_TYPE_EOF               = 22  // End of input
constant integer NAV_TOML_TOKEN_TYPE_ERROR             = 23  // Lexical error


// =============================================================================
// Lexer Error Codes
// =============================================================================

/**
 * Error codes for lexical analysis
 */
constant integer NAV_TOML_LEXER_ERROR_NONE             = 0   // No error
constant integer NAV_TOML_LEXER_ERROR_UNEXPECTED_CHAR  = 1   // Unexpected character
constant integer NAV_TOML_LEXER_ERROR_INVALID_STRING   = 2   // Invalid string literal
constant integer NAV_TOML_LEXER_ERROR_INVALID_NUMBER   = 3   // Invalid number literal
constant integer NAV_TOML_LEXER_ERROR_INVALID_ESCAPE   = 4   // Invalid escape sequence
constant integer NAV_TOML_LEXER_ERROR_UNTERMINATED_STR = 5   // Unterminated string
constant integer NAV_TOML_LEXER_ERROR_INVALID_DATE     = 6   // Invalid date/time format
constant integer NAV_TOML_LEXER_ERROR_TOKEN_LIMIT      = 7   // Exceeded token limit
constant integer NAV_TOML_LEXER_ERROR_TOKEN_TOO_LONG   = 8   // Token exceeds max length
constant integer NAV_TOML_LEXER_ERROR_INVALID_KEY      = 9   // Invalid key format


// =============================================================================
// TOML Value Types (for parser/value representation)
// =============================================================================
// These types are used after parsing to represent the actual TOML value types
// in the document object model.

/**
 * Type of a TOML value
 * These correspond to the fundamental TOML types defined in the specification
 */
constant integer NAV_TOML_TYPE_NONE                    = 0   // Invalid/uninitialized
constant integer NAV_TOML_TYPE_STRING                  = 1   // string
constant integer NAV_TOML_TYPE_INTEGER                 = 2   // integer (64-bit signed)
constant integer NAV_TOML_TYPE_FLOAT                   = 3   // float (double precision)
constant integer NAV_TOML_TYPE_BOOLEAN                 = 4   // boolean (true/false)
constant integer NAV_TOML_TYPE_DATETIME                = 5   // datetime (RFC 3339)
constant integer NAV_TOML_TYPE_DATE                    = 6   // date (local)
constant integer NAV_TOML_TYPE_TIME                    = 7   // time (local)
constant integer NAV_TOML_TYPE_ARRAY                   = 8   // array []
constant integer NAV_TOML_TYPE_TABLE                   = 9   // table (object/map)
constant integer NAV_TOML_TYPE_INLINE_TABLE            = 10  // inline table { }


/**
 * Subtype of a TOML value
 * Provides additional type information for certain value types
 */
// Boolean subtypes
constant integer NAV_TOML_SUBTYPE_NONE                 = 0   // No subtype
constant integer NAV_TOML_SUBTYPE_FALSE                = 0   // false literal
constant integer NAV_TOML_SUBTYPE_TRUE                 = 1   // true literal

// Integer subtypes (base)
constant integer NAV_TOML_SUBTYPE_DECIMAL              = 0   // Base 10
constant integer NAV_TOML_SUBTYPE_HEXADECIMAL          = 1   // Base 16 (0x)
constant integer NAV_TOML_SUBTYPE_OCTAL                = 2   // Base 8 (0o)
constant integer NAV_TOML_SUBTYPE_BINARY               = 3   // Base 2 (0b)

// Float subtypes
constant integer NAV_TOML_SUBTYPE_FLOAT_NORMAL         = 0   // Normal float
constant integer NAV_TOML_SUBTYPE_FLOAT_INF            = 1   // Infinity
constant integer NAV_TOML_SUBTYPE_FLOAT_NAN            = 2   // Not a Number

// String subtypes
constant integer NAV_TOML_SUBTYPE_STRING_BASIC         = 0   // "string"
constant integer NAV_TOML_SUBTYPE_STRING_LITERAL       = 1   // 'string'
constant integer NAV_TOML_SUBTYPE_STRING_MULTILINE     = 2   // """multiline"""
constant integer NAV_TOML_SUBTYPE_STRING_LITERAL_ML    = 3   // '''multiline'''


DEFINE_TYPE

/**
 * @struct _NAVTomlToken
 * @public
 * @description Represents a single token produced by the lexer.
 *
 * Each token has a type, value, and position information for error reporting.
 *
 * @property {integer} type - The token type (NAV_TOML_TOKEN_TYPE_*\)
 * @property {char[]} value - The token's text value
 * @property {long} start - Byte offset where token starts in source
 * @property {long} end - Byte offset where token ends in source
 * @property {integer} line - Line number where token appears (1-based)
 * @property {integer} column - Column number where token starts (1-based)
 */
struct _NAVTomlToken {
    integer type
    char value[NAV_TOML_LEXER_MAX_TOKEN_LENGTH]
    long start
    long end
    integer line
    integer column
}


/**
 * @struct _NAVTomlLexer
 * @private
 * @description The lexer state structure for tokenizing TOML source text.
 *
 * This structure maintains the current position in the source text and
 * accumulates tokens as they are recognized.
 *
 * @property {char[]} source - The source text being tokenized
 * @property {long} cursor - Current position in source text (1-based)
 * @property {long} start - Start position of current token (1-based)
 * @property {integer} line - Current line number (1-based)
 * @property {integer} column - Current column number (1-based)
 * @property {_NAVTomlToken[]} tokens - Array of emitted tokens
 * @property {integer} tokenCount - Number of tokens emitted
 * @property {char} hasError - True if a lexical error occurred
 * @property {char[]} error - Error message if hasError is true
 */
struct _NAVTomlLexer {
    char source[NAV_TOML_LEXER_MAX_SOURCE]
    integer cursor
    integer start
    integer line
    integer column

    _NAVTomlToken tokens[NAV_TOML_LEXER_MAX_TOKENS]
    integer tokenCount

    char hasError
    char error[255]
}


#END_IF // __NAV_FOUNDATION_TOML_LEXER_H__
