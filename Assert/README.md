# NAVFoundation.Assert

## Overview

The NAVFoundation.Assert library provides a comprehensive set of assertion functions for testing, debugging, and verifying code behavior in AMX NetLinx applications. These functions help ensure that expected conditions are met during development and testing phases, making it easier to identify and fix issues.

The library is particularly useful for:

- Unit testing NetLinx code
- Verifying function behavior during development
- Debugging complex applications
- Ensuring correct implementation of algorithms and business logic

## API Reference

The Assert library offers a wide range of assertion functions for different data types and comparison operations:

### Equality Assertions

#### NAVAssertCharEqual

```netlinx
define_function char NAVAssertCharEqual(char testName[], char expected, char actual)
```

**Description:** Tests if two char values are equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected char value
- `actual` - Actual char value

**Returns:** `true` if equal, `false` otherwise

---

#### NAVAssertWideCharEqual

```netlinx
define_function char NAVAssertWideCharEqual(char testName[], widechar expected, widechar actual)
```

**Description:** Tests if two widechar values are equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected widechar value
- `actual` - Actual widechar value

**Returns:** `true` if equal, `false` otherwise

---

#### NAVAssertIntegerEqual

```netlinx
define_function char NAVAssertIntegerEqual(char testName[], integer expected, integer actual)
```

**Description:** Tests if two integer values are equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected integer value
- `actual` - Actual integer value

**Returns:** `true` if equal, `false` otherwise

---

#### NAVAssertSignedIntegerEqual

```netlinx
define_function char NAVAssertSignedIntegerEqual(char testName[], sinteger expected, sinteger actual)
```

**Description:** Tests if two signed integer values are equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected signed integer value
- `actual` - Actual signed integer value

**Returns:** `true` if equal, `false` otherwise

---

#### NAVAssertLongEqual

```netlinx
define_function char NAVAssertLongEqual(char testName[], long expected, long actual)
```

**Description:** Tests if two long values are equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected long value
- `actual` - Actual long value

**Returns:** `true` if equal, `false` otherwise

---

#### NAVAssertSignedLongEqual

```netlinx
define_function char NAVAssertSignedLongEqual(char testName[], slong expected, slong actual)
```

**Description:** Tests if two signed long values are equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected signed long value
- `actual` - Actual signed long value

**Returns:** `true` if equal, `false` otherwise

---

#### NAVAssertFloatEqual

```netlinx
define_function char NAVAssertFloatEqual(char testName[], float expected, float actual)
```

**Description:** Tests if two float values are equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected float value
- `actual` - Actual float value

**Returns:** `true` if equal, `false` otherwise

---

#### NAVAssertDoubleEqual

```netlinx
define_function char NAVAssertDoubleEqual(char testName[], double expected, double actual)
```

**Description:** Tests if two double values are equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected double value
- `actual` - Actual double value

**Returns:** `true` if equal, `false` otherwise

---

#### NAVAssertStringEqual

```netlinx
define_function char NAVAssertStringEqual(char testName[], char expected[], char actual[])
```

**Description:** Tests if two string values are equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected string
- `actual` - Actual string

**Returns:** `true` if equal, `false` otherwise

---

#### NAVAssertInt64Equal

```netlinx
define_function char NAVAssertInt64Equal(char testName[], _NAVInt64 expected, _NAVInt64 actual)
```

**Description:** Tests if two Int64 values are equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected Int64 value
- `actual` - Actual Int64 value

**Returns:** `true` if equal, `false` otherwise

### Inequality Assertions

#### NAVAssertStringNotEqual

```netlinx
define_function char NAVAssertStringNotEqual(char testName[], char expected[], char actual[])
```

**Description:** Tests if two string values are not equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that should not match
- `actual` - Actual value

**Returns:** `true` if not equal (test passed), `false` otherwise

---

#### NAVAssertIntegerNotEqual

```netlinx
define_function char NAVAssertIntegerNotEqual(char testName[], integer expected, integer actual)
```

**Description:** Tests if two integer values are not equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that should not match
- `actual` - Actual value

**Returns:** `true` if not equal (test passed), `false` otherwise

---

#### NAVAssertCharNotEqual

```netlinx
define_function char NAVAssertCharNotEqual(char testName[], char expected, char actual)
```

**Description:** Tests if two char values are not equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that should not match
- `actual` - Actual value

**Returns:** `true` if not equal (test passed), `false` otherwise

---

#### NAVAssertWideCharNotEqual

```netlinx
define_function char NAVAssertWideCharNotEqual(char testName[], widechar expected, widechar actual)
```

**Description:** Tests if two widechar values are not equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that should not match
- `actual` - Actual value

**Returns:** `true` if not equal (test passed), `false` otherwise

---

#### NAVAssertSignedIntegerNotEqual

```netlinx
define_function char NAVAssertSignedIntegerNotEqual(char testName[], sinteger expected, sinteger actual)
```

**Description:** Tests if two signed integer values are not equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that should not match
- `actual` - Actual value

**Returns:** `true` if not equal (test passed), `false` otherwise

---

#### NAVAssertFloatNotEqual

```netlinx
define_function char NAVAssertFloatNotEqual(char testName[], float expected, float actual)
```

**Description:** Tests if two float values are not equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that should not match
- `actual` - Actual value

**Returns:** `true` if not equal (test passed), `false` otherwise

---

#### NAVAssertInt64NotEqual

```netlinx
define_function char NAVAssertInt64NotEqual(char testName[], _NAVInt64 expected, _NAVInt64 actual)
```

**Description:** Tests if two Int64 values are not equal and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that should not match
- `actual` - Actual value

**Returns:** `true` if not equal (test passed), `false` otherwise

### Comparison Assertions

#### NAVAssertIntegerGreaterThan

```netlinx
define_function char NAVAssertIntegerGreaterThan(char testName[], integer expected, integer actual)
```

**Description:** Tests if actual integer value is greater than expected value and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that actual should be greater than
- `actual` - Actual value

**Returns:** `true` if actual > expected (test passed), `false` otherwise

---

#### NAVAssertIntegerLessThan

```netlinx
define_function char NAVAssertIntegerLessThan(char testName[], integer expected, integer actual)
```

**Description:** Tests if actual integer value is less than expected value and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that actual should be less than
- `actual` - Actual value

**Returns:** `true` if actual < expected (test passed), `false` otherwise

---

#### NAVAssertIntegerGreaterThanOrEqual

```netlinx
define_function char NAVAssertIntegerGreaterThanOrEqual(char testName[], integer expected, integer actual)
```

**Description:** Tests if actual integer value is greater than or equal to expected value and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that actual should be greater than or equal to
- `actual` - Actual value

**Returns:** `true` if actual >= expected (test passed), `false` otherwise

---

#### NAVAssertIntegerLessThanOrEqual

```netlinx
define_function char NAVAssertIntegerLessThanOrEqual(char testName[], integer expected, integer actual)
```

**Description:** Tests if actual integer value is less than or equal to expected value and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that actual should be less than or equal to
- `actual` - Actual value

**Returns:** `true` if actual <= expected (test passed), `false` otherwise

---

#### NAVAssertFloatGreaterThan

```netlinx
define_function char NAVAssertFloatGreaterThan(char testName[], float expected, float actual)
```

**Description:** Tests if actual float value is greater than expected value and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that actual should be greater than
- `actual` - Actual value

**Returns:** `true` if actual > expected (test passed), `false` otherwise

---

#### NAVAssertFloatLessThan

```netlinx
define_function char NAVAssertFloatLessThan(char testName[], float expected, float actual)
```

**Description:** Tests if actual float value is less than expected value and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that actual should be less than
- `actual` - Actual value

**Returns:** `true` if actual < expected (test passed), `false` otherwise

---

#### NAVAssertFloatGreaterThanOrEqual

```netlinx
define_function char NAVAssertFloatGreaterThanOrEqual(char testName[], float expected, float actual)
```

**Description:** Tests if actual float value is greater than or equal to expected value and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that actual should be greater than or equal to
- `actual` - Actual value

**Returns:** `true` if actual >= expected (test passed), `false` otherwise

---

#### NAVAssertFloatLessThanOrEqual

```netlinx
define_function char NAVAssertFloatLessThanOrEqual(char testName[], float expected, float actual)
```

**Description:** Tests if actual float value is less than or equal to expected value and logs the result.

**Parameters:**

- `testName` - Name of the test
- `expected` - Value that actual should be less than or equal to
- `actual` - Actual value

**Returns:** `true` if actual <= expected (test passed), `false` otherwise

### Boolean Assertions

#### NAVAssertTrue

```netlinx
define_function char NAVAssertTrue(char testName[], char condition)
```

**Description:** Tests if a condition is true.

**Parameters:**

- `testName` - Name of the test
- `condition` - Condition to test

**Returns:** `true` if condition is true, `false` otherwise

---

#### NAVAssertFalse

```netlinx
define_function char NAVAssertFalse(char testName[], char condition)
```

**Description:** Tests if a condition is false.

**Parameters:**

- `testName` - Name of the test
- `condition` - Condition to test

**Returns:** `true` if condition is false, `false` otherwise

### String Assertions

#### NAVAssertStringContains

```netlinx
define_function char NAVAssertStringContains(char testName[], char searchString[], char stringToSearch[])
```

**Description:** Tests if a string contains a substring.

**Parameters:**

- `testName` - Name of the test
- `searchString` - String to find
- `stringToSearch` - String to search in

**Returns:** `true` if stringToSearch contains searchString, `false` otherwise

---

#### NAVAssertStringStartsWith

```netlinx
define_function char NAVAssertStringStartsWith(char testName[], char prefix[], char str[])
```

**Description:** Tests if a string starts with the specified prefix.

**Parameters:**

- `testName` - Name of the test
- `prefix` - Expected prefix
- `str` - String to test

**Returns:** `true` if str starts with prefix, `false` otherwise

---

#### NAVAssertStringEndsWith

```netlinx
define_function char NAVAssertStringEndsWith(char testName[], char suffix[], char str[])
```

**Description:** Tests if a string ends with the specified suffix.

**Parameters:**

- `testName` - Name of the test
- `suffix` - Expected suffix
- `str` - String to test

**Returns:** `true` if str ends with suffix, `false` otherwise

### Approximate Equality

#### NAVAssertFloatAlmostEqual

```netlinx
define_function char NAVAssertFloatAlmostEqual(char testName[], float expected, float actual, float epsilon)
```

**Description:** Tests if two float values are almost equal within a given epsilon.

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected value
- `actual` - Actual value
- `epsilon` - Maximum allowed difference

**Returns:** `true` if |expected-actual| <= epsilon, `false` otherwise

---

### Array Assertions

#### String Array Assertions

##### NAVAssertStringArrayEqual

```netlinx
define_function char NAVAssertStringArrayEqual(char testName[], char expected[][], char actual[][])
```

**Description:** Tests if two string arrays are equal (same length and all elements match).

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected string array
- `actual` - Actual string array

**Returns:** `true` if arrays are equal, `false` otherwise

---

##### NAVAssertStringArrayNotEqual

```netlinx
define_function char NAVAssertStringArrayNotEqual(char testName[], char expected[][], char actual[][])
```

**Description:** Tests if two string arrays are not equal (different length or any elements differ).

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected string array
- `actual` - Actual string array

**Returns:** `true` if arrays are not equal, `false` otherwise

---

##### NAVAssertStringArrayContains

```netlinx
define_function char NAVAssertStringArrayContains(char testName[], char searchString[], char array[][])
```

**Description:** Tests if a string array contains a specific string.

**Parameters:**

- `testName` - Name of the test
- `searchString` - String to search for
- `array` - String array to search in

**Returns:** `true` if array contains searchString, `false` otherwise

---

##### NAVAssertStringArrayNotContains

```netlinx
define_function char NAVAssertStringArrayNotContains(char testName[], char searchString[], char array[][])
```

**Description:** Tests if a string array does not contain a specific string.

**Parameters:**

- `testName` - Name of the test
- `searchString` - String to search for
- `array` - String array to search in

**Returns:** `true` if array does not contain searchString, `false` otherwise

---

##### NAVAssertStringArrayLengthEqual

```netlinx
define_function char NAVAssertStringArrayLengthEqual(char testName[], integer expectedLength, char array[][])
```

**Description:** Tests if a string array has the expected length.

**Parameters:**

- `testName` - Name of the test
- `expectedLength` - Expected array length
- `array` - String array to check

**Returns:** `true` if array length matches expectedLength, `false` otherwise

---

##### NAVAssertStringArrayLengthNotEqual

```netlinx
define_function char NAVAssertStringArrayLengthNotEqual(char testName[], integer expectedLength, char array[][])
```

**Description:** Tests if a string array does not have the specified length.

**Parameters:**

- `testName` - Name of the test
- `expectedLength` - Length that array should not have
- `array` - String array to check

**Returns:** `true` if array length does not match expectedLength, `false` otherwise

---

#### Integer Array Assertions

##### NAVAssertIntegerArrayEqual

```netlinx
define_function char NAVAssertIntegerArrayEqual(char testName[], integer expected[], integer actual[])
```

**Description:** Tests if two integer arrays are equal (same length and all elements match).

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected integer array
- `actual` - Actual integer array

**Returns:** `true` if arrays are equal, `false` otherwise

---

##### NAVAssertIntegerArrayNotEqual

```netlinx
define_function char NAVAssertIntegerArrayNotEqual(char testName[], integer expected[], integer actual[])
```

**Description:** Tests if two integer arrays are not equal (different length or any elements differ).

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected integer array
- `actual` - Actual integer array

**Returns:** `true` if arrays are not equal, `false` otherwise

---

##### NAVAssertIntegerArrayLengthEqual

```netlinx
define_function char NAVAssertIntegerArrayLengthEqual(char testName[], integer expectedLength, integer array[])
```

**Description:** Tests if an integer array has the expected length.

**Parameters:**

- `testName` - Name of the test
- `expectedLength` - Expected array length
- `array` - Integer array to check

**Returns:** `true` if array length matches expectedLength, `false` otherwise

---

##### NAVAssertIntegerArrayLengthNotEqual

```netlinx
define_function char NAVAssertIntegerArrayLengthNotEqual(char testName[], integer expectedLength, integer array[])
```

**Description:** Tests if an integer array does not have the specified length.

**Parameters:**

- `testName` - Name of the test
- `expectedLength` - Length that array should not have
- `array` - Integer array to check

**Returns:** `true` if array length does not match expectedLength, `false` otherwise

---

#### Two-Dimensional Integer Array Assertions

##### NAVAssertInteger2DArrayEqual

```netlinx
define_function char NAVAssertInteger2DArrayEqual(char testName[], integer expected[][], integer actual[][])
```

**Description:** Tests if two 2D integer arrays are equal (same dimensions and all elements match).

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected 2D integer array
- `actual` - Actual 2D integer array

**Returns:** `true` if arrays are equal, `false` otherwise

---

##### NAVAssertInteger2DArrayNotEqual

```netlinx
define_function char NAVAssertInteger2DArrayNotEqual(char testName[], integer expected[][], integer actual[][])
```

**Description:** Tests if two 2D integer arrays are not equal (different dimensions or any elements differ).

**Parameters:**

- `testName` - Name of the test
- `expected` - Expected 2D integer array
- `actual` - Actual 2D integer array

**Returns:** `true` if arrays are not equal, `false` otherwise

---

##### NAVAssertInteger2DArrayDimensionsEqual

```netlinx
define_function char NAVAssertInteger2DArrayDimensionsEqual(char testName[], integer expectedRows, integer expectedCols, integer array[][])
```

**Description:** Tests if a 2D integer array has the expected dimensions.

**Parameters:**

- `testName` - Name of the test
- `expectedRows` - Expected number of rows
- `expectedCols` - Expected number of columns
- `array` - 2D integer array to check

**Returns:** `true` if array dimensions match expected values, `false` otherwise

---

##### NAVAssertInteger2DArrayDimensionsNotEqual

```netlinx
define_function char NAVAssertInteger2DArrayDimensionsNotEqual(char testName[], integer expectedRows, integer expectedCols, integer array[][])
```

**Description:** Tests if a 2D integer array does not have the specified dimensions.

**Parameters:**

- `testName` - Name of the test
- `expectedRows` - Row count that array should not have
- `expectedCols` - Column count that array should not have
- `array` - 2D integer array to check

**Returns:** `true` if array dimensions do not match expected values, `false` otherwise

---

## Usage Examples

### Basic Usage

```netlinx
// Import the Assert module
#include 'NAVFoundation.Assert.axi'

// Example function to test
define_function integer Add(integer a, integer b)
{
    return a + b
}

// Test function
define_function TestAddFunction()
{
    stack_var integer result

    // Test case 1: Basic addition
    result = Add(2, 3)
    NAVAssertIntegerEqual('Add function - positive integers', 5, result)

    // Test case 2: Addition with zero
    result = Add(10, 0)
    NAVAssertIntegerEqual('Add function - zero as operand', 10, result)

    // Test case 3: Addition with negative numbers
    result = Add(-5, 3)
    NAVAssertIntegerEqual('Add function - negative integer', -2, result)
}
```

### Testing a String Processing Function

```netlinx
// Import the Assert module
#include 'NAVFoundation.Assert.axi'

// Example string function to test
define_function char[100] FormatName(char firstName[], char lastName[])
{
    stack_var char formattedName[100]

    if (length_array(firstName) == 0 && length_array(lastName) == 0)
    {
        return 'Unknown'
    }

    if (length_array(firstName) == 0)
    {
        return lastName
    }

    if (length_array(lastName) == 0)
    {
        return firstName
    }

    formattedName = "lastName, ', ', firstName"
    return formattedName
}

// Test function
define_function TestFormatNameFunction()
{
    stack_var char result[100]

    // Test case 1: Normal case
    result = FormatName('John', 'Doe')
    NAVAssertStringEqual('FormatName - full name', 'Doe, John', result)

    // Test case 2: Missing first name
    result = FormatName('', 'Doe')
    NAVAssertStringEqual('FormatName - missing first name', 'Doe', result)

    // Test case 3: Missing last name
    result = FormatName('John', '')
    NAVAssertStringEqual('FormatName - missing last name', 'John', result)

    // Test case 4: Both names missing
    result = FormatName('', '')
    NAVAssertStringEqual('FormatName - both names missing', 'Unknown', result)

    // String pattern assertions
    NAVAssertStringContains('FormatName - contains comma', ',', FormatName('John', 'Doe'))
    NAVAssertStringStartsWith('FormatName - starts with last name', 'Doe', FormatName('John', 'Doe'))
}
```

### Testing Numeric Operations with Floating-Point Values

```netlinx
// Import the Assert module
#include 'NAVFoundation.Assert.axi'

// Example function to test
define_function float CalculateCircleArea(float radius)
{
    stack_var float PI
    PI = 3.14159
    return PI * radius * radius
}

// Test function
define_function TestCircleAreaCalculation()
{
    stack_var float result
    stack_var float epsilon

    // Small value for floating point comparison tolerance
    epsilon = 0.0001

    // Test case 1: Unit circle (r = 1)
    result = CalculateCircleArea(1.0)
    NAVAssertFloatAlmostEqual('Circle area - unit circle', 3.14159, result, epsilon)

    // Test case 2: Circle with radius 2
    result = CalculateCircleArea(2.0)
    NAVAssertFloatAlmostEqual('Circle area - radius 2', 12.56636, result, epsilon)

    // Test case 3: Zero radius
    result = CalculateCircleArea(0.0)
    NAVAssertFloatEqual('Circle area - zero radius', 0.0, result)

    // Test case 4: Comparison tests
    result = CalculateCircleArea(5.0)
    NAVAssertFloatGreaterThan('Circle area - larger than 50', 50.0, result)
    NAVAssertFloatLessThan('Circle area - smaller than 100', 100.0, result)
}
```

### Comprehensive Test Suite

```netlinx
// Import the Assert module
#include 'NAVFoundation.Assert.axi'

// Run all tests
define_function RunAllTests()
{
    stack_var integer passCount
    stack_var integer totalTests

    passCount = 0
    totalTests = 0

    // String tests
    totalTests++
    if (NAVAssertStringEqual('String equality test', 'Hello World', 'Hello World'))
    {
        passCount++
    }

    totalTests++
    if (NAVAssertStringNotEqual('String inequality test', 'Hello', 'World'))
    {
        passCount++
    }

    totalTests++
    if (NAVAssertStringContains('String contains test', 'World', 'Hello World'))
    {
        passCount++
    }

    totalTests++
    if (NAVAssertStringStartsWith('String starts with test', 'Hello', 'Hello World'))
    {
        passCount++
    }

    totalTests++
    if (NAVAssertStringEndsWith('String ends with test', 'World', 'Hello World'))
    {
        passCount++
    }

    // Integer tests
    totalTests++
    if (NAVAssertIntegerEqual('Integer equality test', 42, 42))
    {
        passCount++
    }

    totalTests++
    if (NAVAssertIntegerNotEqual('Integer inequality test', 42, 43))
    {
        passCount++
    }

    totalTests++
    if (NAVAssertIntegerGreaterThan('Integer greater than test', 10, 20))
    {
        passCount++
    }

    totalTests++
    if (NAVAssertIntegerLessThan('Integer less than test', 30, 20))
    {
        passCount++
    }

    // Float tests
    totalTests++
    if (NAVAssertFloatAlmostEqual('Float almost equal test', 3.14159, 3.14158, 0.0001))
    {
        passCount++
    }

    // Boolean condition tests
    totalTests++
    if (NAVAssertTrue('Boolean true test', 1 == 1))
    {
        passCount++
    }

    totalTests++
    if (NAVAssertFalse('Boolean false test', 1 == 2))
    {
        passCount++
    }

    // Print test summary
    send_string 0, "'\n--- Test Summary ---'"
    send_string 0, "'Tests passed: ', itoa(passCount), '/', itoa(totalTests)"
    send_string 0, "'Success rate: ', ftoa((passCount * 100.0) / totalTests), '%'"
}
```

## Implementation Notes

- All assertion functions log test information using the NAVErrorLog system at NAV_LOG_LEVEL_DEBUG
- Test names are optional but recommended for clear identification of failing tests
- When an assertion fails, it logs both the expected and actual values
- The functions return a boolean value indicating success or failure, allowing them to be used in conditional logic
- For floating-point comparisons, consider using NAVAssertFloatAlmostEqual with a suitable epsilon value
- The assertion library does not abort execution on failure, allowing multiple tests to run in sequence

## Best Practices

1. **Use Descriptive Test Names**: Include meaningful test names that clearly identify what is being tested and what the expected outcome is.

2. **Test Edge Cases**: Include tests for boundary conditions, zero values, empty strings, and other edge cases.

3. **Group Related Tests**: Organize tests for related functionality together in test suite functions.

4. **Keep Tests Independent**: Each test should be independent of others and not rely on state changes from previous tests.

5. **Test Failure Conditions**: Assert that functions fail appropriately when given invalid inputs.

6. **Use Appropriate Assertion Types**: Choose the most appropriate assertion type for each test (e.g., use NAVAssertFloatAlmostEqual for floating-point comparisons).

7. **Run Tests Regularly**: Integrate testing into your development workflow and run tests after code changes.

8. **Track Test Coverage**: Ensure that you have assertions that cover all critical paths in your code.

## Real-World Testing Scenarios

### Device Control Module Testing

```netlinx
// Import the Assert module
#include 'NAVFoundation.Assert.axi'

// Test device control functions
define_function TestDeviceControlModule()
{
    stack_var char commandString[100]

    // Test command string generation
    commandString = BuildDeviceCommand('POWER', 'ON')
    NAVAssertStringEqual('Power on command', 'PWR1', commandString)

    commandString = BuildDeviceCommand('VOLUME', '50')
    NAVAssertStringEqual('Volume command', 'VOL50', commandString)

    // Test command validation
    NAVAssertTrue('Valid command check', IsValidCommand('PWR1'))
    NAVAssertFalse('Invalid command check', IsValidCommand('XYZ123'))

    // Test response parsing
    NAVAssertStringEqual('Response parsing', 'ON', ParseDeviceResponse('PWR=ON'))
    NAVAssertStringEqual('Error response parsing', 'ERROR', ParseDeviceResponse('ERR'))
}
```

### User Interface Logic Testing

```netlinx
// Import the Assert module
#include 'NAVFoundation.Assert.axi'

// Test UI state logic
define_function TestUIStateLogic()
{
    // Test button state calculations based on system state
    NAVAssertIntegerEqual('Home button active', BUTTON_STATE_ACTIVE,
                          CalculateButtonState(BUTTON_HOME, SYSTEM_STATE_NORMAL))

    NAVAssertIntegerEqual('Settings button disabled', BUTTON_STATE_DISABLED,
                          CalculateButtonState(BUTTON_SETTINGS, SYSTEM_STATE_LOCKED))

    // Test visibility logic
    NAVAssertTrue('Page visibility check - home page',
                   ShouldShowPage(PAGE_HOME, ACCESS_LEVEL_USER))

    NAVAssertFalse('Page visibility check - admin page',
                    ShouldShowPage(PAGE_ADMIN, ACCESS_LEVEL_USER))

    NAVAssertTrue('Page visibility check - admin access',
                   ShouldShowPage(PAGE_ADMIN, ACCESS_LEVEL_ADMIN))
}
```

### Data Processing Function Testing

```netlinx
// Import the Assert module
#include 'NAVFoundation.Assert.axi'

// Test data processing functions
define_function TestDataProcessing()
{
    stack_var char testJson[500]
    stack_var char extractedValue[100]
    stack_var integer arrayCount

    // Test JSON parsing
    testJson = '{"name":"Test Device","ip":"192.168.1.100","port":23}'
    extractedValue = ExtractJsonValue(testJson, 'name')
    NAVAssertStringEqual('JSON extract name', 'Test Device', extractedValue)

    extractedValue = ExtractJsonValue(testJson, 'ip')
    NAVAssertStringEqual('JSON extract IP', '192.168.1.100', extractedValue)

    // Test array processing
    arrayCount = CountArrayItems('apple,orange,banana', ',')
    NAVAssertIntegerEqual('Array item count', 3, arrayCount)

    extractedValue = GetArrayItem('apple,orange,banana', ',', 2)
    NAVAssertStringEqual('Array item extraction', 'orange', extractedValue)
}
```

## Limitations

- The assertion library relies on the NAVErrorLog system for output
- There's no automatic test discovery or runner; tests must be explicitly called
- Complex assertions requiring multiple conditions must be broken down into multiple assertion calls
- No built-in support for setup/teardown operations before and after tests
- Limited support for testing asynchronous operations; additional custom handling is required
