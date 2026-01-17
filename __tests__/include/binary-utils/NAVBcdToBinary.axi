PROGRAM_NAME='NAVBcdToBinary'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data: [bcdValue, expected]
constant long BCD_TO_BINARY_TESTS[][2] = {
    // BCD byte, expected integer result
    { $00, 0 },                         // Test 1: BCD 0x00 -> 0
    { $01, 1 },                         // Test 2: BCD 0x01 -> 1
    { $09, 9 },                         // Test 3: BCD 0x09 -> 9
    { $10, 10 },                        // Test 4: BCD 0x10 -> 10
    { $15, 15 },                        // Test 5: BCD 0x15 -> 15
    { $19, 19 },                        // Test 6: BCD 0x19 -> 19
    { $20, 20 },                        // Test 7: BCD 0x20 -> 20
    { $42, 42 },                        // Test 8: BCD 0x42 -> 42
    { $50, 50 },                        // Test 9: BCD 0x50 -> 50
    { $99, 99 },                        // Test 10: BCD 0x99 -> 99
    { $12, 12 },                        // Test 11: BCD 0x12 -> 12
    { $34, 34 },                        // Test 12: BCD 0x34 -> 34
    { $56, 56 },                        // Test 13: BCD 0x56 -> 56
    { $78, 78 },                        // Test 14: BCD 0x78 -> 78
    { $87, 87 }                         // Test 15: BCD 0x87 -> 87
}

define_function TestNAVBcdToBinary() {
    stack_var integer x
    stack_var integer result

    NAVLog("'***************** NAVBcdToBinary *****************'")

    for (x = 1; x <= length_array(BCD_TO_BINARY_TESTS); x++) {
        result = NAVBcdToBinary(type_cast(BCD_TO_BINARY_TESTS[x][1]))

        if (!NAVAssertIntegerEqual('Should convert BCD to binary correctly', type_cast(BCD_TO_BINARY_TESTS[x][2]), result)) {
            NAVLogTestFailed(x, itoa(BCD_TO_BINARY_TESTS[x][2]), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
