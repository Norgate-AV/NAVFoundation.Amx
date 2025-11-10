PROGRAM_NAME='NAVRegexParserHexEscapes'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexParserTestHelpers.axi'

DEFINE_CONSTANT

// Test type constants for hex escape sequence validation
constant integer HEX_TEST_SINGLE         = 1
constant integer HEX_TEST_COMBINED       = 2
constant integer HEX_TEST_WITH_QUANTIFIER = 3
constant integer HEX_TEST_IN_GROUP       = 4
constant integer HEX_TEST_WITH_ANCHOR    = 5
constant integer HEX_TEST_IN_PATTERN     = 6

// Test patterns for hex escape sequence validation
constant char REGEX_PARSER_HEX_PATTERN[][255] = {
    // Single hex escapes (8 tests)
    '/\x41/',       // 1: 'A' (uppercase letter)
    '/\x42/',       // 2: 'B'
    '/\x30/',       // 3: '0' (digit)
    '/\x20/',       // 4: ' ' (space)
    '/\x0A/',       // 5: '\n' (newline)
    '/\x0D/',       // 6: '\r' (carriage return)
    '/\xFF/',       // 7: 0xFF (high byte)
    '/\x00/',       // 8: NULL character

    // Combined hex escapes (5 tests)
    '/\x41\x42\x43/', // 9: 'ABC'
    '/\x30\x31\x32/', // 10: '012'
    '/\x48\x65\x6C\x6C\x6F/', // 11: 'Hello'
    '/\x0D\x0A/',   // 12: CRLF
    '/\x20\x09\x0A/', // 13: Space, tab, newline

    // With quantifiers (5 tests)
    '/\x41+/',      // 14: One or more 'A'
    '/\x20*/',      // 15: Zero or more spaces
    '/\x30{2}/',    // 16: Exactly two '0's
    '/\x0A{1,3}/',  // 17: One to three newlines
    '/\x42{2,}/',   // 18: Two or more 'B's

    // In groups (4 tests)
    '/(\x41\x42)/', // 19: 'AB' in capturing group
    '/(?:\x30\x31)/', // 20: '01' in non-capturing group
    '/(\x0D|\x0A)/', // 21: CR or LF in group
    '/(^\x41)/',    // 22: 'A' at start in group

    // With anchors (3 tests)
    '/^\x41/',      // 23: 'A' at start
    '/\x42$/',      // 24: 'B' at end
    '/^\x30\x31$/'  // 25: '01' as entire match
}

// Test type classifications
constant integer REGEX_PARSER_HEX_TYPE[] = {
    HEX_TEST_SINGLE,         // 1
    HEX_TEST_SINGLE,         // 2
    HEX_TEST_SINGLE,         // 3
    HEX_TEST_SINGLE,         // 4
    HEX_TEST_SINGLE,         // 5
    HEX_TEST_SINGLE,         // 6
    HEX_TEST_SINGLE,         // 7
    HEX_TEST_SINGLE,         // 8
    HEX_TEST_COMBINED,       // 9
    HEX_TEST_COMBINED,       // 10
    HEX_TEST_COMBINED,       // 11
    HEX_TEST_COMBINED,       // 12
    HEX_TEST_COMBINED,       // 13
    HEX_TEST_WITH_QUANTIFIER, // 14
    HEX_TEST_WITH_QUANTIFIER, // 15
    HEX_TEST_WITH_QUANTIFIER, // 16
    HEX_TEST_WITH_QUANTIFIER, // 17
    HEX_TEST_WITH_QUANTIFIER, // 18
    HEX_TEST_IN_GROUP,       // 19
    HEX_TEST_IN_GROUP,       // 20
    HEX_TEST_IN_GROUP,       // 21
    HEX_TEST_IN_GROUP,       // 22
    HEX_TEST_WITH_ANCHOR,    // 23
    HEX_TEST_WITH_ANCHOR,    // 24
    HEX_TEST_WITH_ANCHOR     // 25
}

// Expected character values for single hex escape tests
// Format: { test_number, expected_character_code }
constant integer REGEX_PARSER_HEX_EXPECTED_VALUE[][2] = {
    { 1, $41 },  // \x41 = 'A'
    { 2, $42 },  // \x42 = 'B'
    { 3, $30 },  // \x30 = '0'
    { 4, $20 },  // \x20 = ' ' (space)
    { 5, $0A },  // \x0A = LF (newline)
    { 6, $0D },  // \x0D = CR (carriage return)
    { 7, $FF },  // \xFF = 255
    { 8, $00 }   // \x00 = NULL
}

// Expected character sequences for combined hex escape tests
// Format: { test_number, count, char1, char2, char3, char4, char5 }
constant integer REGEX_PARSER_HEX_COMBINED_EXPECTED[][7] = {
    { 9,  3, $41, $42, $43, 0,   0   },  // \x41\x42\x43 = 'ABC'
    { 10, 3, $30, $31, $32, 0,   0   },  // \x30\x31\x32 = '012'
    { 11, 5, $48, $65, $6C, $6C, $6F },  // \x48\x65\x6C\x6C\x6F = 'Hello'
    { 12, 2, $0D, $0A, 0,   0,   0   },  // \x0D\x0A = CRLF
    { 13, 3, $20, $09, $0A, 0,   0   }   // \x20\x09\x0A = space, tab, newline
}


define_function TestNAVRegexParserHexEscapes() {
    stack_var integer x
    stack_var _NAVRegexLexer lexer
    stack_var _NAVRegexNFA nfa
    stack_var char pattern[255]
    stack_var integer testType

    NAVLog("'***************** NAVRegexParser - HexEscapes *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_HEX_PATTERN); x++) {
        pattern = REGEX_PARSER_HEX_PATTERN[x]
        testType = REGEX_PARSER_HEX_TYPE[x]

        // Test 1: Tokenize
        if (!NAVAssertTrue("'Test ', itoa(x), ': Should tokenize pattern: ', pattern",
                           NAVRegexLexerTokenize(pattern, lexer))) {
            NAVLogTestFailed(x, 'tokenization success', 'tokenization failed')
            continue
        }

        // Test 2: Parse
        if (!NAVAssertTrue("'Test ', itoa(x), ': Should parse pattern: ', pattern",
                           NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Test 3: Validate single hex escape sequences
        if (testType == HEX_TEST_SINGLE) {
            stack_var integer i
            stack_var char foundExpected
            stack_var char expectedChar
            stack_var integer literalStateId

            foundExpected = false

            for (i = 1; i <= length_array(REGEX_PARSER_HEX_EXPECTED_VALUE); i++) {
                if (REGEX_PARSER_HEX_EXPECTED_VALUE[i][1] == x) {
                    expectedChar = type_cast(REGEX_PARSER_HEX_EXPECTED_VALUE[i][2])

                    if (!NAVAssertTrue("'Test ', itoa(x), ': Should have literal state with value ', itoa(expectedChar)",
                                       FindLiteralState(nfa, expectedChar, literalStateId))) {
                        NAVLogTestFailed(x, "'literal state with value ', itoa(expectedChar)", 'no matching literal state')
                        continue
                    }

                    if (!NAVAssertTrue("'Test ', itoa(x), ': Literal state should have correct character value'",
                                       nfa.states[literalStateId].matchChar == expectedChar)) {
                        NAVLogTestFailed(x, "'matchChar = ', itoa(expectedChar)", "'matchChar = ', itoa(nfa.states[literalStateId].matchChar)")
                        continue
                    }

                    foundExpected = true
                    break
                }
            }

            if (!foundExpected) {
                NAVLogTestFailed(x, 'expected value found', 'no expected value defined')
                continue
            }
        }

        // Test 4: Validate combined hex escape sequences
        if (testType == HEX_TEST_COMBINED) {
            stack_var integer i
            stack_var char foundExpected

            foundExpected = false

            for (i = 1; i <= length_array(REGEX_PARSER_HEX_COMBINED_EXPECTED); i++) {
                if (REGEX_PARSER_HEX_COMBINED_EXPECTED[i][1] == x) {
                    stack_var integer expectedCount
                    stack_var integer j
                    stack_var integer literalStateId
                    stack_var char expectedChar

                    expectedCount = REGEX_PARSER_HEX_COMBINED_EXPECTED[i][2]

                    for (j = 1; j <= expectedCount; j++) {
                        expectedChar = type_cast(REGEX_PARSER_HEX_COMBINED_EXPECTED[i][2 + j])

                        if (!NAVAssertTrue("'Test ', itoa(x), ': Should have literal state for char ', itoa(j), ' with value ', itoa(expectedChar)",
                                           FindLiteralState(nfa, expectedChar, literalStateId))) {
                            NAVLogTestFailed(x, "'literal state for char ', itoa(j), ' with value ', itoa(expectedChar)", 'no matching literal state')
                            continue
                        }
                    }

                    foundExpected = true
                    break
                }
            }

            if (!foundExpected) {
                NAVLogTestFailed(x, 'expected sequence found', 'no expected sequence defined')
                continue
            }
        }

        // Test 5: Validate hex escapes with quantifiers
        if (testType == HEX_TEST_WITH_QUANTIFIER) {
            if (!NAVAssertTrue("'Test ', itoa(x), ': Pattern with quantified hex escape should have states'",
                               nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'nfa.stateCount > 0', "'nfa.stateCount = ', itoa(nfa.stateCount)")
                continue
            }
        }

        // Test 6: Validate hex escapes in groups
        if (testType == HEX_TEST_IN_GROUP) {
            if (!NAVAssertTrue("'Test ', itoa(x), ': Pattern with grouped hex escape should parse'",
                               nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'nfa.stateCount > 0', "'nfa.stateCount = ', itoa(nfa.stateCount)")
                continue
            }
        }

        // Test 7: Validate hex escapes with anchors
        if (testType == HEX_TEST_WITH_ANCHOR) {
            if (!NAVAssertTrue("'Test ', itoa(x), ': Pattern with anchored hex escape should parse'",
                               nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'nfa.stateCount > 0', "'nfa.stateCount = ', itoa(nfa.stateCount)")
                continue
            }
        }

        // Test 8: Validate complex patterns with hex escapes
        if (testType == HEX_TEST_IN_PATTERN) {
            if (!NAVAssertTrue("'Test ', itoa(x), ': Complex pattern with hex escapes should parse'",
                               nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'nfa.stateCount > 0', "'nfa.stateCount = ', itoa(nfa.stateCount)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
