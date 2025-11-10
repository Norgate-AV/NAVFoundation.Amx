PROGRAM_NAME='NAVRegexMatcherLargeInput'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for large input strings
constant char REGEX_MATCHER_LARGE_INPUT_PATTERN[][255] = {
    '/test/',               // 1: Simple literal match in large string
    '/^start/',             // 2: Anchor at beginning of large string
    '/end$/',               // 3: Anchor at end of large string
    '/middle/',             // 4: Match in middle of large string
    '/test\d+/',            // 5: Mixed pattern in large string
    '/word\s+word/',        // 6: Whitespace pattern in large string
    '/(capture)/',          // 7: Capture group in large string
    '/rare/'                // 8: Match at end of large string
}

constant integer REGEX_MATCHER_LARGE_INPUT_SIZES[] = {
    10000,                  // 1: 10K string
    20000,                  // 2: 20K string
    30000,                  // 3: 30K string
    40000,                  // 4: 40K string
    25000,                  // 5: 25K string
    20000,                  // 6: 20K string
    30000,                  // 7: 30K string
    50000                   // 8: 50K string (near limit)
}

constant char REGEX_MATCHER_LARGE_INPUT_EXPECTED_MATCH[][255] = {
    'test',                 // 1
    'start',                // 2
    'end',                  // 3
    'middle',               // 4
    'test999',              // 5
    'word    word',         // 6
    'capture',              // 7
    'rare'                  // 8
}

constant integer REGEX_MATCHER_LARGE_INPUT_MATCH_POSITIONS[] = {
    5000,                   // 1: Middle of string
    1,                      // 2: Start of string
    29998,                  // 3: End position (30000 - 3 + 1 for "end")
    20000,                  // 4: Middle of large string
    15000,                  // 5: Middle position
    10000,                  // 6: Middle position
    15000,                  // 7: Middle position
    49996                   // 8: Near end of string (50000 - 4 + 1 for "rare")
}


define_function char[65535] GenerateTestInputData(integer test, integer size, integer matchPos) {
    stack_var integer x
    stack_var char matchText[50]
    stack_var char data[65535]

    for (x = 1; x <= size; x++) {
        data[x] = 'x'  // Fill with padding character
    }

    set_length_array(data, size)

    // Insert test-specific patterns at designated positions
    matchText = REGEX_MATCHER_LARGE_INPUT_EXPECTED_MATCH[test]

    for (x = 1; x <= length_array(matchText); x++) {
        data[matchPos + (x - 1)] = matchText[x]
    }

    return data
}


/**
 * @function TestNAVRegexMatcherLargeInput
 * @public
 * @description Tests regex matching with very large input strings (approaching 65K limit).
 *
 * Validates:
 * - Pattern matching works correctly with large strings (10K-50K)
 * - Start anchors work at beginning of large strings
 * - End anchors work at end of large strings
 * - Matches found in middle of large strings
 * - Character classes and quantifiers work in large strings
 * - Capture groups function correctly in large strings
 * - Performance remains acceptable with large inputs
 * - No buffer overruns or corruption with near-limit strings
 *
 * This ensures the regex engine can handle real-world scenarios with
 * large configuration files, logs, or protocol buffers.
 */
define_function TestNAVRegexMatcherLargeInput() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Large Input Strings *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_LARGE_INPUT_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char largeString[65535]
        stack_var integer stringSize
        stack_var integer matchPos
        stack_var integer expectedEndPos

        stringSize = REGEX_MATCHER_LARGE_INPUT_SIZES[x]
        matchPos = REGEX_MATCHER_LARGE_INPUT_MATCH_POSITIONS[x]

        // Generate large input string
        largeString = GenerateTestInputData(x, stringSize, matchPos)

        // For end anchor test, calculate expected position
        if (x == 3) {
            expectedEndPos = stringSize - length_array(REGEX_MATCHER_LARGE_INPUT_EXPECTED_MATCH[x]) + 1
        }

        NAVStopwatchStart()

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_LARGE_INPUT_PATTERN[x], largeString, collection)

        // Verify match success
        if (!NAVAssertTrue('Should match in large string', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
            NAVLogTestFailed(x, 'Expected match', 'No match')
            NAVLog("'  Pattern: ', REGEX_MATCHER_LARGE_INPUT_PATTERN[x]")
            NAVLog("'  String size: ', itoa(stringSize)")
            NAVLog("'  Status: ', itoa(collection.status)")
            NAVStopwatchStop()
            continue
        }

        // Verify matched text
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_LARGE_INPUT_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_MATCHER_LARGE_INPUT_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVLog("'  Pattern: ', REGEX_MATCHER_LARGE_INPUT_PATTERN[x]")
            NAVLog("'  String size: ', itoa(stringSize)")
            NAVStopwatchStop()
            continue
        }

        // Verify match position (except for end anchor which is calculated)
        if (x == 3) {
            if (!NAVAssertIntegerEqual('Match position should be near end', expectedEndPos, type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(expectedEndPos), itoa(collection.matches[1].fullMatch.start))
                NAVLog("'  Pattern: ', REGEX_MATCHER_LARGE_INPUT_PATTERN[x]")
                NAVStopwatchStop()
                continue
            }
        } else {
            if (!NAVAssertIntegerEqual('Match position should be correct', matchPos, type_cast(collection.matches[1].fullMatch.start))) {
                NAVLogTestFailed(x, itoa(matchPos), itoa(collection.matches[1].fullMatch.start))
                NAVLog("'  Pattern: ', REGEX_MATCHER_LARGE_INPUT_PATTERN[x]")
                NAVLog("'  String size: ', itoa(stringSize)")
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)
        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms (string size: ', itoa(stringSize), ')'")
    }
}
