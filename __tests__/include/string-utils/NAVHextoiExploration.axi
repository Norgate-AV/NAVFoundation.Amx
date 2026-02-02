PROGRAM_NAME='NAVHextoiExploration.axi'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char HEXTOI_TEST_INPUTS[][255] = {
    // Basic hex digits
    'FF',                   // 1: Basic hex - expect 255
    '1A',                   // 2: Basic hex - expect 26
    '0',                    // 3: Zero - expect 0
    'FFFF',                 // 4: Large hex - expect 65535

    // With 0x prefix
    '0xFF',                 // 5: With 0x prefix
    '0X1A',                 // 6: With 0X prefix
    '0x0',                  // 7: Zero with prefix

    // With $ prefix
    '$FF',                  // 8: With $ prefix
    '$1A',                  // 9: With $ prefix
    '$0',                   // 10: Zero with $ prefix

    // With whitespace
    '  FF',                 // 11: Leading whitespace
    'FF  ',                 // 12: Trailing whitespace
    '  1A  ',               // 13: Both whitespace

    // With negative sign
    '-FF',                  // 14: Negative hex (no prefix)
    '-0xFF',                // 15: Negative with 0x prefix
    '-$FF',                 // 16: Negative with $ prefix

    // With non-hex characters
    'GGG',                  // 17: No valid hex - expect 0
    '1G2',                  // 18: Invalid char in middle
    'xyz1A',                // 19: Text prefix
    '1Axyz',                // 20: Text suffix

    // Mixed/edge cases
    '',                     // 21: Empty string - expect 0
    '   ',                  // 22: Only whitespace - expect 0
    '0xGGG',                // 23: Prefix but no valid hex
    'Value=FF',             // 24: Text before hex
    'FF FF',                // 25: Multiple hex with space
    '0xFF 0x10',            // 26: Multiple hex with prefixes

    // Case sensitivity
    'ff',                   // 27: Lowercase
    'Ff',                   // 28: Mixed case
    '0xff',                 // 29: Lowercase prefix

    // Large values
    'FFFFFFFF',             // 30: Max 32-bit - expect 4294967295
    '100000000',            // 31: Overflow test

    // Special patterns
    '0x',                   // 32: Prefix only
    '$',                    // 33: $ only
    '0x 10',                // 34: Space after prefix
    '10 20 30'              // 35: Multiple numbers with spaces
}

constant long HEXTOI_EXPECTED_VALUES[35] = {
    255,            // 1: 'FF'
    26,             // 2: '1A'
    0,              // 3: '0'
    65535,          // 4: 'FFFF'
    0,              // 5: '0xFF' - UNKNOWN (testing)
    0,              // 6: '0X1A' - UNKNOWN (testing)
    0,              // 7: '0x0' - UNKNOWN (testing)
    0,              // 8: '$FF' - UNKNOWN (testing)
    0,              // 9: '$1A' - UNKNOWN (testing)
    0,              // 10: '$0' - UNKNOWN (testing)
    255,            // 11: '  FF' - UNKNOWN (testing)
    255,            // 12: 'FF  ' - UNKNOWN (testing)
    26,             // 13: '  1A  ' - UNKNOWN (testing)
    0,              // 14: '-FF' - UNKNOWN (testing)
    0,              // 15: '-0xFF' - UNKNOWN (testing)
    0,              // 16: '-$FF' - UNKNOWN (testing)
    0,              // 17: 'GGG' - expect 0
    1,              // 18: '1G2' - UNKNOWN (testing)
    0,              // 19: 'xyz1A' - UNKNOWN (testing)
    26,             // 20: '1Axyz' - UNKNOWN (testing)
    0,              // 21: '' - expect 0
    0,              // 22: '   ' - expect 0
    0,              // 23: '0xGGG' - UNKNOWN (testing)
    0,              // 24: 'Value=FF' - UNKNOWN (testing)
    255,            // 25: 'FF FF' - UNKNOWN (testing)
    255,            // 26: '0xFF 0x10' - UNKNOWN (testing)
    255,            // 27: 'ff' - lowercase
    255,            // 28: 'Ff' - mixed
    0,              // 29: '0xff' - UNKNOWN (testing)
    4294967295,  // 30: 'FFFFFFFF' - max 32-bit
    0,              // 31: '100000000' - UNKNOWN (testing)
    0,              // 32: '0x' - expect 0
    0,              // 33: '$' - expect 0
    0,              // 34: '0x 10' - UNKNOWN (testing)
    16              // 35: '10 20 30' - UNKNOWN (testing)
}

define_function TestHextoiExploration() {
    stack_var integer x
    stack_var long result

    NAVLogTestSuiteStart('hextoi() Exploration')

    NAVLog("'Testing hextoi() behavior with ', itoa(length_array(HEXTOI_TEST_INPUTS)), ' different inputs'")
    NAVLog("'Note: Many expected values are set to 0 because behavior is unknown - we are discovering it!'")
    NAVLog("'='")

    for (x = 1; x <= length_array(HEXTOI_TEST_INPUTS); x++) {
        result = hextoi(HEXTOI_TEST_INPUTS[x])

        // Log the result for analysis
        NAVLog("'Test #', itoa(x), ': Input=[', HEXTOI_TEST_INPUTS[x], '] => Result=', itoa(result), ' (Expected: ', itoa(HEXTOI_EXPECTED_VALUES[x]), ')'")

        // We're not failing tests here - just observing behavior
        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('hextoi() Exploration')
}
