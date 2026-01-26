PROGRAM_NAME='NAVJsonQuerySignedIntegerArray'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[10][512]
volatile char JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[10][64]


define_function InitializeJsonQuerySignedIntegerArrayTestData() {
    // Test 1: Simple root array with mixed signs
    JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[1] = '[-100, 200, -300]'
    JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Array property with negatives
    JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[2] = '{"temperatures":[-15, -10, -5, 0, 5]}'
    JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[2] = '.temperatures'

    // Test 3: Nested array property
    JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[3] = '{"sensor":{"offsets":[-100, -50, 0]}}'
    JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[3] = '.sensor.offsets'

    // Test 4: Array in array
    JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[4] = '[[-10, -20], [-30, -40, -50]]'
    JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Array with zeros
    JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[5] = '{"baseline":[0, 0, 0]}'
    JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[5] = '.baseline'

    // Test 6: Large negative values
    JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[6] = '{"deltas":[-10000, -20000, -30000]}'
    JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[6] = '.deltas'

    // Test 7: Extreme values
    JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[7] = '[32767, -32768]'
    JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[8] = '{"empty":[]}'
    JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single negative element
    JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[9] = '{"single":[-42]}'
    JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[10] = '{"readings":[{"vals":[-1, -2]},{"vals":[-3, -4]}]}'
    JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[10] = '.readings[2].vals'

    set_length_array(JSON_QUERY_SINTEGER_ARRAY_TEST_JSON, 10)
    set_length_array(JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer JSON_QUERY_SINTEGER_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    5,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    3,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant sinteger JSON_QUERY_SINTEGER_ARRAY_EXPECTED[10][5] = {
    {-100, 200, -300},                  // Test 1
    {-15, -10, -5, 0, 5},               // Test 2
    {-100, -50, 0},                     // Test 3
    {-30, -40, -50},                    // Test 4
    {0, 0, 0},                          // Test 5
    {-10000, -20000, -30000},           // Test 6
    {32767, -32768},                    // Test 7
    {0},                                // Test 8 (empty)
    {-42},                              // Test 9
    {-3, -4}                            // Test 10
}


define_function TestNAVJsonQuerySignedIntegerArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQuerySignedIntegerArray'")

    InitializeJsonQuerySignedIntegerArrayTestData()

    for (x = 1; x <= length_array(JSON_QUERY_SINTEGER_ARRAY_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var sinteger result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVJsonParse(JSON_QUERY_SINTEGER_ARRAY_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQuerySignedIntegerArray(json, JSON_QUERY_SINTEGER_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   JSON_QUERY_SINTEGER_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(JSON_QUERY_SINTEGER_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertSignedIntegerEqual("'Array element ', itoa(i)",
                                            JSON_QUERY_SINTEGER_ARRAY_EXPECTED[x][i],
                                            result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(JSON_QUERY_SINTEGER_ARRAY_EXPECTED[x][i])",
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

    NAVLogTestSuiteEnd("'NAVJsonQuerySignedIntegerArray'")
}
