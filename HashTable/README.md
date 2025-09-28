# NAVFoundation.HashTable

A high-performance hash table implementation for AMX NetLinx systems. This library provides a complete key-value store with polynomial rolling hash function, linear probing collision resolution, and optimized memory usage for embedded systems.

## Features

- **High Performance**: Polynomial rolling hash (base 37) with linear probing for optimal distribution
- **Scalable**: Configurable size up to 5000 items (~1.83MB memory footprint)
- **Memory Optimized**: Domain-specific string lengths (128-byte keys, 256-byte values)
- **Collision Resistant**: Advanced hash function minimizes clustering
- **Comprehensive API**: Full CRUD operations with utility functions
- **Error Handling**: Detailed error codes and diagnostic functions
- **Load Factor Monitoring**: Built-in performance tracking
- **Production Ready**: Extensively tested with 39 comprehensive tests

## Quick Start

### Basic Usage

```netlinx
#include 'NAVFoundation.HashTable.axi'

stack_var _NAVHashTable myTable
stack_var char value[NAV_HASH_TABLE_MAX_VALUE_LENGTH]

// Initialize the hash table
NAVHashTableInit(myTable)

// Add items
NAVHashTableAddItem(myTable, 'user_id', '12345')
NAVHashTableAddItem(myTable, 'session_token', 'abc123xyz')
NAVHashTableAddItem(myTable, 'device_name', 'Conference Room A')

// Retrieve values
value = NAVHashTableGetItemValue(myTable, 'user_id')        // Returns '12345'
value = NAVHashTableGetItemValue(myTable, 'device_name')    // Returns 'Conference Room A'

// Check if key exists
if (NAVHashTableContainsKey(myTable, 'session_token')) {
    // Key exists, safe to retrieve
}

// Remove items
NAVHashTableItemRemove(myTable, 'session_token')

// Clear entire table
NAVHashTableClear(myTable)
```

### Configuration Options

The library supports compile-time configuration via preprocessor directives:

```netlinx
// Custom hash table size (default: 5000)
#define NAV_HASH_TABLE_SIZE 10000

// Custom key length (default: 128)
#define NAV_HASH_TABLE_MAX_KEY_LENGTH 256

// Custom value length (default: 256)  
#define NAV_HASH_TABLE_MAX_VALUE_LENGTH 512

#include 'NAVFoundation.HashTable.axi'
```

## Performance Characteristics

### Memory Usage

| Configuration | Memory Usage | Recommended Max Items (70% load) |
|---------------|--------------|----------------------------------|
| Default (5000) | ~1.83 MB | 3,500 items |
| Small (1000) | ~375 KB | 700 items |
| Large (10000) | ~3.66 MB | 7,000 items |

### Hash Distribution

The polynomial rolling hash provides excellent key distribution:
- **Average case**: O(1) access time
- **Load factor**: Optimal performance below 70%
- **Collision rate**: <1% with diverse keys

## API Reference

### Core Functions

#### `NAVHashTableInit`
**Purpose**: Initialize an empty hash table.

**Signature**: `NAVHashTableInit(_NAVHashTable hashTable)`

**Parameters**:
- `hashTable` - Hash table structure to initialize

**Example**:
```netlinx
stack_var _NAVHashTable myTable
NAVHashTableInit(myTable)
```

#### `NAVHashTableAddItem`
**Purpose**: Add or update a key-value pair in the hash table.

**Signature**: `integer NAVHashTableAddItem(_NAVHashTable hashTable, char key[], char value[])`

**Parameters**:
- `hashTable` - Hash table to modify
- `key[]` - Key string (max 128 characters)
- `value[]` - Value string (max 256 characters)

**Returns**: `1` on success, `0` on failure

**Example**:
```netlinx
if (NAVHashTableAddItem(myTable, 'config_timeout', '30')) {
    // Successfully added
} else {
    // Handle error - table might be full
}
```

#### `NAVHashTableGetItemValue`
**Purpose**: Retrieve the value associated with a key.

**Signature**: `char[NAV_HASH_TABLE_MAX_VALUE_LENGTH] NAVHashTableGetItemValue(_NAVHashTable hashTable, char key[])`

**Parameters**:
- `hashTable` - Hash table to search
- `key[]` - Key to look up

**Returns**: Value string or empty string if key not found

**Example**:
```netlinx
stack_var char timeout[NAV_HASH_TABLE_MAX_VALUE_LENGTH]
timeout = NAVHashTableGetItemValue(myTable, 'config_timeout')
if (length_array(timeout)) {
    // Key found, use the value
}
```

#### `NAVHashTableContainsKey`
**Purpose**: Check if a key exists in the hash table.

**Signature**: `integer NAVHashTableContainsKey(_NAVHashTable hashTable, char key[])`

**Parameters**:
- `hashTable` - Hash table to search
- `key[]` - Key to check

**Returns**: `1` if key exists, `0` if not found

**Example**:
```netlinx
if (NAVHashTableContainsKey(myTable, 'user_preferences')) {
    // Key exists, safe to retrieve or update
}
```

#### `NAVHashTableItemRemove`
**Purpose**: Remove a key-value pair from the hash table.

**Signature**: `NAVHashTableItemRemove(_NAVHashTable hashTable, char key[])`

**Parameters**:
- `hashTable` - Hash table to modify
- `key[]` - Key to remove

**Example**:
```netlinx
NAVHashTableItemRemove(myTable, 'temporary_data')
```

### Utility Functions

#### `NAVHashTableGetItemCount`
**Purpose**: Get the current number of items in the hash table.

**Signature**: `integer NAVHashTableGetItemCount(_NAVHashTable hashTable)`

**Returns**: Number of key-value pairs currently stored

#### `NAVHashTableGetLoadFactor`
**Purpose**: Calculate the current load factor (percentage full).

**Signature**: `float NAVHashTableGetLoadFactor(_NAVHashTable hashTable)`

**Returns**: Load factor as decimal (0.0 to 1.0)

**Example**:
```netlinx
stack_var float loadFactor
loadFactor = NAVHashTableGetLoadFactor(myTable)
if (loadFactor > 0.7) {
    // Consider increasing table size
}
```

#### `NAVHashTableGetKeys`
**Purpose**: Retrieve all keys from the hash table.

**Signature**: `integer NAVHashTableGetKeys(_NAVHashTable hashTable, char keys[][NAV_HASH_TABLE_MAX_KEY_LENGTH], integer keysSize)`

**Parameters**:
- `hashTable` - Hash table to enumerate
- `keys[][]` - Array to store retrieved keys
- `keysSize` - Maximum number of keys to retrieve

**Returns**: Number of keys retrieved

#### `NAVHashTableGetValues`
**Purpose**: Retrieve all values from the hash table.

**Signature**: `integer NAVHashTableGetValues(_NAVHashTable hashTable, char values[][NAV_HASH_TABLE_MAX_VALUE_LENGTH], integer valuesSize)`

**Returns**: Number of values retrieved

#### `NAVHashTableClear`
**Purpose**: Remove all items from the hash table.

**Signature**: `NAVHashTableClear(_NAVHashTable hashTable)`

### Error Handling

#### `NAVHashTableGetLastError`
**Purpose**: Get the last error code from a hash table operation.

**Signature**: `integer NAVHashTableGetLastError(_NAVHashTable hashTable)`

**Returns**: Error code constant

#### `NAVHashTableGetErrorString`
**Purpose**: Convert error code to human-readable string.

**Signature**: `char[NAV_HASH_TABLE_MAX_VALUE_LENGTH] NAVHashTableGetErrorString(integer errorCode)`

**Error Codes**:
- `NAV_HASH_TABLE_ERROR_NONE` (0) - No error
- `NAV_HASH_TABLE_ERROR_EMPTY_KEY` (1) - Key cannot be empty
- `NAV_HASH_TABLE_ERROR_INVALID_HASH` (2) - Hash calculation failed
- `NAV_HASH_TABLE_ERROR_FULL` (3) - Hash table is full
- `NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND` (4) - Key does not exist
- `NAV_HASH_TABLE_ERROR_COLLISION` (5) - Hash collision occurred

**Example**:
```netlinx
if (!NAVHashTableAddItem(myTable, 'new_key', 'new_value')) {
    stack_var integer errorCode
    stack_var char errorMsg[NAV_HASH_TABLE_MAX_VALUE_LENGTH]
    
    errorCode = NAVHashTableGetLastError(myTable)
    errorMsg = NAVHashTableGetErrorString(errorCode)
    
    send_string 0, "'Hash table error: ', errorMsg"
}
```

### Advanced Functions

#### `NAVHashTableGetKeyHash`
**Purpose**: Calculate hash value for a given key (debugging/optimization).

**Signature**: `integer NAVHashTableGetKeyHash(char key[])`

#### `NAVHashTableDump`
**Purpose**: Print hash table contents to console for debugging.

**Signature**: `NAVHashTableDump(_NAVHashTable hashTable)`

## Best Practices

### Performance Optimization

1. **Monitor Load Factor**: Keep below 70% for optimal performance
   ```netlinx
   if (NAVHashTableGetLoadFactor(myTable) > 0.7) {
       // Consider increasing NAV_HASH_TABLE_SIZE
   }
   ```

2. **Use Descriptive Keys**: Diverse key patterns reduce collisions
   ```netlinx
   // Good - diverse prefixes
   NAVHashTableAddItem(table, 'device_001_status', 'online')
   NAVHashTableAddItem(table, 'user_admin_role', 'administrator')
   
   // Avoid - similar prefixes may cluster
   NAVHashTableAddItem(table, 'config_001', 'value1')
   NAVHashTableAddItem(table, 'config_002', 'value2')
   ```

3. **Check Existence Before Operations**:
   ```netlinx
   if (NAVHashTableContainsKey(table, key)) {
       value = NAVHashTableGetItemValue(table, key)
   }
   ```

### Memory Management

1. **Size Appropriately**: Choose table size based on expected data
   - Small datasets (<500 items): `NAV_HASH_TABLE_SIZE = 1000`
   - Medium datasets (<3500 items): `NAV_HASH_TABLE_SIZE = 5000` (default)
   - Large datasets (<7000 items): `NAV_HASH_TABLE_SIZE = 10000`

2. **String Length Optimization**: Adjust constants for your use case
   ```netlinx
   // For shorter keys/values, reduce memory usage
   #define NAV_HASH_TABLE_MAX_KEY_LENGTH 64
   #define NAV_HASH_TABLE_MAX_VALUE_LENGTH 128
   ```

### Error Handling

Always check return values and handle errors appropriately:

```netlinx
define_function char HandleHashTableOperation(_NAVHashTable table, char key[], char value[]) {
    if (!NAVHashTableAddItem(table, key, value)) {
        stack_var integer errorCode
        errorCode = NAVHashTableGetLastError(table)
        
        switch(errorCode) {
            case NAV_HASH_TABLE_ERROR_FULL: {
                send_string 0, 'Hash table is full - consider increasing size'
                return false
            }
            case NAV_HASH_TABLE_ERROR_EMPTY_KEY: {
                send_string 0, 'Key cannot be empty'
                return false
            }
            default: {
                send_string 0, "'Unknown hash table error: ', itoa(errorCode)"
                return false
            }
        }
    }
    return true
}
```

## Testing

The library includes comprehensive test coverage with 39 test functions across 11 modules:

- **Core functionality tests** (7 functions)
- **Performance and load tests** (6 functions)  
- **Boundary condition tests** (5 functions)
- **Error handling tests** (4 functions)
- **Collision resolution tests** (3 functions)
- **Memory management tests** (3 functions)
- **Integration tests** (4 functions)
- **Utility function tests** (4 functions)
- **Edge case tests** (3 functions)

## Configuration Reference

### Compile-time Constants

```netlinx
// Hash table size (number of slots)
#define NAV_HASH_TABLE_SIZE 5000

// Maximum key length in characters
#define NAV_HASH_TABLE_MAX_KEY_LENGTH 128

// Maximum value length in characters  
#define NAV_HASH_TABLE_MAX_VALUE_LENGTH 256

// Recommended maximum items (load factor)
#define NAV_MAX_HASH_TABLE_ITEMS (NAV_HASH_TABLE_SIZE / 2)
```

### Memory Planning

Use this formula to estimate memory usage:

```
Memory = NAV_HASH_TABLE_SIZE × (NAV_HASH_TABLE_MAX_KEY_LENGTH + NAV_HASH_TABLE_MAX_VALUE_LENGTH) + 8 bytes
```

Examples:
- Default (5000 × 384 + 8) = ~1.83 MB
- Small (1000 × 384 + 8) = ~375 KB  
- Large (10000 × 384 + 8) = ~3.66 MB

## License

This library is part of the NAVFoundation framework. See the main project LICENSE file for details.
