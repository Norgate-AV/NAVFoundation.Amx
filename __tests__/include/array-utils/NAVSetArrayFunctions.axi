PROGRAM_NAME='NAVSetArrayFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVSetArrayChar() {
    stack_var char array[10]
    stack_var integer x

    NAVLog("'***************** NAVSetArrayChar *****************'")

    set_length_array(array, 10)
    NAVSetArrayChar(array, $FF)

    for (x = 1; x <= max_length_array(array); x++) {
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

    set_length_array(array, 5)
    NAVSetArrayInteger(array, 42)

    for (x = 1; x <= max_length_array(array); x++) {
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

    set_length_array(array, 5)
    NAVSetArraySignedInteger(array, -10)

    for (x = 1; x <= max_length_array(array); x++) {
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

    set_length_array(array, 5)
    NAVSetArrayLong(array, 1000000)

    for (x = 1; x <= max_length_array(array); x++) {
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

    set_length_array(array, 5)
    NAVSetArraySignedLong(array, type_cast(-1000000))

    for (x = 1; x <= max_length_array(array); x++) {
        if (array[x] != type_cast(-1000000)) {
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

    set_length_array(array, 5)
    NAVSetArrayFloat(array, 3.14)

    for (x = 1; x <= max_length_array(array); x++) {
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

    set_length_array(array, 5)
    NAVSetArrayDouble(array, 3.14159265359)

    for (x = 1; x <= max_length_array(array); x++) {
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

    set_length_array(array, 5)
    NAVSetArrayString(array, 'test')

    for (x = 1; x <= max_length_array(array); x++) {
        if (array[x] != 'test') {
            NAVLogTestFailed(x, "'test'", "array[x]")
            continue
        }

        NAVLogTestPassed(x)
    }
}
