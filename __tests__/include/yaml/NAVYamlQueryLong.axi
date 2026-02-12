PROGRAM_NAME='NAVYamlQueryLong'

DEFINE_VARIABLE

volatile char YAML_QUERY_LONG_TEST_YAML[10][512]
volatile char YAML_QUERY_LONG_TEST_QUERY[10][64]


define_function InitializeYamlQueryLongTestData() {
    // Test 1: Simple value
    YAML_QUERY_LONG_TEST_YAML[1] = '100000'
    YAML_QUERY_LONG_TEST_QUERY[1] = '.'

    // Test 2: Mapping property
    YAML_QUERY_LONG_TEST_YAML[2] = "'timestamp: 1609459200', 13, 10"
    YAML_QUERY_LONG_TEST_QUERY[2] = '.timestamp'

    // Test 3: Nested mapping property
    YAML_QUERY_LONG_TEST_YAML[3] = "'data:', 13, 10,
                                     '  bytes: 2147483647', 13, 10"
    YAML_QUERY_LONG_TEST_QUERY[3] = '.data.bytes'

    // Test 4: Sequence element
    YAML_QUERY_LONG_TEST_YAML[4] = "'- 1000000', 13, 10,
                                     '- 2000000', 13, 10,
                                     '- 3000000', 13, 10"
    YAML_QUERY_LONG_TEST_QUERY[4] = '.[2]'

    // Test 5: Mapping in sequence
    YAML_QUERY_LONG_TEST_YAML[5] = "'- size: 100000', 13, 10,
                                     '- size: 200000', 13, 10,
                                     '- size: 300000', 13, 10"
    YAML_QUERY_LONG_TEST_QUERY[5] = '.[3].size'

    // Test 6: Deeply nested property
    YAML_QUERY_LONG_TEST_YAML[6] = "'system:', 13, 10,
                                     '  memory:', 13, 10,
                                     '    total: 4294967295', 13, 10"
    YAML_QUERY_LONG_TEST_QUERY[6] = '.system.memory.total'

    // Test 7: Zero value
    YAML_QUERY_LONG_TEST_YAML[7] = "'counter: 0', 13, 10"
    YAML_QUERY_LONG_TEST_QUERY[7] = '.counter'

    // Test 8: Large value
    YAML_QUERY_LONG_TEST_YAML[8] = "'fileSize: 999999999', 13, 10"
    YAML_QUERY_LONG_TEST_QUERY[8] = '.fileSize'

    // Test 9: Float to long conversion (truncates)
    YAML_QUERY_LONG_TEST_YAML[9] = "'value: 123456.789', 13, 10"
    YAML_QUERY_LONG_TEST_QUERY[9] = '.value'

    // Test 10: Property after sequence index
    YAML_QUERY_LONG_TEST_YAML[10] = "'records:', 13, 10,
                                      '  - id: 1000000', 13, 10,
                                      '  - id: 2000000', 13, 10"
    YAML_QUERY_LONG_TEST_QUERY[10] = '.records[1].id'

    set_length_array(YAML_QUERY_LONG_TEST_YAML, 10)
    set_length_array(YAML_QUERY_LONG_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant long YAML_QUERY_LONG_EXPECTED[10] = {
    100000,      // Test 1
    1609459200,  // Test 2
    2147483647,  // Test 3
    2000000,     // Test 4
    300000,      // Test 5
    4294967295,  // Test 6
    0,           // Test 7
    999999999,   // Test 8
    123456,      // Test 9 (truncated)
    1000000      // Test 10
}


define_function TestNAVYamlQueryLong() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryLong'")

    InitializeYamlQueryLongTestData()

    for (x = 1; x <= length_array(YAML_QUERY_LONG_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var long result

        if (!NAVYamlParse(YAML_QUERY_LONG_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQueryLong(yaml, YAML_QUERY_LONG_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertLongEqual('NAVYamlQueryLong value',
                                YAML_QUERY_LONG_EXPECTED[x],
                                result)) {
            NAVLogTestFailed(x,
                            itoa(YAML_QUERY_LONG_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQueryLong'")
}

