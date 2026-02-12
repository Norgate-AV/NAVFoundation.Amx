PROGRAM_NAME='NAVByteToBitArray'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_TYPE

struct _NAVByteToBitArrayTest {
    char value
    char expected[8]
}

DEFINE_VARIABLE

volatile _NAVByteToBitArrayTest BYTE_TO_BIT_ARRAY_TESTS[10]

define_function InitializeByteToBitArrayTestData() {
    // Test 1: 0x00 = 00000000
    BYTE_TO_BIT_ARRAY_TESTS[1].value = $00
    BYTE_TO_BIT_ARRAY_TESTS[1].expected = "0,0,0,0,0,0,0,0"

    // Test 2: 0x01 = 00000001
    BYTE_TO_BIT_ARRAY_TESTS[2].value = $01
    BYTE_TO_BIT_ARRAY_TESTS[2].expected = "0,0,0,0,0,0,0,1"

    // Test 3: 0xFF = 11111111
    BYTE_TO_BIT_ARRAY_TESTS[3].value = $FF
    BYTE_TO_BIT_ARRAY_TESTS[3].expected = "1,1,1,1,1,1,1,1"

    // Test 4: 0xA5 = 10100101
    BYTE_TO_BIT_ARRAY_TESTS[4].value = $A5
    BYTE_TO_BIT_ARRAY_TESTS[4].expected = "1,0,1,0,0,1,0,1"

    // Test 5: 0x5A = 01011010
    BYTE_TO_BIT_ARRAY_TESTS[5].value = $5A
    BYTE_TO_BIT_ARRAY_TESTS[5].expected = "0,1,0,1,1,0,1,0"

    // Test 6: 0xF0 = 11110000
    BYTE_TO_BIT_ARRAY_TESTS[6].value = $F0
    BYTE_TO_BIT_ARRAY_TESTS[6].expected = "1,1,1,1,0,0,0,0"

    // Test 7: 0x0F = 00001111
    BYTE_TO_BIT_ARRAY_TESTS[7].value = $0F
    BYTE_TO_BIT_ARRAY_TESTS[7].expected = "0,0,0,0,1,1,1,1"

    // Test 8: 0x80 = 10000000
    BYTE_TO_BIT_ARRAY_TESTS[8].value = $80
    BYTE_TO_BIT_ARRAY_TESTS[8].expected = "1,0,0,0,0,0,0,0"

    // Test 9: 0x55 = 01010101
    BYTE_TO_BIT_ARRAY_TESTS[9].value = $55
    BYTE_TO_BIT_ARRAY_TESTS[9].expected = "0,1,0,1,0,1,0,1"

    // Test 10: 0xAA = 10101010
    BYTE_TO_BIT_ARRAY_TESTS[10].value = $AA
    BYTE_TO_BIT_ARRAY_TESTS[10].expected = "1,0,1,0,1,0,1,0"

    set_length_array(BYTE_TO_BIT_ARRAY_TESTS, 10)
}

define_function TestNAVByteToBitArray() {
    stack_var integer x
    stack_var integer i
    stack_var char result[8]
    stack_var char match

    NAVLog("'***************** NAVByteToBitArray *****************'")

    InitializeByteToBitArrayTestData()

    for (x = 1; x <= length_array(BYTE_TO_BIT_ARRAY_TESTS); x++) {
        result = NAVByteToBitArray(BYTE_TO_BIT_ARRAY_TESTS[x].value)

        // Compare arrays element by element
        match = true
        for (i = 1; i <= 8; i++) {
            if (result[i] != BYTE_TO_BIT_ARRAY_TESTS[x].expected[i]) {
                match = false
                break
            }
        }

        if (!NAVAssertTrue('Should convert byte to bit array correctly', match)) {
            NAVLogTestFailed(x, "'expected bit array'", "'actual bit array'")
            continue
        }

        NAVLogTestPassed(x)
    }
}
