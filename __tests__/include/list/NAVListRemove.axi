PROGRAM_NAME='NAVListRemove'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant integer LIST_REMOVE_TEST_INDEX[] = {
    3,     // Test 1: Remove from middle
    1,     // Test 2: Remove from beginning
    2,     // Test 3: Remove from end (after previous removals, count=2)
    0,     // Test 4: Invalid index (0)
    10     // Test 5: Invalid index (beyond count)
}

constant char LIST_REMOVE_EXPECTED_SUCCESS[] = {
    true,   // Test 1: Valid
    true,   // Test 2: Valid
    true,   // Test 3: Valid
    false,  // Test 4: Invalid index
    false   // Test 5: Invalid index
}

constant char LIST_REMOVE_ITEM_TEST_ITEMS[][50] = {
    'Item 3',      // Test 1: Remove existing item
    'Not Found',   // Test 2: Remove non-existent item
    'Item 1'       // Test 3: Remove first occurrence (when duplicate exists)
}

constant char LIST_REMOVE_ITEM_EXPECTED_SUCCESS[] = {
    true,   // Test 1: Should succeed
    false,  // Test 2: Should fail (not found)
    true    // Test 3: Should succeed (removes first)
}

define_function TestNAVListRemove() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListRemove'")

    NAVListInit(list, 10)

    // Add initial items
    NAVListAdd(list, 'Item 1')
    NAVListAdd(list, 'Item 2')
    NAVListAdd(list, 'Item 3')
    NAVListAdd(list, 'Item 4')
    NAVListAdd(list, 'Item 5')

    for (x = 1; x <= length_array(LIST_REMOVE_TEST_INDEX); x++) {
        stack_var char result

        result = NAVListRemove(list, LIST_REMOVE_TEST_INDEX[x])

        if (!NAVAssertBooleanEqual('Remove result should match expected',
                                   LIST_REMOVE_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_REMOVE_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify count decreased and items shifted for successful removes
        if (result) {
            if (x == 1) {
                // After removing index 3 (Item 3), count should be 4
                if (!NAVAssertIntegerEqual('Count should decrease',
                                          4,
                                          list.count)) {
                    NAVLogTestFailed(x, '4', itoa(list.count))
                    continue
                }
            }
            else if (x == 2) {
                // After removing index 1 (Item 1), count should be 3
                if (!NAVAssertIntegerEqual('Count should decrease',
                                          3,
                                          list.count)) {
                    NAVLogTestFailed(x, '3', itoa(list.count))
                    continue
                }
            }
            else if (x == 3) {
                // After removing index 2, count should be 2
                if (!NAVAssertIntegerEqual('Count should decrease',
                                          2,
                                          list.count)) {
                    NAVLogTestFailed(x, '2', itoa(list.count))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListRemove'")
}

define_function TestNAVListRemoveItem() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListRemoveItem'")

    NAVListInit(list, 10)

    // Add initial items
    NAVListAdd(list, 'Item 1')
    NAVListAdd(list, 'Item 2')
    NAVListAdd(list, 'Item 3')
    NAVListAdd(list, 'Item 4')
    NAVListAdd(list, 'Item 5')

    for (x = 1; x <= length_array(LIST_REMOVE_ITEM_TEST_ITEMS); x++) {
        stack_var char result

        // For test 3, add duplicate
        if (x == 3) {
            NAVListAdd(list, 'Item 1')
        }

        result = NAVListRemoveItem(list, LIST_REMOVE_ITEM_TEST_ITEMS[x])

        if (!NAVAssertBooleanEqual('RemoveItem result should match expected',
                                   LIST_REMOVE_ITEM_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_REMOVE_ITEM_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // For test 3, verify first occurrence was removed and duplicate remains
        if (result && x == 3) {
            stack_var integer remainingIndex
            remainingIndex = NAVListIndexOf(list, 'Item 1')
            // The duplicate was at the end, after removal it should be at position 4
            if (!NAVAssertIntegerEqual('Duplicate should remain at shifted position',
                                      4,
                                      remainingIndex)) {
                NAVLogTestFailed(x, '4', itoa(remainingIndex))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListRemoveItem'")
}
