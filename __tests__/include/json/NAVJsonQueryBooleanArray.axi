PROGRAM_NAME='NAVJsonQueryBooleanArray'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[10][512]
volatile char JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[10][64]


define_function InitializeJsonQueryBooleanArrayTestData() {
    // Test 1: Simple root array
    JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[1] = '[true, false, true]'
    JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Array property
    JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[2] = '{"flags":[false, true, false]}'
    JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[2] = '.flags'

    // Test 3: Nested array property
    JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[3] = '{"settings":{"enabled":[true, true, false]}}'
    JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[3] = '.settings.enabled'

    // Test 4: Array in array
    JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[4] = '[[true, false], [false, true, false]]'
    JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Array with all true
    JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[5] = '{"switches":[true, true, true]}'
    JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[5] = '.switches'

    // Test 6: Array with all false
    JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[6] = '{"disabled":[false, false, false]}'
    JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[6] = '.disabled'

    // Test 7: Mixed array
    JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[7] = '[true, false, false, true, true]'
    JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[8] = '{"empty":[]}'
    JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single element array
    JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[9] = '{"single":[true]}'
    JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[10] = '{"devices":[{"states":[true, false]},{"states":[false, true]}]}'
    JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[10] = '.devices[2].states'

    set_length_array(JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON, 10)
    set_length_array(JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer JSON_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    3,  // Test 6
    5,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant char JSON_QUERY_BOOLEAN_ARRAY_EXPECTED[10][5] = {
    {true, false, true},                // Test 1
    {false, true, false},               // Test 2
    {true, true, false},                // Test 3
    {false, true, false},               // Test 4
    {true, true, true},                 // Test 5
    {false, false, false},              // Test 6
    {true, false, false, true, true},   // Test 7
    {false},                            // Test 8 (empty)
    {true},                             // Test 9
    {false, true}                       // Test 10
}


define_function TestNAVJsonQueryBooleanArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryBooleanArray'")

    InitializeJsonQueryBooleanArrayTestData()

    for (x = 1; x <= length_array(JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var char result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVJsonParse(JSON_QUERY_BOOLEAN_ARRAY_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQueryBooleanArray(json, JSON_QUERY_BOOLEAN_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   JSON_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(JSON_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertBooleanEqual("'Array element ', itoa(i)",
                               JSON_QUERY_BOOLEAN_ARRAY_EXPECTED[x][i],
                               result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', NAVBooleanToString(JSON_QUERY_BOOLEAN_ARRAY_EXPECTED[x][i])",
                                "'Element ', itoa(i), ': ', NAVBooleanToString(result[i])")
                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQueryBooleanArray'")
}
