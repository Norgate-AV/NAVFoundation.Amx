PROGRAM_NAME='NAVRegexMatcherCharClassCaseInsensitive'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for case-insensitive character classes
constant char REGEX_MATCHER_CHARCLASS_CASEINS_PATTERN[][255] = {
    '/[A-Z]/i',             // 1: Uppercase range with /i - should match lowercase
    '/[a-z]/i',             // 2: Lowercase range with /i - should match uppercase
    '/[A-Z0-9]/i',          // 3: Mixed range with /i
    '/[ABC]/i',             // 4: Specific uppercase chars with /i
    '/[abc]/i',             // 5: Specific lowercase chars with /i
    '/[A-Z]/i',             // 6: Uppercase range matching uppercase
    '/[a-z]/i',             // 7: Lowercase range matching lowercase
    '/[A-Z]/',              // 8: Without /i - should NOT match lowercase
    '/[a-z]/',              // 9: Without /i - should NOT match uppercase
    '/[A-Z]+/i',            // 10: Uppercase range with + quantifier and /i
    '/[a-z]+/i',            // 11: Lowercase range with + quantifier and /i
    '/[A-F]/i',             // 12: Hex digit uppercase with /i
    '/[a-f]/i',             // 13: Hex digit lowercase with /i
    '/[A-Z0-9]/i',          // 14: Alphanumeric uppercase with /i
    '/[a-z0-9]/i',          // 15: Alphanumeric lowercase with /i
    '/[^A-Z]/i',            // 16: Negated uppercase range with /i
    '/[^a-z]/i',            // 17: Negated lowercase range with /i
    '/[A-Za-z]/i',          // 18: Both ranges with /i
    '/^[A-Z]+$/i',          // 19: Anchored uppercase with /i matching lowercase
    '/^[a-z]+$/i'           // 20: Anchored lowercase with /i matching uppercase
}

constant char REGEX_MATCHER_CHARCLASS_CASEINS_INPUT[][255] = {
    'abc',                  // 1: Lowercase input
    'ABC',                  // 2: Uppercase input
    'abc123',               // 3: Mixed case and digits
    'abc',                  // 4: Lowercase matching uppercase class
    'ABC',                  // 5: Uppercase matching lowercase class
    'ABC',                  // 6: Uppercase matching uppercase class
    'abc',                  // 7: Lowercase matching lowercase class
    'abc',                  // 8: Lowercase should NOT match without /i
    'ABC',                  // 9: Uppercase should NOT match without /i
    'hello',                // 10: Lowercase matching uppercase+ with /i
    'WORLD',                // 11: Uppercase matching lowercase+ with /i
    'abc',                  // 12: Lowercase hex digit
    'DEF',                  // 13: Uppercase hex digit
    'Test123',              // 14: Mixed case alphanumeric
    'TEST456',              // 15: Uppercase alphanumeric
    '123',                  // 16: Digits (not A-Z)
    '123',                  // 17: Digits (not a-z)
    'Hello',                // 18: Mixed case
    'lowercase',            // 19: Lowercase matching uppercase with /i
    'UPPERCASE'             // 20: Uppercase matching lowercase with /i
}

constant char REGEX_MATCHER_CHARCLASS_CASEINS_EXPECTED_MATCH[][255] = {
    'a',                    // 1: First lowercase char
    'A',                    // 2: First uppercase char
    'a',                    // 3: First alpha char
    'a',                    // 4: First lowercase
    'A',                    // 5: First uppercase
    'A',                    // 6: First uppercase
    'a',                    // 7: First lowercase
    '',                     // 8: No match
    '',                     // 9: No match
    'hello',                // 10: Whole word
    'WORLD',                // 11: Whole word
    'a',                    // 12: First hex char
    'D',                    // 13: First hex char
    'T',                    // 14: First alpha char
    'T',                    // 15: First alpha char
    '1',                    // 16: First non-alpha
    '1',                    // 17: First non-alpha
    'H',                    // 18: First char
    'lowercase',            // 19: Whole word
    'UPPERCASE'             // 20: Whole word
}

constant integer REGEX_MATCHER_CHARCLASS_CASEINS_EXPECTED_START[] = {
    1,                      // 1
    1,                      // 2
    1,                      // 3
    1,                      // 4
    1,                      // 5
    1,                      // 6
    1,                      // 7
    0,                      // 8: No match
    0,                      // 9: No match
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
    1                       // 20
}

constant char REGEX_MATCHER_CHARCLASS_CASEINS_SHOULD_MATCH[] = {
    true,                   // 1: Should match
    true,                   // 2: Should match
    true,                   // 3: Should match
    true,                   // 4: Should match
    true,                   // 5: Should match
    true,                   // 6: Should match
    true,                   // 7: Should match
    false,                  // 8: Should NOT match
    false,                  // 9: Should NOT match
    true,                   // 10: Should match
    true,                   // 11: Should match
    true,                   // 12: Should match
    true,                   // 13: Should match
    true,                   // 14: Should match
    true,                   // 15: Should match
    true,                   // 16: Should match
    true,                   // 17: Should match
    true,                   // 18: Should match
    true,                   // 19: Should match
    true                    // 20: Should match
}

/**
 * @function TestNAVRegexMatcherCharClassCaseInsensitive
 * @public
 * @description Tests character classes with case-insensitive flag (/i).
 *
 * Validates:
 * - [A-Z] with /i matches both uppercase and lowercase
 * - [a-z] with /i matches both uppercase and lowercase
 * - Mixed ranges [A-Z0-9] work correctly with /i
 * - Specific character lists [ABC] work with /i
 * - Quantifiers work with case-insensitive character classes
 * - Negated classes work correctly with /i
 * - Without /i flag, character classes are case-sensitive
 * - Hex digit ranges work with /i
 * - Anchored patterns work with case-insensitive classes
 * - Both uppercase and lowercase ranges match all letters with /i
 *
 * This ensures character classes properly integrate with the
 * case-insensitive flag for flexible pattern matching.
 */
define_function TestNAVRegexMatcherCharClassCaseInsensitive() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Case-Insensitive Character Classes *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_CHARCLASS_CASEINS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_CHARCLASS_CASEINS_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_CHARCLASS_CASEINS_PATTERN[x], REGEX_MATCHER_CHARCLASS_CASEINS_INPUT[x], collection)

        if (shouldMatch) {
            // Verify match success
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_CHARCLASS_CASEINS_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_CHARCLASS_CASEINS_INPUT[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_CHARCLASS_CASEINS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_CHARCLASS_CASEINS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVLog("'  Pattern: ', REGEX_MATCHER_CHARCLASS_CASEINS_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_CHARCLASS_CASEINS_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_CHARCLASS_CASEINS_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_CHARCLASS_CASEINS_EXPECTED_START[x]), itoa(collection.matches[1].fullMatch.start))
                NAVLog("'  Pattern: ', REGEX_MATCHER_CHARCLASS_CASEINS_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_CHARCLASS_CASEINS_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        } else {
            // Verify no match
            if (!NAVAssertTrue('Should not match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match', 'Match found')
                NAVLog("'  Pattern: ', REGEX_MATCHER_CHARCLASS_CASEINS_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_CHARCLASS_CASEINS_INPUT[x]")
                NAVLog("'  Matched: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
