PROGRAM_NAME='NAVStringSubstring'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char SUBSTRING_SUBJECT[] = 'The quick brown fox jumps over the lazy dog'

constant integer SUBSTRING_TEST[][] = {
    // { start, count }
    { 0, 0 },
    { 4, 15 },
    { 10, 20 },
    { 4, 25 },
    { 10, 5 },
    { 5, 0 },
    { 4, 4 },
    { 10, 15 },
    { 1, 2 },
    { 0, 20 }
}

constant char SUBSTRING_EXPECTED[][NAV_MAX_BUFFER] = {
    '',
    ' quick brown fo',
    ' brown fox jumps ove',
    ' quick brown fox jumps ov',
    ' brow',
    'quick brown fox jumps over the lazy dog',
    ' qui',
    ' brown fox jump',
    'Th',
    ''
}


define_function TestNAVStringSubstring() {
    stack_var integer x

    NAVLog("'***************** NAVStringSubstring *****************'")

    for (x = 1; x <= length_array(SUBSTRING_TEST); x++) {
        stack_var integer start
        stack_var integer count
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        start = SUBSTRING_TEST[x][1]
        count = SUBSTRING_TEST[x][2]

        expected = SUBSTRING_EXPECTED[x]

        result = NAVStringSubstring(SUBSTRING_SUBJECT, start, count)

        if (!NAVAssertStringEqual('String Substring Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
