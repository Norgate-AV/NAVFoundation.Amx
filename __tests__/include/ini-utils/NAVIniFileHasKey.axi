PROGRAM_NAME='NAVIniFileHasKey'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVIniFileHasKey
constant char HASKEY_TEST_KEYS[][64] = {
    'timeout',           // Exists in global/default section
    'retries',           // Exists in global/default section
    'debug',             // Exists in global/default section
    'database.host',     // Exists in database section
    'database.port',     // Exists in database section
    'database.name',     // Exists in database section
    'application.title', // Exists in application section
    'application.version', // Exists in application section
    'application.enabled', // Exists in application section
    'nonexistent',       // Does NOT exist in global/default
    'nothere',           // Does NOT exist in global/default
    'database.missing',  // Section exists but key does NOT
    'database.invalid',  // Section exists but key does NOT
    'missing.key',       // Section does NOT exist
    'nosection.nokey',   // Section does NOT exist
    'empty.section',     // Section does NOT exist
    '',                  // Empty key - should not exist
    '.',                 // Just a dot - edge case
    'database.',         // Missing key part
    '.host'              // Missing section part
}

constant char HASKEY_EXPECTED[] = {
    true,   // timeout exists
    true,   // retries exists
    true,   // debug exists
    true,   // database.host exists
    true,   // database.port exists
    true,   // database.name exists
    true,   // application.title exists
    true,   // application.version exists
    true,   // application.enabled exists
    false,  // nonexistent - not found
    false,  // nothere - not found
    false,  // database.missing - key not found
    false,  // database.invalid - key not found
    false,  // missing.key - section not found
    false,  // nosection.nokey - section not found
    false,  // empty.section - section not found
    false,  // empty key
    false,  // just a dot
    false,  // missing key part
    false   // missing section part
}

DEFINE_VARIABLE

// Test data for HasKey tests
volatile char HASKEY_INI_DATA[2048]

/**
 * Initialize test data for HasKey tests
 */
define_function InitializeHasKeyTestData() {
    HASKEY_INI_DATA = "
        'timeout=30', 10,
        'retries=3', 10,
        'debug=true', 10,
        10,
        '[database]', 10,
        'host=localhost', 10,
        'port=5432', 10,
        'name=testdb', 10,
        10,
        '[application]', 10,
        'title=My Application', 10,
        'version=1.0.5', 10,
        'enabled=false', 10
    "
}

/**
 * Test NAVIniFileHasKey function
 * Tests both dot notation (section.key) and simple keys (global/default section)
 */
define_function TestNAVIniFileHasKey() {
    stack_var _NAVIniFile testIni
    stack_var integer i
    stack_var char result

    NAVLog("'***************** NAVIniFileHasKey *****************'")

    // Initialize test data
    InitializeHasKeyTestData()

    // Parse the test INI data
    if (!NAVIniFileParse(HASKEY_INI_DATA, testIni)) {
        NAVLog("'Failed to parse test INI data for HasKey tests'")
        return
    }

    // Run all test cases
    for (i = 1; i <= length_array(HASKEY_TEST_KEYS); i++) {
        result = NAVIniFileHasKey(testIni, HASKEY_TEST_KEYS[i])

        if (!NAVAssertBooleanEqual('HasKey Test', HASKEY_EXPECTED[i], result)) {
            NAVLogTestFailed(i, itoa(HASKEY_EXPECTED[i]), itoa(result))
            continue
        }

        NAVLogTestPassed(i)
    }

    // Additional verification tests
    TestHasKeyVerification()
}

/**
 * Additional verification tests for HasKey
 */
define_function TestHasKeyVerification() {
    stack_var _NAVIniFile emptyIni
    stack_var _NAVIniFile duplicateIni
    stack_var _NAVIniFile specialIni
    stack_var char testData[1024]

    NAVLog("'--- HasKey Verification ---'")

    // Test 1: Empty INI - all lookups should return false
    if (!NAVIniFileParse('', emptyIni)) {
        NAVLog("'Failed to parse empty INI data'")
        return
    }

    if (NAVIniFileHasKey(emptyIni, 'anykey') ||
        NAVIniFileHasKey(emptyIni, 'section.key') ||
        NAVIniFileHasKey(emptyIni, '')) {
        NAVLog("'Fail: Empty INI should return false for all keys'")
    } else {
        NAVLog("'Pass: Empty INI verification passed'")
    }

    // Test 2: Duplicate key names in different sections
    testData = "
        'name=global_value', 10,
        10,
        '[section1]', 10,
        'name=section1_value', 10,
        10,
        '[section2]', 10,
        'name=section2_value', 10
    "

    if (!NAVIniFileParse(testData, duplicateIni)) {
        NAVLog("'Failed to parse duplicate keys test data'")
        return
    }

    if (NAVIniFileHasKey(duplicateIni, 'name') &&
        NAVIniFileHasKey(duplicateIni, 'section1.name') &&
        NAVIniFileHasKey(duplicateIni, 'section2.name') &&
        !NAVIniFileHasKey(duplicateIni, 'section3.name')) {
        NAVLog("'Pass: Duplicate key names verification passed'")
    } else {
        NAVLog("'Fail: Duplicate key names verification failed'")
    }

    // Test 3: Special characters in keys
    testData = "
        'key-with-dashes=value1', 10,
        'key_with_underscores=value2', 10,
        'KEY_UPPERCASE=value3', 10,
        10,
        '[my-section]', 10,
        'my-key=value4', 10
    "

    if (!NAVIniFileParse(testData, specialIni)) {
        NAVLog("'Failed to parse special characters test data'")
        return
    }

    if (NAVIniFileHasKey(specialIni, 'key-with-dashes') &&
        NAVIniFileHasKey(specialIni, 'key_with_underscores') &&
        NAVIniFileHasKey(specialIni, 'KEY_UPPERCASE') &&
        NAVIniFileHasKey(specialIni, 'my-section.my-key')) {
        NAVLog("'Pass: Special characters verification passed'")
    } else {
        NAVLog("'Fail: Special characters verification failed'")
    }
}
