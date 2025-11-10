PROGRAM_NAME='NAVRegexMatcherGlobalFlags'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for global flags functionality
constant char REGEX_MATCHER_GLOBAL_FLAGS_PATTERN_TEST[][255] = {
    // Basic global flag /g - Tests 1-6
    '/\d+/g',                   // 1: Find all digit sequences
    '/\d+/',                    // 2: Without /g: first only
    '/(a+)/g',                  // 3: Multiple captures
    '/(?=a)/g',                 // 4: Empty match handling (lookahead)
    '/aa/g',                    // 5: Non-overlapping matches
    '/\w+/g',                   // 6: Word extraction

    // Global + Case-insensitive /gi - Tests 7-9
    '/test/gi',                 // 7: Multiple + case folding
    '/(t)est/gi',               // 8: Case + capture
    '/[a-z]+/gi',               // 9: Char class + global

    // Global + Multiline /gm - Tests 10-13
    '/^test/gm',                // 10: Multiple line starts
    '/test$/gm',                // 11: Multiple line ends
    '/^test$/gm',               // 12: Complete lines only
    '/^\w+/gm',                 // 13: Words at line starts

    // Global + Dotall /gs - Tests 14-15
    '/a.b/gs',                  // 14: Dot spans newlines
    '/.+/gs',                   // 15: Greedy across all

    // Global + Extended /gx - Tests 16-17 - (?x) NOT IMPLEMENTED (flag ignored)
    '/test/gx',                 // 16: x flag ignored, matches literal 'test'
    '/\d+/gx',                  // 17: x flag ignored, matches digit sequences

    // All flags /gims - Tests 18-19
    '/^test$/gims',             // 18: All flags combined
    '/^A.B$/gims',              // 19: Full combination

    // Flag syntax variations - Tests 20-25
    '/pattern/i',               // 20: Single inline flag
    '/pattern/gim',             // 21: Multiple flags
    '/pattern/',                // 22: No flags
    '/test/gi',                 // 23: Verify flag order doesn't matter
    '/test/ig',                 // 24: Reversed flag order
    '/test/g'                   // 25: Just global
}

constant char REGEX_MATCHER_GLOBAL_FLAGS_INPUT_TEST[][255] = {
    // Basic global inputs (Tests 1-6)
    '1 2 3',                    // 1: Three separate numbers
    '1 2 3',                    // 2: Same input, first only
    'aaa aa a',                 // 3: Three groups of a's
    'aaa',                      // 4: Three positions before each 'a'
    'aaaa',                     // 5: Two non-overlapping 'aa'
    'hello world',              // 6: Two words

    // Global + Case inputs (Tests 7-9)
    'Test TEST test',           // 7: Three case variations
    'Test test',                // 8: Two variations
    'ABC def GHI',              // 9: Three words different cases

    // Global + Multiline inputs (Tests 10-13)
    {'t', 'e', 's', 't', $0A, 't', 'e', 's', 't'},          // 10: test at two line starts
    {'t', 'e', 's', 't', $0A, 't', 'e', 's', 't', $0A, 't', 'e', 's', 't'},  // 11: test at three line ends
    {'f', 'o', 'o', $0A, 't', 'e', 's', 't', $0A, 't', 'e', 's', 't', $0A, 'b', 'a', 'r'},  // 12: Two complete 'test' lines
    {'l', 'i', 'n', 'e', '1', $0A, 'l', 'i', 'n', 'e', '2', $0A, 'l', 'i', 'n', 'e', '3'},  // 13: Three lines starting with words

    // Global + Dotall inputs (Tests 14-15)
    {'a', $0A, 'b', ' ', 'a', $0A, 'b'},            // 14: Two 'a.b' patterns
    {'a', $0A, 'b', $0A, 'c'},              // 15: All chars (greedy)

    // Global + Extended inputs (Tests 16-17)
    'test test',                // 16: Two matches
    '123 456',                  // 17: Two digit sequences

    // All flags inputs (Tests 18-19)
    {'T', 'E', 'S', 'T', $0A, 't', 'e', 's', 't', $0A, 'T', 'e', 's', 't'},  // 18: Three variations
    {'a', $0A, 'b', $0A, 'A', $0A, 'B'},            // 19: Two matches

    // Flag syntax inputs (Tests 20-25)
    'pattern',                  // 20: Simple match
    'pattern',                  // 21: Simple match
    'pattern',                  // 22: Simple match
    'test Test TEST',           // 23: Multiple case variations
    'test Test TEST',           // 24: Same as 23
    'test test test'            // 25: Three identical matches
}

// Expected match counts for MatchAll (always finds all matches)
constant integer REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_COUNT_MATCHALL[] = {
    // Basic global (Tests 1-6)
    3,      // 1: Three numbers
    3,      // 2: MatchAll finds all matches even without /g
    3,      // 3: Three groups
    3,      // 4: Three positions
    2,      // 5: Two non-overlapping 'aa'
    2,      // 6: Two words

    // Global + Case (Tests 7-9)
    3,      // 7: Three variations
    2,      // 8: Two variations
    3,      // 9: Three words

    // Global + Multiline (Tests 10-13)
    2,      // 10: Two line starts
    3,      // 11: Three line ends
    2,      // 12: Two complete lines
    3,      // 13: Three words at line starts

    // Global + Dotall (Tests 14-15)
    2,      // 14: Two patterns
    1,      // 15: One greedy match (all)

    // Global + Extended (Tests 16-17)
    2,      // 16: Two matches
    2,      // 17: Two digit sequences

    // All flags (Tests 18-19)
    3,      // 18: Three case variations
    2,      // 19: Two a.b patterns

    // Flag syntax (Tests 20-25)
    1,      // 20: One match
    1,      // 21: One match
    1,      // 22: One match
    3,      // 23: Three case variations
    3,      // 24: Three case variations
    3       // 25: Three matches
}

// Expected match counts for Match (respects /g flag)
constant integer REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_COUNT_MATCH[] = {
    // Basic global (Tests 1-6)
    3,      // 1: Three numbers (has /g)
    1,      // 2: First only (no /g)
    3,      // 3: Three groups (has /g)
    3,      // 4: Three positions (has /g)
    2,      // 5: Two non-overlapping 'aa' (has /g)
    2,      // 6: Two words (has /g)

    // Global + Case (Tests 7-9)
    3,      // 7: Three variations (has /g)
    2,      // 8: Two variations (has /g)
    3,      // 9: Three words (has /g)

    // Global + Multiline (Tests 10-13)
    2,      // 10: Two line starts (has /g)
    3,      // 11: Three line ends (has /g)
    2,      // 12: Two complete lines (has /g)
    3,      // 13: Three words at line starts (has /g)

    // Global + Dotall (Tests 14-15)
    2,      // 14: Two patterns (has /g)
    1,      // 15: One greedy match (has /g)

    // Global + Extended (Tests 16-17)
    2,      // 16: Two matches (has /g)
    2,      // 17: Two digit sequences (has /g)

    // All flags (Tests 18-19)
    3,      // 18: Three case variations (has /g)
    2,      // 19: Two a.b patterns (has /g)

    // Flag syntax (Tests 20-25)
    1,      // 20: One match (no /g)
    1,      // 21: One match (no /g)
    1,      // 22: One match (no /g)
    3,      // 23: Three case variations (has /g)
    3,      // 24: Three case variations (has /g)
    3       // 25: Three matches (has /g)
}

constant char REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_FIRST_MATCH[][255] = {
    // Basic global (Tests 1-6)
    '1',                        // 1: First number
    '1',                        // 2: First number
    'aaa',                      // 3: First group
    '',                         // 4: Empty match
    'aa',                       // 5: First 'aa'
    'hello',                    // 6: First word

    // Global + Case (Tests 7-9)
    'Test',                     // 7: First match
    'Test',                     // 8: First match
    'ABC',                      // 9: First word

    // Global + Multiline (Tests 10-13)
    'test',                     // 10: First test
    'test',                     // 11: First test
    'test',                     // 12: First complete line
    'line1',                    // 13: First word

    // Global + Dotall (Tests 14-15)
    {'a', $0A, 'b'},                    // 14: First pattern
    {'a', $0A, 'b', $0A, 'c'},                // 15: All (greedy)

    // Global + Extended (Tests 16-17)
    'test',                     // 16: First match
    '123',                      // 17: First digits

    // All flags (Tests 18-19)
    'TEST',                     // 18: First variation
    {'a', $0A, 'b'},                    // 19: First pattern

    // Flag syntax (Tests 20-25)
    'pattern',                  // 20
    'pattern',                  // 21
    'pattern',                  // 22
    'test',                     // 23: First (lowercase)
    'test',                     // 24: First (lowercase)
    'test'                      // 25: First match
}

constant integer REGEX_MATCHER_GLOBAL_FLAGS_TEST_COUNT = 25

/**
 * @function TestNAVRegexMatcherGlobalFlagsMatchAll
 * @description Tests NAVRegexMatchAll with global flags (/g, /gi, /gm, /gs, /gx)
 *
 * @note Extended mode (/gx) is parsed and accepted but has no effect.
 *       Whitespace and comments are NOT stripped from patterns.
 *       Tests 16-17 verify that /x flag is silently ignored.
 */
define_function TestNAVRegexMatcherGlobalFlagsMatchAll() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Global Flags (MatchAll Function) *****************'")

    for (x = 1; x <= REGEX_MATCHER_GLOBAL_FLAGS_TEST_COUNT; x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match - use MatchAll to find all occurrences
        if (!NAVRegexMatchAll(REGEX_MATCHER_GLOBAL_FLAGS_PATTERN_TEST[x], REGEX_MATCHER_GLOBAL_FLAGS_INPUT_TEST[x], collection)) {
            NAVLogTestFailed(x, 'match success', 'match failed')
            NAVStopwatchStop()
            continue
        }

        // Verify match status
        if (!NAVAssertIntegerEqual('Match status should be SUCCESS', MATCH_STATUS_SUCCESS, collection.status)) {
            NAVLogTestFailed(x, 'SUCCESS', itoa(collection.status))
            NAVStopwatchStop()
            continue
        }

        // Verify match count
        if (!NAVAssertIntegerEqual('Match count should be correct', REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_COUNT_MATCHALL[x], collection.count)) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_COUNT_MATCHALL[x]), itoa(collection.count))
            NAVStopwatchStop()
            continue
        }

        // Verify first match text (if count > 0)
        if (collection.count > 0) {
            if (!NAVAssertStringEqual('First match text should be correct', REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_FIRST_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_FIRST_MATCH[x], collection.matches[1].fullMatch.text)
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}

/**
 * @function TestNAVRegexMatcherGlobalFlagsMatch
 * @description Tests NAVRegexMatch with global flags (respects /g flag behavior)
 *
 * @note Match function respects /g flag: with /g finds all matches, without /g finds first only.
 * @note Extended mode (/gx) is parsed and accepted but has no effect.
 *       Tests 16-17 verify that /x flag is silently ignored.
 */
// Additional test: NAVRegexMatch should respect global flags even when not using MatchAll
define_function TestNAVRegexMatcherGlobalFlagsMatch() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Global Flags (Match Function) *****************'")

    for (x = 1; x <= REGEX_MATCHER_GLOBAL_FLAGS_TEST_COUNT; x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match
        if (!NAVRegexMatch(REGEX_MATCHER_GLOBAL_FLAGS_PATTERN_TEST[x], REGEX_MATCHER_GLOBAL_FLAGS_INPUT_TEST[x], collection)) {
            NAVLogTestFailed(x, 'match success', 'match failed')
            NAVStopwatchStop()
            continue
        }

        // Verify match status
        if (!NAVAssertIntegerEqual('Match status should be SUCCESS', MATCH_STATUS_SUCCESS, collection.status)) {
            NAVLogTestFailed(x, 'SUCCESS', itoa(collection.status))
            NAVStopwatchStop()
            continue
        }

        // Verify match count
        if (!NAVAssertIntegerEqual('Match count should be correct', REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_COUNT_MATCH[x], collection.count)) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_COUNT_MATCH[x]), itoa(collection.count))
            NAVStopwatchStop()
            continue
        }

        // Verify first match text (if count > 0)
        if (collection.count > 0) {
            if (!NAVAssertStringEqual('First match text should be correct', REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_FIRST_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_GLOBAL_FLAGS_EXPECTED_FIRST_MATCH[x], collection.matches[1].fullMatch.text)
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
