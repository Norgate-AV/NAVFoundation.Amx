PROGRAM_NAME='NAVRegexMatchQuantifiers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char REGEX_MATCH_QUANTIFIERS_TEST[][][255] = {
    // Pattern, Test Text, Expected Length, Expected Start, Expected End, Expected Match Text, Debug

    // Basic quantifiers: + (one or more)
    { '/\d+/', '123', '3', '1', '4', '123', 'false' },
    { '/\w+/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\D+/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\W+/', ' ', '1', '1', '2', ' ', 'false' },

    // Basic quantifiers: * (zero or more)
    { '/\w*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\D*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\S*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\s*/', ' ', '1', '1', '2', ' ', 'false' },
    { '/.*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/.*/', '', '0', '1', '1', '', 'false' },  // Should match epsilon

    // Basic quantifiers: ? (zero or one)
    { '/\d?/', '1', '1', '1', '2', '1', 'false' },
    { '/\w?/', 'x', '1', '1', '2', 'x', 'false' },

    // Mixed quantifiers
    { '/\d\w?\s/', '1a ', '3', '1', '4', '1a ', 'false' },
    { '/\d\w\s+/', '1a ', '3', '1', '4', '1a ', 'false' },
    { '/\d?\w\s*/', 'a ', '2', '1', '3', 'a ', 'false' },
    { '/\s/', ' ', '1', '1', '2', ' ', 'false' },
    { '/\s+/', ' ', '1', '1', '2', ' ', 'false' },
    { '/\D\s/', 'abc ', '2', '3', '5', 'c ', 'false' }
}

constant char REGEX_MATCH_QUANTIFIERS_EXPECTED_RESULT[] = {
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
    true   // 18
}

define_function TestNAVRegexMatchQuantifiers() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatch - Quantifiers *****************'")

    for (x = 1; x <= length_array(REGEX_MATCH_QUANTIFIERS_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char result
        stack_var char failed

        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatch expected

        failed = false

        pattern = REGEX_MATCH_QUANTIFIERS_TEST[x][1]
        text = REGEX_MATCH_QUANTIFIERS_TEST[x][2]

        expected.length = atoi(REGEX_MATCH_QUANTIFIERS_TEST[x][3])
        expected.start = atoi(REGEX_MATCH_QUANTIFIERS_TEST[x][4])
        expected.end = atoi(REGEX_MATCH_QUANTIFIERS_TEST[x][5])
        expected.text = REGEX_MATCH_QUANTIFIERS_TEST[x][6]

        // Set the debug flag
        match.debug = (REGEX_MATCH_QUANTIFIERS_TEST[x][7] == 'true')

        result = NAVRegexMatch(pattern, text, match)

        if (!NAVAssertBooleanEqual('Should return the expected result', REGEX_MATCH_QUANTIFIERS_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(REGEX_MATCH_QUANTIFIERS_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!REGEX_MATCH_QUANTIFIERS_EXPECTED_RESULT[x]) {
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
