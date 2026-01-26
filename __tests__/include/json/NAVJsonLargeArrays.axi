PROGRAM_NAME='NAVJsonLargeArrays'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_LARGE_ARRAYS_TEST_JSON[10][8192]


define_function InitializeJsonLargeArraysTestData() {
    stack_var integer i
    stack_var char temp[8192]

    // Test 1: 50 element string array
    temp = '['
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        temp = "temp, '"item', itoa(i), '"'"
    }
    temp = "temp, ']'"
    JSON_LARGE_ARRAYS_TEST_JSON[1] = temp

    // Test 2: 50 element integer array
    temp = '['
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        temp = "temp, itoa(i * 10)"
    }
    temp = "temp, ']'"
    JSON_LARGE_ARRAYS_TEST_JSON[2] = temp

    // Test 3: 100 element boolean array
    temp = '['
    for (i = 1; i <= 100; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        if (i mod 2) {
            temp = "temp, 'true'"
        } else {
            temp = "temp, 'false'"
        }
    }
    temp = "temp, ']'"
    JSON_LARGE_ARRAYS_TEST_JSON[3] = temp

    // Test 4: 25 element float array
    temp = '['
    for (i = 1; i <= 25; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        temp = "temp, itoa(i), '.', itoa(i * 5)"
    }
    temp = "temp, ']'"
    JSON_LARGE_ARRAYS_TEST_JSON[4] = temp

    // Test 5: Large object with 30 properties
    temp = '{'
    for (i = 1; i <= 30; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        temp = "temp, '"prop', itoa(i), '":"value', itoa(i), '"'"
    }
    temp = "temp, '}'"
    JSON_LARGE_ARRAYS_TEST_JSON[5] = temp

    // Test 6: Array of 25 objects
    temp = '['
    for (i = 1; i <= 25; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        temp = "temp, '{"id":', itoa(i), ',"name":"item', itoa(i), '"}'"
    }
    temp = "temp, ']'"
    JSON_LARGE_ARRAYS_TEST_JSON[6] = temp

    // Test 7: 50 element array with access to middle element
    temp = '['
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        temp = "temp, itoa(i)"
    }
    temp = "temp, ']'"
    JSON_LARGE_ARRAYS_TEST_JSON[7] = temp

    // Test 8: 50 element array with access to last element
    JSON_LARGE_ARRAYS_TEST_JSON[8] = JSON_LARGE_ARRAYS_TEST_JSON[7]

    // Test 9: Mixed type object with large array property
    temp = '{"count":100,"items":['
    for (i = 1; i <= 50; i++) {
        if (i > 1) {
            temp = "temp, ','"
        }
        temp = "temp, itoa(i)"
    }
    temp = "temp, ']}'"
    JSON_LARGE_ARRAYS_TEST_JSON[9] = temp

    // Test 10: Large nested structure
    temp = '{"data":["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]}'
    JSON_LARGE_ARRAYS_TEST_JSON[10] = temp

    set_length_array(JSON_LARGE_ARRAYS_TEST_JSON, 10)
}


DEFINE_CONSTANT

constant integer JSON_LARGE_ARRAYS_EXPECTED_COUNT[10] = {
    50,   // Test 1
    50,   // Test 2
    100,  // Test 3
    25,   // Test 4
    30,   // Test 5
    25,   // Test 6
    50,   // Test 7
    50,   // Test 8
    50,   // Test 9 - items array
    26    // Test 10 - data array
}

constant char JSON_LARGE_ARRAYS_TEST_QUERY[10][64] = {
    '.',              // Test 1 - root array
    '.',              // Test 2 - root array
    '.',              // Test 3 - root array
    '.',              // Test 4 - root array
    '.',              // Test 5 - root object (property count)
    '.',              // Test 6 - root array
    '.[25]',          // Test 7 - middle element
    '.[50]',          // Test 8 - last element
    '.items',         // Test 9 - nested array
    '.data'           // Test 10 - nested array
}

constant integer JSON_LARGE_ARRAYS_EXPECTED_VALUE[10] = {
    0,    // Test 1 - string array
    0,    // Test 2 - integer array (validate count)
    0,    // Test 3 - boolean array (validate count)
    0,    // Test 4 - float array (validate count)
    0,    // Test 5 - object properties (validate count)
    0,    // Test 6 - object array (validate count)
    25,   // Test 7 - middle element value
    50,   // Test 8 - last element value
    0,    // Test 9 - nested array (validate count)
    0     // Test 10 - nested array (validate count)
}


define_function TestNAVJsonLargeArrays() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonLargeArrays'")

    InitializeJsonLargeArraysTestData()

    for (x = 1; x <= length_array(JSON_LARGE_ARRAYS_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var _NAVJsonNode node
        stack_var integer count
        stack_var integer value

        if (!NAVJsonParse(JSON_LARGE_ARRAYS_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQuery(json, JSON_LARGE_ARRAYS_TEST_QUERY[x], node)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // For tests 1-6, 9-10: validate child count
        // For tests 7-8: validate element value
        if (x == 7 || x == 8) {
            if (!NAVJsonQueryInteger(json, JSON_LARGE_ARRAYS_TEST_QUERY[x], value)) {
                NAVLogTestFailed(x, 'Query element success', 'Query element failed')
                continue
            }

            if (!NAVAssertIntegerEqual('Large array element value',
                                      JSON_LARGE_ARRAYS_EXPECTED_VALUE[x],
                                      value)) {
                NAVLogTestFailed(x,
                                itoa(JSON_LARGE_ARRAYS_EXPECTED_VALUE[x]),
                                itoa(value))
                continue
            }
        } else {
            count = NAVJsonGetChildCount(node)

            if (!NAVAssertIntegerEqual('Large array/object count',
                                      JSON_LARGE_ARRAYS_EXPECTED_COUNT[x],
                                      count)) {
                NAVLogTestFailed(x,
                                itoa(JSON_LARGE_ARRAYS_EXPECTED_COUNT[x]),
                                itoa(count))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonLargeArrays'")
}
