PROGRAM_NAME='NAVYamlQueryFloat'

DEFINE_VARIABLE

volatile char YAML_QUERY_FLOAT_TEST_YAML[10][512]
volatile char YAML_QUERY_FLOAT_TEST_QUERY[10][64]


define_function InitializeYamlQueryFloatTestData() {
    // Test 1: Simple root number
    YAML_QUERY_FLOAT_TEST_YAML[1] = '3.14'
    YAML_QUERY_FLOAT_TEST_QUERY[1] = '.'

    // Test 2: Mapping property
    YAML_QUERY_FLOAT_TEST_YAML[2] = "'temperature: 98.6', 13, 10"
    YAML_QUERY_FLOAT_TEST_QUERY[2] = '.temperature'

    // Test 3: Nested mapping property
    YAML_QUERY_FLOAT_TEST_YAML[3] = "'sensor:', 13, 10,
                                      '  value: 23.5', 13, 10"
    YAML_QUERY_FLOAT_TEST_QUERY[3] = '.sensor.value'

    // Test 4: Sequence element
    YAML_QUERY_FLOAT_TEST_YAML[4] = "'- 1.1', 13, 10,
                                      '- 2.2', 13, 10,
                                      '- 3.3', 13, 10"
    YAML_QUERY_FLOAT_TEST_QUERY[4] = '.[2]'

    // Test 5: Mapping in sequence
    YAML_QUERY_FLOAT_TEST_YAML[5] = "'- price: 19.99', 13, 10,
                                      '- price: 29.99', 13, 10,
                                      '- price: 39.99', 13, 10"
    YAML_QUERY_FLOAT_TEST_QUERY[5] = '.[3].price'

    // Test 6: Zero value
    YAML_QUERY_FLOAT_TEST_YAML[6] = "'balance: 0.0', 13, 10"
    YAML_QUERY_FLOAT_TEST_QUERY[6] = '.balance'

    // Test 7: Negative value
    YAML_QUERY_FLOAT_TEST_YAML[7] = "'offset: -12.5', 13, 10"
    YAML_QUERY_FLOAT_TEST_QUERY[7] = '.offset'

    // Test 8: Deeply nested property
    YAML_QUERY_FLOAT_TEST_YAML[8] = "'config:', 13, 10,
                                      '  graphics:', 13, 10,
                                      '    brightness: 0.75', 13, 10"
    YAML_QUERY_FLOAT_TEST_QUERY[8] = '.config.graphics.brightness'

    // Test 9: Integer to float
    YAML_QUERY_FLOAT_TEST_YAML[9] = "'count: 42', 13, 10"
    YAML_QUERY_FLOAT_TEST_QUERY[9] = '.count'

    // Test 10: Property after sequence index
    YAML_QUERY_FLOAT_TEST_YAML[10] = "'readings:', 13, 10,
                                       '  - value: 12.34', 13, 10,
                                       '  - value: 56.78', 13, 10"
    YAML_QUERY_FLOAT_TEST_QUERY[10] = '.readings[2].value'

    set_length_array(YAML_QUERY_FLOAT_TEST_YAML, 10)
    set_length_array(YAML_QUERY_FLOAT_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant float YAML_QUERY_FLOAT_EXPECTED[10] = {
    3.14,    // Test 1
    98.6,    // Test 2
    23.5,    // Test 3
    2.2,     // Test 4
    39.99,   // Test 5
    0.0,     // Test 6
    -12.5,   // Test 7
    0.75,    // Test 8
    42.0,    // Test 9
    56.78    // Test 10
}


define_function TestNAVYamlQueryFloat() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryFloat'")

    InitializeYamlQueryFloatTestData()

    for (x = 1; x <= length_array(YAML_QUERY_FLOAT_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var float result

        if (!NAVYamlParse(YAML_QUERY_FLOAT_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQueryFloat(yaml, YAML_QUERY_FLOAT_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertFloatEqual('NAVYamlQueryFloat value',
                                 YAML_QUERY_FLOAT_EXPECTED[x],
                                 result)) {
            NAVLogTestFailed(x,
                            ftoa(YAML_QUERY_FLOAT_EXPECTED[x]),
                            ftoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQueryFloat'")
}

