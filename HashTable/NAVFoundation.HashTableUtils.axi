PROGRAM_NAME='NAVFoundation.HashTableUtils.axi'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Solutions Ltd

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

#IF_NOT_DEFINED __NAV_FOUNDATION_HASHTABLEUTILS__
#DEFINE __NAV_FOUNDATION_HASHTABLEUTILS__

#include 'NAVFoundation.Core.axi'

// #DEFINE NAV_HASHTABLE_DEBUG


DEFINE_CONSTANT

#IF_NOT_DEFINED NAV_HASH_TABLE_SIZE
constant integer NAV_HASH_TABLE_SIZE = 1000
#END_IF

#IF_NOT_DEFINED NAV_MAX_HASH_TABLE_ITEMS
constant long NAV_MAX_HASH_TABLE_ITEMS = NAV_HASH_TABLE_SIZE / 2
#END_IF


DEFINE_TYPE

struct _NAVHashTable {
    _NAVKeyValuePair Items[NAV_HASH_TABLE_SIZE];
    integer ItemCount;
}


#IF_DEFINED NAV_HASHTABLE_DEBUG
define_function NAVHashTableDebug(char caller[], char message[]) {
    NAVLog("caller, ' => ', message")
}
#END_IF


define_function integer NAVHashTableGetKeyHash(char key[]) {
    stack_var integer keyLength
    stack_var long value
    stack_var integer x

    value = 0
    keyLength = length_array(key)

    if (keyLength <= 0) {
        #IF_DEFINED NAV_HASHTABLE_DEBUG
        NAVHashTableDebug('NAVHashTableGetKeyHash()', 'Key length is 0, returning 0')
        #END_IF

        return type_cast(value)
    }

    #IF_DEFINED NAV_HASHTABLE_DEBUG
    NAVHashTableDebug('NAVHashTableGetKeyHash()', "'Getting key hash for key: ', key, ' with length: ', itoa(keyLength)")
    #END_IF

    for (x = 1; x <= keyLength; x++) {
        value = value * 37 + key[x]
    }

    value = value % NAV_HASH_TABLE_SIZE

    #IF_DEFINED NAV_HASHTABLE_DEBUG
    NAVHashTableDebug('NAVHashTableGetKeyHash()', "'Key hash value: ', format('%04d', type_cast(value))")
    #END_IF

    if (value == 0) {
        #IF_DEFINED NAV_HASHTABLE_DEBUG
        NAVHashTableDebug('NAVHashTableGetKeyHash()', 'Key hash value is 0, returning 1 instead')
        #END_IF

        value = 1
    }

    return type_cast(value)
}


define_function NAVHashTableInit(_NAVHashTable hashTable) {
    stack_var integer x

    for (x = 1; x <= max_length_array(hashTable.Items); x++) {
        hashTable.Items[x].Key = "NAV_NULL"
        hashTable.Items[x].Value = ''
    }

    hashTable.ItemCount = 0
}


define_function NAVHashTableItemInit(_NAVKeyValuePair item, char key[], char value[]) {
    item.Key = key
    item.Value = value
}


define_function NAVHashTableItemUpdate(_NAVKeyValuePair item, char value[]) {
    item.Value = value
}


define_function NAVHashTableSetItem(_NAVHashTable hashTable, integer slot, _NAVKeyValuePair item) {
    NAVHashTableItemInit(hashTable.Items[slot], item.Key, item.Value)
}


define_function NAVHashTableItemNew(_NAVHashTable hashTable, integer slot, _NAVKeyValuePair item) {
    hashTable.ItemCount++
    NAVHashTableItemInit(hashTable.Items[slot], item.Key, item.Value)
}


define_function NAVHashTableItemDispose(_NAVHashTable hashTable, integer slot) {
    hashTable.ItemCount--
    NAVHashTableItemInit(hashTable.Items[slot], "NAV_NULL", '')
}


define_function NAVHashTableGetItem(_NAVHashTable hashTable, integer slot, _NAVKeyValuePair item) {
    item.Key = hashTable.Items[slot].Key
    item.Value = hashTable.Items[slot].Value
}


define_function integer NAVHashTableAddItem(_NAVHashTable hashTable, char key[], char value[]) {
    stack_var integer slot
    stack_var _NAVKeyValuePair item

    if (!length_array(key)) {
        #IF_DEFINED NAV_HASHTABLE_DEBUG
        NAVHashTableDebug('NAVHashTableAddItem()', 'Error: Key is empty')
        #END_IF

        return 0
    }

    slot = NAVHashTableGetKeyHash(key)

    if (slot <= 0) {
        #IF_DEFINED NAV_HASHTABLE_DEBUG
        NAVHashTableDebug('NAVHashTableAddItem()', 'Error: Key hash is invalid')
        #END_IF

        return 0
    }

    #IF_DEFINED NAV_HASHTABLE_DEBUG
    NAVHashTableDebug('NAVHashTableAddItem()', "'Using slot: ', format('%04d', slot)")
    #END_IF

    NAVHashTableGetItem(hashTable, slot, item)

    if (item.Key == "NAV_NULL") {
        if (NAVHashTableGetItemCount(hashTable) >= NAV_MAX_HASH_TABLE_ITEMS) {
            #IF_DEFINED NAV_HASHTABLE_DEBUG
            NAVHashTableDebug('NAVHashTableAddItem()', 'Hashtable is full')
            #END_IF

            return 0
        }

        #IF_DEFINED NAV_HASHTABLE_DEBUG
        NAVHashTableDebug('NAVHashTableAddItem()', "'Slot ', format('%04d', slot), ' is empty, adding item'")
        #END_IF

        NAVHashTableItemInit(item, key, value)
        NAVHashTableItemNew(hashTable, slot, item)

        return slot
    }

    #IF_DEFINED NAV_HASHTABLE_DEBUG
    NAVHashTableDebug('NAVHashTableAddItem()', "'Slot ', format('%04d', slot), ' is in use'")
    NAVHashTableDebug('NAVHashTableAddItem()', "'Current item in slot: ', format('%04d', slot)")
    NAVHashTableDebug('NAVHashTableAddItem()', "'Item Key: ', item.Key, ' Item Value: ', item.Value")
    #END_IF

    if (item.Key == key) {
        NAVHashTableItemUpdate(hashTable.Items[slot], value)

        return slot
    }

    #IF_DEFINED NAV_HASHTABLE_DEBUG
    NAVHashTableDebug('NAVHashTableAddItem()', 'Error: Hashtable Collision Detected')
    #END_IF

    return 0
}


define_function char[NAV_MAX_BUFFER] NAVHashTableGetItemValue(_NAVHashTable hashTable, char key[]) {
    stack_var integer slot
    stack_var _NAVKeyValuePair item

    if (!length_array(key)) {
        #IF_DEFINED NAV_HASHTABLE_DEBUG
        NAVHashTableDebug('NAVHashTableGetItemValue()', 'Error: Key is empty')
        #END_IF

        return ""
    }

    slot = NAVHashTableGetKeyHash(key)

    NAVHashTableGetItem(hashTable, slot, item)

    if (item.Key == "NAV_NULL") {
        return ""
    }

    if (item.Key != key) {
        return ""
    }

    return item.Value
}


define_function integer NAVHashTableGetItemCount(_NAVHashTable hashTable) {
    return hashTable.ItemCount
}


define_function NAVHashTableItemRemove(_NAVHashTable hashTable, char key[]) {
    stack_var integer slot
    stack_var _NAVKeyValuePair item

    slot = NAVHashTableGetKeyHash(key)

    NAVHashTableGetItem(hashTable, slot, item)

    if (item.Key == "NAV_NULL") {
        return
    }

    if (item.Key != key) {
        return
    }

    NAVHashTableItemDispose(hashTable, slot)
}


define_function NAVHashTableDump(_NAVHashTable hashTable) {
    stack_var integer x

    for (x = 1; x <= max_length_array(hashTable.Items); x++) {
        stack_var _NAVKeyValuePair item

        NAVHashTableGetItem(hashTable, x, item)

        if (item.Key == "NAV_NULL") {
            continue
        }

        NAVLog("'Slot: ', format('%04d', x), ' Key: ', item.Key, ' Value: ', item.Value")
    }
}


#END_IF // __NAV_FOUNDATION_HASHTABLEUTILS__
