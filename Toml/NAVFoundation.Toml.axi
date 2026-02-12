PROGRAM_NAME='NAVFoundation.Toml'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_TOML__
#DEFINE __NAV_FOUNDATION_TOML__ 'NAVFoundation.Toml'

#include 'NAVFoundation.TomlLexer.axi'
#include 'NAVFoundation.TomlParser.axi'
#include 'NAVFoundation.TomlQuery.axi'


/**
 * @function NAVTomlParse
 * @public
 * @description Parse a TOML string into a node tree structure.
 *
 * @param {char[]} source - The TOML string to parse
 * @param {_NAVToml} toml - Output parameter to receive the parsed structure
 *
 * @returns {char} True (1) if parsing succeeded, False (0) on error
 *
 * @example
 * stack_var _NAVToml toml
 * stack_var char source[1024]
 *
 * source = "
 * 'title = \"TOML Example\"',
 * '',
 * '[database]',
 * 'server = \"192.168.1.1\"',
 * 'ports = [8000, 8001, 8002]',
 * 'enabled = true'
 * "
 *
 * if (NAVTomlParse(source, toml)) {
 *     // Success - toml.rootIndex points to root table node
 *     // Navigate via toml.nodes[].firstChild and toml.nodes[].nextSibling
 *     // Or use query functions like NAVTomlQuery()
 * } else {
 *     // Error - check toml.error for details
 *     send_string 0, "'Parse error: ', toml.error"
 * }
 */
define_function char NAVTomlParse(char source[], _NAVToml toml) {
    stack_var _NAVTomlLexer lexer
    stack_var _NAVTomlParser parser

    // Initialize TOML structure
    toml.nodeCount = 0
    toml.rootIndex = 0
    toml.error = ''
    toml.errorLine = 0
    toml.errorColumn = 0
    toml.source = source

    // Tokenize the source
    if (!NAVTomlLexerTokenize(lexer, source)) {
        toml.error = lexer.error
        toml.errorLine = lexer.line
        toml.errorColumn = lexer.column
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_TOML__,
                                    'NAVTomlParse',
                                    "'Failed to tokenize source: ', lexer.error")
        return false
    }

    // Initialize parser
    NAVTomlParserInit(parser, lexer.tokens)

    // Parse the tokens into a tree
    if (!NAVTomlParserParse(parser, toml)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_TOML__,
                                    'NAVTomlParse',
                                    "'Failed to parse TOML: ', toml.error")
        return false
    }

    return true
}


#END_IF // __NAV_FOUNDATION_TOML__
