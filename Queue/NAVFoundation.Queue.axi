PROGRAM_NAME='NAVFoundation.Queue'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_QUEUE__
#DEFINE __NAV_FOUNDATION_QUEUE__ 'NAVFoundation.Queue'

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
    queue.Count = 0

    set_length_array(queue.Items, capacity)

    for (x = 1; x <= length_array(queue.Items); x++) {
        queue.Items[x] = "NAV_NULL"
    }
}


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


define_function NAVQueueClear(_NAVQueue queue) {
    stack_var integer x

    for (x = 1; x <= queue.Capacity; x++) {
        queue.Items[x] = "NAV_NULL"
    }

    queue.Head = 0
    queue.Tail = queue.Capacity
    queue.Count = 0
}

define_function integer NAVQueueContains(_NAVQueue queue, char item[]) {
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
