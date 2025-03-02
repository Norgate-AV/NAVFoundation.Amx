PROGRAM_NAME='NAVQueueEmptyFull'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Queue.axi'

define_function TestNAVQueueEmptyFull() {
    stack_var _NAVQueue queue
    stack_var integer testCount

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVQueueIsEmpty and NAVQueueIsFull *****************'")

    testCount = 0

    // Test 1: New queue should be empty and not full
    NAVQueueInit(queue, 3)
    testCount++

    if (!NAVAssertIntegerEqual(NAVQueueIsEmpty(queue), true)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testCount), ' failed. Expected queue to be empty'")
    } else if (!NAVAssertIntegerEqual(NAVQueueIsFull(queue), false)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testCount), ' failed. Expected queue to not be full'")
    } else {
        NAVLogTestPassed(testCount)
    }

    // Test 2: Queue with one item should not be empty
    NAVQueueEnqueue(queue, 'Item1')
    testCount++

    if (!NAVAssertIntegerEqual(NAVQueueIsEmpty(queue), false)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testCount), ' failed. Expected queue to not be empty'")
    } else {
        NAVLogTestPassed(testCount)
    }

    // Test 3: Full queue should be full
    NAVQueueInit(queue, 1)
    NAVQueueEnqueue(queue, 'Item1')
    testCount++

    if (!NAVAssertIntegerEqual(NAVQueueIsFull(queue), true)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testCount), ' failed. Expected queue to be full'")
    } else {
        NAVLogTestPassed(testCount)
    }

    // Test 4: Queue after dequeue should not be full
    NAVQueueDequeue(queue)
    testCount++

    if (!NAVAssertIntegerEqual(NAVQueueIsFull(queue), false)) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test ', itoa(testCount), ' failed. Expected queue not to be full after dequeue'")
    } else {
        NAVLogTestPassed(testCount)
    }
}
