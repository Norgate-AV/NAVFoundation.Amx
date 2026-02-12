PROGRAM_NAME='NAVTomlQueryIntegerArray'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_INTEGER_ARRAY_TEST_TOML[10][512]
volatile char TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[10][64]


define_function InitializeTomlQueryIntegerArrayTestData() {
    // Test 1: Simple root array
    TOML_QUERY_INTEGER_ARRAY_TEST_TOML[1] = 'numbers = [100, 200, 300]'
    TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[1] = '.numbers'

    // Test 2: Array property with multiple values
    TOML_QUERY_INTEGER_ARRAY_TEST_TOML[2] = 'channels = [1, 2, 3, 4, 5]'
    TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[2] = '.channels'

    // Test 3: Nested array property
    TOML_QUERY_INTEGER_ARRAY_TEST_TOML[3] = "'[device]', 13, 10, 'ports = [80, 443, 8080]', 13, 10"
    TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[3] = '.device.ports'

    // Test 4: Array with zeros
    TOML_QUERY_INTEGER_ARRAY_TEST_TOML[4] = 'counters = [0, 0, 0]'
    TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[4] = '.counters'

    // Test 5: Large values
    TOML_QUERY_INTEGER_ARRAY_TEST_TOML[5] = 'ids = [10000, 20000, 30000, 40000]'
    TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[5] = '.ids'

    // Test 6: Max values
    TOML_QUERY_INTEGER_ARRAY_TEST_TOML[6] = 'maximum = [255, 65535]'
    TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[6] = '.maximum'

    // Test 7: Empty array
    TOML_QUERY_INTEGER_ARRAY_TEST_TOML[7] = 'empty = []'
    TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[7] = '.empty'

    // Test 8: Single element array
    TOML_QUERY_INTEGER_ARRAY_TEST_TOML[8] = 'single = [42]'
    TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[8] = '.single'

    // Test 9: Hex and octal values
    TOML_QUERY_INTEGER_ARRAY_TEST_TOML[9] = 'bases = [0xFF, 0o755, 0b1111]'
    TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[9] = '.bases'

    // Test 10: Nested path with array
    TOML_QUERY_INTEGER_ARRAY_TEST_TOML[10] = "'[server]', 13, 10, '[server.config]', 13, 10, 'timeouts = [30, 60, 90]', 13, 10"
    TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[10] = '.server.config.timeouts'

    set_length_array(TOML_QUERY_INTEGER_ARRAY_TEST_TOML, 10)
    set_length_array(TOML_QUERY_INTEGER_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer TOML_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    5,  // Test 2
    3,  // Test 3
    3,  // Test 4
    4,  // Test 5
    2,  // Test 6
    0,  // Test 7 (empty)
    1,  // Test 8
    3,  // Test 9
    3   // Test 10
}

constant integer TOML_QUERY_INTEGER_ARRAY_EXPECTED[10][5] = {
    {100, 200, 300},                    // Test 1
    {1, 2, 3, 4, 5},                    // Test 2
    {80, 443, 8080},                    // Test 3
    {0, 0, 0},                          // Test 4
    {10000, 20000, 30000, 40000},       // Test 5
    {255, 65535},                       // Test 6
    {0},                                // Test 7 (empty)
    {42},                               // Test 8
    {255, 493, 15},                     // Test 9 (0xFF=255, 0o755=493, 0b1111=15)
    {30, 60, 90}                        // Test 10
}


define_function TestNAVTomlQueryIntegerArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQueryIntegerArray'")

    InitializeTomlQueryIntegerArrayTestData()

    for (x = 1; x <= length_array(TOML_QUERY_INTEGER_ARRAY_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var integer result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVTomlParse(TOML_QUERY_INTEGER_ARRAY_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQueryIntegerArray(toml, TOML_QUERY_INTEGER_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   TOML_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(TOML_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertIntegerEqual("'Array element ', itoa(i)",
                                      TOML_QUERY_INTEGER_ARRAY_EXPECTED[x][i],
                                      result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(TOML_QUERY_INTEGER_ARRAY_EXPECTED[x][i])",
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

    NAVLogTestSuiteEnd("'NAVTomlQueryIntegerArray'")
}
