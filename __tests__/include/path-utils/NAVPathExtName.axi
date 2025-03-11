PROGRAM_NAME='NAVPathExtName'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.PathUtils.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char EXTNAME_EXPECTED[][255] = {
    '.txt',
    '.txt',
    '.txt',
    '.txt',
    '.xht',
    '.ico',
    '.gif',
    '.so',
    '.lrf',
    '.bin',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '.bak'
}


define_function TestNAVPathExtName(char paths[][]) {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVPathExtName *****************'")

    for (x = 1; x <= length_array(paths); x++) {
        stack_var char expected[NAV_MAX_BUFFER]
        stack_var char result[NAV_MAX_BUFFER]

        expected = EXTNAME_EXPECTED[x]

        result = NAVPathExtName(paths[x])

        if (!NAVAssertStringEqual(expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
