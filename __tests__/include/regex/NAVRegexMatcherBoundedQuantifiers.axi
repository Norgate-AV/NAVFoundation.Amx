PROGRAM_NAME='NAVRegexMatcherBoundedQuantifiers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for bounded quantifier matching {n}, {n,}, {n,m}
constant char REGEX_MATCHER_BOUNDED_QUANTIFIERS_PATTERN[][255] = {
    '/a{3}/',               // 1: Exactly 3 'a's
    '/a{2,}/',              // 2: 2 or more 'a's
    '/a{2,4}/',             // 3: Between 2 and 4 'a's
    '/\d{3}/',              // 4: Exactly 3 digits
    '/\d{2,}/',             // 5: 2 or more digits
    '/\d{2,4}/',            // 6: Between 2 and 4 digits
    '/\w{5}/',              // 7: Exactly 5 word chars
    '/\w{3,}/',             // 8: 3 or more word chars
    '/\w{3,6}/',            // 9: Between 3 and 6 word chars
    '/[a-z]{4}/',           // 10: Exactly 4 lowercase letters
    '/[a-z]{2,}/',          // 11: 2 or more lowercase letters
    '/[a-z]{2,5}/',         // 12: Between 2 and 5 lowercase letters
    '/x{1}/',               // 13: Exactly 1 'x' (same as /x/)
    '/x{0,1}/',             // 14: 0 or 1 'x' (same as /x?/)
    '/x{1,}/',              // 15: 1 or more 'x' (same as /x+/)
    '/\d{3}-\d{4}/',        // 16: Phone number pattern
    '/\w{3,}\s\w{3,}/',     // 17: Two words (3+ chars each)
    '/[A-Z]{2,3}/',         // 18: 2-3 uppercase letters
    '/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/',  // 19: IP address pattern
    '/a{2}b{2}/',           // 20: 2 'a's then 2 'b's
    '/\d{2,3}/g',           // 21: Global - 2-3 digits
    '/\w{4}/g',             // 22: Global - exactly 4 word chars
    '/a{3}/',               // 23: Should NOT match (only 2 'a's)
    '/\d{4}/',              // 24: Should NOT match (only 3 digits)
    '/\w{5,}/',             // 25: Should NOT match (only 4 chars)
    '/a{2,4}/',             // 26: Should match exactly 2 'a's
    '/a{2,4}/',             // 27: Should match exactly 4 'a's
    '/\d{1,2}/',            // 28: Should match 1 digit
    '/\d{1,2}/',            // 29: Should match 2 digits
    '/[0-9]{3}/'            // 30: Exactly 3 digits (char class)
}

constant char REGEX_MATCHER_BOUNDED_QUANTIFIERS_INPUT[][255] = {
    'aaa',                  // 1: Exactly 3 'a's
    'aaaa',                 // 2: 4 'a's (matches first 2+)
    'aaaa',                 // 3: 4 'a's (matches 2-4)
    '123',                  // 4: Exactly 3 digits
    '12345',                // 5: 5 digits (matches first 2+)
    '12345',                // 6: 5 digits (matches 2-4)
    'hello',                // 7: Exactly 5 word chars
    'testing',              // 8: 7 word chars (matches first 3+)
    'testing',              // 9: 7 word chars (matches 3-6)
    'test',                 // 10: Exactly 4 lowercase
    'hello',                // 11: 5 lowercase (matches first 2+)
    'hello',                // 12: 5 lowercase (matches 2-5)
    'xxx',                  // 13: Contains 'x'
    'yyy',                  // 14: No 'x' (matches empty)
    'xxx',                  // 15: Three 'x's
    '555-1234',             // 16: Phone number
    'hello world',          // 17: Two words
    'USA',                  // 18: Three uppercase
    '192.168.1.1',          // 19: IP address
    'aabb',                 // 20: 2 'a's and 2 'b's
    '12 345 6789',          // 21: Multiple digit groups
    'test word here',       // 22: Multiple 4-char words
    'aa',                   // 23: Only 2 'a's (needs 3)
    '123',                  // 24: Only 3 digits (needs 4)
    'test',                 // 25: Only 4 chars (needs 5+)
    'aa',                   // 26: Exactly 2 'a's
    'aaaa',                 // 27: Exactly 4 'a's
    '5',                    // 28: Exactly 1 digit
    '55',                   // 29: Exactly 2 digits
    '555'                   // 30: Exactly 3 digits
}

constant char REGEX_MATCHER_BOUNDED_QUANTIFIERS_EXPECTED_MATCH[][255] = {
    'aaa',                  // 1: Exactly 3
    'aaaa',                 // 2: Greedy - matches all 4 (2 or more)
    'aaaa',                 // 3: Greedy - matches all 4 (within 2-4 range)
    '123',                  // 4: Exactly 3
    '12345',                // 5: Greedy - matches all 5 (2 or more)
    '1234',                 // 6: Greedy - matches 4 (max of 2-4 range)
    'hello',                // 7: Exactly 5
    'testing',              // 8: Greedy - matches all 7 (3 or more)
    'testin',               // 9: Greedy - matches 6 (max of 3-6 range)
    'test',                 // 10: Exactly 4
    'hello',                // 11: Greedy - matches all 5 (2 or more)
    'hello',                // 12: Greedy - matches all 5 (within 2-5 range)
    'x',                    // 13: Exactly 1
    '',                     // 14: 0 or 1 - empty match
    'xxx',                  // 15: 1 or more - all 3
    '555-1234',             // 16: Phone pattern
    'hello world',          // 17: Two words pattern
    'USA',                  // 18: 2-3 uppercase
    '192.168.1.1',          // 19: IP address
    'aabb',                 // 20: 2 a's then 2 b's
    '12',                   // 21: First global match
    'test',                 // 22: First global match
    '',                     // 23: No match (insufficient)
    '',                     // 24: No match (insufficient)
    '',                     // 25: No match (insufficient)
    'aa',                   // 26: 2 a's (within 2-4 range)
    'aaaa',                 // 27: 4 a's (max of 2-4 range)
    '5',                    // 28: 1 digit (within 1-2 range)
    '55',                   // 29: 2 digits (max of 1-2 range)
    '555'                   // 30: Exactly 3 digits
}

constant integer REGEX_MATCHER_BOUNDED_QUANTIFIERS_EXPECTED_START[] = {
    1,                      // 1
    1,                      // 2
    1,                      // 3
    1,                      // 4
    1,                      // 5
    1,                      // 6
    1,                      // 7
    1,                      // 8
    1,                      // 9
    1,                      // 10
    1,                      // 11
    1,                      // 12
    1,                      // 13
    1,                      // 14
    1,                      // 15
    1,                      // 16
    1,                      // 17
    1,                      // 18
    1,                      // 19
    1,                      // 20
    1,                      // 21
    1,                      // 22
    0,                      // 23: No match
    0,                      // 24: No match
    0,                      // 25: No match
    1,                      // 26
    1,                      // 27
    1,                      // 28
    1,                      // 29
    1                       // 30
}

constant char REGEX_MATCHER_BOUNDED_QUANTIFIERS_SHOULD_MATCH[] = {
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
    true,                   // 13
    true,                   // 14
    true,                   // 15
    true,                   // 16
    true,                   // 17
    true,                   // 18
    true,                   // 19
    true,                   // 20
    true,                   // 21
    true,                   // 22
    false,                  // 23
    false,                  // 24
    false,                  // 25
    true,                   // 26
    true,                   // 27
    true,                   // 28
    true,                   // 29
    true                    // 30
}


/**
 * @function TestNAVRegexMatcherBoundedQuantifiers
 * @public
 * @description Tests bounded quantifier matching {n}, {n,}, {n,m}.
 *
 * Validates:
 * - {n} exact count quantifier
 * - {n,} minimum count quantifier (n or more)
 * - {n,m} range quantifier (between n and m)
 * - Bounded quantifiers with literals
 * - Bounded quantifiers with character classes (\d, \w, \s)
 * - Bounded quantifiers with custom character classes [a-z]
 * - Complex patterns with multiple bounded quantifiers
 * - Greedy matching behavior with bounded quantifiers
 * - Equivalence to basic quantifiers (\*, +, ?)
 * - Global matching with bounded quantifiers
 */
define_function TestNAVRegexMatcherBoundedQuantifiers() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Bounded Quantifiers *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_BOUNDED_QUANTIFIERS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_BOUNDED_QUANTIFIERS_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_BOUNDED_QUANTIFIERS_PATTERN[x], REGEX_MATCHER_BOUNDED_QUANTIFIERS_INPUT[x], collection)

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
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_BOUNDED_QUANTIFIERS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_BOUNDED_QUANTIFIERS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_BOUNDED_QUANTIFIERS_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_BOUNDED_QUANTIFIERS_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
                NAVStopwatchStop()
                continue
            }

            // Verify match length
            if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_BOUNDED_QUANTIFIERS_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
                NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_BOUNDED_QUANTIFIERS_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
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
