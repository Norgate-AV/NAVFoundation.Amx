PROGRAM_NAME='NAVUtilityFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

DEFINE_VARIABLE

volatile char RESET_FORMATTING_EXPECTED[NAV_MAX_CHARS]
volatile char SAVE_CURSOR_POSITION_EXPECTED[NAV_MAX_CHARS]
volatile char RESTORE_CURSOR_POSITION_EXPECTED[NAV_MAX_CHARS]

define_function SetupUtilityFunctionsExpectedValues() {
    RESET_FORMATTING_EXPECTED = "$1B, '[0m'"
    SAVE_CURSOR_POSITION_EXPECTED = "$1B, '[s'"
    RESTORE_CURSOR_POSITION_EXPECTED = "$1B, '[u'"
}

define_function TestNAVUtilityFunctions() {
    stack_var char result[NAV_MAX_CHARS]

    NAVLog("'***************** NAVUtilityFunctions *****************'")

    SetupUtilityFunctionsExpectedValues()

    // Test NAVResetFormatting
    result = NAVResetFormatting()
    if (!NAVAssertStringEqual('Reset Formatting Test', RESET_FORMATTING_EXPECTED, result)) {
        NAVLogTestFailed(1, RESET_FORMATTING_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test NAVSaveCursorPosition
    result = NAVSaveCursorPosition()
    if (!NAVAssertStringEqual('Save Cursor Position Test', SAVE_CURSOR_POSITION_EXPECTED, result)) {
        NAVLogTestFailed(2, SAVE_CURSOR_POSITION_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test NAVRestoreCursorPosition
    result = NAVRestoreCursorPosition()
    if (!NAVAssertStringEqual('Restore Cursor Position Test', RESTORE_CURSOR_POSITION_EXPECTED, result)) {
        NAVLogTestFailed(3, RESTORE_CURSOR_POSITION_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(3)
    }
}
