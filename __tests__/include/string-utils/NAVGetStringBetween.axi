PROGRAM_NAME='string-utils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char TEST[][][NAV_MAX_BUFFER] = {
    { '', '' },
    { 'The', 'fox' },
    { 'quick', 'jumps' },
    { 'the ', ' dog' },
    { 'brown', 'bob' },
    { 'fox ', 'jumps' },
    { 'alice', 'bob' },
    { 'dog', '' },
    { 'The', 'The ' },
    { 'the', 'fox' }
}

constant char TEST_EXPECTED[][NAV_MAX_BUFFER] = {
    '',
    ' quick brown ',
    ' brown fox ',
    'lazy',
    '',
    '',
    '',
    '',
    '',
    ''
}


define_function TestNAVGetStringBetween(char text[]) {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVGetStringBetween *****************'")

    for (x = 1; x <= length_array(TEST); x++) {
        stack_var char token[2][NAV_MAX_BUFFER]
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        token[1] = TEST[x][1]
        token[2] = TEST[x][2]

        expected = TEST_EXPECTED[x]

        result = NAVGetStringBetween(text, token[1], token[2])

        if (!NAVAssertStringEqual(expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
