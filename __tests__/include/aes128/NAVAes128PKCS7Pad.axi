PROGRAM_NAME='NAVAes128PKCS7Pad'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Test vectors for padding function
constant char PAD_TEST_INPUTS[][32] = {
    // Test 1: Single byte (should pad with 15 bytes of 0x0F)
    {$AA},

    // Test 2: 15 bytes (should pad with 1 byte of 0x01)
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F},

    // Test 3: 16 bytes (should pad with 16 bytes of 0x10)
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10},

    // Test 4: 20 bytes (should pad with 12 bytes of 0x0C)
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10,
     $11, $12, $13, $14}
}

// Expected padding values for each test case
constant integer EXPECTED_PAD_VALUES[4] = {
    $0F,  // Test 1: padding value for 1 byte input
    $01,  // Test 2: padding value for 15 byte input
    $10,  // Test 3: padding value for 16 byte input
    $0C   // Test 4: padding value for 20 byte input
}

// Expected lengths after padding
constant integer EXPECTED_PAD_LENGTHS[4] = {
    16,   // Test 1: 1 byte -> 16 bytes
    16,   // Test 2: 15 bytes -> 16 bytes
    32,   // Test 3: 16 bytes -> 32 bytes
    32    // Test 4: 20 bytes -> 32 bytes
}

define_function RunNAVAes128PKCS7PadTests() {
    stack_var integer i
    stack_var char input[32]
    stack_var char padded[48]
    stack_var integer inputLen

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128PKCS7Pad ******************')

    // Test empty input separately (handling NetLinx limitation with empty array constants)
    {
        stack_var char emptyInput[1]
        stack_var integer expectedPadValue
        stack_var integer expectedPadLength
        stack_var char failed
        stack_var integer j

        expectedPadValue = $10
        expectedPadLength = 16
        // set_length_array(emptyInput, 1)

        // Apply padding
        padded = NAVAes128PKCS7Pad(emptyInput)
        inputLen = length_array(padded)

        // Test 1: Verify padded length is what we expect
        if (inputLen != expectedPadLength) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input test - Wrong padded length: got ', itoa(inputLen), ', expected ', itoa(expectedPadLength)")
            failed = true
        }

        // Test 2: Verify all padding bytes have the correct value
        for (j = 1; j <= inputLen; j++) {
            if (padded[j] != expectedPadValue) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input test - Wrong padding value at position ', itoa(j), ': got ', format('$%02X', padded[j]), ', expected ', format('$%02X', expectedPadValue)")
                failed = true
                break
            }
        }

        if (failed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input test - Padded: ', NAVByteArrayToNetLinxHexString(padded)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input test failed'")
        } else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input test passed'")
        }
    }

    // Test the other cases (with non-empty inputs)
    for (i = 1; i <= length_array(PAD_TEST_INPUTS); i++) {
        stack_var char failed
        stack_var integer paddedLen
        stack_var integer expectedPadValue
        stack_var integer j

        // Copy test vector to input buffer
        inputLen = length_array(PAD_TEST_INPUTS[i])
        set_length_array(input, inputLen)

        // Copy input data
        for (j = 1; j <= inputLen; j++) {
            input[j] = PAD_TEST_INPUTS[i][j]
        }

        // Apply padding
        padded = NAVAes128PKCS7Pad(input)
        paddedLen = length_array(padded)

        expectedPadValue = EXPECTED_PAD_VALUES[i]

        // Test 1: Verify padded length is what we expect
        if (paddedLen != EXPECTED_PAD_LENGTHS[i]) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Wrong padded length: got ', itoa(paddedLen), ', expected ', itoa(EXPECTED_PAD_LENGTHS[i])")
            failed = true
        }

        // Test 2: Verify padded length is multiple of block size
        if (paddedLen % 16 != 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Padded length is not multiple of 16: ', itoa(paddedLen)")
            failed = true
        }

        // Test 3: Verify all padding bytes have the correct value
        for (j = inputLen + 1; j <= paddedLen; j++) {
            if (padded[j] != expectedPadValue) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Wrong padding value at position ', itoa(j), ': got ', format('$%02X', padded[j]), ', expected ', format('$%02X', expectedPadValue)")
                failed = true
                break
            }
        }

        // Test 4: Verify original data is preserved
        for (j = 1; j <= inputLen; j++) {
            if (padded[j] != input[j]) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Input data was modified at position ', itoa(j)")
                failed = true
                break
            }
        }

        // Display detailed information for failures
        if (failed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Input length: ', itoa(inputLen)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Input: ', NAVByteArrayToNetLinxHexString(input)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Padded: ', NAVByteArrayToNetLinxHexString(padded)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
    }
}
