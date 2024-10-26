PROGRAM_NAME='NAVFoundation.Regex'

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

/**
 *  Largely based on the tiny-regex-c library
 *  https://github.com/kokke/tiny-regex-c
 *
 *  Adapted for use in NetLinx
 */


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX__
#DEFINE __NAV_FOUNDATION_REGEX__ 'NAVFoundation.Regex'


#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.h.axi'


define_function char NAVRegexTest(char buffer[], char pattern[]) {
    stack_var _NAVRegexParser parser
    stack_var _NAVRegexMatchResult match

    if (!NAVRegexCompile(pattern, parser)) {
        return false
    }

    return NAVRegexMatchCompiled(parser, buffer, match)
}


define_function char NAVRegexMatch(char pattern[], char buffer[], _NAVRegexMatchResult match) {
    stack_var _NAVRegexParser parser

    if (!NAVRegexCompile(pattern, parser)) {
        return false
    }

    if (NAVRegexMatchCompiled(parser, buffer, match)) {
        #WARN 'May need to move this to the NAVRegexMatchCompiled function'
        // May move this to the NAVRegexMatchCompiled function?
        // The below needs to be done if the MatchCompiled function
        // is used directly as well as the Match function.
        // So it probably make more sense to do it in the MatchCompiled function

        // match.matches[match.current].end = match.matches[match.current].start + match.matches[match.current].length
        NAVRegexMatchSetEnd(match, NAVRegexMatchGetEnd(match))
        // match.matches[match.current].text = NAVStringSlice(buffer, match.matches[match.current].start, match.matches[match.current].end)
        NAVRegexMatchSetText(match, NAVRegexMatchGetTextFromBuffer(match, buffer))

        match.count++
        match.current++

        // If global flag is set, continue matching after the current match
        // Maybe switch to a while loop here?
        // In this case we would need to return as array of matches
        // meaning the function signature would need to change
        // So perhaps a separate function for global matching?
        // However, the flag is set in the regex pattern, so it seems
        // silly to have to remember to use a different API. Maybe
        // instead the match result should always be an array of matches
        // with a count?

        return true
    }

    return false
}


define_function char NAVRegexMatchCompiled(_NAVRegexParser parser, char buffer[], _NAVRegexMatchResult match) {
    if (!NAVRegexMatchResultInit(match)) {
        return false
    }

    NAVRegexDebugSync(parser, match)

    NAVRegexMatchSetStart(match, 0)
    NAVRegexMatchSetLength(match, 0)

    NAVRegexParserSetInput(parser, buffer)

    if (parser.state[parser.pattern.cursor].type == REGEX_TYPE_BEGIN) {
        NAVRegexAdvancePatternCursor(parser, 1)

        if (NAVRegexMatchPattern(parser, match)) {
            // If we have a match following the "BEGIN" anchor,
            // we need to set the start position to 1
            NAVRegexMatchSetStart(match, 1)
            // NAVRegexMatchIncreaseStart(match, 1)
            // return (parser.input.cursor == parser.input.length)
            return (parser.input.cursor >= parser.input.length)
        }

        return false
    }

    while (true) {
        NAVRegexMatchIncreaseStart(match, 1)

        if (NAVRegexMatchPattern(parser, match)) {
            if (parser.input.cursor == parser.input.length) {
                return false
            }

            return true
        }

        // NAVRegexAdvanceInputCursor(parser, 1)

        if (parser.input.cursor <= parser.input.length) {
            continue
        }

        break
    }

    return false
}


define_function char NAVRegexCompile(char pattern[], _NAVRegexParser parser) {
    stack_var char c

    if (!NAVRegexParserInit(parser, pattern)) {
        return false
    }

    parser.pattern.cursor = 0

    while ((parser.pattern.cursor + 1) <= parser.pattern.length && ((parser.count + 1) < MAX_REGEXP_OBJECTS)) {
        c = NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1))

        switch (c) {
            case '^': { parser.state[(parser.count + 1)].type = REGEX_TYPE_BEGIN }
            case '$': { parser.state[(parser.count + 1)].type = REGEX_TYPE_END }
            case '.': { parser.state[(parser.count + 1)].type = REGEX_TYPE_DOT }

            // Quantifiers. Should these be handled differently?
            case '*': { parser.state[(parser.count + 1)].type = REGEX_TYPE_STAR }
            case '+': { parser.state[(parser.count + 1)].type = REGEX_TYPE_PLUS }
            case '?': { parser.state[(parser.count + 1)].type = REGEX_TYPE_QUESTIONMARK }

            case '|': { parser.state[(parser.count + 1)].type = REGEX_TYPE_BRANCH }  // Not working properly

            case '\': {
                if ((parser.pattern.cursor + 2) <= parser.pattern.length) {
                    parser.pattern.cursor++

                    switch (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1))) {
                        case 'b': { parser.state[(parser.count + 1)].type = REGEX_TYPE_WORD_BOUNDARY }      // Not implemented
                        case 'B': { parser.state[(parser.count + 1)].type = REGEX_TYPE_NOT_WORD_BOUNDARY }  // Not implemented
                        case 'd': { parser.state[(parser.count + 1)].type = REGEX_TYPE_DIGIT }
                        case 'D': { parser.state[(parser.count + 1)].type = REGEX_TYPE_NOT_DIGIT }
                        case 'w': { parser.state[(parser.count + 1)].type = REGEX_TYPE_ALPHA }
                        case 'W': { parser.state[(parser.count + 1)].type = REGEX_TYPE_NOT_ALPHA }
                        case 's': { parser.state[(parser.count + 1)].type = REGEX_TYPE_WHITESPACE }
                        case 'S': { parser.state[(parser.count + 1)].type = REGEX_TYPE_NOT_WHITESPACE }
                        case 'x': { parser.state[(parser.count + 1)].type = REGEX_TYPE_HEX }                // Not implemented
                        case 'n': { parser.state[(parser.count + 1)].type = REGEX_TYPE_NEWLINE }            // Not implemented
                        case 'r': { parser.state[(parser.count + 1)].type = REGEX_TYPE_RETURN }             // Not implemented
                        case 't': { parser.state[(parser.count + 1)].type = REGEX_TYPE_TAB }                // Not implemented
                        default: {
                            parser.state[(parser.count + 1)].type = REGEX_TYPE_CHAR
                            parser.state[(parser.count + 1)].value = NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1))
                        }
                    }
                }
            }

            case '{': { return false } // Not implemented
            case '(': { return false } // Not implemented
            case '[': {
                stack_var char charclass[MAX_CHAR_CLASS_LENGTH]
                stack_var integer length

                length = 0

                // Lookahead to see if this is a negated character class first
                if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 2)) == '^') {
                    parser.state[(parser.count + 1)].type = REGEX_TYPE_INV_CHAR_CLASS

                    parser.pattern.cursor++

                    if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 2)) == 0) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX__,
                                                    'NAVRegexCompile',
                                                    "'Incomplete pattern. Missing non-zero character after ^'")

                        return false
                    }
                }
                else {
                    parser.state[(parser.count + 1)].type = REGEX_TYPE_CHAR_CLASS
                }

                parser.pattern.cursor++

                while ((NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1)) != ']') &&
                        ((parser.pattern.cursor + 1) <= parser.pattern.length)) {
                    stack_var char code

                    code = NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1))

                    if (code == '\') {
                        if (length > (MAX_CHAR_CLASS_LENGTH - 1)) {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                        __NAV_FOUNDATION_REGEX__,
                                                        'NAVRegexCompile',
                                                        "'Character class exceeded maximum length'")
                            return false
                        }

                        if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 2)) == 0) {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                        __NAV_FOUNDATION_REGEX__,
                                                        'NAVRegexCompile',
                                                        "'Incomplete pattern. Missing non-zero character after \'")
                            return false
                        }

                        charclass = "charclass, code"
                        parser.pattern.cursor++
                    }
                    else if (length > MAX_CHAR_CLASS_LENGTH) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX__,
                                                    'NAVRegexCompile',
                                                    "'Character class exceeded maximum length'")
                        return false
                    }

                    charclass = "charclass, code"
                    length = length_array(charclass)
                    parser.pattern.cursor++
                }

                if (length > MAX_CHAR_CLASS_LENGTH) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Character class exceeded maximum length'")
                    return false
                }

                parser.state[(parser.count + 1)].charclass.value = charclass
                parser.state[(parser.count + 1)].charclass.length = length
                set_length_array(parser.state[(parser.count + 1)].charclass.value, length)
            }

            default: {
                parser.state[(parser.count + 1)].type = REGEX_TYPE_CHAR
                parser.state[(parser.count + 1)].value = c
            }
        }

        parser.pattern.cursor++
        parser.count++
    }

    parser.state[(parser.count + 1)].type = REGEX_TYPE_UNUSED
    set_length_array(parser.state, (parser.count + 1))

    // Reset the pattern cursor
    parser.pattern.cursor = 1

    return true
}


define_function NAVRegexPrintState(_NAVRegexParser parser) {
    stack_var integer i
    stack_var integer j
    stack_var char c
    stack_var char message[255]

    if (parser.count <= 0) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '[]')
        return
    }

    message = ''

    for (i = 0; i < parser.count; i++) {
        if (parser.state[(i + 1)].type == REGEX_TYPE_UNUSED) {
            break
        }

        message = "message, ' ', REGEX_TYPES[parser.state[(i + 1)].type]"

        if (parser.state[(i + 1)].type == REGEX_TYPE_CHAR_CLASS || parser.state[(i + 1)].type == REGEX_TYPE_INV_CHAR_CLASS) {
            message = "message, ' ['"

            for (j = 0; j < parser.state[(i + 1)].charclass.length; j++) {
                c = NAVCharCodeAt(parser.state[(i + 1)].charclass.value, (j + 1))

                if ((c == 0) || (c == ']')) {
                    break
                }

                message = "message, c"
            }

            message = "message, ']'"
        }
        else if (parser.state[(i + 1)].type == REGEX_TYPE_CHAR) {
            message = "message, ' "', parser.state[(i + 1)].value, '"'"
        }

        if (i < (parser.count - 1)) {
            message = "message, ','"
        }
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'[ ', message, ' ]'")
}


define_function char NAVRegexMatchDigit(char c) {
    return NAVIsDigit(c)
}


define_function char NAVRegexMatchAlpha(char c) {
    return NAVIsAlpha(c)
}


define_function char NAVRegexMatchWhitespace(char c) {
    return NAVIsWhitespace(c)
}


define_function char NAVRegexMatchAlphaNumeric(char c) {
    return NAVIsAlphaNumeric(c)
}


define_function char NAVRegexMatchEpsilon(char c) {
    return (c == '' || c == 0)
}


define_function char NAVRegexMatchWordBoundary(_NAVRegexParser parser) {
    // How do you match a word boundary?
    // A word boundary is a position in the string where a word character is not followed or preceded by another word-character.
}


define_function char NAVRegexMatchHex(_NAVRegexParser parser) {
    // How do you match a hex character?
    // A hex character is a character in the range 0-9, A-F, a-f
}


define_function char NAVRegexMatchDot(char c) {
    // Check parser options for global and multiline flags?
    return (c != NAV_CR && c != NAV_LF)
}


define_function char NAVRegexIsMetaChar(char c) {
    return (
        (c == 's') ||
        (c == 'S') ||
        (c == 'w') ||
        (c == 'W') ||
        (c == 'd') ||
        (c == 'D') ||
        (c == 'x')
    )
}


define_function char NAVRegexIsAnchorChar(char c) {
    return (
        (c == '^') ||
        (c == '$') ||
        (c == 'b') ||
        (c == 'B')
    )
}


define_function char NAVRegexIsGeneralChar(char c) {
    return (
        (c == 'n') ||
        (c == 'r') ||
        (c == 't')
    )
}


define_function char NAVRegexMatchMetaChar(char c, char buffer[]) {
    switch (NAVCharCodeAt(buffer, 1)) {
        // case 'b':   { return  NAVRegexMatchBackspace(c) }
        case 'd':   { return  NAVRegexMatchDigit(c) }
        case 'D':   { return !NAVRegexMatchDigit(c) }
        case 'w':   { return  NAVRegexMatchAlphaNumeric(c) }
        case 'W':   { return !NAVRegexMatchAlphaNumeric(c) }
        case 's':   { return  NAVRegexMatchWhitespace(c) }
        case 'S':   { return !NAVRegexMatchWhitespace(c) }
        // case 'x':   { return  NAVRegexMatchHex(c) }
        default:    { return (c == NAVCharCodeAt(buffer, 1)) }
    }
}


define_function char NAVRegexMatchRange(_NAVRegexParser parser) {
    stack_var char charclass[MAX_CHAR_CLASS_LENGTH]
    stack_var integer cursor
    stack_var char c

    charclass = parser.state[parser.pattern.cursor].charclass.value
    cursor = parser.state[parser.pattern.cursor].charclass.cursor
    c = NAVCharCodeAt(parser.input.value, parser.input.cursor)

    return (
        (c != '-') &&
        (NAVCharCodeAt(charclass, cursor) != 0) &&
        (NAVCharCodeAt(charclass, cursor) != '-') &&
        (NAVCharCodeAt(charclass, cursor + 1) == '-') &&
        (NAVCharCodeAt(charclass, cursor + 2) != 0) &&
        ((c >= NAVCharCodeAt(charclass, cursor)) &&
            (c <= NAVCharCodeAt(charclass, cursor + 2)))
    )
}



define_function char NAVRegexMatchCharClass(_NAVRegexParser parser) {
    stack_var integer length
    stack_var char charclass[MAX_CHAR_CLASS_LENGTH]
    stack_var char c

    charclass = parser.state[parser.pattern.cursor].charclass.value
    length = parser.state[parser.pattern.cursor].charclass.length

    if (!length) {
        return false
    }

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchCharClass: Matching character class => "', charclass, '"'")
    }

    NAVRegexSetPatternCharClassCursor(parser, 1)

    while (true) {
        c = NAVCharCodeAt(parser.input.value, parser.input.cursor)

        if (NAVRegexMatchRange(parser)) {
            if (NAVRegexParserDebug(parser)) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchCharClass: Matched range'")
            }

            return true
        }

        if (NAVCharCodeAt(charclass, parser.state[parser.pattern.cursor].charclass.cursor) == '\') {
            if (NAVRegexParserDebug(parser)) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchCharClass: Escaped character'")
            }

            NAVRegexAdvancePatternCharClassCursor(parser, 1)

            if (NAVRegexMatchMetaChar(c, charclass)) {
                if (NAVRegexParserDebug(parser)) {
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchCharClass: Matched meta character "\', c, '"'")
                }

                return true
            }

            if ((NAVCharCodeAt(charclass, parser.state[parser.pattern.cursor].charclass.cursor) == c) && !NAVRegexIsMetaChar(c)) {
                if (NAVRegexParserDebug(parser)) {
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchCharClass: Yes. Matched character => "', c, '"'")
                }

                return true
            }
        }

        if (NAVCharCodeAt(charclass, parser.state[parser.pattern.cursor].charclass.cursor) == c) {
            if (NAVRegexParserDebug(parser)) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchCharClass: Yes. Matched character => "', c, '"'")
            }

            if (c == '-') {
                return ((parser.state[parser.pattern.cursor].charclass.cursor - 1) == length) ||
                        ((parser.state[parser.pattern.cursor].charclass.cursor + 1) == length)
            }

            return true
        }

        NAVRegexAdvancePatternCharClassCursor(parser, 1)

        if (parser.state[parser.pattern.cursor].charclass.cursor <= length) {
            continue
        }

        break
    }

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchCharClass: No. It doesn`t match'")
    }

    return false
}


define_function char NAVRegexMatchOne(_NAVRegexParser parser) {
    stack_var integer type
    stack_var char value
    stack_var char c

    if (parser.input.cursor > parser.input.length) {
        return false
    }

    if (parser.pattern.cursor > parser.count) {
        return false
    }

    type = parser.state[parser.pattern.cursor].type
    value = parser.state[parser.pattern.cursor].value

    c = NAVCharCodeAt(parser.input.value, parser.input.cursor)

    if (!c) {
        return false
    }

    switch (type) {
        case REGEX_TYPE_DOT:                { return  NAVRegexMatchDot(c) }
        case REGEX_TYPE_CHAR_CLASS:         { return  NAVRegexMatchCharClass(parser) }
        case REGEX_TYPE_INV_CHAR_CLASS:     { return !NAVRegexMatchCharClass(parser) }
        case REGEX_TYPE_DIGIT:              { return  NAVRegexMatchDigit(c) }
        case REGEX_TYPE_NOT_DIGIT:          { return !NAVRegexMatchDigit(c) }
        case REGEX_TYPE_ALPHA:              { return  NAVRegexMatchAlphaNumeric(c) }
        case REGEX_TYPE_NOT_ALPHA:          { return !NAVRegexMatchAlphaNumeric(c) }
        case REGEX_TYPE_WHITESPACE:         { return  NAVRegexMatchWhitespace(c) }
        case REGEX_TYPE_NOT_WHITESPACE:     { return !NAVRegexMatchWhitespace(c) }
        case REGEX_TYPE_WORD_BOUNDARY:      { return  NAVRegexMatchWordBoundary(parser) }
        case REGEX_TYPE_NOT_WORD_BOUNDARY:  { return !NAVRegexMatchWordBoundary(parser) }
        case REGEX_TYPE_HEX:                { return  NAVRegexMatchHex(parser) }
    }

    return (value == c)
}


define_function char NAVRegexMatchStar(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    // * matches the previous token between zero and unlimited times, as many times as possible, giving back as needed (greedy)
    stack_var integer prelength
    stack_var integer precursor
    stack_var integer count

    prelength = NAVRegexMatchGetLength(match)
    precursor = parser.input.cursor

    while (NAVRegexMatchOne(parser)) {
        if (NAVRegexParserDebug(parser)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchStar: Yes. Matched 1 character => "',
                    NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")
        }

        count++
        NAVRegexAdvanceInputCursor(parser, 1)
    }

    NAVRegexMatchIncreaseLength(match, count)

    // Once we have matched the current pattern, we advance the pattern cursor by 2, to skip the '*' character
    NAVRegexAdvancePatternCursor(parser, 2)

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchStar: Total Matched ', itoa(count)")
    }

    while (parser.input.cursor >= precursor) {
        if (NAVRegexMatchPattern(parser, match)) {
            return true
        }

        NAVRegexMatchDecreaseLength(match, 1)
        NAVRegexBacktrackInputCursor(parser, 1)
    }

    // Try to match epsilon?
    if (NAVRegexMatchEpsilon(NAVCharCodeAt(parser.input.value, parser.input.cursor))) {
        return true
    }

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchStar: No. It doesn`t match'")
    }

    NAVRegexMatchSetLength(match, prelength)

    return false
}


define_function char NAVRegexMatchPlus(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    // + matches the previous token between one and unlimited times, as many times as possible, giving back as needed (greedy)
    stack_var integer precursor
    stack_var integer count

    precursor = parser.input.cursor

    while (NAVRegexMatchOne(parser)) {
        if (NAVRegexParserDebug(parser)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchPlus: Yes. Matched 1 character => "',
                    NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")
        }

        count++
        NAVRegexAdvanceInputCursor(parser, 1)
    }

    NAVRegexMatchIncreaseLength(match, count)

    // Once we have matched the current pattern, we advance the pattern cursor by 2, to skip the '+' character
    NAVRegexAdvancePatternCursor(parser, 2)

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchPlus: Total Matched ', itoa(count)")
    }

    while (parser.input.cursor > precursor) {
        if (NAVRegexMatchPattern(parser, match)) {
            return true
        }

        NAVRegexMatchDecreaseLength(match, 1)
        NAVRegexBacktrackInputCursor(parser, 1)
    }

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchPlus: No. It doesn`t match'")
    }

    return false
}


define_function char NAVRegexMatchQuestion(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    // ? matches the previous token between zero and one times, as many times as possible, giving back as needed (greedy)
    stack_var integer precursor

    precursor = NAVRegexGetPatternCursor(parser)

    if (parser.state[parser.pattern.cursor].type == REGEX_TYPE_UNUSED) {
        if (NAVRegexParserDebug(parser)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, 'NAVRegexMatchQuestion: There is nothing left to match')
        }

        return true
    }

    // First, we increases the pattern cursor by 2 to skip the '?' character
    // and then try to match again. This is being greedy
    NAVRegexAdvancePatternCursor(parser, 2)
    if (NAVRegexMatchPattern(parser, match)) {
        return true
    }

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchQuestion: No more greedy matches'")
    }

    // If we didn't return true, we backtrack the pattern cursor to the precursor
    // And then try to match the current pattern one time
    NAVRegexSetPatternCursor(parser, precursor)

    if (NAVRegexMatchOne(parser)) {
        if (NAVRegexParserDebug(parser)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchQuestion: Yes. Matched 1 character => "',
                    NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")
        }

        NAVRegexAdvanceInputCursor(parser, 1)
        NAVRegexAdvancePatternCursor(parser, 2)

        if (NAVRegexMatchPattern(parser, match)) {
            NAVRegexMatchIncreaseLength(match, 1)
            return true
        }
    }

    // Try to match epsilon?
    if (NAVRegexMatchEpsilon(NAVCharCodeAt(parser.input.value, parser.input.cursor))) {
        return true
    }

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchQuestion: No. It doesn`t match'")
    }

    return false


    //////////////////////////////////////////////////////////////////////
    // This is working, but it's not quite right. It's not being greedy
    //////////////////////////////////////////////////////////////////////
    // // We try to match the current pattern first
    // // If that succeeds, we consume the character and increase the match length
    // if (NAVRegexMatchOne(parser)) {
    //     #IF_DEFINED REGEX_DEBUG
    //     NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchQuestion: Matched 1 character => "',
    //             NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")
    //     #END_IF

    //     NAVRegexAdvanceInputCursor(parser, 1)
    //     NAVRegexMatchIncreaseLength(match, 1)
    // }

    // // If the current pattern does not match, we advance the pattern cursor by 2
    // // and try to match the next pattern
    // #IF_DEFINED REGEX_DEBUG
    // NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchQuestion: No match => Advance pattern cursor by 2 and continue'")
    // #END_IF

    // NAVRegexAdvancePatternCursor(parser, 2)

    // return NAVRegexMatchPattern(parser, match)
}


define_function char NAVRegexMatchPattern(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    stack_var integer prelength
    stack_var integer precursor

    prelength = NAVRegexMatchGetLength(match)
    precursor = NAVRegexGetPatternCursor(parser)

    while (true) {
        NAVRegexPrintCurrentState(parser)

        select {
            active (parser.state[parser.pattern.cursor].type == REGEX_TYPE_UNUSED ||
                    parser.state[(parser.pattern.cursor + 1)].type == REGEX_TYPE_QUESTIONMARK): {
                return NAVRegexMatchQuestion(parser, match)
            }
            active (parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_STAR): {
                return NAVRegexMatchStar(parser, match)
            }
            active (parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_PLUS): {
                return NAVRegexMatchPlus(parser, match)
            }
            active (parser.state[parser.pattern.cursor].type == REGEX_TYPE_END &&
                    parser.state[(parser.pattern.cursor + 1)].type == REGEX_TYPE_UNUSED): {
                // return (parser.input.cursor == parser.input.length)
                return (parser.input.cursor >= parser.input.length)
            }
            // Branching is not working properly
            // active (parser.state[x].type == REGEX_TYPE_BRANCH): {
            //     return (NAVRegexMatchPattern(parser.state, buffer, matchLength) || NAVRegexMatchPattern(parser.state[(x + 1)], buffer, matchLength))
            // }
        }

        // NAVRegexMatchIncreaseLength(match, 1)
        // NAVRegexAdvanceInputCursor(parser, 1)
        // NAVRegexAdvancePatternCursor(parser, 1)

        if (NAVRegexMatchOne(parser)) {
            if (NAVRegexParserDebug(parser)) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchPattern: Yes. Matched 1 character => "',
                        NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")
            }

            NAVRegexMatchIncreaseLength(match, 1)
            NAVRegexAdvanceInputCursor(parser, 1)
            NAVRegexAdvancePatternCursor(parser, 1)

            continue
        }

        break
    }

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVRegexMatchPattern: No. It doesn`t match'")
    }

    NAVRegexMatchSetLength(match, prelength)
    NAVRegexSetPatternCursor(parser, precursor)

    return false
}


define_function char NAVRegexParserInit(_NAVRegexParser parser, char pattern[]) {
    parser.pattern.value = NAVStringBetweenGreedy(NAVTrimString(pattern), '/', '/')

    if (!length_array(parser.pattern.value)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexParserInit',
                                    "'Failed to extract pattern from input'")

        return false
    }

    parser.pattern.length = length_array(parser.pattern.value)
    NAVRegexSetPatternCursor(parser, 1)

    if (!NAVRegexParserParseOptions(parser, pattern)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexParserInit',
                                    "'Failed to parse options'")

        return false
    }

    parser.input.value = ''
    parser.input.length = 0
    NAVRegexSetInputCursor(parser, 1)

    parser.count = 0

    parser.groups.count = 0
    parser.groups.current = 0

    return true
}


define_function char NAVRegexParserParseOptions(_NAVRegexParser parser, char pattern[]) {
    stack_var char options[5]
    stack_var integer length
    stack_var integer x

    if (NAVStringEndsWith(pattern, '/')) {
        // No options to parse
        return true
    }

    options = NAVStringSlice(pattern, (parser.pattern.length + 2), 0)

    length = length_array(options)
    if (!length) {
        return false
    }

    parser.options.value = options

    for (x = 1; x <= length; x++) {
        stack_var char c

        c = NAVCharCodeAt(options, x)

        switch (c) {
            case 'i': { parser.options.case_insensitive = true }        // Not implemented
            case 'g': { parser.options.global = true }                  // Not implemented
            case 'm': { parser.options.multiline = true }               // Not implemented

            // Unrecognised/unsupported option
            // Perhaps we shouldn't fail the entire operation if we encounter an unknown option
            // Just log a warning, ignore it and continue
            default: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                            __NAV_FOUNDATION_REGEX__,
                                            'NAVRegexParserParseOptions',
                                            "'Unrecognised option => ', c")
            }
        }
    }

    return true
}


define_function NAVRegexParserSetInput(_NAVRegexParser parser, char buffer[]) {
    parser.input.value = buffer
    parser.input.length = length_array(buffer)
}



/******************************************************************************
 * Helper functions
 *****************************************************************************/

define_function NAVRegexSetInputCursor(_NAVRegexParser parser, integer cursor) {
    if (cursor < 1) {
        cursor = 1
    }

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Setting input cursor to position => ', itoa(cursor)")
    }

    parser.input.cursor = cursor
}


define_function NAVRegexSetPatternCursor(_NAVRegexParser parser, integer cursor) {
    if (cursor < 1) {
        cursor = 1
    }

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Setting pattern cursor to position => ', itoa(cursor)")
    }

    parser.pattern.cursor = cursor
}


define_function NAVRegexSetPatternCharClassCursor(_NAVRegexParser parser, integer cursor) {
    if (cursor < 1) {
        cursor = 1
    }

    if (NAVRegexParserDebug(parser)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Setting pattern charclass cursor to position => ', itoa(cursor)")
    }

    parser.state[parser.pattern.cursor].charclass.cursor = cursor
}


define_function NAVRegexAdvanceInputCursor(_NAVRegexParser parser, integer count) {
    NAVRegexSetInputCursor(parser, (parser.input.cursor + count))
}


define_function NAVRegexAdvancePatternCursor(_NAVRegexParser parser, integer count) {
    NAVRegexSetPatternCursor(parser, (parser.pattern.cursor + count))
}


define_function NAVRegexAdvancePatternCharClassCursor(_NAVRegexParser parser, integer count) {
    NAVRegexSetPatternCharClassCursor(parser, (parser.state[parser.pattern.cursor].charclass.cursor + count))
}


define_function NAVRegexBacktrackInputCursor(_NAVRegexParser parser, integer count) {
    NAVRegexSetInputCursor(parser, (parser.input.cursor - count))
}


define_function NAVRegexBacktrackPatternCursor(_NAVRegexParser parser, integer count) {
    NAVRegexSetPatternCursor(parser, (parser.pattern.cursor - count))
}


define_function NAVRegexBacktrackPatternCharClassCursor(_NAVRegexParser parser, integer count) {
    NAVRegexSetPatternCharClassCursor(parser, (parser.state[parser.pattern.cursor].charclass.cursor - count))
}


define_function integer NAVRegexGetInputCursor(_NAVRegexParser parser) {
    return parser.input.cursor
}


define_function integer NAVRegexGetPatternCursor(_NAVRegexParser parser) {
    return parser.pattern.cursor
}


define_function integer NAVRegexGetPatternCharClassCursor(_NAVRegexParser parser) {
    return parser.state[parser.pattern.cursor].charclass.cursor
}


define_function char NAVRegexMatchResultInit(_NAVRegexMatchResult match) {
    match.count = 0
    match.current = 1

    return true
}


define_function NAVRegexMatchSetLength(_NAVRegexMatchResult match, integer length) {
    if (NAVRegexMatchDebug(match)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Setting match length to => ', itoa(length)")
    }

    match.matches[match.current].length = length
}


define_function NAVRegexMatchIncreaseLength(_NAVRegexMatchResult match, integer count) {
    NAVRegexMatchSetLength(match, match.matches[match.current].length + count)
}


define_function NAVRegexMatchDecreaseLength(_NAVRegexMatchResult match, integer count) {
    NAVRegexMatchSetLength(match, match.matches[match.current].length - count)
}


define_function integer NAVRegexMatchGetLength(_NAVRegexMatchResult match) {
    return match.matches[match.current].length
}


define_function NAVRegexMatchSetStart(_NAVRegexMatchResult match, integer start) {
    if (NAVRegexMatchDebug(match)) {
        #IF_DEFINED REGEX_DEBUG
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Setting match start to => ', itoa(start)")
        #END_IF
    }

    match.matches[match.current].start = start
}


define_function NAVRegexMatchIncreaseStart(_NAVRegexMatchResult match, integer count) {
    NAVRegexMatchSetStart(match, match.matches[match.current].start + count)
}


define_function NAVRegexMatchDecreaseStart(_NAVRegexMatchResult match, integer count) {
    NAVRegexMatchSetStart(match, match.matches[match.current].start - count)
}


define_function integer NAVRegexMatchGetStart(_NAVRegexMatchResult match) {
    return match.matches[match.current].start
}


define_function integer NAVRegexMatchGetEnd(_NAVRegexMatchResult match) {
    return NAVRegexMatchGetStart(match) + NAVRegexMatchGetLength(match)
}


define_function NAVRegexMatchSetEnd(_NAVRegexMatchResult match, integer end) {
    if (NAVRegexMatchDebug(match)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Setting match end to => ', itoa(end)")
    }

    match.matches[match.current].end = end
}


define_function char[NAV_MAX_BUFFER] NAVRegexMatchGetTextFromBuffer(_NAVRegexMatchResult match, char buffer[]) {
    return NAVStringSlice(buffer, NAVRegexMatchGetStart(match), NAVRegexMatchGetEnd(match))
}


define_function char[NAV_MAX_BUFFER] NAVRegexMatchGetTextFromParser(_NAVRegexMatchResult match, _NAVRegexParser parser) {
    return NAVStringSlice(parser.input.value, NAVRegexMatchGetStart(match), NAVRegexMatchGetEnd(match))
}


define_function NAVRegexMatchSetText(_NAVRegexMatchResult match, char text[]) {
    if (NAVRegexMatchDebug(match)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Setting match text to => "', text, '"'")
    }

    match.matches[match.current].text = text
}


define_function char NAVRegexParserDebug(_NAVRegexParser parser) {
    return parser.debug
}


define_function char NAVRegexMatchDebug(_NAVRegexMatchResult match) {
    return match.debug
}


define_function NAVRegexDebugSync(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    if (!parser.debug && !match.debug) {
        return
    }

    parser.debug = true
    match.debug = true
}


// define_function NAVRegexDebug()


define_function NAVRegexPrintCurrentState(_NAVRegexParser parser) {
    stack_var char c
    stack_var integer type
    stack_var char pattern[50]

    if(!NAVRegexParserDebug(parser)) {
        return
    }

    if (parser.pattern.cursor > parser.count) {
        return
    }

    if (parser.input.cursor > parser.input.length) {
        return
    }

    c = NAVCharCodeAt(parser.input.value, parser.input.cursor)
    // if (!c) {
    //     return
    // }

    type = parser.state[parser.pattern.cursor].type

    // if (!type || type == REGEX_TYPE_UNUSED) {
    //     return
    // }
    if (!type) {
        return
    }

    // NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Current state type: ', itoa(type)")

    switch (type) {
        case REGEX_TYPE_CHAR:           { pattern = "parser.state[parser.pattern.cursor].value" }
        case REGEX_TYPE_CHAR_CLASS:     { pattern = parser.state[parser.pattern.cursor].charclass.value }
        default:                        { pattern = REGEX_TYPES[type] }
    }

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Current state => Does "', c, '" match "', pattern, '"?'")
}


// define_function integer NAVRegexGetCurrentGroup(_NAVRegexParser parser) {
//     return parser.CurrentGroup
// }


// define_function integer NAVRegexGetCurrentState(_NAVRegexParser parser) {
//     return parser.StateCount[NAVRegexGetCurrentGroup(parser)]
// }


// define_function integer NAVRegexGetLastState(_NAVRegexParser parser) {
//     return parser.StateCount[NAVRegexGetCurrentGroup(parser)]
// }


// define_function NAVRegexCopyState(_NAVRegexState source, _NAVRegexState destination) {
//     // stack_var integer x

//     destination.Type = source.Type
//     destination.Quantifier = source.Quantifier
//     destination.Value = source.Value

//     // for (x = 1; x <= length_array(source.GroupState); x++) {
//     //     destination.GroupState[x] = source.GroupState[x]
//     // }
// }


// // define_function NAVRegexCopyStateToGroupState(_NAVRegexState source, _NAVRegexGroupState destination) {
// //     stack_var integer x

// //     destination.Type = source.Type
// //     destination.Quantifier = source.Quantifier
// //     destination.Value = source.Value

// //     for (x = 1; x <= length_array(source.GroupState); x++) {
// //         destination.GroupState[x] = source.GroupState[x]
// //     }
// // }


// define_function NAVRegexCopyStateArray(_NAVRegexState source[], _NAVRegexState destination[]) {
//     stack_var integer x
//     stack_var integer length

//     length = length_array(source)

//     for (x = 1; x <= length; x++) {
//         NAVRegexCopyState(source[x], destination[x])
//     }
// }


// // define_function NAVRegexCopyStateToGroupStateArray(_NAVRegexState source[], _NAVRegexGroupState destination[]) {
// //     stack_var integer x
// //     stack_var integer length

// //     length = length_array(source)

// //     for (x = 1; x <= length; x++) {
// //         NAVRegexCopyState(source[x], type_cast(destination[x]))
// //     }
// // }


// define_function sinteger NAVRegexParse(_NAVRegexParser parser, char pattern[]) {
//     stack_var integer x
//     stack_var integer next

//     stack_var integer group
//     stack_var integer state
//     stack_var integer lastState

//     NAVRegexParserInit(parser)

//     x = 1

//     while (x <= length_array(pattern)) {
//         next = pattern[x]

//         group = NAVRegexGetCurrentGroup(parser)

//         switch (next) {
//             case '^': {
//                 parser.StateCount[group]++

//                 state = NAVRegexGetCurrentState(parser)
//                 parser.State[group][state].Type = NAV_REGEX_TYPE_START_OF_STRING

//                 x++
//                 continue
//             }
//             case '$': {
//                 parser.StateCount[group]++

//                 state = NAVRegexGetCurrentState(parser)
//                 parser.State[group][state].Type = NAV_REGEX_TYPE_END_OF_STRING

//                 x++
//                 continue
//             }
//             case '.': {
//                 parser.StateCount[group]++

//                 state = NAVRegexGetCurrentState(parser)
//                 parser.State[group][state].Type = NAV_REGEX_TYPE_WILDCARD
//                 parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

//                 x++
//                 continue
//             }

//             case '?': {
//                 state = NAVRegexGetLastState(parser)

//                 if (!state || parser.State[group][state].Quantifier != NAV_REGEX_QUANTIFIER_EXACTLY_ONE) {
//                     return NAV_REGEX_ERROR_INVALID_QUANTIFIER
//                 }

//                 parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_ZERO_OR_ONE

//                 x++
//                 continue
//             }

//             case '*': {
//                 state = NAVRegexGetLastState(parser)

//                 if (!state || parser.State[group][state].Quantifier != NAV_REGEX_QUANTIFIER_EXACTLY_ONE) {
//                     return NAV_REGEX_ERROR_INVALID_QUANTIFIER
//                 }

//                 parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_ZERO_OR_MORE

//                 x++
//                 continue
//             }

//             case '+': {
//                 state = NAVRegexGetLastState(parser)

//                 if (!state || parser.State[group][state].Quantifier != NAV_REGEX_QUANTIFIER_EXACTLY_ONE) {
//                     return NAV_REGEX_ERROR_INVALID_QUANTIFIER
//                 }

//                 if (true) {
//                     stack_var _NAVRegexState newState

//                     NAVRegexCopyState(parser.State[group][state], newState)
//                     newState.Quantifier = NAV_REGEX_QUANTIFIER_ZERO_OR_MORE

//                     parser.StateCount[group]++
//                     state = NAVRegexGetCurrentState(parser)
//                     NAVRegexCopyState(newState, parser.State[group][state])

//                     x++
//                 }

//                 continue
//             }

//             case '(': {
//                 // parser.StateCount[group]++

//                 // state = NAVRegexGetCurrentState(parser)
//                 // parser.State[group][state].Type = NAV_REGEX_TYPE_GROUP

//                 parser.GroupCount++
//                 parser.CurrentGroup = parser.GroupCount

//                 x++
//                 continue
//             }

//             case ')': {
//                 if (parser.StateCount[group] < 1) {
//                     return -1
//                 }

//                 if (true) {
//                     stack_var _NAVRegexState states[NAV_REGEX_MAX_STATES]

//                     NAVRegexCopyStateArray(parser.State[group], states)

//                     parser.CurrentGroup = parser.GroupCount - 1
//                     group = NAVRegexGetCurrentGroup(parser)

//                     parser.StateCount[group]++
//                     state = NAVRegexGetCurrentState(parser)
//                     parser.State[group][state].Type = NAV_REGEX_TYPE_GROUP
//                     parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE
//                     // NAVRegexCopyStateToGroupStateArray(states, parser.State[group][state].GroupState)
//                 }

//                 x++
//                 continue
//             }

//             case '\': {
//                 if ((x + 1) > length_array(pattern)) {
//                     return NAV_REGEX_ERROR_INVALID_ESCAPE
//                 }

//                 switch (pattern[x + 1]) {
//                     case 'd': {
//                         parser.StateCount[group]++

//                         state = NAVRegexGetLastState(parser)
//                         parser.State[group][state].Type = NAV_REGEX_TYPE_DIGIT
//                         parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

//                         x = x + 2
//                         continue
//                     }
//                     case 'D': {
//                         parser.StateCount[group]++

//                         state = NAVRegexGetLastState(parser)
//                         parser.State[group][state].Type = NAV_REGEX_TYPE_NON_DIGIT
//                         parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

//                         x = x + 2
//                         continue
//                     }
//                     case 'w': {
//                         parser.StateCount[group]++

//                         state = NAVRegexGetLastState(parser)
//                         parser.State[group][state].Type = NAV_REGEX_TYPE_WORD
//                         parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

//                         x = x + 2
//                         continue
//                     }
//                     case 'W': {
//                         parser.StateCount[group]++

//                         state = NAVRegexGetLastState(parser)
//                         parser.State[group][state].Type = NAV_REGEX_TYPE_NON_WORD
//                         parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

//                         x = x + 2
//                         continue
//                     }
//                     case 's': {
//                         parser.StateCount[group]++

//                         state = NAVRegexGetLastState(parser)
//                         parser.State[group][state].Type = NAV_REGEX_TYPE_WHITESPACE
//                         parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

//                         x = x + 2
//                         continue
//                     }
//                     case 'S': {
//                         parser.StateCount[group]++

//                         state = NAVRegexGetLastState(parser)
//                         parser.State[group][state].Type = NAV_REGEX_TYPE_NON_WHITESPACE
//                         parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

//                         x = x + 2
//                         continue
//                     }
//                     case '\': {
//                         // state = NAVRegexGetLastState(parser)

//                         // parser.State[group][state].Type = NAV_REGEX_TYPE_ESCAPE
//                         // parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE
//                         // parser.State[group][state].Value = pattern[x + 2]

//                         // x = x + 3
//                         // continue
//                     }
//                     default: {
//                         parser.StateCount[group]++

//                         state = NAVRegexGetLastState(parser)
//                         parser.State[group][state].Type = NAV_REGEX_TYPE_CHARACTER
//                         parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE
//                         parser.State[group][state].Value = pattern[x + 1]

//                         x = x + 2
//                         continue
//                     }
//                 }
//             }

//             default: {
//                 parser.StateCount[group]++

//                 state = NAVRegexGetCurrentState(parser)
//                 parser.State[group][state].Type = NAV_REGEX_TYPE_CHARACTER
//                 parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE
//                 parser.State[group][state].Value = next

//                 x++
//                 continue
//             }
//         }

//         if (parser.StateCount[1] < 1) {
//             return NAV_REGEX_ERROR_INVALID_PATTERN
//         }
//     }

//     return 0
// }


// define_function char[16000] NAVRegexPrintState(_NAVRegexParser parser, integer group, integer state) {
//     stack_var char result[16000]

//     switch (parser.State[group][state].Type) {
//         case NAV_REGEX_TYPE_GROUP: {
//             result = '{ '
//             result = "result, '"type": "', NAVRegexGetType(parser.State[group][state].Type), '", '"
//             result = "result, '"states": [', NAVRegexPrintStates(parser, group + 1), ']'"
//             result = "result, '"quantifier": "', NAVRegexGetQuantifier(parser.State[group][state].Quantifier), '"'"
//             result = "result, ' }'"
//         }
//         default: {
//             result = '{ '
//             result = "result, '"type": "', NAVRegexGetType(parser.State[group][state].Type), '", '"
//             result = "result, '"value": "', parser.State[group][state].Value, '", '"
//             result = "result, '"quantifier": "', NAVRegexGetQuantifier(parser.State[group][state].Quantifier), '"'"
//             result = "result, ' }'"
//         }
//     }

//     return result
// }


// define_function char[16000] NAVRegexPrintStates(_NAVRegexParser parser, integer group) {
//     stack_var char result[16000]
//     stack_var integer x

//     result = '['

//     for (x = 1; x <= parser.StateCount[group]; x++) {
//         result = "result, NAVRegexPrintState(parser, group, x)"

//         if (x < parser.StateCount[group]) {
//             result = "result, ','"
//         }
//     }

//     result = "result, ']'"

//     return result
// }


// define_function char[16000] NAVRegexPrintParser(_NAVRegexParser parser) {
//     stack_var char result[16000]
//     stack_var integer x
//     stack_var integer y

//     stack_var integer group
//     stack_var integer state

//     group = 1

//     // result = "NAV_CR, NAV_LF, '[', NAV_CR, NAV_LF"

//     // for (x = 1; x <= parser.GroupCount; x++) {
//     //     group = x

//     for (y = 1; y <= parser.StateCount[group]; y++) {
//         state = y

//         switch (parser.State[group][state].Type) {
//             case NAV_REGEX_TYPE_GROUP: {
//                 // group++

//                 // result = "result, NAVRegexGetTab(x), '{ '"

//                 // result = "result, '"states": [', NAV_CR, NAV_LF"


//                 // result = "result, '"quantifier": "', NAVRegexGetQuantifier(parser.State[group][state].Quantifier), '"'"

//                 // result = "result, ' }'"

//                 // if (y < parser.StateCount[group]) {
//                 //     result = "result, ','"
//                 // }

//                 // result = "result, NAV_CR, NAV_LF"

//                 // result = "result, NAVRegexPrintStates(parser, group)"
//             }
//             default: {
//                 // result = "result, NAVRegexGetTab(x), '{ '"

//                 // result = "result, '"type": "', NAVRegexGetType(parser.State[group][state].Type), '", '"
//                 // result = "result, '"value": "', parser.State[group][state].Value, '", '"
//                 // result = "result, '"quantifier": "', NAVRegexGetQuantifier(parser.State[group][state].Quantifier), '"'"

//                 // result = "result, ' }'"

//                 // if (y < parser.StateCount[group]) {
//                 //     result = "result, ','"
//                 // }

//                 // result = "result, NAV_CR, NAV_LF"

//                 result = "result, NAVRegexPrintState(parser, group, state)"
//             }
//         }
//     }

//     //     if (x < parser.GroupCount) {
//     //         result = "result, ','"
//     //     }
//     // }


//     // result = "result, ']'"

//     return result
// }


define_function char[NAV_MAX_CHARS] NAVRegexGetType(integer type) {
    switch (type) {
        case NAV_REGEX_TYPE_WILDCARD:       { return 'wildcard' }
        case NAV_REGEX_TYPE_CHARACTER:      { return 'character' }
        case NAV_REGEX_TYPE_ESCAPE:         { return 'escape' }
        case NAV_REGEX_TYPE_GROUP:          { return 'group' }
        case NAV_REGEX_TYPE_START_OF_STRING:{ return 'startOfString' }
        case NAV_REGEX_TYPE_END_OF_STRING:  { return 'endOfString' }
        case NAV_REGEX_TYPE_DIGIT:          { return 'digit' }
        case NAV_REGEX_TYPE_NON_DIGIT:      { return 'nonDigit' }
        case NAV_REGEX_TYPE_WORD:           { return 'word' }
        case NAV_REGEX_TYPE_NON_WORD:       { return 'nonWord' }
        case NAV_REGEX_TYPE_WHITESPACE:     { return 'whitespace' }
        case NAV_REGEX_TYPE_NON_WHITESPACE: { return 'nonWhitespace' }
    }
}


define_function char[NAV_MAX_CHARS] NAVRegexGetQuantifier(integer quantifier) {
    switch (quantifier) {
        case NAV_REGEX_QUANTIFIER_EXACTLY_ONE:   { return 'exactlyOne' }
        case NAV_REGEX_QUANTIFIER_ZERO_OR_MORE:  { return 'zeroOrMore' }
        case NAV_REGEX_QUANTIFIER_ONE_OR_MORE:   { return 'oneOrMore' }
        case NAV_REGEX_QUANTIFIER_ZERO_OR_ONE:   { return 'zeroOrOne' }
    }
}


define_function char[NAV_MAX_CHARS] NAVRegexGetError(sinteger error) {
    switch (error) {
        case NAV_REGEX_ERROR_INVALID_QUANTIFIER:{ return 'Invalid quantifier' }
        case NAV_REGEX_ERROR_INVALID_ESCAPE:    { return 'Invalid escape' }
        case NAV_REGEX_ERROR_INVALID_PATTERN:   { return 'Invalid pattern' }
        default:                                { return 'Unknown error' }
    }
}


// define_function char[NAV_MAX_BUFFER] NAVRegexGetTab(integer count) {
//     stack_var char result[NAV_MAX_BUFFER]
//     stack_var integer x
//     stack_var integer y

//     result = ''

//     for (x = 1; x <= count; x++) {
//         for (y = 1; y <= NAV_REGEX_TAB_SIZE; y++) {
//             result = "result, ' '"
//         }
//     }

//     return result
// }


#END_IF // __NAV_FOUNDATION_REGEX__
