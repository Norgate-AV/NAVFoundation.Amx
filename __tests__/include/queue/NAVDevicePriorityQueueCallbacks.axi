PROGRAM_NAME='NAVDevicePriorityQueueCallbacks'

/**
 * Test file for NAVDevicePriorityQueue callback functionality
 *
 * NOTE: This file must be structured carefully:
 * 1. The callback #DEFINEs must be set BEFORE including DevicePriorityQueue.axi
 * 2. The callback functions must be defined AFTER including the header (for struct)
 *    but BEFORE including the implementation
 * 3. The test functions must be defined AFTER including the implementation (for constants)
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_DEVICEPRIORITYQUEUE_CALLBACKS__
#DEFINE __NAV_FOUNDATION_DEVICEPRIORITYQUEUE_CALLBACKS__ 'NAVDevicePriorityQueueCallbacks'


// Enable callbacks for testing - these must be defined early
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK

DEFINE_CONSTANT

constant integer NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND = true
constant integer NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY = false


DEFINE_VARIABLE

// Track callback invocations
volatile char callbackSendNextItemCalled = false
volatile char callbackSendNextItemValue[NAV_MAX_BUFFER]
volatile char callbackFailedResponseCalled = false
volatile integer callbackFailedResponseFailedCount = 0


/**
 * Reset callback tracking variables
 */
define_function ResetCallbackTracking() {
    callbackSendNextItemCalled = false
    callbackSendNextItemValue = ''
    callbackFailedResponseCalled = false
    callbackFailedResponseFailedCount = 0
}


/**
 * Callback implementation for SendNextItem
 */
define_function NAVDevicePriorityQueueSendNextItemEventCallback(char item[]) {
    callbackSendNextItemCalled = true
    callbackSendNextItemValue = item
}


/**
 * Callback implementation for FailedResponse
 */
define_function NAVDevicePriorityQueueFailedResponseEventCallback(_NAVDevicePriorityQueue queue) {
    callbackFailedResponseCalled = true
    callbackFailedResponseFailedCount = queue.FailedCount
}


#END_IF  // End of callback implementations
