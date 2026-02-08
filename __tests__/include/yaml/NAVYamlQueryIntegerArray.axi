PROGRAM_NAME='NAVYamlQueryIntegerArray'

DEFINE_VARIABLE

volatile char YAML_QUERY_INTEGER_ARRAY_TEST_YAML[10][512]
volatile char YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[10][64]


define_function InitializeYamlQueryIntegerArrayTestData() {
    // Test 1: Simple root sequence
    YAML_QUERY_INTEGER_ARRAY_TEST_YAML[1] = "'- 100', 13, 10,
                                             '- 200', 13, 10,
                                             '- 300', 13, 10"
    YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Sequence property
    YAML_QUERY_INTEGER_ARRAY_TEST_YAML[2] = "'channels:', 13, 10,
                                             '  - 1', 13, 10,
                                             '  - 2', 13, 10,
                                             '  - 3', 13, 10,
                                             '  - 4', 13, 10,
                                             '  - 5', 13, 10"
    YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[2] = '.channels'

    // Test 3: Nested sequence property
    YAML_QUERY_INTEGER_ARRAY_TEST_YAML[3] = "'device:', 13, 10,
                                             '  ports:', 13, 10,
                                             '    - 80', 13, 10,
                                             '    - 443', 13, 10,
                                             '    - 8080', 13, 10"
    YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[3] = '.device.ports'

    // Test 4: Sequence in sequence
    YAML_QUERY_INTEGER_ARRAY_TEST_YAML[4] = "'- - 10', 13, 10,
                                             '  - 20', 13, 10,
                                             '- - 30', 13, 10,
                                             '  - 40', 13, 10,
                                             '  - 50', 13, 10"
    YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Sequence with zeros
    YAML_QUERY_INTEGER_ARRAY_TEST_YAML[5] = "'counters:', 13, 10,
                                             '  - 0', 13, 10,
                                             '  - 0', 13, 10,
                                             '  - 0', 13, 10"
    YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[5] = '.counters'

    // Test 6: Large values
    YAML_QUERY_INTEGER_ARRAY_TEST_YAML[6] = "'ids:', 13, 10,
                                             '  - 10000', 13, 10,
                                             '  - 20000', 13, 10,
                                             '  - 30000', 13, 10,
                                             '  - 40000', 13, 10"
    YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[6] = '.ids'

    // Test 7: Max values
    YAML_QUERY_INTEGER_ARRAY_TEST_YAML[7] = "'- 255', 13, 10,
                                             '- 65535', 13, 10"
    YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty sequence
    YAML_QUERY_INTEGER_ARRAY_TEST_YAML[8] = "'empty: []', 13, 10"
    YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single element sequence
    YAML_QUERY_INTEGER_ARRAY_TEST_YAML[9] = "'single:', 13, 10,
                                             '  - 42', 13, 10"
    YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Sequence property after sequence index
    YAML_QUERY_INTEGER_ARRAY_TEST_YAML[10] = "'devices:', 13, 10,
                                              '  - addresses:', 13, 10,
                                              '    - 1', 13, 10,
                                              '    - 2', 13, 10,
                                              '  - addresses:', 13, 10,
                                              '    - 3', 13, 10,
                                              '    - 4', 13, 10"
    YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[10] = '.devices[2].addresses'

    set_length_array(YAML_QUERY_INTEGER_ARRAY_TEST_YAML, 10)
    set_length_array(YAML_QUERY_INTEGER_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer YAML_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    5,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    4,  // Test 6
    2,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant integer YAML_QUERY_INTEGER_ARRAY_EXPECTED[10][5] = {
    {100, 200, 300},                    // Test 1
    {1, 2, 3, 4, 5},                    // Test 2
    {80, 443, 8080},                    // Test 3
    {30, 40, 50},                       // Test 4
    {0, 0, 0},                          // Test 5
    {10000, 20000, 30000, 40000},       // Test 6
    {255, 65535},                       // Test 7
    {0},                                // Test 8 (empty)
    {42},                               // Test 9
    {3, 4}                              // Test 10
}


define_function TestNAVYamlQueryIntegerArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryIntegerArray'")

    InitializeYamlQueryIntegerArrayTestData()

    for (x = 1; x <= length_array(YAML_QUERY_INTEGER_ARRAY_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var integer result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVYamlParse(YAML_QUERY_INTEGER_ARRAY_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQueryIntegerArray(yaml, YAML_QUERY_INTEGER_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   YAML_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(YAML_QUERY_INTEGER_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertIntegerEqual("'Array element ', itoa(i)",
                              YAML_QUERY_INTEGER_ARRAY_EXPECTED[x][i],
                              result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', itoa(YAML_QUERY_INTEGER_ARRAY_EXPECTED[x][i])",
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

    NAVLogTestSuiteEnd("'NAVYamlQueryIntegerArray'")
}

