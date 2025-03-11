PROGRAM_NAME='NAVPathJoinPath'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.PathUtils.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char JOIN_EXPECTED[][255] = {
    '/home/user/file.txt/someotherpath',
    'home/user/docs/file.txt/someotherpath',
    '\home\user\docs\file.txt/someotherpath',
    '\home\user\docs\projects\file.txt/someotherpath',
    '/lost+found/fortunate_yuck.xht/someotherpath',
    '/usr/ports/joyfully.ico/someotherpath',
    '/lib/now_goodwill_yearningly.gif/someotherpath',
    '/net/duh_bandana_after.so/someotherpath',
    '/Users/manicure_instead.lrf/someotherpath',
    '/var/yp/barring_unfortunately.bin/someotherpath',
    'someotherpath',
    '/someotherpath',
    'home/someotherpath',
    'home/someotherpath',
    'home/someotherpath',
    '../home/someotherpath',
    'home/user/someotherpath',
    'home/user/someotherpath',
    'someotherpath',
    '../someotherpath',
    '/someotherpath',
    '/var/yp/barring_unfortunately.bin.bak/someotherpath'
}


define_function TestNAVPathJoinPath(char paths[][]) {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVPathJoinPath *****************'")

    for (x = 1; x <= length_array(paths); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = JOIN_EXPECTED[x]

        result = NAVPathJoinPath(paths[x], '', '', 'someotherpath')

        if (!NAVAssertStringEqual(expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
