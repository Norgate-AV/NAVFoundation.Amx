PROGRAM_NAME='NAVRegexMatcherBackreference'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for backreference matching
constant char REGEX_MATCHER_BACKREF_PATTERN[][255] = {
    '/(a)\1/',              // 1: Simple backreference - matches "aa"
    '/(abc)\1/',            // 2: Multi-char backreference - matches "abcabc"
    '/(\d)\1/',             // 3: Digit backreference - matches repeated digit
    '/(\w)\1/',             // 4: Word char backreference
    '/(a)(b)\1\2/',         // 5: Two backreferences - matches "abab"
    '/(x)(y)(z)\1\2\3/',    // 6: Three backreferences - matches "xyzxyz"
    '/(a)\1+/',             // 7: Backreference with quantifier
    '/(\d+)\1/',            // 8: Captured group with quantifier
    '/([a-z])\1/',          // 9: Character class backreference
    '/(a)\1/i',             // 10: Case-insensitive backreference
    '/(abc)\1/i',           // 11: Case-insensitive multi-char
    '/^(a)\1$/',            // 12: Anchored backreference
    '/\b(\w)\1\b/',         // 13: Word boundary with backreference
    '/(a)|(b)\2/',          // 14: Non-participating group (b not captured)
    '/(a)\1/',              // 15: Should NOT match "ab" (different chars)
    '/(\d)\1/'              // 16: Should NOT match "12" (different digits)
}

constant char REGEX_MATCHER_BACKREF_INPUT[][255] = {
    'aa',                   // 1: Simple repeated char
    'abcabc',               // 2: Repeated sequence
    '11',                   // 3: Repeated digit
    'aa',                   // 4: Repeated word char
    'abab',                 // 5: Two group repetition
    'xyzxyz',               // 6: Three group repetition
    'aaa',                  // 7: Multiple repetitions
    '123123',               // 8: Repeated number sequence
    'aa',                   // 9: Repeated from char class
    'aA',                   // 10: Case variation
    'abcABC',               // 11: Case variation multi-char
    'aa',                   // 12: Anchored repetition
    'aa',                   // 13: Word boundary repetition
    'a',                    // 14: First alternative (b not captured)
    'ab',                   // 15: Different chars (should NOT match)
    '12'                    // 16: Different digits (should NOT match)
}

constant char REGEX_MATCHER_BACKREF_EXPECTED_MATCH[][255] = {
    'aa',                   // 1: Both "a" chars
    'abcabc',               // 2: Both "abc" sequences
    '11',                   // 3: Both "1" digits
    'aa',                   // 4: Both "a" chars
    'abab',                 // 5: "a", "b", "a", "b"
    'xyzxyz',               // 6: "x", "y", "z", "x", "y", "z"
    'aaa',                  // 7: "a" then "aa" (one or more)
    '123123',               // 8: "123" then "123"
    'aa',                   // 9: Both "a" chars
    'aA',                   // 10: "a" then "A" (case-insensitive)
    'abcABC',               // 11: "abc" then "ABC" (case-insensitive)
    'aa',                   // 12: Both "a" chars
    'aa',                   // 13: Both "a" chars
    'a',                    // 14: Just "a" (second group not participating)
    '',                     // 15: No match expected
    ''                      // 16: No match expected
}

constant integer REGEX_MATCHER_BACKREF_EXPECTED_START[] = {
    1,                      // 1: Match at position 1
    1,                      // 2: Match at position 1
    1,                      // 3: Match at position 1
    1,                      // 4: Match at position 1
    1,                      // 5: Match at position 1
    1,                      // 6: Match at position 1
    1,                      // 7: Match at position 1
    1,                      // 8: Match at position 1
    1,                      // 9: Match at position 1
    1,                      // 10: Match at position 1
    1,                      // 11: Match at position 1
    1,                      // 12: Match at position 1
    1,                      // 13: Match at position 1
    1,                      // 14: Match at position 1
    0,                      // 15: No match
    0                       // 16: No match
}

constant char REGEX_MATCHER_BACKREF_SHOULD_MATCH[] = {
    true,                   // 1: Should match
    true,                   // 2: Should match
    true,                   // 3: Should match
    true,                   // 4: Should match
    true,                   // 5: Should match
    true,                   // 6: Should match
    true,                   // 7: Should match
    true,                   // 8: Should match
    true,                   // 9: Should match
    true,                   // 10: Should match
    true,                   // 11: Should match
    true,                   // 12: Should match
    true,                   // 13: Should match
    true,                   // 14: Should match
    false,                  // 15: Should NOT match (different chars)
    false                   // 16: Should NOT match (different digits)
}


/**
 * @function TestNAVRegexMatcherBackreference
 * @public
 * @description Tests backreference matching (\1, \2, etc.).
 *
 * Validates:
 * - Simple single-char backreferences
 * - Multi-char backreferences
 * - Multiple backreferences in same pattern
 * - Backreferences with quantifiers
 * - Case-insensitive backreferences
 * - Backreferences with anchors and word boundaries
 * - Non-participating groups (groups that don't capture)
 */
define_function TestNAVRegexMatcherBackreference() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Backreferences *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_BACKREF_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_BACKREF_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_BACKREF_PATTERN[x], REGEX_MATCHER_BACKREF_INPUT[x], collection)

        if (shouldMatch) {
            // Verify it matched
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_BACKREF_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_BACKREF_INPUT[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_BACKREF_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, 'Correct match text', 'Wrong match text')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_BACKREF_PATTERN[x]")
                NAVLog("'  Input:    ', REGEX_MATCHER_BACKREF_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_BACKREF_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, 'Correct start position', 'Wrong start position')
                NAVLog("'  Pattern:  ', REGEX_MATCHER_BACKREF_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        } else {
            // Verify it didn't match
            if (!NAVAssertTrue('Should not match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match', 'Match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_BACKREF_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_BACKREF_INPUT[x]")
                NAVLog("'  Matched: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
