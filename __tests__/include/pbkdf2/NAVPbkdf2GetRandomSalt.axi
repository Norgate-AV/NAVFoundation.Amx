PROGRAM_NAME='NAVPbkdf2GetRandomSalt'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Pbkdf2.axi'
#include 'NAVPbkdf2Shared.axi'

define_function RunNAVPbkdf2GetRandomSaltTests() {
    stack_var integer testNum
    stack_var integer testCases[3]

    // Test with different salt lengths
    testCases[1] = 8    // Minimum size
    testCases[2] = 16   // Default size
    testCases[3] = 32   // Large size

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVPbkdf2GetRandomSalt ******************')

    // Test 1: Generate salt with specified length
    for (testNum = 1; testNum <= 3; testNum++) {
        stack_var char salt[100]
        stack_var integer requestedLength
        stack_var integer actualLength

        requestedLength = testCases[testNum]
        salt = NAVPbkdf2GetRandomSalt(requestedLength)
        actualLength = length_array(salt)

        if (actualLength == requestedLength) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' passed: Requested length ', itoa(requestedLength),
                      ', got ', itoa(actualLength)")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' failed: Requested length ', itoa(requestedLength),
                      ', got ', itoa(actualLength)")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt: ', Pbkdf2BufferToHexString(salt)")
    }

    // Test 4: Generate salt with default size (when passing 0)
    {
        stack_var char salt[100]
        stack_var integer actualLength

        salt = NAVPbkdf2GetRandomSalt(0)
        actualLength = length_array(salt)

        if (actualLength == NAV_KDF_DEFAULT_SALT_SIZE) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 passed: Default length ', itoa(NAV_KDF_DEFAULT_SALT_SIZE),
                      ', got ', itoa(actualLength)")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 failed: Default length ', itoa(NAV_KDF_DEFAULT_SALT_SIZE),
                      ', got ', itoa(actualLength)")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt: ', Pbkdf2BufferToHexString(salt)")
    }

    // Test 5: Generate multiple salts to ensure uniqueness
    {
        stack_var char salt1[16]
        stack_var char salt2[16]
        stack_var integer different

        salt1 = NAVPbkdf2GetRandomSalt(16)
        salt2 = NAVPbkdf2GetRandomSalt(16)

        // The salts should be different - use native comparison
        different = (salt1 != salt2)

        if (different) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 passed: Two random salts are different'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 failed: Two random salts are identical (very unlikely!)'")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt 1: ', Pbkdf2BufferToHexString(salt1)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt 2: ', Pbkdf2BufferToHexString(salt2)")
    }
}
