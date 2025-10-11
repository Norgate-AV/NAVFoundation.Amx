PROGRAM_NAME='NAVUIElements'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

DEFINE_VARIABLE

volatile char HORIZONTAL_LINE_TEST[3][NAV_MAX_BUFFER]
volatile char BOX_TEST[2][NAV_MAX_BUFFER]
volatile char CENTER_TEXT_TEST[4][NAV_MAX_BUFFER]

define_function SetupUIElementsExpectedValues() {
    HORIZONTAL_LINE_TEST[1] = '─'
    HORIZONTAL_LINE_TEST[2] = '─────'
    HORIZONTAL_LINE_TEST[3] = '──────────'

    BOX_TEST[1] = "'┌─┐', $0D, $0A, '│ │', $0D, $0A, '└─┘'"
    BOX_TEST[2] = "'┌───┐', $0D, $0A, '│   │', $0D, $0A, '└───┘'"

    CENTER_TEXT_TEST[1] = '     Hello     '
    CENTER_TEXT_TEST[2] = '   World   '
    CENTER_TEXT_TEST[3] = 'Centered T'  // Text longer than width gets truncated
    CENTER_TEXT_TEST[4] = '  Test  '
}

define_function TestNAVUIElements() {
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVUIElements *****************'")

    SetupUIElementsExpectedValues()

    // Test NAVDrawHorizontalLine
    result = NAVDrawHorizontalLine(1)
    if (!NAVAssertStringEqual('Draw Horizontal Line 1 Test', HORIZONTAL_LINE_TEST[1], result)) {
        NAVLogTestFailed(1, HORIZONTAL_LINE_TEST[1], result)
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVDrawHorizontalLine(5)
    if (!NAVAssertStringEqual('Draw Horizontal Line 5 Test', HORIZONTAL_LINE_TEST[2], result)) {
        NAVLogTestFailed(2, HORIZONTAL_LINE_TEST[2], result)
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVDrawHorizontalLine(10)
    if (!NAVAssertStringEqual('Draw Horizontal Line 10 Test', HORIZONTAL_LINE_TEST[3], result)) {
        NAVLogTestFailed(3, HORIZONTAL_LINE_TEST[3], result)
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test NAVDrawBox
    result = NAVDrawBox(3, 3)
    if (!NAVAssertStringEqual('Draw Box 3x3 Test', BOX_TEST[1], result)) {
        NAVLogTestFailed(4, BOX_TEST[1], result)
    }
    else {
        NAVLogTestPassed(4)
    }

    result = NAVDrawBox(5, 3)
    if (!NAVAssertStringEqual('Draw Box 5x3 Test', BOX_TEST[2], result)) {
        NAVLogTestFailed(5, BOX_TEST[2], result)
    }
    else {
        NAVLogTestPassed(5)
    }

    // Test NAVCenterText
    result = NAVCenterText('Hello', 15)
    if (!NAVAssertStringEqual('Center Text Hello Test', CENTER_TEXT_TEST[1], result)) {
        NAVLogTestFailed(6, CENTER_TEXT_TEST[1], result)
    }
    else {
        NAVLogTestPassed(6)
    }

    result = NAVCenterText('World', 11)
    if (!NAVAssertStringEqual('Center Text World Test', CENTER_TEXT_TEST[2], result)) {
        NAVLogTestFailed(7, CENTER_TEXT_TEST[2], result)
    }
    else {
        NAVLogTestPassed(7)
    }

    result = NAVCenterText('Centered Text', 10)  // Text longer than width
    if (!NAVAssertStringEqual('Center Text Longer Test', CENTER_TEXT_TEST[3], result)) {
        NAVLogTestFailed(8, CENTER_TEXT_TEST[3], result)
    }
    else {
        NAVLogTestPassed(8)
    }

    result = NAVCenterText('Test', 8)
    if (!NAVAssertStringEqual('Center Text Test Test', CENTER_TEXT_TEST[4], result)) {
        NAVLogTestFailed(9, CENTER_TEXT_TEST[4], result)
    }
    else {
        NAVLogTestPassed(9)
    }
}
