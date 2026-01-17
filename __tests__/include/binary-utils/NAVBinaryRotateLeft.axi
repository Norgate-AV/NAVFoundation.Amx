PROGRAM_NAME='NAVBinaryRotateLeft'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data: [value, count, expected]
constant long BINARY_ROTATE_LEFT_TESTS[][3] = {
    { $00000001, 1, $00000002 },        // Test 1: Rotate 0x00000001 left by 1 -> 0x00000002
    { $00000001, 4, $00000010 },        // Test 2: Rotate 0x00000001 left by 4 -> 0x00000010
    { $00000001, 8, $00000100 },        // Test 3: Rotate 0x00000001 left by 8 -> 0x00000100
    { $00000001, 16, $00010000 },       // Test 4: Rotate 0x00000001 left by 16 -> 0x00010000
    { $00000001, 31, $80000000 },       // Test 5: Rotate 0x00000001 left by 31 -> 0x80000000
    { $80000000, 1, $00000001 },        // Test 6: Rotate 0x80000000 left by 1 (wraps) -> 0x00000001
    { $00000003, 1, $00000006 },        // Test 7: Rotate 0x00000003 left by 1 -> 0x00000006
    { $000000FF, 8, $0000FF00 },        // Test 8: Rotate 0x000000FF left by 8 -> 0x0000FF00
    { $FFFFFFFF, 1, $FFFFFFFF },        // Test 9: Rotate all 1s left by 1 -> all 1s
    { $FFFFFFFF, 16, $FFFFFFFF },       // Test 10: Rotate all 1s left by 16 -> all 1s
    { $00000000, 10, $00000000 },       // Test 11: Rotate all 0s left by 10 -> all 0s
    { $12345678, 4, $23456781 },        // Test 12: Rotate 0x12345678 left by 4 -> 0x23456781
    { $A5A5A5A5, 8, $A5A5A5A5 },        // Test 13: Rotate pattern left by 8 -> same pattern
    { $00000001, 0, $00000001 },        // Test 14: Rotate by 0 -> no change
    { $0000FFFF, 16, $FFFF0000 }        // Test 15: Rotate 0x0000FFFF left by 16 -> 0xFFFF0000
}

define_function TestNAVBinaryRotateLeft() {
    stack_var integer x
    stack_var long result

    NAVLog("'***************** NAVBinaryRotateLeft *****************'")

    for (x = 1; x <= length_array(BINARY_ROTATE_LEFT_TESTS); x++) {
        result = NAVBinaryRotateLeft(BINARY_ROTATE_LEFT_TESTS[x][1], BINARY_ROTATE_LEFT_TESTS[x][2])

        if (!NAVAssertLongEqual('Should rotate bits left correctly', BINARY_ROTATE_LEFT_TESTS[x][3], result)) {
            NAVLogTestFailed(x, itohex(BINARY_ROTATE_LEFT_TESTS[x][3]), itohex(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
