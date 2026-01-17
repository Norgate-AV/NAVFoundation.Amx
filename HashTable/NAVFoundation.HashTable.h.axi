PROGRAM_NAME='NAVFoundation.HashTable.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_HASHTABLE_H__
#DEFINE __NAV_FOUNDATION_HASHTABLE_H__ 'NAVFoundation.HashTable.h'


DEFINE_CONSTANT

// Hash table size configuration
// Memory footprint: ~1.83MB for 5000 items, recommended load factor <70%
#IF_NOT_DEFINED NAV_HASH_TABLE_SIZE
constant integer NAV_HASH_TABLE_SIZE = 5000
#END_IF

#IF_NOT_DEFINED NAV_MAX_HASH_TABLE_ITEMS
constant long NAV_MAX_HASH_TABLE_ITEMS = NAV_HASH_TABLE_SIZE / 2
#END_IF

#IF_NOT_DEFINED NAV_HASH_TABLE_MAX_KEY_LENGTH
constant integer NAV_HASH_TABLE_MAX_KEY_LENGTH = 128
#END_IF

#IF_NOT_DEFINED NAV_HASH_TABLE_MAX_VALUE_LENGTH
constant integer NAV_HASH_TABLE_MAX_VALUE_LENGTH = 256
#END_IF

constant integer NAV_HASH_TABLE_ERROR_NONE          = 0
constant integer NAV_HASH_TABLE_ERROR_EMPTY_KEY     = 1
constant integer NAV_HASH_TABLE_ERROR_INVALID_HASH  = 2
constant integer NAV_HASH_TABLE_ERROR_FULL          = 3
constant integer NAV_HASH_TABLE_ERROR_KEY_NOT_FOUND = 4
constant integer NAV_HASH_TABLE_ERROR_COLLISION     = 5


DEFINE_TYPE

/**
 * @struct _NAVHashTableKeyValuePair
 * @description Hash table specific key-value pair with optimized string lengths
 * @property {char[]} Key - Hash table key (up to 128 characters)
 * @property {char[]} Value - Hash table value (up to 256 characters)
 */
struct _NAVHashTableKeyValuePair {
    char Key[NAV_HASH_TABLE_MAX_KEY_LENGTH];
    char Value[NAV_HASH_TABLE_MAX_VALUE_LENGTH];
}

/**
 * @struct _NAVHashTable
 * @description Main hash table structure containing the item array and metadata.
 *              Uses linear probing for collision resolution with polynomial rolling hash.
 * @property {_NAVHashTableKeyValuePair[]} Items - Array of key-value pairs (size NAV_HASH_TABLE_SIZE)
 * @property {integer} ItemCount - Current number of items stored in the table
 * @property {integer} LastError - Last error code from hash table operations
 */
struct _NAVHashTable {
    _NAVHashTableKeyValuePair Items[NAV_HASH_TABLE_SIZE];
    integer ItemCount;
    integer LastError;
}


#END_IF // __NAV_FOUNDATION_HASHTABLE_H__
