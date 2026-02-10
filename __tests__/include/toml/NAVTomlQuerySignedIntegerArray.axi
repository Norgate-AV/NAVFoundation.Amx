PROGRAM_NAME='NAVTomlQuerySignedIntegerArray'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[10][512]
volatile char TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[10][64]


define_function InitializeTomlQuerySignedIntegerArrayTestData() {
    // Test 1: Simple root array with mixed signs
    TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[1] = 'mixed = [-100, 200, -300]'
    TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[1] = '.mixed'

    // Test 2: Array property with negatives
    TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[2] = 'temperatures = [-15, -10, -5, 0, 5]'
    TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[2] = '.temperatures'

    // Test 3: Nested array property
    TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[3] = "'[sensor]', 13, 10, 'offsets = [-100, -50, 0]', 13, 10"
    TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[3] = '.sensor.offsets'

    // Test 4: Array with zeros
    TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[4] = 'baseline = [0, 0, 0]'
    TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[4] = '.baseline'

    // Test 5: Large negative values
    TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[5] = 'deltas = [-10000, -20000, -30000]'
    TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[5] = '.deltas'

    // Test 6: Extreme values
    TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[6] = 'extremes = [32767, -32768]'
    TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[6] = '.extremes'

    // Test 7: Empty array
    TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[7] = 'empty = []'
    TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[7] = '.empty'

    // Test 8: Single negative element
    TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[8] = 'single = [-42]'
    TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[8] = '.single'

    // Test 9: All positive
    TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[9] = 'positive = [10, 20, 30, 40]'
    TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[9] = '.positive'

    // Test 10: Nested path with array
    TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[10] = "'[device]', 13, 10, '[device.readings]', 13, 10, 'values = [-5, -3, -1, 0, 1]', 13, 10"
    TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[10] = '.device.readings.values'

    set_length_array(TOML_QUERY_SINTEGER_ARRAY_TEST_TOML, 10)
    set_length_array(TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer TOML_QUERY_SINTEGER_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    5,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    2,  // Test 6
    0,  // Test 7 (empty)
    1,  // Test 8
    4,  // Test 9
    5   // Test 10
}

constant sinteger TOML_QUERY_SINTEGER_ARRAY_EXPECTED[10][5] = {
    {-100, 200, -300},                  // Test 1
    {-15, -10, -5, 0, 5},               // Test 2
    {-100, -50, 0},                     // Test 3
    {0, 0, 0},                          // Test 4
    {-10000, -20000, -30000},           // Test 5
    {32767, -32768},                    // Test 6
    {0},                                // Test 7 (empty)
    {-42},                              // Test 8
    {10, 20, 30, 40},                   // Test 9
    {-5, -3, -1, 0, 1}                  // Test 10
}


define_function TestNAVTomlQuerySignedIntegerArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQuerySignedIntegerArray'")

    InitializeTomlQuerySignedIntegerArrayTestData()

    for (x = 1; x <= length_array(TOML_QUERY_SINTEGER_ARRAY_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var sinteger result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVTomlParse(TOML_QUERY_SINTEGER_ARRAY_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQuerySignedIntegerArray(toml, TOML_QUERY_SINTEGER_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   TOML_QUERY_SINTEGER_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(TOML_QUERY_SINTEGER_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertSignedIntegerEqual("'Array element ', itoa(i)",
                                            TOML_QUERY_SINTEGER_ARRAY_EXPECTED[x][i],
                                            result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(TOML_QUERY_SINTEGER_ARRAY_EXPECTED[x][i])",
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

    NAVLogTestSuiteEnd("'NAVTomlQuerySignedIntegerArray'")
}
