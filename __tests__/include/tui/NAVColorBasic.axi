PROGRAM_NAME='NAVColorBasic'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char COLOR_TEST_INPUT[] = 'Test Message'

DEFINE_VARIABLE

volatile char COLOR_RED_EXPECTED[100]
volatile char COLOR_GREEN_EXPECTED[100]
volatile char COLOR_YELLOW_EXPECTED[100]
volatile char COLOR_BLUE_EXPECTED[100]
volatile char COLOR_MAGENTA_EXPECTED[100]
volatile char COLOR_CYAN_EXPECTED[100]
volatile char COLOR_WHITE_EXPECTED[100]
volatile char COLOR_BLACK_EXPECTED[100]

define_function SetupColorBasicExpectedValues() {
    COLOR_RED_EXPECTED = "$1B, '[91m', COLOR_TEST_INPUT, $1B, '[0m'"
    COLOR_GREEN_EXPECTED = "$1B, '[92m', COLOR_TEST_INPUT, $1B, '[0m'"
    COLOR_YELLOW_EXPECTED = "$1B, '[93m', COLOR_TEST_INPUT, $1B, '[0m'"
    COLOR_BLUE_EXPECTED = "$1B, '[94m', COLOR_TEST_INPUT, $1B, '[0m'"
    COLOR_MAGENTA_EXPECTED = "$1B, '[95m', COLOR_TEST_INPUT, $1B, '[0m'"
    COLOR_CYAN_EXPECTED = "$1B, '[96m', COLOR_TEST_INPUT, $1B, '[0m'"
    COLOR_WHITE_EXPECTED = "$1B, '[97m', COLOR_TEST_INPUT, $1B, '[0m'"
    COLOR_BLACK_EXPECTED = "$1B, '[90m', COLOR_TEST_INPUT, $1B, '[0m'"
}

define_function TestNAVColorBasic() {
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVColorBasic *****************'")

    SetupColorBasicExpectedValues()

    // Test NAVColorRed
    result = NAVColorRed(COLOR_TEST_INPUT)
    if (!NAVAssertStringEqual('Color Red Test', COLOR_RED_EXPECTED, result)) {
        NAVLogTestFailed(1, COLOR_RED_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test NAVColorGreen
    result = NAVColorGreen(COLOR_TEST_INPUT)
    if (!NAVAssertStringEqual('Color Green Test', COLOR_GREEN_EXPECTED, result)) {
        NAVLogTestFailed(2, COLOR_GREEN_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test NAVColorYellow
    result = NAVColorYellow(COLOR_TEST_INPUT)
    if (!NAVAssertStringEqual('Color Yellow Test', COLOR_YELLOW_EXPECTED, result)) {
        NAVLogTestFailed(3, COLOR_YELLOW_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test NAVColorBlue
    result = NAVColorBlue(COLOR_TEST_INPUT)
    if (!NAVAssertStringEqual('Color Blue Test', COLOR_BLUE_EXPECTED, result)) {
        NAVLogTestFailed(4, COLOR_BLUE_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(4)
    }

    // Test NAVColorMagenta
    result = NAVColorMagenta(COLOR_TEST_INPUT)
    if (!NAVAssertStringEqual('Color Magenta Test', COLOR_MAGENTA_EXPECTED, result)) {
        NAVLogTestFailed(5, COLOR_MAGENTA_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(5)
    }

    // Test NAVColorCyan
    result = NAVColorCyan(COLOR_TEST_INPUT)
    if (!NAVAssertStringEqual('Color Cyan Test', COLOR_CYAN_EXPECTED, result)) {
        NAVLogTestFailed(6, COLOR_CYAN_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(6)
    }

    // Test NAVColorWhite
    result = NAVColorWhite(COLOR_TEST_INPUT)
    if (!NAVAssertStringEqual('Color White Test', COLOR_WHITE_EXPECTED, result)) {
        NAVLogTestFailed(7, COLOR_WHITE_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(7)
    }

    // Test NAVColorBlack
    result = NAVColorBlack(COLOR_TEST_INPUT)
    if (!NAVAssertStringEqual('Color Black Test', COLOR_BLACK_EXPECTED, result)) {
        NAVLogTestFailed(8, COLOR_BLACK_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(8)
    }
}
