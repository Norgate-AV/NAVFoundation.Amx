PROGRAM_NAME='NAVAes128DeriveKey'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'
#include 'NAVFoundation.Stopwatch.axi'


define_function RunNAVAes128DeriveKeyTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVAes128DeriveKey ******************')

    // Test 1: Standard successful key derivation
    {
        stack_var char password[50]
        stack_var char salt[16]
        stack_var integer iterations
        stack_var char key[16]
        stack_var sinteger result

        password = 'SecurePassword123'
        salt = 'saltyRandomBytes1'
        iterations = 10  // Using low iteration count for testing speed

        set_length_array(salt, 16)

        result = NAVAes128DeriveKey(password, salt, iterations, key)

        if (result == NAV_AES_SUCCESS && length_array(key) == 16) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 passed: Successfully derived key'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 failed: Error code ', itoa(result), ' - ', NAVAes128GetError(result)")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Password  : ', password")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt      : ', BufferToHexString(salt)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Iterations: ', itoa(iterations)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Key       : ', BufferToHexString(key)")
    }

    // Test 2: Using default iterations (when passing 0)
    {
        stack_var char password[50]
        stack_var char salt[16]
        stack_var integer iterations
        stack_var char key[16]
        stack_var sinteger result

        password = 'SecurePassword123'
        salt = 'saltyRandomBytes2'
        iterations = 0  // This should use the default iteration count

        set_length_array(salt, 16)

        result = NAVAes128DeriveKey(password, salt, iterations, key)

        if (result == NAV_AES_SUCCESS && length_array(key) == 16) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 passed: Successfully derived key with default iterations'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 failed: Error code ', itoa(result), ' - ', NAVAes128GetError(result)")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Password  : ', password")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt      : ', BufferToHexString(salt)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Iterations: Default'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Key       : ', BufferToHexString(key)")
    }

    // Test 3: Empty password (should return error)
    {
        stack_var char password[50]
        stack_var char salt[16]
        stack_var integer iterations
        stack_var char key[16]
        stack_var sinteger result

        password = ''  // Empty password - should fail
        salt = 'saltyRandomBytes3'
        iterations = 10

        set_length_array(salt, 16)

        result = NAVAes128DeriveKey(password, salt, iterations, key)

        if (result == NAV_AES_ERROR_NULL_PARAMETER) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 passed: Correctly returned error for empty password'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 failed: Expected error NAV_AES_ERROR_NULL_PARAMETER but got ', itoa(result), ' - ', NAVAes128GetError(result)")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Password  : ""[empty]""'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt      : ', BufferToHexString(salt)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Iterations: ', itoa(iterations)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Error     : ', NAVAes128GetError(result)")
    }

    // Test 4: Invalid salt length (too short)
    {
        stack_var char password[50]
        stack_var char salt[4]
        stack_var integer iterations
        stack_var char key[16]
        stack_var sinteger result

        password = 'SecurePassword123'
        salt = 'salt'  // 4 bytes - too short
        iterations = 10

        set_length_array(salt, 4)

        result = NAVAes128DeriveKey(password, salt, iterations, key)

        if (result == NAV_AES_ERROR_KEY_DERIVATION_FAILED) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 passed: Correctly returned error for short salt'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 failed: Expected error NAV_AES_ERROR_KEY_DERIVATION_FAILED but got ', itoa(result), ' - ', NAVAes128GetError(result)")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Password  : ', password")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt      : ', BufferToHexString(salt), ' (', itoa(length_array(salt)), ' bytes)'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Iterations: ', itoa(iterations)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Error     : ', NAVAes128GetError(result)")
    }

    // Test 5: Different input produces different key
    {
        stack_var char password1[50], password2[50]
        stack_var char salt[16]
        stack_var integer iterations
        stack_var char key1[16], key2[16]
        stack_var sinteger result1, result2
        stack_var integer different

        password1 = 'Password1'
        password2 = 'Password2'  // One character different
        salt = 'sameSaltForBoth!'
        iterations = 10

        set_length_array(salt, 16)

        // Derive first key
        result1 = NAVAes128DeriveKey(password1, salt, iterations, key1)

        // Derive second key
        result2 = NAVAes128DeriveKey(password2, salt, iterations, key2)

        // Check if results are both successful and keys are different
        if (result1 == NAV_AES_SUCCESS && result2 == NAV_AES_SUCCESS) {
            different = (key1 != key2)  // Keys should be different

            if (different) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 passed: Different passwords produce different keys'")
            }
            else {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 failed: Different passwords produced identical keys (unlikely!)'")
            }
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 failed: Key derivation failed with error'")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Password 1: ', password1")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Password 2: ', password2")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt      : ', BufferToHexString(salt)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Key 1     : ', BufferToHexString(key1)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Key 2     : ', BufferToHexString(key2)")
    }

    // Test 6: Same input produces same key (deterministic)
    {
        stack_var char password[50]
        stack_var char salt[16]
        stack_var integer iterations
        stack_var char key1[16], key2[16]
        stack_var sinteger result1, result2
        stack_var integer same

        password = 'SamePasswordTest'
        salt = 'consistentSalt!!'
        iterations = 10

        set_length_array(salt, 16)

        // Derive first key
        result1 = NAVAes128DeriveKey(password, salt, iterations, key1)

        // Derive second key with exactly same parameters
        result2 = NAVAes128DeriveKey(password, salt, iterations, key2)

        // Check if results are both successful and keys are the same
        if (result1 == NAV_AES_SUCCESS && result2 == NAV_AES_SUCCESS) {
            same = (key1 == key2)  // Keys should be identical

            if (same) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 6 passed: Same inputs produce consistent keys'")
            }
            else {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 6 failed: Same inputs produced different keys (function not deterministic)'")
            }
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 6 failed: Key derivation failed with error'")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Password  : ', password")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt      : ', BufferToHexString(salt)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Key 1     : ', BufferToHexString(key1)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Key 2     : ', BufferToHexString(key2)")
    }
}
