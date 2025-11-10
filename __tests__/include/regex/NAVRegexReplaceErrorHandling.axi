PROGRAM_NAME='NAVRegexReplaceErrorHandling'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for replace error handling
constant char REGEX_REPLACE_ERROR_PATTERN[][255] = {
    '/[invalid/',           // 1: Unclosed character class
    '/(?<unclosed/',        // 2: Unclosed named group
    '/(unclosed/',          // 3: Unclosed capture group
    '/invalid)/',           // 4: Unmatched closing paren
    '/(?P<name>test/',      // 5: Unclosed Python-style named group
    '/test{5/',             // 6: Unclosed quantifier
    '/test[/',              // 7: Unclosed char class at end
    '/(?:unclosed/',        // 8: Unclosed non-capturing group
    '/test\k<invalid/',     // 9: Invalid backreference syntax
    '/(?<>empty)/'          // 10: Empty group name
}

constant char REGEX_REPLACE_ERROR_INPUT[][255] = {
    'test input',           // 1
    'test input',           // 2
    'test input',           // 3
    'test input',           // 4
    'test input',           // 5
    'test input',           // 6
    'test input',           // 7
    'test input',           // 8
    'test input',           // 9
    'test input'            // 10
}

constant char REGEX_REPLACE_ERROR_REPLACEMENT[][255] = {
    'replacement',          // 1
    'replacement',          // 2
    'replacement',          // 3
    'replacement',          // 4
    'replacement',          // 5
    'replacement',          // 6
    'replacement',          // 7
    'replacement',          // 8
    'replacement',          // 9
    'replacement'           // 10
}

// Test patterns for split error handling
constant char REGEX_SPLIT_ERROR_PATTERN[][255] = {
    '/[invalid/',           // 1: Unclosed character class
    '/(?<unclosed/',        // 2: Unclosed named group
    '/(unclosed/',          // 3: Unclosed capture group
    '/invalid)/',           // 4: Unmatched closing paren
    '/test{5/',             // 5: Unclosed quantifier
    '/test[/',              // 6: Unclosed char class at end
    '/(?:unclosed/',        // 7: Unclosed non-capturing group
    '/\k<invalid/',         // 8: Invalid backreference syntax
    '/(?P<name>test/',      // 9: Unclosed Python-style named group
    '/(?<>empty)/'          // 10: Empty group name
}

constant char REGEX_SPLIT_ERROR_INPUT[][255] = {
    'test,input,data',      // 1
    'test,input,data',      // 2
    'test,input,data',      // 3
    'test,input,data',      // 4
    'test,input,data',      // 5
    'test,input,data',      // 6
    'test,input,data',      // 7
    'test,input,data',      // 8
    'test,input,data',      // 9
    'test,input,data'       // 10
}

/**
 * @function TestNAVRegexReplaceErrorHandling
 * @public
 * @description Tests error handling in NAVRegexReplace and NAVRegexReplaceAll functions.
 *
 * Validates:
 * - Invalid patterns cause Replace to return FALSE
 * - Output string is empty when pattern fails to compile
 * - Unclosed character classes handled gracefully
 * - Unclosed groups handled gracefully
 * - Invalid quantifiers handled gracefully
 * - Unmatched parentheses handled gracefully
 * - Invalid backreference syntax handled gracefully
 * - No crashes or undefined behavior on invalid patterns
 * - Error state properly propagated to caller
 * - Both Replace and ReplaceAll handle errors the same way
 *
 * This ensures the Replace/ReplaceAll functions fail safely when
 * given malformed regex patterns instead of causing crashes or corruption.
 */
define_function TestNAVRegexReplaceErrorHandling() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - Replace Error Handling *****************'")

    for (x = 1; x <= length_array(REGEX_REPLACE_ERROR_PATTERN); x++) {
        stack_var char output[65535]
        stack_var char result

        NAVStopwatchStart()

        output = ''

        // Test NAVRegexReplace
        result = NAVRegexReplace(REGEX_REPLACE_ERROR_PATTERN[x], REGEX_REPLACE_ERROR_INPUT[x], REGEX_REPLACE_ERROR_REPLACEMENT[x], output)

        // Verify Replace returns FALSE on error
        if (!NAVAssertFalse('Replace should return FALSE for invalid pattern', result)) {
            NAVLogTestFailed(x, 'FALSE', 'TRUE')
            NAVLog("'  Pattern: ', REGEX_REPLACE_ERROR_PATTERN[x]")
            NAVLog("'  Replace should fail for invalid pattern'")
            NAVStopwatchStop()
            continue
        }

        // Verify output is empty or unchanged
        if (!NAVAssertTrue('Output should be empty on error', length_array(output) == 0)) {
            NAVLogTestFailed(x, 'empty string', output)
            NAVLog("'  Pattern: ', REGEX_REPLACE_ERROR_PATTERN[x]")
            NAVLog("'  Output should be empty when pattern compilation fails'")
            NAVStopwatchStop()
            continue
        }

        // Test NAVRegexReplaceAll with same invalid pattern
        output = ''
        result = NAVRegexReplaceAll(REGEX_REPLACE_ERROR_PATTERN[x], REGEX_REPLACE_ERROR_INPUT[x], REGEX_REPLACE_ERROR_REPLACEMENT[x], output)

        // Verify ReplaceAll also returns FALSE on error
        if (!NAVAssertFalse('ReplaceAll should return FALSE for invalid pattern', result)) {
            NAVLogTestFailed(x, 'FALSE', 'TRUE')
            NAVLog("'  Pattern: ', REGEX_REPLACE_ERROR_PATTERN[x]")
            NAVLog("'  ReplaceAll should fail for invalid pattern'")
            NAVStopwatchStop()
            continue
        }

        // Verify ReplaceAll output is also empty
        if (!NAVAssertTrue('ReplaceAll output should be empty on error', length_array(output) == 0)) {
            NAVLogTestFailed(x, 'empty string', output)
            NAVLog("'  Pattern: ', REGEX_REPLACE_ERROR_PATTERN[x]")
            NAVLog("'  ReplaceAll output should be empty when pattern compilation fails'")
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}

/**
 * @function TestNAVRegexSplitErrorHandling
 * @public
 * @description Tests error handling in NAVRegexSplit function.
 *
 * Validates:
 * - Invalid patterns cause Split to return FALSE
 * - Count parameter is set to 0 when pattern fails to compile
 * - Unclosed character classes handled gracefully
 * - Unclosed groups handled gracefully
 * - Invalid quantifiers handled gracefully
 * - Unmatched parentheses handled gracefully
 * - Invalid backreference syntax handled gracefully
 * - No crashes or undefined behavior on invalid patterns
 * - Error state properly propagated to caller
 *
 * This ensures the Split function fails safely when given
 * malformed regex patterns instead of causing crashes or corruption.
 */
define_function TestNAVRegexSplitErrorHandling() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - Split Error Handling *****************'")

    for (x = 1; x <= length_array(REGEX_SPLIT_ERROR_PATTERN); x++) {
        stack_var char output[100][255]
        stack_var integer count
        stack_var char result
        stack_var integer i

        NAVStopwatchStart()

        // Clear output array
        for (i = 1; i <= 100; i++) {
            output[i] = ''
        }

        count = 0

        // Test NAVRegexSplit
        result = NAVRegexSplit(REGEX_SPLIT_ERROR_PATTERN[x], REGEX_SPLIT_ERROR_INPUT[x], output, count)

        // Verify Split returns FALSE on error
        if (!NAVAssertTrue('Split should return FALSE for invalid pattern', result == FALSE)) {
            NAVLogTestFailed(x, 'FALSE', 'TRUE')
            NAVLog("'  Pattern: ', REGEX_SPLIT_ERROR_PATTERN[x]")
            NAVLog("'  Split should fail for invalid pattern'")
            NAVStopwatchStop()
            continue
        }

        // Verify count is 0 on error
        if (!NAVAssertTrue('Count should be 0 on error', count == 0)) {
            NAVLogTestFailed(x, '0', itoa(count))
            NAVLog("'  Pattern: ', REGEX_SPLIT_ERROR_PATTERN[x]")
            NAVLog("'  Count should be 0 when pattern compilation fails'")
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
