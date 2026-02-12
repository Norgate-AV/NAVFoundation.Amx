PROGRAM_NAME='NAVSocketGetConnectionInterval'

#include 'NAVFoundation.SocketUtils.axi'


DEFINE_CONSTANT

constant integer CONNECTION_INTERVAL_TEST_COUNT = 10

constant char CONNECTION_INTERVAL_TEST_DESCRIPTIONS[CONNECTION_INTERVAL_TEST_COUNT][255] = {
    'Attempt 1 returns base delay (5000ms)',
    'Attempt 5 returns base delay',
    'Attempt 10 (boundary) returns base delay',
    'Attempt 11 starts exponential backoff',
    'Attempt 15 continues exponential growth',
    'Attempt 20 nears max delay',
    'Attempt 25 caps at max delay (300000ms)',
    'Attempt 50 remains capped at max delay',
    'Attempt 100 remains capped without overflow',
    'Multiple calls show consistent behavior'
}


define_function TestNAVSocketGetConnectionInterval() {
    stack_var integer x
    stack_var long result

    NAVLogTestSuiteStart("'NAVSocketGetConnectionInterval'")

    for (x = 1; x <= CONNECTION_INTERVAL_TEST_COUNT; x++) {
        stack_var char failed
        stack_var long minExpected
        stack_var long maxExpected

        switch (x) {
            case 1: { // Attempt 1
                result = NAVSocketGetConnectionInterval(1)
                if (!NAVAssertLongEqual('Attempt 1 returns 5000ms',
                                       5000,
                                       result)) {
                    failed = true
                }
            }
            case 2: { // Attempt 5
                result = NAVSocketGetConnectionInterval(5)
                if (!NAVAssertLongEqual('Attempt 5 returns 5000ms',
                                       5000,
                                       result)) {
                    failed = true
                }
            }
            case 3: { // Attempt 10 (boundary)
                result = NAVSocketGetConnectionInterval(10)
                if (!NAVAssertLongEqual('Attempt 10 returns 5000ms',
                                       5000,
                                       result)) {
                    failed = true
                }
            }
            case 4: { // Attempt 11 - first exponential
                result = NAVSocketGetConnectionInterval(11)
                // 5000 * 2^1 = 10000 + jitter (100-1000)
                minExpected = 10100
                maxExpected = 11000
                if (!NAVAssertTrue('Attempt 11 exponential backoff',
                                   result >= minExpected && result <= maxExpected)) {
                    failed = true
                }
            }
            case 5: { // Attempt 15
                result = NAVSocketGetConnectionInterval(15)
                // 5000 * 2^5 = 160000 + jitter
                minExpected = 160100
                maxExpected = 161000
                if (!NAVAssertTrue('Attempt 15 exponential growth',
                                   result >= minExpected && result <= maxExpected)) {
                    failed = true
                }
            }
            case 6: { // Attempt 20 - should be approaching/at cap
                result = NAVSocketGetConnectionInterval(20)
                // 5000 * 2^10 = 5,120,000 exceeds 300,000 cap
                if (!NAVAssertLongEqual('Attempt 20 reaches max delay',
                                       300000,
                                       result)) {
                    failed = true
                }
            }
            case 7: { // Attempt 25 - definitely capped
                result = NAVSocketGetConnectionInterval(25)
                if (!NAVAssertLongEqual('Attempt 25 capped at 300000ms',
                                       300000,
                                       result)) {
                    failed = true
                }
            }
            case 8: { // Attempt 50 - large value
                result = NAVSocketGetConnectionInterval(50)
                if (!NAVAssertLongEqual('Attempt 50 remains at max',
                                       300000,
                                       result)) {
                    failed = true
                }
            }
            case 9: { // Attempt 100 - overflow protection test
                result = NAVSocketGetConnectionInterval(100)
                if (!NAVAssertLongEqual('Attempt 100 no overflow',
                                       300000,
                                       result)) {
                    failed = true
                }
            }
            case 10: { // Consistency test
                stack_var integer y
                stack_var long result1
                stack_var long result2
                stack_var long result3

                // All non-exponential attempts should be identical
                result1 = NAVSocketGetConnectionInterval(1)
                result2 = NAVSocketGetConnectionInterval(1)
                result3 = NAVSocketGetConnectionInterval(1)

                if (!NAVAssertTrue('Consistent base delay results',
                                  result1 == result2 && result2 == result3 && result3 == 5000)) {
                    failed = true
                }

                // All max-capped attempts should be identical
                result1 = NAVSocketGetConnectionInterval(50)
                result2 = NAVSocketGetConnectionInterval(100)
                result3 = NAVSocketGetConnectionInterval(200)

                if (!NAVAssertTrue('Consistent max delay results',
                                  result1 == result2 && result2 == result3 && result3 == 300000)) {
                    failed = true
                }
            }
        }

        if (failed) {
            NAVLogTestFailed(x, CONNECTION_INTERVAL_TEST_DESCRIPTIONS[x], "itoa(result)")
        }
        else {
            NAVLogTestPassed(x)
        }
    }

    NAVLogTestSuiteEnd("'NAVSocketGetConnectionInterval'")
}
