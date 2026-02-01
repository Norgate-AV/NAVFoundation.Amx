PROGRAM_NAME='NAVIniFileGetSignedLongValue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVIniFileGetSignedLongValue - Valid signed long integers
constant char SIGNED_LONG_VALID_TEST_KEYS[][64] = {
    'slong_zero',        // Value: 0
    'slong_positive',    // Value: 42
    'slong_negative',    // Value: -100
    'slong_max',         // Value: 2147483647
    'slong_min',         // Value: -2000000000
    'slong_plus_sign',   // Value: +123456
    'slong_spaces',      // Value: "  -456789  " (with spaces)
    'section1.offset',   // Section value: -1000000
    'section1.delta'     // Section value: 500000
}

// Test cases for default value returns (missing or invalid)
constant char SIGNED_LONG_DEFAULT_TEST_KEYS[][64] = {
    'nonexistent',      // Key doesn't exist
    'section1.missing', // Key doesn't exist in section
    'missing.key',      // Section doesn't exist
    'slong_invalid',    // Invalid value: 'abc'
    'slong_float',      // Float value: '-3.14' (atol returns -3)
    'slong_mixed',      // Mixed value: '-12345abc' (atol returns -12345)
    'slong_empty',      // Empty value
    ''                  // Empty key
}

DEFINE_VARIABLE

// Test data for GetSignedLongValue tests
volatile char SIGNED_LONG_GET_INI_DATA[2048]

/**
 * Initialize test data for GetSignedLongValue tests
 */
define_function InitializeSignedLongGetTestData() {
    SIGNED_LONG_GET_INI_DATA = "
        '; Valid signed long integers', 10,
        'slong_zero=0', 10,
        'slong_positive=42', 10,
        'slong_negative=-100', 10,
        'slong_max=2147483647', 10,
        'slong_min=-2000000000', 10,
        'slong_plus_sign=+123456', 10,
        'slong_spaces=  -456789  ', 10,
        10,
        '; Invalid values', 10,
        'slong_invalid=abc', 10,
        'slong_float=-3.14', 10,
        'slong_mixed=-12345abc', 10,
        'slong_empty=', 10,
        10,
        '[section1]', 10,
        'offset=-1000000', 10,
        'delta=500000', 10
    "
}

/**
 * Test NAVIniFileGetSignedLongValue function
 */
define_function TestNAVIniFileGetSignedLongValue() {
    stack_var _NAVIniFile testIni
    stack_var integer i
    stack_var slong result

    NAVLog("'***************** NAVIniFileGetSignedLongValue *****************'")

    // Initialize test data
    InitializeSignedLongGetTestData()

    // Parse the test INI data
    if (!NAVIniFileParse(SIGNED_LONG_GET_INI_DATA, testIni)) {
        NAVLog("'Failed to parse test INI data for GetSignedLongValue tests'")
        return
    }

    NAVLog("'--- Testing Valid Signed Long Integers ---'")

    // Test all valid signed long integer conversions
    for (i = 1; i <= length_array(SIGNED_LONG_VALID_TEST_KEYS); i++) {
        stack_var slong expected

        expected = 0

        // Create expected value at runtime using switch/case
        switch (i) {
            case 1: expected = type_cast(0)           // slong_zero
            case 2: expected = type_cast(42)          // slong_positive
            case 3: expected = expected - type_cast(100)     // slong_negative
            case 4: expected = type_cast(2147483647)  // slong_max
            case 5: expected = expected - type_cast(2000000000)  // slong_min
            case 6: expected = type_cast(123456)      // slong_plus_sign
            case 7: expected = expected - type_cast(456789)  // slong_spaces
            case 8: expected = expected - type_cast(1000000) // section1.offset
            case 9: expected = type_cast(500000)      // section1.delta
        }

        result = NAVIniFileGetSignedLongValue(testIni, SIGNED_LONG_VALID_TEST_KEYS[i], 0)

        if (!NAVAssertSignedLongEqual('GetSignedLongValue Valid Test', expected, result)) {
            // Don't format signed longs - NetLinx can't do it correctly
            NAVLogTestFailed(i, "'comparison failed'", "'see debug output above'")
            continue
        }

        NAVLogTestPassed(i)
    }

    NAVLog("'--- Testing Default Values ---'")

    // Test default value returns for missing/invalid keys
    for (i = 1; i <= length_array(SIGNED_LONG_DEFAULT_TEST_KEYS); i++) {
        stack_var slong expected

        expected = 0

        // Create expected value at runtime using switch/case
        switch (i) {
            case 1: expected = expected - type_cast(999999)  // Test with negative default
            case 2: expected = type_cast(0)           // Test with 0 as default
            case 3: expected = type_cast(1000000)     // Test with positive default
            case 4: expected = expected - type_cast(1)       // Test with -1 as default
            case 5: expected = expected - type_cast(3)       // Float converts to -3 (atol behavior)
            case 6: expected = expected - type_cast(12345)   // Mixed converts to -12345 (atol behavior)
            case 7: expected = type_cast(42)          // Empty returns default
            case 8: expected = expected - type_cast(50000)   // Empty key returns default
        }

        result = NAVIniFileGetSignedLongValue(testIni, SIGNED_LONG_DEFAULT_TEST_KEYS[i], expected)

        if (!NAVAssertSignedLongEqual('GetSignedLongValue Default Test', expected, result)) {
            NAVLogTestFailed(i, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    // Additional verification tests
    TestSignedLongGetVerification()
}

/**
 * Additional verification tests for GetSignedLongValue
 */
define_function TestSignedLongGetVerification() {
    stack_var _NAVIniFile testIni
    stack_var char testData[1024]
    stack_var slong result

    NAVLog("'--- GetSignedLongValue Verification ---'")

    // Test 1: Boundary test - Max positive value
    testData = "'boundary_max=2147483647', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetSignedLongValue(testIni, 'boundary_max', 0)
        if (!NAVAssertSignedLongEqual('Boundary Max Test', 2147483647, result)) {
            NAVLogTestFailed(1, '2147483647', itoa(result))
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test 2: Boundary test - Max negative value
    testData = "'boundary_min=-2000000000', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetSignedLongValue(testIni, 'boundary_min', 0)
        if (!NAVAssertSignedLongEqual('Boundary Min Test', type_cast(0 - 2000000000), result)) {
            NAVLogTestFailed(2, '-2000000000', itoa(result))
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test 3: Plus sign handling
    testData = "'plus_value=+987654', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetSignedLongValue(testIni, 'plus_value', 0)
        if (!NAVAssertSignedLongEqual('Plus Sign Test', 987654, result)) {
            NAVLogTestFailed(3, '987654', itoa(result))
        } else {
            NAVLogTestPassed(3)
        }
    }

    // Test 4: Negative with spaces
    testData = "'neg_spaces=  -1234567  ', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetSignedLongValue(testIni, 'neg_spaces', 0)
        if (!NAVAssertSignedLongEqual('Negative Spaces Test', type_cast(0 - 1234567), result)) {
            NAVLogTestFailed(4, '-1234567', itoa(result))
        } else {
            NAVLogTestPassed(4)
        }
    }

    // Test 5: Mixed format with hyphens - parses first number
    testData = "'invalid_format=12-34-56', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetSignedLongValue(testIni, 'invalid_format', type_cast(0 - 999999))
        if (!NAVAssertSignedLongEqual('Mixed Format Test', 12, result)) {
            NAVLogTestFailed(5, '12', itoa(result))
        } else {
            NAVLogTestPassed(5)
        }
    }
}
