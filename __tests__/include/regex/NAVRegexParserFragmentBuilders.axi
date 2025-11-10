PROGRAM_NAME='NAVRegexParserFragmentBuilders'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Fragment builder test types
constant integer FRAGMENT_TEST_LITERAL      = 1
constant integer FRAGMENT_TEST_DOT          = 2
constant integer FRAGMENT_TEST_PREDEFINED   = 3
constant integer FRAGMENT_TEST_ANCHOR       = 4
constant integer FRAGMENT_TEST_INVALID_PRE  = 5
constant integer FRAGMENT_TEST_INVALID_ANC  = 6
constant integer FRAGMENT_TEST_CAPACITY     = 7

// Test configuration: type, token type (for predefined/anchor), expected state type, should succeed
constant integer FRAGMENT_TEST_TYPE[] = {
    FRAGMENT_TEST_LITERAL,      // 1: BuildLiteral 'a'
    FRAGMENT_TEST_DOT,          // 2: BuildDot
    FRAGMENT_TEST_PREDEFINED,   // 3: BuildPredefinedClass \d
    FRAGMENT_TEST_PREDEFINED,   // 4: BuildPredefinedClass \w
    FRAGMENT_TEST_PREDEFINED,   // 5: BuildPredefinedClass \s
    FRAGMENT_TEST_PREDEFINED,   // 6: BuildPredefinedClass \D
    FRAGMENT_TEST_INVALID_PRE,  // 7: Invalid predefined token
    FRAGMENT_TEST_ANCHOR,       // 8: BuildAnchor ^
    FRAGMENT_TEST_ANCHOR,       // 9: BuildAnchor $
    FRAGMENT_TEST_ANCHOR,       // 10: BuildAnchor \b
    FRAGMENT_TEST_ANCHOR,       // 11: BuildAnchor \A
    FRAGMENT_TEST_INVALID_ANC,  // 12: Invalid anchor token
    FRAGMENT_TEST_CAPACITY      // 13: Test at capacity
}

constant integer FRAGMENT_TEST_TOKEN_TYPE[] = {
    0,                          // 1: Literal (unused)
    0,                          // 2: Dot (unused)
    REGEX_TOKEN_DIGIT,          // 3: \d
    REGEX_TOKEN_ALPHA,          // 4: \w
    REGEX_TOKEN_WHITESPACE,     // 5: \s
    REGEX_TOKEN_NOT_DIGIT,      // 6: \D
    REGEX_TOKEN_CHAR,           // 7: Invalid (not a predefined class)
    REGEX_TOKEN_BEGIN,          // 8: ^
    REGEX_TOKEN_END,            // 9: $
    REGEX_TOKEN_WORD_BOUNDARY,  // 10: \b
    REGEX_TOKEN_STRING_START,   // 11: \A
    REGEX_TOKEN_CHAR,           // 12: Invalid (not an anchor)
    0                           // 13: Capacity (unused)
}

constant integer FRAGMENT_TEST_EXPECTED_STATE[] = {
    NFA_STATE_LITERAL,          // 1: Literal
    NFA_STATE_DOT,              // 2: Dot
    NFA_STATE_DIGIT,            // 3: \d
    NFA_STATE_WORD,             // 4: \w
    NFA_STATE_WHITESPACE,       // 5: \s
    NFA_STATE_NOT_DIGIT,        // 6: \D
    0,                          // 7: Invalid (no state created)
    NFA_STATE_BEGIN,            // 8: ^
    NFA_STATE_END,              // 9: $
    NFA_STATE_WORD_BOUNDARY,    // 10: \b
    NFA_STATE_STRING_START,     // 11: \A
    0,                          // 12: Invalid (no state created)
    0                           // 13: Capacity (no state created)
}

constant char FRAGMENT_TEST_SHOULD_SUCCEED[] = {
    true,   // 1: Literal should succeed
    true,   // 2: Dot should succeed
    true,   // 3: \d should succeed
    true,   // 4: \w should succeed
    true,   // 5: \s should succeed
    true,   // 6: \D should succeed
    false,  // 7: Invalid predefined should fail
    true,   // 8: ^ should succeed
    true,   // 9: $ should succeed
    true,   // 10: \b should succeed
    true,   // 11: \A should succeed
    false,  // 12: Invalid anchor should fail
    false   // 13: At capacity should fail
}


/**
 * @function TestNAVRegexParserFragmentBuilders
 * @public
 * @description Tests fragment builder functions.
 *
 * Validates:
 * - NAVRegexParserBuildLiteral() creates literal character fragments
 * - NAVRegexParserBuildDot() creates dot wildcard fragments
 * - NAVRegexParserBuildPredefinedClass() creates predefined class fragments
 * - NAVRegexParserBuildAnchor() creates anchor fragments
 * - Fragment structure (startState, outStates, outCount)
 * - State type correctness
 * - Invalid token rejection
 * - Capacity checking
 */
define_function TestNAVRegexParserFragmentBuilders() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Fragment Builders *****************'")

    for (x = 1; x <= length_array(FRAGMENT_TEST_TYPE); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment
        stack_var char result
        stack_var integer testType
        stack_var integer tokenType
        stack_var integer expectedState
        stack_var char shouldSucceed

        testType = FRAGMENT_TEST_TYPE[x]
        tokenType = FRAGMENT_TEST_TOKEN_TYPE[x]
        expectedState = FRAGMENT_TEST_EXPECTED_STATE[x]
        shouldSucceed = FRAGMENT_TEST_SHOULD_SUCCEED[x]

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
            case FRAGMENT_TEST_LITERAL: {
                result = NAVRegexParserBuildLiteral(parser, 'a', fragment)
            }
            case FRAGMENT_TEST_DOT: {
                result = NAVRegexParserBuildDot(parser, fragment)
            }
            case FRAGMENT_TEST_PREDEFINED:
            case FRAGMENT_TEST_INVALID_PRE: {
                result = NAVRegexParserBuildPredefinedClass(parser, tokenType, fragment)
            }
            case FRAGMENT_TEST_ANCHOR:
            case FRAGMENT_TEST_INVALID_ANC: {
                result = NAVRegexParserBuildAnchor(parser, tokenType, fragment)
            }
            case FRAGMENT_TEST_CAPACITY: {
                parser.stateCount = MAX_REGEX_NFA_STATES
                result = NAVRegexParserBuildLiteral(parser, 'x', fragment)
            }
        }

        // Verify result matches expectation
        if (shouldSucceed) {
            if (!NAVAssertTrue('Should succeed', result)) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }

            // For successful tests, verify state type
            if (testType != FRAGMENT_TEST_CAPACITY) {
                if (!NAVAssertIntegerEqual('State type should match', expectedState, parser.states[fragment.startState].type)) {
                    NAVLogTestFailed(x, itoa(expectedState), itoa(parser.states[fragment.startState].type))
                    continue
                }

                // Verify fragment has out states
                if (!NAVAssertTrue('Should have out states', fragment.outCount > 0)) {
                    NAVLogTestFailed(x, '>0', itoa(fragment.outCount))
                    continue
                }
            }
        }
        else {
            if (!NAVAssertFalse('Should fail', result)) {
                NAVLogTestFailed(x, 'false', 'true')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
