PROGRAM_NAME='NAVFindInArrayFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVFindInArrayINTEGER() {
    stack_var integer array[5]
    stack_var integer result

    NAVLog("'***************** NAVFindInArrayINTEGER *****************'")

    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    // Test 1: Find existing value
    result = NAVFindInArrayINTEGER(array, 30)
    if (result != 3) {
        NAVLogTestFailed(1, "'3'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVFindInArrayINTEGER(array, 99)
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Find first element
    result = NAVFindInArrayINTEGER(array, 10)
    if (result != 1) {
        NAVLogTestFailed(3, "'1'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test 4: Find last element
    result = NAVFindInArrayINTEGER(array, 50)
    if (result != 5) {
        NAVLogTestFailed(4, "'5'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(4)
    }
}

define_function TestNAVFindInArrayCHAR() {
    stack_var char array[5]
    stack_var integer result

    NAVLog("'***************** NAVFindInArrayCHAR *****************'")

    array[1] = 'A'
    array[2] = 'B'
    array[3] = 'C'
    array[4] = 'D'
    array[5] = 'E'
    set_length_array(array, 5)

    // Test 1: Find existing value
    result = NAVFindInArrayCHAR(array, 'C')
    if (result != 3) {
        NAVLogTestFailed(1, "'3'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVFindInArrayCHAR(array, 'Z')
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVFindInArraySTRING() {
    stack_var char array[5][20]
    stack_var integer result

    NAVLog("'***************** NAVFindInArraySTRING *****************'")

    array[1] = 'apple'
    array[2] = 'banana'
    array[3] = 'cherry'
    array[4] = 'date'
    array[5] = 'elderberry'
    set_length_array(array, 5)

    // Test 1: Find existing value
    result = NAVFindInArraySTRING(array, 'cherry')
    if (result != 3) {
        NAVLogTestFailed(1, "'3'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVFindInArraySTRING(array, 'fig')
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Find first element
    result = NAVFindInArraySTRING(array, 'apple')
    if (result != 1) {
        NAVLogTestFailed(3, "'1'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(3)
    }

    // Test 4: Find last element
    result = NAVFindInArraySTRING(array, 'elderberry')
    if (result != 5) {
        NAVLogTestFailed(4, "'5'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(4)
    }
}

define_function TestNAVFindInArrayLONG() {
    stack_var long array[5]
    stack_var integer result

    NAVLog("'***************** NAVFindInArrayLONG *****************'")

    array[1] = 1000000
    array[2] = 2000000
    array[3] = 3000000
    array[4] = 4000000
    array[5] = 5000000
    set_length_array(array, 5)

    // Test 1: Find existing value
    result = NAVFindInArrayLONG(array, 3000000)
    if (result != 3) {
        NAVLogTestFailed(1, "'3'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVFindInArrayLONG(array, 9999999)
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVFindInArrayFLOAT() {
    stack_var float array[5]
    stack_var integer result

    NAVLog("'***************** NAVFindInArrayFLOAT *****************'")

    array[1] = 1.1
    array[2] = 2.2
    array[3] = 3.3
    array[4] = 4.4
    array[5] = 5.5
    set_length_array(array, 5)

    // Test 1: Find existing value
    result = NAVFindInArrayFLOAT(array, 3.3)
    if (result != 3) {
        NAVLogTestFailed(1, "'3'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVFindInArrayFLOAT(array, 9.9)
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVFindInArrayDOUBLE() {
    stack_var double array[5]
    stack_var integer result

    NAVLog("'***************** NAVFindInArrayDOUBLE *****************'")

    array[1] = 1.123456789
    array[2] = 2.234567890
    array[3] = 3.345678901
    array[4] = 4.456789012
    array[5] = 5.567890123
    set_length_array(array, 5)

    // Test 1: Find existing value
    result = NAVFindInArrayDOUBLE(array, 3.345678901)
    if (result != 3) {
        NAVLogTestFailed(1, "'3'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find non-existing value
    result = NAVFindInArrayDOUBLE(array, 9.999999999)
    if (result != 0) {
        NAVLogTestFailed(2, "'0'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Find first element
    result = NAVFindInArrayDOUBLE(array, 1.123456789)
    if (result != 1) {
        NAVLogTestFailed(3, "'1'", "itoa(result)")
    }
    else {
        NAVLogTestPassed(3)
    }
}
