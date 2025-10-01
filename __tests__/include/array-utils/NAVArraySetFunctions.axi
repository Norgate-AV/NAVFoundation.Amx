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
