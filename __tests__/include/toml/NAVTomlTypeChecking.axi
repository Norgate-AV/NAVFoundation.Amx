PROGRAM_NAME='NAVTomlTypeChecking'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_TYPE_CHECK_TEST[10][512]


define_function InitializeTomlTypeCheckTestData() {
    // Test 1: Table (root table)
    TOML_TYPE_CHECK_TEST[1] = 'name = "test"'

    // Test 2: Array of integers
    TOML_TYPE_CHECK_TEST[2] = 'items = [1, 2, 3]'

    // Test 3: String value
    TOML_TYPE_CHECK_TEST[3] = 'text = "hello"'

    // Test 4: Integer value
    TOML_TYPE_CHECK_TEST[4] = 'count = 42'

    // Test 5: Boolean true
    TOML_TYPE_CHECK_TEST[5] = 'enabled = true'

    // Test 6: Boolean false
    TOML_TYPE_CHECK_TEST[6] = 'disabled = false'

    // Test 7: DateTime value
    TOML_TYPE_CHECK_TEST[7] = 'created = 1979-05-27T07:32:00Z'

    // Test 8: Nested table (inline table)
    TOML_TYPE_CHECK_TEST[8] = 'point = { x = 10, y = 20 }'

    // Test 9: Array of tables
    TOML_TYPE_CHECK_TEST[9] = "'[[products]]', 13, 10, 'name = "Widget"', 13, 10"

    // Test 10: Complex structure with array
    TOML_TYPE_CHECK_TEST[10] = 'data = [1, 2, 3]'

    set_length_array(TOML_TYPE_CHECK_TEST, 10)
}


DEFINE_CONSTANT

// Expected results for root node type checks (tests 1-10)
constant char TOML_TYPE_CHECK_ROOT_IS_TABLE[10] = {
    true,   // Test 1: Root table
    true,   // Test 2: Root table
    true,   // Test 3: Root table
    true,   // Test 4: Root table
    true,   // Test 5: Root table
    true,   // Test 6: Root table
    true,   // Test 7: Root table
    true,   // Test 8: Root table
    true,   // Test 9: Root table
    true    // Test 10: Root table
}

constant char TOML_TYPE_CHECK_ROOT_IS_ARRAY[10] = {
    false,  // Test 1: Root table
    false,  // Test 2: Root table
    false,  // Test 3: Root table
    false,  // Test 4: Root table
    false,  // Test 5: Root table
    false,  // Test 6: Root table
    false,  // Test 7: Root table
    false,  // Test 8: Root table
    false,  // Test 9: Root table
    false   // Test 10: Root table
}

// Expected results for first child type checks (where applicable)
constant char TOML_TYPE_CHECK_FIRST_CHILD_IS_STRING[10] = {
    true,   // Test 1: name = "test"
    false,  // Test 2: items = [...]
    true,   // Test 3: text = "hello"
    false,  // Test 4: count = 42
    false,  // Test 5: enabled = true
    false,  // Test 6: disabled = false
    false,  // Test 7: created = DateTime
    false,  // Test 8: point = {...}
    false,  // Test 9: products[0] is table
    false   // Test 10: data = [...]
}

constant char TOML_TYPE_CHECK_FIRST_CHILD_IS_NUMBER[10] = {
    false,  // Test 1: name = "test"
    false,  // Test 2: items = [...]
    false,  // Test 3: text = "hello"
    true,   // Test 4: count = 42
    false,  // Test 5: enabled = true
    false,  // Test 6: disabled = false
    false,  // Test 7: created = DateTime
    false,  // Test 8: point = {...}
    false,  // Test 9: products[0] is table
    false   // Test 10: data = [...]
}

constant char TOML_TYPE_CHECK_FIRST_CHILD_IS_BOOLEAN[10] = {
    false,  // Test 1: name = "test"
    false,  // Test 2: items = [...]
    false,  // Test 3: text = "hello"
    false,  // Test 4: count = 42
    true,   // Test 5: enabled = true
    true,   // Test 6: disabled = false
    false,  // Test 7: created = DateTime
    false,  // Test 8: point = {...}
    false,  // Test 9: products[0] is table
    false   // Test 10: data = [...]
}

constant char TOML_TYPE_CHECK_FIRST_CHILD_IS_DATETIME[10] = {
    false,  // Test 1: name = "test"
    false,  // Test 2: items = [...]
    false,  // Test 3: text = "hello"
    false,  // Test 4: count = 42
    false,  // Test 5: enabled = true
    false,  // Test 6: disabled = false
    true,   // Test 7: created = DateTime
    false,  // Test 8: point = {...}
    false,  // Test 9: products[0] is table
    false   // Test 10: data = [...]
}

constant char TOML_TYPE_CHECK_FIRST_CHILD_IS_TABLE[10] = {
    false,  // Test 1: name = "test"
    false,  // Test 2: items = [...]
    false,  // Test 3: text = "hello"
    false,  // Test 4: count = 42
    false,  // Test 5: enabled = true
    false,  // Test 6: disabled = false
    false,  // Test 7: created = DateTime
    true,   // Test 8: point = {...}
    false,  // Test 9: products is TABLE_ARRAY (not table or array)
    false   // Test 10: data = [...]
}

constant char TOML_TYPE_CHECK_FIRST_CHILD_IS_ARRAY[10] = {
    false,  // Test 1: name = "test"
    true,   // Test 2: items = [...]
    false,  // Test 3: text = "hello"
    false,  // Test 4: count = 42
    false,  // Test 5: enabled = true
    false,  // Test 6: disabled = false
    false,  // Test 7: created = DateTime
    false,  // Test 8: point = {...}
    false,  // Test 9: products[0] is table
    true    // Test 10: data = [...]
}


define_function TestNAVTomlTypeChecking() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlTypeChecking'")

    InitializeTomlTypeCheckTestData()

    for (x = 1; x <= length_array(TOML_TYPE_CHECK_TEST); x++) {
        stack_var _NAVToml toml
        stack_var _NAVTomlNode root
        stack_var _NAVTomlNode child

        if (!NAVTomlParse(TOML_TYPE_CHECK_TEST[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQuery(toml, '.', root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        // Test root node type checking
        if (!NAVAssertBooleanEqual('NAVTomlIsTable for root',
                                    TOML_TYPE_CHECK_ROOT_IS_TABLE[x],
                                    NAVTomlIsTable(root))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_TYPE_CHECK_ROOT_IS_TABLE[x]),
                            NAVBooleanToString(NAVTomlIsTable(root)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVTomlIsArray for root',
                                    TOML_TYPE_CHECK_ROOT_IS_ARRAY[x],
                                    NAVTomlIsArray(root))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_TYPE_CHECK_ROOT_IS_ARRAY[x]),
                            NAVBooleanToString(NAVTomlIsArray(root)))
            continue
        }

        // Get first child for further testing
        if (!NAVTomlGetFirstChild(toml, root, child)) {
            NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
            continue
        }

        // Test first child type checking
        if (!NAVAssertBooleanEqual('NAVTomlIsString for first child',
                                    TOML_TYPE_CHECK_FIRST_CHILD_IS_STRING[x],
                                    NAVTomlIsString(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_TYPE_CHECK_FIRST_CHILD_IS_STRING[x]),
                            NAVBooleanToString(NAVTomlIsString(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVTomlIsNumber for first child',
                                    TOML_TYPE_CHECK_FIRST_CHILD_IS_NUMBER[x],
                                    NAVTomlIsNumber(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_TYPE_CHECK_FIRST_CHILD_IS_NUMBER[x]),
                            NAVBooleanToString(NAVTomlIsNumber(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVTomlIsBoolean for first child',
                                    TOML_TYPE_CHECK_FIRST_CHILD_IS_BOOLEAN[x],
                                    NAVTomlIsBoolean(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_TYPE_CHECK_FIRST_CHILD_IS_BOOLEAN[x]),
                            NAVBooleanToString(NAVTomlIsBoolean(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVTomlIsDateTime for first child',
                                    TOML_TYPE_CHECK_FIRST_CHILD_IS_DATETIME[x],
                                    NAVTomlIsDateTime(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_TYPE_CHECK_FIRST_CHILD_IS_DATETIME[x]),
                            NAVBooleanToString(NAVTomlIsDateTime(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVTomlIsTable for first child',
                                    TOML_TYPE_CHECK_FIRST_CHILD_IS_TABLE[x],
                                    NAVTomlIsTable(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_TYPE_CHECK_FIRST_CHILD_IS_TABLE[x]),
                            NAVBooleanToString(NAVTomlIsTable(child)))
            continue
        }

        if (!NAVAssertBooleanEqual('NAVTomlIsArray for first child',
                                    TOML_TYPE_CHECK_FIRST_CHILD_IS_ARRAY[x],
                                    NAVTomlIsArray(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_TYPE_CHECK_FIRST_CHILD_IS_ARRAY[x]),
                            NAVBooleanToString(NAVTomlIsArray(child)))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlTypeChecking'")
}

