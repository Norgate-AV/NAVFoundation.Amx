PROGRAM_NAME='NAVListInit'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant integer LIST_INIT_TEST_CAPACITY[] = {
    10,              // Test 1: Normal capacity
    50,              // Test 2: Medium capacity
    NAV_MAX_LIST_SIZE,  // Test 3: Maximum capacity
    1,               // Test 4: Minimum capacity
    0,               // Test 5: Zero capacity (should be clamped to 1)
    NAV_MAX_LIST_SIZE + 10  // Test 6: Over max (should be clamped to max)
}

constant integer LIST_INIT_EXPECTED_CAPACITY[] = {
    10,              // Test 1
    50,              // Test 2
    NAV_MAX_LIST_SIZE,  // Test 3
    1,               // Test 4
    1,               // Test 5: Clamped to 1
    NAV_MAX_LIST_SIZE   // Test 6: Clamped to max
}

define_function TestNAVListInit() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVListInit'")

    for (x = 1; x <= length_array(LIST_INIT_TEST_CAPACITY); x++) {
        stack_var _NAVList list

        NAVListInit(list, LIST_INIT_TEST_CAPACITY[x])

        if (!NAVAssertIntegerEqual('Capacity should be set correctly',
                                   LIST_INIT_EXPECTED_CAPACITY[x],
                                   list.capacity)) {
            NAVLogTestFailed(x,
                            itoa(LIST_INIT_EXPECTED_CAPACITY[x]),
                            itoa(list.capacity))
            continue
        }

        if (!NAVAssertIntegerEqual('Count should be 0',
                                   0,
                                   list.count)) {
            NAVLogTestFailed(x, itoa(0), itoa(list.count))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListInit'")
}
