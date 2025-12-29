PROGRAM_NAME='NAVIniFileGetBooleanValue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVIniFileGetBooleanValue - True variants
constant char BOOLEAN_TRUE_TEST_KEYS[][64] = {
    'bool_1',           // Value: 1
    'bool_true',        // Value: true
    'bool_TRUE',        // Value: TRUE (test case insensitivity)
    'bool_True',        // Value: True (mixed case)
    'bool_yes',         // Value: yes
    'bool_YES',         // Value: YES
    'bool_on',          // Value: on
    'bool_ON',          // Value: ON
    'section1.enabled', // Section value: true
    'section1.active'   // Section value: 1
}

// Test cases for NAVIniFileGetBooleanValue - False variants
constant char BOOLEAN_FALSE_TEST_KEYS[][64] = {
    'bool_0',           // Value: 0
    'bool_false',       // Value: false
    'bool_FALSE',       // Value: FALSE (test case insensitivity)
    'bool_False',       // Value: False (mixed case)
    'bool_no',          // Value: no
    'bool_NO',          // Value: NO
    'bool_off',         // Value: off
    'bool_OFF',         // Value: OFF
    'section1.disabled',// Section value: false
    'section1.inactive' // Section value: 0
}

// Test cases for default value returns (missing or invalid)
constant char BOOLEAN_DEFAULT_TEST_KEYS[][64] = {
    'nonexistent',      // Key doesn't exist
    'section1.missing', // Key doesn't exist in section
    'missing.key',      // Section doesn't exist
    'bool_invalid',     // Invalid value: 'maybe'
    'bool_number',      // Invalid value: '2'
    'bool_empty',       // Empty value
    ''                  // Empty key
}

constant char BOOLEAN_DEFAULT_VALUES[] = {
    false,  // Test with false as default
    true,   // Test with true as default
    false,
    true,
    false,
    true,
    false
}

DEFINE_VARIABLE

// Test data for GetBooleanValue tests
volatile char BOOLEAN_GET_INI_DATA[2048]

/**
 * Initialize test data for GetBooleanValue tests
 */
define_function InitializeBooleanGetTestData() {
    BOOLEAN_GET_INI_DATA = "
        '; True variants', 10,
        'bool_1=1', 10,
        'bool_true=true', 10,
        'bool_TRUE=TRUE', 10,
        'bool_True=True', 10,
        'bool_yes=yes', 10,
        'bool_YES=YES', 10,
        'bool_on=on', 10,
        'bool_ON=ON', 10,
        10,
        '; False variants', 10,
        'bool_0=0', 10,
        'bool_false=false', 10,
        'bool_FALSE=FALSE', 10,
        'bool_False=False', 10,
        'bool_no=no', 10,
        'bool_NO=NO', 10,
        'bool_off=off', 10,
        'bool_OFF=OFF', 10,
        10,
        '; Invalid values', 10,
        'bool_invalid=maybe', 10,
        'bool_number=2', 10,
        'bool_empty=', 10,
        10,
        '[section1]', 10,
        'enabled=true', 10,
        'active=1', 10,
        'disabled=false', 10,
        'inactive=0', 10
    "
}

/**
 * Test NAVIniFileGetBooleanValue function - True variants
 */
define_function TestNAVIniFileGetBooleanValue() {
    stack_var _NAVIniFile testIni
    stack_var integer i
    stack_var char result

    NAVLog("'***************** NAVIniFileGetBooleanValue *****************'")

    // Initialize test data
    InitializeBooleanGetTestData()

    // Parse the test INI data
    if (!NAVIniFileParse(BOOLEAN_GET_INI_DATA, testIni)) {
        NAVLog("'Failed to parse test INI data for GetBooleanValue tests'")
        return
    }

    NAVLog("'--- Testing True Variants ---'")

    // Test all true variants (should return true)
    for (i = 1; i <= length_array(BOOLEAN_TRUE_TEST_KEYS); i++) {
        result = NAVIniFileGetBooleanValue(testIni, BOOLEAN_TRUE_TEST_KEYS[i], false)

        if (!NAVAssertBooleanEqual('GetBooleanValue True Test', true, result)) {
            NAVLogTestFailed(i, "'true'", "'false'")
            continue
        }

        NAVLogTestPassed(i)
    }

    NAVLog("'--- Testing False Variants ---'")

    // Test all false variants (should return false)
    for (i = 1; i <= length_array(BOOLEAN_FALSE_TEST_KEYS); i++) {
        result = NAVIniFileGetBooleanValue(testIni, BOOLEAN_FALSE_TEST_KEYS[i], true)

        if (!NAVAssertBooleanEqual('GetBooleanValue False Test', false, result)) {
            NAVLogTestFailed(i, "'false'", "'true'")
            continue
        }

        NAVLogTestPassed(i)
    }

    NAVLog("'--- Testing Default Values ---'")

    // Test default value returns for missing/invalid keys
    for (i = 1; i <= length_array(BOOLEAN_DEFAULT_TEST_KEYS); i++) {
        stack_var char expected

        expected = BOOLEAN_DEFAULT_VALUES[i]
        result = NAVIniFileGetBooleanValue(testIni, BOOLEAN_DEFAULT_TEST_KEYS[i], expected)

        if (!NAVAssertBooleanEqual('GetBooleanValue Default Test', expected, result)) {
            NAVLogTestFailed(i, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    // Additional verification tests
    TestBooleanGetVerification()
}

/**
 * Additional verification tests for GetBooleanValue
 */
define_function TestBooleanGetVerification() {
    stack_var _NAVIniFile testIni
    stack_var char testData[1024]
    stack_var char result

    NAVLog("'--- GetBooleanValue Verification ---'")

    // Test 1: Empty INI - should return default
    if (!NAVIniFileParse('', testIni)) {
        NAVLog("'Failed to parse empty INI data'")
        return
    }

    result = NAVIniFileGetBooleanValue(testIni, 'anykey', true)
    if (result == true) {
        NAVLog("'Pass: Empty INI returns default (true)'")
    } else {
        NAVLog("'Fail: Empty INI should return default'")
    }

    result = NAVIniFileGetBooleanValue(testIni, 'anykey', false)
    if (result == false) {
        NAVLog("'Pass: Empty INI returns default (false)'")
    } else {
        NAVLog("'Fail: Empty INI should return default'")
    }

    // Test 2: Whitespace in values
    testData = "
        'trimmed=  true  ', 10,
        'spaced= false ', 10
    "

    if (!NAVIniFileParse(testData, testIni)) {
        NAVLog("'Failed to parse whitespace test data'")
        return
    }

    result = NAVIniFileGetBooleanValue(testIni, 'trimmed', false)
    if (result == true) {
        NAVLog("'Pass: Whitespace trimmed correctly (true)'")
    } else {
        NAVLog("'Fail: Whitespace in ''true'' value'")
    }

    result = NAVIniFileGetBooleanValue(testIni, 'spaced', true)
    if (result == false) {
        NAVLog("'Pass: Whitespace trimmed correctly (false)'")
    } else {
        NAVLog("'Fail: Whitespace in ''false'' value'")
    }

    // Test 3: Numeric strings that aren't 0 or 1
    testData = "
        'two=2', 10,
        'negative=-1', 10,
        'hundred=100', 10
    "

    if (!NAVIniFileParse(testData, testIni)) {
        NAVLog("'Failed to parse numeric test data'")
        return
    }

    result = NAVIniFileGetBooleanValue(testIni, 'two', true)
    if (result == true) {
        NAVLog("'Pass: Invalid numeric (2) returns default'")
    } else {
        NAVLog("'Fail: Invalid numeric should return default'")
    }

    result = NAVIniFileGetBooleanValue(testIni, 'negative', false)
    if (result == false) {
        NAVLog("'Pass: Invalid numeric (-1) returns default'")
    } else {
        NAVLog("'Fail: Invalid numeric should return default'")
    }

    // Test 4: Mixed case boolean strings
    testData = "
        'mixed1=TrUe', 10,
        'mixed2=FaLsE', 10,
        'mixed3=YeS', 10,
        'mixed4=nO', 10
    "

    if (!NAVIniFileParse(testData, testIni)) {
        NAVLog("'Failed to parse mixed case test data'")
        return
    }

    result = NAVIniFileGetBooleanValue(testIni, 'mixed1', false)
    if (result == true &&
        NAVIniFileGetBooleanValue(testIni, 'mixed3', false) == true) {
        NAVLog("'Pass: Mixed case true variants work'")
    } else {
        NAVLog("'Fail: Mixed case true variants'")
    }

    result = NAVIniFileGetBooleanValue(testIni, 'mixed2', true)
    if (result == false &&
        NAVIniFileGetBooleanValue(testIni, 'mixed4', true) == false) {
        NAVLog("'Pass: Mixed case false variants work'")
    } else {
        NAVLog("'Fail: Mixed case false variants'")
    }
}
