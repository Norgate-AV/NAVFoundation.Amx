PROGRAM_NAME='NAVFoundation.Queue.axi'

#IF_NOT_DEFINED __NAV_FOUNDATION_QUEUE__
#DEFINE __NAV_FOUNDATION_QUEUE__

#include 'NAVFoundation.Queue.h.axi'


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

define_function NAVQueueInit(_NAVQueue queue, integer capacity) {
    stack_var integer x

    if (capacity <= 0 || capacity > NAV_MAX_QUEUE_ITEMS) {
        capacity = NAV_MAX_QUEUE_ITEMS
    }

    queue.Capacity = capacity
    queue.Head = 0
    queue.Tail = capacity

    set_length_array(queue.Items, capacity)

    for (x = 1; x <= length_array(queue.Items); x++) {
        queue.Items[x] = "NAV_NULL"
    }
}


define_function integer NAVQueueEnqueue(_NAVQueue queue, char item[]) {
    if (NAVQueueIsFull(queue)) {
        NAVLog("'NAVQueueEnqueue(): Queue is full. Cannot enqueue item.'")
        return false
    }

    queue.Tail = (queue.Tail + 1) % queue.Capacity
    queue.Count++

    queue.Items[queue.Tail] = item

    return true
}


define_function char[NAV_MAX_BUFFER] NAVQueueDequeue(_NAVQueue queue) {
    stack_var char item[NAV_MAX_BUFFER]

    if (NAVQueueIsEmpty(queue)) {
        return "NAV_NULL"
    }

    queue.Head = (queue.Head + 1) % queue.Capacity
    queue.Count--

    item = queue.Items[queue.Head]

    return item
}


define_function integer NAVQueueIsEmpty(_NAVQueue queue) {
    return (queue.Count == 0)
}


define_function integer NAVQueueHasItems(_NAVQueue queue) {
    return (queue.Count > 0)
}


define_function integer NAVQueueIsFull(_NAVQueue queue) {
    return (queue.Count == queue.Capacity)
}


define_function integer NAVQueueGetCount(_NAVQueue queue) {
    return queue.Count
}


define_function integer NAVQueueGetCapacity(_NAVQueue queue) {
    return length_array(queue.Items)
}


define_function char[NAV_MAX_BUFFER] NAVQueuePeek(_NAVQueue queue) {
    if (NAVQueueIsEmpty(queue)) {
        return "NAV_NULL"
    }

    return queue.Items[(queue.Head + 1) % queue.Capacity]
}


#END_IF // __NAV_FOUNDATION_QUEUE__
