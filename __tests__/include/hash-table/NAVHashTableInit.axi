PROGRAM_NAME='NAVHashTableInit'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Test basic hash table initialization functionality
 */
define_function TestNAVHashTableInit() {
    stack_var _NAVHashTable table

    NAVLog("'***************** NAVHashTableInit *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Check item count is 0
    if (!NAVAssertIntegerEqual('ItemCount should be 0', 0, table.ItemCount)) {
        NAVLogTestFailed(1, itoa(0), itoa(table.ItemCount))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test hash table initialization sets correct initial values
 */
define_function TestNAVHashTableInitialization() {
    stack_var _NAVHashTable table

    NAVLog("'***************** NAVHashTableInitialization *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Check error code is NONE
    if (!NAVAssertIntegerEqual('LastError should be NONE', NAV_HASH_TABLE_ERROR_NONE, table.LastError)) {
        NAVLogTestFailed(1, itoa(NAV_HASH_TABLE_ERROR_NONE), itoa(table.LastError))
    }
    else {
        NAVLogTestPassed(1)
    }
}

/**
 * Test hash table initial state has empty slots
 */
define_function TestNAVHashTableInitialState() {
    stack_var _NAVHashTable table
    stack_var integer i
    stack_var integer emptyCount

    NAVLog("'***************** NAVHashTableInitialState *****************'")

    // Initialize the hash table
    NAVHashTableInit(table)

    // Check that all slots contain NULL key
    emptyCount = 0
    for (i = 1; i <= NAV_HASH_TABLE_SIZE; i++) {
        if (table.Items[i].Key == "NAV_NULL") {
            emptyCount++
        }
    }

    if (!NAVAssertIntegerEqual('All slots should be empty', NAV_HASH_TABLE_SIZE, emptyCount)) {
        NAVLogTestFailed(1, itoa(NAV_HASH_TABLE_SIZE), itoa(emptyCount))
    }
    else {
        NAVLogTestPassed(1)
    }
}
