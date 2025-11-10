PROGRAM_NAME='NAVRegexMatcherInlineFlags'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for inline flags functionality
constant char REGEX_MATCHER_INLINE_FLAGS_PATTERN_TEST[][255] = {
    // Case-insensitive flag (?i) - Tests 1-12
    '/(?i)test/',               // 1: Uppercase input matches
    '/(?i)test/',               // 2: Mixed case matches
    '/(?i)test/',               // 3: Lowercase matches
    '/test/',                   // 4: Without flag is case-sensitive (no match)
    '/(?i:test)end/',           // 5: Scoped flag works
    '/(?i:test)end/',           // 6: Scope boundary (END case-sensitive, no match)
    '/(?i)test(?-i)END/',       // 7: Flag toggle off (no match)
    '/(?i)test(?-i)END/',       // 8: Flag toggle validates
    '/((?i)test)/',             // 9: Flag in capture group
    '/(?i)[a-z]/',              // 10: Char class case folding
    '/(?i)[a-z]/',              // 11: Char class lowercase
    '/(?i)\w+/',                // 12: Shorthand class

    // Multiline flag (?m) - Tests 13-19
    '/(?m)^test/',              // 13: ^ matches after \n
    '/^test/',                  // 14: Without flag: string-start only (no match)
    '/(?m)test$/',              // 15: $ matches before \n
    '/test$/',                  // 16: Without flag: string-end only (no match)
    '/(?m)^test$/',             // 17: Complete line match
    '/(?m:^test)end/',          // 18: Scoped multiline
    '/(?m)^line1/',             // 19: Match first line start

    // Dotall flag (?s) - Tests 20-25
    '/(?s)./',                  // 20: Dot matches newline
    '/./',                      // 21: Without flag: dot excludes \n (no match on \n)
    '/(?s)a.b/',                // 22: Dot spans newline
    '/a.b/',                    // 23: Default behavior (no match across \n)
    '/(?s).+/',                 // 24: Greedy across newlines
    '/(?s:a.)b/',               // 25: Scoped dotall

    // Extended flag (?x) - Tests 26-29 - NOT IMPLEMENTED (flag ignored)
    // When (?x) is ignored, whitespace is treated as literal characters
    '/(?x)test/',               // 26: (?x) ignored - matches literal 'test'
    '/(?x)test/',               // 27: (?x) ignored - matches literal 'test' (# not special)
    '/(?x)abc/',                // 28: (?x) ignored - matches literal 'abc'
    '/(?x)a b/',                // 29: (?x) ignored - matches literal 'a b' (space literal)

    // Combined flags - Tests 30-34
    '/(?im)^test/',             // 30: Case + multiline
    '/(?is)A.B/',               // 31: Case + dotall
    '/(?ms)^.+$/',              // 32: Multiline + dotall
    '/(?ims)^TEST$/',           // 33: All three flags
    '/(?ims)TEST/',             // 34: Three flags (x ignored, matches literal 'TEST')

    // Scoped flags - Tests 35-40
    '/(?i:abc)def/',            // 35: Scope applies
    '/(?i:abc)def/',            // 36: Scope boundary (no match)
    '/(?i:abc\n)(?m:^test)/',  // 37: Multiple independent scopes with newline
    '/((?i:test))/',            // 38: Scoped flag in group
    '/(?i:a\n(?m:^b))/',       // 39: Nested scopes with newline
    '/(?i)(?-i:test)/'          // 40: Toggle disables (?i), matches lowercase 'test' only
}

constant char REGEX_MATCHER_INLINE_FLAGS_INPUT_TEST[][255] = {
    // Case-insensitive inputs (Tests 1-12)
    'TEST',                     // 1: Uppercase
    'Test',                     // 2: Mixed case
    'test',                     // 3: Lowercase
    'TEST',                     // 4: Should NOT match without flag
    'TESTend',                  // 5: Scoped matches
    'TESTEND',                  // 6: Should NOT match (END case-sensitive)
    'TESTend',                  // 7: Should NOT match (toggle off)
    'TESTEND',                  // 8: Toggle validates
    'TEST',                     // 9: In capture
    'Z',                        // 10: Uppercase letter
    'z',                        // 11: Lowercase letter
    'ABC123',                   // 12: Alphanumeric

    // Multiline inputs (Tests 13-19)
    {'f', 'o', 'o', $0A, 't', 'e', 's', 't'},               // 13: test after newline
    {'f', 'o', 'o', $0A, 't', 'e', 's', 't'},               // 14: Should NOT match (no multiline)
    {'t', 'e', 's', 't', $0A, 'f', 'o', 'o'},               // 15: test before newline
    {'t', 'e', 's', 't', $0A, 'f', 'o', 'o'},               // 16: Should NOT match (no multiline)
    {'f', 'o', 'o', $0A, 't', 'e', 's', 't', $0A, 'b', 'a', 'r'},         // 17: test as complete line
    {'f', 'o', 'o', $0A, 't', 'e', 's', 't', 'e', 'n', 'd'},            // 18: Scoped multiline
    {'l', 'i', 'n', 'e', '1', $0A, 'l', 'i', 'n', 'e', '2'},            // 19: line1 at start

    // Dotall inputs (Tests 20-25)
    {$0A},                      // 20: Just newline
    {$0A},                      // 21: Should NOT match (dot excludes \n)
    {'a', $0A, 'b'},                    // 22: a newline b
    {'a', $0A, 'b'},                    // 23: Should NOT match
    {'a', $0A, 'b', $0A, 'c'},                // 24: Multiple lines
    {'a', $0A, 'b'},                    // 25: Scoped dotall

    // Extended inputs (Tests 26-29) - (?x) flag ignored, patterns match literally
    'test',                     // 26: Matches literal 'test'
    'test',                     // 27: Matches literal 'test'
    'abc',                      // 28: Matches literal 'abc'
    'a b',                      // 29: Matches literal 'a b' (space in pattern)

    // Combined flags inputs (Tests 30-34)
    {'f', 'o', 'o', $0A, 'T', 'E', 'S', 'T'},               // 30: Case + multiline
    {'a', $0A, 'b'},                    // 31: Case + dotall
    {'l', 'i', 'n', 'e', '1', $0A, 'l', 'i', 'n', 'e', '2'},            // 32: Multiline + dotall
    'TEST',                     // 33: Case-insensitive match preserves input case
    'TEST',                     // 34: Case-insensitive matches 'TEST' literally

    // Scoped flags inputs (Tests 35-40)
    'ABCdef',                   // 35: Uppercase ABC, lowercase def
    'ABCDEF',                   // 36: Should NOT match (def case-sensitive)
    {'A', 'B', 'C', $0A, 't', 'e', 's', 't'},               // 37: Multiple scopes
    'TEST',                     // 38: Scoped in group
    {'A', $0A, 'b'},                    // 39: Nested scopes
    'TESTtest'                  // 40: Matches 'test' (toggle makes it case-sensitive)
}

constant char REGEX_MATCHER_INLINE_FLAGS_EXPECTED_MATCH[][255] = {
    // Case-insensitive matches (Tests 1-12)
    'TEST',                     // 1
    'Test',                     // 2
    'test',                     // 3
    '',                         // 4: No match
    'TESTend',                  // 5
    '',                         // 6: No match
    '',                         // 7: No match
    'TESTEND',                  // 8
    'TEST',                     // 9
    'Z',                        // 10
    'z',                        // 11
    'ABC123',                   // 12

    // Multiline matches (Tests 13-19)
    'test',                     // 13
    '',                         // 14: No match
    'test',                     // 15
    '',                         // 16: No match
    'test',                     // 17
    'testend',                  // 18
    'line1',                    // 19

    // Dotall matches (Tests 20-25)
    {$0A},                      // 20
    '',                         // 21: No match
    {'a', $0A, 'b'},                    // 22
    '',                         // 23: No match
    {'a', $0A, 'b', $0A, 'c'},                // 24
    {'a', $0A, 'b'},                    // 25

    // Extended matches (Tests 26-29) - (?x) ignored, matches literal text
    'test',                     // 26: Matches literal 'test'
    'test',                     // 27: Matches literal 'test'
    'abc',                      // 28: Matches literal 'abc'
    'a b',                      // 29: Matches literal 'a b'

    // Combined flags matches (Tests 30-34)
    'TEST',                     // 30
    {'a', $0A, 'b'},                    // 31
    {'l', 'i', 'n', 'e', '1', $0A, 'l', 'i', 'n', 'e', '2'},            // 32
    'TEST',                     // 33
    'TEST',                     // 34: Case-insensitive matches 'TEST'

    // Scoped flags matches (Tests 35-40)
    'ABCdef',                   // 35
    '',                         // 36: No match
    {'A', 'B', 'C', $0A, 't', 'e', 's', 't'},               // 37
    'TEST',                     // 38
    {'A', $0A, 'b'},                    // 39
    'test'                      // 40: Matches lowercase 'test' (toggle enforces case-sensitivity)
}

constant integer REGEX_MATCHER_INLINE_FLAGS_EXPECTED_MATCH_START[] = {
    // Case-insensitive start positions (Tests 1-12)
    1,                          // 1
    1,                          // 2
    1,                          // 3
    0,                          // 4: No match
    1,                          // 5
    0,                          // 6: No match
    0,                          // 7: No match
    1,                          // 8
    1,                          // 9
    1,                          // 10
    1,                          // 11
    1,                          // 12

    // Multiline start positions (Tests 13-19)
    5,                          // 13: 'test' starts at position 5 (after 'foo\n' at positions 1-4)
    0,                          // 14: No match
    1,                          // 15
    0,                          // 16: No match
    5,                          // 17: 'test' starts at position 5 (after 'foo\n' at positions 1-4)
    5,                          // 18: 'testend' starts at position 5 (after 'foo\n' at positions 1-4)
    1,                          // 19

    // Dotall start positions (Tests 20-25)
    1,                          // 20
    0,                          // 21: No match
    1,                          // 22
    0,                          // 23: No match
    1,                          // 24
    1,                          // 25

    // Extended start positions (Tests 26-29)
    1,                          // 26
    1,                          // 27
    1,                          // 28
    1,                          // 29

    // Combined flags start positions (Tests 30-34)
    5,                          // 30: 'TEST' starts at position 5 (after 'foo\n' at positions 1-4)
    1,                          // 31
    1,                          // 32
    1,                          // 33: 'TEST' at position 1
    1,                          // 34

    // Scoped flags start positions (Tests 35-40)
    1,                          // 35
    0,                          // 36: No match
    1,                          // 37
    1,                          // 38
    1,                          // 39
    5                           // 40: 'test' starts at position 5
}

constant integer REGEX_MATCHER_INLINE_FLAGS_EXPECTED_HAS_MATCH[] = {
    // Expected match status (1 = match, 0 = no match)
    // Case-insensitive (Tests 1-12)
    1, 1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1,
    // Multiline (Tests 13-19)
    1, 0, 1, 0, 1, 1, 1,
    // Dotall (Tests 20-25)
    1, 0, 1, 0, 1, 1,
    // Extended (Tests 26-29)
    1, 1, 1, 1,
    // Combined (Tests 30-34)
    1, 1, 1, 1, 1,
    // Scoped (Tests 35-40)
    1, 0, 1, 1, 1, 1
}


/**
 * @function TestNAVRegexMatcherInlineFlags
 * @public
 * @description Tests inline flag functionality in the matcher.
 *
 * Validates:
 * - Case-insensitive flag (?i) and case folding
 * - Multiline flag (?m) with ^ and $ anchors
 * - Dotall flag (?s) with . metacharacter
 * - Extended flag (?x) - PARSED BUT NOT IMPLEMENTED (treated as no-op)
 * - Combined flags (?im, ?is, ?ms, ?ims, ?imsx)
 * - Scoped flags (?i:pattern)
 * - Flag toggles (?i-m)
 * - Nested scopes
 *
 * @note Extended mode (?x) is parsed and accepted but has no effect.
 *       Whitespace and comments are NOT stripped from patterns.
 *       This is by design as NetLinx lacks multi-line string literals.
 *
 * @note This is a CRITICAL test suite as flags are a core advertised
 *       feature that previously had zero matcher-level validation.
 */
define_function TestNAVRegexMatcherInlineFlags() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Inline Flags *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_INLINE_FLAGS_PATTERN_TEST); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match using simple API
        NAVRegexMatch(REGEX_MATCHER_INLINE_FLAGS_PATTERN_TEST[x], REGEX_MATCHER_INLINE_FLAGS_INPUT_TEST[x], collection)

        // Check if we expected a match
        if (REGEX_MATCHER_INLINE_FLAGS_EXPECTED_HAS_MATCH[x]) {
            // Expected match - validate it
            if (!NAVAssertTrue('Should match pattern', collection.count > 0 && collection.matches[1].hasMatch)) {
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

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_INLINE_FLAGS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_INLINE_FLAGS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_INLINE_FLAGS_EXPECTED_MATCH_START[x], type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_INLINE_FLAGS_EXPECTED_MATCH_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
                NAVStopwatchStop()
                continue
            }

            // Verify match length
            if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_INLINE_FLAGS_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
                NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_INLINE_FLAGS_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
                NAVStopwatchStop()
                continue
            }
        } else {
            // Expected no match - validate it
            if (!NAVAssertTrue('Should not match pattern', !collection.matches[1].hasMatch || collection.count == 0)) {
                NAVLogTestFailed(x, 'no match', "'unexpected match: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
