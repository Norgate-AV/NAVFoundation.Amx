PROGRAM_NAME='NAVFoundation.Regex.Compiler'

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


#IF_NOT_DEFINED __NAV_FOUNDATION_REGEX_COMPILER__
#DEFINE __NAV_FOUNDATION_REGEX_COMPILER__ 'NAVFoundation.Regex.Compiler'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Regex.h.axi'
#include 'NAVFoundation.Regex.Helpers.axi'


define_function char NAVRegexPatternHasMoreTokens(_NAVRegexParser parser) {
    return parser.pattern.cursor < parser.pattern.length
}


define_function char NAVRegexPatternCursorIsOutOfBounds(_NAVRegexParser parser) {
    return parser.pattern.cursor <= 0 || parser.pattern.cursor > parser.pattern.length
}


define_function char NAVRegexPatternAdvanceCursor(_NAVRegexParser parser) {
    NAVRegexSetPatternCursor(parser, 'PatternAdvanceCursor', parser.pattern.cursor + 1)

    if (NAVRegexPatternCursorIsOutOfBounds(parser)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexPatternAdvanceCursor',
                                    "'Parser pattern cursor out of bounds: ', itoa(parser.pattern.cursor)")
        return false
    }


    return true
}


define_function char NAVRegexParserInit(_NAVRegexParser parser, char pattern[]) {
    parser.pattern.value = NAVStringBetweenGreedy(NAVTrimString(pattern), '/', '/')

    #IF_DEFINED REGEX_DEBUG
    NAVLog("'[ ParserInit ]: Input pattern: "', pattern, '" (length=', itoa(length_array(pattern)), ')'")
    NAVLog("'[ ParserInit ]: Extracted pattern: "', parser.pattern.value, '" (length=', itoa(length_array(parser.pattern.value)), ')'")
    #END_IF

    if (!length_array(parser.pattern.value)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexParserInit',
                                    "'Failed to extract pattern from input'")

        return false
    }

    parser.pattern.length = length_array(parser.pattern.value)
    NAVRegexSetPatternCursor(parser, 'ParserInit', 0)

    if (!NAVRegexParserParseOptions(parser, pattern)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexParserInit',
                                    "'Failed to parse options'")

        return false
    }

    parser.input.value = ''
    parser.input.length = 0
    NAVRegexSetInputCursor(parser, 'ParserInit', 0)

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


define_function char NAVRegexCompile(char pattern[], _NAVRegexParser parser) {
    stack_var char c

    if (!NAVRegexParserInit(parser, pattern)) {
        return false
    }

    // parser.pattern.cursor = 0

    while (NAVRegexPatternHasMoreTokens(parser) && (parser.count < MAX_REGEXP_OBJECTS)) {
        if (!NAVRegexPatternAdvanceCursor(parser)) {
            return false
        }

        c = NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)

        #IF_DEFINED REGEX_DEBUG
        NAVLog("'[ Compile ]: cursor=', itoa(parser.pattern.cursor), ' char=', c, ' (', itoa(type_cast(c)), ')'")
        #END_IF

        switch (c) {
            case '^': {
                parser.count++
                parser.state[parser.count].type = REGEX_TYPE_BEGIN
            }
            case '$': {
                parser.count++
                parser.state[parser.count].type = REGEX_TYPE_END
            }
            case '.': {
                parser.count++
                parser.state[parser.count].type = REGEX_TYPE_DOT
            }

            // Quantifiers. Should these be handled differently?
            case '*': {
                // Check if the following character is '?'
                if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1)) == '?') {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Don`t support lazy quantifiers yet'")

                    return false
                }

                parser.count++
                parser.state[parser.count].type = REGEX_TYPE_STAR
            }
            case '+': {
                // Check if the following character is '?'
                if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1)) == '?') {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Don`t support lazy quantifiers yet'")

                    return false
                }

                parser.count++
                parser.state[parser.count].type = REGEX_TYPE_PLUS
            }
            case '?': {
                // Check if the following character is '?'
                if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1)) == '?') {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Don`t support lazy quantifiers yet'")

                    return false
                }

                parser.count++
                parser.state[parser.count].type = REGEX_TYPE_QUESTIONMARK
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
                #IF_DEFINED REGEX_DEBUG
                NAVLog("'[ Compile ]: Backslash case - cursor=', itoa(parser.pattern.cursor), ' checking (cursor+1) <= length: (', itoa(parser.pattern.cursor + 1), ') <= (', itoa(parser.pattern.length), ') = ', itoa((parser.pattern.cursor + 1) <= parser.pattern.length)")
                #END_IF

                if ((parser.pattern.cursor + 1) <= parser.pattern.length) {
                    // Increment cursor to look at the character after the backslash
                    // parser.pattern.cursor++
                    if (!NAVRegexPatternAdvanceCursor(parser)) {
                        return false
                    }

                    #IF_DEFINED REGEX_DEBUG
                    NAVLog("'[ Compile ]: Backslash processing - cursor now=', itoa(parser.pattern.cursor), ' char is: ', NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)")
                    #END_IF

                    switch (NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)) {
                        case 'b': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_WORD_BOUNDARY
                        }      // Not implemented
                        case 'B': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_NOT_WORD_BOUNDARY
                        }  // Not implemented
                        case 'd': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_DIGIT
                        }
                        case 'D': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_NOT_DIGIT
                        }
                        case 'w': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_ALPHA
                        }
                        case 'W': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_NOT_ALPHA
                        }
                        case 's': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_WHITESPACE
                        }
                        case 'S': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_NOT_WHITESPACE
                        }
                        case 'x': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_HEX
                        }                // Not implemented
                        case 'n': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_NEWLINE
                        }            // Not implemented
                        case 'r': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_RETURN
                        }             // Not implemented
                        case 't': {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_TAB
                        }                // Not implemented
                        default: {
                            parser.count++
                            parser.state[parser.count].type = REGEX_TYPE_CHAR
                            parser.state[parser.count].value = NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)
                        }
                    }
                    // Note: Main loop will increment cursor again, so \d sequence will advance by 2 total
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

                // Increment count and set type
                parser.count++

                // Lookahead to see if this is a negated character class first
                if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1)) == '^') {
                    parser.state[parser.count].type = REGEX_TYPE_INV_CHAR_CLASS

                    if (!NAVRegexPatternAdvanceCursor(parser)) {
                        return false
                    }

                    if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1)) == 0) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX__,
                                                    'NAVRegexCompile',
                                                    "'Incomplete pattern. Missing non-zero character after ^'")

                        return false
                    }
                }
                else {
                    parser.state[parser.count].type = REGEX_TYPE_CHAR_CLASS
                }

                // Advance to first character in the class
                if (!NAVRegexPatternAdvanceCursor(parser)) {
                    return false
                }

                // Build character class until we hit ']'
                while (parser.pattern.cursor <= parser.pattern.length) {
                    stack_var char code

                    code = NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)

                    // Check if we've reached the closing bracket
                    if (code == ']') {
                        break
                    }

                    if (code == '\') {
                        if (length > (MAX_CHAR_CLASS_LENGTH - 1)) {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                        __NAV_FOUNDATION_REGEX__,
                                                        'NAVRegexCompile',
                                                        "'Character class exceeded maximum length'")
                            return false
                        }

                        // Add the backslash
                        charclass = "charclass, code"
                        length = length_array(charclass)

                        // Advance to the escaped character
                        if (!NAVRegexPatternAdvanceCursor(parser)) {
                            return false
                        }

                        code = NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)

                        if (code == 0) {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                        __NAV_FOUNDATION_REGEX__,
                                                        'NAVRegexCompile',
                                                        "'Incomplete pattern. Missing non-zero character after \'")
                            return false
                        }

                        // Add the escaped character
                        charclass = "charclass, code"
                        length = length_array(charclass)
                    }
                    else {
                        if (length > MAX_CHAR_CLASS_LENGTH) {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                        __NAV_FOUNDATION_REGEX__,
                                                        'NAVRegexCompile',
                                                        "'Character class exceeded maximum length'")
                            return false
                        }

                        charclass = "charclass, code"
                        length = length_array(charclass)
                    }

                    // Advance to next character in class
                    if (!NAVRegexPatternAdvanceCursor(parser)) {
                        return false
                    }
                }

                if (length > MAX_CHAR_CLASS_LENGTH) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Character class exceeded maximum length'")
                    return false
                }

                // Set character class value (count was already incremented above)
                parser.state[parser.count].charclass.value = charclass
                parser.state[parser.count].charclass.length = length
                set_length_array(parser.state[parser.count].charclass.value, length)
            }

            default: {
                parser.count++
                parser.state[parser.count].type = REGEX_TYPE_CHAR
                parser.state[parser.count].value = c
            }
        }

        #IF_DEFINED REGEX_DEBUG
        NAVLog("'[ Compile ]: About to increment - cursor=', itoa(parser.pattern.cursor), ' count=', itoa(parser.count), ' length=', itoa(parser.pattern.length)")
        #END_IF

        // parser.pattern.cursor++
        // parser.count++

        #IF_DEFINED REGEX_DEBUG
        NAVLog("'[ Compile ]: After increment - cursor=', itoa(parser.pattern.cursor), ' count=', itoa(parser.count), ' condition=', itoa((parser.pattern.cursor + 1) <= parser.pattern.length)")
        #END_IF
    }

    // Add UNUSED marker after last token
    parser.state[parser.count + 1].type = REGEX_TYPE_UNUSED
    set_length_array(parser.state, parser.count + 1)

    // Reset the pattern cursor to 1 for matching phase
    // parser.pattern.cursor = 0
    NAVRegexSetPatternCursor(parser, 'Compile', 0)


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


#END_IF // __NAV_FOUNDATION_REGEX_COMPILER__
