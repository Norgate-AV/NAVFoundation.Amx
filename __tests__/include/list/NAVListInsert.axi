PROGRAM_NAME='NAVListInsert'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char LIST_INSERT_TEST_ITEMS[][50] = {
    'At Beginning',  // Test 1: Insert at index 1
    'In Middle',     // Test 2: Insert at index 3
    'At End',        // Test 3: Insert at count+1
    'Invalid Zero',  // Test 4: Insert at index 0 (invalid)
    'Beyond Limit',  // Test 5: Insert beyond count+1 (invalid)
    'When Full'      // Test 6: Insert when list is full (invalid)
}

constant integer LIST_INSERT_TEST_INDEX[] = {
    1,     // Test 1: At beginning
    3,     // Test 2: In middle
    4,     // Test 3: At end (after 3 items + insert at beginning)
    0,     // Test 4: Invalid (0)
    10,    // Test 5: Invalid (too high)
    1      // Test 6: When full
}

constant char LIST_INSERT_EXPECTED_SUCCESS[] = {
    true,   // Test 1: Valid
    true,   // Test 2: Valid
    true,   // Test 3: Valid
    false,  // Test 4: Invalid index
    false,  // Test 5: Invalid index
    false   // Test 6: List full
}

define_function TestNAVListInsert() {
    stack_var integer x
    stack_var _NAVList list
    stack_var char verifyItem[NAV_MAX_LIST_ITEM_LENGTH]

    NAVLogTestSuiteStart("'NAVListInsert'")

    NAVListInit(list, 10)

    // Add initial items
    NAVListAdd(list, 'First')
    NAVListAdd(list, 'Second')
    NAVListAdd(list, 'Third')

    for (x = 1; x <= length_array(LIST_INSERT_TEST_ITEMS); x++) {
        stack_var char result

        // For test 6, fill the list
        if (x == 6) {
            NAVListInit(list, 3)
            NAVListAdd(list, 'Full 1')
            NAVListAdd(list, 'Full 2')
            NAVListAdd(list, 'Full 3')
        }

        result = NAVListInsert(list, LIST_INSERT_TEST_INDEX[x], LIST_INSERT_TEST_ITEMS[x])

        if (!NAVAssertBooleanEqual('Insert result should match expected',
                                   LIST_INSERT_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_INSERT_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify item was inserted at correct position for successful cases
        if (result) {
            NAVListGet(list, LIST_INSERT_TEST_INDEX[x], verifyItem)
            if (!NAVAssertStringEqual('Inserted item should be at index',
                                     LIST_INSERT_TEST_ITEMS[x],
                                     verifyItem)) {
                NAVLogTestFailed(x,
                                LIST_INSERT_TEST_ITEMS[x],
                                verifyItem)
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListInsert'")
}
