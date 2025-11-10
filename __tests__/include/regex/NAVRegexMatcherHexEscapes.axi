PROGRAM_NAME='NAVRegexMatcherHexEscapes'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for hex escape matching
constant char REGEX_MATCHER_HEX_ESCAPES_PATTERN[][255] = {
    '/\x41/',                       // 1: Single hex escape (A)
    '/\x61/',                       // 2: Single hex escape (a)
    '/\x20/',                       // 3: Space character
    '/\x09/',                       // 4: Tab character
    '/\x0A/',                       // 5: Newline character
    '/\xFF/',                       // 6: Max value (uppercase)
    '/\xff/',                       // 7: Max value (lowercase)
    '/\x00/',                       // 8: Null character
    '/\x41\x42/',                   // 9: Multiple hex escapes (AB)
    '/\x48\x65\x6C\x6C\x6F/',       // 10: Word with hex (Hello)
    '/\x41+/',                      // 11: Hex with + quantifier
    '/\x41*/',                      // 12: Hex with * quantifier
    '/\x41?/',                      // 13: Hex with ? quantifier
    '/\x41{2}/',                    // 14: Hex with exact quantifier
    '/\x41{2,4}/',                  // 15: Hex with range quantifier
    '/[\x41-\x5A]/',                // 16: Hex range in char class (A-Z)
    '/[\x61-\x7A]/',                // 17: Hex range in char class (a-z)
    '/[\x30-\x39]/',                // 18: Hex range in char class (0-9)
    '/[^\x41-\x5A]/',               // 19: Negated hex range (not A-Z)
    '/[\x41\x45\x49]/',             // 20: Multiple hex in char class (AEI)
    '/(\x41)/',                     // 21: Hex in capture group
    '/(\x41+)/',                    // 22: Hex quantified in group
    '/(\x41)(\x42)/',               // 23: Multiple hex groups
    '/(?:\x41)/',                   // 24: Hex in non-capturing group
    '/^\x41/',                      // 25: Hex with start anchor
    '/\x41$/',                      // 26: Hex with end anchor
    '/\b\x41/',                     // 27: Hex with word boundary
    '/\x41|\x42/',                  // 28: Hex with alternation
    '/\x41\d+/',                    // 29: Hex with other escape
    '/(?=\x41)\x41/'                // 30: Hex in lookahead
}

constant char REGEX_MATCHER_HEX_ESCAPES_INPUT[][255] = {
    'A',                            // 1: Letter A
    'a',                            // 2: Letter a
    ' ',                            // 3: Space
    {$09},                          // 4: Tab character
    {$0A},                          // 5: Newline character
    {$FF},                          // 6: Max byte value
    {$FF},                          // 7: Max byte value
    {$00},                          // 8: Null byte
    'AB',                           // 9: Two letters
    'Hello',                        // 10: Hello word
    'AAA',                          // 11: Multiple A's
    'test',                         // 12: No A's (empty match)
    'test',                         // 13: No A's (empty match)
    'AA',                           // 14: Exactly 2 A's
    'AAA',                          // 15: 3 A's (within 2-4)
    'X',                            // 16: Uppercase letter
    'x',                            // 17: Lowercase letter
    '5',                            // 18: Digit
    'x',                            // 19: Lowercase (not uppercase)
    'E',                            // 20: Letter E
    'A',                            // 21: Letter A
    'AAA',                          // 22: Multiple A's
    'AB',                           // 23: Letters AB
    'A',                            // 24: Letter A
    'ABC',                          // 25: A at start
    'XYZ A',                        // 26: A at end
    'test A word',                  // 27: A at word boundary
    'A',                            // 28: Letter A
    'A123',                         // 29: A followed by digits
    'A'                             // 30: Letter A
}

constant char REGEX_MATCHER_HEX_ESCAPES_EXPECTED_MATCH[][255] = {
    'A',                            // 1
    'a',                            // 2
    ' ',                            // 3
    {$09},                          // 4
    {$0A},                          // 5
    {$FF},                          // 6
    {$FF},                          // 7
    {$00},                          // 8
    'AB',                           // 9
    'Hello',                        // 10
    'AAA',                          // 11
    '',                             // 12: Empty match (zero A's)
    '',                             // 13: Empty match (zero A's)
    'AA',                           // 14
    'AAA',                          // 15
    'X',                            // 16
    'x',                            // 17
    '5',                            // 18
    'x',                            // 19
    'E',                            // 20
    'A',                            // 21
    'AAA',                          // 22
    'AB',                           // 23
    'A',                            // 24
    'A',                            // 25
    'A',                            // 26
    'A',                            // 27
    'A',                            // 28
    'A123',                         // 29
    'A'                             // 30
}

constant integer REGEX_MATCHER_HEX_ESCAPES_EXPECTED_START[] = {
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
    1,                              // 12: Empty match at start
    1,                              // 13: Empty match at start
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
    5,                              // 26: A at position 5 in "XYZ A"
    6,                              // 27: A at position 6 in "test A word"
    1,                              // 28
    1,                              // 29
    1                               // 30
}

/**
 * @function TestNAVRegexMatcherHexEscapes
 * @public
 * @description Tests hexadecimal escape sequence matching (\xNN).
 *
 * Tests comprehensive hex escape functionality:
 * - Basic hex escapes (\x41 = 'A', \x61 = 'a')
 * - Control characters (\x00, \x09, \x0A, \xFF)
 * - Multiple hex escapes in sequence
 * - Hex escapes with quantifiers (\*, +, ?, {n,m})
 * - Hex escapes in character classes ([\x41-\x5A])
 * - Hex ranges and negated classes
 * - Hex escapes in groups (capturing and non-capturing)
 * - Hex escapes with anchors and boundaries
 * - Hex escapes with alternation
 * - Hex escapes in lookahead assertions
 *
 * @returns {void}
 */
define_function TestNAVRegexMatcherHexEscapes() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Hex Escapes *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_HEX_ESCAPES_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match
        if (!NAVAssertTrue('Should match pattern', NAVRegexMatch(REGEX_MATCHER_HEX_ESCAPES_PATTERN[x], REGEX_MATCHER_HEX_ESCAPES_INPUT[x], collection))) {
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
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_HEX_ESCAPES_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_MATCHER_HEX_ESCAPES_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_HEX_ESCAPES_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_HEX_ESCAPES_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
            NAVStopwatchStop()
            continue
        }

        // Verify match length
        if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_HEX_ESCAPES_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_HEX_ESCAPES_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
