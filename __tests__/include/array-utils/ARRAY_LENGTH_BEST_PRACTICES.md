# AMX NetLinx Array Length: Best Practices and Predictability

## Executive Summary

**The ArrayUtils library correctly uses `LENGTH_ARRAY()`** - this is the right design choice for a flexible, efficient array utility library. While this requires callers to explicitly call `SET_LENGTH_ARRAY()` (especially for stack arrays), this trade-off enables:

- **Efficiency**: Process only active elements, not entire capacity
- **Flexibility**: Support for partial arrays and dynamic operations
- **Standard practice**: Matches NetLinx conventions and built-in behavior

See `DESIGN_DECISION_LENGTH_VS_MAX.md` for detailed analysis of why this approach is preferred over using `MAX_LENGTH_ARRAY()`.

---

## Official Documentation Summary

Based on the NetLinx help files, here are the official definitions:

### `MAX_LENGTH_ARRAY()`
**Official Definition:** Returns the **maximum length** of a dimension of an array.

- This is the **declared size** of the array at compile time
- **Always fixed and predictable** - never changes at runtime
- Represents the **capacity** or **allocated space** for the array
- Example: `INTEGER Array[10]` → `MAX_LENGTH_ARRAY(Array)` always returns `10`

### `LENGTH_ARRAY()`
**Official Definition:** Returns the **effective length** of a dimension of an array, set either:
- **Implicitly** through array initialization (e.g., `INTEGER Array[] = {1,2,3}`)
- **Explicitly** through a call to `SET_LENGTH_ARRAY()`

Key characteristics:
- This is the **"working" or "active"** length of the array
- **Dynamic and can change at runtime** via `SET_LENGTH_ARRAY()`
- **Important:** Changing an element in an array does NOT change its length
- For arrays without initialization or explicit `SET_LENGTH_ARRAY()` call, the behavior is **undefined**

### Critical Distinction from NetLinx Documentation:

> **"Changing an element in array does not change its length. `SET_LENGTH_ARRAY` is used to change the effective length of an array when necessary, such as when you've added elements via a FOR loop."**

This means:
```netlinx
INTEGER Array[10]
Array[1] = 5
Array[2] = 10
Array[3] = 15

// At this point:
// MAX_LENGTH_ARRAY(Array) = 10   ✓ Predictable
// LENGTH_ARRAY(Array) = ???       ✗ Undefined! (likely 0 for stack vars)

// You MUST explicitly set the length:
SET_LENGTH_ARRAY(Array, 3)        // Now LENGTH_ARRAY(Array) = 3
```

## The Issue in Tests

In the ArrayUtils test suite, we encountered failures because:

1. **Stack-allocated arrays** (using `stack_var`) do NOT have their effective length automatically set
2. **Populating array elements does NOT change the effective length** (per NetLinx documentation)
3. Functions like `NAVSetArrayChar()` and others in the ArrayUtils library use `LENGTH_ARRAY()` internally to determine how many elements to process
4. Without calling `SET_LENGTH_ARRAY()`, these functions process 0 elements (or an undefined number)

### The Root Cause (from NetLinx Documentation):

The official documentation states:
> "Changing an element in array does not change its length."

This means that doing this:
```netlinx
stack_var integer array[5]
array[1] = 10
array[2] = 20
array[3] = 30
array[4] = 40
array[5] = 50
```

Does NOT set `LENGTH_ARRAY(array)` to `5`! The effective length remains undefined (often 0 for stack variables).

### Example of the Problem:
```netlinx
define_function TestNAVSetArrayInteger() {
    stack_var integer array[5]  // Declares space for 5 elements
    
    // At this point:
    // MAX_LENGTH_ARRAY(array) = 5  ✓ Predictable - the declared capacity
    // LENGTH_ARRAY(array) = ???     ✗ Undefined - not set yet
    
    NAVSetArrayInteger(array, 42)  // Uses LENGTH_ARRAY internally - may process 0 elements!
}
```

### Solution:
```netlinx
define_function TestNAVSetArrayInteger() {
    stack_var integer array[5]
    
    SET_LENGTH_ARRAY(array, 5)  // Explicitly set the effective length
    
    // Now:
    // MAX_LENGTH_ARRAY(array) = 5  ✓ The declared capacity
    // LENGTH_ARRAY(array) = 5       ✓ The effective/working length
    
    NAVSetArrayInteger(array, 42)  // Processes all 5 elements
}
```

## Why Arrays with Initializers Work Differently

From the NetLinx documentation, arrays initialized with values have their effective length set **implicitly**:

```netlinx
// This works because initialization sets the effective length implicitly
INTEGER Array1[] = {3, 4, 5, 6, 7}
// LENGTH_ARRAY(Array1) = 5   ✓ Set implicitly by initialization
// MAX_LENGTH_ARRAY(Array1) = 5

INTEGER Array2[] = {1, 2}
// LENGTH_ARRAY(Array2) = 2   ✓ Set implicitly by initialization
// MAX_LENGTH_ARRAY(Array2) = 2
```

However, **stack variables cannot use initializer syntax**, so their effective length must be set explicitly:

```netlinx
// ✗ NOT ALLOWED for stack_var
stack_var integer array[] = {1, 2, 3}  // Syntax error!

// ✓ CORRECT for stack_var
stack_var integer array[3]
array[1] = 1
array[2] = 2
array[3] = 3
SET_LENGTH_ARRAY(array, 3)  // MUST set explicitly!
```

## When to Use Each Function

### Use `MAX_LENGTH_ARRAY()` when:
- You need the **declared capacity** of an array (how much space was allocated)
- You want to iterate over the entire declared array size
- You're writing utility functions that should work with the full array capacity
- You need **guaranteed predictability** without runtime dependencies
- You want to avoid dependency on someone having called `SET_LENGTH_ARRAY()`

**Examples where `MAX_LENGTH_ARRAY()` is appropriate:**
```netlinx
// Initialize all declared elements to a default value
define_function InitializeArray(integer array[], integer defaultValue) {
    stack_var integer x
    for (x = 1; x <= MAX_LENGTH_ARRAY(array); x++) {
        array[x] = defaultValue
    }
    // Now optionally set the effective length
    SET_LENGTH_ARRAY(array, MAX_LENGTH_ARRAY(array))
}

// Clear/zero out all allocated space
define_function ClearArray(char array[]) {
    stack_var integer x
    for (x = 1; x <= MAX_LENGTH_ARRAY(array); x++) {
        array[x] = 0
    }
}
```

### Use `LENGTH_ARRAY()` when:
- You need the **effective/working length** of an array (how many elements are "active")
- Working with partially-filled arrays where only some elements are in use
- Processing arrays where the active size varies and has been explicitly set
- Implementing dynamic array operations that respect the current working size
- **IMPORTANT:** Only when you can guarantee `SET_LENGTH_ARRAY()` has been called!

**Examples where `LENGTH_ARRAY()` is appropriate:**
```netlinx
// Process only the "active" elements in a partially-filled array
define_function integer SumArrayElements(integer array[]) {
    stack_var integer x
    stack_var integer sum
    
    sum = 0
    for (x = 1; x <= LENGTH_ARRAY(array); x++) {
        sum = sum + array[x]
    }
    return sum
}

// Add an element to a dynamic array
define_function AddToArray(integer array[], integer value) {
    stack_var integer currentLength
    
    currentLength = LENGTH_ARRAY(array)
    
    // Make sure we have capacity
    if (currentLength < MAX_LENGTH_ARRAY(array)) {
        array[currentLength + 1] = value
        SET_LENGTH_ARRAY(array, currentLength + 1)  // Update effective length
    }
}
```

### The Key Distinction:

**`MAX_LENGTH_ARRAY()`** = "How much space do I have?" (capacity)
**`LENGTH_ARRAY()`** = "How many elements am I using?" (active size)

From the official documentation:
> "`LENGTH_ARRAY` returns the effective length of a dimension of an array: the length set implicitly through array initialization or explicitly through a call to `SET_LENGTH_ARRAY`."

## Best Practices for ArrayUtils Library

### 1. **In Library Functions**
The ArrayUtils library functions correctly use `LENGTH_ARRAY()` because:
- They need to respect the caller's intended working array size
- They provide flexibility for partial array operations
- This is the expected NetLinx convention for array processing functions
- It allows callers to work with partially-filled arrays efficiently

**However**, this means callers MUST call `SET_LENGTH_ARRAY()` first!

### 2. **In Test Code (and Application Code)**
Based on the NetLinx documentation's explicit statement that "changing an element in array does not change its length," you MUST explicitly set the array length:

```netlinx
// ✓ CORRECT - Full array usage
stack_var integer array[10]
array[1] = 10
array[2] = 20
// ... populate all 10 elements ...
array[10] = 100
SET_LENGTH_ARRAY(array, 10)  // All 10 elements are active
NAVSomeArrayFunction(array)   // Processes 10 elements

// ✓ ALSO CORRECT - Partial array usage
stack_var integer array[10]
array[1] = 10
array[2] = 20
SET_LENGTH_ARRAY(array, 2)    // Only first 2 elements are active
NAVSomeArrayFunction(array)   // Processes only 2 elements

// ✗ WRONG - Undefined behavior
stack_var integer array[10]
array[1] = 10
array[2] = 20
// Missing SET_LENGTH_ARRAY()!
NAVSomeArrayFunction(array)   // Undefined behavior - likely processes 0 elements
```

### 3. **When to Call `SET_LENGTH_ARRAY()`**

From the NetLinx documentation:
> "`SET_LENGTH_ARRAY` is used to change the effective length of an array when necessary, such as when you've added elements via a FOR loop."

This means you should call `SET_LENGTH_ARRAY()` whenever:
- You populate array elements manually (via assignment or loops)
- You add or remove elements from a dynamic array
- You want to change the "active" portion of an array
- You receive an array and need to set its working size

```netlinx
// Example: Building an array dynamically
stack_var integer results[100]
stack_var integer count
stack_var integer x

count = 0
for (x = 1; x <= 100; x++) {
    if (SomeCondition(x)) {
        count++
        results[count] = x
    }
}

// MUST set the effective length after populating
SET_LENGTH_ARRAY(results, count)

// Now other functions can process the correct number of elements
ProcessResults(results)  // Will process 'count' elements, not 100
```

### 4. **Pattern for All Tests**
The consistent pattern applied across all test files, following NetLinx best practices:

```netlinx
define_function TestSomeArrayFunction() {
    stack_var integer array[5]
    
    // Step 1: Declare array with maximum capacity
    // MAX_LENGTH_ARRAY(array) is now 5
    
    // Step 2: Populate array elements
    array[1] = value1
    array[2] = value2
    array[3] = value3
    array[4] = value4
    array[5] = value5
    
    // Step 3: CRITICAL - Set effective length explicitly
    // Per NetLinx docs: "changing an element in array does not change its length"
    SET_LENGTH_ARRAY(array, 5)
    // LENGTH_ARRAY(array) is now 5
    
    // Step 4: Call function under test
    NAVSomeArrayFunction(array)  // Will use LENGTH_ARRAY(array) = 5
    
    // Step 5: Verify results
    // Use MAX_LENGTH_ARRAY for predictable iteration over declared size
    for (x = 1; x <= MAX_LENGTH_ARRAY(array); x++) {
        // verify array[x]
    }
    
    // Or use LENGTH_ARRAY if you only want to verify active elements
    for (x = 1; x <= LENGTH_ARRAY(array); x++) {
        // verify array[x]
    }
}
```

### 5. **Testing Library Functions - Two Approaches**

When testing array functions, you can choose between two valid approaches:

**Approach A: Use `LENGTH_ARRAY()` (current ArrayUtils approach)**
```netlinx
// Library function
define_function NAVSetArrayInteger(integer array[], integer value) {
    stack_var integer x
    stack_var integer length
    
    length = LENGTH_ARRAY(array)  // Use effective length
    
    for (x = 1; x <= length; x++) {
        array[x] = value
    }
}

// Test - Caller MUST set length
stack_var integer array[5]
SET_LENGTH_ARRAY(array, 5)        // Required!
NAVSetArrayInteger(array, 42)
```

**Approach B: Use `MAX_LENGTH_ARRAY()` (alternative)**
```netlinx
// Library function
define_function NAVSetArrayIntegerFull(integer array[], integer value) {
    stack_var integer x
    stack_var integer length
    
    length = MAX_LENGTH_ARRAY(array)  // Use maximum capacity
    
    for (x = 1; x <= length; x++) {
        array[x] = value
    }
}

// Test - Length setting optional
stack_var integer array[5]
// No SET_LENGTH_ARRAY needed
NAVSetArrayIntegerFull(array, 42)
```

Both approaches are valid, but they serve different purposes:
- `LENGTH_ARRAY()`: Flexible, respects partial arrays, requires explicit length management
- `MAX_LENGTH_ARRAY()`: Simpler, always processes full capacity, no length management needed

## Recommendations

### For Maximum Predictability and Correctness:

1. **Always call `SET_LENGTH_ARRAY()` after populating a stack array**
   - Per NetLinx documentation: "Changing an element in array does not change its length"
   - This makes the effective length match your intentions
   - Prevents undefined behavior and silent failures
   - Call it even if you're filling the entire declared capacity

2. **Understand the difference between capacity and effective length**
   - `MAX_LENGTH_ARRAY()` = declared capacity (fixed at compile time)
   - `LENGTH_ARRAY()` = effective/working length (dynamic at runtime)
   - They are independent and serve different purposes

3. **Use `MAX_LENGTH_ARRAY()` when you need predictability**
   - No dependency on `SET_LENGTH_ARRAY()` having been called
   - Always returns the same value for a given array
   - Ideal for initialization and setup code
   - Example: `for (x = 1; x <= MAX_LENGTH_ARRAY(array); x++)`

4. **Use `LENGTH_ARRAY()` when you need flexibility**
   - Allows for partial array usage
   - Enables dynamic array operations
   - But ONLY after ensuring `SET_LENGTH_ARRAY()` has been called
   - Document this requirement clearly in function comments

5. **Document your choice in production code**
   ```netlinx
   /**
    * Processes all elements in the array up to its effective length.
    * IMPORTANT: Caller must call SET_LENGTH_ARRAY() before calling this function.
    */
   define_function ProcessArray(integer array[])
   
   /**
    * Initializes all elements in the array to the default value.
    * Uses MAX_LENGTH_ARRAY internally - no SET_LENGTH_ARRAY required.
    */
   define_function InitializeArrayFull(integer array[], integer defaultValue)
   ```

6. **For new library functions, consider the usage pattern**
   - If users will populate arrays element-by-element, use `LENGTH_ARRAY()` (but document it!)
   - If your function initializes/clears arrays, consider `MAX_LENGTH_ARRAY()` for simplicity
   - You can provide both variants for maximum flexibility

7. **In multi-dimensional arrays, apply these principles to each dimension**
   ```netlinx
   INTEGER My3DArray[5][3][4]
   
   // Each dimension has both MAX_LENGTH_ARRAY and LENGTH_ARRAY
   MAX_LENGTH_ARRAY(My3DArray)        // 5 - tables capacity
   MAX_LENGTH_ARRAY(My3DArray[1])     // 3 - rows capacity
   MAX_LENGTH_ARRAY(My3DArray[1][1])  // 4 - columns capacity
   
   // Effective lengths must be set for each dimension you use
   SET_LENGTH_ARRAY(My3DArray, 2)           // Using 2 tables
   SET_LENGTH_ARRAY(My3DArray[1], 3)        // Using 3 rows in table 1
   SET_LENGTH_ARRAY(My3DArray[1][1], 4)     // Using 4 columns in table 1, row 1
   ```

## Summary

### The Critical Takeaway from NetLinx Documentation:

**"Changing an element in array does not change its length."**

This means `LENGTH_ARRAY()` is NOT automatically updated when you assign values to array elements. You MUST explicitly call `SET_LENGTH_ARRAY()` to define the effective/working length.

### Two Independent Properties:

1. **`MAX_LENGTH_ARRAY()`** - The declared capacity (fixed at compile time)
2. **`LENGTH_ARRAY()`** - The effective/working length (dynamic at runtime, set explicitly or implicitly)

### For the ArrayUtils Test Suite:

- ✓ Library functions correctly use `LENGTH_ARRAY()` for flexibility
- ✓ Test code explicitly calls `SET_LENGTH_ARRAY()` after populating arrays (required!)
- ✓ This follows NetLinx best practices and official documentation
- ✓ Tests now pass reliably because effective length is properly set

### Quick Reference:

| Scenario | Use This | Why |
|----------|----------|-----|
| Need declared capacity | `MAX_LENGTH_ARRAY()` | Always predictable, no setup needed |
| Need working/active size | `LENGTH_ARRAY()` | Flexible, but requires `SET_LENGTH_ARRAY()` first |
| Initializing entire array | `MAX_LENGTH_ARRAY()` | Simple, don't need to track size |
| Working with partial arrays | `LENGTH_ARRAY()` | Efficient, process only active elements |
| After populating elements | Call `SET_LENGTH_ARRAY()` | Required per NetLinx docs! |
| Array with initializer | Neither needed | Length set implicitly: `INTEGER A[] = {1,2,3}` |

### Related NetLinx Functions:

- `SET_LENGTH_ARRAY(array, length)` - Explicitly sets the effective length
- `LENGTH_ARRAY(array)` - Returns the effective length
- `MAX_LENGTH_ARRAY(array)` - Returns the declared capacity

### See Also:

- `LENGTH_ARRAY.md` - Official NetLinx documentation for LENGTH_ARRAY
- `MAX_LENGTH_ARRAY.md` - Official NetLinx documentation for MAX_LENGTH_ARRAY
- NetLinx Help: Array Keywords section
