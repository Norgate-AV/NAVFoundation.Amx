PROGRAM_NAME='NAVBinaryGetBit'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data: [value, bit, expected]
constant long BINARY_GET_BIT_TESTS[][3] = {
    // value, bit position, expected
    { $00000001, 0, 1 },                // Test 1: Bit 0 of 0x00000001 is 1
    { $00000001, 1, 0 },                // Test 2: Bit 1 of 0x00000001 is 0
    { $00000002, 1, 1 },                // Test 3: Bit 1 of 0x00000002 is 1
    { $00000004, 2, 1 },                // Test 4: Bit 2 of 0x00000004 is 1
    { $00000008, 3, 1 },                // Test 5: Bit 3 of 0x00000008 is 1
    { $00000010, 4, 1 },                // Test 6: Bit 4 of 0x00000010 is 1
    { $80000000, 31, 1 },               // Test 7: Bit 31 (MSB) of 0x80000000 is 1
    { $80000000, 30, 0 },               // Test 8: Bit 30 of 0x80000000 is 0
    { $00000000, 0, 0 },                // Test 9: All bits 0
    { $00000000, 15, 0 },               // Test 10: All bits 0
    { $FFFFFFFF, 0, 1 },                // Test 11: All bits 1, check bit 0
    { $FFFFFFFF, 15, 1 },               // Test 12: All bits 1, check bit 15
    { $FFFFFFFF, 31, 1 },               // Test 13: All bits 1, check bit 31
    { $000000A5, 0, 1 },                // Test 14: 0xA5 = 10100101, bit 0 is 1
    { $000000A5, 2, 1 },                // Test 15: 0xA5 = 10100101, bit 2 is 1
    { $000000A5, 5, 1 },                // Test 16: 0xA5 = 10100101, bit 5 is 1
    { $000000A5, 7, 1 },                // Test 17: 0xA5 = 10100101, bit 7 is 1
    { $000000A5, 1, 0 },                // Test 18: 0xA5 = 10100101, bit 1 is 0
    { $000000A5, 3, 0 },                // Test 19: 0xA5 = 10100101, bit 3 is 0
    { $000000A5, 4, 0 }                 // Test 20: 0xA5 = 10100101, bit 4 is 0
}

define_function TestNAVBinaryGetBit() {
    stack_var integer x
    stack_var long result

    NAVLog("'***************** NAVBinaryGetBit *****************'")

    for (x = 1; x <= length_array(BINARY_GET_BIT_TESTS); x++) {
        result = NAVBinaryGetBit(BINARY_GET_BIT_TESTS[x][1], BINARY_GET_BIT_TESTS[x][2])

        if (!NAVAssertLongEqual('Should extract bit correctly', BINARY_GET_BIT_TESTS[x][3], result)) {
            NAVLogTestFailed(x, itoa(BINARY_GET_BIT_TESTS[x][3]), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
