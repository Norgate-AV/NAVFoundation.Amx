PROGRAM_NAME='NAVHashTableItemRemove'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REMOVE_TEST_KEYS[][50] = {
    'remove_key1',
    'remove_key2',
    'remove_key3',
    'test_remove'
}

constant char REMOVE_TEST_VALUES[][100] = {
    'remove_value1',
    'remove_value2',
    'remove_value3',
    'test_remove_value'
}

/**
 * Test basic hash table item remove functionality
 */
define_function TestNAVHashTableItemRemove() {
    stack_var _NAVHashTable table

    NAVLog("'***************** TestNAVHashTableItemRemove *****************'")

    // Initialize the hash table and add an item
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'test_key', 'test_value')

    // Verify item is there first
    if (!NAVAssertIntegerEqual('Should have 1 item', 1, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(1), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Remove the item
    NAVHashTableItemRemove(table, 'test_key')

    // Check item count is now 0
    if (!NAVAssertIntegerEqual('Should have 0 items after removal', 0, table.ItemCount)) {
        NAVLogTestFailed(2, itoa(0), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test hash table item remove validation
 */
define_function TestNAVHashTableItemRemoveValidation() {
    stack_var _NAVHashTable table
    stack_var integer i

    NAVLog("'***************** TestNAVHashTableItemRemoveValidation *****************'")

    // Initialize the hash table and add multiple items
    NAVHashTableInit(table)

    for (i = 1; i <= 3; i++) {
        NAVHashTableAddItem(table, REMOVE_TEST_KEYS[i], REMOVE_TEST_VALUES[i])
    }

    // Should have 3 items
    if (!NAVAssertIntegerEqual('Should have 3 items initially', 3, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(3), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Remove items one by one and verify count decreases
    for (i = 1; i <= 3; i++) {
        NAVHashTableItemRemove(table, REMOVE_TEST_KEYS[i])

        if (!NAVAssertIntegerEqual('Should decrease item count', 3 - i, table.ItemCount)) {
            NAVLogTestFailed(i + 1, itoa(3 - i), itoa(table.ItemCount))
        }
        else {
            NAVLogTestPassed(i + 1)
        }
    }
}

/**
 * Test hash table item remove verification
 */
define_function TestNAVHashTableItemRemoveVerification() {
    stack_var _NAVHashTable table
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVHashTableItemRemoveVerification *****************'")

    // Initialize the hash table and add an item
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'verify_key', 'verify_value')

    // Remove the item
    NAVHashTableItemRemove(table, 'verify_key')

    // Verify item was actually removed (should return empty string)
    result = NAVHashTableGetItemValue(table, 'verify_key')

    if (!NAVAssertStringEqual('Removed item should return empty string', '', result)) {
        NAVLogTestFailed(1, '', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    // Should set KEY_NOT_FOUND error when trying to get removed item
    if (!NAVAssertIntegerEqual('Should set KEY_NOT_FOUND error', NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND, table.LastError)) {
        NAVLogTestFailed(2, itoa(NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND), itoa(table.LastError))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test hash table item remove with empty key (should fail)
 */
define_function TestNAVHashTableItemRemoveEmptyKey() {
    stack_var _NAVHashTable table

    NAVLog("'***************** TestNAVHashTableItemRemoveEmptyKey *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Test removing empty key (should fail)
    NAVHashTableItemRemove(table, '')

    if (!NAVAssertIntegerEqual('Empty key should set EMPTY_KEY error', NAV_HASH_TABLE_ERROR_EMPTY_KEY, table.LastError)) {
        NAVLogTestFailed(1, itoa(NAV_HASH_TABLE_ERROR_EMPTY_KEY), itoa(table.LastError))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test hash table item remove with non-existent key
 */
define_function TestNAVHashTableItemRemoveNotFound() {
    stack_var _NAVHashTable table

    NAVLog("'***************** TestNAVHashTableItemRemoveNotFound *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Test removing non-existent key
    NAVHashTableItemRemove(table, 'non-existent-key')

    if (!NAVAssertIntegerEqual('Non-existent key should set KEY_NOT_FOUND error', NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND, table.LastError)) {
        NAVLogTestFailed(1, itoa(NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND), itoa(table.LastError))
    }
    else {
        NAVLogTestPassed(1)
    }
}