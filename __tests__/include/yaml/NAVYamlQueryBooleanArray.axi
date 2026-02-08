PROGRAM_NAME='NAVYamlQueryBooleanArray'

DEFINE_VARIABLE

volatile char YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[10][512]
volatile char YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[10][64]


define_function InitializeYamlQueryBooleanArrayTestData() {
    // Test 1: Simple root sequence
    YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[1] = "'- true', 13, 10,
                                              '- false', 13, 10,
                                              '- true', 13, 10"
    YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Sequence property
    YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[2] = "'flags:', 13, 10,
                                              '  - false', 13, 10,
                                              '  - true', 13, 10,
                                              '  - false', 13, 10"
    YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[2] = '.flags'

    // Test 3: Nested sequence property
    YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[3] = "'settings:', 13, 10,
                                              '  enabled:', 13, 10,
                                              '    - yes', 13, 10,
                                              '    - yes', 13, 10,
                                              '    - no', 13, 10"
    YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[3] = '.settings.enabled'

    // Test 4: Sequence in sequence
    YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[4] = "'- - on', 13, 10,
                                              '  - off', 13, 10,
                                              '- - off', 13, 10,
                                              '  - on', 13, 10,
                                              '  - off', 13, 10"
    YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Sequence with all true
    YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[5] = "'switches:', 13, 10,
                                              '  - true', 13, 10,
                                              '  - true', 13, 10,
                                              '  - true', 13, 10"
    YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[5] = '.switches'

    // Test 6: Sequence with all false
    YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[6] = "'disabled:', 13, 10,
                                              '  - false', 13, 10,
                                              '  - false', 13, 10,
                                              '  - false', 13, 10"
    YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[6] = '.disabled'

    // Test 7: Mixed sequence
    YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[7] = "'- true', 13, 10,
                                              '- no', 13, 10,
                                              '- off', 13, 10,
                                              '- yes', 13, 10,
                                              '- on', 13, 10"
    YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty sequence
    YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[8] = "'empty: []', 13, 10"
    YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single element sequence
    YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[9] = "'single:', 13, 10,
                                              '  - true', 13, 10"
    YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Sequence property after sequence index
    YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[10] = "'devices:', 13, 10,
                                               '  - states:', 13, 10,
                                               '    - true', 13, 10,
                                               '    - false', 13, 10,
                                               '  - states:', 13, 10,
                                               '    - false', 13, 10,
                                               '    - true', 13, 10"
    YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[10] = '.devices[2].states'

    set_length_array(YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML, 10)
    set_length_array(YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer YAML_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    3,  // Test 6
    5,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant char YAML_QUERY_BOOLEAN_ARRAY_EXPECTED[10][5] = {
    {true, false, true},                // Test 1
    {false, true, false},               // Test 2
    {true, true, false},                // Test 3
    {false, true, false},               // Test 4
    {true, true, true},                 // Test 5
    {false, false, false},              // Test 6
    {true, false, false, true, true},   // Test 7
    {false},                            // Test 8 (empty)
    {true},                             // Test 9
    {false, true}                       // Test 10
}


define_function TestNAVYamlQueryBooleanArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryBooleanArray'")

    InitializeYamlQueryBooleanArrayTestData()

    for (x = 1; x <= length_array(YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var char result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVYamlParse(YAML_QUERY_BOOLEAN_ARRAY_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQueryBooleanArray(yaml, YAML_QUERY_BOOLEAN_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   YAML_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(YAML_QUERY_BOOLEAN_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertBooleanEqual("'Array element ', itoa(i)",
                               YAML_QUERY_BOOLEAN_ARRAY_EXPECTED[x][i],
                               result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', NAVBooleanToString(YAML_QUERY_BOOLEAN_ARRAY_EXPECTED[x][i])",
                                "'Element ', itoa(i), ': ', NAVBooleanToString(result[i])")
                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQueryBooleanArray'")
}

