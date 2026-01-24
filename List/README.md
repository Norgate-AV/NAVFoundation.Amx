# NAVFoundation.List

A dynamic string list implementation for AMX NetLinx systems. This library provides a contiguous array-based list with automatic element shifting, comprehensive bounds checking, and full CRUD operations for managing ordered collections of string data.

## Features

- **Dynamic List Management**: Add, insert, remove, and modify string elements
- **Configurable Capacity**: Support for lists up to 100 items (customizable via NAV_MAX_LIST_SIZE)
- **Contiguous Storage**: Automatic element shifting maintains data continuity
- **Full CRUD Operations**: Create, Read, Update, Delete with bounds checking
- **Search Operations**: Find items by value or index
- **Array Conversion**: Seamless conversion to/from NetLinx arrays
- **Safe Access**: Reference-based getters prevent accidental modifications
- **Production Ready**: Extensively tested with 144 comprehensive tests

## Quick Start

### Basic Usage

```netlinx
#include 'NAVFoundation.List.axi'

stack_var _NAVList todoList
stack_var char item[NAV_MAX_LIST_ITEM_LENGTH]

// Initialize the list with capacity
NAVListInit(todoList, 20)

// Add items to the list
NAVListAdd(todoList, 'Task 1: Review code')
NAVListAdd(todoList, 'Task 2: Write tests')
NAVListAdd(todoList, 'Task 3: Deploy')

// Insert an item at a specific position
NAVListInsert(todoList, 2, 'Task 1.5: Code review meeting')

// Get an item by index
if (NAVListGet(todoList, 1, item)) {
    send_string 0, "'First task: ', item"
}

// Update an existing item
NAVListSet(todoList, 3, 'Task 2: Write unit tests')

// Check list state
send_string 0, "'List has ', itoa(NAVListSize(todoList)), ' items'"
send_string 0, "'List capacity: ', itoa(NAVListCapacity(todoList))"

// Search for an item
stack_var integer index
index = NAVListIndexOf(todoList, 'Task 3: Deploy')
if (index > 0) {
    send_string 0, "'Deploy task is at position ', itoa(index)"
}

// Remove specific item
NAVListRemoveItem(todoList, 'Task 1.5: Code review meeting')

// Remove by index
NAVListRemove(todoList, 1)

// Get first and last items
NAVListFirst(todoList, item)  // First item
NAVListLast(todoList, item)   // Last item

// Pop last item off the list
NAVListPop(todoList, item)    // Returns and removes last item

// Clear all items
NAVListClear(todoList)
```

## Performance Characteristics

### Memory Usage

| Configuration                       | Memory per List | Typical Use Case  |
| ----------------------------------- | --------------- | ----------------- |
| 10 items × 255 chars                | ~2.5 KB         | Command sequences |
| 50 items × 255 chars                | ~12.5 KB        | Message buffers   |
| 100 items × 255 chars (default max) | ~25 KB          | Data collections  |

**Note**: Memory usage can be customized by changing `NAV_MAX_LIST_SIZE` and `NAV_MAX_LIST_ITEM_LENGTH` constants.

### Complexity

| Operation    | Complexity | Notes                  |
| ------------ | ---------- | ---------------------- |
| Add (append) | O(1)       | Constant time          |
| Insert       | O(n)       | Linear due to shifting |
| Remove       | O(n)       | Linear due to shifting |
| Get/Set      | O(1)       | Direct array access    |
| Search       | O(n)       | Linear search          |
| Clear        | O(1)       | Count reset only       |

## Configuration

The List library uses two configurable constants in `NAVFoundation.List.h.axi`:

```netlinx
// Maximum number of items in a list (default: 100)
#IF_NOT_DEFINED NAV_MAX_LIST_SIZE
    DEFINE_CONSTANT integer NAV_MAX_LIST_SIZE = 100
#END_IF

// Maximum length of each string item (default: 255)
#IF_NOT_DEFINED NAV_MAX_LIST_ITEM_LENGTH
    DEFINE_CONSTANT integer NAV_MAX_LIST_ITEM_LENGTH = 255
#END_IF
```

To customize, define these constants **before** including the List library:

```netlinx
DEFINE_CONSTANT
integer NAV_MAX_LIST_SIZE = 200        // Support up to 200 items
integer NAV_MAX_LIST_ITEM_LENGTH = 512 // Support longer strings

#include 'NAVFoundation.List.axi'
```

## API Reference

### Initialization

#### `NAVListInit`

**Purpose**: Initialize a list with a specified capacity.

**Signature**: `NAVListInit(_NAVList list, integer initCapacity)`

**Parameters**:

- `list` - List structure to initialize
- `initCapacity` - Maximum number of items. If < 1, defaults to 1. If > NAV_MAX_LIST_SIZE, defaults to NAV_MAX_LIST_SIZE.

**Notes**:

- The parameter is copied internally to handle constant values passed at initialization
- Capacity is automatically clamped to valid range (1 to NAV_MAX_LIST_SIZE)
- Must be called before using any other list operations

**Example**:

```netlinx
stack_var _NAVList myList
NAVListInit(myList, 50)  // Initialize with capacity of 50
NAVListInit(myList, 0)   // Defaults to capacity of 1
NAVListInit(myList, 200) // Clamped to NAV_MAX_LIST_SIZE (100)
```

---

### Adding Items

#### `NAVListAdd`

**Purpose**: Append an item to the end of the list.

**Signature**: `char NAVListAdd(_NAVList list, char item[])`

**Parameters**:

- `list` - List to add to
- `item[]` - String item to append

**Returns**: `true` on success, `false` if list is full

**Example**:

```netlinx
if (NAVListAdd(myList, 'New Item')) {
    send_string 0, "'Item added successfully'"
} else {
    send_string 0, "'List is full'"
}
```

#### `NAVListInsert`

**Purpose**: Insert an item at a specific position, shifting subsequent elements right.

**Signature**: `char NAVListInsert(_NAVList list, integer index, char item[])`

**Parameters**:

- `list` - List to insert into
- `index` - Position to insert at (1-based). Must be between 1 and count+1
- `item[]` - String item to insert

**Returns**: `true` on success, `false` if list is full or index is invalid

**Example**:

```netlinx
// Insert at beginning
NAVListInsert(myList, 1, 'First Item')

// Insert in middle (after 2nd item)
NAVListInsert(myList, 3, 'Middle Item')

// Insert at end (same as Add if index = count+1)
NAVListInsert(myList, NAVListSize(myList) + 1, 'Last Item')
```

---

### Removing Items

#### `NAVListRemove`

**Purpose**: Remove the item at a specific index, shifting subsequent elements left.

**Signature**: `char NAVListRemove(_NAVList list, integer index)`

**Parameters**:

- `list` - List to remove from
- `index` - Position to remove from (1-based)

**Returns**: `true` on success, `false` if index is invalid

**Example**:

```netlinx
// Remove first item
NAVListRemove(myList, 1)

// Remove last item
NAVListRemove(myList, NAVListSize(myList))

// Remove specific position
NAVListRemove(myList, 5)
```

#### `NAVListRemoveItem`

**Purpose**: Remove the first occurrence of a specific item.

**Signature**: `char NAVListRemoveItem(_NAVList list, char item[])`

**Parameters**:

- `list` - List to remove from
- `item[]` - Item to search for and remove

**Returns**: `true` if item was found and removed, `false` if not found

**Example**:

```netlinx
if (NAVListRemoveItem(myList, 'Remove Me')) {
    send_string 0, "'Item removed'"
} else {
    send_string 0, "'Item not found'"
}
```

#### `NAVListPop`

**Purpose**: Remove and return the last item from the list.

**Signature**: `char NAVListPop(_NAVList list, char result[])`

**Parameters**:

- `list` - List to pop from
- `result[]` - Output parameter that receives the popped item

**Returns**: `true` on success, `false` if list is empty

**Example**:

```netlinx
stack_var char lastItem[NAV_MAX_LIST_ITEM_LENGTH]
if (NAVListPop(myList, lastItem)) {
    send_string 0, "'Popped: ', lastItem"
}
```

#### `NAVListClear`

**Purpose**: Remove all items from the list (resets count to 0).

**Signature**: `NAVListClear(_NAVList list)`

**Parameters**:

- `list` - List to clear

**Example**:

```netlinx
NAVListClear(myList)
// List is now empty but capacity remains unchanged
```

---

### Accessing Items

#### `NAVListGet`

**Purpose**: Retrieve the item at a specific index without removing it.

**Signature**: `char NAVListGet(_NAVList list, integer index, char result[])`

**Parameters**:

- `list` - List to get from
- `index` - Position to retrieve from (1-based)
- `result[]` - Output parameter that receives the item

**Returns**: `true` on success, `false` if index is invalid

**Example**:

```netlinx
stack_var char item[NAV_MAX_LIST_ITEM_LENGTH]
if (NAVListGet(myList, 3, item)) {
    send_string 0, "'Item at position 3: ', item"
}
```

#### `NAVListSet`

**Purpose**: Replace the item at a specific index with a new value.

**Signature**: `char NAVListSet(_NAVList list, integer index, char item[])`

**Parameters**:

- `list` - List to modify
- `index` - Position to update (1-based)
- `item[]` - New value

**Returns**: `true` on success, `false` if index is invalid

**Example**:

```netlinx
// Update existing item
NAVListSet(myList, 1, 'Updated First Item')
```

#### `NAVListFirst`

**Purpose**: Retrieve the first item in the list.

**Signature**: `char NAVListFirst(_NAVList list, char result[])`

**Parameters**:

- `list` - List to get from
- `result[]` - Output parameter that receives the first item

**Returns**: `true` on success, `false` if list is empty

**Example**:

```netlinx
stack_var char firstItem[NAV_MAX_LIST_ITEM_LENGTH]
if (NAVListFirst(myList, firstItem)) {
    send_string 0, "'First: ', firstItem"
}
```

#### `NAVListLast`

**Purpose**: Retrieve the last item in the list.

**Signature**: `char NAVListLast(_NAVList list, char result[])`

**Parameters**:

- `list` - List to get from
- `result[]` - Output parameter that receives the last item

**Returns**: `true` on success, `false` if list is empty

**Example**:

```netlinx
stack_var char lastItem[NAV_MAX_LIST_ITEM_LENGTH]
if (NAVListLast(myList, lastItem)) {
    send_string 0, "'Last: ', lastItem"
}
```

---

### Querying State

#### `NAVListSize`

**Purpose**: Get the current number of items in the list.

**Signature**: `integer NAVListSize(_NAVList list)`

**Parameters**:

- `list` - List to query

**Returns**: Current count of items

**Example**:

```netlinx
stack_var integer count
count = NAVListSize(myList)
send_string 0, "'List has ', itoa(count), ' items'"
```

#### `NAVListCapacity`

**Purpose**: Get the maximum capacity of the list.

**Signature**: `integer NAVListCapacity(_NAVList list)`

**Parameters**:

- `list` - List to query

**Returns**: Maximum capacity

**Example**:

```netlinx
stack_var integer maxSize
maxSize = NAVListCapacity(myList)
send_string 0, "'List can hold up to ', itoa(maxSize), ' items'"
```

#### `NAVListIsEmpty`

**Purpose**: Check if the list has no items.

**Signature**: `char NAVListIsEmpty(_NAVList list)`

**Parameters**:

- `list` - List to check

**Returns**: `true` if empty, `false` otherwise

**Example**:

```netlinx
if (NAVListIsEmpty(myList)) {
    send_string 0, "'List is empty'"
}
```

#### `NAVListIsFull`

**Purpose**: Check if the list is at maximum capacity.

**Signature**: `char NAVListIsFull(_NAVList list)`

**Parameters**:

- `list` - List to check

**Returns**: `true` if full, `false` otherwise

**Example**:

```netlinx
if (!NAVListIsFull(myList)) {
    NAVListAdd(myList, 'New Item')
} else {
    send_string 0, "'Cannot add - list is full'"
}
```

---

### Searching

#### `NAVListContains`

**Purpose**: Check if a specific item exists in the list.

**Signature**: `char NAVListContains(_NAVList list, char item[])`

**Parameters**:

- `list` - List to search
- `item[]` - Item to search for

**Returns**: `true` if item exists, `false` otherwise

**Example**:

```netlinx
if (NAVListContains(myList, 'Target Item')) {
    send_string 0, "'Item found in list'"
}
```

#### `NAVListIndexOf`

**Purpose**: Find the index of the first occurrence of a specific item.

**Signature**: `integer NAVListIndexOf(_NAVList list, char item[])`

**Parameters**:

- `list` - List to search
- `item[]` - Item to search for

**Returns**: 1-based index of item, or 0 if not found

**Example**:

```netlinx
stack_var integer index
index = NAVListIndexOf(myList, 'Search Item')
if (index > 0) {
    send_string 0, "'Found at position ', itoa(index)"
} else {
    send_string 0, "'Not found'"
}
```

---

### Array Conversion

#### `NAVListToArray`

**Purpose**: Copy all list items to a standard NetLinx array.

**Signature**: `char NAVListToArray(_NAVList list, char result[][])`

**Parameters**:

- `list` - List to copy from
- `result[][]` - Output 2D array (length will be set automatically via `set_length_array`)

**Returns**: `true` on success, `false` if list is empty

**Example**:

```netlinx
stack_var char myArray[100][NAV_MAX_LIST_ITEM_LENGTH]
if (NAVListToArray(myList, myArray)) {
    // myArray now contains all list items
    // length_array(myArray) equals NAVListSize(myList)

    stack_var integer i
    for (i = 1; i <= length_array(myArray); i++) {
        send_string 0, "'Item ', itoa(i), ': ', myArray[i]"
    }
}
```

#### `NAVListFromArray`

**Purpose**: Initialize a list from a standard NetLinx array.

**Signature**: `char NAVListFromArray(_NAVList list, char items[][])`

**Parameters**:

- `list` - List to initialize (must already have capacity set via NAVListInit)
- `items[][]` - Source 2D array (uses `length_array` to determine count)

**Returns**: `true` on success, `false` if array length exceeds list capacity

**Example**:

```netlinx
stack_var char sourceArray[5][50]
stack_var _NAVList myList

// Prepare source array
sourceArray[1] = 'First'
sourceArray[2] = 'Second'
sourceArray[3] = 'Third'
sourceArray[4] = 'Fourth'
sourceArray[5] = 'Fifth'
set_length_array(sourceArray, 5)

// Initialize list with sufficient capacity
NAVListInit(myList, 10)

// Convert array to list
if (NAVListFromArray(myList, sourceArray)) {
    send_string 0, "'List now has ', itoa(NAVListSize(myList)), ' items'"
}
```

---

## Common Patterns

### Iterating Through a List

```netlinx
stack_var _NAVList myList
stack_var char item[NAV_MAX_LIST_ITEM_LENGTH]
stack_var integer i

for (i = 1; i <= NAVListSize(myList); i++) {
    NAVListGet(myList, i, item)
    send_string 0, "'Item ', itoa(i), ': ', item"
}
```

### Building a List from User Input

```netlinx
define_function AddToList(_NAVList list, char input[]) {
    if (NAVListIsFull(list)) {
        send_string 0, "'List is full - cannot add more items'"
        return
    }

    if (NAVListAdd(list, input)) {
        send_string 0, "'Added: ', input"
        send_string 0, "'List now has ', itoa(NAVListSize(list)), ' items'"
    }
}
```

### Removing All Occurrences of an Item

```netlinx
define_function RemoveAllOccurrences(_NAVList list, char item[]) {
    stack_var integer removed
    removed = 0

    while (NAVListContains(list, item)) {
        NAVListRemoveItem(list, item)
        removed++
    }

    send_string 0, "'Removed ', itoa(removed), ' occurrences'"
}
```

### Safely Processing and Removing Items

```netlinx
define_function ProcessList(_NAVList list) {
    stack_var char item[NAV_MAX_LIST_ITEM_LENGTH]

    while (!NAVListIsEmpty(list)) {
        if (NAVListPop(list, item)) {
            // Process the item
            send_string dvDevice, item
            wait 10 {
                // Continue with next item after delay
            }
        }
    }
}
```

### Finding and Updating Items

```netlinx
define_function UpdateItem(_NAVList list, char oldValue[], char newValue[]) {
    stack_var integer index

    index = NAVListIndexOf(list, oldValue)
    if (index > 0) {
        if (NAVListSet(list, index, newValue)) {
            send_string 0, "'Updated item at position ', itoa(index)"
        }
    } else {
        send_string 0, "'Item not found'"
    }
}
```

---

## Implementation Details

### Storage Model

The List uses a **contiguous array** storage model where:

- Items are stored sequentially in a fixed-size array
- Empty spaces are automatically eliminated through element shifting
- All elements remain contiguous (no gaps)

### Element Shifting

- **Insert**: Elements from insertion point to end shift right
- **Remove**: Elements after removal point shift left
- This maintains data continuity but has O(n) time complexity

### Index Bounds

- All indices are **1-based** (NetLinx convention)
- Valid range: 1 to `list.count`
- Insert accepts: 1 to `list.count + 1` (allows append)
- All operations check bounds and log errors for invalid indices

### Capacity vs Count

- **Capacity**: Maximum number of items (set at initialization, immutable)
- **Count**: Current number of items (changes with add/remove)
- Capacity remains constant regardless of count

### Error Handling

All operations that can fail return boolean success indicators and log descriptive errors via `NAVLibraryFunctionErrorLog`.

---

## Testing

The List library includes comprehensive test coverage with 144 tests across all operations:

- **Initialization**: Capacity clamping, count reset
- **Addition**: Add, insert at various positions
- **Removal**: Remove by index, remove by value, pop
- **Access**: Get, set, first, last
- **State Queries**: Size, capacity, empty, full
- **Search**: Contains, indexOf
- **Conversion**: ToArray, FromArray, clear
- **Edge Cases**: Empty lists, full lists, invalid indices, duplicates

All tests verify both return values and actual state changes.

---

## License

MIT License - Copyright (c) 2010-2026 Norgate AV

---

## See Also

- [NAVFoundation.Queue](../Queue/README.md) - FIFO queue implementation
- [NAVFoundation.Stack](../Stack/README.md) - LIFO stack implementation
- [NAVFoundation.HashTable](../HashTable/README.md) - Key-value storage
