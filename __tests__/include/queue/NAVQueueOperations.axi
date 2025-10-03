PROGRAM_NAME='NAVQueueOperations'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Test queue peek functionality
 */
define_function TestNAVQueuePeek() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVQueuePeek *****************'")

    NAVQueueInit(queue, 3)

    NAVQueueEnqueue(queue, 'item1')
    NAVQueueEnqueue(queue, 'item2')

    result = NAVQueuePeek(queue)
    if (!NAVAssertStringEqual('Peek should return item1', 'item1', result)) {
        NAVLogTestFailed(1, 'item1', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should remain 2 after peek', 2, queue.Count)) {
        NAVLogTestFailed(2, itoa(2), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }

    NAVQueueDequeue(queue)
    result = NAVQueuePeek(queue)
    if (!NAVAssertStringEqual('Peek should return item2 after dequeue', 'item2', result)) {
        NAVLogTestFailed(3, 'item2', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test queue clear functionality
 */
define_function TestNAVQueueClear() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueClear *****************'")

    NAVQueueInit(queue, 3)

    NAVQueueEnqueue(queue, 'item1')
    NAVQueueEnqueue(queue, 'item2')

    if (!NAVAssertIntegerEqual('Count should be 2 before clear', 2, queue.Count)) {
        NAVLogTestFailed(1, itoa(2), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVQueueClear(queue)

    if (!NAVAssertIntegerEqual('Count should be 0 after clear', 0, queue.Count)) {
        NAVLogTestFailed(2, itoa(0), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertTrue('Queue should be empty after clear', NAVQueueIsEmpty(queue))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test queue contains functionality
 */
define_function TestNAVQueueContains() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueContains *****************'")

    NAVQueueInit(queue, 3)

    NAVQueueEnqueue(queue, 'item1')
    NAVQueueEnqueue(queue, 'item2')

    if (!NAVAssertTrue('Queue should contain item1', NAVQueueContains(queue, 'item1'))) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertTrue('Queue should contain item2', NAVQueueContains(queue, 'item2'))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertFalse('Queue should not contain item3', NAVQueueContains(queue, 'item3'))) {
        NAVLogTestFailed(3, 'false', 'true')
    }
    else {
        NAVLogTestPassed(3)
    }

    NAVQueueDequeue(queue)

    if (!NAVAssertFalse('Queue should not contain item1 after dequeue', NAVQueueContains(queue, 'item1'))) {
        NAVLogTestFailed(4, 'false', 'true')
    }
    else {
        NAVLogTestPassed(4)
    }

    if (!NAVAssertTrue('Queue should still contain item2', NAVQueueContains(queue, 'item2'))) {
        NAVLogTestFailed(5, 'true', 'false')
    }
    else {
        NAVLogTestPassed(5)
    }
}

/**
 * Test queue ToString functionality
 */
define_function TestNAVQueueToString() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVQueueToString *****************'")

    NAVQueueInit(queue, 3)

    result = NAVQueueToString(queue)
    if (!NAVAssertStringEqual('Empty queue should show empty', 'Queue [0/3]: empty', result)) {
        NAVLogTestFailed(1, 'Queue [0/3]: empty', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    NAVQueueEnqueue(queue, 'item1')
    result = NAVQueueToString(queue)
    if (!NAVAssertStringEqual('Queue with one item', 'Queue [1/3]: item1', result)) {
        NAVLogTestFailed(2, 'Queue [1/3]: item1', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    NAVQueueEnqueue(queue, 'item2')
    result = NAVQueueToString(queue)
    if (!NAVAssertStringEqual('Queue with two items', 'Queue [2/3]: item1, item2', result)) {
        NAVLogTestFailed(3, 'Queue [2/3]: item1, item2', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}
