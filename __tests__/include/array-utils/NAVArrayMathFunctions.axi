PROGRAM_NAME='NAVArrayMathFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVArraySumInteger() {
    stack_var integer array[5]
    stack_var double result

    NAVLog("'***************** NAVArraySumInteger *****************'")

    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    result = NAVArraySumInteger(array)

    // Expected sum: 10 + 20 + 30 + 40 + 50 = 150
    if (result != 150.0) {
        NAVLogTestFailed(1, "'150.0'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArraySumSignedInteger() {
    stack_var sinteger array[5]
    stack_var double result

    NAVLog("'***************** NAVArraySumSignedInteger *****************'")

    array[1] = -10
    array[2] = 20
    array[3] = -30
    array[4] = 40
    array[5] = -50
    set_length_array(array, 5)

    result = NAVArraySumSignedInteger(array)

    // Expected sum: -10 + 20 + -30 + 40 + -50 = -30
    if (result != -30.0) {
        NAVLogTestFailed(1, "'-30.0'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArraySumLong() {
    stack_var long array[5]
    stack_var double result

    NAVLog("'***************** NAVArraySumLong *****************'")

    array[1] = 1000000
    array[2] = 2000000
    array[3] = 3000000
    array[4] = 4000000
    array[5] = 5000000
    set_length_array(array, 5)

    result = NAVArraySumLong(array)

    // Expected sum: 15000000
    if (result != 15000000.0) {
        NAVLogTestFailed(1, "'15000000.0'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArraySumSignedLong() {
    stack_var slong array[5]
    stack_var double result

    NAVLog("'***************** NAVArraySumSignedLong *****************'")

    array[1] = type_cast(-1000000)
    array[2] = type_cast(2000000)
    array[3] = type_cast(-3000000)
    array[4] = type_cast(4000000)
    array[5] = type_cast(-5000000)
    set_length_array(array, 5)

    result = NAVArraySumSignedLong(array)

    // Expected sum: -1000000 + 2000000 + -3000000 + 4000000 + -5000000 = -3000000
    if (result != -3000000.0) {
        NAVLogTestFailed(1, "'-3000000.0'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArraySumFloat() {
    stack_var float array[5]
    stack_var double result

    NAVLog("'***************** NAVArraySumFloat *****************'")

    array[1] = 1.5
    array[2] = 2.5
    array[3] = 3.5
    array[4] = 4.5
    array[5] = 5.5
    set_length_array(array, 5)

    result = NAVArraySumFloat(array)

    // Expected sum: 17.5
    if (result != 17.5) {
        NAVLogTestFailed(1, "'17.5'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArraySumDouble() {
    stack_var double array[5]
    stack_var double result
    stack_var double expected
    stack_var double epsilon

    NAVLog("'***************** NAVArraySumDouble *****************'")

    array[1] = 1.111
    array[2] = 2.222
    array[3] = 3.333
    array[4] = 4.444
    array[5] = 5.555
    set_length_array(array, 5)

    result = NAVArraySumDouble(array)

    // Expected sum: 16.665
    expected = 16.665
    epsilon = 0.0001  // Tolerance for floating-point comparison

    if (abs_value(result - expected) > epsilon) {
        NAVLogTestFailed(1, "'16.665'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayAverageInteger() {
    stack_var integer array[5]
    stack_var double result

    NAVLog("'***************** NAVArrayAverageInteger *****************'")

    array[1] = 10
    array[2] = 20
    array[3] = 30
    array[4] = 40
    array[5] = 50
    set_length_array(array, 5)

    result = NAVArrayAverageInteger(array)

    // Expected average: (10 + 20 + 30 + 40 + 50) / 5 = 30.0
    if (result != 30.0) {
        NAVLogTestFailed(1, "'30.0'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayAverageSignedInteger() {
    stack_var sinteger array[5]
    stack_var double result

    NAVLog("'***************** NAVArrayAverageSignedInteger *****************'")

    array[1] = -10
    array[2] = 20
    array[3] = -30
    array[4] = 40
    array[5] = -50
    set_length_array(array, 5)

    result = NAVArrayAverageSignedInteger(array)

    // Expected average: (-10 + 20 + -30 + 40 + -50) / 5 = -6.0
    if (result != -6.0) {
        NAVLogTestFailed(1, "'-6.0'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayAverageLong() {
    stack_var long array[5]
    stack_var double result

    NAVLog("'***************** NAVArrayAverageLong *****************'")

    array[1] = 1000000
    array[2] = 2000000
    array[3] = 3000000
    array[4] = 4000000
    array[5] = 5000000
    set_length_array(array, 5)

    result = NAVArrayAverageLong(array)

    // Expected average: 3000000.0
    if (result != 3000000.0) {
        NAVLogTestFailed(1, "'3000000.0'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayAverageSignedLong() {
    stack_var slong array[5]
    stack_var double result

    NAVLog("'***************** NAVArrayAverageSignedLong *****************'")

    array[1] = type_cast(-1000000)
    array[2] = type_cast(2000000)
    array[3] = type_cast(-3000000)
    array[4] = type_cast(4000000)
    array[5] = type_cast(-5000000)
    set_length_array(array, 5)

    result = NAVArrayAverageSignedLong(array)

    // Expected average: (-1000000 + 2000000 + -3000000 + 4000000 + -5000000) / 5 = -600000.0
    if (result != -600000.0) {
        NAVLogTestFailed(1, "'-600000.0'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayAverageFloat() {
    stack_var float array[5]
    stack_var double result

    NAVLog("'***************** NAVArrayAverageFloat *****************'")

    array[1] = 1.5
    array[2] = 2.5
    array[3] = 3.5
    array[4] = 4.5
    array[5] = 5.5
    set_length_array(array, 5)

    result = NAVArrayAverageFloat(array)

    // Expected average: 3.5
    if (result != 3.5) {
        NAVLogTestFailed(1, "'3.5'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayAverageDouble() {
    stack_var double array[5]
    stack_var double result
    stack_var double expected
    stack_var double epsilon

    NAVLog("'***************** NAVArrayAverageDouble *****************'")

    array[1] = 1.111
    array[2] = 2.222
    array[3] = 3.333
    array[4] = 4.444
    array[5] = 5.555
    set_length_array(array, 5)

    result = NAVArrayAverageDouble(array)

    // Expected average: 3.333
    expected = 3.333
    epsilon = 0.0001  // Tolerance for floating-point comparison

    if (abs_value(result - expected) > epsilon) {
        NAVLogTestFailed(1, "'3.333'", "ftoa(result)")
    }
    else {
        NAVLogTestPassed(1)
    }
}
