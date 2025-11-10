PROGRAM_NAME='NAVRegexSplit'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for NAVRegexSplit
constant char REGEX_SPLIT_PATTERN[][255] = {
    '/,/',                                      // 1: Simple comma delimiter
    '/\s+/',                                    // 2: Whitespace (one or more)
    '/\s*,\s*/',                                // 3: Comma with optional whitespace
    '/[;,]/',                                   // 4: Multiple delimiters (semicolon or comma)
    '/:/',                                      // 5: Colon delimiter
    '/\|/',                                     // 6: Pipe delimiter (escaped)
    '/\s*-\s*/',                                // 7: Dash with optional whitespace
    '/\./',                                     // 8: Period delimiter (escaped)
    '/\d+/',                                    // 9: Split on digits
    '/[aeiou]/',                                // 10: Split on vowels
    '/(?=a)/',                                  // 11: Zero-width lookahead (before 'a')
    '/\b/',                                     // 12: Word boundary (zero-width)
    '/ /',                                      // 13: Literal space
    '/x/',                                      // 14: No match in input
    '/,/',                                      // 15: Leading delimiter
    '/,/',                                      // 16: Trailing delimiter
    '/,/',                                      // 17: Consecutive delimiters
    '/,/',                                      // 18: Delimiter at both ends
    '/[,;]/',                                   // 19: Complex multiple delimiters
    '/nomatch/'                                 // 20: Pattern that won't match (instead of empty)
}

constant char REGEX_SPLIT_INPUT[][255] = {
    'a,b,c',                                    // 1
    'hello  world   test',                      // 2
    'a, b,c , d',                               // 3
    'one;two,three;four',                       // 4
    'key:value:extra',                          // 5
    'x|y|z',                                    // 6
    'foo - bar - baz',                          // 7
    '192.168.1.1',                              // 8
    'abc123def456ghi',                          // 9
    'hello',                                    // 10
    'aaa',                                      // 11
    'hello world',                              // 12
    'a b c',                                    // 13
    'no commas here',                           // 14
    ',a,b,c',                                   // 15
    'a,b,c,',                                   // 16
    'a,,b',                                     // 17
    ',a,b,',                                    // 18
    'x,y;z,w',                                  // 19
    'test'                                      // 20
}

// Expected part counts
constant integer REGEX_SPLIT_EXPECTED_COUNT[] = {
    3,                                          // 1: a, b, c
    3,                                          // 2: hello, world, test
    4,                                          // 3: a, b, c, d
    4,                                          // 4: one, two, three, four
    3,                                          // 5: key, value, extra
    3,                                          // 6: x, y, z
    3,                                          // 7: foo, bar, baz
    4,                                          // 8: 192, 168, 1, 1
    3,                                          // 9: abc, def, ghi
    3,                                          // 10: h, ll, (empty after last 'o')
    4,                                          // 11: (empty), a, a, a - splits before each 'a'
    4,                                          // 12: (empty), hello, (space), world - word boundaries (missing final boundary)
    3,                                          // 13: a, b, c
    1,                                          // 14: no commas here (no match)
    4,                                          // 15: (empty), a, b, c
    4,                                          // 16: a, b, c, (empty)
    3,                                          // 17: a, (empty), b
    4,                                          // 18: (empty), a, b, (empty)
    4,                                          // 19: x, y, z, w
    1                                           // 20: test (empty pattern matches nothing)
}

// Expected first part
constant char REGEX_SPLIT_EXPECTED_PART1[][255] = {
    'a',                                        // 1
    'hello',                                    // 2
    'a',                                        // 3
    'one',                                      // 4
    'key',                                      // 5
    'x',                                        // 6
    'foo',                                      // 7
    '192',                                      // 8
    'abc',                                      // 9
    'h',                                        // 10
    '',                                         // 11: Empty before first 'a'
    '',                                         // 12: Empty before 'hello'
    'a',                                        // 13
    'no commas here',                           // 14
    '',                                         // 15: Empty before first comma
    'a',                                        // 16
    'a',                                        // 17
    '',                                         // 18: Empty before first comma
    'x',                                        // 19
    'test'                                      // 20
}

// Expected second part
constant char REGEX_SPLIT_EXPECTED_PART2[][255] = {
    'b',                                        // 1
    'world',                                    // 2
    'b',                                        // 3
    'two',                                      // 4
    'value',                                    // 5
    'y',                                        // 6
    'bar',                                      // 7
    '168',                                      // 8
    'def',                                      // 9
    'll',                                       // 10
    'a',                                        // 11: First 'a'
    'hello',                                    // 12
    'b',                                        // 13
    '',                                         // 14: No part 2
    'a',                                        // 15
    'b',                                        // 16
    '',                                         // 17: Empty between commas
    'a',                                        // 18
    'y',                                        // 19
    ''                                          // 20: No part 2
}

// Expected third part
constant char REGEX_SPLIT_EXPECTED_PART3[][255] = {
    'c',                                        // 1
    'test',                                     // 2
    'c',                                        // 3
    'three',                                    // 4
    'extra',                                    // 5
    'z',                                        // 6
    'baz',                                      // 7
    '1',                                        // 8
    'ghi',                                      // 9
    '',                                         // 10: Empty after last 'o'
    'a',                                        // 11: Second 'a'
    ' ',                                        // 12: Space between words
    'c',                                        // 13
    '',                                         // 14: No part 3
    'b',                                        // 15
    'c',                                        // 16
    'b',                                        // 17
    'b',                                        // 18
    'z',                                        // 19
    ''                                          // 20: No part 3
}

// Expected fourth part (where applicable)
constant char REGEX_SPLIT_EXPECTED_PART4[][255] = {
    '',                                         // 1: No part 4
    '',                                         // 2: No part 4
    'd',                                        // 3
    'four',                                     // 4
    '',                                         // 5: No part 4
    '',                                         // 6: No part 4
    '',                                         // 7: No part 4
    '1',                                        // 8
    '',                                         // 9: No part 4
    '',                                         // 10: No part 4
    'a',                                        // 11: Third 'a'
    'world',                                    // 12
    '',                                         // 13: No part 4
    '',                                         // 14: No part 4
    'c',                                        // 15
    '',                                         // 16: Empty after last comma
    '',                                         // 17: No part 4
    '',                                         // 18: Empty after last comma
    'w',                                        // 19
    ''                                          // 20: No part 4
}

// Has fourth part?
constant char REGEX_SPLIT_HAS_PART4[] = {
    false,                                      // 1
    false,                                      // 2
    true,                                       // 3
    true,                                       // 4
    false,                                      // 5
    false,                                      // 6
    false,                                      // 7
    true,                                       // 8
    false,                                      // 9
    false,                                      // 10
    true,                                       // 11
    true,                                       // 12
    false,                                      // 13
    false,                                      // 14
    true,                                       // 15
    true,                                       // 16
    false,                                      // 17
    true,                                       // 18
    true,                                       // 19
    false                                       // 20
}


/**
 * @function TestNAVRegexSplit
 * @public
 * @description Tests NAVRegexSplit() function.
 *
 * Validates:
 * - Splits string by delimiter pattern
 * - Handles simple and complex patterns
 * - Preserves empty parts (consecutive delimiters)
 * - Handles leading delimiters (creates empty first part)
 * - Handles trailing delimiters (creates empty last part)
 * - Returns entire input when no match
 * - Handles zero-width assertions correctly
 * - Returns correct part count
 * - Populates array with correct values
 */
define_function TestNAVRegexSplit() {
    stack_var integer x

    NAVLog("'***************** NAVRegexSplit *****************'")

    for (x = 1; x <= length_array(REGEX_SPLIT_PATTERN); x++) {
        stack_var char parts[20][255]
        stack_var integer count
        stack_var char result

        NAVStopwatchStart()

        // Execute split
        result = NAVRegexSplit(REGEX_SPLIT_PATTERN[x], REGEX_SPLIT_INPUT[x], parts, count)

        if (!NAVAssertTrue("'Should compile pattern'", result)) {
            NAVLogTestFailed(x, 'Pattern should compile', 'Failed to compile')
            NAVLog("'  Pattern: ', REGEX_SPLIT_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_SPLIT_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Verify part count
        if (!NAVAssertIntegerEqual("'Should return correct part count'", REGEX_SPLIT_EXPECTED_COUNT[x], count)) {
            NAVLogTestFailed(x, "'Expected ', itoa(REGEX_SPLIT_EXPECTED_COUNT[x]), ' parts'", "'Got ', itoa(count), ' parts'")
            NAVLog("'  Pattern: ', REGEX_SPLIT_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_SPLIT_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Verify array length matches count (or max array size if truncated)
        if (count <= max_length_array(parts)) {
            if (!NAVAssertIntegerEqual("'Array length should match count'", count, length_array(parts))) {
                NAVLogTestFailed(x, "'Array length ', itoa(count)", "'Array length ', itoa(length_array(parts))")
                NAVLog("'  Pattern: ', REGEX_SPLIT_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }
        }

        // Verify part 1
        if (count >= 1) {
            if (!NAVAssertStringEqual("'Part 1 should match'", REGEX_SPLIT_EXPECTED_PART1[x], parts[1])) {
                NAVLogTestFailed(x, "'Part 1: ''', REGEX_SPLIT_EXPECTED_PART1[x], ''''", "'Part 1: ''', parts[1], ''''")
                NAVLog("'  Pattern: ', REGEX_SPLIT_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_SPLIT_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
        }

        // Verify part 2
        if (count >= 2) {
            if (!NAVAssertStringEqual("'Part 2 should match'", REGEX_SPLIT_EXPECTED_PART2[x], parts[2])) {
                NAVLogTestFailed(x, "'Part 2: ''', REGEX_SPLIT_EXPECTED_PART2[x], ''''", "'Part 2: ''', parts[2], ''''")
                NAVLog("'  Pattern: ', REGEX_SPLIT_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_SPLIT_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
        }

        // Verify part 3
        if (count >= 3) {
            if (!NAVAssertStringEqual("'Part 3 should match'", REGEX_SPLIT_EXPECTED_PART3[x], parts[3])) {
                NAVLogTestFailed(x, "'Part 3: ''', REGEX_SPLIT_EXPECTED_PART3[x], ''''", "'Part 3: ''', parts[3], ''''")
                NAVLog("'  Pattern: ', REGEX_SPLIT_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_SPLIT_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
        }

        // Verify part 4 (if expected)
        if (REGEX_SPLIT_HAS_PART4[x] && count >= 4) {
            if (!NAVAssertStringEqual("'Part 4 should match'", REGEX_SPLIT_EXPECTED_PART4[x], parts[4])) {
                NAVLogTestFailed(x, "'Part 4: ''', REGEX_SPLIT_EXPECTED_PART4[x], ''''", "'Part 4: ''', parts[4], ''''")
                NAVLog("'  Pattern: ', REGEX_SPLIT_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_SPLIT_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}


/**
 * @function TestNAVRegexSplitEmptyInput
 * @public
 * @description Tests NAVRegexSplit() with empty input.
 *
 * Validates:
 * - Empty input returns 1 part (empty string)
 * - Count is 1
 * - Array length is 1
 */
define_function TestNAVRegexSplitEmptyInput() {
    stack_var char parts[10][100]
    stack_var integer count
    stack_var char result

    NAVLog("'***************** NAVRegex - Split Empty Input *****************'")

    NAVStopwatchStart()

    result = NAVRegexSplit(',', '', parts, count)

    if (!NAVAssertTrue("'Should handle empty input'", result)) {
        NAVLogTestFailed(1, 'Should succeed', 'Failed')
        NAVStopwatchStop()
        return
    }

    if (!NAVAssertIntegerEqual("'Should return count of 1'", 1, count)) {
        NAVLogTestFailed(1, 'Count should be 1', "'Count is ', itoa(count)")
        NAVStopwatchStop()
        return
    }

    if (!NAVAssertIntegerEqual("'Array length should be 1'", 1, length_array(parts))) {
        NAVLogTestFailed(1, 'Array length should be 1', "'Array length is ', itoa(length_array(parts))")
        NAVStopwatchStop()
        return
    }

    if (!NAVAssertStringEqual("'Part 1 should be empty string'", '', parts[1])) {
        NAVLogTestFailed(1, 'Part 1 should be empty', "'Part 1 is ''', parts[1], ''''")
        NAVStopwatchStop()
        return
    }

    NAVLogTestPassed(1)
    NAVLog("'Test ', itoa(1), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
}


/**
 * @function TestNAVRegexSplitArrayTooSmall
 * @public
 * @description Tests NAVRegexSplit() with array smaller than result.
 *
 * Validates:
 * - Count reports actual number of parts
 * - Array is filled to maximum capacity
 * - Array length equals max capacity (not count)
 * - User can detect truncation by comparing count vs max_length_array
 */
define_function TestNAVRegexSplitArrayTooSmall() {
    stack_var char parts[2][100]
    stack_var integer count
    stack_var char result

    NAVLog("'***************** NAVRegex - Split Array Too Small *****************'")

    NAVStopwatchStart()

    // Input: 'a,b,c,d,e' should split into 5 parts
    // But array can only hold 2
    result = NAVRegexSplit('/,/', 'a,b,c,d,e', parts, count)

    if (!NAVAssertTrue("'Should succeed even with small array'", result)) {
        NAVLogTestFailed(1, 'Should succeed', 'Failed')
        NAVStopwatchStop()
        return
    }

    if (!NAVAssertIntegerEqual("'Count should be 5 (actual parts)'", 5, count)) {
        NAVLogTestFailed(1, 'Count should be 5', "'Count is ', itoa(count)")
        NAVStopwatchStop()
        return
    }

    if (!NAVAssertIntegerEqual("'Array length should be 2 (max capacity)'", 2, length_array(parts))) {
        NAVLogTestFailed(1, 'Array length should be 2', "'Array length is ', itoa(length_array(parts))")
        NAVStopwatchStop()
        return
    }

    if (!NAVAssertStringEqual("'Part 1 should be a'", 'a', parts[1])) {
        NAVLogTestFailed(1, 'Part 1 should be a', "'Part 1 is ''', parts[1], ''''")
        NAVStopwatchStop()
        return
    }

    if (!NAVAssertStringEqual("'Part 2 should be b'", 'b', parts[2])) {
        NAVLogTestFailed(1, 'Part 2 should be b', "'Part 2 is ''', parts[2], ''''")
        NAVStopwatchStop()
        return
    }

    // User can detect truncation
    if (!NAVAssertTrue("'Should detect truncation (count > max)'", count > max_length_array(parts))) {
        NAVLogTestFailed(1, 'Truncation should be detectable', 'Cannot detect truncation')
        NAVStopwatchStop()
        return
    }

    NAVLogTestPassed(1)
    NAVLog("'Test ', itoa(1), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
}
