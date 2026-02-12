PROGRAM_NAME='NAVYamlQueryString'

DEFINE_VARIABLE

volatile char YAML_QUERY_STRING_TEST_YAML[10][512]
volatile char YAML_QUERY_STRING_TEST_QUERY[10][64]


define_function InitializeYamlQueryStringTestData() {
    // Test 1: Simple root string
    YAML_QUERY_STRING_TEST_YAML[1] = 'hello'
    YAML_QUERY_STRING_TEST_QUERY[1] = '.'

    // Test 2: Mapping property
    YAML_QUERY_STRING_TEST_YAML[2] = "'name: John', 13, 10"
    YAML_QUERY_STRING_TEST_QUERY[2] = '.name'

    // Test 3: Nested mapping property
    YAML_QUERY_STRING_TEST_YAML[3] = "'user:', 13, 10,
                                      '  name: Jane', 13, 10"
    YAML_QUERY_STRING_TEST_QUERY[3] = '.user.name'

    // Test 4: Sequence element
    YAML_QUERY_STRING_TEST_YAML[4] = "'- first', 13, 10,
                                      '- second', 13, 10,
                                      '- third', 13, 10"
    YAML_QUERY_STRING_TEST_QUERY[4] = '.[2]'

    // Test 5: Mapping in sequence
    YAML_QUERY_STRING_TEST_YAML[5] = "'- title: A', 13, 10,
                                      '- title: B', 13, 10,
                                      '- title: C', 13, 10"
    YAML_QUERY_STRING_TEST_QUERY[5] = '.[3].title'

    // Test 6: Empty string value
    YAML_QUERY_STRING_TEST_YAML[6] = "'value: ""', 13, 10"
    YAML_QUERY_STRING_TEST_QUERY[6] = '.value'

    // Test 7: String with special characters
    YAML_QUERY_STRING_TEST_YAML[7] = "'text: "Hello\nWorld"', 13, 10"
    YAML_QUERY_STRING_TEST_QUERY[7] = '.text'

    // Test 8: Deeply nested property
    YAML_QUERY_STRING_TEST_YAML[8] = "'config:', 13, 10,
                                      '  server:', 13, 10,
                                      '    host: localhost', 13, 10"
    YAML_QUERY_STRING_TEST_QUERY[8] = '.config.server.host'

    // Test 9: Property after sequence index
    YAML_QUERY_STRING_TEST_YAML[9] = "'items:', 13, 10,
                                      '  - label: Item1', 13, 10,
                                      '  - label: Item2', 13, 10"
    YAML_QUERY_STRING_TEST_QUERY[9] = '.items[1].label'

    // Test 10: Multiple nested levels
    YAML_QUERY_STRING_TEST_YAML[10] = "'data:', 13, 10,
                                       '  users:', 13, 10,
                                       '    - name: Alice', 13, 10,
                                       '    - name: Bob', 13, 10"
    YAML_QUERY_STRING_TEST_QUERY[10] = '.data.users[2].name'

    set_length_array(YAML_QUERY_STRING_TEST_YAML, 10)
    set_length_array(YAML_QUERY_STRING_TEST_QUERY, 10)
}


DEFINE_CONSTANT

constant char YAML_QUERY_STRING_EXPECTED[10][64] = {
    'hello',       // Test 1
    'John',        // Test 2
    'Jane',        // Test 3
    'second',      // Test 4
    'C',           // Test 5
    '',            // Test 6: Empty string
    {'H', 'e', 'l', 'l', 'o', $0A, 'W', 'o', 'r', 'l', 'd'},  // Test 7
    'localhost',   // Test 8
    'Item1',       // Test 9
    'Bob'          // Test 10
}


define_function TestNAVYamlQueryString() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryString'")

    InitializeYamlQueryStringTestData()

    for (x = 1; x <= length_array(YAML_QUERY_STRING_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var char result[256]

        if (!NAVYamlParse(YAML_QUERY_STRING_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlQueryString(yaml, YAML_QUERY_STRING_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        if (!NAVAssertStringEqual('NAVYamlQueryString value',
                                  YAML_QUERY_STRING_EXPECTED[x],
                                  result)) {
            NAVLogTestFailed(x,
                            YAML_QUERY_STRING_EXPECTED[x],
                            result)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQueryString'")
}
