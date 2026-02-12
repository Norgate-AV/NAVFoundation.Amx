PROGRAM_NAME='NAVTomlQueryLongArray'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_LONG_ARRAY_TEST_TOML[10][512]
volatile char TOML_QUERY_LONG_ARRAY_TEST_QUERY[10][64]


define_function InitializeTomlQueryLongArrayTestData() {
    // Test 1: Simple root array
    TOML_QUERY_LONG_ARRAY_TEST_TOML[1] = 'timestamps = [1000000, 2000000, 3000000]'
    TOML_QUERY_LONG_ARRAY_TEST_QUERY[1] = '.timestamps'

    // Test 2: Array property with large values
    TOML_QUERY_LONG_ARRAY_TEST_TOML[2] = 'ids = [100000, 200000, 300000, 400000, 500000]'
    TOML_QUERY_LONG_ARRAY_TEST_QUERY[2] = '.ids'

    // Test 3: Nested array property
    TOML_QUERY_LONG_ARRAY_TEST_TOML[3] = "'[database]', 13, 10, 'records = [1234567, 2345678, 3456789]', 13, 10"
    TOML_QUERY_LONG_ARRAY_TEST_QUERY[3] = '.database.records'

    // Test 4: Array with zeros
    TOML_QUERY_LONG_ARRAY_TEST_TOML[4] = 'counters = [0, 0, 0]'
    TOML_QUERY_LONG_ARRAY_TEST_QUERY[4] = '.counters'

    // Test 5: Very large values
    TOML_QUERY_LONG_ARRAY_TEST_TOML[5] = 'big = [1000000000, 2000000000, 3000000000]'
    TOML_QUERY_LONG_ARRAY_TEST_QUERY[5] = '.big'

    // Test 6: Max 32-bit values
    TOML_QUERY_LONG_ARRAY_TEST_TOML[6] = 'maximum = [4294967295]'
    TOML_QUERY_LONG_ARRAY_TEST_QUERY[6] = '.maximum'

    // Test 7: Empty array
    TOML_QUERY_LONG_ARRAY_TEST_TOML[7] = 'empty = []'
    TOML_QUERY_LONG_ARRAY_TEST_QUERY[7] = '.empty'

    // Test 8: Single element array
    TOML_QUERY_LONG_ARRAY_TEST_TOML[8] = 'single = [123456789]'
    TOML_QUERY_LONG_ARRAY_TEST_QUERY[8] = '.single'

    // Test 9: Mixed sizes
    TOML_QUERY_LONG_ARRAY_TEST_TOML[9] = 'mixed = [1, 100, 10000, 1000000]'
    TOML_QUERY_LONG_ARRAY_TEST_QUERY[9] = '.mixed'

    // Test 10: Nested path with array
    TOML_QUERY_LONG_ARRAY_TEST_TOML[10] = "'[server]', 13, 10, '[server.metrics]', 13, 10, 'bytes = [1048576, 2097152, 4194304]', 13, 10"
    TOML_QUERY_LONG_ARRAY_TEST_QUERY[10] = '.server.metrics.bytes'

    set_length_array(TOML_QUERY_LONG_ARRAY_TEST_TOML, 10)
    set_length_array(TOML_QUERY_LONG_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer TOML_QUERY_LONG_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    5,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    1,  // Test 6
    0,  // Test 7 (empty)
    1,  // Test 8
    4,  // Test 9
    3   // Test 10
}

constant long TOML_QUERY_LONG_ARRAY_EXPECTED[10][5] = {
    {1000000, 2000000, 3000000},                    // Test 1
    {100000, 200000, 300000, 400000, 500000},       // Test 2
    {1234567, 2345678, 3456789},                    // Test 3
    {0, 0, 0},                                      // Test 4
    {1000000000, 2000000000, 3000000000},           // Test 5
    {4294967295},                                   // Test 6
    {0},                                            // Test 7 (empty)
    {123456789},                                    // Test 8
    {1, 100, 10000, 1000000},                       // Test 9
    {1048576, 2097152, 4194304}                     // Test 10
}


define_function TestNAVTomlQueryLongArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQueryLongArray'")

    InitializeTomlQueryLongArrayTestData()

    for (x = 1; x <= length_array(TOML_QUERY_LONG_ARRAY_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var long result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVTomlParse(TOML_QUERY_LONG_ARRAY_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQueryLongArray(toml, TOML_QUERY_LONG_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   TOML_QUERY_LONG_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(TOML_QUERY_LONG_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertLongEqual("'Array element ', itoa(i)",
                                   TOML_QUERY_LONG_ARRAY_EXPECTED[x][i],
                                   result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(TOML_QUERY_LONG_ARRAY_EXPECTED[x][i])",
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

    NAVLogTestSuiteEnd("'NAVTomlQueryLongArray'")
}
