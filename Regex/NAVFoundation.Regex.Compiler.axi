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

    #IF_DEFINED REGEX_COMPILE_DEBUG
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


define_function char NAVRegexCompilerIsValidGroupName(char name[]) {
    stack_var integer length
    stack_var integer x
    stack_var char c

    length = length_array(name)

    if (length == 0) {
        return false
    }

    // First character must be a letter or underscore
    c = NAVCharCodeAt(name, 1)
    if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_')) {
        return false
    }

    // Remaining characters can be letters, digits, or underscores
    for (x = 2; x <= length; x++) {
        c = NAVCharCodeAt(name, x)
        if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_')) {
            return false
        }
    }

    return true
}


define_function char NAVRegexCompilerIsGroupNameUnique(_NAVRegexParser parser, char name[]) {
    stack_var integer x

    // Check all existing groups for duplicate names
    for (x = 1; x <= parser.groupTotal; x++) {
        if (parser.groupInfo[x].isNamed) {
            if (parser.groupInfo[x].name == name) {
                return false  // Duplicate found
            }
        }
    }

    return true
}


define_function char NAVRegexCompileParseGroupName(_NAVRegexParser parser, char groupName[]) {
    stack_var char buffer[50]
    stack_var integer length
    stack_var char c

    // We're positioned after '(?P<' or '(?<'
    // Parse until we hit '>'

    length = 0
    while (parser.pattern.cursor <= parser.pattern.length) {
        c = NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)

        if (c == '>') {
            break  // Found end of name
        }

        if (length >= 49) {  // Leave room for null terminator
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX__,
                                        'NAVRegexCompileParseGroupName',
                                        "'Group name too long (max 49 characters)'")
            return false
        }

        length++
        buffer = "buffer, c"

        if (!NAVRegexPatternAdvanceCursor(parser)) {
            return false
        }
    }

    if (c != '>') {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompileParseGroupName',
                                    "'Missing closing `>` in named group'")
        return false
    }

    if (length == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompileParseGroupName',
                                    "'Empty group name'")
        return false
    }

    set_length_array(buffer, length)
    groupName = buffer

    // Validate name
    if (!NAVRegexCompilerIsValidGroupName(groupName)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompileParseGroupName',
                                    "'Invalid group name: ', groupName, ' (must start with letter/underscore, contain only alphanumeric/underscore)'")
        return false
    }

    // Check for uniqueness
    if (!NAVRegexCompilerIsGroupNameUnique(parser, groupName)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompileParseGroupName',
                                    "'Duplicate group name: ', groupName")
        return false
    }

    return true
}


define_function char NAVRegexCompilerIsValidEscapeChar(char c) {
    // Check if this is a valid escape character
    // Letters that are valid escape sequences
    switch (c) {
        case 'b':   // Word boundary
        case 'B':   // Not word boundary
        case 'd':   // Digit
        case 'D':   // Not digit
        case 'w':   // Word character
        case 'W':   // Not word character
        case 's':   // Whitespace
        case 'S':   // Not whitespace
        case 'x':   // Hex (not implemented)
        case 'n':   // Newline (not implemented)
        case 'r':   // Return (not implemented)
        case 't': { // Tab (not implemented)
            return true
        }
    }

    // Special characters that can be escaped (literal matching)
    // These include regex metacharacters: . * + ? ^ $ { } [ ] ( ) | \
    switch (c) {
        case '.':
        case '*':
        case '+':
        case '?':
        case '^':
        case '$':
        case '{':
        case '}':
        case '[':
        case ']':
        case '(':
        case ')':
        case '|':
        case '\':
        case '/': {  // Forward slash for delimiter
            return true
        }
    }

    // If we get here, it's not a valid escape sequence
    return false
}


define_function char NAVRegexCompilerCanQuantify(_NAVRegexParser parser) {
    // Check if there's a previous token that can be quantified
    if (parser.count == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompilerCanQuantify',
                                    "'Quantifier at start of pattern - nothing to quantify'")
        return false  // No previous token
    }

    // Check if previous token is already a quantifier
    switch (parser.state[parser.count].type) {
        case REGEX_TYPE_STAR:
        case REGEX_TYPE_PLUS:
        case REGEX_TYPE_QUESTIONMARK:
        case REGEX_TYPE_QUANTIFIER: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX__,
                                        'NAVRegexCompilerCanQuantify',
                                        "'Consecutive quantifiers - cannot quantify a quantifier'")
            return false  // Can't quantify a quantifier
        }
        case REGEX_TYPE_BEGIN:
        case REGEX_TYPE_END: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX__,
                                        'NAVRegexCompilerCanQuantify',
                                        "'Cannot quantify an anchor (^ or $)'")
            return false  // Can't quantify anchors
        }
    }

    return true
}


define_function char NAVRegexCompileBoundedQuantifier(_NAVRegexParser parser) {
    stack_var char buffer[20]
    stack_var integer length
    stack_var integer commaPos
    stack_var char minStr[10]
    stack_var char maxStr[10]
    stack_var sinteger minVal
    stack_var sinteger maxVal

    // Start after the opening '{'
    if (!NAVRegexPatternAdvanceCursor(parser)) {
        return false
    }

    // Collect digits and comma until we hit '}'
    length = 0
    while (parser.pattern.cursor <= parser.pattern.length) {
        stack_var char c

        c = NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)

        if (c == '}') {
            break
        }

        if ((c >= '0' && c <= '9') || c == ',' || c == ' ') {
            if (c != ' ') {  // Skip spaces
                length++
                buffer = "buffer, c"
            }

            if (!NAVRegexPatternAdvanceCursor(parser)) {
                return false
            }
        }
        else {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX__,
                                        'NAVRegexCompileBoundedQuantifier',
                                        "'Invalid character in bounded quantifier: ', c")
            return false
        }
    }

    if (NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor) != '}') {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompileBoundedQuantifier',
                                    "'Missing closing brace in bounded quantifier'")
        return false
    }

    if (length == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompileBoundedQuantifier',
                                    "'Empty bounded quantifier'")
        return false
    }

    // Parse the quantifier: {n}, {n,}, or {n,m}
    commaPos = NAVIndexOf(buffer, ',', 1)

    if (commaPos == 0) {
        // No comma, just {n}
        minVal = atoi(buffer)
        maxVal = minVal
    }
    else if (commaPos == 1) {
        // Starts with comma: {,m} is invalid (missing minimum)
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompileBoundedQuantifier',
                                    "'Missing minimum value in bounded quantifier'")
        return false
    }
    else if (commaPos == length) {
        // Ends with comma: {n,} means n or more (unlimited)
        minStr = left_string(buffer, commaPos - 1)
        minVal = atoi(minStr)
        maxVal = -1  // -1 means unlimited
    }
    else {
        // Has comma in middle: {n,m}
        minStr = left_string(buffer, commaPos - 1)
        maxStr = right_string(buffer, length - commaPos)
        minVal = atoi(minStr)
        maxVal = atoi(maxStr)

        if (maxVal < minVal) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX__,
                                        'NAVRegexCompileBoundedQuantifier',
                                        "'Maximum must be >= minimum in bounded quantifier'")
            return false
        }
    }

    if (minVal < 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompileBoundedQuantifier',
                                    "'Minimum must be >= 0 in bounded quantifier'")
        return false
    }

    // Add the quantifier token
    parser.count++
    parser.state[parser.count].type = REGEX_TYPE_QUANTIFIER
    parser.state[parser.count].quantifierMin = minVal
    parser.state[parser.count].quantifierMax = maxVal

    #IF_DEFINED REGEX_COMPILE_DEBUG
    NAVLog("'[ Compile ]: Bounded quantifier {', itoa(minVal), ',', itoa(maxVal), '}'")
    #END_IF

    return true
}


define_function char NAVRegexCompileCharacterClass(_NAVRegexParser parser) {
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
                                        'NAVRegexCompileCharacterClass',
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

        // Check for nested opening bracket (not allowed)
        if (code == '[') {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_REGEX__,
                                        'NAVRegexCompileCharacterClass',
                                        "'Nested character class - `[` not allowed inside character class'")
            return false
        }

        if (code == '\') {
            if (length > (MAX_CHAR_CLASS_LENGTH - 1)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_REGEX__,
                                            'NAVRegexCompileCharacterClass',
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
                                            'NAVRegexCompileCharacterClass',
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
                                            'NAVRegexCompileCharacterClass',
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
                                    'NAVRegexCompileCharacterClass',
                                    "'Character class exceeded maximum length'")
        return false
    }

    // Set character class value (count was already incremented above)
    parser.state[parser.count].charclass.value = charclass
    parser.state[parser.count].charclass.length = length
    set_length_array(parser.state[parser.count].charclass.value, length)

    return true
}


define_function char NAVRegexCompile(char pattern[], _NAVRegexParser parser) {
    stack_var char c

    if (!NAVRegexParserInit(parser, pattern)) {
        return false
    }

    while (NAVRegexPatternHasMoreTokens(parser) && (parser.count < MAX_REGEXP_OBJECTS)) {
        if (!NAVRegexPatternAdvanceCursor(parser)) {
            return false
        }

        c = NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)

        #IF_DEFINED REGEX_COMPILE_DEBUG
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

                // Validate that we can quantify
                if (!NAVRegexCompilerCanQuantify(parser)) {
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

                // Validate that we can quantify
                if (!NAVRegexCompilerCanQuantify(parser)) {
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

                // Validate that we can quantify
                if (!NAVRegexCompilerCanQuantify(parser)) {
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
                #IF_DEFINED REGEX_COMPILE_DEBUG
                NAVLog("'[ Compile ]: Backslash case - cursor=', itoa(parser.pattern.cursor), ' checking (cursor+1) <= length: (', itoa(parser.pattern.cursor + 1), ') <= (', itoa(parser.pattern.length), ') = ', itoa((parser.pattern.cursor + 1) <= parser.pattern.length)")
                #END_IF

                if ((parser.pattern.cursor + 1) <= parser.pattern.length) {
                    // Increment cursor to look at the character after the backslash
                    if (!NAVRegexPatternAdvanceCursor(parser)) {
                        return false
                    }

                    #IF_DEFINED REGEX_COMPILE_DEBUG
                    NAVLog("'[ Compile ]: Backslash processing - cursor now=', itoa(parser.pattern.cursor), ' char is: ', NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)")
                    #END_IF

                    // Validate that this is a supported escape sequence
                    if (!NAVRegexCompilerIsValidEscapeChar(NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor))) {
                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                    __NAV_FOUNDATION_REGEX__,
                                                    'NAVRegexCompile',
                                                    "'Invalid escape sequence: \', NAVCharCodeAt(parser.pattern.value, parser.pattern.cursor)")
                        return false
                    }

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
                else {
                    // Trailing backslash with nothing after it
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Trailing backslash - incomplete escape sequence'")
                    return false
                }
            }

            case '{': {
                // Validate that we can quantify
                if (!NAVRegexCompilerCanQuantify(parser)) {
                    return false
                }

                if (!NAVRegexCompileBoundedQuantifier(parser)) {
                    return false
                }
            }
            case '(': {
                // Check for special group types: (?:...), (?P<name>...), (?<name>...)
                stack_var char isCapturing
                stack_var char isNamed
                stack_var char groupName[50]
                stack_var char nextChar
                stack_var char secondChar

                isCapturing = true  // Default to capturing group
                isNamed = false
                groupName = ''

                // Lookahead to check for special group syntax
                if ((parser.pattern.cursor + 1) <= parser.pattern.length) {
                    nextChar = NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 1))

                    if (nextChar == '?') {
                        // Special group syntax - check what type
                        if ((parser.pattern.cursor + 2) <= parser.pattern.length) {
                            secondChar = NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 2))

                            if (secondChar == ':') {
                                // Non-capturing group (?:...)
                                isCapturing = false

                                // Advance past '(?:'
                                if (!NAVRegexPatternAdvanceCursor(parser)) { return false }  // Move to '?'
                                if (!NAVRegexPatternAdvanceCursor(parser)) { return false }  // Move to ':'

                                #IF_DEFINED REGEX_COMPILE_DEBUG
                                NAVLog("'[ Compile ]: Non-capturing group detected'")
                                #END_IF
                            }
                            else if (secondChar == 'P') {
                                // Python-style named group (?P<name>...)
                                if ((parser.pattern.cursor + 3) <= parser.pattern.length) {
                                    if (NAVCharCodeAt(parser.pattern.value, (parser.pattern.cursor + 3)) == '<') {
                                        isNamed = true

                                        // Advance past '(?P<'
                                        if (!NAVRegexPatternAdvanceCursor(parser)) { return false }  // Move to '?'
                                        if (!NAVRegexPatternAdvanceCursor(parser)) { return false }  // Move to 'P'
                                        if (!NAVRegexPatternAdvanceCursor(parser)) { return false }  // Move to '<'
                                        if (!NAVRegexPatternAdvanceCursor(parser)) { return false }  // Move to first char of name

                                        // Parse the group name
                                        if (!NAVRegexCompileParseGroupName(parser, groupName)) {
                                            return false
                                        }

                                        #IF_DEFINED REGEX_COMPILE_DEBUG
                                        NAVLog("'[ Compile ]: Named group detected: ', groupName")
                                        #END_IF
                                    }
                                    else {
                                        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                                    __NAV_FOUNDATION_REGEX__,
                                                                    'NAVRegexCompile',
                                                                    "'Invalid group syntax - (?P requires < after P'")
                                        return false
                                    }
                                }
                                else {
                                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                                __NAV_FOUNDATION_REGEX__,
                                                                'NAVRegexCompile',
                                                                "'Invalid group syntax - incomplete (?P pattern'")
                                    return false
                                }
                            }
                            else if (secondChar == '<') {
                                // .NET-style named group (?<name>...)
                                isNamed = true

                                // Advance past '(?<'
                                if (!NAVRegexPatternAdvanceCursor(parser)) { return false }  // Move to '?'
                                if (!NAVRegexPatternAdvanceCursor(parser)) { return false }  // Move to '<'
                                if (!NAVRegexPatternAdvanceCursor(parser)) { return false }  // Move to first char of name

                                // Parse the group name
                                if (!NAVRegexCompileParseGroupName(parser, groupName)) {
                                    return false
                                }

                                #IF_DEFINED REGEX_COMPILE_DEBUG
                                NAVLog("'[ Compile ]: Named group detected (.NET style): ', groupName")
                                #END_IF
                            }
                            else {
                                // Invalid (? pattern - not :, P, or <
                                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                            __NAV_FOUNDATION_REGEX__,
                                                            'NAVRegexCompile',
                                                            "'Invalid group syntax - (? must be followed by :, P<, or <'")
                                return false
                            }
                        }
                        else {
                            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                        __NAV_FOUNDATION_REGEX__,
                                                        'NAVRegexCompile',
                                                        "'Invalid group syntax - incomplete (? pattern'")
                            return false
                        }
                    }
                }

                // Increment total group count (for all types)
                parser.groupTotal++

                if (parser.groupTotal > NAV_REGEX_MAX_GROUPS) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Too many groups (max: ', itoa(NAV_REGEX_MAX_GROUPS), ')'")
                    return false
                }

                // Only increment capturing group count if this is a capturing group
                if (isCapturing) {
                    if (!NAVRegexCompileIncrementGroupCount(parser)) {
                        return false
                    }
                }

                // Increment nesting depth (for all group types)
                if (!NAVRegexCompilerIncrementGroupDepth(parser)) {
                    return false
                }

                // Store group info
                parser.groupInfo[parser.groupTotal].number = parser.groupCount  // 0 for non-capturing
                parser.groupInfo[parser.groupTotal].name = groupName
                parser.groupInfo[parser.groupTotal].isNamed = isNamed
                parser.groupInfo[parser.groupTotal].isCapturing = isCapturing
                parser.groupInfo[parser.groupTotal].startToken = parser.count + 1

                // Track group on stack
                parser.groupStack[parser.groupDepth] = parser.groupTotal

                // Add token
                parser.count++
                if (isCapturing) {
                    parser.state[parser.count].type = REGEX_TYPE_GROUP_START
                }
                else {
                    parser.state[parser.count].type = REGEX_TYPE_NON_CAPTURE_GROUP_START
                }

                #IF_DEFINED REGEX_COMPILE_DEBUG
                if (isCapturing) {
                    if (isNamed) {
                        NAVLog("'[ Compile ]: GROUP_START - Named group #', itoa(parser.groupCount), ' (', groupName, ') at depth ', itoa(parser.groupDepth)")
                    }
                    else {
                        NAVLog("'[ Compile ]: GROUP_START - Group #', itoa(parser.groupCount), ' at depth ', itoa(parser.groupDepth)")
                    }
                }
                else {
                    NAVLog("'[ Compile ]: NON_CAPTURE_GROUP_START at depth ', itoa(parser.groupDepth)")
                }
                #END_IF
            }
            case ')': {
                // End of group (capturing or non-capturing)
                stack_var integer groupIndex
                stack_var char isCapturing

                // First check if we have a matching opening parenthesis
                if (parser.groupDepth <= 0) {
                    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                                __NAV_FOUNDATION_REGEX__,
                                                'NAVRegexCompile',
                                                "'Unmatched closing parenthesis `)` in pattern'")
                    return false
                }

                // Get the group index from the stack
                groupIndex = parser.groupStack[parser.groupDepth]
                isCapturing = parser.groupInfo[groupIndex].isCapturing

                // Update group info with end token
                parser.groupInfo[groupIndex].endToken = parser.count + 1

                // Add token
                parser.count++
                if (isCapturing) {
                    parser.state[parser.count].type = REGEX_TYPE_GROUP_END
                }
                else {
                    parser.state[parser.count].type = REGEX_TYPE_NON_CAPTURE_GROUP_END
                }

                #IF_DEFINED REGEX_COMPILE_DEBUG
                if (isCapturing) {
                    if (parser.groupInfo[groupIndex].isNamed) {
                        NAVLog("'[ Compile ]: GROUP_END - Named group #', itoa(parser.groupInfo[groupIndex].number), ' (', parser.groupInfo[groupIndex].name, ') at depth ', itoa(parser.groupDepth)")
                    }
                    else {
                        NAVLog("'[ Compile ]: GROUP_END - Group #', itoa(parser.groupInfo[groupIndex].number), ' at depth ', itoa(parser.groupDepth)")
                    }
                }
                else {
                    NAVLog("'[ Compile ]: NON_CAPTURE_GROUP_END at depth ', itoa(parser.groupDepth)")
                }
                #END_IF

                // Pop from stack
                parser.groupDepth--
            }
            case '[': {
                if (!NAVRegexCompileCharacterClass(parser)) {
                    return false
                }
            }

            default: {
                parser.count++
                parser.state[parser.count].type = REGEX_TYPE_CHAR
                parser.state[parser.count].value = c
            }
        }
    }

    // Validate that all groups are closed
    if (parser.groupDepth != 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompile',
                                    "'Unclosed capturing group - missing `)` in pattern'")
        return false
    }

    if (parser.count >= MAX_REGEXP_OBJECTS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompile',
                                    "'Pattern too complex - exceeded maximum number of tokens (', itoa(MAX_REGEXP_OBJECTS), ')'")
        return false
    }

    // Add UNUSED marker after last token
    parser.state[parser.count + 1].type = REGEX_TYPE_UNUSED
    set_length_array(parser.state, parser.count + 1)

    // Reset the pattern cursor to 1 for matching phase
    NAVRegexSetPatternCursor(parser, 'Compile', 0)

    #IF_DEFINED REGEX_COMPILE_DEBUG
    if (parser.groupTotal > 0) {
        stack_var integer namedCount
        stack_var integer nonCapturingCount
        stack_var integer x

        namedCount = 0
        nonCapturingCount = 0

        for (x = 1; x <= parser.groupTotal; x++) {
            if (parser.groupInfo[x].isNamed) {
                namedCount++
            }
            if (!parser.groupInfo[x].isCapturing) {
                nonCapturingCount++
            }
        }

        NAVLog("'[ Compile ]: Pattern contains ', itoa(parser.groupCount), ' capturing group(s)'")
        if (namedCount > 0) {
            NAVLog("'[ Compile ]:   - ', itoa(namedCount), ' named group(s)'")
        }
        if (nonCapturingCount > 0) {
            NAVLog("'[ Compile ]:   - ', itoa(nonCapturingCount), ' non-capturing group(s)'")
        }
        NAVLog("'[ Compile ]:   Total groups: ', itoa(parser.groupTotal)")
    }
    #END_IF

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


define_function char NAVRegexCompileIncrementGroupCount(_NAVRegexParser parser) {
    // Check if we've exceeded max groups BEFORE incrementing
    if (parser.groupCount >= NAV_REGEX_MAX_GROUPS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompileIncrementGroupCount',
                                    "'Too many capturing groups (max: ', itoa(NAV_REGEX_MAX_GROUPS), ')'")
        return false
    }

    parser.groupCount++

    return true
}


define_function char NAVRegexCompilerIncrementGroupDepth(_NAVRegexParser parser) {
    // Check depth before using as array index
    if (parser.groupDepth >= NAV_REGEX_MAX_GROUPS) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompilerIncrementGroupDepth',
                                    "'Group nesting too deep (max: ', itoa(NAV_REGEX_MAX_GROUPS), ')'")
        return false
    }

    parser.groupDepth++

    // Push group number onto stack for validation
    // parser.groupStack[parser.groupDepth] = parser.groupCount

    return true
}


define_function char NAVRegexCompilerDecrementGroupDepth(_NAVRegexParser parser) {
    // Check if we have a matching opening parenthesis
    if (parser.groupDepth <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_REGEX__,
                                    'NAVRegexCompileDecreaseGroupDepth',
                                    "'Unmatched closing parenthesis `)` in pattern'")
        return false
    }

    // Pop from stack
    parser.groupDepth--

    return true
}


#END_IF // __NAV_FOUNDATION_REGEX_COMPILER__
