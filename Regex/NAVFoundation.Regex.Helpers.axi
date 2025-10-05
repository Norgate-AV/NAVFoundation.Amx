PROGRAM_NAME='NAVFoundation.Regex.Helpers'

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


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_HELPERS__
#DEFINE __NAV_FOUNDATION_REGEX_HELPERS__ 'NAVFoundation.Regex.Helpers'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Regex.h.axi'


/******************************************************************************
 * Character type checking functions
 *****************************************************************************/

define_function char NAVRegexIsCharClassMetaChar(char c) {
    return (
        (c == 's') ||
        (c == 'S') ||
        (c == 'w') ||
        (c == 'W') ||
        (c == 'd') ||
        (c == 'D') ||
        (c == 'b') ||
        (c == 'x') ||
        (c == 'n') ||
        (c == 'r') ||
        (c == 't')
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


/******************************************************************************
 * Parser input management
 *****************************************************************************/

define_function NAVRegexParserSetInput(_NAVRegexParser parser, char buffer[]) {
    parser.input.value = buffer
    parser.input.length = length_array(buffer)
}


/******************************************************************************
 * Cursor management functions
 *****************************************************************************/

define_function NAVRegexSetInputCursor(_NAVRegexParser parser, char caller[], integer cursor) {
    NAVRegexDebug(parser,
                    caller,
                    "'Setting input cursor to position => ', itoa(cursor)")

    parser.input.cursor = cursor
}


define_function NAVRegexSetPatternCursor(_NAVRegexParser parser, char caller[], integer cursor) {
    NAVRegexDebug(parser,
                    caller,
                    "'Setting pattern cursor to position => ', itoa(cursor)")

    parser.pattern.cursor = cursor
}


define_function NAVRegexSetPatternCharClassCursor(_NAVRegexParser parser, char caller[], integer cursor) {
    NAVRegexDebug(parser,
                    caller,
                    "'Setting pattern charclass cursor to position => ', itoa(cursor)")

    parser.state[parser.pattern.cursor].charclass.cursor = cursor
}


define_function NAVRegexAdvanceInputCursor(_NAVRegexParser parser, char caller[], integer count) {
    NAVRegexSetInputCursor(parser, caller, (parser.input.cursor + count))
}


define_function NAVRegexAdvancePatternCursor(_NAVRegexParser parser, char caller[], integer count) {
    NAVRegexSetPatternCursor(parser, caller, (parser.pattern.cursor + count))
}


define_function NAVRegexAdvancePatternCharClassCursor(_NAVRegexParser parser, char caller[], integer count) {
    NAVRegexSetPatternCharClassCursor(parser, caller, (parser.state[parser.pattern.cursor].charclass.cursor + count))
}


define_function NAVRegexBacktrackInputCursor(_NAVRegexParser parser, char caller[], integer count) {
    NAVRegexSetInputCursor(parser, caller, (parser.input.cursor - count))
}


define_function NAVRegexBacktrackPatternCursor(_NAVRegexParser parser, char caller[], integer count) {
    NAVRegexSetPatternCursor(parser, caller, (parser.pattern.cursor - count))
}


define_function NAVRegexBacktrackPatternCharClassCursor(_NAVRegexParser parser, char caller[], integer count) {
    NAVRegexSetPatternCharClassCursor(parser, caller, (parser.state[parser.pattern.cursor].charclass.cursor - count))
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


/******************************************************************************
 * Match result management
 *****************************************************************************/

define_function char NAVRegexMatchResultInit(_NAVRegexMatchResult match) {
    match.count = 0
    match.current = 1

    return true
}


define_function NAVRegexMatchSetLength(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, integer length) {
    NAVRegexDebug(parser,
                    caller,
                    "'Setting match length to => ', itoa(length)")

    match.matches[match.current].length = length
}


define_function NAVRegexMatchIncreaseLength(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, integer count) {
    NAVRegexMatchSetLength(parser, caller, match, match.matches[match.current].length + count)
}


define_function NAVRegexMatchDecreaseLength(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, integer count) {
    NAVRegexMatchSetLength(parser, caller, match, match.matches[match.current].length - count)
}


define_function integer NAVRegexMatchGetLength(_NAVRegexMatchResult match) {
    return match.matches[match.current].length
}


define_function NAVRegexMatchSetStart(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, integer start) {
    NAVRegexDebug(parser,
                    caller,
                    "'Setting match start to => ', itoa(start)")

    match.matches[match.current].start = start
}


define_function NAVRegexMatchIncreaseStart(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, integer count) {
    NAVRegexMatchSetStart(parser, caller, match, match.matches[match.current].start + count)
}


define_function NAVRegexMatchDecreaseStart(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, integer count) {
    NAVRegexMatchSetStart(parser, caller, match, match.matches[match.current].start - count)
}


define_function integer NAVRegexMatchGetStart(_NAVRegexMatchResult match) {
    return match.matches[match.current].start
}


define_function integer NAVRegexMatchGetEnd(_NAVRegexMatchResult match) {
    return NAVRegexMatchGetStart(match) + NAVRegexMatchGetLength(match)
}


define_function NAVRegexMatchSetEnd(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, integer end) {
    NAVRegexDebug(parser,
                    caller,
                    "'Setting match end to => ', itoa(end)")

    match.matches[match.current].end = end
}


define_function char[NAV_MAX_BUFFER] NAVRegexMatchGetTextFromBuffer(_NAVRegexMatchResult match, char buffer[]) {
    return NAVStringSlice(buffer, NAVRegexMatchGetStart(match), NAVRegexMatchGetEnd(match))
}


define_function char[NAV_MAX_BUFFER] NAVRegexMatchGetTextFromParser(_NAVRegexMatchResult match, _NAVRegexParser parser) {
    return NAVStringSlice(parser.input.value, NAVRegexMatchGetStart(match), NAVRegexMatchGetEnd(match))
}


define_function NAVRegexMatchSetText(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, char text[]) {
    NAVRegexDebug(parser,
                    caller,
                    "'Setting match text to => "', text, '"'")

    match.matches[match.current].text = text
}


/******************************************************************************
 * State management
 *****************************************************************************/

define_function char NAVRegexQuantifierIsLazy(_NAVRegexParser parser) {
    if ((parser.pattern.cursor + 2) > parser.count) {
        return false
    }

    return (parser.state[parser.pattern.cursor + 2].type == REGEX_TYPE_QUESTIONMARK)
}


define_function NAVRegexSaveState(_NAVRegexParser parser, _NAVRegexMatchResult match, _NAVRegexBacktrackState state) {
    // Parser state
    state.input.cursor = parser.input.cursor
    state.pattern.cursor = parser.pattern.cursor

    // Match state
    state.match.count = match.count
    state.match.current = match.current
    state.match.matches[state.match.current].length = NAVRegexMatchGetLength(match)
}


define_function NAVRegexRestoreState(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, _NAVRegexBacktrackState state) {
    NAVRegexDebug(parser,
                    caller,
                    "'Backtracking to previous state'")

    NAVRegexSetInputCursor(parser, caller, state.input.cursor)
    NAVRegexSetPatternCursor(parser, caller, state.pattern.cursor)

    match.count = state.match.count
    match.current = state.match.current
    NAVRegexMatchSetLength(parser, caller, match, NAVRegexMatchGetLength(state.match))
}


define_function char NAVRegexMadeProgress(_NAVRegexParser parser) {
    // Have we made progress?

    // If the input cursor is greater than the input length, we have not made progress
    if (parser.input.cursor > parser.input.length) {
        return false
    }

    // If the pattern cursor is greater than the pattern count, we have not made progress
    if (parser.pattern.cursor > parser.count) {
        return false
    }

    return true
}


/******************************************************************************
 * Debug functions
 *****************************************************************************/

define_function char NAVRegexGetParserDebug(_NAVRegexParser parser) {
    return parser.debug
}


define_function char NAVRegexGetMatchDebug(_NAVRegexMatchResult match) {
    return match.debug
}


define_function NAVRegexDebugSync(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    if (!parser.debug && !match.debug) {
        return
    }

    parser.debug = true
    match.debug = true
}


define_function NAVRegexPrintCurrentState(_NAVRegexParser parser, char caller[]) {
    stack_var char c
    stack_var integer type
    stack_var char pattern[50]

    if (parser.pattern.cursor > parser.count) {
        return
    }

    if (parser.input.cursor > parser.input.length) {
        return
    }

    c = NAVCharCodeAt(parser.input.value, parser.input.cursor)
    type = parser.state[parser.pattern.cursor].type

    if (!type) {
        return
    }

    switch (type) {
        case REGEX_TYPE_CHAR:           { pattern = "parser.state[parser.pattern.cursor].value" }
        case REGEX_TYPE_CHAR_CLASS:     { pattern = parser.state[parser.pattern.cursor].charclass.value }
        default:                        { pattern = REGEX_TYPES[type] }
    }

    NAVRegexDebug(parser, caller, "'Current state => Does "', c, '" match "', pattern, '"?'")
}


define_function NAVRegexDebug(_NAVRegexParser parser, char caller[], char message[]) {
    if (!NAVRegexGetParserDebug(parser)) {
        return
    }

    if (!length_array(caller) || !length_array(message)) {
        return
    }

    NAVLog("'[ ', caller, ' ]: ', message")
}


define_function char[NAV_MAX_CHARS] NAVRegexGetTokenType(integer type) {
    if (type < 1 || type > REGEX_TYPE_TAB) {
        return "'UNKNOWN (', itoa(type), ')'"
    }

    return REGEX_TYPES[type]
}


#END_IF // __NAV_FOUNDATION_REGEX_HELPERS__
