PROGRAM_NAME='NAVInt64FindHighestBit'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Int64.axi'

DEFINE_CONSTANT

// 2D array format: [test_case][2] where [test_case][1] = Hi, [test_case][2] = Lo
constant long TEST_VALUES[17][2] = {
    // Zero value
    {0, 0},                // Test case 1: All zeros - should return -1

    // Low word cases (bit positions 0-31)
    {0, 1},                // Test case 2: Bit 0 set - should return 0
    {0, 2},                // Test case 3: Bit 1 set - should return 1
    {0, 4},                // Test case 4: Bit 2 set - should return 2
    {0, $8000},            // Test case 5: Bit 15 set - should return 15
    {0, $10000},           // Test case 6: Bit 16 set - should return 16
    {0, $40000000},        // Test case 7: Bit 30 set - should return 30
    {0, $80000000},        // Test case 8: Bit 31 set - should return 31
    {0, $FF},              // Test case 9: Bits 0-7 set - should return 7

    // High word cases (bit positions 32-63)
    {1, 0},                // Test case 10: Bit 32 set - should return 32
    {2, 0},                // Test case 11: Bit 33 set - should return 33
    {4, 0},                // Test case 12: Bit 34 set - should return 34
    {$8000, 0},            // Test case 13: Bit 47 set - should return 47
    {$10000, 0},           // Test case 14: Bit 48 set - should return 48
    {$40000000, 0},        // Test case 15: Bit 62 set - should return 62
    {$80000000, 0},        // Test case 16: Bit 63 set - should return 63
    {$FFFFFFFF, $FFFFFFFF} // Test case 17: All bits set - should return 63
}

// Expected highest bit values for each test case
constant sinteger EXPECTED_RESULTS[17] = {
    -1,    // Test case 1: Zero value
    0,     // Test case 2: Bit 0
    1,     // Test case 3: Bit 1
    2,     // Test case 4: Bit 2
    15,    // Test case 5: Bit 15
    16,    // Test case 6: Bit 16
    30,    // Test case 7: Bit 30
    31,    // Test case 8: Bit 31
    7,     // Test case 9: Bits 0-7 (highest is 7)
    32,    // Test case 10: Bit 32
    33,    // Test case 11: Bit 33
    34,    // Test case 12: Bit 34
    47,    // Test case 13: Bit 47
    48,    // Test case 14: Bit 48
    62,    // Test case 15: Bit 62
    63,    // Test case 16: Bit 63
    63     // Test case 17: All bits (highest is 63)
}

/**
 * @function CreateTestInt64Value
 * @description Helper function to create an Int64 struct from test values array
 *
 * @param {integer} index - Array index (1-based)
 * @param {_NAVInt64} result - The struct to populate
 */
define_function CreateTestInt64Value(integer index, _NAVInt64 result) {
    if (index >= 1 && index <= 17) {
        result.Hi = TEST_VALUES[index][1]
        result.Lo = TEST_VALUES[index][2]
    }
    else {
        result.Hi = 0
        result.Lo = 0
    }
}

define_function RunNAVInt64FindHighestBitTests() {
    stack_var integer i
    stack_var sinteger result
    stack_var _NAVInt64 testVal

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVInt64FindHighestBit Tests ******************')

    for (i = 1; i <= 17; i++) {
        // Create test value from the array
        CreateTestInt64Value(i, testVal)

        // Call the function
        result = NAVInt64FindHighestBit(testVal)

        // Verify result
        if (result == EXPECTED_RESULTS[i]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed: Value $', format('%08x', testVal.Hi), format('%08x', testVal.Lo), ', highest bit = ', itoa(result)")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Test ', itoa(i), ' FAILED: Value $', format('%08x', testVal.Hi), format('%08x', testVal.Lo)")
            NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'  Expected highest bit = ', itoa(EXPECTED_RESULTS[i]), ', got = ', itoa(result)")
        }
    }

    {
        // Additional test cases with complex bit patterns
        stack_var _NAVInt64 complexTest1
        stack_var _NAVInt64 complexTest2

        complexTest1.Hi = $ABCDEF12
        complexTest1.Lo = $34567890
        result = NAVInt64FindHighestBit(complexTest1)
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Complex test 1: Value $', format('%08x', complexTest1.Hi), format('%08x', complexTest1.Lo), ', highest bit = ', itoa(result)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  (Expected value should be near 63, as the high bits are set)'")

        complexTest2.Hi = 0
        complexTest2.Lo = $FEDCBA98
        result = NAVInt64FindHighestBit(complexTest2)
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Complex test 2: Value $', format('%08x', complexTest2.Hi), format('%08x', complexTest2.Lo), ', highest bit = ', itoa(result)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  (Expected value should be near 31, as only the low word has bits set)'")

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '************ NAVInt64FindHighestBit Tests Complete *************')
    }
}
