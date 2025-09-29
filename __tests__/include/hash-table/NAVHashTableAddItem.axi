PROGRAM_NAME='NAVHashTableAddItem'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char ADD_ITEM_TEST_KEYS[][50] = {
    'key1',
    'key2',
    'key3',
    'test_key',
    'simple'
}

constant char ADD_ITEM_TEST_VALUES[][100] = {
    'value1',
    'value2',
    'value3',
    'test_value',
    'simple_value'
}

/**
 * Test basic hash table add item functionality
 */
define_function TestNAVHashTableAddItem() {
    stack_var _NAVHashTable table
    stack_var integer slot

    NAVLog("'***************** NAVHashTableAddItem *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Test adding a single item
    slot = NAVHashTableAddItem(table, 'test_key', 'test_value')

    // Check slot is non-zero (valid)
    if (slot <= 0) {
        NAVLogTestFailed(1, 'positive slot number', itoa(slot))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test hash table add item validation and counts
 */
define_function TestNAVHashTableAddItemValidation() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var integer slot

    NAVLog("'***************** NAVHashTableAddItemValidation *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Test adding multiple items and verify count increases
    for (i = 1; i <= 3; i++) {
        slot = NAVHashTableAddItem(table, ADD_ITEM_TEST_KEYS[i], ADD_ITEM_TEST_VALUES[i])

        if (!NAVAssertIntegerEqual('Should update item count', i, table.ItemCount)) {
            NAVLogTestFailed(i, itoa(i), itoa(table.ItemCount))
        }
        else {
            NAVLogTestPassed(i)
        }
    }
}

/**
 * Test hash table add item value retrieval
 */
define_function TestNAVHashTableAddItemUpdate() {
    stack_var _NAVHashTable table
    stack_var integer slot

    NAVLog("'***************** NAVHashTableAddItemUpdate *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Add item and verify value
    slot = NAVHashTableAddItem(table, 'update_key', 'original_value')

    if (!NAVAssertStringEqual('Should add item correctly', 'original_value', NAVHashTableGetItemValue(table, 'update_key'))) {
        NAVLogTestFailed(1, 'original_value', NAVHashTableGetItemValue(table, 'update_key'))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Update existing key
    slot = NAVHashTableAddItem(table, 'update_key', 'updated_value')

    if (!NAVAssertStringEqual('Should update existing item', 'updated_value', NAVHashTableGetItemValue(table, 'update_key'))) {
        NAVLogTestFailed(2, 'updated_value', NAVHashTableGetItemValue(table, 'update_key'))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test hash table add item with empty key (should fail)
 */
define_function TestNAVHashTableAddItemEmptyKey() {
    stack_var _NAVHashTable table
    stack_var integer slot

    NAVLog("'***************** NAVHashTableAddItemEmptyKey *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Test adding empty key (should fail)
    slot = NAVHashTableAddItem(table, '', 'empty_key_value')

    if (!NAVAssertIntegerEqual('Empty key should return slot 0', 0, slot)) {
        NAVLogTestFailed(1, itoa(0), itoa(slot))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Empty key should set EMPTY_KEY error', NAV_HASH_TABLE_ERROR_EMPTY_KEY, table.LastError)) {
        NAVLogTestFailed(2, itoa(NAV_HASH_TABLE_ERROR_EMPTY_KEY), itoa(table.LastError))
    }
    else {
        NAVLogTestPassed(2)
    }
}
