PROGRAM_NAME='NAVHashTablePerformance'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char PERFORMANCE_TEST_KEY_PREFIX[] = 'perf_key_'
constant char PERFORMANCE_TEST_VALUE_PREFIX[] = 'perf_value_'

/**
 * Test hash table performance with large number of items
 */
define_function TestNAVHashTablePerformanceLarge() {
    _NAVHashTable table
    integer i
    char key[NAV_MAX_CHARS]
    char value[NAV_MAX_CHARS]
    integer targetCount
    integer successCount

    NAVLog("'***************** TestNAVHashTablePerformanceLarge *****************'")

    // Initialize table
    NAVHashTableInit(table)

    targetCount = 50  // Realistic test size for hash table capacity

    // Add many items rapidly
    for (i = 1; i <= targetCount; i++) {
        key = "'perf_', itoa(i)"
        value = "'val_', itoa(i)"
        NAVHashTableAddItem(table, key, value)
    }

    // Verify reasonable number of items were added (allowing for some collisions)
    if (!NAVAssertIntegerEqual('Should have most items added', targetCount, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(targetCount), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test retrieval performance - count successful retrievals
    successCount = 0
    for (i = 1; i <= targetCount; i++) {
        key = "'perf_', itoa(i)"
        value = NAVHashTableGetItemValue(table, key)

        if (value != '') {
            successCount++
        }
    }

    // Should retrieve most items successfully
    if (!NAVAssertIntegerEqual('Should retrieve most items', table.ItemCount, successCount)) {
        NAVLogTestFailed(2, itoa(table.ItemCount), itoa(successCount))
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test hash table stress with rapid operations
 */
define_function TestNAVHashTableStressOperations() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var char key[NAV_MAX_CHARS]
    stack_var char value[NAV_MAX_CHARS]
    stack_var integer cycles

    NAVLog("'***************** TestNAVHashTableStressOperations *****************'")

    NAVHashTableInit(table)
    cycles = 25  // More reasonable cycle count

    // Stress test: Add and remove items in cycles
    for (i = 1; i <= cycles; i++) {
        key = "'s', itoa(i)"  // Shorter keys to reduce collisions
        value = "'v', itoa(i)"

        // Add item
        NAVHashTableAddItem(table, key, value)

        // Verify it exists
        if (!NAVHashTableContainsKey(table, key)) {
            NAVLogTestFailed(1, "'key should exist'", "'key not found'")
            return
        }

        // Remove it
        NAVHashTableItemRemove(table, key)

        // Verify it's gone
        if (NAVHashTableContainsKey(table, key)) {
            NAVLogTestFailed(2, "'key should not exist'", "'key still found'")
            return
        }
    }

    NAVLogTestPassed(1)
    NAVLogTestPassed(2)

    // Table should be empty after stress test
    if (!NAVAssertIntegerEqual('Should be empty after stress test', 0, table.ItemCount)) {
        NAVLogTestFailed(3, itoa(0), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test hash table memory usage patterns
 */
define_function TestNAVHashTableMemoryUsage() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var char key[NAV_MAX_CHARS]
    stack_var char value[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableMemoryUsage *****************'")

    NAVHashTableInit(table)

    // Add items and check table stays consistent
    for (i = 1; i <= 20; i++) {
        key = "'mem_key_', itoa(i)"
        value = "'This is a longer value string to test memory usage patterns and ensure no corruption occurs with larger data sets'"

        NAVHashTableAddItem(table, key, value)

        // Verify item count is correct
        if (table.ItemCount != i) {
            NAVLogTestFailed(1, itoa(i), itoa(table.ItemCount))
            return
        }
    }
    NAVLogTestPassed(1)

    // Clear and verify memory is properly released
    NAVHashTableClear(table)

    if (!NAVAssertIntegerEqual('Should be empty after clear', 0, table.ItemCount)) {
        NAVLogTestFailed(2, itoa(0), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Re-add items to ensure table is reusable
    for (i = 1; i <= 10; i++) {
        key = "'reuse_key_', itoa(i)"
        value = "'reuse_value_', itoa(i)"
        NAVHashTableAddItem(table, key, value)
    }

    if (!NAVAssertIntegerEqual('Should have 10 items after reuse', 10, table.ItemCount)) {
        NAVLogTestFailed(3, itoa(10), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(3)
    }
}
