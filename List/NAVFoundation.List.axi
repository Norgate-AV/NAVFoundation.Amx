PROGRAM_NAME='NAVFoundation.List'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_LIST__
#DEFINE __NAV_FOUNDATION_LIST__ 'NAVFoundation.List'

// #include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.List.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


/**
 * @function NAVListInit
 * @public
 * @description Initializes a list with the specified capacity. The capacity parameter
 *              is copied internally to support constant values. Capacity is automatically
 *              clamped to the valid range (1 to NAV_MAX_LIST_SIZE).
 *
 * @param {_NAVList} list - List structure to initialize
 * @param {integer} initCapacity - Maximum capacity. If < 1, defaults to 1.
 *                                 If > NAV_MAX_LIST_SIZE, defaults to NAV_MAX_LIST_SIZE.
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVList myList
 * NAVListInit(myList, 50)  // Initialize with capacity of 50 items
 */
define_function NAVListInit(_NAVList list, integer initCapacity) {
    stack_var integer capacity

    // Make a copy in case a constant is passed
    capacity = initCapacity

    if (capacity < 1) {
        capacity = 1
    }

    if (capacity > NAV_MAX_LIST_SIZE) {
        capacity = NAV_MAX_LIST_SIZE
    }

    list.capacity = capacity
    list.count = 0
}


/**
 * @function NAVListClear
 * @public
 * @description Clears all elements from the list, resetting count to 0.
 *
 * @param {_NAVList} list - List to clear
 *
 * @returns {void}
 *
 * @example
 * NAVListClear(myList)
 */
define_function NAVListClear(_NAVList list) {
    list.count = 0
}


/**
 * @function NAVListAdd
 * @public
 * @description Appends an item to the end of the list.
 *
 * @param {_NAVList} list - List to add to
 * @param {char[]} item - Item to append
 *
 * @returns {char} TRUE if successful, FALSE if list is full
 *
 * @example
 * if (NAVListAdd(myList, 'Hello')) {
 *     // Item added successfully
 * }
 */
define_function char NAVListAdd(_NAVList list, char item[]) {
    if (list.count >= list.capacity) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListAdd',
                                    'List is full')
        return false
    }

    list.count++
    list.items[list.count] = item

    return true
}


/**
 * @function NAVListInsert
 * @public
 * @description Inserts an item at the specified index, shifting subsequent elements right.
 *
 * @param {_NAVList} list - List to insert into
 * @param {integer} index - Position to insert at (1-based)
 * @param {char[]} item - Item to insert
 *
 * @returns {char} TRUE if successful, FALSE if list is full or index is invalid
 *
 * @example
 * NAVListInsert(myList, 2, 'New Item')  // Inserts at position 2
 */
define_function char NAVListInsert(_NAVList list, integer index, char item[]) {
    stack_var integer i

    if (list.count >= list.capacity) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListInsert',
                                    'List is full')
        return false
    }

    if (index < 1 || index > list.count + 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListInsert',
                                    "'Index out of bounds: ', itoa(index)")
        return false
    }

    // Shift elements right from the end
    for (i = list.count; i >= index; i--) {
        list.items[i + 1] = list.items[i]
    }

    list.items[index] = item
    list.count++

    return true
}


/**
 * @function NAVListRemove
 * @public
 * @description Removes the item at the specified index, shifting subsequent elements left.
 *
 * @param {_NAVList} list - List to remove from
 * @param {integer} index - Position to remove from (1-based)
 *
 * @returns {char} TRUE if successful, FALSE if index is invalid
 *
 * @example
 * NAVListRemove(myList, 3)  // Removes item at position 3
 */
define_function char NAVListRemove(_NAVList list, integer index) {
    stack_var integer i

    if (index < 1 || index > list.count) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListRemove',
                                    "'Index out of bounds: ', itoa(index)")
        return false
    }

    // Shift elements left
    for (i = index; i < list.count; i++) {
        list.items[i] = list.items[i + 1]
    }

    list.count--

    return true
}


/**
 * @function NAVListRemoveItem
 * @public
 * @description Removes the first occurrence of the specified item from the list.
 *
 * @param {_NAVList} list - List to remove from
 * @param {char[]} item - Item to remove
 *
 * @returns {char} TRUE if item was found and removed, FALSE if not found
 *
 * @example
 * NAVListRemoveItem(myList, 'Hello')  // Removes first 'Hello'
 */
define_function char NAVListRemoveItem(_NAVList list, char item[]) {
    stack_var integer index

    index = NAVListIndexOf(list, item)

    if (index < 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListRemoveItem',
                                    "'Item not found: ', item")
        return false
    }

    return NAVListRemove(list, index)
}


/**
 * @function NAVListGet
 * @public
 * @description Retrieves the item at the specified index.
 *
 * @param {_NAVList} list - List to get from
 * @param {integer} index - Position to get from (1-based)
 * @param {char[]} result - Output parameter for the retrieved item
 *
 * @returns {char} TRUE if successful, FALSE if index is invalid
 *
 * @example
 * stack_var char item[NAV_MAX_LIST_ITEM_LENGTH]
 * if (NAVListGet(myList, 2, item)) {
 *     // item now contains the value at index 2
 * }
 */
define_function char NAVListGet(_NAVList list, integer index, char result[]) {
    if (index < 1 || index > list.count) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListGet',
                                    "'Index out of bounds: ', itoa(index)")
        return false
    }

    result = list.items[index]

    return true
}


/**
 * @function NAVListSet
 * @public
 * @description Replaces the item at the specified index with a new value.
 *
 * @param {_NAVList} list - List to modify
 * @param {integer} index - Position to replace (1-based)
 * @param {char[]} item - New item value
 *
 * @returns {char} TRUE if successful, FALSE if index is invalid
 *
 * @example
 * NAVListSet(myList, 1, 'Updated Value')
 */
define_function char NAVListSet(_NAVList list, integer index, char item[]) {
    if (index < 1 || index > list.count) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListSet',
                                    "'Index out of bounds: ', itoa(index)")
        return false
    }

    list.items[index] = item

    return true
}


/**
 * @function NAVListPop
 * @public
 * @description Removes and returns the last item from the list.
 *
 * @param {_NAVList} list - List to pop from
 * @param {char[]} result - Output parameter for the popped item
 *
 * @returns {char} TRUE if successful, FALSE if list is empty
 *
 * @example
 * stack_var char lastItem[NAV_MAX_LIST_ITEM_LENGTH]
 * if (NAVListPop(myList, lastItem)) {
 *     // lastItem contains the last element
 * }
 */
define_function char NAVListPop(_NAVList list, char result[]) {
    if (list.count < 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListPop',
                                    'List is empty')
        return false
    }

    result = list.items[list.count]
    list.count--

    return true
}


/**
 * @function NAVListFirst
 * @public
 * @description Retrieves the first item in the list.
 *
 * @param {_NAVList} list - List to get from
 * @param {char[]} result - Output parameter for the first item
 *
 * @returns {char} TRUE if successful, FALSE if list is empty
 *
 * @example
 * stack_var char firstItem[NAV_MAX_LIST_ITEM_LENGTH]
 * if (NAVListFirst(myList, firstItem)) {
 *     // firstItem contains the first element
 * }
 */
define_function char NAVListFirst(_NAVList list, char result[]) {
    if (list.count < 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListFirst',
                                    'List is empty')
        return false
    }

    result = list.items[1]

    return true
}


/**
 * @function NAVListLast
 * @public
 * @description Retrieves the last item in the list.
 *
 * @param {_NAVList} list - List to get from
 * @param {char[]} result - Output parameter for the last item
 *
 * @returns {char} TRUE if successful, FALSE if list is empty
 *
 * @example
 * stack_var char lastItem[NAV_MAX_LIST_ITEM_LENGTH]
 * if (NAVListLast(myList, lastItem)) {
 *     // lastItem contains the last element
 * }
 */
define_function char NAVListLast(_NAVList list, char result[]) {
    if (list.count < 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListLast',
                                    'List is empty')
        return false
    }

    result = list.items[list.count]

    return true
}


/**
 * @function NAVListSize
 * @public
 * @description Returns the current number of items in the list.
 *
 * @param {_NAVList} list - List to query
 *
 * @returns {integer} Current count of items
 *
 * @example
 * stack_var integer size
 * size = NAVListSize(myList)
 */
define_function integer NAVListSize(_NAVList list) {
    return list.count
}


/**
 * @function NAVListCapacity
 * @public
 * @description Returns the maximum capacity of the list.
 *
 * @param {_NAVList} list - List to query
 *
 * @returns {integer} Maximum capacity
 *
 * @example
 * stack_var integer maxSize
 * maxSize = NAVListCapacity(myList)
 */
define_function integer NAVListCapacity(_NAVList list) {
    return list.capacity
}


/**
 * @function NAVListIsEmpty
 * @public
 * @description Checks if the list is empty.
 *
 * @param {_NAVList} list - List to check
 *
 * @returns {char} TRUE if empty, FALSE otherwise
 *
 * @example
 * if (NAVListIsEmpty(myList)) {
 *     // List has no items
 * }
 */
define_function char NAVListIsEmpty(_NAVList list) {
    return list.count == 0
}


/**
 * @function NAVListIsFull
 * @public
 * @description Checks if the list is at maximum capacity.
 *
 * @param {_NAVList} list - List to check
 *
 * @returns {char} TRUE if full, FALSE otherwise
 *
 * @example
 * if (!NAVListIsFull(myList)) {
 *     NAVListAdd(myList, 'New Item')
 * }
 */
define_function char NAVListIsFull(_NAVList list) {
    return list.count >= list.capacity
}


/**
 * @function NAVListContains
 * @public
 * @description Checks if the list contains the specified item.
 *
 * @param {_NAVList} list - List to search
 * @param {char[]} item - Item to search for
 *
 * @returns {char} TRUE if item exists, FALSE otherwise
 *
 * @example
 * if (NAVListContains(myList, 'Hello')) {
 *     // Item exists in list
 * }
 */
define_function char NAVListContains(_NAVList list, char item[]) {
    return NAVListIndexOf(list, item) > 0
}


/**
 * @function NAVListIndexOf
 * @public
 * @description Finds the index of the first occurrence of the specified item.
 *
 * @param {_NAVList} list - List to search
 * @param {char[]} item - Item to search for
 *
 * @returns {integer} Index of item (1-based) or 0 if not found
 *
 * @example
 * stack_var integer index
 * index = NAVListIndexOf(myList, 'Hello')
 * if (index > 0) {
 *     // Item found at position 'index'
 * }
 */
define_function integer NAVListIndexOf(_NAVList list, char item[]) {
    stack_var integer i

    for (i = 1; i <= list.count; i++) {
        if (list.items[i] == item) {
            return i
        }
    }

    return 0
}


/**
 * @function NAVListToArray
 * @public
 * @description Copies all list items to a standard 2D array and sets the array length.
 *
 * @param {_NAVList} list - List to copy from
 * @param {char[][]} result - Output array (array length will be set automatically)
 *
 * @returns {char} TRUE if successful, FALSE if list is empty
 *
 * @example
 * stack_var char myArray[100][255]
 * if (NAVListToArray(myList, myArray)) {
 *     // myArray now contains all list items with length set to list size
 * }
 */
define_function char NAVListToArray(_NAVList list, char result[][]) {
    stack_var integer i

    if (list.count < 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListToArray',
                                    'List is empty')
        return false
    }

    for (i = 1; i <= list.count; i++) {
        result[i] = list.items[i]
    }

    // Ensure we explicitly set the length of the output array
    set_length_array(result, list.count)

    return true
}


/**
 * @function NAVListFromArray
 * @public
 * @description Initializes a list from a standard 2D array. Uses length_array to determine item count.
 *
 * @param {_NAVList} list - List to initialize
 * @param {char[][]} items - Source array of items (length determined automatically)
 *
 * @returns {char} TRUE if successful, FALSE if array length exceeds capacity
 *
 * @example
 * stack_var char myArray[3][50]
 * stack_var _NAVList myList
 * myArray[1] = 'First'
 * myArray[2] = 'Second'
 * myArray[3] = 'Third'
 * set_length_array(myArray, 3)
 * NAVListFromArray(myList, myArray)
 */
define_function char NAVListFromArray(_NAVList list, char items[][]) {
    stack_var integer i
    stack_var integer count

    count = length_array(items)

    if (count > list.capacity) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_LIST__,
                                    'NAVListFromArray',
                                    "'Count exceeds list capacity: ', itoa(count), ' > ', itoa(list.capacity)")
        return false
    }

    list.count = 0

    for (i = 1; i <= count; i++) {
        list.count++
        list.items[list.count] = items[i]
    }

    return true
}


#END_IF // __NAV_FOUNDATION_LIST__
