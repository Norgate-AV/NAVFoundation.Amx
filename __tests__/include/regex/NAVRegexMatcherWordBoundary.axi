PROGRAM_NAME='NAVRegexMatcherWordBoundary'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for word boundary matching
constant char REGEX_MATCHER_WORD_BOUNDARY_PATTERN[][255] = {
    '/\bcat\b/',            // 1: Whole word "cat"
    '/\bcat/',              // 2: Word starting with "cat"
    '/cat\b/',              // 3: Word ending with "cat"
    '/\b\w{3}\b/',          // 4: Three-letter word
    '/\b\w{4}\b/',          // 5: Four-letter word
    '/\b\d+\b/',            // 6: Number as whole word
    '/\B\w+\B/',            // 7: Non-boundary (middle of word)
    '/\b[A-Z][a-z]+\b/',    // 8: Capitalized word
    '/\bthe\b/',            // 9: Word "the" (common word)
    '/\b\w+\b/i',           // 10: Any word (case-insensitive)
    '/\bcat\b/',            // 11: Should NOT match "scatter"
    '/\btest\b/',           // 12: Should NOT match "testing"
    '/\b\d{3}\b/',          // 13: Three digits as whole word
    '/\Bcat/',              // 14: NOT at word boundary before "cat" (matches "scatter")
    '/cat\B/',              // 15: NOT at word boundary after "cat" (matches "catch")
    '/\B\d\B/',             // 16: Digit NOT at boundaries (middle digit)
    '/\B\w{2}\B/',          // 17: Two chars NOT at boundaries
    '/\B[aeiou]\B/'         // 18: Vowel NOT at boundaries (middle of word)
}

constant char REGEX_MATCHER_WORD_BOUNDARY_INPUT[][255] = {
    'the cat sat',          // 1: Contains whole word "cat"
    'catch the cat',        // 2: "cat" at start of word
    'copycat is here',      // 3: "cat" at end of word
    'the cat sat on mat',   // 4: Has three-letter words
    'this test word',       // 5: Has four-letter words
    'Room 101 Floor 5',     // 6: Has numbers as words
    'testing',              // 7: Middle chars (estin)
    'The Quick Brown',      // 8: Capitalized words
    'the cat on the mat',   // 9: Multiple "the"
    'Hello WORLD',          // 10: Mixed case words
    'scatter about',        // 11: Should NOT match (cat in middle)
    'testing phase',        // 12: Should NOT match (test in middle)
    'abc123def',            // 13: Three digits NOT as whole word
    'scatter',              // 14: "cat" in middle (after "s")
    'catch',                // 15: "cat" in middle (before "ch")
    'a1b2c3',               // 16: Digits in middle
    'testing',              // 17: Two chars in middle
    'hello'                 // 18: Vowel in middle (e, l)
}

constant char REGEX_MATCHER_WORD_BOUNDARY_EXPECTED_MATCH[][255] = {
    'cat',                  // 1: Whole word
    'cat',                  // 2: "cat" in "catch"
    'cat',                  // 3: "cat" in "copycat"
    'the',                  // 4: First three-letter word
    'this',                 // 5: First four-letter word
    '101',                  // 6: First number
    'estin',                // 7: Middle of "testing"
    'The',                  // 8: First capitalized word
    'the',                  // 9: First "the"
    'Hello',                // 10: First word
    '',                     // 11: No match expected
    '',                     // 12: No match expected
    '',                     // 13: No match expected
    'cat',                  // 14: "cat" after "s"
    'cat',                  // 15: "cat" before "ch"
    '1',                    // 16: Middle digit "1" (in "a1b")
    'es',                   // 17: "es" in middle of "testing"
    'e'                     // 18: "e" in middle of "hello"
}

constant integer REGEX_MATCHER_WORD_BOUNDARY_EXPECTED_START[] = {
    5,                      // 1: "cat" at position 5
    1,                      // 2: "cat" at position 1 in "catch"
    5,                      // 3: "cat" at position 5 in "copycat"
    1,                      // 4: "the" at position 1
    1,                      // 5: "this" at position 1
    6,                      // 6: "101" at position 6
    2,                      // 7: "estin" at position 2 in "testing"
    1,                      // 8: "The" at position 1
    1,                      // 9: "the" at position 1
    1,                      // 10: "Hello" at position 1
    0,                      // 11: No match
    0,                      // 12: No match
    0,                      // 13: No match
    2,                      // 14: "cat" at position 2 in "scatter"
    1,                      // 15: "cat" at position 1 in "catch"
    2,                      // 16: "1" at position 2 in "a1b2c3"
    2,                      // 17: "es" at position 2 in "testing"
    2                       // 18: "e" at position 2 in "hello"
}

constant char REGEX_MATCHER_WORD_BOUNDARY_SHOULD_MATCH[] = {
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
    false,                  // 11: Should NOT match
    false,                  // 12: Should NOT match
    false,                  // 13: Should NOT match
    true,                   // 14: Should match (\B matches non-boundary)
    true,                   // 15: Should match (\B matches non-boundary)
    true,                   // 16: Should match (\B matches non-boundary)
    true,                   // 17: Should match (\B matches non-boundary)
    true                    // 18: Should match (\B matches non-boundary)
}


/**
 * @function TestNAVRegexMatcherWordBoundary
 * @public
 * @description Tests word boundary matching (\b and \B).
 *
 * Validates:
 * - \b at start of word
 * - \b at end of word
 * - \b surrounding whole words
 * - \b with quantifiers (\w{3})
 * - \B for non-boundaries
 * - Word boundaries with different character classes
 */
define_function TestNAVRegexMatcherWordBoundary() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Word Boundaries *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_WORD_BOUNDARY_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_WORD_BOUNDARY_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_WORD_BOUNDARY_PATTERN[x], REGEX_MATCHER_WORD_BOUNDARY_INPUT[x], collection)

        if (shouldMatch) {
            // Verify it matched
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_WORD_BOUNDARY_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_WORD_BOUNDARY_INPUT[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_WORD_BOUNDARY_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, 'Correct match text', 'Wrong match text')
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_WORD_BOUNDARY_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, 'Correct start position', 'Wrong start position')
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        } else {
            // Verify it didn't match
            if (!NAVAssertTrue('Should not match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match',  'Match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_WORD_BOUNDARY_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_WORD_BOUNDARY_INPUT[x]")
                NAVLog("'  Matched: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
