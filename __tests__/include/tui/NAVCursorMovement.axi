PROGRAM_NAME='NAVCursorMovement'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

DEFINE_VARIABLE

volatile char CURSOR_UP_TEST[3][NAV_MAX_CHARS]
volatile char CURSOR_DOWN_TEST[3][NAV_MAX_CHARS]
volatile char CURSOR_FORWARD_TEST[3][NAV_MAX_CHARS]
volatile char CURSOR_BACK_TEST[3][NAV_MAX_CHARS]
volatile char CURSOR_POSITION_TEST[3][NAV_MAX_CHARS]
volatile char CURSOR_HOME_EXPECTED[NAV_MAX_CHARS]
volatile char CURSOR_HIDE_EXPECTED[NAV_MAX_CHARS]
volatile char CURSOR_SHOW_EXPECTED[NAV_MAX_CHARS]

define_function SetupCursorMovementExpectedValues() {
    CURSOR_UP_TEST[1] = "$1B, '[1A'"
    CURSOR_UP_TEST[2] = "$1B, '[5A'"
    CURSOR_UP_TEST[3] = "$1B, '[10A'"

    CURSOR_DOWN_TEST[1] = "$1B, '[1B'"
    CURSOR_DOWN_TEST[2] = "$1B, '[5B'"
    CURSOR_DOWN_TEST[3] = "$1B, '[10B'"

    CURSOR_FORWARD_TEST[1] = "$1B, '[1C'"
    CURSOR_FORWARD_TEST[2] = "$1B, '[5C'"
    CURSOR_FORWARD_TEST[3] = "$1B, '[10C'"

    CURSOR_BACK_TEST[1] = "$1B, '[1D'"
    CURSOR_BACK_TEST[2] = "$1B, '[5D'"
    CURSOR_BACK_TEST[3] = "$1B, '[10D'"

    CURSOR_POSITION_TEST[1] = "$1B, '[1;1H'"
    CURSOR_POSITION_TEST[2] = "$1B, '[10;20H'"
    CURSOR_POSITION_TEST[3] = "$1B, '[25;80H'"

    CURSOR_HOME_EXPECTED = "$1B, '[H'"
    CURSOR_HIDE_EXPECTED = "$1B, '[?25l'"
    CURSOR_SHOW_EXPECTED = "$1B, '[?25h'"
}

define_function TestNAVCursorMovement() {
    stack_var integer x
    stack_var char result[NAV_MAX_CHARS]

    NAVLog("'***************** NAVCursorMovement *****************'")

    SetupCursorMovementExpectedValues()

    // Test NAVCursorUp
    for (x = 1; x <= length_array(CURSOR_UP_TEST); x++) {
        result = NAVCursorUp(x)
        if (!NAVAssertStringEqual('Cursor Up Test', CURSOR_UP_TEST[x], result)) {
            NAVLogTestFailed(x, CURSOR_UP_TEST[x], result)
            continue
        }
        NAVLogTestPassed(x)
    }

    // Test NAVCursorDown
    for (x = 1; x <= length_array(CURSOR_DOWN_TEST); x++) {
        result = NAVCursorDown(x)
        if (!NAVAssertStringEqual('Cursor Down Test', CURSOR_DOWN_TEST[x], result)) {
            NAVLogTestFailed(x + 3, CURSOR_DOWN_TEST[x], result)
            continue
        }
        NAVLogTestPassed(x + 3)
    }

    // Test NAVCursorForward
    for (x = 1; x <= length_array(CURSOR_FORWARD_TEST); x++) {
        result = NAVCursorForward(x)
        if (!NAVAssertStringEqual('Cursor Forward Test', CURSOR_FORWARD_TEST[x], result)) {
            NAVLogTestFailed(x + 6, CURSOR_FORWARD_TEST[x], result)
            continue
        }
        NAVLogTestPassed(x + 6)
    }

    // Test NAVCursorBack
    for (x = 1; x <= length_array(CURSOR_BACK_TEST); x++) {
        result = NAVCursorBack(x)
        if (!NAVAssertStringEqual('Cursor Back Test', CURSOR_BACK_TEST[x], result)) {
            NAVLogTestFailed(x + 9, CURSOR_BACK_TEST[x], result)
            continue
        }
        NAVLogTestPassed(x + 9)
    }

    // Test NAVCursorPosition
    result = NAVCursorPosition(1, 1)
    if (!NAVAssertStringEqual('Cursor Position Test 1', CURSOR_POSITION_TEST[1], result)) {
        NAVLogTestFailed(13, CURSOR_POSITION_TEST[1], result)
    }
    else {
        NAVLogTestPassed(13)
    }

    result = NAVCursorPosition(10, 20)
    if (!NAVAssertStringEqual('Cursor Position Test 2', CURSOR_POSITION_TEST[2], result)) {
        NAVLogTestFailed(14, CURSOR_POSITION_TEST[2], result)
    }
    else {
        NAVLogTestPassed(14)
    }

    result = NAVCursorPosition(25, 80)
    if (!NAVAssertStringEqual('Cursor Position Test 3', CURSOR_POSITION_TEST[3], result)) {
        NAVLogTestFailed(15, CURSOR_POSITION_TEST[3], result)
    }
    else {
        NAVLogTestPassed(15)
    }

    // Test NAVCursorHome
    result = NAVCursorHome()
    if (!NAVAssertStringEqual('Cursor Home Test', CURSOR_HOME_EXPECTED, result)) {
        NAVLogTestFailed(16, CURSOR_HOME_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(16)
    }

    // Test NAVCursorHide
    result = NAVCursorHide()
    if (!NAVAssertStringEqual('Cursor Hide Test', CURSOR_HIDE_EXPECTED, result)) {
        NAVLogTestFailed(17, CURSOR_HIDE_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(17)
    }

    // Test NAVCursorShow
    result = NAVCursorShow()
    if (!NAVAssertStringEqual('Cursor Show Test', CURSOR_SHOW_EXPECTED, result)) {
        NAVLogTestFailed(18, CURSOR_SHOW_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(18)
    }
}
