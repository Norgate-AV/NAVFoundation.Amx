# NAVFoundation.Queue

A robust FIFO (First-In-First-Out) queue implementation for AMX NetLinx systems. This library provides a circular buffer-based queue with full state management, boundary checking, and comprehensive utility functions for command buffering, message queuing, and general data sequencing.

## Features

- **Circular Buffer Design**: Efficient memory usage with wrap-around indexing
- **Configurable Capacity**: Support for queues up to 500 items
- **Full State Management**: Empty, full, and count tracking
- **Boundary Checking**: Safe enqueue/dequeue with overflow protection
- **Search Operations**: Check for item existence without dequeuing
- **Debug Support**: Built-in string representation for diagnostics
- **Zero Memory Leaks**: Proper initialization and cleanup
- **Production Ready**: Extensively tested with 38 comprehensive tests

## Quick Start

### Basic Usage

```netlinx
#include 'NAVFoundation.Queue.axi'

stack_var _NAVQueue commandQueue
stack_var char command[NAV_MAX_BUFFER]

// Initialize the queue with capacity
NAVQueueInit(commandQueue, 10)

// Add items to the queue
NAVQueueEnqueue(commandQueue, 'POWER=ON')
NAVQueueEnqueue(commandQueue, 'INPUT=HDMI1')
NAVQueueEnqueue(commandQueue, 'VOLUME=50')

// Check queue state
if (NAVQueueHasItems(commandQueue)) {
    send_string 0, "'Queue has ', itoa(NAVQueueGetCount(commandQueue)), ' items'"
}

// Process items (FIFO order)
command = NAVQueueDequeue(commandQueue)  // Returns 'POWER=ON'
command = NAVQueueDequeue(commandQueue)  // Returns 'INPUT=HDMI1'

// Peek at next item without removing
command = NAVQueuePeek(commandQueue)     // Returns 'VOLUME=50' (still in queue)

// Check if specific item exists
if (NAVQueueContains(commandQueue, 'VOLUME=50')) {
    // Item is in the queue
}

// Clear all items
NAVQueueClear(commandQueue)
```

## Performance Characteristics

### Memory Usage

| Capacity | Memory per Queue | Typical Use Case |
|----------|------------------|------------------|
| 10 items | ~2.5 KB | Command buffering |
| 50 items | ~12.5 KB | Message queuing |
| 100 items | ~25 KB | Event buffering |
| 500 items (max) | ~125 KB | High-volume data |

### Complexity

- **Enqueue**: O(1) constant time
- **Dequeue**: O(1) constant time
- **Peek**: O(1) constant time
- **Contains**: O(n) linear search
- **Clear**: O(1) constant time

## API Reference

### Initialization

#### `NAVQueueInit`
**Purpose**: Initialize a queue with a specified capacity.

**Signature**: `NAVQueueInit(_NAVQueue queue, integer capacity)`

**Parameters**:
- `queue` - Queue structure to initialize
- `capacity` - Maximum number of items (1-500)

**Example**:
```netlinx
stack_var _NAVQueue myQueue
NAVQueueInit(myQueue, 20)  // Queue can hold up to 20 items
```

### Adding Items

#### `NAVQueueEnqueue`
**Purpose**: Add an item to the end of the queue.

**Signature**: `sinteger NAVQueueEnqueue(_NAVQueue queue, char item[NAV_MAX_BUFFER])`

**Parameters**:
- `queue` - Queue to add to
- `item[]` - String item to add (max 4096 characters)

**Returns**: `1` on success, `0` if queue is full

**Example**:
```netlinx
if (NAVQueueEnqueue(myQueue, 'POWER=ON')) {
    // Successfully added
} else {
    // Queue is full
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'Queue is full, cannot add item'")
}
```

### Removing Items

#### `NAVQueueDequeue`
**Purpose**: Remove and return the item at the front of the queue.

**Signature**: `char[NAV_MAX_BUFFER] NAVQueueDequeue(_NAVQueue queue)`

**Parameters**:
- `queue` - Queue to remove from

**Returns**: Front item string, or empty string if queue is empty

**Example**:
```netlinx
stack_var char nextCommand[NAV_MAX_BUFFER]
nextCommand = NAVQueueDequeue(myQueue)
if (length_array(nextCommand)) {
    // Process the command
    send_string dvDevice, nextCommand
} else {
    // Queue was empty
}
```

### Inspecting Items

#### `NAVQueuePeek`
**Purpose**: View the front item without removing it.

**Signature**: `char[NAV_MAX_BUFFER] NAVQueuePeek(_NAVQueue queue)`

**Parameters**:
- `queue` - Queue to inspect

**Returns**: Front item string, or empty string if queue is empty

**Example**:
```netlinx
stack_var char nextItem[NAV_MAX_BUFFER]
nextItem = NAVQueuePeek(myQueue)
if (length_array(nextItem)) {
    send_string 0, "'Next item will be: ', nextItem"
}
```

#### `NAVQueueContains`
**Purpose**: Check if a specific item exists anywhere in the queue.

**Signature**: `sinteger NAVQueueContains(_NAVQueue queue, char item[NAV_MAX_BUFFER])`

**Parameters**:
- `queue` - Queue to search
- `item[]` - Item to search for

**Returns**: `1` if item exists, `0` if not found

**Example**:
```netlinx
if (NAVQueueContains(myQueue, 'EMERGENCY_STOP')) {
    // Emergency stop command is queued
    NAVQueueClear(myQueue)
    NAVQueueEnqueue(myQueue, 'EMERGENCY_STOP')
}
```

### State Queries

#### `NAVQueueIsEmpty`
**Purpose**: Check if the queue has no items.

**Signature**: `sinteger NAVQueueIsEmpty(_NAVQueue queue)`

**Parameters**:
- `queue` - Queue to check

**Returns**: `1` if empty, `0` if has items

**Example**:
```netlinx
if (NAVQueueIsEmpty(myQueue)) {
    send_string 0, "'No commands pending'"
}
```

#### `NAVQueueHasItems`
**Purpose**: Check if the queue contains one or more items.

**Signature**: `sinteger NAVQueueHasItems(_NAVQueue queue)`

**Parameters**:
- `queue` - Queue to check

**Returns**: `1` if has items, `0` if empty

**Example**:
```netlinx
if (NAVQueueHasItems(myQueue)) {
    // Process next item
    processCommand(NAVQueueDequeue(myQueue))
}
```

#### `NAVQueueIsFull`
**Purpose**: Check if the queue has reached maximum capacity.

**Signature**: `sinteger NAVQueueIsFull(_NAVQueue queue)`

**Parameters**:
- `queue` - Queue to check

**Returns**: `1` if full, `0` if space available

**Example**:
```netlinx
if (!NAVQueueIsFull(myQueue)) {
    NAVQueueEnqueue(myQueue, newCommand)
} else {
    send_string 0, "'Queue full - dropping command'"
}
```

#### `NAVQueueGetCount`
**Purpose**: Get the current number of items in the queue.

**Signature**: `integer NAVQueueGetCount(_NAVQueue queue)`

**Parameters**:
- `queue` - Queue to query

**Returns**: Current item count (0 to capacity)

**Example**:
```netlinx
stack_var integer count
count = NAVQueueGetCount(myQueue)
send_string 0, "'Queue has ', itoa(count), ' items'"
```

#### `NAVQueueGetCapacity`
**Purpose**: Get the maximum capacity of the queue.

**Signature**: `integer NAVQueueGetCapacity(_NAVQueue queue)`

**Parameters**:
- `queue` - Queue to query

**Returns**: Maximum capacity set during initialization

**Example**:
```netlinx
stack_var integer capacity, count
capacity = NAVQueueGetCapacity(myQueue)
count = NAVQueueGetCount(myQueue)
send_string 0, "'Queue usage: ', itoa(count), '/', itoa(capacity)"
```

### Utility Functions

#### `NAVQueueClear`
**Purpose**: Remove all items from the queue.

**Signature**: `NAVQueueClear(_NAVQueue queue)`

**Parameters**:
- `queue` - Queue to clear

**Example**:
```netlinx
// Clear all pending commands
NAVQueueClear(myQueue)
send_string 0, "'All queued commands cleared'"
```

#### `NAVQueueToString`
**Purpose**: Get a string representation of the queue for debugging.

**Signature**: `char[NAV_MAX_BUFFER] NAVQueueToString(_NAVQueue queue)`

**Parameters**:
- `queue` - Queue to represent

**Returns**: String showing count, capacity, and all items

**Example**:
```netlinx
send_string 0, NAVQueueToString(myQueue)
// Output: "Queue [3/10]: item1, item2, item3"
```

## Common Use Cases

### Command Buffering for Device Communication

```netlinx
DEFINE_VARIABLE
volatile _NAVQueue deviceCommands

DEFINE_START
NAVQueueInit(deviceCommands, 50)

DEFINE_FUNCTION sendToDevice(char cmd[]) {
    if (!NAVQueueIsFull(deviceCommands)) {
        NAVQueueEnqueue(deviceCommands, cmd)
    }
    
    if (!deviceBusy) {
        processNextCommand()
    }
}

DEFINE_FUNCTION processNextCommand() {
    stack_var char cmd[NAV_MAX_BUFFER]
    
    if (!NAVQueueHasItems(deviceCommands)) {
        return
    }
    
    cmd = NAVQueueDequeue(deviceCommands)
    send_string dvDevice, cmd
    deviceBusy = true
}

DEFINE_EVENT
string_event[dvDevice] {
    if (find_string(string.text, 'OK', 1)) {
        deviceBusy = false
        processNextCommand()  // Send next queued command
    }
}
```

### Event Buffering with Priority Handling

```netlinx
DEFINE_VARIABLE
volatile _NAVQueue eventQueue
volatile _NAVQueue priorityQueue

DEFINE_START
NAVQueueInit(eventQueue, 100)
NAVQueueInit(priorityQueue, 20)

DEFINE_FUNCTION queueEvent(char event[], integer isPriority) {
    if (isPriority) {
        if (!NAVQueueIsFull(priorityQueue)) {
            NAVQueueEnqueue(priorityQueue, event)
        }
    } else {
        if (!NAVQueueIsFull(eventQueue)) {
            NAVQueueEnqueue(eventQueue, event)
        }
    }
}

DEFINE_FUNCTION char[NAV_MAX_BUFFER] getNextEvent() {
    // Check priority queue first
    if (NAVQueueHasItems(priorityQueue)) {
        return NAVQueueDequeue(priorityQueue)
    }
    
    // Then check regular queue
    if (NAVQueueHasItems(eventQueue)) {
        return NAVQueueDequeue(eventQueue)
    }
    
    return ''
}
```

### Message Rate Limiting

```netlinx
DEFINE_VARIABLE
volatile _NAVQueue messageQueue
volatile long lastSendTime

DEFINE_START
NAVQueueInit(messageQueue, 30)
lastSendTime = 0

DEFINE_FUNCTION queueMessage(char msg[]) {
    NAVQueueEnqueue(messageQueue, msg)
}

timeline_event[TL_RATE_LIMITER] {
    stack_var char msg[NAV_MAX_BUFFER]
    stack_var long currentTime
    
    currentTime = get_timer
    
    // Enforce 100ms minimum between messages
    if ((currentTime - lastSendTime) < 100) {
        return
    }
    
    if (NAVQueueHasItems(messageQueue)) {
        msg = NAVQueueDequeue(messageQueue)
        send_string dvOutput, msg
        lastSendTime = currentTime
    }
}
```

## Error Handling

The queue library includes comprehensive error logging for debugging:

```netlinx
// Enable error logging
#define NAV_LOG_LEVEL_ERROR 1
#include 'NAVFoundation.Queue.axi'

// Errors are automatically logged:
// - Enqueue to full queue
// - Dequeue from empty queue
// - Invalid capacity during initialization
// - Contains search on empty queue
```

All error conditions are logged but non-fatal - functions return safe values (0, empty string) to prevent crashes.

## Best Practices

### 1. **Choose Appropriate Capacity**
```netlinx
// For command buffering (typically 10-20 items)
NAVQueueInit(cmdQueue, 20)

// For high-volume event processing (50-100+ items)
NAVQueueInit(eventQueue, 100)
```

### 2. **Always Check Return Values**
```netlinx
// Good - checks if enqueue succeeded
if (NAVQueueEnqueue(queue, item)) {
    // Success
} else {
    // Handle full queue
}

// Good - checks if dequeue returned data
stack_var char item[NAV_MAX_BUFFER]
item = NAVQueueDequeue(queue)
if (length_array(item)) {
    // Process item
}
```

### 3. **Monitor Queue Depth**
```netlinx
// Warn if queue is getting full
if (NAVQueueGetCount(queue) > (NAVQueueGetCapacity(queue) * 0.8)) {
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'Queue is 80% full'")
}
```

### 4. **Use Peek for Non-Destructive Inspection**
```netlinx
// Look ahead without removing
stack_var char nextItem[NAV_MAX_BUFFER]
nextItem = NAVQueuePeek(queue)
if (nextItem == 'EMERGENCY_STOP') {
    // Clear everything and prioritize
    NAVQueueClear(queue)
    processEmergencyStop()
}
```

## Breaking Changes

### v3.0.0 - Event Handling Refactor

**Important**: As of version 3.0.0, the `timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE]` and the global variable declaration have been removed from the library to minimize side effects and avoid global variable dependencies. This is a breaking change that requires updates to consumer code.

#### What Changed

- The timeline event that previously handled failed responses has been removed from `NAVFoundation.DevicePriorityQueue.axi`.
- The global variable declaration `volatile _NAVDevicePriorityQueue priorityQueue` has been removed from the library.
- The library now focuses purely on data structures and functions, without enforcing global variables or event handling.
- Consumers must now declare their own queue variable and manage the timeline event in their own code.

#### Migration Guide

To migrate your code to the new version:

1. **Remove any reliance on the built-in event**: The library no longer declares or handles the `TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE` timeline event.

2. **Declare your queue variable**: Add a variable declaration for your queue instance in your consumer code. You can name it anything you want:

    ```netlinx-source
    DEFINE_VARIABLE
    volatile _NAVDevicePriorityQueue myDeviceQueue  // Replace 'myDeviceQueue' with your preferred name
    ```

3. **Add the event to your consumer code**: In your main `.axs` file (or wherever you declare events), add the following:

    ```netlinx-source
    DEFINE_EVENT
    timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
        NAVDevicePriorityQueueFailedResponse(yourQueueVariable)  // Replace 'yourQueueVariable' with your actual queue instance name
    }
    ```

4. **Ensure callback definitions**: If you're using the callback mechanism, make sure `USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK` is defined in your code. **Important**: Because NetLinx compiles top-down, these compiler directives must be placed _before_ the `#include` statement for the library.

5. **Update function calls**: Replace any references to the old global `priorityQueue` variable with your new variable name throughout your code.

#### Example Consumer Code

Here's a complete example of how to use the library after the migration:

```netlinx-source
PROGRAM_NAME='MyProgram'

// Compiler directives must be defined BEFORE the include
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK

// Include the library
#include 'NAVFoundation.DevicePriorityQueue.axi'

// Declare your queue variable (previously was global in the library)
DEFINE_VARIABLE
volatile _NAVDevicePriorityQueue myDeviceQueue

// Define the callback if needed
define_function NAVDevicePriorityQueueFailedResponseEventCallback(_NAVDevicePriorityQueue queue) {
    // Your custom logic here
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Failed response for queue: ', queue.LastMessage")
}

DEFINE_EVENT
// Handle the timeline event in your code (previously was in the library)
timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
    NAVDevicePriorityQueueFailedResponse(myDeviceQueue)
}

// Other events and logic...
button_event[dvTP, 1] {
    push: {
        // Initialize and use your queue
        NAVDevicePriorityQueueInit(myDeviceQueue)
        // ... rest of your code
    }
}
```
