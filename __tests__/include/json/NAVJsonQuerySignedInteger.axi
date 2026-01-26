PROGRAM_NAME='NAVJsonQuerySignedInteger'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_SINTEGER_TEST_JSON[10][512]
volatile char JSON_QUERY_SINTEGER_TEST_QUERY[10][64]


define_function InitializeJsonQuerySignedIntegerTestData() {
    // Test 1: Positive value
    JSON_QUERY_SINTEGER_TEST_JSON[1] = '42'
    JSON_QUERY_SINTEGER_TEST_QUERY[1] = '.'

    // Test 2: Negative value
    JSON_QUERY_SINTEGER_TEST_JSON[2] = '{"temperature":-15}'
    JSON_QUERY_SINTEGER_TEST_QUERY[2] = '.temperature'

    // Test 3: Nested negative value
    JSON_QUERY_SINTEGER_TEST_JSON[3] = '{"sensor":{"offset":-100}}'
    JSON_QUERY_SINTEGER_TEST_QUERY[3] = '.sensor.offset'

    // Test 4: Array with negative
    JSON_QUERY_SINTEGER_TEST_JSON[4] = '[-10, -20, -30]'
    JSON_QUERY_SINTEGER_TEST_QUERY[4] = '.[2]'

    // Test 5: Object in array with negative
    JSON_QUERY_SINTEGER_TEST_JSON[5] = '[{"delta":-5}, {"delta":-10}, {"delta":-15}]'
    JSON_QUERY_SINTEGER_TEST_QUERY[5] = '.[3].delta'

    // Test 6: Deeply nested negative
    JSON_QUERY_SINTEGER_TEST_JSON[6] = '{"data":{"calibration":{"adjustment":-50}}}'
    JSON_QUERY_SINTEGER_TEST_QUERY[6] = '.data.calibration.adjustment'

    // Test 7: Zero value
    JSON_QUERY_SINTEGER_TEST_JSON[7] = '{"baseline":0}'
    JSON_QUERY_SINTEGER_TEST_QUERY[7] = '.baseline'

    // Test 8: Maximum positive value
    JSON_QUERY_SINTEGER_TEST_JSON[8] = '{"maxValue":32767}'
    JSON_QUERY_SINTEGER_TEST_QUERY[8] = '.maxValue'

    // Test 9: Maximum negative value
    JSON_QUERY_SINTEGER_TEST_JSON[9] = '{"minValue":-32768}'
    JSON_QUERY_SINTEGER_TEST_QUERY[9] = '.minValue'

    // Test 10: Property after array index
    JSON_QUERY_SINTEGER_TEST_JSON[10] = '{"readings":[{"value":-123},{"value":456}]}'
    JSON_QUERY_SINTEGER_TEST_QUERY[10] = '.readings[1].value'

    set_length_array(JSON_QUERY_SINTEGER_TEST_JSON, 10)
    set_length_array(JSON_QUERY_SINTEGER_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant sinteger JSON_QUERY_SINTEGER_EXPECTED[10] = {
    42,      // Test 1
    -15,     // Test 2
    -100,    // Test 3
    -20,     // Test 4
    -15,     // Test 5
    -50,     // Test 6
    0,       // Test 7
    32767,   // Test 8
    -32768,  // Test 9
    -123     // Test 10
}


define_function TestNAVJsonQuerySignedInteger() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQuerySignedInteger'")

    InitializeJsonQuerySignedIntegerTestData()

    for (x = 1; x <= length_array(JSON_QUERY_SINTEGER_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var sinteger result

        if (!NAVJsonParse(JSON_QUERY_SINTEGER_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQuerySignedInteger(json, JSON_QUERY_SINTEGER_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertSignedIntegerEqual('NAVJsonQuerySignedInteger value',
                                         JSON_QUERY_SINTEGER_EXPECTED[x],
                                         result)) {
            NAVLogTestFailed(x,
                            itoa(JSON_QUERY_SINTEGER_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQuerySignedInteger'")
}
