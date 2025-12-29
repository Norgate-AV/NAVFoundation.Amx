PROGRAM_NAME='NAVByteToBinaryString'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_VARIABLE

// Test data arrays - separate arrays for values and expected strings
volatile char BYTE_TO_BINARY_STRING_VALUES[] = {
    $00, $01, $FF, $A5, $5A, $F0, $0F, $80, $55, $AA, $12, $C3, $7E, $42, $20
}

volatile char BYTE_TO_BINARY_STRING_EXPECTED[15][8]

define_function InitializeByteToBinaryStringTestData() {
    BYTE_TO_BINARY_STRING_EXPECTED[1]  = '00000000'  // Test 1: All bits 0
    BYTE_TO_BINARY_STRING_EXPECTED[2]  = '00000001'  // Test 2: LSB set
    BYTE_TO_BINARY_STRING_EXPECTED[3]  = '11111111'  // Test 3: All bits 1
    BYTE_TO_BINARY_STRING_EXPECTED[4]  = '10100101'  // Test 4: Alternating pattern
    BYTE_TO_BINARY_STRING_EXPECTED[5]  = '01011010'  // Test 5: Inverse alternating pattern
    BYTE_TO_BINARY_STRING_EXPECTED[6]  = '11110000'  // Test 6: Upper nibble set
    BYTE_TO_BINARY_STRING_EXPECTED[7]  = '00001111'  // Test 7: Lower nibble set
    BYTE_TO_BINARY_STRING_EXPECTED[8]  = '10000000'  // Test 8: MSB only set
    BYTE_TO_BINARY_STRING_EXPECTED[9]  = '01010101'  // Test 9: 01010101 pattern
    BYTE_TO_BINARY_STRING_EXPECTED[10] = '10101010'  // Test 10: 10101010 pattern
    BYTE_TO_BINARY_STRING_EXPECTED[11] = '00010010'  // Test 11: Random pattern 1
    BYTE_TO_BINARY_STRING_EXPECTED[12] = '11000011'  // Test 12: Random pattern 2
    BYTE_TO_BINARY_STRING_EXPECTED[13] = '01111110'  // Test 13: Random pattern 3
    BYTE_TO_BINARY_STRING_EXPECTED[14] = '01000010'  // Test 14: ASCII 'B'
    BYTE_TO_BINARY_STRING_EXPECTED[15] = '00100000'  // Test 15: ASCII space
}

define_function TestNAVByteToBinaryString() {
    stack_var integer x
    stack_var char result[8]

    NAVLog("'***************** NAVByteToBinaryString *****************'")

    InitializeByteToBinaryStringTestData()

    for (x = 1; x <= length_array(BYTE_TO_BINARY_STRING_VALUES); x++) {
        result = NAVByteToBinaryString(BYTE_TO_BINARY_STRING_VALUES[x])

        if (!NAVAssertStringEqual('Should convert byte to binary string correctly', BYTE_TO_BINARY_STRING_EXPECTED[x], result)) {
            NAVLogTestFailed(x, BYTE_TO_BINARY_STRING_EXPECTED[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }
}
