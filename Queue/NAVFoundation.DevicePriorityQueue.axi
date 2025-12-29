PROGRAM_NAME='NAVFoundation.DevicePriorityQueue'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE__
#DEFINE __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE__ 'NAVFoundation.DevicePriorityQueue'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.Queue.axi'
#include 'NAVFoundation.TimelineUtils.axi'
#include 'NAVFoundation.DevicePriorityQueue.h.axi'


// #DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK
// define_function NAVDevicePriorityQueueSendNextItemEventCallback(char item[]) {}

// #DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK
// define_function NAVDevicePriorityQueueFailedResponseEventCallback(_NAVDevicePriorityQueue queue) {}

// !!! If you define the above callback, you MUST also define the event below in your main .axs file !!!

// DEFINE_EVENT

// timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
//     NAVDevicePriorityQueueFailedResponse(queue)  <-- MUST MATCH THE VARIABLE NAME DECLARED FOR THE QUEUE
// }


/**
 * @function NAVDevicePriorityQueueIsEmpty
 * @public
 * @description Checks if both the command and query queues are empty.
 * @param {_NAVDevicePriorityQueue} queue - The device priority queue to check
 * @returns {integer} Returns true (1) if both queues are empty, false (0) otherwise
 * @example
 * _NAVDevicePriorityQueue deviceQueue
 * if (NAVDevicePriorityQueueIsEmpty(deviceQueue)) {
 *     // Both queues are empty
 * }
 */
define_function integer NAVDevicePriorityQueueIsEmpty(_NAVDevicePriorityQueue queue) {
    return (NAVQueueIsEmpty(queue.CommandQueue) && NAVQueueIsEmpty(queue.QueryQueue))
}


/**
 * @function NAVDevicePriorityQueueHasItems
 * @public
 * @description Checks if either the command or query queue has items.
 * @param {_NAVDevicePriorityQueue} queue - The device priority queue to check
 * @returns {integer} Returns true (1) if either queue has items, false (0) otherwise
 * @example
 * _NAVDevicePriorityQueue deviceQueue
 * if (NAVDevicePriorityQueueHasItems(deviceQueue)) {
 *     // At least one queue has items
 * }
 */
define_function integer NAVDevicePriorityQueueHasItems(_NAVDevicePriorityQueue queue) {
    return (NAVQueueHasItems(queue.CommandQueue) || NAVQueueHasItems(queue.QueryQueue))
}


/**
 * @function NAVDevicePriorityQueueGetLastMessage
 * @public
 * @description Retrieves the last message that was dequeued and sent.
 * @param {_NAVDevicePriorityQueue} queue - The device priority queue
 * @returns {char[NAV_MAX_BUFFER]} Returns the last message that was sent
 * @example
 * _NAVDevicePriorityQueue deviceQueue
 * char lastMsg[NAV_MAX_BUFFER]
 * lastMsg = NAVDevicePriorityQueueGetLastMessage(deviceQueue)
 */
define_function char[NAV_MAX_BUFFER] NAVDevicePriorityQueueGetLastMessage(_NAVDevicePriorityQueue queue) {
    return queue.LastMessage
}


/**
 * @function NAVDevicePriorityQueueEnqueue
 * @public
 * @description Adds an item to either the command queue (high priority) or query queue (low priority).
 *              If queue was empty before enqueuing, automatically sends the next item.
 * @param {_NAVDevicePriorityQueue} queue - The device priority queue
 * @param {char[]} item - The item to add to the queue
 * @param {integer} priority - Priority level (NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND for high, NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY for low)
 * @returns {void}
 * @example
 * _NAVDevicePriorityQueue deviceQueue
 * // Add a high-priority command
 * NAVDevicePriorityQueueEnqueue(deviceQueue, 'POWER=ON', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
 * // Add a low-priority query
 * NAVDevicePriorityQueueEnqueue(deviceQueue, '?POWER', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
 */
define_function NAVDevicePriorityQueueEnqueue(_NAVDevicePriorityQueue queue, char item[], integer priority) {
    stack_var integer queueWasEmpty

    queueWasEmpty = (NAVDevicePriorityQueueIsEmpty(queue) && !queue.Busy)

    switch (priority) {
        case true: {
            NAVQueueEnqueue(queue.CommandQueue, item)
        }
        case false: {
            NAVQueueEnqueue(queue.QueryQueue, item)
        }
    }

    if (!queueWasEmpty) {
        return
    }

    NAVDevicePriorityQueueSendNextItem(queue)
}


/**
 * @function NAVDevicePriorityQueueDequeue
 * @public
 * @description Removes and returns the next item, prioritizing command queue over query queue.
 *              Marks the queue as busy and stores the last message. Returns empty string if already busy or empty.
 * @param {_NAVDevicePriorityQueue} queue - The device priority queue
 * @returns {char[NAV_MAX_BUFFER]} Returns the next item (command queue first, then query queue), or empty string if busy/empty
 * @example
 * _NAVDevicePriorityQueue deviceQueue
 * char nextCommand[NAV_MAX_BUFFER]
 * nextCommand = NAVDevicePriorityQueueDequeue(deviceQueue)
 * if (length_array(nextCommand)) {
 *     // Send the command
 * }
 */
define_function char[NAV_MAX_BUFFER] NAVDevicePriorityQueueDequeue(_NAVDevicePriorityQueue queue) {
    if (!NAVDevicePriorityQueueHasItems(queue)) {
        return ""
    }

    if (queue.Busy) {
        return ""
    }

    queue.Busy = true

    if (NAVQueueHasItems(queue.CommandQueue)) {
        queue.LastMessage = NAVQueueDequeue(queue.CommandQueue)
        return queue.LastMessage
    }

    queue.LastMessage = NAVQueueDequeue(queue.QueryQueue)
    return queue.LastMessage
}


/**
 * @function NAVDevicePriorityQueueGoodResponse
 * @public
 * @description Called when a good response is received from the device. Marks queue as not busy,
 *              stops the failed response timeline, resets failure count, and sends the next item.
 * @param {_NAVDevicePriorityQueue} queue - The device priority queue
 * @returns {void}
 * @example
 * _NAVDevicePriorityQueue deviceQueue
 * // When device responds successfully
 * NAVDevicePriorityQueueGoodResponse(deviceQueue)
 */
define_function NAVDevicePriorityQueueGoodResponse(_NAVDevicePriorityQueue queue) {
    queue.Busy = false

    NAVTimelineStop(queue.FailedResponseTimeline.Id)

    queue.FailedCount = 0
    queue.Resend = false

    NAVDevicePriorityQueueSendNextItem(queue)
}


/**
 * @function NAVDevicePriorityQueueSendNextItem
 * @public
 * @description Sends the next item from the queue. If resend flag is set, resends the last message,
 *              otherwise dequeues the next item. Triggers callback and starts failed response timeline.
 * @param {_NAVDevicePriorityQueue} queue - The device priority queue
 * @returns {void}
 * @example
 * _NAVDevicePriorityQueue deviceQueue
 * NAVDevicePriorityQueueSendNextItem(deviceQueue)
 */
define_function NAVDevicePriorityQueueSendNextItem(_NAVDevicePriorityQueue queue) {
    stack_var char item[NAV_MAX_BUFFER]

    if (queue.Resend) {
        queue.Resend = false
        item = queue.LastMessage
    }
    else {
        item = NAVDevicePriorityQueueDequeue(queue)
    }

    if (!length_array(item)) {
        return
    }

    #IF_DEFINED USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK
    NAVDevicePriorityQueueSendNextItemEventCallback(item)
    #END_IF

    #IF_DEFINED USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK
    NAVTimelineStart(queue.FailedResponseTimeline.Id,
                        queue.FailedResponseTimeline.Time,
                        TIMELINE_ABSOLUTE,
                        TIMELINE_ONCE)
    #END_IF
}


/**
 * @function NAVDevicePriorityQueueFailedResponse
 * @public
 * @description Called when a device fails to respond. Increments failure count and retries up to
 *              MaxFailedCount. If max failures reached, triggers callback and reinitializes queue.
 * @param {_NAVDevicePriorityQueue} queue - The device priority queue
 * @returns {void}
 * @example
 * _NAVDevicePriorityQueue deviceQueue
 * // When device fails to respond (in timeline event)
 * NAVDevicePriorityQueueFailedResponse(deviceQueue)
 */
define_function NAVDevicePriorityQueueFailedResponse(_NAVDevicePriorityQueue queue) {
    if (!queue.Busy) {
        return
    }

    if (queue.FailedCount < queue.MaxFailedCount) {
        queue.FailedCount++
        queue.Resend = true

        NAVDevicePriorityQueueSendNextItem(queue)

        return
    }

    #IF_DEFINED USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK
    NAVDevicePriorityQueueFailedResponseEventCallback(queue)
    #END_IF

    NAVDevicePriorityQueueInit(queue)
}


/**
 * @function NAVDevicePriorityQueueInit
 * @public
 * @description Initializes a device priority queue with default settings. Sets up both command
 *              and query queues, configures the failed response timeline, and resets all state flags.
 * @param {_NAVDevicePriorityQueue} queue - The device priority queue to initialize
 * @returns {void}
 * @example
 * _NAVDevicePriorityQueue deviceQueue
 * NAVDevicePriorityQueueInit(deviceQueue)
 */
define_function NAVDevicePriorityQueueInit(_NAVDevicePriorityQueue queue) {
    queue.Busy = false
    queue.FailedCount = 0
    queue.MaxFailedCount = NAV_DEVICE_PRIORITY_QUEUE_MAX_FAILED_RESPONSE_COUNT
    queue.Resend = false
    queue.LastMessage = ""

    queue.FailedResponseTimeline.Id = TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE
    queue.FailedResponseTimeline.Time[1] = TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_TIME
    set_length_array(queue.FailedResponseTimeline.Time, 1)

    NAVQueueInit(queue.CommandQueue, NAV_DEVICE_PRIORITY_QUEUE_COMMAND_QUEUE_SIZE)
    NAVQueueInit(queue.QueryQueue, NAV_DEVICE_PRIORITY_QUEUE_QUERY_QUEUE_SIZE)
}


#END_IF  // __NAV_FOUNDATION_DEVICE_COMMAND_QUEUE__
