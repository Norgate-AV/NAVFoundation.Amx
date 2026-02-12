PROGRAM_NAME='NAVTomlQueryInteger'

#include 'NAVFoundation.Toml.axi'

DEFINE_VARIABLE

volatile char TOML_QUERY_INTEGER_INPUT[20][2048]
volatile char TOML_QUERY_INTEGER_PATH[20][256]

constant char TOML_QUERY_INTEGER_EXPECTED_RESULT[] = {
    true,   // Test 1: Positive integer
    true,   // Test 2: Small positive integer
    true,   // Test 3: Zero
    true,   // Test 4: Hexadecimal
    true,   // Test 5: Octal
    true,   // Test 6: Binary
    true,   // Test 7: Integer with underscores
    true,   // Test 8: Nested integer
    true,   // Test 9: Integer in array element
    true,   // Test 10: Integer in inline table
    true,   // Test 11: Integer in array of tables
    false,  // Test 12: Query string as integer (should fail)
    false,  // Test 13: Query boolean as integer (should fail)
    false,  // Test 14: Query float as integer (should fail)
    true,   // Test 15: Large positive integer
    true,   // Test 16: Maximum 16-bit integer
    true,   // Test 17: Integer in deep nesting
    true,   // Test 18: Dotted key integer
    false,  // Test 19: Query array as integer (should fail)
    true    // Test 20: Multiple integers
}

constant integer TOML_QUERY_INTEGER_EXPECTED_VALUE[] = {
    42,         // Test 1
    100,        // Test 2
    0,          // Test 3
    255,        // Test 4: 0xFF
    493,        // Test 5: 0o755
    214,        // Test 6: 0b11010110
    10000,      // Test 7
    8080,       // Test 8
    20,         // Test 9
    5000,       // Test 10
    55555,      // Test 11
    0,          // Test 12 (not used, fail case)
    0,          // Test 13 (not used, fail case)
    0,          // Test 14 (not used, fail case)
    50000,      // Test 15
    65535,      // Test 16
    300,        // Test 17
    123,        // Test 18
    0,          // Test 19 (not used, fail case)
    30          // Test 20
}


define_function InitializeTomlQueryIntegerTestData() {
    // Test 1: Positive integer
    TOML_QUERY_INTEGER_INPUT[1] = 'number = 42'
    TOML_QUERY_INTEGER_PATH[1] = '.number'

    // Test 2: Small positive integer
    TOML_QUERY_INTEGER_INPUT[2] = 'count = 100'
    TOML_QUERY_INTEGER_PATH[2] = '.count'

    // Test 3: Zero
    TOML_QUERY_INTEGER_INPUT[3] = 'zero = 0'
    TOML_QUERY_INTEGER_PATH[3] = '.zero'

    // Test 4: Hexadecimal
    TOML_QUERY_INTEGER_INPUT[4] = 'hex = 0xFF'
    TOML_QUERY_INTEGER_PATH[4] = '.hex'

    // Test 5: Octal
    TOML_QUERY_INTEGER_INPUT[5] = 'oct = 0o755'
    TOML_QUERY_INTEGER_PATH[5] = '.oct'

    // Test 6: Binary
    TOML_QUERY_INTEGER_INPUT[6] = 'bin = 0b11010110'
    TOML_QUERY_INTEGER_PATH[6] = '.bin'

    // Test 7: Integer with underscores
    TOML_QUERY_INTEGER_INPUT[7] = 'large = 10_000'
    TOML_QUERY_INTEGER_PATH[7] = '.large'

    // Test 8: Nested integer
    TOML_QUERY_INTEGER_INPUT[8] = "'[server]', 13, 10, 'port = 8080', 13, 10"
    TOML_QUERY_INTEGER_PATH[8] = '.server.port'

    // Test 9: Integer in array element
    TOML_QUERY_INTEGER_INPUT[9] = 'numbers = [10, 20, 30]'
    TOML_QUERY_INTEGER_PATH[9] = '.numbers[2]'

    // Test 10: Integer in inline table
    TOML_QUERY_INTEGER_INPUT[10] = 'database = { max_connections = 5000 }'
    TOML_QUERY_INTEGER_PATH[10] = '.database.max_connections'

    // Test 11: Integer in array of tables
    TOML_QUERY_INTEGER_INPUT[11] = "'[[products]]', 13, 10, 'sku = 55555', 13, 10"
    TOML_QUERY_INTEGER_PATH[11] = '.products[1].sku'

    // Test 12: Query string as integer (should fail)
    TOML_QUERY_INTEGER_INPUT[12] = 'text = "not a number"'
    TOML_QUERY_INTEGER_PATH[12] = '.text'

    // Test 13: Query boolean as integer (should fail)
    TOML_QUERY_INTEGER_INPUT[13] = 'flag = true'
    TOML_QUERY_INTEGER_PATH[13] = '.flag'

    // Test 14: Query float as integer (should fail)
    TOML_QUERY_INTEGER_INPUT[14] = 'pi = 3.14'
    TOML_QUERY_INTEGER_PATH[14] = '.pi'

    // Test 15: Large positive integer
    TOML_QUERY_INTEGER_INPUT[15] = 'big = 50000'
    TOML_QUERY_INTEGER_PATH[15] = '.big'

    // Test 16: Maximum 16-bit integer
    TOML_QUERY_INTEGER_INPUT[16] = 'maxval = 65535'
    TOML_QUERY_INTEGER_PATH[16] = '.maxval'

    // Test 17: Integer in deep nesting
    TOML_QUERY_INTEGER_INPUT[17] = "'[a]', 13, 10, '[a.b]', 13, 10, '[a.b.c]', 13, 10, 'timeout = 300', 13, 10"
    TOML_QUERY_INTEGER_PATH[17] = '.a.b.c.timeout'

    // Test 18: Dotted key integer
    TOML_QUERY_INTEGER_INPUT[18] = 'config.retry.count = 123'
    TOML_QUERY_INTEGER_PATH[18] = '.config.retry.count'

    // Test 19: Query array as integer (should fail)
    TOML_QUERY_INTEGER_INPUT[19] = 'arr = [1, 2, 3]'
    TOML_QUERY_INTEGER_PATH[19] = '.arr'

    // Test 20: Multiple integers
    TOML_QUERY_INTEGER_INPUT[20] = "'first = 10', 13, 10, 'second = 20', 13, 10, 'third = 30', 13, 10"
    TOML_QUERY_INTEGER_PATH[20] = '.third'

    set_length_array(TOML_QUERY_INTEGER_INPUT, 20)
    set_length_array(TOML_QUERY_INTEGER_PATH, 20)
}


define_function TestNAVTomlQueryInteger() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlQueryInteger'")

    InitializeTomlQueryIntegerTestData()

    for (x = 1; x <= length_array(TOML_QUERY_INTEGER_INPUT); x++) {
        stack_var _NAVToml toml
        stack_var integer result
        stack_var char queryResult

        // Parse TOML
        if (!NAVTomlParse(TOML_QUERY_INTEGER_INPUT[x], toml)) {
            NAVLogTestFailed(x, "'Parse success'", "'Parse failed'")
            continue
        }

        // Execute integer query
        queryResult = NAVTomlQueryInteger(toml, TOML_QUERY_INTEGER_PATH[x], result)

        // Assert query result
        if (TOML_QUERY_INTEGER_EXPECTED_RESULT[x]) {
            // Expected to succeed
            if (!queryResult) {
                NAVLogTestFailed(x, "'Query success'", "'Query failed'")
                continue
            }
            if (!NAVAssertIntegerEqual('Integer value should match',
                                       TOML_QUERY_INTEGER_EXPECTED_VALUE[x],
                                       result)) {
                NAVLogTestFailed(x,
                                itoa(TOML_QUERY_INTEGER_EXPECTED_VALUE[x]),
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

    NAVLogTestSuiteEnd("'NAVTomlQueryInteger'")
}

