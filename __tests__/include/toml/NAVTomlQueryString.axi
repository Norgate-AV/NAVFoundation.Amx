PROGRAM_NAME='NAVTomlQueryString'

#include 'NAVFoundation.Toml.axi'

DEFINE_VARIABLE

volatile char TOML_QUERY_STRING_INPUT[20][2048]
volatile char TOML_QUERY_STRING_PATH[20][256]
volatile char TOML_QUERY_STRING_EXPECTED_VALUE[20][512]

constant char TOML_QUERY_STRING_EXPECTED_RESULT[] = {
    true,   // Test 1: Simple string
    true,   // Test 2: Empty string
    true,   // Test 3: String with spaces
    true,   // Test 4: String with special chars
    true,   // Test 5: Nested string
    true,   // Test 6: String in array element
    true,   // Test 7: String in inline table
    true,   // Test 8: String in array of tables
    true,   // Test 9: Literal string
    true,   // Test 10: Multiline basic string
    true,   // Test 11: Multiline literal string
    true,   // Test 12: String with escapes
    false,  // Test 13: Query integer as string (should fail)
    false,  // Test 14: Query boolean as string (should fail)
    false,  // Test 15: Query array as string (should fail)
    true,   // Test 16: Long string
    true,   // Test 17: String with Unicode
    true,   // Test 18: Dotted key string
    true,   // Test 19: String in deep nesting
    true    // Test 20: String with quotes
}


define_function InitializeTomlQueryStringTestData() {
    // Test 1: Simple string
    TOML_QUERY_STRING_INPUT[1] = 'name = "John Doe"'
    TOML_QUERY_STRING_PATH[1] = '.name'
    TOML_QUERY_STRING_EXPECTED_VALUE[1] = 'John Doe'

    // Test 2: Empty string
    TOML_QUERY_STRING_INPUT[2] = 'empty = ""'
    TOML_QUERY_STRING_PATH[2] = '.empty'
    TOML_QUERY_STRING_EXPECTED_VALUE[2] = ''

    // Test 3: String with spaces
    TOML_QUERY_STRING_INPUT[3] = 'text = "  leading and trailing  "'
    TOML_QUERY_STRING_PATH[3] = '.text'
    TOML_QUERY_STRING_EXPECTED_VALUE[3] = '  leading and trailing  '

    // Test 4: String with special chars
    TOML_QUERY_STRING_INPUT[4] = 'special = "Hello@#$%^&*()World"'
    TOML_QUERY_STRING_PATH[4] = '.special'
    TOML_QUERY_STRING_EXPECTED_VALUE[4] = 'Hello@#$%^&*()World'

    // Test 5: Nested string
    TOML_QUERY_STRING_INPUT[5] = "'[server]', 13, 10, 'host = "localhost"', 13, 10"
    TOML_QUERY_STRING_PATH[5] = '.server.host'
    TOML_QUERY_STRING_EXPECTED_VALUE[5] = 'localhost'

    // Test 6: String in array element
    TOML_QUERY_STRING_INPUT[6] = 'colors = ["red", "green", "blue"]'
    TOML_QUERY_STRING_PATH[6] = '.colors[2]'
    TOML_QUERY_STRING_EXPECTED_VALUE[6] = 'green'

    // Test 7: String in inline table
    TOML_QUERY_STRING_INPUT[7] = 'user = { name = "Alice", role = "admin" }'
    TOML_QUERY_STRING_PATH[7] = '.user.name'
    TOML_QUERY_STRING_EXPECTED_VALUE[7] = 'Alice'

    // Test 8: String in array of tables
    TOML_QUERY_STRING_INPUT[8] = "'[[products]]', 13, 10, 'name = "Hammer"', 13, 10, '[[products]]', 13, 10, 'name = "Nail"', 13, 10"
    TOML_QUERY_STRING_PATH[8] = '.products[1].name'
    TOML_QUERY_STRING_EXPECTED_VALUE[8] = 'Hammer'

    // Test 9: Literal string
    TOML_QUERY_STRING_INPUT[9] = "'path = ''C:\Windows\System32'''"
    TOML_QUERY_STRING_PATH[9] = '.path'
    TOML_QUERY_STRING_EXPECTED_VALUE[9] = 'C:\Windows\System32'

    // Test 10: Multiline basic string
    TOML_QUERY_STRING_INPUT[10] = "'text = ', $22, $22, $22, 13, 10, 'Line 1', 13, 10, 'Line 2', $22, $22, $22, 13, 10"
    TOML_QUERY_STRING_PATH[10] = '.text'
    TOML_QUERY_STRING_EXPECTED_VALUE[10] = "'Line 1', 13, 10, 'Line 2'"

    // Test 11: Multiline literal string
    TOML_QUERY_STRING_INPUT[11] = "'data = ', $27, $27, $27, 13, 10, 'Raw', 13, 10, 'Text', $27, $27, $27, 13, 10"
    TOML_QUERY_STRING_PATH[11] = '.data'
    TOML_QUERY_STRING_EXPECTED_VALUE[11] = "'Raw', 13, 10, 'Text'"

    // Test 12: String with escapes
    TOML_QUERY_STRING_INPUT[12] = 'escaped = "Tab:\t Newline:\n Quote:\" Backslash:\\"'
    TOML_QUERY_STRING_PATH[12] = '.escaped'
    TOML_QUERY_STRING_EXPECTED_VALUE[12] = "'Tab:', 9, ' Newline:', 10, ' Quote:', 34, ' Backslash:', 92"

    // Test 13: Query integer as string (should fail)
    TOML_QUERY_STRING_INPUT[13] = 'number = 42'
    TOML_QUERY_STRING_PATH[13] = '.number'
    TOML_QUERY_STRING_EXPECTED_VALUE[13] = ''

    // Test 14: Query boolean as string (should fail)
    TOML_QUERY_STRING_INPUT[14] = 'flag = true'
    TOML_QUERY_STRING_PATH[14] = '.flag'
    TOML_QUERY_STRING_EXPECTED_VALUE[14] = ''

    // Test 15: Query array as string (should fail)
    TOML_QUERY_STRING_INPUT[15] = 'arr = [1, 2, 3]'
    TOML_QUERY_STRING_PATH[15] = '.arr'
    TOML_QUERY_STRING_EXPECTED_VALUE[15] = ''

    // Test 16: Long string
    TOML_QUERY_STRING_INPUT[16] = 'long = "This is a very long string that contains many characters to test string handling capabilities"'
    TOML_QUERY_STRING_PATH[16] = '.long'
    TOML_QUERY_STRING_EXPECTED_VALUE[16] = 'This is a very long string that contains many characters to test string handling capabilities'

    // Test 17: String with Unicode escape (NetLinx preserves \uXXXX as-is)
    TOML_QUERY_STRING_INPUT[17] = 'unicode = "Hello \u0057orld"'
    TOML_QUERY_STRING_PATH[17] = '.unicode'
    TOML_QUERY_STRING_EXPECTED_VALUE[17] = 'Hello \u0057orld'

    // Test 18: Dotted key string
    TOML_QUERY_STRING_INPUT[18] = 'fruit.apple.color = "red"'
    TOML_QUERY_STRING_PATH[18] = '.fruit.apple.color'
    TOML_QUERY_STRING_EXPECTED_VALUE[18] = 'red'

    // Test 19: String in deep nesting
    TOML_QUERY_STRING_INPUT[19] = "'[a]', 13, 10, '[a.b]', 13, 10, '[a.b.c]', 13, 10, 'value = "deep"', 13, 10"
    TOML_QUERY_STRING_PATH[19] = '.a.b.c.value'
    TOML_QUERY_STRING_EXPECTED_VALUE[19] = 'deep'

    // Test 20: String with quotes
    TOML_QUERY_STRING_INPUT[20] = 'quoted = "He said \"Hello\""'
    TOML_QUERY_STRING_PATH[20] = '.quoted'
    TOML_QUERY_STRING_EXPECTED_VALUE[20] = "'He said ', 34, 'Hello', 34"

    set_length_array(TOML_QUERY_STRING_INPUT, 20)
    set_length_array(TOML_QUERY_STRING_PATH, 20)
    set_length_array(TOML_QUERY_STRING_EXPECTED_VALUE, 20)
}


define_function TestNAVTomlQueryString() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQueryString'")

    InitializeTomlQueryStringTestData()

    for (x = 1; x <= length_array(TOML_QUERY_STRING_INPUT); x++) {
        stack_var _NAVToml toml
        stack_var char result[512]        stack_var char queryResult
        // Parse TOML
        if (!NAVTomlParse(TOML_QUERY_STRING_INPUT[x], toml)) {
            NAVLogTestFailed(x, "'Parse success'", "'Parse failed'")
            continue
        }

        // Execute string query
        queryResult = NAVTomlQueryString(toml, TOML_QUERY_STRING_PATH[x], result)

        // Assert query result
        if (TOML_QUERY_STRING_EXPECTED_RESULT[x]) {
            // Expected to succeed
            if (!queryResult) {
                NAVLogTestFailed(x, "'Query success'", "'Query failed'")
                continue
            }
            if (!NAVAssertStringEqual('String value should match',
                                      TOML_QUERY_STRING_EXPECTED_VALUE[x],
                                      result)) {
                NAVLogTestFailed(x,
                                TOML_QUERY_STRING_EXPECTED_VALUE[x],
                                result)
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

    NAVLogTestSuiteEnd("'NAVTomlQueryString'")
}

