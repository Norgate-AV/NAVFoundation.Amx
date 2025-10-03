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

#DEFINE REGEX_DEBUG 1

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Regex.h.axi'


define_function char NAVRegexTest(char buffer[], char pattern[]) {
    stack_var _NAVRegexParser parser
    stack_var _NAVRegexMatchResult match

    if (!NAVRegexCompile(pattern, parser)) {
        return false
    }

    return NAVRegexMatchCompiled(parser, buffer, match)
}


define_function char NAVRegexMatch(char pattern[], char subject[], _NAVRegexMatchResult match) {
    stack_var _NAVRegexParser parser

    if (!NAVRegexCompile(pattern, parser)) {
        return false
    }

    #IF_DEFINED REGEX_DEBUG
    NAVLog("'[ Match ]: Pattern compiled with ', itoa(parser.count), ' tokens'")
    NAVRegexPrintState(parser)
    #END_IF

    if (NAVRegexMatchCompiled(parser, subject, match)) {
        #WARN 'May need to move this to the NAVRegexMatchCompiled function'
        // May move this to the NAVRegexMatchCompiled function?
        // The below needs to be done if the MatchCompiled function
        // is used directly as well as the Match function.
        // So it probably make more sense to do it in the MatchCompiled function

        // match.matches[match.current].end = match.matches[match.current].start + match.matches[match.current].length
        NAVRegexMatchSetEnd(parser, 'Match', match, NAVRegexMatchGetEnd(match))
        // match.matches[match.current].text = NAVStringSlice(buffer, match.matches[match.current].start, match.matches[match.current].end)
        NAVRegexMatchSetText(parser, 'Match', match, NAVRegexMatchGetTextFromBuffer(match, subject))

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


define_function char NAVRegexMatchCompiled(_NAVRegexParser parser, char subject[], _NAVRegexMatchResult match) {
    stack_var integer idx

    if (!NAVRegexMatchResultInit(match)) {
        return false
    }

    NAVRegexDebugSync(parser, match)

    NAVRegexMatchSetLength(parser, 'MatchCompiled', match, 0)

    NAVRegexParserSetInput(parser, subject)

    // Handle BEGIN anchor (^)
    if (parser.state[1].type == REGEX_TYPE_BEGIN) {
        NAVRegexSetPatternCursor(parser, 'MatchCompiled', 2)
        NAVRegexSetInputCursor(parser, 'MatchCompiled', 1)
        NAVRegexMatchSetStart(parser, 'MatchCompiled', match, 1)

        return NAVRegexMatchPattern(parser, match)
    }

    // Try matching from each position in the text
    // This is equivalent to the do-while loop in C's re_matchp
    idx = 0  // idx = -1 in C, but we're 1-indexed so start at 0

    while (true) {
        idx++

        // Reset state for each new attempt
        NAVRegexSetPatternCursor(parser, 'MatchCompiled', 1)
        NAVRegexSetInputCursor(parser, 'MatchCompiled', idx)
        NAVRegexMatchSetStart(parser, 'MatchCompiled', match, idx)
        NAVRegexMatchSetLength(parser, 'MatchCompiled', match, 0)

        if (NAVRegexMatchPattern(parser, match)) {
            // In C: if (text[0] == '\0') return -1;
            // This checks if we matched starting at the null terminator (past all chars)
            // For empty string (length=0), idx=1 is valid
            // For non-empty string, idx should not be > length
            if (parser.input.length > 0 && idx > parser.input.length) {
                return false
            }

            return true
        }

        // Advance to next starting position
        // In C this is: while (*text++ != '\0')
        // which means advance text, then check if previous char was null
        if (idx >= parser.input.length) {
            break
        }
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

        #IF_DEFINED REGEX_DEBUG
        NAVLog("'[ Compile ]: cursor=', itoa(parser.pattern.cursor), ' char=', c, ' (', itoa(type_cast(c)), ')'")
        #END_IF

        switch (c) {
            case '^': { parser.state[(parser.count + 1)].type = REGEX_TYPE_BEGIN }
            case '$': { parser.state[(parser.count + 1)].type = REGEX_TYPE_END }
            case '.': { parser.state[(parser.count + 1)].type = REGEX_TYPE_DOT }

            // Quantifiers. Should these be handled differently?
            case '*': {
                // Check if the following character is '?'
                if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 2)) == '?') {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Don`t support lazy quantifiers yet'")

                    return false
                }

                parser.state[(parser.count + 1)].type = REGEX_TYPE_STAR
            }
            case '+': {
                // Check if the following character is '?'
                if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 2)) == '?') {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Don`t support lazy quantifiers yet'")

                    return false
                }

                parser.state[(parser.count + 1)].type = REGEX_TYPE_PLUS
            }
            case '?': {
                // Check if the following character is '?'
                if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 2)) == '?') {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Don`t support lazy quantifiers yet'")

                    return false
                }

                parser.state[(parser.count + 1)].type = REGEX_TYPE_QUESTIONMARK
            }

            case '|': { // Not working properly
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX__,
                                            'NAVRegexCompile',
                                            "'Don`t support branching yet'")

                return false
                // parser.state[(parser.count + 1)].type = REGEX_TYPE_BRANCH
            }

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

            case '{': {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX__,
                                            'NAVRegexCompile',
                                            "'Don`t support specific quantifiers yet'")

                return false
            }
            case '(': {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX__,
                                            'NAVRegexCompile',
                                            "'Don`t support group constructs yet'")

                return false
            }
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
        NAVLog('[]')
        return
    }

    NAVLog("'[ Compiled Pattern Tokens ]'")

    for (i = 0; i < parser.count; i++) {
        if (parser.state[(i + 1)].type == REGEX_TYPE_UNUSED) {
            break
        }

        message = "'  [', itoa(i + 1), '] ', REGEX_TYPES[parser.state[(i + 1)].type]"

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
            message = "message, ' => "', parser.state[(i + 1)].value, '"'"
        }

        NAVLog(message)
    }

    NAVLog("'[ End Pattern Tokens ]'")
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
    return (!NAVRegexMatchAlphaNumeric(NAVCharCodeAt(parser.input.value, parser.input.cursor - 1)) &&
            NAVRegexMatchAlphaNumeric(NAVCharCodeAt(parser.input.value, parser.input.cursor)))
}


define_function char NAVRegexMatchHex(_NAVRegexParser parser) {
    // How do you match a hex character?
    // A hex character is a character in the range 0-9, A-F, a-f
    return (NAVIsDigit(NAVCharCodeAt(parser.input.value, parser.input.cursor)) ||
            (NAVCharCodeAt(parser.input.value, parser.input.cursor) >= 'A' && NAVCharCodeAt(parser.input.value, parser.input.cursor) <= 'F') ||
            (NAVCharCodeAt(parser.input.value, parser.input.cursor) >= 'a' && NAVCharCodeAt(parser.input.value, parser.input.cursor) <= 'f'))
}


define_function char NAVRegexMatchDot(char c) {
    // Check parser options for global and multiline flags?
    return (c != NAV_CR && c != NAV_LF)
}


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


define_function char NAVRegexMatchCharClassMetaChar(char c, char buffer[]) {
    switch (NAVCharCodeAt(buffer, 1)) {
        // case 'b':   { return  NAVRegexMatchBackspace(c) }
        case 'd':   { return  NAVRegexMatchDigit(c) }
        case 'D':   { return !NAVRegexMatchDigit(c) }
        case 'w':   { return  NAVRegexMatchAlphaNumeric(c) }
        case 'W':   { return !NAVRegexMatchAlphaNumeric(c) }
        case 's':   { return  NAVRegexMatchWhitespace(c) }
        case 'S':   { return !NAVRegexMatchWhitespace(c) }
        // case 'x':   { return  NAVRegexMatchHex(c) }
        // case 'n':   { return NAVRegexMatchNewline(c) }
        // case 'r':   { return NAVRegexMatchReturn(c) }
        // case 't':   { return NAVRegexMatchTab(c) }
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

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    'MatchCharClass',
                    "'Matching character class => "', charclass, '"'")
    #END_IF

    NAVRegexSetPatternCharClassCursor(parser, 'MatchCharClass', 1)

    while (true) {
        c = NAVCharCodeAt(parser.input.value, parser.input.cursor)

        if (NAVRegexMatchRange(parser)) {
            #IF_DEFINED REGEX_DEBUG
            NAVRegexDebug(parser,
                            'MatchCharClass',
                            'Matched range')
            #END_IF

            return true
        }

        if (NAVCharCodeAt(charclass, parser.state[parser.pattern.cursor].charclass.cursor) == '\') {
            #IF_DEFINED REGEX_DEBUG
            NAVRegexDebug(parser,
                            'MatchCharClass',
                            'Escaped character')
            #END_IF

            NAVRegexAdvancePatternCharClassCursor(parser, 'MatchCharClass', 1)

            if (NAVRegexMatchCharClassMetaChar(c, charclass)) {
                #IF_DEFINED REGEX_DEBUG
                NAVRegexDebug(parser,
                                'MatchCharClass',
                                "'Matched meta character => "', c, '"'")
                #END_IF

                return true
            }

            if ((NAVCharCodeAt(charclass, parser.state[parser.pattern.cursor].charclass.cursor) == c) && !NAVRegexIsCharClassMetaChar(c)) {
                #IF_DEFINED REGEX_DEBUG
                NAVRegexDebug(parser,
                                'MatchCharClass',
                                "'Yes. Matched character => "', c, '"'")
                #END_IF

                return true
            }
        }

        if (NAVCharCodeAt(charclass, parser.state[parser.pattern.cursor].charclass.cursor) == c) {
            #IF_DEFINED REGEX_DEBUG
            NAVRegexDebug(parser,
                            'MatchCharClass',
                            "'Yes. Matched character => "', c, '"'")
            #END_IF

            if (c == '-') {
                return ((parser.state[parser.pattern.cursor].charclass.cursor - 1) == length) ||
                        ((parser.state[parser.pattern.cursor].charclass.cursor + 1) == length)
            }

            return true
        }

        NAVRegexAdvancePatternCharClassCursor(parser, 'MatchCharClass', 1)

        if (parser.state[parser.pattern.cursor].charclass.cursor <= length) {
            continue
        }

        break
    }

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    'MatchCharClass',
                    'No. It doesn`t match')
    #END_IF

    return false
}


define_function char NAVRegexMatchOne(_NAVRegexParser parser) {
    stack_var integer type
    stack_var char value
    stack_var char c

    if (parser.input.cursor > parser.input.length) {
        #IF_DEFINED REGEX_DEBUG
        NAVRegexDebug(parser,
                        'MatchOne',
                        'Input cursor is greater than input length')
        #END_IF

        return false
    }

    if (parser.pattern.cursor > parser.count) {
        #IF_DEFINED REGEX_DEBUG
        NAVRegexDebug(parser,
                        'MatchOne',
                        'Pattern cursor is greater than pattern count')
        #END_IF

        return false
    }

    type = parser.state[parser.pattern.cursor].type
    value = parser.state[parser.pattern.cursor].value

    c = NAVCharCodeAt(parser.input.value, parser.input.cursor)

    if (!c) {
        #IF_DEFINED REGEX_DEBUG
        NAVRegexDebug(parser,
                        'MatchOne',
                        'The current character is null')
        #END_IF

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
    // NOTE: Pattern cursor is already pointing to &pattern[2] when this is called
    // NOTE: We need to look back at pattern[cursor-2] to get the token to match

    stack_var integer prelen
    stack_var integer prepoint
    stack_var integer count
    stack_var integer saved_pattern_cursor

    prelen = NAVRegexMatchGetLength(match)
    prepoint = parser.input.cursor

    // Save the pattern cursor (already at &pattern[2])
    saved_pattern_cursor = parser.pattern.cursor

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    'MatchStar',
                    "'Attempting to match token type ', REGEX_TYPES[parser.state[saved_pattern_cursor - 2].type], ' zero or more times'")
    #END_IF

    // Match as many as possible (greedy)
    // Temporarily point to the token we're matching for matchone
    NAVRegexSetPatternCursor(parser, 'MatchStar', saved_pattern_cursor - 2)

    while (parser.input.cursor <= parser.input.length && NAVRegexMatchOne(parser)) {
        #IF_DEFINED REGEX_DEBUG
        NAVRegexDebug(parser,
                        'MatchStar',
                        "'Yes. Matched 1 character => "',
                            NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")
        #END_IF

        count++
        NAVRegexAdvanceInputCursor(parser, 'MatchStar', 1)
    }

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    'MatchStar',
                    "'Total Matched: ', itoa(count), ' characters'")
    #END_IF

    NAVRegexMatchIncreaseLength(parser, 'MatchStar', match, count)

    // Restore pattern cursor to &pattern[2] for the recursive matchpattern calls
    NAVRegexSetPatternCursor(parser, 'MatchStar', saved_pattern_cursor)

    // Backtrack: try matching the rest of the pattern from each position
    // In C: while (text >= prepoint)
    while (parser.input.cursor >= prepoint) {
        if (NAVRegexMatchPattern(parser, match)) {
            #IF_DEFINED REGEX_DEBUG
            NAVRegexDebug(parser,
                            'MatchStar',
                            'Yes. It matches')
            #END_IF

            return true
        }

        // Backtrack one character
        NAVRegexMatchDecreaseLength(parser, 'MatchStar', match, 1)
        NAVRegexBacktrackInputCursor(parser, 'MatchStar', 1)

        // Reset pattern cursor for next attempt
        NAVRegexSetPatternCursor(parser, 'MatchStar', saved_pattern_cursor)
    }

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    'MatchStar',
                    'No. It doesn`t match')
    #END_IF

    NAVRegexMatchSetLength(parser, 'MatchStar', match, prelen)

    return false
}


define_function char NAVRegexMatchPlus(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    // + matches the previous token between one and unlimited times, as many times as possible, giving back as needed (greedy)
    // NOTE: Pattern cursor is already pointing to &pattern[2] when this is called
    // NOTE: We need to look back at pattern[cursor-2] to get the token to match

    stack_var integer prepoint
    stack_var integer count
    stack_var integer saved_pattern_cursor

    prepoint = parser.input.cursor

    // Save the pattern cursor (already at &pattern[2])
    saved_pattern_cursor = parser.pattern.cursor

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    'MatchPlus',
                    "'Attempting to match token type ', REGEX_TYPES[parser.state[saved_pattern_cursor - 2].type], ' one or more times'")
    #END_IF

    // Match as many as possible (greedy)
    // Temporarily point to the token we're matching for matchone
    NAVRegexSetPatternCursor(parser, 'MatchPlus', saved_pattern_cursor - 2)

    while (parser.input.cursor <= parser.input.length && NAVRegexMatchOne(parser)) {
        #IF_DEFINED REGEX_DEBUG
        NAVRegexDebug(parser,
                        'MatchPlus',
                        "'Yes. Matched 1 character => "',
                            NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")
        #END_IF

        count++
        NAVRegexAdvanceInputCursor(parser, 'MatchPlus', 1)
    }

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    'MatchPlus',
                    "'Total Matched: ', itoa(count), ' characters'")
    #END_IF

    NAVRegexMatchIncreaseLength(parser, 'MatchPlus', match, count)

    // Restore pattern cursor to &pattern[2] for the recursive matchpattern calls
    NAVRegexSetPatternCursor(parser, 'MatchPlus', saved_pattern_cursor)

    // Backtrack: try matching the rest of the pattern from each position
    // In C: while (text > prepoint) - note the > not >=, because + requires at least one match
    while (parser.input.cursor > prepoint) {
        if (NAVRegexMatchPattern(parser, match)) {
            #IF_DEFINED REGEX_DEBUG
            NAVRegexDebug(parser,
                            'MatchPlus',
                            'Yes. It matches')
            #END_IF

            return true
        }

        // Backtrack one character
        NAVRegexMatchDecreaseLength(parser, 'MatchPlus', match, 1)
        NAVRegexBacktrackInputCursor(parser, 'MatchPlus', 1)

        // Reset pattern cursor for next attempt
        NAVRegexSetPatternCursor(parser, 'MatchPlus', saved_pattern_cursor)
    }

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    'MatchPlus',
                    'No. It doesn`t match')
    #END_IF

    return false
}


define_function char NAVRegexMatchQuestion(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    // ? matches the previous token between zero and one times
    // In tiny-regex-c, this is NON-GREEDY (despite the comment saying greedy in your code)
    // The C implementation tries ZERO first, then ONE

    // p = pattern[0], pattern = &pattern[2], text unchanged, matchlength passed through
    // Pattern cursor has been advanced by 2, so the token to match is at cursor - 2

    stack_var integer saved_pattern_cursor

    // Save the current pattern cursor (points to rest of pattern after ?)
    saved_pattern_cursor = parser.pattern.cursor

    // Check if pattern type is UNUSED (end of pattern)
    if (parser.state[parser.pattern.cursor].type == REGEX_TYPE_UNUSED) {
        #IF_DEFINED REGEX_DEBUG
        NAVRegexDebug(parser,
                        'MatchQuestion',
                        'Pattern type is UNUSED - returning true')
        #END_IF

        return true
    }

    // Try matching the rest of the pattern WITHOUT consuming input (match zero)
    // In C: if (matchpattern(pattern, text, matchlength)) return 1;
    if (NAVRegexMatchPattern(parser, match)) {
        #IF_DEFINED REGEX_DEBUG
        NAVRegexDebug(parser,
                        'MatchQuestion',
                        'Matched zero instances (rest of pattern matched without consuming)')
        #END_IF

        return true
    }

    // Try matching one character then the rest of the pattern
    // Need to check the token at cursor - 2 (the token before the ?)
    // In C: if (*text && matchone(p, *text++))

    // Temporarily set pattern cursor to the token to match
    NAVRegexSetPatternCursor(parser, 'MatchQuestion', saved_pattern_cursor - 2)

    if (parser.input.cursor <= parser.input.length && NAVRegexMatchOne(parser)) {
        #IF_DEFINED REGEX_DEBUG
        NAVRegexDebug(parser,
                        'MatchQuestion',
                        "'Matched one character => "',
                            NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")
        #END_IF

        // Advance input cursor (equivalent to text++)
        NAVRegexAdvanceInputCursor(parser, 'MatchQuestion', 1)

        // Restore pattern cursor to rest of pattern
        NAVRegexSetPatternCursor(parser, 'MatchQuestion', saved_pattern_cursor)

        // Try matching the rest of the pattern
        if (NAVRegexMatchPattern(parser, match)) {
            // Increase match length by 1 for the character we just matched
            NAVRegexMatchIncreaseLength(parser, 'MatchQuestion', match, 1)

            #IF_DEFINED REGEX_DEBUG
            NAVRegexDebug(parser,
                            'MatchQuestion',
                            'Yes. It matches (with one character)')
            #END_IF

            return true
        }
    }

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    'MatchQuestion',
                    'No. It doesn`t match')
    #END_IF

    return false
}


define_function char NAVRegexMatchPattern(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    stack_var integer pre

    // Save the current match length (used for backtracking)
    pre = NAVRegexMatchGetLength(match)

    // Main matching loop - equivalent to do-while in C
    while (true) {
        // Check if pattern[0].type == UNUSED (end of pattern)
        if (parser.state[parser.pattern.cursor].type == REGEX_TYPE_UNUSED) {
            #IF_DEFINED REGEX_DEBUG
            NAVRegexDebug(parser,
                            'MatchPattern',
                            'Pattern UNUSED - match successful')
            #END_IF

            return true
        }

        // Check if pattern[1].type == QUESTIONMARK
        // Call matchquestion with p=pattern[0], pattern=&pattern[2]
        if (parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_QUESTIONMARK) {
            // Advance pattern cursor by 2 to point to &pattern[2] before calling
            NAVRegexAdvancePatternCursor(parser, 'MatchPattern', 2)
            return NAVRegexMatchQuestion(parser, match)
        }

        // Check if pattern[1].type == STAR
        // Call matchstar with p=pattern[0], pattern=&pattern[2]
        if (parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_STAR) {
            // Advance pattern cursor by 2 to point to &pattern[2] before calling
            NAVRegexAdvancePatternCursor(parser, 'MatchPattern', 2)
            return NAVRegexMatchStar(parser, match)
        }

        // Check if pattern[1].type == PLUS
        // Call matchplus with p=pattern[0], pattern=&pattern[2]
        if (parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_PLUS) {
            // Advance pattern cursor by 2 to point to &pattern[2] before calling
            NAVRegexAdvancePatternCursor(parser, 'MatchPattern', 2)
            return NAVRegexMatchPlus(parser, match)
        }

        // Check if pattern[0].type == END and pattern[1].type == UNUSED
        if (parser.state[parser.pattern.cursor].type == REGEX_TYPE_END &&
            parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_UNUSED) {
            #IF_DEFINED REGEX_DEBUG
            NAVRegexDebug(parser,
                            'MatchPattern',
                            'END anchor - checking if at end of text')
            #END_IF

            // In C: return (text[0] == '\0')
            return (parser.input.cursor > parser.input.length)
        }

        // Default case: try to match one character
        // In C: while ((text[0] != '\0') && matchone(*pattern++, *text++))

        // Check if we've reached end of text
        if (parser.input.cursor > parser.input.length) {
            break
        }

        #IF_DEFINED REGEX_DEBUG
        NAVRegexPrintCurrentState(parser, 'MatchPattern')
        #END_IF

        // Try to match current character with current pattern
        if (NAVRegexMatchOne(parser)) {
            #IF_DEFINED REGEX_DEBUG
            NAVRegexDebug(parser,
                            'MatchPattern',
                            "'Yes. Matched 1 character => "',
                                NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")
            #END_IF

            // Increment matchlength, advance both pattern and text
            NAVRegexMatchIncreaseLength(parser, 'MatchPattern', match, 1)
            NAVRegexAdvanceInputCursor(parser, 'MatchPattern', 1)
            NAVRegexAdvancePatternCursor(parser, 'MatchPattern', 1)

            continue
        }

        // Match failed
        break
    }

    // Restore match length and return false
    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    'MatchPattern',
                    'No. It doesn`t match')
    #END_IF

    NAVRegexMatchSetLength(parser, 'MatchPattern', match, pre)

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
    NAVRegexSetPatternCursor(parser, 'ParserInit', 1)

    if (!NAVRegexParserParseOptions(parser, pattern)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexParserInit',
                                    "'Failed to parse options'")

        return false
    }

    parser.input.value = ''
    parser.input.length = 0
    NAVRegexSetInputCursor(parser, 'ParserInit', 1)

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

    options = lower_string(NAVStringSlice(pattern, (parser.pattern.length + 2), 0))

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

define_function NAVRegexSetInputCursor(_NAVRegexParser parser, char caller[], integer cursor) {
    if (cursor < 1) {
        cursor = 1
    }

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    caller,
                    "'Setting input cursor to position => ', itoa(cursor)")
    #END_IF

    parser.input.cursor = cursor
}


define_function NAVRegexSetPatternCursor(_NAVRegexParser parser, char caller[], integer cursor) {
    if (cursor < 1) {
        cursor = 1
    }

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    caller,
                    "'Setting pattern cursor to position => ', itoa(cursor)")
    #END_IF

    parser.pattern.cursor = cursor
}


define_function NAVRegexSetPatternCharClassCursor(_NAVRegexParser parser, char caller[], integer cursor) {
    if (cursor < 1) {
        cursor = 1
    }

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    caller,
                    "'Setting pattern charclass cursor to position => ', itoa(cursor)")
    #END_IF

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


define_function char NAVRegexMatchResultInit(_NAVRegexMatchResult match) {
    match.count = 0
    match.current = 1

    return true
}


define_function NAVRegexMatchSetLength(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, integer length) {
    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    caller,
                    "'Setting match length to => ', itoa(length)")
    #END_IF

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
    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    caller,
                    "'Setting match start to => ', itoa(start)")
    #END_IF

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
    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    caller,
                    "'Setting match end to => ', itoa(end)")
    #END_IF

    match.matches[match.current].end = end
}


define_function char[NAV_MAX_BUFFER] NAVRegexMatchGetTextFromBuffer(_NAVRegexMatchResult match, char buffer[]) {
    return NAVStringSlice(buffer, NAVRegexMatchGetStart(match), NAVRegexMatchGetEnd(match))
}


define_function char[NAV_MAX_BUFFER] NAVRegexMatchGetTextFromParser(_NAVRegexMatchResult match, _NAVRegexParser parser) {
    return NAVStringSlice(parser.input.value, NAVRegexMatchGetStart(match), NAVRegexMatchGetEnd(match))
}


define_function NAVRegexMatchSetText(_NAVRegexParser parser, char caller[], _NAVRegexMatchResult match, char text[]) {
    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    caller,
                    "'Setting match text to => "', text, '"'")
    #END_IF

    match.matches[match.current].text = text
}


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

    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser, caller, "'Current state => Does "', c, '" match "', pattern, '"?'")
    #END_IF
}


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
    #IF_DEFINED REGEX_DEBUG
    NAVRegexDebug(parser,
                    caller,
                    "'Backtracking to previous state'")
    #END_IF

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


define_function NAVRegexDebug(_NAVRegexParser parser, char caller[], char message[]) {
    if (!NAVRegexGetParserDebug(parser)) {
        return
    }

    if (!length_array(caller) || !length_array(message)) {
        return
    }

    NAVLog("'[ ', caller, ' ]: ', message")
}


#END_IF // __NAV_FOUNDATION_REGEX__
