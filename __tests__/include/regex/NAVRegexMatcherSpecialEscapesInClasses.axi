PROGRAM_NAME='NAVRegexMatcherSpecialEscapesInClasses'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for special escape sequences in character classes
constant char REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_PATTERN[][255] = {
    '/[\n]/',                       // 1: Newline in character class
    '/[\r]/',                       // 2: Carriage return in character class
    '/[\t]/',                       // 3: Tab in character class
    '/[\f]/',                       // 4: Form feed in character class
    '/[\v]/',                       // 5: Vertical tab in character class
    '/[\a]/',                       // 6: Bell in character class
    '/[\e]/',                       // 7: Escape in character class
    '/[\n\r\t]/',                   // 8: Multiple special escapes in class
    '/[\n\r]/',                     // 9: Newline or carriage return
    '/[\t ]/',                      // 10: Tab or space
    '/[a-z\n]/',                    // 11: Lowercase letter or newline
    '/[A-Z\t]/',                    // 12: Uppercase letter or tab
    '/[0-9\r]/',                    // 13: Digit or carriage return
    '/[\d\n]/',                     // 14: Digit shorthand or newline
    '/[\w\t]/',                     // 15: Word char or tab
    '/[\s\n]/',                     // 16: Whitespace or newline (redundant but valid)
    '/[^\n]/',                      // 17: Anything except newline
    '/[^\r]/',                      // 18: Anything except carriage return
    '/[^\t]/',                      // 19: Anything except tab
    '/[^\n\r]/',                    // 20: Anything except newline or CR
    '/[\n]+/',                      // 21: One or more newlines in class
    '/[\t]+/',                      // 22: One or more tabs in class
    '/[\n\r\t]+/',                  // 23: One or more of any special escape
    '/[a-z\n]+/',                   // 24: One or more lowercase or newline
    '/[\x41\n]/',                   // 25: Hex escape and newline in class
    '/[\101\t]/',                   // 26: Octal escape and tab in class
    '/[a-z\x41\n]/',                // 27: Range, hex, and newline (from Lexer.md)
    '/[\d\t\n]/',                   // 28: Digit, tab, and newline
    '/[^\n\r\t]/',                  // 29: Negated - not newline, CR, or tab
    '/[\n\r\t\f\v]/'                // 30: All special whitespace escapes
}

constant char REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_INPUT[][255] = {
    {$0A},                          // 1: Newline
    {$0D},                          // 2: Carriage return
    {$09},                          // 3: Tab
    {$0C},                          // 4: Form feed
    {$0B},                          // 5: Vertical tab
    {$07},                          // 6: Bell
    {$1B},                          // 7: Escape
    {$09},                          // 8: Tab (matches one of [\n\r\t])
    {$0A},                          // 9: Newline (matches [\n\r])
    {$09},                          // 10: Tab (matches [\t ])
    'x',                            // 11: Letter x (matches [a-z\n])
    'T',                            // 12: Letter T (matches [A-Z\t])
    '5',                            // 13: Digit 5 (matches [0-9\r])
    '7',                            // 14: Digit 7 (matches [\d\n])
    'w',                            // 15: Letter w (matches [\w\t])
    ' ',                            // 16: Space (matches [\s\n])
    'a',                            // 17: Letter a (not newline)
    'b',                            // 18: Letter b (not CR)
    'c',                            // 19: Letter c (not tab)
    'x',                            // 20: Letter x (not newline or CR)
    {$0A, $0A},                      // 21: Two newlines
    {$09, $09, $09},                  // 22: Three tabs
    {$0A, $09, $0D},                  // 23: Newline, tab, CR
    {'a', 'b', 'c', $0A},                       // 24: "abc\n"
    'A',                            // 25: 'A' (matches \x41 or \n)
    'A',                            // 26: 'A' (matches \101 or \t)
    'A',                            // 27: 'A' (matches a-z, \x41, or \n)
    '5',                            // 28: Digit (matches [\d\t\n])
    'a',                            // 29: Letter (not newline, CR, or tab)
    {$0A}                           // 30: Newline (matches any in class)
}

constant char REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_EXPECTED_MATCH[][255] = {
    {$0A},                          // 1
    {$0D},                          // 2
    {$09},                          // 3
    {$0C},                          // 4
    {$0B},                          // 5
    {$07},                          // 6
    {$1B},                          // 7
    {$09},                          // 8
    {$0A},                          // 9
    {$09},                          // 10
    'x',                            // 11
    'T',                            // 12
    '5',                            // 13
    '7',                            // 14
    'w',                            // 15
    ' ',                            // 16
    'a',                            // 17
    'b',                            // 18
    'c',                            // 19
    'x',                            // 20
    {$0A, $0A},                      // 21
    {$09, $09, $09},                  // 22
    {$0A, $09, $0D},                  // 23
    {'a', 'b', 'c', $0A},                       // 24
    'A',                            // 25
    'A',                            // 26
    'A',                            // 27
    '5',                            // 28
    'a',                            // 29
    {$0A}                           // 30
}

constant integer REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_EXPECTED_START[] = {
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
 * @function TestNAVRegexMatcherSpecialEscapesInClasses
 * @public
 * @description Tests special escape sequences inside character classes.
 *
 * Validates:
 * - Individual special escapes in classes: [\n], [\r], [\t], [\f], [\v], [\a], [\e]
 * - Multiple special escapes: [\n\r\t]
 * - Special escapes with other characters: [\t ], [a-z\n]
 * - Special escapes with ranges: [a-z\n], [A-Z\t], [0-9\r]
 * - Special escapes with shorthands: [\d\n], [\w\t], [\s\n]
 * - Negated special escapes: [^\n], [^\r], [^\t]
 * - Quantifiers on classes with special escapes: [\n]+, [\t]+
 * - Mixed with hex escapes: [\x41\n]
 * - Mixed with octal escapes: [\101\t]
 * - Complex combinations: [a-z\x41\n] (documented in Lexer.md)
 * - All special whitespace escapes: [\n\r\t\f\v]
 *
 * CRITICAL: These patterns are documented as supported in Lexer.md
 * but had NO matcher test coverage prior to this test suite.
 */
define_function TestNAVRegexMatcherSpecialEscapesInClasses() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Special Escapes in Character Classes *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match
        if (!NAVAssertTrue('Should match pattern', NAVRegexMatch(REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_PATTERN[x], REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_INPUT[x], collection))) {
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
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
            NAVStopwatchStop()
            continue
        }

        // Verify match length
        if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_SPECIAL_ESCAPES_IN_CLASSES_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
