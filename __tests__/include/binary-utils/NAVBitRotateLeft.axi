PROGRAM_NAME='NAVBitRotateLeft'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data: [value, count, expected]
constant long BIT_ROTATE_LEFT_TESTS[][3] = {
    // value, count, expected
    // Test that alias function behaves identically to NAVBinaryRotateLeft
    { $00000001, 1, $00000002 },        // Test 1: Same as NAVBinaryRotateLeft
    { $00000001, 4, $00000010 },        // Test 2: Same as NAVBinaryRotateLeft
    { $80000000, 1, $00000001 },        // Test 3: Wrap test
    { $12345678, 4, $23456781 },        // Test 4: Complex pattern
    { $FFFFFFFF, 8, $FFFFFFFF }         // Test 5: All bits set
}

define_function TestNAVBitRotateLeft() {
    stack_var integer x
    stack_var long result

    NAVLog("'***************** NAVBitRotateLeft *****************'")

    for (x = 1; x <= length_array(BIT_ROTATE_LEFT_TESTS); x++) {
        result = NAVBitRotateLeft(BIT_ROTATE_LEFT_TESTS[x][1], BIT_ROTATE_LEFT_TESTS[x][2])

        if (!NAVAssertLongEqual('Should rotate bits left correctly (alias)', BIT_ROTATE_LEFT_TESTS[x][3], result)) {
            NAVLogTestFailed(x, itohex(BIT_ROTATE_LEFT_TESTS[x][3]), itohex(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
