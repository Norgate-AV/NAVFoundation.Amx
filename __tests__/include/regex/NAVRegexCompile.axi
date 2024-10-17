PROGRAM_NAME='NAVRegexCompile'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Testing.axi'


DEFINE_CONSTANT

constant char COMPILE_TEST[][255] = {
    '\d',
    '\d+',
    '\d*',
    '\w',
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

    for (x = 1; x <= length_array(COMPILE_TEST); x++) {
        stack_var _NAVRegexState state[MAX_REGEXP_OBJECTS]

        if (!NAVRegexCompile(COMPILE_TEST[x], state)) {
            NAVLogTestFailed(x, 'true', 'false')
            re_print(state)
            continue
        }

        NAVLogTestPassed(x)
    }
}
