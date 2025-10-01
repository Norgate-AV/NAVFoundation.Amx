PROGRAM_NAME='NAVDevicePriorityQueueBasic'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char DPQ_BASIC_TEST_COMMANDS[][50] = {
    'POWER=ON',
    'INPUT=HDMI1',
    'VOLUME=50'
}

constant integer NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND = true

/**
 * Test device priority queue initialization
 */
define_function TestNAVDevicePriorityQueueInit() {
    stack_var _NAVDevicePriorityQueue queue

    NAVLog("'***************** TestNAVDevicePriorityQueueInit *****************'")

    NAVDevicePriorityQueueInit(queue)

    if (!NAVAssertIntegerEqual('Command queue capacity should be 50', 50, NAVQueueGetCapacity(queue.CommandQueue))) {
        NAVLogTestFailed(1, itoa(50), itoa(NAVQueueGetCapacity(queue.CommandQueue)))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Query queue capacity should be 100', 100, NAVQueueGetCapacity(queue.QueryQueue))) {
        NAVLogTestFailed(2, itoa(100), itoa(NAVQueueGetCapacity(queue.QueryQueue)))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Busy flag should be false', false, queue.Busy)) {
        NAVLogTestFailed(3, itoa(false), itoa(queue.Busy))
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('FailedCount should be 0', 0, queue.FailedCount)) {
        NAVLogTestFailed(4, itoa(0), itoa(queue.FailedCount))
    }
    else {
        NAVLogTestPassed(4)
    }

    if (!NAVAssertIntegerEqual('MaxFailedCount should be 3', 3, queue.MaxFailedCount)) {
        NAVLogTestFailed(5, itoa(3), itoa(queue.MaxFailedCount))
    }
    else {
        NAVLogTestPassed(5)
    }

    if (!NAVAssertIntegerEqual('Resend flag should be false', false, queue.Resend)) {
        NAVLogTestFailed(6, itoa(false), itoa(queue.Resend))
    }
    else {
        NAVLogTestPassed(6)
    }

    if (!NAVAssertStringEqual('LastMessage should be empty', '', queue.LastMessage)) {
        NAVLogTestFailed(7, "''", queue.LastMessage)
    }
    else {
        NAVLogTestPassed(7)
    }
}


/**
 * Test device priority queue isEmpty and hasItems functionality
 */
define_function TestNAVDevicePriorityQueueEmptyState() {
    stack_var _NAVDevicePriorityQueue queue

    NAVLog("'***************** TestNAVDevicePriorityQueueEmptyState *****************'")

    NAVDevicePriorityQueueInit(queue)

    if (!NAVAssertIntegerEqual('New queue should be empty', true, NAVDevicePriorityQueueIsEmpty(queue))) {
        NAVLogTestFailed(1, itoa(true), itoa(NAVDevicePriorityQueueIsEmpty(queue)))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('New queue should not have items', false, NAVDevicePriorityQueueHasItems(queue))) {
        NAVLogTestFailed(2, itoa(false), itoa(NAVDevicePriorityQueueHasItems(queue)))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Set busy to prevent auto-send on enqueue (for testing enqueue behavior in isolation)
    queue.Busy = true

    // Add a command
    NAVDevicePriorityQueueEnqueue(queue, DPQ_BASIC_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    if (!NAVAssertIntegerEqual('Queue should not be empty after enqueue', false, NAVDevicePriorityQueueIsEmpty(queue))) {
        NAVLogTestFailed(3, itoa(false), itoa(NAVDevicePriorityQueueIsEmpty(queue)))
    }
    else {
        NAVLogTestPassed(3)
    }

    if (!NAVAssertIntegerEqual('Queue should have items after enqueue', true, NAVDevicePriorityQueueHasItems(queue))) {
        NAVLogTestFailed(4, itoa(true), itoa(NAVDevicePriorityQueueHasItems(queue)))
    }
    else {
        NAVLogTestPassed(4)
    }
}


/**
 * Test GetLastMessage functionality
 */
define_function TestNAVDevicePriorityQueueGetLastMessage() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVDevicePriorityQueueGetLastMessage *****************'")

    NAVDevicePriorityQueueInit(queue)

    // Set busy to prevent auto-send on enqueue
    queue.Busy = true
    NAVDevicePriorityQueueEnqueue(queue, DPQ_BASIC_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)

    result = NAVDevicePriorityQueueGetLastMessage(queue)

    if (!NAVAssertStringEqual('GetLastMessage should return last dequeued item', DPQ_BASIC_TEST_COMMANDS[1], result)) {
        NAVLogTestFailed(1, DPQ_BASIC_TEST_COMMANDS[1], result)
    }
    else {
        NAVLogTestPassed(1)
    }
}
