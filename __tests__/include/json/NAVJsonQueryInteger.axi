PROGRAM_NAME='NAVJsonQueryInteger'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_INTEGER_TEST_JSON[10][512]
volatile char JSON_QUERY_INTEGER_TEST_QUERY[10][64]


define_function InitializeJsonQueryIntegerTestData() {
    // Test 1: Simple root number
    JSON_QUERY_INTEGER_TEST_JSON[1] = '42'
    JSON_QUERY_INTEGER_TEST_QUERY[1] = '.'

    // Test 2: Object property
    JSON_QUERY_INTEGER_TEST_JSON[2] = '{"channel":101}'
    JSON_QUERY_INTEGER_TEST_QUERY[2] = '.channel'

    // Test 3: Nested object property
    JSON_QUERY_INTEGER_TEST_JSON[3] = '{"device":{"id":128}}'
    JSON_QUERY_INTEGER_TEST_QUERY[3] = '.device.id'

    // Test 4: Array element
    JSON_QUERY_INTEGER_TEST_JSON[4] = '[100, 200, 300]'
    JSON_QUERY_INTEGER_TEST_QUERY[4] = '.[2]'

    // Test 5: Object in array
    JSON_QUERY_INTEGER_TEST_JSON[5] = '[{"port":80}, {"port":443}, {"port":8080}]'
    JSON_QUERY_INTEGER_TEST_QUERY[5] = '.[3].port'

    // Test 6: Deeply nested property
    JSON_QUERY_INTEGER_TEST_JSON[6] = '{"config":{"network":{"timeout":5000}}}'
    JSON_QUERY_INTEGER_TEST_QUERY[6] = '.config.network.timeout'

    // Test 7: Zero value
    JSON_QUERY_INTEGER_TEST_JSON[7] = '{"count":0}'
    JSON_QUERY_INTEGER_TEST_QUERY[7] = '.count'

    // Test 8: Maximum 16-bit value
    JSON_QUERY_INTEGER_TEST_JSON[8] = '{"maxValue":65535}'
    JSON_QUERY_INTEGER_TEST_QUERY[8] = '.maxValue'

    // Test 9: Float to integer conversion (truncates)
    JSON_QUERY_INTEGER_TEST_JSON[9] = '{"value":123.456}'
    JSON_QUERY_INTEGER_TEST_QUERY[9] = '.value'

    // Test 10: Property after array index
    JSON_QUERY_INTEGER_TEST_JSON[10] = '{"devices":[{"address":1},{"address":2}]}'
    JSON_QUERY_INTEGER_TEST_QUERY[10] = '.devices[1].address'

    set_length_array(JSON_QUERY_INTEGER_TEST_JSON, 10)
    set_length_array(JSON_QUERY_INTEGER_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer JSON_QUERY_INTEGER_EXPECTED[10] = {
    42,      // Test 1
    101,     // Test 2
    128,     // Test 3
    200,     // Test 4
    8080,    // Test 5
    5000,    // Test 6
    0,       // Test 7
    65535,   // Test 8
    123,     // Test 9 (truncated)
    1        // Test 10
}


define_function TestNAVJsonQueryInteger() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryInteger'")

    InitializeJsonQueryIntegerTestData()

    for (x = 1; x <= length_array(JSON_QUERY_INTEGER_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var integer result

        if (!NAVJsonParse(JSON_QUERY_INTEGER_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQueryInteger(json, JSON_QUERY_INTEGER_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('NAVJsonQueryInteger value',
                                   JSON_QUERY_INTEGER_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(JSON_QUERY_INTEGER_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQueryInteger'")
}
