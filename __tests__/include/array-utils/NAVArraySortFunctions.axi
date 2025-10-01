PROGRAM_NAME='NAVArraySortFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVArrayBubbleSortInteger() {
    stack_var integer array[5]
    stack_var integer x

    NAVLog("'***************** NAVArrayBubbleSortInteger *****************'")

    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)

    NAVArrayBubbleSortInteger(array)

    // Verify sorted ascending
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'10,20,30,40,50'", "NAVFormatArrayInteger(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArraySelectionSortInteger() {
    stack_var integer array[5]

    NAVLog("'***************** NAVArraySelectionSortInteger *****************'")

    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)

    NAVArraySelectionSortInteger(array)

    // Verify sorted ascending
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'10,20,30,40,50'", "NAVFormatArrayInteger(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArraySelectionSortString() {
    stack_var char array[5][20]

    NAVLog("'***************** NAVArraySelectionSortString *****************'")

    array[1] = 'echo'
    array[2] = 'bravo'
    array[3] = 'delta'
    array[4] = 'alpha'
    array[5] = 'charlie'
    set_length_array(array, 5)

    NAVArraySelectionSortString(array)

    // Verify sorted ascending
    if (array[1] != 'alpha' || array[2] != 'bravo' || array[3] != 'charlie' || array[4] != 'delta' || array[5] != 'echo') {
        NAVLogTestFailed(1, "'alpha,bravo,charlie,delta,echo'", "NAVFormatArrayString(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayInsertionSortInteger() {
    stack_var integer array[5]

    NAVLog("'***************** NAVArrayInsertionSortInteger *****************'")

    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)

    NAVArrayInsertionSortInteger(array)

    // Verify sorted ascending
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'10,20,30,40,50'", "NAVFormatArrayInteger(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayQuickSortInteger() {
    stack_var integer array[5]

    NAVLog("'***************** NAVArrayQuickSortInteger *****************'")

    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)

    NAVArrayQuickSortInteger(array)

    // Verify sorted ascending
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'10,20,30,40,50'", "NAVFormatArrayInteger(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayMergeSortInteger() {
    stack_var integer array[5]

    NAVLog("'***************** NAVArrayMergeSortInteger *****************'")

    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)

    NAVArrayMergeSortInteger(array)

    // Verify sorted ascending
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'10,20,30,40,50'", "NAVFormatArrayInteger(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayCountingSortInteger() {
    stack_var integer array[5]

    NAVLog("'***************** NAVArrayCountingSortInteger *****************'")

    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)

    NAVArrayCountingSortInteger(array, 50)

    // Verify sorted ascending
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'10,20,30,40,50'", "NAVFormatArrayInteger(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}
