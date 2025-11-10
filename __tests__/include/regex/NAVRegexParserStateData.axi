PROGRAM_NAME='NAVRegexParserStateData'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test type constants
constant integer STATE_DATA_TEST_LITERAL        = 1
constant integer STATE_DATA_TEST_DOT            = 2
constant integer STATE_DATA_TEST_DOT_DOTALL     = 3
constant integer STATE_DATA_TEST_CAPTURE        = 4
constant integer STATE_DATA_TEST_PREDEFINED     = 5
constant integer STATE_DATA_TEST_ANCHOR         = 6
constant integer STATE_DATA_TEST_FLAGS          = 7

// Test configurations
constant char REGEX_PARSER_STATE_DATA_PATTERN[][255] = {
    '/a/',              // 1: Literal 'a'
    '/z/',              // 2: Literal 'z'
    '/5/',              // 3: Literal digit
    '/./',              // 4: Dot (default, no DOTALL)
    '/./s',             // 5: Dot with DOTALL flag
    '/(a)/',            // 6: Capturing group #1
    '/(a)(b)/',         // 7: Multiple capturing groups (#1, #2)
    '/(a)(b)(c)/',      // 8: Three capturing groups
    '/\d/',             // 9: Predefined digit class
    '/\w/',             // 10: Predefined word class
    '/\s/',             // 11: Predefined whitespace class
    '/\D/',             // 12: Predefined NOT digit
    '/\W/',             // 13: Predefined NOT word
    '/\S/',             // 14: Predefined NOT whitespace
    '/^a/',             // 15: Begin anchor
    '/a$/',             // 16: End anchor
    '/\ba/',            // 17: Word boundary
    '/\Ba/',            // 18: NOT word boundary
    '/\Aa/',            // 19: String start
    '/a\Z/',            // 20: String end
    '/a/i',             // 21: Case insensitive flag
    '/a/m',             // 22: Multiline flag
    '/a/s',             // 23: Dotall flag
    '/a/im',            // 24: Multiple flags
    '/(?i)a/',          // 25: Inline case insensitive
    '/(?m)^a/'          // 26: Inline multiline with anchor
}

constant integer REGEX_PARSER_STATE_DATA_TEST_TYPE[] = {
    STATE_DATA_TEST_LITERAL,        // 1
    STATE_DATA_TEST_LITERAL,        // 2
    STATE_DATA_TEST_LITERAL,        // 3
    STATE_DATA_TEST_DOT,            // 4
    STATE_DATA_TEST_DOT_DOTALL,     // 5
    STATE_DATA_TEST_CAPTURE,        // 6
    STATE_DATA_TEST_CAPTURE,        // 7
    STATE_DATA_TEST_CAPTURE,        // 8
    STATE_DATA_TEST_PREDEFINED,     // 9
    STATE_DATA_TEST_PREDEFINED,     // 10
    STATE_DATA_TEST_PREDEFINED,     // 11
    STATE_DATA_TEST_PREDEFINED,     // 12
    STATE_DATA_TEST_PREDEFINED,     // 13
    STATE_DATA_TEST_PREDEFINED,     // 14
    STATE_DATA_TEST_ANCHOR,         // 15
    STATE_DATA_TEST_ANCHOR,         // 16
    STATE_DATA_TEST_ANCHOR,         // 17
    STATE_DATA_TEST_ANCHOR,         // 18
    STATE_DATA_TEST_ANCHOR,         // 19
    STATE_DATA_TEST_ANCHOR,         // 20
    STATE_DATA_TEST_FLAGS,          // 21
    STATE_DATA_TEST_FLAGS,          // 22
    STATE_DATA_TEST_FLAGS,          // 23
    STATE_DATA_TEST_FLAGS,          // 24
    STATE_DATA_TEST_FLAGS,          // 25
    STATE_DATA_TEST_FLAGS           // 26
}

constant char REGEX_PARSER_STATE_DATA_MATCH_CHAR[] = {
    'a',    // 1
    'z',    // 2
    '5',    // 3
    0,      // 4: N/A
    0,      // 5: N/A
    0,      // 6: N/A
    0,      // 7: N/A
    0,      // 8: N/A
    0,      // 9: N/A
    0,      // 10: N/A
    0,      // 11: N/A
    0,      // 12: N/A
    0,      // 13: N/A
    0,      // 14: N/A
    0,      // 15: N/A
    0,      // 16: N/A
    0,      // 17: N/A
    0,      // 18: N/A
    0,      // 19: N/A
    0,      // 20: N/A
    'a',    // 21: literal with flag
    'a',    // 22: literal with flag
    'a',    // 23: literal with flag
    'a',    // 24: literal with flag
    'a',    // 25: literal with flag
    0       // 26: anchor, not literal
}

constant char REGEX_PARSER_STATE_DATA_DOT_MATCHES_NEWLINE[] = {
    false,  // 1: N/A
    false,  // 2: N/A
    false,  // 3: N/A
    false,  // 4: Dot without DOTALL
    true,   // 5: Dot with DOTALL
    false,  // 6: N/A
    false,  // 7: N/A
    false,  // 8: N/A
    false,  // 9: N/A
    false,  // 10: N/A
    false,  // 11: N/A
    false,  // 12: N/A
    false,  // 13: N/A
    false,  // 14: N/A
    false,  // 15: N/A
    false,  // 16: N/A
    false,  // 17: N/A
    false,  // 18: N/A
    false,  // 19: N/A
    false,  // 20: N/A
    false,  // 21: N/A
    false,  // 22: N/A
    false,  // 23: N/A
    false,  // 24: N/A
    false,  // 25: N/A
    false   // 26: N/A
}

constant integer REGEX_PARSER_STATE_DATA_EXPECTED_STATE_TYPE[] = {
    NFA_STATE_LITERAL,          // 1
    NFA_STATE_LITERAL,          // 2
    NFA_STATE_LITERAL,          // 3
    NFA_STATE_DOT,              // 4
    NFA_STATE_DOT,              // 5
    NFA_STATE_CAPTURE_START,    // 6
    NFA_STATE_CAPTURE_START,    // 7
    NFA_STATE_CAPTURE_START,    // 8
    NFA_STATE_DIGIT,            // 9
    NFA_STATE_WORD,             // 10
    NFA_STATE_WHITESPACE,       // 11
    NFA_STATE_NOT_DIGIT,        // 12
    NFA_STATE_NOT_WORD,         // 13
    NFA_STATE_NOT_WHITESPACE,   // 14
    NFA_STATE_BEGIN,            // 15
    NFA_STATE_END,              // 16
    NFA_STATE_WORD_BOUNDARY,    // 17
    NFA_STATE_NOT_WORD_BOUNDARY,// 18
    NFA_STATE_STRING_START,     // 19
    NFA_STATE_STRING_END,       // 20
    NFA_STATE_LITERAL,          // 21
    NFA_STATE_LITERAL,          // 22
    NFA_STATE_LITERAL,          // 23
    NFA_STATE_LITERAL,          // 24
    NFA_STATE_LITERAL,          // 25
    NFA_STATE_BEGIN             // 26
}


/**
 * @function TestNAVRegexParserStateData
 * @public
 * @description Validates that NFA state data matches state type.
 *
 * This test ensures the parser correctly populates state-specific fields:
 * - LITERAL states: matchChar contains the literal character
 * - DOT states: matchesNewline reflects DOTALL flag
 * - CAPTURE_START/END states: groupNumber is valid (1-99)
 * - PREDEFINED states: correct type (DIGIT, WORD, etc.)
 * - ANCHOR states: correct type and positioning
 * - Flag states: stateFlags reflect active flags
 *
 * Why this matters:
 * - The matcher dispatches on state.type then reads type-specific fields
 * - Uninitialized or incorrect data = undefined matching behavior
 * - Example: Bug #7 where charClass.isNegated was set but state.isNegated wasn't
 *
 * This complements the CharClass test by covering all other state types.
 */
define_function TestNAVRegexParserStateData() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - State Data Validation *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_STATE_DATA_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer testType
        stack_var integer expectedStateType
        stack_var integer stateIdx
        stack_var char foundState
        stack_var integer targetStateId

        testType = REGEX_PARSER_STATE_DATA_TEST_TYPE[x]
        expectedStateType = REGEX_PARSER_STATE_DATA_EXPECTED_STATE_TYPE[x]

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_STATE_DATA_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Find the target state of the expected type
        foundState = false
        for (stateIdx = 1; stateIdx <= nfa.stateCount; stateIdx++) {
            if (nfa.states[stateIdx].type == expectedStateType) {
                targetStateId = stateIdx
                foundState = true
                break
            }
        }

        if (!NAVAssertTrue('Should find expected state type', foundState)) {
            NAVLogTestFailed(x, "'Found state type ', itoa(expectedStateType)", 'Not found')
            continue
        }

        // Validate state-specific data based on test type
        switch (testType) {
            case STATE_DATA_TEST_LITERAL: {
                // Verify matchChar is set correctly
                if (!NAVAssertCharEqual('Literal state should have correct matchChar',
                                       REGEX_PARSER_STATE_DATA_MATCH_CHAR[x],
                                       nfa.states[targetStateId].matchChar)) {
                    NAVLogTestFailed(x,
                        "'matchChar = ', REGEX_PARSER_STATE_DATA_MATCH_CHAR[x]",
                        "'matchChar = ', nfa.states[targetStateId].matchChar")
                    continue
                }

                // Verify matchChar is not zero (uninitialized)
                if (!NAVAssertTrue('Literal matchChar should not be zero',
                                  nfa.states[targetStateId].matchChar != 0)) {
                    NAVLogTestFailed(x, 'matchChar != 0', 'matchChar == 0')
                    continue
                }
            }

            case STATE_DATA_TEST_DOT: {
                // Verify matchesNewline is false (no DOTALL flag)
                if (!NAVAssertBooleanEqual('DOT without DOTALL should not match newlines',
                                          false,
                                          nfa.states[targetStateId].matchesNewline)) {
                    NAVLogTestFailed(x, 'matchesNewline = false', 'matchesNewline = true')
                    continue
                }
            }

            case STATE_DATA_TEST_DOT_DOTALL: {
                // Verify matchesNewline is true (DOTALL flag active)
                if (!NAVAssertBooleanEqual('DOT with DOTALL should match newlines',
                                          true,
                                          nfa.states[targetStateId].matchesNewline)) {
                    NAVLogTestFailed(x, 'matchesNewline = true', 'matchesNewline = false')
                    continue
                }
            }

            case STATE_DATA_TEST_CAPTURE: {
                // Verify groupNumber is valid (1-99)
                if (!NAVAssertTrue('Capture state should have valid group number',
                                  nfa.states[targetStateId].groupNumber >= 1 &&
                                  nfa.states[targetStateId].groupNumber <= MAX_REGEX_GROUPS)) {
                    NAVLogTestFailed(x,
                        "'groupNumber in range 1-', itoa(MAX_REGEX_GROUPS)",
                        "'groupNumber = ', itoa(nfa.states[targetStateId].groupNumber)")
                    continue
                }

                // For multi-group patterns, verify there are corresponding CAPTURE_END states
                if (testType == STATE_DATA_TEST_CAPTURE) {
                    stack_var integer captureEndCount
                    stack_var integer searchIdx
                    stack_var integer captureStartCount
                    captureEndCount = 0

                    for (searchIdx = 1; searchIdx <= nfa.stateCount; searchIdx++) {
                        if (nfa.states[searchIdx].type == NFA_STATE_CAPTURE_END) {
                            captureEndCount++
                        }
                    }

                    // Should have matching CAPTURE_END for each CAPTURE_START
                    captureStartCount = 0
                    for (searchIdx = 1; searchIdx <= nfa.stateCount; searchIdx++) {
                        if (nfa.states[searchIdx].type == NFA_STATE_CAPTURE_START) {
                            captureStartCount++
                        }
                    }

                    if (!NAVAssertIntegerEqual('CAPTURE_START count should match CAPTURE_END count',
                                              captureStartCount,
                                              captureEndCount)) {
                        NAVLogTestFailed(x,
                            "'START=', itoa(captureStartCount), ' END=', itoa(captureStartCount)",
                            "'START=', itoa(captureStartCount), ' END=', itoa(captureEndCount)")
                        continue
                    }
                }
            }

            case STATE_DATA_TEST_PREDEFINED:
            case STATE_DATA_TEST_ANCHOR: {
                // For predefined classes and anchors, just verify the type is correct
                // (already validated by finding the state)
                // No additional data fields to check
            }

            case STATE_DATA_TEST_FLAGS: {
                // For flag tests, verify the NFA flags are set correctly
                // Test 21: /a/i should have CASE_INSENSITIVE flag
                // Test 22: /a/m should have MULTILINE flag
                // Test 23: /a/s should have DOTALL flag
                // Test 24: /a/im should have both CASE_INSENSITIVE and MULTILINE

                if (x == 21 || x == 24 || x == 25) {
                    if (!NAVAssertTrue('Should have CASE_INSENSITIVE flag',
                                      (nfa.flags band PARSER_FLAG_CASE_INSENSITIVE) != 0)) {
                        NAVLogTestFailed(x, 'CASE_INSENSITIVE flag set', 'CASE_INSENSITIVE flag not set')
                        continue
                    }
                }

                if (x == 22 || x == 24 || x == 26) {
                    if (!NAVAssertTrue('Should have MULTILINE flag',
                                      (nfa.flags band PARSER_FLAG_MULTILINE) != 0)) {
                        NAVLogTestFailed(x, 'MULTILINE flag set', 'MULTILINE flag not set')
                        continue
                    }
                }

                if (x == 23) {
                    if (!NAVAssertTrue('Should have DOTALL flag',
                                      (nfa.flags band PARSER_FLAG_DOTALL) != 0)) {
                        NAVLogTestFailed(x, 'DOTALL flag set', 'DOTALL flag not set')
                        continue
                    }
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
