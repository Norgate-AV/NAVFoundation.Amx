PROGRAM_NAME='NAVStringSlice'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char SLICE_SUBJECT[] = 'The quick brown fox jumps over the lazy dog'

constant integer SLICE_TEST[][] = {
    // { start, end }
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

constant char SLICE_EXPECTED[][NAV_MAX_BUFFER] = {
    '',
    ' quick brow',
    ' brown fox',
    ' quick brown fox jump',
    '',
    'quick brown fox jumps over the lazy dog',
    '',
    ' brow',
    'T',
    ''
}


define_function TestNAVStringSlice() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVGetStringSlice *****************'")

    for (x = 1; x <= length_array(SLICE_TEST); x++) {
        stack_var integer start
        stack_var integer end
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        start = SLICE_TEST[x][1]
        end = SLICE_TEST[x][2]

        expected = SLICE_EXPECTED[x]

        result = NAVStringSlice(SLICE_SUBJECT, start, end)

        if (!NAVAssertStringEqual(expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
