PROGRAM_NAME='NAVRegexCompile'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char COMPILE_TEST[][255] = {
    '/\d+/',
    '/\w+/',
    '/\w*/',
    '/\s/',
    '/\s+/',
    '/\s*/',
    '/\d\w?\s/',
    '/\d\w\s+/',
    '/\d?\w\s*/',
    '/\D+/',
    '/\D*/',
    '/\D\s/',
    '/\W+/',
    '/\S*/',
    '/^[a-zA-Z0-9_]+$/'
}


define_function RegexCompileSetupExpected(_NAVRegexParser parser) {
    stack_var integer x

    for (x = 1; x <= length_array(COMPILE_TEST); x++) {
        switch (x) {
            case 1: {
                parser.pattern.value = '\d+'
                parser.pattern.length = 3
                parser.pattern.cursor = 1

                parser.count = 2

                parser.state[1].type = REGEX_TYPE_DIGIT
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_PLUS
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0
            }
            case 2: {
                parser.pattern.value = '\w+'
                parser.pattern.length = 3
                parser.pattern.cursor = 1

                parser.count = 2

                parser.state[1].type = REGEX_TYPE_ALPHA
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_PLUS
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0
            }
            case 3: {
                parser.pattern.value = '\w*'
                parser.pattern.length = 3
                parser.pattern.cursor = 1

                parser.count = 2

                parser.state[1].type = REGEX_TYPE_ALPHA
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_STAR
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0
            }
            case 4: {
                parser.pattern.value = '\s'
                parser.pattern.length = 2
                parser.pattern.cursor = 1

                parser.count = 1

                parser.state[1].type = REGEX_TYPE_WHITESPACE
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0
            }
            case 5: {
                parser.pattern.value = '\s+'
                parser.pattern.length = 2
                parser.pattern.cursor = 1

                parser.count = 2

                parser.state[1].type = REGEX_TYPE_WHITESPACE
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_PLUS
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0
            }
            case 6: {
                parser.pattern.value = '\s*'
                parser.pattern.length = 3
                parser.pattern.cursor = 1

                parser.count = 2

                parser.state[1].type = REGEX_TYPE_WHITESPACE
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_STAR
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0
            }
            case 7: {
                parser.pattern.value = '\d\w?\s'
                parser.pattern.length = 7
                parser.pattern.cursor = 1

                parser.count = 4

                parser.state[1].type = REGEX_TYPE_DIGIT
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_ALPHA
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0

                parser.state[3].type = REGEX_TYPE_QUESTIONMARK
                // parser.state[3].value = 0
                parser.state[3].charclass.length = 0
                parser.state[3].charclass.cursor = 0
                // parser.state[3].charclass.value = 0

                parser.state[4].type = REGEX_TYPE_WHITESPACE
                // parser.state[4].value = 0
                parser.state[4].charclass.length = 0
                parser.state[4].charclass.cursor = 0
                // parser.state[4].charclass.value = 0
            }
            case 8: {
                parser.pattern.value = '\d\w\s+'
                parser.pattern.length = 7
                parser.pattern.cursor = 1

                parser.count = 4

                parser.state[1].type = REGEX_TYPE_DIGIT
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_ALPHA
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0

                parser.state[3].type = REGEX_TYPE_PLUS
                // parser.state[3].value = 0
                parser.state[3].charclass.length = 0
                parser.state[3].charclass.cursor = 0
                // parser.state[3].charclass.value = 0

                parser.state[4].type = REGEX_TYPE_WHITESPACE
                // parser.state[4].value = 0
                parser.state[4].charclass.length = 0
                parser.state[4].charclass.cursor = 0
                // parser.state[4].charclass.value = 0
            }
            case 9: {
                parser.pattern.value = '\d?\w\s*'
                parser.pattern.length = 8
                parser.pattern.cursor = 1

                parser.count = 4

                parser.state[1].type = REGEX_TYPE_DIGIT
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_QUESTIONMARK
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0

                parser.state[3].type = REGEX_TYPE_ALPHA
                // parser.state[3].value = 0
                parser.state[3].charclass.length = 0
                parser.state[3].charclass.cursor = 0
                // parser.state[3].charclass.value = 0

                parser.state[4].type = REGEX_TYPE_STAR
                // parser.state[4].value = 0
                parser.state[4].charclass.length = 0
                parser.state[4].charclass.cursor = 0
                // parser.state[4].charclass.value = 0
            }
            case 10: {
                parser.pattern.value = '\D+'
                parser.pattern.length = 3
                parser.pattern.cursor = 1

                parser.count = 2

                parser.state[1].type = REGEX_TYPE_NOT_ALPHA
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_PLUS
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0
            }
            case 11: {
                parser.pattern.value = '\D*'
                parser.pattern.length = 3
                parser.pattern.cursor = 1

                parser.count = 2

                parser.state[1].type = REGEX_TYPE_NOT_ALPHA
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_STAR
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0
            }
            case 12: {
                parser.pattern.value = '\D\s'
                parser.pattern.length = 4
                parser.pattern.cursor = 1

                parser.count = 2

                parser.state[1].type = REGEX_TYPE_NOT_ALPHA
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_WHITESPACE
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0
            }
            case 13: {
                parser.pattern.value = '\W+'
                parser.pattern.length = 3
                parser.pattern.cursor = 1

                parser.count = 2

                parser.state[1].type = REGEX_TYPE_NOT_WHITESPACE
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_PLUS
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0
            }
            case 14: {
                parser.pattern.value = '\S*'
                parser.pattern.length = 3
                parser.pattern.cursor = 1

                parser.count = 2

                parser.state[1].type = REGEX_TYPE_NOT_WHITESPACE
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_STAR
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 0
                parser.state[2].charclass.cursor = 0
                // parser.state[2].charclass.value = 0
            }
            case 15: {
                parser.pattern.value = '^[a-zA-Z0-9_]+$'
                parser.pattern.length = 15
                parser.pattern.cursor = 1

                parser.count = 4

                parser.state[1].type = REGEX_TYPE_BEGIN
                // parser.state[1].value = 0
                parser.state[1].charclass.length = 0
                parser.state[1].charclass.cursor = 0
                // parser.state[1].charclass.value = 0

                parser.state[2].type = REGEX_TYPE_CHAR_CLASS
                // parser.state[2].value = 0
                parser.state[2].charclass.length = 10
                parser.state[2].charclass.cursor = 0
                parser.state[2].charclass.value = 'a-zA-Z0-9_'

                parser.state[3].type = REGEX_TYPE_PLUS
                // parser.state[3].value = 0
                parser.state[3].charclass.length = 0
                parser.state[3].charclass.cursor = 0
                // parser.state[3].charclass.value = 0

                parser.state[4].type = REGEX_TYPE_END
                // parser.state[4].value = 0
                parser.state[4].charclass.length = 0
                parser.state[4].charclass.cursor = 0
                // parser.state[4].charclass.value = 0
            }
        }
    }
}


define_function TestNAVRegexCompile() {
    stack_var integer x
    stack_var _NAVRegexParser expected

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexCompile *****************'")

    RegexCompileSetupExpected(expected)

    for (x = 1; x <= length_array(COMPILE_TEST); x++) {
        stack_var _NAVRegexParser parser

        if (!NAVRegexCompile(COMPILE_TEST[x], parser)) {
            NAVLog("'Test ', itoa(x), ' failed'")
            NAVLog("'Failed to compile pattern: "', COMPILE_TEST[x], '"'")
            continue
        }

        if (!AssertRegexParserDeepEqual(parser, expected)) {
            NAVLog("'Test ', itoa(x), ' failed'")
            NAVLog("'The compiled parser did not deep match the expected parser'")
            continue
        }

        NAVLogTestPassed(x)
    }
}


define_function char AssertRegexParserDeepEqual(_NAVRegexParser actual, _NAVRegexParser expected) {
    stack_var integer x

    if (actual.pattern.value != expected.pattern.value) {
        NAVLog("'Expected pattern value to be "', expected.pattern.value, '" but got "', actual.pattern.value, '"'")
        return false
    }

    if (actual.pattern.length != expected.pattern.length) {
        NAVLog("'Expected pattern length to be ', itoa(expected.pattern.length), ' but got ', itoa(actual.pattern.length)")
        return false
    }

    if (actual.pattern.cursor != expected.pattern.cursor) {
        NAVLog("'Expected pattern cursor to be ', itoa(expected.pattern.cursor), ' but got ', itoa(actual.pattern.cursor)")
        return false
    }

    if (actual.count != expected.count) {
        NAVLog("'Expected state count to be ', itoa(expected.count), ' but got ', itoa(actual.count)")
        return false
    }

    for (x = 1; x <= expected.count; x++) {
        if (actual.state[x].type != expected.state[x].type) {
            NAVLog("'Expected state ', itoa(x), ' type to be "', REGEX_TYPES[expected.state[x].type], '" but got "', REGEX_TYPES[actual.state[x].type], '"'")
            return false
        }

        if (actual.state[x].value != expected.state[x].value) {
            NAVLog("'Expected state ', itoa(x), ' value to be "', expected.state[x].value, '" but got "', actual.state[x].value, '"'")
            return false
        }

        if (actual.state[x].charclass.length != expected.state[x].charclass.length) {
            NAVLog("'Expected state ', itoa(x), ' charclass length to be ', itoa(expected.state[x].charclass.length), ' but got ', itoa(actual.state[x].charclass.length)")
            return false
        }

        if (actual.state[x].charclass.cursor != expected.state[x].charclass.cursor) {
            NAVLog("'Expected state ', itoa(x), ' charclass cursor to be ', itoa(expected.state[x].charclass.cursor), ' but got ', itoa(actual.state[x].charclass.cursor)")
            return false
        }

        if (actual.state[x].charclass.value != expected.state[x].charclass.value) {
            NAVLog("'Expected state ', itoa(x), ' charclass value to be "', expected.state[x].charclass.value, '" but got "', actual.state[x].charclass.value, '"'")
            return false
        }
    }

    return true
}
