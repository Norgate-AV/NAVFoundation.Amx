PROGRAM_NAME='NAVYamlQuerySignedLong'

DEFINE_VARIABLE

volatile char YAML_QUERY_SLONG_TEST_YAML[10][512]
volatile char YAML_QUERY_SLONG_TEST_QUERY[10][64]


define_function InitializeYamlQuerySignedLongTestData() {
    // Test 1: Positive value
    YAML_QUERY_SLONG_TEST_YAML[1] = '100000'
    YAML_QUERY_SLONG_TEST_QUERY[1] = '.'

    // Test 2: Negative value
    YAML_QUERY_SLONG_TEST_YAML[2] = "'offset: -1000000', 13, 10"
    YAML_QUERY_SLONG_TEST_QUERY[2] = '.offset'

    // Test 3: Nested negative value
    YAML_QUERY_SLONG_TEST_YAML[3] = "'data:', 13, 10,
                                      '  delta: -2147483648', 13, 10"
    YAML_QUERY_SLONG_TEST_QUERY[3] = '.data.delta'

    // Test 4: Sequence with negative
    YAML_QUERY_SLONG_TEST_YAML[4] = "'- -100000', 13, 10,
                                      '- -200000', 13, 10,
                                      '- -300000', 13, 10"
    YAML_QUERY_SLONG_TEST_QUERY[4] = '.[2]'

    // Test 5: Mapping in sequence with negative
    YAML_QUERY_SLONG_TEST_YAML[5] = "'- adjustment: -50000', 13, 10,
                                      '- adjustment: -100000', 13, 10,
                                      '- adjustment: -150000', 13, 10"
    YAML_QUERY_SLONG_TEST_QUERY[5] = '.[3].adjustment'

    // Test 6: Deeply nested negative
    YAML_QUERY_SLONG_TEST_YAML[6] = "'system:', 13, 10,
                                      '  financial:', 13, 10,
                                      '    balance: -999999999', 13, 10"
    YAML_QUERY_SLONG_TEST_QUERY[6] = '.system.financial.balance'

    // Test 7: Zero value
    YAML_QUERY_SLONG_TEST_YAML[7] = "'baseline: 0', 13, 10"
    YAML_QUERY_SLONG_TEST_QUERY[7] = '.baseline'

    // Test 8: Maximum positive value
    YAML_QUERY_SLONG_TEST_YAML[8] = "'maxValue: 2147483647', 13, 10"
    YAML_QUERY_SLONG_TEST_QUERY[8] = '.maxValue'

    // Test 9: Maximum negative value
    YAML_QUERY_SLONG_TEST_YAML[9] = "'minValue: -2147483648', 13, 10"
    YAML_QUERY_SLONG_TEST_QUERY[9] = '.minValue'

    // Test 10: Property after sequence index
    YAML_QUERY_SLONG_TEST_YAML[10] = "'transactions:', 13, 10,
                                       '  - amount: -123456', 13, 10,
                                       '  - amount: 789012', 13, 10"
    YAML_QUERY_SLONG_TEST_QUERY[10] = '.transactions[1].amount'

    set_length_array(YAML_QUERY_SLONG_TEST_YAML, 10)
    set_length_array(YAML_QUERY_SLONG_TEST_QUERY, 10)
}


define_function TestNAVYamlQuerySignedLong() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQuerySignedLong'")

    InitializeYamlQuerySignedLongTestData()

    for (x = 1; x <= length_array(YAML_QUERY_SLONG_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var slong result
        stack_var slong expected

        // NetLinx compiler quirk - SLONG literal negative values
        // The NetLinx compiler does not properly handle literal negative values
        // with SLONG type. To work around this, we initialize expected to 0 and
        // calculate negative values programmatically using subtraction.
        expected = 0

        switch (x) {
            case 1: expected = type_cast(100000)
            case 2: expected = expected - type_cast(1000000)
            case 3: expected = expected - type_cast(2147483648)
            case 4: expected = expected - type_cast(200000)
            case 5: expected = expected - type_cast(150000)
            case 6: expected = expected - type_cast(999999999)
            case 7: expected = 0
            case 8: expected = type_cast(2147483647)
            case 9: expected = expected - type_cast(2147483648)
            case 10: expected = expected - type_cast(123456)
        }

        if (!NAVYamlParse(YAML_QUERY_SLONG_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQuerySignedLong(yaml, YAML_QUERY_SLONG_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertSignedLongEqual('NAVYamlQuerySignedLong value',
                                      expected,
                                      result)) {
            NAVLogTestFailed(x,
                            itoa(expected),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQuerySignedLong'")
}

