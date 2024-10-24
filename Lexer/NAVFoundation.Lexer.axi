PROGRAM_NAME='NAVFoundation.Lexer'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_LEXER__
#DEFINE __NAV_FOUNDATION_LEXER__ 'NAVFoundation.Lexer'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'


DEFINE_CONSTANT

constant integer NAV_LEXER_SPEC_PATTERN = 1
constant integer NAV_LEXER_SPEC_TYPE    = 2


DEFINE_TYPE

struct _NAVLexer {
    char source[NAV_MAX_BUFFER * 2]
    long cursor

    char spec[255][2][100]
}


struct _NAVLexerToken {
    char type[50]
    char value[255]
}


define_function char NAVLexerInit(_NAVLexer lexer, char source[], char spec[][][]) {
    if (!length_array(source)) {
        return false
    }

    if (!length_array(spec)) {
        return false
    }

    lexer.source = source
    lexer.cursor = 0

    lexer.spec = spec
    set_length_array(lexer.spec, length_array(spec))

    return true
}


define_function char NAVLexerIsEOF(_NAVLexer lexer) {
    return lexer.cursor == length_array(lexer.source)
}


define_function char NAVLexerHasMoreTokens(_NAVLexer lexer) {
    return lexer.cursor < length_array(lexer.source)
}


define_function char NAVLexerGetNextToken(_NAVLexer lexer, _NAVLexerToken token) {
    stack_var char source[NAV_MAX_BUFFER]
    stack_var integer x

    if (!NAVLexerHasMoreTokens(lexer)) {
        return false
    }

    source = NAVStringSlice(lexer.source, type_cast(lexer.cursor), 0)

    for (x = 1; x <= length_array(lexer.spec); x++) {
        stack_var char pattern[255]
        stack_var char value[255]

        pattern = lexer.spec[x][NAV_LEXER_SPEC_PATTERN]
        value = NAVLexerMatchPattern(lexer, pattern, source)

        if (!length_array(value)) {
            continue
        }

        if (lexer.spec[x][NAV_LEXER_SPEC_TYPE] == 'NULL') {
            return NAVLexerGetNextToken(lexer, token)
        }

        token.type = lexer.spec[x][NAV_LEXER_SPEC_TYPE]
        token.value = value

        return true
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                __NAV_FOUNDATION_LEXER__,
                                'NAVLexerGetNextToken',
                                "'Unexepected token: "', itoa(NAVCharCodeAt(source, 1)), '"'")

    return false
}


define_function char[NAV_MAX_BUFFER] NAVLexerMatchPattern(_NAVLexer lexer, char pattern[], char source[]) {
    stack_var _NAVRegexMatchResult match

    if (!NAVRegexMatch(pattern, source, match)) {
        return ''
    }

    lexer.cursor = lexer.cursor + match.length
    return match.text
}


#END_IF // __NAV_FOUNDATION_LEXER__
