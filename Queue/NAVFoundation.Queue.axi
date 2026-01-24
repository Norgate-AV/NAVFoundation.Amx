PROGRAM_NAME='NAVFoundation.Queue'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_QUEUE__
#DEFINE __NAV_FOUNDATION_QUEUE__ 'NAVFoundation.Queue'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.Queue.h.axi'


(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)

/**
 * @function NAVQueueInit
 * @public
 * @description Initialize a queue with the specified capacity. The queue uses a circular
 *              buffer implementation for efficient FIFO (First In, First Out) operations.
 *              This function must be called before using any other queue operations.
 *              The capacity parameter is copied internally to support constant values.
 *
 * @param {_NAVQueue} queue - The queue structure to initialize
 * @param {integer} initCapacity - The maximum number of items the queue can hold.
 *                                 If initCapacity is <= 0 or > NAV_MAX_QUEUE_ITEMS,
 *                                 it will be set to NAV_MAX_QUEUE_ITEMS
 *
 * @example
 * stack_var _NAVQueue myQueue
 * NAVQueueInit(myQueue, 100)  // Initialize queue with capacity of 100 items
 */
define_function NAVQueueInit(_NAVQueue queue, integer initCapacity) {
    stack_var integer x
    stack_var integer capacity

    // Make a copy in case a constant is passed
    capacity = initCapacity

    if (capacity <= 0 || capacity > NAV_MAX_QUEUE_ITEMS) {
        capacity = NAV_MAX_QUEUE_ITEMS
    }

    queue.Capacity = capacity
    queue.Head = 0
    queue.Tail = capacity
    queue.Count = 0

    set_length_array(queue.Items, capacity)

    for (x = 1; x <= length_array(queue.Items); x++) {
        queue.Items[x] = "NAV_NULL"
    }
}


/**
 * @function NAVQueueEnqueue
 * @public
 * @description Add an item to the rear of the queue. If the queue is full,
 *              the operation will fail and log a warning message.
 *
 * @param {_NAVQueue} queue - The queue to add the item to
 * @param {char[]} item - The item string to add to the queue
 *
 * @returns {integer} True (1) if the item was successfully added,
 *                    False (0) if the queue is full
 *
 * @example
 * stack_var _NAVQueue myQueue
 * NAVQueueInit(myQueue, 10)
 * if (NAVQueueEnqueue(myQueue, 'new_item')) {
 *     // Item successfully added
 * }
 */
define_function integer NAVQueueEnqueue(_NAVQueue queue, char item[]) {
    if (NAVQueueIsFull(queue)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_QUEUE__,
                                    'NAVQueueEnqueue',
                                    "'Queue is full. Cannot enqueue item'")
        return false
    }

    queue.Tail = (queue.Tail % queue.Capacity) + 1
    queue.Count++
    queue.Items[queue.Tail] = item

    return true
}


/**
 * @function NAVQueueDequeue
 * @public
 * @description Remove and return the item from the front of the queue.
 *              This follows FIFO (First In, First Out) ordering.
 *
 * @param {_NAVQueue} queue - The queue to remove the item from
 *
 * @returns {char[]} The item from the front of the queue,
 *                   or NAV_NULL if the queue is empty
 *
 * @example
 * stack_var _NAVQueue myQueue
 * stack_var char item[NAV_MAX_BUFFER]
 *
 * item = NAVQueueDequeue(myQueue)
 * if (item != NAV_NULL) {
 *     // Process the item
 * }
 */
define_function char[NAV_MAX_BUFFER] NAVQueueDequeue(_NAVQueue queue) {
    stack_var char item[NAV_MAX_BUFFER]

    if (NAVQueueIsEmpty(queue)) {
        return "NAV_NULL"
    }

    queue.Head = (queue.Head % queue.Capacity) + 1
    queue.Count--

    item = queue.Items[queue.Head]
    queue.Items[queue.Head] = "NAV_NULL"  // Clear the item after dequeuing

    return item
}


/**
 * @function NAVQueueIsEmpty
 * @public
 * @description Check if the queue contains no items.
 *
 * @param {_NAVQueue} queue - The queue to check
 *
 * @returns {char} True (1) if the queue is empty, False (0) if it contains items
 *
 * @example
 * if (NAVQueueIsEmpty(myQueue)) {
 *     // Queue is empty
 * }
 */
define_function char NAVQueueIsEmpty(_NAVQueue queue) {
    return (queue.Count == 0)
}


/**
 * @function NAVQueueHasItems
 * @public
 * @description Check if the queue contains one or more items.
 *
 * @param {_NAVQueue} queue - The queue to check
 *
 * @returns {char} True (1) if the queue has items, False (0) if it is empty
 *
 * @example
 * if (NAVQueueHasItems(myQueue)) {
 *     // Process queue items
 * }
 */
define_function char NAVQueueHasItems(_NAVQueue queue) {
    return (queue.Count > 0)
}


/**
 * @function NAVQueueIsFull
 * @public
 * @description Check if the queue has reached its maximum capacity.
 *
 * @param {_NAVQueue} queue - The queue to check
 *
 * @returns {char} True (1) if the queue is full, False (0) if there is space available
 *
 * @example
 * if (!NAVQueueIsFull(myQueue)) {
 *     NAVQueueEnqueue(myQueue, 'new_item')
 * }
 */
define_function char NAVQueueIsFull(_NAVQueue queue) {
    return (queue.Count == queue.Capacity)
}


/**
 * @function NAVQueueGetCount
 * @public
 * @description Get the current number of items in the queue.
 *
 * @param {_NAVQueue} queue - The queue to query
 *
 * @returns {integer} The number of items currently in the queue (0 to capacity)
 *
 * @example
 * stack_var integer count
 * count = NAVQueueGetCount(myQueue)
 * NAVLog("'Queue has ', itoa(count), ' items'")
 */
define_function integer NAVQueueGetCount(_NAVQueue queue) {
    return queue.Count
}


/**
 * @function NAVQueueGetCapacity
 * @public
 * @description Get the maximum number of items the queue can hold.
 *
 * @param {_NAVQueue} queue - The queue to query
 *
 * @returns {integer} The maximum capacity of the queue
 *
 * @example
 * stack_var integer capacity
 * capacity = NAVQueueGetCapacity(myQueue)
 * NAVLog("'Queue capacity: ', itoa(capacity)")
 */
define_function integer NAVQueueGetCapacity(_NAVQueue queue) {
    return length_array(queue.Items)
}


/**
 * @function NAVQueuePeek
 * @public
 * @description View the item at the front of the queue without removing it.
 *              This allows inspection of the next item to be dequeued.
 *
 * @param {_NAVQueue} queue - The queue to peek at
 *
 * @returns {char[]} The item at the front of the queue,
 *                   or NAV_NULL if the queue is empty
 *
 * @example
 * stack_var char nextItem[NAV_MAX_BUFFER]
 * nextItem = NAVQueuePeek(myQueue)
 * if (nextItem != NAV_NULL) {
 *     NAVLog("'Next item to process: ', nextItem")
 * }
 */
define_function char[NAV_MAX_BUFFER] NAVQueuePeek(_NAVQueue queue) {
    if (NAVQueueIsEmpty(queue)) {
        return "NAV_NULL"
    }

    return queue.Items[(queue.Head + 1) % queue.Capacity]
}


/**
 * @function NAVQueueClear
 * @public
 * @description Remove all items from the queue and reset it to empty state.
 *              This operation resets the head, tail, and count but maintains
 *              the original capacity.
 *
 * @param {_NAVQueue} queue - The queue to clear
 *
 * @example
 * NAVQueueClear(myQueue)
 * // Queue is now empty and ready for reuse
 */
define_function NAVQueueClear(_NAVQueue queue) {
    stack_var integer x

    for (x = 1; x <= queue.Capacity; x++) {
        queue.Items[x] = "NAV_NULL"
    }

    queue.Head = 0
    queue.Tail = queue.Capacity
    queue.Count = 0
}

/**
 * @function NAVQueueContains
 * @public
 * @description Check if a specific item exists anywhere in the queue.
 *              This performs a linear search through all items in the queue.
 *
 * @param {_NAVQueue} queue - The queue to search
 * @param {char[]} item - The item string to search for
 *
 * @returns {char} True (1) if the item is found in the queue,
 *                 False (0) if not found or queue is empty
 *
 * @example
 * if (NAVQueueContains(myQueue, 'target_item')) {
 *     NAVLog("'Item found in queue'")
 * }
 */
define_function char NAVQueueContains(_NAVQueue queue, char item[]) {
    stack_var integer i
    stack_var integer index

    if (NAVQueueIsEmpty(queue)) {
        return false
    }

    for (i = 1; i <= queue.Count; i++) {
        index = (queue.Head + i) % queue.Capacity
        if (index == 0) { index = queue.Capacity }

        if (queue.Items[index] == item) {
            return true
        }
    }

    return false
}

/**
 * @function NAVQueueToString
 * @public
 * @description Generate a human-readable string representation of the queue
 *              showing its current state and contents in FIFO order.
 *
 * @param {_NAVQueue} queue - The queue to convert to string
 *
 * @returns {char[]} A formatted string showing queue count, capacity, and items
 *                   Format: "Queue [count/capacity]: item1, item2, item3" or
 *                          "Queue [0/capacity]: empty" for empty queue
 *
 * @example
 * stack_var char queueState[NAV_MAX_BUFFER]
 * queueState = NAVQueueToString(myQueue)
 * NAVLog("'Queue state: ', queueState")
 * // Output: "Queue [3/10]: first, second, third"
 */
define_function char[NAV_MAX_BUFFER] NAVQueueToString(_NAVQueue queue) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer index

    result = "'Queue [', itoa(queue.Count), '/', itoa(queue.Capacity), ']: '"

    if (NAVQueueIsEmpty(queue)) {
        result = "result, 'empty'"
        return result
    }

    for (i = 1; i <= queue.Count; i++) {
        index = (queue.Head + i) % queue.Capacity
        if (index == 0) { index = queue.Capacity }

        result = "result, queue.Items[index]"
        if (i < queue.Count) {
            result = "result, ', '"
        }
    }

    return result
}

#END_IF // __NAV_FOUNDATION_QUEUE__
