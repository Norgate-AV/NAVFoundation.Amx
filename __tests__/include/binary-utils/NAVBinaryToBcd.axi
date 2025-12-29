PROGRAM_NAME='NAVBinaryToBcd'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data: [value, expected]
constant long BINARY_TO_BCD_TESTS[][2] = {
    // Binary integer, expected BCD result
    { 0, $00 },                         // Test 1: 0 -> BCD 0x00
    { 1, $01 },                         // Test 2: 1 -> BCD 0x01
    { 9, $09 },                         // Test 3: 9 -> BCD 0x09
    { 10, $10 },                        // Test 4: 10 -> BCD 0x10
    { 15, $15 },                        // Test 5: 15 -> BCD 0x15
    { 19, $19 },                        // Test 6: 19 -> BCD 0x19
    { 20, $20 },                        // Test 7: 20 -> BCD 0x20
    { 42, $42 },                        // Test 8: 42 -> BCD 0x42
    { 50, $50 },                        // Test 9: 50 -> BCD 0x50
    { 99, $99 },                        // Test 10: 99 -> BCD 0x99
    { 12, $12 },                        // Test 11: 12 -> BCD 0x12
    { 34, $34 },                        // Test 12: 34 -> BCD 0x34
    { 56, $56 },                        // Test 13: 56 -> BCD 0x56
    { 78, $78 },                        // Test 14: 78 -> BCD 0x78
    { 87, $87 },                        // Test 15: 87 -> BCD 0x87
    { 100, $0100 },                     // Test 16: 100 -> BCD 0x0100
    { 255, $0255 },                     // Test 17: 255 -> BCD 0x0255
    { 1234, $1234 },                    // Test 18: 1234 -> BCD 0x1234
    { 9999, $9999 }                     // Test 19: 9999 -> BCD 0x9999
}

define_function TestNAVBinaryToBcd() {
    stack_var integer x
    stack_var long result

    NAVLog("'***************** NAVBinaryToBcd *****************'")

    for (x = 1; x <= length_array(BINARY_TO_BCD_TESTS); x++) {
        result = NAVBinaryToBcd(type_cast(BINARY_TO_BCD_TESTS[x][1]))

        if (!NAVAssertLongEqual('Should convert binary to BCD correctly', BINARY_TO_BCD_TESTS[x][2], result)) {
            NAVLogTestFailed(x, format('$%04X', BINARY_TO_BCD_TESTS[x][2]), format('$%04X', result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
