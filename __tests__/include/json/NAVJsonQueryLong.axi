PROGRAM_NAME='NAVJsonQueryLong'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_LONG_TEST_JSON[10][512]
volatile char JSON_QUERY_LONG_TEST_QUERY[10][64]


define_function InitializeJsonQueryLongTestData() {
    // Test 1: Simple value
    JSON_QUERY_LONG_TEST_JSON[1] = '100000'
    JSON_QUERY_LONG_TEST_QUERY[1] = '.'

    // Test 2: Object property
    JSON_QUERY_LONG_TEST_JSON[2] = '{"timestamp":1609459200}'
    JSON_QUERY_LONG_TEST_QUERY[2] = '.timestamp'

    // Test 3: Nested object property
    JSON_QUERY_LONG_TEST_JSON[3] = '{"data":{"bytes":2147483647}}'
    JSON_QUERY_LONG_TEST_QUERY[3] = '.data.bytes'

    // Test 4: Array element
    JSON_QUERY_LONG_TEST_JSON[4] = '[1000000, 2000000, 3000000]'
    JSON_QUERY_LONG_TEST_QUERY[4] = '.[2]'

    // Test 5: Object in array
    JSON_QUERY_LONG_TEST_JSON[5] = '[{"size":100000}, {"size":200000}, {"size":300000}]'
    JSON_QUERY_LONG_TEST_QUERY[5] = '.[3].size'

    // Test 6: Deeply nested property
    JSON_QUERY_LONG_TEST_JSON[6] = '{"system":{"memory":{"total":4294967295}}}'
    JSON_QUERY_LONG_TEST_QUERY[6] = '.system.memory.total'

    // Test 7: Zero value
    JSON_QUERY_LONG_TEST_JSON[7] = '{"counter":0}'
    JSON_QUERY_LONG_TEST_QUERY[7] = '.counter'

    // Test 8: Large value
    JSON_QUERY_LONG_TEST_JSON[8] = '{"fileSize":999999999}'
    JSON_QUERY_LONG_TEST_QUERY[8] = '.fileSize'

    // Test 9: Float to long conversion (truncates)
    JSON_QUERY_LONG_TEST_JSON[9] = '{"value":123456.789}'
    JSON_QUERY_LONG_TEST_QUERY[9] = '.value'

    // Test 10: Property after array index
    JSON_QUERY_LONG_TEST_JSON[10] = '{"records":[{"id":1000000},{"id":2000000}]}'
    JSON_QUERY_LONG_TEST_QUERY[10] = '.records[1].id'

    set_length_array(JSON_QUERY_LONG_TEST_JSON, 10)
    set_length_array(JSON_QUERY_LONG_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant long JSON_QUERY_LONG_EXPECTED[10] = {
    100000,      // Test 1
    1609459200,  // Test 2
    2147483647,  // Test 3
    2000000,     // Test 4
    300000,      // Test 5
    4294967295,  // Test 6
    0,           // Test 7
    999999999,   // Test 8
    123456,      // Test 9 (truncated)
    1000000      // Test 10
}


define_function TestNAVJsonQueryLong() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQueryLong'")

    InitializeJsonQueryLongTestData()

    for (x = 1; x <= length_array(JSON_QUERY_LONG_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var long result

        if (!NAVJsonParse(JSON_QUERY_LONG_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQueryLong(json, JSON_QUERY_LONG_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertLongEqual('NAVJsonQueryLong value',
                                JSON_QUERY_LONG_EXPECTED[x],
                                result)) {
            NAVLogTestFailed(x,
                            itoa(JSON_QUERY_LONG_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQueryLong'")
}
