PROGRAM_NAME='NAVIniFileGetFloatValue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVIniFileGetFloatValue - Valid float values
constant char FLOAT_VALID_TEST_KEYS[][64] = {
    'float_zero',        // Value: 0.0
    'float_integer',     // Value: 42
    'float_positive',    // Value: 3.14
    'float_negative',    // Value: -2.5
    'float_large',       // Value: 9999.99
    'float_small',       // Value: 0.001
    'float_plus_sign',   // Value: +1.5
    'float_no_leading',  // Value: .5 (without leading zero)
    'float_spaces',      // Value: "  -456.78  " (with spaces)
    'section1.scale',    // Section value: 1.0
    'section1.threshold' // Section value: 0.5
}

constant float FLOAT_VALID_EXPECTED[] = {
    0.0,        // float_zero
    42.0,       // float_integer
    3.14,       // float_positive
    -2.5,       // float_negative
    9999.99,    // float_large
    0.001,      // float_small
    1.5,        // float_plus_sign
    0.5,        // float_no_leading
    -456.78,    // float_spaces
    1.0,        // section1.scale
    0.5         // section1.threshold
}

// Test cases for default value returns (missing or invalid)
constant char FLOAT_DEFAULT_TEST_KEYS[][64] = {
    'nonexistent',      // Key doesn't exist
    'section1.missing', // Key doesn't exist in section
    'missing.key',      // Section doesn't exist
    'float_invalid',    // Invalid value: 'abc'
    'float_mixed',      // Mixed value: '12.34abc' (atof returns 12.34)
    'float_empty',      // Empty value
    ''                  // Empty key
}

constant float FLOAT_DEFAULT_VALUES[] = {
    -999.9,     // Test with negative default
    0.0,        // Test with 0.0 as default
    1.0,        // Test with 1.0 as default
    -1.5,       // Test with -1.5 as default
    12.34,      // Mixed converts to 12.34 (atof behavior)
    3.14,       // Empty returns default
    -0.5        // Empty key returns default
}

DEFINE_VARIABLE

// Test data for GetFloatValue tests
volatile char FLOAT_GET_INI_DATA[2048]

/**
 * Initialize test data for GetFloatValue tests
 */
define_function InitializeFloatGetTestData() {
    FLOAT_GET_INI_DATA = "
        '; Valid float values', 10,
        'float_zero=0.0', 10,
        'float_integer=42', 10,
        'float_positive=3.14', 10,
        'float_negative=-2.5', 10,
        'float_large=9999.99', 10,
        'float_small=0.001', 10,
        'float_plus_sign=+1.5', 10,
        'float_no_leading=.5', 10,
        'float_spaces=  -456.78  ', 10,
        10,
        '; Invalid values', 10,
        'float_invalid=abc', 10,
        'float_mixed=12.34abc', 10,
        'float_empty=', 10,
        10,
        '[section1]', 10,
        'scale=1.0', 10,
        'threshold=0.5', 10
    "
}

/**
 * Test NAVIniFileGetFloatValue function
 */
define_function TestNAVIniFileGetFloatValue() {
    stack_var _NAVIniFile testIni
    stack_var integer i
    stack_var float result

    NAVLog("'***************** NAVIniFileGetFloatValue *****************'")

    // Initialize test data
    InitializeFloatGetTestData()

    // Parse the test INI data
    if (!NAVIniFileParse(FLOAT_GET_INI_DATA, testIni)) {
        NAVLog("'Failed to parse test INI data for GetFloatValue tests'")
        return
    }

    NAVLog("'--- Testing Valid Float Values ---'")

    // Test all valid float conversions
    for (i = 1; i <= length_array(FLOAT_VALID_TEST_KEYS); i++) {
        result = NAVIniFileGetFloatValue(testIni, FLOAT_VALID_TEST_KEYS[i], -999.9)

        if (!NAVAssertFloatEqual('GetFloatValue Valid Test', FLOAT_VALID_EXPECTED[i], result)) {
            NAVLogTestFailed(i, ftoa(FLOAT_VALID_EXPECTED[i]), ftoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    NAVLog("'--- Testing Default Values ---'")

    // Test default value returns for missing/invalid keys
    for (i = 1; i <= length_array(FLOAT_DEFAULT_TEST_KEYS); i++) {
        stack_var float expected

        expected = FLOAT_DEFAULT_VALUES[i]
        result = NAVIniFileGetFloatValue(testIni, FLOAT_DEFAULT_TEST_KEYS[i], expected)

        if (!NAVAssertFloatEqual('GetFloatValue Default Test', expected, result)) {
            NAVLogTestFailed(i, ftoa(expected), ftoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    // Additional verification tests
    TestFloatGetVerification()
}

/**
 * Additional verification tests for GetFloatValue
 */
define_function TestFloatGetVerification() {
    stack_var _NAVIniFile testIni
    stack_var char testData[1024]
    stack_var float result

    NAVLog("'--- GetFloatValue Verification ---'")

    // Test 1: Integer without decimal point
    testData = "'int_value=100', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetFloatValue(testIni, 'int_value', 0.0)
        if (!NAVAssertFloatEqual('Integer Test', 100.0, result)) {
            NAVLogTestFailed(1, '100.0', ftoa(result))
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test 2: Negative decimal
    testData = "'neg_decimal=-123.456', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetFloatValue(testIni, 'neg_decimal', 0.0)
        if (!NAVAssertFloatEqual('Negative Decimal Test', -123.456, result)) {
            NAVLogTestFailed(2, '-123.456', ftoa(result))
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test 3: Plus sign handling
    testData = "'plus_value=+99.5', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetFloatValue(testIni, 'plus_value', 0.0)
        if (!NAVAssertFloatEqual('Plus Sign Test', 99.5, result)) {
            NAVLogTestFailed(3, '99.5', ftoa(result))
        } else {
            NAVLogTestPassed(3)
        }
    }

    // Test 4: Whitespace trimming
    testData = "'spaces_value=  7.89  ', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetFloatValue(testIni, 'spaces_value', 0.0)
        if (!NAVAssertFloatEqual('Spaces Test', 7.89, result)) {
            NAVLogTestFailed(4, '7.89', ftoa(result))
        } else {
            NAVLogTestPassed(4)
        }
    }

    // Test 5: Mixed format with multiple decimals - parses first number
    testData = "'invalid_format=12.34.56', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetFloatValue(testIni, 'invalid_format', 888.8)
        if (!NAVAssertFloatEqual('Mixed Format Test', 12.34, result)) {
            NAVLogTestFailed(5, '12.34', ftoa(result))
        } else {
            NAVLogTestPassed(5)
        }
    }

    // Test 6: Very small value
    testData = "'tiny_value=0.0001', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetFloatValue(testIni, 'tiny_value', 0.0)
        if (!NAVAssertFloatEqual('Tiny Value Test', 0.0001, result)) {
            NAVLogTestFailed(6, '0.0001', ftoa(result))
        } else {
            NAVLogTestPassed(6)
        }
    }

    // Test 7: Decimal without leading zero
    testData = "'no_leading=.25', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetFloatValue(testIni, 'no_leading', 0.0)
        if (!NAVAssertFloatEqual('No Leading Zero Test', 0.25, result)) {
            NAVLogTestFailed(7, '0.25', ftoa(result))
        } else {
            NAVLogTestPassed(7)
        }
    }

    // Test 8: Negative decimal without leading zero
    testData = "'neg_no_leading=-.75', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetFloatValue(testIni, 'neg_no_leading', 0.0)
        if (!NAVAssertFloatEqual('Negative No Leading Zero Test', -0.75, result)) {
            NAVLogTestFailed(8, '-0.75', ftoa(result))
        } else {
            NAVLogTestPassed(8)
        }
    }
}
