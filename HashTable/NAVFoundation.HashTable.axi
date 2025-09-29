PROGRAM_NAME='NAVFoundation.HashTable'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Services Limited

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#IF_NOT_DEFINED __NAV_FOUNDATION_HASHTABLE__
#DEFINE __NAV_FOUNDATION_HASHTABLE__ 'NAVFoundation.HashTable'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.HashTable.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


/**
 * @function NAVHashTableGetKeyHash
 * @public
 * @description Calculate polynomial rolling hash value for a given key using base 37.
 *              This function implements a high-quality hash function that provides
 *              good distribution across the hash table to minimize collisions.
 *
 * @param {char[]} key - The key string to hash
 *
 * @returns {integer} Hash value (0 to NAV_HASH_TABLE_SIZE-1), or 0 if key is empty
 *
 * @example
 * stack_var integer hashValue
 * hashValue = NAVHashTableGetKeyHash('user_session_123')
 */
define_function integer NAVHashTableGetKeyHash(char key[]) {
    stack_var integer length
    stack_var long value
    stack_var integer x

    value = 0
    length = length_array(key)

    if (length <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HASHTABLE__,
                                    'NAVHashTableGetKeyHash',
                                    'The argument "key" is an empty string')

        return type_cast(value)
    }

    for (x = 1; x <= length; x++) {
        value = value * 37 + key[x]
    }

    value = value % NAV_HASH_TABLE_SIZE

    return type_cast(value)
}


/**
 * @function NAVHashTableInit
 * @public
 * @description Initialize an empty hash table by clearing all slots and resetting counters.
 *              This function must be called before using any other hash table operations.
 *
 * @param {_NAVHashTable} table - The hash table structure to initialize
 *
 * @example
 * stack_var _NAVHashTable myTable
 * NAVHashTableInit(myTable)
 */
define_function NAVHashTableInit(_NAVHashTable table) {
    stack_var integer x

    for (x = 1; x <= max_length_array(table.Items); x++) {
        table.Items[x].Key = "NAV_NULL"
        table.Items[x].Value = ''
    }

    table.ItemCount = 0
    table.LastError = NAV_HASH_TABLE_ERROR_NONE
}


/**
 * @function NAVHashTableItemInit
 * @private
 * @description Initialize a hash table key-value pair item with the specified key and value.
 *
 * @param {_NAVHashTableKeyValuePair} item - The item structure to initialize
 * @param {char[]} key - The key string to assign
 * @param {char[]} value - The value string to assign
 */
define_function NAVHashTableItemInit(_NAVHashTableKeyValuePair item, char key[], char value[]) {
    item.Key = key
    item.Value = value
}


/**
 * @function NAVHashTableItemUpdate
 * @private
 * @description Update the value of an existing hash table key-value pair item.
 *
 * @param {_NAVHashTableKeyValuePair} item - The item structure to update
 * @param {char[]} value - The new value string to assign
 */
define_function NAVHashTableItemUpdate(_NAVHashTableKeyValuePair item, char value[]) {
    item.Value = value
}


/**
 * @function NAVHashTableSetItem
 * @private
 * @description Set an item at a specific slot in the hash table (overwrites existing).
 *
 * @param {_NAVHashTable} table - The hash table to modify
 * @param {integer} slot - The slot index (1-based)
 * @param {_NAVHashTableKeyValuePair} item - The item to set at the slot
 */
define_function NAVHashTableSetItem(_NAVHashTable table, integer slot, _NAVHashTableKeyValuePair item) {
    NAVHashTableItemInit(table.Items[slot], item.Key, item.Value)
}


/**
 * @function NAVHashTableItemNew
 * @private
 * @description Create a new item at a specific slot and increment the item count.
 *
 * @param {_NAVHashTable} table - The hash table to modify
 * @param {integer} slot - The slot index (1-based)
 * @param {_NAVHashTableKeyValuePair} item - The item to create at the slot
 */
define_function NAVHashTableItemNew(_NAVHashTable table, integer slot, _NAVHashTableKeyValuePair item) {
    table.ItemCount++
    NAVHashTableItemInit(table.Items[slot], item.Key, item.Value)
}


/**
 * @function NAVHashTableItemDispose
 * @private
 * @description Remove an item from a specific slot and decrement the item count.
 *
 * @param {_NAVHashTable} table - The hash table to modify
 * @param {integer} slot - The slot index (1-based) to clear
 */
define_function NAVHashTableItemDispose(_NAVHashTable table, integer slot) {
    table.ItemCount--
    NAVHashTableItemInit(table.Items[slot], "NAV_NULL", '')
}


/**
 * @function NAVHashTableGetItem
 * @private
 * @description Retrieve an item from a specific slot in the hash table.
 *
 * @param {_NAVHashTable} table - The hash table to read from
 * @param {integer} slot - The slot index (1-based)
 * @param {_NAVHashTableKeyValuePair} item - Output structure to store the retrieved item
 */
define_function NAVHashTableGetItem(_NAVHashTable table, integer slot, _NAVHashTableKeyValuePair item) {
    item.Key = table.Items[slot].Key
    item.Value = table.Items[slot].Value
}


/**
 * @function NAVHashTableAddItem
 * @public
 * @description Add a new key-value pair to the hash table or update existing key.
 *              Uses linear probing for collision resolution. If the table is full,
 *              the operation will fail and set an error code.
 *
 * @param {_NAVHashTable} table - The hash table to modify
 * @param {char[]} key - The key string (must not be empty, max 128 chars)
 * @param {char[]} value - The value string (max 256 chars)
 *
 * @returns {integer} 1 on success, 0 on failure (check LastError for details)
 *
 * @example
 * stack_var _NAVHashTable myTable
 * NAVHashTableInit(myTable)
 * if (NAVHashTableAddItem(myTable, 'username', 'admin')) {
 *     // Successfully added
 * }
 */
define_function integer NAVHashTableAddItem(_NAVHashTable table, char key[], char value[]) {
    stack_var integer slot
    stack_var _NAVHashTableKeyValuePair item
    stack_var integer originalSlot
    stack_var integer probeSlot

    table.LastError = NAV_HASH_TABLE_ERROR_NONE

    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HASHTABLE__,
                                    'NAVHashTableAddItem',
                                    'The argument "key" is an empty string')

        table.LastError = NAV_HASH_TABLE_ERROR_EMPTY_KEY
        return 0
    }

    slot = NAVHashTableGetKeyHash(key)

    if (slot <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HASHTABLE__,
                                    'NAVHashTableAddItem',
                                    "'Hash value for key "', key, '" is invalid'")

        table.LastError = NAV_HASH_TABLE_ERROR_INVALID_HASH
        return 0
    }

    NAVHashTableGetItem(table, slot, item)

    // If the slot is empty, add the item
    if (item.Key == "NAV_NULL") {
        if (NAVHashTableGetItemCount(table) >= NAV_MAX_HASH_TABLE_ITEMS) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_HASHTABLE__,
                                        'NAVHashTableAddItem',
                                        'The hashtable is full')

            table.LastError = NAV_HASH_TABLE_ERROR_FULL
            return 0
        }

        NAVHashTableItemInit(item, key, value)
        NAVHashTableItemNew(table, slot, item)

        return slot
    }

    // If the key already exists, update the value
    if (item.Key == key) {
        NAVHashTableItemUpdate(table.Items[slot], value)
        return slot
    }

    // Collision occurred - use linear probing
    originalSlot = slot
    probeSlot = slot

    while (true) {
        probeSlot = (probeSlot % NAV_HASH_TABLE_SIZE) + 1

        // No space left
        if (probeSlot == originalSlot) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                      __NAV_FOUNDATION_HASHTABLE__,
                                      'NAVHashTableAddItem',
                                      'Hash table is full (probing completed full cycle)')

            table.LastError = NAV_HASH_TABLE_ERROR_FULL
            return 0
        }

        NAVHashTableGetItem(table, probeSlot, item)

        // Found an empty slot
        if (item.Key == "NAV_NULL") {
            if (NAVHashTableGetItemCount(table) >= NAV_MAX_HASH_TABLE_ITEMS) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                          __NAV_FOUNDATION_HASHTABLE__,
                                          'NAVHashTableAddItem',
                                          'The hashtable is full')

                table.LastError = NAV_HASH_TABLE_ERROR_FULL
                return 0
            }

            NAVHashTableItemInit(item, key, value)
            NAVHashTableItemNew(table, probeSlot, item)
            return probeSlot
        }

        // Found the same key in another slot
        if (item.Key == key) {
            NAVHashTableItemUpdate(table.Items[probeSlot], value)
            return probeSlot
        }

        break
    }
}


/**
 * @function NAVHashTableGetItemValue
 * @public
 * @description Retrieve the value associated with a key from the hash table.
 *              Uses linear probing to handle collisions when searching for the key.
 *
 * @param {_NAVHashTable} table - The hash table to search
 * @param {char[]} key - The key string to look up (must not be empty)
 *
 * @returns {char[]} The value string if key exists, empty string if not found
 *
 * @example
 * stack_var char username[NAV_HASH_TABLE_MAX_VALUE_LENGTH]
 * username = NAVHashTableGetItemValue(myTable, 'current_user')
 * if (length_array(username)) {
 *     // Key found, use the value
 * }
 */
define_function char[NAV_HASH_TABLE_MAX_VALUE_LENGTH] NAVHashTableGetItemValue(_NAVHashTable table, char key[]) {
    stack_var integer slot
    stack_var _NAVHashTableKeyValuePair item
    stack_var integer originalSlot
    stack_var integer probeSlot

    table.LastError = NAV_HASH_TABLE_ERROR_NONE

    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HASHTABLE__,
                                    'NAVHashTableGetItemValue',
                                    'The argument "key" is an empty string')

        table.LastError = NAV_HASH_TABLE_ERROR_EMPTY_KEY
        return ""
    }

    slot = NAVHashTableGetKeyHash(key)

    if (slot <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HASHTABLE__,
                                    'NAVHashTableGetItemValue',
                                    "'Hash value for key "', key, '" is invalid'")

        table.LastError = NAV_HASH_TABLE_ERROR_INVALID_HASH
        return ""
    }

    // Check initial slot
    NAVHashTableGetItem(table, slot, item)
    if (item.Key == key) {
        return item.Value
    }

    // Key not found in initial slot, try linear probing
    if (item.Key != "NAV_NULL") {
        originalSlot = slot
        probeSlot = slot

        while (true) {
            probeSlot = (probeSlot % NAV_HASH_TABLE_SIZE) + 1

            // Completed full cycle without finding the key
            if (probeSlot == originalSlot) {
                table.LastError = NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND
                return ""
            }

            NAVHashTableGetItem(table, probeSlot, item)

            // Found the key
            if (item.Key == key) {
                return item.Value
            }

            if (item.Key == "NAV_NULL") {
                break
            }
        }
    }

    table.LastError = NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND
    return ""
}


/**
 * @function NAVHashTableItemRemove
 * @public
 * @description Remove a key-value pair from the hash table.
 *              Uses linear probing to locate the key, then removes it and decrements count.
 *
 * @param {_NAVHashTable} table - The hash table to modify
 * @param {char[]} key - The key string to remove (must not be empty)
 *
 * @example
 * NAVHashTableItemRemove(myTable, 'temporary_session')
 * // Key is now removed from the table
 */
define_function NAVHashTableItemRemove(_NAVHashTable table, char key[]) {
    stack_var integer slot
    stack_var _NAVHashTableKeyValuePair item
    stack_var integer originalSlot
    stack_var integer probeSlot

    table.LastError = NAV_HASH_TABLE_ERROR_NONE

    if (!length_array(key)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HASHTABLE__,
                                    'NAVHashTableItemRemove',
                                    'The argument "key" is an empty string')

        table.LastError = NAV_HASH_TABLE_ERROR_EMPTY_KEY
        return
    }

    slot = NAVHashTableGetKeyHash(key)

    if (slot <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_HASHTABLE__,
                                    'NAVHashTableItemRemove',
                                    "'Hash value for key "', key, '" is invalid'")

        table.LastError = NAV_HASH_TABLE_ERROR_INVALID_HASH
        return
    }

    // Check initial slot
    NAVHashTableGetItem(table, slot, item)

    if (item.Key == key) {
        NAVHashTableItemDispose(table, slot)
        return
    }

    // Key not found in initial slot, try linear probing
    if (item.Key != "NAV_NULL") {
        originalSlot = slot
        probeSlot = slot

        while (true) {
            probeSlot = (probeSlot % NAV_HASH_TABLE_SIZE) + 1

            if (probeSlot == originalSlot) {
                table.LastError = NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND
                return
            }

            NAVHashTableGetItem(table, probeSlot, item)

            // Found the key, remove it
            if (item.Key == key) {
                NAVHashTableItemDispose(table, probeSlot)
                return
            }

            if (item.Key == "NAV_NULL") {
                break
            }
        }
    }

    table.LastError = NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND
}


/**
 * @function NAVHashTableContainsKey
 * @public
 * @description Check if a key exists in the hash table without retrieving the value.
 *              More efficient than checking if GetItemValue returns an empty string.
 *
 * @param {_NAVHashTable} table - The hash table to search
 * @param {char[]} key - The key string to check for
 *
 * @returns {integer} 1 if key exists, 0 if not found
 *
 * @example
 * if (NAVHashTableContainsKey(myTable, 'user_preferences')) {
 *     // Key exists, safe to retrieve or update
 * }
 */
define_function integer NAVHashTableContainsKey(_NAVHashTable table, char key[]) {
    stack_var char value[NAV_HASH_TABLE_MAX_VALUE_LENGTH]

    value = NAVHashTableGetItemValue(table, key)

    // If there was no error finding the key, it exists
    return (table.LastError == NAV_HASH_TABLE_ERROR_NONE)
}


/**
 * @function NAVHashTableClear
 * @public
 * @description Remove all items from the hash table and reset it to empty state.
 *              Equivalent to calling NAVHashTableInit but more semantically clear.
 *
 * @param {_NAVHashTable} table - The hash table to clear
 *
 * @example
 * NAVHashTableClear(myTable)
 * // Table is now empty with ItemCount = 0
 */
define_function NAVHashTableClear(_NAVHashTable table) {
    NAVHashTableInit(table)
}


/**
 * @function NAVHashTableGetLoadFactor
 * @public
 * @description Calculate the current load factor of the hash table (percentage full).
 *              Load factor = ItemCount / TableSize. Values above 0.7 may impact performance.
 *
 * @param {_NAVHashTable} table - The hash table to analyze
 *
 * @returns {float} Load factor as decimal (0.0 to 1.0)
 *
 * @example
 * stack_var float loadFactor
 * loadFactor = NAVHashTableGetLoadFactor(myTable)
 * if (loadFactor > 0.7) {
 *     // Consider increasing table size
 * }
 */
define_function float NAVHashTableGetLoadFactor(_NAVHashTable table) {
    return type_cast(NAVHashTableGetItemCount(table)) / type_cast(NAV_HASH_TABLE_SIZE)
}


/**
 * @function NAVHashTableGetLastError
 * @public
 * @description Get the last error code from a hash table operation.
 *              Useful for diagnosing why an operation failed.
 *
 * @param {_NAVHashTable} table - The hash table to check
 *
 * @returns {integer} Error code constant (see NAV_HASH_TABLE_ERROR_* constants)
 *
 * @example
 * if (!NAVHashTableAddItem(myTable, 'key', 'value')) {
 *     stack_var integer errorCode
 *     errorCode = NAVHashTableGetLastError(myTable)
 *     // Handle specific error types
 * }
 */
define_function integer NAVHashTableGetLastError(_NAVHashTable table) {
    return table.LastError
}


/**
 * @function NAVHashTableGetItemCount
 * @public
 * @description Get the current number of key-value pairs stored in the hash table.
 *
 * @param {_NAVHashTable} table - The hash table to query
 *
 * @returns {integer} Number of items currently in the table
 *
 * @example
 * stack_var integer count
 * count = NAVHashTableGetItemCount(myTable)
 * send_string 0, "'Table contains ', itoa(count), ' items'"
 */
define_function integer NAVHashTableGetItemCount(_NAVHashTable table) {
    return table.ItemCount
}


/**
 * @function NAVHashTableDump
 * @public
 * @description Print all key-value pairs in the hash table to the console for debugging.
 *              Shows slot numbers, keys, and values for all occupied slots.
 *
 * @param {_NAVHashTable} table - The hash table to dump
 *
 * @example
 * NAVHashTableDump(myTable)
 * // Outputs: "Slot: 0042 Key: username Value: admin"
 * //         "Slot: 0157 Key: timeout Value: 30"
 */
define_function NAVHashTableDump(_NAVHashTable table) {
    stack_var integer x

    for (x = 1; x <= max_length_array(table.Items); x++) {
        stack_var _NAVHashTableKeyValuePair item

        NAVHashTableGetItem(table, x, item)

        if (item.Key == "NAV_NULL") {
            continue
        }

        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_INFO,
                                    __NAV_FOUNDATION_HASHTABLE__,
                                    'NAVHashTableDump',
                                    "'Slot: ', format('%04d', x), ' Key: ', item.Key, ' Value: ', item.Value")
    }
}


#END_IF // __NAV_FOUNDATION_HASHTABLEUTILS__
