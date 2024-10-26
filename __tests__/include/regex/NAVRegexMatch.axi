PROGRAM_NAME='NAVRegexMatch'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char MATCH_TEST[][][50] = {
    // Pattern, Test Text, Expected Length, Expected Start, Expected End, Expected Match Text, Debug
    { '/\d+/', '123', '3', '1', '4', '123', 'false' },
    { '/\w+/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\w*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\s/', ' ', '1', '1', '2', ' ', 'false' },
    { '/\s+/', ' ', '1', '1', '2', ' ', 'false' },
    { '/\s*/', ' ', '1', '1', '2', ' ', 'false' },
    { '/\d\w?\s/', '1a ', '3', '1', '4', '1a ', 'false' },
    { '/\d\w\s+/', '1a ', '3', '1', '4', '1a ', 'false' },
    { '/\d?\w\s*/', 'a ', '2', '1', '3', 'a ', 'false' },
    { '/\D+/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\D*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/\D\s/', 'abc ', '2', '3', '5', 'c ', 'false' },
    { '/\W+/', ' ', '1', '1', '2', ' ', 'false' },
    { '/\S*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/^[a-zA-Z0-9_]+$/', 'abc123_', '7', '1', '8', 'abc123_', 'false' },
    { '/^[Hh]ello,\s[Ww]orld!$/', 'Hello, World!', '13', '1', '14', 'Hello, World!', 'false' },
    // { '/^\d{3}-\d{2}-\d{4}$/', '123-45-6789', '11', '1', '12', '123-45-6789' },
    { '/^"[^"]*"/', '"abc"', '5', '1', '6', '"abc"', 'false' },
    // { '/^([a-zA-Z_]\w*)\s*=\s*([^;#].*)/', 'abc = def', '7', '1', '8', 'abc = def' },
    { '/.*/', 'abc', '3', '1', '4', 'abc', 'false' },
    { '/.*/', '', '0', '1', '1', '', 'false' },  // Should match epsilon
    { '/\d?\d?\d\.\d?\d?\d\.\d?\d?\d\.\d?\d?\d/', '192.168.1.10', '12', '1', '13', '192.168.1.10', 'true' }
}


define_function TestNAVRegexMatch() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexMatch *****************'")

    for (x = 1; x <= length_array(MATCH_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char failed

        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatch expected
        failed = false

        pattern = MATCH_TEST[x][1]
        text = MATCH_TEST[x][2]

        expected.length = atoi(MATCH_TEST[x][3])
        expected.start = atoi(MATCH_TEST[x][4])
        expected.end = atoi(MATCH_TEST[x][5])
        expected.text = MATCH_TEST[x][6]

        // Set the debug flag
        match.debug = (MATCH_TEST[x][7] == 'true')

        if (!NAVRegexMatch(pattern, text, match)) {
            NAVLog("'Failed to match pattern: "', pattern, '" with text: "', text, '"'")
            NAVLog("'Test ', itoa(x), ' failed'")
            continue
        }

        if (match.matches[1].length != expected.length) {
            failed = true
            NAVLog("'Expected Match Length: ', itoa(expected.length), ' but got ', itoa(match.matches[1].length)")
        }

        if (match.matches[1].start != expected.start) {
            failed = true
            NAVLog("'Expected Match Start: ', itoa(expected.start), ' but got ', itoa(match.matches[1].start)")
        }

        if (match.matches[1].end != expected.end) {
            failed = true
            NAVLog("'Expected Match End: ', itoa(expected.end), ' but got ', itoa(match.matches[1].end)")
        }

        if (match.matches[1].text != expected.text) {
            failed = true
            NAVLog("'Expected Match Text: "', expected.text, '" but got "', match.matches[1].text, '"'")
        }

        if (failed) {
            NAVLog("'Test ', itoa(x), ' failed'")
            continue
        }

        NAVLogTestPassed(x)
    }
}
