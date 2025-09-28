PROGRAM_NAME='NAVHashTableClear'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char CLEAR_TEST_KEYS[][50] = {
    'clear_key1',
    'clear_key2',
    'clear_key3',
    'test_clear'
}

constant char CLEAR_TEST_VALUES[][100] = {
    'clear_value1',
    'clear_value2',
    'clear_value3',
    'test_clear_value'
}

/**
 * Test basic hash table clear functionality
 */
define_function TestNAVHashTableClear() {
    stack_var _NAVHashTable table

    NAVLog("'***************** TestNAVHashTableClear *****************'")

    // Initialize the hash table and add some items
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'test_key1', 'test_value1')
    NAVHashTableAddItem(table, 'test_key2', 'test_value2')

    // Verify items are in the hash table
    if (!NAVAssertIntegerEqual('Should have 2 items initially', 2, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(2), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Clear the hash table
    NAVHashTableClear(table)

    // Check item count is reset to 0
    if (!NAVAssertIntegerEqual('Should have 0 items after clear', 0, table.ItemCount)) {
        NAVLogTestFailed(2, itoa(0), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test hash table clear with multiple items
 */
define_function TestNAVHashTableClearMultiple() {
    stack_var _NAVHashTable table
    stack_var integer i

    NAVLog("'***************** TestNAVHashTableClearMultiple *****************'")

    // Initialize the hash table and add multiple items
    NAVHashTableInit(table)

    for (i = 1; i <= 4; i++) {
        NAVHashTableAddItem(table, CLEAR_TEST_KEYS[i], CLEAR_TEST_VALUES[i])
    }

    // Verify all items are added
    if (!NAVAssertIntegerEqual('Should have 4 items initially', 4, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(4), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Clear the hash table
    NAVHashTableClear(table)

    // Check item count is 0
    if (!NAVAssertIntegerEqual('Should have 0 items after clear', 0, table.ItemCount)) {
        NAVLogTestFailed(2, itoa(0), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test hash table clear verification (all slots empty)
 */
define_function TestNAVHashTableClearVerification() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var integer emptyCount

    NAVLog("'***************** TestNAVHashTableClearVerification *****************'")

    // Initialize the hash table and add items
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'verify_key1', 'verify_value1')
    NAVHashTableAddItem(table, 'verify_key2', 'verify_value2')

    // Clear the hash table
    NAVHashTableClear(table)

    // Check that all slots contain NULL key
    emptyCount = 0
    for (i = 1; i <= NAV_HASH_TABLE_SIZE; i++) {
        if (table.Items[i].Key == "NAV_NULL") {
            emptyCount++
        }
    }

    if (!NAVAssertIntegerEqual('All slots should be empty after clear', NAV_HASH_TABLE_SIZE, emptyCount)) {
        NAVLogTestFailed(1, itoa(NAV_HASH_TABLE_SIZE), itoa(emptyCount))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test hash table clear on empty table
 */
define_function TestNAVHashTableClearEmpty() {
    stack_var _NAVHashTable table

    NAVLog("'***************** TestNAVHashTableClearEmpty *****************'")

    // Initialize the hash table (but don't add items)
    NAVHashTableInit(table)

    // Verify table is empty
    if (!NAVAssertIntegerEqual('Should start with 0 items', 0, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(0), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Clear the empty hash table (should work fine)
    NAVHashTableClear(table)

    // Should still be 0
    if (!NAVAssertIntegerEqual('Should remain 0 items after clear', 0, table.ItemCount)) {
        NAVLogTestFailed(2, itoa(0), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test hash table functionality after clear
 */
define_function TestNAVHashTableClearAndReuse() {
    stack_var _NAVHashTable table

    NAVLog("'***************** TestNAVHashTableClearAndReuse *****************'")

    // Initialize, add items, and clear
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'temp_key', 'temp_value')
    NAVHashTableClear(table)

    // Add new items after clear
    NAVHashTableAddItem(table, 'new_key', 'new_value')

    // Should have 1 item
    if (!NAVAssertIntegerEqual('Should have 1 item after reuse', 1, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(1), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Should be able to retrieve the new item
    if (!NAVAssertStringEqual('Should retrieve new value', 'new_value', NAVHashTableGetItemValue(table, 'new_key'))) {
        NAVLogTestFailed(2, 'new_value', NAVHashTableGetItemValue(table, 'new_key'))
    }
    else {
        NAVLogTestPassed(2)
    }
}
