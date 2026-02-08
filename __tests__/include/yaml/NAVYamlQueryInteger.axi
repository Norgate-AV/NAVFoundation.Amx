PROGRAM_NAME='NAVYamlQueryInteger'

DEFINE_VARIABLE

volatile char YAML_QUERY_INTEGER_TEST_YAML[10][512]
volatile char YAML_QUERY_INTEGER_TEST_QUERY[10][64]


define_function InitializeYamlQueryIntegerTestData() {
    // Test 1: Simple root number
    YAML_QUERY_INTEGER_TEST_YAML[1] = '42'
    YAML_QUERY_INTEGER_TEST_QUERY[1] = '.'

    // Test 2: Mapping property
    YAML_QUERY_INTEGER_TEST_YAML[2] = "'channel: 101', 13, 10"
    YAML_QUERY_INTEGER_TEST_QUERY[2] = '.channel'

    // Test 3: Nested mapping property
    YAML_QUERY_INTEGER_TEST_YAML[3] = "'device:', 13, 10,
                                        '  id: 128', 13, 10"
    YAML_QUERY_INTEGER_TEST_QUERY[3] = '.device.id'

    // Test 4: Sequence element
    YAML_QUERY_INTEGER_TEST_YAML[4] = "'- 100', 13, 10,
                                        '- 200', 13, 10,
                                        '- 300', 13, 10"
    YAML_QUERY_INTEGER_TEST_QUERY[4] = '.[2]'

    // Test 5: Mapping in sequence
    YAML_QUERY_INTEGER_TEST_YAML[5] = "'- port: 80', 13, 10,
                                        '- port: 443', 13, 10,
                                        '- port: 8080', 13, 10"
    YAML_QUERY_INTEGER_TEST_QUERY[5] = '.[3].port'

    // Test 6: Deeply nested property
    YAML_QUERY_INTEGER_TEST_YAML[6] = "'config:', 13, 10,
                                        '  network:', 13, 10,
                                        '    timeout: 5000', 13, 10"
    YAML_QUERY_INTEGER_TEST_QUERY[6] = '.config.network.timeout'

    // Test 7: Zero value
    YAML_QUERY_INTEGER_TEST_YAML[7] = "'count: 0', 13, 10"
    YAML_QUERY_INTEGER_TEST_QUERY[7] = '.count'

    // Test 8: Maximum 16-bit value
    YAML_QUERY_INTEGER_TEST_YAML[8] = "'maxValue: 65535', 13, 10"
    YAML_QUERY_INTEGER_TEST_QUERY[8] = '.maxValue'

    // Test 9: Float to integer conversion (truncates)
    YAML_QUERY_INTEGER_TEST_YAML[9] = "'value: 123.456', 13, 10"
    YAML_QUERY_INTEGER_TEST_QUERY[9] = '.value'

    // Test 10: Property after sequence index
    YAML_QUERY_INTEGER_TEST_YAML[10] = "'devices:', 13, 10,
                                         '  - address: 1', 13, 10,
                                         '  - address: 2', 13, 10"
    YAML_QUERY_INTEGER_TEST_QUERY[10] = '.devices[1].address'

    set_length_array(YAML_QUERY_INTEGER_TEST_YAML, 10)
    set_length_array(YAML_QUERY_INTEGER_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant integer YAML_QUERY_INTEGER_EXPECTED[10] = {
    42,      // Test 1
    101,     // Test 2
    128,     // Test 3
    200,     // Test 4
    8080,    // Test 5
    5000,    // Test 6
    0,       // Test 7
    65535,   // Test 8
    123,     // Test 9 (truncated)
    1        // Test 10
}


define_function TestNAVYamlQueryInteger() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryInteger'")

    InitializeYamlQueryIntegerTestData()

    for (x = 1; x <= length_array(YAML_QUERY_INTEGER_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var integer result

        if (!NAVYamlParse(YAML_QUERY_INTEGER_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQueryInteger(yaml, YAML_QUERY_INTEGER_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertIntegerEqual('NAVYamlQueryInteger value',
                                   YAML_QUERY_INTEGER_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(YAML_QUERY_INTEGER_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQueryInteger'")
}

