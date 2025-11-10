PROGRAM_NAME='NAVRegexApiCompile'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for NAVRegexCompile() API function
constant char REGEX_API_COMPILE_PATTERN[][255] = {
    '/a/',                      // 1: Simple literal
    '/\d+/',                    // 2: Predefined class with quantifier
    '/[a-z]+/',                 // 3: Character class with quantifier
    '/^test$/',                 // 4: Anchored pattern
    '/(hello)\s+(world)/',      // 5: Multiple capturing groups
    '/(?<name>\w+)/',           // 6: Named group
    '/foo|bar|baz/',            // 7: Multiple alternation
    '/a{3,5}/',                 // 8: Bounded quantifier
    '/(?=test)/',               // 9: Lookahead assertion
    '/\b\w+\b/',                // 10: Word boundaries
    '/case/i',                  // 11: Case-insensitive flag
    '/multi/m',                 // 12: Multiline flag
    '/dot/s',                   // 13: Dotall flag
    '/combined/ims',            // 14: Multiple flags
    '/invalidPattern[/'         // 15: Invalid pattern (should fail)
}

constant char REGEX_API_COMPILE_SHOULD_SUCCEED[] = {
    true,               // 1
    true,               // 2
    true,               // 3
    true,               // 4
    true,               // 5
    true,               // 6
    true,               // 7
    true,               // 8
    true,               // 9
    true,               // 10
    true,               // 11
    true,               // 12
    true,               // 13
    true,               // 14
    false               // 15: Invalid pattern should fail
}

/**
 * @function TestNAVRegexApiCompile
 * @public
 * @description Tests the NAVRegexCompile() public API function.
 *
 * Validates:
 * - Successful compilation of valid patterns
 * - NFA structure is populated (stateCount > 0)
 * - Start and accept states are set correctly
 * - Error handling for invalid patterns
 * - Various pattern types compile correctly
 * - Flags are processed correctly
 */
define_function TestNAVRegexApiCompile() {
    stack_var integer x

    NAVLog("'***************** NAVRegexAPI - Compile Function *****************'")

    for (x = 1; x <= length_array(REGEX_API_COMPILE_PATTERN); x++) {
        stack_var _NAVRegexNFA nfa
        stack_var char result

        NAVStopwatchStart()

        // Execute compile using NAVRegexCompile() API
        result = NAVRegexCompile(REGEX_API_COMPILE_PATTERN[x], nfa)

        if (REGEX_API_COMPILE_SHOULD_SUCCEED[x]) {
            // Should succeed
            if (!NAVAssertTrue('Compilation should succeed', result)) {
                NAVLogTestFailed(x, 'success (TRUE)', 'failure (FALSE)')
                NAVLog("'  Pattern: ', REGEX_API_COMPILE_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify NFA has states
            if (!NAVAssertTrue('NFA should have states', nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'stateCount > 0', itoa(nfa.stateCount))
                NAVLog("'  Pattern: ', REGEX_API_COMPILE_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify start state is valid
            if (!NAVAssertTrue('Start state should be valid', nfa.startState > 0)) {
                NAVLogTestFailed(x, 'startState > 0', itoa(nfa.startState))
                NAVLog("'  Pattern: ', REGEX_API_COMPILE_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify accept state is valid (state 0 in our implementation)
            if (!NAVAssertIntegerEqual('Accept state should be 0', 0, nfa.acceptState)) {
                NAVLogTestFailed(x, '0', itoa(nfa.acceptState))
                NAVLog("'  Pattern: ', REGEX_API_COMPILE_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify start state is within bounds
            if (!NAVAssertTrue('Start state within state count', nfa.startState <= nfa.stateCount)) {
                NAVLogTestFailed(x, 'startState <= stateCount', "itoa(nfa.startState), ' > ', itoa(nfa.stateCount)")
                NAVLog("'  Pattern: ', REGEX_API_COMPILE_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }
        }
        else {
            // Should fail
            if (!NAVAssertFalse('Compilation should fail for invalid pattern', result)) {
                NAVLogTestFailed(x, 'failure (FALSE)', 'success (TRUE)')
                NAVLog("'  Pattern: ', REGEX_API_COMPILE_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}

