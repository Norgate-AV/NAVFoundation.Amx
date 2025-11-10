PROGRAM_NAME='NAVRegexMatcherAnchors'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for anchor matching (^, $, \b, \B)
constant char REGEX_MATCHER_ANCHORS_PATTERN[][255] = {
    '/^hello/',             // 1: Start of string
    '/world$/',             // 2: End of string
    '/^test$/',             // 3: Exact match (start and end)
    '/^$/',                 // 4: Empty string
    '/^\d+/',               // 5: Digits at start
    '/\d+$/',               // 6: Digits at end
    '/^[A-Z]/',             // 7: Uppercase letter at start
    '/[a-z]$/',             // 8: Lowercase letter at end
    '/^\w+$/',              // 9: Whole string is word chars
    '/^.{5}$/',             // 10: Exactly 5 characters
    '/^abc/',               // 11: Should match "abc" at start
    '/xyz$/',               // 12: Should match "xyz" at end
    '/^hello/',             // 13: Should NOT match "say hello"
    '/world$/',             // 14: Should NOT match "world peace"
    '/^test$/',             // 15: Should NOT match "testing"
    '/\bcat\b/',            // 16: Word boundary - whole word
    '/\btest/',             // 17: Word boundary - start of word
    '/ing\b/',              // 18: Word boundary - end of word
    '/\B\w\B/',             // 19: Non-boundary - middle char
    '/\Btest/',             // 20: Non-boundary - not at word start
    '/ing\B/',              // 21: Non-boundary - not at word end
    '/^\s*\w+/',            // 22: Optional whitespace then word at start
    '/\w+\s*$/',            // 23: Word then optional whitespace at end
    '/^[^a-z]+$/',          // 24: Whole string is non-lowercase
    '/^.*$/'                // 25: Match entire string (any chars)
}

constant char REGEX_MATCHER_ANCHORS_INPUT[][255] = {
    'hello world',          // 1: Starts with "hello"
    'hello world',          // 2: Ends with "world"
    'test',                 // 3: Exactly "test"
    '',                     // 4: Empty string
    '123abc',               // 5: Starts with digits
    'abc123',               // 6: Ends with digits
    'Hello',                // 7: Starts with uppercase
    'Hello',                // 8: Ends with lowercase
    'test',                 // 9: All word chars
    'hello',                // 10: Exactly 5 chars
    'abcdef',               // 11: Starts with "abc"
    'abcxyz',               // 12: Ends with "xyz"
    'say hello',            // 13: "hello" not at start
    'world peace',          // 14: "world" not at end
    'testing',              // 15: Not exactly "test"
    'the cat sat',          // 16: Whole word "cat"
    'testing phase',        // 17: "test" at start of word
    'running fast',         // 18: "ing" at end of word
    'test',                 // 19: Middle char 'e' or 's'
    'retest',               // 20: "test" not at word start
    'singing',              // 21: "ing" not at word end
    '  hello',              // 22: Whitespace before word
    'hello  ',              // 23: Whitespace after word
    '123-456',              // 24: All non-lowercase
    'any text here'         // 25: Any string
}

constant char REGEX_MATCHER_ANCHORS_EXPECTED_MATCH[][255] = {
    'hello',                // 1
    'world',                // 2
    'test',                 // 3
    '',                     // 4
    '123',                  // 5
    '123',                  // 6
    'H',                    // 7
    'o',                    // 8
    'test',                 // 9
    'hello',                // 10
    'abc',                  // 11
    'xyz',                  // 12
    '',                     // 13: No match
    '',                     // 14: No match
    '',                     // 15: No match
    'cat',                  // 16
    'test',                 // 17
    'ing',                  // 18
    'e',                    // 19
    'test',                 // 20
    'ing',                  // 21
    '  hello',              // 22
    'hello  ',              // 23
    '123-456',              // 24
    'any text here'         // 25
}

constant integer REGEX_MATCHER_ANCHORS_EXPECTED_START[] = {
    1,                      // 1
    7,                      // 2
    1,                      // 3
    1,                      // 4
    1,                      // 5
    4,                      // 6
    1,                      // 7
    5,                      // 8
    1,                      // 9
    1,                      // 10
    1,                      // 11
    4,                      // 12
    0,                      // 13: No match
    0,                      // 14: No match
    0,                      // 15: No match
    5,                      // 16
    1,                      // 17
    5,                      // 18
    2,                      // 19
    3,                      // 20
    2,                      // 21
    1,                      // 22
    1,                      // 23
    1,                      // 24
    1                       // 25
}

constant char REGEX_MATCHER_ANCHORS_SHOULD_MATCH[] = {
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
 * @function TestNAVRegexMatcherAnchors
 * @public
 * @description Tests anchor assertions (^, $, \b, \B).
 *
 * Validates:
 * - ^ start of string anchor
 * - $ end of string anchor
 * - Combined ^...$ for exact matching
 * - \b word boundary anchor
 * - \B non-word-boundary anchor
 * - Anchors with character classes and quantifiers
 * - Empty string matching
 */
define_function TestNAVRegexMatcherAnchors() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Anchors *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_ANCHORS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_ANCHORS_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_ANCHORS_PATTERN[x], REGEX_MATCHER_ANCHORS_INPUT[x], collection)

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
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_ANCHORS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_ANCHORS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_ANCHORS_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_ANCHORS_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
                NAVStopwatchStop()
                continue
            }

            // Verify match length
            if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_ANCHORS_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
                NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_ANCHORS_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
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
