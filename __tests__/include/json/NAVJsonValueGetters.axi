PROGRAM_NAME='NAVJsonValueGetters'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_VALUE_GETTER_TEST[10][512]


define_function InitializeJsonValueGetterTestData() {
    // Test 1: String value
    JSON_VALUE_GETTER_TEST[1] = '{"name":"John Doe"}'

    // Test 2: Number value (integer)
    JSON_VALUE_GETTER_TEST[2] = '{"age":42}'

    // Test 3: Number value (float)
    JSON_VALUE_GETTER_TEST[3] = '{"price":19.99}'

    // Test 4: Boolean value (true)
    JSON_VALUE_GETTER_TEST[4] = '{"active":true}'

    // Test 5: Boolean value (false)
    JSON_VALUE_GETTER_TEST[5] = '{"enabled":false}'

    // Test 6: Object with key
    JSON_VALUE_GETTER_TEST[6] = '{"firstName":"Jane"}'

    // Test 7: Empty string
    JSON_VALUE_GETTER_TEST[7] = '{"text":""}'

    // Test 8: Zero number
    JSON_VALUE_GETTER_TEST[8] = '{"count":0}'

    // Test 9: Negative number
    JSON_VALUE_GETTER_TEST[9] = '{"temperature":-15.5}'

    // Test 10: Multiple properties
    JSON_VALUE_GETTER_TEST[10] = '{"id":100,"label":"Item A","visible":true}'

    set_length_array(JSON_VALUE_GETTER_TEST, 10)
}


DEFINE_CONSTANT

// Expected string values (for tests with strings)
constant char JSON_VALUE_GETTER_EXPECTED_STRING[10][64] = {
    'John Doe',  // Test 1
    '',          // Test 2 (not a string)
    '',          // Test 3 (not a string)
    '',          // Test 4 (not a string)
    '',          // Test 5 (not a string)
    'Jane',      // Test 6
    '',          // Test 7 (empty string)
    '',          // Test 8 (not a string)
    '',          // Test 9 (not a string)
    ''           // Test 10 (not a string, but has string property)
}

// Expected number values (for tests with numbers)
constant float JSON_VALUE_GETTER_EXPECTED_NUMBER[10] = {
    0.0,    // Test 1 (not a number)
    42.0,   // Test 2
    19.99,  // Test 3
    0.0,    // Test 4 (not a number)
    0.0,    // Test 5 (not a number)
    0.0,    // Test 6 (not a number)
    0.0,    // Test 7 (not a number)
    0.0,    // Test 8
    -15.5,  // Test 9
    0.0     // Test 10 (not a number, but has number property)
}

// Expected boolean values (for tests with booleans)
constant char JSON_VALUE_GETTER_EXPECTED_BOOLEAN[10] = {
    false,  // Test 1 (not a boolean)
    false,  // Test 2 (not a boolean)
    false,  // Test 3 (not a boolean)
    true,   // Test 4
    false,  // Test 5
    false,  // Test 6 (not a boolean)
    false,  // Test 7 (not a boolean)
    false,  // Test 8 (not a boolean)
    false,  // Test 9 (not a boolean)
    false   // Test 10 (not a boolean, but has boolean property)
}

// Expected key values (for tests with object properties)
constant char JSON_VALUE_GETTER_EXPECTED_KEY[10][32] = {
    'name',      // Test 1
    'age',       // Test 2
    'price',     // Test 3
    'active',    // Test 4
    'enabled',   // Test 5
    'firstName', // Test 6
    'text',      // Test 7
    'count',     // Test 8
    'temperature', // Test 9
    'id'         // Test 10 (first key)
}

// Which tests have valid string values
constant char JSON_VALUE_GETTER_HAS_STRING[10] = {
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

// Which tests have valid number values
constant char JSON_VALUE_GETTER_HAS_NUMBER[10] = {
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

// Which tests have valid boolean values
constant char JSON_VALUE_GETTER_HAS_BOOLEAN[10] = {
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


define_function TestNAVJsonValueGetters() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonValueGetters'")

    InitializeJsonValueGetterTestData()

    for (x = 1; x <= length_array(JSON_VALUE_GETTER_TEST); x++) {
        stack_var _NAVJson json
        stack_var _NAVJsonNode root
        stack_var _NAVJsonNode child
        stack_var char stringValue[256]
        stack_var float numberValue
        stack_var char booleanValue
        stack_var char keyValue[64]

        if (!NAVJsonParse(JSON_VALUE_GETTER_TEST[x], json)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        if (!NAVJsonGetRootNode(json, root)) {
            NAVLogTestFailed(x, 'Get root success', 'Get root failed')
            continue
        }

        if (!NAVJsonGetFirstChild(json, root, child)) {
            NAVLogTestFailed(x, 'Get first child success', 'Get first child failed')
            continue
        }

        // Test NAVJsonGetString
        if (JSON_VALUE_GETTER_HAS_STRING[x]) {
            if (!NAVJsonGetString(child, stringValue)) {
                NAVLogTestFailed(x, 'GetString success', 'GetString failed')
                continue
            }

            if (!NAVAssertStringEqual('NAVJsonGetString value',
                                      JSON_VALUE_GETTER_EXPECTED_STRING[x],
                                      stringValue)) {
                NAVLogTestFailed(x,
                                JSON_VALUE_GETTER_EXPECTED_STRING[x],
                                stringValue)
                continue
            }
        }

        // Test NAVJsonGetNumber
        if (JSON_VALUE_GETTER_HAS_NUMBER[x]) {
            if (!NAVJsonGetNumber(child, numberValue)) {
                NAVLogTestFailed(x, 'GetNumber success', 'GetNumber failed')
                continue
            }

            if (!NAVAssertFloatAlmostEqual('NAVJsonGetNumber value',
                                           JSON_VALUE_GETTER_EXPECTED_NUMBER[x],
                                           numberValue,
                                           0.000001)) {
                NAVLogTestFailed(x,
                                ftoa(JSON_VALUE_GETTER_EXPECTED_NUMBER[x]),
                                ftoa(numberValue))
                continue
            }
        }

        // Test NAVJsonGetBoolean
        if (JSON_VALUE_GETTER_HAS_BOOLEAN[x]) {
            if (!NAVJsonGetBoolean(child, booleanValue)) {
                NAVLogTestFailed(x, 'GetBoolean success', 'GetBoolean failed')
                continue
            }

            if (!NAVAssertBooleanEqual('NAVJsonGetBoolean value',
                                       JSON_VALUE_GETTER_EXPECTED_BOOLEAN[x],
                                       booleanValue)) {
                NAVLogTestFailed(x,
                                NAVBooleanToString(JSON_VALUE_GETTER_EXPECTED_BOOLEAN[x]),
                                NAVBooleanToString(booleanValue))
                continue
            }
        }

        // Test NAVJsonGetKey (all tests have keys)
        keyValue = NAVJsonGetKey(child)
        if (length_array(keyValue) == 0) {
            NAVLogTestFailed(x, 'GetKey success', 'GetKey failed')
            continue
        }

        if (!NAVAssertStringEqual('NAVJsonGetKey value',
                                  JSON_VALUE_GETTER_EXPECTED_KEY[x],
                                  keyValue)) {
            NAVLogTestFailed(x,
                            JSON_VALUE_GETTER_EXPECTED_KEY[x],
                            keyValue)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonValueGetters'")
}
