PROGRAM_NAME='NAVIniFileGetIntegerValue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVIniFileGetIntegerValue - Valid integers
constant char INTEGER_VALID_TEST_KEYS[][64] = {
    'int_zero',         // Value: 0
    'int_positive',     // Value: 42
    'int_large',        // Value: 32767
    'int_max',          // Value: 65535
    'int_leading_zero', // Value: 0123 (should be 123)
    'int_spaces',       // Value: "  456  " (with spaces)
    'section1.port',    // Section value: 5432
    'section1.timeout', // Section value: 30
    'section1.retries'  // Section value: 3
}

constant integer INTEGER_VALID_EXPECTED[] = {
    0,      // int_zero
    42,     // int_positive
    32767,  // int_large
    65535,  // int_max
    123,    // int_leading_zero (atoi parses as 123)
    456,    // int_spaces (atoi trims)
    5432,   // section1.port
    30,     // section1.timeout
    3       // section1.retries
}

// Test cases for default value returns (missing or invalid)
constant char INTEGER_DEFAULT_TEST_KEYS[][64] = {
    'nonexistent',      // Key doesn't exist
    'section1.missing', // Key doesn't exist in section
    'missing.key',      // Section doesn't exist
    'int_invalid',      // Invalid value: 'abc'
    'int_float',        // Float value: '3.14' (atoi returns 3)
    'int_mixed',        // Mixed value: '12abc' (atoi returns 12)
    'int_empty',        // Empty value
    ''                  // Empty key
}

constant integer INTEGER_DEFAULT_VALUES[] = {
    65535,  // Test with max value as default
    0,      // Test with 0 as default
    100,    // Test with 100 as default
    999,    // Test with 999 as default
    3,      // Float converts to 3 (atoi behavior)
    12,     // Mixed converts to 12 (atoi behavior)
    42,     // Empty returns default
    100     // Empty key returns default
}

DEFINE_VARIABLE

// Test data for GetIntegerValue tests
volatile char INTEGER_GET_INI_DATA[2048]

/**
 * Initialize test data for GetIntegerValue tests
 */
define_function InitializeIntegerGetTestData() {
    INTEGER_GET_INI_DATA = "
        '; Valid integers', 10,
        'int_zero=0', 10,
        'int_positive=42', 10,
        'int_large=32767', 10,
        'int_max=65535', 10,
        'int_leading_zero=0123', 10,
        'int_spaces=  456  ', 10,
        10,
        '; Invalid values', 10,
        'int_invalid=abc', 10,
        'int_float=3.14', 10,
        'int_mixed=12abc', 10,
        'int_empty=', 10,
        10,
        '[section1]', 10,
        'port=5432', 10,
        'timeout=30', 10,
        'retries=3', 10
    "
}

/**
 * Test NAVIniFileGetIntegerValue function
 */
define_function TestNAVIniFileGetIntegerValue() {
    stack_var _NAVIniFile testIni
    stack_var integer i
    stack_var integer result

    NAVLog("'***************** NAVIniFileGetIntegerValue *****************'")

    // Initialize test data
    InitializeIntegerGetTestData()

    // Parse the test INI data
    if (!NAVIniFileParse(INTEGER_GET_INI_DATA, testIni)) {
        NAVLog("'Failed to parse test INI data for GetIntegerValue tests'")
        return
    }

    NAVLog("'--- Testing Valid Integers ---'")

    // Test all valid integer conversions
    for (i = 1; i <= length_array(INTEGER_VALID_TEST_KEYS); i++) {
        result = NAVIniFileGetIntegerValue(testIni, INTEGER_VALID_TEST_KEYS[i], 999)

        if (!NAVAssertIntegerEqual('GetIntegerValue Valid Test', INTEGER_VALID_EXPECTED[i], result)) {
            NAVLogTestFailed(i, itoa(INTEGER_VALID_EXPECTED[i]), itoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    NAVLog("'--- Testing Default Values ---'")

    // Test default value returns for missing/invalid keys
    for (i = 1; i <= length_array(INTEGER_DEFAULT_TEST_KEYS); i++) {
        stack_var integer expected

        expected = INTEGER_DEFAULT_VALUES[i]
        result = NAVIniFileGetIntegerValue(testIni, INTEGER_DEFAULT_TEST_KEYS[i], expected)

        if (!NAVAssertIntegerEqual('GetIntegerValue Default Test', expected, result)) {
            NAVLogTestFailed(i, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    // Additional verification tests
    TestIntegerGetVerification()
}

/**
 * Additional verification tests for GetIntegerValue
 */
define_function TestIntegerGetVerification() {
    stack_var _NAVIniFile testIni
    stack_var char testData[1024]
    stack_var integer result

    NAVLog("'--- GetIntegerValue Verification ---'")

    // Test 1: Empty INI - should return default
    if (!NAVIniFileParse('', testIni)) {
        NAVLog("'Failed to parse empty INI data'")
        return
    }

    result = NAVIniFileGetIntegerValue(testIni, 'anykey', 12345)
    if (result == 12345) {
        NAVLog("'Pass: Empty INI returns default value'")
    } else {
        NAVLog("'Fail: Empty INI should return default'")
    }

    // Test 2: Boundary values
    testData = "
        'max_value=65535', 10,
        'min_value=0', 10,
        'overflow=99999', 10
    "

    if (!NAVIniFileParse(testData, testIni)) {
        NAVLog("'Failed to parse boundary test data'")
        return
    }

    result = NAVIniFileGetIntegerValue(testIni, 'max_value', 0)
    if (result == 65535) {
        NAVLog("'Pass: Maximum integer value (65535) works'")
    } else {
        NAVLog("'Fail: Maximum integer value incorrect'")
    }

    result = NAVIniFileGetIntegerValue(testIni, 'min_value', 999)
    if (result == 0) {
        NAVLog("'Pass: Minimum integer value (0) works'")
    } else {
        NAVLog("'Fail: Minimum integer value incorrect'")
    }

    // Test 3: Hexadecimal strings (atoi doesn't parse hex, implementation validates)
    testData = "
        'hex1=0xFF', 10,
        'hex2=0x10', 10
    "

    if (!NAVIniFileParse(testData, testIni)) {
        NAVLog("'Failed to parse hex test data'")
        return
    }

    result = NAVIniFileGetIntegerValue(testIni, 'hex1', 65535)
    if (result == 0) {
        NAVLog("'Pass: Hex strings (0xFF) parse as 0 (ATOI behavior)'")
    } else {
        NAVLog("'Fail: Hex string conversion unexpected'")
    }

    // Test 4: Strings with trailing characters (implementation validates as invalid)
    testData = "
        'partial1=123abc', 10,
        'partial2=456 def', 10,
        'partial3=78.9xyz', 10
    "

    if (!NAVIniFileParse(testData, testIni)) {
        NAVLog("'Failed to parse partial test data'")
        return
    }

    result = NAVIniFileGetIntegerValue(testIni, 'partial1', 999)
    if (result == 123) {
        NAVLog("'Pass: Strings with trailing chars parse first number (123abc -> 123)'")
    } else {
        NAVLog("'Fail: Partial conversion incorrect'")
    }

    // Test 5: Multiple sections with same key name
    testData = "
        'value=10', 10,
        10,
        '[section1]', 10,
        'value=20', 10,
        10,
        '[section2]', 10,
        'value=30', 10
    "

    if (!NAVIniFileParse(testData, testIni)) {
        NAVLog("'Failed to parse multi-section test data'")
        return
    }

    if (NAVIniFileGetIntegerValue(testIni, 'value', 0) == 10 &&
        NAVIniFileGetIntegerValue(testIni, 'section1.value', 0) == 20 &&
        NAVIniFileGetIntegerValue(testIni, 'section2.value', 0) == 30) {
        NAVLog("'Pass: Multiple sections with same key name work correctly'")
    } else {
        NAVLog("'Fail: Multiple sections with same key name'")
    }

    // Test 6: Leading/trailing whitespace
    testData = "
        'trim1=  123', 10,
        'trim2=456  ', 10,
        'trim3=  789  ', 10
    "

    if (!NAVIniFileParse(testData, testIni)) {
        NAVLog("'Failed to parse whitespace test data'")
        return
    }

    if (NAVIniFileGetIntegerValue(testIni, 'trim1', 0) == 123 &&
        NAVIniFileGetIntegerValue(testIni, 'trim2', 0) == 456 &&
        NAVIniFileGetIntegerValue(testIni, 'trim3', 0) == 789) {
        NAVLog("'Pass: Whitespace trimming works correctly'")
    } else {
        NAVLog("'Fail: Whitespace trimming incorrect'")
    }
}
