PROGRAM_NAME='NAVRegexMatcherNonCapturingGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for non-capturing group matching
constant char REGEX_MATCHER_NON_CAPTURING_PATTERN[][255] = {
    '/(?:a)/',                      // 1: Simple non-capturing group
    '/(?:abc)/',                    // 2: Multi-char non-capturing
    '/(?:a)b/',                     // 3: Non-capturing followed by literal
    '/(a)(?:b)/',                   // 4: Capturing then non-capturing
    '/(?:a)(b)/',                   // 5: Non-capturing then capturing
    '/(a)(?:b)(c)/',                // 6: Capturing, non-capturing, capturing
    '/(?:a)+/',                     // 7: Non-capturing with quantifier
    '/(?:ab)+/',                    // 8: Multi-char non-capturing with quantifier
    '/(?:a|b)/',                    // 9: Non-capturing alternation
    '/((?:a)b)/',                   // 10: Nested non-capturing inside capturing
    '/(?:(a)b)/',                   // 11: Nested capturing inside non-capturing
    '/(?:(?:a))/',                  // 12: Nested non-capturing groups
    '/(?:\d+)-(\d+)/',              // 13: Non-capturing digits, capturing digits
    '/(?:Mr|Ms|Mrs)\.?\s+(\w+)/',   // 14: Non-capturing title, capturing name
    '/(?:https?):\/\/(\w+)/',       // 15: Non-capturing protocol, capturing domain
    '/(a(?:b)c)/',                  // 16: Capturing with non-capturing inside
    '/(?:a)(b)(?:c)(d)/',           // 17: Alternating non-capturing and capturing
    '/(?:a)?/',                     // 18: Optional non-capturing
    '/(?:test)/',                   // 19: Non-capturing word
    '/(?:a)(?:b)(?:c)/'             // 20: Multiple non-capturing groups
}

constant char REGEX_MATCHER_NON_CAPTURING_INPUT[][255] = {
    'a',                            // 1
    'abc',                          // 2
    'ab',                           // 3
    'ab',                           // 4
    'ab',                           // 5
    'abc',                          // 6
    'aaa',                          // 7
    'ababab',                       // 8
    'a',                            // 9
    'ab',                           // 10
    'ab',                           // 11
    'a',                            // 12
    '123-456',                      // 13
    'Mr Smith',                     // 14
    'https://example',              // 15
    'abc',                          // 16
    'abcd',                         // 17
    'b',                            // 18: Non-capturing group not present
    'testing',                      // 19
    'abc'                           // 20
}

constant char REGEX_MATCHER_NON_CAPTURING_EXPECTED_MATCH[][255] = {
    'a',                            // 1
    'abc',                          // 2
    'ab',                           // 3
    'ab',                           // 4
    'ab',                           // 5
    'abc',                          // 6
    'aaa',                          // 7
    'ababab',                       // 8
    'a',                            // 9
    'ab',                           // 10
    'ab',                           // 11
    'a',                            // 12
    '123-456',                      // 13
    'Mr Smith',                     // 14
    'https://example',              // 15
    'abc',                          // 16
    'abcd',                         // 17
    '',                             // 18: Empty match (optional non-capturing)
    'test',                         // 19
    'abc'                           // 20
}

constant integer REGEX_MATCHER_NON_CAPTURING_EXPECTED_START[] = {
    1,                              // 1
    1,                              // 2
    1,                              // 3
    1,                              // 4
    1,                              // 5
    1,                              // 6
    1,                              // 7
    1,                              // 8
    1,                              // 9
    1,                              // 10
    1,                              // 11
    1,                              // 12
    1,                              // 13
    1,                              // 14
    1,                              // 15
    1,                              // 16
    1,                              // 17
    1,                              // 18
    1,                              // 19
    1                               // 20
}

constant char REGEX_MATCHER_NON_CAPTURING_SHOULD_MATCH[] = {
    true,                           // 1
    true,                           // 2
    true,                           // 3
    true,                           // 4
    true,                           // 5
    true,                           // 6
    true,                           // 7
    true,                           // 8
    true,                           // 9
    true,                           // 10
    true,                           // 11
    true,                           // 12
    true,                           // 13
    true,                           // 14
    true,                           // 15
    true,                           // 16
    true,                           // 17
    true,                           // 18
    true,                           // 19
    true                            // 20
}

// Expected group count - only CAPTURING groups are counted
constant integer REGEX_MATCHER_NON_CAPTURING_EXPECTED_GROUP_COUNT[] = {
    0,                              // 1: No capturing groups
    0,                              // 2: No capturing groups
    0,                              // 3: No capturing groups
    1,                              // 4: One capturing group (a)
    1,                              // 5: One capturing group (b)
    2,                              // 6: Two capturing groups (a, c)
    0,                              // 7: No capturing groups
    0,                              // 8: No capturing groups
    0,                              // 9: No capturing groups
    1,                              // 10: Outer capturing group
    1,                              // 11: Inner capturing group
    0,                              // 12: No capturing groups
    1,                              // 13: One capturing group
    1,                              // 14: One capturing group (name)
    1,                              // 15: One capturing group (domain)
    1,                              // 16: One outer capturing group
    2,                              // 17: Two capturing groups (b, d)
    0,                              // 18: No capturing groups
    0,                              // 19: No capturing groups
    0                               // 20: No capturing groups
}

// Expected text for group 1 (where applicable)
constant char REGEX_MATCHER_NON_CAPTURING_EXPECTED_GROUP1[][255] = {
    '',                             // 1: No groups
    '',                             // 2: No groups
    '',                             // 3: No groups
    'a',                            // 4
    'b',                            // 5
    'a',                            // 6
    '',                             // 7: No groups
    '',                             // 8: No groups
    '',                             // 9: No groups
    'ab',                           // 10: Outer group captures 'ab'
    'a',                            // 11: Inner group captures 'a'
    '',                             // 12: No groups
    '456',                          // 13
    'Smith',                        // 14
    'example',                      // 15
    'abc',                          // 16: Outer group
    'b',                            // 17
    '',                             // 18: No groups
    '',                             // 19: No groups
    ''                              // 20: No groups
}

// Expected text for group 2 (where applicable)
constant char REGEX_MATCHER_NON_CAPTURING_EXPECTED_GROUP2[][255] = {
    '',                             // 1: No group 2
    '',                             // 2: No group 2
    '',                             // 3: No group 2
    '',                             // 4: No group 2
    '',                             // 5: No group 2
    'c',                            // 6
    '',                             // 7: No group 2
    '',                             // 8: No group 2
    '',                             // 9: No group 2
    '',                             // 10: No group 2
    '',                             // 11: No group 2
    '',                             // 12: No group 2
    '',                             // 13: No group 2
    '',                             // 14: No group 2
    '',                             // 15: No group 2
    '',                             // 16: No group 2
    'd',                            // 17
    '',                             // 18: No group 2
    '',                             // 19: No group 2
    ''                              // 20: No group 2
}


/**
 * @function TestNAVRegexMatcherNonCapturingGroups
 * @public
 * @description Tests non-capturing group functionality (?:...).
 *
 * Validates:
 * - Non-capturing groups match but don't create capture groups
 * - Group count excludes non-capturing groups
 * - Non-capturing groups with quantifiers
 * - Non-capturing groups with alternation
 * - Mixed capturing and non-capturing groups
 * - Nested non-capturing groups
 * - Non-capturing groups preserve group numbering for capturing groups
 */
define_function TestNAVRegexMatcherNonCapturingGroups() {
    stack_var integer x
    stack_var integer expectedGroupCount

    NAVLog("'***************** NAVRegexMatcher - Non-Capturing Groups *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_NON_CAPTURING_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_NON_CAPTURING_SHOULD_MATCH[x]
        expectedGroupCount = REGEX_MATCHER_NON_CAPTURING_EXPECTED_GROUP_COUNT[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_NON_CAPTURING_PATTERN[x], REGEX_MATCHER_NON_CAPTURING_INPUT[x], collection)

        if (shouldMatch) {
            // Verify it matched
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_NON_CAPTURING_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_NON_CAPTURING_INPUT[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_NON_CAPTURING_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, 'Correct match text', 'Wrong match text')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_NON_CAPTURING_PATTERN[x]")
                NAVLog("'  Input:    ', REGEX_MATCHER_NON_CAPTURING_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_NON_CAPTURING_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, 'Correct start position', 'Wrong start position')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_NON_CAPTURING_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify group count - NON-CAPTURING groups should NOT be counted
            if (!NAVAssertIntegerEqual('Group count should be correct', expectedGroupCount, collection.matches[1].groupCount)) {
                NAVLogTestFailed(x, 'Correct group count', 'Wrong group count')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_NON_CAPTURING_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify group 1 if present
            if (expectedGroupCount >= 1 && length_array(REGEX_MATCHER_NON_CAPTURING_EXPECTED_GROUP1[x]) > 0) {
                if (!NAVAssertStringEqual('Group 1 text should be correct', REGEX_MATCHER_NON_CAPTURING_EXPECTED_GROUP1[x], collection.matches[1].groups[1].text)) {
                    NAVLogTestFailed(x, 'Correct group 1 text', 'Wrong group 1 text')
                    NAVLog("'  Pattern:  ', REGEX_MATCHER_NON_CAPTURING_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }

            // Verify group 2 if present
            if (expectedGroupCount >= 2 && length_array(REGEX_MATCHER_NON_CAPTURING_EXPECTED_GROUP2[x]) > 0) {
                if (!NAVAssertStringEqual('Group 2 text should be correct', REGEX_MATCHER_NON_CAPTURING_EXPECTED_GROUP2[x], collection.matches[1].groups[2].text)) {
                    NAVLogTestFailed(x, 'Correct group 2 text', 'Wrong group 2 text')
                    NAVLog("'  Pattern:  ', REGEX_MATCHER_NON_CAPTURING_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }

            NAVLogTestPassed(x)
        } else {
            // Verify it didn't match
            if (!NAVAssertTrue('Should not match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match', 'Match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_NON_CAPTURING_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_NON_CAPTURING_INPUT[x]")
                NAVLog("'  Matched: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
