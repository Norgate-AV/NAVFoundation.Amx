PROGRAM_NAME='length-array-behavior-test'

/*
 * Test program to demonstrate LENGTH_ARRAY behavior in different circumstances.
 * This program tests how LENGTH_ARRAY behaves with:
 * - Initialized arrays (constants)
 * - Global arrays with and without initializers
 * - Stack arrays (local variables)
 * - After SET_LENGTH_ARRAY calls
 * - After modifying array elements
 */

DEFINE_CONSTANT

// Test 1: Constant arrays with initializers
CONSTANT INTEGER CONST_ARRAY_FULL[] = {1, 2, 3, 4, 5}
CONSTANT INTEGER CONST_ARRAY_PARTIAL[] = {10, 20}

// Test 2: Constant arrays with declared size
CONSTANT INTEGER CONST_ARRAY_DECLARED[10] = {1, 2, 3}

DEFINE_VARIABLE

// Test 3: Global arrays with initializers
INTEGER globalArrayInit[] = {100, 200, 300, 400}

// Test 4: Global arrays without initializers
INTEGER globalArrayNoInit[10]
INTEGER globalArrayNoInit2[5]

// Test 5: Global array that will be modified
INTEGER globalModifiable[8]

DEFINE_START

// ========================================
// TEST 1: Constant Arrays with Initializers
// ========================================
send_string 0, "'========================================'"
send_string 0, "'TEST 1: Constant Arrays with Initializers'"
send_string 0, "'========================================'"

send_string 0, "'CONST_ARRAY_FULL[] = {1,2,3,4,5}'"
send_string 0, "'  MAX_LENGTH_ARRAY: ', itoa(max_length_array(CONST_ARRAY_FULL))"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(CONST_ARRAY_FULL))"
send_string 0, "'  EXPECTED: Both = 5 (initializer sets length implicitly)'"
send_string 0, "''"

send_string 0, "'CONST_ARRAY_PARTIAL[] = {10,20}'"
send_string 0, "'  MAX_LENGTH_ARRAY: ', itoa(max_length_array(CONST_ARRAY_PARTIAL))"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(CONST_ARRAY_PARTIAL))"
send_string 0, "'  EXPECTED: Both = 2 (initializer sets length implicitly)'"
send_string 0, "''"

send_string 0, "'CONST_ARRAY_DECLARED[10] = {1,2,3}'"
send_string 0, "'  MAX_LENGTH_ARRAY: ', itoa(max_length_array(CONST_ARRAY_DECLARED))"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(CONST_ARRAY_DECLARED))"
send_string 0, "'  EXPECTED: MAX=10, LENGTH=3 (initializer sets length to 3)'"
send_string 0, "''"

// ========================================
// TEST 2: Global Arrays with Initializers
// ========================================
send_string 0, "'========================================'"
send_string 0, "'TEST 2: Global Arrays with Initializers'"
send_string 0, "'========================================'"

send_string 0, "'globalArrayInit[] = {100,200,300,400}'"
send_string 0, "'  MAX_LENGTH_ARRAY: ', itoa(max_length_array(globalArrayInit))"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(globalArrayInit))"
send_string 0, "'  EXPECTED: Both = 4 (initializer sets length implicitly)'"
send_string 0, "''"

// ========================================
// TEST 3: Global Arrays WITHOUT Initializers
// ========================================
send_string 0, "'========================================'"
send_string 0, "'TEST 3: Global Arrays WITHOUT Initializers'"
send_string 0, "'========================================'"

send_string 0, "'globalArrayNoInit[10] (no initializer)'"
send_string 0, "'  MAX_LENGTH_ARRAY: ', itoa(max_length_array(globalArrayNoInit))"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(globalArrayNoInit))"
send_string 0, "'  EXPECTED: MAX=10, LENGTH=? (undefined without initializer)'"
send_string 0, "''"

// ========================================
// TEST 4: Modifying Array Elements
// ========================================
send_string 0, "'========================================'"
send_string 0, "'TEST 4: Does Modifying Elements Change LENGTH_ARRAY?'"
send_string 0, "'========================================'"

send_string 0, "'globalModifiable[8] - Initial state:'"
send_string 0, "'  MAX_LENGTH_ARRAY: ', itoa(max_length_array(globalModifiable))"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(globalModifiable))"

// Modify some elements
globalModifiable[1] = 111
globalModifiable[2] = 222
globalModifiable[3] = 333

send_string 0, "'After setting elements [1]=111, [2]=222, [3]=333:'"
send_string 0, "'  MAX_LENGTH_ARRAY: ', itoa(max_length_array(globalModifiable))"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(globalModifiable))"
send_string 0, "'  EXPECTED: LENGTH unchanged (per NetLinx docs!)'"
send_string 0, "''"

// ========================================
// TEST 5: Explicit SET_LENGTH_ARRAY
// ========================================
send_string 0, "'========================================'"
send_string 0, "'TEST 5: Using SET_LENGTH_ARRAY Explicitly'"
send_string 0, "'========================================'"

send_string 0, "'globalArrayNoInit2[5] - Before SET_LENGTH_ARRAY:'"
send_string 0, "'  MAX_LENGTH_ARRAY: ', itoa(max_length_array(globalArrayNoInit2))"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(globalArrayNoInit2))"

// Populate some elements
globalArrayNoInit2[1] = 10
globalArrayNoInit2[2] = 20
globalArrayNoInit2[3] = 30

send_string 0, "'After populating [1]=10, [2]=20, [3]=30 (no SET_LENGTH_ARRAY):'"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(globalArrayNoInit2))"

// Now explicitly set the length
set_length_array(globalArrayNoInit2, 3)

send_string 0, "'After SET_LENGTH_ARRAY(array, 3):'"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(globalArrayNoInit2))"
send_string 0, "'  EXPECTED: LENGTH=3 now'"
send_string 0, "''"

// Change the length again
set_length_array(globalArrayNoInit2, 5)

send_string 0, "'After SET_LENGTH_ARRAY(array, 5):'"
send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(globalArrayNoInit2))"
send_string 0, "'  EXPECTED: LENGTH=5 now'"
send_string 0, "''"

// ========================================
// TEST 6: Stack Variables (Local Arrays)
// ========================================
send_string 0, "'========================================'"
send_string 0, "'TEST 6: Stack Variables (Local Arrays)'"
send_string 0, "'========================================'"

TestStackArrays()

send_string 0, "''"
send_string 0, "'========================================'"
send_string 0, "'SUMMARY OF FINDINGS'"
send_string 0, "'========================================'"
send_string 0, "'1. Arrays with initializers have LENGTH_ARRAY set implicitly'"
send_string 0, "'2. Arrays without initializers have undefined LENGTH_ARRAY'"
send_string 0, "'3. Modifying elements does NOT change LENGTH_ARRAY'"
send_string 0, "'4. SET_LENGTH_ARRAY must be called explicitly to set length'"
send_string 0, "'5. Stack arrays behave differently - see function below'"
send_string 0, "'========================================'"

DEFINE_FUNCTION TestStackArrays() {
    stack_var integer stackArray1[10]
    stack_var integer stackArray2[5]
    stack_var integer x

    send_string 0, "'Inside TestStackArrays function:'"
    send_string 0, "''"

    // Test stack array without any initialization
    send_string 0, "'stackArray1[10] - Immediately after declaration:'"
    send_string 0, "'  MAX_LENGTH_ARRAY: ', itoa(max_length_array(stackArray1))"
    send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(stackArray1))"
    send_string 0, "'  EXPECTED: MAX=10, LENGTH=? (often 0 for stack vars)'"
    send_string 0, "''"

    // Populate some elements
    stackArray1[1] = 100
    stackArray1[2] = 200
    stackArray1[3] = 300

    send_string 0, "'After populating [1]=100, [2]=200, [3]=300:'"
    send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(stackArray1))"
    send_string 0, "'  EXPECTED: Unchanged (modifying elements does not set length)'"
    send_string 0, "''"

    // Explicitly set length
    set_length_array(stackArray1, 3)

    send_string 0, "'After SET_LENGTH_ARRAY(stackArray1, 3):'"
    send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(stackArray1))"
    send_string 0, "'  EXPECTED: LENGTH=3'"
    send_string 0, "''"

    // Test with a loop population
    send_string 0, "'stackArray2[5] - Populating via loop:'"

    for (x = 1; x <= 5; x++) {
        stackArray2[x] = x * 10
    }

    send_string 0, "'After loop: for (x=1; x<=5; x++) array[x] = x*10'"
    send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(stackArray2))"
    send_string 0, "'  EXPECTED: Still undefined/0 (loop does not set length)'"
    send_string 0, "''"

    // Now set the length
    set_length_array(stackArray2, 5)

    send_string 0, "'After SET_LENGTH_ARRAY(stackArray2, 5):'"
    send_string 0, "'  LENGTH_ARRAY:     ', itoa(length_array(stackArray2))"
    send_string 0, "'  EXPECTED: LENGTH=5'"
}
