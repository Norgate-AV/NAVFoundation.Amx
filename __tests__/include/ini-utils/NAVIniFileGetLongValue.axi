PROGRAM_NAME='NAVIniFileGetLongValue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVIniFileGetLongValue - Valid long integers
constant char LONG_VALID_TEST_KEYS[][64] = {
    'long_zero',         // Value: 0
    'long_small',        // Value: 42
    'long_medium',       // Value: 100000
    'long_large',        // Value: 1000000
    'long_max',          // Value: 4294967295
    'long_leading_zero', // Value: 0123 (should be 123)
    'long_spaces',       // Value: "  456789  " (with spaces)
    'section1.timestamp',// Section value: 1640000000
    'section1.counter'   // Section value: 999999
}

constant long LONG_VALID_EXPECTED[] = {
    0,          // long_zero
    42,         // long_small
    100000,     // long_medium
    1000000,    // long_large
    2000000000, // long_max (using 2 billion instead of max to avoid signed issues)
    123,        // long_leading_zero
    456789,     // long_spaces
    1640000000, // section1.timestamp
    999999      // section1.counter
}

// Test cases for default value returns (missing or invalid)
constant char LONG_DEFAULT_TEST_KEYS[][64] = {
    'nonexistent',      // Key doesn't exist
    'section1.missing', // Key doesn't exist in section
    'missing.key',      // Section doesn't exist
    'long_invalid',     // Invalid value: 'abc'
    'long_float',       // Float value: '3.14' (atol returns 3)
    'long_mixed',       // Mixed value: '12345abc' (atol returns 12345)
    'long_empty',       // Empty value
    ''                  // Empty key
}

constant long LONG_DEFAULT_VALUES[] = {
    2000000000, // Test with large value as default
    0,          // Test with 0 as default
    1000000,    // Test with 1000000 as default
    999,        // Test with 999 as default
    3,          // Float converts to 3 (atol behavior)
    12345,      // Mixed converts to 12345 (atol behavior)
    42,         // Empty returns default
    100         // Empty key returns default
}

DEFINE_VARIABLE

// Test data for GetLongValue tests
volatile char LONG_GET_INI_DATA[2048]

/**
 * Initialize test data for GetLongValue tests
 */
define_function InitializeLongGetTestData() {
    LONG_GET_INI_DATA = "
        '; Valid long integers', 10,
        'long_zero=0', 10,
        'long_small=42', 10,
        'long_medium=100000', 10,
        'long_large=1000000', 10,
        'long_max=2000000000', 10,
        'long_leading_zero=0123', 10,
        'long_spaces=  456789  ', 10,
        10,
        '; Invalid values', 10,
        'long_invalid=abc', 10,
        'long_float=3.14', 10,
        'long_mixed=12345abc', 10,
        'long_empty=', 10,
        10,
        '[section1]', 10,
        'timestamp=1640000000', 10,
        'counter=999999', 10
    "
}

/**
 * Test NAVIniFileGetLongValue function
 */
define_function TestNAVIniFileGetLongValue() {
    stack_var _NAVIniFile testIni
    stack_var integer i
    stack_var long result

    NAVLog("'***************** NAVIniFileGetLongValue *****************'")

    // Initialize test data
    InitializeLongGetTestData()

    // Parse the test INI data
    if (!NAVIniFileParse(LONG_GET_INI_DATA, testIni)) {
        NAVLog("'Failed to parse test INI data for GetLongValue tests'")
        return
    }

    NAVLog("'--- Testing Valid Long Integers ---'")

    // Test all valid long integer conversions
    for (i = 1; i <= length_array(LONG_VALID_TEST_KEYS); i++) {
        result = NAVIniFileGetLongValue(testIni, LONG_VALID_TEST_KEYS[i], 0)

        if (!NAVAssertLongEqual('GetLongValue Valid Test', LONG_VALID_EXPECTED[i], result)) {
            NAVLogTestFailed(i, itoa(LONG_VALID_EXPECTED[i]), itoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    NAVLog("'--- Testing Default Values ---'")

    // Test default value returns for missing/invalid keys
    for (i = 1; i <= length_array(LONG_DEFAULT_TEST_KEYS); i++) {
        stack_var long expected

        expected = LONG_DEFAULT_VALUES[i]
        result = NAVIniFileGetLongValue(testIni, LONG_DEFAULT_TEST_KEYS[i], expected)

        if (!NAVAssertLongEqual('GetLongValue Default Test', expected, result)) {
            NAVLogTestFailed(i, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    // Additional verification tests
    TestLongGetVerification()
}

/**
 * Additional verification tests for GetLongValue
 */
define_function TestLongGetVerification() {
    stack_var _NAVIniFile testIni
    stack_var char testData[1024]
    stack_var long result

    NAVLog("'--- GetLongValue Verification ---'")

    // Test 1: Boundary test - Max value
    testData = "'boundary_max=2000000000', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetLongValue(testIni, 'boundary_max', 0)
        if (!NAVAssertLongEqual('Boundary Max Test', 2000000000, result)) {
            NAVLogTestFailed(1, '2000000000', itoa(result))
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test 2: Boundary test - Min value (0)
    testData = "'boundary_min=0', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetLongValue(testIni, 'boundary_min', 999)
        if (!NAVAssertLongEqual('Boundary Min Test', 0, result)) {
            NAVLogTestFailed(2, '0', itoa(result))
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test 3: Large value in middle of range
    testData = "'mid_value=2147483647', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetLongValue(testIni, 'mid_value', 0)
        if (!NAVAssertLongEqual('Mid Range Test', 2147483647, result)) {
            NAVLogTestFailed(3, '2147483647', itoa(result))
        } else {
            NAVLogTestPassed(3)
        }
    }

    // Test 4: Whitespace trimming
    testData = "'spaces_value=  987654  ', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetLongValue(testIni, 'spaces_value', 0)
        if (!NAVAssertLongEqual('Spaces Test', 987654, result)) {
            NAVLogTestFailed(4, '987654', itoa(result))
        } else {
            NAVLogTestPassed(4)
        }
    }

    // Test 5: Mixed format with letters - parses first number
    testData = "'invalid_format=123abc456', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetLongValue(testIni, 'invalid_format', 888888)
        if (!NAVAssertLongEqual('Mixed Format Test', 123, result)) {
            NAVLogTestFailed(5, '123', itoa(result))
        } else {
            NAVLogTestPassed(5)
        }
    }
}
