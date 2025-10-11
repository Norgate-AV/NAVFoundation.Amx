PROGRAM_NAME='NAVRepeatChar'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REPEAT_CHAR_TEST[][NAV_MAX_CHARS] = {
    'A',           // Single A
    'AAA',         // Three A's
    '-----',       // Five dashes
    '     ',       // Five spaces
    '****',        // Four asterisks
    'X'            // Single X
}

define_function TestNAVRepeatChar() {
    stack_var integer x
    stack_var char result[NAV_MAX_CHARS]

    NAVLog("'***************** NAVRepeatChar *****************'")

    // Test various character repetitions
    result = NAVRepeatChar('A', 1)
    if (!NAVAssertStringEqual('Repeat Char A x1 Test', REPEAT_CHAR_TEST[1], result)) {
        NAVLogTestFailed(1, REPEAT_CHAR_TEST[1], result)
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVRepeatChar('A', 3)
    if (!NAVAssertStringEqual('Repeat Char A x3 Test', REPEAT_CHAR_TEST[2], result)) {
        NAVLogTestFailed(2, REPEAT_CHAR_TEST[2], result)
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVRepeatChar('-', 5)
    if (!NAVAssertStringEqual('Repeat Char Dash x5 Test', REPEAT_CHAR_TEST[3], result)) {
        NAVLogTestFailed(3, REPEAT_CHAR_TEST[3], result)
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVRepeatChar(' ', 5)
    if (!NAVAssertStringEqual('Repeat Char Space x5 Test', REPEAT_CHAR_TEST[4], result)) {
        NAVLogTestFailed(4, REPEAT_CHAR_TEST[4], result)
    }
    else {
        NAVLogTestPassed(4)
    }

    result = NAVRepeatChar('*', 4)
    if (!NAVAssertStringEqual('Repeat Char Asterisk x4 Test', REPEAT_CHAR_TEST[5], result)) {
        NAVLogTestFailed(5, REPEAT_CHAR_TEST[5], result)
    }
    else {
        NAVLogTestPassed(5)
    }

    result = NAVRepeatChar('X', 1)
    if (!NAVAssertStringEqual('Repeat Char X x1 Test', REPEAT_CHAR_TEST[6], result)) {
        NAVLogTestFailed(6, REPEAT_CHAR_TEST[6], result)
    }
    else {
        NAVLogTestPassed(6)
    }

    // Test edge cases
    result = NAVRepeatChar('Z', 0)
    if (!NAVAssertStringEqual('Repeat Char Z x0 Test', '', result)) {
        NAVLogTestFailed(7, '', result)
    }
    else {
        NAVLogTestPassed(7)
    }

    result = NAVRepeatChar('!', 10)
    if (!NAVAssertStringEqual('Repeat Char Exclamation x10 Test', '!!!!!!!!!!', result)) {
        NAVLogTestFailed(8, '!!!!!!!!!!', result)
    }
    else {
        NAVLogTestPassed(8)
    }
}
