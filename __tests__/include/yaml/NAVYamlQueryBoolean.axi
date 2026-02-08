PROGRAM_NAME='NAVYamlQueryBoolean'

DEFINE_VARIABLE

volatile char YAML_QUERY_BOOLEAN_TEST_YAML[10][512]
volatile char YAML_QUERY_BOOLEAN_TEST_QUERY[10][64]


define_function InitializeYamlQueryBooleanTestData() {
    // Test 1: Simple root true
    YAML_QUERY_BOOLEAN_TEST_YAML[1] = 'true'
    YAML_QUERY_BOOLEAN_TEST_QUERY[1] = '.'

    // Test 2: Simple root false
    YAML_QUERY_BOOLEAN_TEST_YAML[2] = 'false'
    YAML_QUERY_BOOLEAN_TEST_QUERY[2] = '.'

    // Test 3: Mapping property true
    YAML_QUERY_BOOLEAN_TEST_YAML[3] = "'enabled: true', 13, 10"
    YAML_QUERY_BOOLEAN_TEST_QUERY[3] = '.enabled'

    // Test 4: Mapping property false
    YAML_QUERY_BOOLEAN_TEST_YAML[4] = "'active: false', 13, 10"
    YAML_QUERY_BOOLEAN_TEST_QUERY[4] = '.active'

    // Test 5: Nested mapping property
    YAML_QUERY_BOOLEAN_TEST_YAML[5] = "'settings:', 13, 10,
                                        '  isVisible: yes', 13, 10"
    YAML_QUERY_BOOLEAN_TEST_QUERY[5] = '.settings.isVisible'

    // Test 6: Sequence element
    YAML_QUERY_BOOLEAN_TEST_YAML[6] = "'- on', 13, 10,
                                        '- off', 13, 10,
                                        '- on', 13, 10"
    YAML_QUERY_BOOLEAN_TEST_QUERY[6] = '.[2]'

    // Test 7: Mapping in sequence
    YAML_QUERY_BOOLEAN_TEST_YAML[7] = "'- flag: no', 13, 10,
                                        '- flag: yes', 13, 10,
                                        '- flag: no', 13, 10"
    YAML_QUERY_BOOLEAN_TEST_QUERY[7] = '.[2].flag'

    // Test 8: Deeply nested property
    YAML_QUERY_BOOLEAN_TEST_YAML[8] = "'config:', 13, 10,
                                        '  options:', 13, 10,
                                        '    debug: false', 13, 10"
    YAML_QUERY_BOOLEAN_TEST_QUERY[8] = '.config.options.debug'

    // Test 9: Property after sequence index
    YAML_QUERY_BOOLEAN_TEST_YAML[9] = "'devices:', 13, 10,
                                        '  - online: true', 13, 10,
                                        '  - online: false', 13, 10"
    YAML_QUERY_BOOLEAN_TEST_QUERY[9] = '.devices[1].online'

    // Test 10: Multiple nested levels
    YAML_QUERY_BOOLEAN_TEST_YAML[10] = "'system:', 13, 10,
                                         '  modules:', 13, 10,
                                         '    - enabled: true', 13, 10,
                                         '    - enabled: false', 13, 10"
    YAML_QUERY_BOOLEAN_TEST_QUERY[10] = '.system.modules[2].enabled'

    set_length_array(YAML_QUERY_BOOLEAN_TEST_YAML, 10)
    set_length_array(YAML_QUERY_BOOLEAN_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant char YAML_QUERY_BOOLEAN_EXPECTED[10] = {
    true,  // Test 1
    false, // Test 2
    true,  // Test 3
    false, // Test 4
    true,  // Test 5
    false, // Test 6
    true,  // Test 7
    false, // Test 8
    true,  // Test 9
    false  // Test 10
}


define_function TestNAVYamlQueryBoolean() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryBoolean'")

    InitializeYamlQueryBooleanTestData()

    for (x = 1; x <= length_array(YAML_QUERY_BOOLEAN_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var char result

        if (!NAVYamlParse(YAML_QUERY_BOOLEAN_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQueryBoolean(yaml, YAML_QUERY_BOOLEAN_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertBooleanEqual('NAVYamlQueryBoolean value',
                           YAML_QUERY_BOOLEAN_EXPECTED[x],
                           result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_QUERY_BOOLEAN_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQueryBoolean'")
}

