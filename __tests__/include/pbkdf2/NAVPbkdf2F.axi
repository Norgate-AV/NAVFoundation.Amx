PROGRAM_NAME='NAVPbkdf2F'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Pbkdf2.axi'
#include 'NAVPbkdf2Shared.axi'

// Test vectors for PBKDF2_F function
// Format: [password, salt, iterations, block_index, expected_result]
DEFINE_CONSTANT
constant char PBKDF2_F_TEST_VECTORS[2][5][100] = {
    // Test vector 1: Basic test with known output
    {
        {'password'},
        {'salt'},
        {'1'},  // 1 iteration
        {'1'},  // First block
        {$0c, $60, $c8, $0f, $96, $1f, $0e, $71, $f3, $a9, $b5, $24, $af, $60, $12, $06, $2f, $e0, $37, $a6}
    },

    // Test vector 2: Multiple iterations
    {
        {'password'},
        {'salt'},
        {'2'},  // 2 iterations
        {'1'},  // First block
        {$ea, $6c, $01, $4d, $c7, $2d, $6f, $8c, $cd, $1e, $d9, $2a, $ce, $1d, $41, $f0, $d8, $de, $89, $57}
    }
}

define_function RunNAVPbkdf2FTests() {
    stack_var integer testNum

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVPbkdf2F ******************')

    for (testNum = 1; testNum <= length_array(PBKDF2_F_TEST_VECTORS); testNum++) {
        stack_var char password[100]
        stack_var char salt[100]
        stack_var integer iterations
        stack_var integer blockIndex
        stack_var char expected[20]
        stack_var char result[20]
        stack_var integer passed

        // Get test inputs
        password = PBKDF2_F_TEST_VECTORS[testNum][1]
        salt = PBKDF2_F_TEST_VECTORS[testNum][2]
        iterations = atoi(PBKDF2_F_TEST_VECTORS[testNum][3])
        blockIndex = atoi(PBKDF2_F_TEST_VECTORS[testNum][4])

        // Ensure salt is a plain "salt" string without the block index
        set_length_array(salt, 4)  // 'salt' is 4 characters

        // For expected result byte array - make sure to properly initialize with format_to_array
        format_to_array(expected, PBKDF2_F_TEST_VECTORS[testNum][5])

        // Run PBKDF2_F function
        result = NAVPbkdf2F(password, salt, iterations, blockIndex)

        // Check if result matches expected using native comparison
        passed = (result == expected)

        if (passed) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' passed'")
        }
        else {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testNum), ' failed'")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Password  : ', password")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt      : ', salt")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Iterations: ', itoa(iterations)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Block     : ', itoa(blockIndex)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Expected  : ', Pbkdf2BufferToHexString(expected)")
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Actual    : ', Pbkdf2BufferToHexString(result)")
        }
    }
}
