PROGRAM_NAME='NAVTextFormatting'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char TEXT_FORMAT_TEST_INPUT[] = 'Format Me'

DEFINE_VARIABLE

volatile char TEXT_BOLD_EXPECTED[NAV_MAX_BUFFER]
volatile char TEXT_UNDERLINE_EXPECTED[NAV_MAX_BUFFER]
volatile char TEXT_REVERSE_EXPECTED[NAV_MAX_BUFFER]

define_function SetupTextFormattingExpectedValues() {
    TEXT_BOLD_EXPECTED = "$1B, '[1m', TEXT_FORMAT_TEST_INPUT, $1B, '[0m'"
    TEXT_UNDERLINE_EXPECTED = "$1B, '[4m', TEXT_FORMAT_TEST_INPUT, $1B, '[0m'"
    TEXT_REVERSE_EXPECTED = "$1B, '[7m', TEXT_FORMAT_TEST_INPUT, $1B, '[0m'"
}

define_function TestNAVTextFormatting() {
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVTextFormatting *****************'")

    SetupTextFormattingExpectedValues()

    // Test NAVTextBold
    result = NAVTextBold(TEXT_FORMAT_TEST_INPUT)
    if (!NAVAssertStringEqual('Text Bold Test', TEXT_BOLD_EXPECTED, result)) {
        NAVLogTestFailed(1, TEXT_BOLD_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test NAVTextUnderline
    result = NAVTextUnderline(TEXT_FORMAT_TEST_INPUT)
    if (!NAVAssertStringEqual('Text Underline Test', TEXT_UNDERLINE_EXPECTED, result)) {
        NAVLogTestFailed(2, TEXT_UNDERLINE_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test NAVTextReverse
    result = NAVTextReverse(TEXT_FORMAT_TEST_INPUT)
    if (!NAVAssertStringEqual('Text Reverse Test', TEXT_REVERSE_EXPECTED, result)) {
        NAVLogTestFailed(3, TEXT_REVERSE_EXPECTED, result)
    }
    else {
        NAVLogTestPassed(3)
    }
}
