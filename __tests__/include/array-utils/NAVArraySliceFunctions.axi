PROGRAM_NAME='NAVArraySliceFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVArraySliceInteger() {
    stack_var integer array[10]
    stack_var integer slice[5]
    stack_var integer result
    stack_var integer x

    NAVLog("'***************** NAVArraySliceInteger *****************'")

    for (x = 1; x <= 10; x++) {
        array[x] = x * 10
    }
    set_length_array(array, 10)

    // Test 1: Slice from index 3 to 7
    result = NAVArraySliceInteger(array, 3, 7, slice)

    if (result != 5) {
        NAVLogTestFailed(1, "'5'", "itoa(result)")
    }
    else if (slice[1] != 30 || slice[2] != 40 || slice[3] != 50 || slice[4] != 60 || slice[5] != 70) {
        NAVLogTestFailed(1, "'30,40,50,60,70'", "NAVFormatArrayInteger(slice)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Slice from beginning
    result = NAVArraySliceInteger(array, 1, 3, slice)

    if (result != 3) {
        NAVLogTestFailed(2, "'3'", "itoa(result)")
    }
    else if (slice[1] != 10 || slice[2] != 20 || slice[3] != 30) {
        NAVLogTestFailed(2, "'10,20,30'", "NAVFormatArrayInteger(slice)")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Slice to end
    result = NAVArraySliceInteger(array, 8, 10, slice)

    if (result != 3) {
        NAVLogTestFailed(3, "'3'", "itoa(result)")
    }
    else if (slice[1] != 80 || slice[2] != 90 || slice[3] != 100) {
        NAVLogTestFailed(3, "'80,90,100'", "NAVFormatArrayInteger(slice)")
    }
    else {
        NAVLogTestPassed(3)
    }
}

define_function TestNAVArraySliceString() {
    stack_var char array[10][20]
    stack_var char slice[5][20]
    stack_var integer result
    stack_var integer x

    NAVLog("'***************** NAVArraySliceString *****************'")

    array[1] = 'one'
    array[2] = 'two'
    array[3] = 'three'
    array[4] = 'four'
    array[5] = 'five'
    array[6] = 'six'
    array[7] = 'seven'
    array[8] = 'eight'
    array[9] = 'nine'
    array[10] = 'ten'
    set_length_array(array, 10)

    // Test 1: Slice from index 3 to 7
    result = NAVArraySliceString(array, 3, 7, slice)

    if (result != 5) {
        NAVLogTestFailed(1, "'5'", "itoa(result)")
    }
    else if (slice[1] != 'three' || slice[2] != 'four' || slice[3] != 'five' || slice[4] != 'six' || slice[5] != 'seven') {
        NAVLogTestFailed(1, "'three,four,five,six,seven'", "NAVFormatArrayString(slice)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Slice from beginning
    result = NAVArraySliceString(array, 1, 3, slice)

    if (result != 3) {
        NAVLogTestFailed(2, "'3'", "itoa(result)")
    }
    else if (slice[1] != 'one' || slice[2] != 'two' || slice[3] != 'three') {
        NAVLogTestFailed(2, "'one,two,three'", "NAVFormatArrayString(slice)")
    }
    else {
        NAVLogTestPassed(2)
    }
}
