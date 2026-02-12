PROGRAM_NAME='NAVFoundation.TomlQuery.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TOML_QUERY_H__
#DEFINE __NAV_FOUNDATION_TOML_QUERY_H__ 'NAVFoundation.TomlQuery.h'


DEFINE_CONSTANT

/**
 * @constant NAV_TOML_QUERY_MAX_TOKENS
 * @description Maximum number of tokens that can be produced by the query lexer.
 * Each component in a query path (dots, identifiers, brackets) requires one token.
 * Increase this value if working with very long query paths.
 * @default 50
 */
constant integer NAV_TOML_QUERY_MAX_TOKENS = 50

/**
 * @constant NAV_TOML_QUERY_MAX_IDENTIFIER_LENGTH
 * @description Maximum length of an identifier (property name) in a query path.
 * @default 128
 */
constant integer NAV_TOML_QUERY_MAX_IDENTIFIER_LENGTH = 128

/**
 * @constant NAV_TOML_QUERY_MAX_PATH_STEPS
 * @description Maximum number of path steps in a query.
 * Each navigation step (property access or array index) requires one path step.
 * @default 25
 */
constant integer NAV_TOML_QUERY_MAX_PATH_STEPS = 25

/**
 * @constant NAV_TOML_QUERY_TOKEN_DOT
 * @description Token type for the dot operator (.) in query syntax.
 * Used to access object properties.
 * @example .property
 */
constant integer NAV_TOML_QUERY_TOKEN_DOT = 1

/**
 * @constant NAV_TOML_QUERY_TOKEN_IDENTIFIER
 * @description Token type for identifiers (property names) in query syntax.
 * @example .name or .database.server
 */
constant integer NAV_TOML_QUERY_TOKEN_IDENTIFIER = 2

/**
 * @constant NAV_TOML_QUERY_TOKEN_LEFT_BRACKET
 * @description Token type for left bracket ([) in query syntax.
 * Used to begin array index access.
 * @example .[0]
 */
constant integer NAV_TOML_QUERY_TOKEN_LEFT_BRACKET = 3

/**
 * @constant NAV_TOML_QUERY_TOKEN_RIGHT_BRACKET
 * @description Token type for right bracket (]) in query syntax.
 * Used to end array index access.
 * @example .[0]
 */
constant integer NAV_TOML_QUERY_TOKEN_RIGHT_BRACKET = 4

/**
 * @constant NAV_TOML_QUERY_TOKEN_NUMBER
 * @description Token type for numeric array indices in query syntax.
 * @example .[2] or .[15]
 */
constant integer NAV_TOML_QUERY_TOKEN_NUMBER = 5

/**
 * @constant NAV_TOML_QUERY_STEP_ROOT
 * @description Path step type representing the root of the document.
 * Used when the query is just "." with no further navigation.
 * @example .
 */
constant integer NAV_TOML_QUERY_STEP_ROOT = 1

/**
 * @constant NAV_TOML_QUERY_STEP_PROPERTY
 * @description Path step type for table property access.
 * Navigates to a child property by key name.
 * @example .name or .database.server
 */
constant integer NAV_TOML_QUERY_STEP_PROPERTY = 2

/**
 * @constant NAV_TOML_QUERY_STEP_ARRAY_INDEX
 * @description Path step type for array element access by index.
 * Navigates to a specific array element (1-based in queries, 0-based internally).
 * @example .[1] or .items[3]
 */
constant integer NAV_TOML_QUERY_STEP_ARRAY_INDEX = 3


DEFINE_TYPE

/**
 * @struct _NAVTomlQueryToken
 * @description Represents a single token produced by the query lexer.
 * Used internally to parse JQ-like query syntax into executable steps.
 *
 * @property {integer} type - The token type (NAV_TOML_QUERY_TOKEN_*\)
 * @property {char[]} identifier - Property name for IDENTIFIER tokens
 * @property {integer} number - Array index for NUMBER tokens
 *
 * @example
 * // Query ".database.server" produces tokens:
 * // DOT, IDENTIFIER("database"), DOT, IDENTIFIER("server")
 */
struct _NAVTomlQueryToken {
    integer type
    char identifier[NAV_TOML_QUERY_MAX_IDENTIFIER_LENGTH]
    integer number
}

/**
 * @struct _NAVTomlQueryPathStep
 * @description Represents a single step in a query execution path.
 * Query tokens are parsed into path steps which are then executed against the TOML tree.
 *
 * @property {integer} type - The step type (NAV_TOML_QUERY_STEP_*\)
 * @property {char[]} propertyKey - Property name for PROPERTY steps
 * @property {integer} arrayIndex - Array index for ARRAY_INDEX steps (1-based in queries)
 *
 * @example
 * // Query ".database.ports[1]" produces path steps:
 * // PROPERTY("database"), PROPERTY("ports"), ARRAY_INDEX(1)
 */
struct _NAVTomlQueryPathStep {
    integer type
    char propertyKey[NAV_TOML_QUERY_MAX_IDENTIFIER_LENGTH]
    integer arrayIndex
}


#END_IF // __NAV_FOUNDATION_TOML_QUERY_H__
