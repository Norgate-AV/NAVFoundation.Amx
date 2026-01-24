PROGRAM_NAME='NAVFoundation.List.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_LIST_H__
#DEFINE __NAV_FOUNDATION_LIST_H__ 'NAVFoundation.List.h'


DEFINE_CONSTANT

/**
 * Maximum capacity for a list.
 * Can be overridden before including this file.
 */
#IF_NOT_DEFINED NAV_MAX_LIST_SIZE
constant integer NAV_MAX_LIST_SIZE = 100
#END_IF

/**
 * Maximum length for each list item string.
 * Can be overridden before including this file.
 */
#IF_NOT_DEFINED NAV_MAX_LIST_ITEM_LENGTH
constant integer NAV_MAX_LIST_ITEM_LENGTH = 255
#END_IF


DEFINE_TYPE

/**
 * @struct _NAVList
 * @description A dynamic list structure for storing strings with a fixed capacity.
 *              Uses a shifting pattern for element management.
 *
 * @field {char[][]} items - Array of string items
 * @field {integer} count - Current number of items in the list
 * @field {integer} capacity - Maximum number of items the list can hold
 */
struct _NAVList {
    char items[NAV_MAX_LIST_SIZE][NAV_MAX_LIST_ITEM_LENGTH]
    integer count
    integer capacity
}


#END_IF // __NAV_FOUNDATION_LIST_H__
