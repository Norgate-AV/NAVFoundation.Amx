PROGRAM_NAME='NAVAes128ECBDecrypt'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Test keys that will be used for encryption/decryption
constant char ECBDECRYPT_KEYS[][16] = {
    // Common AES-128 test key
    {$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F},

    // FIPS-197 example key
    {$2B, $7E, $15, $16, $28, $AE, $D2, $A6, $AB, $F7, $15, $88, $09, $CF, $4F, $3C},

    // Random test key
    {$A0, $FA, $FE, $17, $88, $54, $2C, $B1, $23, $A3, $39, $39, $2A, $6C, $76, $05}
}

// Original plaintext data for each test
constant char ECBDECRYPT_PLAINTEXTS[][] = {
    // Test case 1: Single block exactly (16 bytes)
    {$54, $68, $69, $73, $20, $69, $73, $20, $65, $78, $61, $63, $74, $6C, $79, $20},

    // Test case 2: Single block + padding (15 bytes)
    {$54, $68, $69, $73, $20, $69, $73, $20, $31, $35, $20, $62, $79, $74, $65},

    // Test case 3: Multi-block (32 bytes)
    {$54, $68, $69, $73, $20, $69, $73, $20, $61, $20, $6D, $75, $6C, $74, $69, $2D,
     $62, $6C, $6F, $63, $6B, $20, $74, $65, $73, $74, $20, $63, $61, $73, $65, $2E},

    // Test case 4: Multi-block with padding (30 bytes)
    {$4D, $75, $6C, $74, $69, $2D, $62, $6C, $6F, $63, $6B, $20, $77, $69, $74, $68,
     $20, $73, $6F, $6D, $65, $20, $70, $61, $64, $64, $69, $6E, $67, $2E}
}

define_function RunNAVAes128ECBDecryptTests() {
    stack_var integer i

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128ECBDecrypt ******************')

    // Test each plaintext with its corresponding key
    for (i = 1; i <= length_array(ECBDECRYPT_KEYS); i++) {
        stack_var _NAVAesContext context
        stack_var char originalText[1024]
        stack_var char encryptedText[1024]
        stack_var char decryptedText[1024]
        stack_var sinteger result
        stack_var integer j
        stack_var integer passed

        // Initialize context
        NAVAes128ContextInit(context, ECBDECRYPT_KEYS[i])

        // Skip tests where we don't have enough test plaintexts
        if (i > length_array(ECBDECRYPT_PLAINTEXTS)) {
            break
        }

        // Copy plaintext for this test
        originalText = ECBDECRYPT_PLAINTEXTS[i]

        // First encrypt the plaintext
        result = NAVAes128ECBEncrypt(context, originalText, encryptedText)
        if (result != NAV_AES_SUCCESS) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed during encryption: ', NAVAes128GetError(result)")
            continue
        }

        // Then decrypt the ciphertext
        result = NAVAes128ECBDecrypt(context, encryptedText, decryptedText)
        if (result != NAV_AES_SUCCESS) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed during decryption: ', NAVAes128GetError(result)")
            continue
        }

        // Compare decrypted text with original
        if (length_array(decryptedText) != length_array(originalText)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed: length mismatch'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Original length: ', itoa(length_array(originalText)), ', Decrypted length: ', itoa(length_array(decryptedText))")
            continue
        }

        passed = true
        for (j = 1; j <= length_array(originalText); j++) {
            if (originalText[j] != decryptedText[j]) {
                passed = false
                break
            }
        }

        if (passed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' passed'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Original text: ', NAVByteArrayToNetLinxHexString(originalText)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Decrypted text: ', NAVByteArrayToNetLinxHexString(decryptedText)")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(i), ' failed: data mismatch'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Original text: ', NAVByteArrayToNetLinxHexString(originalText)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Decrypted text: ', NAVByteArrayToNetLinxHexString(decryptedText)")
        }
    }

    // Additional tests for edge cases
    {
        // Create a properly empty buffer
        stack_var char emptyText[16]  // Allocate reasonable size
        stack_var char cipherText[1024]
        stack_var char decryptedText[1024]
        stack_var _NAVAesContext context
        stack_var sinteger result

        // Ensure it's truly empty
        set_length_array(emptyText, 0)

        NAVAes128ContextInit(context, ECBDECRYPT_KEYS[1])

        // Fix the empty input test
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing empty input encrypt-then-decrypt'")
        result = NAVAes128ECBEncrypt(context, emptyText, cipherText)
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input produced ciphertext of length: ', itoa(length_array(cipherText))")

        if (result == NAV_AES_SUCCESS && length_array(cipherText) > 0) {
            // For empty input, we expect a 16-byte ciphertext (full block of padding)
            if (length_array(cipherText) != 16) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Unexpected ciphertext length: ', itoa(length_array(cipherText))")
            }

            result = NAVAes128ECBDecrypt(context, cipherText, decryptedText)

            // Now we expect a successful result with an empty decrypted text
            if (result == NAV_AES_SUCCESS && length_array(decryptedText) == 0) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input encrypt-then-decrypt test passed'")
            }
            else {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty input encrypt-then-decrypt test failed: ', NAVAes128GetError(result)")
            }
        }

        // Continue with testing empty ciphertext...
        // Test decrypt of empty ciphertext (should return empty plaintext)
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing empty ciphertext'")
        set_length_array(cipherText, 0)

        result = NAVAes128ECBDecrypt(context, cipherText, decryptedText)
        if (result == NAV_AES_SUCCESS && length_array(decryptedText) == 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty ciphertext test passed'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty ciphertext test failed: ', NAVAes128GetError(result)")
        }
    }

    // Random data tests
    {
        stack_var _NAVAesContext context
        stack_var char key[16]
        stack_var char original[80]  // Random length
        stack_var char encrypted[1024]
        stack_var char decrypted[1024]
        stack_var integer j, k
        stack_var sinteger result

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing random data'")

        // Generate random key
        for (j = 1; j <= 16; j++) {
            key[j] = random_number(255)
        }
        set_length_array(key, 16)

        // Initialize context
        NAVAes128ContextInit(context, key)

        // Generate random data of varying lengths
        for (k = 1; k <= 3; k++) {
            stack_var integer dataLen
            stack_var integer passed

            // Random length between 1 and 80 bytes
            dataLen = random_number(80)
            if (dataLen == 0) dataLen = 1

            set_length_array(original, dataLen)
            for (j = 1; j <= dataLen; j++) {
                original[j] = random_number(255)
            }

            // Encrypt
            result = NAVAes128ECBEncrypt(context, original, encrypted)
            if (result != NAV_AES_SUCCESS) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Random test ', itoa(k), ' failed during encryption: ', NAVAes128GetError(result)")
                continue
            }

            // Decrypt
            result = NAVAes128ECBDecrypt(context, encrypted, decrypted)
            if (result != NAV_AES_SUCCESS) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Random test ', itoa(k), ' failed during decryption: ', NAVAes128GetError(result)")
                continue
            }

            // Verify
            passed = true
            if (length_array(decrypted) != length_array(original)) {
                passed = false
            }
            else {
                for (j = 1; j <= dataLen; j++) {
                    if (original[j] != decrypted[j]) {
                        passed = false
                        break
                    }
                }
            }

            if (passed) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Random test ', itoa(k), ' passed (length: ', itoa(dataLen), ')'")
            }
            else {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Random test ', itoa(k), ' failed: data mismatch'")
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Original length: ', itoa(length_array(original)), ', Decrypted length: ', itoa(length_array(decrypted))")
            }
        }
    }

    // Test invalid padding
    {
        stack_var _NAVAesContext context
        stack_var char mangled[32]
        stack_var char result[1024]
        stack_var sinteger errorCode

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Testing invalid padding handling'")

        // Initialize with a known key
        NAVAes128ContextInit(context, ECBDECRYPT_KEYS[1])

        // Create a block with invalid padding (last byte = 0)
        for (i = 1; i <= 32; i++) {
            mangled[i] = $FF  // Fill with non-zero bytes
        }
        mangled[32] = 0  // Invalid padding value
        set_length_array(mangled, 32)

        // Try to decrypt this invalid ciphertext
        errorCode = NAVAes128ECBDecrypt(context, mangled, result)

        // This should fail during unpadding
        if (errorCode != NAV_AES_SUCCESS && length_array(result) == 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Invalid padding test passed with error: ', NAVAes128GetError(errorCode)")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Invalid padding test failed'")
        }
    }
}
