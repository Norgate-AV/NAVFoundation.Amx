PROGRAM_NAME='NAVArraySetFunctions'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVArrayCharSetInit() {
    stack_var _NAVArrayCharSet set

    NAVLog("'***************** NAVArrayCharSetInit *****************'")

    NAVArrayCharSetInit(set, 10)

    // Test initialization
    if (set.size != 0) {
        NAVLogTestFailed(1, "'0'", "itoa(set.size)")
    }
    else if (set.capacity != 10) {
        NAVLogTestFailed(1, "'10'", "itoa(set.capacity)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayCharSetAdd() {
    stack_var _NAVArrayCharSet set
    stack_var char result

    NAVLog("'***************** NAVArrayCharSetAdd *****************'")

    NAVArrayCharSetInit(set, 10)

    // Test 1: Add unique value
    result = NAVArrayCharSetAdd(set, 'A')
    if (!result || set.size != 1) {
        NAVLogTestFailed(1, "'true, size=1'", "'false or wrong size'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Add duplicate value (should fail)
    result = NAVArrayCharSetAdd(set, 'A')
    if (result || set.size != 1) {
        NAVLogTestFailed(2, "'false, size=1'", "'true or wrong size'")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Add another unique value
    result = NAVArrayCharSetAdd(set, 'B')
    if (!result || set.size != 2) {
        NAVLogTestFailed(3, "'true, size=2'", "'false or wrong size'")
    }
    else {
        NAVLogTestPassed(3)
    }
}

define_function TestNAVArrayCharSetContains() {
    stack_var _NAVArrayCharSet set
    stack_var char result

    NAVLog("'***************** NAVArrayCharSetContains *****************'")

    NAVArrayCharSetInit(set, 10)
    NAVArrayCharSetAdd(set, 'A')
    NAVArrayCharSetAdd(set, 'B')
    NAVArrayCharSetAdd(set, 'C')

    // Test 1: Check for existing value
    result = NAVArrayCharSetContains(set, 'B')
    if (!result) {
        NAVLogTestFailed(1, "'true'", "'false'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // // Test 2: Check for non-existing value
    result = NAVArrayCharSetContains(set, 'Z')
    if (result) {
        NAVLogTestFailed(2, "'false'", "'true'")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVArrayCharSetRemove() {
    stack_var _NAVArrayCharSet set
    stack_var char result

    NAVLog("'***************** NAVArrayCharSetRemove *****************'")

    NAVArrayCharSetInit(set, 10)
    NAVArrayCharSetAdd(set, 'A')
    NAVArrayCharSetAdd(set, 'B')
    NAVArrayCharSetAdd(set, 'C')

    // Test 1: Remove existing value
    result = NAVArrayCharSetRemove(set, 'B')
    if (!result || set.size != 2) {
        NAVLogTestFailed(1, "'true, size=2'", "'false or wrong size'")
    }
    else if (NAVArrayCharSetContains(set, 'B')) {
        NAVLogTestFailed(1, "'B removed'", "'B still in set'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Remove non-existing value
    result = NAVArrayCharSetRemove(set, 'Z')
    if (result || set.size != 2) {
        NAVLogTestFailed(2, "'false, size=2'", "'true or wrong size'")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVArrayIntegerSetInit() {
    stack_var _NAVArrayIntegerSet set

    NAVLog("'***************** NAVArrayIntegerSetInit *****************'")

    NAVArrayIntegerSetInit(set, 10)

    // Test initialization
    if (set.size != 0) {
        NAVLogTestFailed(1, "'0'", "itoa(set.size)")
    }
    else if (set.capacity != 10) {
        NAVLogTestFailed(1, "'10'", "itoa(set.capacity)")
    }
    else {
        NAVLogTestPassed(1)
    }
}

define_function TestNAVArrayIntegerSetAdd() {
    stack_var _NAVArrayIntegerSet set
    stack_var char result

    NAVLog("'***************** NAVArrayIntegerSetAdd *****************'")

    NAVArrayIntegerSetInit(set, 10)

    // Test 1: Add unique value
    result = NAVArrayIntegerSetAdd(set, 42)
    if (!result || set.size != 1) {
        NAVLogTestFailed(1, "'true, size=1'", "'false or wrong size'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Add duplicate value (should fail)
    result = NAVArrayIntegerSetAdd(set, 42)
    if (result || set.size != 1) {
        NAVLogTestFailed(2, "'false, size=1'", "'true or wrong size'")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Add another unique value
    result = NAVArrayIntegerSetAdd(set, 99)
    if (!result || set.size != 2) {
        NAVLogTestFailed(3, "'true, size=2'", "'false or wrong size'")
    }
    else {
        NAVLogTestPassed(3)
    }
}

define_function TestNAVArrayIntegerSetContains() {
    stack_var _NAVArrayIntegerSet set
    stack_var char result

    NAVLog("'***************** NAVArrayIntegerSetContains *****************'")

    NAVArrayIntegerSetInit(set, 10)
    NAVArrayIntegerSetAdd(set, 10)
    NAVArrayIntegerSetAdd(set, 20)
    NAVArrayIntegerSetAdd(set, 30)

    // Test 1: Check for existing value
    result = NAVArrayIntegerSetContains(set, 20)
    if (!result) {
        NAVLogTestFailed(1, "'true'", "'false'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Check for non-existing value
    result = NAVArrayIntegerSetContains(set, 99)
    if (result) {
        NAVLogTestFailed(2, "'false'", "'true'")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVArrayIntegerSetRemove() {
    stack_var _NAVArrayIntegerSet set
    stack_var char result

    NAVLog("'***************** NAVArrayIntegerSetRemove *****************'")

    NAVArrayIntegerSetInit(set, 10)
    NAVArrayIntegerSetAdd(set, 10)
    NAVArrayIntegerSetAdd(set, 20)
    NAVArrayIntegerSetAdd(set, 30)

    // Test 1: Remove existing value
    result = NAVArrayIntegerSetRemove(set, 20)
    if (!result || set.size != 2) {
        NAVLogTestFailed(1, "'true, size=2'", "'false or wrong size'")
    }
    else if (NAVArrayIntegerSetContains(set, 20)) {
        NAVLogTestFailed(1, "'20 removed'", "'20 still in set'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Remove non-existing value
    result = NAVArrayIntegerSetRemove(set, 99)
    if (result || set.size != 2) {
        NAVLogTestFailed(2, "'false, size=2'", "'true or wrong size'")
    }
    else {
        NAVLogTestPassed(2)
    }
}

define_function TestNAVArrayCharSetFrom() {
    stack_var _NAVArrayCharSet set
    stack_var char sourceArray[5]

    NAVLog("'***************** NAVArrayCharSetFrom *****************'")

    // Test 1: Create set from array with unique values
    NAVArrayCharSetInit(set, 10)  // Initialize set with capacity first
    set_length_array(sourceArray, 5)
    sourceArray[1] = 'A'
    sourceArray[2] = 'B'
    sourceArray[3] = 'C'
    sourceArray[4] = 'D'
    sourceArray[5] = 'E'

    NAVArrayCharSetFrom(set, sourceArray)

    if (set.size != 5) {
        NAVLogTestFailed(1, "'size=5'", "itoa(set.size)")
    }
    else if (!NAVArrayCharSetContains(set, 'A') || !NAVArrayCharSetContains(set, 'E')) {
        NAVLogTestFailed(1, "'contains A and E'", "'missing values'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Create set from array with duplicate values
    NAVArrayCharSetInit(set, 10)  // Re-initialize for test 2
    set_length_array(sourceArray, 5)
    sourceArray[1] = 'X'
    sourceArray[2] = 'Y'
    sourceArray[3] = 'X'
    sourceArray[4] = 'Y'
    sourceArray[5] = 'Z'

    NAVArrayCharSetFrom(set, sourceArray)

    if (set.size != 3) {
        NAVLogTestFailed(2, "'size=3 (duplicates removed)'", "itoa(set.size)")
    }
    else if (!NAVArrayCharSetContains(set, 'X') || !NAVArrayCharSetContains(set, 'Y') || !NAVArrayCharSetContains(set, 'Z')) {
        NAVLogTestFailed(2, "'contains X, Y, Z'", "'missing values'")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Create set from empty array
    NAVArrayCharSetInit(set, 10)  // Re-initialize for test 3
    set_length_array(sourceArray, 0)

    NAVArrayCharSetFrom(set, sourceArray)

    if (set.size != 0) {
        NAVLogTestFailed(3, "'size=0'", "itoa(set.size)")
    }
    else {
        NAVLogTestPassed(3)
    }
}

define_function TestNAVArrayIntegerSetFrom() {
    stack_var _NAVArrayIntegerSet set
    stack_var integer sourceArray[5]

    NAVLog("'***************** NAVArrayIntegerSetFrom *****************'")

    // Test 1: Create set from array with unique values
    NAVArrayIntegerSetInit(set, 10)  // Initialize set with capacity first
    set_length_array(sourceArray, 5)
    sourceArray[1] = 10
    sourceArray[2] = 20
    sourceArray[3] = 30
    sourceArray[4] = 40
    sourceArray[5] = 50

    NAVArrayIntegerSetFrom(set, sourceArray)

    if (set.size != 5) {
        NAVLogTestFailed(1, "'size=5'", "itoa(set.size)")
    }
    else if (!NAVArrayIntegerSetContains(set, 10) || !NAVArrayIntegerSetContains(set, 50)) {
        NAVLogTestFailed(1, "'contains 10 and 50'", "'missing values'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Create set from array with duplicate values
    NAVArrayIntegerSetInit(set, 10)  // Re-initialize for test 2
    set_length_array(sourceArray, 5)
    sourceArray[1] = 100
    sourceArray[2] = 200
    sourceArray[3] = 100
    sourceArray[4] = 200
    sourceArray[5] = 300

    NAVArrayIntegerSetFrom(set, sourceArray)

    if (set.size != 3) {
        NAVLogTestFailed(2, "'size=3 (duplicates removed)'", "itoa(set.size)")
    }
    else if (!NAVArrayIntegerSetContains(set, 100) || !NAVArrayIntegerSetContains(set, 200) || !NAVArrayIntegerSetContains(set, 300)) {
        NAVLogTestFailed(2, "'contains 100, 200, 300'", "'missing values'")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Create set from empty array
    NAVArrayIntegerSetInit(set, 10)  // Re-initialize for test 3
    set_length_array(sourceArray, 0)

    NAVArrayIntegerSetFrom(set, sourceArray)

    if (set.size != 0) {
        NAVLogTestFailed(3, "'size=0'", "itoa(set.size)")
    }
    else {
        NAVLogTestPassed(3)
    }
}

define_function TestNAVArrayCharSetFind() {
    stack_var _NAVArrayCharSet set
    stack_var integer index

    NAVLog("'***************** NAVArrayCharSetFind *****************'")

    NAVArrayCharSetInit(set, 10)
    NAVArrayCharSetAdd(set, 'A')
    NAVArrayCharSetAdd(set, 'B')
    NAVArrayCharSetAdd(set, 'C')
    NAVArrayCharSetAdd(set, 'D')

    // Test 1: Find existing value at start
    index = NAVArrayCharSetFind(set, 'A')
    if (index <> 1) {
        NAVLogTestFailed(1, "'1'", "itoa(index)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find existing value in middle
    index = NAVArrayCharSetFind(set, 'C')
    if (index <> 3) {
        NAVLogTestFailed(2, "'3'", "itoa(index)")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Find non-existing value
    index = NAVArrayCharSetFind(set, 'Z')
    if (index <> 0) {
        NAVLogTestFailed(3, "'0'", "itoa(index)")
    }
    else {
        NAVLogTestPassed(3)
    }
}

define_function TestNAVArrayIntegerSetFind() {
    stack_var _NAVArrayIntegerSet set
    stack_var integer index

    NAVLog("'***************** NAVArrayIntegerSetFind *****************'")

    NAVArrayIntegerSetInit(set, 10)
    NAVArrayIntegerSetAdd(set, 10)
    NAVArrayIntegerSetAdd(set, 20)
    NAVArrayIntegerSetAdd(set, 30)
    NAVArrayIntegerSetAdd(set, 40)

    // Test 1: Find existing value at start
    index = NAVArrayIntegerSetFind(set, type_cast(10))
    if (index <> 1) {
        NAVLogTestFailed(1, "'1'", "itoa(index)")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test 2: Find existing value in middle
    index = NAVArrayIntegerSetFind(set, type_cast(30))
    if (index <> 3) {
        NAVLogTestFailed(2, "'3'", "itoa(index)")
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Find non-existing value
    index = NAVArrayIntegerSetFind(set, type_cast(99))
    if (index <> 0) {
        NAVLogTestFailed(3, "'0'", "itoa(index)")
    }
    else {
        NAVLogTestPassed(3)
    }
}
