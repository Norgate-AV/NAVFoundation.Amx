PROGRAM_NAME='NAVHashTableRegression'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

/**
 * Test regression: Slot validation fix (slot > 0)
 */
define_function TestNAVHashTableRegressionSlotValidation() {
    stack_var _NAVHashTable table
    stack_var integer slot
    stack_var char retrievedValue[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableRegressionSlotValidation *****************'")

    NAVHashTableInit(table)

    // This tests the specific fix for slot validation
    slot = NAVHashTableAddItem(table, 'regression_test_key', 'regression_test_value')

    // Slot should be valid (> 0)
    if (!NAVAssertIntegerEqual('Slot should be valid (> 0)', 1, (slot > 0))) {
        NAVLogTestFailed(1, "'slot > 0'", itoa(slot))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Item should be retrievable
    retrievedValue = NAVHashTableGetItemValue(table, 'regression_test_key')
    if (!NAVAssertStringEqual('Should retrieve added value', 'regression_test_value', retrievedValue)) {
        NAVLogTestFailed(2, 'regression_test_value', retrievedValue)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Item count should be correct
    if (!NAVAssertIntegerEqual('Item count should be 1', 1, table.ItemCount)) {
        NAVLogTestFailed(3, itoa(1), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test regression: Empty string handling
 */
define_function TestNAVHashTableRegressionEmptyHandling() {
    stack_var _NAVHashTable table
    stack_var integer slot
    stack_var char retrievedValue[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableRegressionEmptyHandling *****************'")

    NAVHashTableInit(table)

    // Test empty key handling (should fail gracefully)
    slot = NAVHashTableAddItem(table, '', 'value_for_empty_key')
    if (!NAVAssertIntegerEqual('Empty key should return slot 0', 0, slot)) {
        NAVLogTestFailed(1, itoa(0), itoa(slot))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Table should remain empty
    if (!NAVAssertIntegerEqual('Table should remain empty with empty key', 0, table.ItemCount)) {
        NAVLogTestFailed(2, itoa(0), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test empty value handling (should work)
    slot = NAVHashTableAddItem(table, 'key_with_empty_value', '')
    if (!NAVAssertIntegerEqual('Should accept empty value', 1, (slot > 0))) {
        NAVLogTestFailed(3, "'slot > 0'", itoa(slot))
    }
    else {
        NAVLogTestPassed(3)
    }

    // Should retrieve empty value correctly
    retrievedValue = NAVHashTableGetItemValue(table, 'key_with_empty_value')
    if (!NAVAssertStringEqual('Should retrieve empty value', '', retrievedValue)) {
        NAVLogTestFailed(4, "''", retrievedValue)
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test error recovery after invalid operations
 */
define_function TestNAVHashTableErrorRecovery() {
    stack_var _NAVHashTable table
    stack_var integer slot

    NAVLog("'***************** TestNAVHashTableErrorRecovery *****************'")

    NAVHashTableInit(table)

    // Perform invalid operations
    NAVHashTableAddItem(table, '', 'invalid_key_test')  // Should fail
    NAVHashTableItemRemove(table, '')                   // Should fail
    NAVHashTableItemRemove(table, 'nonexistent_key')    // Should fail gracefully

    // Table should still be functional after errors
    slot = NAVHashTableAddItem(table, 'recovery_test', 'recovery_value')
    if (!NAVAssertIntegerEqual('Should recover and work normally', 1, (slot > 0))) {
        NAVLogTestFailed(1, "'functional after errors'", "'not functional'")
    }
    else {
        NAVLogTestPassed(1)
    }

    // Should have exactly 1 item (the valid one)
    if (!NAVAssertIntegerEqual('Should have 1 valid item after errors', 1, table.ItemCount)) {
        NAVLogTestFailed(2, itoa(1), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Should be able to perform normal operations
    if (!NAVAssertIntegerEqual('Should find valid item after errors', 1, NAVHashTableContainsKey(table, 'recovery_test'))) {
        NAVLogTestFailed(3, itoa(1), itoa(NAVHashTableContainsKey(table, 'recovery_test')))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test partial operations and state consistency
 */
define_function TestNAVHashTablePartialOperations() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var char key[NAV_MAX_CHARS]
    stack_var char value[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTablePartialOperations *****************'")

    NAVHashTableInit(table)

    // Add some items
    for (i = 1; i <= 10; i++) {
        key = "'partial_key_', itoa(i)"
        value = "'partial_value_', itoa(i)"
        NAVHashTableAddItem(table, key, value)
    }

    // Simulate interrupted operations by mixing valid and invalid operations
    NAVHashTableItemRemove(table, 'partial_key_1')      // Valid
    NAVHashTableItemRemove(table, 'nonexistent')        // Invalid
    NAVHashTableAddItem(table, 'partial_key_2', 'updated')  // Valid (update)
    NAVHashTableItemRemove(table, '')                   // Invalid
    NAVHashTableAddItem(table, 'new_key', 'new_value') // Valid

    // Count should be correct: 10 - 1 (removed) + 1 (new) = 10
    if (!NAVAssertIntegerEqual('Count should be correct after partial ops', 10, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(10), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Updated item should have new value
    value = NAVHashTableGetItemValue(table, 'partial_key_2')
    if (!NAVAssertStringEqual('Updated item should have new value', 'updated', value)) {
        NAVLogTestFailed(2, 'updated', value)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Removed item should not exist
    if (!NAVAssertIntegerEqual('Removed item should not exist', 0, NAVHashTableContainsKey(table, 'partial_key_1'))) {
        NAVLogTestFailed(3, itoa(0), itoa(NAVHashTableContainsKey(table, 'partial_key_1')))
    }
    else {
        NAVLogTestPassed(3)
    }

    // New item should exist
    value = NAVHashTableGetItemValue(table, 'new_key')
    if (!NAVAssertStringEqual('New item should exist', 'new_value', value)) {
        NAVLogTestFailed(4, 'new_value', value)
    }
    else {
        NAVLogTestPassed(4)
    }
}

/**
 * Test table state after multiple clears
 */
define_function TestNAVHashTableMultipleClearRegression() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var char key[NAV_MAX_CHARS]
    stack_var char value[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableMultipleClearRegression *****************'")

    NAVHashTableInit(table)

    // Multiple cycles of add/clear to test for memory issues
    for (i = 1; i <= 5; i++) {
        // Add items
        key = "'cycle_key_', itoa(i)"
        value = "'cycle_value_', itoa(i)"
        NAVHashTableAddItem(table, key, value)
        NAVHashTableAddItem(table, "'extra_', itoa(i)", "'extra_value_', itoa(i)")

        // Verify items added
        if (table.ItemCount != 2) {
            NAVLogTestFailed(1, itoa(2), itoa(table.ItemCount))
            return
        }

        // Clear table
        NAVHashTableClear(table)

        // Verify clear worked
        if (table.ItemCount != 0) {
            NAVLogTestFailed(2, itoa(0), itoa(table.ItemCount))
            return
        }
    }

    NAVLogTestPassed(1)  // All cycles maintained correct count
    NAVLogTestPassed(2)  // All clears worked properly

    // After multiple cycles, table should still be functional
    NAVHashTableAddItem(table, 'final_test', 'final_value')
    if (!NAVAssertIntegerEqual('Should be functional after multiple clears', 1, table.ItemCount)) {
        NAVLogTestFailed(3, itoa(1), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(3)
    }
}
