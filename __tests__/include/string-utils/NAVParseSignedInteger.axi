PROGRAM_NAME='NAVParseSignedInteger.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_PARSE_SIGNED_INTEGER_TESTS[][255] = {
    // Valid cases - positive
    '0',                    // 1: Zero
    '1',                    // 2: Single digit
    '42',                   // 3: Two digits
    '12345',                // 4: Multiple digits
    '32767',                // 5: Maximum positive value
    // Valid cases - negative
    '-1',                   // 6: Negative single digit
    '-42',                  // 7: Negative two digits
    '-12345',               // 8: Negative multiple digits
    '-32768',               // 9: Minimum value
    // Valid cases - with whitespace/text
    ' -100',                // 10: Leading whitespace
    '-50 ',                 // 11: Trailing whitespace
    '  -25  ',              // 12: Both whitespace
    'Temp=-10',             // 13: Text prefix
    '-5 degrees',           // 14: Text suffix

    // Invalid cases
    '',                     // 15: Empty string
    '   ',                  // 16: Whitespace only
    '32768',                // 17: Above maximum (32767)
    '50000',                // 18: Way above maximum
    '-32769',               // 19: Below minimum (-32768)
    '-40000',               // 20: Way below minimum
    'abc',                  // 21: No digits
    'xyz-123',              // 22: Letters before number
    {' ', $0D, $0A},        // 23: Whitespace characters (space, CR, LF)
    {' ', $0D, $0A, '-', '1', '5', '0', $09},  // 24: Whitespace with number (space, CR, LF, '-150', tab)
    '   -10  20   ',        // 25: Multiple numbers with spaces

    // Hexadecimal tests
    '0xFF',                 // 26: Hex positive (255)
    '-0xFF',                // 27: Hex negative (-255)
    '0x7FFF',               // 28: Hex max positive (32767)
    '-0x8000',              // 29: Hex min value (-32768)

    // Binary tests
    '0b1111',               // 30: Binary positive (15)
    '-0b1111',              // 31: Binary negative (-15)
    '0b111111111111111',    // 32: Binary max positive (32767)

    // Octal tests
    '0o77',                 // 33: Octal positive (63)
    '-0o77',                // 34: Octal negative (-63)
    '0o77777',              // 35: Octal max positive (32767)

    // $ prefix hexadecimal tests
    '$FF',                  // 36: $ hex positive (255)
    '-$FF',                 // 37: $ hex negative (-255)
    '$7FFF',                // 38: $ hex max positive (32767)
    '-$8000',               // 39: $ hex min value (-32768)

    // Mixed case prefix tests
    '0XFF',                 // 40: Uppercase hex prefix (255)
    '0B1010',               // 41: Uppercase binary prefix (10)
    '0O77',                 // 42: Uppercase octal prefix (63)

    // Additional boundary tests
    '0x1',                  // 43: Hex single digit (1)
    '-0x1',                 // 44: Hex negative single digit (-1)
    '0b0',                  // 45: Binary zero (0)
    '0o0',                  // 46: Octal zero (0)
    '0x7FFE',               // 47: Hex near max (32766)
    '-0x7FFF',              // 48: Hex large negative (-32767)

    // Invalid multi-base cases
    '0x8000',               // 49: Hex overflow (32768)
    '-0x8001',              // 50: Hex underflow (-32769)
    '0xGHI',                // 51: Invalid hex digits
    '0b2',                  // 52: Invalid binary digit
    '0o8',                  // 53: Invalid octal digit
    '$GHIJ'                 // 54: Invalid $ hex digits
}

constant char NAV_PARSE_SIGNED_INTEGER_EXPECTED_RESULT[] = {
    // Valid (1-14)
    true, true, true, true, true, true, true, true, true, true, true, true, true, true,
    // Invalid (15-21, 23)
    false, false, false, false, false, false, false,
    // Valid (22, 24) - ATOI extracts numbers
    true,
    // Invalid (23)
    false,
    // Valid (24-25)
    true, true,
    // Hexadecimal - Valid (26-29)
    true, true, true, true,
    // Binary - Valid (30-32)
    true, true, true,
    // Octal - Valid (33-35)
    true, true, true,
    // $ prefix hex - Valid (36-39)
    true, true, true, true,
    // Mixed case - Valid (40-42)
    true, true, true,
    // Additional boundaries - Valid (43-48)
    true, true, true, true, true, true,
    // Invalid multi-base (49-54)
    false, false, false, false, false, false
}

constant sinteger NAV_PARSE_SIGNED_INTEGER_EXPECTED_VALUES[] = {
    0,      // 1: '0'
    1,      // 2: '1'
    42,     // 3: '42'
    12345,  // 4: '12345'
    32767,  // 5: '32767'
    -1,     // 6: '-1'
    -42,    // 7: '-42'
    -12345, // 8: '-12345'
    -32768, // 9: '-32768'
    -100,   // 10: ' -100'
    -50,    // 11: '-50 '
    -25,    // 12: '  -25  '
    -10,    // 13: 'Temp=-10'
    -5,     // 14: '-5 degrees'
    -123,   // 15: 'xyz-123' - ATOI extracts -123 (test 22 in array)
    -150,   // 16: Whitespace with number - ATOI extracts -150 (test 24)
    -10,    // 17: '   -10  20   ' (test 25)
    // Hexadecimal values
    255,    // 18: '0xFF' (test 26)
    -255,   // 19: '-0xFF' (test 27)
    32767,  // 20: '0x7FFF' (test 28)
    -32768, // 21: '-0x8000' (test 29)
    // Binary values
    15,     // 22: '0b1111' (test 30)
    -15,    // 23: '-0b1111' (test 31)
    32767,  // 24: '0b111111111111111' (test 32)
    // Octal values
    63,     // 25: '0o77' (test 33)
    -63,    // 26: '-0o77' (test 34)
    32767,  // 27: '0o77777' (test 35)
    // $ prefix hex
    255,    // 28: '$FF' (test 36)
    -255,   // 29: '-$FF' (test 37)
    32767,  // 30: '$7FFF' (test 38)
    -32768, // 31: '-$8000' (test 39)
    // Mixed case prefixes
    255,    // 32: '0XFF' (test 40)
    10,     // 33: '0B1010' (test 41)
    63,     // 34: '0O77' (test 42)
    // Additional boundaries
    1,      // 35: '0x1' (test 43)
    -1,     // 36: '-0x1' (test 44)
    0,      // 37: '0b0' (test 45)
    0,      // 38: '0o0' (test 46)
    32766,  // 39: '0x7FFE' (test 47)
    -32767  // 40: '-0x7FFF' (test 48)
}

define_function TestNAVParseSignedInteger() {
    stack_var integer x
    stack_var integer validCount

    NAVLogTestSuiteStart('NAVParseSignedInteger')

    validCount = 0

    for (x = 1; x <= length_array(NAV_PARSE_SIGNED_INTEGER_TESTS); x++) {
        stack_var char result
        stack_var sinteger value
        stack_var char shouldPass

        shouldPass = NAV_PARSE_SIGNED_INTEGER_EXPECTED_RESULT[x]
        result = NAVParseSignedInteger(NAV_PARSE_SIGNED_INTEGER_TESTS[x], value)

        // Check if result matches expectation
        if (!NAVAssertBooleanEqual('Should parse with the expected result', shouldPass, result)) {
            NAVLogTestFailed(x, NAVBooleanToString(shouldPass), NAVBooleanToString(result))
            continue
        }

        if (!shouldPass) {
            // If should fail, no further checks needed
            NAVLogTestPassed(x)
            continue
        }

        // If should pass, validate the parsed value
        {
            validCount++

            if (!NAVAssertSignedIntegerEqual('Should parse to the expected signed integer value', NAV_PARSE_SIGNED_INTEGER_EXPECTED_VALUES[validCount], value)) {
                NAVLogTestFailed(x, itoa(NAV_PARSE_SIGNED_INTEGER_EXPECTED_VALUES[validCount]), itoa(value))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVParseSignedInteger')
}
