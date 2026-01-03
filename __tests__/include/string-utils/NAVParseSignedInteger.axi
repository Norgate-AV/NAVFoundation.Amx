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
    '   -10  20   '         // 25: Multiple numbers with spaces
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
    true, true
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
    -123,   // 22: 'xyz-123' - ATOI extracts -123
    -150,   // 24: Whitespace with number - ATOI extracts -150
    -10     // 25: '   -10  20   '
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
