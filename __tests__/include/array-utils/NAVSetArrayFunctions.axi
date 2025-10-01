PROGRAM_NAME='NAVSetArrayFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVSetArrayChar() {
    stack_var char array[10]
    stack_var integer x

    NAVLog("'***************** NAVSetArrayChar *****************'")

    NAVSetArrayChar(array, $FF)

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] != $FF) {
            NAVLogTestFailed(x, "'$FF'", "itoa(array[x])")
            continue
        }
        NAVLogTestPassed(x)
    }
}

define_function TestNAVSetArrayInteger() {
    stack_var integer array[5]
    stack_var integer x

    NAVLog("'***************** NAVSetArrayInteger *****************'")

    NAVSetArrayInteger(array, 42)

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] != 42) {
            NAVLogTestFailed(x, "'42'", "itoa(array[x])")
            continue
        }
        NAVLogTestPassed(x)
    }
}

define_function TestNAVSetArraySignedInteger() {
    stack_var sinteger array[5]
    stack_var integer x

    NAVLog("'***************** NAVSetArraySignedInteger *****************'")

    NAVSetArraySignedInteger(array, -10)

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] != -10) {
            NAVLogTestFailed(x, "'-10'", "itoa(array[x])")
            continue
        }
        NAVLogTestPassed(x)
    }
}

define_function TestNAVSetArrayLong() {
    stack_var long array[5]
    stack_var integer x

    NAVLog("'***************** NAVSetArrayLong *****************'")

    NAVSetArrayLong(array, 1000000)

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] != 1000000) {
            NAVLogTestFailed(x, "'1000000'", "itoa(array[x])")
            continue
        }
        NAVLogTestPassed(x)
    }
}

define_function TestNAVSetArraySignedLong() {
    stack_var slong array[5]
    stack_var integer x

    NAVLog("'***************** NAVSetArraySignedLong *****************'")

    NAVSetArraySignedLong(array, -1000000)

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] != -1000000) {
            NAVLogTestFailed(x, "'-1000000'", "itoa(array[x])")
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVSetArrayFloat() {
    stack_var float array[5]
    stack_var integer x

    NAVLog("'***************** NAVSetArrayFloat *****************'")

    NAVSetArrayFloat(array, 3.14)

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] != 3.14) {
            NAVLogTestFailed(x, "'3.14'", "ftoa(array[x])")
            continue
        }
        NAVLogTestPassed(x)
    }
}

define_function TestNAVSetArrayDouble() {
    stack_var double array[5]
    stack_var integer x

    NAVLog("'***************** NAVSetArrayDouble *****************'")

    NAVSetArrayDouble(array, 3.14159265359)

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] != 3.14159265359) {
            NAVLogTestFailed(x, "'3.14159265359'", "ftoa(array[x])")
            continue
        }
        NAVLogTestPassed(x)
    }
}

define_function TestNAVSetArrayString() {
    stack_var char array[5][20]
    stack_var integer x

    NAVLog("'***************** NAVSetArrayString *****************'")

    NAVSetArrayString(array, 'test')

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] != 'test') {
            NAVLogTestFailed(x, "'test'", "array[x]")
            continue
        }
        NAVLogTestPassed(x)
    }
}
