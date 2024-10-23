PROGRAM_NAME='NAVRegexCompile'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char COMPILE_TEST[][255] = {
    '\d+',
    '\w+',
    '\w*',
    '\s',
    '\s+',
    '\s*',
    '\d\w?\s',
    '\d\w\s+',
    '\d?\w\s*',
    '\D+',
    '\D*',
    '\D\s',
    '\W+',
    '\S*',
    '^[a-zA-Z0-9_]+$'
}


define_function TestNAVRegexCompile() {
    stack_var integer x

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVRegexCompile *****************'")

    for (x = 15; x <= 15; x++) {
        stack_var _NAVRegexParser parser

        if (!NAVRegexCompile(COMPILE_TEST[x], parser)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        NAVLogTestPassed(x)
    }
}
