PROGRAM_NAME='NAVBinaryRotateRight'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data: [value, count, expected]
constant long BINARY_ROTATE_RIGHT_TESTS[][3] = {
    // value, count, expected
    { $00000002, 1, $00000001 },        // Test 1: Rotate 0x00000002 right by 1 -> 0x00000001
    { $00000010, 4, $00000001 },        // Test 2: Rotate 0x00000010 right by 4 -> 0x00000001
    { $00000100, 8, $00000001 },        // Test 3: Rotate 0x00000100 right by 8 -> 0x00000001
    { $00010000, 16, $00000001 },       // Test 4: Rotate 0x00010000 right by 16 -> 0x00000001
    { $80000000, 31, $00000001 },       // Test 5: Rotate 0x80000000 right by 31 -> 0x00000001
    { $00000001, 1, $80000000 },        // Test 6: Rotate 0x00000001 right by 1 (wraps) -> 0x80000000
    { $00000006, 1, $00000003 },        // Test 7: Rotate 0x00000006 right by 1 -> 0x00000003
    { $0000FF00, 8, $000000FF },        // Test 8: Rotate 0x0000FF00 right by 8 -> 0x000000FF
    { $FFFFFFFF, 1, $FFFFFFFF },        // Test 9: Rotate all 1s right by 1 -> all 1s
    { $FFFFFFFF, 16, $FFFFFFFF },       // Test 10: Rotate all 1s right by 16 -> all 1s
    { $00000000, 10, $00000000 },       // Test 11: Rotate all 0s right by 10 -> all 0s
    { $12345678, 4, $81234567 },        // Test 12: Rotate 0x12345678 right by 4 -> 0x81234567
    { $A5A5A5A5, 8, $A5A5A5A5 },        // Test 13: Rotate pattern right by 8 -> same pattern
    { $00000001, 0, $00000001 },        // Test 14: Rotate by 0 -> no change
    { $FFFF0000, 16, $0000FFFF }        // Test 15: Rotate 0xFFFF0000 right by 16 -> 0x0000FFFF
}

define_function TestNAVBinaryRotateRight() {
    stack_var integer x
    stack_var long result

    NAVLog("'***************** NAVBinaryRotateRight *****************'")

    for (x = 1; x <= length_array(BINARY_ROTATE_RIGHT_TESTS); x++) {
        result = NAVBinaryRotateRight(BINARY_ROTATE_RIGHT_TESTS[x][1], BINARY_ROTATE_RIGHT_TESTS[x][2])

        if (!NAVAssertLongEqual('Should rotate bits right correctly', BINARY_ROTATE_RIGHT_TESTS[x][3], result)) {
            NAVLogTestFailed(x, itohex(BINARY_ROTATE_RIGHT_TESTS[x][3]), itohex(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
