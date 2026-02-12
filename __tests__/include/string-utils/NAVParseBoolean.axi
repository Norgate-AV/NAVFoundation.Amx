PROGRAM_NAME='NAVParseBoolean.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char NAV_PARSE_BOOLEAN_TESTS[][255] = {
    // Valid true values (case variations)
    '1',                    // 1: Numeric true
    'true',                 // 2: Lowercase true
    'True',                 // 3: Capitalized true
    'TRUE',                 // 4: Uppercase true
    'TrUe',                 // 5: Mixed case true
    'yes',                  // 6: Lowercase yes
    'Yes',                  // 7: Capitalized yes
    'YES',                  // 8: Uppercase yes
    'YeS',                  // 9: Mixed case yes
    'on',                   // 10: Lowercase on
    'On',                   // 11: Capitalized on
    'ON',                   // 12: Uppercase on
    'oN',                   // 13: Mixed case on

    // Valid false values (case variations)
    '0',                    // 14: Numeric false
    'false',                // 15: Lowercase false
    'False',                // 16: Capitalized false
    'FALSE',                // 17: Uppercase false
    'FaLsE',                // 18: Mixed case false
    'no',                   // 19: Lowercase no
    'No',                   // 20: Capitalized no
    'NO',                   // 21: Uppercase no
    'nO',                   // 22: Mixed case no
    'off',                  // 23: Lowercase off
    'Off',                  // 24: Capitalized off
    'OFF',                  // 25: Uppercase off
    'oFf',                  // 26: Mixed case off

    // Invalid values
    '',                     // 27: Empty string
    '   ',                  // 28: Whitespace only
    '2',                    // 29: Invalid number
    '-1',                   // 30: Negative number
    '10',                   // 31: Multi-digit number
    'maybe',                // 32: Invalid word
    'unknown',              // 33: Invalid word
    'null',                 // 34: Invalid word
    'undefined',            // 35: Invalid word
    'y',                    // 36: Abbreviated (not recognized)
    'n',                    // 37: Abbreviated (not recognized)
    't',                    // 38: Abbreviated (not recognized)
    'f',                    // 39: Abbreviated (not recognized)
    'enabled',              // 40: Not recognized
    'disabled',             // 41: Not recognized
    'active',               // 42: Not recognized
    'inactive',             // 43: Not recognized
    'true ',                // 44: Trailing space (should fail - not normalized)
    ' true',                // 45: Leading space (should fail - not normalized)
    ' true ',               // 46: Both spaces (should fail - not normalized)
    'true1',                // 47: True with trailing digit
    '1true',                // 48: True with leading digit
    'truee',                // 49: Misspelled
    'tru',                  // 50: Truncated
    'yess',                 // 51: Misspelled
    'ye',                   // 52: Truncated
    'onnn',                 // 53: Misspelled
    'falses',               // 54: Misspelled
    'fals',                 // 55: Truncated
    'noo',                  // 56: Misspelled
    'offf',                 // 57: Misspelled
    'of',                   // 58: Truncated
    'TRUE ',                // 59: Uppercase with trailing space
    ' FALSE',               // 60: Uppercase with leading space
    {$09, '1'},              // 61: Tab before 1
    {'0', $0A},              // 62: Newline after 0
    {'t', 'r', 'u', 'e', $0D}, // 63: CR after true
    '0x1',                  // 64: Hex notation
    '0b1',                  // 65: Binary notation
    'True!',                // 66: True with punctuation
    'yes?',                 // 67: Yes with punctuation
    'on.',                  // 68: On with punctuation
    '[true]',               // 69: True in brackets
    '{false}',              // 70: False in braces
    '"yes"',                // 71: Yes in quotes
    "'no'",                 // 72: No in single quotes
    'oui',                  // 73: French yes
    'non',                  // 74: French no
    'si',                   // 75: Spanish yes
    'ja',                   // 76: German yes
    'nein'                  // 77: German no
}

constant char NAV_PARSE_BOOLEAN_EXPECTED_RESULT[] = {
    // Valid true (1-13)
    true, true, true, true, true, true, true, true, true, true,
    true, true, true,

    // Valid false (14-26)
    true, true, true, true, true, true, true, true, true, true,
    true, true, true,

    // Invalid (27-77)
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false,
    false
}

constant char NAV_PARSE_BOOLEAN_EXPECTED_VALUES[] = {
    // True values (1-13)
    true, true, true, true, true, true, true, true, true, true,
    true, true, true,

    // False values (14-26)
    false, false, false, false, false, false, false, false, false, false,
    false, false, false
}

define_function TestNAVParseBoolean() {
    stack_var integer x
    stack_var integer validCount

    NAVLogTestSuiteStart('NAVParseBoolean')

    validCount = 0

    for (x = 1; x <= length_array(NAV_PARSE_BOOLEAN_TESTS); x++) {
        stack_var char result
        stack_var char value
        stack_var char shouldPass

        shouldPass = NAV_PARSE_BOOLEAN_EXPECTED_RESULT[x]
        result = NAVParseBoolean(NAV_PARSE_BOOLEAN_TESTS[x], value)

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
            stack_var char expectedValue

            validCount++
            expectedValue = NAV_PARSE_BOOLEAN_EXPECTED_VALUES[validCount]

            if (!NAVAssertBooleanEqual('Should parse to the expected boolean value', expectedValue, value)) {
                NAVLogTestFailed(x, NAVBooleanToString(expectedValue), NAVBooleanToString(value))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVParseBoolean')
}
