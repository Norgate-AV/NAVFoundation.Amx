PROGRAM_NAME='NAVPathBaseName'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.PathUtils.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char BASENAME_EXPECTED[][255] = {
    'file.txt',
    'file.txt',
    '\home\user\docs\file.txt',
    '\home\user\docs\projects\file.txt',
    'fortunate_yuck.xht',
    'joyfully.ico',
    'now_goodwill_yearningly.gif',
    'duh_bandana_after.so',
    'manicure_instead.lrf',
    'barring_unfortunately.bin',
    '',
    '',
    'home',
    'home',
    'home',
    'home',
    'user',
    'user',
    '.',
    '..',
    '',
    'barring_unfortunately.bin.bak'
}


define_function TestNAVPathBaseName(char paths[][]) {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVPathBaseName *****************'")

    for (x = 1; x <= length_array(paths); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = BASENAME_EXPECTED[x]

        result = NAVPathBaseName(paths[x])

        if (!NAVAssertStringEqual('PathBaseName', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
