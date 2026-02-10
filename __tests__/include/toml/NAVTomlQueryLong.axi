PROGRAM_NAME='NAVTomlQueryLong'

#include 'NAVFoundation.Toml.axi'

DEFINE_VARIABLE

volatile char TOML_QUERY_LONG_INPUT[15][2048]
volatile char TOML_QUERY_LONG_PATH[15][256]
volatile long TOML_QUERY_LONG_EXPECTED_VALUE[15]

constant char TOML_QUERY_LONG_EXPECTED_RESULT[] = {
    true,   // Test 1: Large positive long
    true,   // Test 2: Another large positive long
    true,   // Test 3: Zero
    true,   // Test 4: Hexadecimal
    true,   // Test 5: Octal
    true,   // Test 6: Binary
    true,   // Test 7: Long with underscores
    true,   // Test 8: Nested long
    true,   // Test 9: Long in array element
    true,   // Test 10: Long in inline table
    false,  // Test 11: Query string as long (should fail)
    false,  // Test 12: Query boolean as long (should fail)
    false,  // Test 13: Query float as long (should fail)
    true,   // Test 14: Very large long
    true    // Test 15: Dotted key long
}


define_function InitializeTomlQueryLongTestData() {
    // Test 1: Large positive long
    TOML_QUERY_LONG_INPUT[1] = 'big_number = 4000000000'
    TOML_QUERY_LONG_PATH[1] = '.big_number'
    TOML_QUERY_LONG_EXPECTED_VALUE[1] = 4000000000

    // Test 2: Another large positive long
    TOML_QUERY_LONG_INPUT[2] = 'big_value = 2000000000'
    TOML_QUERY_LONG_PATH[2] = '.big_value'
    TOML_QUERY_LONG_EXPECTED_VALUE[2] = 2000000000

    // Test 3: Zero
    TOML_QUERY_LONG_INPUT[3] = 'zero = 0'
    TOML_QUERY_LONG_PATH[3] = '.zero'
    TOML_QUERY_LONG_EXPECTED_VALUE[3] = 0

    // Test 4: Hexadecimal
    TOML_QUERY_LONG_INPUT[4] = 'hex = 0xDEADBEEF'
    TOML_QUERY_LONG_PATH[4] = '.hex'
    TOML_QUERY_LONG_EXPECTED_VALUE[4] = 3735928559

    // Test 5: Octal
    TOML_QUERY_LONG_INPUT[5] = 'oct = 0o755'
    TOML_QUERY_LONG_PATH[5] = '.oct'
    TOML_QUERY_LONG_EXPECTED_VALUE[5] = 493

    // Test 6: Binary
    TOML_QUERY_LONG_INPUT[6] = 'bin = 0b11111111'
    TOML_QUERY_LONG_PATH[6] = '.bin'
    TOML_QUERY_LONG_EXPECTED_VALUE[6] = 255

    // Test 7: Long with underscores
    TOML_QUERY_LONG_INPUT[7] = 'large = 1_000_000_000'
    TOML_QUERY_LONG_PATH[7] = '.large'
    TOML_QUERY_LONG_EXPECTED_VALUE[7] = 1000000000

    // Test 8: Nested long
    TOML_QUERY_LONG_INPUT[8] = "'[server]', 13, 10, 'timestamp = 1234567890', 13, 10"
    TOML_QUERY_LONG_PATH[8] = '.server.timestamp'
    TOML_QUERY_LONG_EXPECTED_VALUE[8] = 1234567890

    // Test 9: Long in array element
    TOML_QUERY_LONG_INPUT[9] = 'timestamps = [1000000000, 2000000000, 3000000000]'
    TOML_QUERY_LONG_PATH[9] = '.timestamps[3]'
    TOML_QUERY_LONG_EXPECTED_VALUE[9] = 3000000000

    // Test 10: Long in inline table
    TOML_QUERY_LONG_INPUT[10] = 'data = { value = 4200000000 }'
    TOML_QUERY_LONG_PATH[10] = '.data.value'
    TOML_QUERY_LONG_EXPECTED_VALUE[10] = 4200000000

    // Test 11: Query string as long (should fail)
    TOML_QUERY_LONG_INPUT[11] = 'text = "not a long"'
    TOML_QUERY_LONG_PATH[11] = '.text'
    TOML_QUERY_LONG_EXPECTED_VALUE[11] = 0

    // Test 12: Query boolean as long (should fail)
    TOML_QUERY_LONG_INPUT[12] = 'flag = true'
    TOML_QUERY_LONG_PATH[12] = '.flag'
    TOML_QUERY_LONG_EXPECTED_VALUE[12] = 0

    // Test 13: Query float as long (should fail)
    TOML_QUERY_LONG_INPUT[13] = 'pi = 3.14'
    TOML_QUERY_LONG_PATH[13] = '.pi'
    TOML_QUERY_LONG_EXPECTED_VALUE[13] = 0

    // Test 14: Very large long
    TOML_QUERY_LONG_INPUT[14] = 'huge = 4000000000'
    TOML_QUERY_LONG_PATH[14] = '.huge'
    TOML_QUERY_LONG_EXPECTED_VALUE[14] = 4000000000

    // Test 15: Dotted key long
    TOML_QUERY_LONG_INPUT[15] = 'metrics.total.count = 3500000000'
    TOML_QUERY_LONG_PATH[15] = '.metrics.total.count'
    TOML_QUERY_LONG_EXPECTED_VALUE[15] = 3500000000

    set_length_array(TOML_QUERY_LONG_INPUT, 15)
    set_length_array(TOML_QUERY_LONG_PATH, 15)
}


define_function TestNAVTomlQueryLong() {
    stack_var integer x


    NAVLogTestSuiteStart("'NAVTomlQueryLong'")

    InitializeTomlQueryLongTestData()

    for (x = 1; x <= length_array(TOML_QUERY_LONG_INPUT); x++) {
        stack_var _NAVToml toml
        stack_var long result
        stack_var char queryResult

        // Parse TOML
        if (!NAVTomlParse(TOML_QUERY_LONG_INPUT[x], toml)) {
            NAVLogTestFailed(x, "'Parse success'", "'Parse failed'")
            continue
        }

        // Execute long query
        queryResult = NAVTomlQueryLong(toml, TOML_QUERY_LONG_PATH[x], result)

        // Assert query result
        if (TOML_QUERY_LONG_EXPECTED_RESULT[x]) {
            // Expected to succeed
            if (!queryResult) {
                NAVLogTestFailed(x, "'Query success'", "'Query failed'")
                continue
            }
            if (!NAVAssertLongEqual('Long value should match',
                                    TOML_QUERY_LONG_EXPECTED_VALUE[x],
                                    result)) {
                NAVLogTestFailed(x,
                                itoa(TOML_QUERY_LONG_EXPECTED_VALUE[x]),
                                itoa(result))
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

    NAVLogTestSuiteEnd("'NAVTomlQueryLong'")
}
