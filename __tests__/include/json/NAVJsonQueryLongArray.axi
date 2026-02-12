PROGRAM_NAME='NAVJsonQueryLongArray'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_LONG_ARRAY_TEST_JSON[10][512]
volatile char JSON_QUERY_LONG_ARRAY_TEST_QUERY[10][64]


define_function InitializeJsonQueryLongArrayTestData() {
    // Test 1: Simple root array
    JSON_QUERY_LONG_ARRAY_TEST_JSON[1] = '[100000, 200000, 300000]'
    JSON_QUERY_LONG_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Array property
    JSON_QUERY_LONG_ARRAY_TEST_JSON[2] = '{"timestamps":[1609459200, 1609545600, 1609632000]}'
    JSON_QUERY_LONG_ARRAY_TEST_QUERY[2] = '.timestamps'

    // Test 3: Nested array property
    JSON_QUERY_LONG_ARRAY_TEST_JSON[3] = '{"system":{"sizes":[1000000, 2000000, 3000000]}}'
    JSON_QUERY_LONG_ARRAY_TEST_QUERY[3] = '.system.sizes'

    // Test 4: Array in array
    JSON_QUERY_LONG_ARRAY_TEST_JSON[4] = '[[100000, 200000], [300000, 400000, 500000]]'
    JSON_QUERY_LONG_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Array with zeros
    JSON_QUERY_LONG_ARRAY_TEST_JSON[5] = '{"counters":[0, 0, 0]}'
    JSON_QUERY_LONG_ARRAY_TEST_QUERY[5] = '.counters'

    // Test 6: Large values
    JSON_QUERY_LONG_ARRAY_TEST_JSON[6] = '{"bytes":[2147483647, 1000000000]}'
    JSON_QUERY_LONG_ARRAY_TEST_QUERY[6] = '.bytes'

    // Test 7: Very large values
    JSON_QUERY_LONG_ARRAY_TEST_JSON[7] = '[4294967295, 3000000000]'
    JSON_QUERY_LONG_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    JSON_QUERY_LONG_ARRAY_TEST_JSON[8] = '{"empty":[]}'
    JSON_QUERY_LONG_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single element array
    JSON_QUERY_LONG_ARRAY_TEST_JSON[9] = '{"single":[999999999]}'
    JSON_QUERY_LONG_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    JSON_QUERY_LONG_ARRAY_TEST_JSON[10] = '{"records":[{"ids":[1000000, 2000000]},{"ids":[3000000, 4000000]}]}'
    JSON_QUERY_LONG_ARRAY_TEST_QUERY[10] = '.records[2].ids'

    set_length_array(JSON_QUERY_LONG_ARRAY_TEST_JSON, 10)
    set_length_array(JSON_QUERY_LONG_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer JSON_QUERY_LONG_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    2,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant long JSON_QUERY_LONG_ARRAY_EXPECTED[10][5] = {
    {100000, 200000, 300000},                       // Test 1
    {1609459200, 1609545600, 1609632000},           // Test 2
    {1000000, 2000000, 3000000},                    // Test 3
    {300000, 400000, 500000},                       // Test 4
    {0, 0, 0},                                      // Test 5
    {2147483647, 1000000000},                       // Test 6
    {4294967295, 3000000000},                       // Test 7
    {0},                                            // Test 8 (empty)
    {999999999},                                    // Test 9
    {3000000, 4000000}                              // Test 10
}


define_function TestNAVJsonQueryLongArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryLongArray'")

    InitializeJsonQueryLongArrayTestData()

    for (x = 1; x <= length_array(JSON_QUERY_LONG_ARRAY_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var long result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVJsonParse(JSON_QUERY_LONG_ARRAY_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQueryLongArray(json, JSON_QUERY_LONG_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   JSON_QUERY_LONG_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(JSON_QUERY_LONG_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertLongEqual("'Array element ', itoa(i)",
                                   JSON_QUERY_LONG_ARRAY_EXPECTED[x][i],
                                   result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(JSON_QUERY_LONG_ARRAY_EXPECTED[x][i])",
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

    NAVLogTestSuiteEnd("'NAVJsonQueryLongArray'")
}
