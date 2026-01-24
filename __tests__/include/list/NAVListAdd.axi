PROGRAM_NAME='NAVListAdd'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char LIST_ADD_TEST_ITEMS[][50] = {
    'Item 1',        // Test 1: Add first item
    'Item 2',        // Test 2: Add second item
    'Item 3',        // Test 3: Add third item
    'Test String',   // Test 4: Add fourth item
    'Another Item',  // Test 5: Add fifth item
    'Full List'      // Test 6: Add to full list (should fail)
}

constant integer LIST_ADD_TEST_CAPACITY[] = {
    10,  // Test 1-5: Large capacity
    10,
    10,
    10,
    10,
    5    // Test 6: Capacity exactly at limit before this test
}

constant char LIST_ADD_EXPECTED_SUCCESS[] = {
    true,   // Test 1-5: Should succeed
    true,
    true,
    true,
    true,
    false   // Test 6: Should fail (list full)
}

define_function TestNAVListAdd() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListAdd'")

    NAVListInit(list, LIST_ADD_TEST_CAPACITY[1])

    for (x = 1; x <= length_array(LIST_ADD_TEST_ITEMS); x++) {
        stack_var char result

        // For test 6, reinitialize with smaller capacity and fill it
        if (x == 6) {
            NAVListInit(list, 5)
            NAVListAdd(list, 'Fill 1')
            NAVListAdd(list, 'Fill 2')
            NAVListAdd(list, 'Fill 3')
            NAVListAdd(list, 'Fill 4')
            NAVListAdd(list, 'Fill 5')
        }

        result = NAVListAdd(list, LIST_ADD_TEST_ITEMS[x])

        if (!NAVAssertBooleanEqual('Add result should match expected',
                                   LIST_ADD_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_ADD_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify count incremented for successful adds
        if (result && x <= 5) {
            if (!NAVAssertIntegerEqual('Count should increment',
                                      x,
                                      list.count)) {
                NAVLogTestFailed(x, itoa(x), itoa(list.count))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListAdd'")
}
