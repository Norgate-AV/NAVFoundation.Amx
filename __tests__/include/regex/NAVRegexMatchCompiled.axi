PROGRAM_NAME='NAVRegexMatchCompiled'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char MATCH_COMPILED_TEST[][][50] = {
    // Pattern, Test Text, Expected Length, Expected Start, Expected End, Expected Match Text
    { '/\d+/', '123', '3', '1', '4', '123' },
    { '/\w+/', 'abc', '3', '1', '4', 'abc' },
    { '/\w*/', 'abc', '3', '1', '4', 'abc' },
    { '/\s/', ' ', '1', '1', '2', ' ' },
    { '/\s+/', ' ', '1', '1', '2', ' ' },
    { '/\s*/', ' ', '1', '1', '2', ' ' },
    { '/\d\w?\s/', '1a ', '3', '1', '4', '1a ' },
    { '/\d\w\s+/', '1a ', '3', '1', '4', '1a ' },
    { '/\d?\w\s*/', 'a ', '2', '1', '2', 'a ' },
    { '/\D+/', 'abc', '3', '1', '4', 'abc' },
    { '/\D*/', 'abc', '3', '1', '4', 'abc' },
    { '/\D\s/', 'abc ', '2', '1', '3', 'abc ' },
    { '/\W+/', ' ', '1', '1', '2', ' ' },
    { '/\S*/', 'abc', '3', '1', '4', 'abc' },
    { '/^[a-zA-Z0-9_]+$/', 'abc123_', '7', '1', '8', 'abc123_' }
}


define_function TestNAVRegexMatchCompiled() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexMatchCompiled *****************'")

    for (x = 1; x <= length_array(MATCH_COMPILED_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char failed

        stack_var _NAVRegexParser parser
        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatch expected
        failed = false

        pattern = MATCH_COMPILED_TEST[x][1]
        text = MATCH_COMPILED_TEST[x][2]

        expected.length = atoi(MATCH_COMPILED_TEST[x][3])
        expected.start = atoi(MATCH_COMPILED_TEST[x][4])
        expected.end = atoi(MATCH_COMPILED_TEST[x][5])
        expected.text = MATCH_COMPILED_TEST[x][6]

        if (!NAVRegexCompile(pattern, parser)) {
            NAVLog("'Test ', itoa(x), ' failed'")
            NAVLog("'Failed to compile pattern: "', pattern, '"'")
            continue
        }

        NAVRegexMatchCompiled(parser, text, match)

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
