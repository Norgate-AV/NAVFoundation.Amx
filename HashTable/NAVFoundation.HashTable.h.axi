PROGRAM_NAME='NAVFoundation.HashTable.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_HASHTABLE_H__
#DEFINE __NAV_FOUNDATION_HASHTABLE_H__ 'NAVFoundation.HashTable.h'

#include 'NAVFoundation.Core.axi'


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


#END_IF // __NAV_FOUNDATION_HASHTABLE_H__
