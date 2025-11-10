PROGRAM_NAME='NAVRegexMatcherGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for group capture matching
constant char REGEX_MATCHER_CAPTURE_PATTERN[][255] = {
    '/(a)/',                        // 1: Single group, single char
    '/(abc)/',                      // 2: Single group, multi char
    '/(\d+)/',                      // 3: Single group with quantifier
    '/(a)(b)/',                     // 4: Two groups
    '/(a)(b)(c)/',                  // 5: Three groups
    '/(\d+)-(\d+)/',                // 6: Two groups with separator
    '/(\d+)-(\d+)-(\d+)/',          // 7: Three groups (date pattern)
    '/(\w+)@(\w+)\.(\w+)/',         // 8: Email-like pattern (3 groups)
    '/((a))/',                      // 9: Nested groups
    '/((a)(b))/',                   // 10: Nested with siblings
    '/(a)|(b)/',                    // 11: Alternation - first alt matches
    '/(a)|(b)/',                    // 12: Alternation - second alt matches
    '/(x)?/',                       // 13: Optional group - present
    '/(x)?/',                       // 14: Optional group - absent
    '/(\d+)?(\w+)/',                // 15: Optional group followed by required
    '/(a+)/',                       // 16: Group with greedy quantifier
    '/(a+?)/',                      // 17: Group with lazy quantifier
    '/^(\w+)\s+(\w+)$/',            // 18: Two groups with anchors
    '/([a-z]+)([0-9]+)/',           // 19: Letter group, digit group
    '/(test)/'                      // 20: Word group
}

constant char REGEX_MATCHER_CAPTURE_INPUT[][255] = {
    'a',                            // 1: Single char
    'abc',                          // 2: Multi char
    '123',                          // 3: Digits
    'ab',                           // 4: Two chars
    'abc',                          // 5: Three chars
    '2025-10',                      // 6: Year-month
    '2025-10-23',                   // 7: Full date
    'user@example.com',             // 8: Email
    'a',                            // 9: Single char for nested
    'ab',                           // 10: Two chars for nested
    'a',                            // 11: Matches first alternative
    'b',                            // 12: Matches second alternative
    'x',                            // 13: Optional present
    'y',                            // 14: Optional absent (matches empty)
    'abc',                          // 15: No digits, just word
    'aaa',                          // 16: Multiple 'a' for greedy
    'aaa',                          // 17: Multiple 'a' for lazy
    'hello world',                  // 18: Two words
    'test123',                      // 19: Letters and digits
    'testing'                       // 20: Contains "test"
}

constant char REGEX_MATCHER_CAPTURE_EXPECTED_MATCH[][255] = {
    'a',                            // 1
    'abc',                          // 2
    '123',                          // 3
    'ab',                           // 4
    'abc',                          // 5
    '2025-10',                      // 6
    '2025-10-23',                   // 7
    'user@example.com',             // 8
    'a',                            // 9
    'ab',                           // 10
    'a',                            // 11
    'b',                            // 12
    'x',                            // 13
    '',                             // 14: Empty match (optional absent)
    'abc',                          // 15
    'aaa',                          // 16
    'a',                            // 17: Lazy - minimal match
    'hello world',                  // 18
    'test123',                      // 19
    'test'                          // 20
}

constant integer REGEX_MATCHER_CAPTURE_EXPECTED_START[] = {
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

constant char REGEX_MATCHER_CAPTURE_SHOULD_MATCH[] = {
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

// Expected group count for each test
constant integer REGEX_MATCHER_CAPTURE_EXPECTED_GROUP_COUNT[] = {
    1,                              // 1: One group
    1,                              // 2: One group
    1,                              // 3: One group
    2,                              // 4: Two groups
    3,                              // 5: Three groups
    2,                              // 6: Two groups
    3,                              // 7: Three groups
    3,                              // 8: Three groups
    2,                              // 9: Two groups (nested)
    3,                              // 10: Three groups (nested with siblings)
    2,                              // 11: Two groups (alternation)
    2,                              // 12: Two groups (alternation)
    1,                              // 13: One group
    1,                              // 14: One group
    2,                              // 15: Two groups
    1,                              // 16: One group
    1,                              // 17: One group
    2,                              // 18: Two groups
    2,                              // 19: Two groups
    1                               // 20: One group
}

// Expected text for group 1
constant char REGEX_MATCHER_CAPTURE_EXPECTED_GROUP1[][255] = {
    'a',                            // 1
    'abc',                          // 2
    '123',                          // 3
    'a',                            // 4
    'a',                            // 5
    '2025',                         // 6
    '2025',                         // 7
    'user',                         // 8
    'a',                            // 9: Outer group
    'ab',                           // 10: Outer group
    'a',                            // 11: First alternative captured
    '',                             // 12: First alternative not captured
    'x',                            // 13
    '',                             // 14: Optional not captured
    '',                             // 15: Optional digits not present
    'aaa',                          // 16
    'a',                            // 17: Lazy
    'hello',                        // 18
    'test',                         // 19
    'test'                          // 20
}

// Expected text for group 2 (where applicable)
constant char REGEX_MATCHER_CAPTURE_EXPECTED_GROUP2[][255] = {
    '',                             // 1: No group 2
    '',                             // 2: No group 2
    '',                             // 3: No group 2
    'b',                            // 4
    'b',                            // 5
    '10',                           // 6
    '10',                           // 7
    'example',                      // 8
    'a',                            // 9: Inner group
    'a',                            // 10: First nested
    '',                             // 11: Second alternative not captured
    'b',                            // 12: Second alternative captured
    '',                             // 13: No group 2
    '',                             // 14: No group 2
    'abc',                          // 15
    '',                             // 16: No group 2
    '',                             // 17: No group 2
    'world',                        // 18
    '123',                          // 19
    ''                              // 20: No group 2
}

// Expected text for group 3 (where applicable)
constant char REGEX_MATCHER_CAPTURE_EXPECTED_GROUP3[][255] = {
    '',                             // 1: No group 3
    '',                             // 2: No group 3
    '',                             // 3: No group 3
    '',                             // 4: No group 3
    'c',                            // 5
    '',                             // 6: No group 3
    '23',                           // 7
    'com',                          // 8
    '',                             // 9: No group 3
    'b',                            // 10: Second nested
    '',                             // 11: No group 3
    '',                             // 12: No group 3
    '',                             // 13: No group 3
    '',                             // 14: No group 3
    '',                             // 15: No group 3
    '',                             // 16: No group 3
    '',                             // 17: No group 3
    '',                             // 18: No group 3
    '',                             // 19: No group 3
    ''                              // 20: No group 3
}

// Which groups should be captured (for alternation/optional tests)
constant char REGEX_MATCHER_CAPTURE_GROUP1_CAPTURED[] = {
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
    true,                           // 11: First alt captured
    false,                          // 12: First alt not captured
    true,                           // 13
    false,                          // 14: Optional not present
    false,                          // 15: Optional not present
    true,                           // 16
    true,                           // 17
    true,                           // 18
    true,                           // 19
    true                            // 20
}

constant char REGEX_MATCHER_CAPTURE_GROUP2_CAPTURED[] = {
    false,                          // 1
    false,                          // 2
    false,                          // 3
    true,                           // 4
    true,                           // 5
    true,                           // 6
    true,                           // 7
    true,                           // 8
    true,                           // 9
    true,                           // 10
    false,                          // 11: Second alt not captured
    true,                           // 12: Second alt captured
    false,                          // 13
    false,                          // 14
    true,                           // 15
    false,                          // 16
    false,                          // 17
    true,                           // 18
    true,                           // 19
    false                           // 20
}


/**
 * @function TestNAVRegexMatcherGroups
 * @public
 * @description Tests capturing group functionality.
 *
 * Validates:
 * - Single capturing groups
 * - Multiple capturing groups
 * - Nested capturing groups
 * - Groups with quantifiers
 * - Optional groups (may not participate)
 * - Alternation (only one branch captures)
 * - Group numbering and text extraction
 * - isCaptured flag for non-participating groups
 */
define_function TestNAVRegexMatcherGroups() {
    stack_var integer x
    stack_var integer expectedGroupCount

    NAVLog("'***************** NAVRegexMatcher - Group Captures *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_CAPTURE_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_CAPTURE_SHOULD_MATCH[x]
        expectedGroupCount = REGEX_MATCHER_CAPTURE_EXPECTED_GROUP_COUNT[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_CAPTURE_PATTERN[x], REGEX_MATCHER_CAPTURE_INPUT[x], collection)

        if (shouldMatch) {
            // Verify it matched
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_CAPTURE_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_CAPTURE_INPUT[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_CAPTURE_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, 'Correct match text', 'Wrong match text')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_CAPTURE_PATTERN[x]")
                NAVLog("'  Input:    ', REGEX_MATCHER_CAPTURE_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_CAPTURE_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, 'Correct start position', 'Wrong start position')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_CAPTURE_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify group count
            if (!NAVAssertIntegerEqual('Group count should be correct', expectedGroupCount, collection.matches[1].groupCount)) {
                NAVLogTestFailed(x, 'Correct group count', 'Wrong group count')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_CAPTURE_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify group 1 capture status
            if (expectedGroupCount >= 1) {
                if (!NAVAssertTrue('Group 1 captured status should be correct', collection.matches[1].groups[1].isCaptured == REGEX_MATCHER_CAPTURE_GROUP1_CAPTURED[x])) {
                    NAVLogTestFailed(x, 'Group 1 captured status', 'Wrong status')
                    NAVLog("'  Pattern:  ', REGEX_MATCHER_CAPTURE_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }

                // Only verify text if group was captured
                if (REGEX_MATCHER_CAPTURE_GROUP1_CAPTURED[x]) {
                    if (!NAVAssertStringEqual('Group 1 text should be correct', REGEX_MATCHER_CAPTURE_EXPECTED_GROUP1[x], collection.matches[1].groups[1].text)) {
                        NAVLogTestFailed(x, 'Correct group 1 text', 'Wrong group 1 text')
                        NAVLog("'  Pattern:  ', REGEX_MATCHER_CAPTURE_PATTERN[x]")
                        NAVStopwatchStop()
                        continue
                    }
                }
            }

            // Verify group 2 if present
            if (expectedGroupCount >= 2) {
                if (!NAVAssertTrue('Group 2 captured status should be correct', collection.matches[1].groups[2].isCaptured == REGEX_MATCHER_CAPTURE_GROUP2_CAPTURED[x])) {
                    NAVLogTestFailed(x, 'Group 2 captured status', 'Wrong status')
                    NAVLog("'  Pattern:  ', REGEX_MATCHER_CAPTURE_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }

                // Only verify text if group was captured
                if (REGEX_MATCHER_CAPTURE_GROUP2_CAPTURED[x]) {
                    if (!NAVAssertStringEqual('Group 2 text should be correct', REGEX_MATCHER_CAPTURE_EXPECTED_GROUP2[x], collection.matches[1].groups[2].text)) {
                        NAVLogTestFailed(x, 'Correct group 2 text', 'Wrong group 2 text')
                        NAVLog("'  Pattern:  ', REGEX_MATCHER_CAPTURE_PATTERN[x]")
                        NAVStopwatchStop()
                        continue
                    }
                }
            }

            // Verify group 3 if present
            if (expectedGroupCount >= 3) {
                if (length_array(REGEX_MATCHER_CAPTURE_EXPECTED_GROUP3[x]) > 0) {
                    if (!NAVAssertStringEqual('Group 3 text should be correct', REGEX_MATCHER_CAPTURE_EXPECTED_GROUP3[x], collection.matches[1].groups[3].text)) {
                        NAVLogTestFailed(x, 'Correct group 3 text', 'Wrong group 3 text')
                        NAVLog("'  Pattern:  ', REGEX_MATCHER_CAPTURE_PATTERN[x]")
                        NAVStopwatchStop()
                        continue
                    }
                }
            }

            NAVLogTestPassed(x)
        } else {
            // Verify it didn't match
            if (!NAVAssertTrue('Should not match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match', 'Match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_CAPTURE_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_CAPTURE_INPUT[x]")
                NAVLog("'  Matched: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
