PROGRAM_NAME='NAVRegexMatch'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char MATCH_TEST[][][50] = {
    // Pattern, Test Text, Expected Length, Expected Start, Expected End, Expected Match Text
    { '\d+', '123', '3', '1', '4', '123' },
    { '\w+', 'abc', '3', '1', '4', 'abc' },
    { '\w*', 'abc', '3', '1', '4', 'abc' },
    { '\s', ' ', '1', '1', '2', ' ' },
    { '\s+', ' ', '1', '1', '2', ' ' },
    { '\s*', ' ', '1', '1', '2', ' ' },
    { '\d\w?\s', '1a ', '3', '1', '4', '1a ' },
    { '\d\w\s+', '1a ', '3', '1', '4', '1a ' },
    { '\d?\w\s*', 'a ', '2', '1', '2', 'a ' },
    { '\D+', 'abc', '3', '1', '4', 'abc' },
    { '\D*', 'abc', '3', '1', '4', 'abc' },
    { '\D\s', 'abc ', '2', '1', '3', 'abc ' },
    { '\W+', ' ', '1', '1', '2', ' ' },
    { '\S*', 'abc', '3', '1', '4', 'abc' },
    { '^[a-zA-Z0-9_]+$', 'abc123_', '7', '1', '8', 'abc123_' }
    // { '\s+', ' ' },         // 1
    // { '\s*', ' ' },         // 1
    // { '\d\w?\s', '1a ' },   // 3
    // { '\d\w\s+', '1a ' },   // 3
    // { '\d?\w\s*', 'a ' },   // 2
    // { '\D+', 'abc' },       // 3
    // { '\D*', 'abc' },       // 3
    // { '\D\s', 'abc ' },     // 2
    // { '\W+', ' ' },         // 1
    // { '\S*', 'abc' },       // 3
    // { '^[a-zA-Z0-9_]+$', 'abc123_' }    // 7
}


constant integer MATCH_EXPECTED[] = {
    3, 3, 3, 1, 1, 1, 3, 3, 2, 3, 3, 2, 1, 3, 7
}


DEFINE_TYPE




define_function TestNAVRegexMatch() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexMatch *****************'")

    for (x = 15; x <= 15; x++) {
        stack_var char pattern[255]
        stack_var char text[255]
        stack_var char failed

        stack_var _NAVRegexMatchResult match
        stack_var _NAVRegexMatchResult expected
        failed = false

        pattern = MATCH_TEST[x][1]
        text = MATCH_TEST[x][2]

        expected.length = atoi(MATCH_TEST[x][3])
        expected.start = atoi(MATCH_TEST[x][4])
        expected.end = atoi(MATCH_TEST[x][5])
        expected.text = MATCH_TEST[x][6]

        NAVRegexMatch(pattern, text, match)

        if (match.length != expected.length) {
            failed = true
            NAVLog("'Expected Match Length: ', itoa(expected.length), ' but got ', itoa(match.length)")
        }

        if (match.start != expected.start) {
            failed = true
            NAVLog("'Expected Match Start: ', itoa(expected.start), ' but got ', itoa(match.start)")
        }

        if (match.end != expected.end) {
            failed = true
            NAVLog("'Expected Match End: ', itoa(expected.end), ' but got ', itoa(match.end)")
        }

        if (match.text != expected.text) {
            failed = true
            NAVLog("'Expected Match Text: "', expected.text, '" but got "', match.text, '"'")
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }
}
