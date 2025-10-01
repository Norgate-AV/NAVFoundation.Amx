PROGRAM_NAME='NAVDevicePriorityQueueCallbackTests'

/**
 * Test functions for NAVDevicePriorityQueue callbacks
 * This file must be included AFTER DevicePriorityQueue.axi so constants are available
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_DEVICEPRIORITYQUEUE_CALLBACK_TESTS__
#DEFINE __NAV_FOUNDATION_DEVICEPRIORITYQUEUE_CALLBACK_TESTS__ 'NAVDevicePriorityQueueCallbackTests'


DEFINE_CONSTANT

char DPQ_CALLBACK_TEST_COMMANDS[][NAV_MAX_BUFFER] = {
    'POWER=ON',
    'VOLUME=50',
    'INPUT=HDMI1'
}


/**
 * Test SendNextItem callback is invoked when sending next item
 */
define_function TestNAVDevicePriorityQueueSendNextItemCallback() {
    stack_var _NAVDevicePriorityQueue queue

    NAVLog("'***************** TestNAVDevicePriorityQueueSendNextItemCallback *****************'")

    NAVDevicePriorityQueueInit(queue)
    ResetCallbackTracking()

    // Enqueue an item
    NAVDevicePriorityQueueEnqueue(queue, DPQ_CALLBACK_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    // Call SendNextItem explicitly (this is what triggers the callback)
    NAVDevicePriorityQueueSendNextItem(queue)

    if (!NAVAssertIntegerEqual('SendNextItem callback should be called', true, callbackSendNextItemCalled)) {
        NAVLogTestFailed(1, itoa(true), itoa(callbackSendNextItemCalled))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertStringEqual('Callback should receive the command', DPQ_CALLBACK_TEST_COMMANDS[1], callbackSendNextItemValue)) {
        NAVLogTestFailed(2, DPQ_CALLBACK_TEST_COMMANDS[1], callbackSendNextItemValue)
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test SendNextItem callback is invoked on GoodResponse
 */
define_function TestNAVDevicePriorityQueueGoodResponseCallback() {
    stack_var _NAVDevicePriorityQueue queue

    NAVLog("'***************** TestNAVDevicePriorityQueueGoodResponseCallback *****************'")

    NAVDevicePriorityQueueInit(queue)

    // Enqueue two items
    NAVDevicePriorityQueueEnqueue(queue, DPQ_CALLBACK_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_CALLBACK_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    // First item will auto-send on enqueue, reset tracking after that
    ResetCallbackTracking()

    // Now call GoodResponse which should trigger callback for second item
    NAVDevicePriorityQueueGoodResponse(queue)

    if (!NAVAssertIntegerEqual('SendNextItem callback should be called by GoodResponse', true, callbackSendNextItemCalled)) {
        NAVLogTestFailed(1, itoa(true), itoa(callbackSendNextItemCalled))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertStringEqual('Callback should receive second command', DPQ_CALLBACK_TEST_COMMANDS[2], callbackSendNextItemValue)) {
        NAVLogTestFailed(2, DPQ_CALLBACK_TEST_COMMANDS[2], callbackSendNextItemValue)
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test SendNextItem callback is invoked on resend
 */
define_function TestNAVDevicePriorityQueueResendCallback() {
    stack_var _NAVDevicePriorityQueue queue

    NAVLog("'***************** TestNAVDevicePriorityQueueResendCallback *****************'")

    NAVDevicePriorityQueueInit(queue)

    // Enqueue an item (it will auto-send)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_CALLBACK_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    ResetCallbackTracking()  // Reset after auto-send

    // Calling FailedResponse will set Resend flag and call SendNextItem
    NAVDevicePriorityQueueFailedResponse(queue)

    if (!NAVAssertIntegerEqual('SendNextItem callback should be called on resend', true, callbackSendNextItemCalled)) {
        NAVLogTestFailed(1, itoa(true), itoa(callbackSendNextItemCalled))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertStringEqual('Callback should receive same command (resend)', DPQ_CALLBACK_TEST_COMMANDS[1], callbackSendNextItemValue)) {
        NAVLogTestFailed(2, DPQ_CALLBACK_TEST_COMMANDS[1], callbackSendNextItemValue)
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test FailedResponse callback is invoked after max failures
 */
define_function TestNAVDevicePriorityQueueFailedResponseCallback() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var integer i

    NAVLog("'***************** TestNAVDevicePriorityQueueFailedResponseCallback *****************'")

    NAVDevicePriorityQueueInit(queue)
    ResetCallbackTracking()

    // Enqueue an item (it will auto-send)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_CALLBACK_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    // Fail 4 times to trigger max failures callback
    // With MaxFailedCount=3, we need: 0->1, 1->2, 2->3, then 3>=3 triggers callback
    for (i = 1; i <= 4; i++) {
        NAVDevicePriorityQueueFailedResponse(queue)
    }

    if (!NAVAssertIntegerEqual('FailedResponse callback should be called', true, callbackFailedResponseCalled)) {
        NAVLogTestFailed(1, itoa(true), itoa(callbackFailedResponseCalled))
    }
    else {
        NAVLogTestPassed(1)
    }

    // The callback captures FailedCount before Init() resets it
    if (!NAVAssertIntegerEqual('Callback should receive FailedCount of 3', 3, callbackFailedResponseFailedCount)) {
        NAVLogTestFailed(2, itoa(3), itoa(callbackFailedResponseFailedCount))
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test FailedResponse callback is NOT invoked on non-max failures
 */
define_function TestNAVDevicePriorityQueueFailedResponseCallbackNotCalledEarly() {
    stack_var _NAVDevicePriorityQueue queue

    NAVLog("'***************** TestNAVDevicePriorityQueueFailedResponseCallbackNotCalledEarly *****************'")

    NAVDevicePriorityQueueInit(queue)
    ResetCallbackTracking()

    // Enqueue an item (it will auto-send)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_CALLBACK_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    // Fail only once (not max failures)
    NAVDevicePriorityQueueFailedResponse(queue)

    if (!NAVAssertIntegerEqual('FailedResponse callback should NOT be called yet', false, callbackFailedResponseCalled)) {
        NAVLogTestFailed(1, itoa(false), itoa(callbackFailedResponseCalled))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('FailedCount should be 1', 1, queue.FailedCount)) {
        NAVLogTestFailed(2, itoa(1), itoa(queue.FailedCount))
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test callback receives correct items in sequence
 */
define_function TestNAVDevicePriorityQueueCallbackSequence() {
    stack_var _NAVDevicePriorityQueue queue

    NAVLog("'***************** TestNAVDevicePriorityQueueCallbackSequence *****************'")

    NAVDevicePriorityQueueInit(queue)
    ResetCallbackTracking()

    // Enqueue three items
    NAVDevicePriorityQueueEnqueue(queue, DPQ_CALLBACK_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    // First item will auto-send on first enqueue, verify it
    if (!NAVAssertStringEqual('First callback should receive first command', DPQ_CALLBACK_TEST_COMMANDS[1], callbackSendNextItemValue)) {
        NAVLogTestFailed(1, DPQ_CALLBACK_TEST_COMMANDS[1], callbackSendNextItemValue)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Enqueue remaining items
    NAVDevicePriorityQueueEnqueue(queue, DPQ_CALLBACK_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_CALLBACK_TEST_COMMANDS[3], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    // Process second item via GoodResponse
    ResetCallbackTracking()
    NAVDevicePriorityQueueGoodResponse(queue)

    if (!NAVAssertStringEqual('Second callback should receive second command', DPQ_CALLBACK_TEST_COMMANDS[2], callbackSendNextItemValue)) {
        NAVLogTestFailed(2, DPQ_CALLBACK_TEST_COMMANDS[2], callbackSendNextItemValue)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Process third item via GoodResponse
    ResetCallbackTracking()
    NAVDevicePriorityQueueGoodResponse(queue)

    if (!NAVAssertStringEqual('Third callback should receive third command', DPQ_CALLBACK_TEST_COMMANDS[3], callbackSendNextItemValue)) {
        NAVLogTestFailed(3, DPQ_CALLBACK_TEST_COMMANDS[3], callbackSendNextItemValue)
    }
    else {
        NAVLogTestPassed(3)
    }
}


#END_IF
