PROGRAM_NAME='NAVJsonQueryIntegerArray'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_INTEGER_ARRAY_TEST_JSON[10][512]
volatile char JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[10][64]


define_function InitializeJsonQueryIntegerArrayTestData() {
    // Test 1: Simple root array
    JSON_QUERY_INTEGER_ARRAY_TEST_JSON[1] = '[100, 200, 300]'
    JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Array property
    JSON_QUERY_INTEGER_ARRAY_TEST_JSON[2] = '{"channels":[1, 2, 3, 4, 5]}'
    JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[2] = '.channels'

    // Test 3: Nested array property
    JSON_QUERY_INTEGER_ARRAY_TEST_JSON[3] = '{"device":{"ports":[80, 443, 8080]}}'
    JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[3] = '.device.ports'

    // Test 4: Array in array
    JSON_QUERY_INTEGER_ARRAY_TEST_JSON[4] = '[[10, 20], [30, 40, 50]]'
    JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Array with zeros
    JSON_QUERY_INTEGER_ARRAY_TEST_JSON[5] = '{"counters":[0, 0, 0]}'
    JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[5] = '.counters'

    // Test 6: Large values
    JSON_QUERY_INTEGER_ARRAY_TEST_JSON[6] = '{"ids":[10000, 20000, 30000, 40000]}'
    JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[6] = '.ids'

    // Test 7: Max values
    JSON_QUERY_INTEGER_ARRAY_TEST_JSON[7] = '[255, 65535]'
    JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    JSON_QUERY_INTEGER_ARRAY_TEST_JSON[8] = '{"empty":[]}'
    JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single element array
    JSON_QUERY_INTEGER_ARRAY_TEST_JSON[9] = '{"single":[42]}'
    JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    JSON_QUERY_INTEGER_ARRAY_TEST_JSON[10] = '{"devices":[{"addresses":[1, 2]},{"addresses":[3, 4]}]}'
    JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[10] = '.devices[2].addresses'

    set_length_array(JSON_QUERY_INTEGER_ARRAY_TEST_JSON, 10)
    set_length_array(JSON_QUERY_INTEGER_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer JSON_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    5,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    4,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant integer JSON_QUERY_INTEGER_ARRAY_EXPECTED[10][5] = {
    {100, 200, 300},                    // Test 1
    {1, 2, 3, 4, 5},                    // Test 2
    {80, 443, 8080},                    // Test 3
    {30, 40, 50},                       // Test 4
    {0, 0, 0},                          // Test 5
    {10000, 20000, 30000, 40000},       // Test 6
    {255, 65535},                       // Test 7
    {0},                                // Test 8 (empty)
    {42},                               // Test 9
    {3, 4}                              // Test 10
}


define_function TestNAVJsonQueryIntegerArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryIntegerArray'")

    InitializeJsonQueryIntegerArrayTestData()

    for (x = 1; x <= length_array(JSON_QUERY_INTEGER_ARRAY_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var integer result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVJsonParse(JSON_QUERY_INTEGER_ARRAY_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQueryIntegerArray(json, JSON_QUERY_INTEGER_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   JSON_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(JSON_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertIntegerEqual("'Array element ', itoa(i)",
                                      JSON_QUERY_INTEGER_ARRAY_EXPECTED[x][i],
                                      result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(JSON_QUERY_INTEGER_ARRAY_EXPECTED[x][i])",
                                "'Element ', itoa(i), ': ', itoa(result[i])")

                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQueryIntegerArray'")
}
