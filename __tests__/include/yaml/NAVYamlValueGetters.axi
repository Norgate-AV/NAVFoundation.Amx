PROGRAM_NAME='NAVYamlValueGetters'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_VALUE_GETTER_TEST[10][1024]


define_function InitializeYamlValueGetterTestData() {
    // Test 1: String value
    YAML_VALUE_GETTER_TEST[1] = "'name: John Doe'"

    // Test 2: Number value (integer)
    YAML_VALUE_GETTER_TEST[2] = "'age: 42'"

    // Test 3: Number value (float)
    YAML_VALUE_GETTER_TEST[3] = "'price: 19.99'"

    // Test 4: Boolean value (true)
    YAML_VALUE_GETTER_TEST[4] = "'active: true'"

    // Test 5: Boolean value (false)
    YAML_VALUE_GETTER_TEST[5] = "'enabled: false'"

    // Test 6: Object with key
    YAML_VALUE_GETTER_TEST[6] = "'firstName: Jane'"

    // Test 7: Empty string
    YAML_VALUE_GETTER_TEST[7] = "'text: ', $27, $27"

    // Test 8: Zero number
    YAML_VALUE_GETTER_TEST[8] = "'count: 0'"

    // Test 9: Negative number
    YAML_VALUE_GETTER_TEST[9] = "'temperature: -15.5'"

    // Test 10: Null value
    YAML_VALUE_GETTER_TEST[10] = "'value: null'"

    set_length_array(YAML_VALUE_GETTER_TEST, 10)
}


DEFINE_CONSTANT

// Expected string values (as returned by NAVYamlGetValue)
constant char YAML_VALUE_GETTER_EXPECTED_VALUE[10][64] = {
    'John Doe',  // Test 1
    '42',        // Test 2
    '19.99',     // Test 3
    'true',      // Test 4
    'false',     // Test 5
    'Jane',      // Test 6
    '',          // Test 7 (empty string)
    '0',         // Test 8
    '-15.5',     // Test 9
    'null'       // Test 10 (null as string)
}

// Expected key values
constant char YAML_VALUE_GETTER_EXPECTED_KEY[10][32] = {
    'name',        // Test 1
    'age',         // Test 2
    'price',       // Test 3
    'active',      // Test 4
    'enabled',     // Test 5
    'firstName',   // Test 6
    'text',        // Test 7
    'count',       // Test 8
    'temperature', // Test 9
    'value'        // Test 10
}

// Which tests have string values
constant char YAML_VALUE_GETTER_IS_STRING[10] = {
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
constant char YAML_VALUE_GETTER_IS_NUMBER[10] = {
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
constant char YAML_VALUE_GETTER_IS_BOOLEAN[10] = {
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

// Which tests have null values
constant char YAML_VALUE_GETTER_IS_NULL[10] = {
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


define_function TestNAVYamlValueGetters() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlValueGetters'")

    InitializeYamlValueGetterTestData()

    for (x = 1; x <= length_array(YAML_VALUE_GETTER_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode root
        stack_var _NAVYamlNode child
        stack_var char value[256]
        stack_var char key[64]

        if (!NAVYamlParse(YAML_VALUE_GETTER_TEST[x], yaml)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVYamlGetRoot(yaml, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        if (!NAVYamlGetFirstChild(yaml, root, child)) {
            NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
            continue
        }

        // Test NAVYamlGetKey
        key = NAVYamlGetKey(child)
        if (length_array(key) == 0) {
            NAVLogTestFailed(x, 'GetKey success', 'GetKey failed')
            continue
        }

        if (!NAVAssertStringEqual('NAVYamlGetKey value',
                                  YAML_VALUE_GETTER_EXPECTED_KEY[x],
                                  key)) {
            NAVLogTestFailed(x,
                            YAML_VALUE_GETTER_EXPECTED_KEY[x],
                            key)
            continue
        }

        // Test NAVYamlGetValue
        value = NAVYamlGetValue(child)
        if (!NAVAssertStringEqual('NAVYamlGetValue value',
                                  YAML_VALUE_GETTER_EXPECTED_VALUE[x],
                                  value)) {
            NAVLogTestFailed(x,
                            YAML_VALUE_GETTER_EXPECTED_VALUE[x],
                            value)
            continue
        }

        // Test type checking - NAVYamlIsString
        if (!NAVAssertBooleanEqual('NAVYamlIsString',
                                    YAML_VALUE_GETTER_IS_STRING[x],
                                    NAVYamlIsString(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_VALUE_GETTER_IS_STRING[x]),
                            NAVBooleanToString(NAVYamlIsString(child)))
            continue
        }

        // Test type checking - NAVYamlIsNumber
        if (!NAVAssertBooleanEqual('NAVYamlIsNumber',
                                    YAML_VALUE_GETTER_IS_NUMBER[x],
                                    NAVYamlIsNumber(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_VALUE_GETTER_IS_NUMBER[x]),
                            NAVBooleanToString(NAVYamlIsNumber(child)))
            continue
        }

        // Test type checking - NAVYamlIsBoolean
        if (!NAVAssertBooleanEqual('NAVYamlIsBoolean',
                                    YAML_VALUE_GETTER_IS_BOOLEAN[x],
                                    NAVYamlIsBoolean(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_VALUE_GETTER_IS_BOOLEAN[x]),
                            NAVBooleanToString(NAVYamlIsBoolean(child)))
            continue
        }

        // Test type checking - NAVYamlIsNull
        if (!NAVAssertBooleanEqual('NAVYamlIsNull',
                                    YAML_VALUE_GETTER_IS_NULL[x],
                                    NAVYamlIsNull(child))) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_VALUE_GETTER_IS_NULL[x]),
                            NAVBooleanToString(NAVYamlIsNull(child)))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlValueGetters'")
}

