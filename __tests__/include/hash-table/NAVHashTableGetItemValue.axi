PROGRAM_NAME='NAVHashTableGetItemValue'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char GET_ITEM_TEST_KEYS[][50] = {
    'test_key1',
    'test_key2',
    'test_key3',
    'lookup_key'
}

constant char GET_ITEM_TEST_VALUES[][100] = {
    'test_value1',
    'test_value2',
    'test_value3',
    'lookup_value'
}

/**
 * Test basic hash table get item value functionality
 */
define_function TestNAVHashTableGetItemValue() {
    stack_var _NAVHashTable table
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVHashTableGetItemValue *****************'")

    // Initialize the hash table and add an item
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'test_key', 'test_value')

    // Test retrieving the value
    result = NAVHashTableGetItemValue(table, 'test_key')

    if (!NAVAssertStringEqual('Should retrieve correct value', 'test_value', result)) {
        NAVLogTestFailed(1, 'test_value', result)
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test hash table get item value with multiple items
 */
define_function TestNAVHashTableGetItemValueMultiple() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVHashTableGetItemValueMultiple *****************'")

    // Initialize the hash table and add multiple items
    NAVHashTableInit(table)

    for (i = 1; i <= 3; i++) {
        NAVHashTableAddItem(table, GET_ITEM_TEST_KEYS[i], GET_ITEM_TEST_VALUES[i])
    }

    // Test retrieving each value
    for (i = 1; i <= 3; i++) {
        result = NAVHashTableGetItemValue(table, GET_ITEM_TEST_KEYS[i])

        if (!NAVAssertStringEqual('Should retrieve correct value', GET_ITEM_TEST_VALUES[i], result)) {
            NAVLogTestFailed(i, GET_ITEM_TEST_VALUES[i], result)
        }
        else {
            NAVLogTestPassed(i)
        }
    }
}

/**
 * Test hash table get item value with empty key (should fail)
 */
define_function TestNAVHashTableGetItemValueEmptyKey() {
    stack_var _NAVHashTable table
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVHashTableGetItemValueEmptyKey *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Test empty key
    result = NAVHashTableGetItemValue(table, '')

    if (!NAVAssertStringEqual('Empty key should return empty string', '', result)) {
        NAVLogTestFailed(1, '', result)
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

/**
 * Test hash table get item value with non-existent key
 */
define_function TestNAVHashTableGetItemValueNotFound() {
    stack_var _NAVHashTable table
    stack_var char result[NAV_MAX_BUFFER]

    NAVLog("'***************** TestNAVHashTableGetItemValueNotFound *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Test non-existent key
    result = NAVHashTableGetItemValue(table, 'non-existent-key')

    if (!NAVAssertStringEqual('Non-existent key should return empty string', '', result)) {
        NAVLogTestFailed(1, '', result)
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Non-existent key should set KEY_NOT_FOUND error', NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND, table.LastError)) {
        NAVLogTestFailed(2, itoa(NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND), itoa(table.LastError))
    }
    else {
        NAVLogTestPassed(2)
    }
}
