# NAVFoundation.Testing

A lightweight testing utility library providing simple logging functions for test results in AMX NetLinx.

## Overview

The Testing library provides basic test logging utilities designed to work within NetLinx's constraints. Rather than attempting to build a full testing framework (which NetLinx's lack of function pointers, reflection, and dynamic dispatch makes impractical), this library focuses on providing clean, consistent test result logging.

## Philosophy

Traditional testing frameworks rely on language features NetLinx doesn't have:
- Function pointers/callbacks for registering tests
- Reflection for test discovery
- Dynamic dispatch for test runners
- Closures or lambdas for test case factories

Instead, this library embraces a simpler approach:
- **Explicit test functions** - manually write test functions
- **Simple logging utilities** - consistent pass/fail output
- **Conditional compilation** - enable/disable test suites with `#DEFINE`
- **Structured test data** - use arrays for test cases

## Installation

Include the library in your NetLinx project:

```netlinx
#include 'NAVFoundation.Testing.axi'
```

## API Reference

### `NAVLogTestPassed(integer test)`

Logs a test passed message.

**Parameters:**
- `test` (integer): The test number

**Example:**
```netlinx
NAVLogTestPassed(1)
// Output: "Test 1 passed"
```

---

### `NAVLogTestFailed(integer test, char expected[], char result[])`

Logs a test failed message with expected and actual values.

**Parameters:**
- `test` (integer): The test number
- `expected` (char[]): The expected value
- `result` (char[]): The actual result value

**Example:**
```netlinx
NAVLogTestFailed(2, '42', '43')
// Output: "Test 2 failed. Expected: "42", but got: "43"."
```

**Note:** If both expected and result are empty strings, comparison details are still shown.

---

## Usage Patterns

### Basic Test Structure

```netlinx
define_function TestMyFunction() {
    stack_var integer testNum
    stack_var char result[100]
    
    NAVLog("'***************** TestMyFunction *****************'")
    
    // Test 1
    testNum++
    result = MyFunction('input1')
    if (result == 'expected1') {
        NAVLogTestPassed(testNum)
    }
    else {
        NAVLogTestFailed(testNum, 'expected1', result)
    }
    
    // Test 2
    testNum++
    result = MyFunction('input2')
    if (result == 'expected2') {
        NAVLogTestPassed(testNum)
    }
    else {
        NAVLogTestFailed(testNum, 'expected2', result)
    }
}
```

### Array-Based Test Data

```netlinx
define_function TestWithArrayData() {
    stack_var integer x
    stack_var integer testNum
    stack_var long inputs[5][1]
    stack_var long expected[5][1]
    stack_var long result
    
    // Initialize test data
    inputs[1][1] = 10
    inputs[2][1] = 20
    inputs[3][1] = 30
    inputs[4][1] = 40
    inputs[5][1] = 50
    
    expected[1][1] = 100
    expected[2][1] = 200
    expected[3][1] = 300
    expected[4][1] = 400
    expected[5][1] = 500
    
    NAVLog("'***************** TestWithArrayData *****************'")
    
    for (x = 1; x <= 5; x++) {
        testNum++
        result = MyFunction(inputs[x][1])
        
        if (result == expected[x][1]) {
            NAVLogTestPassed(testNum)
        }
        else {
            NAVLogTestFailed(testNum, itoa(expected[x][1]), itoa(result))
        }
    }
}
```

### Conditional Test Compilation

```netlinx
// Test runner file
#DEFINE TESTING_MYFUNCTION
#DEFINE TESTING_ANOTHERFUNCTION

#include 'NAVFoundation.Testing.axi'

#IF_DEFINED TESTING_MYFUNCTION
#include 'TestMyFunction.axi'
#END_IF

#IF_DEFINED TESTING_ANOTHERFUNCTION
#include 'TestAnotherFunction.axi'
#END_IF

define_function RunAllTests() {
    #IF_DEFINED TESTING_MYFUNCTION
    TestMyFunction()
    #END_IF
    
    #IF_DEFINED TESTING_ANOTHERFUNCTION
    TestAnotherFunction()
    #END_IF
}
```

### Testing with Assertions

Combine with the Assert library for cleaner test code:

```netlinx
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestWithAssertions() {
    stack_var integer testNum
    stack_var long result
    stack_var long expected
    
    NAVLog("'***************** TestWithAssertions *****************'")
    
    testNum++
    result = MyFunction(42)
    expected = 100
    
    if (NAVAssertLongEqual(result, expected)) {
        NAVLogTestPassed(testNum)
    }
    else {
        NAVLogTestFailed(testNum, itoa(expected), itoa(result))
    }
}
```

## Example Test Output

```
2025-12-29 (15:22:43.682):: ***************** NAVBinaryRotateLeft *****************
2025-12-29 (15:22:43.702):: Test 1 passed
2025-12-29 (15:22:43.702):: Test 2 passed
2025-12-29 (15:22:43.702):: Test 3 passed
2025-12-29 (15:22:43.702):: Test 4 failed. Expected: "16", but got: "15".
2025-12-29 (15:22:43.702):: Test 5 passed
```

## Best Practices

1. **One test function per library function** - Keep tests organized and focused
2. **Use descriptive test section headers** - Log section names with asterisks for clarity
3. **Sequential test numbering** - Use a counter variable for test numbers
4. **Convert values to strings** - Use `itoa()`, `ftoa()`, etc. for numeric comparisons
5. **Separate test data initialization** - Keep test setup separate from execution
6. **Use conditional compilation** - Enable/disable test suites as needed
7. **Write tests alongside development** - Test as you implement

## Limitations

This is intentionally a minimal testing utility, not a full framework:
- ❌ No automatic test discovery
- ❌ No test fixtures or setup/teardown
- ❌ No mocking or stubbing capabilities
- ❌ No test statistics or summaries
- ❌ No parameterized test generation
- ✅ Simple, explicit, and works within NetLinx constraints

## Dependencies

- `NAVFoundation.Core.axi`

## See Also

- [NAVFoundation.Assert](../Assert/README.md) - Assertion utilities for testing
- [NAVFoundation.ErrorLogUtils](../ErrorLogUtils/README.md) - Logging utilities

## License

MIT License - Copyright (c) 2010-2026 Norgate AV
