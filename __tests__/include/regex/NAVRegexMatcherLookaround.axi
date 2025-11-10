PROGRAM_NAME='NAVRegexMatcherLookaround'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for lookaround assertion matching
constant char REGEX_MATCHER_LOOKAROUND_PATTERN[][255] = {
    // Positive lookahead (?=...)
    '/a(?=b)/',                         // 1: Match 'a' followed by 'b'
    '/\d(?=px)/',                       // 2: Match digit followed by 'px'
    '/\w+(?=@)/',                       // 3: Match word before '@'
    '/test(?=ing)/',                    // 4: Match 'test' before 'ing'

    // Negative lookahead (?!...)
    '/a(?!b)/',                         // 5: Match 'a' NOT followed by 'b'
    '/\d(?!px)/',                       // 6: Match digit NOT followed by 'px'
    '/\w+(?!@)/',                       // 7: Match word NOT before '@'
    '/test(?!ing)/',                    // 8: Match 'test' NOT before 'ing'

    // Positive lookbehind (?<=...)
    '/(?<=@)\w+/',                      // 9: Match word after '@'
    '/(?<=\$)\d+/',                     // 10: Match digits after '$'
    '/(?<=Mr )\w+/',                    // 11: Match name after 'Mr '
    '/(?<=https:\/\/)\w+/',             // 12: Match domain after 'https://'

    // Negative lookbehind (?<!...)
    '/(?<!@)\w+/',                      // 13: Match word NOT after '@'
    '/(?<!\$)\d+/',                     // 14: Match digits NOT after '$'
    '/(?<!Mr )\w+/',                    // 15: Match word NOT after 'Mr '
    '/(?<!https:\/\/)\w+/',             // 16: Match word NOT after 'https://'

    // Combined lookarounds
    '/(?<=\$)\d+(?=\.00)/',             // 17: Dollars with .00
    '/(?<=<)\w+(?=>)/',                 // 18: Tag name between < and >
    '/\b\w+(?=ing\b)/',                 // 19: Word stem before 'ing' at word end
    '/(?<=\bMr )\w+(?= Smith)/'         // 20: First name between 'Mr ' and ' Smith'
}

constant char REGEX_MATCHER_LOOKAROUND_INPUT[][255] = {
    'ab',                               // 1: 'a' followed by 'b'
    '12px',                             // 2: Digit followed by 'px'
    'user@example',                     // 3: Word before '@'
    'testing',                          // 4: 'test' before 'ing'
    'ac',                               // 5: 'a' NOT followed by 'b'
    '12em',                             // 6: Digit NOT followed by 'px'
    'user',                             // 7: Word NOT before '@'
    'tester',                           // 8: 'test' NOT before 'ing'
    '@user',                            // 9: Word after '@'
    '$100',                             // 10: Digits after '$'
    'Mr Jones',                         // 11: Name after 'Mr '
    'https://example',                  // 12: Domain after 'https://'
    'user',                             // 13: Word NOT after '@'
    '100',                              // 14: Digits NOT after '$'
    'Jones',                            // 15: Word NOT after 'Mr '
    'example',                          // 16: Word NOT after 'https://'
    '$50.00',                           // 17: Dollars with .00
    '<div>',                            // 18: Tag name
    'testing',                          // 19: Word ending in 'ing'
    'Mr John Smith'                     // 20: Name between 'Mr ' and ' Smith'
}

constant char REGEX_MATCHER_LOOKAROUND_EXPECTED_MATCH[][255] = {
    'a',                                // 1: Just 'a' (lookahead not captured)
    '2',                                // 2: Just digit (the '2' that's followed by 'px')
    'user',                             // 3: Word before '@'
    'test',                             // 4: 'test' without 'ing'
    'a',                                // 5: 'a' not followed by 'b'
    '1',                                // 6: Digit not followed by 'px'
    'user',                             // 7: Word not before '@'
    'test',                             // 8: 'test' not before 'ing'
    'user',                             // 9: Word after '@'
    '100',                              // 10: Digits after '$'
    'Jones',                            // 11: Name after 'Mr '
    'example',                          // 12: Domain after 'https://'
    'user',                             // 13: Word not after '@'
    '100',                              // 14: Digits not after '$'
    'Jones',                            // 15: Word not after 'Mr '
    'example',                          // 16: Word not after 'https://'
    '50',                               // 17: Just the dollars amount
    'div',                              // 18: Just tag name
    'test',                             // 19: 'test' before 'ing'
    'John'                              // 20: First name
}

constant integer REGEX_MATCHER_LOOKAROUND_EXPECTED_START[] = {
    1,                                  // 1
    2,                                  // 2: Starts at position 2 (the '2' in '12px')
    1,                                  // 3
    1,                                  // 4
    1,                                  // 5
    1,                                  // 6
    1,                                  // 7
    1,                                  // 8
    2,                                  // 9: After '@'
    2,                                  // 10: After '$'
    4,                                  // 11: After 'Mr '
    9,                                  // 12: After 'https://'
    1,                                  // 13
    1,                                  // 14
    1,                                  // 15
    1,                                  // 16
    2,                                  // 17: After '$'
    2,                                  // 18: After '<'
    1,                                  // 19
    4                                   // 20: After 'Mr '
}

constant char REGEX_MATCHER_LOOKAROUND_SHOULD_MATCH[] = {
    true,                               // 1
    true,                               // 2
    true,                               // 3
    true,                               // 4
    true,                               // 5
    true,                               // 6
    true,                               // 7
    true,                               // 8
    true,                               // 9
    true,                               // 10
    true,                               // 11
    true,                               // 12
    true,                               // 13
    true,                               // 14
    true,                               // 15
    true,                               // 16
    true,                               // 17
    true,                               // 18
    true,                               // 19
    true                                // 20
}

/**
 * Test NAVRegexMatcher lookaround assertions
 *
 * Validates:
 * - Positive lookahead: (?=...)
 * - Negative lookahead: (?!...)
 * - Positive lookbehind: (?<=...)
 * - Negative lookbehind: (?<!...)
 * - Combined lookaround patterns
 * - Lookarounds with word boundaries
 * - Lookarounds with character classes and quantifiers
 * - Real-world patterns (prices, HTML tags, names, URLs)
 *
 * Note: Lookarounds are zero-width assertions - they don't consume
 * characters in the match, only assert conditions at a position.
 */
define_function TestNAVRegexMatcherLookaround() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Lookaround Assertions *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_LOOKAROUND_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_LOOKAROUND_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_LOOKAROUND_PATTERN[x], REGEX_MATCHER_LOOKAROUND_INPUT[x], collection)

        if (shouldMatch) {
            // Verify it matched
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_LOOKAROUND_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_LOOKAROUND_INPUT[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct',
                                     REGEX_MATCHER_LOOKAROUND_EXPECTED_MATCH[x],
                                     collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_LOOKAROUND_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVLog("'  Pattern: ', REGEX_MATCHER_LOOKAROUND_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_LOOKAROUND_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct',
                                      REGEX_MATCHER_LOOKAROUND_EXPECTED_START[x],
                                      type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_LOOKAROUND_EXPECTED_START[x]), itoa(collection.matches[1].fullMatch.start))
                NAVLog("'  Pattern: ', REGEX_MATCHER_LOOKAROUND_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        } else {
            // Verify it didn't match
            if (!NAVAssertTrue('Should not match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match', 'Match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_LOOKAROUND_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_LOOKAROUND_INPUT[x]")
                NAVLog("'  Matched: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
