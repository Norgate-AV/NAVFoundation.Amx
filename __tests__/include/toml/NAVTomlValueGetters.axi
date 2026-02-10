PROGRAM_NAME='NAVTomlValueGetters'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_VALUE_GETTER_TEST[10][1024]


define_function InitializeTomlValueGetterTestData() {
    // Test 1: String value
    TOML_VALUE_GETTER_TEST[1] = 'name = "John Doe"'

    // Test 2: Number value (integer)
    TOML_VALUE_GETTER_TEST[2] = 'age = 42'

    // Test 3: Number value (float)
    TOML_VALUE_GETTER_TEST[3] = 'price = 19.99'

    // Test 4: Boolean value (true)
    TOML_VALUE_GETTER_TEST[4] = 'active = true'

    // Test 5: Boolean value (false)
    TOML_VALUE_GETTER_TEST[5] = 'enabled = false'

    // Test 6: String with different key
    TOML_VALUE_GETTER_TEST[6] = 'firstName = "Jane"'

    // Test 7: Empty string
    TOML_VALUE_GETTER_TEST[7] = 'text = ""'

    // Test 8: Zero number
    TOML_VALUE_GETTER_TEST[8] = 'count = 0'

    // Test 9: Negative number
    TOML_VALUE_GETTER_TEST[9] = 'temperature = -15.5'

    // Test 10: DateTime value
    TOML_VALUE_GETTER_TEST[10] = 'created = 1979-05-27T07:32:00Z'

    set_length_array(TOML_VALUE_GETTER_TEST, 10)
}


DEFINE_CONSTANT

// Expected string values (as returned by NAVTomlGetValue)
constant char TOML_VALUE_GETTER_EXPECTED_VALUE[10][64] = {
    'John Doe',             // Test 1
    '42',                   // Test 2
    '19.99',                // Test 3
    'true',                 // Test 4
    'false',                // Test 5
    'Jane',                 // Test 6
    '',                     // Test 7 (empty string)
    '0',                    // Test 8
    '-15.5',                // Test 9
    '1979-05-27T07:32:00Z'  // Test 10
}

// Expected key values
constant char TOML_VALUE_GETTER_EXPECTED_KEY[10][32] = {
    'name',        // Test 1
    'age',         // Test 2
    'price',       // Test 3
    'active',      // Test 4
    'enabled',     // Test 5
    'firstName',   // Test 6
    'text',        // Test 7
    'count',       // Test 8
    'temperature', // Test 9
    'created'      // Test 10
}

// Which tests have string values
constant char TOML_VALUE_GETTER_IS_STRING[10] = {
    true,   // Test 1
    false,  // Test 2
    false,  // Test 3
    false,  // Test 4
    false,  // Test 5
    true,   // Test 6
    true,   // Test 7 (empty string is still a string)
    false,  // Test 8
    false,  // Test 9
    false   // Test 10
}

// Which tests have number values
constant char TOML_VALUE_GETTER_IS_NUMBER[10] = {
    false,  // Test 1
    true,   // Test 2
    true,   // Test 3
    false,  // Test 4
    false,  // Test 5
    false,  // Test 6
    false,  // Test 7
    true,   // Test 8
    true,   // Test 9
    false   // Test 10
}

// Which tests have boolean values
constant char TOML_VALUE_GETTER_IS_BOOLEAN[10] = {
    false,  // Test 1
    false,  // Test 2
    false,  // Test 3
    true,   // Test 4
    true,   // Test 5
    false,  // Test 6
    false,  // Test 7
    false,  // Test 8
    false,  // Test 9
    false   // Test 10
}

// Which tests have datetime values
constant char TOML_VALUE_GETTER_IS_DATETIME[10] = {
    false,  // Test 1
    false,  // Test 2
    false,  // Test 3
    false,  // Test 4
    false,  // Test 5
    false,  // Test 6
    false,  // Test 7
    false,  // Test 8
    false,  // Test 9
    true    // Test 10
}


define_function TestNAVTomlValueGetters() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlValueGetters'")

    InitializeTomlValueGetterTestData()

    for (x = 1; x <= length_array(TOML_VALUE_GETTER_TEST); x++) {
        stack_var _NAVToml toml
        stack_var _NAVTomlNode root
        stack_var _NAVTomlNode child
        stack_var char value[256]
        stack_var char key[64]

        if (!NAVTomlParse(TOML_VALUE_GETTER_TEST[x], toml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVTomlQuery(toml, '.', root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        if (!NAVTomlGetFirstChild(toml, root, child)) {
            NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
            continue
        }

        // Test NAVTomlGetKey
        key = NAVTomlGetKey(child)
        if (length_array(key) == 0) {
            NAVLogTestFailed(x, 'GetKey success', 'GetKey failed')
            continue
        }

        if (!NAVAssertStringEqual('NAVTomlGetKey value',
                                  TOML_VALUE_GETTER_EXPECTED_KEY[x],
                                  key)) {
            NAVLogTestFailed(x,
                            TOML_VALUE_GETTER_EXPECTED_KEY[x],
                            key)
            continue
        }

        // Test NAVTomlGetValue
        value = NAVTomlGetValue(child)
        if (!NAVAssertStringEqual('NAVTomlGetValue value',
                                  TOML_VALUE_GETTER_EXPECTED_VALUE[x],
                                  value)) {
            NAVLogTestFailed(x,
                            TOML_VALUE_GETTER_EXPECTED_VALUE[x],
                            value)
            continue
        }

        // Test type checking - NAVTomlIsString
        if (!NAVAssertBooleanEqual('NAVTomlIsString',
                                    TOML_VALUE_GETTER_IS_STRING[x],
                                    NAVTomlIsString(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_VALUE_GETTER_IS_STRING[x]),
                            NAVBooleanToString(NAVTomlIsString(child)))
            continue
        }

        // Test type checking - NAVTomlIsNumber
        if (!NAVAssertBooleanEqual('NAVTomlIsNumber',
                                    TOML_VALUE_GETTER_IS_NUMBER[x],
                                    NAVTomlIsNumber(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_VALUE_GETTER_IS_NUMBER[x]),
                            NAVBooleanToString(NAVTomlIsNumber(child)))
            continue
        }

        // Test type checking - NAVTomlIsBoolean
        if (!NAVAssertBooleanEqual('NAVTomlIsBoolean',
                                    TOML_VALUE_GETTER_IS_BOOLEAN[x],
                                    NAVTomlIsBoolean(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_VALUE_GETTER_IS_BOOLEAN[x]),
                            NAVBooleanToString(NAVTomlIsBoolean(child)))
            continue
        }

        // Test type checking - NAVTomlIsDateTime
        if (!NAVAssertBooleanEqual('NAVTomlIsDateTime',
                                    TOML_VALUE_GETTER_IS_DATETIME[x],
                                    NAVTomlIsDateTime(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_VALUE_GETTER_IS_DATETIME[x]),
                            NAVBooleanToString(NAVTomlIsDateTime(child)))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlValueGetters'")
}
