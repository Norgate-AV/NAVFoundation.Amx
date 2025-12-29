# NAVFoundation.ArrayUtils

The ArrayUtils library for NAVFoundation provides comprehensive utilities for working with arrays in NetLinx programming. It includes functions for array manipulation, searching, sorting, set operations, and common array algorithms.

## Overview

Working with arrays in NetLinx can be challenging due to limited built-in functionality. This library bridges that gap by providing robust, well-tested functions for performing common operations on arrays of different data types.

## Features

- **Array Manipulation**: Set/fill, copy, reverse, slice operations
- **Array Searching**: Linear search, binary search, ternary search, jump search, exponential search
- **Array Sorting**: Bubble sort, selection sort, insertion sort, quick sort, merge sort, counting sort
- **Set Operations**: Specialized data structures for all primitive types that prevent duplicates
- **Array Analysis**: Sum, average, check if sorted
- **String Array Operations**: Case conversion, trimming

## Array Manipulation Functions

### Setting Array Values

```netlinx
NAVSetArrayChar(charArray, $FF)            // Sets all elements to $FF
NAVSetArrayInteger(intArray, 42)           // Sets all elements to 42
NAVSetArrayString(stringArray, 'Default')  // Sets all elements to "Default"
```

### Array Copying

```netlinx
NAVArrayCopyInteger(sourceArray, destinationArray)  // Copies integer array
NAVArrayCopyString(sourceArray, destinationArray)   // Copies string array
```

### Array Reversal

```netlinx
NAVArrayReverseInteger(intArray)   // Reverses integer array in-place
NAVArrayReverseString(stringArray) // Reverses string array in-place
```

### Array Slicing

```netlinx
NAVArraySliceInteger(sourceArray, 1, 3, resultArray) // Creates slice from index 1 to 3
NAVArraySliceString(sourceArray, 2, 5, resultArray)  // Creates slice from index 2 to 5
```

## Array Searching Functions

### Linear Search

```netlinx
index = NAVFindInArrayINTEGER(intArray, 42)  // Returns index of first occurrence of 42
index = NAVFindInArraySTRING(stringArray, 'Hello') // Returns index of "Hello"
```

### Binary Search (for sorted arrays)

```netlinx
// Requires sorted array
index = NAVArrayBinarySearchIntegerIterative(sortedArray, 42)
index = NAVArrayBinarySearchIntegerRecursive(sortedArray, 42)
```

### Advanced Searches

```netlinx
index = NAVArrayTernarySearchInteger(sortedArray, 42)
index = NAVArrayJumpSearchInteger(sortedArray, 42)
index = NAVArrayExponentialSearchInteger(sortedArray, 42)
```

## Array Sorting Functions

### Basic Sorting

```netlinx
NAVArrayBubbleSortInteger(intArray)      // Simple but inefficient for large arrays
NAVArraySelectionSortInteger(intArray)   // Simple selection sort
NAVArrayInsertionSortInteger(intArray)   // Good for nearly sorted data
```

### Advanced Sorting

```netlinx
NAVArrayQuickSortInteger(intArray)                // Efficient divide-and-conquer sort
NAVArrayMergeSortInteger(intArray)                // Stable, efficient sort
NAVArrayCountingSortInteger(intArray, maxValue)   // Efficient for small integer ranges
                                                  // maxValue should be the maximum value in array
```

### String Sorting

```netlinx
NAVArraySelectionSortString(stringArray) // Sort strings alphabetically
```

## Set Operations

Each set type prevents duplicate values and provides efficient lookup operations.

### Creation and Initialization

```netlinx
stack_var _NAVArrayIntegerSet integerSet
NAVArrayIntegerSetInit(integerSet, 50) // Initialize with capacity 50

// Initialize from existing array
NAVArrayIntegerSetFrom(integerSet, existingArray)
```

### Set Operations

```netlinx
// Adding values
NAVArrayIntegerSetAdd(integerSet, 42)

// Checking if value exists
isPresent = NAVArrayIntegerSetContains(integerSet, 42)

// Removing values
NAVArrayIntegerSetRemove(integerSet, 42)
```

### Supported Set Types

- `_NAVArrayCharSet` - For char values
- `_NAVArrayIntegerSet` - For integer values
- `_NAVArraySignedIntegerSet` - For signed integer values
- `_NAVArrayLongSet` - For long values
- `_NAVArraySignedLongSet` - For signed long values
- `_NAVArrayFloatSet` - For float values
- `_NAVArrayDoubleSet` - For double values
- `_NAVArrayStringSet` - For string values

## Array Analysis

### Statistics

```netlinx
sum = NAVArraySumInteger(intArray)            // Calculate sum of array
average = NAVArrayAverageInteger(intArray)    // Calculate average of array

// Also available for: SignedInteger, Long, SignedLong, Float, Double
```

### Array Characteristics

```netlinx
isSorted = NAVArrayIsSortedInteger(intArray)             // Check if sorted (ascending)
isSorted = NAVArrayIsSortedAscendingInteger(intArray)    // Check if sorted ascending
isSortedDesc = NAVArrayIsSortedDescendingInteger(intArray) // Check if sorted descending
```

### Array Element Swapping

```netlinx
NAVArraySwapInteger(intArray, 1, 3)      // Swap elements at index 1 and 3
NAVArraySwapString(stringArray, 2, 5)    // Swap string elements at index 2 and 5
```

## String Array Operations

```netlinx
NAVArrayToUpperString(stringArray)   // Convert all strings to uppercase
NAVArrayToLowerString(stringArray)   // Convert all strings to lowercase
NAVArrayTrimString(stringArray)      // Trim whitespace from all strings
```

## Debugging Utilities

```netlinx
NAVPrintArrayInteger(intArray)   // Print integer array to debug log
NAVPrintArrayString(stringArray) // Print string array to debug log
```

## Performance Considerations

- For small arrays (fewer than 50 elements), simple sorts like bubble or insertion sort may be sufficient
- For larger arrays, prefer quick sort or merge sort
- Binary search is significantly faster than linear search for sorted arrays
- For frequent lookups, consider using set data structures instead of arrays
- Counting sort requires knowledge of the maximum value in the array, but is very efficient for small integer ranges

## Important Usage Notes

### Array Length Management

When working with stack arrays in NetLinx, you should always use `set_length_array()` after populating the array to ensure the length is properly set:

```netlinx
stack_var integer values[10]
values[1] = 5
values[2] = 3
values[3] = 8
set_length_array(values, 3)  // Important: Set the length explicitly
```

Without calling `set_length_array()`, many array functions may not work correctly because `length_array()` will return 0 for unpopulated stack arrays.

### Function Name Conventions

Most find and search functions use ALL CAPS for the data type in the function name:

- `NAVFindInArrayINTEGER()` (not `NAVFindInArrayInteger()`)
- `NAVFindInArraySTRING()` (not `NAVFindInArrayString()`)
- `NAVFindInArrayCHAR()`, `NAVFindInArrayLONG()`, etc.

This matches the NetLinx naming convention for these fundamental search operations.

## Complete API Reference

The library provides array functions for the following types:

- char
- integer / sinteger
- long / slong
- float / double
- string (char[][])
- device (dev)

For each type, most of these operations are available:

- Setting values
- Finding elements
- Sorting
- Analyzing (sum, average)
- Set operations (add, remove, contains)

For detailed function signatures and descriptions, refer to the comprehensive documentation in the source files.

## Example: Working with Integer Arrays

```netlinx
// Initialize and fill an array
stack_var integer values[10]
NAVSetArrayInteger(values, 0) // Fill with zeros

// Add some values
values[1] = 5
values[2] = 3
values[3] = 8
values[4] = 1
values[5] = 9
set_length_array(values, 5) // Set array length to actual data size

// Sort the array
NAVArrayQuickSortInteger(values)
// values is now {1, 3, 5, 8, 9}

// Search for a value
index = NAVArrayBinarySearchIntegerIterative(values, 5) // Returns 3

// Check if array is sorted
isSorted = NAVArrayIsSortedAscendingInteger(values) // Returns true

// Print array to debug log
NAVPrintArrayInteger(values) // Outputs: [1, 3, 5, 8, 9]
```

## Example: Working with String Arrays

```netlinx
// Initialize an array of strings
stack_var char names[5][20]
names[1] = 'Dave'
names[2] = 'Bob'
names[3] = 'Alice'
names[4] = 'Charlie'
names[5] = 'Eve'
set_length_array(names, 5) // Set array length to actual data size

// Sort alphabetically
NAVArraySelectionSortString(names)
// names is now {'Alice', 'Bob', 'Charlie', 'Dave', 'Eve'}

// Convert to lowercase
NAVArrayToLowerString(names)
// names is now {'alice', 'bob', 'charlie', 'dave', 'eve'}

// Find a string
index = NAVFindInArraySTRING(names, 'charlie') // Returns 3

// Print array to debug log
NAVPrintArrayString(names)
```

## Example: Using Sets

```netlinx
// Create a set of unique values
stack_var _NAVArrayIntegerSet uniqueNumbers
NAVArrayIntegerSetInit(uniqueNumbers, 20)

// Add elements (duplicates are ignored)
NAVArrayIntegerSetAdd(uniqueNumbers, 10)
NAVArrayIntegerSetAdd(uniqueNumbers, 20)
NAVArrayIntegerSetAdd(uniqueNumbers, 10) // This is ignored as 10 already exists

// Check if value exists
if (NAVArrayIntegerSetContains(uniqueNumbers, 10)) {
    // Value exists in set
}

// Remove a value
NAVArrayIntegerSetRemove(uniqueNumbers, 10)
```

## Testing

The ArrayUtils library includes a comprehensive test suite located in `__tests__/include/array-utils/`. The test suite covers:

- All array manipulation functions (set, copy, reverse, slice)
- All sorting algorithms with edge cases (empty, single element, duplicates, reverse sorted, etc.)
- All search algorithms
- Mathematical operations (sum, average)
- Set operations
- Format and print functions

To run the tests, compile and run the test program at `__tests__/src/array-utils.axs`.

## Contributing

For issues, suggestions, or contributions, please contact Norgate AV Services Limited.

## License

MIT License - Copyright (c) 2010-2026 Norgate AV
