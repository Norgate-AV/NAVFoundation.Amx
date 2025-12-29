PROGRAM_NAME='NAVIniFileGetSignedIntegerValue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVIniFileGetSignedIntegerValue - Valid signed integers
constant char SIGNED_INTEGER_VALID_TEST_KEYS[][64] = {
    'sint_zero',         // Value: 0
    'sint_positive',     // Value: 42
    'sint_negative',     // Value: -100
    'sint_max',          // Value: 32767
    'sint_min',          // Value: -32768
    'sint_plus_sign',    // Value: +25
    'sint_spaces',       // Value: "  -456  " (with spaces)
    'section1.offset',   // Section value: -10
    'section1.adjustment' // Section value: 15
}

constant sinteger SIGNED_INTEGER_VALID_EXPECTED[] = {
    0,      // sint_zero
    42,     // sint_positive
    -100,   // sint_negative
    32767,  // sint_max
    -32768, // sint_min
    25,     // sint_plus_sign
    -456,   // sint_spaces
    -10,    // section1.offset
    15      // section1.adjustment
}

// Test cases for default value returns (missing or invalid)
constant char SIGNED_INTEGER_DEFAULT_TEST_KEYS[][64] = {
    'nonexistent',      // Key doesn't exist
    'section1.missing', // Key doesn't exist in section
    'missing.key',      // Section doesn't exist
    'sint_invalid',     // Invalid value: 'abc'
    'sint_float',       // Float value: '-3.14' (atoi returns -3)
    'sint_mixed',       // Mixed value: '-12abc' (atoi returns -12)
    'sint_empty',       // Empty value
    ''                  // Empty key
}

constant sinteger SIGNED_INTEGER_DEFAULT_VALUES[] = {
    -999,   // Test with negative default
    0,      // Test with 0 as default
    100,    // Test with positive default
    -1,     // Test with -1 as default
    -3,     // Float converts to -3 (atoi behavior)
    -12,    // Mixed converts to -12 (atoi behavior)
    42,     // Empty returns default
    -50     // Empty key returns default
}

DEFINE_VARIABLE

// Test data for GetSignedIntegerValue tests
volatile char SIGNED_INTEGER_GET_INI_DATA[2048]

/**
 * Initialize test data for GetSignedIntegerValue tests
 */
define_function InitializeSignedIntegerGetTestData() {
    SIGNED_INTEGER_GET_INI_DATA = "
        '; Valid signed integers', 10,
        'sint_zero=0', 10,
        'sint_positive=42', 10,
        'sint_negative=-100', 10,
        'sint_max=32767', 10,
        'sint_min=-32768', 10,
        'sint_plus_sign=+25', 10,
        'sint_spaces=  -456  ', 10,
        10,
        '; Invalid values', 10,
        'sint_invalid=abc', 10,
        'sint_float=-3.14', 10,
        'sint_mixed=-12abc', 10,
        'sint_empty=', 10,
        10,
        '[section1]', 10,
        'offset=-10', 10,
        'adjustment=15', 10
    "
}

/**
 * Test NAVIniFileGetSignedIntegerValue function
 */
define_function TestNAVIniFileGetSignedIntegerValue() {
    stack_var _NAVIniFile testIni
    stack_var integer i
    stack_var sinteger result

    NAVLog("'***************** NAVIniFileGetSignedIntegerValue *****************'")

    // Initialize test data
    InitializeSignedIntegerGetTestData()

    // Parse the test INI data
    if (!NAVIniFileParse(SIGNED_INTEGER_GET_INI_DATA, testIni)) {
        NAVLog("'Failed to parse test INI data for GetSignedIntegerValue tests'")
        return
    }

    NAVLog("'--- Testing Valid Signed Integers ---'")

    // Test all valid signed integer conversions
    for (i = 1; i <= length_array(SIGNED_INTEGER_VALID_TEST_KEYS); i++) {
        result = NAVIniFileGetSignedIntegerValue(testIni, SIGNED_INTEGER_VALID_TEST_KEYS[i], -999)

        if (!NAVAssertSignedIntegerEqual('GetSignedIntegerValue Valid Test', SIGNED_INTEGER_VALID_EXPECTED[i], result)) {
            NAVLogTestFailed(i, itoa(SIGNED_INTEGER_VALID_EXPECTED[i]), itoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    NAVLog("'--- Testing Default Values ---'")

    // Test default value returns for missing/invalid keys
    for (i = 1; i <= length_array(SIGNED_INTEGER_DEFAULT_TEST_KEYS); i++) {
        stack_var sinteger expected

        expected = SIGNED_INTEGER_DEFAULT_VALUES[i]
        result = NAVIniFileGetSignedIntegerValue(testIni, SIGNED_INTEGER_DEFAULT_TEST_KEYS[i], expected)

        if (!NAVAssertSignedIntegerEqual('GetSignedIntegerValue Default Test', expected, result)) {
            NAVLogTestFailed(i, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    // Additional verification tests
    TestSignedIntegerGetVerification()
}

/**
 * Additional verification tests for GetSignedIntegerValue
 */
define_function TestSignedIntegerGetVerification() {
    stack_var _NAVIniFile testIni
    stack_var char testData[1024]
    stack_var sinteger result

    NAVLog("'--- GetSignedIntegerValue Verification ---'")

    // Test 1: Boundary test - Max positive value
    testData = "'boundary_max=32767', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetSignedIntegerValue(testIni, 'boundary_max', 0)
        if (!NAVAssertSignedIntegerEqual('Boundary Max Test', 32767, result)) {
            NAVLogTestFailed(1, '32767', itoa(result))
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test 2: Boundary test - Max negative value
    testData = "'boundary_min=-32768', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetSignedIntegerValue(testIni, 'boundary_min', 0)
        if (!NAVAssertSignedIntegerEqual('Boundary Min Test', -32768, result)) {
            NAVLogTestFailed(2, '-32768', itoa(result))
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test 3: Plus sign handling
    testData = "'plus_value=+123', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetSignedIntegerValue(testIni, 'plus_value', 0)
        if (!NAVAssertSignedIntegerEqual('Plus Sign Test', 123, result)) {
            NAVLogTestFailed(3, '123', itoa(result))
        } else {
            NAVLogTestPassed(3)
        }
    }

    // Test 4: Negative with spaces
    testData = "'neg_spaces=  -789  ', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetSignedIntegerValue(testIni, 'neg_spaces', 0)
        if (!NAVAssertSignedIntegerEqual('Negative Spaces Test', -789, result)) {
            NAVLogTestFailed(4, '-789', itoa(result))
        } else {
            NAVLogTestPassed(4)
        }
    }

    // Test 5: Invalid format with invalid characters
    testData = "'invalid_format=12-34', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetSignedIntegerValue(testIni, 'invalid_format', -999)
        if (!NAVAssertSignedIntegerEqual('Invalid Format Test', -999, result)) {
            NAVLogTestFailed(5, '-999', itoa(result))
        } else {
            NAVLogTestPassed(5)
        }
    }
}
