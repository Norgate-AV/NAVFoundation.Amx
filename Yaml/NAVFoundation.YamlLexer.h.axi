PROGRAM_NAME='NAVFoundation.YamlLexer.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_YAML_LEXER_H__
#DEFINE __NAV_FOUNDATION_YAML_LEXER_H__ 'NAVFoundation.YamlLexer.h'


DEFINE_CONSTANT

// =============================================================================
// Configuration Constants
// =============================================================================

/**
 * Maximum number of tokens that can be produced by the lexer.
 * Increase this value if parsing large YAML documents with many tokens.
 * @default 1000
 */
#IF_NOT_DEFINED NAV_YAML_LEXER_MAX_TOKENS
constant integer NAV_YAML_LEXER_MAX_TOKENS           = 1000
#END_IF

/**
 * Maximum length of a single token value (in characters).
 * This limits the size of string values, keys, and scalars.
 * @default 255
 */
#IF_NOT_DEFINED NAV_YAML_LEXER_MAX_TOKEN_LENGTH
constant integer NAV_YAML_LEXER_MAX_TOKEN_LENGTH     = 255
#END_IF

/**
 * Maximum length of the source input string to tokenize (in characters).
 * @default 4096
 */
#IF_NOT_DEFINED NAV_YAML_LEXER_MAX_SOURCE
constant long NAV_YAML_LEXER_MAX_SOURCE              = 4096
#END_IF

/**
 * Maximum nesting depth for indentation levels.
 * YAML structure is determined by indentation, not braces.
 * @default 32
 */
#IF_NOT_DEFINED NAV_YAML_LEXER_MAX_INDENT_LEVEL
constant integer NAV_YAML_LEXER_MAX_INDENT_LEVEL     = 32
#END_IF


// =============================================================================
// YAML Token Types
// =============================================================================
// Based on YAML 1.2 specification, these tokens represent the syntactic
// elements found in YAML source text.

/**
 * Document markers
 */
constant integer NAV_YAML_TOKEN_TYPE_DOCUMENT_START    = 1   // ---
constant integer NAV_YAML_TOKEN_TYPE_DOCUMENT_END      = 2   // ...

/**
 * Structural tokens
 */
constant integer NAV_YAML_TOKEN_TYPE_KEY               = 3   // Mapping key (before colon)
constant integer NAV_YAML_TOKEN_TYPE_VALUE             = 4   // Scalar value
constant integer NAV_YAML_TOKEN_TYPE_COLON             = 5   // :
constant integer NAV_YAML_TOKEN_TYPE_DASH              = 6   // - (sequence item)
constant integer NAV_YAML_TOKEN_TYPE_COMMA             = 7   // ,

/**
 * Flow style delimiters
 */
constant integer NAV_YAML_TOKEN_TYPE_LEFT_BRACKET      = 8   // [
constant integer NAV_YAML_TOKEN_TYPE_RIGHT_BRACKET     = 9   // ]
constant integer NAV_YAML_TOKEN_TYPE_LEFT_BRACE        = 10  // {
constant integer NAV_YAML_TOKEN_TYPE_RIGHT_BRACE       = 11  // }

/**
 * String tokens
 */
constant integer NAV_YAML_TOKEN_TYPE_STRING            = 12  // Quoted string
constant integer NAV_YAML_TOKEN_TYPE_PLAIN_SCALAR      = 13  // Unquoted scalar
constant integer NAV_YAML_TOKEN_TYPE_LITERAL           = 14  // | block scalar
constant integer NAV_YAML_TOKEN_TYPE_FOLDED            = 15  // > block scalar

/**
 * Special tokens
 */
constant integer NAV_YAML_TOKEN_TYPE_ANCHOR            = 16  // &anchor
constant integer NAV_YAML_TOKEN_TYPE_ALIAS             = 17  // *anchor
constant integer NAV_YAML_TOKEN_TYPE_TAG               = 18  // !!type

/**
 * Boolean and null literals
 */
constant integer NAV_YAML_TOKEN_TYPE_TRUE              = 19  // true, True, TRUE, yes, Yes, YES, on, On, ON
constant integer NAV_YAML_TOKEN_TYPE_FALSE             = 20  // false, False, FALSE, no, No, NO, off, Off, OFF
constant integer NAV_YAML_TOKEN_TYPE_NULL              = 21  // null, Null, NULL, ~

/**
 * Whitespace and control tokens
 */
constant integer NAV_YAML_TOKEN_TYPE_NEWLINE           = 22  // Line break
constant integer NAV_YAML_TOKEN_TYPE_INDENT            = 23  // Increased indentation
constant integer NAV_YAML_TOKEN_TYPE_DEDENT            = 24  // Decreased indentation
constant integer NAV_YAML_TOKEN_TYPE_COMMENT           = 25  // # comment

/**
 * Directives
 */
constant integer NAV_YAML_TOKEN_TYPE_DIRECTIVE         = 26  // %YAML or %TAG directive

/**
 * End marker
 */
constant integer NAV_YAML_TOKEN_TYPE_EOF               = 27  // End of input


// =============================================================================
// YAML Quote Types
// =============================================================================

constant integer NAV_YAML_QUOTE_TYPE_NONE              = 0   // Unquoted
constant integer NAV_YAML_QUOTE_TYPE_SINGLE            = 1   // 'single quoted'
constant integer NAV_YAML_QUOTE_TYPE_DOUBLE            = 2   // "double quoted"


DEFINE_TYPE

/**
 * @struct _NAVYamlToken
 * @public
 * @description Represents a single token produced by the YAML lexer.
 *
 * @property {integer} type - The token type (NAV_YAML_TOKEN_TYPE_*\)
 * @property {char[]} value - The token's text value
 * @property {integer} line - Line number where token starts (1-based)
 * @property {integer} column - Column number where token starts (1-based)
 * @property {integer} indent - Indentation level (number of spaces)
 * @property {integer} quoteType - Quote type for strings (NAV_YAML_QUOTE_TYPE_*\)
 */
struct _NAVYamlToken {
    integer type
    char value[NAV_YAML_LEXER_MAX_TOKEN_LENGTH]
    integer line
    integer column
    integer indent
    integer quoteType
}

/**
 * @struct _NAVYamlLexer
 * @public
 * @description Lexer state for YAML tokenization.
 * Follows Rob Pike's lexer pattern with start/cursor positions.
 *
 * @property {char[]} source - Original YAML source text
 * @property {integer} start - Start position of current token (1-based)
 * @property {integer} cursor - Current position in source text (1-based)
 * @property {integer} line - Current line number (1-based)
 * @property {integer} column - Current column number (1-based)
 * @property {_NAVYamlToken[]} tokens - Array of tokens produced by lexer
 * @property {integer} tokenCount - Number of tokens in the array
 * @property {integer[]} indentStack - Stack of indentation levels
 * @property {integer} indentStackSize - Number of items in indent stack
 * @property {char} hasError - Flag indicating if a lexical error occurred
 * @property {char[]} error - Error message if tokenization fails
 */
struct _NAVYamlLexer {
    char source[NAV_YAML_LEXER_MAX_SOURCE]
    integer start
    integer cursor
    integer line
    integer column

    _NAVYamlToken tokens[NAV_YAML_LEXER_MAX_TOKENS]
    integer tokenCount

    integer indentStack[NAV_YAML_LEXER_MAX_INDENT_LEVEL]
    integer indentStackSize

    char inBlockScalar
    integer blockScalarIndent

    char hasError
    char error[255]
}


#END_IF // __NAV_FOUNDATION_YAML_LEXER_H__
