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

---

# NAVFoundation.DevicePriorityQueue

A specialized dual-queue implementation designed for device communication with built-in priority handling, automatic retry logic, busy state management, and timeout detection. This library extends the basic queue functionality to provide robust command/query management for unreliable device communication.

## Features

- **Dual-Queue Architecture**: Separate high-priority (command) and low-priority (query) queues
- **Priority Management**: Commands always processed before queries
- **Automatic Retry Logic**: Configurable retry attempts with failed response tracking
- **Busy State Management**: Prevents concurrent requests to devices
- **Auto-Send on First Item**: Automatically sends first item when queue is idle
- **Timeline-Based Timeout**: Failed response detection for unresponsive devices
- **Resend Capability**: Automatic retry of failed messages
- **Callback Support**: Optional event callbacks for send and failure events
- **Production Ready**: Extensively tested with 22 comprehensive tests (16 core + 6 callback tests)

## Quick Start

### Basic Usage

```netlinx
#include 'NAVFoundation.DevicePriorityQueue.axi'

DEFINE_VARIABLE
volatile _NAVDevicePriorityQueue deviceQueue

DEFINE_START
// Initialize the queue
NAVDevicePriorityQueueInit(deviceQueue)

// Enqueue high-priority command (will auto-send if queue is idle)
NAVDevicePriorityQueueEnqueue(deviceQueue, '?POWER', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

// Enqueue low-priority query
NAVDevicePriorityQueueEnqueue(deviceQueue, '?INPUT', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)

// Handle the timeline event for failed response detection
DEFINE_EVENT
timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
    NAVDevicePriorityQueueFailedResponse(deviceQueue)
}

// When device responds successfully
string_event[dvDevice] {
    // Process the response...
    
    // Mark as good response and send next item
    NAVDevicePriorityQueueGoodResponse(deviceQueue)
}
```

## Architecture

### Dual-Queue System

The DevicePriorityQueue maintains two internal queues:

| Queue Type | Capacity | Priority | Use Case |
|------------|----------|----------|----------|
| **Command Queue** | 50 items | High (true) | Critical commands that must execute first |
| **Query Queue** | 100 items | Low (false) | Status queries that can wait |

Commands are always processed before queries. When `SendNextItem()` is called, it checks the command queue first, then the query queue.

### State Machine

```
┌─────────────┐
│   Idle      │  Busy = false, queues empty
│ (Not Busy)  │
└──────┬──────┘
       │ Enqueue() with empty queue
       ▼
┌─────────────┐
│   Sending   │  Busy = true, timeline started
│  (Busy)     │  LastMessage stored
└──────┬──────┘
       │
       ├─────── Good Response ────────┐
       │                              │
       │                              ▼
       │                    ┌──────────────────┐
       │                    │   Send Next or   │
       │                    │   Return to Idle │
       │                    └──────────────────┘
       │
       ├─────── Failed Response ──────┐
       │        (FailedCount < Max)   │
       │                              ▼
       │                    ┌──────────────────┐
       │                    │ Resend = true    │
       │                    │ FailedCount++    │
       │                    │ SendNextItem()   │
       │                    └──────────────────┘
       │
       └─────── Max Failures ─────────┐
                (FailedCount >= Max)  │
                                      ▼
                            ┌──────────────────┐
                            │ Callback (opt)   │
                            │ Init() - Reset   │
                            └──────────────────┘
```

## API Reference

### Initialization

#### `NAVDevicePriorityQueueInit`
**Purpose**: Initialize a device priority queue with default settings.

**Signature**: `NAVDevicePriorityQueueInit(_NAVDevicePriorityQueue queue)`

**Parameters**:
- `queue` - Device priority queue structure to initialize

**Behavior**:
- Sets `Busy = false`, `FailedCount = 0`, `Resend = false`
- Initializes `MaxFailedCount = 3` (configurable constant)
- Clears `LastMessage`
- Initializes both command queue (50 items) and query queue (100 items)
- Configures failed response timeline

**Example**:
```netlinx
stack_var _NAVDevicePriorityQueue queue
NAVDevicePriorityQueueInit(queue)
```

### Queue Operations

#### `NAVDevicePriorityQueueEnqueue`
**Purpose**: Add an item to the appropriate priority queue and auto-send if idle.

**Signature**: `sinteger NAVDevicePriorityQueueEnqueue(_NAVDevicePriorityQueue queue, char item[NAV_MAX_BUFFER], integer priority)`

**Parameters**:
- `queue` - Device priority queue
- `item` - Message to enqueue (max 65535 characters)
- `priority` - `NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND` (true) for high priority, `NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY` (false) for low priority

**Returns**: `1` on success, `0` if target queue is full

**Behavior**:
- Routes item to command queue (high priority) or query queue (low priority)
- **Auto-send**: If both queues are empty AND `Busy = false`, automatically calls `SendNextItem()`
- Returns success/failure based on target queue capacity

**Example**:
```netlinx
// High-priority command
NAVDevicePriorityQueueEnqueue(queue, 'POWER=ON', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

// Low-priority query
NAVDevicePriorityQueueEnqueue(queue, '?STATUS', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
```

#### `NAVDevicePriorityQueueDequeue`
**Purpose**: Remove and return the next item based on priority.

**Signature**: `char[NAV_MAX_BUFFER] NAVDevicePriorityQueueDequeue(_NAVDevicePriorityQueue queue)`

**Returns**: Next item (commands before queries), or empty string if both queues are empty

**Example**:
```netlinx
stack_var char nextItem[NAV_MAX_BUFFER]
nextItem = NAVDevicePriorityQueueDequeue(queue)
```

#### `NAVDevicePriorityQueueHasItems`
**Purpose**: Check if either queue has items.

**Signature**: `sinteger NAVDevicePriorityQueueHasItems(_NAVDevicePriorityQueue queue)`

**Returns**: `1` if either queue has items, `0` if both are empty

**Example**:
```netlinx
if (NAVDevicePriorityQueueHasItems(queue)) {
    // Process items
}
```

#### `NAVDevicePriorityQueueGetCount`
**Purpose**: Get total number of items across both queues.

**Signature**: `sinteger NAVDevicePriorityQueueGetCount(_NAVDevicePriorityQueue queue)`

**Returns**: Combined count of command queue + query queue

**Example**:
```netlinx
send_string 0, "'Total queued: ', itoa(NAVDevicePriorityQueueGetCount(queue))"
```

### Message Handling

#### `NAVDevicePriorityQueueSendNextItem`
**Purpose**: Dequeue and send the next item based on priority.

**Signature**: `NAVDevicePriorityQueueSendNextItem(_NAVDevicePriorityQueue queue)`

**Behavior**:
- If `Resend = true`: Re-sends `LastMessage` without dequeuing
- Otherwise: Dequeues next item (commands before queries) and sends it
- Sets `Busy = true` and stores message in `LastMessage`
- Starts failed response timeline for timeout detection
- Triggers optional `SendNextItemEventCallback` if enabled
- Does nothing if both queues are empty

**Timeline**: Starts `TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE` to detect response timeout

**Example**:
```netlinx
// Typically called internally, but can be called manually
NAVDevicePriorityQueueSendNextItem(queue)
```

#### `NAVDevicePriorityQueueGoodResponse`
**Purpose**: Mark the current message as successfully responded to.

**Signature**: `NAVDevicePriorityQueueGoodResponse(_NAVDevicePriorityQueue queue)`

**Behavior**:
- Stops failed response timeline
- Resets `FailedCount = 0`
- Sets `Busy = false`, `Resend = false`, clears `LastMessage`
- Automatically calls `SendNextItem()` if more items are queued

**Example**:
```netlinx
string_event[dvDevice] {
    if (find_string(string.text, 'OK', 1)) {
        NAVDevicePriorityQueueGoodResponse(deviceQueue)
    }
}
```

### Failure Handling

#### `NAVDevicePriorityQueueFailedResponse`
**Purpose**: Handle a failed or timed-out response.

**Signature**: `NAVDevicePriorityQueueFailedResponse(_NAVDevicePriorityQueue queue)`

**Behavior**:
- Does nothing if `Busy = false`
- If `FailedCount < MaxFailedCount` (default 3):
  - Increments `FailedCount`
  - Sets `Resend = true`
  - Calls `SendNextItem()` to retry
- If `FailedCount >= MaxFailedCount`:
  - Triggers optional `FailedResponseEventCallback` if enabled
  - Calls `Init()` to reset the queue (clears all state and items)

**Example**:
```netlinx
// Typically called from timeline event
timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
    NAVDevicePriorityQueueFailedResponse(deviceQueue)
}

// Can also be called manually when error is detected
string_event[dvDevice] {
    if (find_string(string.text, 'ERROR', 1)) {
        NAVDevicePriorityQueueFailedResponse(deviceQueue)
    }
}
```

### Utility Functions

#### `NAVDevicePriorityQueueToString`
**Purpose**: Get a human-readable representation for debugging.

**Signature**: `char[NAV_MAX_CHARS] NAVDevicePriorityQueueToString(_NAVDevicePriorityQueue queue)`

**Returns**: String showing queue counts and state

**Example**:
```netlinx
send_string 0, NAVDevicePriorityQueueToString(queue)
// Output: "DevicePriorityQueue [Commands: 3/50, Queries: 5/100, Busy: true]"
```

## Configuration

### Constants

```netlinx
// Maximum retry attempts before reinitializing (default: 3)
constant integer NAV_DEVICE_PRIORITY_QUEUE_MAX_FAILED_RESPONSE_COUNT = 3

// Timeline ID for failed response detection
constant long TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE = 1000

// Timeout period for failed response (default: 5000ms = 5 seconds)
constant long TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_TIME = 5000

// Queue capacities
constant integer NAV_DEVICE_PRIORITY_QUEUE_COMMAND_QUEUE_SIZE = 50   // High priority
constant integer NAV_DEVICE_PRIORITY_QUEUE_QUERY_QUEUE_SIZE = 100    // Low priority

// Priority values
constant integer NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND = true   // High priority
constant integer NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY = false    // Low priority
```

### Customization

To customize timeout or retry behavior, modify the constants in `NAVFoundation.DevicePriorityQueue.h.axi` before including the library:

```netlinx
// Custom configuration
#define NAV_DEVICE_PRIORITY_QUEUE_MAX_FAILED_RESPONSE_COUNT 5  // Allow 5 retries
#define TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_TIME 10000  // 10 second timeout

#include 'NAVFoundation.DevicePriorityQueue.axi'
```

## Callback System

The library supports optional callbacks for advanced event handling. Callbacks must be defined **before** including the library.

### Available Callbacks

#### 1. SendNextItem Event Callback

**Purpose**: Called whenever an item is sent (new or resend).

**Enable**: `#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK`

**Signature**: `define_function NAVDevicePriorityQueueSendNextItemEventCallback(_NAVDevicePriorityQueue queue, char message[NAV_MAX_BUFFER], integer isResend)`

**Parameters**:
- `queue` - The device priority queue
- `message` - The message being sent
- `isResend` - `1` if this is a retry, `0` if new message

**Example**:
```netlinx
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK
#include 'NAVFoundation.DevicePriorityQueue.axi'

define_function NAVDevicePriorityQueueSendNextItemEventCallback(_NAVDevicePriorityQueue queue, char message[NAV_MAX_BUFFER], integer isResend) {
    if (isResend) {
        NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'Resending: ', message")
    } else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Sending: ', message")
    }
    
    // Send to device
    send_string dvDevice, message
}
```

#### 2. FailedResponse Event Callback

**Purpose**: Called when maximum retry attempts are reached before queue reinitializes.

**Enable**: `#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK`

**Signature**: `define_function NAVDevicePriorityQueueFailedResponseEventCallback(_NAVDevicePriorityQueue queue)`

**Parameters**:
- `queue` - The device priority queue (contains `FailedCount`, `LastMessage` before reset)

**Example**:
```netlinx
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK
#include 'NAVFoundation.DevicePriorityQueue.axi'

define_function NAVDevicePriorityQueueFailedResponseEventCallback(_NAVDevicePriorityQueue queue) {
    NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Device failed to respond after ', itoa(queue.FailedCount), ' attempts'")
    NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'Last message: ', queue.LastMessage")
    
    // Notify user or trigger recovery actions
    send_command dvTP, "'@PPN-Device Communication Failed'"
}
```

### Complete Callback Example

```netlinx
PROGRAM_NAME='DeviceControl'

// Enable both callbacks BEFORE including library
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_EVENT_CALLBACK

#include 'NAVFoundation.DevicePriorityQueue.axi'

DEFINE_VARIABLE
volatile _NAVDevicePriorityQueue projectorQueue
dev dvProjector = 5001:1:0

// SendNextItem callback - handles actual device communication
define_function NAVDevicePriorityQueueSendNextItemEventCallback(_NAVDevicePriorityQueue queue, char message[NAV_MAX_BUFFER], integer isResend) {
    if (isResend) {
        NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'[Projector] Retry #', itoa(queue.FailedCount), ': ', message")
    }
    
    send_string dvProjector, "message, $0D"  // Add carriage return
}

// FailedResponse callback - handles max failures
define_function NAVDevicePriorityQueueFailedResponseEventCallback(_NAVDevicePriorityQueue queue) {
    NAVErrorLog(NAV_LOG_LEVEL_ERROR, "'[Projector] Communication failed after ', itoa(queue.FailedCount), ' attempts'")
    send_command dvTP, "'@PPN-Projector Not Responding'"
    
    // Try power cycling the device
    pulse[dvProjectorRelay, 1]
}

DEFINE_START
NAVDevicePriorityQueueInit(projectorQueue)

DEFINE_EVENT
// Timeline event for timeout detection
timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
    NAVDevicePriorityQueueFailedResponse(projectorQueue)
}

// Device response handling
string_event[dvProjector] {
    if (find_string(string.text, 'OK', 1)) {
        NAVDevicePriorityQueueGoodResponse(projectorQueue)
    }
    else if (find_string(string.text, 'ERR', 1)) {
        NAVDevicePriorityQueueFailedResponse(projectorQueue)
    }
}

// Button to send commands
button_event[dvTP, 1] {
    push: {
        NAVDevicePriorityQueueEnqueue(projectorQueue, 'PWR ON', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    }
}
```

## Common Use Cases

### 1. Projector Control with Query Feedback

```netlinx
DEFINE_VARIABLE
volatile _NAVDevicePriorityQueue projQueue

DEFINE_START
NAVDevicePriorityQueueInit(projQueue)

DEFINE_FUNCTION powerOnProjector() {
    // Send power command (high priority)
    NAVDevicePriorityQueueEnqueue(projQueue, 'PWR ON', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    
    // Follow with status queries (low priority - will wait for command to complete)
    NAVDevicePriorityQueueEnqueue(projQueue, '?PWR', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
    NAVDevicePriorityQueueEnqueue(projQueue, '?LAMP', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
}

DEFINE_EVENT
timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
    NAVDevicePriorityQueueFailedResponse(projQueue)
}

string_event[dvProjector] {
    // Process response...
    NAVDevicePriorityQueueGoodResponse(projQueue)
}
```

### 2. Matrix Switcher with Priority Override

```netlinx
DEFINE_VARIABLE
volatile _NAVDevicePriorityQueue matrixQueue

DEFINE_FUNCTION routeInput(integer input, integer output) {
    // Normal routing (low priority - can be interrupted)
    NAVDevicePriorityQueueEnqueue(matrixQueue, "input, '*', output, '!'", NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
}

DEFINE_FUNCTION emergencyRoute(integer input, integer output) {
    // Emergency routing (high priority - executes immediately)
    NAVDevicePriorityQueueEnqueue(matrixQueue, "input, '*', output, '!'", NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
}

// Commands are always sent before queries, so emergency routes jump the queue
```

### 3. Display Control with Retry Logic

```netlinx
DEFINE_VARIABLE
volatile _NAVDevicePriorityQueue displayQueue

DEFINE_START
NAVDevicePriorityQueueInit(displayQueue)

DEFINE_FUNCTION setDisplayInput(char input[]) {
    NAVDevicePriorityQueueEnqueue(displayQueue, "'INPUT=', input", NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
}

DEFINE_EVENT
// Automatically retries up to 3 times if display doesn't respond
timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
    NAVDevicePriorityQueueFailedResponse(displayQueue)
}

string_event[dvDisplay] {
    if (find_string(string.text, 'OK', 1)) {
        NAVDevicePriorityQueueGoodResponse(displayQueue)
    }
}
```

### 4. Multi-Device Coordinator

```netlinx
DEFINE_VARIABLE
volatile _NAVDevicePriorityQueue projectorQueue
volatile _NAVDevicePriorityQueue audioQueue
volatile _NAVDevicePriorityQueue lightsQueue

DEFINE_START
NAVDevicePriorityQueueInit(projectorQueue)
NAVDevicePriorityQueueInit(audioQueue)
NAVDevicePriorityQueueInit(lightsQueue)

DEFINE_FUNCTION startPresentation() {
    // All high-priority commands - execute immediately
    NAVDevicePriorityQueueEnqueue(projectorQueue, 'PWR ON', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(audioQueue, 'MUTE OFF', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    NAVDevicePriorityQueueEnqueue(lightsQueue, 'PRESET 1', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
    
    // Low-priority status queries - execute after commands
    NAVDevicePriorityQueueEnqueue(projectorQueue, '?STATUS', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
    NAVDevicePriorityQueueEnqueue(audioQueue, '?VOLUME', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
}

// Each device has its own queue with independent retry logic
```

## Best Practices

### 1. Always Handle Timeline Events

```netlinx
// Required - library needs this for timeout detection
DEFINE_EVENT
timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
    NAVDevicePriorityQueueFailedResponse(yourQueue)
}
```

### 2. Use Priority Appropriately

```netlinx
// HIGH priority (commands) - state changes, critical operations
NAVDevicePriorityQueueEnqueue(queue, 'POWER=ON', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)
NAVDevicePriorityQueueEnqueue(queue, 'INPUT=HDMI1', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)

// LOW priority (queries) - status requests, polling
NAVDevicePriorityQueueEnqueue(queue, '?POWER', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
NAVDevicePriorityQueueEnqueue(queue, '?TEMP', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)
```

### 3. Don't Manually Set Busy State (Usually)

```netlinx
// WRONG - breaks auto-send behavior
queue.Busy = true
NAVDevicePriorityQueueEnqueue(queue, 'CMD')

// RIGHT - let the library manage Busy state
NAVDevicePriorityQueueEnqueue(queue, 'CMD')  // Auto-sends if idle
```

**Exception**: In unit tests where you need to test queue behavior in isolation without triggering auto-send.

### 4. Monitor Queue Depth for Debugging

```netlinx
// Useful for identifying communication bottlenecks
if (NAVDevicePriorityQueueGetCount(queue) > 20) {
    NAVErrorLog(NAV_LOG_LEVEL_WARNING, "'Queue backup detected: ', itoa(NAVDevicePriorityQueueGetCount(queue)), ' items'")
}
```

### 5. Use Callbacks for Custom Communication

```netlinx
// Instead of manually sending in Enqueue, use the SendNextItem callback
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK
#include 'NAVFoundation.DevicePriorityQueue.axi'

define_function NAVDevicePriorityQueueSendNextItemEventCallback(_NAVDevicePriorityQueue queue, char message[NAV_MAX_BUFFER], integer isResend) {
    // Add protocol-specific formatting here
    send_string dvDevice, "STX, message, ETX"
}
```

## Error Handling

### Automatic Error Recovery

The library includes built-in error recovery:

1. **Failed Response Detection**: Timeline automatically detects when device doesn't respond within timeout period (default 5 seconds)
2. **Automatic Retry**: Retries failed messages up to `MaxFailedCount` times (default 3)
3. **Queue Reinitialization**: After max failures, reinitializes queue to prevent permanent stuck state
4. **Callback Notifications**: Optional callbacks allow custom error handling

### Error Logging

```netlinx
// Enable logging to diagnose issues
#define NAV_LOG_LEVEL_DEBUG
#include 'NAVFoundation.DevicePriorityQueue.axi'

// Library will log:
// - Enqueue to full queue
// - Failed responses and retry attempts
// - Queue reinitialization after max failures
```

## Performance Characteristics

### Memory Usage

- **Per Queue Instance**: ~40 KB
  - Command Queue: 50 items × ~250 bytes = ~12.5 KB
  - Query Queue: 100 items × ~250 bytes = ~25 KB
  - Overhead: ~2.5 KB

### Timing

- **Auto-Send Delay**: Immediate (0ms) when enqueuing to idle queue
- **Default Timeout**: 5000ms (5 seconds) - configurable
- **Retry Overhead**: ~10ms per retry (timeline + function call)

### Complexity

- **Enqueue**: O(1) constant time
- **Dequeue**: O(1) constant time (priority check is O(1))
- **SendNextItem**: O(1) constant time
- **GoodResponse**: O(1) constant time (+ O(1) for next send if queued)
- **FailedResponse**: O(1) constant time (+ O(n) for Init if max failures)

## Troubleshooting

### Queue Gets Stuck / Nothing Sends

**Symptoms**: Items enqueue but never send

**Causes**:
1. Missing timeline event handler
2. `Busy` flag stuck as `true`
3. Timeline not triggering

**Solutions**:
```netlinx
// 1. Ensure timeline event is defined
DEFINE_EVENT
timeline_event[TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE] {
    NAVDevicePriorityQueueFailedResponse(queue)
}

// 2. Check Busy state
send_string 0, "'Queue Busy: ', itoa(queue.Busy)"

// 3. Manually trigger next send if stuck
if (queue.Busy) {
    NAVDevicePriorityQueueFailedResponse(queue)  // Force timeout
}
```

### Commands Execute Out of Order

**Symptoms**: Low-priority commands execute before high-priority ones

**Cause**: Using wrong priority constant

**Solution**:
```netlinx
// Use the defined constants, not magic numbers
NAVDevicePriorityQueueEnqueue(queue, 'CMD', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_COMMAND)  // ✓ Correct
NAVDevicePriorityQueueEnqueue(queue, 'QRY', NAV_DEVICE_PRIORITY_QUEUE_PRIORITY_QUERY)    // ✓ Correct

// NOT:
NAVDevicePriorityQueueEnqueue(queue, 'CMD', 1)  // ✗ Wrong
NAVDevicePriorityQueueEnqueue(queue, 'QRY', 0)  // ✗ Wrong
```

### Device Never Responds / Constant Retries

**Symptoms**: Library keeps retrying, eventually reinitializes

**Causes**:
1. Device not connected
2. Wrong baud rate / protocol
3. Not calling `GoodResponse()` when device responds
4. Timeline timeout too short

**Solutions**:
```netlinx
// 1. Verify device connection
send_string 0, "'Device online: ', itoa(device_id(dvDevice))"

// 2. Check protocol in callback
define_function NAVDevicePriorityQueueSendNextItemEventCallback(_NAVDevicePriorityQueue queue, char message[NAV_MAX_BUFFER], integer isResend) {
    send_string 0, "'Sending: ', message"  // Verify format
    send_string dvDevice, message
}

// 3. Ensure GoodResponse is called
string_event[dvDevice] {
    send_string 0, "'Device response: ', string.text"  // Debug
    NAVDevicePriorityQueueGoodResponse(queue)  // Must call this!
}

// 4. Increase timeout if device is slow
#define TL_NAV_DEVICE_PRIORITY_QUEUE_FAILED_RESPONSE_TIME 10000  // 10 seconds
```

### Callback Not Being Called

**Symptoms**: Callback define is set but function never executes

**Causes**:
1. `#DEFINE` placed after `#include`
2. Callback function not defined
3. Wrong function signature

**Solution**:
```netlinx
// ✓ CORRECT ORDER
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK
#include 'NAVFoundation.DevicePriorityQueue.axi'

define_function NAVDevicePriorityQueueSendNextItemEventCallback(_NAVDevicePriorityQueue queue, char message[NAV_MAX_BUFFER], integer isResend) {
    // Function body
}

// ✗ WRONG ORDER - won't work!
#include 'NAVFoundation.DevicePriorityQueue.axi'
#DEFINE USING_NAV_DEVICE_PRIORITY_QUEUE_SEND_NEXT_ITEM_EVENT_CALLBACK  // Too late!
```

## Testing

The DevicePriorityQueue library has been extensively tested:

- **Core Tests**: 16 tests covering initialization, enqueue/dequeue, priority handling, state management, and response handling
- **Callback Tests**: 6 tests covering callback invocation and behavior
- **Total Coverage**: 22 comprehensive tests validating all functionality

Test categories:
- Basic operations (init, enqueue, dequeue)
- Priority handling (command vs query order)
- State management (busy flag, counters)
- Response handling (good, failed, resend, max failures)
- Callback integration (send event, failed response event)
- Sequence verification (end-to-end workflows)

All tests must pass before release.

## Breaking Changes

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
