PROGRAM_NAME='NAVRegexMatcherStringAnchors'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for string anchor matching (\A, \z, \Z)
constant char REGEX_MATCHER_STRING_ANCHORS_PATTERN[][255] = {
    '/\Ahello/',            // 1: \A - absolute start of string
    '/world\z/',            // 2: \z - absolute end of string
    '/world\Z/',            // 3: \Z - end of string (before final newline)
    '/\Atest\z/',           // 4: Exact match with \A and \z
    '/\Atest\Z/',           // 5: Exact match with \A and \Z
    '/\A\d+/',              // 6: Digits at absolute start
    '/\d+\z/',              // 7: Digits at absolute end
    '/\d+\Z/',              // 8: Digits at end (before newline)
    '/\A[A-Z]/',            // 9: Uppercase at absolute start
    '/[a-z]\z/',            // 10: Lowercase at absolute end
    '/\A\w+\z/',            // 11: Whole string is word chars
    '/\A.{5}\z/',           // 12: Exactly 5 characters
    '/\Ahello/',            // 13: Should NOT match " hello"
    '/world\z/',            // 14: Should NOT match "world "
    '/\Atest\z/',           // 15: Should NOT match "test$0D$0A"
    '/\Atest\Z/',           // 16: Should match "test$0D$0A"
    '/\A\s*\w+/',           // 17: Optional whitespace then word at start
    '/\w+\s*\z/',           // 18: Word then optional whitespace at end
    '/\A[^a-z]+\z/',        // 19: Whole string is non-lowercase
    '/\A.*\z/',             // 20: Match entire string (any chars)
    '/\Afirst/',            // 21: Start of multiline string
    '/last\z/',             // 22: End of multiline string
    '/\A\w+\s+\w+\z/',      // 23: Two words with whitespace
    '/\A\d{3}-\d{4}\z/',    // 24: Phone number pattern
    '/\A[a-z0-9]+@[a-z]+\.[a-z]+\z/'  // 25: Email pattern
}

constant char REGEX_MATCHER_STRING_ANCHORS_INPUT[][255] = {
    'hello world',          // 1: Starts with "hello"
    'hello world',          // 2: Ends with "world"
    'hello world',          // 3: Ends with "world"
    'test',                 // 4: Exactly "test"
    'test',                 // 5: Exactly "test"
    '123abc',               // 6: Starts with digits
    'abc123',               // 7: Ends with digits
    'abc123',               // 8: Ends with digits
    'Hello',                // 9: Starts with uppercase
    'Hello',                // 10: Ends with lowercase
    'test',                 // 11: All word chars
    'hello',                // 12: Exactly 5 chars
    ' hello',               // 13: Space before "hello"
    'world ',               // 14: Space after "world"
    {'t', 'e', 's', 't', $0D, $0A},     // 15: "test" with newline
    {'t', 'e', 's', 't', $0D, $0A},     // 16: "test" with newline
    '  hello',              // 17: Whitespace before word
    'hello  ',              // 18: Whitespace after word
    '123-456',              // 19: All non-lowercase
    'any text here',        // 20: Any string
    {'f', 'i', 'r', 's', 't', $0D, $0A, 's', 'e', 'c', 'o', 'n', 'd'},  // 21: Multiline
    {'f', 'i', 'r', 's', 't', $0D, $0A, 'l', 'a', 's', 't'},    // 22: Multiline
    'hello world',          // 23: Two words
    '555-1234',             // 24: Phone number
    'user@example.com'      // 25: Email address
}

constant char REGEX_MATCHER_STRING_ANCHORS_EXPECTED_MATCH[][255] = {
    'hello',                // 1
    'world',                // 2
    'world',                // 3
    'test',                 // 4
    'test',                 // 5
    '123',                  // 6
    '123',                  // 7
    '123',                  // 8
    'H',                    // 9
    'o',                    // 10
    'test',                 // 11
    'hello',                // 12
    '',                     // 13: No match
    '',                     // 14: No match
    '',                     // 15: No match
    'test',                 // 16
    '  hello',              // 17
    'hello  ',              // 18
    '123-456',              // 19
    'any text here',        // 20
    'first',                // 21
    'last',                 // 22
    'hello world',          // 23
    '555-1234',             // 24
    'user@example.com'      // 25
}

constant integer REGEX_MATCHER_STRING_ANCHORS_EXPECTED_START[] = {
    1,                      // 1
    7,                      // 2
    7,                      // 3
    1,                      // 4
    1,                      // 5
    1,                      // 6
    4,                      // 7
    4,                      // 8
    1,                      // 9
    5,                      // 10
    1,                      // 11
    1,                      // 12
    0,                      // 13: No match
    0,                      // 14: No match
    0,                      // 15: No match
    1,                      // 16
    1,                      // 17
    1,                      // 18
    1,                      // 19
    1,                      // 20
    1,                      // 21
    8,                      // 22: 'last' starts at position 8 (after 'first\r\n')
    1,                      // 23
    1,                      // 24
    1                       // 25
}

constant char REGEX_MATCHER_STRING_ANCHORS_SHOULD_MATCH[] = {
    true,                   // 1
    true,                   // 2
    true,                   // 3
    true,                   // 4
    true,                   // 5
    true,                   // 6
    true,                   // 7
    true,                   // 8
    true,                   // 9
    true,                   // 10
    true,                   // 11
    true,                   // 12
    false,                  // 13
    false,                  // 14
    false,                  // 15
    true,                   // 16
    true,                   // 17
    true,                   // 18
    true,                   // 19
    true,                   // 20
    true,                   // 21
    true,                   // 22
    true,                   // 23
    true,                   // 24
    true                    // 25
}


/**
 * @function TestNAVRegexMatcherStringAnchors
 * @public
 * @description Tests string anchor assertions (\A, \z, \Z).
 *
 * Validates:
 * - \A absolute start of string anchor
 * - \z absolute end of string anchor (no newline)
 * - \Z end of string anchor (before optional final newline)
 * - Combined \A...\z for exact matching
 * - Combined \A...\Z for exact matching with optional newline
 * - String anchors with character classes and quantifiers
 * - Difference between \z and \Z with newlines
 * - Multiline string handling
 */
define_function TestNAVRegexMatcherStringAnchors() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - String Anchors *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_STRING_ANCHORS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_STRING_ANCHORS_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_STRING_ANCHORS_PATTERN[x], REGEX_MATCHER_STRING_ANCHORS_INPUT[x], collection)

        if (shouldMatch) {
            // Verify it matched
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVStopwatchStop()
                continue
            }

            // Verify hasMatch flag
            if (!NAVAssertTrue('Result should have match', collection.matches[1].hasMatch)) {
                NAVLogTestFailed(x, 'hasMatch=true', 'hasMatch=false')
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_STRING_ANCHORS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_STRING_ANCHORS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_STRING_ANCHORS_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_STRING_ANCHORS_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
                NAVStopwatchStop()
                continue
            }

            // Verify match length
            if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_STRING_ANCHORS_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
                NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_STRING_ANCHORS_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
                NAVStopwatchStop()
                continue
            }
        }
        else {
            // Verify it did NOT match
            if (!NAVAssertTrue('Should NOT match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match', "'Matched: ", collection.matches[1].fullMatch.text, "'")
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
