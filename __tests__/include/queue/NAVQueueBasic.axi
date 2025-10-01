PROGRAM_NAME='NAVQueueBasic'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char BASIC_TEST_ITEMS[][50] = {
    'item1',
    'item2',
    'item3',
    'item4',
    'item5'
}

/**
 * Test basic queue initialization functionality
 */
define_function TestNAVQueueInit() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueInit *****************'")

    NAVQueueInit(queue, 10)

    if (!NAVAssertIntegerEqual('Queue capacity should be 10', 10, queue.Capacity)) {
        NAVLogTestFailed(1, itoa(10), itoa(queue.Capacity))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Queue count should be 0', 0, queue.Count)) {
        NAVLogTestFailed(2, itoa(0), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Queue head should be 0', 0, queue.Head)) {
        NAVLogTestFailed(3, itoa(0), itoa(queue.Head))
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('Queue tail should be capacity', 10, queue.Tail)) {
        NAVLogTestFailed(4, itoa(10), itoa(queue.Tail))
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test basic queue enqueue functionality
 */
define_function TestNAVQueueEnqueue() {
    stack_var _NAVQueue queue
    stack_var integer result

    NAVLog("'***************** TestNAVQueueEnqueue *****************'")

    NAVQueueInit(queue, 3)

    result = NAVQueueEnqueue(queue, BASIC_TEST_ITEMS[1])
    if (!NAVAssertIntegerEqual('First enqueue should succeed', true, result)) {
        NAVLogTestFailed(1, itoa(true), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should be 1 after enqueue', 1, queue.Count)) {
        NAVLogTestFailed(2, itoa(1), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVQueueEnqueue(queue, BASIC_TEST_ITEMS[2])
    if (!NAVAssertIntegerEqual('Count should be 2 after second enqueue', 2, queue.Count)) {
        NAVLogTestFailed(3, itoa(2), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVQueueEnqueue(queue, BASIC_TEST_ITEMS[3])
    if (!NAVAssertIntegerEqual('Count should be 3 after third enqueue', 3, queue.Count)) {
        NAVLogTestFailed(4, itoa(3), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test basic queue dequeue functionality
 */
define_function TestNAVQueueDequeue() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVQueueDequeue *****************'")

    NAVQueueInit(queue, 3)

    NAVQueueEnqueue(queue, BASIC_TEST_ITEMS[1])
    NAVQueueEnqueue(queue, BASIC_TEST_ITEMS[2])
    NAVQueueEnqueue(queue, BASIC_TEST_ITEMS[3])

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Dequeued item should be item1', BASIC_TEST_ITEMS[1], result)) {
        NAVLogTestFailed(1, BASIC_TEST_ITEMS[1], result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should be 2 after dequeue', 2, queue.Count)) {
        NAVLogTestFailed(2, itoa(2), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Dequeued item should be item2', BASIC_TEST_ITEMS[2], result)) {
        NAVLogTestFailed(3, BASIC_TEST_ITEMS[2], result)
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('Count should be 1 after second dequeue', 1, queue.Count)) {
        NAVLogTestFailed(4, itoa(1), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(4)
    }

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Dequeued item should be item3', BASIC_TEST_ITEMS[3], result)) {
        NAVLogTestFailed(5, BASIC_TEST_ITEMS[3], result)
    }
    else {
        NAVLogTestPassed(5)
    }

    if (!NAVAssertIntegerEqual('Count should be 0 after third dequeue', 0, queue.Count)) {
        NAVLogTestFailed(6, itoa(0), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(6)
    }
}
