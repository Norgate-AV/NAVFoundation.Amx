PROGRAM_NAME='NAVRegexParserLookaround'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test types
constant integer LOOKAROUND_TEST_TYPE_LOOKAHEAD_POS = 1
constant integer LOOKAROUND_TEST_TYPE_LOOKAHEAD_NEG = 2
constant integer LOOKAROUND_TEST_TYPE_LOOKBEHIND_POS = 3
constant integer LOOKAROUND_TEST_TYPE_LOOKBEHIND_NEG = 4

// Test data
constant char LOOKAROUND_TEST_PATTERN[][255] = {
    '/a(?=b)/',             // 1: Positive lookahead
    '/a(?=bc)/',            // 2: Positive lookahead with sequence
    '/a(?!\d)/',            // 3: Negative lookahead
    '/a(?!bc)/',            // 4: Negative lookahead with sequence
    '/(?<=a)b/',            // 5: Positive lookbehind
    '/(?<=ab)c/',           // 6: Positive lookbehind with sequence
    '/(?<!a)b/',            // 7: Negative lookbehind
    '/(?<!ab)c/'            // 8: Negative lookbehind with sequence
}

constant integer LOOKAROUND_TEST_TYPE[] = {
    LOOKAROUND_TEST_TYPE_LOOKAHEAD_POS,    // 1
    LOOKAROUND_TEST_TYPE_LOOKAHEAD_POS,    // 2
    LOOKAROUND_TEST_TYPE_LOOKAHEAD_NEG,    // 3
    LOOKAROUND_TEST_TYPE_LOOKAHEAD_NEG,    // 4
    LOOKAROUND_TEST_TYPE_LOOKBEHIND_POS,   // 5
    LOOKAROUND_TEST_TYPE_LOOKBEHIND_POS,   // 6
    LOOKAROUND_TEST_TYPE_LOOKBEHIND_NEG,   // 7
    LOOKAROUND_TEST_TYPE_LOOKBEHIND_NEG    // 8
}


/**
 * @function TestNAVRegexParserLookaround
 * @public
 * @description Tests lookaround assertion parsing.
 *
 * Validates:
 * - Positive lookahead (?=...) creates correct state
 * - Negative lookahead (?!...) creates correct state
 * - Positive lookbehind (?<=...) creates correct state
 * - Negative lookbehind (?<!...) creates correct state
 * - Sub-expression reference is stored correctly
 * - Zero-width assertion behavior (single out state)
 */
define_function TestNAVRegexParserLookaround() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Lookaround Assertions *****************'")

    for (x = 1; x <= length_array(LOOKAROUND_TEST_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment subExpr
        stack_var _NAVRegexNFAFragment result
        stack_var integer expectedStateType
        stack_var integer lookaroundState
        stack_var integer y

        // Tokenize the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(LOOKAROUND_TEST_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Initialize parser
        if (!NAVAssertTrue('Should initialize parser', NAVRegexParserInit(parser, lexer.tokens))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Create a simple sub-expression fragment (literal 'a')
        if (!NAVRegexParserBuildLiteral(parser, 'a', subExpr)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Build the appropriate lookaround type
        select {
            active (LOOKAROUND_TEST_TYPE[x] == LOOKAROUND_TEST_TYPE_LOOKAHEAD_POS): {
                expectedStateType = NFA_STATE_LOOKAHEAD_POS
                if (!NAVAssertTrue('Should build positive lookahead', NAVRegexParserBuildLookahead(parser, subExpr, false, result))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            active (LOOKAROUND_TEST_TYPE[x] == LOOKAROUND_TEST_TYPE_LOOKAHEAD_NEG): {
                expectedStateType = NFA_STATE_LOOKAHEAD_NEG
                if (!NAVAssertTrue('Should build negative lookahead', NAVRegexParserBuildLookahead(parser, subExpr, true, result))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            active (LOOKAROUND_TEST_TYPE[x] == LOOKAROUND_TEST_TYPE_LOOKBEHIND_POS): {
                expectedStateType = NFA_STATE_LOOKBEHIND_POS
                if (!NAVAssertTrue('Should build positive lookbehind', NAVRegexParserBuildLookbehind(parser, subExpr, false, result))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            active (LOOKAROUND_TEST_TYPE[x] == LOOKAROUND_TEST_TYPE_LOOKBEHIND_NEG): {
                expectedStateType = NFA_STATE_LOOKBEHIND_NEG
                if (!NAVAssertTrue('Should build negative lookbehind', NAVRegexParserBuildLookbehind(parser, subExpr, true, result))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
        }

        // Verify result fragment
        if (!NAVAssertTrue('Result should have valid start state', result.startState > 0)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Lookaround assertions are zero-width, should have 1 out state
        if (!NAVAssertIntegerEqual('Should have 1 out state', 1, result.outCount)) {
            NAVLogTestFailed(x, '1', itoa(result.outCount))
            continue
        }

        // Find the lookaround state (should be the result start state)
        lookaroundState = result.startState

        // Verify state type
        if (!NAVAssertIntegerEqual('State type should match', expectedStateType, parser.states[lookaroundState].type)) {
            NAVLogTestFailed(x, itoa(expectedStateType), itoa(parser.states[lookaroundState].type))
            continue
        }

        // Verify sub-expression reference is stored (in groupNumber field)
        if (!NAVAssertIntegerEqual('Should store sub-expression start state', subExpr.startState, parser.states[lookaroundState].groupNumber)) {
            NAVLogTestFailed(x, itoa(subExpr.startState), itoa(parser.states[lookaroundState].groupNumber))
            continue
        }

        // Verify isNegated flag for negative lookarounds
        if (LOOKAROUND_TEST_TYPE[x] == LOOKAROUND_TEST_TYPE_LOOKAHEAD_NEG || LOOKAROUND_TEST_TYPE[x] == LOOKAROUND_TEST_TYPE_LOOKBEHIND_NEG) {
            if (!NAVAssertTrue('Should be marked as negated', parser.states[lookaroundState].isNegated)) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }
        }
        else {
            if (!NAVAssertFalse('Should not be marked as negated', parser.states[lookaroundState].isNegated)) {
                NAVLogTestFailed(x, 'false', 'true')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
