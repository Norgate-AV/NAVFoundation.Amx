PROGRAM_NAME='NAVRegexMatcherBackreferenceCaseInsensitive'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for case-insensitive backreferences
constant char REGEX_MATCHER_BACKREF_CASEINS_PATTERN[][255] = {
    '/(\w)-\1/i',           // 1: Single char - lowercase to uppercase
    '/(\w)-\1/i',           // 2: Single char - uppercase to lowercase
    '/(\w+)-\1/i',          // 3: Multi-char - same case
    '/(\w+)-\1/i',          // 4: Multi-char - lowercase to uppercase
    '/(\w+)-\1/i',          // 5: Multi-char - uppercase to lowercase
    '/(\w+)-\1/i',          // 6: Different words should NOT match
    '/(\w)-\1/',            // 7: Without /i - different case should NOT match
    '/(\w)-\1-(\w)-\2/i',   // 8: Multiple backrefs with mixed case
    '/(\w+)-\1/i',          // 9: Mixed case in captured group
    '/^(\w+)-\1$/i',        // 10: Anchored with case variation
    '/(abc)-\1/i',          // 11: Specific word - different case
    '/(\d+)-\1/i',          // 12: Digits with /i (case doesn't apply)
    '/([a-z]+)-\1/i',       // 13: Char class with case variation
    '/(test)-\1/i',         // 14: Word with all caps variation
    '/(\w)-\1-\1/i',        // 15: Same backref used twice
    '/(\w+)-\1/i',          // 16: CamelCase variations
    '/(\w)-\1/',            // 17: Case-sensitive should NOT match
    '/(\w+)-\1/i'           // 18: Multiple words should NOT match
}

constant char REGEX_MATCHER_BACKREF_CASEINS_INPUT[][255] = {
    'a-A',                  // 1: a then A
    'A-a',                  // 2: A then a
    'hello-hello',          // 3: Same case
    'hello-HELLO',          // 4: hello then HELLO
    'HELLO-hello',          // 5: HELLO then hello
    'hello-world',          // 6: Different words
    'a-A',                  // 7: Different case without /i
    'a-A-b-B',              // 8: Two groups with case variation
    'HeLLo-hello',          // 9: Mixed case to lowercase
    'TeSt-TEST',            // 10: Mixed case anchored
    'abc-ABC',              // 11: abc then ABC
    '123-123',              // 12: Digits (case irrelevant)
    'test-TEST',            // 13: Char class case variation
    'test-TEST',            // 14: test then TEST
    'x-X-x',                // 15: Same backref multiple times
    'camelCase-CamelCase',  // 16: CamelCase variations
    'b-B',                  // 17: Case-sensitive mismatch
    'foo-bar'               // 18: Different words
}

constant char REGEX_MATCHER_BACKREF_CASEINS_EXPECTED_MATCH[][255] = {
    'a-A',                  // 1
    'A-a',                  // 2
    'hello-hello',          // 3
    'hello-HELLO',          // 4
    'HELLO-hello',          // 5
    '',                     // 6: No match
    '',                     // 7: No match
    'a-A-b-B',              // 8
    'HeLLo-hello',          // 9
    'TeSt-TEST',            // 10
    'abc-ABC',              // 11
    '123-123',              // 12
    'test-TEST',            // 13
    'test-TEST',            // 14
    'x-X-x',                // 15
    'camelCase-CamelCase',  // 16
    '',                     // 17: No match
    ''                      // 18: No match
}

constant integer REGEX_MATCHER_BACKREF_CASEINS_EXPECTED_START[] = {
    1,                      // 1
    1,                      // 2
    1,                      // 3
    1,                      // 4
    1,                      // 5
    0,                      // 6: No match
    0,                      // 7: No match
    1,                      // 8
    1,                      // 9
    1,                      // 10
    1,                      // 11
    1,                      // 12
    1,                      // 13
    1,                      // 14
    1,                      // 15
    1,                      // 16
    0,                      // 17: No match
    0                       // 18: No match
}

constant char REGEX_MATCHER_BACKREF_CASEINS_SHOULD_MATCH[] = {
    true,                   // 1: Should match
    true,                   // 2: Should match
    true,                   // 3: Should match
    true,                   // 4: Should match
    true,                   // 5: Should match
    false,                  // 6: Should NOT match
    false,                  // 7: Should NOT match
    true,                   // 8: Should match
    true,                   // 9: Should match
    true,                   // 10: Should match
    true,                   // 11: Should match
    true,                   // 12: Should match
    true,                   // 13: Should match
    true,                   // 14: Should match
    true,                   // 15: Should match
    true,                   // 16: Should match
    false,                  // 17: Should NOT match
    false                   // 18: Should NOT match
}

/**
 * @function TestNAVRegexMatcherBackreferenceCaseInsensitive
 * @public
 * @description Tests backreferences with case-insensitive flag (/i).
 *
 * Validates:
 * - Single character backreferences with case variations
 * - Multi-character backreferences with case variations
 * - Multiple backreferences in same pattern with /i
 * - Case-insensitive flag applies to backreference matching
 * - Patterns without /i still enforce case matching
 * - Mixed case in captured groups
 * - Same backreference used multiple times
 *
 * This ensures backreferences properly integrate with the case-insensitive
 * flag for flexible pattern matching across different case styles.
 */
define_function TestNAVRegexMatcherBackreferenceCaseInsensitive() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Case-Insensitive Backreferences *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_BACKREF_CASEINS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_BACKREF_CASEINS_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_BACKREF_CASEINS_PATTERN[x], REGEX_MATCHER_BACKREF_CASEINS_INPUT[x], collection)

        if (shouldMatch) {
            // Verify match success
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_BACKREF_CASEINS_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_BACKREF_CASEINS_INPUT[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_BACKREF_CASEINS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_BACKREF_CASEINS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVLog("'  Pattern: ', REGEX_MATCHER_BACKREF_CASEINS_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_BACKREF_CASEINS_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_BACKREF_CASEINS_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_BACKREF_CASEINS_EXPECTED_START[x]), itoa(collection.matches[1].fullMatch.start))
                NAVLog("'  Pattern: ', REGEX_MATCHER_BACKREF_CASEINS_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_BACKREF_CASEINS_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        } else {
            // Verify no match
            if (!NAVAssertTrue('Should not match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match', 'Match found')
                NAVLog("'  Pattern: ', REGEX_MATCHER_BACKREF_CASEINS_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_BACKREF_CASEINS_INPUT[x]")
                NAVLog("'  Matched: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
