PROGRAM_NAME='NAVYamlQueryEdgeCases'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_QUERY_EDGE_CASE_TEST_YAML[10][512]
volatile char YAML_QUERY_EDGE_CASE_TEST_QUERY[10][128]


define_function InitializeYamlQueryEdgeCaseTestData() {
    // Test 1: Query non-existent property
    YAML_QUERY_EDGE_CASE_TEST_YAML[1] = "'name: John'"
    YAML_QUERY_EDGE_CASE_TEST_QUERY[1] = '.age'

    // Test 2: Array index out of bounds (high)
    YAML_QUERY_EDGE_CASE_TEST_YAML[2] = "'- 1', 13, 10, '- 2', 13, 10, '- 3'"
    YAML_QUERY_EDGE_CASE_TEST_QUERY[2] = '.[5]'

    // Test 3: Query property on sequence (type mismatch)
    YAML_QUERY_EDGE_CASE_TEST_YAML[3] = "'- 1', 13, 10, '- 2', 13, 10, '- 3'"
    YAML_QUERY_EDGE_CASE_TEST_QUERY[3] = '.property'

    // Test 4: Query array index on mapping (type mismatch)
    YAML_QUERY_EDGE_CASE_TEST_YAML[4] = "'name: John'"
    YAML_QUERY_EDGE_CASE_TEST_QUERY[4] = '.[1]'

    // Test 5: Empty path after valid path
    YAML_QUERY_EDGE_CASE_TEST_YAML[5] = "'user:', 13, 10, '  name: Jane'"
    YAML_QUERY_EDGE_CASE_TEST_QUERY[5] = '.user.name.invalid'

    // Test 6: Nested property doesn't exist
    YAML_QUERY_EDGE_CASE_TEST_YAML[6] = "'user:', 13, 10, '  name: Jane'"
    YAML_QUERY_EDGE_CASE_TEST_QUERY[6] = '.user.age'

    // Test 7: Query on null value
    YAML_QUERY_EDGE_CASE_TEST_YAML[7] = "'value: null'"
    YAML_QUERY_EDGE_CASE_TEST_QUERY[7] = '.value.property'

    // Test 8: Array index zero (1-based indexing)
    YAML_QUERY_EDGE_CASE_TEST_YAML[8] = "'- 1', 13, 10, '- 2', 13, 10, '- 3'"
    YAML_QUERY_EDGE_CASE_TEST_QUERY[8] = '.[0]'

    // Test 9: Property after array index out of bounds
    YAML_QUERY_EDGE_CASE_TEST_YAML[9] = "'items:', 13, 10, '  - id: 1'"
    YAML_QUERY_EDGE_CASE_TEST_QUERY[9] = '.items[5].id'

    // Test 10: Query empty mapping property
    YAML_QUERY_EDGE_CASE_TEST_YAML[10] = "'data: {}'"
    YAML_QUERY_EDGE_CASE_TEST_QUERY[10] = '.data.missing'

    set_length_array(YAML_QUERY_EDGE_CASE_TEST_YAML, 10)
    set_length_array(YAML_QUERY_EDGE_CASE_TEST_QUERY, 10)
}


DEFINE_CONSTANT

// Expected: all queries should fail (return false)
constant char YAML_QUERY_EDGE_CASE_EXPECTED_SUCCESS[10] = {
    false, // Test 1: Property doesn't exist
    false, // Test 2: Index out of bounds
    false, // Test 3: Wrong type (sequence vs mapping)
    false, // Test 4: Wrong type (mapping vs sequence)
    false, // Test 5: Can't query on string
    false, // Test 6: Nested property missing
    false, // Test 7: Can't query on null
    false, // Test 8: Index 0 invalid (1-based)
    false, // Test 9: Index out of bounds
    false  // Test 10: Property doesn't exist in empty mapping
}


define_function TestNAVYamlQueryEdgeCases() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlQueryEdgeCases'")

    InitializeYamlQueryEdgeCaseTestData()

    for (x = 1; x <= length_array(YAML_QUERY_EDGE_CASE_TEST_YAML); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode result
        stack_var char querySuccess

        if (!NAVYamlParse(YAML_QUERY_EDGE_CASE_TEST_YAML[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        querySuccess = NAVYamlQuery(yaml, YAML_QUERY_EDGE_CASE_TEST_QUERY[x], result)

        if (!NAVAssertBooleanEqual('NAVYamlQuery edge case',
                                   YAML_QUERY_EDGE_CASE_EXPECTED_SUCCESS[x],
                                   querySuccess)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_QUERY_EDGE_CASE_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(querySuccess))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlQueryEdgeCases'")
}
