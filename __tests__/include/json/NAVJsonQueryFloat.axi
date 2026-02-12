PROGRAM_NAME='NAVJsonQueryFloat'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_FLOAT_TEST_JSON[10][512]
volatile char JSON_QUERY_FLOAT_TEST_QUERY[10][64]


define_function InitializeJsonQueryFloatTestData() {
    // Test 1: Simple root number
    JSON_QUERY_FLOAT_TEST_JSON[1] = '42.5'
    JSON_QUERY_FLOAT_TEST_QUERY[1] = '.'

    // Test 2: Object property
    JSON_QUERY_FLOAT_TEST_JSON[2] = '{"price":19.99}'
    JSON_QUERY_FLOAT_TEST_QUERY[2] = '.price'

    // Test 3: Nested object property
    JSON_QUERY_FLOAT_TEST_JSON[3] = '{"product":{"cost":99.95}}'
    JSON_QUERY_FLOAT_TEST_QUERY[3] = '.product.cost'

    // Test 4: Array element
    JSON_QUERY_FLOAT_TEST_JSON[4] = '[10.5, 20.25, 30.75]'
    JSON_QUERY_FLOAT_TEST_QUERY[4] = '.[2]'

    // Test 5: Object in array
    JSON_QUERY_FLOAT_TEST_JSON[5] = '[{"value":1.1}, {"value":2.2}, {"value":3.3}]'
    JSON_QUERY_FLOAT_TEST_QUERY[5] = '.[3].value'

    // Test 6: Deeply nested property
    JSON_QUERY_FLOAT_TEST_JSON[6] = '{"data":{"readings":{"temperature":23.5}}}'
    JSON_QUERY_FLOAT_TEST_QUERY[6] = '.data.readings.temperature'

    // Test 7: Zero value
    JSON_QUERY_FLOAT_TEST_JSON[7] = '{"count":0.0}'
    JSON_QUERY_FLOAT_TEST_QUERY[7] = '.count'

    // Test 8: Negative value
    JSON_QUERY_FLOAT_TEST_JSON[8] = '{"temperature":-15.5}'
    JSON_QUERY_FLOAT_TEST_QUERY[8] = '.temperature'

    // Test 9: Large value
    JSON_QUERY_FLOAT_TEST_JSON[9] = '{"distance":12345.6789}'
    JSON_QUERY_FLOAT_TEST_QUERY[9] = '.distance'

    // Test 10: Property after array index
    JSON_QUERY_FLOAT_TEST_JSON[10] = '{"items":[{"weight":1.5},{"weight":2.7}]}'
    JSON_QUERY_FLOAT_TEST_QUERY[10] = '.items[1].weight'

    set_length_array(JSON_QUERY_FLOAT_TEST_JSON, 10)
    set_length_array(JSON_QUERY_FLOAT_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant float JSON_QUERY_FLOAT_EXPECTED[10] = {
    42.5,      // Test 1
    19.99,     // Test 2
    99.95,     // Test 3
    20.25,     // Test 4
    3.3,       // Test 5
    23.5,      // Test 6
    0.0,       // Test 7
    -15.5,     // Test 8
    12345.6789,// Test 9
    1.5        // Test 10
}


define_function TestNAVJsonQueryFloat() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryFloat'")

    InitializeJsonQueryFloatTestData()

    for (x = 1; x <= length_array(JSON_QUERY_FLOAT_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var float result

        if (!NAVJsonParse(JSON_QUERY_FLOAT_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQueryFloat(json, JSON_QUERY_FLOAT_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertFloatAlmostEqual('NAVJsonQueryFloat value',
                                       JSON_QUERY_FLOAT_EXPECTED[x],
                                       result,
                                       0.000001)) {
            NAVLogTestFailed(x,
                            ftoa(JSON_QUERY_FLOAT_EXPECTED[x]),
                            ftoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQueryFloat'")
}
