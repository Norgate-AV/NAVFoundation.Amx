PROGRAM_NAME='NAVListConversion'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char LIST_CLEAR_TEST_OPERATIONS[][10] = {
    'initial',  // Test 1: Count before clear
    'clear',    // Test 2: Count after clear (should be 0)
    'capacity', // Test 3: Capacity unchanged after clear
    'isempty'   // Test 4: IsEmpty should be TRUE after clear
}

constant integer LIST_CLEAR_EXPECTED[] = {
    4,   // Test 1: Initial count
    0,   // Test 2: After clear
    10,  // Test 3: Capacity unchanged
    1    // Test 4: IsEmpty TRUE
}

constant char LIST_FROMARRAY_TEST_SCENARIOS[][20] = {
    'normal',      // Test 1: Normal array (should succeed)
    'exceeds',     // Test 2: Array exceeds capacity (should fail)
    'empty'        // Test 3: Empty array (should succeed with count 0)
}

constant char LIST_FROMARRAY_EXPECTED_SUCCESS[] = {
    true,   // Test 1
    false,  // Test 2
    true    // Test 3
}

constant integer LIST_FROMARRAY_TEST_CAPACITY[] = {
    10,  // Test 1: Large enough
    2,   // Test 2: Too small
    10   // Test 3: Large enough
}

constant char LIST_TOARRAY_TEST_SCENARIOS[][10] = {
    'empty',      // Test 1: Empty list (should fail)
    'populated'   // Test 2: Populated list (should succeed)
}

constant char LIST_TOARRAY_EXPECTED_SUCCESS[] = {
    false,  // Test 1
    true    // Test 2
}

define_function TestNAVListClear() {
    stack_var integer x
    stack_var _NAVList list
    stack_var char testItem[NAV_MAX_LIST_ITEM_LENGTH]
    stack_var char getResult

    NAVLogTestSuiteStart("'NAVListClear'")

    NAVListInit(list, 10)
    NAVListAdd(list, 'Item 1')
    NAVListAdd(list, 'Item 2')
    NAVListAdd(list, 'Item 3')
    NAVListAdd(list, 'Item 4')

    for (x = 1; x <= length_array(LIST_CLEAR_TEST_OPERATIONS); x++) {
        stack_var integer result

        if (x == 2) {
            NAVListClear(list)
        }

        if (x == 1 || x == 2) {
            result = list.count
        }
        else if (x == 3) {
            result = list.capacity
        }
        else if (x == 4) {
            result = NAVListIsEmpty(list)
        }

        if (!NAVAssertIntegerEqual('Result should match expected',
                                   LIST_CLEAR_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(LIST_CLEAR_EXPECTED[x]),
                            itoa(result))
            continue
        }

        // After clear, verify items are truly inaccessible
        if (x == 2) {
            getResult = NAVListGet(list, 1, testItem)
            if (getResult) {
                NAVLogTestFailed(x, 'Get should fail after clear', 'Get succeeded')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListClear'")
}

define_function TestNAVListToArray() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVListToArray'")

    for (x = 1; x <= length_array(LIST_TOARRAY_TEST_SCENARIOS); x++) {
        stack_var _NAVList list
        stack_var char result
        stack_var char testArray[10][NAV_MAX_LIST_ITEM_LENGTH]

        NAVListInit(list, 10)

        if (x == 2) {
            NAVListAdd(list, 'Convert 1')
            NAVListAdd(list, 'Convert 2')
            NAVListAdd(list, 'Convert 3')
            NAVListAdd(list, 'Convert 4')
        }

        result = NAVListToArray(list, testArray)

        if (!NAVAssertBooleanEqual('ToArray result should match expected',
                                   LIST_TOARRAY_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_TOARRAY_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify array length and contents for successful conversion
        if (result && x == 2) {
            if (!NAVAssertIntegerEqual('Array length should match list count',
                                      4,
                                      length_array(testArray))) {
                NAVLogTestFailed(x, '4', itoa(length_array(testArray)))
                continue
            }

            if (!NAVAssertStringEqual('Array[1] should match',
                                     'Convert 1',
                                     testArray[1])) {
                NAVLogTestFailed(x, 'Convert 1', testArray[1])
                continue
            }

            if (!NAVAssertStringEqual('Array[4] should match',
                                     'Convert 4',
                                     testArray[4])) {
                NAVLogTestFailed(x, 'Convert 4', testArray[4])
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListToArray'")
}

define_function TestNAVListFromArray() {
    stack_var integer x
    stack_var char verifyItem[NAV_MAX_LIST_ITEM_LENGTH]

    NAVLogTestSuiteStart("'NAVListFromArray'")

    for (x = 1; x <= length_array(LIST_FROMARRAY_TEST_SCENARIOS); x++) {
        stack_var _NAVList list
        stack_var char result
        stack_var char testArray[10][50]

        NAVListInit(list, LIST_FROMARRAY_TEST_CAPACITY[x])

        if (x == 1 || x == 2) {
            testArray[1] = 'First'
            testArray[2] = 'Second'
            testArray[3] = 'Third'
            testArray[4] = 'Fourth'
            set_length_array(testArray, 4)
        }
        else if (x == 3) {
            set_length_array(testArray, 0)
        }

        result = NAVListFromArray(list, testArray)

        if (!NAVAssertBooleanEqual('FromArray result should match expected',
                                   LIST_FROMARRAY_EXPECTED_SUCCESS[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_FROMARRAY_EXPECTED_SUCCESS[x]),
                            NAVBooleanToString(result))
            continue
        }

        // Verify list count and contents for successful conversions
        if (result) {
            if (x == 1) {
                if (!NAVAssertIntegerEqual('List count should match array length',
                                          4,
                                          list.count)) {
                    NAVLogTestFailed(x, '4', itoa(list.count))
                    continue
                }

                NAVListGet(list, 1, verifyItem)
                if (!NAVAssertStringEqual('List[1] should match array[1]',
                                         'First',
                                         verifyItem)) {
                    NAVLogTestFailed(x, 'First', verifyItem)
                    continue
                }

                NAVListGet(list, 4, verifyItem)
                if (!NAVAssertStringEqual('List[4] should match array[4]',
                                         'Fourth',
                                         verifyItem)) {
                    NAVLogTestFailed(x, 'Fourth', verifyItem)
                    continue
                }
            }
            else if (x == 3) {
                if (!NAVAssertIntegerEqual('Empty array should result in count 0',
                                          0,
                                          list.count)) {
                    NAVLogTestFailed(x, '0', itoa(list.count))
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListFromArray'")
}
