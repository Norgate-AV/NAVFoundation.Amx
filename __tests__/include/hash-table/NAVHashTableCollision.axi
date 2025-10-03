PROGRAM_NAME='NAVHashTableCollision'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char COLLISION_TEST_KEYS[][50] = {
    'collision_key1',
    'collision_key2',
    'test_hash_a',
    'test_hash_b'
}

constant char COLLISION_TEST_VALUES[][100] = {
    'collision_value1',
    'collision_value2',
    'test_value_a',
    'test_value_b'
}

/**
 * Test basic hash table collision handling
 */
define_function TestNAVHashTableCollision() {
    stack_var _NAVHashTable table
    stack_var char value1[NAV_MAX_CHARS]
    stack_var char value2[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableCollision *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Add first key-value pair
    NAVHashTableAddItem(table, COLLISION_TEST_KEYS[1], COLLISION_TEST_VALUES[1])

    // Add second key-value pair (may cause collision depending on hash)
    NAVHashTableAddItem(table, COLLISION_TEST_KEYS[2], COLLISION_TEST_VALUES[2])

    // Verify both items were added
    if (!NAVAssertIntegerEqual('Should have 2 items after adding both keys', 2, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(2), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test that both values can be retrieved correctly
    value1 = NAVHashTableGetItemValue(table, COLLISION_TEST_KEYS[1])
    if (!NAVAssertStringEqual('Should retrieve first collision value', COLLISION_TEST_VALUES[1], value1)) {
        NAVLogTestFailed(2, COLLISION_TEST_VALUES[1], value1)
    }
    else {
        NAVLogTestPassed(2)
    }

    value2 = NAVHashTableGetItemValue(table, COLLISION_TEST_KEYS[2])
    if (!NAVAssertStringEqual('Should retrieve second collision value', COLLISION_TEST_VALUES[2], value2)) {
        NAVLogTestFailed(3, COLLISION_TEST_VALUES[2], value2)
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test hash table collision with multiple items
 */
define_function TestNAVHashTableCollisionMultiple() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var char retrievedValue[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableCollisionMultiple *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Add multiple items that may collide
    for (i = 1; i <= 4; i++) {
        NAVHashTableAddItem(table, COLLISION_TEST_KEYS[i], COLLISION_TEST_VALUES[i])
    }

    // Verify all items were added
    if (!NAVAssertIntegerEqual('Should have 4 items after adding all keys', 4, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(4), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test that all values can be retrieved correctly
    for (i = 1; i <= 4; i++) {
        retrievedValue = NAVHashTableGetItemValue(table, COLLISION_TEST_KEYS[i])
        if (!NAVAssertStringEqual("'Should retrieve collision value ', itoa(i)", COLLISION_TEST_VALUES[i], retrievedValue)) {
            NAVLogTestFailed(i + 1, COLLISION_TEST_VALUES[i], retrievedValue)
        }
        else {
            NAVLogTestPassed(i + 1)
        }
    }
}

/**
 * Test collision handling during item removal
 */
define_function TestNAVHashTableCollisionRemoval() {
    stack_var _NAVHashTable table
    stack_var char value[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableCollisionRemoval *****************'")

    // Initialize and add test items
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'remove_test1', 'remove_value1')
    NAVHashTableAddItem(table, 'remove_test2', 'remove_value2')
    NAVHashTableAddItem(table, 'remove_test3', 'remove_value3')

    // Remove the first item
    NAVHashTableItemRemove(table, 'remove_test1')

    // Verify remaining items are still accessible
    value = NAVHashTableGetItemValue(table, 'remove_test2')
    if (!NAVAssertStringEqual('Should retrieve second item after removal', 'remove_value2', value)) {
        NAVLogTestFailed(1, 'remove_value2', value)
    }
    else {
        NAVLogTestPassed(1)
    }

    value = NAVHashTableGetItemValue(table, 'remove_test3')
    if (!NAVAssertStringEqual('Should retrieve third item after removal', 'remove_value3', value)) {
        NAVLogTestFailed(2, 'remove_value3', value)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Verify item count is correct
    if (!NAVAssertIntegerEqual('Should have 2 items after removal', 2, table.ItemCount)) {
        NAVLogTestFailed(3, itoa(2), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test hash table behavior with duplicate key handling
 */
define_function TestNAVHashTableCollisionDuplicateKey() {
    stack_var _NAVHashTable table
    stack_var char value[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableCollisionDuplicateKey *****************'")

    // Initialize and add an item
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'duplicate_key', 'original_value')

    // Add the same key with a different value (should update)
    NAVHashTableAddItem(table, 'duplicate_key', 'updated_value')

    // Should still have only 1 item
    if (!NAVAssertIntegerEqual('Should have 1 item after duplicate key', 1, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(1), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Should retrieve the updated value
    value = NAVHashTableGetItemValue(table, 'duplicate_key')
    if (!NAVAssertStringEqual('Should retrieve updated value for duplicate key', 'updated_value', value)) {
        NAVLogTestFailed(2, 'updated_value', value)
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test hash table collision with key existence checks
 */
define_function TestNAVHashTableCollisionContains() {
    stack_var _NAVHashTable table

    NAVLog("'***************** TestNAVHashTableCollisionContains *****************'")

    // Initialize and add test items
    NAVHashTableInit(table)
    NAVHashTableAddItem(table, 'contains_test1', 'contains_value1')
    NAVHashTableAddItem(table, 'contains_test2', 'contains_value2')

    // Test that both keys are found
    if (!NAVAssertIntegerEqual('Should contain first key', 1, NAVHashTableContainsKey(table, 'contains_test1'))) {
        NAVLogTestFailed(1, itoa(1), itoa(NAVHashTableContainsKey(table, 'contains_test1')))
    }
    else {
        NAVLogTestPassed(1)
    }

    if (!NAVAssertIntegerEqual('Should contain second key', 1, NAVHashTableContainsKey(table, 'contains_test2'))) {
        NAVLogTestFailed(2, itoa(1), itoa(NAVHashTableContainsKey(table, 'contains_test2')))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test that non-existent key is not found
    if (!NAVAssertIntegerEqual('Should not contain non-existent key', 0, NAVHashTableContainsKey(table, 'nonexistent_key'))) {
        NAVLogTestFailed(3, itoa(0), itoa(NAVHashTableContainsKey(table, 'nonexistent_key')))
    }
    else {
        NAVLogTestPassed(3)
    }
}
