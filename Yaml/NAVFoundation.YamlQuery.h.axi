PROGRAM_NAME='NAVFoundation.YamlQuery.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_YAML_QUERY_H__
#DEFINE __NAV_FOUNDATION_YAML_QUERY_H__ 'NAVFoundation.YamlQuery.h'


DEFINE_CONSTANT

/**
 * @constant NAV_YAML_QUERY_MAX_TOKENS
 * @description Maximum number of tokens that can be produced by the query lexer.
 * Each component in a query path (dots, identifiers, brackets) requires one token.
 * Increase this value if working with very long query paths.
 * @default 50
 */
constant integer NAV_YAML_QUERY_MAX_TOKENS = 50

/**
 * @constant NAV_YAML_QUERY_MAX_IDENTIFIER_LENGTH
 * @description Maximum length of an identifier (property name) in a query path.
 * @default 64
 */
constant integer NAV_YAML_QUERY_MAX_IDENTIFIER_LENGTH = 64

/**
 * @constant NAV_YAML_QUERY_MAX_PATH_STEPS
 * @description Maximum number of path steps in a query.
 * Each navigation step (property access or array index) requires one path step.
 * @default 25
 */
constant integer NAV_YAML_QUERY_MAX_PATH_STEPS = 25

/**
 * @constant NAV_YAML_QUERY_TOKEN_DOT
 * @description Token type for the dot operator (.) in query syntax.
 * Used to access mapping keys.
 * @example .property
 */
constant integer NAV_YAML_QUERY_TOKEN_DOT = 1

/**
 * @constant NAV_YAML_QUERY_TOKEN_IDENTIFIER
 * @description Token type for identifiers (property names) in query syntax.
 * @example .name or .user.name
 */
constant integer NAV_YAML_QUERY_TOKEN_IDENTIFIER = 2

/**
 * @constant NAV_YAML_QUERY_TOKEN_LEFT_BRACKET
 * @description Token type for left bracket ([) in query syntax.
 * Used to begin array index access.
 * @example .[0]
 */
constant integer NAV_YAML_QUERY_TOKEN_LEFT_BRACKET = 3

/**
 * @constant NAV_YAML_QUERY_TOKEN_RIGHT_BRACKET
 * @description Token type for right bracket (]) in query syntax.
 * Used to end array index access.
 * @example .[0]
 */
constant integer NAV_YAML_QUERY_TOKEN_RIGHT_BRACKET = 4

/**
 * @constant NAV_YAML_QUERY_TOKEN_NUMBER
 * @description Token type for numeric array indices in query syntax.
 * @example .[2] or .[15]
 */
constant integer NAV_YAML_QUERY_TOKEN_NUMBER = 5

/**
 * @constant NAV_YAML_QUERY_TOKEN_EOF
 * @description Token type for end of query string.
 */
constant integer NAV_YAML_QUERY_TOKEN_EOF = 6


// =============================================================================
// Query Path Step Types
// =============================================================================

/**
 * @constant NAV_YAML_QUERY_STEP_PROPERTY
 * @description Path step that accesses a mapping property by key.
 * @example .name, .config.server
 */
constant integer NAV_YAML_QUERY_STEP_PROPERTY = 1

/**
 * @constant NAV_YAML_QUERY_STEP_INDEX
 * @description Path step that accesses a sequence element by index.
 * @example .[0], .items[3]
 */
constant integer NAV_YAML_QUERY_STEP_INDEX = 2


DEFINE_TYPE

/**
 * @struct _NAVYamlQueryToken
 * @private
 * @description Represents a token in a query path.
 *
 * @property {integer} type - The token type (NAV_YAML_QUERY_TOKEN_*\)
 * @property {char[]} value - The token value (identifier or number)
 */
struct _NAVYamlQueryToken {
    integer type
    char value[NAV_YAML_QUERY_MAX_IDENTIFIER_LENGTH]
}

/**
 * @struct _NAVYamlQueryStep
 * @private
 * @description Represents a single step in a query path.
 *
 * @property {integer} type - The step type (NAV_YAML_QUERY_STEP_*\)
 * @property {char[]} property - Property name (for PROPERTY steps)
 * @property {integer} index - Array index (for INDEX steps, 1-based user query, converted to 0-based internally)
 */
struct _NAVYamlQueryStep {
    integer type
    char property[NAV_YAML_QUERY_MAX_IDENTIFIER_LENGTH]
    integer index
}

/**
 * @struct _NAVYamlQuery
 * @private
 * @description Parsed query path structure.
 *
 * @property {_NAVYamlQueryStep[]} steps - Array of path steps
 * @property {integer} stepCount - Number of steps in the path
 * @property {char[]} error - Error message if query parsing failed
 */
struct _NAVYamlQuery {
    _NAVYamlQueryStep steps[NAV_YAML_QUERY_MAX_PATH_STEPS]
    integer stepCount
    char error[255]
}


#END_IF // __NAV_FOUNDATION_YAML_QUERY_H__
