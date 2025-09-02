PROGRAM_NAME='NAVPathDirName'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.PathUtils.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char DIRNAME_EXPECTED[][255] = {
    '/home/user',
    'home/user/docs',
    '.',
    '.',
    '/lost+found',
    '/usr/ports',
    '/lib',
    '/net',
    '/Users',
    '/var/yp',
    '.',
    '/',
    '.',
    '.',
    '.',
    '..',
    'home',
    'home',
    '.',
    '.',
    '/',
    '/var/yp'
}


define_function TestNAVPathDirName(char paths[][]) {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVPathDirName *****************'")

    for (x = 1; x <= length_array(paths); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = DIRNAME_EXPECTED[x]

        result = NAVPathDirName(paths[x])

        if (!NAVAssertStringEqual('PathDirName', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
