PROGRAM_NAME='NAVYamlQueryStringArray'

DEFINE_VARIABLE

volatile char YAML_QUERY_STRING_ARRAY_TEST_YAML[10][512]
volatile char YAML_QUERY_STRING_ARRAY_TEST_QUERY[10][64]


define_function InitializeYamlQueryStringArrayTestData() {
    // Test 1: Simple root sequence
    YAML_QUERY_STRING_ARRAY_TEST_YAML[1] = "'- first', 13, 10,
                                             '- second', 13, 10,
                                             '- third', 13, 10"
    YAML_QUERY_STRING_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Sequence property
    YAML_QUERY_STRING_ARRAY_TEST_YAML[2] = "'names:', 13, 10,
                                             '  - Alice', 13, 10,
                                             '  - Bob', 13, 10,
                                             '  - Charlie', 13, 10"
    YAML_QUERY_STRING_ARRAY_TEST_QUERY[2] = '.names'

    // Test 3: Nested sequence property
    YAML_QUERY_STRING_ARRAY_TEST_YAML[3] = "'user:', 13, 10,
                                             '  tags:', 13, 10,
                                             '    - admin', 13, 10,
                                             '    - developer', 13, 10,
                                             '    - tester', 13, 10"
    YAML_QUERY_STRING_ARRAY_TEST_QUERY[3] = '.user.tags'

    // Test 4: Sequence in sequence
    YAML_QUERY_STRING_ARRAY_TEST_YAML[4] = "'- - a', 13, 10,
                                             '  - b', 13, 10,
                                             '- - c', 13, 10,
                                             '  - d', 13, 10,
                                             '  - e', 13, 10"
    YAML_QUERY_STRING_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Empty strings
    YAML_QUERY_STRING_ARRAY_TEST_YAML[5] = "'items:', 13, 10,
                                             '  - ""', 13, 10,
                                             '  - ""', 13, 10,
                                             '  - ""', 13, 10"
    YAML_QUERY_STRING_ARRAY_TEST_QUERY[5] = '.items'

    // Test 6: Quoted strings
    YAML_QUERY_STRING_ARRAY_TEST_YAML[6] = "'values:', 13, 10,
                                             '  - "hello"', 13, 10,
                                             '  - "world"', 13, 10"
    YAML_QUERY_STRING_ARRAY_TEST_QUERY[6] = '.values'

    // Test 7: Mixed quoted/unquoted
    YAML_QUERY_STRING_ARRAY_TEST_YAML[7] = "'- one', 13, 10,
                                             '- "two"', 13, 10,
                                             '- three', 13, 10,
                                             '- "four"', 13, 10,
                                             '- five', 13, 10"
    YAML_QUERY_STRING_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty sequence
    YAML_QUERY_STRING_ARRAY_TEST_YAML[8] = "'empty: []', 13, 10"
    YAML_QUERY_STRING_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single element sequence
    YAML_QUERY_STRING_ARRAY_TEST_YAML[9] = "'single:', 13, 10,
                                             '  - only', 13, 10"
    YAML_QUERY_STRING_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Sequence property after sequence index
    YAML_QUERY_STRING_ARRAY_TEST_YAML[10] = "'groups:', 13, 10,
                                              '  - items:', 13, 10,
                                              '    - x', 13, 10,
                                              '    - y', 13, 10,
                                              '  - items:', 13, 10,
                                              '    - a', 13, 10,
                                              '    - b', 13, 10"
    YAML_QUERY_STRING_ARRAY_TEST_QUERY[10] = '.groups[2].items'

    set_length_array(YAML_QUERY_STRING_ARRAY_TEST_YAML, 10)
    set_length_array(YAML_QUERY_STRING_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer YAML_QUERY_STRING_ARRAY_EXPECTED_COUNT[10] = {
    3,  // Test 1
    3,  // Test 2
    3,  // Test 3
    3,  // Test 4
    3,  // Test 5
    2,  // Test 6
    5,  // Test 7
    0,  // Test 8 (empty)
    1,  // Test 9
    2   // Test 10
}

constant char YAML_QUERY_STRING_ARRAY_EXPECTED[10][5][32] = {
    {'first', 'second', 'third'},                // Test 1
    {'Alice', 'Bob', 'Charlie'},                 // Test 2
    {'admin', 'developer', 'tester'},            // Test 3
    {'c', 'd', 'e'},                             // Test 4
    {'', '', ''},                                // Test 5
    {'hello', 'world'},                          // Test 6
    {'one', 'two', 'three', 'four', 'five'},     // Test 7
    {''},                                        // Test 8 (empty)
    {'only'},                                    // Test 9
    {'a', 'b'}                                   // Test 10
}


define_function TestNAVYamlQueryStringArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryStringArray'")

    InitializeYamlQueryStringArrayTestData()

    for (x = 1; x <= length_array(YAML_QUERY_STRING_ARRAY_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var char result[100][256]
        stack_var integer i
        stack_var char failed

        if (!NAVYamlParse(YAML_QUERY_STRING_ARRAY_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQueryStringArray(yaml, YAML_QUERY_STRING_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   YAML_QUERY_STRING_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(YAML_QUERY_STRING_ARRAY_EXPECTED_COUNT[x]),
                            itoa(length_array(result)))
            continue
        }

        for (i = 1; i <= length_array(result); i++) {
            if (!NAVAssertStringEqual("'Array element ', itoa(i)",
                              YAML_QUERY_STRING_ARRAY_EXPECTED[x][i],
                              result[i])) {
                NAVLogTestFailed(x,
                                "'Element ', itoa(i), ': ', YAML_QUERY_STRING_ARRAY_EXPECTED[x][i]",
                                "'Element ', itoa(i), ': ', result[i]")
                failed = true
                continue
            }
        }

        if (failed) {
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQueryStringArray'")
}

