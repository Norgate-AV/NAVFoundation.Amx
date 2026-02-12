PROGRAM_NAME='NAVTomlQuery'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_QUERY_TEST_TOML[10][512]
volatile char TOML_QUERY_TEST_QUERY[10][64]


define_function InitializeTomlQueryTestData() {
    // Test 1: Root table
    TOML_QUERY_TEST_TOML[1] = "'name = "John"', 13, 10,
                               'age = 30', 13, 10"
    TOML_QUERY_TEST_QUERY[1] = '.'

    // Test 2: Nested table
    TOML_QUERY_TEST_TOML[2] = "'[user]', 13, 10,
                               'id = 123', 13, 10,
                               'name = "Jane"', 13, 10"
    TOML_QUERY_TEST_QUERY[2] = '.user'

    // Test 3: Deeply nested table
    TOML_QUERY_TEST_TOML[3] = "'[data]', 13, 10,
                               '[data.config]', 13, 10,
                               '[data.config.settings]', 13, 10,
                               'timeout = 5000', 13, 10"
    TOML_QUERY_TEST_QUERY[3] = '.data.config.settings'

    // Test 4: Root array
    TOML_QUERY_TEST_TOML[4] = 'values = [1, 2, 3, 4, 5]'
    TOML_QUERY_TEST_QUERY[4] = '.values'

    // Test 5: Array of tables
    TOML_QUERY_TEST_TOML[5] = "'[[items]]', 13, 10,
                               'id = 1', 13, 10,
                               13, 10,
                               '[[items]]', 13, 10,
                               'id = 2', 13, 10,
                               13, 10,
                               '[[items]]', 13, 10,
                               'id = 3', 13, 10"
    TOML_QUERY_TEST_QUERY[5] = '.items'

    // Test 6: Table in array of tables
    TOML_QUERY_TEST_TOML[6] = "'[[person]]', 13, 10,
                               'name = "Alice"', 13, 10,
                               'age = 25', 13, 10,
                               13, 10,
                               '[[person]]', 13, 10,
                               'name = "Bob"', 13, 10,
                               'age = 30', 13, 10"
    TOML_QUERY_TEST_QUERY[6] = '.person[1]'

    // Test 7: Nested table in array of tables
    TOML_QUERY_TEST_TOML[7] = "'[[users]]', 13, 10,
                               'profile.name = "Charlie"', 13, 10,
                               13, 10,
                               '[[users]]', 13, 10,
                               'profile.name = "David"', 13, 10"
    TOML_QUERY_TEST_QUERY[7] = '.users[1].profile'

    // Test 8: Array in nested table
    TOML_QUERY_TEST_TOML[8] = "'[response]', 13, 10,
                               '[response.data]', 13, 10,
                               'records = [10, 20, 30]', 13, 10"
    TOML_QUERY_TEST_QUERY[8] = '.response.data.records'

    // Test 9: Empty inline table
    TOML_QUERY_TEST_TOML[9] = 'empty = {}'
    TOML_QUERY_TEST_QUERY[9] = '.empty'

    // Test 10: Empty array
    TOML_QUERY_TEST_TOML[10] = 'list = []'
    TOML_QUERY_TEST_QUERY[10] = '.list'

    set_length_array(TOML_QUERY_TEST_TOML, 10)
    set_length_array(TOML_QUERY_TEST_QUERY, 10)
}


DEFINE_CONSTANT

// Expected node types
constant integer TOML_QUERY_EXPECTED_TYPE[10] = {
    NAV_TOML_NODE_TYPE_TABLE,  // Test 1
    NAV_TOML_NODE_TYPE_TABLE,  // Test 2
    NAV_TOML_NODE_TYPE_TABLE,  // Test 3
    NAV_TOML_NODE_TYPE_ARRAY,  // Test 4
    NAV_TOML_NODE_TYPE_TABLE_ARRAY,  // Test 5
    NAV_TOML_NODE_TYPE_TABLE,  // Test 6
    NAV_TOML_NODE_TYPE_TABLE,  // Test 7
    NAV_TOML_NODE_TYPE_ARRAY,  // Test 8
    NAV_TOML_NODE_TYPE_INLINE_TABLE,  // Test 9
    NAV_TOML_NODE_TYPE_ARRAY   // Test 10
}

// Expected child counts (for validation)
constant integer TOML_QUERY_EXPECTED_CHILD_COUNT[10] = {
    2,  // Test 1: {name, age}
    2,  // Test 2: {id, name}
    1,  // Test 3: {timeout}
    5,  // Test 4: [1,2,3,4,5]
    3,  // Test 5: [[items],[items],[items]]
    2,  // Test 6: {name, age}
    1,  // Test 7: {name}
    3,  // Test 8: [10,20,30]
    0,  // Test 9: {} (empty)
    0   // Test 10: [] (empty)
}

// Expected first property key (for tables)
constant char TOML_QUERY_EXPECTED_FIRST_KEY[10][32] = {
    'name',      // Test 1
    'id',        // Test 2
    'timeout',   // Test 3
    '',          // Test 4 (array)
    '',          // Test 5 (array)
    'name',      // Test 6
    'name',      // Test 7
    '',          // Test 8 (array)
    '',          // Test 9 (empty inline table)
    ''           // Test 10 (array)
}


define_function TestNAVTomlQuery() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQuery'")

    InitializeTomlQueryTestData()

    for (x = 1; x <= length_array(TOML_QUERY_TEST_TOML); x++) {
        stack_var _NAVToml toml
        stack_var _NAVTomlNode result
        stack_var _NAVTomlNode firstChild
        stack_var char keyValue[NAV_TOML_PARSER_MAX_KEY_LENGTH]

        if (!NAVTomlParse(TOML_QUERY_TEST_TOML[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQuery(toml, TOML_QUERY_TEST_QUERY[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Validate node type
        select {
            active (TOML_QUERY_EXPECTED_TYPE[x] == NAV_TOML_NODE_TYPE_TABLE): {
                if (!NAVAssertTrue('Node is table', NAVTomlIsTable(result))) {
                    NAVLogTestFailed(x, 'Node type: TABLE', "'Node type: ', NAVTomlGetNodeType(result.type)")
                    continue
                }
            }
            active (TOML_QUERY_EXPECTED_TYPE[x] == NAV_TOML_NODE_TYPE_ARRAY): {
                if (!NAVAssertTrue('Node is array', NAVTomlIsArray(result))) {
                    NAVLogTestFailed(x, 'Node type: ARRAY', "'Node type: ', NAVTomlGetNodeType(result.type)")
                    continue
                }
            }
            active (TOML_QUERY_EXPECTED_TYPE[x] == NAV_TOML_NODE_TYPE_TABLE_ARRAY): {
                if (!NAVAssertIntegerEqual('Node type', NAV_TOML_NODE_TYPE_TABLE_ARRAY, result.type)) {
                    NAVLogTestFailed(x, 'Node type: TABLE_ARRAY', "'Node type: ', NAVTomlGetNodeType(result.type)")
                    continue
                }
            }
            active (TOML_QUERY_EXPECTED_TYPE[x] == NAV_TOML_NODE_TYPE_INLINE_TABLE): {
                if (!NAVAssertTrue('Node is table', NAVTomlIsTable(result))) {
                    NAVLogTestFailed(x, 'Node type: INLINE_TABLE', "'Node type: ', NAVTomlGetNodeType(result.type)")
                    continue
                }
            }
        }

        // Validate child count
        if (!NAVAssertIntegerEqual('Child count',
                                   TOML_QUERY_EXPECTED_CHILD_COUNT[x],
                                   NAVTomlGetChildCount(result))) {
            NAVLogTestFailed(x,
                            "'Expected children: ', itoa(TOML_QUERY_EXPECTED_CHILD_COUNT[x])",
                            "'Got children: ', itoa(NAVTomlGetChildCount(result))")
            continue
        }

        // For non-empty tables, validate first key
        if ((TOML_QUERY_EXPECTED_TYPE[x] == NAV_TOML_NODE_TYPE_TABLE ||
             TOML_QUERY_EXPECTED_TYPE[x] == NAV_TOML_NODE_TYPE_INLINE_TABLE) &&
            TOML_QUERY_EXPECTED_CHILD_COUNT[x] > 0) {

            if (!NAVTomlGetFirstChild(toml, result, firstChild)) {
                NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
                continue
            }

            keyValue = NAVTomlGetKey(firstChild)
            if (!NAVAssertStringEqual('First property key',
                                      TOML_QUERY_EXPECTED_FIRST_KEY[x],
                                      keyValue)) {
                NAVLogTestFailed(x,
                                TOML_QUERY_EXPECTED_FIRST_KEY[x],
                                keyValue)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlQuery'")
}
