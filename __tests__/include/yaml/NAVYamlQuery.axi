PROGRAM_NAME='NAVYamlQuery'

DEFINE_VARIABLE

volatile char YAML_QUERY_TEST_YAML[10][512]
volatile char YAML_QUERY_TEST_QUERY[10][64]


define_function InitializeYamlQueryTestData() {
    // Test 1: Root mapping
    YAML_QUERY_TEST_YAML[1] = "'name: John', 13, 10,
                               'age: 30', 13, 10"
    YAML_QUERY_TEST_QUERY[1] = '.'

    // Test 2: Nested mapping
    YAML_QUERY_TEST_YAML[2] = "'user:', 13, 10,
                               '  id: 123', 13, 10,
                               '  name: Jane', 13, 10"
    YAML_QUERY_TEST_QUERY[2] = '.user'

    // Test 3: Deeply nested mapping
    YAML_QUERY_TEST_YAML[3] = "'data:', 13, 10,
                               '  config:', 13, 10,
                               '    settings:', 13, 10,
                               '      timeout: 5000', 13, 10"
    YAML_QUERY_TEST_QUERY[3] = '.data.config.settings'

    // Test 4: Root sequence
    YAML_QUERY_TEST_YAML[4] = "'- 1', 13, 10,
                               '- 2', 13, 10,
                               '- 3', 13, 10,
                               '- 4', 13, 10,
                               '- 5', 13, 10"
    YAML_QUERY_TEST_QUERY[4] = '.'

    // Test 5: Sequence property
    YAML_QUERY_TEST_YAML[5] = "'items:', 13, 10,
                               '  - id: 1', 13, 10,
                               '  - id: 2', 13, 10,
                               '  - id: 3', 13, 10"
    YAML_QUERY_TEST_QUERY[5] = '.items'

    // Test 6: Mapping in sequence
    YAML_QUERY_TEST_YAML[6] = "'- name: Alice', 13, 10,
                               '  age: 25', 13, 10,
                               '- name: Bob', 13, 10,
                               '  age: 30', 13, 10"
    YAML_QUERY_TEST_QUERY[6] = '.[1]'

    // Test 7: Nested mapping in sequence
    YAML_QUERY_TEST_YAML[7] = "'users:', 13, 10,
                               '  - profile:', 13, 10,
                               '    name: Charlie', 13, 10,
                               '  - profile:', 13, 10,
                               '    name: David', 13, 10"
    YAML_QUERY_TEST_QUERY[7] = '.users[1].profile'

    // Test 8: Sequence in nested mapping
    YAML_QUERY_TEST_YAML[8] = "'response:', 13, 10,
                               '  data:', 13, 10,
                               '    records:', 13, 10,
                               '      - 10', 13, 10,
                               '      - 20', 13, 10,
                               '      - 30', 13, 10"
    YAML_QUERY_TEST_QUERY[8] = '.response.data.records'

    // Test 9: Empty mapping
    YAML_QUERY_TEST_YAML[9] = "'empty: {}', 13, 10"
    YAML_QUERY_TEST_QUERY[9] = '.empty'

    // Test 10: Empty sequence
    YAML_QUERY_TEST_YAML[10] = "'list: []', 13, 10"
    YAML_QUERY_TEST_QUERY[10] = '.list'

    set_length_array(YAML_QUERY_TEST_YAML, 10)
    set_length_array(YAML_QUERY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

// Expected node types
constant integer YAML_QUERY_EXPECTED_TYPE[10] = {
    NAV_YAML_TYPE_MAP,  // Test 1
    NAV_YAML_TYPE_MAP,  // Test 2
    NAV_YAML_TYPE_MAP,  // Test 3
    NAV_YAML_TYPE_SEQ,  // Test 4
    NAV_YAML_TYPE_SEQ,  // Test 5
    NAV_YAML_TYPE_MAP,  // Test 6
    NAV_YAML_TYPE_MAP,  // Test 7
    NAV_YAML_TYPE_SEQ,  // Test 8
    NAV_YAML_TYPE_MAP,  // Test 9
    NAV_YAML_TYPE_SEQ   // Test 10
}


define_function TestNAVYamlQuery() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQuery'")

    InitializeYamlQueryTestData()

    for (x = 1; x <= length_array(YAML_QUERY_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode result

        if (!NAVYamlParse(YAML_QUERY_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQuery(yaml, YAML_QUERY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Validate node type
        select {
            active (YAML_QUERY_EXPECTED_TYPE[x] == NAV_YAML_TYPE_MAP): {
                if (!NAVYamlIsMapping(result)) {
                    NAVLogTestFailed(x, 'Node type: MAPPING', "'Node type: ', NAVYamlGetNodeType(result.type)")
                    continue
                }
            }
            active (YAML_QUERY_EXPECTED_TYPE[x] == NAV_YAML_TYPE_SEQ): {
                if (!NAVYamlIsSequence(result)) {
                    NAVLogTestFailed(x, 'Node type: SEQUENCE', "'Node type: ', NAVYamlGetNodeType(result.type)")
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQuery'")
}
