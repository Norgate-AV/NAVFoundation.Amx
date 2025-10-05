PROGRAM_NAME='NAVRegexMatchComplex'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char REGEX_MATCH_COMPLEX_TEST[][][255] = {
    // Pattern, Test Text, Expected Length, Expected Start, Expected End, Expected Match Text, Debug

    // Escaped special characters
    { '/\./', '.', '1', '1', '2', '.', 'false' },
    { '/\.\d+/', '.5', '2', '1', '3', '.5', 'false' },
    { '/\^/', '^', '1', '1', '2', '^', 'false' },
    { '/\$/', '$', '1', '1', '2', '$', 'false' },
    { '/\.txt$/', 'file.txt', '4', '5', '9', '.txt', 'false' },

    // Quoted strings
    { '/"[^"]*"/', '"test"', '6', '1', '7', '"test"', 'false' },
    { '/^"[^"]*"/', '"abc"', '5', '1', '6', '"abc"', 'false' },
    { '/^"[^"]*"$/', '"hello world"', '13', '1', '14', '"hello world"', 'false' },
    { '/"[^"]*"/', 'say "hello"', '7', '5', '12', '"hello"', 'false' },

    // Complex patterns
    { '/\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/', '192.168.1.10', '12', '1', '13', '192.168.1.10', 'false' },
    { '/[a-z]+@[a-z]+\.[a-z]+/', 'test@example.com', '16', '1', '17', 'test@example.com', 'false' },
    { '/\w+\s\w+/', 'hello world', '11', '1', '12', 'hello world', 'false' },
    { '/[A-Z][a-z]+/', 'Hello', '5', '1', '6', 'Hello', 'false' },
    { '/\d+[a-z]*/', '123abc', '6', '1', '7', '123abc', 'false' },

    // Multiple digit patterns
    { '/\d\d/', '42', '2', '1', '3', '42', 'false' },
    { '/\d\d\d/', '999', '3', '1', '4', '999', 'false' },

    // Edge cases with positioning
    { '/\d+/', 'abc123def', '3', '4', '7', '123', 'false' },  // Not at start
    { '/\w+/', '  test', '4', '3', '7', 'test', 'false' },  // After whitespace
    { '/[a-z]+/', '123abc', '3', '4', '7', 'abc', 'false' }  // After digits
}

constant char REGEX_MATCH_COMPLEX_EXPECTED_RESULT[] = {
    true,  // 1
    true,  // 2
    true,  // 3
    true,  // 4
    true,  // 5
    true,  // 6
    true,  // 7
    true,  // 8
    true,  // 9
    true,  // 10
    true,  // 11
    true,  // 12
    true,  // 13
    true,  // 14
    true,  // 15
    true,  // 16
    true,  // 17
    true,  // 18
    true   // 19
}

define_function TestNAVRegexMatchComplex() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatch - Complex Patterns *****************'")

    for (x = 1; x <= length_array(REGEX_MATCH_COMPLEX_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char result
        stack_var char failed

        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatch expected

        failed = false

        pattern = REGEX_MATCH_COMPLEX_TEST[x][1]
        text = REGEX_MATCH_COMPLEX_TEST[x][2]

        expected.length = atoi(REGEX_MATCH_COMPLEX_TEST[x][3])
        expected.start = atoi(REGEX_MATCH_COMPLEX_TEST[x][4])
        expected.end = atoi(REGEX_MATCH_COMPLEX_TEST[x][5])
        expected.text = REGEX_MATCH_COMPLEX_TEST[x][6]

        // Set the debug flag
        match.debug = (REGEX_MATCH_COMPLEX_TEST[x][7] == 'true')

        result = NAVRegexMatch(pattern, text, match)

        if (!NAVAssertBooleanEqual('Should return the expected result', REGEX_MATCH_COMPLEX_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(REGEX_MATCH_COMPLEX_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!REGEX_MATCH_COMPLEX_EXPECTED_RESULT[x]) {
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
