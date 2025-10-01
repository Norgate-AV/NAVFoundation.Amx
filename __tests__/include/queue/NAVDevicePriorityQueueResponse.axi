PROGRAM_NAME='NAVDevicePriorityQueueResponse'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char DPQ_RESPONSE_TEST_COMMANDS[][50] = {
    'POWER=ON',
    'INPUT=HDMI1',
    'VOLUME=50'
}

constant integer NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND = true


/**
 * Test GoodResponse clears busy flag and processes next item
 */
define_function TestNAVDevicePriorityQueueGoodResponse() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVDevicePriorityQueueGoodResponse *****************'")

    NAVDevicePriorityQueueInit(queue)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)  // Sets busy, dequeues first item

    NAVDevicePriorityQueueGoodResponse(queue)

    if (!NAVAssertIntegerEqual('Busy flag should be false after good response', false, queue.Busy)) {
        NAVLogTestFailed(1, itoa(false), itoa(queue.Busy))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('FailedCount should be 0', 0, queue.FailedCount)) {
        NAVLogTestFailed(2, itoa(0), itoa(queue.FailedCount))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('Resend flag should be false', false, queue.Resend)) {
        NAVLogTestFailed(3, itoa(false), itoa(queue.Resend))
    }
    else {
        NAVLogTestPassed(3)
    }

    // GoodResponse should have dequeued the next item and set busy again
    if (!NAVAssertIntegerEqual('Busy flag should be true after processing next item', true, queue.Busy)) {
        NAVLogTestFailed(4, itoa(true), itoa(queue.Busy))
    }
    else {
        NAVLogTestPassed(4)
    }

    if (!NAVAssertStringEqual('LastMessage should be second command', DPQ_RESPONSE_TEST_COMMANDS[2], queue.LastMessage)) {
        NAVLogTestFailed(5, DPQ_RESPONSE_TEST_COMMANDS[2], queue.LastMessage)
    }
    else {
        NAVLogTestPassed(5)
    }
}


/**
 * Test FailedResponse increments counter and sets resend flag
 */
define_function TestNAVDevicePriorityQueueFailedResponse() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVDevicePriorityQueueFailedResponse *****************'")

    NAVDevicePriorityQueueInit(queue)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)

    NAVDevicePriorityQueueFailedResponse(queue)

    if (!NAVAssertIntegerEqual('FailedCount should be 1 after first failure', 1, queue.FailedCount)) {
        NAVLogTestFailed(1, itoa(1), itoa(queue.FailedCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Resend flag should be true', true, queue.Resend)) {
        NAVLogTestFailed(2, itoa(true), itoa(queue.Resend))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertStringEqual('LastMessage should still be the failed command', DPQ_RESPONSE_TEST_COMMANDS[1], queue.LastMessage)) {
        NAVLogTestFailed(3, DPQ_RESPONSE_TEST_COMMANDS[1], queue.LastMessage)
    }
    else {
        NAVLogTestPassed(3)
    }
}


/**
 * Test FailedResponse reinitializes after max failures
 */
define_function TestNAVDevicePriorityQueueMaxFailures() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'***************** TestNAVDevicePriorityQueueMaxFailures *****************'")

    NAVDevicePriorityQueueInit(queue)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)

    // Fail 3 times (max failures)
    for (i = 1; i <= 3; i++) {
        NAVDevicePriorityQueueFailedResponse(queue)
    }

    if (!NAVAssertIntegerEqual('FailedCount should be 0 after max failures', 0, queue.FailedCount)) {
        NAVLogTestFailed(1, itoa(0), itoa(queue.FailedCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Busy flag should be false after reinit', false, queue.Busy)) {
        NAVLogTestFailed(2, itoa(false), itoa(queue.Busy))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertStringEqual('LastMessage should be empty after reinit', '', queue.LastMessage)) {
        NAVLogTestFailed(3, "''", queue.LastMessage)
    }
    else {
        NAVLogTestPassed(3)
    }

    // The queues should still have the remaining item (second command)
    if (!NAVAssertIntegerEqual('Command queue should have 1 item remaining', 1, NAVQueueGetCount(queue.CommandQueue))) {
        NAVLogTestFailed(4, itoa(1), itoa(NAVQueueGetCount(queue.CommandQueue)))
    }
    else {
        NAVLogTestPassed(4)
    }
}


/**
 * Test FailedResponse does nothing when not busy
 */
define_function TestNAVDevicePriorityQueueFailedResponseWhenNotBusy() {
    stack_var _NAVDevicePriorityQueue queue

    NAVLog("'***************** TestNAVDevicePriorityQueueFailedResponseWhenNotBusy *****************'")

    NAVDevicePriorityQueueInit(queue)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false

    NAVDevicePriorityQueueFailedResponse(queue)

    if (!NAVAssertIntegerEqual('FailedCount should remain 0', 0, queue.FailedCount)) {
        NAVLogTestFailed(1, itoa(0), itoa(queue.FailedCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Resend flag should remain false', false, queue.Resend)) {
        NAVLogTestFailed(2, itoa(false), itoa(queue.Resend))
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test resend functionality
 */
define_function TestNAVDevicePriorityQueueResend() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVDevicePriorityQueueResend *****************'")

    NAVDevicePriorityQueueInit(queue)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)  // Dequeues first command

    // Simulate failure and resend
    NAVDevicePriorityQueueFailedResponse(queue)

    if (!NAVAssertIntegerEqual('Resend flag should be true', true, queue.Resend)) {
        NAVLogTestFailed(1, itoa(true), itoa(queue.Resend))
    }
    else {
        NAVLogTestPassed(1)
    }

    // SendNextItem would be called by FailedResponse, which should resend the same message
    // The LastMessage should still be the first command
    if (!NAVAssertStringEqual('LastMessage should still be first command', DPQ_RESPONSE_TEST_COMMANDS[1], queue.LastMessage)) {
        NAVLogTestFailed(2, DPQ_RESPONSE_TEST_COMMANDS[1], queue.LastMessage)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Command queue should still have 1 item (second command)
    if (!NAVAssertIntegerEqual('Command queue should still have 1 item', 1, NAVQueueGetCount(queue.CommandQueue))) {
        NAVLogTestFailed(3, itoa(1), itoa(NAVQueueGetCount(queue.CommandQueue)))
    }
    else {
        NAVLogTestPassed(3)
    }
}
