PROGRAM_NAME='NAVPathNormalize'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.PathUtils.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NORMALIZE_EXPECTED[][255] = {
    '/home/user/file.txt',
    'home/user/docs/file.txt',
    '\home\user\docs\file.txt',
    '\home\user\docs\projects\file.txt',
    '/lost+found/fortunate_yuck.xht',
    '/usr/ports/joyfully.ico',
    '/lib/now_goodwill_yearningly.gif',
    '/net/duh_bandana_after.so',
    '/Users/manicure_instead.lrf',
    '/var/yp/barring_unfortunately.bin',
    '.',
    '/',
    'home',
    'home/',
    'home',
    '../home',
    'home/user',
    'home/user/',
    '.',
    '..',
    '/',
    '/var/yp/barring_unfortunately.bin.bak'
}


define_function TestNAVPathNormalize(char paths[][]) {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVPathNormalize *****************'")

    for (x = 1; x <= length_array(paths); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = NORMALIZE_EXPECTED[x]

        result = NAVPathNormalize(paths[x])

        if (!NAVAssertStringEqual('PathNormalize', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
