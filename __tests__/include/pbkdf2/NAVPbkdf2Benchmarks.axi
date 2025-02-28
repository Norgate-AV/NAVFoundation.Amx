PROGRAM_NAME='NAVPbkdf2Benchmarks'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Cryptography.Pbkdf2.axi'
#include 'NAVFoundation.Cryptography.Aes128.axi'
#include 'NAVFoundation.Stopwatch.axi'
#include 'NAVPbkdf2Shared.axi'

define_function RunNAVPbkdf2BenchmarkTests() {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, '****************** NAVPbkdf2 Benchmarks ******************')

    // Basic test with AES128 key derivation
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Running benchmarks for key derivation...'")
    BenchmarkPBKDF2()
}

// Benchmarking function to measure performance with different iteration counts
define_function BenchmarkPBKDF2() {
    stack_var char password[50]
    stack_var char salt[16]
    stack_var char key[16]
    stack_var integer iterationCounts[4]
    stack_var integer i
    stack_var long elapsedTime
    stack_var sinteger result

    // Define iteration counts to test
    iterationCounts[1] = 100
    iterationCounts[2] = 250
    iterationCounts[3] = 500
    iterationCounts[4] = 1000
    set_length_array(iterationCounts, 4)

    // Setup test data
    password = 'productionPassword123'
    salt = NAVPbkdf2GetRandomSalt(16)

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'PBKDF2 Performance Benchmarks:'")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Password: ', password")
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Salt: ', BufferToHexString(salt)")

    // Run tests with different iteration counts
    for (i = 1; i <= length_array(iterationCounts); i++) {
        // Start timing
        NAVStopwatchStart()

        // Test PBKDF2 raw function
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'----- Testing NAVPbkdf2Sha1 with ', itoa(iterationCounts[i]), ' iterations -----'")
        result = NAVPbkdf2Sha1(password, salt, iterationCounts[i], key, 16)

        // Stop timing
        elapsedTime = NAVStopwatchStop()

        // Log results
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Result: ', itoa(result), ' (', NAVPbkdf2GetError(result), ')'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Time: ', itoa(elapsedTime), ' ms'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Key: ', BufferToHexString(key)")

        // Now test AES key derivation wrapper
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'----- Testing NAVAes128DeriveKey with ', itoa(iterationCounts[i]), ' iterations -----'")
        set_length_array(key, 0)
        NAVStopwatchStart()
        result = NAVAes128DeriveKey(password, salt, iterationCounts[i], key)
        elapsedTime = NAVStopwatchStop()

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Result: ', itoa(result), ' (', NAVAes128GetError(result), ')'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Time: ', itoa(elapsedTime), ' ms'")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'  Key: ', BufferToHexString(key)")
    }
}
