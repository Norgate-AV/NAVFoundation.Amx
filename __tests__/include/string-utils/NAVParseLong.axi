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
    '4294967296',           // 16: Above maximum (exact max is 4294967295)
    '9999999999',           // 17: Way above maximum
    'abc',                  // 18: No digits
    'xyz123',               // 19: Letters before number - ATOI extracts 123
    {' ', $0D, $0A},        // 20: Whitespace characters (space, CR, LF)
    {' ', $0D, $0A, '1', '5', '0', '0', $09},  // 21: Whitespace with number (space, CR, LF, '1500', tab)
    '   100  200   ',       // 22: Multiple numbers with spaces

    // Hexadecimal tests
    '0xFFFFFFFF',           // 23: Hex max (4294967295)
    '0x10000',              // 24: Hex above integer range (65536)
    '0xABCDEF',             // 25: Hex large value (11259375)

    // Binary tests
    '0b11111111',           // 26: Binary (255)
    '0b11111111111111111111111111111111',  // 27: Binary max (4294967295)

    // Octal tests
    '0o777',                // 28: Octal (511)
    '0o37777777777',        // 29: Octal max (4294967295)

    // $ prefix hexadecimal tests
    '$FF',                  // 30: $ hex (255)
    '$FFFF',                // 31: $ hex (65535)
    '$FFFFFFFF',            // 32: $ hex max (4294967295)

    // Mixed case prefix tests
    '0XABCD',               // 33: Uppercase hex prefix (43981)
    '0B11111111',           // 34: Uppercase binary prefix (255)
    '0O777',                // 35: Uppercase octal prefix (511)

    // Additional edge cases
    '0x1',                  // 36: Hex single digit (1)
    '0b1',                  // 37: Binary single digit (1)
    '0o1',                  // 38: Octal single digit (1)
    '0x0',                  // 39: Hex zero
    '0xFFFFFFFE',           // 40: Hex near max (4294967294)

    // Invalid multi-base cases
    '0x100000000',          // 41: Hex overflow
    '0xGHI',                // 42: Invalid hex digits
    '0b2',                  // 43: Invalid binary digit
    '0o8',                  // 44: Invalid octal digit
    '$GHIJ'                 // 45: Invalid $ hex digits
}

constant char NAV_PARSE_LONG_EXPECTED_RESULT[] = {
    // Valid (1-11)
    true, true, true, true, true, true, true, true, true, true, true,
    // Invalid (12-16)
    false, false, false, false, false,
    // Invalid (17)
    false,
    // Invalid (18)
    false,
    // Valid (19)
    true,
    // Invalid (20)
    false,
    // Valid (21-22)
    true, true,
    // Hexadecimal - Valid (23-25)
    true, true, true,
    // Binary - Valid (26-27)
    true, true,
    // Octal - Valid (28-29)
    true, true,
    // $ prefix hex - Valid (30-32)
    true, true, true,
    // Mixed case - Valid (33-35)
    true, true, true,
    // Additional edges - Valid (36-40)
    true, true, true, true, true,
    // Invalid multi-base (41-45)
    false, false, false, false, false
}

DEFINE_VARIABLE

volatile long NAV_PARSE_LONG_EXPECTED_VALUES[33]

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
    // Hexadecimal values
    NAV_PARSE_LONG_EXPECTED_VALUES[15] = type_cast(4294967295)  // 23: '0xFFFFFFFF'
    NAV_PARSE_LONG_EXPECTED_VALUES[16] = 65536      // 24: '0x10000'
    NAV_PARSE_LONG_EXPECTED_VALUES[17] = 11259375   // 25: '0xABCDEF'
    // Binary values
    NAV_PARSE_LONG_EXPECTED_VALUES[18] = 255        // 26: '0b11111111'
    NAV_PARSE_LONG_EXPECTED_VALUES[19] = type_cast(4294967295)  // 27: '0b11111111111111111111111111111111'
    // Octal values (28-29 handled dynamically)
    // $ prefix hex
    NAV_PARSE_LONG_EXPECTED_VALUES[20] = 255        // 30: '$FF'
    NAV_PARSE_LONG_EXPECTED_VALUES[21] = 65535      // 31: '$FFFF'
    NAV_PARSE_LONG_EXPECTED_VALUES[22] = type_cast(4294967295)  // 32: '$FFFFFFFF'
    // Mixed case prefixes
    NAV_PARSE_LONG_EXPECTED_VALUES[23] = 43981      // 33: '0XABCD'
    NAV_PARSE_LONG_EXPECTED_VALUES[24] = 255        // 34: '0B11111111'
    NAV_PARSE_LONG_EXPECTED_VALUES[25] = 511        // 35: '0O777'
    // Additional edges
    NAV_PARSE_LONG_EXPECTED_VALUES[26] = 1          // 36: '0x1'
    NAV_PARSE_LONG_EXPECTED_VALUES[27] = 1          // 37: '0b1'
    NAV_PARSE_LONG_EXPECTED_VALUES[28] = 1          // 38: '0o1'
    NAV_PARSE_LONG_EXPECTED_VALUES[29] = 0          // 39: '0x0'
    NAV_PARSE_LONG_EXPECTED_VALUES[30] = type_cast(4294967294)  // 40: '0xFFFFFFFE'
    // Octal values from tests 28-29
    NAV_PARSE_LONG_EXPECTED_VALUES[31] = 511        // 28: '0o777'
    NAV_PARSE_LONG_EXPECTED_VALUES[32] = type_cast(4294967295)  // 29: '0o37777777777'
    NAV_PARSE_LONG_EXPECTED_VALUES[33] = 0  // Placeholder
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
        stack_var long expectedValue

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

            // Map validCount to expected value - octal values 28-29 are at indices 31-32
            if (validCount <= 19) {
                expectedValue = NAV_PARSE_LONG_EXPECTED_VALUES[validCount]
            }
            else if (validCount == 20 || validCount == 21) {
                // Tests 28-29 (octal) map to array indices 31-32
                expectedValue = NAV_PARSE_LONG_EXPECTED_VALUES[validCount + 11]
            }
            else if (validCount >= 22) {
                // Tests 30+ map to array indices 20+
                expectedValue = NAV_PARSE_LONG_EXPECTED_VALUES[validCount - 2]
            }

            if (!NAVAssertLongEqual('Should parse to the expected long value', expectedValue, value)) {
                NAVLogTestFailed(x, itoa(expectedValue), itoa(value))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVParseLong')
}
