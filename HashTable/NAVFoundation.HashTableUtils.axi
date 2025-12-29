PROGRAM_NAME='NAVFoundation.HashTableUtils'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

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

#IF_NOT_DEFINED __NAV_FOUNDATION_HASHTABLE_UTILS__
#DEFINE __NAV_FOUNDATION_HASHTABLE_UTILS__ 'NAVFoundation.HashTableUtils'

#include 'NAVFoundation.HashTable.axi'


/**
 * @function NAVHashTableGetKeys
 * @public
 * @description Retrieve all keys from the hash table into an array.
 *              Useful for iterating over all keys or creating key lists.
 *
 * @param {_NAVHashTable} table - The hash table to enumerate
 * @param {char[][]} keys - Output array to store retrieved keys
 * @param {integer} size - Maximum number of keys to retrieve (array size)
 *
 * @returns {integer} The actual number of keys retrieved
 *
 * @example
 * stack_var char allKeys[100][NAV_HASH_TABLE_MAX_KEY_LENGTH]
 * stack_var integer keyCount
 * keyCount = NAVHashTableGetKeys(myTable, allKeys, 100)
 * // Now allKeys[1] to allKeys[keyCount] contain the keys
 */
define_function integer NAVHashTableGetKeys(_NAVHashTable table, char keys[][NAV_HASH_TABLE_MAX_KEY_LENGTH], integer size) {
    stack_var integer x
    stack_var integer count

    count = 0

    for (x = 1; x <= NAV_HASH_TABLE_SIZE; x++) {
        if (count >= size) {
            break
        }

        if (table.Items[x].Key != "NAV_NULL") {
            count++
            keys[count] = table.Items[x].Key
        }
    }

    return count
}


/**
 * @function NAVHashTableGetValues
 * @public
 * @description Retrieve all values from the hash table into an array.
 *              Values are returned in the same order as their corresponding keys.
 *
 * @param {_NAVHashTable} table - The hash table to enumerate
 * @param {char[][]} values - Output array to store retrieved values
 * @param {integer} size - Maximum number of values to retrieve (array size)
 *
 * @returns {integer} The actual number of values retrieved
 *
 * @example
 * stack_var char allValues[100][NAV_HASH_TABLE_MAX_VALUE_LENGTH]
 * stack_var integer valueCount
 * valueCount = NAVHashTableGetValues(myTable, allValues, 100)
 * // Now allValues[1] to allValues[valueCount] contain the values
 */
define_function integer NAVHashTableGetValues(_NAVHashTable table, char values[][NAV_HASH_TABLE_MAX_VALUE_LENGTH], integer size) {
    stack_var integer x
    stack_var integer count

    count = 0

    for (x = 1; x <= NAV_HASH_TABLE_SIZE; x++) {
        if (count >= size) {
            break
        }

        if (table.Items[x].Key != "NAV_NULL") {
            count++
            values[count] = table.Items[x].Value
        }
    }

    return count
}


/**
 * @function NAVHashTableGetErrorString
 * @public
 * @description Convert a hash table error code to a human-readable string.
 *              Useful for logging and debugging error conditions.
 *
 * @param {integer} error - The error code to convert
 *
 * @returns {char[]} Human-readable error description string
 *
 * @example
 * stack_var integer errorCode
 * stack_var char errorMsg[NAV_HASH_TABLE_MAX_VALUE_LENGTH]
 * errorCode = NAVHashTableGetLastError(myTable)
 * errorMsg = NAVHashTableGetErrorString(errorCode)
 * send_string 0, "'Hash table error: ', errorMsg"
 */
define_function char[NAV_HASH_TABLE_MAX_VALUE_LENGTH] NAVHashTableGetErrorString(integer error) {
    switch (error) {
        case NAV_HASH_TABLE_ERROR_NONE:             { return 'No error' }
        case NAV_HASH_TABLE_ERROR_EMPTY_KEY:        { return 'Empty key' }
        case NAV_HASH_TABLE_ERROR_INVALID_HASH:     { return 'Invalid hash' }
        case NAV_HASH_TABLE_ERROR_FULL:             { return 'Hash table full' }
        case NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND:    { return 'Key not found' }
        case NAV_HASH_TABLE_ERROR_COLLISION:        { return 'Hash collision' }
        default:                                    { return 'Unknown error' }
    }
}


#END_IF // __NAV_FOUNDATION_HASHTABLE_UTILS__
