PROGRAM_NAME='NAVJsonQueryBoolean'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_BOOLEAN_TEST_JSON[10][512]
volatile char JSON_QUERY_BOOLEAN_TEST_QUERY[10][64]


define_function InitializeJsonQueryBooleanTestData() {
    // Test 1: Simple root true
    JSON_QUERY_BOOLEAN_TEST_JSON[1] = 'true'
    JSON_QUERY_BOOLEAN_TEST_QUERY[1] = '.'

    // Test 2: Simple root false
    JSON_QUERY_BOOLEAN_TEST_JSON[2] = 'false'
    JSON_QUERY_BOOLEAN_TEST_QUERY[2] = '.'

    // Test 3: Object property true
    JSON_QUERY_BOOLEAN_TEST_JSON[3] = '{"enabled":true}'
    JSON_QUERY_BOOLEAN_TEST_QUERY[3] = '.enabled'

    // Test 4: Object property false
    JSON_QUERY_BOOLEAN_TEST_JSON[4] = '{"active":false}'
    JSON_QUERY_BOOLEAN_TEST_QUERY[4] = '.active'

    // Test 5: Nested object property
    JSON_QUERY_BOOLEAN_TEST_JSON[5] = '{"settings":{"isVisible":true}}'
    JSON_QUERY_BOOLEAN_TEST_QUERY[5] = '.settings.isVisible'

    // Test 6: Array element
    JSON_QUERY_BOOLEAN_TEST_JSON[6] = '[true, false, true]'
    JSON_QUERY_BOOLEAN_TEST_QUERY[6] = '.[2]'

    // Test 7: Object in array
    JSON_QUERY_BOOLEAN_TEST_JSON[7] = '[{"flag":false}, {"flag":true}, {"flag":false}]'
    JSON_QUERY_BOOLEAN_TEST_QUERY[7] = '.[2].flag'

    // Test 8: Deeply nested property
    JSON_QUERY_BOOLEAN_TEST_JSON[8] = '{"config":{"options":{"debug":false}}}'
    JSON_QUERY_BOOLEAN_TEST_QUERY[8] = '.config.options.debug'

    // Test 9: Property after array index
    JSON_QUERY_BOOLEAN_TEST_JSON[9] = '{"devices":[{"online":true},{"online":false}]}'
    JSON_QUERY_BOOLEAN_TEST_QUERY[9] = '.devices[1].online'

    // Test 10: Multiple nested levels
    JSON_QUERY_BOOLEAN_TEST_JSON[10] = '{"system":{"modules":[{"enabled":true},{"enabled":false}]}}'
    JSON_QUERY_BOOLEAN_TEST_QUERY[10] = '.system.modules[2].enabled'

    set_length_array(JSON_QUERY_BOOLEAN_TEST_JSON, 10)
    set_length_array(JSON_QUERY_BOOLEAN_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant char JSON_QUERY_BOOLEAN_EXPECTED[10] = {
    true,  // Test 1
    false, // Test 2
    true,  // Test 3
    false, // Test 4
    true,  // Test 5
    false, // Test 6
    true,  // Test 7
    false, // Test 8
    true,  // Test 9
    false  // Test 10
}


define_function TestNAVJsonQueryBoolean() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryBoolean'")

    InitializeJsonQueryBooleanTestData()

    for (x = 1; x <= length_array(JSON_QUERY_BOOLEAN_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var char result

        if (!NAVJsonParse(JSON_QUERY_BOOLEAN_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQueryBoolean(json, JSON_QUERY_BOOLEAN_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertBooleanEqual('NAVJsonQueryBoolean value',
                           JSON_QUERY_BOOLEAN_EXPECTED[x],
                           result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_QUERY_BOOLEAN_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQueryBoolean'")
}
