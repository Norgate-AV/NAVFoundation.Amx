PROGRAM_NAME='NAVPbkdf2Sha1'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Pbkdf2.axi'
#include 'NAVPbkdf2Shared.axi'

DEFINE_CONSTANT

// Test case structure:
// [password, salt, iterations, key_length, expected_result, expected_error_code]
constant char PBKDF2_TEST_VECTORS[5][6][100] = {
    // Test 1: Basic case (RFC 6070 test vector with saltsalt)
    {
        {'password'},
        {'saltsalt'}, // 8 bytes
        {'1'},        // iterations
        {'20'},       // output key length
        {$A4, $B9, $CE, $A2, $06, $44, $5D, $0C, $02, $FD, $F8, $AB, $A9, $0C, $FD, $9B, $E3, $8B, $60, $2A},
        {'0'}         // expected error code (success)
    },

    // Test 2: More iterations (RFC 6070 test vector with saltsalt)
    {
        {'password'},
        {'saltsalt'}, // 8 bytes
        {'2'},        // iterations
        {'20'},       // output key length
        {$59, $D8, $6E, $B8, $27, $97, $EB, $0F, $A6, $62, $2C, $A8, $4D, $20, $09, $3D, $12, $17, $87, $0B},
        {'0'}         // expected error code (success)
    },

    // Test 3: Shorter output key (16 bytes)
    {
        {'password123'},
        {'saltsalt'},
        {'10'},       // iterations
        {'16'},       // output key length
        {$F5, $FB, $9F, $3C, $44, $3C, $44, $CA, $D1, $B6, $E6, $5B, $49, $2D, $FA, $70},
        {'0'}         // expected error code (success)
    },

    // Test 4: Invalid case - empty password
    {
        {''},        // empty password
        {'salt'},
        {'1000'},    // iterations
        {'16'},      // output key length
        {''},        // no expected output
        {'-100'}     // NAV_KDF_ERROR_INVALID_PARAMETER
    },

    // Test 5: Invalid case - short salt
    {
        {'password'},
        {'salt'},    // 4-byte salt (too short)
        {'1000'},    // iterations
        {'16'},      // output key length
        {''},        // no expected output
        {'-101'}     // NAV_KDF_ERROR_INVALID_SALT_SIZE (assuming 8-byte minimum)
    }
}

define_function RunNAVPbkdf2Sha1Tests() {
    stack_var integer testNum

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVPbkdf2Sha1 ******************')

    for (testNum = 1; testNum <= length_array(PBKDF2_TEST_VECTORS); testNum++) {
        stack_var char password[100]
        stack_var char salt[100]
        stack_var integer iterations
        stack_var integer keyLength
        stack_var char derivedKey[100]
        stack_var char expected[100]
        stack_var sinteger expectedError
        stack_var sinteger result
        stack_var integer passed

        // Get test inputs
        password = PBKDF2_TEST_VECTORS[testNum][1]
        salt = PBKDF2_TEST_VECTORS[testNum][2]
        iterations = atoi(PBKDF2_TEST_VECTORS[testNum][3])
        keyLength = atoi(PBKDF2_TEST_VECTORS[testNum][4])

        // Get expected output and error code
        format_to_array(expected, PBKDF2_TEST_VECTORS[testNum][5])
        expectedError = atoi(PBKDF2_TEST_VECTORS[testNum][6])

        // Make sure salt is properly formatted for tests 1-3
        if (testNum <= 3) {
            set_length_array(salt, 8); // Ensure minimum salt length
        }

        // Special case for test 5: make salt exactly 4 bytes (for testing salt size validation)
        if (testNum == 5) {
            set_length_array(salt, 4)
        }

        // Run PBKDF2
        result = NAVPbkdf2Sha1(password, salt, iterations, derivedKey, keyLength)

        // Check if error code matches expected
        if (result == expectedError) {
            // For success cases, also check the derived key
            if (result == NAV_KDF_SUCCESS) {
                // Use native comparison operator
                passed = (derivedKey == expected)

                if (passed) {
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' passed'")
                }
                else {
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' failed: Incorrect derived key'")
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Expected: ', BufferToHexString(expected)")
                    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Actual  : ', BufferToHexString(derivedKey)")
                }
            }
            else {
                // For failure cases, just check the error code
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' passed: Correctly returned error ', itoa(result), ' (', NAVPbkdf2GetError(result), ')'")
            }
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' failed: Expected error code ', itoa(expectedError), ' got ', itoa(result), ' (', NAVPbkdf2GetError(result), ')'")
        }

        // Print detailed test information
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Password  : ', password")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt      : ', salt, ' (', itoa(length_array(salt)), ' bytes)'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Iterations: ', itoa(iterations), ' times'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Key Length: ', itoa(keyLength), ' bytes'")
    }
}
