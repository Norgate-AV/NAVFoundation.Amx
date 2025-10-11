PROGRAM_NAME='NAVScreenClearing'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

DEFINE_VARIABLE

volatile char CLEAR_SCREEN_EXPECTED[NAV_MAX_CHARS]
volatile char CLEAR_SCREEN_FROM_CURSOR_EXPECTED[NAV_MAX_CHARS]
volatile char CLEAR_SCREEN_TO_CURSOR_EXPECTED[NAV_MAX_CHARS]
volatile char CLEAR_LINE_EXPECTED[NAV_MAX_CHARS]
volatile char CLEAR_LINE_FROM_CURSOR_EXPECTED[NAV_MAX_CHARS]
volatile char CLEAR_LINE_TO_CURSOR_EXPECTED[NAV_MAX_CHARS]

define_function SetupScreenClearingExpectedValues() {
    CLEAR_SCREEN_EXPECTED = "$1B, '[2J'"
    CLEAR_SCREEN_FROM_CURSOR_EXPECTED = "$1B, '[0J'"
    CLEAR_SCREEN_TO_CURSOR_EXPECTED = "$1B, '[1J'"
    CLEAR_LINE_EXPECTED = "$1B, '[2K'"
    CLEAR_LINE_FROM_CURSOR_EXPECTED = "$1B, '[0K'"
    CLEAR_LINE_TO_CURSOR_EXPECTED = "$1B, '[1K'"
}

define_function TestNAVScreenClearing() {
    stack_var char result[NAV_MAX_CHARS]

    NAVLog("'***************** NAVScreenClearing *****************'")

    SetupScreenClearingExpectedValues()

    // Test NAVClearScreen
    result = NAVClearScreen()
    if (!NAVAssertStringEqual('Clear Screen Test', CLEAR_SCREEN_EXPECTED, result)) {
        NAVLogTestFailed(1, CLEAR_SCREEN_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test NAVClearScreenFromCursor
    result = NAVClearScreenFromCursor()
    if (!NAVAssertStringEqual('Clear Screen From Cursor Test', CLEAR_SCREEN_FROM_CURSOR_EXPECTED, result)) {
        NAVLogTestFailed(2, CLEAR_SCREEN_FROM_CURSOR_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test NAVClearScreenToCursor
    result = NAVClearScreenToCursor()
    if (!NAVAssertStringEqual('Clear Screen To Cursor Test', CLEAR_SCREEN_TO_CURSOR_EXPECTED, result)) {
        NAVLogTestFailed(3, CLEAR_SCREEN_TO_CURSOR_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test NAVClearLine
    result = NAVClearLine()
    if (!NAVAssertStringEqual('Clear Line Test', CLEAR_LINE_EXPECTED, result)) {
        NAVLogTestFailed(4, CLEAR_LINE_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(4)
    }

    // Test NAVClearLineFromCursor
    result = NAVClearLineFromCursor()
    if (!NAVAssertStringEqual('Clear Line From Cursor Test', CLEAR_LINE_FROM_CURSOR_EXPECTED, result)) {
        NAVLogTestFailed(5, CLEAR_LINE_FROM_CURSOR_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(5)
    }

    // Test NAVClearLineToCursor
    result = NAVClearLineToCursor()
    if (!NAVAssertStringEqual('Clear Line To Cursor Test', CLEAR_LINE_TO_CURSOR_EXPECTED, result)) {
        NAVLogTestFailed(6, CLEAR_LINE_TO_CURSOR_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(6)
    }
}
