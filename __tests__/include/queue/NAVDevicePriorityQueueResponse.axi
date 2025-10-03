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

    // Set busy to prevent auto-send on first enqueue
    queue.Busy = true
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)  // Sets busy, dequeues first item

    NAVDevicePriorityQueueGoodResponse(queue)

    // GoodResponse clears busy, then SendNextItem dequeues next item and sets busy again
    if (!NAVAssertIntegerEqual('Busy flag should be true after processing next item', true, queue.Busy)) {
        NAVLogTestFailed(1, itoa(true), itoa(queue.Busy))
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

    // Note: GoodResponse calls SendNextItem which dequeues next item
    // Since we have 2 items, after processing the first good response,
    // SendNextItem will dequeue and send the second item
    if (!NAVAssertStringEqual('LastMessage should be second command', DPQ_RESPONSE_TEST_COMMANDS[2], queue.LastMessage)) {
        NAVLogTestFailed(4, DPQ_RESPONSE_TEST_COMMANDS[2], queue.LastMessage)
    }
    else {
        NAVLogTestPassed(4)
    }

    // Both items should now be dequeued (first was dequeued manually, second by GoodResponse)
    if (!NAVAssertIntegerEqual('Command queue should be empty', 0, NAVQueueGetCount(queue.CommandQueue))) {
        NAVLogTestFailed(5, itoa(0), itoa(NAVQueueGetCount(queue.CommandQueue)))
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

    // Set busy to prevent auto-send on enqueue
    queue.Busy = true
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

    // FailedResponse sets Resend=true then calls SendNextItem
    // SendNextItem checks Resend flag, uses LastMessage, then clears Resend
    if (!NAVAssertIntegerEqual('Resend flag should be false after SendNextItem', false, queue.Resend)) {
        NAVLogTestFailed(2, itoa(false), itoa(queue.Resend))
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

    // Set busy to prevent auto-send on first enqueue
    queue.Busy = true
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)

    // Fail 4 times (3 retries + 1 final failure triggers reinit)
    // MaxFailedCount = 3, so: 0→1, 1→2, 2→3 (all retry), then 3 triggers reinit
    for (i = 1; i <= 4; i++) {
        NAVDevicePriorityQueueFailedResponse(queue)
    }

    // After max failures, FailedResponse calls Init which clears everything
    if (!NAVAssertIntegerEqual('FailedCount should be 0 after reinit', 0, queue.FailedCount)) {
        NAVLogTestFailed(1, itoa(0), itoa(queue.FailedCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // After Init, Busy will be false (cleared by Init)
    if (!NAVAssertIntegerEqual('Busy flag should be false after reinit', false, queue.Busy)) {
        NAVLogTestFailed(2, itoa(false), itoa(queue.Busy))
    }
    else {
        NAVLogTestPassed(2)
    }

    // LastMessage should be empty (cleared by Init)
    if (!NAVAssertStringEqual('LastMessage should be empty after reinit', '', queue.LastMessage)) {
        NAVLogTestFailed(3, "''", queue.LastMessage)
    }
    else {
        NAVLogTestPassed(3)
    }

    // The queues should be empty (cleared by Init)
    if (!NAVAssertIntegerEqual('Command queue should be empty after reinit', 0, NAVQueueGetCount(queue.CommandQueue))) {
        NAVLogTestFailed(4, itoa(0), itoa(NAVQueueGetCount(queue.CommandQueue)))
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

    // Set busy to prevent auto-send on first enqueue
    queue.Busy = true
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_RESPONSE_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)  // Dequeues first command

    // Simulate failure and resend
    NAVDevicePriorityQueueFailedResponse(queue)

    // FailedResponse sets Resend=true then calls SendNextItem
    // SendNextItem uses LastMessage (resend), then clears Resend flag
    if (!NAVAssertIntegerEqual('Resend flag should be false after SendNextItem', false, queue.Resend)) {
        NAVLogTestFailed(1, itoa(false), itoa(queue.Resend))
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
