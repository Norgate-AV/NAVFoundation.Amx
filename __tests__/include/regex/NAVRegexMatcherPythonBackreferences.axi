PROGRAM_NAME='NAVRegexMatcherPythonBackreferences'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for Python-style named backreference matching (?P=name)
constant char REGEX_MATCHER_PYTHON_BACKREF_PATTERN[][255] = {
    '/(?P<letter>a)(?P=letter)/',                           // 1: Basic Python-style backref
    '/(?P<name>test)(?P=name)/',                            // 2: Multi-char with Python backref
    '/(?P<first>a)(?P<second>b)(?P=first)(?P=second)/',     // 3: Multiple groups, two Python backrefs
    '/(?P<first>a)(?P<second>b)(?P=second)(?P=first)/',     // 4: Multiple groups, two Python backrefs reversed
    '/(?P<a>x)(?P<b>y)(?P=a)(?P=b)/',                       // 5: Two Python backrefs
    '/(?P<word>a)(?P=word)(?P=word)/',                      // 6: Same Python backref multiple times
    '/(?P<outer>(?P<inner>a))(?P=inner)/',                  // 7: Nested groups with Python backref to inner
    '/(?P<outer>(?P<inner>a))(?P=outer)/',                  // 8: Nested groups with Python backref to outer
    '/(?P<char>\w)(?P=char)+/',                             // 9: Python backref with quantifier
    '/(?P<digit>\d)(?P=digit)*/',                           // 10: Python backref with * quantifier
    '/(?P<letter>[a-z])(?P=letter)/',                       // 11: Python backref with character class
    '/<(?P<tag>\w+)>.*?<\/(?P=tag)>/',                        // 12: Python backref for HTML-like tags (opening tag name)
    '/(?P<quote>[''"]).*?(?P=quote)/',                        // 13: Python backref for quote matching
    '/(?P<word>\w+)\s+(?P=word)/',                          // 14: Python backref with whitespace
    '/(?P<a>.)(?P<b>.)(?P=b)(?P=a)/',                       // 15: Python palindrome pattern (abba)
    '/(?<word>a)(?P=word)/',                                // 16: PCRE group with Python backref
    '/(?''word''a)(?P=word)/',                                // 17: PCRE quote group with Python backref
    '/(?P<name>a)\k<name>(?P=name)/',                       // 18: Mixed PCRE and Python backrefs
    '/(a)(?P<named>b)(?P=named)\1/',                        // 19: Numbered and Python named backref
    '/(?P<x>a)(?P<y>b)(?P=x)(?P=y)/',                       // 20: Multiple different Python backrefs
    '/(?P<word>a)(?:(?P=word))/',                           // 21: Python backref in non-capturing group
    '/(?P<word>test)(?P=word)/i',                           // 22: Case-insensitive Python backref
    '/^(?P<char>a)(?P=char)$/',                             // 23: Anchored Python backref
    '/\b(?P<letter>\w)(?P=letter)\b/',                      // 24: Word boundary with Python backref
    '/(?P<num>\d+)(?P=num)/',                               // 25: Captured group with quantifier
    '/(?P<bracket>[\[\]])(?P=bracket)/',                    // 26: Matching same bracket type
    '/(?P<paren>[()]) (?P=paren)/',                         // 27: Matching same paren type
    '/(?P<word>a)(?P=word)/',                               // 28: Should NOT match "ab"
    '/(?P<digit>\d)(?P=digit)/',                            // 29: Should NOT match "12"
    '/(?P<char>.)(?P=char)/'                                // 30: Should NOT match "xy"
}

constant char REGEX_MATCHER_PYTHON_BACKREF_INPUT[][255] = {
    'aa',                       // 1: Simple repeated char
    'testtest',                 // 2: Repeated word
    'abab',                     // 3: Two groups in order
    'abba',                     // 4: Two groups reversed (palindrome)
    'xyxy',                     // 5: Two named group repetition
    'aaa',                      // 6: Multiple repetitions of same group
    'aa',                       // 7: Nested, backref to inner
    'aa',                       // 8: Nested, backref to outer
    'aaa',                      // 9: Char with one-or-more quantifier
    '1',                        // 10: Char with zero-or-more quantifier (no repetition)
    'aa',                       // 11: Repeated from char class
    '<div>test</div>',            // 12: HTML tag name matching (div and /div)
    '"hello world"',            // 13: Double quotes
    'test test',                // 14: Repeated word with space
    'abba',                     // 15: Palindrome pattern
    'aa',                       // 16: PCRE group, Python backref
    'aa',                       // 17: PCRE quote group, Python backref
    'aaa',                      // 18: Mixed PCRE and Python backrefs
    'abba',                     // 19: Numbered and named backref
    'abab',                     // 20: Multiple different backrefs
    'aa',                       // 21: Python backref in non-capturing group
    'testTEST',                 // 22: Case variation
    'aa',                       // 23: Anchored repetition
    'aa',                       // 24: Word boundary repetition
    '123123',                   // 25: Repeated number sequence
    '[[',                       // 26: Matching brackets (consecutive)
    '( (',                      // 27: Matching parentheses (with space)
    'ab',                       // 28: Different chars (should NOT match)
    '12',                       // 29: Different digits (should NOT match)
    'xy'                        // 30: Different chars (should NOT match)
}

constant char REGEX_MATCHER_PYTHON_BACKREF_EXPECTED_MATCH[][255] = {
    'aa',                       // 1
    'testtest',                 // 2
    'abab',                     // 3
    'abba',                     // 4
    'xyxy',                     // 5
    'aaa',                      // 6
    'aa',                       // 7
    'aa',                       // 8
    'aaa',                      // 9
    '1',                        // 10
    'aa',                       // 11
    '<div>test</div>',          // 12
    '"hello world"',            // 13
    'test test',                // 14
    'abba',                     // 15
    'aa',                       // 16
    'aa',                       // 17
    'aaa',                      // 18
    'abba',                     // 19
    'abab',                     // 20
    'aa',                       // 21
    'testTEST',                 // 22
    'aa',                       // 23
    'aa',                       // 24
    '123123',                   // 25
    '[[',                       // 26
    '( (',                      // 27
    '',                         // 28: No match
    '',                         // 29: No match
    ''                          // 30: No match
}

constant integer REGEX_MATCHER_PYTHON_BACKREF_EXPECTED_START[] = {
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
    1,                          // 19
    1,                          // 20
    1,                          // 21
    1,                          // 22
    1,                          // 23
    1,                          // 24
    1,                          // 25
    1,                          // 26
    1,                          // 27
    0,                          // 28: No match
    0,                          // 29: No match
    0                           // 30: No match
}

constant char REGEX_MATCHER_PYTHON_BACKREF_SHOULD_MATCH[] = {
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
    true,                       // 19
    true,                       // 20
    true,                       // 21
    true,                       // 22
    true,                       // 23
    true,                       // 24
    true,                       // 25
    true,                       // 26
    true,                       // 27
    false,                      // 28
    false,                      // 29
    false                       // 30
}

/**
 * @function TestNAVRegexMatcherPythonBackreferences
 * @public
 * @description Tests Python-style named backreference matching (?P=name) in the matcher.
 *
 * This validates that the matcher correctly executes patterns containing Python-style
 * backreferences by matching captured content from named groups.
 *
 * Critical properties tested:
 * 1. (?P=name) backreferences match exact captured content
 * 2. Multiple (?P=name) backreferences in one pattern work correctly
 * 3. Works with (?P<name>...) groups (Python-style)
 * 4. Works with (?<name>...) groups (PCRE-style)
 * 5. Works with (?'name'...) groups (PCRE quotes-style)
 * 6. Can mix (?P=name) with \k<name> syntax in same pattern
 * 7. Can mix with numbered backreferences
 * 8. Works with quantifiers on backreferences
 * 9. Works with anchors and word boundaries
 * 10. Case-insensitive matching works correctly
 * 11. Nested groups with Python backreferences work correctly
 * 12. Real-world patterns (HTML tags, quotes, brackets) work
 * 13. Negative tests: Different content correctly fails to match
 *
 * Why this matters:
 * - Provides Python regex compatibility at matcher level
 * - Validates that parser's NFA_STATE_BACKREF states execute correctly
 * - Ensures (?P=name) and \k<name> have identical matching behavior
 * - Critical for users migrating Python patterns to NAVFoundation
 *
 * Example: /(?P<word>test)(?P=word)/ should:
 * - Capture "test" in group 1 (named "word")
 * - Match second "test" via backreference
 * - Fail to match "test" followed by different content
 */
define_function TestNAVRegexMatcherPythonBackreferences() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Python-Style Backreferences (?P=name) *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_PYTHON_BACKREF_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char shouldMatch

        shouldMatch = REGEX_MATCHER_PYTHON_BACKREF_SHOULD_MATCH[x]

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_PYTHON_BACKREF_PATTERN[x], REGEX_MATCHER_PYTHON_BACKREF_INPUT[x], collection)

        if (shouldMatch) {
            // Verify it matched
            if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
                NAVLogTestFailed(x, 'Expected match', 'No match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_PYTHON_BACKREF_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_PYTHON_BACKREF_INPUT[x]")
                NAVLog("'  Status:  ', itoa(collection.status)")
                NAVLog("'  Count:   ', itoa(collection.count)")
                NAVStopwatchStop()
                continue
            }

            // Verify matched text
            if (!NAVAssertStringEqual('Matched text should be correct',
                                     REGEX_MATCHER_PYTHON_BACKREF_EXPECTED_MATCH[x],
                                     collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_MATCHER_PYTHON_BACKREF_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
                NAVLog("'  Pattern: ', REGEX_MATCHER_PYTHON_BACKREF_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_PYTHON_BACKREF_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify match start position
            if (!NAVAssertIntegerEqual('Match start position should be correct',
                                      REGEX_MATCHER_PYTHON_BACKREF_EXPECTED_START[x],
                                      type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(REGEX_MATCHER_PYTHON_BACKREF_EXPECTED_START[x]), itoa(collection.matches[1].fullMatch.start))
                NAVLog("'  Pattern: ', REGEX_MATCHER_PYTHON_BACKREF_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        } else {
            // Verify it didn't match
            if (!NAVAssertTrue('Should not match pattern', (collection.status != MATCH_STATUS_SUCCESS || collection.count == 0))) {
                NAVLogTestFailed(x, 'Expected no match', 'Match')
                NAVLog("'  Pattern: ', REGEX_MATCHER_PYTHON_BACKREF_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_MATCHER_PYTHON_BACKREF_INPUT[x]")
                NAVLog("'  Matched: ', collection.matches[1].fullMatch.text")
                NAVStopwatchStop()
                continue
            }

            NAVLogTestPassed(x)
        }

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
