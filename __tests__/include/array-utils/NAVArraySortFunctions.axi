PROGRAM_NAME='NAVArraySortFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVArrayBubbleSortInteger() {
    stack_var integer array[10]

    NAVLog("'***************** NAVArrayBubbleSortInteger *****************'")

    // Test 1: Random unsorted array
    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)
    NAVArrayBubbleSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'Random unsorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(1)
    }

    // Test 2: Already sorted array
    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)
    NAVArrayBubbleSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(2, "'Already sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(2)
    }

    // Test 3: Reverse sorted array
    array[1] = 50
    array[2] = 40
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArrayBubbleSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(3, "'Reverse sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(3)
    }

    // Test 4: Array with duplicates
    array[1] = 30
    array[2] = 10
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArrayBubbleSortInteger(array)
    if (array[1] != 10 || array[2] != 10 || array[3] != 20 || array[4] != 30 || array[5] != 30) {
        NAVLogTestFailed(4, "'With duplicates'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(4)
    }

    // Test 5: All same values
    array[1] = 25
    array[2] = 25
    array[3] = 25
    set_length_array(array, 3)
    NAVArrayBubbleSortInteger(array)
    if (array[1] != 25 || array[2] != 25 || array[3] != 25) {
        NAVLogTestFailed(5, "'All same values'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(5)
    }

    // Test 6: Single element
    array[1] = 42
    set_length_array(array, 1)
    NAVArrayBubbleSortInteger(array)
    if (array[1] != 42) {
        NAVLogTestFailed(6, "'Single element'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(6)
    }

    // Test 7: Two elements
    array[1] = 20
    array[2] = 10
    set_length_array(array, 2)
    NAVArrayBubbleSortInteger(array)
    if (array[1] != 10 || array[2] != 20) {
        NAVLogTestFailed(7, "'Two elements'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(7)
    }
}

define_function TestNAVArraySelectionSortInteger() {
    stack_var integer array[10]

    NAVLog("'***************** NAVArraySelectionSortInteger *****************'")

    // Test 1: Random unsorted array
    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)
    NAVArraySelectionSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'Random unsorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(1)
    }

    // Test 2: Already sorted array
    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)
    NAVArraySelectionSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(2, "'Already sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(2)
    }

    // Test 3: Reverse sorted array
    array[1] = 50
    array[2] = 40
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArraySelectionSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(3, "'Reverse sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(3)
    }

    // Test 4: Array with duplicates
    array[1] = 30
    array[2] = 10
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArraySelectionSortInteger(array)
    if (array[1] != 10 || array[2] != 10 || array[3] != 20 || array[4] != 30 || array[5] != 30) {
        NAVLogTestFailed(4, "'With duplicates'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(4)
    }

    // Test 5: Single element
    array[1] = 42
    set_length_array(array, 1)
    NAVArraySelectionSortInteger(array)
    if (array[1] != 42) {
        NAVLogTestFailed(5, "'Single element'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(5)
    }

    // Test 6: Two elements
    array[1] = 20
    array[2] = 10
    set_length_array(array, 2)
    NAVArraySelectionSortInteger(array)
    if (array[1] != 10 || array[2] != 20) {
        NAVLogTestFailed(6, "'Two elements'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(6)
    }
}

define_function TestNAVArraySelectionSortString() {
    stack_var char array[10][20]

    NAVLog("'***************** NAVArraySelectionSortString *****************'")

    // Test 1: Random unsorted array
    array[1] = 'echo'
    array[2] = 'bravo'
    array[3] = 'delta'
    array[4] = 'alpha'
    array[5] = 'charlie'
    set_length_array(array, 5)
    NAVArraySelectionSortString(array)
    if (array[1] != 'alpha' || array[2] != 'bravo' || array[3] != 'charlie' || array[4] != 'delta' || array[5] != 'echo') {
        NAVLogTestFailed(1, "'Random unsorted'", "NAVFormatArrayString(array)")
    } else {
        NAVLogTestPassed(1)
    }

    // Test 2: Already sorted array
    array[1] = 'alpha'
    array[2] = 'bravo'
    array[3] = 'charlie'
    array[4] = 'delta'
    array[5] = 'echo'
    set_length_array(array, 5)
    NAVArraySelectionSortString(array)
    if (array[1] != 'alpha' || array[2] != 'bravo' || array[3] != 'charlie' || array[4] != 'delta' || array[5] != 'echo') {
        NAVLogTestFailed(2, "'Already sorted'", "NAVFormatArrayString(array)")
    } else {
        NAVLogTestPassed(2)
    }

    // Test 3: Reverse sorted array
    array[1] = 'echo'
    array[2] = 'delta'
    array[3] = 'charlie'
    array[4] = 'bravo'
    array[5] = 'alpha'
    set_length_array(array, 5)
    NAVArraySelectionSortString(array)
    if (array[1] != 'alpha' || array[2] != 'bravo' || array[3] != 'charlie' || array[4] != 'delta' || array[5] != 'echo') {
        NAVLogTestFailed(3, "'Reverse sorted'", "NAVFormatArrayString(array)")
    } else {
        NAVLogTestPassed(3)
    }

    // Test 4: Array with duplicates
    array[1] = 'zebra'
    array[2] = 'apple'
    array[3] = 'zebra'
    array[4] = 'apple'
    set_length_array(array, 4)
    NAVArraySelectionSortString(array)
    if (array[1] != 'apple' || array[2] != 'apple' || array[3] != 'zebra' || array[4] != 'zebra') {
        NAVLogTestFailed(4, "'With duplicates'", "NAVFormatArrayString(array)")
    } else {
        NAVLogTestPassed(4)
    }

    // Test 5: Single element
    array[1] = 'solo'
    set_length_array(array, 1)
    NAVArraySelectionSortString(array)
    if (array[1] != 'solo') {
        NAVLogTestFailed(5, "'Single element'", "NAVFormatArrayString(array)")
    } else {
        NAVLogTestPassed(5)
    }

    // Test 6: Two elements
    array[1] = 'second'
    array[2] = 'first'
    set_length_array(array, 2)
    NAVArraySelectionSortString(array)
    if (array[1] != 'first' || array[2] != 'second') {
        NAVLogTestFailed(6, "'Two elements'", "NAVFormatArrayString(array)")
    } else {
        NAVLogTestPassed(6)
    }
}

define_function TestNAVArrayInsertionSortInteger() {
    stack_var integer array[10]

    NAVLog("'***************** NAVArrayInsertionSortInteger *****************'")

    // Test 1: Random unsorted array
    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)
    NAVArrayInsertionSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'Random unsorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(1)
    }

    // Test 2: Already sorted array
    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)
    NAVArrayInsertionSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(2, "'Already sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(2)
    }

    // Test 3: Reverse sorted array
    array[1] = 50
    array[2] = 40
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArrayInsertionSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(3, "'Reverse sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(3)
    }

    // Test 4: Array with duplicates
    array[1] = 30
    array[2] = 10
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArrayInsertionSortInteger(array)
    if (array[1] != 10 || array[2] != 10 || array[3] != 20 || array[4] != 30 || array[5] != 30) {
        NAVLogTestFailed(4, "'With duplicates'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(4)
    }

    // Test 5: Single element
    array[1] = 42
    set_length_array(array, 1)
    NAVArrayInsertionSortInteger(array)
    if (array[1] != 42) {
        NAVLogTestFailed(5, "'Single element'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(5)
    }

    // Test 6: Two elements
    array[1] = 20
    array[2] = 10
    set_length_array(array, 2)
    NAVArrayInsertionSortInteger(array)
    if (array[1] != 10 || array[2] != 20) {
        NAVLogTestFailed(6, "'Two elements'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(6)
    }
}

define_function TestNAVArrayQuickSortInteger() {
    stack_var integer array[10]

    NAVLog("'***************** NAVArrayQuickSortInteger *****************'")

    // Test 1: Random unsorted array
    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)
    NAVArrayQuickSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'Random unsorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(1)
    }

    // Test 2: Already sorted array
    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)
    NAVArrayQuickSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(2, "'Already sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(2)
    }

    // Test 3: Reverse sorted array
    array[1] = 50
    array[2] = 40
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArrayQuickSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(3, "'Reverse sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(3)
    }

    // Test 4: Array with duplicates
    array[1] = 30
    array[2] = 10
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArrayQuickSortInteger(array)
    if (array[1] != 10 || array[2] != 10 || array[3] != 20 || array[4] != 30 || array[5] != 30) {
        NAVLogTestFailed(4, "'With duplicates'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(4)
    }

    // Test 5: Single element
    array[1] = 42
    set_length_array(array, 1)
    NAVArrayQuickSortInteger(array)
    if (array[1] != 42) {
        NAVLogTestFailed(5, "'Single element'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(5)
    }

    // Test 6: Two elements
    array[1] = 20
    array[2] = 10
    set_length_array(array, 2)
    NAVArrayQuickSortInteger(array)
    if (array[1] != 10 || array[2] != 20) {
        NAVLogTestFailed(6, "'Two elements'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(6)
    }
}

define_function TestNAVArrayMergeSortInteger() {
    stack_var integer array[10]

    NAVLog("'***************** NAVArrayMergeSortInteger *****************'")

    // Test 1: Random unsorted array
    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)
    NAVArrayMergeSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'Random unsorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(1)
    }

    // Test 2: Already sorted array
    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)
    NAVArrayMergeSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(2, "'Already sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(2)
    }

    // Test 3: Reverse sorted array
    array[1] = 50
    array[2] = 40
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArrayMergeSortInteger(array)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(3, "'Reverse sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(3)
    }

    // Test 4: Array with duplicates
    array[1] = 30
    array[2] = 10
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArrayMergeSortInteger(array)
    if (array[1] != 10 || array[2] != 10 || array[3] != 20 || array[4] != 30 || array[5] != 30) {
        NAVLogTestFailed(4, "'With duplicates'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(4)
    }

    // Test 5: Single element
    array[1] = 42
    set_length_array(array, 1)
    NAVArrayMergeSortInteger(array)
    if (array[1] != 42) {
        NAVLogTestFailed(5, "'Single element'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(5)
    }

    // Test 6: Two elements
    array[1] = 20
    array[2] = 10
    set_length_array(array, 2)
    NAVArrayMergeSortInteger(array)
    if (array[1] != 10 || array[2] != 20) {
        NAVLogTestFailed(6, "'Two elements'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(6)
    }
}

define_function TestNAVArrayCountingSortInteger() {
    stack_var integer array[10]

    NAVLog("'***************** NAVArrayCountingSortInteger *****************'")

    // Test 1: Random unsorted array
    array[1] = 50
    array[2] = 20
    array[3] = 40
    array[4] = 10
    array[5] = 30
    set_length_array(array, 5)
    NAVArrayCountingSortInteger(array, 50)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(1, "'Random unsorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(1)
    }

    // Test 2: Already sorted array
    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)
    NAVArrayCountingSortInteger(array, 50)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(2, "'Already sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(2)
    }

    // Test 3: Reverse sorted array
    array[1] = 50
    array[2] = 40
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArrayCountingSortInteger(array, 50)
    if (array[1] != 10 || array[2] != 20 || array[3] != 30 || array[4] != 40 || array[5] != 50) {
        NAVLogTestFailed(3, "'Reverse sorted'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(3)
    }

    // Test 4: Array with duplicates
    array[1] = 30
    array[2] = 10
    array[3] = 30
    array[4] = 20
    array[5] = 10
    set_length_array(array, 5)
    NAVArrayCountingSortInteger(array, 30)
    if (array[1] != 10 || array[2] != 10 || array[3] != 20 || array[4] != 30 || array[5] != 30) {
        NAVLogTestFailed(4, "'With duplicates'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(4)
    }

    // Test 5: Single element
    array[1] = 42
    set_length_array(array, 1)
    NAVArrayCountingSortInteger(array, 42)
    if (array[1] != 42) {
        NAVLogTestFailed(5, "'Single element'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(5)
    }

    // Test 6: Two elements
    array[1] = 20
    array[2] = 10
    set_length_array(array, 2)
    NAVArrayCountingSortInteger(array, 20)
    if (array[1] != 10 || array[2] != 20) {
        NAVLogTestFailed(6, "'Two elements'", "NAVFormatArrayInteger(array)")
    } else {
        NAVLogTestPassed(6)
    }
}
