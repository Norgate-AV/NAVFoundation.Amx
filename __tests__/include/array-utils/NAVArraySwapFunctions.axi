PROGRAM_NAME='NAVArraySwapFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVArraySwapInteger() {
    stack_var integer array[5]

    NAVLog("'***************** NAVArraySwapInteger *****************'")

    // Test 1: Swap first and last elements
    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    NAVArraySwapInteger(array, 1, 5)

    if (array[1] != 50 || array[5] != 10) {
        NAVLogTestFailed(1, "'array[1]=50, array[5]=10'", "'array[1]=', itoa(array[1]), ', array[5]=', itoa(array[5])")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Swap middle elements
    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    NAVArraySwapInteger(array, 2, 4)

    if (array[2] != 40 || array[4] != 20) {
        NAVLogTestFailed(2, "'array[2]=40, array[4]=20'", "'array[2]=', itoa(array[2]), ', array[4]=', itoa(array[4])")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Swap adjacent elements
    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    NAVArraySwapInteger(array, 2, 3)

    if (array[2] != 30 || array[3] != 20) {
        NAVLogTestFailed(3, "'array[2]=30, array[3]=20'", "'array[2]=', itoa(array[2]), ', array[3]=', itoa(array[3])")
    }
    else {
        NAVLogTestPassed(3)
    }
}

define_function TestNAVArraySwapString() {
    stack_var char array[5][20]

    NAVLog("'***************** NAVArraySwapString *****************'")

    // Test 1: Swap first and last elements
    array[1] = 'Alice'
    array[2] = 'Bob'
    array[3] = 'Charlie'
    array[4] = 'David'
    array[5] = 'Eve'
    set_length_array(array, 5)

    NAVArraySwapString(array, 1, 5)

    if (array[1] != 'Eve' || array[5] != 'Alice') {
        NAVLogTestFailed(1, "'array[1]=Eve, array[5]=Alice'", "'array[1]=', array[1], ', array[5]=', array[5]")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Swap middle elements
    array[1] = 'Alice'
    array[2] = 'Bob'
    array[3] = 'Charlie'
    array[4] = 'David'
    array[5] = 'Eve'
    set_length_array(array, 5)

    NAVArraySwapString(array, 2, 4)

    if (array[2] != 'David' || array[4] != 'Bob') {
        NAVLogTestFailed(2, "'array[2]=David, array[4]=Bob'", "'array[2]=', array[2], ', array[4]=', array[4]")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Swap adjacent elements
    array[1] = 'Alice'
    array[2] = 'Bob'
    array[3] = 'Charlie'
    array[4] = 'David'
    array[5] = 'Eve'
    set_length_array(array, 5)

    NAVArraySwapString(array, 2, 3)

    if (array[2] != 'Charlie' || array[3] != 'Bob') {
        NAVLogTestFailed(3, "'array[2]=Charlie, array[3]=Bob'", "'array[2]=', array[2], ', array[3]=', array[3]")
    }
    else {
        NAVLogTestPassed(3)
    }
}
