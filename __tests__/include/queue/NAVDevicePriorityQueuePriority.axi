PROGRAM_NAME='NAVDevicePriorityQueuePriority'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char DPQ_PRIORITY_TEST_COMMANDS[][50] = {
    'POWER=ON',
    'INPUT=HDMI1',
    'VOLUME=50',
    'MUTE=ON',
    'POWER=OFF'
}

constant char DPQ_PRIORITY_TEST_QUERIES[][50] = {
    '?POWER',
    '?INPUT',
    '?VOLUME',
    '?MUTE',
    '?STATUS'
}

constant integer NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND = true
constant integer NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY = false


/**
 * Test enqueuing commands (high priority)
 */
define_function TestNAVDevicePriorityQueueEnqueueCommands() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var integer i

    NAVLog("'***************** TestNAVDevicePriorityQueueEnqueueCommands *****************'")

    NAVDevicePriorityQueueInit(queue)

    // Set busy to prevent auto-send on first enqueue
    queue.Busy = true

    // Enqueue multiple commands
    for (i = 1; i <= 3; i++) {
        NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_COMMANDS[i], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    }

    if (!NAVAssertIntegerEqual('Command queue should have 3 items', 3, NAVQueueGetCount(queue.CommandQueue))) {
        NAVLogTestFailed(1, itoa(3), itoa(NAVQueueGetCount(queue.CommandQueue)))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Query queue should be empty', 0, NAVQueueGetCount(queue.QueryQueue))) {
        NAVLogTestFailed(2, itoa(0), itoa(NAVQueueGetCount(queue.QueryQueue)))
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test enqueuing queries (low priority)
 */
define_function TestNAVDevicePriorityQueueEnqueueQueries() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var integer i

    NAVLog("'***************** TestNAVDevicePriorityQueueEnqueueQueries *****************'")

    NAVDevicePriorityQueueInit(queue)

    // Set busy to prevent auto-send on first enqueue
    queue.Busy = true

    // Enqueue multiple queries
    for (i = 1; i <= 3; i++) {
        NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_QUERIES[i], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
    }

    if (!NAVAssertIntegerEqual('Query queue should have 3 items', 3, NAVQueueGetCount(queue.QueryQueue))) {
        NAVLogTestFailed(1, itoa(3), itoa(NAVQueueGetCount(queue.QueryQueue)))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Command queue should be empty', 0, NAVQueueGetCount(queue.CommandQueue))) {
        NAVLogTestFailed(2, itoa(0), itoa(NAVQueueGetCount(queue.CommandQueue)))
    }
    else {
        NAVLogTestPassed(2)
    }
}


/**
 * Test priority ordering - commands should be processed before queries
 */
define_function TestNAVDevicePriorityQueuePriorityOrdering() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVDevicePriorityQueuePriorityOrdering *****************'")

    NAVDevicePriorityQueueInit(queue)

    // Set busy to prevent auto-send on first enqueue
    queue.Busy = true

    // Add queries first
    NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_QUERIES[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_QUERIES[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)

    // Then add commands
    NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

    // Mark as not busy so we can dequeue
    queue.Busy = false

    // First dequeue should return first command, not first query
    result = NAVDevicePriorityQueueDequeue(queue)
    if (!NAVAssertStringEqual('First dequeue should return first command', DPQ_PRIORITY_TEST_COMMANDS[1], result)) {
        NAVLogTestFailed(1, DPQ_PRIORITY_TEST_COMMANDS[1], result)
    }
    else {
        NAVLogTestPassed(1)
    }

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)
    if (!NAVAssertStringEqual('Second dequeue should return second command', DPQ_PRIORITY_TEST_COMMANDS[2], result)) {
        NAVLogTestFailed(2, DPQ_PRIORITY_TEST_COMMANDS[2], result)
    }
    else {
        NAVLogTestPassed(2)
    }

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)
    if (!NAVAssertStringEqual('Third dequeue should return first query', DPQ_PRIORITY_TEST_QUERIES[1], result)) {
        NAVLogTestFailed(3, DPQ_PRIORITY_TEST_QUERIES[1], result)
    }
    else {
        NAVLogTestPassed(3)
    }

    queue.Busy = false
    result = NAVDevicePriorityQueueDequeue(queue)
    if (!NAVAssertStringEqual('Fourth dequeue should return second query', DPQ_PRIORITY_TEST_QUERIES[2], result)) {
        NAVLogTestFailed(4, DPQ_PRIORITY_TEST_QUERIES[2], result)
    }
    else {
        NAVLogTestPassed(4)
    }
}


/**
 * Test mixed commands and queries
 */
define_function TestNAVDevicePriorityQueueMixedOperations() {
    stack_var _NAVDevicePriorityQueue queue
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVDevicePriorityQueueMixedOperations *****************'")

    NAVDevicePriorityQueueInit(queue)

    // Set busy to prevent auto-send on first enqueue
    queue.Busy = true

    // Mix of commands and queries
    NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_QUERIES[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_COMMANDS[1], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_QUERIES[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_COMMANDS[2], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(queue, DPQ_PRIORITY_TEST_QUERIES[3], NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)

    if (!NAVAssertIntegerEqual('Command queue should have 2 items', 2, NAVQueueGetCount(queue.CommandQueue))) {
        NAVLogTestFailed(1, itoa(2), itoa(NAVQueueGetCount(queue.CommandQueue)))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Query queue should have 3 items', 3, NAVQueueGetCount(queue.QueryQueue))) {
        NAVLogTestFailed(2, itoa(3), itoa(NAVQueueGetCount(queue.QueryQueue)))
    }
    else {
        NAVLogTestPassed(2)
    }

    if (!NAVAssertIntegerEqual('HasItems should return true', true, NAVDevicePriorityQueueHasItems(queue))) {
        NAVLogTestFailed(3, itoa(true), itoa(NAVDevicePriorityQueueHasItems(queue)))
    }
    else {
        NAVLogTestPassed(3)
    }
}
