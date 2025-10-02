PROGRAM_NAME='NAVArrayUtilityFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVArrayReverseInteger() {
    stack_var integer array[5]

    NAVLog("'***************** NAVArrayReverseInteger *****************'")

    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    NAVArrayReverseInteger(array)

    // Verify reversed
    if (array[1] != 50 || array[2] != 40 || array[3] != 30 || array[4] != 20 || array[5] != 10) {
        NAVLogTestFailed(1, "'50,40,30,20,10'", "NAVFormatArrayInteger(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayReverseString() {
    stack_var char array[5][20]

    NAVLog("'***************** NAVArrayReverseString *****************'")

    array[1] = 'first'
    array[2] = 'second'
    array[3] = 'third'
    array[4] = 'fourth'
    array[5] = 'fifth'
    set_length_array(array, 5)

    NAVArrayReverseString(array)

    // Verify reversed
    if (array[1] != 'fifth' || array[2] != 'fourth' || array[3] != 'third' || array[4] != 'second' || array[5] != 'first') {
        NAVLogTestFailed(1, "'fifth,fourth,third,second,first'", "NAVFormatArrayString(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayCopyInteger() {
    stack_var integer source[5]
    stack_var integer destination[5]

    NAVLog("'***************** NAVArrayCopyInteger *****************'")

    source[1] = 10
    source[2] = 20
    source[3] = 30
    source[4] = 40
    source[5] = 50
    set_length_array(source, 5)
    set_length_array(destination, 5)

    NAVArrayCopyInteger(source, destination)

    // Verify copied
    if (destination[1] != 10 || destination[2] != 20 || destination[3] != 30 || destination[4] != 40 || destination[5] != 50) {
        NAVLogTestFailed(1, "'10,20,30,40,50'", "NAVFormatArrayInteger(destination)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayCopyString() {
    stack_var char source[5][20]
    stack_var char destination[5][20]

    NAVLog("'***************** NAVArrayCopyString *****************'")

    source[1] = 'apple'
    source[2] = 'banana'
    source[3] = 'cherry'
    source[4] = 'date'
    source[5] = 'elderberry'
    set_length_array(source, 5)
    set_length_array(destination, 5)

    NAVArrayCopyString(source, destination)

    // Verify copied
    if (destination[1] != 'apple' || destination[2] != 'banana' || destination[3] != 'cherry' || destination[4] != 'date' || destination[5] != 'elderberry') {
        NAVLogTestFailed(1, "'apple,banana,cherry,date,elderberry'", "NAVFormatArrayString(destination)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayIsSortedInteger() {
    stack_var integer sortedArray[5]
    stack_var integer unsortedArray[5]
    stack_var char result

    NAVLog("'***************** NAVArrayIsSortedInteger *****************'")

    sortedArray[1] = 10
    sortedArray[2] = 20
    sortedArray[3] = 30
    sortedArray[4] = 40
    sortedArray[5] = 50
    set_length_array(sortedArray, 5)

    unsortedArray[1] = 50
    unsortedArray[2] = 20
    unsortedArray[3] = 40
    unsortedArray[4] = 10
    unsortedArray[5] = 30
    set_length_array(unsortedArray, 5)

    // Test 1: Check sorted array
    result = NAVArrayIsSortedInteger(sortedArray)
    if (!result) {
        NAVLogTestFailed(1, "'true'", "'false'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Check unsorted array
    result = NAVArrayIsSortedInteger(unsortedArray)
    if (result) {
        NAVLogTestFailed(2, "'false'", "'true'")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVArrayIsSortedString() {
    stack_var char sortedArray[5][20]
    stack_var char unsortedArray[5][20]
    stack_var char result

    NAVLog("'***************** NAVArrayIsSortedString *****************'")

    sortedArray[1] = 'alpha'
    sortedArray[2] = 'bravo'
    sortedArray[3] = 'charlie'
    sortedArray[4] = 'delta'
    sortedArray[5] = 'echo'
    set_length_array(sortedArray, 5)

    unsortedArray[1] = 'echo'
    unsortedArray[2] = 'bravo'
    unsortedArray[3] = 'delta'
    unsortedArray[4] = 'alpha'
    unsortedArray[5] = 'charlie'
    set_length_array(unsortedArray, 5)

    // Test 1: Check sorted array
    result = NAVArrayIsSortedString(sortedArray)
    if (!result) {
        NAVLogTestFailed(1, "'true'", "'false'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Check unsorted array
    result = NAVArrayIsSortedString(unsortedArray)
    if (result) {
        NAVLogTestFailed(2, "'false'", "'true'")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVArrayToLowerString() {
    stack_var char array[3][20]

    NAVLog("'***************** NAVArrayToLowerString *****************'")

    array[1] = 'HELLO'
    array[2] = 'WORLD'
    array[3] = 'TEST'
    set_length_array(array, 3)

    NAVArrayToLowerString(array)

    // Verify converted to lowercase
    if (array[1] != 'hello' || array[2] != 'world' || array[3] != 'test') {
        NAVLogTestFailed(1, "'hello,world,test'", "NAVFormatArrayString(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayToUpperString() {
    stack_var char array[3][20]

    NAVLog("'***************** NAVArrayToUpperString *****************'")

    array[1] = 'hello'
    array[2] = 'world'
    array[3] = 'test'
    set_length_array(array, 3)

    NAVArrayToUpperString(array)

    // Verify converted to uppercase
    if (array[1] != 'HELLO' || array[2] != 'WORLD' || array[3] != 'TEST') {
        NAVLogTestFailed(1, "'HELLO,WORLD,TEST'", "NAVFormatArrayString(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayTrimString() {
    stack_var char array[3][20]

    NAVLog("'***************** NAVArrayTrimString *****************'")

    array[1] = '  hello  '
    array[2] = '  world  '
    array[3] = '  test  '
    set_length_array(array, 3)

    NAVArrayTrimString(array)

    // Verify trimmed
    if (array[1] != 'hello' || array[2] != 'world' || array[3] != 'test') {
        NAVLogTestFailed(1, "'hello,world,test'", "NAVFormatArrayString(array)")
    }
    else {
        NAVLogTestPassed(1)
    }
}
