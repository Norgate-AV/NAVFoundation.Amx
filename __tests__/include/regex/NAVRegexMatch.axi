PROGRAM_NAME='NAVRegexMatch'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char MATCH_TEST[][][50] = {
    { '\d+', '123' },       // 3
    { '\w+', 'abc' },       // 3
    { '\w*', 'abc' },       // 3
    { '\s', ' ' },          // 1
    { '\s+', ' ' },         // 1
    { '\s*', ' ' },         // 1
    { '\d\w?\s', '1a ' },   // 3
    { '\d\w\s+', '1a ' },   // 3
    { '\d?\w\s*', 'a ' },   // 2
    { '\D+', 'abc' },       // 3
    { '\D*', 'abc' },       // 3
    { '\D\s', 'abc ' },     // 2
    { '\W+', ' ' },         // 1
    { '\S*', 'abc' },       // 3
    { '^[a-zA-Z0-9_]+$', 'abc123_' }    // 7
}


constant integer MATCH_EXPECTED[] = {
    3, 3, 3, 1, 1, 1, 3, 3, 2, 3, 3, 2, 1, 3, 7
}


define_function TestNAVRegexMatch() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexMatch *****************'")

    for (x = 1; x <= length_array(MATCH_TEST); x++) {
        stack_var char pattern[255]
        stack_var char text[255]

        stack_var _NAVRegexMatchResult match

        stack_var integer expected

        pattern = MATCH_TEST[x][1]
        text = MATCH_TEST[x][2]
        expected = MATCH_EXPECTED[x]

        NAVRegexMatch(pattern, text, match)

        if (match.length != expected) {
            NAVLogTestFailed(x, itoa(expected), itoa(match.length))
            continue
        }

        NAVLogTestPassed(x)
    }
}
