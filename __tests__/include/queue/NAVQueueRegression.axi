PROGRAM_NAME='NAVQueueRegression'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

/**
 * Test error recovery after invalid operations
 */
define_function TestNAVQueueErrorRecovery() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer enqueueResult

    NAVLog("'***************** TestNAVQueueErrorRecovery *****************'")

    NAVQueueInit(queue, 3)

    // Perform invalid operations
    result = NAVQueueDequeue(queue)  // Dequeue from empty
    result = NAVQueuePeek(queue)     // Peek at empty

    // Queue should still be functional
    enqueueResult = NAVQueueEnqueue(queue, 'recovery_test')
    if (!NAVAssertIntegerEqual('Should work after errors', true, enqueueResult)) {
        NAVLogTestFailed(1, 'true', 'false')
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Should have 1 item', 1, queue.Count)) {
        NAVLogTestFailed(2, itoa(1), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }

    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Should retrieve correct item', 'recovery_test', result)) {
        NAVLogTestFailed(3, 'recovery_test', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test partial operations maintain consistency
 */
define_function TestNAVQueuePartialOperations() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVQueuePartialOperations *****************'")

    NAVQueueInit(queue, 5)

    // Add items (queue is full)
    for (i = 1; i <= 5; i++) {
        NAVQueueEnqueue(queue, "'item_', itoa(i)")
    }

    // Mix valid and invalid operations
    result = NAVQueueDequeue(queue)              // Valid (item_1) - now count=4
    NAVQueueEnqueue(queue, 'overflow')           // Valid (now has space) - count=5
    result = NAVQueueDequeue(queue)              // Valid (item_2) - count=4
    NAVQueueEnqueue(queue, 'new_item')           // Valid - count=5
    result = NAVQueuePeek(queue)                 // Valid (item_3)

    // Verify state is consistent: started with 5, dequeued 2, enqueued 2 = 5
    if (!NAVAssertIntegerEqual('Count should be correct', 5, queue.Count)) {
        NAVLogTestFailed(1, itoa(5), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Verify correct items remain (should be item_3, item_4, item_5, overflow, new_item)
    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Should be item_3', 'item_3', result)) {
        NAVLogTestFailed(2, 'item_3', result)
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test multiple clear operations
 */
define_function TestNAVQueueMultipleClear() {
    stack_var _NAVQueue queue
    stack_var integer i

    NAVLog("'***************** TestNAVQueueMultipleClear *****************'")

    NAVQueueInit(queue, 5)

    // Clear empty queue
    NAVQueueClear(queue)
    if (!NAVAssertIntegerEqual('Count should be 0 after clear empty', 0, queue.Count)) {
        NAVLogTestFailed(1, itoa(0), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Add items and clear
    for (i = 1; i <= 3; i++) {
        NAVQueueEnqueue(queue, "'item_', itoa(i)")
    }
    NAVQueueClear(queue)

    // Add items again and clear again
    for (i = 1; i <= 2; i++) {
        NAVQueueEnqueue(queue, "'new_', itoa(i)")
    }
    NAVQueueClear(queue)

    if (!NAVAssertIntegerEqual('Count should be 0 after multiple clears', 0, queue.Count)) {
        NAVLogTestFailed(2, itoa(0), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Queue should still work
    NAVQueueEnqueue(queue, 'final_item')
    if (!NAVAssertIntegerEqual('Should work after multiple clears', 1, queue.Count)) {
        NAVLogTestFailed(3, itoa(1), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test state consistency after full/empty cycles
 */
define_function TestNAVQueueFullEmptyCycles() {
    stack_var _NAVQueue queue
    stack_var integer i
    stack_var integer cycle

    NAVLog("'***************** TestNAVQueueFullEmptyCycles *****************'")

    NAVQueueInit(queue, 3)

    // Perform multiple fill/empty cycles
    for (cycle = 1; cycle <= 5; cycle++) {
        // Fill
        for (i = 1; i <= 3; i++) {
            NAVQueueEnqueue(queue, "'cycle_', itoa(cycle), '_item_', itoa(i)")
        }

        if (!NAVAssertTrue('Should be full', NAVQueueIsFull(queue))) {
            NAVLogTestFailed(cycle * 2 - 1, 'true', 'false')
            return
        }
        else {
            NAVLogTestPassed(cycle * 2 - 1)
        }

        // Empty
        for (i = 1; i <= 3; i++) {
            NAVQueueDequeue(queue)
        }

        if (!NAVAssertTrue('Should be empty', NAVQueueIsEmpty(queue))) {
            NAVLogTestFailed(cycle * 2, 'true', 'false')
            return
        }
        else {
            NAVLogTestPassed(cycle * 2)
        }
    }
}

/**
 * Test queue integrity with rapid operations
 */
define_function TestNAVQueueRapidOperations() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVQueueRapidOperations *****************'")

    NAVQueueInit(queue, 10)

    // Rapid enqueue/dequeue pattern
    // Enqueues: i=1 through i=19 succeed (20 attempts, but i=20 fails when full)
    // Dequeues: after i=2,4,6,8,10,12,14,16,18,20 (10 times)
    // Dequeues remove: rapid_1,2,3,4,5,6,7,8,9,10
    // Remaining: rapid_11,12,13,14,15,16,17,18,19 (9 items)
    for (i = 1; i <= 20; i++) {
        NAVQueueEnqueue(queue, "'rapid_', itoa(i)")
        if (i % 2 == 0) {
            NAVQueueDequeue(queue)
        }
    }

    // After the loop:
    // - i=19 enqueued rapid_19 (10th item, queue full)
    // - i=20 enqueue rapid_20 failed (queue full)
    // - i=20 then dequeued rapid_10, leaving 9 items
    // - Remaining items: rapid_11 through rapid_19 (9 items)
    if (!NAVAssertIntegerEqual('Count should be 9', 9, queue.Count)) {
        NAVLogTestFailed(1, itoa(9), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Should not be full (9 items, capacity 10)
    if (!NAVAssertFalse('Should not be full', NAVQueueIsFull(queue))) {
        NAVLogTestFailed(2, 'false', 'true')
    }
    else {
        NAVLogTestPassed(2)
    }

    // Verify first item is rapid_11 (first 10 items were dequeued)
    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('First should be rapid_11', 'rapid_11', result)) {
        NAVLogTestFailed(3, 'rapid_11', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test regression: contains with empty slots
 */
define_function TestNAVQueueContainsWithEmptySlots() {
    stack_var _NAVQueue queue

    NAVLog("'***************** TestNAVQueueContainsWithEmptySlots *****************'")

    NAVQueueInit(queue, 5)

    // Add and remove to create pattern with NAV_NULL
    NAVQueueEnqueue(queue, 'item1')
    NAVQueueEnqueue(queue, 'item2')
    NAVQueueDequeue(queue)
    NAVQueueEnqueue(queue, 'item3')

    // Contains should work correctly with empty slots
    if (!NAVAssertFalse('Should not contain dequeued item', NAVQueueContains(queue, 'item1'))) {
        NAVLogTestFailed(1, 'false', 'true')
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertTrue('Should contain item2', NAVQueueContains(queue, 'item2'))) {
        NAVLogTestFailed(2, 'true', 'false')
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertTrue('Should contain item3', NAVQueueContains(queue, 'item3'))) {
        NAVLogTestFailed(3, 'true', 'false')
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test regression: ToString with wrapped queue
 */
define_function TestNAVQueueToStringWrapped() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVQueueToStringWrapped *****************'")

    NAVQueueInit(queue, 3)

    // Create wrapped state
    for (i = 1; i <= 3; i++) {
        NAVQueueEnqueue(queue, "'first_', itoa(i)")
    }

    for (i = 1; i <= 2; i++) {
        NAVQueueDequeue(queue)
    }

    NAVQueueEnqueue(queue, 'wrapped_1')
    NAVQueueEnqueue(queue, 'wrapped_2')

    result = NAVQueueToString(queue)

    // Should show 3 items in correct order
    if (!NAVAssertTrue('ToString should work with wrapped queue', length_array(result) > 0)) {
        NAVLogTestFailed(1, 'non-empty string', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Verify it contains the correct items
    if (!NAVAssertTrue('Should contain first_3', find_string(result, 'first_3', 1) > 0)) {
        NAVLogTestFailed(2, 'contains first_3', result)
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertTrue('Should contain wrapped_1', find_string(result, 'wrapped_1', 1) > 0)) {
        NAVLogTestFailed(3, 'contains wrapped_1', result)
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test initialization multiple times
 */
define_function TestNAVQueueReinitialization() {
    stack_var _NAVQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVQueueReinitialization *****************'")

    // Initialize and use
    NAVQueueInit(queue, 5)
    NAVQueueEnqueue(queue, 'old_item')

    // Reinitialize with different capacity
    NAVQueueInit(queue, 3)

    if (!NAVAssertIntegerEqual('Capacity should be 3 after reinit', 3, queue.Capacity)) {
        NAVLogTestFailed(1, itoa(3), itoa(queue.Capacity))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Count should be 0 after reinit', 0, queue.Count)) {
        NAVLogTestFailed(2, itoa(0), itoa(queue.Count))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Should not contain old item
    if (!NAVAssertFalse('Should not contain old item', NAVQueueContains(queue, 'old_item'))) {
        NAVLogTestFailed(3, 'false', 'true')
    }
    else {
        NAVLogTestPassed(3)
    }

    // Should work normally after reinit
    NAVQueueEnqueue(queue, 'new_item')
    result = NAVQueueDequeue(queue)
    if (!NAVAssertStringEqual('Should work after reinit', 'new_item', result)) {
        NAVLogTestFailed(4, 'new_item', result)
    }
    else {
        NAVLogTestPassed(4)
    }
}
