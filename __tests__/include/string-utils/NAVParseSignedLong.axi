PROGRAM_NAME='NAVParseSignedLong.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_PARSE_SIGNED_LONG_TESTS[][255] = {
    // Valid cases - positive
    '0',                    // 1: Zero
    '1',                    // 2: Single digit
    '42',                   // 3: Two digits
    '1234567890',           // 4: Large positive
    '2147483647',           // 5: Maximum positive value
    // Valid cases - negative
    '-1',                   // 6: Negative single digit
    '-42',                  // 7: Negative two digits
    '-1234567890',          // 8: Large negative
    '-2147483648',          // 9: Minimum value
    // Valid cases - with whitespace/text
    ' -1000',               // 10: Leading whitespace
    '-500 ',                // 11: Trailing whitespace
    '  -250  ',             // 12: Both whitespace
    'Offset=-100000',       // 13: Text prefix

    // Invalid cases
    '',                     // 14: Empty string
    '   ',                  // 15: Whitespace only
    '2147483648',           // 16: Above maximum (exact max is 2147483647)
    '3000000000',           // 17: Way above maximum
    '-2147483649',          // 18: Below minimum (exact min is -2147483648)
    '-3000000000',          // 19: Way below minimum
    'abc',                  // 20: No digits
    'xyz-123',              // 21: Letters before number - extracts -123
    {' ', $0D, $0A},        // 22: Whitespace characters (space, CR, LF)
    {' ', $0D, $0A, '-', '1', '0', '0', '0', $09},  // 23: Whitespace with number (space, CR, LF, '-1000', tab)
    '   -100  200   ',      // 24: Multiple numbers with spaces

    // Hexadecimal tests
    '0x7FFFFFFF',           // 25: Hex max positive (2147483647)
    '-0x7FFFFFFF',          // 26: Hex large negative (-2147483647)
    '0xFFFF',               // 27: Hex positive (65535)

    // Binary tests
    '0b1111111111111111111111111111111',  // 28: Binary max positive (2147483647)
    '-0b1111',              // 29: Binary negative (-15)

    // Octal tests
    '0o17777777777',        // 30: Octal max positive (2147483647)
    '-0o777',               // 31: Octal negative (-511)

    // $ prefix hexadecimal tests
    '$FF',                  // 32: $ hex positive (255)
    '-$FF',                 // 33: $ hex negative (-255)
    '$7FFFFFFF',            // 34: $ hex max positive (2147483647)
    '-$80000000',           // 35: $ hex min value (-2147483648)

    // Mixed case prefix tests
    '0XABCD',               // 36: Uppercase hex prefix (43981)
    '0B1010',               // 37: Uppercase binary prefix (10)
    '0O777',                // 38: Uppercase octal prefix (511)

    // Additional edge cases
    '0x1',                  // 39: Hex single digit positive (1)
    '-0x1',                 // 40: Hex single digit negative (-1)
    '0b0',                  // 41: Binary zero (0)
    '0o0',                  // 42: Octal zero (0)
    '0x7FFFFFFE',           // 43: Hex near max (2147483646)
    '-0x7FFFFFFE',          // 44: Hex large negative (-2147483646)

    // Invalid multi-base cases
    '0x80000000',           // 45: Hex overflow (2147483648)
    '-0x80000001',          // 46: Hex underflow (-2147483649)
    '0xGHI',                // 47: Invalid hex digits
    '0b2',                  // 48: Invalid binary digit
    '0o8',                  // 49: Invalid octal digit
    '$GHIJ'                 // 50: Invalid $ hex digits
}

constant char NAV_PARSE_SIGNED_LONG_EXPECTED_RESULT[] = {
    // Valid (1-13)
    true, true, true, true, true, true, true, true, true, true, true, true, true,
    // Invalid (14-16)
    false, false, false,
    // Invalid (17)
    false,
    // Invalid (18)
    false,
    // Invalid (19)
    false,
    // Invalid (20)
    false,
    // Valid (21) - extracts -123
    true,
    // Invalid (22)
    false,
    // Valid (23-24)
    true, true,
    // Hexadecimal - Valid (25-27)
    true, true, true,
    // Binary - Valid (28-29)
    true, true,
    // Octal - Valid (30-31)
    true, true,
    // $ prefix hex - Valid (32-35)
    true, true, true, true,
    // Mixed case - Valid (36-38)
    true, true, true,
    // Additional edges - Valid (39-44)
    true, true, true, true, true, true,
    // Invalid multi-base (45-50)
    false, false, false, false, false, false
}


define_function TestNAVParseSignedLong() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVParseSignedLong')

    for (x = 1; x <= length_array(NAV_PARSE_SIGNED_LONG_TESTS); x++) {
        stack_var char result
        stack_var slong value
        stack_var char shouldPass

        shouldPass = NAV_PARSE_SIGNED_LONG_EXPECTED_RESULT[x]
        result = NAVParseSignedLong(NAV_PARSE_SIGNED_LONG_TESTS[x], value)

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
            stack_var slong expected

            // NOTE: NetLinx compiler quirk - SLONG literal negative values
            // The NetLinx compiler does not properly handle literal negative values
            // with SLONG type (e.g., expected = -1000). This causes type conversion
            // warnings and incorrect values. To work around this, we initialize
            // expected to 0 and calculate negative values programmatically using
            // subtraction (e.g., expected = 0 - 1000 or expected - type_cast(1000)).
            expected = 0

            switch (x) {
                case 1: expected = 0
                case 2: expected = 1
                case 3: expected = 42
                case 4: expected = 1234567890
                case 5: expected = 2147483647
                case 6: expected = expected - type_cast(1)
                case 7: expected = expected - type_cast(42)
                case 8: expected = expected - type_cast(1234567890)
                case 9: expected = expected - type_cast(2147483648)
                case 10: expected = expected - type_cast(1000)
                case 11: expected = expected - type_cast(500)
                case 12: expected = expected - type_cast(250)
                case 13: expected = expected - type_cast(100000)
                case 21: expected = expected - type_cast(123)
                case 23: expected = expected - type_cast(1000)
                case 24: expected = expected - type_cast(100)
                // Hexadecimal values
                case 25: expected = 2147483647
                case 26: expected = expected - type_cast(2147483647)
                case 27: expected = 65535
                // Binary values
                case 28: expected = 2147483647
                case 29: expected = expected - type_cast(15)
                // Octal values
                case 30: expected = 2147483647
                case 31: expected = expected - type_cast(511)
                // $ prefix hex values
                case 32: expected = 255
                case 33: expected = expected - type_cast(255)
                case 34: expected = 2147483647
                case 35: expected = expected - type_cast(2147483648)
                // Mixed case prefixes
                case 36: expected = 43981
                case 37: expected = 10
                case 38: expected = 511
                // Additional edges
                case 39: expected = 1
                case 40: expected = expected - type_cast(1)
                case 41: expected = 0
                case 42: expected = 0
                case 43: expected = 2147483646
                case 44: expected = expected - type_cast(2147483646)
            }

            if (!NAVAssertSignedLongEqual('Should parse to the expected signed long value', expected, value)) {
                NAVLogTestFailed(x, itoa(expected), itoa(value))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVParseSignedLong')
}
