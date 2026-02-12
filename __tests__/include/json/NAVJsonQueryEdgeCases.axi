PROGRAM_NAME='NAVJsonQueryEdgeCases'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_EDGE_CASE_TEST_JSON[10][512]
volatile char JSON_QUERY_EDGE_CASE_TEST_QUERY[10][128]


define_function InitializeJsonQueryEdgeCaseTestData() {
    // Test 1: Query non-existent property
    JSON_QUERY_EDGE_CASE_TEST_JSON[1] = '{"name":"John"}'
    JSON_QUERY_EDGE_CASE_TEST_QUERY[1] = '.age'

    // Test 2: Array index out of bounds (high)
    JSON_QUERY_EDGE_CASE_TEST_JSON[2] = '[1,2,3]'
    JSON_QUERY_EDGE_CASE_TEST_QUERY[2] = '.[5]'

    // Test 3: Query property on array (type mismatch)
    JSON_QUERY_EDGE_CASE_TEST_JSON[3] = '[1,2,3]'
    JSON_QUERY_EDGE_CASE_TEST_QUERY[3] = '.property'

    // Test 4: Query array index on object (type mismatch)
    JSON_QUERY_EDGE_CASE_TEST_JSON[4] = '{"name":"John"}'
    JSON_QUERY_EDGE_CASE_TEST_QUERY[4] = '.[1]'

    // Test 5: Empty path after valid path
    JSON_QUERY_EDGE_CASE_TEST_JSON[5] = '{"user":{"name":"Jane"}}'
    JSON_QUERY_EDGE_CASE_TEST_QUERY[5] = '.user.name.invalid'

    // Test 6: Nested property doesn't exist
    JSON_QUERY_EDGE_CASE_TEST_JSON[6] = '{"user":{"name":"Jane"}}'
    JSON_QUERY_EDGE_CASE_TEST_QUERY[6] = '.user.age'

    // Test 7: Query on null value
    JSON_QUERY_EDGE_CASE_TEST_JSON[7] = '{"value":null}'
    JSON_QUERY_EDGE_CASE_TEST_QUERY[7] = '.value.property'

    // Test 8: Array index zero (1-based indexing)
    JSON_QUERY_EDGE_CASE_TEST_JSON[8] = '[1,2,3]'
    JSON_QUERY_EDGE_CASE_TEST_QUERY[8] = '.[0]'

    // Test 9: Property after array index out of bounds
    JSON_QUERY_EDGE_CASE_TEST_JSON[9] = '{"items":[{"id":1}]}'
    JSON_QUERY_EDGE_CASE_TEST_QUERY[9] = '.items[5].id'

    // Test 10: Query empty object property
    JSON_QUERY_EDGE_CASE_TEST_JSON[10] = '{"data":{}}'
    JSON_QUERY_EDGE_CASE_TEST_QUERY[10] = '.data.missing'

    set_length_array(JSON_QUERY_EDGE_CASE_TEST_JSON, 10)
    set_length_array(JSON_QUERY_EDGE_CASE_TEST_QUERY, 10)
}


DEFINE_CONSTANT

// Expected: all queries should fail (return false)
constant char JSON_QUERY_EDGE_CASE_EXPECTED_SUCCESS[10] = {
    false, // Test 1: Property doesn't exist
    false, // Test 2: Index out of bounds
    false, // Test 3: Wrong type (array vs object)
    false, // Test 4: Wrong type (object vs array)
    false, // Test 5: Can't query on string
    false, // Test 6: Nested property missing
    false, // Test 7: Can't query on null
    false, // Test 8: Index 0 invalid (1-based)
    false, // Test 9: Index out of bounds
    false  // Test 10: Property doesn't exist in empty object
}


define_function TestNAVJsonQueryEdgeCases() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryEdgeCases'")

    InitializeJsonQueryEdgeCaseTestData()

    for (x = 1; x <= length_array(JSON_QUERY_EDGE_CASE_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var _NAVJsonNode result
        stack_var char querySuccess

        if (!NAVJsonParse(JSON_QUERY_EDGE_CASE_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        querySuccess = NAVJsonQuery(json, JSON_QUERY_EDGE_CASE_TEST_QUERY[x], result)

        if (!NAVAssertBooleanEqual('NAVJsonQuery edge case',
                                   JSON_QUERY_EDGE_CASE_EXPECTED_SUCCESS[x],
                                   querySuccess)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_QUERY_EDGE_CASE_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(querySuccess))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQueryEdgeCases'")
}
