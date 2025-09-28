PROGRAM_NAME='NAVHashTableIntegrity'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char INTEGRITY_TEST_KEYS[][50] = {
    'integrity_key_1',
    'integrity_key_2',
    'integrity_key_3',
    'integrity_key_4',
    'integrity_key_5'
}

constant char INTEGRITY_TEST_VALUES[][100] = {
    'integrity_value_1',
    'integrity_value_2',
    'integrity_value_3',
    'integrity_value_4',
    'integrity_value_5'
}

/**
 * Test data persistence through multiple operations
 */
define_function TestNAVHashTableDataPersistence() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var char retrievedValue[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableDataPersistence *****************'")

    NAVHashTableInit(table)

    // Add initial data
    for (i = 1; i <= 5; i++) {
        NAVHashTableAddItem(table, INTEGRITY_TEST_KEYS[i], INTEGRITY_TEST_VALUES[i])
    }

    // Perform various operations that might affect data integrity
    NAVHashTableAddItem(table, 'temp_key', 'temp_value')
    NAVHashTableItemRemove(table, 'temp_key')
    NAVHashTableAddItem(table, 'another_temp', 'another_value')
    NAVHashTableItemRemove(table, 'another_temp')

    // Verify original data is still intact
    for (i = 1; i <= 5; i++) {
        retrievedValue = NAVHashTableGetItemValue(table, INTEGRITY_TEST_KEYS[i])
        if (!NAVAssertStringEqual('Data should persist through operations', INTEGRITY_TEST_VALUES[i], retrievedValue)) {
            NAVLogTestFailed(i, INTEGRITY_TEST_VALUES[i], retrievedValue)
        }
        else {
            NAVLogTestPassed(i)
        }
    }
}

/**
 * Test hash distribution quality
 */
define_function TestNAVHashTableHashDistribution() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var integer usedSlots
    stack_var char key[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableHashDistribution *****************'")

    NAVHashTableInit(table)

    // Add items with systematically different keys
    for (i = 1; i <= 50; i++) {
        key = "'dist_test_', itoa(i), '_key'"
        NAVHashTableAddItem(table, key, "'value_', itoa(i)")
    }

    if (!NAVAssertIntegerEqual('Should have added all distribution test items', 50, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(50), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Count used slots to assess distribution
    usedSlots = 0
    for (i = 1; i <= NAV_HASH_TABLE_SIZE; i++) {
        if (table.Items[i].Key != 'NAV_NULL') {
            usedSlots++
        }
    }

    // With good distribution, used slots should be close to item count
    // (allowing for some collisions)
    if (usedSlots < 30) {  // Expect at least 30 different slots used out of 50 items
        NAVLogTestFailed(2, "'good distribution (30+)'", itoa(usedSlots))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Verify all items are still retrievable (distribution didn't break functionality)
    for (i = 1; i <= 50; i++) {
        key = "'dist_test_', itoa(i), '_key'"
        if (NAVHashTableGetItemValue(table, key) == '') {
            NAVLogTestFailed(3, "'non-empty value'", "'empty'")
            return
        }
    }
    NAVLogTestPassed(3)
}

/**
 * Test collision handling robustness
 */
define_function TestNAVHashTableCollisionRobustness() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var char key1[NAV_MAX_CHARS]
    stack_var char key2[NAV_MAX_CHARS]
    stack_var char value1[NAV_MAX_CHARS]
    stack_var char value2[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableCollisionRobustness *****************'")

    NAVHashTableInit(table)

    // Add pairs of keys that are likely to cause collisions
    for (i = 1; i <= 20; i++) {
        key1 = "'collision_a_', itoa(i)"
        key2 = "'collision_b_', itoa(i)"
        value1 = "'value_a_', itoa(i)"
        value2 = "'value_b_', itoa(i)"

        NAVHashTableAddItem(table, key1, value1)
        NAVHashTableAddItem(table, key2, value2)
    }

    if (!NAVAssertIntegerEqual('Should handle collision-prone keys', 40, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(40), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Verify all collision-prone items are retrievable
    for (i = 1; i <= 20; i++) {
        key1 = "'collision_a_', itoa(i)"
        key2 = "'collision_b_', itoa(i)"

        if (NAVHashTableGetItemValue(table, key1) == '') {
            NAVLogTestFailed(2, "'value found'", "'empty'")
            return
        }

        if (NAVHashTableGetItemValue(table, key2) == '') {
            NAVLogTestFailed(2, "'value found'", "'empty'")
            return
        }
    }
    NAVLogTestPassed(2)

    // Remove every other item and verify remaining items are intact
    for (i = 1; i <= 20; i = i + 2) {
        key1 = "'collision_a_', itoa(i)"
        NAVHashTableItemRemove(table, key1)
    }

    // Verify remaining items are still accessible
    for (i = 2; i <= 20; i = i + 2) {
        key1 = "'collision_a_', itoa(i)"
        if (NAVHashTableGetItemValue(table, key1) == '') {
            NAVLogTestFailed(3, "'remaining value'", "'empty'")
            return
        }
    }
    NAVLogTestPassed(3)
}

/**
 * Test concurrent operation simulation
 */
define_function TestNAVHashTableConcurrentOperations() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var char key[NAV_MAX_CHARS]
    stack_var char value[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableConcurrentOperations *****************'")

    NAVHashTableInit(table)

    // Simulate concurrent-like operations: interleaved add/remove/get/contains
    for (i = 1; i <= 30; i++) {
        key = "'concurrent_key_', itoa(i)"
        value = "'concurrent_value_', itoa(i)"

        // Add
        NAVHashTableAddItem(table, key, value)

        // Immediate get (should work)
        if (NAVHashTableGetItemValue(table, key) == '') {
            NAVLogTestFailed(1, "'immediate retrieval'", "'failed'")
            return
        }

        // Contains check
        if (!NAVHashTableContainsKey(table, key)) {
            NAVLogTestFailed(2, "'key should exist'", "'key not found'")
            return
        }

        // For every 3rd item, remove it immediately
        if ((i % 3) == 0) {
            NAVHashTableItemRemove(table, key)

            // Verify removal
            if (NAVHashTableContainsKey(table, key)) {
                NAVLogTestFailed(3, "'key should not exist'", "'key still found'")
                return
            }
        }
    }

    NAVLogTestPassed(1)  // Immediate retrievals worked
    NAVLogTestPassed(2)  // Contains checks worked
    NAVLogTestPassed(3)  // Removals worked

    // Final count should be 20 (30 added, 10 removed)
    if (!NAVAssertIntegerEqual('Should have correct final count', 20, table.ItemCount)) {
        NAVLogTestFailed(4, itoa(20), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(4)
    }
}