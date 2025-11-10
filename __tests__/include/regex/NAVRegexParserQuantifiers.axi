PROGRAM_NAME='NAVRegexParserQuantifiers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test types for simple quantifiers (?, *, +)
constant integer QUANT_TEST_LITERAL     = 1
constant integer QUANT_TEST_DOT         = 2
constant integer QUANT_TEST_LITERAL2    = 3
constant integer QUANT_TEST_INVALID     = 4

// Test data for ZeroOrOne, ZeroOrMore, OneOrMore
constant integer SIMPLE_QUANT_TEST_TYPE[] = {
    QUANT_TEST_LITERAL,     // 1: Apply to literal 'a'
    QUANT_TEST_DOT,         // 2: Apply to dot
    QUANT_TEST_LITERAL2,    // 3: Apply to another literal
    QUANT_TEST_INVALID      // 4: Invalid fragment
}

constant char SIMPLE_QUANT_TEST_CHAR[] = {
    'a',    // 1
    0,      // 2: Not used for dot
    'x',    // 3
    0       // 4: Not used for invalid
}

constant char SIMPLE_QUANT_SHOULD_SUCCEED[] = {
    true,   // 1
    true,   // 2
    true,   // 3
    false   // 4
}

// Bounded quantifier test configuration
constant integer BOUNDED_QUANT_MIN[] = {
    0,      // 1: {0,0}
    2,      // 2: {2,2}
    1,      // 3: {1,3}
    2,      // 4: {2,-1}
    0,      // 5: {0,3}
    0,      // 6: {0,-1}
    3,      // 7: {3,-1}
    5,      // 8: Invalid {5,2}
    1,      // 9: Invalid fragment
    1,      // 10: {1,-1}
    5,      // 11: {5,10}
    -5      // 12: Negative min
}

constant sinteger BOUNDED_QUANT_MAX[] = {
    0,      // 1: {0,0}
    2,      // 2: {2,2}
    3,      // 3: {1,3}
    -1,     // 4: {2,-1}
    3,      // 5: {0,3}
    -1,     // 6: {0,-1}
    -1,     // 7: {3,-1}
    2,      // 8: Invalid {5,2}
    3,      // 9: Invalid fragment
    -1,     // 10: {1,-1}
    10,     // 11: {5,10}
    3       // 12: Negative min
}

constant char BOUNDED_QUANT_TEST_CHAR[] = {
    'a',    // 1
    'b',    // 2
    'c',    // 3
    'd',    // 4
    'e',    // 5
    'f',    // 6
    'g',    // 7
    'h',    // 8
    0,      // 9: Invalid fragment
    'i',    // 10
    'j',    // 11
    'k'     // 12
}

constant char BOUNDED_QUANT_SHOULD_SUCCEED[] = {
    true,   // 1: {0,0}
    true,   // 2: {2,2}
    true,   // 3: {1,3}
    true,   // 4: {2,-1}
    true,   // 5: {0,3}
    true,   // 6: {0,-1}
    true,   // 7: {3,-1}
    false,  // 8: Invalid bounds
    false,  // 9: Invalid fragment
    true,   // 10: {1,-1}
    true,   // 11: {5,10}
    false   // 12: Negative min
}

constant integer BOUNDED_QUANT_EXPECTED_STATE[] = {
    NFA_STATE_EPSILON,  // 1: {0,0} returns epsilon
    0,                  // 2: {2,2} concatenation
    0,                  // 3: {1,3} mixed
    0,                  // 4: {2,-1} required + unbounded
    0,                  // 5: {0,3} optional copies
    NFA_STATE_SPLIT,    // 6: {0,-1} equivalent to *
    0,                  // 7: {3,-1} required + unbounded
    0,                  // 8: Invalid
    0,                  // 9: Invalid
    0,                  // 10: {1,-1} equivalent to +
    0,                  // 11: {5,10} large range
    0                   // 12: Invalid
}


/**
 * @function TestNAVRegexParserZeroOrOne
 * @public
 * @description Tests zero-or-one (?) quantifier fragment builder.
 *
 * Validates:
 * - NAVRegexParserBuildZeroOrOne() creates optional fragment
 * - SPLIT state branches to fragment or bypass
 * - Result fragment has correct start and out states
 * - Invalid fragments are rejected
 */
define_function TestNAVRegexParserZeroOrOne() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - ZeroOrOne *****************'")

    for (x = 1; x <= length_array(SIMPLE_QUANT_TEST_TYPE); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment
        stack_var _NAVRegexNFAFragment invalidFragment
        stack_var _NAVRegexNFAFragment result
        stack_var char testResult
        stack_var integer testType
        stack_var char testChar
        stack_var char shouldSucceed

        testType = SIMPLE_QUANT_TEST_TYPE[x]
        testChar = SIMPLE_QUANT_TEST_CHAR[x]
        shouldSucceed = SIMPLE_QUANT_SHOULD_SUCCEED[x]

        // Initialize parser
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Build fragment and apply quantifier
        switch (testType) {
            case QUANT_TEST_LITERAL:
            case QUANT_TEST_LITERAL2: {
                if (!NAVRegexParserBuildLiteral(parser, testChar, fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildZeroOrOne(parser, fragment, false, result)
            }
            case QUANT_TEST_DOT: {
                if (!NAVRegexParserBuildDot(parser, fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildZeroOrOne(parser, fragment, false, result)
            }
            case QUANT_TEST_INVALID: {
                invalidFragment.startState = 0
                invalidFragment.outCount = 0
                testResult = NAVRegexParserBuildZeroOrOne(parser, invalidFragment, false, result)
            }
        }

        // Verify result
        if (shouldSucceed) {
            if (!NAVAssertTrue('Should succeed', testResult)) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }

            // For successful tests, verify SPLIT state structure
            if (testType != QUANT_TEST_INVALID) {
                if (!NAVAssertIntegerEqual('Should have SPLIT state', NFA_STATE_SPLIT, parser.states[result.startState].type)) {
                    NAVLogTestFailed(x, itoa(NFA_STATE_SPLIT), itoa(parser.states[result.startState].type))
                    continue
                }

                if (x == 1) {
                    // First test: do detailed validation
                    if (!NAVAssertIntegerEqual('SPLIT should have 1 transition', 1, parser.states[result.startState].transitionCount)) {
                        NAVLogTestFailed(x, '1', itoa(parser.states[result.startState].transitionCount))
                        continue
                    }
                    if (!NAVAssertIntegerEqual('Should have 2 outs', 2, result.outCount)) {
                        NAVLogTestFailed(x, '2', itoa(result.outCount))
                        continue
                    }
                }
            }
        }
        else {
            if (!NAVAssertFalse('Should fail', testResult)) {
                NAVLogTestFailed(x, 'false', 'true')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserZeroOrMore
 * @public
 * @description Tests zero-or-more (\*\) quantifier fragment builder.
 *
 * Validates:
 * - NAVRegexParserBuildZeroOrMore() creates repeating fragment
 * - SPLIT state branches to fragment or bypass
 * - Fragment loops back to SPLIT
 * - Result fragment has correct structure
 */
define_function TestNAVRegexParserZeroOrMore() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - ZeroOrMore *****************'")

    for (x = 1; x <= length_array(SIMPLE_QUANT_TEST_TYPE); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment
        stack_var _NAVRegexNFAFragment invalidFragment
        stack_var _NAVRegexNFAFragment result
        stack_var char testResult
        stack_var integer testType
        stack_var char testChar
        stack_var char shouldSucceed

        testType = SIMPLE_QUANT_TEST_TYPE[x]
        testChar = SIMPLE_QUANT_TEST_CHAR[x]
        shouldSucceed = SIMPLE_QUANT_SHOULD_SUCCEED[x]

        // Initialize parser
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Build fragment and apply quantifier
        switch (testType) {
            case QUANT_TEST_LITERAL:
            case QUANT_TEST_LITERAL2: {
                if (!NAVRegexParserBuildLiteral(parser, testChar, fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildZeroOrMore(parser, fragment, false, result)
            }
            case QUANT_TEST_DOT: {
                if (!NAVRegexParserBuildDot(parser, fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildZeroOrMore(parser, fragment, false, result)
            }
            case QUANT_TEST_INVALID: {
                invalidFragment.startState = 0
                invalidFragment.outCount = 0
                testResult = NAVRegexParserBuildZeroOrMore(parser, invalidFragment, false, result)
            }
        }

        // Verify result
        if (shouldSucceed) {
            if (!NAVAssertTrue('Should succeed', testResult)) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }

            // For successful tests, verify SPLIT state
            if (testType != QUANT_TEST_INVALID) {
                if (!NAVAssertIntegerEqual('Should have SPLIT state', NFA_STATE_SPLIT, parser.states[result.startState].type)) {
                    NAVLogTestFailed(x, itoa(NFA_STATE_SPLIT), itoa(parser.states[result.startState].type))
                    continue
                }

                if (x == 1) {
                    // First test: do detailed validation
                    if (!NAVAssertIntegerEqual('Should have 1 out', 1, result.outCount)) {
                        NAVLogTestFailed(x, '1', itoa(result.outCount))
                        continue
                    }
                }
            }
        }
        else {
            if (!NAVAssertFalse('Should fail', testResult)) {
                NAVLogTestFailed(x, 'false', 'true')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserOneOrMore
 * @public
 * @description Tests one-or-more (+) quantifier fragment builder.
 *
 * Validates:
 * - NAVRegexParserBuildOneOrMore() requires at least one match
 * - Fragment followed by SPLIT that loops back
 * - Result fragment has correct structure
 * - Invalid fragments are rejected
 */
define_function TestNAVRegexParserOneOrMore() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - OneOrMore *****************'")

    for (x = 1; x <= length_array(SIMPLE_QUANT_TEST_TYPE); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment
        stack_var _NAVRegexNFAFragment invalidFragment
        stack_var _NAVRegexNFAFragment result
        stack_var char testResult
        stack_var integer testType
        stack_var char testChar
        stack_var char shouldSucceed

        testType = SIMPLE_QUANT_TEST_TYPE[x]
        testChar = SIMPLE_QUANT_TEST_CHAR[x]
        shouldSucceed = SIMPLE_QUANT_SHOULD_SUCCEED[x]

        // Initialize parser
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Build fragment and apply quantifier
        switch (testType) {
            case QUANT_TEST_LITERAL:
            case QUANT_TEST_LITERAL2: {
                if (!NAVRegexParserBuildLiteral(parser, testChar, fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildOneOrMore(parser, fragment, false, result)
            }
            case QUANT_TEST_DOT: {
                if (!NAVRegexParserBuildDot(parser, fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildOneOrMore(parser, fragment, false, result)
            }
            case QUANT_TEST_INVALID: {
                invalidFragment.startState = 0
                invalidFragment.outCount = 0
                testResult = NAVRegexParserBuildOneOrMore(parser, invalidFragment, false, result)
            }
        }

        // Verify result
        if (shouldSucceed) {
            if (!NAVAssertTrue('Should succeed', testResult)) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }

            // For successful tests, verify result starts with fragment (required first match)
            if (testType != QUANT_TEST_INVALID) {
                if (!NAVAssertIntegerEqual('Result start should be fragment start', fragment.startState, result.startState)) {
                    NAVLogTestFailed(x, itoa(fragment.startState), itoa(result.startState))
                    continue
                }

                if (x == 1) {
                    // First test: do detailed validation
                    if (!NAVAssertIntegerEqual('Should have 1 out', 1, result.outCount)) {
                        NAVLogTestFailed(x, '1', itoa(result.outCount))
                        continue
                    }
                }
            }
        }
        else {
            if (!NAVAssertFalse('Should fail', testResult)) {
                NAVLogTestFailed(x, 'false', 'true')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserBoundedQuantifier
 * @public
 * @description Tests bounded quantifier {n,m} fragment builder.
 *
 * Validates:
 * - NAVRegexParserBuildBoundedQuantifier() handles various ranges
 * - Special case {0,0} returns epsilon
 * - Special case {n,n} creates exactly n copies
 * - Special case {n,-1} creates n copies + unbounded
 * - Range {m,n} creates m required + (n-m) optional
 * - Invalid bounds are rejected
 */
define_function TestNAVRegexParserBoundedQuantifier() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - BoundedQuantifier *****************'")

    for (x = 1; x <= length_array(BOUNDED_QUANT_MIN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment
        stack_var _NAVRegexNFAFragment invalidFragment
        stack_var _NAVRegexNFAFragment result
        stack_var char testResult
        stack_var integer testMin
        stack_var sinteger testMax
        stack_var char testChar
        stack_var char shouldSucceed
        stack_var integer expectedState

        testMin = type_cast(BOUNDED_QUANT_MIN[x])
        testMax = BOUNDED_QUANT_MAX[x]
        testChar = BOUNDED_QUANT_TEST_CHAR[x]
        shouldSucceed = BOUNDED_QUANT_SHOULD_SUCCEED[x]
        expectedState = BOUNDED_QUANT_EXPECTED_STATE[x]

        // Initialize parser
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Build fragment or use invalid
        if (x == 9) {
            // Invalid fragment test
            invalidFragment.startState = 0
            invalidFragment.outCount = 0
            testResult = NAVRegexParserBuildBoundedQuantifier(parser, invalidFragment, testMin, testMax, false, result)
        }
        else {
            // Normal test with literal fragment
            if (!NAVRegexParserBuildLiteral(parser, testChar, fragment)) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }
            testResult = NAVRegexParserBuildBoundedQuantifier(parser, fragment, testMin, testMax, false, result)
        }

        // Verify result
        if (shouldSucceed) {
            if (!NAVAssertTrue('Should succeed', testResult)) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }

            // Verify special states if expected
            if (expectedState != 0) {
                if (!NAVAssertIntegerEqual('State type should match', expectedState, parser.states[result.startState].type)) {
                    NAVLogTestFailed(x, itoa(expectedState), itoa(parser.states[result.startState].type))
                    continue
                }
            }

            // Verify has out states
            if (!NAVAssertTrue('Should have outs', result.outCount > 0)) {
                NAVLogTestFailed(x, '>0', itoa(result.outCount))
                continue
            }
        }
        else {
            if (!NAVAssertFalse('Should fail', testResult)) {
                NAVLogTestFailed(x, 'false', 'true')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
