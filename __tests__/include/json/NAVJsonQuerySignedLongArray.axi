PROGRAM_NAME='NAVJsonQuerySignedLongArray'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_QUERY_SLONG_ARRAY_TEST_JSON[10][512]
volatile char JSON_QUERY_SLONG_ARRAY_TEST_QUERY[10][64]


define_function InitializeJsonQuerySignedLongArrayTestData() {
    // Test 1: Simple root array with mixed signs
    JSON_QUERY_SLONG_ARRAY_TEST_JSON[1] = '[-100000, 200000, -300000]'
    JSON_QUERY_SLONG_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Array property with negatives
    JSON_QUERY_SLONG_ARRAY_TEST_JSON[2] = '{"balances":[-500000, 1000000, -250000]}'
    JSON_QUERY_SLONG_ARRAY_TEST_QUERY[2] = '.balances'

    // Test 3: Nested array property
    JSON_QUERY_SLONG_ARRAY_TEST_JSON[3] = '{"financial":{"deltas":[-1000000, -500000, 0]}}'
    JSON_QUERY_SLONG_ARRAY_TEST_QUERY[3] = '.financial.deltas'

    // Test 4: Array in array
    JSON_QUERY_SLONG_ARRAY_TEST_JSON[4] = '[[-100000, -200000], [-300000, -400000, -500000]]'
    JSON_QUERY_SLONG_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Array with zeros
    JSON_QUERY_SLONG_ARRAY_TEST_JSON[5] = '{"net":[0, 0, 0]}'
    JSON_QUERY_SLONG_ARRAY_TEST_QUERY[5] = '.net'

    // Test 6: Large negative values
    JSON_QUERY_SLONG_ARRAY_TEST_JSON[6] = '{"losses":[-2000000000, -1000000000]}'
    JSON_QUERY_SLONG_ARRAY_TEST_QUERY[6] = '.losses'

    // Test 7: Extreme values
    JSON_QUERY_SLONG_ARRAY_TEST_JSON[7] = '[2147483647, -2147483648]'
    JSON_QUERY_SLONG_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty array
    JSON_QUERY_SLONG_ARRAY_TEST_JSON[8] = '{"empty":[]}'
    JSON_QUERY_SLONG_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single negative element
    JSON_QUERY_SLONG_ARRAY_TEST_JSON[9] = '{"single":[-10000000]}'
    JSON_QUERY_SLONG_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Array property after array index
    JSON_QUERY_SLONG_ARRAY_TEST_JSON[10] = '{"transactions":[{"amounts":[-100000, -200000]},{"amounts":[-300000, -400000]}]}'
    JSON_QUERY_SLONG_ARRAY_TEST_QUERY[10] = '.transactions[2].amounts'

    set_length_array(JSON_QUERY_SLONG_ARRAY_TEST_JSON, 10)
    set_length_array(JSON_QUERY_SLONG_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer JSON_QUERY_SLONG_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    2,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}


define_function TestNAVJsonQuerySignedLongArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonQuerySignedLongArray'")

    InitializeJsonQuerySignedLongArrayTestData()

    for (x = 1; x <= length_array(JSON_QUERY_SLONG_ARRAY_TEST_JSON); x++) {
        stack_var _NAVJson json
        stack_var slong result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVJsonParse(JSON_QUERY_SLONG_ARRAY_TEST_JSON[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonQuerySignedLongArray(json, JSON_QUERY_SLONG_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   JSON_QUERY_SLONG_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(JSON_QUERY_SLONG_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        // NOTE: NetLinx compiler quirk - SLONG literal negative values
        // The NetLinx compiler does not properly handle literal negative values
        // with SLONG type. To work around this, we initialize expected to 0 and
        // calculate negative values programmatically using subtraction.
        for (i = 1; i <= length_array(result); i++) {
            stack_var slong expected
            expected = 0

            switch (x) {
                case 1: {
                    switch (i) {
                        case 1: expected = expected - type_cast(100000)
                        case 2: expected = type_cast(200000)
                        case 3: expected = expected - type_cast(300000)
                    }
                }
                case 2: {
                    switch (i) {
                        case 1: expected = expected - type_cast(500000)
                        case 2: expected = type_cast(1000000)
                        case 3: expected = expected - type_cast(250000)
                    }
                }
                case 3: {
                    switch (i) {
                        case 1: expected = expected - type_cast(1000000)
                        case 2: expected = expected - type_cast(500000)
                        case 3: expected = 0
                    }
                }
                case 4: {
                    switch (i) {
                        case 1: expected = expected - type_cast(300000)
                        case 2: expected = expected - type_cast(400000)
                        case 3: expected = expected - type_cast(500000)
                    }
                }
                case 5: {
                    expected = 0  // All zeros
                }
                case 6: {
                    switch (i) {
                        case 1: expected = expected - type_cast(2000000000)
                        case 2: expected = expected - type_cast(1000000000)
                    }
                }
                case 7: {
                    switch (i) {
                        case 1: expected = type_cast(2147483647)
                        case 2: expected = expected - type_cast(2147483648)
                    }
                }
                case 9: {
                    expected = expected - type_cast(10000000)
                }
                case 10: {
                    switch (i) {
                        case 1: expected = expected - type_cast(300000)
                        case 2: expected = expected - type_cast(400000)
                    }
                }
            }

            if (!NAVAssertSignedLongEqual("'Array element ', itoa(i)",
                                         expected,
                                         result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(expected)",
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

    NAVLogTestSuiteEnd("'NAVJsonQuerySignedLongArray'")
}
