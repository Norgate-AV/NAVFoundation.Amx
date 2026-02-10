PROGRAM_NAME='NAVTomlQueryFloatArray'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_FLOAT_ARRAY_TEST_TOML[10][512]
volatile char TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[10][64]


define_function InitializeTomlQueryFloatArrayTestData() {
    // Test 1: Simple root array
    TOML_QUERY_FLOAT_ARRAY_TEST_TOML[1] = 'values = [1.1, 2.2, 3.3]'
    TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[1] = '.values'

    // Test 2: Array property with decimals
    TOML_QUERY_FLOAT_ARRAY_TEST_TOML[2] = 'temperatures = [20.5, 21.0, 19.8, 22.3]'
    TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[2] = '.temperatures'

    // Test 3: Nested array property
    TOML_QUERY_FLOAT_ARRAY_TEST_TOML[3] = "'[sensor]', 13, 10, 'readings = [98.6, 99.1, 97.8]', 13, 10"
    TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[3] = '.sensor.readings'

    // Test 4: Array with zeros and negatives
    TOML_QUERY_FLOAT_ARRAY_TEST_TOML[4] = 'mixed = [0.0, -1.5, 3.14]'
    TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[4] = '.mixed'

    // Test 5: Scientific notation
    TOML_QUERY_FLOAT_ARRAY_TEST_TOML[5] = 'scientific = [1e2, 2.5e-1, 3.14e0]'
    TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[5] = '.scientific'

    // Test 6: Large values
    TOML_QUERY_FLOAT_ARRAY_TEST_TOML[6] = 'large = [1000.0, 2000.0]'
    TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[6] = '.large'

    // Test 7: Empty array
    TOML_QUERY_FLOAT_ARRAY_TEST_TOML[7] = 'empty = []'
    TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[7] = '.empty'

    // Test 8: Single element array
    TOML_QUERY_FLOAT_ARRAY_TEST_TOML[8] = 'single = [3.14159]'
    TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[8] = '.single'

    // Test 9: Multiple floats with different notations
    TOML_QUERY_FLOAT_ARRAY_TEST_TOML[9] = 'numbers = [1.0, 2.5, 3.0, 4.5]'
    TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[9] = '.numbers'

    // Test 10: Nested path with array
    TOML_QUERY_FLOAT_ARRAY_TEST_TOML[10] = "'[data]', 13, 10, '[data.metrics]', 13, 10, 'scores = [85.5, 92.0, 78.3]', 13, 10"
    TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[10] = '.data.metrics.scores'

    set_length_array(TOML_QUERY_FLOAT_ARRAY_TEST_TOML, 10)
    set_length_array(TOML_QUERY_FLOAT_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer TOML_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    4,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    2,  // Test 6
    0,  // Test 7 (empty)
    1,  // Test 8
    4,  // Test 9
    3   // Test 10
}

constant float TOML_QUERY_FLOAT_ARRAY_EXPECTED[10][4] = {
    {1.1, 2.2, 3.3},                        // Test 1
    {20.5, 21.0, 19.8, 22.3},               // Test 2
    {98.6, 99.1, 97.8},                     // Test 3
    {0.0, -1.5, 3.14},                      // Test 4
    {100.0, 0.25, 3.14},                    // Test 5 (1e2=100, 2.5e-1=0.25, 3.14e0=3.14)
    {1000.0, 2000.0},                       // Test 6
    {0.0},                                  // Test 7 (empty)
    {3.14159},                              // Test 8
    {1.0, 2.5, 3.0, 4.5},                   // Test 9
    {85.5, 92.0, 78.3}                      // Test 10
}


define_function TestNAVTomlQueryFloatArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQueryFloatArray'")

    InitializeTomlQueryFloatArrayTestData()

    for (x = 1; x <= length_array(TOML_QUERY_FLOAT_ARRAY_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var float result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVTomlParse(TOML_QUERY_FLOAT_ARRAY_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQueryFloatArray(toml, TOML_QUERY_FLOAT_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   TOML_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(TOML_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertFloatEqual("'Array element ', itoa(i)",
                                    TOML_QUERY_FLOAT_ARRAY_EXPECTED[x][i],
                                    result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', ftoa(TOML_QUERY_FLOAT_ARRAY_EXPECTED[x][i])",
                                "'Element ', itoa(i), ': ', ftoa(result[i])")

                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlQueryFloatArray'")
}
