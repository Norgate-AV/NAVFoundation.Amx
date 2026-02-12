PROGRAM_NAME='NAVJsonQuerySignedLong'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_SLONG_TEST_JSON[10][512]
volatile char JSON_QUERY_SLONG_TEST_QUERY[10][64]


define_function InitializeJsonQuerySignedLongTestData() {
    // Test 1: Positive value
    JSON_QUERY_SLONG_TEST_JSON[1] = '1000000'
    JSON_QUERY_SLONG_TEST_QUERY[1] = '.'

    // Test 2: Negative value
    JSON_QUERY_SLONG_TEST_JSON[2] = '{"balance":-500000}'
    JSON_QUERY_SLONG_TEST_QUERY[2] = '.balance'

    // Test 3: Nested negative value
    JSON_QUERY_SLONG_TEST_JSON[3] = '{"account":{"deficit":-1000000}}'
    JSON_QUERY_SLONG_TEST_QUERY[3] = '.account.deficit'

    // Test 4: Array with negative
    JSON_QUERY_SLONG_TEST_JSON[4] = '[-100000, -200000, -300000]'
    JSON_QUERY_SLONG_TEST_QUERY[4] = '.[2]'

    // Test 5: Object in array with negative
    JSON_QUERY_SLONG_TEST_JSON[5] = '[{"offset":-50000}, {"offset":-100000}, {"offset":-150000}]'
    JSON_QUERY_SLONG_TEST_QUERY[5] = '.[3].offset'

    // Test 6: Deeply nested negative
    JSON_QUERY_SLONG_TEST_JSON[6] = '{"financial":{"data":{"loss":-2000000}}}'
    JSON_QUERY_SLONG_TEST_QUERY[6] = '.financial.data.loss'

    // Test 7: Zero value
    JSON_QUERY_SLONG_TEST_JSON[7] = '{"net":0}'
    JSON_QUERY_SLONG_TEST_QUERY[7] = '.net'

    // Test 8: Maximum positive value
    JSON_QUERY_SLONG_TEST_JSON[8] = '{"maxValue":2147483647}'
    JSON_QUERY_SLONG_TEST_QUERY[8] = '.maxValue'

    // Test 9: Maximum negative value
    JSON_QUERY_SLONG_TEST_JSON[9] = '{"minValue":-2147483648}'
    JSON_QUERY_SLONG_TEST_QUERY[9] = '.minValue'

    // Test 10: Property after array index
    JSON_QUERY_SLONG_TEST_JSON[10] = '{"transactions":[{"amount":-12345},{"amount":67890}]}'
    JSON_QUERY_SLONG_TEST_QUERY[10] = '.transactions[1].amount'

    set_length_array(JSON_QUERY_SLONG_TEST_JSON, 10)
    set_length_array(JSON_QUERY_SLONG_TEST_QUERY, 10)
}


define_function TestNAVJsonQuerySignedLong() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQuerySignedLong'")

    InitializeJsonQuerySignedLongTestData()

    for (x = 1; x <= length_array(JSON_QUERY_SLONG_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var slong result
        stack_var slong expected

        if (!NAVJsonParse(JSON_QUERY_SLONG_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQuerySignedLong(json, JSON_QUERY_SLONG_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // NOTE: NetLinx compiler quirk - SLONG literal negative values
        // The NetLinx compiler does not properly handle literal negative values
        // with SLONG type (e.g., expected = -1000). This causes type conversion
        // warnings and incorrect values. To work around this, we initialize
        // expected to 0 and calculate negative values programmatically using
        // subtraction (e.g., expected = 0 - 1000 or expected - type_cast(1000)).
        expected = 0

        switch (x) {
            case 1: expected = type_cast(1000000)          // Test 1: Positive value
            case 2: expected = expected - type_cast(500000) // Test 2: Negative value
            case 3: expected = expected - type_cast(1000000) // Test 3: Nested negative
            case 4: expected = expected - type_cast(200000) // Test 4: Array with negative
            case 5: expected = expected - type_cast(150000) // Test 5: Object in array
            case 6: expected = expected - type_cast(2000000) // Test 6: Deeply nested
            case 7: expected = 0                           // Test 7: Zero value
            case 8: expected = type_cast(2147483647)       // Test 8: Max positive
            case 9: expected = expected - type_cast(2147483648) // Test 9: Max negative
            case 10: expected = expected - type_cast(12345) // Test 10: Property after array
        }

        if (!NAVAssertSignedLongEqual('NAVJsonQuerySignedLong value',
                                      expected,
                                      result)) {
            NAVLogTestFailed(x,
                            itoa(expected),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonQuerySignedLong'")
}
