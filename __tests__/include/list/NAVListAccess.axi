PROGRAM_NAME='NAVListAccess'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant integer LIST_GET_TEST_INDEX[] = {
    1,     // Test 1: Get first item
    3,     // Test 2: Get middle item
    5,     // Test 3: Get last item
    0,     // Test 4: Invalid index (0)
    10     // Test 5: Invalid index (beyond count)
}

constant char LIST_GET_EXPECTED_ITEMS[][50] = {
    'Alpha',    // Test 1
    'Gamma',    // Test 2
    'Epsilon',  // Test 3
    '',         // Test 4: Invalid
    ''          // Test 5: Invalid
}

constant char LIST_GET_EXPECTED_SUCCESS[] = {
    true,   // Test 1-3: Valid
    true,
    true,
    false,  // Test 4-5: Invalid
    false
}

constant char LIST_FIRST_TEST_SETUP[][10] = {
    'empty',     // Test 1: Empty list (should fail)
    'populated'  // Test 2: Populated list (should succeed)
}

constant char LIST_FIRST_EXPECTED_SUCCESS[] = {
    false,  // Test 1: Empty
    true    // Test 2: Populated
}

constant integer LIST_SET_TEST_INDEX[] = {
    3,     // Test 1: Set middle item
    1,     // Test 2: Set first item
    5,     // Test 3: Set last item
    0,     // Test 4: Invalid index (0)
    10     // Test 5: Invalid index (beyond count)
}

constant char LIST_SET_TEST_ITEMS[][50] = {
    'Updated Gamma',  // Test 1
    'Updated Alpha',  // Test 2
    'Updated Epsilon',// Test 3
    'Should Fail',    // Test 4
    'Should Fail'     // Test 5
}

constant char LIST_SET_EXPECTED_SUCCESS[] = {
    true,   // Test 1-3: Valid
    true,
    true,
    false,  // Test 4-5: Invalid
    false
}

constant char LIST_LAST_TEST_SETUP[][10] = {
    'empty',     // Test 1: Empty list (should fail)
    'populated'  // Test 2: Populated list (should succeed)
}

constant char LIST_LAST_EXPECTED_SUCCESS[] = {
    false,  // Test 1: Empty
    true    // Test 2: Populated
}

constant char LIST_POP_TEST_SETUP[][10] = {
    'empty',      // Test 1: Pop from empty list (should fail)
    'populated',  // Test 2: Pop from populated list (should succeed)
    'again'       // Test 3: Pop again (should succeed)
}

constant char LIST_POP_EXPECTED_SUCCESS[] = {
    false,  // Test 1: Empty
    true,   // Test 2: Populated
    true    // Test 3: Again
}

define_function TestNAVListGet() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListGet'")

    NAVListInit(list, 10)
    NAVListAdd(list, 'Alpha')
    NAVListAdd(list, 'Beta')
    NAVListAdd(list, 'Gamma')
    NAVListAdd(list, 'Delta')
    NAVListAdd(list, 'Epsilon')

    for (x = 1; x <= length_array(LIST_GET_TEST_INDEX); x++) {
        stack_var char result
        stack_var char item[NAV_MAX_LIST_ITEM_LENGTH]

        result = NAVListGet(list, LIST_GET_TEST_INDEX[x], item)

        if (!NAVAssertBooleanEqual('Get result should match expected',
                                   LIST_GET_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_GET_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify retrieved value for successful cases
        if (result && LIST_GET_EXPECTED_ITEMS[x] != '') {
            if (!NAVAssertStringEqual('Retrieved item should match expected',
                                     LIST_GET_EXPECTED_ITEMS[x],
                                     item)) {
                NAVLogTestFailed(x,
                                LIST_GET_EXPECTED_ITEMS[x],
                                item)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListGet'")
}

define_function TestNAVListSet() {
    stack_var integer x
    stack_var _NAVList list
    stack_var char verifyItem[NAV_MAX_LIST_ITEM_LENGTH]

    NAVLogTestSuiteStart("'NAVListSet'")

    NAVListInit(list, 10)
    NAVListAdd(list, 'Alpha')
    NAVListAdd(list, 'Beta')
    NAVListAdd(list, 'Gamma')
    NAVListAdd(list, 'Delta')
    NAVListAdd(list, 'Epsilon')

    for (x = 1; x <= length_array(LIST_SET_TEST_INDEX); x++) {
        stack_var char result

        result = NAVListSet(list, LIST_SET_TEST_INDEX[x], LIST_SET_TEST_ITEMS[x])

        if (!NAVAssertBooleanEqual('Set result should match expected',
                                   LIST_SET_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_SET_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify value was actually updated for successful cases
        if (result) {
            NAVListGet(list, LIST_SET_TEST_INDEX[x], verifyItem)
            if (!NAVAssertStringEqual('Set value should match',
                                     LIST_SET_TEST_ITEMS[x],
                                     verifyItem)) {
                NAVLogTestFailed(x,
                                LIST_SET_TEST_ITEMS[x],
                                verifyItem)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListSet'")
}

define_function TestNAVListFirst() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListFirst'")

    for (x = 1; x <= length_array(LIST_FIRST_TEST_SETUP); x++) {
        stack_var char result
        stack_var char item[NAV_MAX_LIST_ITEM_LENGTH]

        NAVListInit(list, 10)

        if (x == 2) {
            NAVListAdd(list, 'First Item')
            NAVListAdd(list, 'Second Item')
        }

        result = NAVListFirst(list, item)

        if (!NAVAssertBooleanEqual('First result should match expected',
                                   LIST_FIRST_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_FIRST_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify retrieved value for successful case
        if (result && x == 2) {
            if (!NAVAssertStringEqual('First item should match expected',
                                     'First Item',
                                     item)) {
                NAVLogTestFailed(x, 'First Item', item)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListFirst'")
}

define_function TestNAVListLast() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListLast'")

    for (x = 1; x <= length_array(LIST_LAST_TEST_SETUP); x++) {
        stack_var char result
        stack_var char item[NAV_MAX_LIST_ITEM_LENGTH]

        NAVListInit(list, 10)

        if (x == 2) {
            NAVListAdd(list, 'First Item')
            NAVListAdd(list, 'Last Item')
        }

        result = NAVListLast(list, item)

        if (!NAVAssertBooleanEqual('Last result should match expected',
                                   LIST_LAST_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_LAST_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify retrieved value for successful case
        if (result && x == 2) {
            if (!NAVAssertStringEqual('Last item should match expected',
                                     'Last Item',
                                     item)) {
                NAVLogTestFailed(x, 'Last Item', item)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListLast'")
}

define_function TestNAVListPop() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListPop'")

    NAVListInit(list, 10)

    for (x = 1; x <= length_array(LIST_POP_TEST_SETUP); x++) {
        stack_var char result
        stack_var char item[NAV_MAX_LIST_ITEM_LENGTH]

        if (x == 2) {
            NAVListAdd(list, 'Item 1')
            NAVListAdd(list, 'Item 2')
            NAVListAdd(list, 'Item 3')
        }

        result = NAVListPop(list, item)

        if (!NAVAssertBooleanEqual('Pop result should match expected',
                                   LIST_POP_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_POP_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify popped value and count for successful cases
        if (result) {
            if (x == 2) {
                if (!NAVAssertStringEqual('Popped item should be last',
                                         'Item 3',
                                         item)) {
                    NAVLogTestFailed(x, 'Item 3', item)
                    continue
                }
                if (!NAVAssertIntegerEqual('Count should decrease',
                                          2,
                                          list.count)) {
                    NAVLogTestFailed(x, '2', itoa(list.count))
                    continue
                }
            }
            else if (x == 3) {
                if (!NAVAssertStringEqual('Popped item should be second',
                                         'Item 2',
                                         item)) {
                    NAVLogTestFailed(x, 'Item 2', item)
                    continue
                }
                if (!NAVAssertIntegerEqual('Count should decrease again',
                                          1,
                                          list.count)) {
                    NAVLogTestFailed(x, '1', itoa(list.count))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListPop'")
}
