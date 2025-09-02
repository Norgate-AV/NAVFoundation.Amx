PROGRAM_NAME='NAVAes128EndToEndTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'
#include 'NAVFoundation.Cryptography.Pbkdf2.axi'

DEFINE_CONSTANT

// Test cases with different passwords, salts, and plaintext data
constant char TEST_PASSWORDS[][100] = {
    'simple123',
    'Complex P@ssw0rd!',
    'This is a longer passphrase with spaces',
    '123456',
    'VeryLongPasswordThatExceedsTheNormalLengthOfWhatAPeopleMightUseButStillValid'
}

// Test salts (properly declared as constants)
constant char TEST_SALT_1[16] = {$73, $61, $6C, $74, $79, $73, $61, $6C, $74, $76, $61, $6C, $75, $65, $31, $32}
constant char TEST_SALT_2[16] = {$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00}
constant char TEST_SALT_3[16] = {$A5, $24, $73, $C7, $AB, $F1, $62, $4D, $89, $E3, $D5, $F7, $1B, $C8, $9A, $44}
constant char TEST_SALT_4[16] = {$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F}

constant char TEST_PLAINTEXTS[][200] = {
    // Test 1: Short text
    'Hello World!',

    // Test 2: Exact block size (16 bytes)
    'Sixteen_byteblock',

    // Test 3: Empty string
    '',

    // Test 4: Longer text spanning multiple blocks
    'This is a much longer plaintext that will require multiple AES blocks to encrypt. It demonstrates the correct handling of multi-block data with proper padding.',

    // Test 5: JSON data
    '{"user":"john_doe","role":"admin","actions":["read","write","delete"],"active":true}'
}

// Reduced iterations for test performance
constant integer PBKDF2_TEST_ITERATIONS = 10

define_function RunNAVAes128EndToEndTests() {
    stack_var integer testNum
    stack_var _NAVAesContext context

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128 End-to-End Tests ******************')

    // Run tests with different combinations
    for (testNum = 1; testNum <= length_array(TEST_PLAINTEXTS); testNum++) {
        stack_var char password[50]
        stack_var char salt[16]
        stack_var char plaintext[1024]
        stack_var char derivedKey[16]
        stack_var char encryptedText[1024]
        stack_var char decryptedText[1024]
        stack_var sinteger result
        stack_var integer passwordIdx, saltIdx
        stack_var integer i

        // Select password and salt based on test number
        passwordIdx = ((testNum - 1) % length_array(TEST_PASSWORDS)) + 1

        // Copy the password
        password = TEST_PASSWORDS[passwordIdx]

        // Copy the appropriate salt based on test number
        set_length_array(salt, 16)
        saltIdx = ((testNum - 1) % 4) + 1

        // Copy the salt data
        switch(saltIdx) {
            case 1: {
                for(i = 1; i <= 16; i++) {
                    salt[i] = TEST_SALT_1[i]
                }
                break
            }
            case 2: {
                for(i = 1; i <= 16; i++) {
                    salt[i] = TEST_SALT_2[i]
                }
                break
            }
            case 3: {
                for(i = 1; i <= 16; i++) {
                    salt[i] = TEST_SALT_3[i]
                }
                break
            }
            case 4: {
                for(i = 1; i <= 16; i++) {
                    salt[i] = TEST_SALT_4[i]
                }
                break
            }
        }

        // Copy the plaintext
        plaintext = TEST_PLAINTEXTS[testNum]

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ': Password: "', password, '", Plaintext (', itoa(length_array(plaintext)), ' bytes)'")

        // 1. Derive encryption key from password and salt
        result = NAVAes128DeriveKey(password, salt, PBKDF2_TEST_ITERATIONS, derivedKey)

        if (result != NAV_AES_SUCCESS) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - Key derivation failed: ', NAVAes128GetError(result)")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - Derived key: ', NAVByteArrayToNetLinxHexString(derivedKey)")

        // 2. Initialize AES context with the derived key
        result = NAVAes128ContextInit(context, derivedKey)

        if (result != NAV_AES_SUCCESS) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - Context initialization failed: ', NAVAes128GetError(result)")
            continue
        }

        // 3. Encrypt the plaintext
        result = NAVAes128ECBEncrypt(context, plaintext, encryptedText)

        if (result != NAV_AES_SUCCESS) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - Encryption failed: ', NAVAes128GetError(result)")
            continue
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - Ciphertext (', itoa(length_array(encryptedText)), ' bytes): ', NAVByteArrayToNetLinxHexString(encryptedText)")

        // 4. Decrypt the ciphertext (using same context)
        result = NAVAes128ECBDecrypt(context, encryptedText, decryptedText)

        if (result != NAV_AES_SUCCESS) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - Decryption failed: ', NAVAes128GetError(result)")
            continue
        }

        // 5. Verify decrypted text matches original
        if (NAVCompareBuffers(plaintext, decryptedText)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - PASSED: Decrypted text matches original'")
            if (length_array(plaintext) <= 64) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - Original: "', plaintext, '"'")
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - Decrypted: "', decryptedText, '"'")
            }
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - FAILED: Decryption does not match original'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' - Original length: ', itoa(length_array(plaintext)), ', Decrypted length: ', itoa(length_array(decryptedText))")
        }
    }

    // Special test: encrypt-decrypt with randomly generated salt
    {
        stack_var char password[50]
        stack_var char randomSalt[16]
        stack_var char plaintext[100]
        stack_var char derivedKey[16]
        stack_var char encryptedData[200]
        stack_var char decryptedData[100]
        stack_var sinteger result

        password = 'RandomSaltTest'
        plaintext = 'This text will be encrypted with a randomly generated salt'

        // Generate random salt
        randomSalt = NAVPbkdf2GetRandomSalt(16)

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Random Salt Test - Salt: ', NAVByteArrayToNetLinxHexString(randomSalt)")

        // Complete encryption cycle with random salt
        result = NAVAes128DeriveKey(password, randomSalt, PBKDF2_TEST_ITERATIONS, derivedKey)

        if (result == NAV_AES_SUCCESS) {
            NAVAes128ContextInit(context, derivedKey)
            NAVAes128ECBEncrypt(context, plaintext, encryptedData)
            NAVAes128ECBDecrypt(context, encryptedData, decryptedData)

            if (NAVCompareBuffers(plaintext, decryptedData)) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Random Salt Test - PASSED'")
            }
            else {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Random Salt Test - FAILED'")
            }
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Random Salt Test - Key derivation failed'")
        }
    }
}


// Helper function to copy buffer contents
define_function NAVCopyBuffer(char source[], char dest[], integer count) {
    stack_var integer i

    for (i = 1; i <= count && i <= length_array(source) && i <= length_array(dest); i++) {
        dest[i] = source[i]
    }
}


// Helper function to compare two buffers
define_function integer NAVCompareBuffers(char buf1[], char buf2[]) {
    stack_var integer i

    if (length_array(buf1) != length_array(buf2)) {
        return 0
    }

    for (i = 1; i <= length_array(buf1); i++) {
        if (buf1[i] != buf2[i]) {
            return 0
        }
    }

    return 1
}
