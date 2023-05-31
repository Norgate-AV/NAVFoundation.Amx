DEFINE_VARIABLE

volatile _NAVQueue queue


define_function TestQueue(_NAVQueue queue) {
    stack_var integer x
    stack_var integer capacity
    stack_var integer count

    NAVLog('Initializing queue...')
    NAVQueueInit(queue, 100)

    NAVLog('Enqueuing items to queue...')
    NAVQueueEnqueue(queue, 'Item 1')
    NAVQueueEnqueue(queue, 'Item 2')
    NAVQueueEnqueue(queue, 'Item 3')
    NAVQueueEnqueue(queue, 'Item 4')
    NAVQueueEnqueue(queue, 'Item 5')
    NAVQueueEnqueue(queue, 'Item 6')
    NAVQueueEnqueue(queue, 'Item 7')
    NAVQueueEnqueue(queue, 'Item 8')
    NAVQueueEnqueue(queue, 'Item 9')
    NAVQueueEnqueue(queue, 'Item 10')

    NAVLog('Peeking queue...')
    NAVLog("'Peek: ', NAVQueuePeek(queue)")

    capacity = NAVQueueGetCapacity(queue)
    NAVLog("'Queue capacity: ', itoa(capacity)")

    count = NAVQueueGetCount(queue)
    NAVLog("'Items in queue: ', itoa(count)")

    NAVLog('Dequeuing items from queue...')
    while (NAVQueueHasItems(queue)) {
        NAVLog("'Dequeue: ', NAVQueueDequeue(queue)")
        NAVLog("'Items in queue: ', itoa(NAVQueueGetCount(queue))")
    }
}
