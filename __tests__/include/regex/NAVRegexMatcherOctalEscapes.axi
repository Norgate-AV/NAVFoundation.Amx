PROGRAM_NAME='NAVRegexMatcherOctalEscapes'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for octal escape matching
constant char REGEX_MATCHER_OCTAL_ESCAPES_PATTERN[][255] = {
    '/\101/',                       // 1: Single octal (A = 0x41 = 065)
    '/\141/',                       // 2: Single octal (a = 0x61 = 097)
    '/\40/',                        // 3: Space (0x20 = 032)
    '/\11/',                        // 4: Tab (0x09 = 011)
    '/\12/',                        // 5: Newline (0x0A = 012)
    '/\377/',                       // 6: Max octal value (0xFF = 255)
    '/\0/',                         // 7: Null character (0x00)
    '/\7/',                         // 8: Bell character (0x07)
    '/\101\102/',                   // 9: Multiple octals (AB)
    '/\110\145\154\154\157/',       // 10: Word with octals (Hello)
    '/\101+/',                      // 11: Octal with + quantifier
    '/\101*/',                      // 12: Octal with * quantifier
    '/\101?/',                      // 13: Octal with ? quantifier
    '/\101{2}/',                    // 14: Octal with exact quantifier
    '/\101{2,4}/',                  // 15: Octal with range quantifier
    '/[\101-\132]/',                // 16: Octal range in char class (A-Z)
    '/[\141-\172]/',                // 17: Octal range in char class (a-z)
    '/[\60-\71]/',                  // 18: Octal range in char class (0-9)
    '/[^\101-\132]/',               // 19: Negated octal range (not A-Z)
    '/[\101\105\111]/',             // 20: Multiple octals in char class (AEI)
    '/(\101)/',                     // 21: Octal in capture group
    '/(\101+)/',                    // 22: Octal quantified in group
    '/(\101)(\102)/',               // 23: Multiple octal groups
    '/(?:\101)/',                   // 24: Octal in non-capturing group
    '/^\101/',                      // 25: Octal with start anchor
    '/\101$/',                      // 26: Octal with end anchor
    '/\b\101/',                     // 27: Octal with word boundary
    '/\101|\102/',                  // 28: Octal with alternation
    '/\101\d+/',                    // 29: Octal with other escape
    '/(?=\101)\101/'                // 30: Octal in lookahead
}

constant char REGEX_MATCHER_OCTAL_ESCAPES_INPUT[][255] = {
    'A',                            // 1: Letter A
    'a',                            // 2: Letter a
    ' ',                            // 3: Space
    {$09},                          // 4: Tab character
    {$0A},                          // 5: Newline character
    {$FF},                          // 6: Max byte value
    {$00},                          // 7: Null byte
    {$07},                          // 8: Bell character
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

constant char REGEX_MATCHER_OCTAL_ESCAPES_EXPECTED_MATCH[][255] = {
    'A',                            // 1
    'a',                            // 2
    ' ',                            // 3
    {$09},                          // 4
    {$0A},                          // 5
    {$FF},                          // 6
    {$00},                          // 7
    {$07},                          // 8
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

constant integer REGEX_MATCHER_OCTAL_ESCAPES_EXPECTED_START[] = {
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
 * @function TestNAVRegexMatcherOctalEscapes
 * @public
 * @description Tests octal escape sequence matching (\NNN).
 *
 * Tests comprehensive octal escape functionality:
 * - Single digit octals (\0-\7)
 * - Double digit octals (\10-\77)
 * - Triple digit octals (\100-\377)
 * - Control characters (\0, \7, \11, \12)
 * - Multiple octal escapes in sequence
 * - Octal escapes with quantifiers (\*, +, ?, {n,m})
 * - Octal escapes in character classes ([\101-\132])
 * - Octal ranges and negated classes
 * - Octal escapes in groups (capturing and non-capturing)
 * - Octal escapes with anchors and boundaries
 * - Octal escapes with alternation
 * - Octal escapes in lookahead assertions
 *
 * NOTE: This tests octal escapes in contexts WITHOUT backreferences.
 * Ambiguous cases like /(a)\10/ are tested separately as they involve
 * disambiguation between backreferences and octal literals.
 *
 * @returns {void}
 */
define_function TestNAVRegexMatcherOctalEscapes() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Octal Escapes *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_OCTAL_ESCAPES_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match
        if (!NAVAssertTrue('Should match pattern', NAVRegexMatch(REGEX_MATCHER_OCTAL_ESCAPES_PATTERN[x], REGEX_MATCHER_OCTAL_ESCAPES_INPUT[x], collection))) {
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
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_OCTAL_ESCAPES_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_MATCHER_OCTAL_ESCAPES_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_OCTAL_ESCAPES_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_OCTAL_ESCAPES_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
            NAVStopwatchStop()
            continue
        }

        // Verify match length
        if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_MATCHER_OCTAL_ESCAPES_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_MATCHER_OCTAL_ESCAPES_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
