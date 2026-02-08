PROGRAM_NAME='NAVYamlQuerySignedLongArray'

DEFINE_VARIABLE

volatile char YAML_QUERY_SLONG_ARRAY_TEST_YAML[10][512]
volatile char YAML_QUERY_SLONG_ARRAY_TEST_QUERY[10][64]


define_function InitializeYamlQuerySignedLongArrayTestData() {
    // Test 1: Simple root sequence with mixed signs
    YAML_QUERY_SLONG_ARRAY_TEST_YAML[1] = "'- -100000', 13, 10,
                                            '- 200000', 13, 10,
                                            '- -300000', 13, 10"
    YAML_QUERY_SLONG_ARRAY_TEST_QUERY[1] = '.'

    // Test 2: Sequence property with negatives
    YAML_QUERY_SLONG_ARRAY_TEST_YAML[2] = "'balances:', 13, 10,
                                            '  - -500000', 13, 10,
                                            '  - 1000000', 13, 10,
                                            '  - -250000', 13, 10"
    YAML_QUERY_SLONG_ARRAY_TEST_QUERY[2] = '.balances'

    // Test 3: Nested sequence property
    YAML_QUERY_SLONG_ARRAY_TEST_YAML[3] = "'financial:', 13, 10,
                                            '  deltas:', 13, 10,
                                            '    - -1000000', 13, 10,
                                            '    - -500000', 13, 10,
                                            '    - 0', 13, 10"
    YAML_QUERY_SLONG_ARRAY_TEST_QUERY[3] = '.financial.deltas'

    // Test 4: Sequence in sequence
    YAML_QUERY_SLONG_ARRAY_TEST_YAML[4] = "'- - -100000', 13, 10,
                                            '  - -200000', 13, 10,
                                            '- - -300000', 13, 10,
                                            '  - -400000', 13, 10,
                                            '  - -500000', 13, 10"
    YAML_QUERY_SLONG_ARRAY_TEST_QUERY[4] = '.[2]'

    // Test 5: Sequence with zeros
    YAML_QUERY_SLONG_ARRAY_TEST_YAML[5] = "'net:', 13, 10,
                                            '  - 0', 13, 10,
                                            '  - 0', 13, 10,
                                            '  - 0', 13, 10"
    YAML_QUERY_SLONG_ARRAY_TEST_QUERY[5] = '.net'

    // Test 6: Large negative values
    YAML_QUERY_SLONG_ARRAY_TEST_YAML[6] = "'losses:', 13, 10,
                                            '  - -2000000000', 13, 10,
                                            '  - -1000000000', 13, 10"
    YAML_QUERY_SLONG_ARRAY_TEST_QUERY[6] = '.losses'

    // Test 7: Extreme values
    YAML_QUERY_SLONG_ARRAY_TEST_YAML[7] = "'- 2147483647', 13, 10,
                                            '- -2147483648', 13, 10"
    YAML_QUERY_SLONG_ARRAY_TEST_QUERY[7] = '.'

    // Test 8: Empty sequence
    YAML_QUERY_SLONG_ARRAY_TEST_YAML[8] = "'empty: []', 13, 10"
    YAML_QUERY_SLONG_ARRAY_TEST_QUERY[8] = '.empty'

    // Test 9: Single negative element
    YAML_QUERY_SLONG_ARRAY_TEST_YAML[9] = "'single:', 13, 10,
                                            '  - -10000000', 13, 10"
    YAML_QUERY_SLONG_ARRAY_TEST_QUERY[9] = '.single'

    // Test 10: Sequence property after sequence index
    YAML_QUERY_SLONG_ARRAY_TEST_YAML[10] = "'transactions:', 13, 10,
                                             '  - amounts:', 13, 10,
                                             '    - -100000', 13, 10,
                                             '    - -200000', 13, 10,
                                             '  - amounts:', 13, 10,
                                             '    - -300000', 13, 10,
                                             '    - -400000', 13, 10"
    YAML_QUERY_SLONG_ARRAY_TEST_QUERY[10] = '.transactions[2].amounts'

    set_length_array(YAML_QUERY_SLONG_ARRAY_TEST_YAML, 10)
    set_length_array(YAML_QUERY_SLONG_ARRAY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer YAML_QUERY_SLONG_ARRAY_EXPECTED_COUNT[10] = {
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


define_function TestNAVYamlQuerySignedLongArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQuerySignedLongArray'")

    InitializeYamlQuerySignedLongArrayTestData()

    for (x = 1; x <= length_array(YAML_QUERY_SLONG_ARRAY_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var slong result[100]
        stack_var integer i
        stack_var char failed

        if (!NAVYamlParse(YAML_QUERY_SLONG_ARRAY_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQuerySignedLongArray(yaml, YAML_QUERY_SLONG_ARRAY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('Array length',
                                   YAML_QUERY_SLONG_ARRAY_EXPECTED_COUNT[x],
                                   length_array(result))) {
            NAVLogTestFailed(x,
                            itoa(YAML_QUERY_SLONG_ARRAY_EXPECTED_COUNT[x]),
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
                case 8: {
                    // Empty array, no iterations
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

    NAVLogTestSuiteEnd("'NAVYamlQuerySignedLongArray'")
}

