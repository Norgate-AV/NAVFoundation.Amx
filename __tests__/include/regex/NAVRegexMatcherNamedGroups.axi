PROGRAM_NAME='NAVRegexMatcherNamedGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for named group matching
constant char REGEX_MATCHER_NAMED_GROUPS_PATTERN[][255] = {
    '/(?P<letter>a)/',              // 1: Python-style named group
    '/(?<letter>a)/',               // 2: .NET-style named group
    '/(?''letter''a)/',               // 3: .NET alternative style named group
    '/(?P<word>\w+)/',              // 4: Python-style with quantifier
    '/(?<digits>\d+)/',             // 5: .NET-style with character class
    '/(?P<first>a)(?P<second>b)/',  // 6: Two Python-style named groups
    '/(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/',  // 7: Date with named groups
    '/(?<protocol>https?):\/\/(?<domain>\w+)\.(?<tld>\w+)/',  // 8: URL pattern
    '/(?P<outer>(?P<inner>a))/',    // 9: Nested Python-style named groups
    '/(?<user>\w+)@(?<host>\w+)/',  // 10: Email-like pattern
    '/(?P<first>\w+)\s+(?P<last>\w+)/',  // 11: Name pattern
    '/(a)(?P<named>b)(c)/',         // 12: Mix of unnamed and named groups
    '/(?<title>Mr|Ms|Mrs)\.?\s+(?<name>\w+)/',  // 13: Named groups with alternation
    '/(?P<tag><\w+>)/',             // 14: Named group with special chars
    '/(?<num>\d+)/',                // 15: Simple named number
    '/(?P<vowel>[aeiou])/',         // 16: Named character class
    '/(?<greeting>hello|hi)/',      // 17: Named alternation
    '/(?P<test>test)/',             // 18: Named word
    '/(?<a>a)(?<b>b)(?<c>c)/',      // 19: Three named groups
    '/(?<whole>(?<part1>a)(?<part2>b))/'  // 20: Nested named groups
}

constant char REGEX_MATCHER_NAMED_GROUPS_INPUT[][255] = {
    'a',                            // 1
    'a',                            // 2
    'a',                            // 3
    'hello',                        // 4
    '123',                          // 5
    'ab',                           // 6
    '2025-10-23',                   // 7
    'https://example.com',          // 8
    'a',                            // 9
    'user@example',                 // 10
    'John Smith',                   // 11
    'abc',                          // 12
    'Mr Jones',                     // 13
    '<div>',                        // 14
    '42',                           // 15
    'a',                            // 16
    'hello',                        // 17
    'testing',                      // 18
    'abc',                          // 19
    'ab'                            // 20
}

constant char REGEX_MATCHER_NAMED_GROUPS_EXPECTED_MATCH[][255] = {
    'a',                            // 1
    'a',                            // 2
    'a',                            // 3
    'hello',                        // 4
    '123',                          // 5
    'ab',                           // 6
    '2025-10-23',                   // 7
    'https://example.com',          // 8
    'a',                            // 9
    'user@example',                 // 10
    'John Smith',                   // 11
    'abc',                          // 12
    'Mr Jones',                     // 13
    '<div>',                        // 14
    '42',                           // 15
    'a',                            // 16
    'hello',                        // 17
    'test',                         // 18
    'abc',                          // 19
    'ab'                            // 20
}

constant integer REGEX_MATCHER_NAMED_GROUPS_EXPECTED_START[] = {
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

constant char REGEX_MATCHER_NAMED_GROUPS_SHOULD_MATCH[] = {
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

// Expected group count
constant integer REGEX_MATCHER_NAMED_GROUPS_EXPECTED_GROUP_COUNT[] = {
    1,                              // 1: One named group
    1,                              // 2: One named group
    1,                              // 3: One named group
    1,                              // 4: One named group
    1,                              // 5: One named group
    2,                              // 6: Two named groups
    3,                              // 7: Three named groups
    3,                              // 8: Three named groups
    2,                              // 9: Two nested named groups
    2,                              // 10: Two named groups
    2,                              // 11: Two named groups
    3,                              // 12: Three groups (1 unnamed, 1 named, 1 unnamed)
    2,                              // 13: Two named groups
    1,                              // 14: One named group
    1,                              // 15: One named group
    1,                              // 16: One named group
    1,                              // 17: One named group
    1,                              // 18: One named group
    3,                              // 19: Three named groups
    3                               // 20: Three named groups (nested)
}

// Expected name for group 1
constant char REGEX_MATCHER_NAMED_GROUPS_EXPECTED_NAME1[][50] = {
    'letter',                       // 1
    'letter',                       // 2
    'letter',                       // 3
    'word',                         // 4
    'digits',                       // 5
    'first',                        // 6
    'year',                         // 7
    'protocol',                     // 8
    'outer',                        // 9
    'user',                         // 10
    'first',                        // 11
    '',                             // 12: Unnamed group
    'title',                        // 13
    'tag',                          // 14
    'num',                          // 15
    'vowel',                        // 16
    'greeting',                     // 17
    'test',                         // 18
    'a',                            // 19
    'whole'                         // 20
}

// Expected text for group 1
constant char REGEX_MATCHER_NAMED_GROUPS_EXPECTED_GROUP1[][255] = {
    'a',                            // 1
    'a',                            // 2
    'a',                            // 3
    'hello',                        // 4
    '123',                          // 5
    'a',                            // 6
    '2025',                         // 7
    'https',                        // 8
    'a',                            // 9: Outer group
    'user',                         // 10
    'John',                         // 11
    'a',                            // 12: Unnamed
    'Mr',                           // 13
    '<div>',                        // 14
    '42',                           // 15
    'a',                            // 16
    'hello',                        // 17
    'test',                         // 18
    'a',                            // 19
    'ab'                            // 20: Outer group
}

// Expected name for group 2
constant char REGEX_MATCHER_NAMED_GROUPS_EXPECTED_NAME2[][50] = {
    '',                             // 1: No group 2
    '',                             // 2: No group 2
    '',                             // 3: No group 2
    '',                             // 4: No group 2
    '',                             // 5: No group 2
    'second',                       // 6
    'month',                        // 7
    'domain',                       // 8
    'inner',                        // 9: Inner named group
    'host',                         // 10
    'last',                         // 11
    'named',                        // 12: Named group
    'name',                         // 13
    '',                             // 14: No group 2
    '',                             // 15: No group 2
    '',                             // 16: No group 2
    '',                             // 17: No group 2
    '',                             // 18: No group 2
    'b',                            // 19
    'part1'                         // 20
}

// Expected text for group 2
constant char REGEX_MATCHER_NAMED_GROUPS_EXPECTED_GROUP2[][255] = {
    '',                             // 1: No group 2
    '',                             // 2: No group 2
    '',                             // 3: No group 2
    '',                             // 4: No group 2
    '',                             // 5: No group 2
    'b',                            // 6
    '10',                           // 7
    'example',                      // 8
    'a',                            // 9: Inner group
    'example',                      // 10
    'Smith',                        // 11
    'b',                            // 12
    'Jones',                        // 13
    '',                             // 14: No group 2
    '',                             // 15: No group 2
    '',                             // 16: No group 2
    '',                             // 17: No group 2
    '',                             // 18: No group 2
    'b',                            // 19
    'a'                             // 20
}

// Expected name for group 3
constant char REGEX_MATCHER_NAMED_GROUPS_EXPECTED_NAME3[][50] = {
    '',                             // 1: No group 3
    '',                             // 2: No group 3
    '',                             // 3: No group 3
    '',                             // 4: No group 3
    '',                             // 5: No group 3
    '',                             // 6: No group 3
    'day',                          // 7
    'tld',                          // 8
    '',                             // 9: No group 3
    '',                             // 10: No group 3
    '',                             // 11: No group 3
    '',                             // 12: Unnamed
    '',                             // 13: No group 3
    '',                             // 14: No group 3
    '',                             // 15: No group 3
    '',                             // 16: No group 3
    '',                             // 17: No group 3
    '',                             // 18: No group 3
    'c',                            // 19
    'part2'                         // 20
}

// Expected text for group 3
constant char REGEX_MATCHER_NAMED_GROUPS_EXPECTED_GROUP3[][255] = {
    '',                             // 1: No group 3
    '',                             // 2: No group 3
    '',                             // 3: No group 3
    '',                             // 4: No group 3
    '',                             // 5: No group 3
    '',                             // 6: No group 3
    '23',                           // 7
    'com',                          // 8
    '',                             // 9: No group 3
    '',                             // 10: No group 3
    '',                             // 11: No group 3
    'c',                            // 12: Unnamed
    '',                             // 13: No group 3
    '',                             // 14: No group 3
    '',                             // 15: No group 3
    '',                             // 16: No group 3
    '',                             // 17: No group 3
    '',                             // 18: No group 3
    'c',                            // 19
    'b'                             // 20
}


/**
 * @function TestNAVRegexMatcherNamedGroups
 * @public
 * @description Tests named capturing group functionality.
 *
 * Validates:
 * - Python-style named groups: (?P<name>...)
 * - .NET-style named groups: (?<name>...)
 * - .NET alternative style: (?'name'...)
 * - Named groups are counted like regular groups
 * - Group name field is populated correctly
 * - Group text extraction works for named groups
 * - Multiple named groups in one pattern
 * - Nested named groups
 * - Mixed named and unnamed groups
 */
define_function TestNAVRegexMatcherNamedGroups() {
    stack_var integer x
    stack_var integer expectedGroupCount

    NAVLog("'***************** NAVRegexMatcher - Named Groups *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_NAMED_GROUPS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_NAMED_GROUPS_SHOULD_MATCH[x]
        expectedGroupCount = REGEX_MATCHER_NAMED_GROUPS_EXPECTED_GROUP_COUNT[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_NAMED_GROUPS_PATTERN[x], REGEX_MATCHER_NAMED_GROUPS_INPUT[x], collection)

        if (shouldMatch) {
            // Verify it matched
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_NAMED_GROUPS_INPUT[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_NAMED_GROUPS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, 'Correct match text', 'Wrong match text')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
                NAVLog("'  Input:    ', REGEX_MATCHER_NAMED_GROUPS_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_NAMED_GROUPS_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, 'Correct start position', 'Wrong start position')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify group count
            if (!NAVAssertIntegerEqual('Group count should be correct', expectedGroupCount, collection.matches[1].groupCount)) {
                NAVLogTestFailed(x, 'Correct group count', 'Wrong group count')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify group 1 name and text
            if (expectedGroupCount >= 1) {
                // Verify group 1 name (if named)
                if (length_array(REGEX_MATCHER_NAMED_GROUPS_EXPECTED_NAME1[x]) > 0) {
                    if (!NAVAssertStringEqual('Group 1 name should be correct', REGEX_MATCHER_NAMED_GROUPS_EXPECTED_NAME1[x], collection.matches[1].groups[1].name)) {
                        NAVLogTestFailed(x, 'Correct group 1 name', 'Wrong group 1 name')
                        NAVLog("'  Pattern:  ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
                        NAVStopwatchStop()
                        continue
                    }
                }

                // Verify group 1 text
                if (!NAVAssertStringEqual('Group 1 text should be correct', REGEX_MATCHER_NAMED_GROUPS_EXPECTED_GROUP1[x], collection.matches[1].groups[1].text)) {
                    NAVLogTestFailed(x, 'Correct group 1 text', 'Wrong group 1 text')
                    NAVLog("'  Pattern:  ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }

            // Verify group 2 name and text if present
            if (expectedGroupCount >= 2) {
                // Verify group 2 name (if named)
                if (length_array(REGEX_MATCHER_NAMED_GROUPS_EXPECTED_NAME2[x]) > 0) {
                    if (!NAVAssertStringEqual('Group 2 name should be correct', REGEX_MATCHER_NAMED_GROUPS_EXPECTED_NAME2[x], collection.matches[1].groups[2].name)) {
                        NAVLogTestFailed(x, 'Correct group 2 name', 'Wrong group 2 name')
                        NAVLog("'  Pattern:  ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
                        NAVStopwatchStop()
                        continue
                    }
                }

                // Verify group 2 text
                if (length_array(REGEX_MATCHER_NAMED_GROUPS_EXPECTED_GROUP2[x]) > 0) {
                    if (!NAVAssertStringEqual('Group 2 text should be correct', REGEX_MATCHER_NAMED_GROUPS_EXPECTED_GROUP2[x], collection.matches[1].groups[2].text)) {
                        NAVLogTestFailed(x, 'Correct group 2 text', 'Wrong group 2 text')
                        NAVLog("'  Pattern:  ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
                        NAVStopwatchStop()
                        continue
                    }
                }
            }

            // Verify group 3 name and text if present
            if (expectedGroupCount >= 3) {
                // Verify group 3 name (if named)
                if (length_array(REGEX_MATCHER_NAMED_GROUPS_EXPECTED_NAME3[x]) > 0) {
                    if (!NAVAssertStringEqual('Group 3 name should be correct', REGEX_MATCHER_NAMED_GROUPS_EXPECTED_NAME3[x], collection.matches[1].groups[3].name)) {
                        NAVLogTestFailed(x, 'Correct group 3 name', 'Wrong group 3 name')
                        NAVLog("'  Pattern:  ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
                        NAVStopwatchStop()
                        continue
                    }
                }

                // Verify group 3 text
                if (length_array(REGEX_MATCHER_NAMED_GROUPS_EXPECTED_GROUP3[x]) > 0) {
                    if (!NAVAssertStringEqual('Group 3 text should be correct', REGEX_MATCHER_NAMED_GROUPS_EXPECTED_GROUP3[x], collection.matches[1].groups[3].text)) {
                        NAVLogTestFailed(x, 'Correct group 3 text', 'Wrong group 3 text')
                        NAVLog("'  Pattern:  ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
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
                NAVLog("'  Pattern: ', REGEX_MATCHER_NAMED_GROUPS_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_NAMED_GROUPS_INPUT[x]")
                NAVLog("'  Matched: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
