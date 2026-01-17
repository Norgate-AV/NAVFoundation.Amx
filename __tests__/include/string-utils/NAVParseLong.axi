PROGRAM_NAME='NAVParseLong.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_PARSE_LONG_TESTS[][255] = {
    // Valid cases
    '0',                    // 1: Zero
    '1',                    // 2: Single digit
    '42',                   // 3: Two digits
    '1234567890',           // 4: Large number
    '4294967295',           // 5: Maximum value
    '65536',                // 6: Above integer range
    '100000',               // 7: Common large value
    ' 12345',               // 8: Leading whitespace
    '98765 ',               // 9: Trailing whitespace
    '  54321  ',            // 10: Both whitespace
    'Count=1000000',        // 11: Text prefix

    // Invalid cases
    '',                     // 12: Empty string
    '   ',                  // 13: Whitespace only
    '-1',                   // 14: Negative number
    '-1000',                // 15: Negative number
    '4294967296',           // 16: Above maximum - ATOI truncates to max SLONG
    '9999999999',           // 17: Way above maximum - ATOI truncates to max SLONG
    'abc',                  // 18: No digits
    'xyz123',               // 19: Letters before number - ATOI extracts 123
    {' ', $0D, $0A},        // 20: Whitespace characters (space, CR, LF)
    {' ', $0D, $0A, '1', '5', '0', '0', $09},  // 21: Whitespace with number (space, CR, LF, '1500', tab)
    '   100  200   '        // 22: Multiple numbers with spaces
}

constant char NAV_PARSE_LONG_EXPECTED_RESULT[] = {
    // Valid (1-11)
    true, true, true, true, true, true, true, true, true, true, true,
    // Invalid (12-18)
    false, false, false, false, false, false, false,
    // Valid (19)
    true,
    // Invalid (20)
    false,
    // Valid (21-22)
    true, true
}

DEFINE_VARIABLE

volatile long NAV_PARSE_LONG_EXPECTED_VALUES[14]

define_function InitializeParseLongTestData() {
    NAV_PARSE_LONG_EXPECTED_VALUES[1] = 0
    NAV_PARSE_LONG_EXPECTED_VALUES[2] = 1
    NAV_PARSE_LONG_EXPECTED_VALUES[3] = 42
    NAV_PARSE_LONG_EXPECTED_VALUES[4] = 1234567890
    NAV_PARSE_LONG_EXPECTED_VALUES[5] = type_cast(4294967295)
    NAV_PARSE_LONG_EXPECTED_VALUES[6] = 65536
    NAV_PARSE_LONG_EXPECTED_VALUES[7] = 100000
    NAV_PARSE_LONG_EXPECTED_VALUES[8] = 12345
    NAV_PARSE_LONG_EXPECTED_VALUES[9] = 98765
    NAV_PARSE_LONG_EXPECTED_VALUES[10] = 54321
    NAV_PARSE_LONG_EXPECTED_VALUES[11] = 1000000
    NAV_PARSE_LONG_EXPECTED_VALUES[12] = 123   // 19: 'xyz123' - extracts 123
    NAV_PARSE_LONG_EXPECTED_VALUES[13] = 1500  // 21: Whitespace with number - extracts 1500
    NAV_PARSE_LONG_EXPECTED_VALUES[14] = 100   // 22: '   100  200   ' - stops at space, returns 100
}

define_function TestNAVParseLong() {
    stack_var integer x
    stack_var integer validCount

    NAVLogTestSuiteStart('NAVParseLong')

    InitializeParseLongTestData()

    validCount = 0

    for (x = 1; x <= length_array(NAV_PARSE_LONG_TESTS); x++) {
        stack_var char result
        stack_var long value
        stack_var char shouldPass

        shouldPass = NAV_PARSE_LONG_EXPECTED_RESULT[x]
        result = NAVParseLong(NAV_PARSE_LONG_TESTS[x], value)

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

            if (!NAVAssertLongEqual('Should parse to the expected long value', NAV_PARSE_LONG_EXPECTED_VALUES[validCount], value)) {
                NAVLogTestFailed(x, itoa(NAV_PARSE_LONG_EXPECTED_VALUES[validCount]), itoa(value))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVParseLong')
}
