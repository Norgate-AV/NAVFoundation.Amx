PROGRAM_NAME='NAVBitRotateRight'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test data: [value, count, expected]
constant long BIT_ROTATE_RIGHT_TESTS[][3] = {
    // value, count, expected
    // Test that alias function behaves identically to NAVBinaryRotateRight
    { $00000002, 1, $00000001 },        // Test 1: Same as NAVBinaryRotateRight
    { $00000010, 4, $00000001 },        // Test 2: Same as NAVBinaryRotateRight
    { $00000001, 1, $80000000 },        // Test 3: Wrap test
    { $12345678, 4, $81234567 },        // Test 4: Complex pattern
    { $FFFFFFFF, 8, $FFFFFFFF }         // Test 5: All bits set
}

define_function TestNAVBitRotateRight() {
    stack_var integer x
    stack_var long result

    NAVLog("'***************** NAVBitRotateRight *****************'")

    for (x = 1; x <= length_array(BIT_ROTATE_RIGHT_TESTS); x++) {
        result = NAVBitRotateRight(BIT_ROTATE_RIGHT_TESTS[x][1], BIT_ROTATE_RIGHT_TESTS[x][2])

        if (!NAVAssertLongEqual('Should rotate bits right correctly (alias)', BIT_ROTATE_RIGHT_TESTS[x][3], result)) {
            NAVLogTestFailed(x, itohex(BIT_ROTATE_RIGHT_TESTS[x][3]), itohex(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}
