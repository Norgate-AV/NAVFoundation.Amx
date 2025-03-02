PROGRAM_NAME='NAVQueueEnqueueDequeue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Queue.axi'

DEFINE_CONSTANT

constant integer QUEUE_SIZE = 3

constant char ENQUEUE_TEST_ITEMS[][NAV_MAX_BUFFER] = {
    'Item1',
    'Item2',
    'Item3',
    'Item4'  // This should fail on a queue of size 3
}


define_function TestNAVQueueEnqueueDequeue() {
    stack_var integer x
    stack_var _NAVQueue queue

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** NAVQueueEnqueue and NAVQueueDequeue *****************'")

    // Initialize queue
    NAVQueueInit(queue, QUEUE_SIZE)

    // Test Enqueue operations
    for (x = 1; x <= length_array(ENQUEUE_TEST_ITEMS); x++) {
        stack_var integer result
        stack_var integer expected

        // For the 4th item, we expect enqueue to fail (queue size is 3)
        expected = (x <= QUEUE_SIZE)

        result = NAVQueueEnqueue(queue, ENQUEUE_TEST_ITEMS[x])

        if (!NAVAssertIntegerEqual(result, expected)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Enqueue Test ', itoa(x), ' failed. Expected: ', itoa(expected), ' but got: ', itoa(result)")
            continue
        }

        // Only check count if enqueue was successful
        if (result) {
            if (!NAVAssertIntegerEqual(queue.Count, x)) {
                NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Count Test ', itoa(x), ' failed. Expected count: ', itoa(x), ' but got: ', itoa(queue.Count))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    // Test Dequeue operations
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** Testing dequeue *****************'")

    for (x = 1; x <= QUEUE_SIZE; x++) {
        stack_var char result[NAV_MAX_BUFFER]

        result = NAVQueueDequeue(queue)

        if (!NAVAssertStringEqual(result, ENQUEUE_TEST_ITEMS[x])) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Dequeue Test ', itoa(x), ' failed. Expected: ', ENQUEUE_TEST_ITEMS[x], ' but got: ', result)
            continue
        }

        if (!NAVAssertIntegerEqual(queue.Count, QUEUE_SIZE - x)) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Dequeue Count Test ', itoa(x), ' failed. Expected count: ', itoa(QUEUE_SIZE - x), ' but got: ', itoa(queue.Count))
            continue
        }

        NAVLogTestPassed(QUEUE_SIZE + x)
    }

    // Test dequeue on empty queue
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'***************** Testing dequeue on empty queue *****************'")
    if (!NAVAssertStringEqual(NAVQueueDequeue(queue), 'NAV_NULL')) {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Empty Dequeue Test failed. Expected: NAV_NULL but got something else'")
    } else {
        NAVLogTestPassed(2 * QUEUE_SIZE + 1)
    }
}
