PROGRAM_NAME='NAVPathRelative'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.PathUtils.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char RELATIVE_EXPECTED[][255] = {
    '../../..',
    '../../../..',
    '..',
    '..',
    '../..',
    '../../..',
    '../..',
    '../..',
    '../..',
    '../../..',
    '',
    '',
    '..',
    '..',
    '..',
    '..',
    '../..',
    '../..',
    '',
    '',
    '',
    '../../..'
}


define_function TestNAVPathRelative(char paths[][]) {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVPathRelative *****************'")

    for (x = 1; x <= length_array(paths); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = RELATIVE_EXPECTED[x]

        result = NAVPathRelative(paths[x], '')

        if (!NAVAssertStringEqual(expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
