# AMX NetLinx Array Length: Best Practices and Predictability

## The Problem: `length_array()` vs `max_length_array()`

When working with AMX NetLinx arrays, there's a critical distinction between two built-in functions:

### `max_length_array()`
- Returns the **maximum size** of the array as declared
- This value is **fixed at compile time** based on the array declaration
- **Always predictable and consistent**
- Example: `integer array[5]` → `max_length_array(array)` always returns `5`

### `length_array()`
- Returns the **current logical length** of the array
- This value is **dynamic and changes at runtime**
- Can be unpredictable unless explicitly set with `set_length_array()`
- For stack variables (local arrays), often initialized to `0` or an unpredictable value
- For module/global variables, behavior may vary

## The Issue in Tests

In the ArrayUtils test suite, we encountered failures because:

1. **Stack-allocated arrays** (using `stack_var`) don't automatically have their length set
2. Functions like `NAVSetArrayChar()` and others use `length_array()` internally to determine how many elements to process
3. Without calling `set_length_array()`, these functions would process 0 elements or unpredictable numbers of elements

### Example of the Problem:
```netlinx
define_function TestNAVSetArrayInteger() {
    stack_var integer array[5]  // Declares space for 5 elements
    
    // At this point:
    // max_length_array(array) = 5  ✓ Predictable
    // length_array(array) = ???     ✗ Unpredictable (often 0 for stack vars)
    
    NAVSetArrayInteger(array, 42)  // May process 0 elements!
}
```

### Solution:
```netlinx
define_function TestNAVSetArrayInteger() {
    stack_var integer array[5]
    
    set_length_array(array, 5)  // Explicitly set logical length
    
    // Now:
    // max_length_array(array) = 5  ✓
    // length_array(array) = 5       ✓ Predictable!
    
    NAVSetArrayInteger(array, 42)  // Processes all 5 elements
}
```

## When to Use Each Function

### Use `max_length_array()` when:
- You need the **declared capacity** of an array
- You want to fill the entire array regardless of its current logical length
- You're writing utility functions that should work with the full array capacity
- You need **guaranteed predictability** without runtime dependencies

### Use `length_array()` when:
- You need the **current active length** of an array
- Working with dynamically-sized arrays where only part may be in use
- Processing arrays received from other functions/modules where the active size varies
- **BUT**: Always ensure `set_length_array()` has been called first!

## Best Practices for ArrayUtils Library

### 1. **In Library Functions**
The ArrayUtils library functions correctly use `length_array()` because:
- They need to respect the caller's intended array size
- They provide flexibility for partial array operations
- This is the expected NetLinx convention

### 2. **In Test Code (and Application Code)**
Always explicitly set the array length after initialization:

```netlinx
// ✓ CORRECT - Predictable
stack_var integer array[10]
array[1] = 10
array[2] = 20
// ... populate elements ...
set_length_array(array, 2)  // Only first 2 elements are "active"
NAVSomeArrayFunction(array)  // Processes 2 elements

// ✓ ALSO CORRECT - Full array
stack_var integer array[10]
// ... populate all 10 elements ...
set_length_array(array, 10)  // All elements active
NAVSomeArrayFunction(array)   // Processes 10 elements

// ✗ WRONG - Unpredictable
stack_var integer array[10]
array[1] = 10
array[2] = 20
// Missing set_length_array()!
NAVSomeArrayFunction(array)  // May process 0, 10, or ??? elements
```

### 3. **Pattern for All Tests**
The consistent pattern applied across all test files:

```netlinx
define_function TestSomeArrayFunction() {
    stack_var integer array[5]
    
    // Step 1: Populate array
    array[1] = value1
    array[2] = value2
    // ...
    
    // Step 2: ALWAYS set length explicitly
    set_length_array(array, 5)
    
    // Step 3: Call function under test
    NAVSomeArrayFunction(array)
    
    // Step 4: Verify results
    // Can use max_length_array() in loops for predictability
    for (x = 1; x <= max_length_array(array); x++) {
        // verify array[x]
    }
}
```

## Recommendations

### For Maximum Predictability:

1. **Always call `set_length_array()` immediately after populating a stack array**
   - This makes the logical length match your intentions
   - Prevents silent failures or unexpected behavior

2. **Consider using `max_length_array()` in test verification loops**
   - Ensures you check all declared elements
   - More predictable than `length_array()`
   - Example: `for (x = 1; x <= max_length_array(array); x++)`

3. **Document your choice in production code**
   - If using partial arrays (length < max_length), document why
   - Make `set_length_array()` calls explicit and close to initialization

4. **For new library functions, consider offering both variants**
   ```netlinx
   // Respects length_array()
   define_function ProcessArray(integer array[])
   
   // Always uses full capacity
   define_function ProcessArrayFull(integer array[])
   ```

## Summary

The key takeaway: **`length_array()` is dynamic and requires explicit initialization with `set_length_array()` for predictable behavior**, especially with stack-allocated arrays. The test suite now follows this pattern consistently, ensuring all tests pass reliably.

For the ArrayUtils library:
- ✓ Library functions correctly use `length_array()` for flexibility
- ✓ Test code explicitly calls `set_length_array()` for predictability
- ✓ Verification loops can use `max_length_array()` for consistency
- ✓ This approach balances library flexibility with test reliability
