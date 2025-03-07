PROGRAM_NAME='NAVAssertTests'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Assert.axi'

/**
 * @function TestAssertChar
 * @description Test the char assertion functions
 */
define_function char TestAssertChar() {
    stack_var char passed

    passed = true

    // Test passing assertions
    if (NAVAssertCharEqual('Equal chars', 'A', 'A') != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for equal chars'")
    }

    // Test failing assertions
    if (NAVAssertCharEqual('Unequal chars', 'A', 'B') != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for unequal chars'")
    }

    return passed
}

/**
 * @function TestAssertWideChar
 * @description Test the widechar assertion functions
 */
define_function char TestAssertWideChar() {
    stack_var char passed
    stack_var widechar wc1, wc2

    passed = true
    wc1 = 65535  // Maximum 16-bit value
    wc2 = 65534  // Different 16-bit value

    // Test passing assertions
    if (NAVAssertWideCharEqual('Equal wide chars', wc1, wc1) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for equal wide chars'")
    }

    // Test failing assertions
    if (NAVAssertWideCharEqual('Unequal wide chars', wc1, wc2) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for unequal wide chars'")
    }

    return passed
}

/**
 * @function TestAssertSignedInteger
 * @description Test the signed integer assertion functions
 */
define_function char TestAssertSignedInteger() {
    stack_var char passed

    passed = true

    // Test passing assertions
    if (NAVAssertSignedIntegerEqual('Equal signed integers', -42, -42) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for equal signed integers'")
    }

    // Test failing assertions
    if (NAVAssertSignedIntegerEqual('Unequal signed integers', -42, 42) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for unequal signed integers'")
    }

    return passed
}

/**
 * @function TestAssertLong
 * @description Test the long assertion functions
 */
define_function char TestAssertLong() {
    stack_var char passed
    stack_var long l1, l2

    passed = true
    l1 = $12345678  // A large 32-bit value
    l2 = $87654321  // Different 32-bit value

    // Test passing assertions
    if (NAVAssertLongEqual('Equal longs', l1, l1) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for equal longs'")
    }

    // Test failing assertions
    if (NAVAssertLongEqual('Unequal longs', l1, l2) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for unequal longs'")
    }

    return passed
}

/**
 * @function TestAssertSignedLong
 * @description Test the signed long assertion functions
 */
define_function char TestAssertSignedLong() {
    stack_var char passed
    stack_var slong sl1, sl2

    passed = true
    sl1 = type_cast(-2147483000)  // Large negative 32-bit value
    sl2 = type_cast(2147483000)   // Large positive 32-bit value

    // Test passing assertions
    if (NAVAssertSignedLongEqual('Equal signed longs', sl1, sl1) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for equal signed longs'")
    }

    // Test failing assertions
    if (NAVAssertSignedLongEqual('Unequal signed longs', sl1, sl2) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for unequal signed longs'")
    }

    return passed
}

/**
 * @function TestAssertFloat
 * @description Test the float assertion functions
 */
define_function char TestAssertFloat() {
    stack_var char passed
    stack_var float f1, f2

    passed = true
    f1 = 3.14159
    f2 = 2.71828

    // Test passing assertions
    if (NAVAssertFloatEqual('Equal floats', f1, f1) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for equal floats'")
    }

    // Test failing assertions
    if (NAVAssertFloatEqual('Unequal floats', f1, f2) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for unequal floats'")
    }

    return passed
}

/**
 * @function TestAssertDouble
 * @description Test the double assertion functions
 */
define_function char TestAssertDouble() {
    stack_var char passed
    stack_var double d1, d2

    passed = true
    d1 = 123456789.123456
    d2 = 987654321.987654

    // Test passing assertions
    if (NAVAssertDoubleEqual('Equal doubles', d1, d1) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for equal doubles'")
    }

    // Test failing assertions
    if (NAVAssertDoubleEqual('Unequal doubles', d1, d2) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for unequal doubles'")
    }

    return passed
}

/**
 * @function TestAssertInteger
 * @description Test the integer assertion functions
 */
define_function char TestAssertInteger() {
    stack_var char passed

    passed = true

    // Test passing assertions
    if (NAVAssertIntegerEqual('Equal integers', 42, 42) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for equal integers'")
    }

    // Test failing assertions (should return false)
    if (NAVAssertIntegerEqual('Unequal integers', 42, 43) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for unequal integers'")
    }

    return passed
}

/**
 * @function TestAssertString
 * @description Test the string assertion functions
 */
define_function char TestAssertString() {
    stack_var char passed

    passed = true

    // Test passing assertions
    if (NAVAssertStringEqual('Equal strings', 'test', 'test') != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for equal strings'")
    }

    // Test failing assertions (should return false)
    if (NAVAssertStringEqual('Unequal strings', 'test', 'not test') != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for unequal strings'")
    }

    return passed
}

/**
 * @function TestAssertInt64
 * @description Test the Int64 assertion functions
 */
define_function char TestAssertInt64() {
    stack_var _NAVInt64 a, b, c
    stack_var char passed

    passed = true

    // Set up test values
    a.Hi = 1; a.Lo = 2
    b.Hi = 1; b.Lo = 2
    c.Hi = 1; c.Lo = 3

    // Test passing assertions
    if (NAVAssertInt64Equal('Equal Int64', a, b) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for equal Int64 values'")
    }

    // Test failing assertions (should return false)
    if (NAVAssertInt64Equal('Unequal Int64', a, c) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for unequal Int64 values'")
    }

    return passed
}

/**
 * @function TestAssertComparisonOperations
 * @description Test the comparison assertion functions (not equal, greater than, less than, etc.)
 */
define_function char TestAssertComparisonOperations() {
    stack_var char passed

    passed = true

    // Test string not equal
    if (NAVAssertStringNotEqual('String not equal test', 'test1', 'test2') != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for not equal strings'")
    }

    if (NAVAssertStringNotEqual('String not equal fail test', 'test', 'test') != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false when strings are equal'")
    }

    // Test integer not equal
    if (NAVAssertIntegerNotEqual('Integer not equal test', 5, 10) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for not equal integers'")
    }

    if (NAVAssertIntegerNotEqual('Integer not equal fail test', 5, 5) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false when integers are equal'")
    }

    // Test integer greater than
    if (NAVAssertIntegerGreaterThan('Integer greater than test', 5, 10) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for 10 > 5'")
    }

    if (NAVAssertIntegerGreaterThan('Integer greater than fail test', 10, 5) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for 5 > 10'")
    }

    // Test integer less than
    if (NAVAssertIntegerLessThan('Integer less than test', 10, 5) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for 5 < 10'")
    }

    if (NAVAssertIntegerLessThan('Integer less than fail test', 5, 10) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for 10 < 5'")
    }

    // Test integer greater than or equal
    if (NAVAssertIntegerGreaterThanOrEqual('Integer greater than or equal test', 5, 10) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for 10 >= 5'")
    }

    if (NAVAssertIntegerGreaterThanOrEqual('Integer greater than or equal test (equal)', 5, 5) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for 5 >= 5'")
    }

    if (NAVAssertIntegerGreaterThanOrEqual('Integer greater than or equal fail test', 10, 5) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for 5 >= 10'")
    }

    // Test integer less than or equal
    if (NAVAssertIntegerLessThanOrEqual('Integer less than or equal test', 10, 5) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for 5 <= 10'")
    }

    if (NAVAssertIntegerLessThanOrEqual('Integer less than or equal test (equal)', 5, 5) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for 5 <= 5'")
    }

    if (NAVAssertIntegerLessThanOrEqual('Integer less than or equal fail test', 5, 10) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for 10 <= 5'")
    }

    return passed
}

/**
 * @function TestAssertFloatComparisons
 * @description Test the float comparison assertion functions
 */
define_function char TestAssertFloatComparisons() {
    stack_var char passed
    stack_var float f1, f2, f3

    passed = true
    f1 = 3.14159
    f2 = 2.71828
    f3 = 3.14159  // Same as f1

    // Test float not equal
    if (NAVAssertFloatNotEqual('Float not equal test', f1, f2) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for not equal floats'")
    }

    if (NAVAssertFloatNotEqual('Float not equal fail test', f1, f3) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false when floats are equal'")
    }

    // Test float greater than
    if (NAVAssertFloatGreaterThan('Float greater than test', f2, f1) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for pi > e'")
    }

    if (NAVAssertFloatGreaterThan('Float greater than fail test', f1, f2) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for e > pi'")
    }

    // Test float less than
    if (NAVAssertFloatLessThan('Float less than test', f1, f2) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for e < pi'")
    }

    if (NAVAssertFloatLessThan('Float less than fail test', f2, f1) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for pi < e'")
    }

    // Test float greater than or equal
    if (NAVAssertFloatGreaterThanOrEqual('Float greater than or equal test', f2, f1) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for pi >= e'")
    }

    if (NAVAssertFloatGreaterThanOrEqual('Float greater than or equal test (equal)', f1, f3) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for pi >= pi'")
    }

    if (NAVAssertFloatGreaterThanOrEqual('Float greater than or equal fail test', f1, f2) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for e >= pi'")
    }

    // Test float less than or equal
    if (NAVAssertFloatLessThanOrEqual('Float less than or equal test', f1, f2) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for e <= pi'")
    }

    if (NAVAssertFloatLessThanOrEqual('Float less than or equal test (equal)', f1, f3) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for pi <= pi'")
    }

    if (NAVAssertFloatLessThanOrEqual('Float less than or equal fail test', f2, f1) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for pi <= e'")
    }

    return passed
}

/**
 * @function TestAssertTrueFalse
 * @description Test the true/false assertion functions
 */
define_function char TestAssertTrueFalse() {
    stack_var char passed
    stack_var char trueValue, falseValue

    passed = true
    trueValue = true
    falseValue = false

    // Test NAVAssertTrue with true value
    if (NAVAssertTrue('Testing true condition', trueValue) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true when checking true value'")
    }

    // Test NAVAssertTrue with false value
    if (NAVAssertTrue('Testing false condition', falseValue) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false when checking false value'")
    }

    // Test NAVAssertFalse with false value
    if (NAVAssertFalse('Testing false condition', falseValue) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true when checking false value'")
    }

    // Test NAVAssertFalse with true value
    if (NAVAssertFalse('Testing true condition', trueValue) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false when checking true value'")
    }

    return passed
}

/**
 * @function TestAssertAdditionalNotEqual
 * @description Test the additional not equal assertion functions
 */
define_function char TestAssertAdditionalNotEqual() {
    stack_var char passed
    stack_var _NAVInt64 a, b

    passed = true

    // Test char not equal
    if (NAVAssertCharNotEqual('Char not equal test', 'A', 'B') != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for different chars'")
    }

    if (NAVAssertCharNotEqual('Char not equal fail test', 'A', 'A') != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for same chars'")
    }

    // Test signed integer not equal
    if (NAVAssertSignedIntegerNotEqual('Signed int not equal test', -42, 42) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for different signed integers'")
    }

    if (NAVAssertSignedIntegerNotEqual('Signed int not equal fail test', -42, -42) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for same signed integers'")
    }

    // Test Int64 not equal
    a.Hi = 1; a.Lo = 2
    b.Hi = 1; b.Lo = 3

    if (NAVAssertInt64NotEqual('Int64 not equal test', a, b) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for different Int64 values'")
    }

    if (NAVAssertInt64NotEqual('Int64 not equal fail test', a, a) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for same Int64 values'")
    }

    return passed
}

/**
 * @function TestAssertStringOperations
 * @description Test the string operation assertion functions
 */
define_function char TestAssertStringOperations() {
    stack_var char passed

    passed = true

    // Test string contains
    if (NAVAssertStringContains('String contains test', 'world', 'Hello world') != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for string containing substring'")
    }

    if (NAVAssertStringContains('String contains fail test', 'universe', 'Hello world') != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for string not containing substring'")
    }

    // Test string starts with
    if (NAVAssertStringStartsWith('String starts with test', 'Hello', 'Hello world') != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for string starting with prefix'")
    }

    if (NAVAssertStringStartsWith('String starts with fail test', 'world', 'Hello world') != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for string not starting with prefix'")
    }

    // Test string ends with
    if (NAVAssertStringEndsWith('String ends with test', 'world', 'Hello world') != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for string ending with suffix'")
    }

    if (NAVAssertStringEndsWith('String ends with fail test', 'Hello', 'Hello world') != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for string not ending with suffix'")
    }

    return passed
}

/**
 * @function TestAssertFloatAlmostEqual
 * @description Test the float almost equal assertion function
 */
define_function char TestAssertFloatAlmostEqual() {
    stack_var char passed
    stack_var float epsilon

    passed = true
    epsilon = 0.001

    // Test values within epsilon
    if (NAVAssertFloatAlmostEqual('Float almost equal test', 1.0005, 1.0000, epsilon) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for floats within epsilon'")
    }

    // Test values not within epsilon
    if (NAVAssertFloatAlmostEqual('Float almost equal fail test', 1.002, 1.000, epsilon) != false) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected false for floats not within epsilon'")
    }

    // Test with negative values
    if (NAVAssertFloatAlmostEqual('Float almost equal negative test', -1.0005, -1.0000, epsilon) != true) {
        passed = false
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected true for negative floats within epsilon'")
    }

    return passed
}

/**
 * @function RunNAVAssertTests
 * @description Run all assertion tests
 */
define_function RunNAVAssertTests() {
    stack_var integer passCount, totalTests

    passCount = 0
    totalTests = 16  // Updated to include all tests

    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'****************** NAVAssert Tests ******************'")

    // Test 1: Char assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1: Char assertions'")
    if (TestAssertChar() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 1 failed'")
    }

    // Test 2: Wide Char assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2: Wide Char assertions'")
    if (TestAssertWideChar() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 2 failed'")
    }

    // Test 3: Integer assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3: Integer assertions'")
    if (TestAssertInteger() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 3 failed'")
    }

    // Test 4: Signed Integer assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4: Signed Integer assertions'")
    if (TestAssertSignedInteger() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 4 failed'")
    }

    // Test 5: Long assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5: Long assertions'")
    if (TestAssertLong() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 5 failed'")
    }

    // Test 6: Signed Long assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 6: Signed Long assertions'")
    if (TestAssertSignedLong() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 6 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 6 failed'")
    }

    // Test 7: Float assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 7: Float assertions'")
    if (TestAssertFloat() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 7 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 7 failed'")
    }

    // Test 8: Double assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 8: Double assertions'")
    if (TestAssertDouble() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 8 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 8 failed'")
    }

    // Test 9: String assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 9: String assertions'")
    if (TestAssertString() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 9 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 9 failed'")
    }

    // Test 10: Int64 assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 10: Int64 assertions'")
    if (TestAssertInt64() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 10 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 10 failed'")
    }

    // Test 11: Comparison operation assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 11: Comparison operation assertions'")
    if (TestAssertComparisonOperations() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 11 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 11 failed'")
    }

    // Test 12: Float comparison assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 12: Float comparison assertions'")
    if (TestAssertFloatComparisons() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 12 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 12 failed'")
    }

    // Test 13: True/False assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 13: True/False assertions'")
    if (TestAssertTrueFalse() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 13 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 13 failed'")
    }

    // Test 14: Additional Not Equal assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 14: Additional Not Equal assertions'")
    if (TestAssertAdditionalNotEqual() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 14 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 14 failed'")
    }

    // Test 15: String operation assertions
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 15: String operation assertions'")
    if (TestAssertStringOperations() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 15 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 15 failed'")
    }

    // Test 16: Float almost equal assertion
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 16: Float almost equal assertion'")
    if (TestAssertFloatAlmostEqual() == true) {
        passCount++
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 16 passed'")
    }
    else {
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Test 16 failed'")
    }

    // Summary
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'NAVAssert: ', itoa(passCount), ' of ', itoa(totalTests), ' tests passed'")
}
