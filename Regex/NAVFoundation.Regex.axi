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
 *  Largely based on the tiny-regex-c library by kokke
 *  https://github.com/kokke/tiny-regex-c
 *
 *  Adapted for use in NetLinx
 */


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX__
#DEFINE __NAV_FOUNDATION_REGEX__ 'NAVFoundation.Regex'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.h.axi'


define_function char NAVRegexMatch(char pattern[], char buffer[], _NAVRegexMatchResult match) {
    stack_var _NAVRegexState state[MAX_REGEXP_OBJECTS]

    if (!NAVRegexCompile(pattern, state)) {
        return false
    }

    return NAVRegexMatchCompiled(state, buffer, match)
}


define_function char NAVRegexMatchCompiled(_NAVRegexState state[], char buffer[], _NAVRegexMatchResult match) {
    stack_var integer index

    match.length = 0

    if (state[1].type == REGEX_TYPE_BEGIN) {
        NAVLog("'NAVRegexMatchCompiled: ', 'REGEX_TYPE_BEGIN'")
        return NAVRegexMatchPattern(state, buffer, match)
    }

    index = 1

    while (true) {
        if (NAVRegexMatchPattern(state, NAVStringSlice(buffer, index, 0), match)) {
            return true
        }

        index++

        if (index >= length_array(buffer)) {
            break
        }
    }

    return false
}


define_function char NAVRegexCompile(char pattern[], _NAVRegexState state[MAX_REGEXP_OBJECTS]) {
    stack_var char c
    stack_var integer i
    stack_var integer j

    stack_var integer pattern_length

    pattern_length = length_array(pattern)

    c = 0
    i = 0
    j = 0

    while ((i + 1) <= pattern_length && ((j + 1) < MAX_REGEXP_OBJECTS)) {
        c = NAVCharCodeAt(pattern, (i + 1))

        switch (c) {
            case '^': { state[(j + 1)].type = REGEX_TYPE_BEGIN }
            case '$': { state[(j + 1)].type = REGEX_TYPE_END }
            case '.': { state[(j + 1)].type = REGEX_TYPE_DOT }
            case '*': { state[(j + 1)].type = REGEX_TYPE_STAR }
            case '+': { state[(j + 1)].type = REGEX_TYPE_PLUS }
            case '?': { state[(j + 1)].type = REGEX_TYPE_QUESTIONMARK }
            // case '|': { state[(j + 1)].type = REGEX_TYPE_BRANCH }  // Not working properly

            case '\': {
                if ((i + 2) <= pattern_length) {
                    i++

                    switch (NAVCharCodeAt(pattern, (i + 1))) {
                        case 'd': { state[(j + 1)].type = REGEX_TYPE_DIGIT }
                        case 'D': { state[(j + 1)].type = REGEX_TYPE_NOT_DIGIT }
                        case 'w': { state[(j + 1)].type = REGEX_TYPE_ALPHA }
                        case 'W': { state[(j + 1)].type = REGEX_TYPE_NOT_ALPHA }
                        case 's': { state[(j + 1)].type = REGEX_TYPE_WHITESPACE }
                        case 'S': { state[(j + 1)].type = REGEX_TYPE_NOT_WHITESPACE }
                        default: {
                            state[(j + 1)].type = REGEX_TYPE_CHAR
                            state[(j + 1)].value = NAVCharCodeAt(pattern, (i + 1))
                        }
                    }
                }
            }

            // case '{': {}
            // case '(': {}
            case '[': {
                stack_var char charclass[MAX_CHAR_CLASS_LENGTH]
                stack_var integer class_length

                class_length = 0

                if (NAVCharCodeAt(pattern, (i + 2)) == '^') {
                    state[(j + 1)].type = REGEX_TYPE_INV_CHAR_CLASS
                    i++

                    if (NAVCharCodeAt(pattern, (i + 2)) == 0) {
                        return false
                    }
                }
                else {
                    state[(j + 1)].type = REGEX_TYPE_CHAR_CLASS
                }

                i++
                while ((NAVCharCodeAt(pattern, (i + 1)) != ']') && ((i + 1) <= pattern_length)) {
                    stack_var char code

                    code = NAVCharCodeAt(pattern, (i + 1))

                    if (code == '\') {
                        if (class_length > (MAX_CHAR_CLASS_LENGTH - 1)) {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                        __NAV_FOUNDATION_REGEX__,
                                                        'NAVRegexCompile',
                                                        "'Character class exceeded maximum length'")
                            return false
                        }

                        if (NAVCharCodeAt(pattern, (i + 2)) == 0) {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                        __NAV_FOUNDATION_REGEX__,
                                                        'NAVRegexCompile',
                                                        "'Incomplete pattern. Missing non-zero character after \'")
                            return false
                        }

                        charclass = "charclass, code"
                        i++
                    }
                    else if (class_length > MAX_CHAR_CLASS_LENGTH) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX__,
                                                    'NAVRegexCompile',
                                                    "'Character class exceeded maximum length'")
                        return false
                    }

                    charclass = "charclass, code"
                    class_length = length_array(charclass)
                    i++
                }

                if (class_length > MAX_CHAR_CLASS_LENGTH) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Character class exceeded maximum length'")
                    return false
                }

                state[(j + 1)].charclass = charclass
                set_length_array(state[(j + 1)].charclass, class_length)
            }

            default: {
                state[(j + 1)].type = REGEX_TYPE_CHAR
                state[(j + 1)].value = c
            }
        }

        // if (NAVCharCodeAt(pattern, (i + 1)) == 0) {
        //     NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Error 1'")
        //     return -1
        // }

        i++
        j++
    }

    state[(j + 1)].type = REGEX_TYPE_UNUSED
    set_length_array(state, (j + 1))

    return true
}


define_function re_print(_NAVRegexState state[]) {
    stack_var integer i
    stack_var integer j
    stack_var char c
    stack_var integer length

    length = length_array(state)

    for (i = 0; i < length; i++) {
        stack_var char message[255]

        if (state[(i + 1)].type == REGEX_TYPE_UNUSED) {
            break
        }

        message = "'type: ', REGEX_TYPES[state[(i + 1)].type]"

        if (state[(i + 1)].type == REGEX_TYPE_CHAR_CLASS || state[(i + 1)].type == REGEX_TYPE_INV_CHAR_CLASS) {
            message = "message, ' ['"

            for (j = 0; j < length_array(state[(i + 1)].charclass); j++) {
                c = NAVCharCodeAt(state[(i + 1)].charclass, (j + 1))

                if ((c == 0) || (c == ']')) {
                    break
                }

                message = "message, c"
            }

            message = "message, ']'"
        }
        else if (state[(i + 1)].type == REGEX_TYPE_CHAR) {
            message = "message, ' ', state[(i + 1)].value"
        }

        NAVLog(message)
    }
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


define_function char NAVRegexMatchRange(char c, char buffer[]) {
    return (
        (c != '-') &&
        (NAVCharCodeAt(buffer, 1) != 0) &&
        (NAVCharCodeAt(buffer, 1) != '-') &&
        (NAVCharCodeAt(buffer, 2) == '-') &&
        (NAVCharCodeAt(buffer, 3) != 0) &&
        ((c >= NAVCharCodeAt(buffer, 1)) && (c <= NAVCharCodeAt(buffer, 3)))
    )
}


define_function char NAVRegexMatchDot(char c) {
    return (c != NAV_CR && c != NAV_LF)
}


define_function char NAVRegexIsMetaChar(char c) {
    return (
        (c == 's') ||
        (c == 'S') ||
        (c == 'w') ||
        (c == 'W') ||
        (c == 'd') ||
        (c == 'D')
    )
}


define_function char NAVRegexMatchMetaChar(char c, char buffer[]) {
    switch (NAVCharCodeAt(buffer, 1)) {
        case 'd':   { return  NAVRegexMatchDigit(c) }
        case 'D':   { return !NAVRegexMatchDigit(c) }
        case 'w':   { return  NAVRegexMatchAlphaNumeric(c) }
        case 'W':   { return !NAVRegexMatchAlphaNumeric(c) }
        case 's':   { return  NAVRegexMatchWhitespace(c) }
        case 'S':   { return !NAVRegexMatchWhitespace(c) }
        default:    { return (c == NAVCharCodeAt(buffer, 1)) }
    }
}


define_function char NAVRegexMatchCharClass(char c, char buffer[]) {
    stack_var integer i
    stack_var integer length

    length = length_array(buffer)

    i = 1

    while (true) {
        if (NAVRegexMatchRange(c, buffer)) {
            return true
        }

        if (NAVCharCodeAt(buffer, i) == '\') {
            i++

            if (NAVRegexMatchMetaChar(c, buffer)) {
                return true
            }

            if ((NAVCharCodeAt(buffer, i) == c) && !NAVRegexIsMetaChar(c)) {
                return true
            }
        }

        if (NAVCharCodeAt(buffer, i) == c) {
            if (c == '-') {
                return (i == length) || ((i + 3) == length)
            }

            return true
        }

        i++

        if (i >= length) {
            break
        }
    }

    return false
}


define_function char NAVRegexMatchOne(_NAVRegexState p, char c) {
    switch (p.type) {
        case REGEX_TYPE_DOT:            { return  NAVRegexMatchDot(c) }
        case REGEX_TYPE_CHAR_CLASS:     { return  NAVRegexMatchCharClass(c, p.charclass) }
        case REGEX_TYPE_INV_CHAR_CLASS: { return !NAVRegexMatchCharClass(c, p.charclass) }
        case REGEX_TYPE_DIGIT:          { return  NAVRegexMatchDigit(c) }
        case REGEX_TYPE_NOT_DIGIT:      { return !NAVRegexMatchDigit(c) }
        case REGEX_TYPE_ALPHA:          { return  NAVRegexMatchAlphaNumeric(c) }
        case REGEX_TYPE_NOT_ALPHA:      { return !NAVRegexMatchAlphaNumeric(c) }
        case REGEX_TYPE_WHITESPACE:     { return  NAVRegexMatchWhitespace(c) }
        case REGEX_TYPE_NOT_WHITESPACE: { return !NAVRegexMatchWhitespace(c) }
        default:                        { return  (p.value == c) }
    }
}


define_function char NAVRegexMatchStar(_NAVRegexState p, _NAVRegexState state[], char buffer[], _NAVRegexMatchResult match) {
    stack_var integer length
    stack_var integer x

    length = match.length

    x = 1

    while (x <= length_array(buffer) && NAVRegexMatchOne(p, NAVCharCodeAt(buffer, x))) {
        match.length++
        x++
    }

    while (x >= 1) {
        if (NAVRegexMatchPattern(state, NAVStringSlice(buffer, x, 0), match)) {
            return true
        }

        match.length--
        x--
    }

    match.length = length

    return false
}


define_function char NAVRegexMatchPlus(_NAVRegexState p, _NAVRegexState state[], char buffer[], _NAVRegexMatchResult match) {
    stack_var integer x

    x = 1

    while (x <= length_array(buffer) && NAVRegexMatchOne(p, NAVCharCodeAt(buffer, x))) {
        match.length++
        x++
    }

    while (x >= 1) {
        if (NAVRegexMatchPattern(state, NAVStringSlice(buffer, x, 0), match)) {
            return true
        }

        match.length--
        x--
    }

    return false
}


define_function char NAVRegexMatchQuestion(_NAVRegexState p, _NAVRegexState pattern[], char buffer[], _NAVRegexMatchResult match) {
    if (p.type == REGEX_TYPE_UNUSED) {
        return true
    }

    if (NAVRegexMatchPattern(pattern, buffer, match)) {
        return true
    }

    if (NAVCharCodeAt(buffer, 1) && NAVRegexMatchOne(p, NAVCharCodeAt(buffer, 1))) {
        if (NAVRegexMatchPattern(pattern, NAVStringSlice(buffer, 2, 0), match)) {
            match.length++
            return true
        }
    }

    return false
}


define_function char NAVRegexMatchPattern(_NAVRegexState state[], char buffer[], _NAVRegexMatchResult match) {
    stack_var integer length
    stack_var integer x
    stack_var integer z

    length = match.length

    x = 1
    z = 1

    while (true) {
        select {
            active (state[z].type == REGEX_TYPE_UNUSED || state[(z + 1)].type == REGEX_TYPE_QUESTIONMARK): {
                stack_var _NAVRegexState slice[MAX_REGEXP_OBJECTS]

                NAVRegexStateArraySlice(state, (z + 2), 0, slice)

                return NAVRegexMatchQuestion(state[z], slice, NAVStringSlice(buffer, x, 0), match)
            }
            active (state[(z + 1)].type == REGEX_TYPE_STAR): {
                stack_var _NAVRegexState slice[MAX_REGEXP_OBJECTS]

                NAVRegexStateArraySlice(state, (z + 2), 0, slice)

                return NAVRegexMatchStar(state[z], slice, NAVStringSlice(buffer, x, 0), match)
            }
            active (state[(z + 1)].type == REGEX_TYPE_PLUS): {
                stack_var _NAVRegexState slice[MAX_REGEXP_OBJECTS]

                NAVRegexStateArraySlice(state, (z + 2), 0, slice)

                return NAVRegexMatchPlus(state[z], slice, NAVStringSlice(buffer, x, 0), match)
            }
            active (state[z].type == REGEX_TYPE_END && state[(z + 1)].type == REGEX_TYPE_UNUSED): {
                return (x == length_array(buffer))
            }
            // Branching is not working properly
            // active (state[x].type == REGEX_TYPE_BRANCH): {
            //     return (NAVRegexMatchPattern(state, buffer, matchLength) || NAVRegexMatchPattern(state[(x + 1)], buffer, matchLength))
            // }
        }

        match.length++

        x++
        z++

        if (x <= length_array(buffer) && NAVRegexMatchOne(state[z], NAVCharCodeAt(buffer, x))) {
            break
        }
    }

    match.length = length
    // match.end = match.start + match.length
    // match.text = NAVStringSlice(buffer, match.start, match.end)

    return false
}


define_function integer NAVRegexStateArraySlice(_NAVRegexState state[], integer start, integer end, _NAVRegexState slice[]) {
    stack_var integer x
    stack_var integer z
    stack_var integer count

    if (start < 1) {
        start = 1
    }

    if (end == 0) {
        count = length_array(state)
    }
    else {
        count = end
    }

    // NAVLog("'NAVRegexStateArraySlice: ', itoa(start), ' ', itoa(end)")
    // NAVLog("'NAVRegexStateArraySlice: slicing ', itoa(count), ' items from state starting at ', itoa(start)")

    for (x = start, z = 1; x <= count; x++, z++) {
        slice[z] = state[x]
    }

    set_length_array(slice, z)

    return z
}


// define_function NAVRegexParserInit(_NAVRegexParser parser) {
//     parser.CurrentState = 1
//     parser.CurrentGroup = 1

//     parser.GroupCount = 1
//     NAVSetArrayInteger(parser.StateCount, 0)
// }


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


// define_function char[NAV_MAX_CHARS] NAVRegexGetType(integer type) {
//     switch (type) {
//         case NAV_REGEX_TYPE_WILDCARD:       { return 'wildcard' }
//         case NAV_REGEX_TYPE_CHARACTER:      { return 'character' }
//         case NAV_REGEX_TYPE_ESCAPE:         { return 'escape' }
//         case NAV_REGEX_TYPE_GROUP:          { return 'group' }
//         case NAV_REGEX_TYPE_START_OF_STRING:{ return 'startOfString' }
//         case NAV_REGEX_TYPE_END_OF_STRING:  { return 'endOfString' }
//         case NAV_REGEX_TYPE_DIGIT:          { return 'digit' }
//         case NAV_REGEX_TYPE_NON_DIGIT:      { return 'nonDigit' }
//         case NAV_REGEX_TYPE_WORD:           { return 'word' }
//         case NAV_REGEX_TYPE_NON_WORD:       { return 'nonWord' }
//         case NAV_REGEX_TYPE_WHITESPACE:     { return 'whitespace' }
//         case NAV_REGEX_TYPE_NON_WHITESPACE: { return 'nonWhitespace' }
//     }
// }


// define_function char[NAV_MAX_CHARS] NAVRegexGetQuantifier(integer quantifier) {
//     switch (quantifier) {
//         case NAV_REGEX_QUANTIFIER_EXACTLY_ONE:   { return 'exactlyOne' }
//         case NAV_REGEX_QUANTIFIER_ZERO_OR_MORE:  { return 'zeroOrMore' }
//         case NAV_REGEX_QUANTIFIER_ONE_OR_MORE:   { return 'oneOrMore' }
//         case NAV_REGEX_QUANTIFIER_ZERO_OR_ONE:   { return 'zeroOrOne' }
//     }
// }


// define_function char[NAV_MAX_CHARS] NAVRegexGetError(sinteger error) {
//     switch (error) {
//         case NAV_REGEX_ERROR_INVALID_QUANTIFIER:{ return 'Invalid quantifier' }
//         case NAV_REGEX_ERROR_INVALID_ESCAPE:    { return 'Invalid escape' }
//         case NAV_REGEX_ERROR_INVALID_PATTERN:   { return 'Invalid pattern' }
//         default:                                { return 'Unknown error' }
//     }
// }


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
