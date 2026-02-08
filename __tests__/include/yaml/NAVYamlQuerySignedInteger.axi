PROGRAM_NAME='NAVYamlQuerySignedInteger'

DEFINE_VARIABLE

volatile char YAML_QUERY_SINTEGER_TEST_YAML[10][512]
volatile char YAML_QUERY_SINTEGER_TEST_QUERY[10][64]


define_function InitializeYamlQuerySignedIntegerTestData() {
    // Test 1: Positive value
    YAML_QUERY_SINTEGER_TEST_YAML[1] = '42'
    YAML_QUERY_SINTEGER_TEST_QUERY[1] = '.'

    // Test 2: Negative value
    YAML_QUERY_SINTEGER_TEST_YAML[2] = "'temperature: -15', 13, 10"
    YAML_QUERY_SINTEGER_TEST_QUERY[2] = '.temperature'

    // Test 3: Nested negative value
    YAML_QUERY_SINTEGER_TEST_YAML[3] = "'sensor:', 13, 10,
                                         '  offset: -100', 13, 10"
    YAML_QUERY_SINTEGER_TEST_QUERY[3] = '.sensor.offset'

    // Test 4: Sequence with negative
    YAML_QUERY_SINTEGER_TEST_YAML[4] = "'- -10', 13, 10,
                                         '- -20', 13, 10,
                                         '- -30', 13, 10"
    YAML_QUERY_SINTEGER_TEST_QUERY[4] = '.[2]'

    // Test 5: Mapping in sequence with negative
    YAML_QUERY_SINTEGER_TEST_YAML[5] = "'- delta: -5', 13, 10,
                                         '- delta: -10', 13, 10,
                                         '- delta: -15', 13, 10"
    YAML_QUERY_SINTEGER_TEST_QUERY[5] = '.[3].delta'

    // Test 6: Deeply nested negative
    YAML_QUERY_SINTEGER_TEST_YAML[6] = "'data:', 13, 10,
                                         '  calibration:', 13, 10,
                                         '    adjustment: -50', 13, 10"
    YAML_QUERY_SINTEGER_TEST_QUERY[6] = '.data.calibration.adjustment'

    // Test 7: Zero value
    YAML_QUERY_SINTEGER_TEST_YAML[7] = "'baseline: 0', 13, 10"
    YAML_QUERY_SINTEGER_TEST_QUERY[7] = '.baseline'

    // Test 8: Maximum positive value
    YAML_QUERY_SINTEGER_TEST_YAML[8] = "'maxValue: 32767', 13, 10"
    YAML_QUERY_SINTEGER_TEST_QUERY[8] = '.maxValue'

    // Test 9: Maximum negative value
    YAML_QUERY_SINTEGER_TEST_YAML[9] = "'minValue: -32768', 13, 10"
    YAML_QUERY_SINTEGER_TEST_QUERY[9] = '.minValue'

    // Test 10: Property after sequence index
    YAML_QUERY_SINTEGER_TEST_YAML[10] = "'readings:', 13, 10,
                                          '  - value: -123', 13, 10,
                                          '  - value: 456', 13, 10"
    YAML_QUERY_SINTEGER_TEST_QUERY[10] = '.readings[1].value'

    set_length_array(YAML_QUERY_SINTEGER_TEST_YAML, 10)
    set_length_array(YAML_QUERY_SINTEGER_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant sinteger YAML_QUERY_SINTEGER_EXPECTED[10] = {
    42,      // Test 1
    -15,     // Test 2
    -100,    // Test 3
    -20,     // Test 4
    -15,     // Test 5
    -50,     // Test 6
    0,       // Test 7
    32767,   // Test 8
    -32768,  // Test 9
    -123     // Test 10
}


define_function TestNAVYamlQuerySignedInteger() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQuerySignedInteger'")

    InitializeYamlQuerySignedIntegerTestData()

    for (x = 1; x <= length_array(YAML_QUERY_SINTEGER_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var sinteger result

        if (!NAVYamlParse(YAML_QUERY_SINTEGER_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQuerySignedInteger(yaml, YAML_QUERY_SINTEGER_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertSignedIntegerEqual('NAVYamlQuerySignedInteger value',
                                         YAML_QUERY_SINTEGER_EXPECTED[x],
                                         result)) {
            NAVLogTestFailed(x,
                            itoa(YAML_QUERY_SINTEGER_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQuerySignedInteger'")
}

