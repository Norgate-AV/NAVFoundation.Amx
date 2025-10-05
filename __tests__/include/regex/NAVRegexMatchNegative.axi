PROGRAM_NAME='NAVRegexMatchNegative'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char REGEX_MATCH_NEGATIVE_TEST[][][255] = {
    // Pattern, Test Text, Expected Length, Expected Start, Expected End, Expected Match Text, Debug

    // ==================== NEGATIVE TEST CASES (Should NOT match) ====================

    // Begin anchor failures
    { '/^abc/', 'xabc', '0', '0', '0', '', 'false' },  // Text doesn't start with pattern
    { '/^\d+/', 'abc123', '0', '0', '0', '', 'false' },  // Text starts with letters not digits
    { '/^[A-Z]/', 'test', '0', '0', '0', '', 'false' },  // Text starts with lowercase

    // End anchor failures
    { '/abc$/', 'abcx', '0', '0', '0', '', 'false' },  // Text doesn't end with pattern
    { '/\d+$/', '123abc', '0', '0', '0', '', 'false' },  // Text ends with letters not digits

    // Full string match failures
    { '/^abc$/', 'abcd', '0', '0', '0', '', 'false' },  // Extra character at end
    { '/^\d+$/', '123abc', '0', '0', '0', '', 'false' },  // Mixed content
    { '/^[a-z]+$/', 'Test', '0', '0', '0', '', 'false' },  // Contains uppercase

    // Required quantifier failures (+ requires at least one)
    { '/\d+/', 'abc', '0', '0', '0', '', 'false' },  // No digits
    { '/[A-Z]+/', 'test', '0', '0', '0', '', 'false' },  // No uppercase

    // Character class mismatch
    { '/[0-9]+/', 'abc', '0', '0', '0', '', 'false' },  // No digits in text
    { '/[a-z]+/', '123', '0', '0', '0', '', 'false' },  // No lowercase in text

    // Word boundary failures
    { '/\btest\b/', 'testing', '0', '0', '0', '', 'false' },  // 'test' is not a complete word
    { '/\btest\b/', 'atest', '0', '0', '0', '', 'false' },  // 'test' not at word boundary

    // Pattern too specific
    { '/\d\d\d/', '12', '0', '0', '0', '', 'false' },  // Need 3 digits, only have 2
    { '/test\s+case/', 'testcase', '0', '0', '0', '', 'false' }  // Missing required space
}

constant char REGEX_MATCH_NEGATIVE_EXPECTED_RESULT[] = {
    false, // 1 - Begin anchor failure (^abc vs xabc)
    false, // 2 - Begin anchor failure (^\d+ vs abc123)
    false, // 3 - Begin anchor failure (^[A-Z] vs test)
    false, // 4 - End anchor failure (abc$ vs abcx)
    false, // 5 - End anchor failure (\d+$ vs 123abc)
    false, // 6 - Full string match failure (^abc$ vs abcd)
    false, // 7 - Full string match failure (^\d+$ vs 123abc)
    false, // 8 - Full string match failure (^[a-z]+$ vs Test)
    false, // 9 - Required quantifier failure (\d+ vs abc)
    false, // 10 - Required quantifier failure ([A-Z]+ vs test)
    false, // 11 - Character class mismatch ([0-9]+ vs abc)
    false, // 12 - Character class mismatch ([a-z]+ vs 123)
    false, // 13 - Word boundary failure (\btest\b vs testing)
    false, // 14 - Word boundary failure (\btest\b vs atest)
    false, // 15 - Pattern too specific (\d\d\d vs 12)
    false  // 16 - Pattern too specific (test\s+case vs testcase)
}

define_function TestNAVRegexMatchNegative() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatch - Negative Tests *****************'")

    for (x = 1; x <= length_array(REGEX_MATCH_NEGATIVE_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char result
        stack_var char failed

        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatch expected

        failed = false

        pattern = REGEX_MATCH_NEGATIVE_TEST[x][1]
        text = REGEX_MATCH_NEGATIVE_TEST[x][2]

        expected.length = atoi(REGEX_MATCH_NEGATIVE_TEST[x][3])
        expected.start = atoi(REGEX_MATCH_NEGATIVE_TEST[x][4])
        expected.end = atoi(REGEX_MATCH_NEGATIVE_TEST[x][5])
        expected.text = REGEX_MATCH_NEGATIVE_TEST[x][6]

        // Set the debug flag
        match.debug = (REGEX_MATCH_NEGATIVE_TEST[x][7] == 'true')

        result = NAVRegexMatch(pattern, text, match)

        if (!NAVAssertBooleanEqual('Should return the expected result', REGEX_MATCH_NEGATIVE_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(REGEX_MATCH_NEGATIVE_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!REGEX_MATCH_NEGATIVE_EXPECTED_RESULT[x]) {
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
