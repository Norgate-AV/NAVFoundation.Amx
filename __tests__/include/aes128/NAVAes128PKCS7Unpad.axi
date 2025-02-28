PROGRAM_NAME='NAVAes128PKCS7Unpad'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Original data that will be recovered after unpadding
constant char UNPAD_TEST_ORIGINALS[][32] = {
    // Test 1: Single byte
    {$AA},

    // Test 2: 15 bytes
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F},

    // Test 3: 16 bytes
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10},

    // Test 4: 20 bytes
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10,
     $11, $12, $13, $14}
}

// Padded versions of the test data (manually padded according to PKCS#7)
constant char UNPAD_TEST_INPUTS[][48] = {
    // Test 1: Single byte padded with 15 bytes of 0x0F
    {$AA, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F},

    // Test 2: 15 bytes padded with 1 byte of 0x01
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $01},

    // Test 3: 16 bytes padded with 16 bytes of 0x10
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10,
     $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10},

    // Test 4: 20 bytes padded with 12 bytes of 0x0C
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10,
     $11, $12, $13, $14, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C}
}

// Invalid padded data for testing error cases
constant char INVALID_PADDED_DATA[][16] = {
    // Test 6: Invalid padding value (0x00)
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $00},

    // Test 7: Invalid padding value (0x20 - greater than block size)
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $20},

    // Test 8: Inconsistent padding (should all be 0x03)
    {$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $03, $03, $04}
}

define_function RunNAVAes128PKCS7UnpadTests() {
    stack_var integer i
    stack_var char unpadded[32]
    stack_var integer originalLen, paddedLen, unpaddedLen

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128PKCS7Unpad ******************')

    // Test empty array case separately
    {
        stack_var char paddedEmptyTest[16]
        stack_var integer j
        stack_var char failed

        // Create padding for empty input (16 bytes of 0x10)
        for (j = 1; j <= 16; j++) {
            paddedEmptyTest[j] = $10
        }

        // Always set length of array before use
        set_length_array(paddedEmptyTest, 16)

        // Test unpadding
        unpadded = NAVAes128PKCS7Unpad(paddedEmptyTest)
        unpaddedLen = length_array(unpadded)

        // Verify unpadded length is 0
        if (unpaddedLen != 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input test - Wrong unpadded length: got ', itoa(unpaddedLen), ', expected 0'")
            failed = true
        }

        if (failed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input test - Padded: ', NAVByteArrayToNetLinxHexString(paddedEmptyTest)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input test - Unpadded: ', NAVByteArrayToNetLinxHexString(unpadded)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input test failed'")
        } else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input test passed'")
        }
    }

    // Test valid padding cases
    for (i = 1; i <= length_array(UNPAD_TEST_INPUTS); i++) {
        stack_var char failed
        stack_var char padded[48]
        stack_var integer j

        // Get padded input
        paddedLen = length_array(UNPAD_TEST_INPUTS[i])
        set_length_array(padded, paddedLen)

        // Copy padded data
        for (j = 1; j <= paddedLen; j++) {
            padded[j] = UNPAD_TEST_INPUTS[i][j]
        }

        // Test unpadding
        unpadded = NAVAes128PKCS7Unpad(padded)
        unpaddedLen = length_array(unpadded)

        // Get expected original length
        originalLen = length_array(UNPAD_TEST_ORIGINALS[i])

        // Test 1: Verify unpadded length matches original
        if (unpaddedLen != originalLen) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Wrong unpadded length: got ', itoa(unpaddedLen), ', expected ', itoa(originalLen)")
            failed = true
        }

        // Test 2: Verify unpadded data matches original
        for (j = 1; j <= originalLen; j++) {
            if (j <= unpaddedLen && unpadded[j] != UNPAD_TEST_ORIGINALS[i][j]) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Wrong unpadded data at position ', itoa(j), ': got ', format('$%02X', unpadded[j]), ', expected ', format('$%02X', UNPAD_TEST_ORIGINALS[i][j])")
                failed = true
                break
            }
        }

        // Display detailed information for failures
        if (failed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Original length: ', itoa(originalLen)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Original: ', NAVByteArrayToNetLinxHexString(UNPAD_TEST_ORIGINALS[i])")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Padded: ', NAVByteArrayToNetLinxHexString(padded)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' - Unpadded: ', NAVByteArrayToNetLinxHexString(unpadded)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
    }

    // Test invalid padding cases
    for (i = 1; i <= length_array(INVALID_PADDED_DATA); i++) {
        stack_var char padded[16]
        stack_var integer testIndex
        stack_var integer j

        testIndex = i + length_array(UNPAD_TEST_INPUTS)

        // Copy invalid padded data
        for (j = 1; j <= 16; j++) {
            padded[j] = INVALID_PADDED_DATA[i][j]
        }

        // Always set length of array before use
        set_length_array(padded, 16)

        // Test unpadding - should return empty string for invalid padding
        unpadded = NAVAes128PKCS7Unpad(padded)
        unpaddedLen = length_array(unpadded)

        // Should return empty string for invalid padding
        if (unpaddedLen != 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testIndex), ' - Invalid padding not detected: got ', itoa(unpaddedLen), ' bytes, expected 0'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testIndex), ' - Input: ', NAVByteArrayToNetLinxHexString(padded)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testIndex), ' - Output: ', NAVByteArrayToNetLinxHexString(unpadded)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testIndex), ' failed'")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testIndex), ' passed'")
    }
}
