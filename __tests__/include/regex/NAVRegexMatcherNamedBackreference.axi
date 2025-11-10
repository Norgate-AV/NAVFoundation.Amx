PROGRAM_NAME='NAVRegexMatcherNamedBackreference'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for named backreference matching
constant char REGEX_MATCHER_NAMED_BACKREF_PATTERN[][255] = {
    '/(?P<letter>a)\k<letter>/',                // 1: Python-style named backref
    '/(?<letter>a)\k<letter>/',                 // 2: .NET-style named backref
    '/(?''letter''a)\k<letter>/',                 // 3: .NET quote style with named backref
    '/(?P<word>abc)\k<word>/',                  // 4: Multi-char named backref
    '/(?<digit>\d)\k<digit>/',                  // 5: Digit named backref
    '/(?P<char>\w)\k<char>/',                   // 6: Word char named backref
    '/(?P<first>a)(?P<second>b)\k<first>\k<second>/',  // 7: Two named backrefs
    '/(?<x>x)(?<y>y)(?<z>z)\k<x>\k<y>\k<z>/',  // 8: Three named backrefs
    '/(?P<letter>a)\k<letter>+/',               // 9: Named backref with quantifier
    '/(?<num>\d+)\k<num>/',                     // 10: Named group with quantifier
    '/(?P<char>[a-z])\k<char>/',                // 11: Named char class backref
    '/(?<word>abc)\k<word>/i',                  // 12: Case-insensitive named backref
    '/^(?P<letter>a)\k<letter>$/',              // 13: Anchored named backref
    '/\b(?<word>\w)\k<word>\b/',                // 14: Word boundary with named backref
    '/<(?P<tag>\w+).*?<\/\k<tag>>/',            // 15: HTML-like tag matching
    '/(?<quote>[''"]).*?\k<quote>/',              // 16: Matching quotes
    '/(?P<open>\()\w+(?P<close>\))\k<open>\w+\k<close>/',  // 17: Parenthesis matching
    '/(?<first>\w)(?<second>\w)\k<second>\k<first>/',  // 18: Palindrome-like pattern
    '/(?P<letter>a)\k<letter>/',                // 19: Should NOT match "ab"
    '/(?<digit>\d)\k<digit>/'                   // 20: Should NOT match "12"
}

constant char REGEX_MATCHER_NAMED_BACKREF_INPUT[][255] = {
    'aa',                       // 1: Simple repeated char
    'aa',                       // 2: Simple repeated char
    'aa',                       // 3: Simple repeated char
    'abcabc',                   // 4: Repeated sequence
    '11',                       // 5: Repeated digit
    'aa',                       // 6: Repeated word char
    'abab',                     // 7: Two named group repetition
    'xyzxyz',                   // 8: Three named group repetition
    'aaa',                      // 9: Multiple repetitions
    '123123',                   // 10: Repeated number sequence
    'aa',                       // 11: Repeated from char class
    'abcABC',                   // 12: Case variation
    'aa',                       // 13: Anchored repetition
    'aa',                       // 14: Word boundary repetition
    '<div>test</div>',          // 15: HTML tag
    '"hello world"',            // 16: Double quotes
    '(abc)(def)',               // 17: Matching parentheses
    'abba',                     // 18: Palindrome pattern
    'ab',                       // 19: Different chars (should NOT match)
    '12'                        // 20: Different digits (should NOT match)
}

constant char REGEX_MATCHER_NAMED_BACKREF_EXPECTED_MATCH[][255] = {
    'aa',                       // 1
    'aa',                       // 2
    'aa',                       // 3
    'abcabc',                   // 4
    '11',                       // 5
    'aa',                       // 6
    'abab',                     // 7
    'xyzxyz',                   // 8
    'aaa',                      // 9
    '123123',                   // 10
    'aa',                       // 11
    'abcABC',                   // 12
    'aa',                       // 13
    'aa',                       // 14
    '<div>test</div>',          // 15
    '"hello world"',            // 16
    '(abc)(def)',               // 17
    'abba',                     // 18
    '',                         // 19: No match
    ''                          // 20: No match
}

constant integer REGEX_MATCHER_NAMED_BACKREF_EXPECTED_START[] = {
    1,                          // 1
    1,                          // 2
    1,                          // 3
    1,                          // 4
    1,                          // 5
    1,                          // 6
    1,                          // 7
    1,                          // 8
    1,                          // 9
    1,                          // 10
    1,                          // 11
    1,                          // 12
    1,                          // 13
    1,                          // 14
    1,                          // 15
    1,                          // 16
    1,                          // 17
    1,                          // 18
    0,                          // 19: No match
    0                           // 20: No match
}

constant char REGEX_MATCHER_NAMED_BACKREF_SHOULD_MATCH[] = {
    true,                       // 1
    true,                       // 2
    true,                       // 3
    true,                       // 4
    true,                       // 5
    true,                       // 6
    true,                       // 7
    true,                       // 8
    true,                       // 9
    true,                       // 10
    true,                       // 11
    true,                       // 12
    true,                       // 13
    true,                       // 14
    true,                       // 15
    true,                       // 16
    true,                       // 17
    true,                       // 18
    false,                      // 19
    false                       // 20
}

/**
 * Test NAVRegexMatcher named backreferences
 *
 * Validates:
 * - Python-style named backrefs: \k<name>
 * - .NET-style named backrefs: \k<name>
 * - Named backrefs with all three named group syntaxes
 * - Multiple named backrefs in one pattern
 * - Named backrefs with quantifiers
 * - Case-insensitive named backrefs
 * - Named backrefs with anchors and boundaries
 * - Real-world patterns (HTML tags, quotes, parentheses)
 */
define_function TestNAVRegexMatcherNamedBackreference() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Named Backreferences *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_NAMED_BACKREF_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_NAMED_BACKREF_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_NAMED_BACKREF_PATTERN[x], REGEX_MATCHER_NAMED_BACKREF_INPUT[x], collection)

        if (shouldMatch) {
            // Verify it matched
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_NAMED_BACKREF_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_NAMED_BACKREF_INPUT[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct',
                                     REGEX_MATCHER_NAMED_BACKREF_EXPECTED_MATCH[x],
                                     collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_NAMED_BACKREF_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVLog("'  Pattern: ', REGEX_MATCHER_NAMED_BACKREF_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_NAMED_BACKREF_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct',
                                      REGEX_MATCHER_NAMED_BACKREF_EXPECTED_START[x],
                                      type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_NAMED_BACKREF_EXPECTED_START[x]), itoa(collection.matches[1].fullMatch.start))
                NAVLog("'  Pattern: ', REGEX_MATCHER_NAMED_BACKREF_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        } else {
            // Verify it didn't match
            if (!NAVAssertTrue('Should not match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match', 'Match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_NAMED_BACKREF_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_NAMED_BACKREF_INPUT[x]")
                NAVLog("'  Matched: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
