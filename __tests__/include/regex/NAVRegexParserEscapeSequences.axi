PROGRAM_NAME='NAVRegexParserEscapeSequences'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexParserTestHelpers.axi'

DEFINE_CONSTANT

// Test type constants for special escape sequence validation
constant integer ESCAPE_TEST_SINGLE         = 1
constant integer ESCAPE_TEST_COMBINED       = 2
constant integer ESCAPE_TEST_WITH_QUANTIFIER = 3
constant integer ESCAPE_TEST_IN_GROUP       = 4
constant integer ESCAPE_TEST_WITH_ANCHOR    = 5
constant integer ESCAPE_TEST_IN_ALTERNATION = 6
constant integer ESCAPE_TEST_IN_PATTERN     = 7

// Test patterns for special escape sequence validation
constant char REGEX_PARSER_ESCAPE_PATTERN[][255] = {
    // Single escape sequences (7 tests)
    '/\n/',         // 1: Newline (LF)
    '/\r/',         // 2: Carriage return (CR)
    '/\t/',         // 3: Horizontal tab
    '/\f/',         // 4: Form feed
    '/\v/',         // 5: Vertical tab
    '/\a/',         // 6: Alert/bell
    '/\e/',         // 7: Escape character

    // Combined escapes (8 tests)
    '/\n\r/',       // 8: CRLF sequence
    '/\r\n/',       // 9: CRLF sequence (reversed)
    '/\t\t\t/',     // 10: Multiple tabs
    '/\n\n\n/',     // 11: Multiple newlines
    '/\a\t\n/',     // 12: Mixed escapes
    '/\f\v\e/',     // 13: Form feed, vertical tab, escape
    '/\r\n\t/',     // 14: Windows line ending + tab
    '/\e\[\d+m/',   // 15: ANSI escape sequence pattern

    // With quantifiers (5 tests)
    '/\n+/',        // 16: One or more newlines
    '/\t*/',        // 17: Zero or more tabs
    '/\r{2}/',      // 18: Exactly two carriage returns
    '/\n{1,3}/',    // 19: One to three newlines
    '/\t{2,}/',     // 20: Two or more tabs

    // In groups (4 tests)
    '/(\n\r)/',     // 21: CRLF in capturing group
    '/(?:\t\f)/',   // 22: Tab+form feed in non-capturing group
    '/(\r|\n)/',    // 23: CR or LF in capturing group
    '/(^\n)/',      // 24: Newline at start in group

    // With anchors (3 tests)
    '/^\n/',        // 25: Newline at start
    '/\t$/',        // 26: Tab at end
    '/^\r\n$/',     // 27: CRLF as entire match

    // In alternation (3 tests)
    '/\n|\r/',      // 28: Newline or carriage return
    '/\t|\f|\v/',   // 29: Tab or form feed or vertical tab
    '/\a|\e/'       // 30: Alert or escape
}

// Test type classifications
constant integer REGEX_PARSER_ESCAPE_TYPE[] = {
    ESCAPE_TEST_SINGLE,         // 1
    ESCAPE_TEST_SINGLE,         // 2
    ESCAPE_TEST_SINGLE,         // 3
    ESCAPE_TEST_SINGLE,         // 4
    ESCAPE_TEST_SINGLE,         // 5
    ESCAPE_TEST_SINGLE,         // 6
    ESCAPE_TEST_SINGLE,         // 7
    ESCAPE_TEST_COMBINED,       // 8
    ESCAPE_TEST_COMBINED,       // 9
    ESCAPE_TEST_COMBINED,       // 10
    ESCAPE_TEST_COMBINED,       // 11
    ESCAPE_TEST_COMBINED,       // 12
    ESCAPE_TEST_COMBINED,       // 13
    ESCAPE_TEST_COMBINED,       // 14
    ESCAPE_TEST_IN_PATTERN,     // 15: Complex ANSI pattern
    ESCAPE_TEST_WITH_QUANTIFIER, // 16
    ESCAPE_TEST_WITH_QUANTIFIER, // 17
    ESCAPE_TEST_WITH_QUANTIFIER, // 18
    ESCAPE_TEST_WITH_QUANTIFIER, // 19
    ESCAPE_TEST_WITH_QUANTIFIER, // 20
    ESCAPE_TEST_IN_GROUP,       // 21
    ESCAPE_TEST_IN_GROUP,       // 22
    ESCAPE_TEST_IN_GROUP,       // 23
    ESCAPE_TEST_IN_GROUP,       // 24
    ESCAPE_TEST_WITH_ANCHOR,    // 25
    ESCAPE_TEST_WITH_ANCHOR,    // 26
    ESCAPE_TEST_WITH_ANCHOR,    // 27
    ESCAPE_TEST_IN_ALTERNATION, // 28
    ESCAPE_TEST_IN_ALTERNATION, // 29
    ESCAPE_TEST_IN_ALTERNATION  // 30
}

// Expected character values for single escape tests
// Format: { test_number, expected_character_code }
constant integer REGEX_PARSER_ESCAPE_EXPECTED_VALUE[][2] = {
    { 1, $0A },  // \n = LF (Line Feed)
    { 2, $0D },  // \r = CR (Carriage Return)
    { 3, $09 },  // \t = HT (Horizontal Tab)
    { 4, $0C },  // \f = FF (Form Feed)
    { 5, $0B },  // \v = VT (Vertical Tab)
    { 6, $07 },  // \a = BEL (Bell/Alert)
    { 7, $1B }   // \e = ESC (Escape)
}

// Expected character sequences for combined escape tests
// Format: { test_number, count, char1, char2, char3 }
constant integer REGEX_PARSER_ESCAPE_COMBINED_EXPECTED[][5] = {
    { 8,  2, $0A, $0D, 0   },  // \n\r
    { 9,  2, $0D, $0A, 0   },  // \r\n
    { 10, 3, $09, $09, $09 },  // \t\t\t
    { 11, 3, $0A, $0A, $0A },  // \n\n\n
    { 12, 3, $07, $09, $0A },  // \a\t\n
    { 13, 3, $0C, $0B, $1B },  // \f\v\e
    { 14, 3, $0D, $0A, $09 }   // \r\n\t
}


define_function TestNAVRegexParserEscapeSequences() {
    stack_var integer x
    stack_var _NAVRegexLexer lexer
    stack_var _NAVRegexNFA nfa
    stack_var char pattern[255]
    stack_var integer testType

    NAVLog("'***************** NAVRegexParser - EscapeSequences *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_ESCAPE_PATTERN); x++) {
        pattern = REGEX_PARSER_ESCAPE_PATTERN[x]
        testType = REGEX_PARSER_ESCAPE_TYPE[x]

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

        // Test 3: Validate single escape sequences
        if (testType == ESCAPE_TEST_SINGLE) {
            stack_var integer i
            stack_var char foundExpected
            stack_var char expectedChar
            stack_var integer literalStateId

            foundExpected = false

            for (i = 1; i <= length_array(REGEX_PARSER_ESCAPE_EXPECTED_VALUE); i++) {
                if (REGEX_PARSER_ESCAPE_EXPECTED_VALUE[i][1] == x) {
                    expectedChar = type_cast(REGEX_PARSER_ESCAPE_EXPECTED_VALUE[i][2])

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

        // Test 4: Validate combined escape sequences
        if (testType == ESCAPE_TEST_COMBINED) {
            stack_var integer i
            stack_var char foundExpected

            foundExpected = false

            for (i = 1; i <= length_array(REGEX_PARSER_ESCAPE_COMBINED_EXPECTED); i++) {
                if (REGEX_PARSER_ESCAPE_COMBINED_EXPECTED[i][1] == x) {
                    stack_var integer expectedCount
                    stack_var integer j
                    stack_var integer literalStateId
                    stack_var char expectedChar

                    expectedCount = REGEX_PARSER_ESCAPE_COMBINED_EXPECTED[i][2]

                    for (j = 1; j <= expectedCount; j++) {
                        expectedChar = type_cast(REGEX_PARSER_ESCAPE_COMBINED_EXPECTED[i][2 + j])

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

        // Test 5: Validate escapes with quantifiers
        if (testType == ESCAPE_TEST_WITH_QUANTIFIER) {
            if (!NAVAssertTrue("'Test ', itoa(x), ': Pattern with quantified escape should have states'",
                               nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'nfa.stateCount > 0', "'nfa.stateCount = ', itoa(nfa.stateCount)")
                continue
            }
        }

        // Test 6: Validate escapes in groups
        if (testType == ESCAPE_TEST_IN_GROUP) {
            if (!NAVAssertTrue("'Test ', itoa(x), ': Pattern with grouped escape should parse'",
                               nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'nfa.stateCount > 0', "'nfa.stateCount = ', itoa(nfa.stateCount)")
                continue
            }
        }

        // Test 7: Validate escapes with anchors
        if (testType == ESCAPE_TEST_WITH_ANCHOR) {
            if (!NAVAssertTrue("'Test ', itoa(x), ': Pattern with anchored escape should parse'",
                               nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'nfa.stateCount > 0', "'nfa.stateCount = ', itoa(nfa.stateCount)")
                continue
            }
        }

        // Test 8: Validate escapes in alternation
        if (testType == ESCAPE_TEST_IN_ALTERNATION) {
            if (!NAVAssertTrue("'Test ', itoa(x), ': Pattern with alternation should parse'",
                               nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'nfa.stateCount > 0', "'nfa.stateCount = ', itoa(nfa.stateCount)")
                continue
            }
        }

        // Test 9: Validate complex patterns with escapes
        if (testType == ESCAPE_TEST_IN_PATTERN) {
            if (!NAVAssertTrue("'Test ', itoa(x), ': Complex pattern with escapes should parse'",
                               nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'nfa.stateCount > 0', "'nfa.stateCount = ', itoa(nfa.stateCount)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
