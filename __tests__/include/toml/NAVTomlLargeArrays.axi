PROGRAM_NAME='NAVTomlLargeArrays'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_LARGE_ARRAYS_TEST_TOML[10][8192]


define_function InitializeTomlLargeArraysTestData() {
    stack_var integer i
    stack_var char temp[8192]

    // Test 1: 50 element string array
    temp = 'strings = ['
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, ', '"
        }
        temp = "temp, '"item', itoa(i), '"'"
    }
    temp = "temp, ']'"
    TOML_LARGE_ARRAYS_TEST_TOML[1] = temp

    // Test 2: 50 element integer array
    temp = 'numbers = ['
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, ', '"
        }
        temp = "temp, itoa(i * 10)"
    }
    temp = "temp, ']'"
    TOML_LARGE_ARRAYS_TEST_TOML[2] = temp

    // Test 3: 100 element boolean array
    temp = 'flags = ['
    for (i = 1; i <= 100; i++) {
        if (i > 1) {
            temp = "temp, ', '"
        }
        if (i mod 2) {
            temp = "temp, 'true'"
        } else {
            temp = "temp, 'false'"
        }
    }
    temp = "temp, ']'"
    TOML_LARGE_ARRAYS_TEST_TOML[3] = temp

    // Test 4: 25 element float array
    temp = 'floats = ['
    for (i = 1; i <= 25; i++) {
        if (i > 1) {
            temp = "temp, ', '"
        }
        temp = "temp, itoa(i), '.', itoa(i * 5)"
    }
    temp = "temp, ']'"
    TOML_LARGE_ARRAYS_TEST_TOML[4] = temp

    // Test 5: Table with 30 properties
    temp = "'[data]', $0A"
    for (i = 1; i <= 30; i++) {
        temp = "temp, 'prop', itoa(i), ' = "value', itoa(i), '"', $0A"
    }
    TOML_LARGE_ARRAYS_TEST_TOML[5] = temp

    // Test 6: Array of 25 inline tables
    temp = 'records = ['
    for (i = 1; i <= 25; i++) {
        if (i > 1) {
            temp = "temp, ', '"
        }
        temp = "temp, '{ id = ', itoa(i), ', name = "item', itoa(i), '" }'"
    }
    temp = "temp, ']'"
    TOML_LARGE_ARRAYS_TEST_TOML[6] = temp

    // Test 7: 50 element array with access to middle element
    temp = 'values = ['
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, ', '"
        }
        temp = "temp, itoa(i)"
    }
    temp = "temp, ']'"
    TOML_LARGE_ARRAYS_TEST_TOML[7] = temp

    // Test 8: 50 element array with access to last element
    TOML_LARGE_ARRAYS_TEST_TOML[8] = TOML_LARGE_ARRAYS_TEST_TOML[7]

    // Test 9: Table with large array property
    temp = "'count = 100', $0A, 'items = ['"
    for (i = 1; i <= 100; i++) {
        if (i > 1) {
            temp = "temp, ', '"
        }
        temp = "temp, itoa(i)"
    }
    temp = "temp, ']'"
    TOML_LARGE_ARRAYS_TEST_TOML[9] = temp

    // Test 10: Array of 50 tables (array of tables)
    temp = ''
    for (i = 1; i <= 50; i++) {
        temp = "temp, '[[items]]', $0A, 'index = ', itoa(i), $0A"
    }
    TOML_LARGE_ARRAYS_TEST_TOML[10] = temp

    set_length_array(TOML_LARGE_ARRAYS_TEST_TOML, 10)
}


DEFINE_CONSTANT

constant integer TOML_LARGE_ARRAYS_EXPECTED_LENGTH[10] = {
    50,   // Test 1 - 50 strings
    50,   // Test 2 - 50 integers
    100,  // Test 3 - 100 booleans
    25,   // Test 4 - 25 floats
    30,   // Test 5 - 30 properties
    25,   // Test 6 - 25 inline tables
    50,   // Test 7 - 50 integers
    50,   // Test 8 - 50 integers
    100,  // Test 9 - 100 integers in array
    50    // Test 10 - 50 tables
}

constant char TOML_LARGE_ARRAYS_TEST_QUERY[10][128] = {
    '.strings',         // Test 1
    '.numbers',         // Test 2
    '.flags',           // Test 3
    '.floats',          // Test 4
    '.data',            // Test 5
    '.records',         // Test 6
    '.values',          // Test 7
    '.values',          // Test 8 - array (childCount check)
    '.items',           // Test 9
    '.items'            // Test 10
}

constant integer TOML_LARGE_ARRAYS_EXPECTED_ELEMENT_VALUE[10] = {
    0,     // Test 1 - string
    500,   // Test 2 - 50 * 10 = 500
    0,     // Test 3 - boolean
    0,     // Test 4 - float
    0,     // Test 5 - not an array
    0,     // Test 6 - inline table
    25,    // Test 7 - middle element (index 25)
    50,    // Test 8 - last element (index 50)
    0,     // Test 9 - count field
    0      // Test 10 - array of tables
}


define_function TestNAVTomlLargeArrays() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlLargeArrays'")

    InitializeTomlLargeArraysTestData()

    for (x = 1; x <= length_array(TOML_LARGE_ARRAYS_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var _NAVTomlNode result
        stack_var integer childCount

        if (!NAVTomlParse(TOML_LARGE_ARRAYS_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQuery(toml, TOML_LARGE_ARRAYS_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // For array tests (1-4, 6-10), verify length
        if (x != 5) {
            childCount = result.childCount
            if (!NAVAssertIntegerEqual('Large array child count',
                                       TOML_LARGE_ARRAYS_EXPECTED_LENGTH[x],
                                       childCount)) {
                NAVLogTestFailed(x,
                                itoa(TOML_LARGE_ARRAYS_EXPECTED_LENGTH[x]),
                                itoa(childCount))
                continue
            }
        } else {
            // Test 5 - table with 30 properties
            childCount = result.childCount
            if (!NAVAssertIntegerEqual('Large table property count',
                                       TOML_LARGE_ARRAYS_EXPECTED_LENGTH[x],
                                       childCount)) {
                NAVLogTestFailed(x,
                                itoa(TOML_LARGE_ARRAYS_EXPECTED_LENGTH[x]),
                                itoa(childCount))
                continue
            }
        }

        // Additional tests for elements with specific values
        if (x == 2) { // Test 2 - verify last integer
            stack_var integer lastValue
            if (NAVTomlQueryInteger(toml, '.numbers[50]', lastValue)) {
                if (!NAVAssertIntegerEqual('Last element value',
                                          TOML_LARGE_ARRAYS_EXPECTED_ELEMENT_VALUE[x],
                                          lastValue)) {
                    NAVLogTestFailed(x,
                                    itoa(TOML_LARGE_ARRAYS_EXPECTED_ELEMENT_VALUE[x]),
                                    itoa(lastValue))
                    continue
                }
            }
        }

        if (x == 7) { // Test 7 - verify middle element
            stack_var integer midValue
            if (NAVTomlQueryInteger(toml, '.values[25]', midValue)) {
                if (!NAVAssertIntegerEqual('Middle element value',
                                          TOML_LARGE_ARRAYS_EXPECTED_ELEMENT_VALUE[x],
                                          midValue)) {
                    NAVLogTestFailed(x,
                                    itoa(TOML_LARGE_ARRAYS_EXPECTED_ELEMENT_VALUE[x]),
                                    itoa(midValue))
                    continue
                }
            }
        }

        if (x == 8) { // Test 8 - verify last element
            stack_var integer lastVal
            if (NAVTomlQueryInteger(toml, '.values[50]', lastVal)) {
                if (!NAVAssertIntegerEqual('Last element value',
                                          TOML_LARGE_ARRAYS_EXPECTED_ELEMENT_VALUE[x],
                                          lastVal)) {
                    NAVLogTestFailed(x,
                                    itoa(TOML_LARGE_ARRAYS_EXPECTED_ELEMENT_VALUE[x]),
                                    itoa(lastVal))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlLargeArrays'")
}
