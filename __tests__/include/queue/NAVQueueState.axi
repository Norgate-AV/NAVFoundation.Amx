PROGRAM_NAME='NAVQueueState'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Test queue IsEmpty state check
 */
define_function TestNAVQueueIsEmpty() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueIsEmpty *****************'")

    NAVQueueInit(queue, 3)

    if (!NAVAssertTrue('Queue should be empty initially', NAVQueueIsEmpty(queue))) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVQueueEnqueue(queue, 'item1')

    if (!NAVAssertFalse('Queue should not be empty after enqueue', NAVQueueIsEmpty(queue))) {
        NAVLogTestFailed(2, 'false', 'true')
    }
    else {
        NAVLogTestPassed(2)
    }

    NAVQueueDequeue(queue)

    if (!NAVAssertTrue('Queue should be empty after dequeue', NAVQueueIsEmpty(queue))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test queue HasItems state check
 */
define_function TestNAVQueueHasItems() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueHasItems *****************'")

    NAVQueueInit(queue, 3)

    if (!NAVAssertFalse('Queue should not have items initially', NAVQueueHasItems(queue))) {
        NAVLogTestFailed(1, 'false', 'true')
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVQueueEnqueue(queue, 'item1')

    if (!NAVAssertTrue('Queue should have items after enqueue', NAVQueueHasItems(queue))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }

    NAVQueueDequeue(queue)

    if (!NAVAssertFalse('Queue should not have items after dequeue', NAVQueueHasItems(queue))) {
        NAVLogTestFailed(3, 'false', 'true')
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test queue IsFull state check
 */
define_function TestNAVQueueIsFull() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueIsFull *****************'")

    NAVQueueInit(queue, 2)

    if (!NAVAssertFalse('Queue should not be full initially', NAVQueueIsFull(queue))) {
        NAVLogTestFailed(1, 'false', 'true')
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVQueueEnqueue(queue, 'item1')

    if (!NAVAssertFalse('Queue should not be full with 1 item', NAVQueueIsFull(queue))) {
        NAVLogTestFailed(2, 'false', 'true')
    }
    else {
        NAVLogTestPassed(2)
    }

    NAVQueueEnqueue(queue, 'item2')

    if (!NAVAssertTrue('Queue should be full with 2 items', NAVQueueIsFull(queue))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }

    NAVQueueDequeue(queue)

    if (!NAVAssertFalse('Queue should not be full after dequeue', NAVQueueIsFull(queue))) {
        NAVLogTestFailed(4, 'false', 'true')
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test queue GetCount functionality
 */
define_function TestNAVQueueGetCount() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueGetCount *****************'")

    NAVQueueInit(queue, 3)

    if (!NAVAssertIntegerEqual('Count should be 0 initially', 0, NAVQueueGetCount(queue))) {
        NAVLogTestFailed(1, itoa(0), itoa(NAVQueueGetCount(queue)))
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVQueueEnqueue(queue, 'item1')

    if (!NAVAssertIntegerEqual('Count should be 1 after enqueue', 1, NAVQueueGetCount(queue))) {
        NAVLogTestFailed(2, itoa(1), itoa(NAVQueueGetCount(queue)))
    }
    else {
        NAVLogTestPassed(2)
    }

    NAVQueueEnqueue(queue, 'item2')

    if (!NAVAssertIntegerEqual('Count should be 2 after second enqueue', 2, NAVQueueGetCount(queue))) {
        NAVLogTestFailed(3, itoa(2), itoa(NAVQueueGetCount(queue)))
    }
    else {
        NAVLogTestPassed(3)
    }

    NAVQueueDequeue(queue)

    if (!NAVAssertIntegerEqual('Count should be 1 after dequeue', 1, NAVQueueGetCount(queue))) {
        NAVLogTestFailed(4, itoa(1), itoa(NAVQueueGetCount(queue)))
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test queue GetCapacity functionality
 */
define_function TestNAVQueueGetCapacity() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueGetCapacity *****************'")

    NAVQueueInit(queue, 5)

    if (!NAVAssertIntegerEqual('Capacity should be 5', 5, NAVQueueGetCapacity(queue))) {
        NAVLogTestFailed(1, itoa(5), itoa(NAVQueueGetCapacity(queue)))
    }
    else {
        NAVLogTestPassed(1)
    }
}
