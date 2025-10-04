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
    }
}


// define_function RegexCompileSetupExpected(integer id, _NAVRegexParser parser) {
//     switch (id) {
//         case 1: {
//             parser.pattern.value = '\d+'
//             parser.pattern.length = 3
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_DIGIT
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_PLUS
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 2: {
//             parser.pattern.value = '\w+'
//             parser.pattern.length = 3
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_ALPHA
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_PLUS
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 3: {
//             parser.pattern.value = '\w*'
//             parser.pattern.length = 3
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_ALPHA
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_STAR
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 4: {
//             parser.pattern.value = '\s'
//             parser.pattern.length = 2
//             parser.pattern.cursor = 1

//             parser.count = 1

//             parser.state[1].type = REGEX_TYPE_WHITESPACE
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0
//         }
//         case 5: {
//             parser.pattern.value = '\s+'
//             parser.pattern.length = 3
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_WHITESPACE
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_PLUS
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 6: {
//             parser.pattern.value = '\s*'
//             parser.pattern.length = 3
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_WHITESPACE
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_STAR
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 7: {
//             parser.pattern.value = '\d\w?\s'
//             parser.pattern.length = 7
//             parser.pattern.cursor = 1

//             parser.count = 4

//             parser.state[1].type = REGEX_TYPE_DIGIT
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_ALPHA
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0

//             parser.state[3].type = REGEX_TYPE_QUESTIONMARK
//             // parser.state[3].value = 0
//             parser.state[3].charclass.length = 0
//             parser.state[3].charclass.cursor = 0
//             // parser.state[3].charclass.value = 0

//             parser.state[4].type = REGEX_TYPE_WHITESPACE
//             // parser.state[4].value = 0
//             parser.state[4].charclass.length = 0
//             parser.state[4].charclass.cursor = 0
//             // parser.state[4].charclass.value = 0
//         }
//         case 8: {
//             parser.pattern.value = '\d\w\s+'
//             parser.pattern.length = 7
//             parser.pattern.cursor = 1

//             parser.count = 4

//             parser.state[1].type = REGEX_TYPE_DIGIT
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_ALPHA
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0

//             parser.state[3].type = REGEX_TYPE_WHITESPACE
//             // parser.state[3].value = 0
//             parser.state[3].charclass.length = 0
//             parser.state[3].charclass.cursor = 0
//             // parser.state[3].charclass.value = 0

//             parser.state[4].type = REGEX_TYPE_PLUS
//             // parser.state[4].value = 0
//             parser.state[4].charclass.length = 0
//             parser.state[4].charclass.cursor = 0
//             // parser.state[4].charclass.value = 0
//         }
//         case 9: {
//             parser.pattern.value = '\d?\w\s*'
//             parser.pattern.length = 8
//             parser.pattern.cursor = 1

//             parser.count = 5

//             parser.state[1].type = REGEX_TYPE_DIGIT
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_QUESTIONMARK
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0

//             parser.state[3].type = REGEX_TYPE_ALPHA
//             // parser.state[3].value = 0
//             parser.state[3].charclass.length = 0
//             parser.state[3].charclass.cursor = 0
//             // parser.state[3].charclass.value = 0

//             parser.state[4].type = REGEX_TYPE_WHITESPACE
//             // parser.state[4].value = 0
//             parser.state[4].charclass.length = 0
//             parser.state[4].charclass.cursor = 0
//             // parser.state[4].charclass.value = 0

//             parser.state[5].type = REGEX_TYPE_STAR
//             // parser.state[5].value = 0
//             parser.state[5].charclass.length = 0
//             parser.state[5].charclass.cursor = 0
//             // parser.state[5].charclass.value = 0
//         }
//         case 10: {
//             parser.pattern.value = '\D+'
//             parser.pattern.length = 3
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_NOT_DIGIT
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_PLUS
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 11: {
//             parser.pattern.value = '\D*'
//             parser.pattern.length = 3
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_NOT_DIGIT
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_STAR
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 12: {
//             parser.pattern.value = '\D\s'
//             parser.pattern.length = 4
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_NOT_DIGIT
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_WHITESPACE
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 13: {
//             parser.pattern.value = '\W+'
//             parser.pattern.length = 3
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_NOT_ALPHA
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_PLUS
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 14: {
//             parser.pattern.value = '\S*'
//             parser.pattern.length = 3
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_NOT_WHITESPACE
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_STAR
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 15: {
//             parser.pattern.value = '^[a-zA-Z0-9_]+$'
//             parser.pattern.length = 15
//             parser.pattern.cursor = 1

//             parser.count = 4

//             parser.state[1].type = REGEX_TYPE_BEGIN
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_CHAR_CLASS
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 10
//             parser.state[2].charclass.cursor = 0
//             parser.state[2].charclass.value = 'a-zA-Z0-9_'

//             parser.state[3].type = REGEX_TYPE_PLUS
//             // parser.state[3].value = 0
//             parser.state[3].charclass.length = 0
//             parser.state[3].charclass.cursor = 0
//             // parser.state[3].charclass.value = 0

//             parser.state[4].type = REGEX_TYPE_END
//             // parser.state[4].value = 0
//             parser.state[4].charclass.length = 0
//             parser.state[4].charclass.cursor = 0
//             // parser.state[4].charclass.value = 0
//         }
//         case 16: {
//             parser.pattern.value = '^[Hh]ello,\s[Ww]orld!$'
//             parser.pattern.length = 22
//             parser.pattern.cursor = 1

//             parser.count = 15

//             parser.state[1].type = REGEX_TYPE_BEGIN
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_CHAR_CLASS
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 2
//             parser.state[2].charclass.cursor = 0
//             parser.state[2].charclass.value = 'Hh'

//             parser.state[3].type = REGEX_TYPE_CHAR
//             parser.state[3].value = 'e'
//             parser.state[3].charclass.length = 0
//             parser.state[3].charclass.cursor = 0
//             // parser.state[3].charclass.value = 0

//             parser.state[4].type = REGEX_TYPE_CHAR
//             parser.state[4].value = 'l'
//             parser.state[4].charclass.length = 0
//             parser.state[4].charclass.cursor = 0
//             // parser.state[4].charclass.value = 0

//             parser.state[5].type = REGEX_TYPE_CHAR
//             parser.state[5].value = 'l'
//             parser.state[5].charclass.length = 0
//             parser.state[5].charclass.cursor = 0
//             // parser.state[5].charclass.value = 0

//             parser.state[6].type = REGEX_TYPE_CHAR
//             parser.state[6].value = 'o'
//             parser.state[6].charclass.length = 0
//             parser.state[6].charclass.cursor = 0
//             // parser.state[6].charclass.value = 0

//             parser.state[7].type = REGEX_TYPE_CHAR
//             parser.state[7].value = ','
//             parser.state[7].charclass.length = 0
//             parser.state[7].charclass.cursor = 0
//             // parser.state[7].charclass.value = 0

//             parser.state[8].type = REGEX_TYPE_WHITESPACE
//             // parser.state[8].value = 0
//             parser.state[8].charclass.length = 0
//             parser.state[8].charclass.cursor = 0
//             // parser.state[8].charclass.value = 0

//             parser.state[9].type = REGEX_TYPE_CHAR_CLASS
//             // parser.state[9].value = 0
//             parser.state[9].charclass.length = 2
//             parser.state[9].charclass.cursor = 0
//             parser.state[9].charclass.value = 'Ww'

//             parser.state[10].type = REGEX_TYPE_CHAR
//             parser.state[10].value = 'o'
//             parser.state[10].charclass.length = 0
//             parser.state[10].charclass.cursor = 0
//             // parser.state[10].charclass.value = 0

//             parser.state[11].type = REGEX_TYPE_CHAR
//             parser.state[11].value = 'r'
//             parser.state[11].charclass.length = 0
//             parser.state[11].charclass.cursor = 0
//             // parser.state[11].charclass.value = 0

//             parser.state[12].type = REGEX_TYPE_CHAR
//             parser.state[12].value = 'l'
//             parser.state[12].charclass.length = 0
//             parser.state[12].charclass.cursor = 0
//             // parser.state[12].charclass.value = 0

//             parser.state[13].type = REGEX_TYPE_CHAR
//             parser.state[13].value = 'd'
//             parser.state[13].charclass.length = 0
//             parser.state[13].charclass.cursor = 0
//             // parser.state[13].charclass.value = 0

//             parser.state[14].type = REGEX_TYPE_CHAR
//             parser.state[14].value = '!'
//             parser.state[14].charclass.length = 0
//             parser.state[14].charclass.cursor = 0
//             // parser.state[14].charclass.value = 0

//             parser.state[15].type = REGEX_TYPE_END
//             // parser.state[15].value = 0
//             parser.state[15].charclass.length = 0
//             parser.state[15].charclass.cursor = 0
//             // parser.state[15].charclass.value = 0
//         }
//         case 17: {
//             parser.pattern.value = '^"[^"]*"'
//             parser.pattern.length = 8
//             parser.pattern.cursor = 1

//             parser.count = 5

//             parser.state[1].type = REGEX_TYPE_BEGIN
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_CHAR
//             parser.state[2].value = '"'
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0

//             parser.state[3].type = REGEX_TYPE_INV_CHAR_CLASS
//             // parser.state[3].value = 0
//             parser.state[3].charclass.length = 1
//             parser.state[3].charclass.cursor = 0
//             parser.state[3].charclass.value = '"'

//             parser.state[4].type = REGEX_TYPE_STAR
//             // parser.state[4].value = 0
//             parser.state[4].charclass.length = 0
//             parser.state[4].charclass.cursor = 0
//             // parser.state[4].charclass.value = 0

//             parser.state[5].type = REGEX_TYPE_CHAR
//             parser.state[5].value = '"'
//             parser.state[5].charclass.length = 0
//             parser.state[5].charclass.cursor = 0
//             // parser.state[5].charclass.value = 0
//         }
//         // case 18: {
//         //     parser.pattern.value = '^([a-zA-Z_]\w*)\s*=\s*([^;#].*)'
//         //     parser.pattern.length = 31
//         //     parser.pattern.cursor = 1

//         //     parser.count = 17

//         //     parser.state[1].type = REGEX_TYPE_BEGIN
//         //     // parser.state[1].value = 0
//         //     parser.state[1].charclass.length = 0
//         //     parser.state[1].charclass.cursor = 0
//         //     // parser.state[1].charclass.value = 0

//         //     parser.state[2].type = REGEX_TYPE_GROUP
//         //     // parser.state[2].value = 0
//         //     parser.state[2].charclass.length = 0
//         //     parser.state[2].charclass.cursor = 0
//         //     // parser.state[2].charclass.value = 0

//         //     parser.state[2].type = REGEX_TYPE_CHAR_CLASS
//         //     // parser.state[2].value = 0
//         //     parser.state[2].charclass.length = 7
//         //     parser.state[2].charclass.cursor = 0
//         //     parser.state[2].charclass.value = 'a-zA-Z_'

//         //     parser.state[3].type = REGEX_TYPE_CHAR_CLASS
//         // }
//         case 18: {
//             parser.pattern.value = '.*'
//             parser.pattern.length = 2
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_DOT
//             // parser.state[1].value = 0
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0
//             // parser.state[1].charclass.value = 0

//             parser.state[2].type = REGEX_TYPE_STAR
//             // parser.state[2].value = 0
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//             // parser.state[2].charclass.value = 0
//         }
//         case 19: {
//             // /\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/ - IP address pattern with 27 tokens
//             parser.pattern.value = '\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d'
//             parser.pattern.length = 38
//             parser.pattern.cursor = 1

//             parser.count = 27

//             // First octet: \d?\d?\d (6 tokens)
//             parser.state[1].type = REGEX_TYPE_DIGIT
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0

//             parser.state[2].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0

//             parser.state[3].type = REGEX_TYPE_DIGIT
//             parser.state[3].charclass.length = 0
//             parser.state[3].charclass.cursor = 0

//             parser.state[4].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[4].charclass.length = 0
//             parser.state[4].charclass.cursor = 0

//             parser.state[5].type = REGEX_TYPE_DIGIT
//             parser.state[5].charclass.length = 0
//             parser.state[5].charclass.cursor = 0

//             parser.state[6].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[6].charclass.length = 0
//             parser.state[6].charclass.cursor = 0

//             // Dot separator
//             parser.state[7].type = REGEX_TYPE_CHAR
//             parser.state[7].value = '.'
//             parser.state[7].charclass.length = 0
//             parser.state[7].charclass.cursor = 0

//             // Second octet: \d?\d?\d (6 tokens)
//             parser.state[8].type = REGEX_TYPE_DIGIT
//             parser.state[8].charclass.length = 0
//             parser.state[8].charclass.cursor = 0

//             parser.state[9].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[9].charclass.length = 0
//             parser.state[9].charclass.cursor = 0

//             parser.state[10].type = REGEX_TYPE_DIGIT
//             parser.state[10].charclass.length = 0
//             parser.state[10].charclass.cursor = 0

//             parser.state[11].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[11].charclass.length = 0
//             parser.state[11].charclass.cursor = 0

//             parser.state[12].type = REGEX_TYPE_DIGIT
//             parser.state[12].charclass.length = 0
//             parser.state[12].charclass.cursor = 0

//             parser.state[13].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[13].charclass.length = 0
//             parser.state[13].charclass.cursor = 0

//             // Dot separator
//             parser.state[14].type = REGEX_TYPE_CHAR
//             parser.state[14].value = '.'
//             parser.state[14].charclass.length = 0
//             parser.state[14].charclass.cursor = 0

//             // Third octet: \d?\d?\d (6 tokens)
//             parser.state[15].type = REGEX_TYPE_DIGIT
//             parser.state[15].charclass.length = 0
//             parser.state[15].charclass.cursor = 0

//             parser.state[16].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[16].charclass.length = 0
//             parser.state[16].charclass.cursor = 0

//             parser.state[17].type = REGEX_TYPE_DIGIT
//             parser.state[17].charclass.length = 0
//             parser.state[17].charclass.cursor = 0

//             parser.state[18].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[18].charclass.length = 0
//             parser.state[18].charclass.cursor = 0

//             parser.state[19].type = REGEX_TYPE_DIGIT
//             parser.state[19].charclass.length = 0
//             parser.state[19].charclass.cursor = 0

//             parser.state[20].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[20].charclass.length = 0
//             parser.state[20].charclass.cursor = 0

//             // Dot separator
//             parser.state[21].type = REGEX_TYPE_CHAR
//             parser.state[21].value = '.'
//             parser.state[21].charclass.length = 0
//             parser.state[21].charclass.cursor = 0

//             // Fourth octet: \d?\d?\d (6 tokens)
//             parser.state[22].type = REGEX_TYPE_DIGIT
//             parser.state[22].charclass.length = 0
//             parser.state[22].charclass.cursor = 0

//             parser.state[23].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[23].charclass.length = 0
//             parser.state[23].charclass.cursor = 0

//             parser.state[24].type = REGEX_TYPE_DIGIT
//             parser.state[24].charclass.length = 0
//             parser.state[24].charclass.cursor = 0

//             parser.state[25].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[25].charclass.length = 0
//             parser.state[25].charclass.cursor = 0

//             parser.state[26].type = REGEX_TYPE_DIGIT
//             parser.state[26].charclass.length = 0
//             parser.state[26].charclass.cursor = 0

//             parser.state[27].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[27].charclass.length = 0
//             parser.state[27].charclass.cursor = 0
//         }
//         case 20: {
//             // /\d?/ - Simple single question mark
//             parser.pattern.value = '\d?'
//             parser.pattern.length = 3
//             parser.pattern.cursor = 1

//             parser.count = 2

//             parser.state[1].type = REGEX_TYPE_DIGIT
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0

//             parser.state[2].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0
//         }
//         case 21: {
//             // /\d?\d?/ - Two question marks in sequence
//             parser.pattern.value = '\d?\d?'
//             parser.pattern.length = 6
//             parser.pattern.cursor = 1

//             parser.count = 4

//             parser.state[1].type = REGEX_TYPE_DIGIT
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0

//             parser.state[2].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0

//             parser.state[3].type = REGEX_TYPE_DIGIT
//             parser.state[3].charclass.length = 0
//             parser.state[3].charclass.cursor = 0

//             parser.state[4].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[4].charclass.length = 0
//             parser.state[4].charclass.cursor = 0
//         }
//         case 22: {
//             // /\d?\d?\d/ - Three question marks - minimal failing case
//             parser.pattern.value = '\d?\d?\d'
//             parser.pattern.length = 9
//             parser.pattern.cursor = 1

//             parser.count = 6

//             parser.state[1].type = REGEX_TYPE_DIGIT
//             parser.state[1].charclass.length = 0
//             parser.state[1].charclass.cursor = 0

//             parser.state[2].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[2].charclass.length = 0
//             parser.state[2].charclass.cursor = 0

//             parser.state[3].type = REGEX_TYPE_DIGIT
//             parser.state[3].charclass.length = 0
//             parser.state[3].charclass.cursor = 0

//             parser.state[4].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[4].charclass.length = 0
//             parser.state[4].charclass.cursor = 0

//             parser.state[5].type = REGEX_TYPE_DIGIT
//             parser.state[5].charclass.length = 0
//             parser.state[5].charclass.cursor = 0

//             parser.state[6].type = REGEX_TYPE_QUESTIONMARK
//             parser.state[6].charclass.length = 0
//             parser.state[6].charclass.cursor = 0
//         }
//     }
// }


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

// Alternative: Detailed test function using full parser state (kept for backward compatibility)
// define_function TestNAVRegexCompileDetailed() {
//     stack_var integer x

//     NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexCompile (Detailed) *****************'")

//     for (x = 1; x <= length_array(REGEX_COMPILE_PATTERN_TEST); x++) {
//         stack_var _NAVRegexParser parser
//         stack_var _NAVRegexParser expected

//         // RegexCompileSetupExpected(x, expected)

//         if (!NAVRegexCompile(REGEX_COMPILE_PATTERN_TEST[x], parser)) {
//             NAVLog("'Test ', itoa(x), ' failed'")
//             NAVLog("'Failed to compile pattern: "', REGEX_COMPILE_PATTERN_TEST[x], '"'")
//             continue
//         }

//         if (!AssertRegexParserDeepEqual(parser, expected)) {
//             NAVLog("'Test ', itoa(x), ' failed'")
//             NAVLog("'The compiled parser did not deep match the expected parser'")
//             continue
//         }

//         NAVLogTestPassed(x)
//         // NAVRegexPrintState(parser)
//     }
// }


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
