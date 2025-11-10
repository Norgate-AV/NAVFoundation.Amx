PROGRAM_NAME='NAVRegexParserLookarounds'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexParserTestHelpers.axi'

DEFINE_CONSTANT

// Test type constants for lookaround validation
constant integer LOOKAROUND_TEST_LOOKAHEAD_POS      = 1
constant integer LOOKAROUND_TEST_LOOKAHEAD_NEG      = 2
constant integer LOOKAROUND_TEST_LOOKBEHIND_POS     = 3
constant integer LOOKAROUND_TEST_LOOKBEHIND_NEG     = 4
constant integer LOOKAROUND_TEST_COMBINED           = 5
constant integer LOOKAROUND_TEST_NESTED             = 6
constant integer LOOKAROUND_TEST_WITH_GROUPS        = 7

// Test patterns for lookaround validation
constant char REGEX_PARSER_LOOKAROUND_PATTERN[][255] = {
    // Positive lookahead (?=...)
    '/a(?=b)/',                     // 1: Simple positive lookahead
    '/\d(?=px)/',                   // 2: Digit followed by 'px' (CSS-like)
    '/q(?=u)/',                     // 3: 'q' followed by 'u'
    '/foo(?=bar)/',                 // 4: Multi-char lookahead
    '/\w+(?=\s)/',                  // 5: Word followed by whitespace

    // Negative lookahead (?!...)
    '/a(?!b)/',                     // 6: Simple negative lookahead
    '/\d(?!px)/',                   // 7: Digit NOT followed by 'px'
    '/q(?!u)/',                     // 8: 'q' NOT followed by 'u'
    '/foo(?!bar)/',                 // 9: Multi-char negative lookahead
    '/\w+(?!\d)/',                  // 10: Word NOT followed by digit

    // Positive lookbehind (?<=...)
    '/(?<=a)b/',                    // 11: Simple positive lookbehind
    '/(?<=\$)\d+/',                 // 12: Digits preceded by dollar sign
    '/(?<=@)\w+/',                  // 13: Word preceded by @
    '/(?<=foo)bar/',                // 14: Multi-char lookbehind
    '/(?<=\d)\w+/',                 // 15: Word preceded by digit

    // Negative lookbehind (?<!...)
    '/(?<!a)b/',                    // 16: Simple negative lookbehind
    '/(?<!\$)\d+/',                 // 17: Digits NOT preceded by dollar
    '/(?<!@)\w+/',                  // 18: Word NOT preceded by @
    '/(?<!foo)bar/',                // 19: Multi-char negative lookbehind
    '/(?<!\d)\w+/',                 // 20: Word NOT preceded by digit

    // Combined lookarounds
    '/(?<=\w)(?=\w)/',              // 21: Between two word chars
    '/a(?=b)(?!c)/',                // 22: Positive and negative lookahead
    '/(?<=a)(?!b)/',                // 23: Lookbehind and negative lookahead
    '/(?<=a)b(?=c)/',               // 24: Both lookbehind and lookahead
    '/(?<!a)b(?!c)/',               // 25: Both negative lookbehind and lookahead

    // Nested lookarounds
    '/a(?=b(?=c))/',                // 26: Nested positive lookaheads
    '/a(?!b(?!c))/',                // 27: Nested negative lookaheads
    '/(?<=a(?<=b))c/',              // 28: Nested positive lookbehinds

    // Lookarounds with capturing groups
    '/a(?=(b))c/',                  // 29: Lookahead with capture
    '/(?<=(a))b/',                  // 30: Lookbehind with capture
    '/(a)(?=b)\1/',                 // 31: Capture and lookahead with backref

    // Complex patterns
    '/(?=.*\d)(?=.*[a-z])/',        // 32: Password validation pattern
    '/\b(?=\w{3,})\w+\b/',          // 33: Words 3+ chars with lookahead
    '/(?<=\s|^)\w+(?=\s|$)/',       // 34: Word boundaries with lookarounds
    '/(?<!\\)x/',                   // 35: Character NOT preceded by backslash (negative lookbehind)
    '/\d+(?=(\.\d+)?)/'             // 36: Number with optional decimal lookahead
}

constant integer REGEX_PARSER_LOOKAROUND_TYPE[] = {
    LOOKAROUND_TEST_LOOKAHEAD_POS,      // 1
    LOOKAROUND_TEST_LOOKAHEAD_POS,      // 2
    LOOKAROUND_TEST_LOOKAHEAD_POS,      // 3
    LOOKAROUND_TEST_LOOKAHEAD_POS,      // 4
    LOOKAROUND_TEST_LOOKAHEAD_POS,      // 5
    LOOKAROUND_TEST_LOOKAHEAD_NEG,      // 6
    LOOKAROUND_TEST_LOOKAHEAD_NEG,      // 7
    LOOKAROUND_TEST_LOOKAHEAD_NEG,      // 8
    LOOKAROUND_TEST_LOOKAHEAD_NEG,      // 9
    LOOKAROUND_TEST_LOOKAHEAD_NEG,      // 10
    LOOKAROUND_TEST_LOOKBEHIND_POS,     // 11
    LOOKAROUND_TEST_LOOKBEHIND_POS,     // 12
    LOOKAROUND_TEST_LOOKBEHIND_POS,     // 13
    LOOKAROUND_TEST_LOOKBEHIND_POS,     // 14
    LOOKAROUND_TEST_LOOKBEHIND_POS,     // 15
    LOOKAROUND_TEST_LOOKBEHIND_NEG,     // 16
    LOOKAROUND_TEST_LOOKBEHIND_NEG,     // 17
    LOOKAROUND_TEST_LOOKBEHIND_NEG,     // 18
    LOOKAROUND_TEST_LOOKBEHIND_NEG,     // 19
    LOOKAROUND_TEST_LOOKBEHIND_NEG,     // 20
    LOOKAROUND_TEST_COMBINED,           // 21
    LOOKAROUND_TEST_COMBINED,           // 22
    LOOKAROUND_TEST_COMBINED,           // 23
    LOOKAROUND_TEST_COMBINED,           // 24
    LOOKAROUND_TEST_COMBINED,           // 25
    LOOKAROUND_TEST_NESTED,             // 26
    LOOKAROUND_TEST_NESTED,             // 27
    LOOKAROUND_TEST_NESTED,             // 28
    LOOKAROUND_TEST_WITH_GROUPS,        // 29
    LOOKAROUND_TEST_WITH_GROUPS,        // 30
    LOOKAROUND_TEST_WITH_GROUPS,        // 31
    LOOKAROUND_TEST_COMBINED,           // 32
    LOOKAROUND_TEST_COMBINED,           // 33
    LOOKAROUND_TEST_COMBINED,           // 34
    LOOKAROUND_TEST_COMBINED,           // 35
    LOOKAROUND_TEST_WITH_GROUPS         // 36
}

// Expected lookaround state types
// Format: [test_index, expected_state_type]
constant integer REGEX_PARSER_LOOKAROUND_EXPECTED_TYPE[][2] = {
    { 1, NFA_STATE_LOOKAHEAD_POS },     // Test 1
    { 2, NFA_STATE_LOOKAHEAD_POS },     // Test 2
    { 3, NFA_STATE_LOOKAHEAD_POS },     // Test 3
    { 4, NFA_STATE_LOOKAHEAD_POS },     // Test 4
    { 5, NFA_STATE_LOOKAHEAD_POS },     // Test 5
    { 6, NFA_STATE_LOOKAHEAD_NEG },     // Test 6
    { 7, NFA_STATE_LOOKAHEAD_NEG },     // Test 7
    { 8, NFA_STATE_LOOKAHEAD_NEG },     // Test 8
    { 9, NFA_STATE_LOOKAHEAD_NEG },     // Test 9
    { 10, NFA_STATE_LOOKAHEAD_NEG },    // Test 10
    { 11, NFA_STATE_LOOKBEHIND_POS },   // Test 11
    { 12, NFA_STATE_LOOKBEHIND_POS },   // Test 12
    { 13, NFA_STATE_LOOKBEHIND_POS },   // Test 13
    { 14, NFA_STATE_LOOKBEHIND_POS },   // Test 14
    { 15, NFA_STATE_LOOKBEHIND_POS },   // Test 15
    { 16, NFA_STATE_LOOKBEHIND_NEG },   // Test 16
    { 17, NFA_STATE_LOOKBEHIND_NEG },   // Test 17
    { 18, NFA_STATE_LOOKBEHIND_NEG },   // Test 18
    { 19, NFA_STATE_LOOKBEHIND_NEG },   // Test 19
    { 20, NFA_STATE_LOOKBEHIND_NEG }    // Test 20
}

// Combined lookaround tests - which state types to expect
// Format: [test_index, count, state_type_1, state_type_2, ...]
constant integer REGEX_PARSER_LOOKAROUND_COMBINED[][5] = {
    { 21, 2, NFA_STATE_LOOKBEHIND_POS, NFA_STATE_LOOKAHEAD_POS, 0 },    // Test 21
    { 22, 2, NFA_STATE_LOOKAHEAD_POS, NFA_STATE_LOOKAHEAD_NEG, 0 },     // Test 22
    { 23, 2, NFA_STATE_LOOKBEHIND_POS, NFA_STATE_LOOKAHEAD_NEG, 0 },    // Test 23
    { 24, 2, NFA_STATE_LOOKBEHIND_POS, NFA_STATE_LOOKAHEAD_POS, 0 },    // Test 24
    { 25, 2, NFA_STATE_LOOKBEHIND_NEG, NFA_STATE_LOOKAHEAD_NEG, 0 },    // Test 25
    { 32, 2, NFA_STATE_LOOKAHEAD_POS, NFA_STATE_LOOKAHEAD_POS, 0 },     // Test 32
    { 33, 1, NFA_STATE_LOOKAHEAD_POS, 0, 0 },                            // Test 33
    { 34, 2, NFA_STATE_LOOKBEHIND_POS, NFA_STATE_LOOKAHEAD_POS, 0 },    // Test 34
    { 35, 1, NFA_STATE_LOOKBEHIND_NEG, 0, 0 }                            // Test 35
}

// Error case patterns - these should fail to parse
constant char REGEX_PARSER_LOOKAROUND_ERROR_PATTERN[][255] = {
    '/(?=)/',                       // 1: Empty lookahead
    '/(?!)/',                       // 2: Empty negative lookahead
    '/(?<=)/',                      // 3: Empty lookbehind
    '/(?<!)/',                      // 4: Empty negative lookbehind
    '/(?=/',                        // 5: Unclosed lookahead
    '/(?<=/'                        // 6: Unclosed lookbehind
}


/**
 * @function TestNAVRegexParserLookarounds
 * @description Test lookaround assertion parsing and NFA construction.
 *
 * Tests:
 * - Positive lookahead (?=...)
 * - Negative lookahead (?!...)
 * - Positive lookbehind (?<=...)
 * - Negative lookbehind (?<!...)
 * - Combined lookarounds
 * - Nested lookarounds
 * - Lookarounds with capturing groups
 */
define_function TestNAVRegexParserLookarounds() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Lookarounds *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_LOOKAROUND_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer testType
        stack_var char foundLookaround

        testType = REGEX_PARSER_LOOKAROUND_TYPE[x]

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_LOOKAROUND_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Test based on type
        select {
            // Simple lookaround tests (single lookaround assertion)
            active (testType == LOOKAROUND_TEST_LOOKAHEAD_POS ||
                    testType == LOOKAROUND_TEST_LOOKAHEAD_NEG ||
                    testType == LOOKAROUND_TEST_LOOKBEHIND_POS ||
                    testType == LOOKAROUND_TEST_LOOKBEHIND_NEG): {
                stack_var integer i
                stack_var integer expectedType
                stack_var integer lookaroundStateId

                foundLookaround = false

                // Find expected type for this test
                for (i = 1; i <= length_array(REGEX_PARSER_LOOKAROUND_EXPECTED_TYPE); i++) {
                    if (REGEX_PARSER_LOOKAROUND_EXPECTED_TYPE[i][1] == x) {
                        expectedType = REGEX_PARSER_LOOKAROUND_EXPECTED_TYPE[i][2]

                        // Find lookaround state
                        if (!FindLookaroundState(nfa, expectedType, lookaroundStateId)) {
                            NAVLogTestFailed(x, "'lookaround state type ', itoa(expectedType)", 'no lookaround state found')
                            foundLookaround = true
                            break
                        }

                        // Validate sub-expression
                        if (!ValidateLookaroundSubExpression(nfa, lookaroundStateId)) {
                            NAVLogTestFailed(x, 'valid sub-expression', 'invalid sub-expression')
                            foundLookaround = true
                            break
                        }

                        foundLookaround = true
                        break
                    }
                }

                if (!foundLookaround) {
                    NAVLogTestFailed(x, 'expected type found', 'no expected type defined')
                    continue
                }
            }

            // Combined lookaround tests
            active (testType == LOOKAROUND_TEST_COMBINED): {
                stack_var integer i
                stack_var integer expectedCount
                stack_var integer actualCount
                stack_var char foundConfig

                foundConfig = false

                // Find expected configuration for this test
                for (i = 1; i <= length_array(REGEX_PARSER_LOOKAROUND_COMBINED); i++) {
                    if (REGEX_PARSER_LOOKAROUND_COMBINED[i][1] == x) {
                        stack_var integer j
                        stack_var char allFound

                        expectedCount = REGEX_PARSER_LOOKAROUND_COMBINED[i][2]
                        allFound = true

                        // Check each expected lookaround type
                        for (j = 1; j <= expectedCount; j++) {
                            stack_var integer expectedType
                            stack_var integer stateId

                            expectedType = REGEX_PARSER_LOOKAROUND_COMBINED[i][2 + j]

                            if (!FindLookaroundState(nfa, expectedType, stateId)) {
                                NAVLogTestFailed(x, "'lookaround type ', itoa(expectedType)", 'not found')
                                allFound = false
                                break
                            }

                            if (!ValidateLookaroundSubExpression(nfa, stateId)) {
                                NAVLogTestFailed(x, 'valid sub-expression', "'invalid for type ', itoa(expectedType)")
                                allFound = false
                                break
                            }
                        }

                        if (!allFound) {
                            foundConfig = true
                            break
                        }

                        foundConfig = true
                        break
                    }
                }

                if (!foundConfig) {
                    NAVLogTestFailed(x, 'expected configuration found', 'no configuration defined')
                    continue
                }
            }

            // Nested lookaround tests
            active (testType == LOOKAROUND_TEST_NESTED): {
                stack_var integer lookaheadCount
                stack_var integer lookbehindCount

                // Just verify we can parse nested lookarounds
                // Detailed validation would require traversing the sub-expression NFA
                lookaheadCount = CountLookaroundStates(nfa, NFA_STATE_LOOKAHEAD_POS) +
                                 CountLookaroundStates(nfa, NFA_STATE_LOOKAHEAD_NEG)
                lookbehindCount = CountLookaroundStates(nfa, NFA_STATE_LOOKBEHIND_POS) +
                                  CountLookaroundStates(nfa, NFA_STATE_LOOKBEHIND_NEG)

                if (lookaheadCount == 0 && lookbehindCount == 0) {
                    NAVLogTestFailed(x, 'lookaround states', 'no lookaround states found')
                    continue
                }
            }

            // Lookarounds with capturing groups
            active (testType == LOOKAROUND_TEST_WITH_GROUPS): {
                // Just verify the pattern parses successfully
                // The presence of lookaround and capture states means it worked
                foundLookaround = false

                if (CountLookaroundStates(nfa, NFA_STATE_LOOKAHEAD_POS) > 0 ||
                    CountLookaroundStates(nfa, NFA_STATE_LOOKAHEAD_NEG) > 0 ||
                    CountLookaroundStates(nfa, NFA_STATE_LOOKBEHIND_POS) > 0 ||
                    CountLookaroundStates(nfa, NFA_STATE_LOOKBEHIND_NEG) > 0) {
                    foundLookaround = true
                }

                if (!foundLookaround) {
                    NAVLogTestFailed(x, 'lookaround state', 'no lookaround state found')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    // Test error cases
    NAVLog("'***************** NAVRegexParser - Lookaround Errors *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_LOOKAROUND_ERROR_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa

        // Tokenize - may fail for some patterns
        if (!NAVRegexLexerTokenize(REGEX_PARSER_LOOKAROUND_ERROR_PATTERN[x], lexer)) {
            // Lexer correctly rejected the pattern
            NAVLogTestPassed(x)
            continue
        }

        // Parse - should fail
        if (!NAVAssertFalse('Should fail to parse invalid lookaround', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse failure', 'parse succeeded (should have failed)')
            continue
        }

        NAVLogTestPassed(x)
    }
}
