PROGRAM_NAME='NAVArraySearchFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVArrayBinarySearchIntegerRecursive() {
    stack_var integer array[5]
    stack_var integer result

    NAVLog("'***************** NAVArrayBinarySearchIntegerRecursive *****************'")

    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    // Test 1: Find existing value in middle
    result = NAVArrayBinarySearchIntegerRecursive(array, 30)
    if (result != 3) {
        NAVLogTestFailed(1, "'3'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVArrayBinarySearchIntegerRecursive(array, 99)
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Find first element
    result = NAVArrayBinarySearchIntegerRecursive(array, 10)
    if (result != 1) {
        NAVLogTestFailed(3, "'1'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test 4: Find last element
    result = NAVArrayBinarySearchIntegerRecursive(array, 50)
    if (result != 5) {
        NAVLogTestFailed(4, "'5'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(4)
    }
}

define_function TestNAVArrayBinarySearchIntegerIterative() {
    stack_var integer array[5]
    stack_var integer result

    NAVLog("'***************** NAVArrayBinarySearchIntegerIterative *****************'")

    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    // Test 1: Find existing value in middle
    result = NAVArrayBinarySearchIntegerIterative(array, 30)
    if (result != 3) {
        NAVLogTestFailed(1, "'3'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVArrayBinarySearchIntegerIterative(array, 99)
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Find first element
    result = NAVArrayBinarySearchIntegerIterative(array, 10)
    if (result != 1) {
        NAVLogTestFailed(3, "'1'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(3)
    }
}

define_function TestNAVArrayTernarySearchInteger() {
    stack_var integer array[5]
    stack_var integer result

    NAVLog("'***************** NAVArrayTernarySearchInteger *****************'")

    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    // Test 1: Find existing value
    result = NAVArrayTernarySearchInteger(array, 30)
    if (result != 3) {
        NAVLogTestFailed(1, "'3'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVArrayTernarySearchInteger(array, 99)
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVArrayJumpSearchInteger() {
    stack_var integer array[9]
    stack_var integer result

    NAVLog("'***************** NAVArrayJumpSearchInteger *****************'")

    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    array[6] = 60
    array[7] = 70
    array[8] = 80
    array[9] = 90
    set_length_array(array, 9)

    // Test 1: Find existing value
    result = NAVArrayJumpSearchInteger(array, 50)
    if (result != 5) {
        NAVLogTestFailed(1, "'5'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVArrayJumpSearchInteger(array, 99)
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVArrayExponentialSearchInteger() {
    stack_var integer array[5]
    stack_var integer result

    NAVLog("'***************** NAVArrayExponentialSearchInteger *****************'")

    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    // Test 1: Find existing value
    result = NAVArrayExponentialSearchInteger(array, 30)
    if (result != 3) {
        NAVLogTestFailed(1, "'3'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVArrayExponentialSearchInteger(array, 99)
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }
}
