PROGRAM_NAME='NAVGetStringBetween'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char GET_STRING_BETWEEN_SUBJECT[] = 'The quick brown fox jumps over the lazy dog'

constant char GET_STRING_BETWEEN_TEST[][][NAV_MAX_BUFFER] = {
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

constant char GET_STRING_BETWEEN_EXPECTED[][NAV_MAX_BUFFER] = {
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


define_function TestNAVGetStringBetween() {
    stack_var integer x

    NAVLog("'***************** NAVGetStringBetween *****************'")

    for (x = 1; x <= length_array(GET_STRING_BETWEEN_TEST); x++) {
        stack_var char token[2][NAV_MAX_BUFFER]
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        token[1] = GET_STRING_BETWEEN_TEST[x][1]
        token[2] = GET_STRING_BETWEEN_TEST[x][2]

        expected = GET_STRING_BETWEEN_EXPECTED[x]

        result = NAVGetStringBetween(GET_STRING_BETWEEN_SUBJECT, token[1], token[2])

        if (!NAVAssertStringEqual('Get String Between Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
