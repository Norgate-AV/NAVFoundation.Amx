PROGRAM_NAME='NAVQueueBoundary'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

/**
 * Test dequeue from empty queue
 */
define_function TestNAVQueueDequeueEmpty() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVQueueDequeueEmpty *****************'")

    NAVQueueInit(queue, 5)

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Dequeue from empty should return NAV_NULL', "NAV_NULL", result)) {
        NAVLogTestFailed(1, 'NAV_NULL', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should remain 0', 0, queue.Count)) {
        NAVLogTestFailed(2, itoa(0), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test peek at empty queue
 */
define_function TestNAVQueuePeekEmpty() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVQueuePeekEmpty *****************'")

    NAVQueueInit(queue, 5)

    result = NAVQueuePeek(queue)
    if (!NAVAssertStringEqual('Peek at empty should return NAV_NULL', "NAV_NULL", result)) {
        NAVLogTestFailed(1, 'NAV_NULL', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should remain 0', 0, queue.Count)) {
        NAVLogTestFailed(2, itoa(0), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test enqueue to full queue
 */
define_function TestNAVQueueEnqueueFull() {
    stack_var _NAVQueue queue
    stack_var integer result
    stack_var integer i

    NAVLog("'***************** TestNAVQueueEnqueueFull *****************'")

    NAVQueueInit(queue, 3)

    // Fill the queue
    for (i = 1; i <= 3; i++) {
        NAVQueueEnqueue(queue, "'item', itoa(i)")
    }

    if (!NAVAssertTrue('Queue should be full', NAVQueueIsFull(queue))) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    // Try to enqueue to full queue
    result = NAVQueueEnqueue(queue, 'overflow_item')
    if (!NAVAssertIntegerEqual('Enqueue to full should fail', false, result)) {
        NAVLogTestFailed(2, itoa(false), itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Count should remain at capacity', 3, queue.Count)) {
        NAVLogTestFailed(3, itoa(3), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test contains on empty queue
 */
define_function TestNAVQueueContainsEmpty() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueContainsEmpty *****************'")

    NAVQueueInit(queue, 5)

    if (!NAVAssertFalse('Empty queue should not contain item', NAVQueueContains(queue, 'test_item'))) {
        NAVLogTestFailed(1, 'false', 'true')
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test init with capacity = 1
 */
define_function TestNAVQueueInitCapacityOne() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVQueueInitCapacityOne *****************'")

    NAVQueueInit(queue, 1)

    if (!NAVAssertIntegerEqual('Capacity should be 1', 1, queue.Capacity)) {
        NAVLogTestFailed(1, itoa(1), itoa(queue.Capacity))
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVQueueEnqueue(queue, 'single_item')

    if (!NAVAssertTrue('Queue with capacity 1 should be full', NAVQueueIsFull(queue))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Should dequeue single item', 'single_item', result)) {
        NAVLogTestFailed(3, 'single_item', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test init with capacity = 0 (should default to max)
 */
define_function TestNAVQueueInitCapacityZero() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueInitCapacityZero *****************'")

    NAVQueueInit(queue, 0)

    if (!NAVAssertIntegerEqual('Capacity should default to max', NAV_MAX_QUEUE_ITEMS, queue.Capacity)) {
        NAVLogTestFailed(1, itoa(NAV_MAX_QUEUE_ITEMS), itoa(queue.Capacity))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test init with negative capacity (should default to max)
 */
// define_function TestNAVQueueInitCapacityNegative() {
//     stack_var _NAVQueue queue

//     NAVLog("'***************** TestNAVQueueInitCapacityNegative *****************'")

//     NAVQueueInit(queue, -10)

//     if (!NAVAssertIntegerEqual('Capacity should default to max', NAV_MAX_QUEUE_ITEMS, queue.Capacity)) {
//         NAVLogTestFailed(1, itoa(NAV_MAX_QUEUE_ITEMS), itoa(queue.Capacity))
//     }
//     else {
//         NAVLogTestPassed(1)
//     }
// }

/**
 * Test init with capacity > max (should cap at max)
 */
define_function TestNAVQueueInitCapacityExceedsMax() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueInitCapacityExceedsMax *****************'")

    NAVQueueInit(queue, NAV_MAX_QUEUE_ITEMS + 100)

    if (!NAVAssertIntegerEqual('Capacity should cap at max', NAV_MAX_QUEUE_ITEMS, queue.Capacity)) {
        NAVLogTestFailed(1, itoa(NAV_MAX_QUEUE_ITEMS), itoa(queue.Capacity))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test queue with long strings
 */
define_function TestNAVQueueLongStrings() {
    stack_var _NAVQueue queue
    stack_var char longString[NAV_MAX_BUFFER]
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVQueueLongStrings *****************'")

    NAVQueueInit(queue, 5)

    // Create a long string
    longString = 'This is a very long test string that approaches the NAV_MAX_BUFFER limit '
    for (i = 1; i <= 50; i++) {
        longString = "longString, 'x'"
    }

    NAVQueueEnqueue(queue, longString)

    if (!NAVAssertIntegerEqual('Should enqueue long string', 1, queue.Count)) {
        NAVLogTestFailed(1, itoa(1), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Should dequeue long string correctly', longString, result)) {
        NAVLogTestFailed(2, 'long string', 'mismatch')
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test queue with special characters
 */
define_function TestNAVQueueSpecialCharacters() {
    stack_var _NAVQueue queue
    stack_var char specialString[NAV_MAX_BUFFER]
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVQueueSpecialCharacters *****************'")

    NAVQueueInit(queue, 5)

    specialString = 'Test!@#$%^&*()_+-=[]{}|;:,.<>?'

    NAVQueueEnqueue(queue, specialString)

    if (!NAVAssertIntegerEqual('Should enqueue special chars', 1, queue.Count)) {
        NAVLogTestFailed(1, itoa(1), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(1)
    }

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Should dequeue special chars correctly', specialString, result)) {
        NAVLogTestFailed(2, specialString, result)
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test queue clear and reuse
 */
define_function TestNAVQueueClearAndReuse() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVQueueClearAndReuse *****************'")

    NAVQueueInit(queue, 5)

    // Add some items
    for (i = 1; i <= 3; i++) {
        NAVQueueEnqueue(queue, "'first_', itoa(i)")
    }

    NAVQueueClear(queue)

    if (!NAVAssertIntegerEqual('Count should be 0 after clear', 0, queue.Count)) {
        NAVLogTestFailed(1, itoa(0), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Reuse the queue
    for (i = 1; i <= 3; i++) {
        NAVQueueEnqueue(queue, "'second_', itoa(i)")
    }

    if (!NAVAssertIntegerEqual('Should have 3 items after reuse', 3, queue.Count)) {
        NAVLogTestFailed(2, itoa(3), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Should get new items, not old', 'second_1', result)) {
        NAVLogTestFailed(3, 'second_1', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}
