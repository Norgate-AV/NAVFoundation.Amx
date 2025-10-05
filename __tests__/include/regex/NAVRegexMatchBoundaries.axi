PROGRAM_NAME='NAVRegexMatchBoundaries'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char REGEX_MATCH_BOUNDARIES_TEST[][][255] = {
    // Pattern, Test Text, Expected Length, Expected Start, Expected End, Expected Match Text, Debug

    // Word boundaries
    { '/\btest\b/', 'test', '4', '1', '5', 'test', 'false' },
    { '/\btest\b/', 'this is a test case', '4', '11', '15', 'test', 'false' },
    { '/\b\w+\b/', 'word', '4', '1', '5', 'word', 'false' },

    // Non-word boundaries
    { '/\Btest/', 'contest', '4', '4', '8', 'test', 'false' },
    { '/test\B/', 'testing', '4', '1', '5', 'test', 'false' },

    // Special whitespace
    { '/\t/', '	', '1', '1', '2', '	', 'false' },  // Tab character
    // { '/\n/', "$0A", '1', '1', '2', "$0A", 'false' },  // Newline - COMMENTED OUT
    // { '/\r/', "$0D", '1', '1', '2', "$0D", 'false' },  // Carriage return - COMMENTED OUT
    { '/\s+/', "  	", '3', '1', '4', "  	", 'false' }  // Mixed whitespace
}

constant char REGEX_MATCH_BOUNDARIES_EXPECTED_RESULT[] = {
    true,  // 1
    true,  // 2
    true,  // 3
    true,  // 4
    true,  // 5
    true,  // 6
    true   // 7
}

define_function TestNAVRegexMatchBoundaries() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatch - Boundaries *****************'")

    for (x = 1; x <= length_array(REGEX_MATCH_BOUNDARIES_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char result
        stack_var char failed

        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatch expected

        failed = false

        pattern = REGEX_MATCH_BOUNDARIES_TEST[x][1]
        text = REGEX_MATCH_BOUNDARIES_TEST[x][2]

        expected.length = atoi(REGEX_MATCH_BOUNDARIES_TEST[x][3])
        expected.start = atoi(REGEX_MATCH_BOUNDARIES_TEST[x][4])
        expected.end = atoi(REGEX_MATCH_BOUNDARIES_TEST[x][5])
        expected.text = REGEX_MATCH_BOUNDARIES_TEST[x][6]

        // Set the debug flag
        match.debug = (REGEX_MATCH_BOUNDARIES_TEST[x][7] == 'true')

        result = NAVRegexMatch(pattern, text, match)

        if (!NAVAssertBooleanEqual('Should return the expected result', REGEX_MATCH_BOUNDARIES_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(REGEX_MATCH_BOUNDARIES_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!REGEX_MATCH_BOUNDARIES_EXPECTED_RESULT[x]) {
            // If no match expected, skip further checks
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertIntegerEqual('Should match the correct length', match.matches[1].length, expected.length)) {
            NAVLogTestFailed(x, itoa(expected.length), itoa(match.matches[1].length))
            failed = true
        }

        if (!NAVAssertIntegerEqual('Should have the correct start position', match.matches[1].start, expected.start)) {
            NAVLogTestFailed(x, itoa(expected.start), itoa(match.matches[1].start))
            failed = true
        }

        if (!NAVAssertIntegerEqual('Should have the correct end position', match.matches[1].end, expected.end)) {
            NAVLogTestFailed(x, itoa(expected.end), itoa(match.matches[1].end))
            failed = true
        }

        if (!NAVAssertStringEqual('Should match the correct text', match.matches[1].text, expected.text)) {
            NAVLogTestFailed(x, expected.text, match.matches[1].text)
            failed = true
        }

        if (failed) {
            NAVLogTestFailed(x, '', '')
            continue
        }

        NAVLogTestPassed(x)
    }
}
