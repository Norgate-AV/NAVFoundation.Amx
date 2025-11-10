PROGRAM_NAME='NAVRegexMatcherEscapedChars'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for escaped character matching
constant char REGEX_MATCHER_ESCAPED_CHARS_PATTERN[][255] = {
    '/\d/',                         // 1: Digit shorthand
    '/\D/',                         // 2: Non-digit shorthand
    '/\w/',                         // 3: Word char shorthand
    '/\W/',                         // 4: Non-word char shorthand
    '/\s/',                         // 5: Whitespace shorthand
    '/\S/',                         // 6: Non-whitespace shorthand
    '/\./',                         // 7: Literal dot
    '/\*/',                         // 8: Literal asterisk
    '/\+/',                         // 9: Literal plus
    '/\?/',                         // 10: Literal question mark
    '/\[/',                         // 11: Literal left bracket
    '/\]/',                         // 12: Literal right bracket
    '/\(/',                         // 13: Literal left paren
    '/\)/',                         // 14: Literal right paren
    '/\{/',                         // 15: Literal left brace
    '/\}/',                         // 16: Literal right brace
    '/\|/',                         // 17: Literal pipe
    '/\\/',                         // 18: Literal backslash
    '/\^/',                         // 19: Literal caret
    '/\$/',                         // 20: Literal dollar
    '/\d+/',                        // 21: One or more digits
    '/\w+/',                        // 22: One or more word chars
    '/\s+/',                        // 23: One or more whitespace
    '/\d+\.\d+/',                   // 24: Decimal number
    '/\w+@\w+\.\w+/',               // 25: Email pattern with shorthands
    '/\(\d{3}\)\s\d{3}-\d{4}/',     // 26: Phone (555) 123-4567
    '/\$\d+\.\d{2}/',               // 27: Currency $12.34
    '/\w+\s\w+/',                   // 28: Two words
    '/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/',  // 29: IP address
    '/\[\w+\]/'                     // 30: Word in brackets
}

constant char REGEX_MATCHER_ESCAPED_CHARS_INPUT[][255] = {
    '5',                            // 1: Digit
    'a',                            // 2: Non-digit (letter)
    'w',                            // 3: Word char
    '*',                            // 4: Non-word char
    ' ',                            // 5: Space
    'x',                            // 6: Non-whitespace
    'test.txt',                     // 7: Contains literal dot
    '2*3',                          // 8: Contains literal asterisk
    '2+3',                          // 9: Contains literal plus
    'ok?',                          // 10: Contains literal question mark
    '[test]',                       // 11: Contains literal left bracket
    '[test]',                       // 12: Contains literal right bracket
    '(test)',                       // 13: Contains literal left paren
    '(test)',                       // 14: Contains literal right paren
    '{key}',                        // 15: Contains literal left brace
    '{key}',                        // 16: Contains literal right brace
    'a|b',                          // 17: Contains literal pipe
    'C:\path',                      // 18: Contains literal backslash
    '^start',                       // 19: Contains literal caret
    'cost$10',                      // 20: Contains literal dollar
    '12345',                        // 21: Digits
    'test',                         // 22: Word chars
    '   ',                          // 23: Spaces
    '3.14',                         // 24: Decimal
    'user@example.com',             // 25: Email
    '(555) 123-4567',               // 26: Phone number
    '$12.34',                       // 27: Currency
    'hello world',                  // 28: Two words
    '192.168.1.1',                  // 29: IP address
    '[test]'                        // 30: Word in brackets
}

constant char REGEX_MATCHER_ESCAPED_CHARS_EXPECTED_MATCH[][255] = {
    '5',                            // 1
    'a',                            // 2
    'w',                            // 3
    '*',                            // 4
    ' ',                            // 5
    'x',                            // 6
    '.',                            // 7
    '*',                            // 8
    '+',                            // 9
    '?',                            // 10
    '[',                            // 11
    ']',                            // 12
    '(',                            // 13
    ')',                            // 14
    '{',                            // 15
    '}',                            // 16
    '|',                            // 17
    '\',                            // 18
    '^',                            // 19
    '$',                            // 20
    '12345',                        // 21
    'test',                         // 22
    '   ',                          // 23
    '3.14',                         // 24
    'user@example.com',             // 25
    '(555) 123-4567',               // 26
    '$12.34',                       // 27
    'hello world',                  // 28
    '192.168.1.1',                  // 29
    '[test]'                        // 30
}

constant integer REGEX_MATCHER_ESCAPED_CHARS_EXPECTED_START[] = {
    1,                              // 1
    1,                              // 2
    1,                              // 3
    1,                              // 4
    1,                              // 5
    1,                              // 6
    5,                              // 7: Dot at position 5 in "test.txt"
    2,                              // 8: Asterisk at position 2 in "2*3"
    2,                              // 9: Plus at position 2 in "2+3"
    3,                              // 10: Question mark at position 3 in "ok?"
    1,                              // 11: Left bracket at position 1
    6,                              // 12: Right bracket at position 6 in "[test]"
    1,                              // 13: Left paren at position 1
    6,                              // 14: Right paren at position 6 in "(test)"
    1,                              // 15: Left brace at position 1
    5,                              // 16: Right brace at position 5 in "{key}"
    2,                              // 17: Pipe at position 2 in "a|b"
    3,                              // 18: Backslash at position 3 in "C:\"
    1,                              // 19: Caret at position 1
    5,                              // 20: Dollar at position 5 in "cost$10"
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
 * @function TestNAVRegexMatcherEscapedChars
 * @public
 * @description Tests escaped character matching (\d, \., \*, etc).
 *
 * Validates:
 * - Predefined character class shorthands (\d, \D, \w, \W, \s, \S)
 * - Escaped metacharacters (\., \*, \+, \?, etc)
 * - Escaped brackets and braces (\[, \], \(, \), \{, \})
 * - Escaped special chars (\|, \\, \^, \$)
 * - Shorthands with quantifiers (\d+, \w+, \s+)
 * - Complex patterns using multiple escaped characters
 * - Practical patterns (email, phone, currency, IP address)
 * - Literal matching of regex metacharacters
 */
define_function TestNAVRegexMatcherEscapedChars() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Escaped Characters *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_ESCAPED_CHARS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match
        if (!NAVAssertTrue('Should match pattern', NAVRegexMatch(REGEX_MATCHER_ESCAPED_CHARS_PATTERN[x], REGEX_MATCHER_ESCAPED_CHARS_INPUT[x], collection))) {
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
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_ESCAPED_CHARS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_MATCHER_ESCAPED_CHARS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_ESCAPED_CHARS_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_ESCAPED_CHARS_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
            NAVStopwatchStop()
            continue
        }

        // Verify match length
        if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_ESCAPED_CHARS_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_ESCAPED_CHARS_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
