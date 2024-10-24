PROGRAM_NAME='NAVFoundation.IniParser'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

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


#IF_NOT_DEFINED __NAV_FOUNDATION_INI_PARSER__
#DEFINE __NAV_FOUNDATION_INI_PARSER__ 'NAVFoundation.IniParser'


#include 'NAVFoundation.IniParser.h.axi'


define_function char NAVIniParserInit(_NAVIniParser parser, char source[]) {
    parser.source = source

    NAVLexerInit(parser.lexer, source, NAV_INI_TOKEN_SPEC)
    NAVLexerGetNextToken(parser.lexer, parser.lookahead)

    return true
}


/**
 * Whether the token is a literal
 */
define_function char NAVIniParserTokenIsLiteral(_NAVLexerToken token) {
    return token.type == NAV_INI_TOKEN_TYPE_NUMBER || token.type == NAV_INI_TOKEN_TYPE_STRING
}


/**
 * Literal
 *  : NumericLiteral
 *  | StringLiteral
 *  ;
 */
define_function char NAVIniParserParseLiteral(_NAVIniParser parser) {
    switch (parser.lookahead.type) {
        case NAV_INI_TOKEN_TYPE_NUMBER: {
            return NAVIniParserParseNumericLiteral(parser, parser.lookahead)
        }
        case NAV_INI_TOKEN_TYPE_STRING: {
            return NAVIniParserParseStringLiteral(parser, parser.lookahead)
        }
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                __NAV_FOUNDATION_INI_PARSER__,
                                'NAVIniParserParseLiteral',
                                "'Unexpected literal production'")
    return false
}


/**
 * StringLiteral
 *  : STRING
 *  ;
 */
define_function char NAVIniParserParseStringLiteral(_NAVIniParser parser, _NAVLexerToken token) {
    return NAVIniParserConsumeToken(parser, NAV_INI_TOKEN_TYPE_STRING, token)
}


/**
 * NumericLiteral
 *  : NUMBER
 *  ;
 */
define_function char NAVIniParserParseNumericLiteral(_NAVIniParser parser, _NAVLexerToken token) {
    return NAVIniParserConsumeToken(parser, NAV_INI_TOKEN_TYPE_NUMBER, token)
}


/**
 * Expects a token of a given type and consumes it
 */
define_function char NAVIniParserConsumeToken(_NAVIniParser parser, char type[], _NAVLexerToken token) {
    #WARN 'Something could be wrong here'
    token = parser.lookahead

    if (token.type == 'NULL') {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INI_PARSER__,
                                    'NAVIniParserConsumeToken',
                                    "'Unexpected end of input, expected: "', type, '"'")
        return false
    }

    if (token.type != type) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_INI_PARSER__,
                                    'NAVIniParserConsumeToken',
                                    "'Unexpected token: "', token.value, '", expected: "', type, '"'")
        return false
    }

    // Advance to the next token
    NAVLexerGetNextToken(parser.lexer, parser.lookahead)

    return true
}


#END_IF // __NAV_FOUNDATION_INI_PARSER__
