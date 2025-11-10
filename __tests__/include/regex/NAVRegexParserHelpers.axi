PROGRAM_NAME='NAVRegexParserHelpers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test types for state management tests
constant integer STATE_TEST_INIT                = 1
constant integer STATE_TEST_CREATE_MULTIPLE     = 2
constant integer STATE_TEST_CAN_ADD             = 3
constant integer STATE_TEST_NEAR_CAPACITY       = 4
constant integer STATE_TEST_AT_CAPACITY         = 5
constant integer STATE_TEST_OVER_CAPACITY       = 6
constant integer STATE_TEST_FIELD_INIT          = 7

// State management test configuration
constant integer STATE_TEST_TYPE[] = {
    STATE_TEST_INIT,
    STATE_TEST_CREATE_MULTIPLE,
    STATE_TEST_CAN_ADD,
    STATE_TEST_NEAR_CAPACITY,
    STATE_TEST_AT_CAPACITY,
    STATE_TEST_OVER_CAPACITY,
    STATE_TEST_FIELD_INIT
}

// Test types for transition management tests
constant integer TRANS_TEST_BASIC               = 1
constant integer TRANS_TEST_EPSILON             = 2
constant integer TRANS_TEST_CAN_ADD             = 3
constant integer TRANS_TEST_AT_CAPACITY         = 4
constant integer TRANS_TEST_OVER_CAPACITY       = 5
constant integer TRANS_TEST_INVALID_STATE       = 6

// Transition management test configuration
constant integer TRANS_TEST_TYPE[] = {
    TRANS_TEST_BASIC,
    TRANS_TEST_EPSILON,
    TRANS_TEST_CAN_ADD,
    TRANS_TEST_AT_CAPACITY,
    TRANS_TEST_OVER_CAPACITY,
    TRANS_TEST_INVALID_STATE
}

// Test types for fragment patching tests
constant integer PATCH_TEST_SINGLE_OUT          = 1
constant integer PATCH_TEST_MULTIPLE_OUTS       = 2
constant integer PATCH_TEST_INVALID             = 3

// Fragment patching test configuration
constant integer PATCH_TEST_TYPE[] = {
    PATCH_TEST_SINGLE_OUT,
    PATCH_TEST_MULTIPLE_OUTS,
    PATCH_TEST_INVALID
}


/**
 * @function TestNAVRegexParserStateManagement
 * @public
 * @description Tests parser state creation and management helpers.
 *
 * Validates:
 * - NAVRegexParserCanAddState() capacity checking
 * - NAVRegexParserAddState() state creation
 * - NAVRegexParserCreateState() wrapper delegation
 * - State bounds checking and validation
 * - Proper state field initialization
 */
define_function TestNAVRegexParserStateManagement() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - State Management *****************'")

    for (x = 1; x <= length_array(STATE_TEST_TYPE); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var integer i
        stack_var integer testType

        testType = STATE_TEST_TYPE[x]

        // Initialize parser for all tests
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        switch (testType) {
            case STATE_TEST_INIT: {
                // Test 1: Initialize parser and verify start state
                if (!NAVAssertIntegerEqual('Should have 1 state after init', 1, parser.stateCount)) {
                    NAVLogTestFailed(x, '1', itoa(parser.stateCount))
                    continue
                }
            }
            case STATE_TEST_CREATE_MULTIPLE: {
                // Test 2: Create additional states
                for (i = 1; i <= 10; i++) {
                    if (!NAVRegexParserCreateState(parser, NFA_STATE_LITERAL)) {
                        NAVLogTestFailed(x, 'true', 'false')
                        continue
                    }
                }

                if (!NAVAssertIntegerEqual('Should have 11 states', 11, parser.stateCount)) {
                    NAVLogTestFailed(x, '11', itoa(parser.stateCount))
                    continue
                }
            }
            case STATE_TEST_CAN_ADD: {
                // Test 3: Verify CanAddState capacity checking
                if (!NAVAssertTrue('Should be able to add more states', NAVRegexParserCanAddState(parser))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case STATE_TEST_NEAR_CAPACITY: {
                // Test 4: Create states up to near capacity
                stack_var integer statesToCreate
                statesToCreate = MAX_REGEX_NFA_STATES - parser.stateCount - 1

                for (i = 1; i <= statesToCreate; i++) {
                    if (!NAVRegexParserCreateState(parser, NFA_STATE_EPSILON)) {
                        NAVLogTestFailed(x, 'true', 'false')
                        continue
                    }
                }

                if (!NAVAssertIntegerEqual('Should be at capacity minus 1', MAX_REGEX_NFA_STATES - 1, parser.stateCount)) {
                    NAVLogTestFailed(x, itoa(MAX_REGEX_NFA_STATES - 1), itoa(parser.stateCount))
                    continue
                }
            }
            case STATE_TEST_AT_CAPACITY: {
                // Test 5: Fill to capacity minus 1, verify can add, then add final state
                stack_var integer statesToCreate2
                statesToCreate2 = MAX_REGEX_NFA_STATES - parser.stateCount - 1

                for (i = 1; i <= statesToCreate2; i++) {
                    if (!NAVRegexParserCreateState(parser, NFA_STATE_EPSILON)) {
                        NAVLogTestFailed(x, 'true', 'false')
                        continue
                    }
                }

                // Verify can still add one more
                if (!NAVAssertTrue('Should still be able to add one more', NAVRegexParserCanAddState(parser))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // Add final state
                if (!NAVRegexParserCreateState(parser, NFA_STATE_MATCH)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVAssertIntegerEqual('Should be at max capacity', MAX_REGEX_NFA_STATES, parser.stateCount)) {
                    NAVLogTestFailed(x, itoa(MAX_REGEX_NFA_STATES), itoa(parser.stateCount))
                    continue
                }
            }
            case STATE_TEST_OVER_CAPACITY: {
                // Test 6: Fill to capacity then try to add more
                stack_var integer statesToCreate3
                statesToCreate3 = MAX_REGEX_NFA_STATES - parser.stateCount

                for (i = 1; i <= statesToCreate3; i++) {
                    if (!NAVRegexParserCreateState(parser, NFA_STATE_EPSILON)) {
                        NAVLogTestFailed(x, 'true', 'false')
                        continue
                    }
                }

                // Verify cannot add more
                if (!NAVAssertFalse('Should not be able to add more', NAVRegexParserCanAddState(parser))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }

                if (!NAVAssertFalse('Create should fail at capacity', type_cast(NAVRegexParserCreateState(parser, NFA_STATE_LITERAL)))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }
            }
            case STATE_TEST_FIELD_INIT: {
                // Test 7: Verify state field initialization
                stack_var _NAVRegexLexer lexer2
                stack_var _NAVRegexParserState parser2

                if (!NAVRegexLexerTokenize('/a/', lexer2)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVRegexParserInit(parser2, lexer2.tokens)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVRegexParserCreateState(parser2, NFA_STATE_CHAR_CLASS)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // Verify the newly created state has correct initialization
                if (!NAVAssertIntegerEqual('State type should match', NFA_STATE_CHAR_CLASS, parser2.states[2].type)) {
                    NAVLogTestFailed(x, itoa(NFA_STATE_CHAR_CLASS), itoa(parser2.states[2].type))
                    continue
                }

                if (!NAVAssertIntegerEqual('Transition count should be 0', 0, parser2.states[2].transitionCount)) {
                    NAVLogTestFailed(x, '0', itoa(parser2.states[2].transitionCount))
                    continue
                }

                if (!NAVAssertIntegerEqual('Match char should be 0', 0, parser2.states[2].matchChar)) {
                    NAVLogTestFailed(x, '0', itoa(parser2.states[2].matchChar))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserTransitionManagement
 * @public
 * @description Tests parser transition creation and management helpers.
 *
 * Validates:
 * - NAVRegexParserCanAddTransition() capacity checking
 * - NAVRegexParserAddTransition() transition creation
 * - Transition bounds checking and validation
 * - Invalid state ID handling
 * - Epsilon vs non-epsilon transition creation
 */
define_function TestNAVRegexParserTransitionManagement() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Transition Management *****************'")

    for (x = 1; x <= length_array(TRANS_TEST_TYPE); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var integer i
        stack_var integer testType

        testType = TRANS_TEST_TYPE[x]

        // Initialize parser for all tests
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Create some additional states for transition testing
        for (i = 1; i <= 5; i++) {
            if (!NAVRegexParserCreateState(parser, NFA_STATE_EPSILON)) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }
        }

        switch (testType) {
            case TRANS_TEST_BASIC: {
                // Test 1: Add a basic transition
                if (!NAVAssertTrue('Should add transition', NAVRegexParserAddTransition(parser, 1, 2, false))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVAssertIntegerEqual('State 1 should have 1 transition', 1, parser.states[1].transitionCount)) {
                    NAVLogTestFailed(x, '1', itoa(parser.states[1].transitionCount))
                    continue
                }

                if (!NAVAssertIntegerEqual('Transition target should be 2', 2, parser.states[1].transitions[1].targetState)) {
                    NAVLogTestFailed(x, '2', itoa(parser.states[1].transitions[1].targetState))
                    continue
                }

                if (!NAVAssertFalse('Should not be epsilon', parser.states[1].transitions[1].isEpsilon)) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }
            }
            case TRANS_TEST_EPSILON: {
                // Test 2: Add epsilon transition (need basic one first)
                NAVRegexParserAddTransition(parser, 1, 2, false)

                if (!NAVAssertTrue('Should add epsilon transition', NAVRegexParserAddTransition(parser, 1, 3, true))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVAssertIntegerEqual('State 1 should have 2 transitions', 2, parser.states[1].transitionCount)) {
                    NAVLogTestFailed(x, '2', itoa(parser.states[1].transitionCount))
                    continue
                }

                if (!NAVAssertTrue('Should be epsilon', parser.states[1].transitions[2].isEpsilon)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case TRANS_TEST_CAN_ADD: {
                // Test 3: Verify CanAddTransition capacity checking
                if (!NAVAssertTrue('Should be able to add more transitions', NAVRegexParserCanAddTransition(parser, 1))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case TRANS_TEST_AT_CAPACITY: {
                // Test 4: Add transitions up to capacity
                for (i = 1; i <= MAX_REGEX_STATE_TRANSITIONS; i++) {
                    if (!NAVRegexParserAddTransition(parser, 1, 4, false)) {
                        NAVLogTestFailed(x, 'true', 'false')
                        continue
                    }
                }

                if (!NAVAssertIntegerEqual('Should be at max transitions', MAX_REGEX_STATE_TRANSITIONS, parser.states[1].transitionCount)) {
                    NAVLogTestFailed(x, itoa(MAX_REGEX_STATE_TRANSITIONS), itoa(parser.states[1].transitionCount))
                    continue
                }
            }
            case TRANS_TEST_OVER_CAPACITY: {
                // Test 5: Fill to capacity then try to add more
                for (i = 1; i <= MAX_REGEX_STATE_TRANSITIONS; i++) {
                    NAVRegexParserAddTransition(parser, 1, 4, false)
                }

                // Verify cannot add more
                if (!NAVAssertFalse('Should not be able to add more', NAVRegexParserCanAddTransition(parser, 1))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }

                if (!NAVAssertFalse('Add should fail at capacity', NAVRegexParserAddTransition(parser, 1, 5, false))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }
            }
            case TRANS_TEST_INVALID_STATE: {
                // Test 6: Verify invalid state ID handling
                if (!NAVAssertFalse('Should fail with invalid from state', NAVRegexParserAddTransition(parser, 999, 2, false))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }

                if (!NAVAssertFalse('Should fail with invalid to state', NAVRegexParserAddTransition(parser, 2, 999, false))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserFragmentPatching
 * @public
 * @description Tests parser fragment patching functionality.
 *
 * Validates:
 * - NAVRegexParserPatchFragment() connects fragment to target state
 * - Multiple out states are handled correctly
 * - Epsilon transitions are created properly
 * - Invalid parameters are rejected
 */
define_function TestNAVRegexParserFragmentPatching() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Fragment Patching *****************'")

    for (x = 1; x <= length_array(PATCH_TEST_TYPE); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment
        stack_var integer i
        stack_var integer testType

        testType = PATCH_TEST_TYPE[x]

        // Initialize parser for all tests
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Create states for testing
        for (i = 1; i <= 5; i++) {
            if (!NAVRegexParserCreateState(parser, NFA_STATE_EPSILON)) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }
        }

        switch (testType) {
            case PATCH_TEST_SINGLE_OUT: {
                // Test 1: Patch fragment with single out state
                fragment.startState = 2
                fragment.outStates[1] = 2
                fragment.outCount = 1

                if (!NAVAssertTrue('Should patch fragment', NAVRegexParserPatchFragment(parser, fragment, 3))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVAssertIntegerEqual('State 2 should have transition', 1, parser.states[2].transitionCount)) {
                    NAVLogTestFailed(x, '1', itoa(parser.states[2].transitionCount))
                    continue
                }

                if (!NAVAssertIntegerEqual('Transition should target state 3', 3, parser.states[2].transitions[1].targetState)) {
                    NAVLogTestFailed(x, '3', itoa(parser.states[2].transitions[1].targetState))
                    continue
                }

                if (!NAVAssertTrue('Should be epsilon transition', parser.states[2].transitions[1].isEpsilon)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case PATCH_TEST_MULTIPLE_OUTS: {
                // Test 2: Patch fragment with multiple out states
                fragment.startState = 4
                fragment.outStates[1] = 4
                fragment.outStates[2] = 5
                fragment.outCount = 2

                if (!NAVAssertTrue('Should patch fragment with multiple outs', NAVRegexParserPatchFragment(parser, fragment, 6))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVAssertIntegerEqual('State 4 should have transition', 1, parser.states[4].transitionCount)) {
                    NAVLogTestFailed(x, '1', itoa(parser.states[4].transitionCount))
                    continue
                }

                if (!NAVAssertIntegerEqual('State 5 should have transition', 1, parser.states[5].transitionCount)) {
                    NAVLogTestFailed(x, '1', itoa(parser.states[5].transitionCount))
                    continue
                }
            }
            case PATCH_TEST_INVALID: {
                // Test 3: Verify invalid parameters are rejected
                fragment.outCount = 0

                if (!NAVAssertFalse('Should fail with no out states', NAVRegexParserPatchFragment(parser, fragment, 3))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }

                fragment.outCount = 1
                fragment.outStates[1] = 1

                if (!NAVAssertFalse('Should fail with invalid target', NAVRegexParserPatchFragment(parser, fragment, 999))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
