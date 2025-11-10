PROGRAM_NAME='NAVRegexApiTest'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for NAVRegexTest() API function
constant char REGEX_API_TEST_PATTERN[][255] = {
    '/a/',              // 1: Simple literal match
    '/\d+/',            // 2: One or more digits
    '/[a-z]+/',         // 3: One or more lowercase
    '/^hello/',         // 4: Start anchor
    '/world$/',         // 5: End anchor
    '/\b\w+\b/',        // 6: Word boundaries
    '/(test)/',         // 7: Capturing group
    '/foo|bar/',        // 8: Alternation
    '/x*y+/',           // 9: Multiple quantifiers
    '/[0-9]{3}/',       // 10: Bounded quantifier
    '/(?:non)cap/',     // 11: Non-capturing group
    '/case/i',          // 12: Case-insensitive flag
    '/a.*z/',           // 13: Greedy quantifier with dot
    '/\w+@\w+\.\w+/',   // 14: Email-like pattern
    '/invalidPattern[/' // 15: Invalid pattern (should fail compilation)
}

constant char REGEX_API_TEST_INPUT[][255] = {
    'abc',              // 1: Contains 'a'
    '123',              // 2: All digits
    'hello',            // 3: All lowercase
    'hello world',      // 4: Starts with 'hello'
    'hello world',      // 5: Ends with 'world'
    'test',             // 6: Single word
    'testing',          // 7: Contains 'test'
    'foobar',           // 8: Contains both options
    'yyyyy',            // 9: Zero x, multiple y
    '123',              // 10: Three digits
    'noncap',           // 11: Matches pattern
    'CASE',             // 12: Uppercase (should match with /i)
    'amazing',          // 13: Contains a...z
    'user@test.com',    // 14: Email format
    'anything'          // 15: Input for invalid pattern
}

constant char REGEX_API_TEST_SHOULD_MATCH[] = {
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
    false               // 15: Invalid pattern should return false
}

/**
 * @function TestNAVRegexApiTest
 * @public
 * @description Tests the NAVRegexTest() public API function.
 *
 * Validates:
 * - Boolean return value (TRUE when pattern matches, FALSE otherwise)
 * - Pattern compilation (valid patterns)
 * - Error handling (invalid patterns return FALSE)
 * - Various pattern types (literals, classes, quantifiers, anchors, groups)
 * - Case-insensitive matching
 * - Alternation
 */
define_function TestNAVRegexApiTest() {
    stack_var integer x

    NAVLog("'***************** NAVRegexAPI - Test Function *****************'")

    for (x = 1; x <= length_array(REGEX_API_TEST_PATTERN); x++) {
        stack_var char result

        NAVStopwatchStart()

        // Execute test using NAVRegexTest() API
        result = NAVRegexTest(REGEX_API_TEST_PATTERN[x], REGEX_API_TEST_INPUT[x])

        // Verify result matches expectation
        if (REGEX_API_TEST_SHOULD_MATCH[x]) {
            // Should match
            if (!NAVAssertTrue('Pattern should match', result)) {
                NAVLogTestFailed(x, 'match (TRUE)', 'no match (FALSE)')
                NAVLog("'  Pattern: ', REGEX_API_TEST_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_API_TEST_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
        }
        else {
            // Should NOT match (or fail to compile)
            if (!NAVAssertFalse('Pattern should not match or should fail', result)) {
                NAVLogTestFailed(x, 'no match (FALSE)', 'match (TRUE)')
                NAVLog("'  Pattern: ', REGEX_API_TEST_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_API_TEST_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}

