PROGRAM_NAME='NAVYamlQueryLongArray'

DEFINE_VARIABLE

volatile char YAML_QUERY_LONG_ARRAY_TEST_YAML[10][512]
volatile char YAML_QUERY_LONG_ARRAY_TEST_QUERY[10][64]


define_function InitializeYamlQueryLongArrayTestData() {
    // Test 1: Simple root sequence
    YAML_QUERY_LONG_ARRAY_TEST_YAML[1] = "'- 100000', 13, 10,
                                           '- 200000', 13, 10,
                                           '- 300000', 13, 10"
    YAML_QUERY_LONG_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Sequence property
    YAML_QUERY_LONG_ARRAY_TEST_YAML[2] = "'timestamps:', 13, 10,
                                           '  - 1609459200', 13, 10,
                                           '  - 1609545600', 13, 10,
                                           '  - 1609632000', 13, 10"
    YAML_QUERY_LONG_ARRAY_TEST_QUERY[2] = '.timestamps'

    // Test 3: Nested sequence property
    YAML_QUERY_LONG_ARRAY_TEST_YAML[3] = "'system:', 13, 10,
                                           '  sizes:', 13, 10,
                                           '    - 1000000', 13, 10,
                                           '    - 2000000', 13, 10,
                                           '    - 3000000', 13, 10"
    YAML_QUERY_LONG_ARRAY_TEST_QUERY[3] = '.system.sizes'

    // Test 4: Sequence in sequence
    YAML_QUERY_LONG_ARRAY_TEST_YAML[4] = "'- - 100000', 13, 10,
                                           '  - 200000', 13, 10,
                                           '- - 300000', 13, 10,
                                           '  - 400000', 13, 10,
                                           '  - 500000', 13, 10"
    YAML_QUERY_LONG_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Sequence with zeros
    YAML_QUERY_LONG_ARRAY_TEST_YAML[5] = "'counters:', 13, 10,
                                           '  - 0', 13, 10,
                                           '  - 0', 13, 10,
                                           '  - 0', 13, 10"
    YAML_QUERY_LONG_ARRAY_TEST_QUERY[5] = '.counters'

    // Test 6: Large values
    YAML_QUERY_LONG_ARRAY_TEST_YAML[6] = "'bytes:', 13, 10,
                                           '  - 2147483647', 13, 10,
                                           '  - 1000000000', 13, 10"
    YAML_QUERY_LONG_ARRAY_TEST_QUERY[6] = '.bytes'

    // Test 7: Very large values
    YAML_QUERY_LONG_ARRAY_TEST_YAML[7] = "'- 4294967295', 13, 10,
                                           '- 3000000000', 13, 10"
    YAML_QUERY_LONG_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty sequence
    YAML_QUERY_LONG_ARRAY_TEST_YAML[8] = "'empty: []', 13, 10"
    YAML_QUERY_LONG_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single element sequence
    YAML_QUERY_LONG_ARRAY_TEST_YAML[9] = "'single:', 13, 10,
                                           '  - 999999999', 13, 10"
    YAML_QUERY_LONG_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Sequence property after sequence index
    YAML_QUERY_LONG_ARRAY_TEST_YAML[10] = "'records:', 13, 10,
                                            '  - ids:', 13, 10,
                                            '    - 1000000', 13, 10,
                                            '    - 2000000', 13, 10,
                                            '  - ids:', 13, 10,
                                            '    - 3000000', 13, 10,
                                            '    - 4000000', 13, 10"
    YAML_QUERY_LONG_ARRAY_TEST_QUERY[10] = '.records[2].ids'

    set_length_array(YAML_QUERY_LONG_ARRAY_TEST_YAML, 10)
    set_length_array(YAML_QUERY_LONG_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer YAML_QUERY_LONG_ARRAY_EXPECTED_COUNT[10] = {
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

constant long YAML_QUERY_LONG_ARRAY_EXPECTED[10][5] = {
    {100000, 200000, 300000},                       // Test 1
    {1609459200, 1609545600, 1609632000},           // Test 2
    {1000000, 2000000, 3000000},                    // Test 3
    {300000, 400000, 500000},                       // Test 4
    {0, 0, 0},                                      // Test 5
    {2147483647, 1000000000},                       // Test 6
    {4294967295, 3000000000},                       // Test 7
    {0},                                            // Test 8 (empty)
    {999999999},                                    // Test 9
    {3000000, 4000000}                              // Test 10
}


define_function TestNAVYamlQueryLongArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryLongArray'")

    InitializeYamlQueryLongArrayTestData()

    for (x = 1; x <= length_array(YAML_QUERY_LONG_ARRAY_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var long result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVYamlParse(YAML_QUERY_LONG_ARRAY_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQueryLongArray(yaml, YAML_QUERY_LONG_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   YAML_QUERY_LONG_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(YAML_QUERY_LONG_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertLongEqual("'Array element ', itoa(i)",
                                   YAML_QUERY_LONG_ARRAY_EXPECTED[x][i],
                                   result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(YAML_QUERY_LONG_ARRAY_EXPECTED[x][i])",
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

    NAVLogTestSuiteEnd("'NAVYamlQueryLongArray'")
}

