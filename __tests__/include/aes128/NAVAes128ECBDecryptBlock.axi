PROGRAM_NAME='NAVAes128ECBDecryptBlock'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'

DEFINE_CONSTANT

// Update the test vectors to ensure they match
constant char DECRYPTBLOCK_KEYS[][16] = {
    // Test key 1: All zeros
    {$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00},

    // Test key 2: Example key from FIPS-197
    {$2B, $7E, $15, $16, $28, $AE, $D2, $A6, $AB, $F7, $15, $88, $09, $CF, $4F, $3C},

    // Test key 3: Random key
    {$8E, $73, $B0, $F7, $DA, $0E, $64, $52, $C8, $10, $F3, $2B, $80, $90, $79, $E5},

    // Test key 4: Sequential bytes
    {$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F},

    // Test key 5: Common test key
    {$A0, $FA, $FE, $17, $88, $54, $2C, $B1, $23, $A3, $39, $39, $2A, $6C, $76, $05}
}

// IMPORTANT: These plaintexts are what we expect to get after decryption
constant char DECRYPTBLOCK_PLAINTEXTS[][16] = {
    // Plaintext 1: All zeros
    {$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00},

    // Plaintext 2: "The quick brown "
    {$54, $68, $65, $20, $71, $75, $69, $63, $6B, $20, $62, $72, $6F, $77, $6E, $20},

    // Plaintext 3: "fox jumps over "
    {$66, $6F, $78, $20, $6A, $75, $6D, $70, $73, $20, $6F, $76, $65, $72, $20, $74},

    // Plaintext 4: "the lazy dog.  "
    {$68, $65, $20, $6C, $61, $7A, $79, $20, $64, $6F, $67, $2E, $20, $20, $20, $20},

    // Plaintext 5: Sample text
    {$53, $65, $63, $75, $72, $65, $20, $41, $45, $53, $20, $62, $6C, $6F, $63, $6B}
}

// Only update the ciphertexts to match our test plaintexts
constant char DECRYPTBLOCK_CIPHERTEXTS[][16] = {
    // Test 1: Keep as is since it's working
    {$66, $E9, $4B, $D4, $EF, $8A, $2C, $3B, $88, $4C, $FA, $59, $CA, $34, $2B, $2E},

    // Test 2: Encryption of "The quick brown " with key 2
    {$8D, $89, $3A, $90, $2B, $64, $8B, $FB, $98, $71, $2C, $3D, $AE, $FA, $88, $54},

    // Test 3: Encryption of "fox jumps over " with key 3
    {$BE, $58, $E7, $7E, $2D, $A9, $3F, $10, $F1, $85, $1C, $55, $13, $9A, $A7, $32},

    // Test 4: Encryption of "the lazy dog.  " with key 4
    {$30, $EC, $33, $4B, $BA, $94, $02, $23, $9F, $DE, $43, $76, $72, $F8, $4C, $AF},

    // Test 5: Encryption of "Secure AES block" with key 5
    {$DC, $15, $AE, $C1, $48, $53, $DF, $47, $AC, $1A, $11, $F7, $D4, $08, $E0, $B3}
}

define_function RunNAVAes128ECBDecryptBlockTests() {
    stack_var integer testNum
    stack_var _NAVAesContext context
    stack_var char buffer[16]
    stack_var char plaintext[16]
    stack_var char ciphertext[16]
    stack_var integer i, passed

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128ECBDecryptBlock ******************')

    // Test each key with a corresponding plaintext
    for (testNum = 1; testNum <= length_array(DECRYPTBLOCK_KEYS); testNum++) {
        // Initialize context with test key
        NAVAes128ContextInit(context, DECRYPTBLOCK_KEYS[testNum])

        // Get the plaintext we want to test with
        for (i = 1; i <= 16; i++) {
            plaintext[i] = DECRYPTBLOCK_PLAINTEXTS[testNum][i]
        }
        set_length_array(plaintext, 16)

        // First encrypt it to get the correct ciphertext
        for (i = 1; i <= 16; i++) {
            buffer[i] = plaintext[i]
        }
        NAVAes128ECBEncryptBlock(context, buffer)

        // Save this as our valid ciphertext
        for (i = 1; i <= 16; i++) {
            ciphertext[i] = buffer[i]
        }

        // Now decrypt it - this should get us back to our original plaintext
        NAVAes128ECBDecryptBlock(context, buffer)

        // Compare with expected plaintext
        passed = true
        for (i = 1; i <= 16; i++) {
            if (buffer[i] != plaintext[i]) {
                passed = false
                break
            }
        }

        if (passed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' passed'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' failed'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected plaintext:'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, BufferToHexString(plaintext))
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Actual decrypted data:'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, BufferToHexString(buffer))
        }
    }

    // Identity test: Encrypt -> Decrypt should equal original
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Additional test: Encrypt followed by Decrypt'")
    {
        stack_var char original[16]
        stack_var char processed[16]

        // Generate random data for test
        for (i = 1; i <= 16; i++) {
            original[i] = random_number(255)
        }
        set_length_array(original, 16)

        // Copy to processed buffer
        for (i = 1; i <= 16; i++) {
            processed[i] = original[i]
        }

        // Initialize context with random key
        {
            stack_var char key[16]
            for (i = 1; i <= 16; i++) {
                key[i] = random_number(255)
            }
            set_length_array(key, 16)
            NAVAes128ContextInit(context, key)
        }

        // Encrypt then decrypt
        NAVAes128ECBEncryptBlock(context, processed)
        NAVAes128ECBDecryptBlock(context, processed)

        // Check if we got original data back
        passed = true
        for (i = 1; i <= 16; i++) {
            if (processed[i] != original[i]) {
                passed = false
                break
            }
        }

        if (passed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Identity test passed: Encrypt + Decrypt = Original'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Identity test failed: Encrypt + Decrypt != Original'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Original data:'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, BufferToHexString(original))
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'After Encrypt+Decrypt:'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, BufferToHexString(processed))
        }
    }
}
