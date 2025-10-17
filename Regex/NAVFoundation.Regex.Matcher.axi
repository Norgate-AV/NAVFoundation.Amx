PROGRAM_NAME='NAVFoundation.Regex.Matcher'

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


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_MATCHER__
#DEFINE __NAV_FOUNDATION_REGEX_MATCHER__ 'NAVFoundation.Regex.Matcher'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Regex.h.axi'
#include 'NAVFoundation.Regex.Helpers.axi'


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
    stack_var char charBefore
    stack_var char charAt
    stack_var char isWordBefore
    stack_var char isWordAt

    // A word boundary is a position where:
    // - A word character is followed by a non-word character, OR
    // - A non-word character is followed by a word character, OR
    // - At the start/end of the string adjacent to a word character

    // Get characters (0 if out of bounds)
    if (parser.input.cursor > 1) {
        charBefore = NAVCharCodeAt(parser.input.value, parser.input.cursor - 1)
    }

    if (parser.input.cursor <= length_array(parser.input.value)) {
        charAt = NAVCharCodeAt(parser.input.value, parser.input.cursor)
    }

    // Check if they are word characters
    isWordBefore = NAVRegexMatchAlphaNumeric(charBefore) || charBefore == '_'
    isWordAt = NAVRegexMatchAlphaNumeric(charAt) || charAt == '_'

    // Word boundary exists if exactly one is a word character
    return (isWordBefore != isWordAt)
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


define_function char NAVRegexMatchCharClassMetaChar(char c, char buffer[]) {
    switch (NAVCharCodeAt(buffer, 1)) {
        // case 'b':   { return  NAVRegexMatchBackspace(c) }
        case 'd':   { return  NAVRegexMatchDigit(c) }
        case 'D':   { return !NAVRegexMatchDigit(c) }
        case 'w':   { return  NAVRegexMatchAlphaNumeric(c) }
        case 'W':   { return !NAVRegexMatchAlphaNumeric(c) }
        case 's':   { return  NAVRegexMatchWhitespace(c) }
        case 'S':   { return !NAVRegexMatchWhitespace(c) }
        case 'x':   {
            // Match hex digit: 0-9, A-F, a-f
            return (NAVIsDigit(c) ||
                    (c >= 'A' && c <= 'F') ||
                    (c >= 'a' && c <= 'f'))
        }
        case 'n':   { return (c == NAV_LF) }
        case 'r':   { return (c == NAV_CR) }
        case 't':   { return (c == NAV_TAB) }
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

    NAVRegexDebug(parser,
                    'MatchCharClass',
                    "'Matching character class => "', charclass, '"'")

    NAVRegexSetPatternCharClassCursor(parser, 'MatchCharClass', 1)

    while (true) {
        c = NAVCharCodeAt(parser.input.value, parser.input.cursor)

        if (NAVRegexMatchRange(parser)) {
            NAVRegexDebug(parser,
                            'MatchCharClass',
                            'Matched range')

            return true
        }

        if (NAVCharCodeAt(charclass, parser.state[parser.pattern.cursor].charclass.cursor) == '\') {
            stack_var char buffer[MAX_CHAR_CLASS_LENGTH]

            NAVRegexDebug(parser,
                            'MatchCharClass',
                            'Escaped character')

            NAVRegexAdvancePatternCharClassCursor(parser, 'MatchCharClass', 1)

            // Extract substring from current cursor position for meta character matching
            buffer = right_string(charclass, length_array(charclass) - parser.state[parser.pattern.cursor].charclass.cursor + 1)

            if (NAVRegexMatchCharClassMetaChar(c, buffer)) {
                NAVRegexDebug(parser,
                                'MatchCharClass',
                                "'Matched meta character => "', c, '"'")

                return true
            }

            if ((NAVCharCodeAt(charclass, parser.state[parser.pattern.cursor].charclass.cursor) == c) && !NAVRegexIsCharClassMetaChar(c)) {
                NAVRegexDebug(parser,
                                'MatchCharClass',
                                "'Yes. Matched character => "', c, '"'")

                return true
            }
        }

        if (NAVCharCodeAt(charclass, parser.state[parser.pattern.cursor].charclass.cursor) == c) {
            NAVRegexDebug(parser,
                            'MatchCharClass',
                            "'Yes. Matched character => "', c, '"'")

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

    NAVRegexDebug(parser,
                    'MatchCharClass',
                    'No. It doesn`t match')

    return false
}


define_function char NAVRegexMatchOne(_NAVRegexParser parser) {
    stack_var integer type
    stack_var char value
    stack_var char c

    if (parser.pattern.cursor > parser.count) {
        NAVRegexDebug(parser,
                        'MatchOne',
                        'Pattern cursor is greater than pattern count')

        return false
    }

    type = parser.state[parser.pattern.cursor].type

    // Check for zero-width assertions first (they don't require a character or valid input position)
    switch (type) {
        case REGEX_TYPE_WORD_BOUNDARY:          { return  NAVRegexMatchWordBoundary(parser) }
        case REGEX_TYPE_NOT_WORD_BOUNDARY:      { return !NAVRegexMatchWordBoundary(parser) }
    }

    if (NAVRegexAtEndOfInput(parser)) {
        NAVRegexDebug(parser,
                        'MatchOne',
                        'Input cursor is greater than input length')

        return false
    }

    value = parser.state[parser.pattern.cursor].value
    c = NAVCharCodeAt(parser.input.value, parser.input.cursor)

    if (!c) {
        NAVRegexDebug(parser,
                        'MatchOne',
                        'The current character is null')

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
        case REGEX_TYPE_HEX:                { return  NAVRegexMatchHex(parser) }
        case REGEX_TYPE_TAB:                { return  (c == NAV_TAB) }
        case REGEX_TYPE_NEWLINE:            { return  (c == NAV_LF) }
        case REGEX_TYPE_RETURN:             { return  (c == NAV_CR) }
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

    NAVRegexDebug(parser,
                    'MatchStar',
                    "'Attempting to match token type ', REGEX_TYPES[parser.state[saved_pattern_cursor - 2].type], ' zero or more times'")

    // Match as many as possible (greedy)
    // Temporarily point to the token we're matching for matchone
    NAVRegexSetPatternCursor(parser, 'MatchStar', saved_pattern_cursor - 2)

    while (NAVRegexCanContinueMatching(parser) && NAVRegexMatchOne(parser)) {
        NAVRegexDebug(parser,
                        'MatchStar',
                        "'Yes. Matched 1 character => "',
                            NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")

        count++
        NAVRegexAdvanceInputCursor(parser, 'MatchStar', 1)
    }

    NAVRegexDebug(parser,
                    'MatchStar',
                    "'Total Matched: ', itoa(count), ' characters'")

    NAVRegexMatchIncreaseLength(parser, 'MatchStar', match, count)

    // Restore pattern cursor to &pattern[2] for the recursive matchpattern calls
    NAVRegexSetPatternCursor(parser, 'MatchStar', saved_pattern_cursor)

    // Backtrack: try matching the rest of the pattern from each position
    // In C: while (text >= prepoint)
    while (parser.input.cursor >= prepoint) {
        if (NAVRegexMatchPattern(parser, match)) {
            NAVRegexDebug(parser,
                            'MatchStar',
                            'Yes. It matches')

            return true
        }

        // Backtrack one character
        NAVRegexMatchDecreaseLength(parser, 'MatchStar', match, 1)
        NAVRegexBacktrackInputCursor(parser, 'MatchStar', 1)

        // Reset pattern cursor for next attempt
        NAVRegexSetPatternCursor(parser, 'MatchStar', saved_pattern_cursor)
    }

    NAVRegexDebug(parser,
                    'MatchStar',
                    'No. It doesn`t match')

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

    NAVRegexDebug(parser,
                    'MatchPlus',
                    "'Attempting to match token type ', REGEX_TYPES[parser.state[saved_pattern_cursor - 2].type], ' one or more times'")

    // Match as many as possible (greedy)
    // Temporarily point to the token we're matching for matchone
    NAVRegexSetPatternCursor(parser, 'MatchPlus', saved_pattern_cursor - 2)

    while (NAVRegexCanContinueMatching(parser) && NAVRegexMatchOne(parser)) {
        NAVRegexDebug(parser,
                        'MatchPlus',
                        "'Yes. Matched 1 character => "',
                            NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")

        count++
        NAVRegexAdvanceInputCursor(parser, 'MatchPlus', 1)
    }

    NAVRegexDebug(parser,
                    'MatchPlus',
                    "'Total Matched: ', itoa(count), ' characters'")

    NAVRegexMatchIncreaseLength(parser, 'MatchPlus', match, count)

    // Restore pattern cursor to &pattern[2] for the recursive matchpattern calls
    NAVRegexSetPatternCursor(parser, 'MatchPlus', saved_pattern_cursor)

    // Backtrack: try matching the rest of the pattern from each position
    // In C: while (text > prepoint) - note the > not >=, because + requires at least one match
    while (parser.input.cursor > prepoint) {
        if (NAVRegexMatchPattern(parser, match)) {
            NAVRegexDebug(parser,
                            'MatchPlus',
                            'Yes. It matches')

            return true
        }

        // Backtrack one character
        NAVRegexMatchDecreaseLength(parser, 'MatchPlus', match, 1)
        NAVRegexBacktrackInputCursor(parser, 'MatchPlus', 1)

        // Reset pattern cursor for next attempt
        NAVRegexSetPatternCursor(parser, 'MatchPlus', saved_pattern_cursor)
    }

    NAVRegexDebug(parser,
                    'MatchPlus',
                    'No. It doesn`t match')

    return false
}


define_function char NAVRegexMatchQuestion(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    // ? matches the previous token between zero and one times
    // This implementation tries ONE first (greedy), then ZERO
    // However, we need to ensure we don't accept a shorter match when a longer one exists

    // p = pattern[0], pattern = &pattern[2], text unchanged, matchlength passed through
    // Pattern cursor has been advanced by 2, so the token to match is at cursor - 2

    stack_var integer saved_pattern_cursor
    stack_var integer saved_input_cursor
    stack_var integer saved_match_length

    // Save the current state
    saved_pattern_cursor = parser.pattern.cursor
    saved_input_cursor = parser.input.cursor
    saved_match_length = match.matches[match.current].length

    // Try matching ONE character first (GREEDY behavior)
    // Need to check the token at cursor - 2 (the token before the ?)
    // In C: if (*text && matchone(p, *text++))

    // Temporarily set pattern cursor to the token to match
    NAVRegexSetPatternCursor(parser, 'MatchQuestion', saved_pattern_cursor - 2)

    if (NAVRegexCanContinueMatching(parser) && NAVRegexMatchOne(parser)) {
        NAVRegexDebug(parser,
                        'MatchQuestion',
                        "'Matched one character => "',
                            NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")

        // Advance input cursor (equivalent to text++)
        NAVRegexAdvanceInputCursor(parser, 'MatchQuestion', 1)

        // Restore pattern cursor to rest of pattern
        NAVRegexSetPatternCursor(parser, 'MatchQuestion', saved_pattern_cursor)

        // Check if rest of pattern is UNUSED (end of pattern) - if so, we're done
        if (NAVRegexAtEndOfPattern(parser)) {
            // Increase match length by 1 for the character we just matched
            NAVRegexMatchIncreaseLength(parser, 'MatchQuestion', match, 1)

            NAVRegexDebug(parser,
                            'MatchQuestion',
                            'Matched one character and reached end of pattern')

            return true
        }

        // Try matching the rest of the pattern
        if (NAVRegexMatchPattern(parser, match)) {
            // Increase match length by 1 for the character we just matched
            NAVRegexMatchIncreaseLength(parser, 'MatchQuestion', match, 1)


            NAVRegexDebug(parser,
                            'MatchQuestion',
                            'Yes. It matches (with one character)')

            return true
        }

        // Matching one character failed, restore state completely
        NAVRegexSetInputCursor(parser, 'MatchQuestion', saved_input_cursor)
        NAVRegexMatchSetLength(parser, 'MatchQuestion', match, saved_match_length)
    }

    // Try matching ZERO instances (rest of pattern without consuming input)
    // Restore pattern cursor
    NAVRegexSetPatternCursor(parser, 'MatchQuestion', saved_pattern_cursor)

    // Check if rest of pattern is UNUSED (end of pattern reached with zero matches)
    if (NAVRegexAtEndOfPattern(parser)) {
        NAVRegexDebug(parser,
                        'MatchQuestion',
                        'Matched zero instances - end of pattern reached')

        return true
    }

    // In C: if (matchpattern(pattern, text, matchlength)) return 1;
    if (NAVRegexMatchPattern(parser, match)) {
        NAVRegexDebug(parser,
                            'MatchQuestion',
                            'Matched zero instances (rest of pattern matched without consuming)')

        return true
    }

    NAVRegexDebug(parser,
                    'MatchQuestion',
                    'No. It doesn`t match')

    return false
}

define_function char NAVRegexMatchBoundedQuantifier(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    // Bounded quantifiers: {n}, {n,}, {n,m}
    // Matches the previous token between min and max times (greedy)
    // NOTE: Pattern cursor is already pointing to &pattern[2] when this is called
    // NOTE: We need to look back at pattern[cursor-2] to get the token to match
    // NOTE: quantifierMin and quantifierMax are stored at pattern[cursor-1]

    stack_var integer prepoint
    stack_var integer count
    stack_var sinteger minCount
    stack_var sinteger maxCount
    stack_var integer saved_pattern_cursor

    prepoint = parser.input.cursor

    // Save the pattern cursor (already at &pattern[2])
    saved_pattern_cursor = parser.pattern.cursor

    // Get the min and max counts from the quantifier token at cursor-1
    minCount = parser.state[saved_pattern_cursor - 1].quantifierMin
    maxCount = parser.state[saved_pattern_cursor - 1].quantifierMax

    NAVRegexDebug(parser,
                    'MatchBoundedQuantifier',
                    "'Attempting to match token type ', REGEX_TYPES[parser.state[saved_pattern_cursor - 2].type],
                     ' between ', itoa(minCount), ' and ',
                     itoa(maxCount), ' times (', itoa(maxCount == -1), ' = unlimited)'")

    // Match as many as possible (greedy), up to maxCount (or unlimited if maxCount == -1)
    // Temporarily point to the token we're matching for matchone
    NAVRegexSetPatternCursor(parser, 'MatchBoundedQuantifier', saved_pattern_cursor - 2)

    count = 0
    while (NAVRegexCanContinueMatching(parser) &&
           (maxCount == -1 || count < type_cast(maxCount)) &&
           NAVRegexMatchOne(parser)) {
        NAVRegexDebug(parser,
                        'MatchBoundedQuantifier',
                        "'Yes. Matched character ', itoa(count + 1), ' => "',
                            NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")

        count++
        NAVRegexAdvanceInputCursor(parser, 'MatchBoundedQuantifier', 1)
    }

    NAVRegexDebug(parser,
                    'MatchBoundedQuantifier',
                    "'Total Matched: ', itoa(count), ' characters (min=', itoa(minCount), ', max=', itoa(maxCount), ')'")

    // Check if we matched at least minCount
    if (count < type_cast(minCount)) {
        NAVRegexDebug(parser,
                        'MatchBoundedQuantifier',
                        "'Failed: matched only ', itoa(count), ' but need at least ', itoa(minCount)")

        return false
    }

    NAVRegexMatchIncreaseLength(parser, 'MatchBoundedQuantifier', match, count)

    // Restore pattern cursor to &pattern[2] for the recursive matchpattern calls
    NAVRegexSetPatternCursor(parser, 'MatchBoundedQuantifier', saved_pattern_cursor)

    // Backtrack: try matching the rest of the pattern from each position
    // Start from current position (greedy: matched as many as possible)
    // Go down to minCount (the minimum required)
    while (count >= type_cast(minCount)) {
        NAVRegexDebug(parser,
                        'MatchBoundedQuantifier',
                        "'Trying to match rest of pattern with ', itoa(count), ' characters consumed'")

        if (NAVRegexMatchPattern(parser, match)) {
            NAVRegexDebug(parser,
                            'MatchBoundedQuantifier',
                            "'Yes. It matches with ', itoa(count), ' repetitions'")

            return true
        }

        // Backtrack one character (if we haven't reached minCount yet)
        if (count > type_cast(minCount)) {
            NAVRegexMatchDecreaseLength(parser, 'MatchBoundedQuantifier', match, 1)
            NAVRegexBacktrackInputCursor(parser, 'MatchBoundedQuantifier', 1)
            count--

            // Reset pattern cursor for next attempt
            NAVRegexSetPatternCursor(parser, 'MatchBoundedQuantifier', saved_pattern_cursor)
        }
        else {
            // Reached minCount, can't backtrack further
            break
        }
    }

    NAVRegexDebug(parser,
                    'MatchBoundedQuantifier',
                    'No. It doesn`t match')

    return false
}


/**
 * Handle group start - initialize tracking for a capturing group
 */
define_function integer NAVRegexMatchGroupStart(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    stack_var integer tokenIdx
    stack_var integer groupIdx
    stack_var integer matchIdx
    stack_var integer i

    tokenIdx = parser.pattern.cursor

    // Find which group this token belongs to
    groupIdx = NAVRegexFindGroupByStartToken(parser, tokenIdx)

    if (groupIdx == 0) {
        NAVRegexDebug(parser, 'MatchGroupStart', "'ERROR: Could not find group info for token ', itoa(tokenIdx)")
        return 0
    }

    // Only process capturing groups
    if (!parser.groupInfo[groupIdx].isCapturing) {
        NAVRegexDebug(parser,
                        'MatchGroupStart',
                        "'Non-capturing group at token ', itoa(tokenIdx), ' - skipping'")
        return 0
    }

    // Calculate the match index for this group
    // match.matches[1] is the full match
    // match.matches[2] is group 1, match.matches[3] is group 2, etc.
    matchIdx = 1 + parser.groupInfo[groupIdx].number

    NAVRegexDebug(parser,
                    'MatchGroupStart',
                    "'Entering capturing group #', itoa(parser.groupInfo[groupIdx].number),
                     ' (matchIdx=', itoa(matchIdx), ') at position ', itoa(parser.input.cursor)")

    // Store the start position for this group
    match.matches[matchIdx].start = parser.input.cursor

    // Update match count if this is a new group
    if (matchIdx > match.count) {
        match.count = matchIdx
    }

    return parser.groupInfo[groupIdx].number
}


/**
 * Handle group end - extract the captured text for the group
 */
define_function char NAVRegexMatchGroupEnd(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    stack_var integer tokenIdx
    stack_var integer groupIdx
    stack_var integer matchIdx
    stack_var integer groupStart
    stack_var integer groupEnd
    stack_var integer groupLength
    stack_var integer i

    tokenIdx = parser.pattern.cursor

    // Find which group this token belongs to
    groupIdx = NAVRegexFindGroupByEndToken(parser, tokenIdx)

    if (groupIdx == 0) {
        NAVRegexDebug(parser, 'MatchGroupEnd', "'ERROR: Could not find group info for token ', itoa(tokenIdx)")
        return false
    }

    // Only process capturing groups
    if (!parser.groupInfo[groupIdx].isCapturing) {
        NAVRegexDebug(parser,
                        'MatchGroupEnd',
                        "'Non-capturing group at token ', itoa(tokenIdx), ' - skipping'")
        return true
    }

    // Calculate the match index for this group
    matchIdx = 1 + parser.groupInfo[groupIdx].number

    groupStart = match.matches[matchIdx].start
    groupEnd = parser.input.cursor
    groupLength = groupEnd - groupStart

    NAVRegexDebug(parser,
                    'MatchGroupEnd',
                    "'Closing capturing group #', itoa(parser.groupInfo[groupIdx].number),
                     ' (matchIdx=', itoa(matchIdx), ') - start:', itoa(groupStart), ' end:', itoa(groupEnd), ' length:', itoa(groupLength)")

    // Extract the captured text
    if (groupLength > 0) {
        match.matches[matchIdx].text = NAVStringSlice(parser.input.value, groupStart, groupEnd)  // NAVStringSlice end is exclusive
    }
    else {
        match.matches[matchIdx].text = ''
    }

    match.matches[matchIdx].length = groupLength
    match.matches[matchIdx].end = groupEnd    NAVRegexDebug(parser,
                    'MatchGroupEnd',
                    "'Captured text: "', match.matches[matchIdx].text, '"'")

    return true
}


/**
 * Handle quantified groups - matches a group pattern multiple times based on quantifier
 * This is called when we encounter GROUP_END followed by a quantifier (+, *, ?, {n,m})
 * NOTE: When this is called, we've already matched the group content ONCE (that's why we're at GROUP_END)
 */
define_function char NAVRegexMatchQuantifiedGroup(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    stack_var integer quantifierType
    stack_var integer groupEndToken
    stack_var integer groupStartToken
    stack_var integer groupIdx
    stack_var integer i
    stack_var integer savedPatternCursor
    stack_var integer preMatchLength
    stack_var integer matchCount
    stack_var integer minMatches
    stack_var integer maxMatches
    stack_var integer totalConsumed
    stack_var char matchFailed
    stack_var integer firstMatchStart
    stack_var integer firstMatchEnd
    stack_var integer lastMatchStart
    stack_var integer lastMatchEnd

    // Save current state
    savedPatternCursor = parser.pattern.cursor  // Currently at GROUP_END
    preMatchLength = match.matches[match.current].length

    groupEndToken = parser.pattern.cursor
    quantifierType = parser.state[parser.pattern.cursor + 1].type

    // Find the matching GROUP_START for this GROUP_END
    groupIdx = NAVRegexFindGroupByEndToken(parser, groupEndToken)

    if (groupIdx > 0) {
        groupStartToken = parser.groupInfo[groupIdx].startToken
    }

    if (groupIdx == 0) {
        NAVRegexDebug(parser, 'MatchQuantifiedGroup', "'ERROR: Could not find group for token ', itoa(groupEndToken)")
        return false
    }

    NAVRegexDebug(parser,
                    'MatchQuantifiedGroup',
                    "'Matching quantified group #', itoa(groupIdx), ' with quantifier type ', REGEX_TYPES[quantifierType]")

    // Determine min/max matches based on quantifier type
    switch (quantifierType) {
        case REGEX_TYPE_PLUS:        { minMatches = 1; maxMatches = 999; }  // + : 1 or more
        case REGEX_TYPE_STAR:        { minMatches = 0; maxMatches = 999; }  // * : 0 or more
        case REGEX_TYPE_QUESTIONMARK: { minMatches = 0; maxMatches = 1; }   // ? : 0 or 1
        case REGEX_TYPE_QUANTIFIER: {
            // Bounded quantifier: {n}, {n,}, {n,m}
            // Extract min and max from the quantifier token at cursor + 1
            minMatches = type_cast(parser.state[parser.pattern.cursor + 1].quantifierMin)
            if (parser.state[parser.pattern.cursor + 1].quantifierMax == -1) {
                maxMatches = 999  // Unlimited
            }
            else {
                maxMatches = type_cast(parser.state[parser.pattern.cursor + 1].quantifierMax)
            }

            NAVRegexDebug(parser,
                          'MatchQuantifiedGroup',
                          "'Bounded quantifier: min=', itoa(minMatches), ', max=', itoa(maxMatches)")
        }
        default: {
            NAVRegexDebug(parser, 'MatchQuantifiedGroup', "'Unsupported quantifier type: ', REGEX_TYPES[quantifierType]")
            return false
        }
    }

    // We've already matched the group content ONCE (from GROUP_START to GROUP_END)
    // Track where this first match started
    // For capturing groups, get it from match.matches. For non-capturing groups,
    // get it from the temporary storage in match.matches[255]
    if (parser.groupInfo[groupIdx].isCapturing) {
        firstMatchStart = match.matches[1 + parser.groupInfo[groupIdx].number].start
    }
    else {
        firstMatchStart = match.matches[255].start
    }

    // Check if the group consumed any input
    if (firstMatchStart == parser.input.cursor) {
        // Group matched but consumed ZERO characters
        // For optional quantifiers (? or *), treat this as zero matches
        matchCount = 0
        lastMatchStart = firstMatchStart
        lastMatchEnd = firstMatchStart

        NAVRegexDebug(parser,
                        'MatchQuantifiedGroup',
                        "'Group consumed zero characters - treating as zero matches'")
    }
    else {
        // Group consumed at least one character
        matchCount = 1
        lastMatchStart = firstMatchStart
        lastMatchEnd = parser.input.cursor
        firstMatchEnd = parser.input.cursor  // Save the end of the first match

        NAVRegexDebug(parser,
                        'MatchQuantifiedGroup',
                        "'Already matched group once from position ', itoa(firstMatchStart), ' to ', itoa(lastMatchEnd)")
    }

    // Try to match ADDITIONAL repetitions of the group content
    matchFailed = false

    while (!matchFailed && matchCount < maxMatches && NAVRegexCanContinueMatching(parser)) {
        stack_var integer groupMatchStart
        stack_var integer groupMatchEnd
        stack_var integer j

        groupMatchStart = parser.input.cursor

        // Try to match the group content (from START+1 to END-1)
        NAVRegexSetPatternCursor(parser, 'MatchQuantifiedGroup', groupStartToken + 1)

        // Match until we hit the GROUP_END token
        for (j = groupStartToken + 1; j < groupEndToken; j++) {
            if (NAVRegexAtEndOfInput(parser)) {
                // Ran out of input before completing group match
                NAVRegexSetInputCursor(parser, 'MatchQuantifiedGroup', groupMatchStart)
                matchFailed = true
                break
            }

            if (!NAVRegexMatchOne(parser)) {
                // Failed to match - restore input position
                NAVRegexSetInputCursor(parser, 'MatchQuantifiedGroup', groupMatchStart)
                matchFailed = true
                break
            }

            // Matched one character
            NAVRegexAdvanceInputCursor(parser, 'MatchQuantifiedGroup', 1)
            NAVRegexAdvancePatternCursor(parser, 'MatchQuantifiedGroup', 1)
        }

        if (!matchFailed) {
            // Successfully matched another iteration of the group content
            matchCount++
            groupMatchEnd = parser.input.cursor

            // Track the last match for group capture (capturing groups capture the LAST iteration)
            lastMatchStart = groupMatchStart
            lastMatchEnd = groupMatchEnd

            NAVRegexDebug(parser,
                            'MatchQuantifiedGroup',
                            "'Matched group iteration #', itoa(matchCount), ' consuming ', itoa(groupMatchEnd - groupMatchStart), ' characters'")
        }
    }

    NAVRegexDebug(parser,
                    'MatchQuantifiedGroup',
                    "'Total group matches: ', itoa(matchCount), ' (min=', itoa(minMatches), ', max=', itoa(maxMatches), ')'")

    // Check if we met the minimum requirement
    if (matchCount < minMatches) {
        // Failed to meet minimum - restore state and fail
        NAVRegexMatchSetLength(parser, 'MatchQuantifiedGroup', match, preMatchLength)
        return false
    }

    // Success! Extract the captured group text (last iteration for capturing groups)
    if (parser.groupInfo[groupIdx].isCapturing) {
        stack_var integer matchIdx
        stack_var integer captureLength

        matchIdx = 1 + parser.groupInfo[groupIdx].number
        captureLength = lastMatchEnd - lastMatchStart

        if (captureLength > 0) {
            match.matches[matchIdx].text = NAVStringSlice(parser.input.value, lastMatchStart, lastMatchEnd)
        }
        else {
            match.matches[matchIdx].text = ''
        }

        match.matches[matchIdx].length = captureLength
        match.matches[matchIdx].end = lastMatchEnd

        NAVRegexDebug(parser,
                        'MatchQuantifiedGroup',
                        "'Captured group text: "', match.matches[matchIdx].text, '"'")
    }

    // Update the overall match length with ADDITIONAL characters consumed
    // The first group match is already included in preMatchLength
    // We only need to add the characters consumed by additional matches
    totalConsumed = parser.input.cursor - firstMatchStart
    if (firstMatchEnd > 0) {
        // Add only the additional characters beyond the first match
        stack_var integer firstMatchLength
        stack_var integer additionalConsumed
        firstMatchLength = firstMatchEnd - firstMatchStart
        additionalConsumed = totalConsumed - firstMatchLength
        NAVRegexMatchIncreaseLength(parser, 'MatchQuantifiedGroup', match, additionalConsumed)
    }
    else {
        // No first match (matchCount was 0), so totalConsumed is 0
        // Don't modify length
    }

    // Advance pattern cursor past GROUP_END and quantifier
    NAVRegexSetPatternCursor(parser, 'MatchQuantifiedGroup', savedPatternCursor + 2)

    // Try to match the rest of the pattern
    if (NAVRegexMatchPattern(parser, match)) {
        return true
    }

    // TODO: Implement backtracking - try with fewer group matches
    // For now, just fail
    NAVRegexMatchSetLength(parser, 'MatchQuantifiedGroup', match, preMatchLength)
    return false
}

define_function char NAVRegexMatchPattern(_NAVRegexParser parser, _NAVRegexMatchResult match) {
    stack_var integer pre

    // Save the current match length (used for backtracking)
    pre = NAVRegexMatchGetLength(match)

    // Main matching loop - equivalent to do-while in C
    while (true) {
        // Check if pattern[0].type == UNUSED (end of pattern)
        if (NAVRegexAtEndOfPattern(parser)) {
            NAVRegexDebug(parser,
                            'MatchPattern',
                            'Pattern UNUSED - match successful')

            return true
        }

        // Handle group start/end tokens BEFORE quantifier checks
        // Groups are zero-width markers and must be processed first
        if (NAVRegexIsGroupStart(parser.state[parser.pattern.cursor].type)) {
            stack_var integer groupIdx
            stack_var integer groupEndToken
            stack_var integer i
            stack_var char isQuantified
            stack_var integer quantifierType
            stack_var char groupQuantifierType
            stack_var sinteger groupQuantifierMin
            stack_var sinteger groupQuantifierMax

            NAVRegexDebug(parser,
                            'MatchPattern',
                            "'Group start token at pattern[', itoa(parser.pattern.cursor), ']'")

            // Read quantifier info directly from GROUP_START token (Phase 4)
            // This info was pre-computed by the compiler in Phases 2 & 3
            groupQuantifierType = parser.state[parser.pattern.cursor].groupQuantifierType
            groupQuantifierMin = parser.state[parser.pattern.cursor].groupQuantifierMin
            groupQuantifierMax = parser.state[parser.pattern.cursor].groupQuantifierMax

            #IF_DEFINED REGEX_MATCH_DEBUG
            NAVLog("'[ Match ]: GROUP_START quantifier info: type=', itoa(groupQuantifierType), ' min=', itoa(groupQuantifierMin), ' max=', itoa(groupQuantifierMax)")
            #END_IF

            // Find which group this is and check if it's quantified
            groupIdx = NAVRegexFindGroupByStartToken(parser, parser.pattern.cursor)

            if (groupIdx > 0) {
                groupEndToken = parser.groupInfo[groupIdx].endToken
            }

            if (groupIdx > 0) {
                quantifierType = parser.state[groupEndToken + 1].type

                // Check if the token after GROUP_END is a quantifier
                if (NAVRegexIsQuantifier(quantifierType)) {
                    isQuantified = true
                }
            }

            // For all groups (optional or not), just record the start and continue
            // The quantified group handler will deal with optional groups properly

            // Record group start
            NAVRegexMatchGroupStart(parser, match)

            // For non-capturing groups, store the start position in match.matches[255] temporarily
            // so NAVRegexMatchQuantifiedGroup can access it later
            if (groupIdx > 0 && !parser.groupInfo[groupIdx].isCapturing) {
                match.matches[255].start = parser.input.cursor
            }

            // Phase 5: Store GROUP_START info for optional group skip logic (NO LOOKBEHIND!)
            // When next token fails to match, we can check if we just entered an optional group
            parser.lastGroupStartToken = parser.pattern.cursor
            parser.lastGroupMin = groupQuantifierMin
            parser.lastGroupEndToken = groupEndToken

            // Advance pattern cursor only (groups don't consume characters)
            NAVRegexAdvancePatternCursor(parser, 'MatchPattern', 1)
            continue
        }

        if (NAVRegexIsGroupEnd(parser.state[parser.pattern.cursor].type)) {
            NAVRegexDebug(parser,
                            'MatchPattern',
                            "'Group end token at pattern[', itoa(parser.pattern.cursor), ']'")

            // Check if next token is a quantifier
            if (NAVRegexNextTokenIsQuantifier(parser)) {
                // Quantified group - DON'T extract group text yet
                // Let NAVRegexMatchQuantifiedGroup handle text extraction
                NAVRegexDebug(parser,
                                'MatchPattern',
                                "'Group end followed by quantifier - calling NAVRegexMatchQuantifiedGroup'")
                return NAVRegexMatchQuantifiedGroup(parser, match)
            }
            else {
                // Normal non-quantified group - extract text now
                NAVRegexMatchGroupEnd(parser, match)

                // Advance and continue
                NAVRegexAdvancePatternCursor(parser, 'MatchPattern', 1)

                // Check if we've reached end of pattern
                if (NAVRegexAtEndOfPattern(parser)) {
                    return true
                }

                continue
            }
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

        // Check if pattern[1].type == QUANTIFIER (bounded quantifiers {n}, {n,}, {n,m})
        // Call matchboundedquantifier with p=pattern[0], pattern=&pattern[2]
        if (parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_QUANTIFIER) {
            // Advance pattern cursor by 2 to point to &pattern[2] before calling
            NAVRegexAdvancePatternCursor(parser, 'MatchPattern', 2)
            return NAVRegexMatchBoundedQuantifier(parser, match)
        }

        // Check if pattern[0].type == END and pattern[1].type == UNUSED
        if (parser.state[parser.pattern.cursor].type == REGEX_TYPE_END &&
            parser.state[parser.pattern.cursor + 1].type == REGEX_TYPE_UNUSED) {
            NAVRegexDebug(parser,
                            'MatchPattern',
                            'END anchor - checking if at end of text')

            // In C: return (text[0] == '\0')
            return NAVRegexAtEndOfInput(parser)
        }

        // Default case: try to match one character
        // In C: while ((text[0] != '\0') && matchone(*pattern++, *text++))

        // Check if we've reached end of text
        // BUT: Allow zero-width assertions (word boundaries) to be checked even at end of input
        if (NAVRegexAtEndOfInput(parser)) {
            stack_var integer nextType
            nextType = NAVRegexGetCurrentTokenType(parser)

            // Only continue if next token is a zero-width assertion
            if (!NAVRegexIsZeroWidthAssertion(nextType)) {
                break
            }
        }

        #IF_DEFINED REGEX_MATCHER_DEBUG
        NAVRegexPrintCurrentState(parser, 'MatchPattern')
        #END_IF

        // Try to match current character with current pattern
        if (NAVRegexMatchOne(parser)) {
            stack_var integer currentType

            currentType = parser.state[parser.pattern.cursor].type

            // Check if this is a zero-width assertion (doesn't consume characters)
            if (NAVRegexIsZeroWidthAssertion(currentType)) {
                NAVRegexDebug(parser,
                                'MatchPattern',
                                'Matched zero-width assertion (word boundary)')

                // Only advance pattern cursor, not input cursor or match length
                NAVRegexAdvancePatternCursor(parser, 'MatchPattern', 1)
            }
            else {
                NAVRegexDebug(parser,
                                'MatchPattern',
                                "'Yes. Matched 1 character => "',
                                    NAVCharCodeAt(parser.input.value, parser.input.cursor), '" P(', itoa(parser.input.cursor), ')'")

                // Increment matchlength, advance both pattern and text
                NAVRegexMatchIncreaseLength(parser, 'MatchPattern', match, 1)
                NAVRegexAdvanceInputCursor(parser, 'MatchPattern', 1)
                NAVRegexAdvancePatternCursor(parser, 'MatchPattern', 1)
            }

            continue
        }

        // Match failed - check if we just entered an optional quantified group
        // If so, skip the group instead of failing the whole pattern
        // Phase 5: NO LOOKBEHIND - use stored GROUP_START info from when we entered the group
        {
            // Check if we just entered a group (pattern cursor immediately after last GROUP_START)
            if (parser.lastGroupStartToken > 0 &&
                parser.pattern.cursor == parser.lastGroupStartToken + 1) {

                // Check if that group is optional (min = 0)
                if (parser.lastGroupMin == 0) {
                    // This group is optional (?, *, or {0,n})
                    // Skip past GROUP_END and quantifier
                    NAVRegexDebug(parser,
                                    'MatchPattern',
                                    "'First token in optional group failed - skipping group'")

                    NAVRegexSetPatternCursor(parser, 'MatchPattern', parser.lastGroupEndToken + 2)

                    // Clear the stored GROUP_START info
                    parser.lastGroupStartToken = 0
                    continue
                }
            }
        }

        // Match failed
        break
    }

    // Restore match length and return false
    NAVRegexDebug(parser,
                    'MatchPattern',
                    'No. It doesn`t match')

    NAVRegexMatchSetLength(parser, 'MatchPattern', match, pre)

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
        stack_var integer matchStart
        stack_var integer matchEnd
        stack_var integer matchLength

        NAVRegexSetPatternCursor(parser, 'MatchCompiled', 2)
        NAVRegexSetInputCursor(parser, 'MatchCompiled', 1)
        NAVRegexMatchSetStart(parser, 'MatchCompiled', match, 1)

        if (NAVRegexMatchPattern(parser, match)) {
            // Extract the full match text
            matchStart = match.matches[1].start
            matchLength = match.matches[1].length
            matchEnd = matchStart + matchLength  // NAVStringSlice end is exclusive

            if (matchLength > 0) {
                match.matches[1].text = NAVStringSlice(parser.input.value, matchStart, matchEnd)
                match.matches[1].end = matchEnd
            }
            else {
                match.matches[1].text = ''
                match.matches[1].end = matchStart
            }

            // Ensure match.count includes at least the full match
            if (match.count == 0) {
                match.count = 1
            }

            return true
        }

        return false
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
            stack_var integer matchStart
            stack_var integer matchEnd
            stack_var integer matchLength

            // In C: if (text[0] == '\0') return -1;
            // This checks if we matched starting at the null terminator (past all chars)
            // For empty string (length=0), idx=1 is valid
            // For non-empty string, idx should not be > length
            if (parser.input.length > 0 && idx > parser.input.length) {
                return false
            }

            // Extract the full match text (match.matches[1])
            matchStart = match.matches[1].start
            matchLength = match.matches[1].length
            matchEnd = matchStart + matchLength  // NAVStringSlice end is exclusive, so don't subtract 1

            if (matchLength > 0) {
                match.matches[1].text = NAVStringSlice(parser.input.value, matchStart, matchEnd)
                match.matches[1].end = matchEnd
            }
            else {
                match.matches[1].text = ''
                match.matches[1].end = matchStart
            }

            // Ensure match.count includes at least the full match
            if (match.count == 0) {
                match.count = 1
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


define_function integer NAVRegexPeekTokenType(_NAVRegexParser parser, integer offset) {
    if (parser.pattern.cursor + offset > parser.count) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX_MATCHER__,
                                    'NAVRegexPeekTokenType',
                                    "'Pattern cursor + offset out of bounds: ', itoa(parser.pattern.cursor + offset)")
        return 0
    }

    return parser.state[parser.pattern.cursor + offset].type
}


define_function integer NAVRegexPeekNextTokenType(_NAVRegexParser parser) {
    return NAVRegexPeekTokenType(parser, 1)
}


/**
 * Check if a token type is a quantifier (?, *, +, or {n,m})
 */
define_function char NAVRegexIsQuantifier(integer tokenType) {
    return (tokenType == REGEX_TYPE_QUESTIONMARK ||
            tokenType == REGEX_TYPE_STAR ||
            tokenType == REGEX_TYPE_PLUS ||
            tokenType == REGEX_TYPE_QUANTIFIER)
}


/**
 * Check if the next token in the pattern is a quantifier
 */
define_function char NAVRegexNextTokenIsQuantifier(_NAVRegexParser parser) {
    return NAVRegexIsQuantifier(NAVRegexPeekNextTokenType(parser))
}


/**
 * Check if a token type is a group start marker
 */
define_function char NAVRegexIsGroupStart(integer tokenType) {
    return (tokenType == REGEX_TYPE_GROUP_START ||
            tokenType == REGEX_TYPE_NON_CAPTURE_GROUP_START)
}


/**
 * Check if a token type is a group end marker
 */
define_function char NAVRegexIsGroupEnd(integer tokenType) {
    return (tokenType == REGEX_TYPE_GROUP_END ||
            tokenType == REGEX_TYPE_NON_CAPTURE_GROUP_END)
}


/**
 * Check if a token type is a zero-width assertion
 */
define_function char NAVRegexIsZeroWidthAssertion(integer tokenType) {
    return (tokenType == REGEX_TYPE_WORD_BOUNDARY ||
            tokenType == REGEX_TYPE_NOT_WORD_BOUNDARY)
}


/**
 * Get the type of the current token in the pattern
 */
define_function integer NAVRegexGetCurrentTokenType(_NAVRegexParser parser) {
    return parser.state[parser.pattern.cursor].type
}


/**
 * Check if we've reached the end of the pattern (UNUSED token)
 */
define_function char NAVRegexAtEndOfPattern(_NAVRegexParser parser) {
    return (NAVRegexGetCurrentTokenType(parser) == REGEX_TYPE_UNUSED)
}


/**
 * Check if we've reached the end of the input text
 */
define_function char NAVRegexAtEndOfInput(_NAVRegexParser parser) {
    return (parser.input.cursor > parser.input.length)
}


/**
 * Check if we can continue matching (input not exhausted)
 */
define_function char NAVRegexCanContinueMatching(_NAVRegexParser parser) {
    return (parser.input.cursor <= parser.input.length)
}


(***********************************************************)
(*               GROUP LOOKUP HELPERS                       *)
(***********************************************************)

/**
 * Find a group by its start token index
 *
 * @param parser - The regex parser structure
 * @param tokenIdx - The token index to search for
 * @return The group index (1-based) or 0 if not found
 */
define_function integer NAVRegexFindGroupByStartToken(_NAVRegexParser parser, integer tokenIdx) {
    stack_var integer i

    for (i = 1; i <= parser.groupTotal; i++) {
        if (parser.groupInfo[i].startToken == tokenIdx) {
            return i
        }
    }

    return 0
}

/**
 * Find a group by its end token index
 *
 * @param parser - The regex parser structure
 * @param tokenIdx - The token index to search for
 * @return The group index (1-based) or 0 if not found
 */
define_function integer NAVRegexFindGroupByEndToken(_NAVRegexParser parser, integer tokenIdx) {
    stack_var integer i

    for (i = 1; i <= parser.groupTotal; i++) {
        if (parser.groupInfo[i].endToken == tokenIdx) {
            return i
        }
    }

    return 0
}


#END_IF // __NAV_FOUNDATION_REGEX_MATCHER__
