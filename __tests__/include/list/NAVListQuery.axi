PROGRAM_NAME='NAVListQuery'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char LIST_SIZE_TEST_OPERATIONS[][10] = {
    'initial',  // Test 1: Initial size (0)
    'add3',     // Test 2: After adding 3 items
    'remove1',  // Test 3: After removing 1 item
    'clear'     // Test 4: After clearing
}

constant integer LIST_SIZE_EXPECTED[] = {
    0,  // Test 1
    3,  // Test 2
    2,  // Test 3
    0   // Test 4
}

constant integer LIST_CAPACITY_TEST_INIT[] = {
    10,   // Test 1
    50,   // Test 2
    100   // Test 3
}

constant char LIST_ISEMPTY_TEST_OPERATIONS[][10] = {
    'initial',  // Test 1: Initially empty (TRUE)
    'add1',     // Test 2: After adding item (FALSE)
    'remove1',  // Test 3: After removing item (TRUE again)
    'add2'      // Test 4: After adding again (FALSE)
}

constant char LIST_ISEMPTY_EXPECTED[] = {
    true,   // Test 1
    false,  // Test 2
    true,   // Test 3
    false   // Test 4
}

constant char LIST_ISFULL_TEST_OPERATIONS[][10] = {
    'initial',  // Test 1: Initially empty (FALSE)
    'fill',     // Test 2: Fill to capacity (TRUE)
    'remove1',  // Test 3: Remove one (FALSE)
    'add1'      // Test 4: Add again (TRUE)
}

constant char LIST_ISFULL_EXPECTED[] = {
    false,  // Test 1
    true,   // Test 2
    false,  // Test 3
    true    // Test 4
}

constant char LIST_CONTAINS_TEST_ITEMS[][50] = {
    'Apple',      // Test 1: Exists (TRUE)
    'Banana',     // Test 2: Exists (TRUE)
    'Cherry',     // Test 3: Exists (TRUE)
    'Durian',     // Test 4: Does not exist (FALSE)
    'Elderberry', // Test 5: Exists (TRUE)
    'Fig'         // Test 6: Does not exist (FALSE)
}

constant char LIST_CONTAINS_EXPECTED[] = {
    true,   // Test 1
    true,   // Test 2
    true,   // Test 3
    false,  // Test 4
    true,   // Test 5
    false   // Test 6
}

constant char LIST_INDEXOF_TEST_ITEMS[][50] = {
    'Apple',      // Test 1: At index 1
    'Cherry',     // Test 2: At index 3
    'Elderberry', // Test 3: At index 5
    'Not Found',  // Test 4: Returns 0
    'Date',       // Test 5: At index 4
    'Missing'     // Test 6: Returns 0
}

constant integer LIST_INDEXOF_EXPECTED[] = {
    1,  // Test 1
    3,  // Test 2
    5,  // Test 3
    0,  // Test 4
    4,  // Test 5
    0   // Test 6
}

define_function TestNAVListSize() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListSize'")

    NAVListInit(list, 10)

    for (x = 1; x <= length_array(LIST_SIZE_TEST_OPERATIONS); x++) {
        stack_var integer result

        if (x == 2) {
            NAVListAdd(list, 'Item 1')
            NAVListAdd(list, 'Item 2')
            NAVListAdd(list, 'Item 3')
        }
        else if (x == 3) {
            NAVListRemove(list, 1)
        }
        else if (x == 4) {
            NAVListClear(list)
        }

        result = NAVListSize(list)

        if (!NAVAssertIntegerEqual('Size should match expected',
                                   LIST_SIZE_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(LIST_SIZE_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListSize'")
}

define_function TestNAVListCapacity() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVListCapacity'")

    for (x = 1; x <= length_array(LIST_CAPACITY_TEST_INIT); x++) {
        stack_var _NAVList list
        stack_var integer result

        NAVListInit(list, LIST_CAPACITY_TEST_INIT[x])
        result = NAVListCapacity(list)

        if (!NAVAssertIntegerEqual('Capacity should match init value',
                                   LIST_CAPACITY_TEST_INIT[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(LIST_CAPACITY_TEST_INIT[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListCapacity'")
}

define_function TestNAVListIsEmpty() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListIsEmpty'")

    NAVListInit(list, 10)

    for (x = 1; x <= length_array(LIST_ISEMPTY_TEST_OPERATIONS); x++) {
        stack_var char result

        if (x == 2 || x == 4) {
            NAVListAdd(list, 'Test Item')
        }
        else if (x == 3) {
            NAVListRemove(list, 1)
        }

        result = NAVListIsEmpty(list)

        if (!NAVAssertBooleanEqual('IsEmpty should match expected',
                                   LIST_ISEMPTY_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_ISEMPTY_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListIsEmpty'")
}

define_function TestNAVListIsFull() {
    stack_var integer x
    stack_var _NAVList list
    stack_var integer i

    NAVLogTestSuiteStart("'NAVListIsFull'")

    NAVListInit(list, 3)

    for (x = 1; x <= length_array(LIST_ISFULL_TEST_OPERATIONS); x++) {
        stack_var char result

        if (x == 2) {
            for (i = 1; i <= 3; i++) {
                NAVListAdd(list, "'Item ', itoa(i)")
            }
        }
        else if (x == 3) {
            NAVListRemove(list, 1)
        }
        else if (x == 4) {
            NAVListAdd(list, 'Item 4')
        }

        result = NAVListIsFull(list)

        if (!NAVAssertBooleanEqual('IsFull should match expected',
                                   LIST_ISFULL_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_ISFULL_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListIsFull'")
}

define_function TestNAVListContains() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListContains'")

    NAVListInit(list, 10)
    NAVListAdd(list, 'Apple')
    NAVListAdd(list, 'Banana')
    NAVListAdd(list, 'Cherry')
    NAVListAdd(list, 'Date')
    NAVListAdd(list, 'Elderberry')

    for (x = 1; x <= length_array(LIST_CONTAINS_TEST_ITEMS); x++) {
        stack_var char result

        result = NAVListContains(list, LIST_CONTAINS_TEST_ITEMS[x])

        if (!NAVAssertBooleanEqual('Contains should match expected',
                                   LIST_CONTAINS_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(LIST_CONTAINS_EXPECTED[x]),
                            NAVBooleanToString(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListContains'")
}

define_function TestNAVListIndexOf() {
    stack_var integer x
    stack_var _NAVList list

    NAVLogTestSuiteStart("'NAVListIndexOf'")

    NAVListInit(list, 10)
    NAVListAdd(list, 'Apple')
    NAVListAdd(list, 'Banana')
    NAVListAdd(list, 'Cherry')
    NAVListAdd(list, 'Date')
    NAVListAdd(list, 'Elderberry')

    for (x = 1; x <= length_array(LIST_INDEXOF_TEST_ITEMS); x++) {
        stack_var integer result

        result = NAVListIndexOf(list, LIST_INDEXOF_TEST_ITEMS[x])

        if (!NAVAssertIntegerEqual('IndexOf should match expected',
                                   LIST_INDEXOF_EXPECTED[x],
                                   result)) {
            NAVLogTestFailed(x,
                            itoa(LIST_INDEXOF_EXPECTED[x]),
                            itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVListIndexOf'")
}
