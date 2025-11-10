PROGRAM_NAME='NAVRegexParserConcatAlternation'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Concatenation test types
constant integer CONCAT_TEST_TWO_LITERALS   = 1
constant integer CONCAT_TEST_LITERAL_DOT    = 2
constant integer CONCAT_TEST_THREE_LITERALS = 3
constant integer CONCAT_TEST_INVALID        = 4

// Alternation test types
constant integer ALT_TEST_TWO_LITERALS      = 1
constant integer ALT_TEST_DIGIT_DOT         = 2
constant integer ALT_TEST_THREE_LITERALS    = 3
constant integer ALT_TEST_INVALID           = 4
constant integer ALT_TEST_OUT_LIMIT         = 5

constant integer CONCAT_TEST_TYPE[] = {
    CONCAT_TEST_TWO_LITERALS,   // 1: [a][b]
    CONCAT_TEST_LITERAL_DOT,    // 2: [a][.]
    CONCAT_TEST_THREE_LITERALS, // 3: [a][b][c]
    CONCAT_TEST_INVALID         // 4: Invalid fragments
}

constant char CONCAT_TEST_SHOULD_SUCCEED[] = {
    true,   // 1
    true,   // 2
    true,   // 3
    false   // 4
}

constant integer ALT_TEST_TYPE[] = {
    ALT_TEST_TWO_LITERALS,      // 1: a|b
    ALT_TEST_DIGIT_DOT,         // 2: \d|.
    ALT_TEST_THREE_LITERALS,    // 3: a|b|c
    ALT_TEST_INVALID,           // 4: Invalid fragments
    ALT_TEST_OUT_LIMIT          // 5: Out state limit
}

constant char ALT_TEST_SHOULD_SUCCEED[] = {
    true,   // 1
    true,   // 2
    true,   // 3
    false,  // 4
    false   // 5
}


/**
 * @function TestNAVRegexParserConcatenation
 * @public
 * @description Tests concatenation fragment builder.
 *
 * Validates:
 * - NAVRegexParserBuildConcatenation() connects two fragments in sequence
 * - Fragment1's out states are patched to fragment2's start
 * - Result fragment has correct start and out states
 * - Invalid fragments are rejected
 */
define_function TestNAVRegexParserConcatenation() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Concatenation *****************'")

    for (x = 1; x <= length_array(CONCAT_TEST_TYPE); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment1
        stack_var _NAVRegexNFAFragment fragment2
        stack_var _NAVRegexNFAFragment fragment3
        stack_var _NAVRegexNFAFragment temp
        stack_var _NAVRegexNFAFragment result
        stack_var _NAVRegexNFAFragment invalidFragment
        stack_var char testResult
        stack_var integer testType
        stack_var char shouldSucceed

        testType = CONCAT_TEST_TYPE[x]
        shouldSucceed = CONCAT_TEST_SHOULD_SUCCEED[x]

        // Initialize parser
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Execute test based on type
        switch (testType) {
            case CONCAT_TEST_TWO_LITERALS: {
                // Test: Concatenate [a][b]
                if (!NAVRegexParserBuildLiteral(parser, 'a', fragment1)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, 'b', fragment2)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildConcatenation(parser, fragment1, fragment2, result)

                if (testResult) {
                    // Verify structure
                    if (!NAVAssertIntegerEqual('Result start should be fragment1 start', fragment1.startState, result.startState)) {
                        NAVLogTestFailed(x, itoa(fragment1.startState), itoa(result.startState))
                        continue
                    }
                    if (!NAVAssertIntegerEqual('Result out should be fragment2 out', fragment2.outStates[1], result.outStates[1])) {
                        NAVLogTestFailed(x, itoa(fragment2.outStates[1]), itoa(result.outStates[1]))
                        continue
                    }
                    // Verify patching
                    if (!NAVAssertIntegerEqual('Transition should target fragment2', fragment2.startState, parser.states[fragment1.startState].transitions[1].targetState)) {
                        NAVLogTestFailed(x, itoa(fragment2.startState), itoa(parser.states[fragment1.startState].transitions[1].targetState))
                        continue
                    }
                }
            }
            case CONCAT_TEST_LITERAL_DOT: {
                // Test: Concatenate [a][.]
                if (!NAVRegexParserBuildLiteral(parser, 'x', fragment1)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildDot(parser, fragment2)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildConcatenation(parser, fragment1, fragment2, result)

                if (testResult) {
                    if (!NAVAssertIntegerEqual('Result start should be fragment1 start', fragment1.startState, result.startState)) {
                        NAVLogTestFailed(x, itoa(fragment1.startState), itoa(result.startState))
                        continue
                    }
                }
            }
            case CONCAT_TEST_THREE_LITERALS: {
                // Test: Concatenate [a][b][c]
                if (!NAVRegexParserBuildLiteral(parser, '1', fragment1)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, '2', fragment2)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, '3', fragment3)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildConcatenation(parser, fragment1, fragment2, temp)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildConcatenation(parser, temp, fragment3, result)

                if (testResult) {
                    if (!NAVAssertIntegerEqual('Result start should be fragment1', fragment1.startState, result.startState)) {
                        NAVLogTestFailed(x, itoa(fragment1.startState), itoa(result.startState))
                        continue
                    }
                    if (!NAVAssertIntegerEqual('Result out should be fragment3', fragment3.outStates[1], result.outStates[1])) {
                        NAVLogTestFailed(x, itoa(fragment3.outStates[1]), itoa(result.outStates[1]))
                        continue
                    }
                }
            }
            case CONCAT_TEST_INVALID: {
                // Test: Invalid fragments
                invalidFragment.startState = 0
                invalidFragment.outCount = 0

                if (!NAVRegexParserBuildLiteral(parser, 'y', fragment1)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // Try invalid as first fragment
                if (NAVRegexParserBuildConcatenation(parser, invalidFragment, fragment1, result)) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }

                // Try invalid as second fragment
                testResult = NAVRegexParserBuildConcatenation(parser, fragment1, invalidFragment, result)
            }
        }

        // Verify result matches expectation
        if (shouldSucceed) {
            if (!NAVAssertTrue('Should succeed', testResult)) {
                NAVLogTestFailed(x, 'true', 'false')
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


/**
 * @function TestNAVRegexParserAlternation
 * @public
 * @description Tests alternation fragment builder.
 *
 * Validates:
 * - NAVRegexParserBuildAlternation() creates SPLIT state
 * - SPLIT state has epsilon transitions to both alternatives
 * - Result combines out states from both fragments
 * - Invalid fragments are rejected
 * - Out state array limit is enforced
 */
define_function TestNAVRegexParserAlternation() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Alternation *****************'")

    for (x = 1; x <= length_array(ALT_TEST_TYPE); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment1
        stack_var _NAVRegexNFAFragment fragment2
        stack_var _NAVRegexNFAFragment fragment3
        stack_var _NAVRegexNFAFragment temp
        stack_var _NAVRegexNFAFragment result
        stack_var _NAVRegexNFAFragment invalidFragment
        stack_var _NAVRegexNFAFragment frag1
        stack_var _NAVRegexNFAFragment frag2
        stack_var char testResult
        stack_var integer testType
        stack_var char shouldSucceed

        testType = ALT_TEST_TYPE[x]
        shouldSucceed = ALT_TEST_SHOULD_SUCCEED[x]

        // Initialize parser
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Execute test based on type
        switch (testType) {
            case ALT_TEST_TWO_LITERALS: {
                // Test: Alternation [a|b]
                if (!NAVRegexParserBuildLiteral(parser, 'a', fragment1)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, 'b', fragment2)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildAlternation(parser, fragment1, fragment2, result)

                if (testResult) {
                    // Verify SPLIT state
                    if (!NAVAssertIntegerEqual('SPLIT state type', NFA_STATE_SPLIT, parser.states[result.startState].type)) {
                        NAVLogTestFailed(x, itoa(NFA_STATE_SPLIT), itoa(parser.states[result.startState].type))
                        continue
                    }
                    if (!NAVAssertIntegerEqual('SPLIT should have 2 transitions', 2, parser.states[result.startState].transitionCount)) {
                        NAVLogTestFailed(x, '2', itoa(parser.states[result.startState].transitionCount))
                        continue
                    }
                    if (!NAVAssertIntegerEqual('First transition target', fragment1.startState, parser.states[result.startState].transitions[1].targetState)) {
                        NAVLogTestFailed(x, itoa(fragment1.startState), itoa(parser.states[result.startState].transitions[1].targetState))
                        continue
                    }
                    if (!NAVAssertIntegerEqual('Second transition target', fragment2.startState, parser.states[result.startState].transitions[2].targetState)) {
                        NAVLogTestFailed(x, itoa(fragment2.startState), itoa(parser.states[result.startState].transitions[2].targetState))
                        continue
                    }
                    if (!NAVAssertIntegerEqual('Result should have 2 outs', 2, result.outCount)) {
                        NAVLogTestFailed(x, '2', itoa(result.outCount))
                        continue
                    }
                }
            }
            case ALT_TEST_DIGIT_DOT: {
                // Test: Alternation [\d|.]
                if (!NAVRegexParserBuildPredefinedClass(parser, REGEX_TOKEN_DIGIT, fragment1)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildDot(parser, fragment2)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildAlternation(parser, fragment1, fragment2, result)

                if (testResult) {
                    if (!NAVAssertIntegerEqual('SPLIT state type', NFA_STATE_SPLIT, parser.states[result.startState].type)) {
                        NAVLogTestFailed(x, itoa(NFA_STATE_SPLIT), itoa(parser.states[result.startState].type))
                        continue
                    }
                }
            }
            case ALT_TEST_THREE_LITERALS: {
                // Test: Nested alternation [a|b|c]
                if (!NAVRegexParserBuildLiteral(parser, 'x', fragment1)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, 'y', fragment2)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, 'z', fragment3)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildAlternation(parser, fragment1, fragment2, temp)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                testResult = NAVRegexParserBuildAlternation(parser, temp, fragment3, result)

                if (testResult) {
                    if (!NAVAssertIntegerEqual('Result should have 3 outs', 3, result.outCount)) {
                        NAVLogTestFailed(x, '3', itoa(result.outCount))
                        continue
                    }
                }
            }
            case ALT_TEST_INVALID: {
                // Test: Invalid fragments
                invalidFragment.startState = 0
                invalidFragment.outCount = 0

                if (!NAVRegexParserBuildLiteral(parser, 'm', fragment1)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // Try invalid as first fragment
                if (NAVRegexParserBuildAlternation(parser, invalidFragment, fragment1, result)) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }

                // Try invalid as second fragment
                testResult = NAVRegexParserBuildAlternation(parser, fragment1, invalidFragment, result)
            }
            case ALT_TEST_OUT_LIMIT: {
                // Test: Out state limit
                frag1.startState = 1
                frag1.outCount = 5
                set_length_array(frag1.outStates, 5)
                frag1.outStates[1] = 1
                frag1.outStates[2] = 1
                frag1.outStates[3] = 1
                frag1.outStates[4] = 1
                frag1.outStates[5] = 1

                frag2.startState = 2
                frag2.outCount = 4
                set_length_array(frag2.outStates, 4)
                frag2.outStates[1] = 2
                frag2.outStates[2] = 2
                frag2.outStates[3] = 2
                frag2.outStates[4] = 2

                testResult = NAVRegexParserBuildAlternation(parser, frag1, frag2, result)
            }
        }

        // Verify result matches expectation
        if (shouldSucceed) {
            if (!NAVAssertTrue('Should succeed', testResult)) {
                NAVLogTestFailed(x, 'true', 'false')
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
