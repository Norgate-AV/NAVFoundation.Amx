PROGRAM_NAME='NAVRegexMatcherMultilineLineEndings'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for multiline mode with different line endings
constant char REGEX_MATCHER_MULTILINE_ENDINGS_PATTERN[][255] = {
    '/^test/m',             // 1: Start anchor with Unix LF
    '/test$/m',             // 2: End anchor with Unix LF
    '/^line$/m',            // 3: Both anchors with Unix LF
    '/^test/m',             // 4: Start anchor with Mac CR
    '/test$/m',             // 5: End anchor with Mac CR
    '/^line$/m',            // 6: Both anchors with Mac CR
    '/^test/m',             // 7: Start anchor with Windows CRLF
    '/test$/m',             // 8: End anchor with Windows CRLF
    '/^line$/m',            // 9: Both anchors with Windows CRLF
    '/^$/m',                // 10: Empty line with Unix LF
    '/^$/m',                // 11: Empty line with Windows CRLF
    '/^first$/m',           // 12: First line with mixed endings
    '/^last$/m',            // 13: Last line with mixed endings
    '/^middle$/m',          // 14: Middle line with mixed endings
    '/^a$/m',               // 15: Single char line with Unix LF
    '/^$/m',                // 16: Empty line between content (Unix)
    '/^end$/m',             // 17: Match after trailing newline (Unix)
    '/^end$/m',             // 18: Match after trailing newline (Windows)
    '/^foo$/m',             // 19: Multiple occurrences Unix LF
    '/^foo$/m'              // 20: Multiple occurrences Windows CRLF
}

constant char REGEX_MATCHER_MULTILINE_ENDINGS_INPUT[][255] = {
    {'f','i','r','s','t',$0A,'t','e','s','t',$0A,'l','a','s','t'},           // 1: Unix LF - "test" at start of line
    {'f','i','r','s','t',$0A,'t','e','s','t',$0A,'l','a','s','t'},           // 2: Unix LF - "test" at end of line
    {'f','i','r','s','t',$0A,'l','i','n','e',$0A,'l','a','s','t'},           // 3: Unix LF - "line" is whole line
    {'f','i','r','s','t',$0D,'t','e','s','t',$0D,'l','a','s','t'},           // 4: Mac CR - "test" at start of line
    {'f','i','r','s','t',$0D,'t','e','s','t',$0D,'l','a','s','t'},           // 5: Mac CR - "test" at end of line
    {'f','i','r','s','t',$0D,'l','i','n','e',$0D,'l','a','s','t'},           // 6: Mac CR - "line" is whole line
    {'f','i','r','s','t',$0D,$0A,'t','e','s','t',$0D,$0A,'l','a','s','t'},   // 7: Windows CRLF - "test" at start of line
    {'f','i','r','s','t',$0D,$0A,'t','e','s','t',$0D,$0A,'l','a','s','t'},   // 8: Windows CRLF - "test" at end of line
    {'f','i','r','s','t',$0D,$0A,'l','i','n','e',$0D,$0A,'l','a','s','t'},   // 9: Windows CRLF - "line" is whole line
    {'a',$0A,$0A,'b'},                                                        // 10: Empty line with Unix LF
    {'a',$0D,$0A,$0D,$0A,'b'},                                                // 11: Empty line with Windows CRLF
    {'f','i','r','s','t',$0A,'m','i','d','d','l','e',$0D,$0A,'l','a','s','t'},     // 12: Mixed endings - first line
    {'f','i','r','s','t',$0A,'m','i','d','d','l','e',$0D,$0A,'l','a','s','t'},     // 13: Mixed endings - last line
    {'f','i','r','s','t',$0A,'m','i','d','d','l','e',$0D,$0A,'l','a','s','t'},     // 14: Mixed endings - middle line
    {'a',$0A,'b'},                                                            // 15: Single char line with Unix LF
    {'s','t','a','r','t',$0A,$0A,'e','n','d'},                                // 16: Empty line between content
    {'s','t','a','r','t',$0A,'e','n','d',$0A},                                // 17: Trailing newline Unix
    {'s','t','a','r','t',$0D,$0A,'e','n','d',$0D,$0A},                        // 18: Trailing newline Windows
    {'f','o','o',$0A,'b','a','r',$0A,'f','o','o'},                            // 19: Multiple "foo" lines Unix
    {'f','o','o',$0D,$0A,'b','a','r',$0D,$0A,'f','o','o'}                     // 20: Multiple "foo" lines Windows
}

constant char REGEX_MATCHER_MULTILINE_ENDINGS_EXPECTED_MATCH[][255] = {
    'test',                 // 1
    'test',                 // 2
    'line',                 // 3
    'test',                 // 4
    'test',                 // 5
    'line',                 // 6
    'test',                 // 7
    'test',                 // 8
    'line',                 // 9
    '',                     // 10: Empty line
    '',                     // 11: Empty line
    'first',                // 12
    'last',                 // 13
    'middle',               // 14
    'a',                    // 15
    '',                     // 16: Empty line
    'end',                  // 17
    'end',                  // 18
    'foo',                  // 19: First occurrence
    'foo'                   // 20: First occurrence
}

constant integer REGEX_MATCHER_MULTILINE_ENDINGS_EXPECTED_START[] = {
    7,                      // 1: Position after "first\n"
    7,                      // 2: Position of "test"
    7,                      // 3: Position after "first\n"
    7,                      // 4: Position after "first\r"
    7,                      // 5: Position of "test"
    7,                      // 6: Position after "first\r"
    8,                      // 7: Position after "first\r\n"
    8,                      // 8: Position of "test"
    8,                      // 9: Position after "first\r\n"
    3,                      // 10: Position after "a\n"
    4,                      // 11: Position after "a\r\n"
    1,                      // 12: Start of string
    15,                     // 13: Position after mixed line endings
    7,                      // 14: Position after "first\n"
    1,                      // 15: Start of string
    7,                      // 16: Position after "start\n"
    7,                      // 17: Position after "start\n"
    8,                      // 18: Position after "start\r\n"
    1,                      // 19: First "foo"
    1                       // 20: First "foo"
}

/**
 * @function TestNAVRegexMatcherMultilineLineEndings
 * @public
 * @description Tests multiline mode (^, $) with different line ending conventions.
 *
 * Validates:
 * - Unix line endings (LF - \n)
 * - Mac line endings (CR - \r)
 * - Windows line endings (CRLF - \r\n)
 * - Mixed line endings
 * - Empty lines
 * - Trailing newlines
 *
 * This ensures the multiline flag correctly handles all common line ending
 * styles across different platforms.
 */
define_function TestNAVRegexMatcherMultilineLineEndings() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Multiline Line Endings *****************'")

    for (x = 1; x <= length_array(REGEX_MATCHER_MULTILINE_ENDINGS_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection
        stack_var char input[255]

        NAVStopwatchStart()

        // Build input string with actual line ending characters
        input = REGEX_MATCHER_MULTILINE_ENDINGS_INPUT[x]

        // Execute match
        NAVRegexMatch(REGEX_MATCHER_MULTILINE_ENDINGS_PATTERN[x], input, collection)

        // Verify match success
        if (!NAVAssertTrue('Should match pattern', (collection.status == MATCH_STATUS_SUCCESS && collection.count > 0))) {
            NAVLogTestFailed(x, 'Expected match', 'No match')
            NAVLog("'  Pattern: ', REGEX_MATCHER_MULTILINE_ENDINGS_PATTERN[x]")
            NAVLog("'  Status:  ', itoa(collection.status)")
            NAVLog("'  Count:   ', itoa(collection.count)")
            NAVStopwatchStop()
            continue
        }

        // Verify matched text
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_MATCHER_MULTILINE_ENDINGS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_MATCHER_MULTILINE_ENDINGS_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVLog("'  Pattern:  ', REGEX_MATCHER_MULTILINE_ENDINGS_PATTERN[x]")
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_MATCHER_MULTILINE_ENDINGS_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_MATCHER_MULTILINE_ENDINGS_EXPECTED_START[x]), itoa(collection.matches[1].fullMatch.start))
            NAVLog("'  Pattern:  ', REGEX_MATCHER_MULTILINE_ENDINGS_PATTERN[x]")
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}
