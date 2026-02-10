PROGRAM_NAME='NAVTomlQueryBoolean'

#include 'NAVFoundation.Toml.axi'

DEFINE_VARIABLE

volatile char TOML_QUERY_BOOLEAN_INPUT[15][2048]
volatile char TOML_QUERY_BOOLEAN_PATH[15][256]

constant char TOML_QUERY_BOOLEAN_EXPECTED_RESULT[] = {
    true,   // Test 1: True value
    true,   // Test 2: False value
    true,   // Test 3: Nested boolean
    true,   // Test 4: Boolean in array element
    true,   // Test 5: Boolean in inline table
    true,   // Test 6: Boolean in array of tables
    false,  // Test 7: Query string as boolean (should fail)
    false,  // Test 8: Query integer as boolean (should fail)
    false,  // Test 9: Query float as boolean (should fail)
    true,   // Test 10: Multiple booleans
    true,   // Test 11: Dotted key boolean
    true,   // Test 12: Boolean in deep nesting
    false,  // Test 13: Query array as boolean (should fail)
    true,   // Test 14: Mixed document boolean
    true    // Test 15: Complex structure boolean
}

constant char TOML_QUERY_BOOLEAN_EXPECTED_VALUE[] = {
    true,   // Test 1
    false,  // Test 2
    true,   // Test 3
    false,  // Test 4
    true,   // Test 5
    false,  // Test 6
    false,  // Test 7 (not used, fail case)
    false,  // Test 8 (not used, fail case)
    false,  // Test 9 (not used, fail case)
    true,   // Test 10
    false,  // Test 11
    true,   // Test 12
    false,  // Test 13 (not used, fail case)
    true,   // Test 14
    false   // Test 15
}


define_function InitializeTomlQueryBooleanTestData() {
    // Test 1: True value
    TOML_QUERY_BOOLEAN_INPUT[1] = 'enabled = true'
    TOML_QUERY_BOOLEAN_PATH[1] = '.enabled'

    // Test 2: False value
    TOML_QUERY_BOOLEAN_INPUT[2] = 'disabled = false'
    TOML_QUERY_BOOLEAN_PATH[2] = '.disabled'

    // Test 3: Nested boolean
    TOML_QUERY_BOOLEAN_INPUT[3] = "'[server]', 13, 10, 'active = true', 13, 10"
    TOML_QUERY_BOOLEAN_PATH[3] = '.server.active'

    // Test 4: Boolean in array element
    TOML_QUERY_BOOLEAN_INPUT[4] = 'flags = [true, false, true]'
    TOML_QUERY_BOOLEAN_PATH[4] = '.flags[2]'

    // Test 5: Boolean in inline table
    TOML_QUERY_BOOLEAN_INPUT[5] = 'config = { debug = true, verbose = false }'
    TOML_QUERY_BOOLEAN_PATH[5] = '.config.debug'

    // Test 6: Boolean in array of tables
    TOML_QUERY_BOOLEAN_INPUT[6] = "'[[features]]', 13, 10, 'enabled = false', 13, 10"
    TOML_QUERY_BOOLEAN_PATH[6] = '.features[1].enabled'

    // Test 7: Query string as boolean (should fail)
    TOML_QUERY_BOOLEAN_INPUT[7] = 'text = "not a boolean"'
    TOML_QUERY_BOOLEAN_PATH[7] = '.text'

    // Test 8: Query integer as boolean (should fail)
    TOML_QUERY_BOOLEAN_INPUT[8] = 'count = 42'
    TOML_QUERY_BOOLEAN_PATH[8] = '.count'

    // Test 9: Query float as boolean (should fail)
    TOML_QUERY_BOOLEAN_INPUT[9] = 'pi = 3.14'
    TOML_QUERY_BOOLEAN_PATH[9] = '.pi'

    // Test 10: Multiple booleans
    TOML_QUERY_BOOLEAN_INPUT[10] = "'first = true', 13, 10, 'second = false', 13, 10, 'third = true', 13, 10"
    TOML_QUERY_BOOLEAN_PATH[10] = '.third'

    // Test 11: Dotted key boolean
    TOML_QUERY_BOOLEAN_INPUT[11] = 'settings.cache.enabled = false'
    TOML_QUERY_BOOLEAN_PATH[11] = '.settings.cache.enabled'

    // Test 12: Boolean in deep nesting
    TOML_QUERY_BOOLEAN_INPUT[12] = "'[a]', 13, 10, '[a.b]', 13, 10, '[a.b.c]', 13, 10, 'flag = true', 13, 10"
    TOML_QUERY_BOOLEAN_PATH[12] = '.a.b.c.flag'

    // Test 13: Query array as boolean (should fail)
    TOML_QUERY_BOOLEAN_INPUT[13] = 'arr = [true, false]'
    TOML_QUERY_BOOLEAN_PATH[13] = '.arr'

    // Test 14: Mixed document boolean
    TOML_QUERY_BOOLEAN_INPUT[14] = "'title = "Test"', 13, 10, 'version = 1', 13, 10, 'active = true', 13, 10"
    TOML_QUERY_BOOLEAN_PATH[14] = '.active'

    // Test 15: Complex structure boolean
    TOML_QUERY_BOOLEAN_INPUT[15] = "'[owner]', 13, 10, 'name = "Tom"', 13, 10, '[database]', 13, 10, 'enabled = false', 13, 10, 'ports = [8001, 8002]', 13, 10"
    TOML_QUERY_BOOLEAN_PATH[15] = '.database.enabled'

    set_length_array(TOML_QUERY_BOOLEAN_INPUT, 15)
    set_length_array(TOML_QUERY_BOOLEAN_PATH, 15)
}


define_function TestNAVTomlQueryBoolean() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQueryBoolean'")

    InitializeTomlQueryBooleanTestData()

    for (x = 1; x <= length_array(TOML_QUERY_BOOLEAN_INPUT); x++) {
        stack_var _NAVToml toml
        stack_var char result
        stack_var char queryResult

        // Parse TOML
        if (!NAVTomlParse(TOML_QUERY_BOOLEAN_INPUT[x], toml)) {
            NAVLogTestFailed(x, "'Parse success'", "'Parse failed'")
            continue
        }

        // Execute boolean query
        queryResult = NAVTomlQueryBoolean(toml, TOML_QUERY_BOOLEAN_PATH[x], result)

        // Assert query result
        if (TOML_QUERY_BOOLEAN_EXPECTED_RESULT[x]) {
            // Expected to succeed
            if (!queryResult) {
                NAVLogTestFailed(x, "'Query success'", "'Query failed'")
                continue
            }
            if (!NAVAssertBooleanEqual('Boolean value should match',
                                       TOML_QUERY_BOOLEAN_EXPECTED_VALUE[x],
                                       result)) {
                NAVLogTestFailed(x,
                                NAVBooleanToString(TOML_QUERY_BOOLEAN_EXPECTED_VALUE[x]),
                                NAVBooleanToString(result))
                continue
            }
        } else {
            // Expected to fail
            if (queryResult) {
                NAVLogTestFailed(x, "'Query failed'", "'Query succeeded'")
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlQueryBoolean'")
}

