# LENGTH_ARRAY Behavior Test Program

## Overview

This test program (`length-array-behavior-test.axs`) systematically demonstrates how `LENGTH_ARRAY` behaves in different circumstances to validate the official NetLinx documentation and inform proper usage patterns.

## What This Test Does

The program tests `LENGTH_ARRAY` behavior in 6 different scenarios:

### Test 1: Constant Arrays with Initializers
Tests how `LENGTH_ARRAY` is set for constant arrays that use initializer syntax.

**Expected Results:**
```netlinx
CONSTANT INTEGER CONST_ARRAY_FULL[] = {1, 2, 3, 4, 5}
// MAX_LENGTH_ARRAY = 5
// LENGTH_ARRAY = 5 (set implicitly by initializer)

CONSTANT INTEGER CONST_ARRAY_DECLARED[10] = {1, 2, 3}
// MAX_LENGTH_ARRAY = 10
// LENGTH_ARRAY = 3 (set to number of initializer elements)
```

### Test 2: Global Arrays with Initializers
Tests global (module-level) arrays that use initializers.

**Expected Results:**
```netlinx
INTEGER globalArrayInit[] = {100, 200, 300, 400}
// MAX_LENGTH_ARRAY = 4
// LENGTH_ARRAY = 4 (set implicitly by initializer)
```

### Test 3: Global Arrays WITHOUT Initializers
Tests what happens with declared but uninitialized global arrays.

**Expected Results:**
```netlinx
INTEGER globalArrayNoInit[10]
// MAX_LENGTH_ARRAY = 10
// LENGTH_ARRAY = ??? (undefined - likely 0 or random)
```

**Key Finding:** Without an initializer or explicit `SET_LENGTH_ARRAY` call, the effective length is undefined.

### Test 4: Modifying Array Elements
**Critical Test:** Validates the NetLinx documentation statement: *"Changing an element in array does not change its length."*

**Expected Results:**
```netlinx
INTEGER globalModifiable[8]
// Initial LENGTH_ARRAY = ???

globalModifiable[1] = 111
globalModifiable[2] = 222
globalModifiable[3] = 333

// LENGTH_ARRAY = ??? (unchanged!)
```

**Key Finding:** Assigning values to array elements does NOT change `LENGTH_ARRAY`.

### Test 5: Explicit SET_LENGTH_ARRAY
Tests how `SET_LENGTH_ARRAY` explicitly controls the effective length.

**Expected Results:**
```netlinx
INTEGER array[5]
array[1] = 10
array[2] = 20
array[3] = 30

// LENGTH_ARRAY still undefined

SET_LENGTH_ARRAY(array, 3)
// LENGTH_ARRAY = 3 now

SET_LENGTH_ARRAY(array, 5)
// LENGTH_ARRAY = 5 now
```

**Key Finding:** `SET_LENGTH_ARRAY` is the only way to change effective length after declaration.

### Test 6: Stack Variables (Local Arrays)
**Most Important Test:** Tests stack-allocated arrays (using `stack_var`) which is the most problematic case.

**Expected Results:**
```netlinx
stack_var integer stackArray[10]
// MAX_LENGTH_ARRAY = 10
// LENGTH_ARRAY = 0 or undefined (very likely 0)

stackArray[1] = 100
stackArray[2] = 200
// LENGTH_ARRAY = still 0 or undefined

SET_LENGTH_ARRAY(stackArray, 2)
// LENGTH_ARRAY = 2 now
```

**Key Finding:** Stack arrays almost always have `LENGTH_ARRAY = 0` unless explicitly set.

## How to Run

1. Compile `length-array-behavior-test.axs` in NetLinx Studio
2. Load to your AMX controller
3. View diagnostics output (Telnet or NetLinx Studio diagnostics)
4. The program outputs to String 0, so all results appear in diagnostics

## What to Look For

### Critical Observations:

1. **Do constant arrays with `{}` initializers have LENGTH_ARRAY set?**
   - Expected: YES
   - If NO: This would be surprising and contradict documentation

2. **Do global arrays without initializers have defined LENGTH_ARRAY?**
   - Expected: NO (undefined or 0)
   - Confirms: Need explicit initialization

3. **Does modifying array elements change LENGTH_ARRAY?**
   - Expected: NO
   - If YES: NetLinx documentation would be wrong (very unlikely)
   - This is THE critical test

4. **What is LENGTH_ARRAY for stack arrays immediately after declaration?**
   - Expected: 0 or undefined
   - This explains why ArrayUtils tests failed initially

5. **Does SET_LENGTH_ARRAY actually work?**
   - Expected: YES
   - Should see LENGTH_ARRAY change to the specified value

## Expected Output Format

```
========================================
TEST 1: Constant Arrays with Initializers
========================================
CONST_ARRAY_FULL[] = {1,2,3,4,5}
  MAX_LENGTH_ARRAY: 5
  LENGTH_ARRAY:     5
  EXPECTED: Both = 5 (initializer sets length implicitly)

[... more tests ...]

========================================
SUMMARY OF FINDINGS
========================================
1. Arrays with initializers have LENGTH_ARRAY set implicitly
2. Arrays without initializers have undefined LENGTH_ARRAY
3. Modifying elements does NOT change LENGTH_ARRAY
4. SET_LENGTH_ARRAY must be called explicitly to set length
5. Stack arrays behave differently - see function below
========================================
```

## Interpreting Results

### If Test 4 Shows LENGTH_ARRAY Changed After Modifying Elements:
This would contradict the NetLinx documentation. Document this carefully as it would be a significant finding.

### If Stack Arrays (Test 6) Show LENGTH_ARRAY = 0:
This confirms why the ArrayUtils tests needed explicit `SET_LENGTH_ARRAY` calls. Stack arrays don't have their length set automatically.

### If Global Arrays Without Initializers Show LENGTH_ARRAY ≠ 0:
Note the specific value. It might be the MAX_LENGTH_ARRAY or might be garbage. Either way, it demonstrates undefined behavior.

## Real-World Implications

### Finding: Stack Arrays Have LENGTH_ARRAY = 0
**Implication:** Any function using `LENGTH_ARRAY` will process 0 elements from stack arrays unless `SET_LENGTH_ARRAY` is called first.

**Solution:** Always call `SET_LENGTH_ARRAY` for stack arrays.

### Finding: Initializers Set LENGTH_ARRAY Implicitly
**Implication:** Constants and initialized globals work with `LENGTH_ARRAY`-based functions without additional setup.

**Why production code worked:** Most production code uses constants or initialized globals.

### Finding: Modifying Elements Doesn't Change LENGTH_ARRAY
**Implication:** The NetLinx documentation is accurate. Building arrays element-by-element requires explicit length management.

**This is the key behavior** that necessitates calling `SET_LENGTH_ARRAY` after populating arrays via loops or individual assignments.

## Using Test Results

After running this test:

1. **Validate the NetLinx documentation** - Does behavior match what the docs say?
2. **Confirm ArrayUtils library design** - Does using `LENGTH_ARRAY` make sense given actual behavior?
3. **Document actual observed behavior** - Update best practices docs with real findings
4. **Justify test patterns** - Explain why tests use `SET_LENGTH_ARRAY` based on observed behavior

## Further Testing (Optional)

If you want to extend this test:

1. **Multi-dimensional arrays** - Does each dimension need its own `SET_LENGTH_ARRAY`?
2. **Passing to functions** - Does LENGTH_ARRAY persist when passing arrays to functions?
3. **Different data types** - Do CHAR, LONG, FLOAT arrays behave differently?
4. **Persistent variables** - How do PERSISTENT arrays behave?
5. **After system reset** - Do global array lengths persist across reboots?

## Conclusion

This test program provides empirical evidence of how `LENGTH_ARRAY` actually behaves, which should:
- Validate or correct our understanding
- Justify the ArrayUtils library design choices
- Explain why test code needs explicit `SET_LENGTH_ARRAY` calls
- Guide best practices documentation

Run this test on your actual AMX hardware to get definitive answers about array behavior in your NetLinx runtime environment.
