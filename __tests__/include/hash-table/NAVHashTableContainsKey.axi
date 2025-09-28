PROGRAM_NAME='NAVHashTableContainsKey'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char CONTAINS_TEST_KEYS[][50] = {
    'contains_key1',
    'contains_key2',
    'contains_key3',
    'test_contains'
}

constant char CONTAINS_TEST_VALUES[][100] = {
    'contains_value1',
    'contains_value2',
    'contains_value3',
    'test_contains_value'
}

/**
 * Test basic hash table contains key functionality
 */
define_function TestNAVHashTableContainsKey() {
    stack_var _NAVHashTable table
    stack_var integer result

    NAVLog("'***************** TestNAVHashTableContainsKey *****************'")

    // Initialize the hash table and add an item
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'test_key', 'test_value')

    // Test that key exists
    result = NAVHashTableContainsKey(table, 'test_key')

    if (!NAVAssertIntegerEqual('Should find existing key', 1, result)) {
        NAVLogTestFailed(1, itoa(1), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test hash table contains key with multiple items
 */
define_function TestNAVHashTableContainsKeyMultiple() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var integer result

    NAVLog("'***************** TestNAVHashTableContainsKeyMultiple *****************'")

    // Initialize the hash table and add multiple items
    NAVHashTableInit(table)

    for (i = 1; i <= 3; i++) {
        NAVHashTableAddItem(table, CONTAINS_TEST_KEYS[i], CONTAINS_TEST_VALUES[i])
    }

    // Test that all keys exist
    for (i = 1; i <= 3; i++) {
        result = NAVHashTableContainsKey(table, CONTAINS_TEST_KEYS[i])

        if (!NAVAssertIntegerEqual('Should find existing key', 1, result)) {
            NAVLogTestFailed(i, itoa(1), itoa(result))
            return
        }
        else {
            NAVLogTestPassed(i)
        }
    }
}

/**
 * Test hash table contains key with non-existent key
 */
define_function TestNAVHashTableContainsKeyNotFound() {
    stack_var _NAVHashTable table
    stack_var integer result

    NAVLog("'***************** TestNAVHashTableContainsKeyNotFound *****************'")

    // Initialize the hash table and add an item
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'existing_key', 'existing_value')

    // Test non-existent key
    result = NAVHashTableContainsKey(table, 'non-existent-key')

    if (!NAVAssertIntegerEqual('Non-existent key should return 0', 0, result)) {
        NAVLogTestFailed(1, itoa(0), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test hash table contains key with empty key (should fail)
 */
define_function TestNAVHashTableContainsKeyEmpty() {
    stack_var _NAVHashTable table
    stack_var integer result

    NAVLog("'***************** TestNAVHashTableContainsKeyEmpty *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Test empty key
    result = NAVHashTableContainsKey(table, '')

    if (!NAVAssertIntegerEqual('Empty key should return 0', 0, result)) {
        NAVLogTestFailed(1, itoa(0), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test hash table contains key after removal
 */
define_function TestNAVHashTableContainsKeyAfterRemoval() {
    stack_var _NAVHashTable table
    stack_var integer result

    NAVLog("'***************** TestNAVHashTableContainsKeyAfterRemoval *****************'")

    // Initialize the hash table and add an item
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'removal_test', 'removal_value')

    // Verify key exists first
    result = NAVHashTableContainsKey(table, 'removal_test')
    if (!NAVAssertIntegerEqual('Key should exist initially', 1, result)) {
        NAVLogTestFailed(1, itoa(1), itoa(result))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Remove the item
    NAVHashTableItemRemove(table, 'removal_test')

    // Test that key no longer exists
    result = NAVHashTableContainsKey(table, 'removal_test')

    if (!NAVAssertIntegerEqual('Removed key should not be found', 0, result)) {
        NAVLogTestFailed(2, itoa(0), itoa(result))
    }
    else {
        NAVLogTestPassed(2)
    }
}