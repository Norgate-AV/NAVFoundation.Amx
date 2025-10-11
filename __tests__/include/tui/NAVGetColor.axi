PROGRAM_NAME='NAVGetColor'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char GET_COLOR_TEST[][NAV_MAX_CHARS] = {
    '[0m',      // Reset
    '[1m',      // Bold
    '[31m',     // Red foreground
    '[41m',     // Red background
    '[38;5;196m', // 256-color red
    '[38;2;255;0;0m' // True color red
}

DEFINE_VARIABLE

volatile char GET_COLOR_EXPECTED[6][NAV_MAX_CHARS]

define_function SetupGetColorExpectedValues() {
    GET_COLOR_EXPECTED[1] = "$1B, '[0m'"
    GET_COLOR_EXPECTED[2] = "$1B, '[1m'"
    GET_COLOR_EXPECTED[3] = "$1B, '[31m'"
    GET_COLOR_EXPECTED[4] = "$1B, '[41m'"
    GET_COLOR_EXPECTED[5] = "$1B, '[38;5;196m'"
    GET_COLOR_EXPECTED[6] = "$1B, '[38;2;255;0;0m'"
}

define_function TestNAVGetColor() {
    stack_var integer x

    NAVLog("'***************** NAVGetColor *****************'")

    SetupGetColorExpectedValues()

    for (x = 1; x <= length_array(GET_COLOR_TEST); x++) {
        stack_var char input[NAV_MAX_CHARS]
        stack_var char expected[NAV_MAX_CHARS]
        stack_var char result[NAV_MAX_CHARS]

        input = GET_COLOR_TEST[x]
        expected = GET_COLOR_EXPECTED[x]
        result = NAVGetColor(input)

        if (!NAVAssertStringEqual('Get Color Test', expected, result)) {
            NAVLogTestFailed(x, expected, result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
