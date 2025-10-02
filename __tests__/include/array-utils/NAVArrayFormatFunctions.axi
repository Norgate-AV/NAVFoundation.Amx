PROGRAM_NAME='NAVArrayFormatFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVFormatArrayInteger() {
    stack_var integer array[5]
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVFormatArrayInteger *****************'")

    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    result = NAVFormatArrayInteger(array)

    // Expected format: "[10, 20, 30, 40, 50]"
    if (result != '[10, 20, 30, 40, 50]') {
        NAVLogTestFailed(1, "'[10, 20, 30, 40, 50]'", result)
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVFormatArrayString() {
    stack_var char array[3][20]
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** NAVFormatArrayString *****************'")

    array[1] = 'apple'
    array[2] = 'banana'
    array[3] = 'cherry'
    set_length_array(array, 3)

    result = NAVFormatArrayString(array)

    // Expected format: "['apple', 'banana', 'cherry']"
    if (result != "'[apple, banana, cherry]'") {
        NAVLogTestFailed(1, "'[apple, banana, cherry]'", result)
    }
    else {
        NAVLogTestPassed(1)
    }
}
