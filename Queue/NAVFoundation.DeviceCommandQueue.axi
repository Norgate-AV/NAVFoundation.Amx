PROGRAM_NAME='NAVFoundation.DeviceCommandQueue'

#IF_NOT_DEFINED __NAV_FOUNDATION_DEVICE_COMMAND_QUEUE__
#DEFINE __NAV_FOUNDATION_DEVICE_COMMAND_QUEUE__

#include 'NAVFoundation.DeviceCommandQueue.h.axi'
#include 'NAVFoundation.Queue.axi'


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function NAVPriorityQueueIsEmpty(_NAVPriorityQueue queue) {
    return (!NAVQueueIsEmpty(queue.Command) && !NAVQueueIsEmpty(queue.Status))
}


define_function NAVPriorityQueueEnqueue(_NAVPriorityQueue queue, char value[], integer priority) {
    stack_var integer queueWasEmpty

    queueWasEmpty = (NAVPriorityQueueIsEmpty(queue) && !queue.Busy)

    switch (priority) {
        case true: {
            NAVQueueEnqueue(queue.CommandQueue, value)
        }
        case false: {
            NAVQueueEnqueue(queue.StatusQueue, value)
        }
    }


    //#IF_DEFINED
    //if (iQueueWasEmpty) { SendNextQueueItem(); }
}

define_function char[NAV_MAX_BUFFER] NAVPriorotyQueueDequeue(_NAVPriorityQueue queue) {
    if (!queue.HasItems) {
        return ""
    }

    if (queue.Busy) {
        return ""
    }

    queue.Busy = true

    // select {
    //     active (uQueue.iCommandHead != uQueue.iCommandTail): {
    //         if (uQueue.iCommandTail == max_length_array(cCommandQueue)) {
    //             uQueue.iCommandTail = 1
    //         }
    //         else {
    //             uQueue.iCommandTail++
    //         }

    //         uQueue.cLastMess = cCommandQueue[uQueue.iCommandTail]
    //     }
    //     active (uQueue.iStatusHead != uQueue.iStatusTail): {
    //         if (uQueue.iStatusTail == max_length_array(cStatusQueue)) {
    //             uQueue.iStatusTail = 1
    //         }
    //         else {
    //             uQueue.iStatusTail++
    //         }

    //         uQueue.cLastMess = cStatusQueue[uQueue.iStatusTail]
    //     }
    // }

    // if ((uQueue.iCommandHead == uQueue.iCommandTail) && (uQueue.iStatusHead == uQueue.iStatusTail)) {
    //     uQueue.iHasItems = FALSE
    // }

    return queue.LastMessage
}

define_function NAVPriorityQueueGoodResponse(_NAVPriorityQueue queue) {
    queue.Busy = false

    NAVTimelineStop(queue.TimelineId)

    queue.FailedCount = 0
    queue.Resend = false

    NAVPriorityQueueSendNextItem(queue)
}


define_function NAVPriorityQueueSendNextItem(_NAVPriorityQueue queue) {
    stack_var char item[NAV_MAX_BUFFER]

    if (queue.Resend) {
        queue.Resend = false
        item = queue.LastMessage
    }
    else {
        item = NAVPriorityQueueDequeue(queue)
    }

    if (!length_array(item)) {
        return
    }

    //SendString(item)
    //NAVTimelineStart(TL_QUEUE_FAILED_RESPONSE, ltQueueFailedResponse, TIMELINE_ABSOLUTE, TIMELINE_ONCE)
}


define_function NAVPriorityQueueInit(_NAVPriorityQueue queue) {
    queue.Busy = false
    queue.FailedCount = 0
    queue.Resend = false
    queue.LastMessage = ""
    NAVQueueInit(queue.Command)
    NAVQueueInit(queue.Status)
}

#END_IF  // __NAV_FOUNDATION_DEVICE_COMMAND_QUEUE__
