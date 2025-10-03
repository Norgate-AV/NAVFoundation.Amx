PROGRAM_NAME='NAVQueueIntegrity'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char INTEGRITY_TEST_ITEMS[][50] = {
    'integrity_item_1',
    'integrity_item_2',
    'integrity_item_3',
    'integrity_item_4',
    'integrity_item_5',
    'integrity_item_6',
    'integrity_item_7',
    'integrity_item_8',
    'integrity_item_9',
    'integrity_item_10'
}

/**
 * Test FIFO ordering is maintained
 */
define_function TestNAVQueueFIFOOrdering() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVQueueFIFOOrdering *****************'")

    NAVQueueInit(queue, 10)

    // Enqueue items 1-10
    for (i = 1; i <= 10; i++) {
        NAVQueueEnqueue(queue, INTEGRITY_TEST_ITEMS[i])
    }

    // Dequeue and verify order
    for (i = 1; i <= 10; i++) {
        result = NAVQueueDequeue(queue)
        if (!NAVAssertStringEqual('Should maintain FIFO order', INTEGRITY_TEST_ITEMS[i], result)) {
            NAVLogTestFailed(i, INTEGRITY_TEST_ITEMS[i], result)
            return
        }
        else {
            NAVLogTestPassed(i)
        }
    }
}

/**
 * Test data persistence through operations
 */
define_function TestNAVQueueDataPersistence() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVQueueDataPersistence *****************'")

    NAVQueueInit(queue, 10)

    // Add initial data
    for (i = 1; i <= 5; i++) {
        NAVQueueEnqueue(queue, INTEGRITY_TEST_ITEMS[i])
    }

    // Perform various operations
    NAVQueuePeek(queue)
    NAVQueueContains(queue, INTEGRITY_TEST_ITEMS[3])
    NAVQueueGetCount(queue)
    NAVQueueToString(queue)

    // Verify all original items still exist in correct order
    for (i = 1; i <= 5; i++) {
        result = NAVQueueDequeue(queue)
        if (!NAVAssertStringEqual('Data should persist through operations', INTEGRITY_TEST_ITEMS[i], result)) {
            NAVLogTestFailed(i, INTEGRITY_TEST_ITEMS[i], result)
            return
        }
        else {
            NAVLogTestPassed(i)
        }
    }
}

/**
 * Test circular buffer wrap-around behavior
 */
define_function TestNAVQueueCircularWrapAround() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVQueueCircularWrapAround *****************'")

    NAVQueueInit(queue, 5)

    // Fill the queue
    for (i = 1; i <= 5; i++) {
        NAVQueueEnqueue(queue, "'first_', itoa(i)")
    }

    // Dequeue all
    for (i = 1; i <= 5; i++) {
        NAVQueueDequeue(queue)
    }

    if (!NAVAssertTrue('Queue should be empty after dequeue all', NAVQueueIsEmpty(queue))) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    // Fill again (tests wrap-around)
    for (i = 1; i <= 5; i++) {
        NAVQueueEnqueue(queue, "'second_', itoa(i)")
    }

    if (!NAVAssertIntegerEqual('Count should be 5 after refill', 5, queue.Count)) {
        NAVLogTestFailed(2, itoa(5), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Verify correct order after wrap
    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('First item should be correct after wrap', 'second_1', result)) {
        NAVLogTestFailed(3, 'second_1', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test interleaved enqueue/dequeue operations
 */
define_function TestNAVQueueInterleavedOperations() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVQueueInterleavedOperations *****************'")

    NAVQueueInit(queue, 5)

    // Fill partially
    NAVQueueEnqueue(queue, 'item1')
    NAVQueueEnqueue(queue, 'item2')
    NAVQueueEnqueue(queue, 'item3')

    // Dequeue some
    NAVQueueDequeue(queue)
    NAVQueueDequeue(queue)

    // Enqueue more (causes wrap-around)
    NAVQueueEnqueue(queue, 'item4')
    NAVQueueEnqueue(queue, 'item5')
    NAVQueueEnqueue(queue, 'item6')

    if (!NAVAssertIntegerEqual('Count should be 4', 4, queue.Count)) {
        NAVLogTestFailed(1, itoa(4), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Verify order: should be item3, item4, item5, item6
    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('First should be item3', 'item3', result)) {
        NAVLogTestFailed(2, 'item3', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Second should be item4', 'item4', result)) {
        NAVLogTestFailed(3, 'item4', result)
    }
    else {
        NAVLogTestPassed(3)
    }

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Third should be item5', 'item5', result)) {
        NAVLogTestFailed(4, 'item5', result)
    }
    else {
        NAVLogTestPassed(4)
    }

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Fourth should be item6', 'item6', result)) {
        NAVLogTestFailed(5, 'item6', result)
    }
    else {
        NAVLogTestPassed(5)
    }
}

/**
 * Test head/tail state correctness
 */
define_function TestNAVQueueHeadTailState() {
    stack_var _NAVQueue queue
    stack_var integer initialTail

    NAVLog("'***************** TestNAVQueueHeadTailState *****************'")

    NAVQueueInit(queue, 5)

    initialTail = queue.Tail

    if (!NAVAssertIntegerEqual('Initial head should be 0', 0, queue.Head)) {
        NAVLogTestFailed(1, itoa(0), itoa(queue.Head))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Initial tail should be capacity', 5, initialTail)) {
        NAVLogTestFailed(2, itoa(5), itoa(initialTail))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Enqueue one item
    NAVQueueEnqueue(queue, 'test_item')

    if (!NAVAssertIntegerEqual('Head should still be 0 after enqueue', 0, queue.Head)) {
        NAVLogTestFailed(3, itoa(0), itoa(queue.Head))
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('Tail should increment', 1, queue.Tail)) {
        NAVLogTestFailed(4, itoa(1), itoa(queue.Tail))
    }
    else {
        NAVLogTestPassed(4)
    }

    // Dequeue the item
    NAVQueueDequeue(queue)

    if (!NAVAssertIntegerEqual('Head should increment after dequeue', 1, queue.Head)) {
        NAVLogTestFailed(5, itoa(1), itoa(queue.Head))
    }
    else {
        NAVLogTestPassed(5)
    }
}

/**
 * Test peek after wrap-around
 */
define_function TestNAVQueuePeekAfterWrap() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVQueuePeekAfterWrap *****************'")

    NAVQueueInit(queue, 3)

    // Fill and empty to cause wrap
    for (i = 1; i <= 3; i++) {
        NAVQueueEnqueue(queue, "'first_', itoa(i)")
    }

    for (i = 1; i <= 3; i++) {
        NAVQueueDequeue(queue)
    }

    // Add new items (wrapped around)
    NAVQueueEnqueue(queue, 'wrapped_1')
    NAVQueueEnqueue(queue, 'wrapped_2')

    result = NAVQueuePeek(queue)
    if (!NAVAssertStringEqual('Peek should return first wrapped item', 'wrapped_1', result)) {
        NAVLogTestFailed(1, 'wrapped_1', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Count should still be 2 after peek
    if (!NAVAssertIntegerEqual('Count should remain 2', 2, queue.Count)) {
        NAVLogTestFailed(2, itoa(2), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test contains after wrap-around
 */
define_function TestNAVQueueContainsAfterWrap() {
    stack_var _NAVQueue queue
    stack_var integer i

    NAVLog("'***************** TestNAVQueueContainsAfterWrap *****************'")

    NAVQueueInit(queue, 3)

    // Cause wrap-around
    for (i = 1; i <= 3; i++) {
        NAVQueueEnqueue(queue, "'first_', itoa(i)")
    }

    for (i = 1; i <= 2; i++) {
        NAVQueueDequeue(queue)
    }

    NAVQueueEnqueue(queue, 'wrapped_1')
    NAVQueueEnqueue(queue, 'wrapped_2')

    // Should contain wrapped items
    if (!NAVAssertTrue('Should contain wrapped_1', NAVQueueContains(queue, 'wrapped_1'))) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertTrue('Should contain wrapped_2', NAVQueueContains(queue, 'wrapped_2'))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertTrue('Should still contain first_3', NAVQueueContains(queue, 'first_3'))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }

    // Should not contain dequeued items
    if (!NAVAssertFalse('Should not contain first_1', NAVQueueContains(queue, 'first_1'))) {
        NAVLogTestFailed(4, 'false', 'true')
    }
    else {
        NAVLogTestPassed(4)
    }
}
