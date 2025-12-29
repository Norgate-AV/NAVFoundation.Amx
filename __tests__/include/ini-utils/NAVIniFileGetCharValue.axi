PROGRAM_NAME='NAVIniFileGetCharValue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVIniFileGetCharValue - Valid character values
constant char CHAR_VALID_TEST_KEYS[][64] = {
    'char_letter_upper',    // Value: "A"
    'char_letter_lower',    // Value: "z"
    'char_digit',           // Value: "5"
    'char_special',         // Value: "@"
    'char_from_word',       // Value: "Hello" (should return 'H', removed space test)
    'char_with_spaces',     // Value: "  X  " (should return 'X' after trim)
    'section1.mode',        // Section value: "A"
    'section1.flag'         // Section value: "Y"
}

constant char CHAR_VALID_EXPECTED[] = {
    'A',    // char_letter_upper
    'z',    // char_letter_lower
    '5',    // char_digit
    '@',    // char_special
    'H',    // char_from_word (first char)
    'X',    // char_with_spaces (trimmed)
    'A',    // section1.mode
    'Y'     // section1.flag
}

// Test cases for default value returns (missing or empty keys)
constant char CHAR_DEFAULT_TEST_KEYS[][64] = {
    'nonexistent',          // Key doesn't exist
    'section1.missing',     // Key doesn't exist in section
    'missing.key',          // Section doesn't exist
    'char_empty',           // Empty value
    ''                      // Empty key
}

constant char CHAR_DEFAULT_VALUES[] = {
    'D',    // Test with 'D'
    'F',    // Test with 'F'
    'N',    // Test with 'N'
    'E',    // Empty value returns default
    'K'     // Empty key returns default
}

DEFINE_VARIABLE

// Test data for GetCharValue tests
volatile char CHAR_GET_INI_DATA[2048]

/**
 * Initialize test data for GetCharValue tests
 */
define_function InitializeCharGetTestData() {
    CHAR_GET_INI_DATA = "
        '; Valid character values', 10,
        'char_letter_upper=A', 10,
        'char_letter_lower=z', 10,
        'char_digit=5', 10,
        'char_special=@', 10,
        'char_from_word=Hello', 10,
        'char_with_spaces=  X  ', 10,
        'char_empty=', 10,
        10,
        '[section1]', 10,
        'mode=A', 10,
        'flag=Y', 10
    "
}

/**
 * Test NAVIniFileGetCharValue function
 */
define_function TestNAVIniFileGetCharValue() {
    stack_var _NAVIniFile testIni
    stack_var integer i
    stack_var char result

    NAVLog("'***************** NAVIniFileGetCharValue *****************'")

    // Initialize test data
    InitializeCharGetTestData()

    // Parse the test INI data
    if (!NAVIniFileParse(CHAR_GET_INI_DATA, testIni)) {
        NAVLog("'Failed to parse test INI data for GetCharValue tests'")
        return
    }

    NAVLog("'--- Testing Valid Character Values ---'")

    // Test all valid character retrievals
    for (i = 1; i <= length_array(CHAR_VALID_TEST_KEYS); i++) {
        result = NAVIniFileGetCharValue(testIni, CHAR_VALID_TEST_KEYS[i], 'Z')

        if (!NAVAssertCharEqual('GetCharValue Valid Test', CHAR_VALID_EXPECTED[i], result)) {
            NAVLogTestFailed(i, "CHAR_VALID_EXPECTED[i]", "result")
            continue
        }

        NAVLogTestPassed(i)
    }

    NAVLog("'--- Testing Default Values ---'")

    // Test default value returns for missing/empty keys
    for (i = 1; i <= length_array(CHAR_DEFAULT_TEST_KEYS); i++) {
        stack_var char expected

        expected = CHAR_DEFAULT_VALUES[i]
        result = NAVIniFileGetCharValue(testIni, CHAR_DEFAULT_TEST_KEYS[i], expected)

        if (!NAVAssertCharEqual('GetCharValue Default Test', expected, result)) {
            NAVLogTestFailed(i, "expected", "result")
            continue
        }

        NAVLogTestPassed(i)
    }

    // Additional verification tests
    TestCharGetVerification()
}

/**
 * Additional verification tests for GetCharValue
 */
define_function TestCharGetVerification() {
    stack_var _NAVIniFile testIni
    stack_var char testData[1024]
    stack_var char result

    NAVLog("'--- GetCharValue Verification ---'")

    // Test 1: Single uppercase letter
    testData = "'single_upper=B', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetCharValue(testIni, 'single_upper', 'X')
        if (!NAVAssertCharEqual('Single Upper Test', 'B', result)) {
            NAVLogTestFailed(1, 'B', "result")
        } else {
            NAVLogTestPassed(1)
        }
    }

    // Test 2: Single lowercase letter
    testData = "'single_lower=m', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetCharValue(testIni, 'single_lower', 'X')
        if (!NAVAssertCharEqual('Single Lower Test', 'm', result)) {
            NAVLogTestFailed(2, 'm', "result")
        } else {
            NAVLogTestPassed(2)
        }
    }

    // Test 3: Numeric character
    testData = "'numeric_char=9', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetCharValue(testIni, 'numeric_char', '0')
        if (!NAVAssertCharEqual('Numeric Char Test', '9', result)) {
            NAVLogTestFailed(3, '9', "result")
        } else {
            NAVLogTestPassed(3)
        }
    }

    // Test 4: Special character (avoiding comment chars like # and !)
    testData = "'special_char=@', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetCharValue(testIni, 'special_char', '?')
        if (!NAVAssertCharEqual('Special Char Test', '@', result)) {
            NAVLogTestFailed(4, '@', "result")
        } else {
            NAVLogTestPassed(4)
        }
    }

    // Test 5: First char from multi-character string
    testData = "'multi_char=XYZ', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetCharValue(testIni, 'multi_char', 'A')
        if (!NAVAssertCharEqual('Multi Char Test', 'X', result)) {
            NAVLogTestFailed(5, 'X', "result")
        } else {
            NAVLogTestPassed(5)
        }
    }

    // Test 6: Whitespace trimming - leading spaces
    testData = "'lead_spaces=  P', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetCharValue(testIni, 'lead_spaces', 'X')
        if (!NAVAssertCharEqual('Leading Spaces Test', 'P', result)) {
            NAVLogTestFailed(6, 'P', "result")
        } else {
            NAVLogTestPassed(6)
        }
    }

    // Test 7: Whitespace trimming - trailing spaces
    testData = "'trail_spaces=Q  ', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetCharValue(testIni, 'trail_spaces', 'X')
        if (!NAVAssertCharEqual('Trailing Spaces Test', 'Q', result)) {
            NAVLogTestFailed(7, 'Q', "result")
        } else {
            NAVLogTestPassed(7)
        }
    }

    // Test 8: Empty after trim returns default
    testData = "'only_spaces=   ', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetCharValue(testIni, 'only_spaces', 'D')
        if (!NAVAssertCharEqual('Only Spaces Test', 'D', result)) {
            NAVLogTestFailed(8, 'D', "result")
        } else {
            NAVLogTestPassed(8)
        }
    }

    // Test 9: Special character in verification (avoiding special parser chars)
    testData = "'special_verify=$', 10"
    if (NAVIniFileParse(testData, testIni)) {
        result = NAVIniFileGetCharValue(testIni, 'special_verify', 'X')
        if (!NAVAssertCharEqual('Special Verify Test', '$', result)) {
            NAVLogTestFailed(9, '$', "result")
        } else {
            NAVLogTestPassed(9)
        }
    }
}
