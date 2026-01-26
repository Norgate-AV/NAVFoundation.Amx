# NAVFoundation.Stack

The Stack library for NAVFoundation provides a robust implementation of the Last-In-First-Out (LIFO) data structure for NetLinx programming. It supports both string and integer stack types with comprehensive state management and error handling capabilities.

## Overview

A stack is a fundamental data structure that follows the LIFO (Last-In-First-Out) principle, where the most recently added item is the first one to be removed. This library provides a complete implementation with capacity management, state querying, and type-safe operations for both string and integer data types.

## Features

- **LIFO Operations**: Push and pop items in Last-In-First-Out order
- **Dual Type Support**: Separate implementations for string and integer stacks
- **Capacity Management**: Configurable maximum size with overflow protection
- **Non-Destructive Peek**: View the top item without removing it
- **State Management**: Comprehensive functions to query stack state
- **Error Handling**: Built-in error logging for boundary conditions
- **Memory Safety**: Automatic bounds checking and capacity enforcement

## Quick Start

### Basic String Stack Usage

```netlinx
DEFINE_VARIABLE
volatile _NAVStackString commandStack

DEFINE_START
// Initialize stack with capacity of 20 items
NAVStackInitString(commandStack, 20)

// Push items onto the stack
NAVStackPushString(commandStack, 'First Command')
NAVStackPushString(commandStack, 'Second Command')
NAVStackPushString(commandStack, 'Third Command')

// Pop items in LIFO order (most recent first)
stack_var char cmd[NAV_MAX_BUFFER]
cmd = NAVStackPopString(commandStack)  // Returns 'Third Command'
cmd = NAVStackPopString(commandStack)  // Returns 'Second Command'
cmd = NAVStackPopString(commandStack)  // Returns 'First Command'
```

### Basic Integer Stack Usage

```netlinx
DEFINE_VARIABLE
volatile _NAVStackInteger numberStack

DEFINE_START
// Initialize stack with capacity of 10 items
NAVStackInitInteger(numberStack, 10)

// Push integers onto the stack
NAVStackPushInteger(numberStack, 100)
NAVStackPushInteger(numberStack, 200)
NAVStackPushInteger(numberStack, 300)

// Pop integers in LIFO order
stack_var integer value
value = NAVStackPopInteger(numberStack)  // Returns 300
value = NAVStackPopInteger(numberStack)  // Returns 200
value = NAVStackPopInteger(numberStack)  // Returns 100
```

## Performance Characteristics

### Memory Usage

| Stack Type | Item Size      | Max Capacity  | Memory per Stack |
| ---------- | -------------- | ------------- | ---------------- |
| String     | NAV_MAX_BUFFER | 500 (default) | ~500KB           |
| Integer    | 2 bytes        | 500 (default) | ~1KB             |

### Time Complexity

| Operation | Complexity | Notes         |
| --------- | ---------- | ------------- |
| Push      | O(1)       | Constant time |
| Pop       | O(1)       | Constant time |
| Peek      | O(1)       | Constant time |
| IsEmpty   | O(1)       | Constant time |
| IsFull    | O(1)       | Constant time |
| GetCount  | O(1)       | Constant time |

## API Reference

### String Stack Functions

#### `NAVStackInitString`

**Purpose**: Initialize a string stack with specified capacity.

**Signature**: `NAVStackInitString(_NAVStackString stack, integer initCapacity)`

**Parameters**:

- `stack` - Stack instance to initialize (passed by reference)
- `initCapacity` - Maximum number of items the stack can hold. If <= 0 or > NAV_MAX_STACK_SIZE, defaults to NAV_MAX_STACK_SIZE

**Notes**:

- The parameter is copied internally to handle constant values passed at initialization
- Capacity is clamped to valid range automatically

**Example**:

```netlinx
stack_var _NAVStackString myStack
NAVStackInitString(myStack, 25)  // Initialize with capacity of 25
NAVStackInitString(myStack, 0)   // Defaults to NAV_MAX_STACK_SIZE (500)
```

#### `NAVStackPushString`

**Purpose**: Push a string item onto the top of the stack.

**Signature**: `char NAVStackPushString(_NAVStackString stack, char item[])`

**Parameters**:

- `stack` - Stack instance to push to (passed by reference)
- `item` - String item to push onto the stack

**Returns**: `true` if successful, `false` if stack is full

**Example**:

```netlinx
if (NAVStackPushString(myStack, 'New Command')) {
    send_string 0, "'Command added to stack'"
} else {
    send_string 0, "'Stack is full - command rejected'"
}
```

#### `NAVStackPopString`

**Purpose**: Pop and remove the top item from the stack.

**Signature**: `char[NAV_MAX_BUFFER] NAVStackPopString(_NAVStackString stack)`

**Parameters**:

- `stack` - Stack instance to pop from (passed by reference)

**Returns**: Top item from the stack, or empty string if stack is empty

**Example**:

```netlinx
stack_var char cmd[NAV_MAX_BUFFER]

if (NAVStackHasItems(myStack.Properties)) {
    cmd = NAVStackPopString(myStack)
    processCommand(cmd)
}
```

#### `NAVStackPeekString`

**Purpose**: View the top item without removing it from the stack.

**Signature**: `char[NAV_MAX_BUFFER] NAVStackPeekString(_NAVStackString stack)`

**Parameters**:

- `stack` - Stack instance to peek at

**Returns**: Top item from the stack, or empty string if stack is empty

**Example**:

```netlinx
stack_var char nextCmd[NAV_MAX_BUFFER]
nextCmd = NAVStackPeekString(myStack)
send_string 0, "'Next command will be: ', nextCmd"
```

### Integer Stack Functions

#### `NAVStackInitInteger`

**Purpose**: Initialize an integer stack with specified capacity.

**Signature**: `NAVStackInitInteger(_NAVStackInteger stack, integer initCapacity)`

**Parameters**:

- `stack` - Stack instance to initialize (passed by reference)
- `initCapacity` - Maximum number of items the stack can hold. If <= 0 or > NAV_MAX_STACK_SIZE, defaults to NAV_MAX_STACK_SIZE

**Notes**:

- The parameter is copied internally to handle constant values passed at initialization
- Capacity is clamped to valid range automatically

**Example**:

```netlinx
stack_var _NAVStackInteger myStack
NAVStackInitInteger(myStack, 50)  // Initialize with capacity of 50
NAVStackInitInteger(myStack, 0)   // Defaults to NAV_MAX_STACK_SIZE (500)
```

#### `NAVStackPushInteger`

**Purpose**: Push an integer item onto the top of the stack.

**Signature**: `char NAVStackPushInteger(_NAVStackInteger stack, integer item)`

**Parameters**:

- `stack` - Stack instance to push to (passed by reference)
- `item` - Integer item to push onto the stack

**Returns**: `true` if successful, `false` if stack is full

**Example**:

```netlinx
if (NAVStackPushInteger(myStack, 42)) {
    send_string 0, "'Value added to stack'"
} else {
    send_string 0, "'Stack is full'"
}
```

#### `NAVStackPopInteger`

**Purpose**: Pop and remove the top item from the stack.

**Signature**: `integer NAVStackPopInteger(_NAVStackInteger stack)`

**Parameters**:

- `stack` - Stack instance to pop from (passed by reference)

**Returns**: Top item from the stack, or 0 if stack is empty

**Example**:

```netlinx
stack_var integer value

if (NAVStackHasItems(myStack.Properties)) {
    value = NAVStackPopInteger(myStack)
    send_string 0, "'Popped value: ', itoa(value)"
}
```

#### `NAVStackPeekInteger`

**Purpose**: View the top item without removing it from the stack.

**Signature**: `integer NAVStackPeekInteger(_NAVStackInteger stack)`

**Parameters**:

- `stack` - Stack instance to peek at

**Returns**: Top item from the stack, or 0 if stack is empty

**Example**:

```netlinx
stack_var integer nextValue
nextValue = NAVStackPeekInteger(myStack)
send_string 0, "'Next value will be: ', itoa(nextValue)"
```

### State Management Functions

These functions work with both string and integer stacks by accepting the `_NAVStackProperties` structure.

#### `NAVStackIsEmpty`

**Purpose**: Check if the stack is empty.

**Signature**: `sinteger NAVStackIsEmpty(_NAVStackProperties properties)`

**Parameters**:

- `properties` - Stack properties structure

**Returns**: `1` if empty, `0` if has items

**Example**:

```netlinx
if (NAVStackIsEmpty(myStack.Properties)) {
    send_string 0, "'Stack is empty'"
}
```

#### `NAVStackHasItems`

**Purpose**: Check if the stack contains one or more items.

**Signature**: `sinteger NAVStackHasItems(_NAVStackProperties properties)`

**Parameters**:

- `properties` - Stack properties structure

**Returns**: `1` if has items, `0` if empty

**Example**:

```netlinx
if (NAVStackHasItems(myStack.Properties)) {
    processTopItem()
}
```

#### `NAVStackIsFull`

**Purpose**: Check if the stack has reached maximum capacity.

**Signature**: `sinteger NAVStackIsFull(_NAVStackProperties properties)`

**Parameters**:

- `properties` - Stack properties structure

**Returns**: `1` if full, `0` if space available

**Example**:

```netlinx
if (!NAVStackIsFull(myStack.Properties)) {
    NAVStackPushString(myStack, newItem)
} else {
    send_string 0, "'Cannot add item - stack is full'"
}
```

#### `NAVStackGetCount`

**Purpose**: Get the current number of items in the stack.

**Signature**: `integer NAVStackGetCount(_NAVStackProperties properties)`

**Parameters**:

- `properties` - Stack properties structure

**Returns**: Current item count (0 to capacity)

**Example**:

```netlinx
stack_var integer count
count = NAVStackGetCount(myStack.Properties)
send_string 0, "'Stack has ', itoa(count), ' items'"
```

#### `NAVStackGetCapacity`

**Purpose**: Get the maximum capacity of the stack.

**Signature**: `integer NAVStackGetCapacity(_NAVStackProperties properties)`

**Parameters**:

- `properties` - Stack properties structure

**Returns**: Maximum capacity set during initialization

**Example**:

```netlinx
stack_var integer capacity, count
capacity = NAVStackGetCapacity(myStack.Properties)
count = NAVStackGetCount(myStack.Properties)
send_string 0, "'Stack usage: ', itoa(count), '/', itoa(capacity)"
```

## Common Use Cases

### Undo/Redo Functionality

```netlinx
DEFINE_VARIABLE
volatile _NAVStackString undoStack
volatile _NAVStackString redoStack

DEFINE_START
NAVStackInitString(undoStack, 50)
NAVStackInitString(redoStack, 50)

DEFINE_FUNCTION executeAction(char action[]) {
    stack_var char previousState[NAV_MAX_BUFFER]

    // Save current state to undo stack
    previousState = getCurrentState()
    NAVStackPushString(undoStack, previousState)

    // Clear redo stack when new action is performed
    while (NAVStackHasItems(redoStack.Properties)) {
        NAVStackPopString(redoStack)
    }

    // Execute the action
    applyAction(action)
}

DEFINE_FUNCTION undo() {
    stack_var char previousState[NAV_MAX_BUFFER]
    stack_var char currentState[NAV_MAX_BUFFER]

    if (!NAVStackHasItems(undoStack.Properties)) {
        send_string 0, "'Nothing to undo'"
        return
    }

    // Save current state to redo stack
    currentState = getCurrentState()
    NAVStackPushString(redoStack, currentState)

    // Restore previous state
    previousState = NAVStackPopString(undoStack)
    restoreState(previousState)
}

DEFINE_FUNCTION redo() {
    stack_var char nextState[NAV_MAX_BUFFER]
    stack_var char currentState[NAV_MAX_BUFFER]

    if (!NAVStackHasItems(redoStack.Properties)) {
        send_string 0, "'Nothing to redo'"
        return
    }

    // Save current state to undo stack
    currentState = getCurrentState()
    NAVStackPushString(undoStack, currentState)

    // Apply next state
    nextState = NAVStackPopString(redoStack)
    restoreState(nextState)
}
```

### Function Call Stack (Recursion Simulation)

```netlinx
DEFINE_VARIABLE
volatile _NAVStackInteger callStack
volatile _NAVStackString functionNames

DEFINE_START
NAVStackInitInteger(callStack, 100)
NAVStackInitString(functionNames, 100)

DEFINE_FUNCTION integer factorial(integer n) {
    stack_var integer result

    // Push current function call onto stack
    NAVStackPushInteger(callStack, n)
    NAVStackPushString(functionNames, "'factorial(', itoa(n), ')'")

    if (n <= 1) {
        result = 1
    } else {
        result = n * factorial(n - 1)
    }

    // Pop function call from stack
    NAVStackPopInteger(callStack)
    NAVStackPopString(functionNames)

    return result
}

DEFINE_FUNCTION showCallStack() {
    stack_var integer depth
    depth = NAVStackGetCount(callStack.Properties)
    send_string 0, "'Call stack depth: ', itoa(depth)"

    if (depth > 0) {
        send_string 0, "'Top of stack: ', NAVStackPeekString(functionNames)"
    }
}
```

### Command History Navigation

```netlinx
DEFINE_VARIABLE
volatile _NAVStackString commandHistory
volatile _NAVStackString tempStack
volatile integer historyPosition

DEFINE_START
NAVStackInitString(commandHistory, 100)
NAVStackInitString(tempStack, 100)
historyPosition = 0

DEFINE_FUNCTION addCommand(char cmd[]) {
    NAVStackPushString(commandHistory, cmd)
    historyPosition = 0
}

DEFINE_FUNCTION char[NAV_MAX_BUFFER] getPreviousCommand() {
    stack_var char cmd[NAV_MAX_BUFFER]

    if (!NAVStackHasItems(commandHistory.Properties)) {
        return ''
    }

    // Move command from history to temp stack
    cmd = NAVStackPopString(commandHistory)
    NAVStackPushString(tempStack, cmd)
    historyPosition++

    return cmd
}

DEFINE_FUNCTION char[NAV_MAX_BUFFER] getNextCommand() {
    stack_var char cmd[NAV_MAX_BUFFER]

    if (!NAVStackHasItems(tempStack.Properties)) {
        return ''
    }

    // Move command from temp back to history
    cmd = NAVStackPopString(tempStack)
    NAVStackPushString(commandHistory, cmd)
    historyPosition--

    return cmd
}

DEFINE_FUNCTION resetHistoryPosition() {
    stack_var char cmd[NAV_MAX_BUFFER]

    // Move all commands back to history stack
    while (NAVStackHasItems(tempStack.Properties)) {
        cmd = NAVStackPopString(tempStack)
        NAVStackPushString(commandHistory, cmd)
    }

    historyPosition = 0
}
```

### Expression Evaluation (Parenthesis Matching)

```netlinx
DEFINE_VARIABLE
volatile _NAVStackInteger parenStack

DEFINE_START
NAVStackInitInteger(parenStack, 50)

DEFINE_FUNCTION char isBalanced(char expression[]) {
    stack_var integer i
    stack_var char ch

    // Clear stack
    while (NAVStackHasItems(parenStack.Properties)) {
        NAVStackPopInteger(parenStack)
    }

    // Process each character
    for (i = 1; i <= length_array(expression); i++) {
        ch = expression[i]

        switch (ch) {
            case '(':
            case '[':
            case '{': {
                NAVStackPushInteger(parenStack, ch)
            }
            case ')': {
                if (NAVStackIsEmpty(parenStack.Properties) ||
                    NAVStackPopInteger(parenStack) != '(') {
                    return false
                }
            }
            case ']': {
                if (NAVStackIsEmpty(parenStack.Properties) ||
                    NAVStackPopInteger(parenStack) != '[') {
                    return false
                }
            }
            case '}': {
                if (NAVStackIsEmpty(parenStack.Properties) ||
                    NAVStackPopInteger(parenStack) != '{') {
                    return false
                }
            }
        }
    }

    // Expression is balanced if stack is empty
    return NAVStackIsEmpty(parenStack.Properties)
}
```

### State Machine with History

```netlinx
DEFINE_VARIABLE
volatile _NAVStackInteger stateStack
volatile integer currentState

DEFINE_CONSTANT
STATE_IDLE = 1
STATE_CONNECTING = 2
STATE_CONNECTED = 3
STATE_BUSY = 4
STATE_ERROR = 5

DEFINE_START
NAVStackInitInteger(stateStack, 20)
currentState = STATE_IDLE

DEFINE_FUNCTION pushState(integer newState) {
    // Save current state
    NAVStackPushInteger(stateStack, currentState)

    // Transition to new state
    currentState = newState
    send_string 0, "'State changed to: ', itoa(currentState)"
}

DEFINE_FUNCTION popState() {
    stack_var integer previousState

    if (!NAVStackHasItems(stateStack.Properties)) {
        send_string 0, "'No previous state available'"
        return
    }

    // Restore previous state
    previousState = NAVStackPopInteger(stateStack)
    currentState = previousState
    send_string 0, "'State restored to: ', itoa(currentState)"
}

DEFINE_FUNCTION handleConnection() {
    pushState(STATE_CONNECTING)

    // Simulate connection attempt
    wait 30 {
        if (connectionSuccessful) {
            popState()  // Return to previous state
            pushState(STATE_CONNECTED)
        } else {
            popState()  // Return to previous state
            pushState(STATE_ERROR)
        }
    }
}
```

## Stack vs Queue

While both are linear data structures, they differ in their access patterns:

| Feature          | Stack (LIFO)                       | Queue (FIFO)                           |
| ---------------- | ---------------------------------- | -------------------------------------- |
| Order            | Last-In-First-Out                  | First-In-First-Out                     |
| Add Operation    | Push (top)                         | Enqueue (rear)                         |
| Remove Operation | Pop (top)                          | Dequeue (front)                        |
| Best For         | Undo/Redo, Recursion, Backtracking | Task Processing, Buffering, Scheduling |

## Constants

### `NAV_MAX_STACK_SIZE`

Maximum capacity for a stack instance. Defaults to 500 items.

### `NAV_STACK_EMPTY`

Value indicating an empty stack (0). When `Top` equals this value, the stack contains no items.

## Types

### `_NAVStackString`

Stack structure for storing string items in LIFO order.

**Fields**:

- `Properties` - Stack state information
- `Items[NAV_MAX_STACK_SIZE][NAV_MAX_BUFFER]` - Array of string items

### `_NAVStackInteger`

Stack structure for storing integer items in LIFO order.

**Fields**:

- `Properties` - Stack state information
- `Items[NAV_MAX_STACK_SIZE]` - Array of integer items

### `_NAVStackProperties`

Internal structure maintaining stack state.

**Fields**:

- `Top` - Current position of top element (0 = empty)
- `Capacity` - Maximum number of items the stack can hold

## Error Handling

The Stack library includes built-in error handling:

- **Stack Overflow**: Attempting to push to a full stack logs an error and returns `false`
- **Stack Underflow**: Attempting to pop or peek from an empty stack logs an error and returns empty value
- **Empty String Warning**: Pushing an empty string logs a warning (but still adds it)
- **Invalid Capacity**: Initializing with invalid capacity automatically defaults to `NAV_MAX_STACK_SIZE`

All errors are logged using the NAVFoundation error logging system for debugging and monitoring.

## Best Practices

1. **Always Initialize**: Call `NAVStackInit*` before using a stack
2. **Check Before Pop**: Use `NAVStackHasItems()` before popping to avoid underflow
3. **Check Before Push**: Use `NAVStackIsFull()` before pushing critical items to avoid overflow
4. **Monitor Capacity**: Use `NAVStackGetCount()` to monitor usage patterns
5. **Choose Appropriate Size**: Set capacity based on expected maximum usage to optimize memory
6. **Use Peek for Inspection**: Use `NAVStackPeek*()` when you need to inspect without modifying the stack
7. **Type Safety**: Use the correct stack type (String vs Integer) for your data

## License

MIT License - Copyright (c) 2010-2026 Norgate AV
