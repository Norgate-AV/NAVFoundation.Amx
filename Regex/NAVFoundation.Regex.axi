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

#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX__
#DEFINE __NAV_FOUNDATION_REGEX__ 'NAVFoundation.Regex'

#include 'NAVFoundation.Regex.h.axi'


define_function NAVRegexParserInit(_NAVRegexParser parser) {
    parser.CurrentState = 1
    parser.CurrentGroup = 1

    parser.GroupCount = 1
    NAVSetArrayInteger(parser.StateCount, 0)
}


define_function integer NAVRegexGetCurrentGroup(_NAVRegexParser parser) {
    return parser.CurrentGroup
}


define_function integer NAVRegexGetCurrentState(_NAVRegexParser parser) {
    return parser.StateCount[NAVRegexGetCurrentGroup(parser)]
}


define_function integer NAVRegexGetLastState(_NAVRegexParser parser) {
    return parser.StateCount[NAVRegexGetCurrentGroup(parser)]
}


define_function NAVRegexCopyState(_NAVRegexState source, _NAVRegexState destination) {
    // stack_var integer x

    destination.Type = source.Type
    destination.Quantifier = source.Quantifier
    destination.Value = source.Value

    // for (x = 1; x <= length_array(source.GroupState); x++) {
    //     destination.GroupState[x] = source.GroupState[x]
    // }
}


// define_function NAVRegexCopyStateToGroupState(_NAVRegexState source, _NAVRegexGroupState destination) {
//     stack_var integer x

//     destination.Type = source.Type
//     destination.Quantifier = source.Quantifier
//     destination.Value = source.Value

//     for (x = 1; x <= length_array(source.GroupState); x++) {
//         destination.GroupState[x] = source.GroupState[x]
//     }
// }


define_function NAVRegexCopyStateArray(_NAVRegexState source[], _NAVRegexState destination[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(source)

    for (x = 1; x <= length; x++) {
        NAVRegexCopyState(source[x], destination[x])
    }
}


// define_function NAVRegexCopyStateToGroupStateArray(_NAVRegexState source[], _NAVRegexGroupState destination[]) {
//     stack_var integer x
//     stack_var integer length

//     length = length_array(source)

//     for (x = 1; x <= length; x++) {
//         NAVRegexCopyState(source[x], type_cast(destination[x]))
//     }
// }


define_function sinteger NAVRegexParse(_NAVRegexParser parser, char pattern[]) {
    stack_var integer x
    stack_var integer next

    stack_var integer group
    stack_var integer state
    stack_var integer lastState

    NAVRegexParserInit(parser)

    x = 1

    while (x <= length_array(pattern)) {
        next = pattern[x]

        group = NAVRegexGetCurrentGroup(parser)

        switch (next) {
            case '^': {
                parser.StateCount[group]++

                state = NAVRegexGetCurrentState(parser)
                parser.State[group][state].Type = NAV_REGEX_TYPE_START_OF_STRING

                x++
                continue
            }
            case '$': {
                parser.StateCount[group]++

                state = NAVRegexGetCurrentState(parser)
                parser.State[group][state].Type = NAV_REGEX_TYPE_END_OF_STRING

                x++
                continue
            }
            case '.': {
                parser.StateCount[group]++

                state = NAVRegexGetCurrentState(parser)
                parser.State[group][state].Type = NAV_REGEX_TYPE_WILDCARD
                parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

                x++
                continue
            }

            case '?': {
                state = NAVRegexGetLastState(parser)

                if (!state || parser.State[group][state].Quantifier != NAV_REGEX_QUANTIFIER_EXACTLY_ONE) {
                    return NAV_REGEX_ERROR_INVALID_QUANTIFIER
                }

                parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_ZERO_OR_ONE

                x++
                continue
            }

            case '*': {
                state = NAVRegexGetLastState(parser)

                if (!state || parser.State[group][state].Quantifier != NAV_REGEX_QUANTIFIER_EXACTLY_ONE) {
                    return NAV_REGEX_ERROR_INVALID_QUANTIFIER
                }

                parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_ZERO_OR_MORE

                x++
                continue
            }

            case '+': {
                state = NAVRegexGetLastState(parser)

                if (!state || parser.State[group][state].Quantifier != NAV_REGEX_QUANTIFIER_EXACTLY_ONE) {
                    return NAV_REGEX_ERROR_INVALID_QUANTIFIER
                }

                if (true) {
                    stack_var _NAVRegexState newState

                    NAVRegexCopyState(parser.State[group][state], newState)
                    newState.Quantifier = NAV_REGEX_QUANTIFIER_ZERO_OR_MORE

                    parser.StateCount[group]++
                    state = NAVRegexGetCurrentState(parser)
                    NAVRegexCopyState(newState, parser.State[group][state])

                    x++
                }

                continue
            }

            case '(': {
                // parser.StateCount[group]++

                // state = NAVRegexGetCurrentState(parser)
                // parser.State[group][state].Type = NAV_REGEX_TYPE_GROUP

                parser.GroupCount++
                parser.CurrentGroup = parser.GroupCount

                x++
                continue
            }

            case ')': {
                if (parser.StateCount[group] < 1) {
                    return -1
                }

                if (true) {
                    stack_var _NAVRegexState states[NAV_REGEX_MAX_STATES]

                    NAVRegexCopyStateArray(parser.State[group], states)

                    parser.CurrentGroup = parser.GroupCount - 1
                    group = NAVRegexGetCurrentGroup(parser)

                    parser.StateCount[group]++
                    state = NAVRegexGetCurrentState(parser)
                    parser.State[group][state].Type = NAV_REGEX_TYPE_GROUP
                    parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE
                    // NAVRegexCopyStateToGroupStateArray(states, parser.State[group][state].GroupState)
                }

                x++
                continue
            }

            case '\': {
                if ((x + 1) > length_array(pattern)) {
                    return NAV_REGEX_ERROR_INVALID_ESCAPE
                }

                switch (pattern[x + 1]) {
                    case 'd': {
                        parser.StateCount[group]++

                        state = NAVRegexGetLastState(parser)
                        parser.State[group][state].Type = NAV_REGEX_TYPE_DIGIT
                        parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

                        x = x + 2
                        continue
                    }
                    case 'D': {
                        parser.StateCount[group]++

                        state = NAVRegexGetLastState(parser)
                        parser.State[group][state].Type = NAV_REGEX_TYPE_NON_DIGIT
                        parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

                        x = x + 2
                        continue
                    }
                    case 'w': {
                        parser.StateCount[group]++

                        state = NAVRegexGetLastState(parser)
                        parser.State[group][state].Type = NAV_REGEX_TYPE_WORD
                        parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

                        x = x + 2
                        continue
                    }
                    case 'W': {
                        parser.StateCount[group]++

                        state = NAVRegexGetLastState(parser)
                        parser.State[group][state].Type = NAV_REGEX_TYPE_NON_WORD
                        parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

                        x = x + 2
                        continue
                    }
                    case 's': {
                        parser.StateCount[group]++

                        state = NAVRegexGetLastState(parser)
                        parser.State[group][state].Type = NAV_REGEX_TYPE_WHITESPACE
                        parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

                        x = x + 2
                        continue
                    }
                    case 'S': {
                        parser.StateCount[group]++

                        state = NAVRegexGetLastState(parser)
                        parser.State[group][state].Type = NAV_REGEX_TYPE_NON_WHITESPACE
                        parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE

                        x = x + 2
                        continue
                    }
                    case '\': {
                        // state = NAVRegexGetLastState(parser)

                        // parser.State[group][state].Type = NAV_REGEX_TYPE_ESCAPE
                        // parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE
                        // parser.State[group][state].Value = pattern[x + 2]

                        // x = x + 3
                        // continue
                    }
                    default: {
                        parser.StateCount[group]++

                        state = NAVRegexGetLastState(parser)
                        parser.State[group][state].Type = NAV_REGEX_TYPE_CHARACTER
                        parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE
                        parser.State[group][state].Value = pattern[x + 1]

                        x = x + 2
                        continue
                    }
                }
            }

            default: {
                parser.StateCount[group]++

                state = NAVRegexGetCurrentState(parser)
                parser.State[group][state].Type = NAV_REGEX_TYPE_CHARACTER
                parser.State[group][state].Quantifier = NAV_REGEX_QUANTIFIER_EXACTLY_ONE
                parser.State[group][state].Value = next

                x++
                continue
            }
        }

        if (parser.StateCount[1] < 1) {
            return NAV_REGEX_ERROR_INVALID_PATTERN
        }
    }

    return 0
}


define_function char[16000] NAVRegexPrintState(_NAVRegexParser parser, integer group, integer state) {
    stack_var char result[16000]

    switch (parser.State[group][state].Type) {
        case NAV_REGEX_TYPE_GROUP: {
            result = '{ '
            result = "result, '"type": "', NAVRegexGetType(parser.State[group][state].Type), '", '"
            result = "result, '"states": [', NAVRegexPrintStates(parser, group + 1), ']'"
            result = "result, '"quantifier": "', NAVRegexGetQuantifier(parser.State[group][state].Quantifier), '"'"
            result = "result, ' }'"
        }
        default: {
            result = '{ '
            result = "result, '"type": "', NAVRegexGetType(parser.State[group][state].Type), '", '"
            result = "result, '"value": "', parser.State[group][state].Value, '", '"
            result = "result, '"quantifier": "', NAVRegexGetQuantifier(parser.State[group][state].Quantifier), '"'"
            result = "result, ' }'"
        }
    }

    return result
}


define_function char[16000] NAVRegexPrintStates(_NAVRegexParser parser, integer group) {
    stack_var char result[16000]
    stack_var integer x

    result = '['

    for (x = 1; x <= parser.StateCount[group]; x++) {
        result = "result, NAVRegexPrintState(parser, group, x)"

        if (x < parser.StateCount[group]) {
            result = "result, ','"
        }
    }

    result = "result, ']'"

    return result
}


define_function char[16000] NAVRegexPrintParser(_NAVRegexParser parser) {
    stack_var char result[16000]
    stack_var integer x
    stack_var integer y

    stack_var integer group
    stack_var integer state

    group = 1

    // result = "NAV_CR, NAV_LF, '[', NAV_CR, NAV_LF"

    // for (x = 1; x <= parser.GroupCount; x++) {
    //     group = x

    for (y = 1; y <= parser.StateCount[group]; y++) {
        state = y

        switch (parser.State[group][state].Type) {
            case NAV_REGEX_TYPE_GROUP: {
                // group++

                // result = "result, NAVRegexGetTab(x), '{ '"

                // result = "result, '"states": [', NAV_CR, NAV_LF"


                // result = "result, '"quantifier": "', NAVRegexGetQuantifier(parser.State[group][state].Quantifier), '"'"

                // result = "result, ' }'"

                // if (y < parser.StateCount[group]) {
                //     result = "result, ','"
                // }

                // result = "result, NAV_CR, NAV_LF"

                // result = "result, NAVRegexPrintStates(parser, group)"
            }
            default: {
                // result = "result, NAVRegexGetTab(x), '{ '"

                // result = "result, '"type": "', NAVRegexGetType(parser.State[group][state].Type), '", '"
                // result = "result, '"value": "', parser.State[group][state].Value, '", '"
                // result = "result, '"quantifier": "', NAVRegexGetQuantifier(parser.State[group][state].Quantifier), '"'"

                // result = "result, ' }'"

                // if (y < parser.StateCount[group]) {
                //     result = "result, ','"
                // }

                // result = "result, NAV_CR, NAV_LF"

                result = "result, NAVRegexPrintState(parser, group, state)"
            }
        }
    }

    //     if (x < parser.GroupCount) {
    //         result = "result, ','"
    //     }
    // }


    // result = "result, ']'"

    return result
}


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


define_function char[NAV_MAX_BUFFER] NAVRegexGetTab(integer count) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer x
    stack_var integer y

    result = ''

    for (x = 1; x <= count; x++) {
        for (y = 1; y <= NAV_REGEX_TAB_SIZE; y++) {
            result = "result, ' '"
        }
    }

    return result
}


define_function char NAVRegexMatch(_NAVRegexParser parser, buffer[], _NAVRegexMatchResult match) {

}


#END_IF // __NAV_FOUNDATION_REGEX__
