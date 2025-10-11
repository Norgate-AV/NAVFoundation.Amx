PROGRAM_NAME='NAVColorRGB'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char RGB_TEST_TEXT[] = 'RGB Test'

DEFINE_VARIABLE

volatile char SET_FOREGROUND_RGB_TEST[6][NAV_MAX_CHARS]
volatile char SET_BACKGROUND_RGB_TEST[4][NAV_MAX_CHARS]
volatile char COLOR_RGB_TEST[4][NAV_MAX_BUFFER]

define_function SetupColorRGBExpectedValues() {
    SET_FOREGROUND_RGB_TEST[1] = "$1B, '[38;2;255;0;0m'"
    SET_FOREGROUND_RGB_TEST[2] = "$1B, '[38;2;0;255;0m'"
    SET_FOREGROUND_RGB_TEST[3] = "$1B, '[38;2;0;0;255m'"
    SET_FOREGROUND_RGB_TEST[4] = "$1B, '[38;2;255;255;0m'"
    SET_FOREGROUND_RGB_TEST[5] = "$1B, '[38;2;255;0;255m'"
    SET_FOREGROUND_RGB_TEST[6] = "$1B, '[38;2;0;255;255m'"

    SET_BACKGROUND_RGB_TEST[1] = "$1B, '[48;2;255;0;0m'"
    SET_BACKGROUND_RGB_TEST[2] = "$1B, '[48;2;0;255;0m'"
    SET_BACKGROUND_RGB_TEST[3] = "$1B, '[48;2;0;0;255m'"
    SET_BACKGROUND_RGB_TEST[4] = "$1B, '[48;2;128;128;128m'"

    COLOR_RGB_TEST[1] = "$1B, '[38;2;255;0;0m', RGB_TEST_TEXT, $1B, '[0m'"
    COLOR_RGB_TEST[2] = "$1B, '[38;2;0;255;0m', RGB_TEST_TEXT, $1B, '[0m'"
    COLOR_RGB_TEST[3] = "$1B, '[38;2;0;0;255m', RGB_TEST_TEXT, $1B, '[0m'"
    COLOR_RGB_TEST[4] = "$1B, '[38;2;255;165;0m', RGB_TEST_TEXT, $1B, '[0m'"
}

define_function TestNAVColorRGB() {
    stack_var integer x
    stack_var char result[NAV_MAX_CHARS]

    NAVLog("'***************** NAVColorRGB *****************'")

    SetupColorRGBExpectedValues()

    // Test NAVSetForegroundRGB
    result = NAVSetForegroundRGB(255, 0, 0)
    if (!NAVAssertStringEqual('Set Foreground RGB Red Test', SET_FOREGROUND_RGB_TEST[1], result)) {
        NAVLogTestFailed(1, SET_FOREGROUND_RGB_TEST[1], result)
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVSetForegroundRGB(0, 255, 0)
    if (!NAVAssertStringEqual('Set Foreground RGB Green Test', SET_FOREGROUND_RGB_TEST[2], result)) {
        NAVLogTestFailed(2, SET_FOREGROUND_RGB_TEST[2], result)
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVSetForegroundRGB(0, 0, 255)
    if (!NAVAssertStringEqual('Set Foreground RGB Blue Test', SET_FOREGROUND_RGB_TEST[3], result)) {
        NAVLogTestFailed(3, SET_FOREGROUND_RGB_TEST[3], result)
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test NAVSetBackgroundRGB
    result = NAVSetBackgroundRGB(255, 0, 0)
    if (!NAVAssertStringEqual('Set Background RGB Red Test', SET_BACKGROUND_RGB_TEST[1], result)) {
        NAVLogTestFailed(4, SET_BACKGROUND_RGB_TEST[1], result)
    }
    else {
        NAVLogTestPassed(4)
    }

    result = NAVSetBackgroundRGB(128, 128, 128)
    if (!NAVAssertStringEqual('Set Background RGB Gray Test', SET_BACKGROUND_RGB_TEST[4], result)) {
        NAVLogTestFailed(5, SET_BACKGROUND_RGB_TEST[4], result)
    }
    else {
        NAVLogTestPassed(5)
    }

    // Test NAVColorRGB
    result = NAVColorRGB(RGB_TEST_TEXT, 255, 0, 0)
    if (!NAVAssertStringEqual('Color RGB Red Test', COLOR_RGB_TEST[1], result)) {
        NAVLogTestFailed(6, COLOR_RGB_TEST[1], result)
    }
    else {
        NAVLogTestPassed(6)
    }

    result = NAVColorRGB(RGB_TEST_TEXT, 0, 255, 0)
    if (!NAVAssertStringEqual('Color RGB Green Test', COLOR_RGB_TEST[2], result)) {
        NAVLogTestFailed(7, COLOR_RGB_TEST[2], result)
    }
    else {
        NAVLogTestPassed(7)
    }

    result = NAVColorRGB(RGB_TEST_TEXT, 255, 165, 0)
    if (!NAVAssertStringEqual('Color RGB Orange Test', COLOR_RGB_TEST[4], result)) {
        NAVLogTestFailed(8, COLOR_RGB_TEST[4], result)
    }
    else {
        NAVLogTestPassed(8)
    }
}
