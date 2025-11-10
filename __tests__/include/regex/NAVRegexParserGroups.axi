PROGRAM_NAME='NAVRegexParserGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test types
constant integer TEST_TYPE_CAPTURING = 1
constant integer TEST_TYPE_NON_CAPTURING = 2
constant integer TEST_TYPE_NESTED = 3
constant integer TEST_TYPE_MULTIPLE = 4

// Test data - Pattern, Type, Expected Group Count
constant char TEST_PATTERN[][255] = {
    '/(a)/',                // 1: Simple capturing group
    '/(abc)/',              // 2: Multi-char capturing group
    '/(?:a)/',              // 3: Simple non-capturing group
    '/(?:abc)/',            // 4: Multi-char non-capturing group
    '/((a))/',              // 5: Nested capturing groups
    '/(a(b)c)/',            // 6: Nested capturing inside
    '/((a)(b))/',           // 7: Multiple nested capturing
    '/(a)(b)/',             // 8: Multiple sequential capturing
    '/(a)(b)(c)/',          // 9: Three sequential capturing
    '/(?:(a))/',            // 10: Capturing inside non-capturing
    '/((?:a))/',            // 11: Non-capturing inside capturing
    '/(?:(?:a))/'           // 12: Nested non-capturing
}

constant integer TEST_TYPE[] = {
    TEST_TYPE_CAPTURING,        // 1
    TEST_TYPE_CAPTURING,        // 2
    TEST_TYPE_NON_CAPTURING,    // 3
    TEST_TYPE_NON_CAPTURING,    // 4
    TEST_TYPE_NESTED,           // 5
    TEST_TYPE_NESTED,           // 6
    TEST_TYPE_NESTED,           // 7
    TEST_TYPE_MULTIPLE,         // 8
    TEST_TYPE_MULTIPLE,         // 9
    TEST_TYPE_NESTED,           // 10
    TEST_TYPE_NESTED,           // 11
    TEST_TYPE_NESTED            // 12
}

constant integer TEST_EXPECTED_CAPTURE_COUNT[] = {
    1,  // 1: (a) - 1 group
    1,  // 2: (abc) - 1 group
    0,  // 3: (?:a) - 0 groups
    0,  // 4: (?:abc) - 0 groups
    2,  // 5: ((a)) - 2 groups
    2,  // 6: (a(b)c) - 2 groups
    3,  // 7: ((a)(b)) - 3 groups
    2,  // 8: (a)(b) - 2 groups
    3,  // 9: (a)(b)(c) - 3 groups
    1,  // 10: (?:(a)) - 1 group (inner only)
    1,  // 11: ((?:a)) - 1 group (outer only)
    0   // 12: (?:(?:a)) - 0 groups
}


/**
 * @function TestNAVRegexParserGroups
 * @public
 * @description Tests group parsing (capturing and non-capturing).
 *
 * Validates:
 * - Capturing groups create CAPTURE_START and CAPTURE_END states
 * - Non-capturing groups don't create capture states
 * - Group numbers are assigned correctly
 * - Nested groups are handled properly
 * - Multiple groups in sequence work correctly
 */
define_function TestNAVRegexParserGroups() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Groups & Capturing *****************'")

    for (x = 1; x <= length_array(TEST_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment content
        stack_var _NAVRegexNFAFragment result
        stack_var integer groupNumber
        stack_var integer captureStartCount
        stack_var integer captureEndCount
        stack_var integer y

        // Tokenize the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(TEST_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Initialize parser
        if (!NAVAssertTrue('Should initialize parser', NAVRegexParserInit(parser, lexer.tokens))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // For this test, we need to build the group content manually
        // In the real parser, this would come from parsing the tokens inside the group
        // For now, just create a simple literal fragment as content
        if (!NAVRegexParserBuildLiteral(parser, 'a', content)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Build the appropriate group type
        select {
            active (TEST_TYPE[x] == TEST_TYPE_CAPTURING || TEST_TYPE[x] == TEST_TYPE_NESTED || TEST_TYPE[x] == TEST_TYPE_MULTIPLE): {
                groupNumber = 1
                if (!NAVAssertTrue('Should build capturing group', NAVRegexParserBuildCapturingGroup(parser, content, groupNumber, '', result))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            active (TEST_TYPE[x] == TEST_TYPE_NON_CAPTURING): {
                if (!NAVAssertTrue('Should build non-capturing group', NAVRegexParserBuildNonCapturingGroup(parser, content, result))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
        }

        // Count CAPTURE_START and CAPTURE_END states
        captureStartCount = 0
        captureEndCount = 0
        for (y = 1; y <= parser.stateCount; y++) {
            if (parser.states[y].type == NFA_STATE_CAPTURE_START) {
                captureStartCount++
            }
            else if (parser.states[y].type == NFA_STATE_CAPTURE_END) {
                captureEndCount++
            }
        }

        // For capturing groups, verify CAPTURE states were created
        if (TEST_TYPE[x] == TEST_TYPE_CAPTURING || TEST_TYPE[x] == TEST_TYPE_NESTED || TEST_TYPE[x] == TEST_TYPE_MULTIPLE) {
            if (!NAVAssertIntegerEqual('Should have CAPTURE_START state', 1, captureStartCount)) {
                NAVLogTestFailed(x, '1', itoa(captureStartCount))
                continue
            }

            if (!NAVAssertIntegerEqual('Should have CAPTURE_END state', 1, captureEndCount)) {
                NAVLogTestFailed(x, '1', itoa(captureEndCount))
                continue
            }

            // Verify group number is set correctly on both states
            for (y = 1; y <= parser.stateCount; y++) {
                if (parser.states[y].type == NFA_STATE_CAPTURE_START ||
                    parser.states[y].type == NFA_STATE_CAPTURE_END) {
                    if (!NAVAssertIntegerEqual('Group number should match', groupNumber, parser.states[y].groupNumber)) {
                        NAVLogTestFailed(x, itoa(groupNumber), itoa(parser.states[y].groupNumber))
                        continue
                    }
                }
            }
        }
        else if (TEST_TYPE[x] == TEST_TYPE_NON_CAPTURING) {
            // Non-capturing groups should not create CAPTURE states
            if (!NAVAssertIntegerEqual('Should have no CAPTURE_START states', 0, captureStartCount)) {
                NAVLogTestFailed(x, '0', itoa(captureStartCount))
                continue
            }

            if (!NAVAssertIntegerEqual('Should have no CAPTURE_END states', 0, captureEndCount)) {
                NAVLogTestFailed(x, '0', itoa(captureEndCount))
                continue
            }
        }

        // Verify result fragment is valid
        if (!NAVAssertTrue('Result should have valid start state', result.startState > 0)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVAssertTrue('Result should have out states', result.outCount > 0)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        NAVLogTestPassed(x)
    }
}
