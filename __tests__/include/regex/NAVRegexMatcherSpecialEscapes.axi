PROGRAM_NAME='NAVRegexMatcherSpecialEscapes'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for special escape sequence matching
constant char REGEX_MATCHER_SPECIAL_ESCAPES_PATTERN[][255] = {
    '/\n/',                         // 1: Match newline
    '/\r/',                         // 2: Match carriage return
    '/\t/',                         // 3: Match tab
    '/\f/',                         // 4: Match form feed
    '/\v/',                         // 5: Match vertical tab
    '/\a/',                         // 6: Match bell
    '/\e/',                         // 7: Match escape
    '/\r\n/',                       // 8: Match Windows line ending (CR+LF)
    '/\d+\n/',                      // 9: Digits followed by newline
    '/\w+\t\w+/',                   // 10: Words separated by tab
    '/\w+\n\w+/',                   // 11: Words separated by newline
    '/\s/',                         // 12: Verify \s matches tab
    '/\s/',                         // 13: Verify \s matches newline
    '/\s/',                         // 14: Verify \s matches carriage return
    '/\s/',                         // 15: Verify \s matches form feed
    '/\s/',                         // 16: Verify \s matches vertical tab
    '/\S/',                         // 17: Verify \S does NOT match tab
    '/\S/',                         // 18: Verify \S does NOT match newline
    '/line1\nline2/',               // 19: Multi-line literal with \n
    '/\t+/',                        // 20: One or more tabs
    '/\n+/',                        // 21: One or more newlines
    '/\t{2}/',                      // 22: Exactly two tabs
    '/\n{3}/',                      // 23: Exactly three newlines
    '/^\w+\n/',                     // 24: Word at start followed by newline
    '/\n\w+$/',                     // 25: Newline followed by word at end
    '/\w+\t\d+/',                   // 26: Word, tab, digits
    '/\r\n\r\n/',                   // 27: Two Windows line endings
    '/[ \t]/',                      // 28: Space or tab (literal space + \t)
    '/\d+\.\d+\n/',                 // 29: Decimal number with newline
    '/\t\t\t/'                      // 30: Three consecutive tabs
}

constant char REGEX_MATCHER_SPECIAL_ESCAPES_INPUT[][255] = {
    {$0A},                          // 1: Newline character (LF)
    {$0D},                          // 2: Carriage return (CR)
    {$09},                          // 3: Tab character
    {$0C},                          // 4: Form feed
    {$0B},                          // 5: Vertical tab
    {$07},                          // 6: Bell
    {$1B},                          // 7: Escape character
    {$0D, $0A},                      // 8: CR+LF sequence
    {'1', '2', '3', $0A},                       // 9: "123\n"
    {'h', 'e', 'l', 'l', 'o', $09, 'w', 'o', 'r', 'l', 'd'},                // 10: "hello\tworld"
    {'f', 'o', 'o', $0A, 'b', 'a', 'r'},                    // 11: "foo\nbar"
    {$09},                          // 12: Tab (should match \s)
    {$0A},                          // 13: Newline (should match \s)
    {$0D},                          // 14: CR (should match \s)
    {$0C},                          // 15: Form feed (should match \s)
    {$0B},                          // 16: Vertical tab (should match \s)
    'x',                            // 17: Letter x (should match \S - NOT whitespace)
    'a',                            // 18: Letter a (should match \S - NOT whitespace)
    {'l', 'i', 'n', 'e', '1', $0A, 'l', 'i', 'n', 'e', '2'},                // 19: "line1\nline2"
    {$09, $09, $09},                  // 20: Three tabs
    {$0A, $0A, $0A},                  // 21: Three newlines
    {$09, $09},                      // 22: Two tabs
    {$0A, $0A, $0A},                  // 23: Three newlines
    {'t', 'e', 's', 't', $0A},                      // 24: "test\n" at start
    {$0A, 'e', 'n', 'd'},                       // 25: "\nend" at end
    {'a', 'b', 'c', $09, '1', '2', '3'},                    // 26: "abc\t123"
    {$0D, $0A, $0D, $0A},              // 27: "\r\n\r\n"
    ' ',                            // 28: Space (should match)
    {'3', '.', '1', '4', $0A},                      // 29: "3.14\n"
    {$09, $09, $09}                   // 30: Three tabs
}

constant char REGEX_MATCHER_SPECIAL_ESCAPES_EXPECTED_MATCH[][255] = {
    {$0A},                          // 1
    {$0D},                          // 2
    {$09},                          // 3
    {$0C},                          // 4
    {$0B},                          // 5
    {$07},                          // 6
    {$1B},                          // 7
    {$0D, $0A},                      // 8
    {'1', '2', '3', $0A},                       // 9
    {'h', 'e', 'l', 'l', 'o', $09, 'w', 'o', 'r', 'l', 'd'},                // 10
    {'f', 'o', 'o', $0A, 'b', 'a', 'r'},                    // 11
    {$09},                          // 12
    {$0A},                          // 13
    {$0D},                          // 14
    {$0C},                          // 15
    {$0B},                          // 16
    'x',                            // 17
    'a',                            // 18
    {'l', 'i', 'n', 'e', '1', $0A, 'l', 'i', 'n', 'e', '2'},                // 19
    {$09, $09, $09},                  // 20: All three tabs
    {$0A, $0A, $0A},                  // 21: All three newlines
    {$09, $09},                      // 22: Two tabs
    {$0A, $0A, $0A},                  // 23: Three newlines
    {'t', 'e', 's', 't', $0A},                      // 24
    {$0A, 'e', 'n', 'd'},                       // 25
    {'a', 'b', 'c', $09, '1', '2', '3'},                    // 26
    {$0D, $0A, $0D, $0A},              // 27
    ' ',                            // 28
    {'3', '.', '1', '4', $0A},                      // 29
    {$09, $09, $09}                   // 30
}

constant integer REGEX_MATCHER_SPECIAL_ESCAPES_EXPECTED_START[] = {
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
    1,                              // 21
    1,                              // 22
    1,                              // 23
    1,                              // 24
    1,                              // 25
    1,                              // 26
    1,                              // 27
    1,                              // 28
    1,                              // 29
    1                               // 30
}


/**
 * @function TestNAVRegexMatcherSpecialEscapes
 * @public
 * @description Tests special escape sequence matching (\n, \r, \t, \f, \v, \a, \e).
 *
 * Validates:
 * - Newline character (\n = ASCII 10)
 * - Carriage return (\r = ASCII 13)
 * - Tab character (\t = ASCII 9)
 * - Form feed (\f = ASCII 12)
 * - Vertical tab (\v = ASCII 11)
 * - Bell (\a = ASCII 7)
 * - Escape (\e = ASCII 27)
 * - Windows line endings (\r\n)
 * - Special escapes combined with other patterns (\d+\n, \w+\t\w+)
 * - \s matching all whitespace characters
 * - \S NOT matching whitespace characters
 * - Quantifiers with special escapes (\t+, \n{2})
 * - Anchors with special escapes (^\w+\n)
 */
define_function TestNAVRegexMatcherSpecialEscapes() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Special Escapes *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_SPECIAL_ESCAPES_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match
        if (!NAVAssertTrue('Should match pattern', NAVRegexMatch(REGEX_MATCHER_SPECIAL_ESCAPES_PATTERN[x], REGEX_MATCHER_SPECIAL_ESCAPES_INPUT[x], collection))) {
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
        if (!NAVAssertIntegerEqual('Match count should be 1', 1, collection.count)) {
            NAVLogTestFailed(x, '1', itoa(collection.count))
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
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_SPECIAL_ESCAPES_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_MATCHER_SPECIAL_ESCAPES_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_SPECIAL_ESCAPES_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_SPECIAL_ESCAPES_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
            NAVStopwatchStop()
            continue
        }

        // Verify match length
        if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_SPECIAL_ESCAPES_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_SPECIAL_ESCAPES_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
