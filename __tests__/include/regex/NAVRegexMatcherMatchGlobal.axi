PROGRAM_NAME='NAVRegexMatcherMatchGlobal'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for global matching
constant char REGEX_MATCHER_GLOBAL_PATTERN[][255] = {
    '/a/g',              // 1
    '/\d/g',             // 2
    '/\d+/g',            // 3
    '/[aeiou]/g',        // 4
    '/\w+/g',            // 5
    '/[0-9]+/g',         // 6
    '/[A-Z][a-z]+/g',    // 7
    '/<[^>]+>/g',        // 8
    '/[a-z]{3}/g',       // 9: Three lowercase letters (without word boundaries)
    '/[a-z]+@[a-z]+\.[a-z]+/g'  // 10
}

constant char REGEX_MATCHER_GLOBAL_INPUT[][255] = {
    'banana',                           // 1
    '1a2b3c4',                          // 2
    'abc123def456',                     // 3
    'hello world',                      // 4
    'hello world test',                 // 5
    'Room 101, Floor 5, Building 23',   // 6
    'The Quick Brown Fox Jumps',        // 7
    '<div><p>Hello</p></div>',          // 8
    'the cat sat on the mat',           // 9
    'john@test.com or mary@demo.org'    // 10
}

constant integer REGEX_MATCHER_GLOBAL_EXPECTED_COUNT[] = {
    3,    // 1
    4,    // 2
    2,    // 3
    3,    // 4
    3,    // 5
    3,    // 6
    5,    // 7
    4,    // 8
    5,    // 9: Five 3-letter sequences: "the", "cat", "sat", "the", "mat"
    2     // 10
}

constant char REGEX_MATCHER_GLOBAL_EXPECTED_FIRST_MATCH[][255] = {
    'a',                // 1
    '1',                // 2
    '123',              // 3
    'e',                // 4
    'hello',            // 5
    '101',              // 6
    'The',              // 7
    '<div>',            // 8
    'the',              // 9
    'john@test.com'     // 10
}

define_function TestNAVRegexMatcherMatchGlobal() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Global Matching *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_GLOBAL_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match - use MatchAll to find all occurrences
        if (!NAVRegexMatchAll(REGEX_MATCHER_GLOBAL_PATTERN[x], REGEX_MATCHER_GLOBAL_INPUT[x], collection)) {
            NAVLogTestFailed(x, 'match success', 'match failed')
            NAVStopwatchStop()
            continue
        }

        // Verify match status
        if (!NAVAssertIntegerEqual('Match status should be SUCCESS', MATCH_STATUS_SUCCESS, collection.status)) {
            NAVLogTestFailed(x, 'SUCCESS', itoa(collection.status))
            NAVStopwatchStop()
            continue
        }

        // Verify match count
        if (!NAVAssertIntegerEqual('Match count should be correct', REGEX_MATCHER_GLOBAL_EXPECTED_COUNT[x], collection.count)) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_GLOBAL_EXPECTED_COUNT[x]), itoa(collection.count))
            NAVStopwatchStop()
            continue
        }

        // Verify first match text
        if (collection.count > 0) {
            if (!NAVAssertStringEqual('First match text should be correct', REGEX_MATCHER_GLOBAL_EXPECTED_FIRST_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_GLOBAL_EXPECTED_FIRST_MATCH[x], collection.matches[1].fullMatch.text)
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
