PROGRAM_NAME='NAVRegexNamedGroupHelpers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns with named groups
constant char REGEX_NAMED_GROUP_HELPERS_PATTERN[][255] = {
    '/(?<year>\d{4})-(?<month>\d{2})-(?<day>\d{2})/',           // 1: Date pattern with 3 named groups
    '/(?<protocol>https?):\/\/(?<domain>[\w.]+)/',               // 2: URL pattern with 2 named groups
    '/(?P<user>\w+)@(?P<host>\w+)\.(?P<tld>\w+)/',              // 3: Email pattern (Python-style)
    '/(?<first>\w+)\s+(?<last>\w+)/',                           // 4: Name pattern
    '/(?<tag><\w+>)(?<content>.*?)(?<closetag><\/\w+>)/',      // 5: HTML-like pattern
    '/(?<whole>(?<part1>\w+)-(?<part2>\w+))/',                  // 6: Nested named groups
    '/(a)(?<named>b)(c)/',                                      // 7: Mixed unnamed and named
    '/(?<optional>test)?(?<required>\w+)/',                     // 8: Optional named group
    '/(?<greeting>hello|hi)\s+(?<name>\w+)/',                   // 9: Alternation in named group
    '/(?<num>\d+)(?<unit>px|em|rem)?/',                         // 10: Optional unit group
    '/(?P<a>x)(?P<b>y)(?P<c>z)/',                               // 11: Three sequential named groups
    '/(?<outer>(?<inner1>a)(?<inner2>b))(?<sibling>c)/',       // 12: Complex nesting
    '/(?<key>\w+)=(?<value>[^&]+)/',                            // 13: Key-value pair
    '/(?<ip>\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/',             // 14: IP address
    '/(?''phone''\d{3}-\d{3}-\d{4})/',                          // 15: .NET alternative syntax
    '/(?<word>\w+)/',                                           // 16: Single named group (simple)
    '/(?P<start>^)(?P<content>.*)(?P<end>$)/',                  // 17: Named groups with anchors
    '/(?<digits>\d+)\.(?<decimals>\d+)/',                       // 18: Decimal number
    '/(?<before>\w+)(?<space>\s+)(?<after>\w+)/',               // 19: Whitespace captured
    '/(?<single>a)/'                                            // 20: Minimal named group
}

constant char REGEX_NAMED_GROUP_HELPERS_INPUT[][255] = {
    '2025-11-05',                   // 1
    'https://example.com',          // 2
    'user@domain.com',              // 3
    'John Smith',                   // 4
    '<div>content</div>',           // 5
    'foo-bar',                      // 6
    'abc',                          // 7
    'value',                        // 8: No 'test' prefix
    'hello Alice',                  // 9
    '16px',                         // 10
    'xyz',                          // 11
    'abc',                          // 12
    'key=value',                    // 13
    '192.168.1.1',                  // 14
    '555-123-4567',                 // 15
    'test',                         // 16
    'content',                      // 17
    '123.456',                      // 18
    'hello   world',                // 19
    'a'                             // 20
}

constant char REGEX_NAMED_GROUP_HELPERS_SHOULD_MATCH[] = {
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

// Expected results for GetNamedGroupFromMatch tests
constant char REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[][50] = {
    'year',                         // 1
    'protocol',                     // 2
    'user',                         // 3
    'first',                        // 4
    'tag',                          // 5
    'whole',                        // 6
    '',                             // 7: Unnamed
    'optional',                     // 8
    'greeting',                     // 9
    'num',                          // 10
    'a',                            // 11
    'outer',                        // 12
    'key',                          // 13
    'ip',                           // 14
    'phone',                        // 15
    'word',                         // 16
    'start',                        // 17
    'digits',                       // 18
    'before',                       // 19
    'single'                        // 20
}

constant char REGEX_NAMED_GROUP_HELPERS_GROUP1_TEXT[][255] = {
    '2025',                         // 1
    'https',                        // 2
    'user',                         // 3
    'John',                         // 4
    '<div>',                        // 5
    'foo-bar',                      // 6
    'a',                            // 7
    '',                             // 8: Not captured (optional)
    'hello',                        // 9
    '16',                           // 10
    'x',                            // 11
    'ab',                           // 12: outer captures 'ab', not 'abc' (sibling is separate)
    'key',                          // 13
    '192.168.1.1',                  // 14
    '555-123-4567',                 // 15
    'test',                         // 16
    '',                             // 17: Anchor (zero-width)
    '123',                          // 18
    'hello',                        // 19
    'a'                             // 20
}

constant char REGEX_NAMED_GROUP_HELPERS_GROUP2_NAME[][50] = {
    'month',                        // 1
    'domain',                       // 2
    'host',                         // 3
    'last',                         // 4
    'content',                      // 5
    'part1',                        // 6
    'named',                        // 7
    'required',                     // 8
    'name',                         // 9
    'unit',                         // 10
    'b',                            // 11
    'inner1',                       // 12
    'value',                        // 13
    '',                             // 14: No group 2
    '',                             // 15: No group 2
    '',                             // 16: No group 2
    'content',                      // 17
    'decimals',                     // 18
    'space',                        // 19
    ''                              // 20: No group 2
}

constant char REGEX_NAMED_GROUP_HELPERS_GROUP2_TEXT[][255] = {
    '11',                           // 1
    'example.com',                  // 2
    'domain',                       // 3
    'Smith',                        // 4
    'content',                      // 5
    'foo',                          // 6
    'b',                            // 7
    'value',                        // 8
    'Alice',                        // 9
    'px',                           // 10
    'y',                            // 11
    'a',                            // 12
    'value',                        // 13
    '',                             // 14
    '',                             // 15
    '',                             // 16
    'content',                      // 17
    '456',                          // 18
    '   ',                          // 19
    ''                              // 20
}

constant char REGEX_NAMED_GROUP_HELPERS_GROUP3_NAME[][50] = {
    'day',                          // 1
    '',                             // 2: No group 3
    'tld',                          // 3
    '',                             // 4: No group 3
    'closetag',                     // 5
    'part2',                        // 6
    '',                             // 7: Unnamed
    '',                             // 8: No group 3
    '',                             // 9: No group 3
    '',                             // 10: No group 3
    'c',                            // 11
    'inner2',                       // 12
    '',                             // 13: No group 3
    '',                             // 14: No group 3
    '',                             // 15: No group 3
    '',                             // 16: No group 3
    'end',                          // 17
    '',                             // 18: No group 3
    'after',                        // 19
    ''                              // 20: No group 3
}

constant char REGEX_NAMED_GROUP_HELPERS_GROUP3_TEXT[][255] = {
    '05',                           // 1
    '',                             // 2
    'com',                          // 3
    '',                             // 4
    '</div>',                       // 5
    'bar',                          // 6
    'c',                            // 7
    '',                             // 8
    '',                             // 9
    '',                             // 10
    'z',                            // 11
    'b',                            // 12
    '',                             // 13
    '',                             // 14
    '',                             // 15
    '',                             // 16
    '',                             // 17: Anchor (zero-width)
    '',                             // 18
    'world',                        // 19
    ''                              // 20
}

// Expected group counts
constant integer REGEX_NAMED_GROUP_HELPERS_GROUP_COUNT[] = {
    3,                              // 1: year, month, day
    2,                              // 2: protocol, domain
    3,                              // 3: user, host, tld
    2,                              // 4: first, last
    3,                              // 5: tag, content, closetag
    3,                              // 6: whole, part1, part2
    3,                              // 7: unnamed, named, unnamed
    2,                              // 8: optional, required
    2,                              // 9: greeting, name
    2,                              // 10: num, unit
    3,                              // 11: a, b, c
    4,                              // 12: outer, inner1, inner2, sibling
    2,                              // 13: key, value
    1,                              // 14: ip
    1,                              // 15: phone
    1,                              // 16: word
    3,                              // 17: start, content, end
    2,                              // 18: digits, decimals
    3,                              // 19: before, space, after
    1                               // 20: single
}

// Group 1 is captured?
constant char REGEX_NAMED_GROUP_HELPERS_GROUP1_CAPTURED[] = {
    true,                           // 1
    true,                           // 2
    true,                           // 3
    true,                           // 4
    true,                           // 5
    true,                           // 6
    true,                           // 7
    false,                          // 8: Optional not captured
    true,                           // 9
    true,                           // 10
    true,                           // 11
    true,                           // 12
    true,                           // 13
    true,                           // 14
    true,                           // 15
    true,                           // 16
    false,                          // 17: Zero-width anchor (^) not captured
    true,                           // 18
    true,                           // 19
    true                            // 20
}

// Group 2 is captured?
constant char REGEX_NAMED_GROUP_HELPERS_GROUP2_CAPTURED[] = {
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
    false,                          // 14: No group 2
    false,                          // 15: No group 2
    false,                          // 16: No group 2
    true,                           // 17
    true,                           // 18
    true,                           // 19
    false                           // 20: No group 2
}


/**
 * @function TestNAVRegexGetNamedGroupFromMatch
 * @public
 * @description Tests NAVRegexGetNamedGroupFromMatch() helper function.
 *
 * Validates:
 * - Retrieves correct named group from a single match
 * - Returns group with correct name and text
 * - Returns FALSE for non-existent group names
 * - Returns FALSE for uncaptured optional groups
 * - Works with Python-style (?P<name>...) syntax
 * - Works with .NET-style (?<name>...) syntax
 * - Works with .NET alternative (?'name'...) syntax
 * - Handles nested named groups correctly
 * - Handles mixed named/unnamed groups correctly
 */
define_function TestNAVRegexGetNamedGroupFromMatch() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - GetNamedGroupFromMatch *****************'")

    for (x = 1; x <= length_array(REGEX_NAMED_GROUP_HELPERS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var _NAVRegexGroup group
        stack_var char result
        stack_var char groupName[50]

        NAVStopwatchStart()

        // Execute match
        if (!NAVRegexMatch(REGEX_NAMED_GROUP_HELPERS_PATTERN[x], REGEX_NAMED_GROUP_HELPERS_INPUT[x], collection)) {
            NAVLogTestFailed(x, 'Pattern should compile and match', 'Failed to match')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_NAMED_GROUP_HELPERS_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Test retrieving group 1 by name (if it has a name)
        if (length_array(REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]) > 0) {
            groupName = REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]
            result = NAVRegexGetNamedGroupFromMatch(collection.matches[1], groupName, group)

            if (REGEX_NAMED_GROUP_HELPERS_GROUP1_CAPTURED[x]) {
                // Should find the group
                if (!NAVAssertTrue("'Should find named group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' found'", "'Group ''', groupName, ''' not found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }

                // Verify group name
                if (!NAVAssertStringEqual("'Group name should match'", groupName, group.name)) {
                    NAVLogTestFailed(x, "'Group name ''', groupName, ''''", "'Group name ''', group.name, ''''")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }

                // Verify group text
                if (!NAVAssertStringEqual("'Group text should match'", REGEX_NAMED_GROUP_HELPERS_GROUP1_TEXT[x], group.text)) {
                    NAVLogTestFailed(x, "'Group text ''', REGEX_NAMED_GROUP_HELPERS_GROUP1_TEXT[x], ''''", "'Group text ''', group.text, ''''")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            } else {
                // Should NOT find the group (optional, not captured)
                if (!NAVAssertFalse("'Should not find uncaptured group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' not found (uncaptured)'", "'Group ''', groupName, ''' found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }
        }

        // Test retrieving group 2 by name (if it has a name)
        if (length_array(REGEX_NAMED_GROUP_HELPERS_GROUP2_NAME[x]) > 0) {
            groupName = REGEX_NAMED_GROUP_HELPERS_GROUP2_NAME[x]
            result = NAVRegexGetNamedGroupFromMatch(collection.matches[1], groupName, group)

            if (REGEX_NAMED_GROUP_HELPERS_GROUP2_CAPTURED[x]) {
                if (!NAVAssertTrue("'Should find named group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' found'", "'Group ''', groupName, ''' not found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }

                if (!NAVAssertStringEqual("'Group text should match'", REGEX_NAMED_GROUP_HELPERS_GROUP2_TEXT[x], group.text)) {
                    NAVLogTestFailed(x, "'Group text ''', REGEX_NAMED_GROUP_HELPERS_GROUP2_TEXT[x], ''''", "'Group text ''', group.text, ''''")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }
        }

        // Test retrieving group 3 by name (if it has a name)
        if (length_array(REGEX_NAMED_GROUP_HELPERS_GROUP3_NAME[x]) > 0) {
            groupName = REGEX_NAMED_GROUP_HELPERS_GROUP3_NAME[x]
            result = NAVRegexGetNamedGroupFromMatch(collection.matches[1], groupName, group)

            // Check if group 3 is expected to be captured
            // Zero-width assertions (anchors) are not captured even though they have names
            // Pattern 17 has zero-width $ anchor for 'end' group
            if (x == 17) {
                // This is a zero-width anchor, should NOT be captured
                if (!NAVAssertFalse("'Should not find zero-width anchor ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' not found (zero-width)'", "'Group ''', groupName, ''' found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            } else {
                // Normal captured group
                if (!NAVAssertTrue("'Should find named group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' found'", "'Group ''', groupName, ''' not found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }

                if (!NAVAssertStringEqual("'Group text should match'", REGEX_NAMED_GROUP_HELPERS_GROUP3_TEXT[x], group.text)) {
                    NAVLogTestFailed(x, "'Group text ''', REGEX_NAMED_GROUP_HELPERS_GROUP3_TEXT[x], ''''", "'Group text ''', group.text, ''''")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }
        }

        // Test retrieving non-existent group name
        result = NAVRegexGetNamedGroupFromMatch(collection.matches[1], 'nonexistent', group)
        if (!NAVAssertFalse('Should return FALSE for non-existent group', result)) {
            NAVLogTestFailed(x, 'FALSE for non-existent group', 'TRUE')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}


/**
 * @function TestNAVRegexGetNamedGroupFromMatchCollection
 * @public
 * @description Tests NAVRegexGetNamedGroupFromMatchCollection() helper function.
 *
 * Validates:
 * - Retrieves correct named group from first match in collection
 * - Returns group with correct name and text
 * - Returns FALSE for non-existent group names
 * - Works with all named group syntax styles
 */
define_function TestNAVRegexGetNamedGroupFromMatchCollection() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - GetNamedGroupFromMatchCollection *****************'")

    for (x = 1; x <= length_array(REGEX_NAMED_GROUP_HELPERS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var _NAVRegexGroup group
        stack_var char result
        stack_var char groupName[50]

        NAVStopwatchStart()

        // Execute match
        if (!NAVRegexMatch(REGEX_NAMED_GROUP_HELPERS_PATTERN[x], REGEX_NAMED_GROUP_HELPERS_INPUT[x], collection)) {
            NAVLogTestFailed(x, 'Pattern should compile and match', 'Failed to match')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_NAMED_GROUP_HELPERS_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Test retrieving group 1 by name from collection (if it has a name)
        if (length_array(REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]) > 0) {
            groupName = REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]
            result = NAVRegexGetNamedGroupFromMatchCollection(collection, groupName, group)

            if (REGEX_NAMED_GROUP_HELPERS_GROUP1_CAPTURED[x]) {
                if (!NAVAssertTrue("'Should find named group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' found'", "'Group ''', groupName, ''' not found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }

                if (!NAVAssertStringEqual("'Group name should match'", groupName, group.name)) {
                    NAVLogTestFailed(x, "'Group name ''', groupName, ''''", "'Group name ''', group.name, ''''")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }

                if (!NAVAssertStringEqual("'Group text should match'", REGEX_NAMED_GROUP_HELPERS_GROUP1_TEXT[x], group.text)) {
                    NAVLogTestFailed(x, "'Group text ''', REGEX_NAMED_GROUP_HELPERS_GROUP1_TEXT[x], ''''", "'Group text ''', group.text, ''''")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            } else {
                if (!NAVAssertFalse("'Should not find uncaptured group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' not found (uncaptured)'", "'Group ''', groupName, ''' found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }
        }

        // Test non-existent group name
        result = NAVRegexGetNamedGroupFromMatchCollection(collection, 'nonexistent', group)
        if (!NAVAssertFalse('Should return FALSE for non-existent group', result)) {
            NAVLogTestFailed(x, 'FALSE for non-existent group', 'TRUE')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}


/**
 * @function TestNAVRegexGetNamedGroupTextFromMatch
 * @public
 * @description Tests NAVRegexGetNamedGroupTextFromMatch() helper function.
 *
 * Validates:
 * - Retrieves correct text for named group from single match
 * - Returns TRUE and text for captured groups
 * - Returns FALSE for non-existent or uncaptured groups
 * - Works with all syntax styles
 */
define_function TestNAVRegexGetNamedGroupTextFromMatch() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - GetNamedGroupTextFromMatch *****************'")

    for (x = 1; x <= length_array(REGEX_NAMED_GROUP_HELPERS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char groupText[NAV_MAX_BUFFER]
        stack_var char result
        stack_var char groupName[50]

        NAVStopwatchStart()

        // Execute match
        if (!NAVRegexMatch(REGEX_NAMED_GROUP_HELPERS_PATTERN[x], REGEX_NAMED_GROUP_HELPERS_INPUT[x], collection)) {
            NAVLogTestFailed(x, 'Pattern should compile and match', 'Failed to match')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_NAMED_GROUP_HELPERS_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Test retrieving group 1 text by name (if it has a name)
        if (length_array(REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]) > 0) {
            groupName = REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]
            result = NAVRegexGetNamedGroupTextFromMatch(collection.matches[1], groupName, groupText)

            if (REGEX_NAMED_GROUP_HELPERS_GROUP1_CAPTURED[x]) {
                if (!NAVAssertTrue("'Should find named group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' found'", "'Group ''', groupName, ''' not found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }

                if (!NAVAssertStringEqual("'Group text should match'", REGEX_NAMED_GROUP_HELPERS_GROUP1_TEXT[x], groupText)) {
                    NAVLogTestFailed(x, "'Text ''', REGEX_NAMED_GROUP_HELPERS_GROUP1_TEXT[x], ''''", "'Text ''', groupText, ''''")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            } else {
                if (!NAVAssertFalse("'Should not find uncaptured group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' not found (uncaptured)'", "'Group ''', groupName, ''' found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }
        }

        // Test retrieving group 2 text by name (if it has a name and is captured)
        if (length_array(REGEX_NAMED_GROUP_HELPERS_GROUP2_NAME[x]) > 0 && REGEX_NAMED_GROUP_HELPERS_GROUP2_CAPTURED[x]) {
            groupName = REGEX_NAMED_GROUP_HELPERS_GROUP2_NAME[x]
            result = NAVRegexGetNamedGroupTextFromMatch(collection.matches[1], groupName, groupText)

            if (!NAVAssertTrue("'Should find named group ''', groupName, ''''", result)) {
                NAVLogTestFailed(x, "'Group ''', groupName, ''' found'", "'Group ''', groupName, ''' not found'")
                NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            if (!NAVAssertStringEqual("'Group text should match'", REGEX_NAMED_GROUP_HELPERS_GROUP2_TEXT[x], groupText)) {
                NAVLogTestFailed(x, "'Text ''', REGEX_NAMED_GROUP_HELPERS_GROUP2_TEXT[x], ''''", "'Text ''', groupText, ''''")
                NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }
        }

        // Test non-existent group
        result = NAVRegexGetNamedGroupTextFromMatch(collection.matches[1], 'nonexistent', groupText)
        if (!NAVAssertFalse('Should return FALSE for non-existent group', result)) {
            NAVLogTestFailed(x, 'FALSE for non-existent group', 'TRUE')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}


/**
 * @function TestNAVRegexGetNamedGroupTextFromMatchCollection
 * @public
 * @description Tests NAVRegexGetNamedGroupTextFromMatchCollection() helper function.
 *
 * Validates:
 * - Retrieves correct text for named group from collection
 * - Returns TRUE and text for captured groups
 * - Returns FALSE for non-existent or uncaptured groups
 */
define_function TestNAVRegexGetNamedGroupTextFromMatchCollection() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - GetNamedGroupTextFromMatchCollection *****************'")

    for (x = 1; x <= length_array(REGEX_NAMED_GROUP_HELPERS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char groupText[NAV_MAX_BUFFER]
        stack_var char result
        stack_var char groupName[50]

        NAVStopwatchStart()

        // Execute match
        if (!NAVRegexMatch(REGEX_NAMED_GROUP_HELPERS_PATTERN[x], REGEX_NAMED_GROUP_HELPERS_INPUT[x], collection)) {
            NAVLogTestFailed(x, 'Pattern should compile and match', 'Failed to match')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_NAMED_GROUP_HELPERS_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Test retrieving group 1 text by name (if it has a name)
        if (length_array(REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]) > 0) {
            groupName = REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]
            result = NAVRegexGetNamedGroupTextFromMatchCollection(collection, groupName, groupText)

            if (REGEX_NAMED_GROUP_HELPERS_GROUP1_CAPTURED[x]) {
                if (!NAVAssertTrue("'Should find named group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' found'", "'Group ''', groupName, ''' not found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }

                if (!NAVAssertStringEqual("'Group text should match'", REGEX_NAMED_GROUP_HELPERS_GROUP1_TEXT[x], groupText)) {
                    NAVLogTestFailed(x, "'Text ''', REGEX_NAMED_GROUP_HELPERS_GROUP1_TEXT[x], ''''", "'Text ''', groupText, ''''")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            } else {
                if (!NAVAssertFalse("'Should not find uncaptured group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'Group ''', groupName, ''' not found (uncaptured)'", "'Group ''', groupName, ''' found'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }
        }

        // Test non-existent group
        result = NAVRegexGetNamedGroupTextFromMatchCollection(collection, 'nonexistent', groupText)
        if (!NAVAssertFalse('Should return FALSE for non-existent group', result)) {
            NAVLogTestFailed(x, 'FALSE for non-existent group', 'TRUE')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}


/**
 * @function TestNAVRegexHasNamedGroupInMatch
 * @public
 * @description Tests NAVRegexHasNamedGroupInMatch() helper function.
 *
 * Validates:
 * - Returns TRUE when named group exists and is captured
 * - Returns FALSE when named group doesn't exist
 * - Returns FALSE when named group exists but is not captured (optional)
 * - Works with all syntax styles
 */
define_function TestNAVRegexHasNamedGroupInMatch() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - HasNamedGroupInMatch *****************'")

    for (x = 1; x <= length_array(REGEX_NAMED_GROUP_HELPERS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char result
        stack_var char groupName[50]

        NAVStopwatchStart()

        // Execute match
        if (!NAVRegexMatch(REGEX_NAMED_GROUP_HELPERS_PATTERN[x], REGEX_NAMED_GROUP_HELPERS_INPUT[x], collection)) {
            NAVLogTestFailed(x, 'Pattern should compile and match', 'Failed to match')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_NAMED_GROUP_HELPERS_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Test checking group 1 existence (if it has a name)
        if (length_array(REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]) > 0) {
            groupName = REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]
            result = NAVRegexHasNamedGroupInMatch(collection.matches[1], groupName)

            if (REGEX_NAMED_GROUP_HELPERS_GROUP1_CAPTURED[x]) {
                if (!NAVAssertTrue("'Should return TRUE for existing group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'TRUE for ''', groupName, ''''", "'FALSE'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            } else {
                if (!NAVAssertFalse("'Should return FALSE for uncaptured group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'FALSE for uncaptured ''', groupName, ''''", "'TRUE'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }
        }

        // Test checking group 2 existence (if it has a name)
        if (length_array(REGEX_NAMED_GROUP_HELPERS_GROUP2_NAME[x]) > 0) {
            groupName = REGEX_NAMED_GROUP_HELPERS_GROUP2_NAME[x]
            result = NAVRegexHasNamedGroupInMatch(collection.matches[1], groupName)

            if (REGEX_NAMED_GROUP_HELPERS_GROUP2_CAPTURED[x]) {
                if (!NAVAssertTrue("'Should return TRUE for existing group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'TRUE for ''', groupName, ''''", "'FALSE'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }
        }

        // Test non-existent group
        result = NAVRegexHasNamedGroupInMatch(collection.matches[1], 'nonexistent')
        if (!NAVAssertFalse('Should return FALSE for non-existent group', result)) {
            NAVLogTestFailed(x, 'FALSE for non-existent group', 'TRUE')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}


/**
 * @function TestNAVRegexHasNamedGroupInMatchCollection
 * @public
 * @description Tests NAVRegexHasNamedGroupInMatchCollection() helper function.
 *
 * Validates:
 * - Returns TRUE when named group exists in collection
 * - Returns FALSE when named group doesn't exist
 * - Returns FALSE when named group exists but is not captured
 */
define_function TestNAVRegexHasNamedGroupInMatchCollection() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - HasNamedGroupInMatchCollection *****************'")

    for (x = 1; x <= length_array(REGEX_NAMED_GROUP_HELPERS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char result
        stack_var char groupName[50]

        NAVStopwatchStart()

        // Execute match
        if (!NAVRegexMatch(REGEX_NAMED_GROUP_HELPERS_PATTERN[x], REGEX_NAMED_GROUP_HELPERS_INPUT[x], collection)) {
            NAVLogTestFailed(x, 'Pattern should compile and match', 'Failed to match')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_NAMED_GROUP_HELPERS_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Test checking group 1 existence (if it has a name)
        if (length_array(REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]) > 0) {
            groupName = REGEX_NAMED_GROUP_HELPERS_GROUP1_NAME[x]
            result = NAVRegexHasNamedGroupInMatchCollection(collection, groupName)

            if (REGEX_NAMED_GROUP_HELPERS_GROUP1_CAPTURED[x]) {
                if (!NAVAssertTrue("'Should return TRUE for existing group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'TRUE for ''', groupName, ''''", "'FALSE'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            } else {
                if (!NAVAssertFalse("'Should return FALSE for uncaptured group ''', groupName, ''''", result)) {
                    NAVLogTestFailed(x, "'FALSE for uncaptured ''', groupName, ''''", "'TRUE'")
                    NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
                    NAVStopwatchStop()
                    continue
                }
            }
        }

        // Test non-existent group
        result = NAVRegexHasNamedGroupInMatchCollection(collection, 'nonexistent')
        if (!NAVAssertFalse('Should return FALSE for non-existent group', result)) {
            NAVLogTestFailed(x, 'FALSE for non-existent group', 'TRUE')
            NAVLog("'  Pattern: ', REGEX_NAMED_GROUP_HELPERS_PATTERN[x]")
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
