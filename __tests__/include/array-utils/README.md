# ArrayUtils Test Suite

This test suite provides comprehensive testing for the NAVFoundation ArrayUtils library, following the same patterns used in the StringUtils test suite.

## Test Structure

The test suite is organized into modular test files, each focusing on a specific category of array functions:

### Test Modules

1. **NAVSetArrayFunctions.axi**
   - Tests for setting all elements of arrays to a specific value
   - Covers: `NAVSetArrayChar`, `NAVSetArrayInteger`, `NAVSetArraySignedInteger`, `NAVSetArrayLong`, `NAVSetArraySignedLong`, `NAVSetArrayFloat`, `NAVSetArrayDouble`, `NAVSetArrayString`

2. **NAVFindInArrayFunctions.axi**
   - Tests for finding elements in arrays
   - Covers: `NAVFindInArrayINTEGER`, `NAVFindInArrayCHAR`, `NAVFindInArraySTRING`, `NAVFindInArrayLONG`, `NAVFindInArrayFLOAT`

3. **NAVArraySortFunctions.axi**
   - Tests for various sorting algorithms
   - Covers: `NAVArrayBubbleSortInteger`, `NAVArraySelectionSortInteger`, `NAVArraySelectionSortString`, `NAVArrayInsertionSortInteger`, `NAVArrayQuickSortInteger`, `NAVArrayMergeSortInteger`, `NAVArrayCountingSortInteger`

4. **NAVArraySearchFunctions.axi**
   - Tests for advanced search algorithms (binary, ternary, jump, exponential)
   - Covers: `NAVArrayBinarySearchIntegerRecursive`, `NAVArrayBinarySearchIntegerIterative`, `NAVArrayTernarySearchInteger`, `NAVArrayJumpSearchInteger`, `NAVArrayExponentialSearchInteger`

5. **NAVArrayUtilityFunctions.axi**
   - Tests for utility functions (reverse, copy, sorting checks, case conversion)
   - Covers: `NAVArrayReverseInteger`, `NAVArrayReverseString`, `NAVArrayCopyInteger`, `NAVArrayCopyString`, `NAVArrayIsSortedInteger`, `NAVArrayIsSortedString`, `NAVArrayToLowerString`, `NAVArrayToUpperString`, `NAVArrayTrimString`

6. **NAVArrayMathFunctions.axi**
   - Tests for mathematical operations on arrays
   - Covers: `NAVArraySumInteger`, `NAVArraySumSignedInteger`, `NAVArraySumLong`, `NAVArraySumFloat`, `NAVArraySumDouble`, `NAVArrayAverageInteger`, `NAVArrayAverageSignedInteger`, `NAVArrayAverageLong`, `NAVArrayAverageFloat`, `NAVArrayAverageDouble`

7. **NAVArraySliceFunctions.axi**
   - Tests for array slicing operations
   - Covers: `NAVArraySliceInteger`, `NAVArraySliceString`

8. **NAVArraySetFunctions.axi**
   - Tests for array set data structures (unique value collections)
   - Covers: `NAVArrayCharSetInit`, `NAVArrayCharSetAdd`, `NAVArrayCharSetContains`, `NAVArrayCharSetRemove`, `NAVArrayIntegerSetInit`, `NAVArrayIntegerSetAdd`, `NAVArrayIntegerSetContains`, `NAVArrayIntegerSetRemove`

9. **NAVArrayFormatFunctions.axi**
   - Tests for array formatting/printing functions
   - Covers: `NAVFormatArrayInteger`, `NAVFormatArrayString`

## Running the Tests

### Method 1: Using Touch Panel Button
1. Compile and run `__tests__/src/array-utils.axs`
2. Press button 1 on touch panel device 10001:1:0
3. The test suite will run and output results to the console

### Method 2: Manual Invocation
```netlinx
set_log_level(NAV_LOG_LEVEL_DEBUG)
RunArrayUtilsTests()
```

## Test Configuration

Individual test modules can be enabled or disabled by commenting out the corresponding `#DEFINE` statements in `array-utils.axi`:

```netlinx
#DEFINE TESTING_NAVSETARRAYFUNCTIONS
#DEFINE TESTING_NAVFINDINARRAYFUNCTIONS
#DEFINE TESTING_NAVARRAYSORTFUNCTIONS
// ... etc
```

## Test Output

Each test function outputs results using the NAVFoundation Testing framework:
- `NAVLogTestPassed(testNumber)` - Test passed
- `NAVLogTestFailed(testNumber, expected, actual)` - Test failed with expected vs actual values

Example output:
```
***************** NAVSetArrayChar *****************
[TEST PASSED] Test 1
[TEST PASSED] Test 2
...
***************** NAVFindInArrayINTEGER *****************
[TEST PASSED] Test 1
[TEST FAILED] Test 2 - Expected: '3', Got: '0'
```

## Adding New Tests

To add a new test module:

1. Create a new `.axi` file in `__tests__/include/array-utils/`
2. Follow the existing test pattern:
   ```netlinx
   PROGRAM_NAME='YourTestModule'
   
   #include 'NAVFoundation.Core.axi'
   #include 'NAVFoundation.Testing.axi'
   
   define_function TestYourFunction() {
       NAVLog("'***************** YourFunction *****************'")
       // Test implementation
   }
   ```
3. Add a `#DEFINE` in `array-utils.axi`
4. Include your module file
5. Call your test functions in `RunArrayUtilsTests()`

## Dependencies

- NAVFoundation.Core.axi
- NAVFoundation.ArrayUtils.axi
- NAVFoundation.Assert.axi
- NAVFoundation.ErrorLogUtils.axi
- NAVFoundation.Testing.axi

## Notes

- Tests are designed to be independent and can run in any order
- Each test includes multiple sub-tests to cover edge cases
- Search algorithm tests assume sorted arrays where required
- Set tests verify uniqueness constraints
- Math tests verify correct sum and average calculations
