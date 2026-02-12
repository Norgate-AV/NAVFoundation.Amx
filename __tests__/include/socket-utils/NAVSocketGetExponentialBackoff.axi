PROGRAM_NAME='NAVSocketGetExponentialBackoff'

#include 'NAVFoundation.SocketUtils.axi'


DEFINE_CONSTANT

constant integer BACKOFF_TEST_COUNT = 21

constant char BACKOFF_TEST_DESCRIPTIONS[BACKOFF_TEST_COUNT][255] = {
    'Attempt 1 (within maxRetries) returns base delay',
    'Attempt 5 (within maxRetries) returns base delay',
    'Attempt 10 (at maxRetries boundary) returns base delay',
    'Attempt 11 (first exponential) returns base * 2^1',
    'Attempt 12 (second exponential) returns base * 2^2',
    'Attempt 13 (third exponential) returns base * 2^3',
    'Attempt 15 (fifth exponential) returns base * 2^5',
    'Attempt 20 (tenth exponential) caps at maxDelay',
    'Attempt 30 (large attempt) caps at maxDelay',
    'Attempt 40 (very large attempt) caps at maxDelay without overflow',
    'Attempt 100 (extreme attempt) caps at maxDelay without overflow',
    'Custom parameters: low maxRetries starts backoff early',
    'Custom parameters: high base delay affects all attempts',
    'Custom parameters: low max delay caps quickly',
    'Jitter is applied to exponential backoff attempts',
    'Edge case: attempt 0 (below boundary) returns base delay',
    'Edge case: attempt 31 (exponent 21 hits cap at 20) prevents overflow',
    'Edge case: maxRetries = 0 immediately uses exponential',
    'Edge case: base delay = 1 (minimum value) works correctly',
    'Edge case: max delay = base delay (no growth allowed)',
    'Boundary: attempt where exponential exactly equals max (no jitter needed)'
}


define_function TestNAVSocketGetExponentialBackoff() {
    stack_var integer x
    stack_var long result
    stack_var long previousResult

    NAVLogTestSuiteStart("'NAVSocketGetExponentialBackoff'")

    for (x = 1; x <= BACKOFF_TEST_COUNT; x++) {
        stack_var char failed
        stack_var long expected
        stack_var long minExpected
        stack_var long maxExpected

        switch (x) {
            case 1: { // Attempt 1 - base delay
                result = NAVSocketGetExponentialBackoff(1, 10, 5000, 300000)
                if (!NAVAssertLongEqual('Attempt 1 returns base delay',
                                       5000,
                                       result)) {
                    failed = true
                }
            }
            case 2: { // Attempt 5 - still base delay
                result = NAVSocketGetExponentialBackoff(5, 10, 5000, 300000)
                if (!NAVAssertLongEqual('Attempt 5 returns base delay',
                                       5000,
                                       result)) {
                    failed = true
                }
            }
            case 3: { // Attempt 10 - boundary, still base delay
                result = NAVSocketGetExponentialBackoff(10, 10, 5000, 300000)
                if (!NAVAssertLongEqual('Attempt 10 returns base delay',
                                       5000,
                                       result)) {
                    failed = true
                }
            }
            case 4: { // Attempt 11 - first exponential: 5000 * 2^1 = 10000 + jitter (100-1000)
                result = NAVSocketGetExponentialBackoff(11, 10, 5000, 300000)
                minExpected = 10100  // 10000 + 100 (min jitter)
                maxExpected = 11000  // 10000 + 1000 (max jitter)
                if (!NAVAssertTrue('Attempt 11 exponential with jitter',
                                   result >= minExpected && result <= maxExpected)) {
                    failed = true
                }
            }
            case 5: { // Attempt 12 - second exponential: 5000 * 2^2 = 20000 + jitter
                result = NAVSocketGetExponentialBackoff(12, 10, 5000, 300000)
                minExpected = 20100
                maxExpected = 21000
                if (!NAVAssertTrue('Attempt 12 exponential with jitter',
                                   result >= minExpected && result <= maxExpected)) {
                    failed = true
                }
            }
            case 6: { // Attempt 13 - third exponential: 5000 * 2^3 = 40000 + jitter
                result = NAVSocketGetExponentialBackoff(13, 10, 5000, 300000)
                minExpected = 40100
                maxExpected = 41000
                if (!NAVAssertTrue('Attempt 13 exponential with jitter',
                                   result >= minExpected && result <= maxExpected)) {
                    failed = true
                }
            }
            case 7: { // Attempt 15 - fifth exponential: 5000 * 2^5 = 160000 + jitter
                result = NAVSocketGetExponentialBackoff(15, 10, 5000, 300000)
                minExpected = 160100
                maxExpected = 161000
                if (!NAVAssertTrue('Attempt 15 exponential with jitter',
                                   result >= minExpected && result <= maxExpected)) {
                    failed = true
                }
            }
            case 8: { // Attempt 20 - should hit max delay cap
                result = NAVSocketGetExponentialBackoff(20, 10, 5000, 300000)
                // 5000 * 2^10 = 5,120,000 which exceeds max of 300,000
                if (!NAVAssertLongEqual('Attempt 20 caps at maxDelay',
                                       300000,
                                       result)) {
                    failed = true
                }
            }
            case 9: { // Attempt 30 - should definitely be capped
                result = NAVSocketGetExponentialBackoff(30, 10, 5000, 300000)
                if (!NAVAssertLongEqual('Attempt 30 caps at maxDelay',
                                       300000,
                                       result)) {
                    failed = true
                }
            }
            case 10: { // Attempt 40 - test overflow protection
                result = NAVSocketGetExponentialBackoff(40, 10, 5000, 300000)
                if (!NAVAssertLongEqual('Attempt 40 caps without overflow',
                                       300000,
                                       result)) {
                    failed = true
                }
            }
            case 11: { // Attempt 100 - extreme case
                result = NAVSocketGetExponentialBackoff(100, 10, 5000, 300000)
                if (!NAVAssertLongEqual('Attempt 100 caps without overflow',
                                       300000,
                                       result)) {
                    failed = true
                }
            }
            case 12: { // Custom: low maxRetries (3), attempt 5 should be exponential
                // 5000 * 2^2 = 20000 + jitter
                result = NAVSocketGetExponentialBackoff(5, 3, 5000, 300000)
                minExpected = 20100
                maxExpected = 21000
                if (!NAVAssertTrue('Low maxRetries starts backoff early',
                                   result >= minExpected && result <= maxExpected)) {
                    failed = true
                }
            }
            case 13: { // Custom: high base delay
                result = NAVSocketGetExponentialBackoff(5, 10, 50000, 300000)
                if (!NAVAssertLongEqual('High base delay affects result',
                                       50000,
                                       result)) {
                    failed = true
                }
            }
            case 14: { // Custom: low max delay caps quickly
                // Attempt 12: 5000 * 2^2 = 20000, but max is 15000
                result = NAVSocketGetExponentialBackoff(12, 10, 5000, 15000)
                if (!NAVAssertLongEqual('Low max delay caps quickly',
                                       15000,
                                       result)) {
                    failed = true
                }
            }
            case 15: { // Verify jitter randomness by testing multiple calls
                stack_var integer y
                stack_var char allSame
                stack_var long firstResult
                stack_var long results[10]

                allSame = true

                // Generate 10 results
                for (y = 1; y <= 10; y++) {
                    results[y] = NAVSocketGetExponentialBackoff(11, 10, 5000, 300000)
                    if (y == 1) {
                        firstResult = results[y]
                    }
                    else if (results[y] != firstResult) {
                        allSame = false
                    }
                }

                // At least some should be different due to jitter
                // (There's a tiny chance all 10 are the same, but unlikely)
                if (!NAVAssertFalse('Jitter produces varied results',
                                   allSame)) {
                    failed = true
                }
            }
            case 16: { // Edge: attempt 0 (below boundary)
                result = NAVSocketGetExponentialBackoff(0, 10, 5000, 300000)
                // Should return base delay (attempt <= maxRetries)
                if (!NAVAssertLongEqual('Attempt 0 returns base delay',
                                       5000,
                                       result)) {
                    failed = true
                }
            }
            case 17: { // Edge: attempt 31 tests exponent cap at 20
                // Without cap: 5000 * 2^21 = 10,485,760,000 (huge overflow)
                // With cap at exponent 20: 5000 * 2^20 = 5,242,880,000 > 300000 → caps at 300000
                result = NAVSocketGetExponentialBackoff(31, 10, 5000, 300000)
                if (!NAVAssertLongEqual('Attempt 31 prevents overflow with exponent cap',
                                       300000,
                                       result)) {
                    failed = true
                }
            }
            case 18: { // Edge: maxRetries = 0, immediately exponential
                // Attempt 1 with maxRetries=0: 5000 * 2^1 = 10000 + jitter
                result = NAVSocketGetExponentialBackoff(1, 0, 5000, 300000)
                minExpected = 10100
                maxExpected = 11000
                if (!NAVAssertTrue('maxRetries=0 uses exponential immediately',
                                   result >= minExpected && result <= maxExpected)) {
                    failed = true
                }
            }
            case 19: { // Edge: base delay = 1 (minimum)
                result = NAVSocketGetExponentialBackoff(1, 10, 1, 300000)
                if (!NAVAssertLongEqual('Minimum base delay works',
                                       1,
                                       result)) {
                    failed = true
                }
            }
            case 20: { // Edge: max delay = base delay (no growth)
                result = NAVSocketGetExponentialBackoff(11, 10, 5000, 5000)
                // Would be 10000 + jitter, but capped at 5000
                if (!NAVAssertLongEqual('Max equals base prevents any growth',
                                       5000,
                                       result)) {
                    failed = true
                }
            }
            case 21: { // Boundary: exponential exactly hits max
                // Use base=10000, max=40000
                // Attempt 12: 10000 * 2^2 = 40000 (exactly at max before jitter)
                result = NAVSocketGetExponentialBackoff(12, 10, 10000, 40000)
                // Should cap at 40000 (exponential exceeds max before jitter)
                if (!NAVAssertLongEqual('Exponential exactly at max caps correctly',
                                       40000,
                                       result)) {
                    failed = true
                }
            }
        }

        if (failed) {
            NAVLogTestFailed(x, BACKOFF_TEST_DESCRIPTIONS[x], "itoa(result)")
        }
        else {
            NAVLogTestPassed(x)
        }
    }

    NAVLogTestSuiteEnd("'NAVSocketGetExponentialBackoff'")
}
