PROGRAM_NAME='NAVDevicePriorityQueueState'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char DPQ_STATE_TEST_COMMANDS[][50] = {
    'POWER=ON',
    'INPUT=HDMI1',
    'VOLUME=50'
}

constant integer NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND = true


/**
 * Test dequeue sets busy flag
 */
define_function TestNAVDevicePriorityQueueDequeueBusyFlag() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVDevicePriorityQueueDequeueBusyFlag *****************'")

    NAVDevicePriorityQueueInit(queue)

    // Set busy to prevent auto-send on enqueue
    queue.Busy = true
    NAVDevicePriorityQueueEnqueue(queue, DPQ_STATE_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)

    if (!NAVAssertIntegerEqual('Busy flag should be true after dequeue', true, queue.Busy)) {
        NAVLogTestFailed(1, itoa(true), itoa(queue.Busy))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertStringEqual('LastMessage should be set after dequeue', DPQ_STATE_TEST_COMMANDS[1], queue.LastMessage)) {
        NAVLogTestFailed(2, DPQ_STATE_TEST_COMMANDS[1], queue.LastMessage)
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test dequeue returns empty string when busy
 */
define_function TestNAVDevicePriorityQueueDequeueWhenBusy() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVDevicePriorityQueueDequeueWhenBusy *****************'")

    NAVDevicePriorityQueueInit(queue)

    // Set busy to prevent auto-send on first enqueue
    queue.Busy = true
    NAVDevicePriorityQueueEnqueue(queue, DPQ_STATE_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_STATE_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)  // Sets busy flag

    // Try to dequeue again while busy
    result = NAVDevicePriorityQueueDequeue(queue)

    if (!NAVAssertStringEqual('Dequeue while busy should return empty string', '', result)) {
        NAVLogTestFailed(1, "''", result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Command queue should still have 1 item', 1, NAVQueueGetCount(queue.CommandQueue))) {
        NAVLogTestFailed(2, itoa(1), itoa(NAVQueueGetCount(queue.CommandQueue)))
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test dequeue returns empty string when empty
 */
define_function TestNAVDevicePriorityQueueDequeueWhenEmpty() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVDevicePriorityQueueDequeueWhenEmpty *****************'")

    NAVDevicePriorityQueueInit(queue)
    queue.Busy = false

    result = NAVDevicePriorityQueueDequeue(queue)

    if (!NAVAssertStringEqual('Dequeue from empty queue should return empty string', '', result)) {
        NAVLogTestFailed(1, "''", result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Busy flag should remain false', false, queue.Busy)) {
        NAVLogTestFailed(2, itoa(false), itoa(queue.Busy))
    }
    else {
        NAVLogTestPassed(2)
    }
}
