PROGRAM_NAME='NAVBinaryCountLeadingZeros'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data: [value, expected]
constant long BINARY_COUNT_LEADING_ZEROS_TESTS[][2] = {
    { $00000000, 32 },      // Test 1: Zero value - all 32 bits are zero
    { $80000000, 0 },       // Test 2: MSB set - no leading zeros
    { $40000000, 1 },       // Test 3: Second MSB set - 1 leading zero
    { $20000000, 2 },       // Test 4: Third MSB set - 2 leading zeros
    { $FFFFFFFF, 0 },       // Test 5: All bits set - no leading zeros
    { $00000001, 31 },      // Test 6: Only LSB set - 31 leading zeros
    { $0000FFFF, 16 },      // Test 7: Lower 16 bits set - 16 leading zeros
    { $000000FF, 24 },      // Test 8: Lower 8 bits set - 24 leading zeros
    { $00008000, 16 },      // Test 9: Bit 15 set - 16 leading zeros
    { $00000080, 24 },      // Test 10: Bit 7 set - 24 leading zeros
    { $0000000F, 28 },      // Test 11: Lower 4 bits set - 28 leading zeros
    { $00FF0000, 8 },       // Test 12: Bits 23-16 set - 8 leading zeros
    { $FF000000, 0 },       // Test 13: Upper byte set - no leading zeros
    { $AAAAAAAA, 0 },       // Test 14: Alternating bits (MSB set) - no leading zeros
    { $55555555, 1 },       // Test 15: Alternating bits (MSB clear) - 1 leading zero
    { $01000000, 7 },       // Test 16: Bit 24 set - 7 leading zeros
    { $00001000, 19 },      // Test 17: Bit 12 set - 19 leading zeros
    { $0010000F, 11 },      // Test 18: Bit 20 and lower 4 bits - 11 leading zeros
    { $00000002, 30 },      // Test 19: Bit 1 set - 30 leading zeros
    { $10000000, 3 }        // Test 20: Bit 28 set - 3 leading zeros
}

define_function TestNAVBinaryCountLeadingZeros() {
    stack_var integer x

    NAVLog("'***************** NAVBinaryCountLeadingZeros *****************'")

    for (x = 1; x <= length_array(BINARY_COUNT_LEADING_ZEROS_TESTS); x++) {
        stack_var integer result

        result = NAVBinaryCountLeadingZeros(type_cast(BINARY_COUNT_LEADING_ZEROS_TESTS[x][1]))

        if (!NAVAssertIntegerEqual('Should count leading zeros correctly', BINARY_COUNT_LEADING_ZEROS_TESTS[x][2], result)) {
            NAVLogTestFailed(x, itoa(BINARY_COUNT_LEADING_ZEROS_TESTS[x][2]), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

