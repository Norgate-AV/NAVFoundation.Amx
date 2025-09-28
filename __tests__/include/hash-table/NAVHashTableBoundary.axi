PROGRAM_NAME='NAVHashTableBoundary'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Removed overly long constants - using realistic values in functions instead

/**
 * Test hash table with reasonably long keys
 */
define_function TestNAVHashTableLongKeys() {
    stack_var _NAVHashTable table
    stack_var char retrievedValue[NAV_MAX_CHARS]
    stack_var char mediumKey[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableLongKeys *****************'")

    NAVHashTableInit(table)

    // Use a realistic "long" key within NetLinx string limits
    mediumKey = 'this_is_a_reasonably_long_key_name_for_testing'

    // Test adding item with medium-length key
    NAVHashTableAddItem(table, mediumKey, 'test_value')

    if (!NAVAssertIntegerEqual('Should add item with medium key', 1, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(1), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test retrieving with medium key
    retrievedValue = NAVHashTableGetItemValue(table, mediumKey)
    if (!NAVAssertStringEqual('Should retrieve value with medium key', 'test_value', retrievedValue)) {
        NAVLogTestFailed(2, 'test_value', retrievedValue)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test contains key with medium key
    if (!NAVAssertIntegerEqual('Should find medium key', 1, NAVHashTableContainsKey(table, mediumKey))) {
        NAVLogTestFailed(3, itoa(1), itoa(NAVHashTableContainsKey(table, mediumKey)))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test hash table with reasonably long values
 */
define_function TestNAVHashTableLongValues() {
    stack_var _NAVHashTable table
    stack_var char retrievedValue[NAV_MAX_CHARS]
    stack_var char mediumValue[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableLongValues *****************'")

    NAVHashTableInit(table)

    // Use a realistic medium-length value
    mediumValue = 'This is a reasonably long value for testing purposes within NetLinx limits'

    // Test adding item with medium-length value
    NAVHashTableAddItem(table, 'long_value_key', mediumValue)

    if (!NAVAssertIntegerEqual('Should add item with medium value', 1, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(1), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test retrieving medium-length value
    retrievedValue = NAVHashTableGetItemValue(table, 'long_value_key')
    if (!NAVAssertStringEqual('Should retrieve medium value correctly', mediumValue, retrievedValue)) {
        NAVLogTestFailed(2, mediumValue, retrievedValue)
    }
    else {
        NAVLogTestPassed(2)
    }
}

/**
 * Test hash table with special characters
 */
define_function TestNAVHashTableSpecialCharacters() {
    stack_var _NAVHashTable table
    stack_var char specialKey[NAV_MAX_CHARS]
    stack_var char specialValue[NAV_MAX_CHARS]
    stack_var char retrievedValue[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableSpecialCharacters *****************'")

    NAVHashTableInit(table)
    specialKey = 'key!@#$%^&*()_+-={}[]|:;<>?,./'
    specialValue = 'value with spaces & symbols: !@#$%^&*()'

    // Test adding item with special characters
    NAVHashTableAddItem(table, specialKey, specialValue)

    if (!NAVAssertIntegerEqual('Should add item with special chars', 1, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(1), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test retrieving with special characters
    retrievedValue = NAVHashTableGetItemValue(table, specialKey)
    if (!NAVAssertStringEqual('Should retrieve special char value', specialValue, retrievedValue)) {
        NAVLogTestFailed(2, specialValue, retrievedValue)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test removal with special characters
    NAVHashTableItemRemove(table, specialKey)
    if (!NAVAssertIntegerEqual('Should remove special char item', 0, table.ItemCount)) {
        NAVLogTestFailed(3, itoa(0), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test hash table capacity limits
 */
define_function TestNAVHashTableMaxCapacity() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var integer testItems
    stack_var char key[NAV_MAX_CHARS]
    stack_var char value[NAV_MAX_CHARS]
    stack_var integer addedCount

    NAVLog("'***************** TestNAVHashTableMaxCapacity *****************'")

    NAVHashTableInit(table)
    testItems = 200  // Test a reasonable number that may hit capacity

    // Attempt to fill table
    for (i = 1; i <= testItems; i++) {
        key = "'cap_', itoa(i)"
        value = "'val_', itoa(i)"
        NAVHashTableAddItem(table, key, value)
    }

    // Record how many were actually added
    addedCount = table.ItemCount

    // Verify we added a reasonable number (allowing for capacity limits)
    if (!NAVAssertIntegerEqual('Should add reasonable number of items', 1, (addedCount > 50))) {
        NAVLogTestFailed(1, '50+ items', itoa(addedCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Verify we can retrieve some items that were added
    key = "'cap_1'"
    value = NAVHashTableGetItemValue(table, key)
    if (!NAVAssertStringEqual('Should retrieve first item', 'val_1', value)) {
        NAVLogTestFailed(2, 'val_1', value)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test that hash table can handle the attempted load
    if (!NAVAssertIntegerEqual('Should handle reasonable load', 1, (addedCount >= (testItems * 80 / 100)))) {
        NAVLogTestFailed(3, '80% of attempted items', itoa(addedCount))
    }
    else {
        NAVLogTestPassed(3)
    }
}

/**
 * Test hash table with numeric-like keys
 */
define_function TestNAVHashTableNumericKeys() {
    stack_var _NAVHashTable table
    stack_var char retrievedValue[NAV_MAX_CHARS]

    NAVLog("'***************** TestNAVHashTableNumericKeys *****************'")

    NAVHashTableInit(table)

    // Test with numeric string keys
    NAVHashTableAddItem(table, '12345', 'numeric_value_1')
    NAVHashTableAddItem(table, '00001', 'numeric_value_2')
    NAVHashTableAddItem(table, '-999', 'negative_value')

    if (!NAVAssertIntegerEqual('Should add numeric-like keys', 3, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(3), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }

    // Test retrieval of numeric keys
    retrievedValue = NAVHashTableGetItemValue(table, '12345')
    if (!NAVAssertStringEqual('Should retrieve numeric key value', 'numeric_value_1', retrievedValue)) {
        NAVLogTestFailed(2, 'numeric_value_1', retrievedValue)
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test that different numeric formats are treated as different keys
    retrievedValue = NAVHashTableGetItemValue(table, '00001')
    if (!NAVAssertStringEqual('Should treat 00001 as different key', 'numeric_value_2', retrievedValue)) {
        NAVLogTestFailed(3, 'numeric_value_2', retrievedValue)
    }
    else {
        NAVLogTestPassed(3)
    }
}
