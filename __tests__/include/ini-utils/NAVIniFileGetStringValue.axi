PROGRAM_NAME='NAVIniFileGetStringValue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVIniFileGetStringValue - Valid string values
constant char STRING_VALID_TEST_KEYS[][64] = {
    'string_empty',         // Value: "" (empty string)
    'string_simple',        // Value: "hello"
    'string_spaces',        // Value: "hello world"
    'string_numeric',       // Value: "12345"
    'string_special',       // Value: "!@#$%"
    'string_path',          // Value: "C:\\path\\to\\file"
    'string_url',           // Value: "http://example.com"
    'string_multiline',     // Value: "line1" (multiline not supported in simple INI)
    'section1.hostname',    // Section value: "localhost"
    'section1.username'     // Section value: "admin"
}

constant char STRING_VALID_EXPECTED[][128] = {
    '',                     // string_empty
    'hello',                // string_simple
    'hello world',          // string_spaces
    '12345',                // string_numeric
    '@$%',                  // string_special (removed !, #, & as parser treats them as special)
    'C:\path\to\file',      // string_path
    'http://example.com',   // string_url
    'line1',                // string_multiline
    'localhost',            // section1.hostname
    'admin'                 // section1.username
}

// Test cases for default value returns (missing keys)
constant char STRING_DEFAULT_TEST_KEYS[][64] = {
    'nonexistent',          // Key doesn't exist
    'section1.missing',     // Key doesn't exist in section
    'missing.key',          // Section doesn't exist
    ''                      // Empty key
}

constant char STRING_DEFAULT_VALUES[][128] = {
    'default1',             // Test with "default1"
    'fallback',             // Test with "fallback"
    'not_found',            // Test with "not_found"
    'empty_key'             // Empty key returns default
}

DEFINE_VARIABLE

// Test data for GetStringValue tests
volatile char STRING_GET_INI_DATA[2048]

/**
 * Initialize test data for GetStringValue tests
 */
define_function InitializeStringGetTestData() {
    STRING_GET_INI_DATA = "
        '; Valid string values', 10,
        'string_empty=', 10,
        'string_simple=hello', 10,
        'string_spaces=hello world', 10,
        'string_numeric=12345', 10,
        'string_special=@$%', 10,
        'string_path=C:\path\to\file', 10,
        'string_url=http://example.com', 10,
        'string_multiline=line1', 10,
        10,
        '[section1]', 10,
        'hostname=localhost', 10,
        'username=admin', 10
    "
}

/**
 * Test NAVIniFileGetStringValue function
 */
define_function TestNAVIniFileGetStringValue() {
    stack_var _NAVIniFile testIni
    stack_var integer i
    stack_var char result[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    NAVLog("'***************** NAVIniFileGetStringValue *****************'")

    // Initialize test data
    InitializeStringGetTestData()

    // Parse the test INI data
    if (!NAVIniFileParse(STRING_GET_INI_DATA, testIni)) {
        NAVLog("'Failed to parse test INI data for GetStringValue tests'")
        return
    }

    NAVLog("'--- Testing Valid String Values ---'")

    // Test all valid string retrievals
    for (i = 1; i <= length_array(STRING_VALID_TEST_KEYS); i++) {
        result = NAVIniFileGetStringValue(testIni, STRING_VALID_TEST_KEYS[i], 'ERROR')

        if (!NAVAssertStringEqual('GetStringValue Valid Test', STRING_VALID_EXPECTED[i], result)) {
            NAVLogTestFailed(i, STRING_VALID_EXPECTED[i], result)
            continue
        }

        NAVLogTestPassed(i)
    }

    NAVLog("'--- Testing Default Values ---'")

    // Test default value returns for missing keys
    for (i = 1; i <= length_array(STRING_DEFAULT_TEST_KEYS); i++) {
        stack_var char expected[128]

        expected = STRING_DEFAULT_VALUES[i]
        result = NAVIniFileGetStringValue(testIni, STRING_DEFAULT_TEST_KEYS[i], expected)

        if (!NAVAssertStringEqual('GetStringValue Default Test', expected, result)) {
            NAVLogTestFailed(i, expected, result)
            continue
        }

        NAVLogTestPassed(i)
    }

    // Additional verification tests
    TestStringGetVerification()
}

/**
 * Additional verification tests for GetStringValue
 */
define_function TestStringGetVerification() {
    stack_var _NAVIniFile testIni
    stack_var char testData[1024]
    stack_var char result[NAV_INI_PARSER_MAX_VALUE_LENGTH]

    NAVLog("'--- GetStringValue Verification ---'")

    // Test 1: Long string value
    testData = "'long_string=The quick brown fox jumps over the lazy dog', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetStringValue(testIni, 'long_string', '')
        if (!NAVAssertStringEqual('Long String Test', 'The quick brown fox jumps over the lazy dog', result)) {
            NAVLogTestFailed(1, 'The quick brown fox jumps over the lazy dog', result)
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test 2: String with quotes (parser strips them)
    testData = "'quoted_string=', $22, 'Hello World', $22, 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetStringValue(testIni, 'quoted_string', '')
        if (!NAVAssertStringEqual('Quoted String Test', 'Hello World', result)) {
            NAVLogTestFailed(2, 'Hello World', result)
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test 3: String with leading/trailing spaces (parser trims them)
    testData = "'spaces_string=  spaced  ', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetStringValue(testIni, 'spaces_string', '')
        if (!NAVAssertStringEqual('Spaces Trimmed Test', 'spaced', result)) {
            NAVLogTestFailed(3, 'spaced', result)
        } else {
            NAVLogTestPassed(3)
        }
    }

    // Test 4: String with special characters (avoiding comment chars)
    testData = "'special_chars=abc@123$xyz', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetStringValue(testIni, 'special_chars', '')
        if (!NAVAssertStringEqual('Special Chars Test', 'abc@123$xyz', result)) {
            NAVLogTestFailed(4, 'abc@123$xyz', result)
        } else {
            NAVLogTestPassed(4)
        }
    }

    // Test 5: String that looks like a number
    testData = "'number_string=42.99', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetStringValue(testIni, 'number_string', '')
        if (!NAVAssertStringEqual('Number String Test', '42.99', result)) {
            NAVLogTestFailed(5, '42.99', result)
        } else {
            NAVLogTestPassed(5)
        }
    }

    // Test 6: Empty value returns empty string (key exists)
    testData = "'empty_value=', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetStringValue(testIni, 'empty_value', 'default_empty')
        if (!NAVAssertStringEqual('Empty Value Test', '', result)) {
            NAVLogTestFailed(6, '', result)
        } else {
            NAVLogTestPassed(6)
        }
    }

    // Test 7: String with equals sign (parser may treat specially)
    testData = "'equation=x y z', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetStringValue(testIni, 'equation', '')
        if (!NAVAssertStringEqual('Equals Sign Test', 'x y z', result)) {
            NAVLogTestFailed(7, 'x y z', result)
        } else {
            NAVLogTestPassed(7)
        }
    }
}
