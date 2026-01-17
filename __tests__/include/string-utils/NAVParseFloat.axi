PROGRAM_NAME='NAVParseFloat.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_PARSE_FLOAT_TESTS[][255] = {
    // Valid cases - basic
    '0.0',                  // 1: Zero
    '1.0',                  // 2: One
    '3.14159',              // 3: Pi
    '42.5',                 // 4: Simple decimal
    '-1.5',                 // 5: Negative decimal
    '-99.99',               // 6: Negative with multiple decimals
    // Valid cases - scientific notation
    '1.25e-3',              // 7: Scientific notation (0.00125)
    '-1.25e-3',             // 8: Negative scientific notation
    '1.5e3',                // 9: Positive exponent (1500.0)
    '2.5E2',                // 10: Capital E (250.0)
    // Valid cases - edge formats
    '0.1',                  // 11: Small decimal
    '999999.999999',        // 12: Large number with decimals
    '.5',                   // 13: Leading decimal point
    '5.',                   // 14: Trailing decimal point
    // Valid cases - with whitespace/text
    ' 22.5',                // 15: Leading whitespace
    '22.5 ',                // 16: Trailing whitespace
    '  3.14  ',             // 17: Both whitespace
    'Temp=22.5',            // 18: Text prefix
    '15.5 degrees',         // 19: Text suffix
    // Valid cases - integers (no decimal required now)
    '42',                   // 20: Integer format
    '-10',                  // 21: Negative integer format

    // Invalid cases
    '',                     // 22: Empty string
    '   ',                  // 23: Whitespace only
    'abc',                  // 24: No digits
    'xyz',                  // 25: No digits
    'not a number',         // 26: Text without number
    {' ', $0D, $0A},        // 27: Whitespace characters (space, CR, LF)
    {' ', $0D, $0A, '2', '2', '.', '5', $09},  // 28: Whitespace with number (space, CR, LF, '22.5', tab)
    '   10.5  20.3   '      // 29: Multiple numbers with spaces
}

constant char NAV_PARSE_FLOAT_EXPECTED_RESULT[] = {
    // Valid (1-21)
    true, true, true, true, true, true, true, true, true, true,
    true, true, true, true, true, true, true, true, true, true, true,
    // Invalid (22-26)
    false, false, false, false, false,
    // Invalid (27)
    false,
    // Valid (28-29)
    true, true
}

constant float NAV_PARSE_FLOAT_EXPECTED_VALUES[] = {
    0.0,        // 1: '0.0'
    1.0,        // 2: '1.0'
    3.14159,    // 3: '3.14159'
    42.5,       // 4: '42.5'
    -1.5,       // 5: '-1.5'
    -99.99,     // 6: '-99.99'
    0.00125,    // 7: '1.25e-3'
    -0.00125,   // 8: '-1.25e-3'
    1500.0,     // 9: '1.5e3'
    250.0,      // 10: '2.5E2'
    0.1,        // 11: '0.1'
    999999.999999,  // 12: '999999.999999'
    0.5,        // 13: '.5'
    5.0,        // 14: '5.'
    22.5,       // 15: ' 22.5'
    22.5,       // 16: '22.5 '
    3.14,       // 17: '  3.14  '
    22.5,       // 18: 'Temp=22.5'
    15.5,       // 19: '15.5 degrees'
    42.0,       // 20: '42'
    -10.0,      // 21: '-10'
    22.5,       // 28: Whitespace with number
    10.5        // 29: '   10.5  20.3   '
}

define_function TestNAVParseFloat() {
    stack_var integer x
    stack_var integer validCount

    NAVLogTestSuiteStart('NAVParseFloat')

    validCount = 0

    for (x = 1; x <= length_array(NAV_PARSE_FLOAT_TESTS); x++) {
        stack_var char result
        stack_var float value
        stack_var char shouldPass

        shouldPass = NAV_PARSE_FLOAT_EXPECTED_RESULT[x]
        result = NAVParseFloat(NAV_PARSE_FLOAT_TESTS[x], value)

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
            stack_var float expectedValue

            validCount++
            expectedValue = NAV_PARSE_FLOAT_EXPECTED_VALUES[validCount]

            if (!NAVAssertFloatEqual('Should parse to the expected float value', expectedValue, value)) {
                NAVLogTestFailed(x, ftoa(expectedValue), ftoa(value))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVParseFloat')
}
