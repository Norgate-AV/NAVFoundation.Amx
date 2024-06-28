PROGRAM_NAME='NAVFoundation.DevicePriorityQueue'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

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

#include 'NAVFoundation.DevicePriorityQueue.h.axi'
#include 'NAVFoundation.Queue.axi'


// #DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK
// define_function NAVDevicePriorityQueueSendNextItemEventCallback(char item[]) {}

// #DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK
// define_function NAVDevicePriorityQueueFailedResponseEventCallback(_NAVDevicePriorityQueue queue) {}


DEFINE_VARIABLE

volatile _NAVDevicePriorityQueue priorityQueue


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function integer NAVDevicePriorityQueueIsEmpty(_NAVDevicePriorityQueue queue) {
    return (NAVQueueIsEmpty(queue.CommandQueue) && NAVQueueIsEmpty(queue.QueryQueue))
}


define_function integer NAVDevicePriorityQueueHasItems(_NAVDevicePriorityQueue queue) {
    return (NAVQueueHasItems(queue.CommandQueue) || NAVQueueHasItems(queue.QueryQueue))
}


define_function char[NAV_MAX_BUFFER] NAVDevicePriorityQueueGetLastMessage(_NAVDevicePriorityQueue queue) {
    return queue.LastMessage
}


define_function NAVDevicePriorityQueueEnqueue(_NAVDevicePriorityQueue queue, char item[], integer priority) {
    stack_var integer queueWasEmpty

    queueWasEmpty = (NAVDevicePriorityQueueIsEmpty(queue) && !queue.Busy)

    switch (priority) {
        case true: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                        __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE__,
                                        'NAVDevicePriorityQueueEnqueue',
                                        "'Enqueuing item in CommandQueue: ', item")

            NAVQueueEnqueue(queue.CommandQueue, item)
        }
        case false: {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                        __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE__,
                                        'NAVDevicePriorityQueueEnqueue',
                                        "'Enqueuing item in QueryQueue: ', item")

            NAVQueueEnqueue(queue.QueryQueue, item)
        }
    }

    if (!queueWasEmpty) {
        return
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE__,
                                'NAVDevicePriorityQueueEnqueue',
                                "'Queue was empty. Item being dequeued immediately'")

    NAVDevicePriorityQueueSendNextItem(queue)
}


define_function char[NAV_MAX_BUFFER] NAVDevicePriorityQueueDequeue(_NAVDevicePriorityQueue queue) {
    if (!NAVDevicePriorityQueueHasItems(queue)) {
        return ""
    }

    if (queue.Busy) {
        return ""
    }

    queue.Busy = true

    if (NAVQueueHasItems(queue.CommandQueue)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                    __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE__,
                                    'NAVDevicePriorityQueueEnqueue',
                                    "'Dequeueing item from CommandQueue'")

        queue.LastMessage = NAVQueueDequeue(queue.CommandQueue)
        return queue.LastMessage
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE__,
                                'NAVDevicePriorityQueueEnqueue',
                                "'Dequeueing item from QueryQueue'")

    queue.LastMessage = NAVQueueDequeue(queue.QueryQueue)
    return queue.LastMessage
}


define_function NAVDevicePriorityQueueGoodResponse(_NAVDevicePriorityQueue queue) {
    queue.Busy = false

    NAVTimelineStop(queue.FailedResponseTimeline.Id)

    queue.FailedCount = 0
    queue.Resend = false

    NAVDevicePriorityQueueSendNextItem(queue)
}


define_function NAVDevicePriorityQueueSendNextItem(_NAVDevicePriorityQueue queue) {
    stack_var char item[NAV_MAX_BUFFER]

    if (queue.Resend) {
        queue.Resend = false
        item = queue.LastMessage
    }
    else {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                    __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE__,
                                    'NAVDevicePriorityQueueEnqueue',
                                    "'Attempting to dequeue next item'")

        item = NAVDevicePriorityQueueDequeue(queue)
    }

    if (!length_array(item)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                    __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE__,
                                    'NAVDevicePriorityQueueEnqueue',
                                    "'No items to send. Queue is empty'")

        return
    }

    #IF_DEFINED USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_DEBUG,
                                __NAV_FOUNDATION_DEVICE_PRIORITY_QUEUE__,
                                'NAVDevicePriorityQueueEnqueue',
                                "'Invoking callback: ', item")

    NAVDevicePriorityQueueSendNextItemEventCallback(item)
    NAVTimelineStart(queue.FailedResponseTimeline.Id, queue.FailedResponseTimeline.Time, TIMELINE_ABSOLUTE, TIMELINE_ONCE)
    #END_IF
}


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


DEFINE_START {
    NAVDevicePriorityQueueInit(priorityQueue)
}


DEFINE_EVENT

timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
    NAVDevicePriorityQueueFailedResponse(priorityQueue)
}


#END_IF  // __NAV_FOUNDATION_DEVICE_COMMAND_QUEUE__
