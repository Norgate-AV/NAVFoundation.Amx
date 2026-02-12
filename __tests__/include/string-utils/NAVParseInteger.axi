PROGRAM_NAME='NAVParseInteger.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_PARSE_INTEGER_TESTS[][255] = {
    // Valid cases
    '0',                    // 1: Zero
    '1',                    // 2: Single digit
    '42',                   // 3: Two digits
    '12345',                // 4: Multiple digits
    '65535',                // 5: Maximum value
    '100',                  // 6: Common value
    ' 42',                  // 7: Leading whitespace
    '42 ',                  // 8: Trailing whitespace
    '  123  ',              // 9: Both whitespace
    'Volume=50',            // 10: Text prefix (ATOI extracts number)
    '99 percent',           // 11: Text suffix

    // Invalid cases
    '',                     // 12: Empty string
    '   ',                  // 13: Whitespace only
    '-1',                   // 14: Negative number
    '-100',                 // 15: Negative number
    '65536',                // 16: Above maximum (65535)
    '99999',                // 17: Way above maximum
    '100000',               // 18: Above maximum
    'abc',                  // 19: No digits
    'xyz123',               // 20: Letters before number (ATOI should extract)
    '123.45',               // 21: Decimal point (not integer format)
    {' ', $0D, $0A},         // 22: Whitespace characters (space, CR, LF)
    {' ', $0D, $0A, '1', '5', '0', $09},         // 23: Whitespace with number (space, CR, LF, '150', tab)
    '   10  20   ',         // 24: Multiple numbers with spaces

    // Hexadecimal tests
    '0xFF',                 // 25: Hex with 0x prefix (255)
    '0XFF',                 // 26: Hex with 0X prefix (255)
    '0x10',                 // 27: Hex with 0x prefix (16)
    '0xFFFF',               // 28: Hex max value (65535)
    '0x0',                  // 29: Hex zero
    '0xABCD',               // 30: Hex mixed case (43981)

    // Binary tests
    '0b1111',               // 31: Binary (15)
    '0B1010',               // 32: Binary uppercase (10)
    '0b11111111',           // 33: Binary (255)
    '0b0',                  // 34: Binary zero
    '0b1111111111111111',   // 35: Binary max (65535)

    // Octal tests
    '0o77',                 // 36: Octal (63)
    '0O777',                // 37: Octal uppercase (511)
    '0o177777',             // 38: Octal max (65535)
    '0o0',                  // 39: Octal zero

    // Invalid multi-base cases
    '0x10000',              // 40: Hex overflow (65536)
    '0b10000000000000000',  // 41: Binary overflow (65536)
    '0o200000',             // 42: Octal overflow (65536)
    '0xGHI',                // 43: Invalid hex digits
    '0b2',                  // 44: Invalid binary digit
    '0o8'                   // 45: Invalid octal digit
}

constant char NAV_PARSE_INTEGER_EXPECTED_RESULT[] = {
    // Valid (1-11)
    true, true, true, true, true, true, true, true, true, true, true,
    // Invalid (12-19)
    false, false, false, false, false, false, false, false,
    // Valid (20-21, 23) - ATOI extracts numbers
    true, true,
    // Invalid (22)
    false,
    // Valid (23-24)
    true, true,
    // Hexadecimal - Valid (25-30)
    true, true, true, true, true, true,
    // Binary - Valid (31-35)
    true, true, true, true, true,
    // Octal - Valid (36-39)
    true, true, true, true,
    // Invalid multi-base (40-45)
    false, false, false, false, false, false
}

constant integer NAV_PARSE_INTEGER_EXPECTED_VALUES[] = {
    0,      // 1: '0'
    1,      // 2: '1'
    42,     // 3: '42'
    12345,  // 4: '12345'
    65535,  // 5: '65535'
    100,    // 6: '100'
    42,     // 7: ' 42'
    42,     // 8: '42 '
    123,    // 9: '  123  '
    50,     // 10: 'Volume=50'
    99,     // 11: '99 percent'
    123,    // 20: 'xyz123' - ATOI extracts 123
    123,    // 21: '123.45' - ATOI extracts 123
    150,    // 23: Whitespace with number - ATOI extracts 150
    10,     // 24: '   10  20   ' - ATOI stops at space, returns 10
    // Hexadecimal values
    255,    // 25: '0xFF'
    255,    // 26: '0XFF'
    16,     // 27: '0x10'
    65535,  // 28: '0xFFFF'
    0,      // 29: '0x0'
    43981,  // 30: '0xABCD'
    // Binary values
    15,     // 31: '0b1111'
    10,     // 32: '0B1010'
    255,    // 33: '0b11111111'
    0,      // 34: '0b0'
    65535,  // 35: '0b1111111111111111'
    // Octal values
    63,     // 36: '0o77'
    511,    // 37: '0O777'
    65535,  // 38: '0o177777'
    0       // 39: '0o0'
}

define_function TestNAVParseInteger() {
    stack_var integer x
    stack_var integer validCount

    NAVLogTestSuiteStart('NAVParseInteger')

    validCount = 0

    for (x = 1; x <= length_array(NAV_PARSE_INTEGER_TESTS); x++) {
        stack_var char result
        stack_var integer value
        stack_var char shouldPass

        shouldPass = NAV_PARSE_INTEGER_EXPECTED_RESULT[x]
        result = NAVParseInteger(NAV_PARSE_INTEGER_TESTS[x], value)

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

            if (!NAVAssertIntegerEqual('Should parse to the expected integer value', NAV_PARSE_INTEGER_EXPECTED_VALUES[validCount], value)) {
                NAVLogTestFailed(x, itoa(NAV_PARSE_INTEGER_EXPECTED_VALUES[validCount]), itoa(value))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVParseInteger')
}
