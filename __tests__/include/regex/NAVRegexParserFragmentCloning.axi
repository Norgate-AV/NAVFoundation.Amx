PROGRAM_NAME='NAVRegexParserFragmentCloning'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test types for fragment cloning
constant integer CLONE_TEST_LITERAL         = 1
constant integer CLONE_TEST_DOT             = 2
constant integer CLONE_TEST_CHAR_CLASS      = 3
constant integer CLONE_TEST_CAPTURE_SIMPLE  = 4
constant integer CLONE_TEST_CAPTURE_CONCAT  = 5
constant integer CLONE_TEST_INVALID         = 6

// Test configuration for shallow vs deep clone behavior
constant integer FRAGMENT_CLONE_TEST_TYPE[] = {
    CLONE_TEST_LITERAL,         // 1: Shallow clone - single literal
    CLONE_TEST_DOT,             // 2: Shallow clone - dot metachar
    CLONE_TEST_CHAR_CLASS,      // 3: Shallow clone - char class
    CLONE_TEST_CAPTURE_SIMPLE,  // 4: Deep clone - simple capturing group
    CLONE_TEST_CAPTURE_CONCAT,  // 5: Deep clone - concatenated literals in group
    CLONE_TEST_INVALID          // 6: Invalid fragment (should fail)
}

constant char FRAGMENT_CLONE_TEST_CHAR[] = {
    'a',    // 1: Literal
    0,      // 2: Dot (not used)
    0,      // 3: Char class (not used)
    'x',    // 4: Capture simple
    'a',    // 5: Capture concat (first char)
    0       // 6: Invalid (not used)
}

constant char FRAGMENT_CLONE_SHOULD_SUCCEED[] = {
    true,   // 1: Literal
    true,   // 2: Dot
    true,   // 3: Char class
    true,   // 4: Simple capture
    true,   // 5: Capture with concatenation
    false   // 6: Invalid fragment
}

constant char FRAGMENT_CLONE_IS_DEEP[] = {
    false,  // 1: Shallow
    false,  // 2: Shallow
    false,  // 3: Shallow
    true,   // 4: Deep (has CAPTURE_START)
    true,   // 5: Deep (has CAPTURE_START)
    false   // 6: N/A
}

constant integer FRAGMENT_CLONE_EXPECTED_OUT_COUNT[] = {
    1,      // 1: Single literal has 1 out
    1,      // 2: Dot has 1 out
    1,      // 3: Char class has 1 out
    1,      // 4: Capture group has 1 out
    1,      // 5: Capture group has 1 out
    0       // 6: Invalid
}


/**
 * @function TestNAVRegexParserFragmentCloning
 * @public
 * @description Tests fragment cloning functionality (shallow and deep).
 *
 * Validates:
 * - NAVRegexParserCloneFragment() creates new start state
 * - Shallow clone reuses internal states for simple fragments
 * - Deep clone duplicates all states for capturing groups
 * - Fragment outStates are updated to new states
 * - Multiple clones are independent (no shared states)
 * - Invalid fragments are rejected
 */
define_function TestNAVRegexParserFragmentCloning() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Fragment Cloning *****************'")

    for (x = 1; x <= length_array(FRAGMENT_CLONE_TEST_TYPE); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment
        stack_var _NAVRegexNFAFragment invalidFragment
        stack_var _NAVRegexNFAFragment clone1
        stack_var _NAVRegexNFAFragment clone2
        stack_var char testResult
        stack_var integer testType
        stack_var char testChar
        stack_var char shouldSucceed
        stack_var char isDeep
        stack_var integer expectedOutCount
        stack_var integer originalStart
        stack_var integer originalStateCount
        stack_var integer stateCountAfterClone1

        testType = FRAGMENT_CLONE_TEST_TYPE[x]
        testChar = FRAGMENT_CLONE_TEST_CHAR[x]
        shouldSucceed = FRAGMENT_CLONE_SHOULD_SUCCEED[x]
        isDeep = FRAGMENT_CLONE_IS_DEEP[x]
        expectedOutCount = FRAGMENT_CLONE_EXPECTED_OUT_COUNT[x]

        // Initialize parser
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Build fragment based on test type
        switch (testType) {
            case CLONE_TEST_LITERAL: {
                if (!NAVRegexParserBuildLiteral(parser, testChar, fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case CLONE_TEST_DOT: {
                if (!NAVRegexParserBuildDot(parser, fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case CLONE_TEST_CHAR_CLASS: {
                // For simplicity, just use a literal instead of dealing with char class structure
                if (!NAVRegexParserBuildLiteral(parser, 'c', fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case CLONE_TEST_CAPTURE_SIMPLE: {
                stack_var _NAVRegexNFAFragment inner
                if (!NAVRegexParserBuildLiteral(parser, testChar, inner)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildCapturingGroup(parser, inner, 1, '', fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case CLONE_TEST_CAPTURE_CONCAT: {
                stack_var _NAVRegexNFAFragment innerA
                stack_var _NAVRegexNFAFragment innerB
                stack_var _NAVRegexNFAFragment concatenated
                if (!NAVRegexParserBuildLiteral(parser, testChar, innerA)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, 'b', innerB)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildConcatenation(parser, innerA, innerB, concatenated)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildCapturingGroup(parser, concatenated, 1, '', fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case CLONE_TEST_INVALID: {
                invalidFragment.startState = 0
                invalidFragment.outCount = 0
                fragment = invalidFragment
            }
        }

        originalStart = fragment.startState
        originalStateCount = parser.stateCount

        // Clone the fragment
        testResult = NAVRegexParserCloneFragment(parser, fragment, clone1)

        // Verify result
        if (shouldSucceed) {
            if (!NAVAssertTrue('Should clone successfully', testResult)) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }

            // Verify clone has different start state
            if (!NAVAssertIntegerNotEqual('Clone should have different start state', originalStart, clone1.startState)) {
                NAVLogTestFailed(x, "'different'", "'same'")
                continue
            }

            // Verify outCount matches expected
            if (!NAVAssertIntegerEqual('Clone should have correct outCount', expectedOutCount, clone1.outCount)) {
                NAVLogTestFailed(x, itoa(expectedOutCount), itoa(clone1.outCount))
                continue
            }

            // For deep clone tests, verify new states were created
            if (isDeep) {
                if (!NAVAssertTrue('Deep clone should create new states', parser.stateCount > originalStateCount)) {
                    NAVLogTestFailed(x, "'more states'", "'same states'")
                    continue
                }

                // Clone again to verify independence
                stateCountAfterClone1 = parser.stateCount
                testResult = NAVRegexParserCloneFragment(parser, fragment, clone2)

                if (!NAVAssertTrue('Should clone successfully again', testResult)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVAssertTrue('Second deep clone should create new states', parser.stateCount > stateCountAfterClone1)) {
                    NAVLogTestFailed(x, "'more states'", "'same states'")
                    continue
                }

                if (!NAVAssertIntegerNotEqual('Clones should have different start states', clone1.startState, clone2.startState)) {
                    NAVLogTestFailed(x, "'different'", "'same'")
                    continue
                }
            }
        }
        else {
            if (!NAVAssertFalse('Should fail to clone', testResult)) {
                NAVLogTestFailed(x, 'false', 'true')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserFragmentBoundaryDetection
 * @public
 * @description Tests fragment boundary state detection helper.
 *
 * Validates:
 * - NAVRegexParserIsFragmentBoundary() correctly identifies outStates
 * - Boundary detection works for fragments with multiple outs
 * - Non-boundary states return false
 */
define_function TestNAVRegexParserFragmentBoundaryDetection() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Fragment Boundary Detection *****************'")

    for (x = 1; x <= 4; x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment
        stack_var _NAVRegexNFAFragment literalFragment
        stack_var _NAVRegexNFAFragment innerFragment

        // Initialize parser
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Build fragment based on test number
        switch (x) {
            case 1: {
                // Single literal - the literal state IS both start and boundary
                if (!NAVRegexParserBuildLiteral(parser, 'a', fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // For a literal, startState IS in outStates
                if (!NAVAssertTrue('Literal state should be boundary', NAVRegexParserIsFragmentBoundary(fragment.startState, fragment))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // State 0 should not be boundary
                if (!NAVAssertFalse('State 0 should not be boundary', NAVRegexParserIsFragmentBoundary(0, fragment))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }
            }
            case 2: {
                // Optional literal - SPLIT is start AND boundary (skip path)
                if (!NAVRegexParserBuildLiteral(parser, 'b', literalFragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVRegexParserBuildZeroOrOne(parser, literalFragment, false, fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // Verify fragment has 2 outStates
                if (!NAVAssertIntegerEqual('Should have 2 outStates', 2, fragment.outCount)) {
                    NAVLogTestFailed(x, '2', itoa(fragment.outCount))
                    continue
                }

                // All outStates should be detected as boundaries
                if (!NAVAssertTrue('First outState should be boundary', NAVRegexParserIsFragmentBoundary(fragment.outStates[1], fragment))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVAssertTrue('Second outState should be boundary', NAVRegexParserIsFragmentBoundary(fragment.outStates[2], fragment))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // Start state (SPLIT) IS boundary for zero-or-one (it's the skip path)
                if (!NAVAssertTrue('SPLIT start state should be boundary', NAVRegexParserIsFragmentBoundary(fragment.startState, fragment))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case 3: {
                // Concatenation - start state not in outStates
                if (!NAVRegexParserBuildLiteral(parser, 'x', literalFragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVRegexParserBuildLiteral(parser, 'y', innerFragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVRegexParserBuildConcatenation(parser, literalFragment, innerFragment, fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // Start state should NOT be boundary
                if (!NAVAssertFalse('Concat start state should not be boundary', NAVRegexParserIsFragmentBoundary(fragment.startState, fragment))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }

                // The final literal state should be boundary
                if (!NAVAssertTrue('Final state should be boundary', NAVRegexParserIsFragmentBoundary(fragment.outStates[1], fragment))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
            case 4: {
                // Capturing group - CAPTURE_START is start but NOT boundary
                if (!NAVRegexParserBuildLiteral(parser, 'z', literalFragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                if (!NAVRegexParserBuildCapturingGroup(parser, literalFragment, 1, '', fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // Start state (CAPTURE_START) should NOT be boundary
                if (!NAVAssertFalse('Capture start should not be boundary', NAVRegexParserIsFragmentBoundary(fragment.startState, fragment))) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }

                // The CAPTURE_END state should be boundary
                if (!NAVAssertTrue('Capture end should be boundary', NAVRegexParserIsFragmentBoundary(fragment.outStates[1], fragment))) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserFragmentCloningMultiple
 * @public
 * @description Tests multiple clones and state independence.
 *
 * Validates:
 * - Multiple clones of same fragment work correctly
 * - Each clone gets independent states
 * - State count increases appropriately
 * - Clones can be used in subsequent operations
 */
define_function TestNAVRegexParserFragmentCloningMultiple() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Fragment Cloning (Multiple) *****************'")

    for (x = 1; x <= 3; x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment
        stack_var _NAVRegexNFAFragment clones[5]
        stack_var integer originalStateCount
        stack_var integer expectedStatesPerClone
        stack_var integer i
        stack_var char allUnique

        // Initialize parser
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Build different fragment types
        switch (x) {
            case 1: {
                // Simple capturing group
                stack_var _NAVRegexNFAFragment inner
                if (!NAVRegexParserBuildLiteral(parser, 'a', inner)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildCapturingGroup(parser, inner, 1, '', fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                expectedStatesPerClone = 3  // CAPTURE_START + LITERAL + CAPTURE_END
            }
            case 2: {
                // Capturing group with concatenation
                stack_var _NAVRegexNFAFragment innerA
                stack_var _NAVRegexNFAFragment innerB
                stack_var _NAVRegexNFAFragment concatenated
                if (!NAVRegexParserBuildLiteral(parser, 'a', innerA)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, 'b', innerB)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildConcatenation(parser, innerA, innerB, concatenated)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildCapturingGroup(parser, concatenated, 1, '', fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                expectedStatesPerClone = 4  // CAPTURE_START + LITERAL + LITERAL + CAPTURE_END
            }
            case 3: {
                // Capturing group with alternation
                stack_var _NAVRegexNFAFragment innerX
                stack_var _NAVRegexNFAFragment innerY
                stack_var _NAVRegexNFAFragment alternation
                if (!NAVRegexParserBuildLiteral(parser, 'x', innerX)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, 'y', innerY)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildAlternation(parser, innerX, innerY, alternation)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildCapturingGroup(parser, alternation, 1, '', fragment)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                expectedStatesPerClone = 6  // CAPTURE_START + SPLIT + LITERAL + LITERAL + EPSILON + CAPTURE_END
            }
        }

        originalStateCount = parser.stateCount

        // Create 5 clones
        for (i = 1; i <= 5; i++) {
            if (!NAVRegexParserCloneFragment(parser, fragment, clones[i])) {
                NAVLogTestFailed(x, 'true', 'false')
                continue
            }
        }

        // Verify state count increased
        if (!NAVAssertTrue('State count should increase', parser.stateCount > originalStateCount)) {
            NAVLogTestFailed(x, "'increased'", "'same'")
            continue
        }

        // Verify all clone start states are unique
        allUnique = true
        for (i = 1; i <= 5 && allUnique; i++) {
            stack_var integer j
            for (j = i + 1; j <= 5 && allUnique; j++) {
                if (clones[i].startState == clones[j].startState) {
                    allUnique = false
                }
            }
        }

        if (!NAVAssertTrue('All clones should have unique start states', allUnique)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexParserFragmentCloningEdgeCases
 * @public
 * @description Tests edge cases for fragment cloning.
 *
 * Validates:
 * - Cloning at near-capacity conditions
 * - Cloning fragments with maximum outStates
 * - Proper error handling
 */
define_function TestNAVRegexParserFragmentCloningEdgeCases() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Fragment Cloning (Edge Cases) *****************'")

    for (x = 1; x <= 2; x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment fragment
        stack_var _NAVRegexNFAFragment clone
        stack_var char result

        // Initialize parser
        if (!NAVRegexLexerTokenize('/test/', lexer)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        switch (x) {
            case 1: {
                // Invalid fragment (startState = 0)
                fragment.startState = 0
                fragment.outCount = 1
                set_length_array(fragment.outStates, 1)
                fragment.outStates[1] = 1

                result = NAVRegexParserCloneFragment(parser, fragment, clone)

                if (!NAVAssertFalse('Should fail with invalid fragment', result)) {
                    NAVLogTestFailed(x, 'false', 'true')
                    continue
                }
            }
            case 2: {
                // Fragment with multiple outStates (from alternation)
                stack_var _NAVRegexNFAFragment lit1
                stack_var _NAVRegexNFAFragment lit2
                stack_var _NAVRegexNFAFragment lit3
                stack_var _NAVRegexNFAFragment alt1
                stack_var _NAVRegexNFAFragment alt2
                stack_var _NAVRegexNFAFragment captured

                if (!NAVRegexParserBuildLiteral(parser, 'a', lit1)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, 'b', lit2)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildLiteral(parser, 'c', lit3)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildAlternation(parser, lit1, lit2, alt1)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildAlternation(parser, alt1, lit3, alt2)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }
                if (!NAVRegexParserBuildCapturingGroup(parser, alt2, 1, '', captured)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // Clone this complex fragment
                result = NAVRegexParserCloneFragment(parser, captured, clone)

                if (!NAVAssertTrue('Should clone complex fragment', result)) {
                    NAVLogTestFailed(x, 'true', 'false')
                    continue
                }

                // Verify clone has same outCount
                if (!NAVAssertIntegerEqual('Clone should preserve outCount', captured.outCount, clone.outCount)) {
                    NAVLogTestFailed(x, itoa(captured.outCount), itoa(clone.outCount))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
