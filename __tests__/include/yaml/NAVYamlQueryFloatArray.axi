PROGRAM_NAME='NAVYamlQueryFloatArray'

DEFINE_VARIABLE

volatile char YAML_QUERY_FLOAT_ARRAY_TEST_YAML[10][512]
volatile char YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[10][64]


define_function InitializeYamlQueryFloatArrayTestData() {
    // Test 1: Simple root sequence
    YAML_QUERY_FLOAT_ARRAY_TEST_YAML[1] = "'- 1.1', 13, 10,
                                            '- 2.2', 13, 10,
                                            '- 3.3', 13, 10"
    YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Sequence property
    YAML_QUERY_FLOAT_ARRAY_TEST_YAML[2] = "'temperatures:', 13, 10,
                                            '  - 98.6', 13, 10,
                                            '  - 100.4', 13, 10,
                                            '  - 96.8', 13, 10"
    YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[2] = '.temperatures'

    // Test 3: Nested sequence property
    YAML_QUERY_FLOAT_ARRAY_TEST_YAML[3] = "'sensor:', 13, 10,
                                            '  readings:', 13, 10,
                                            '    - 12.34', 13, 10,
                                            '    - 56.78', 13, 10,
                                            '    - 90.12', 13, 10"
    YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[3] = '.sensor.readings'

    // Test 4: Sequence in sequence
    YAML_QUERY_FLOAT_ARRAY_TEST_YAML[4] = "'- - 1.0', 13, 10,
                                            '  - 2.0', 13, 10,
                                            '- - 3.0', 13, 10,
                                            '  - 4.0', 13, 10,
                                            '  - 5.0', 13, 10"
    YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Sequence with zeros
    YAML_QUERY_FLOAT_ARRAY_TEST_YAML[5] = "'values:', 13, 10,
                                            '  - 0.0', 13, 10,
                                            '  - 0.0', 13, 10,
                                            '  - 0.0', 13, 10"
    YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[5] = '.values'

    // Test 6: Negative values
    YAML_QUERY_FLOAT_ARRAY_TEST_YAML[6] = "'offsets:', 13, 10,
                                            '  - -12.5', 13, 10,
                                            '  - -25.0', 13, 10,
                                            '  - -37.5', 13, 10"
    YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[6] = '.offsets'

    // Test 7: Mixed integer/float
    YAML_QUERY_FLOAT_ARRAY_TEST_YAML[7] = "'- 1', 13, 10,
                                            '- 2.5', 13, 10,
                                            '- 3', 13, 10,
                                            '- 4.75', 13, 10"
    YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty sequence
    YAML_QUERY_FLOAT_ARRAY_TEST_YAML[8] = "'empty: []', 13, 10"
    YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single element sequence
    YAML_QUERY_FLOAT_ARRAY_TEST_YAML[9] = "'single:', 13, 10,
                                            '  - 3.14159', 13, 10"
    YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Sequence property after sequence index
    YAML_QUERY_FLOAT_ARRAY_TEST_YAML[10] = "'sensors:', 13, 10,
                                             '  - data:', 13, 10,
                                             '    - 1.1', 13, 10,
                                             '    - 2.2', 13, 10,
                                             '  - data:', 13, 10,
                                             '    - 3.3', 13, 10,
                                             '    - 4.4', 13, 10"
    YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[10] = '.sensors[2].data'

    set_length_array(YAML_QUERY_FLOAT_ARRAY_TEST_YAML, 10)
    set_length_array(YAML_QUERY_FLOAT_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer YAML_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    3,  // Test 6
    4,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant float YAML_QUERY_FLOAT_ARRAY_EXPECTED[10][5] = {
    {1.1, 2.2, 3.3},                        // Test 1
    {98.6, 100.4, 96.8},                    // Test 2
    {12.34, 56.78, 90.12},                  // Test 3
    {3.0, 4.0, 5.0},                        // Test 4
    {0.0, 0.0, 0.0},                        // Test 5
    {-12.5, -25.0, -37.5},                  // Test 6
    {1.0, 2.5, 3.0, 4.75},                  // Test 7
    {0.0},                                  // Test 8 (empty)
    {3.14159},                              // Test 9
    {3.3, 4.4}                              // Test 10
}


define_function TestNAVYamlQueryFloatArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryFloatArray'")

    InitializeYamlQueryFloatArrayTestData()

    for (x = 1; x <= length_array(YAML_QUERY_FLOAT_ARRAY_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var float result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVYamlParse(YAML_QUERY_FLOAT_ARRAY_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQueryFloatArray(yaml, YAML_QUERY_FLOAT_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   YAML_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(YAML_QUERY_FLOAT_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertFloatEqual("'Array element ', itoa(i)",
                              YAML_QUERY_FLOAT_ARRAY_EXPECTED[x][i],
                              result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', ftoa(YAML_QUERY_FLOAT_ARRAY_EXPECTED[x][i])",
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

    NAVLogTestSuiteEnd("'NAVYamlQueryFloatArray'")
}

