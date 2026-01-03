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
    '2147483648',           // 16: Above maximum (2147483647)
    '3000000000',           // 17: Way above maximum
    '-2147483649',          // 18: Below minimum (-2147483648)
    '-3000000000',          // 19: Way below minimum
    'abc',                  // 20: No digits
    'xyz-123',              // 21: Letters before number - extracts -123
    {' ', $0D, $0A},        // 22: Whitespace characters (space, CR, LF)
    {' ', $0D, $0A, '-', '1', '0', '0', '0', $09},  // 23: Whitespace with number (space, CR, LF, '-1000', tab)
    '   -100  200   '       // 24: Multiple numbers with spaces
}

constant char NAV_PARSE_SIGNED_LONG_EXPECTED_RESULT[] = {
    // Valid (1-13)
    true, true, true, true, true, true, true, true, true, true, true, true, true,
    // Invalid (14-20)
    false, false, false, false, false, false, false,
    // Valid (21) - extracts -123
    true,
    // Invalid (22)
    false,
    // Valid (23-24)
    true, true
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
