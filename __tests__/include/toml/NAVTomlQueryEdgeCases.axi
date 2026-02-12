PROGRAM_NAME='NAVTomlQueryEdgeCases'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_EDGE_CASE_TEST_TOML[10][512]
volatile char TOML_QUERY_EDGE_CASE_TEST_QUERY[10][128]


define_function InitializeTomlQueryEdgeCaseTestData() {
    // Test 1: Query non-existent property
    TOML_QUERY_EDGE_CASE_TEST_TOML[1] = 'name = "John"'
    TOML_QUERY_EDGE_CASE_TEST_QUERY[1] = '.age'

    // Test 2: Array index out of bounds (high)
    TOML_QUERY_EDGE_CASE_TEST_TOML[2] = 'items = [1, 2, 3]'
    TOML_QUERY_EDGE_CASE_TEST_QUERY[2] = '.items[5]'

    // Test 3: Query property on array (type mismatch)
    TOML_QUERY_EDGE_CASE_TEST_TOML[3] = 'items = [1, 2, 3]'
    TOML_QUERY_EDGE_CASE_TEST_QUERY[3] = '.items.property'

    // Test 4: Query array index on table (type mismatch)
    TOML_QUERY_EDGE_CASE_TEST_TOML[4] = "'[data]', $0A, 'name = "John"'"
    TOML_QUERY_EDGE_CASE_TEST_QUERY[4] = '.data[1]'

    // Test 5: Path continues after primitive value
    TOML_QUERY_EDGE_CASE_TEST_TOML[5] = "'[user]', $0A, 'name = "Jane"'"
    TOML_QUERY_EDGE_CASE_TEST_QUERY[5] = '.user.name.invalid'

    // Test 6: Nested property doesn't exist
    TOML_QUERY_EDGE_CASE_TEST_TOML[6] = "'[user]', $0A, 'name = "Jane"'"
    TOML_QUERY_EDGE_CASE_TEST_QUERY[6] = '.user.age'

    // Test 7: Query on empty table
    TOML_QUERY_EDGE_CASE_TEST_TOML[7] = "'[empty]'"
    TOML_QUERY_EDGE_CASE_TEST_QUERY[7] = '.empty.property'

    // Test 8: Array index zero (1-based indexing)
    TOML_QUERY_EDGE_CASE_TEST_TOML[8] = 'items = [1, 2, 3]'
    TOML_QUERY_EDGE_CASE_TEST_QUERY[8] = '.items[0]'

    // Test 9: Property after array index out of bounds
    TOML_QUERY_EDGE_CASE_TEST_TOML[9] = "'[[items]]', $0A, 'id = 1'"
    TOML_QUERY_EDGE_CASE_TEST_QUERY[9] = '.items[5].id'

    // Test 10: Query property in non-existent table
    TOML_QUERY_EDGE_CASE_TEST_TOML[10] = "'[config]', $0A, 'setting = 1'"
    TOML_QUERY_EDGE_CASE_TEST_QUERY[10] = '.data.missing'

    set_length_array(TOML_QUERY_EDGE_CASE_TEST_TOML, 10)
    set_length_array(TOML_QUERY_EDGE_CASE_TEST_QUERY, 10)
}


DEFINE_CONSTANT

// Expected: all queries should fail (return false)
constant char TOML_QUERY_EDGE_CASE_EXPECTED_SUCCESS[10] = {
    false, // Test 1: Property doesn't exist
    false, // Test 2: Index out of bounds
    false, // Test 3: Wrong type (array vs table)
    false, // Test 4: Wrong type (table vs array)
    false, // Test 5: Can't query on string
    false, // Test 6: Nested property missing
    false, // Test 7: Property doesn't exist in empty table
    false, // Test 8: Index 0 invalid (1-based)
    false, // Test 9: Index out of bounds
    false  // Test 10: Table doesn't exist
}


define_function TestNAVTomlQueryEdgeCases() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQueryEdgeCases'")

    InitializeTomlQueryEdgeCaseTestData()

    for (x = 1; x <= length_array(TOML_QUERY_EDGE_CASE_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var _NAVTomlNode result
        stack_var char querySuccess

        if (!NAVTomlParse(TOML_QUERY_EDGE_CASE_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        querySuccess = NAVTomlQuery(toml, TOML_QUERY_EDGE_CASE_TEST_QUERY[x], result)

        if (!NAVAssertBooleanEqual('NAVTomlQuery edge case',
                                   TOML_QUERY_EDGE_CASE_EXPECTED_SUCCESS[x],
                                   querySuccess)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_QUERY_EDGE_CASE_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(querySuccess))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlQueryEdgeCases'")
}
