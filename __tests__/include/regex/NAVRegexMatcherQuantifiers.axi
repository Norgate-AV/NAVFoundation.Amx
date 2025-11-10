PROGRAM_NAME='NAVRegexMatcherQuantifiers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for quantifier matching (\*, +, ?, {n,m})
constant char REGEX_MATCHER_QUANTIFIERS_PATTERN[][255] = {
    '/a*/',                 // 1: Zero or more 'a'
    '/a+/',                 // 2: One or more 'a'
    '/a?/',                 // 3: Zero or one 'a'
    '/ab*c/',               // 4: 'a', zero or more 'b', 'c'
    '/ab+c/',               // 5: 'a', one or more 'b', 'c'
    '/ab?c/',               // 6: 'a', zero or one 'b', 'c'
    '/\d*/',                // 7: Zero or more digits
    '/\d+/',                // 8: One or more digits
    '/\d?/',                // 9: Zero or one digit
    '/\w*/',                // 10: Zero or more word chars
    '/\w+/',                // 11: One or more word chars
    '/\w?/',                // 12: Zero or one word char
    '/a*b/',                // 13: Zero or more 'a' then 'b'
    '/a+b/',                // 14: One or more 'a' then 'b'
    '/a?b/',                // 15: Zero or one 'a' then 'b'
    '/x*y*z/',              // 16: Multiple quantifiers
    '/[0-9]*/',             // 17: Zero or more digits (char class)
    '/[0-9]+/',             // 18: One or more digits (char class)
    '/[a-z]*/',             // 19: Zero or more lowercase
    '/[a-z]+/',             // 20: One or more lowercase
    '/a*/g',                // 21: Global - zero or more 'a'
    '/a+/g',                // 22: Global - one or more 'a'
    '/\d*/g',               // 23: Global - zero or more digits
    '/\d+/g',               // 24: Global - one or more digits
    '/(ab)+/',              // 25: One or more "ab" groups
    '/(test)?/',            // 26: Zero or one "test" group
    '/a*/',                 // 27: Should match empty at start
    '/a+/',                 // 28: Should NOT match (no 'a')
    '/\d+/',                // 29: Should NOT match (no digits)
    '/x+y+z+/'              // 30: Multiple one-or-more quantifiers
}

constant char REGEX_MATCHER_QUANTIFIERS_INPUT[][255] = {
    'bbb',                  // 1: No 'a', matches empty at start
    'aaa',                  // 2: Three 'a's
    'bbb',                  // 3: No 'a', matches empty at start
    'ac',                   // 4: 'a', zero 'b', 'c'
    'abc',                  // 5: 'a', one 'b', 'c'
    'ac',                   // 6: 'a', zero 'b', 'c'
    'abc',                  // 7: Zero digits, matches empty at start
    '123',                  // 8: Three digits
    'abc',                  // 9: Zero digits, matches empty at start
    '***',                  // 10: Zero word chars, matches empty at start
    'test',                 // 11: Four word chars
    '***',                  // 12: Zero word chars, matches empty at start
    'b',                    // 13: Zero 'a', then 'b'
    'aab',                  // 14: Two 'a', then 'b'
    'b',                    // 15: Zero 'a', then 'b'
    'z',                    // 16: Zero 'x', zero 'y', one 'z'
    'abc',                  // 17: Zero digits, matches empty at start
    '123',                  // 18: Three digits
    '123',                  // 19: Zero lowercase, matches empty at start
    'abc',                  // 20: Three lowercase
    'aabaa',                // 21: Global - should match "aa", "b", "aa"
    'aabaa',                // 22: Global - should match "aa", "aa"
    '12ab34',               // 23: Global - should match "12", "ab", "34"
    '12ab34',               // 24: Global - should match "12", "34"
    'ababab',               // 25: Three "ab" sequences
    'hello',                // 26: No "test", matches empty
    'xxx',                  // 27: No 'a', matches empty at start
    'xxx',                  // 28: No 'a', should not match
    'xxx',                  // 29: No digits, should not match
    'xxyyyzz'               // 30: Multiple sequences
}

constant char REGEX_MATCHER_QUANTIFIERS_EXPECTED_MATCH[][255] = {
    '',                     // 1: Empty match
    'aaa',                  // 2
    '',                     // 3: Empty match
    'ac',                   // 4
    'abc',                  // 5
    'ac',                   // 6
    '',                     // 7: Empty match
    '123',                  // 8
    '',                     // 9: Empty match
    '',                     // 10: Empty match
    'test',                 // 11
    '',                     // 12: Empty match
    'b',                    // 13
    'aab',                  // 14
    'b',                    // 15
    'z',                    // 16
    '',                     // 17: Empty match
    '123',                  // 18
    '',                     // 19: Empty match
    'abc',                  // 20
    'aa',                   // 21: First match
    'aa',                   // 22: First match
    '12',                   // 23: First match
    '12',                   // 24: First match
    'ababab',               // 25
    '',                     // 26: Empty match
    '',                     // 27: Empty match
    '',                     // 28: No match
    '',                     // 29: No match
    'xxyyyzz'               // 30
}

constant integer REGEX_MATCHER_QUANTIFIERS_EXPECTED_START[] = {
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
    1,                      // 23
    1,                      // 24
    1,                      // 25
    1,                      // 26
    1,                      // 27
    0,                      // 28: No match
    0,                      // 29: No match
    1                       // 30
}

constant char REGEX_MATCHER_QUANTIFIERS_SHOULD_MATCH[] = {
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
    true,                   // 23
    true,                   // 24
    true,                   // 25
    true,                   // 26
    true,                   // 27
    false,                  // 28
    false,                  // 29
    true                    // 30
}


/**
 * @function TestNAVRegexMatcherQuantifiers
 * @public
 * @description Tests quantifier matching (\*, +, ?).
 *
 * Validates:
 * - * (zero or more) quantifier
 * - + (one or more) quantifier
 * - ? (zero or one) quantifier
 * - Quantifiers with literals
 * - Quantifiers with character classes (\d, \w, \s)
 * - Quantifiers with custom character classes [a-z]
 * - Multiple quantifiers in sequence
 * - Greedy matching behavior
 * - Empty matches with * and ?
 * - Global matching with quantifiers
 */
define_function TestNAVRegexMatcherQuantifiers() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Quantifiers *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_QUANTIFIERS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_QUANTIFIERS_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_QUANTIFIERS_PATTERN[x], REGEX_MATCHER_QUANTIFIERS_INPUT[x], collection)

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
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_QUANTIFIERS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_QUANTIFIERS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_QUANTIFIERS_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_QUANTIFIERS_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
                NAVStopwatchStop()
                continue
            }

            // Verify match length
            if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_QUANTIFIERS_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
                NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_QUANTIFIERS_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
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
