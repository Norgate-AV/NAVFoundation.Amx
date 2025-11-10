PROGRAM_NAME='NAVRegexMatcherGlobalMaxCount'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for global matching at MAX_REGEX_MATCHES limit (64)
constant char REGEX_MATCHER_GLOBAL_MAXCOUNT_PATTERN[][255] = {
    '/a/g',                 // 1: Simple single char - exactly 64
    '/a/g',                 // 2: Simple single char - more than 64 (truncated)
    '/\d/g',                // 3: Digits - approaching limit (60)
    '/x/g',                 // 4: Pattern with no matches
    '/./g',                 // 5: Match every char - truncated to 64
    '/\w/g'                 // 6: Word chars - truncated to 64
}

constant char REGEX_MATCHER_GLOBAL_MAXCOUNT_INPUT[][255] = {
    // 1: Exactly 64 'a' chars
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    // 2: 100 'a' chars (should truncate to 64)
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    // 3: 60 digits (approaching limit)
    '012345678901234567890123456789012345678901234567890123456789',
    // 4: No 'x' chars
    'abcdefghijklmnopqrstuvw',
    // 5: Long string with many chars (should truncate to 64)
    'The quick brown fox jumps over the lazy dog. Pack my box with five dozen liquor jugs. How vexingly quick daft zebras jump!',
    // 6: Many word chars (should truncate to 64)
    'abcdefghijklmnopqrstuvwyzABCDEFGHIJKLMNOPQRSTUVWYZ0123456789abcdefghijklmnopqrstuvwyzABCDEFGHIJKLMNOPQRSTUVWYZ'
}

constant integer REGEX_MATCHER_GLOBAL_MAXCOUNT_EXPECTED_COUNT[] = {
    64,                     // 1: Exactly at limit
    64,                     // 2: Truncated to limit
    60,                     // 3: Below limit
    0,                      // 4: No matches
    64,                     // 5: Truncated to limit
    64                      // 6: Truncated to limit
}

constant char REGEX_MATCHER_GLOBAL_MAXCOUNT_EXPECTED_FIRST_MATCH[][255] = {
    'a',                    // 1
    'a',                    // 2
    '0',                    // 3
    '',                     // 4: No match
    'T',                    // 5
    'a'                     // 6
}

constant char REGEX_MATCHER_GLOBAL_MAXCOUNT_SHOULD_MATCH[] = {
    true,                   // 1: Should match
    true,                   // 2: Should match
    true,                   // 3: Should match
    false,                  // 4: Should NOT match
    true,                   // 5: Should match
    true                    // 6: Should match
}

/**
 * @function TestNAVRegexMatcherGlobalMaxCount
 * @public
 * @description Tests global matching at and beyond MAX_REGEX_MATCHES limit.
 *
 * Validates:
 * - Exactly MAX_REGEX_MATCHES (64) matches
 * - Truncation when input would produce more than 64 matches
 * - Approaching the limit (60+ matches)
 * - Proper status codes when at limit
 *
 * This ensures the global match implementation correctly enforces the
 * MAX_REGEX_MATCHES limit and handles edge cases.
 */
define_function TestNAVRegexMatcherGlobalMaxCount() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Global Match Max Count *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_GLOBAL_MAXCOUNT_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char input[1024]
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_GLOBAL_MAXCOUNT_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Build input string
        input = REGEX_MATCHER_GLOBAL_MAXCOUNT_INPUT[x]

        // Execute match - use MatchAll to find all occurrences
        NAVRegexMatchAll(REGEX_MATCHER_GLOBAL_MAXCOUNT_PATTERN[x], input, collection)

        if (shouldMatch) {
            // Verify match success
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_GLOBAL_MAXCOUNT_PATTERN[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify match count
            if (!NAVAssertIntegerEqual('Match count should be correct', REGEX_MATCHER_GLOBAL_MAXCOUNT_EXPECTED_COUNT[x], collection.count)) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_GLOBAL_MAXCOUNT_EXPECTED_COUNT[x]), itoa(collection.count))
                NAVLog("'  Pattern: ', REGEX_MATCHER_GLOBAL_MAXCOUNT_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify first match text
            if (!NAVAssertStringEqual('First match text should be correct', REGEX_MATCHER_GLOBAL_MAXCOUNT_EXPECTED_FIRST_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_GLOBAL_MAXCOUNT_EXPECTED_FIRST_MATCH[x], collection.matches[1].fullMatch.text)
                NAVLog("'  Pattern: ', REGEX_MATCHER_GLOBAL_MAXCOUNT_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        } else {
            // Verify no match
            if (!NAVAssertTrue('Should not match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match', 'Match found')
                NAVLog("'  Pattern: ', REGEX_MATCHER_GLOBAL_MAXCOUNT_PATTERN[x]")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
