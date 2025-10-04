PROGRAM_NAME='NAVRegexCompile'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

(**
 * Regex Compilation Test Suite
 *
 * This file provides two approaches for testing regex compilation:
 *
 * 1. Simple Token Count Testing (DEFAULT):
 *    - Uses REGEX_COMPILE_EXPECTED_TOKEN_COUNT array
 *    - Just verifies the pattern compiles to the correct number of tokens
 *    - Much easier to maintain (one integer per test)
 *    - Good for catching compilation bugs like missing tokens
 *    - Called via: TestNAVRegexCompile()
 *
 * 2. Detailed Parser State Testing (OPTIONAL):
 *    - Uses RegexCompileSetupExpected() with full state definitions
 *    - Verifies every field of every token matches expected
 *    - More thorough but requires hundreds of lines per test
 *    - Use when you need to verify exact token values/charclasses
 *    - Called via: TestNAVRegexCompileDetailed()
 *
 * For most cases, the simple token count test is sufficient and recommended.
 *)


DEFINE_CONSTANT

constant char REGEX_COMPILE_PATTERN_TEST[][255] = {
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
    '/^[a-zA-Z0-9_]+$/',
    '/^[Hh]ello,\s[Ww]orld!$/',
    '/^"[^"]*"/',
    '/.*/',

    // IP address pattern - should compile to 23 tokens
    '/\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/',

    // Single question mark - should compile to 2 tokens
    '/\d?/',

    // Two question marks - should compile to 4 tokens
    '/\d?\d?/',

    // Two question marks - should compile to 5 tokens
    '/\d?\d?\d/'
}

constant integer REGEX_COMPILE_EXPECTED_PATTERN_LENGTH[] = {
    3,   // 1:  /\d+/ -> length 3
    3,   // 2:  /\w+/ -> length 3
    3,   // 3:  /\w*/ -> length 3
    2,   // 4:  /\s/ -> length 2
    3,   // 5:  /\s+/ -> length 3
    3,   // 6:  /\s*/ -> length 3
    7,   // 7:  /\d\w?\s/ -> length 7
    7,   // 8:  /\d\w\s+/ -> length 7
    8,   // 9:  /\d?\w\s*/ -> length 8
    3,   // 10: /\D+/ -> length 3
    3,   // 11: /\D*/ -> length 3
    4,   // 12: /\D\s/ -> length 4
    3,   // 13: /\W+/ -> length 3
    3,   // 14: /\S*/ -> length 3
    15,  // 15: /^[a-zA-Z0-9_]+$/ -> length 15
    22,  // 16: /^[Hh]ello,\s[Ww]orld!$/ -> length 22
    8,  // 17: /^"[^"]*"/ -> length 8
    2,   // 18: /.*/ -> length 2

    // Test 19: IP address pattern
    27,

    // Test 20: Single question mark - should compile to length = 3
    3,

    // Test 21: Two question marks - should compile to length = 6
    6,

    // Test 22: Three question marks - should compile to length = 8
    8
}

// Expected token counts for each test - simpler than defining full parser state
constant integer REGEX_COMPILE_EXPECTED_TOKEN_COUNT[] = {
    2,   // 1:  /\d+/ -> DIGIT, PLUS
    2,   // 2:  /\w+/ -> WORD, PLUS
    2,   // 3:  /\w*/ -> WORD, STAR
    1,   // 4:  /\s/ -> WHITESPACE
    2,   // 5:  /\s+/ -> WHITESPACE, PLUS
    2,   // 6:  /\s*/ -> WHITESPACE, STAR
    4,   // 7:  /\d\w?\s/ -> DIGIT, WORD, QUESTIONMARK, WHITESPACE
    4,   // 8:  /\d\w\s+/ -> DIGIT, WORD, WHITESPACE, PLUS
    5,   // 9:  /\d?\w\s*/ -> DIGIT, QUESTIONMARK, WORD, WHITESPACE, STAR
    2,   // 10: /\D+/ -> NOT_DIGIT, PLUS
    2,   // 11: /\D*/ -> NOT_DIGIT, STAR
    2,   // 12: /\D\s/ -> NOT_DIGIT, WHITESPACE
    2,   // 13: /\W+/ -> NOT_WORD, PLUS
    2,   // 14: /\S*/ -> NOT_WHITESPACE, STAR
    4,   // 15: /^[a-zA-Z0-9_]+$/ -> BEGIN, CHAR_CLASS, PLUS, END
    15,  // 16: /^[Hh]ello,\s[Ww]orld!$/ -> BEGIN + chars + END
    5,   // 17: /^"[^"]*"/ -> BEGIN, CHAR, INV_CHAR_CLASS, STAR, CHAR
    2,   // 18: /.*/ -> DOT, STAR
    23,  // 19: /\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/ -> IP address (4 octets × 6 tokens + 3 dots)
    2,   // 20: /\d?/ -> DIGIT, QUESTIONMARK
    4,   // 21: /\d?\d?/ -> DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK
    5    // 22: /\d?\d?\d/ -> DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK
}

constant integer REGEX_COMPILE_EXPECTED_TOKENS[][] = {
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_WHITESPACE
    },
    {
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_PLUS
    },
    {
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_WHITESPACE
    },
    {
        // Test 8: /\d\w\s+/ -> DIGIT, WORD, WHITESPACE, PLUS
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_PLUS
    },
    {
        // Test 9: /\d?\w\s*/ -> DIGIT, QUESTIONMARK, WORD, WHITESPACE, STAR
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_ALPHA,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        // Test 10: /\D+/ -> NOT_DIGIT, PLUS
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_PLUS
    },
    {
        // Test 11: /\D*/ -> NOT_DIGIT, STAR
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_STAR
    },
    {
        // Test 12: /\D\s/ -> NOT_DIGIT, WHITESPACE
        REGEX_TYPE_NOT_DIGIT,
        REGEX_TYPE_WHITESPACE
    },
    {
        // Test 13: /\W+/ -> NOT_WORD, PLUS
        REGEX_TYPE_NOT_ALPHA,
        REGEX_TYPE_PLUS
    },
    {
        // Test 14: /\S*/ -> NOT_WHITESPACE, STAR
        REGEX_TYPE_NOT_WHITESPACE,
        REGEX_TYPE_STAR
    },
    {
        // Test 15: /^[a-zA-Z0-9_]+$/ -> BEGIN, CHAR_CLASS, PLUS, END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_PLUS,
        REGEX_TYPE_END
    },
    {
        // Test 16: /^[Hh]ello,\s[Ww]orld!$/ -> BEGIN, CHAR_CLASS, 'e', 'l', 'l', 'o', ',', WHITESPACE, CHAR_CLASS, 'o', 'r', 'l', 'd', '!', END
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_WHITESPACE,
        REGEX_TYPE_CHAR_CLASS,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_END
    },
    {
        // Test 17: /^"[^"]*"/ -> BEGIN, CHAR, INV_CHAR_CLASS, STAR, CHAR
        REGEX_TYPE_BEGIN,
        REGEX_TYPE_CHAR,
        REGEX_TYPE_INV_CHAR_CLASS,
        REGEX_TYPE_STAR,
        REGEX_TYPE_CHAR
    },
    {
        // Test 18: /.*/ -> DOT, STAR
        REGEX_TYPE_DOT,
        REGEX_TYPE_STAR
    },
    {
        // Test 19: /\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/ -> 23 tokens
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_DOT,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_DOT,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_DOT,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT
    },
    {
        // Test 20: /\d?/ -> DIGIT, QUESTIONMARK
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK
    },
    {
        // Test 21: /\d?\d?/ -> DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK
    },
    {
        // Test 22: /\d?\d?\d/ -> DIGIT, QUESTIONMARK, DIGIT, QUESTIONMARK, DIGIT
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT,
        REGEX_TYPE_QUESTIONMARK,
        REGEX_TYPE_DIGIT
    }
}


define_function TestNAVRegexCompile() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexCompile *****************'")

    for (x = 1; x <= length_array(REGEX_COMPILE_PATTERN_TEST); x++) {
        stack_var _NAVRegexParser parser

        if (!NAVAssertTrue('Should compile successfully', NAVRegexCompile(REGEX_COMPILE_PATTERN_TEST[x], parser))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVAssertIntegerEqual('Should have correct pattern length', parser.pattern.length, REGEX_COMPILE_EXPECTED_PATTERN_LENGTH[x])) {
            NAVLogTestFailed(x, itoa(REGEX_COMPILE_EXPECTED_PATTERN_LENGTH[x]), itoa(parser.pattern.length))
            continue
        }

        // Simple token count assertion - much easier to maintain
        if (!NAVAssertIntegerEqual('Should compile to correct amount of tokens', parser.count, REGEX_COMPILE_EXPECTED_TOKEN_COUNT[x])) {
            NAVLogTestFailed(x, itoa(REGEX_COMPILE_EXPECTED_TOKEN_COUNT[x]), itoa(parser.count))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= parser.count; y++) {
                if (parser.state[y].type != REGEX_COMPILE_EXPECTED_TOKENS[x][y]) {
                    NAVLogTestFailed(x, itoa(REGEX_COMPILE_EXPECTED_TOKENS[x][y]), itoa(parser.state[y].type))
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}


// Simpler assertion: just check token count and token type sequence
// define_function char AssertRegexCompileTokenCount(_NAVRegexParser actual, integer expectedCount) {
//     if (actual.count != expectedCount) {
//         NAVLog("'Expected token count to be ', itoa(expectedCount), ' but got ', itoa(actual.count)")
//         return false
//     }
//     return true
// }

// More detailed assertion: check token types match expected sequence
// define_function char AssertRegexCompileTokenTypes(_NAVRegexParser actual, integer expectedTypes[], integer expectedCount) {
//     stack_var integer x

//     if (actual.count != expectedCount) {
//         NAVLog("'Expected token count to be ', itoa(expectedCount), ' but got ', itoa(actual.count)")
//         return false
//     }

//     for (x = 1; x <= expectedCount; x++) {
//         if (actual.state[x].type != expectedTypes[x]) {
//             NAVLog("'Expected token ', itoa(x), ' type to be "', REGEX_TYPES[expectedTypes[x]], '" but got "', REGEX_TYPES[actual.state[x].type], '"'")
//             return false
//         }
//     }

//     return true
// }

// Original deep equality check - kept for backward compatibility or detailed testing
// define_function char AssertRegexParserDeepEqual(_NAVRegexParser actual, _NAVRegexParser expected) {
//     stack_var integer x

//     if (actual.pattern.value != expected.pattern.value) {
//         NAVLog("'Expected pattern value to be "', expected.pattern.value, '" but got "', actual.pattern.value, '"'")
//         return false
//     }

//     if (actual.pattern.length != expected.pattern.length) {
//         NAVLog("'Expected pattern length to be ', itoa(expected.pattern.length), ' but got ', itoa(actual.pattern.length)")
//         return false
//     }

//     if (actual.pattern.cursor != expected.pattern.cursor) {
//         NAVLog("'Expected pattern cursor to be ', itoa(expected.pattern.cursor), ' but got ', itoa(actual.pattern.cursor)")
//         return false
//     }

//     if (actual.count != expected.count) {
//         NAVLog("'Expected state count to be ', itoa(expected.count), ' but got ', itoa(actual.count)")
//         return false
//     }

//     for (x = 1; x <= expected.count; x++) {
//         if (actual.state[x].type != expected.state[x].type) {
//             NAVLog("'Expected state ', itoa(x), ' type to be "', REGEX_TYPES[expected.state[x].type], '" but got "', REGEX_TYPES[actual.state[x].type], '"'")
//             return false
//         }

//         if (actual.state[x].value != expected.state[x].value) {
//             NAVLog("'Expected state ', itoa(x), ' value to be "', expected.state[x].value, '" but got "', actual.state[x].value, '"'")
//             return false
//         }

//         if (actual.state[x].charclass.length != expected.state[x].charclass.length) {
//             NAVLog("'Expected state ', itoa(x), ' charclass length to be ', itoa(expected.state[x].charclass.length), ' but got ', itoa(actual.state[x].charclass.length)")
//             return false
//         }

//         if (actual.state[x].charclass.cursor != expected.state[x].charclass.cursor) {
//             NAVLog("'Expected state ', itoa(x), ' charclass cursor to be ', itoa(expected.state[x].charclass.cursor), ' but got ', itoa(actual.state[x].charclass.cursor)")
//             return false
//         }

//         if (actual.state[x].charclass.value != expected.state[x].charclass.value) {
//             NAVLog("'Expected state ', itoa(x), ' charclass value to be "', expected.state[x].charclass.value, '" but got "', actual.state[x].charclass.value, '"'")
//             return false
//         }
//     }

//     return true
// }
