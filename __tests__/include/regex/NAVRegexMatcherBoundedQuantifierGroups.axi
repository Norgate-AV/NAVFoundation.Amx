PROGRAM_NAME='NAVRegexMatcherBoundedQuantifierGroups'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for bounded quantifiers with groups
constant char REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_PATTERN[][255] = {
    '/(ab){2}/',                    // 1: Exactly 2 repetitions of group
    '/(ab){3}/',                    // 2: Exactly 3 repetitions of group
    '/(ab){2,}/',                   // 3: 2 or more repetitions of group
    '/(ab){2,4}/',                  // 4: Between 2 and 4 repetitions of group
    '/(\d{2})-(\d{2})/',            // 5: Two groups with bounded quantifiers
    '/(\d{3})-(\d{4})/',            // 6: Phone number pattern with groups
    '/(\w{3,5})\s+(\w{3,5})/',      // 7: Two word groups with bounded lengths
    '/(a{2}b{2})/',                 // 8: Group containing bounded quantifiers
    '/((ab){2})/',                  // 9: Nested group with quantifier
    '/(a{2}|b{2})/',                // 10: Alternation with bounded quantifiers
    '/(\d+){2}/',                   // 11: Two repetitions of digit group
    '/(test){1}/',                  // 12: Exactly 1 repetition (same as /(test)/)
    '/(xyz){0,1}/',                 // 13: 0 or 1 repetitions (same as /(xyz)?/)
    '/([a-z]{2,3})-(\d{2,3})/',     // 14: Char class groups with bounds
    '/(hello){2,}/',                // 15: 2 or more "hello"
    '/(\w+\s+){3}/',                // 16: 3 repetitions of word+space
    '/(ab){2}(cd){2}/',             // 17: Two different groups with bounds
    '/(\d{1,3}\.){3}\d{1,3}/',      // 18: IP address pattern with groups
    '/((a){2}(b){2})/',             // 19: Nested groups with bounds
    '/(test){2,3}/',                // 20: Between 2 and 3 "test"
    '/(ab){2}/',                    // 21: Should NOT match (only 1 repetition)
    '/(ab){3}/',                    // 22: Should NOT match (only 2 repetitions)
    '/(\d{3})-(\d{4})/',            // 23: Should NOT match (wrong digit count)
    '/(hello){2,}/',                // 24: Should NOT match (only 1 "hello")
    '/([a-z]{3})\s([a-z]{3})/'      // 25: Two 3-letter word groups
}

constant char REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_INPUT[][255] = {
    'abab',                         // 1: Exactly 2 "ab"
    'ababab',                       // 2: Exactly 3 "ab"
    'ababab',                       // 3: 3 "ab" (matches 2+)
    'ababab',                       // 4: 3 "ab" (matches 2-4)
    '10-23',                        // 5: Month-day
    '555-1234',                     // 6: Phone number
    'hello world',                  // 7: Two words (5 and 5 chars)
    'aabb',                         // 8: Two 'a', two 'b'
    'abab',                         // 9: Two "ab" nested
    'aa',                           // 10: Two 'a' (first alternative)
    '1234',                         // 11: Two digit sequences
    'test',                         // 12: One "test"
    'abc',                          // 13: No "xyz" (matches empty)
    'abc-12',                       // 14: 3 chars, 2 digits
    'hellohello',                   // 15: Two "hello"
    'one two three ',               // 16: Three word+space
    'ababcdcd',                     // 17: Two "ab", two "cd"
    '192.168.1.1',                  // 18: IP address
    'aabb',                         // 19: Nested groups
    'testtest',                     // 20: Two "test"
    'ab',                           // 21: Only one "ab"
    'abab',                         // 22: Only two "ab"
    '55-1234',                      // 23: Only 2 digits before dash
    'hello',                        // 24: Only one "hello"
    'the cat'                       // 25: Two 3-letter words
}

constant char REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_MATCH[][255] = {
    'abab',                         // 1
    'ababab',                       // 2
    'ababab',                       // 3: Greedy matches maximum (all 3 repetitions)
    'ababab',                       // 4: Greedy matches all
    '10-23',                        // 5
    '555-1234',                     // 6
    'hello world',                  // 7
    'aabb',                         // 8
    'abab',                         // 9
    'aa',                           // 10
    '1234',                         // 11: Two digit groups (greedy: "12" + "34")
    'test',                         // 12
    '',                             // 13: Empty match
    'abc-12',                       // 14
    'hellohello',                   // 15
    'one two three ',               // 16
    'ababcdcd',                     // 17
    '192.168.1.1',                  // 18
    'aabb',                         // 19
    'testtest',                     // 20
    '',                             // 21: No match
    '',                             // 22: No match
    '',                             // 23: No match
    '',                             // 24: No match
    'the cat'                       // 25
}

constant integer REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_START[] = {
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
    1,                              // 20
    0,                              // 21: No match
    0,                              // 22: No match
    0,                              // 23: No match
    0,                              // 24: No match
    1                               // 25
}

constant char REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_SHOULD_MATCH[] = {
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
    true,                           // 20
    false,                          // 21
    false,                          // 22
    false,                          // 23
    false,                          // 24
    true                            // 25
}


/**
 * @function TestNAVRegexMatcherBoundedQuantifierGroups
 * @public
 * @description Tests bounded quantifiers applied to groups (group){n,m}.
 *
 * Validates:
 * - (pattern){n} exact repetitions of group
 * - (pattern){n,} minimum repetitions of group
 * - (pattern){n,m} range repetitions of group
 * - Groups containing bounded quantifiers
 * - Multiple groups with different bounded quantifiers
 * - Nested groups with bounded quantifiers
 * - Alternation within bounded quantifier groups
 * - Character classes within bounded quantifier groups
 * - Greedy matching behavior with group repetitions
 */
define_function TestNAVRegexMatcherBoundedQuantifierGroups() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Bounded Quantifier Groups *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_PATTERN[x], REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_INPUT[x], collection)

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
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
                NAVStopwatchStop()
                continue
            }

            // Verify match length
            if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
                NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_BOUNDED_QUANTIFIER_GROUPS_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
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
