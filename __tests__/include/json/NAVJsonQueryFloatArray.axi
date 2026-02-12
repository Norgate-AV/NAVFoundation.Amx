PROGRAM_NAME='NAVJsonQueryFloatArray'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_FLOAT_ARRAY_TEST_JSON[10][512]
volatile char JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[10][64]


define_function InitializeJsonQueryFloatArrayTestData() {
    // Test 1: Simple root array
    JSON_QUERY_FLOAT_ARRAY_TEST_JSON[1] = '[1.5, 2.5, 3.5]'
    JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Array property
    JSON_QUERY_FLOAT_ARRAY_TEST_JSON[2] = '{"temperatures":[20.5, 21.3, 19.8]}'
    JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[2] = '.temperatures'

    // Test 3: Nested array property
    JSON_QUERY_FLOAT_ARRAY_TEST_JSON[3] = '{"data":{"values":[10.1, 20.2, 30.3]}}'
    JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[3] = '.data.values'

    // Test 4: Array in array
    JSON_QUERY_FLOAT_ARRAY_TEST_JSON[4] = '[[1.1, 2.2], [3.3, 4.4, 5.5]]'
    JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Array with zeros
    JSON_QUERY_FLOAT_ARRAY_TEST_JSON[5] = '{"readings":[0.0, 0.0, 0.0]}'
    JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[5] = '.readings'

    // Test 6: Array with negatives
    JSON_QUERY_FLOAT_ARRAY_TEST_JSON[6] = '{"offsets":[-1.5, -2.5, -3.5]}'
    JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[6] = '.offsets'

    // Test 7: Large precision values
    JSON_QUERY_FLOAT_ARRAY_TEST_JSON[7] = '[123.456789, 987.654321]'
    JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    JSON_QUERY_FLOAT_ARRAY_TEST_JSON[8] = '{"empty":[]}'
    JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single element array
    JSON_QUERY_FLOAT_ARRAY_TEST_JSON[9] = '{"single":[42.42]}'
    JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    JSON_QUERY_FLOAT_ARRAY_TEST_JSON[10] = '{"groups":[{"vals":[1.1, 2.2]},{"vals":[3.3, 4.4]}]}'
    JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[10] = '.groups[2].vals'

    set_length_array(JSON_QUERY_FLOAT_ARRAY_TEST_JSON, 10)
    set_length_array(JSON_QUERY_FLOAT_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer JSON_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    3,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant float JSON_QUERY_FLOAT_ARRAY_EXPECTED[10][5] = {
    {1.5, 2.5, 3.5},                    // Test 1
    {20.5, 21.3, 19.8},                 // Test 2
    {10.1, 20.2, 30.3},                 // Test 3
    {3.3, 4.4, 5.5},                    // Test 4
    {0.0, 0.0, 0.0},                    // Test 5
    {-1.5, -2.5, -3.5},                 // Test 6
    {123.456789, 987.654321},           // Test 7
    {0.0},                              // Test 8 (empty)
    {42.42},                            // Test 9
    {3.3, 4.4}                          // Test 10
}


define_function TestNAVJsonQueryFloatArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryFloatArray'")

    InitializeJsonQueryFloatArrayTestData()

    for (x = 1; x <= length_array(JSON_QUERY_FLOAT_ARRAY_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var float result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVJsonParse(JSON_QUERY_FLOAT_ARRAY_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQueryFloatArray(json, JSON_QUERY_FLOAT_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   JSON_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(JSON_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertFloatAlmostEqual("'Array element ', itoa(i)",
                                          JSON_QUERY_FLOAT_ARRAY_EXPECTED[x][i],
                                          result[i],
                                          0.000001)) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', ftoa(JSON_QUERY_FLOAT_ARRAY_EXPECTED[x][i])",
                                "'Element ', itoa(i), ': ', ftoa(result[i])")
                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQueryFloatArray'")
}
