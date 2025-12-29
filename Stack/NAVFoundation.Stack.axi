PROGRAM_NAME='NAVFoundation.Stack'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_STACK__
#DEFINE __NAV_FOUNDATION_STACK__ 'NAVFoundation.Stack'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.Stack.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


/**
 * @function NAVStackInitString
 * @public
 * @description Initializes a string stack with the specified capacity.
 *              Sets up the stack for use by resetting the top pointer and establishing
 *              the maximum capacity. If an invalid capacity is provided (<=0 or > NAV_MAX_STACK_SIZE),
 *              it defaults to NAV_MAX_STACK_SIZE.
 *
 * @param {_NAVStackString} stack - Stack instance to initialize (passed by reference)
 * @param {integer} capacity - Maximum number of items the stack can hold
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVStackString myStack
 * NAVStackInitString(myStack, 10)  // Initialize with capacity of 10
 */
define_function NAVStackInitString(_NAVStackString stack, integer capacity) {
    stack_var integer x

    if (capacity <= 0 || capacity > NAV_MAX_STACK_SIZE) {
        capacity = NAV_MAX_STACK_SIZE
    }

    stack.Properties.Top = NAV_STACK_EMPTY
    stack.Properties.Capacity = capacity
}


/**
 * @function NAVStackPushString
 * @public
 * @description Pushes a string item onto the top of the stack.
 *              Follows LIFO (Last-In-First-Out) behavior. Logs an error if the stack is full.
 *              Logs a warning if an empty string is pushed (but still adds it to the stack).
 *
 * @param {_NAVStackString} stack - Stack instance to push to (passed by reference)
 * @param {char[]} item - String item to push onto the stack
 *
 * @returns {char} true if successful, false if stack is full
 *
 * @example
 * stack_var _NAVStackString myStack
 * NAVStackInitString(myStack, 10)
 * if (NAVStackPushString(myStack, 'Hello World')) {
 *     // Successfully pushed
 * }
 */
define_function char NAVStackPushString(_NAVStackString stack, char item[]) {
    stack_var integer x

    if (NAVStackIsFull(stack.Properties)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STACK__,
                                    'NAVStackPushString',
                                    'Stack is full')

        return false
    }

    if (!length_array(item)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_STACK__,
                                    'NAVStackPushString',
                                    'Item is an empty string')
    }

    stack.Properties.Top++
    set_length_array(stack.Items, stack.Properties.Top)
    stack.Items[stack.Properties.Top] = item

    return true
}


/**
 * @function NAVStackPopString
 * @public
 * @description Removes and returns the top item from the string stack.
 *              Follows LIFO (Last-In-First-Out) behavior. The most recently pushed item
 *              is returned and removed from the stack. Logs an error if the stack is empty.
 *
 * @param {_NAVStackString} stack - Stack instance to pop from (passed by reference)
 *
 * @returns {char[]} The popped string item, or empty string if stack is empty
 *
 * @example
 * stack_var _NAVStackString myStack
 * stack_var char result[NAV_MAX_BUFFER]
 * NAVStackInitString(myStack, 10)
 * NAVStackPushString(myStack, 'First')
 * NAVStackPushString(myStack, 'Second')
 * result = NAVStackPopString(myStack)  // Returns 'Second'
 */
define_function char[NAV_MAX_BUFFER] NAVStackPopString(_NAVStackString stack) {
    stack_var integer x
    stack_var char item[NAV_MAX_BUFFER]

    if (NAVStackIsEmpty(stack.Properties)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STACK__,
                                    'NAVStackPopString',
                                    'Stack is empty')

        return ""
    }

    item = stack.Items[stack.Properties.Top]
    stack.Properties.Top--
    set_length_array(stack.Items, stack.Properties.Top)

    return item
}


/**
 * @function NAVStackPeekString
 * @public
 * @description Returns the top item from the string stack without removing it.
 *              Allows you to view the most recently pushed item while keeping it on the stack.
 *              Logs an error if the stack is empty.
 *
 * @param {_NAVStackString} stack - Stack instance to peek at (passed by reference)
 *
 * @returns {char[]} The top string item, or empty string if stack is empty
 *
 * @example
 * stack_var _NAVStackString myStack
 * stack_var char result[NAV_MAX_BUFFER]
 * NAVStackInitString(myStack, 10)
 * NAVStackPushString(myStack, 'Hello')
 * result = NAVStackPeekString(myStack)  // Returns 'Hello' without removing it
 * // Stack still contains 'Hello'
 */
define_function char[NAV_MAX_BUFFER] NAVStackPeekString(_NAVStackString stack) {
    stack_var integer x
    stack_var char item[NAV_MAX_BUFFER]

    if (NAVStackIsEmpty(stack.Properties)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STACK__,
                                    'NAVStackPeekString',
                                    'Stack is empty')

        return ""
    }

    item = stack.Items[stack.Properties.Top]

    return item
}


/**
 * @function NAVStackInitInteger
 * @public
 * @description Initializes an integer stack with the specified capacity.
 *              Sets up the stack for use by resetting the top pointer and establishing
 *              the maximum capacity. If an invalid capacity is provided (<=0 or > NAV_MAX_STACK_SIZE),
 *              it defaults to NAV_MAX_STACK_SIZE.
 *
 * @param {_NAVStackInteger} stack - Stack instance to initialize (passed by reference)
 * @param {integer} capacity - Maximum number of items the stack can hold
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVStackInteger myStack
 * NAVStackInitInteger(myStack, 10)  // Initialize with capacity of 10
 */
define_function NAVStackInitInteger(_NAVStackInteger stack, integer capacity) {
    stack_var integer x

    if (capacity <= 0 || capacity > NAV_MAX_STACK_SIZE) {
        capacity = NAV_MAX_STACK_SIZE
    }

    stack.Properties.Top = NAV_STACK_EMPTY
    stack.Properties.Capacity = capacity
}


/**
 * @function NAVStackPushInteger
 * @public
 * @description Pushes an integer item onto the top of the stack.
 *              Follows LIFO (Last-In-First-Out) behavior. Logs an error if the stack is full.
 *
 * @param {_NAVStackInteger} stack - Stack instance to push to (passed by reference)
 * @param {integer} item - Integer value to push onto the stack
 *
 * @returns {char} true if successful, false if stack is full
 *
 * @example
 * stack_var _NAVStackInteger myStack
 * NAVStackInitInteger(myStack, 10)
 * if (NAVStackPushInteger(myStack, 42)) {
 *     // Successfully pushed
 * }
 */
define_function char NAVStackPushInteger(_NAVStackInteger stack, integer item) {
    stack_var integer x

    if (NAVStackIsFull(stack.Properties)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STACK__,
                                    'NAVStackPushInteger',
                                    'Stack is full')

        return false
    }

    stack.Properties.Top++
    set_length_array(stack.Items, stack.Properties.Top)
    stack.Items[stack.Properties.Top] = item

    return true
}


/**
 * @function NAVStackPopInteger
 * @public
 * @description Removes and returns the top item from the integer stack.
 *              Follows LIFO (Last-In-First-Out) behavior. The most recently pushed item
 *              is returned and removed from the stack. Logs an error if the stack is empty.
 *
 * @param {_NAVStackInteger} stack - Stack instance to pop from (passed by reference)
 *
 * @returns {integer} The popped integer value, or 0 if stack is empty
 *
 * @example
 * stack_var _NAVStackInteger myStack
 * stack_var integer result
 * NAVStackInitInteger(myStack, 10)
 * NAVStackPushInteger(myStack, 10)
 * NAVStackPushInteger(myStack, 20)
 * result = NAVStackPopInteger(myStack)  // Returns 20
 */
define_function integer NAVStackPopInteger(_NAVStackInteger stack) {
    stack_var integer x
    stack_var integer item

    if (NAVStackIsEmpty(stack.Properties)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STACK__,
                                    'NAVStackPopInteger',
                                    'Stack is empty')

        return 0
    }

    item = stack.Items[stack.Properties.Top]
    stack.Properties.Top--
    set_length_array(stack.Items, stack.Properties.Top)

    return item
}


/**
 * @function NAVStackPeekInteger
 * @public
 * @description Returns the top item from the integer stack without removing it.
 *              Allows you to view the most recently pushed item while keeping it on the stack.
 *              Logs an error if the stack is empty.
 *
 * @param {_NAVStackInteger} stack - Stack instance to peek at (passed by reference)
 *
 * @returns {integer} The top integer value, or 0 if stack is empty
 *
 * @example
 * stack_var _NAVStackInteger myStack
 * stack_var integer result
 * NAVStackInitInteger(myStack, 10)
 * NAVStackPushInteger(myStack, 42)
 * result = NAVStackPeekInteger(myStack)  // Returns 42 without removing it
 * // Stack still contains 42
 */
define_function integer NAVStackPeekInteger(_NAVStackInteger stack) {
    stack_var integer x
    stack_var integer item

    if (NAVStackIsEmpty(stack.Properties)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STACK__,
                                    'NAVStackPeekInteger',
                                    'Stack is empty')

        return 0
    }

    item = stack.Items[stack.Properties.Top]

    return item
}


/**
 * @function NAVStackGetCount
 * @private
 * @description Internal helper function that returns the current number of items in a stack.
 *              This operates on the generic stack properties structure.
 *
 * @param {_NAVStackProperties} stack - Stack properties structure
 *
 * @returns {integer} Current number of items in the stack
 *
 * @see NAVStackStringGetCount
 * @see NAVStackIntegerGetCount
 */
define_function integer NAVStackGetCount(_NAVStackProperties stack) {
    return stack.Top
}


/**
 * @function NAVStackIsFull
 * @private
 * @description Internal helper function that checks if a stack has reached its capacity.
 *              This operates on the generic stack properties structure.
 *
 * @param {_NAVStackProperties} stack - Stack properties structure
 *
 * @returns {char} true if stack is full, false otherwise
 *
 * @see NAVStackStringIsFull
 * @see NAVStackIntegerIsFull
 */
define_function char NAVStackIsFull(_NAVStackProperties stack) {
    return stack.Top == stack.Capacity
}


/**
 * @function NAVStackGetCapacity
 * @private
 * @description Internal helper function that returns the maximum capacity of a stack.
 *              This operates on the generic stack properties structure.
 *
 * @param {_NAVStackProperties} stack - Stack properties structure
 *
 * @returns {integer} Maximum capacity of the stack
 *
 * @see NAVStackStringGetCapacity
 * @see NAVStackIntegerGetCapacity
 */
define_function integer NAVStackGetCapacity(_NAVStackProperties stack) {
    return stack.Capacity
}


/**
 * @function NAVStackIsEmpty
 * @private
 * @description Internal helper function that checks if a stack contains no items.
 *              This operates on the generic stack properties structure.
 *
 * @param {_NAVStackProperties} stack - Stack properties structure
 *
 * @returns {char} true if stack is empty, false otherwise
 *
 * @see NAVStackStringIsEmpty
 * @see NAVStackIntegerIsEmpty
 */
define_function char NAVStackIsEmpty(_NAVStackProperties stack) {
    return stack.Top == NAV_STACK_EMPTY
}


/**
 * @function NAVStackStringGetCount
 * @public
 * @description Returns the current number of items in a string stack.
 *
 * @param {_NAVStackString} stack - String stack instance
 *
 * @returns {integer} Current number of items in the stack (0 if empty)
 *
 * @example
 * stack_var _NAVStackString myStack
 * stack_var integer count
 * NAVStackInitString(myStack, 10)
 * NAVStackPushString(myStack, 'Item1')
 * NAVStackPushString(myStack, 'Item2')
 * count = NAVStackStringGetCount(myStack)  // Returns 2
 */
define_function integer NAVStackStringGetCount(_NAVStackString stack) {
    return NAVStackGetCount(stack.Properties)
}


/**
 * @function NAVStackStringIsFull
 * @public
 * @description Checks if a string stack has reached its maximum capacity.
 *
 * @param {_NAVStackString} stack - String stack instance
 *
 * @returns {char} true if stack is full, false if there is available space
 *
 * @example
 * stack_var _NAVStackString myStack
 * NAVStackInitString(myStack, 2)
 * NAVStackPushString(myStack, 'Item1')
 * NAVStackPushString(myStack, 'Item2')
 * if (NAVStackStringIsFull(myStack)) {
 *     // Stack is full, cannot push more items
 * }
 */
define_function char NAVStackStringIsFull(_NAVStackString stack) {
    return NAVStackIsFull(stack.Properties)
}


/**
 * @function NAVStackStringGetCapacity
 * @public
 * @description Returns the maximum capacity of a string stack.
 *              This value is set during initialization and does not change.
 *
 * @param {_NAVStackString} stack - String stack instance
 *
 * @returns {integer} Maximum number of items the stack can hold
 *
 * @example
 * stack_var _NAVStackString myStack
 * stack_var integer capacity
 * NAVStackInitString(myStack, 10)
 * capacity = NAVStackStringGetCapacity(myStack)  // Returns 10
 */
define_function integer NAVStackStringGetCapacity(_NAVStackString stack) {
    return NAVStackGetCapacity(stack.Properties)
}


/**
 * @function NAVStackStringIsEmpty
 * @public
 * @description Checks if a string stack contains no items.
 *
 * @param {_NAVStackString} stack - String stack instance
 *
 * @returns {char} true if stack is empty, false if it contains items
 *
 * @example
 * stack_var _NAVStackString myStack
 * NAVStackInitString(myStack, 10)
 * if (NAVStackStringIsEmpty(myStack)) {
 *     // Stack is empty
 * }
 * NAVStackPushString(myStack, 'Item1')
 * if (!NAVStackStringIsEmpty(myStack)) {
 *     // Stack now has items
 * }
 */
define_function char NAVStackStringIsEmpty(_NAVStackString stack) {
    return NAVStackIsEmpty(stack.Properties)
}


/**
 * @function NAVStackIntegerGetCount
 * @public
 * @description Returns the current number of items in an integer stack.
 *
 * @param {_NAVStackInteger} stack - Integer stack instance
 *
 * @returns {integer} Current number of items in the stack (0 if empty)
 *
 * @example
 * stack_var _NAVStackInteger myStack
 * stack_var integer count
 * NAVStackInitInteger(myStack, 10)
 * NAVStackPushInteger(myStack, 10)
 * NAVStackPushInteger(myStack, 20)
 * count = NAVStackIntegerGetCount(myStack)  // Returns 2
 */
define_function integer NAVStackIntegerGetCount(_NAVStackInteger stack) {
    return NAVStackGetCount(stack.Properties)
}


/**
 * @function NAVStackIntegerIsFull
 * @public
 * @description Checks if an integer stack has reached its maximum capacity.
 *
 * @param {_NAVStackInteger} stack - Integer stack instance
 *
 * @returns {char} true if stack is full, false if there is available space
 *
 * @example
 * stack_var _NAVStackInteger myStack
 * NAVStackInitInteger(myStack, 2)
 * NAVStackPushInteger(myStack, 10)
 * NAVStackPushInteger(myStack, 20)
 * if (NAVStackIntegerIsFull(myStack)) {
 *     // Stack is full, cannot push more items
 * }
 */
define_function char NAVStackIntegerIsFull(_NAVStackInteger stack) {
    return NAVStackIsFull(stack.Properties)
}


/**
 * @function NAVStackIntegerGetCapacity
 * @public
 * @description Returns the maximum capacity of an integer stack.
 *              This value is set during initialization and does not change.
 *
 * @param {_NAVStackInteger} stack - Integer stack instance
 *
 * @returns {integer} Maximum number of items the stack can hold
 *
 * @example
 * stack_var _NAVStackInteger myStack
 * stack_var integer capacity
 * NAVStackInitInteger(myStack, 10)
 * capacity = NAVStackIntegerGetCapacity(myStack)  // Returns 10
 */
define_function integer NAVStackIntegerGetCapacity(_NAVStackInteger stack) {
    return NAVStackGetCapacity(stack.Properties)
}


/**
 * @function NAVStackIntegerIsEmpty
 * @public
 * @description Checks if an integer stack contains no items.
 *
 * @param {_NAVStackInteger} stack - Integer stack instance
 *
 * @returns {char} true if stack is empty, false if it contains items
 *
 * @example
 * stack_var _NAVStackInteger myStack
 * NAVStackInitInteger(myStack, 10)
 * if (NAVStackIntegerIsEmpty(myStack)) {
 *     // Stack is empty
 * }
 * NAVStackPushInteger(myStack, 42)
 * if (!NAVStackIntegerIsEmpty(myStack)) {
 *     // Stack now has items
 * }
 */
define_function char NAVStackIntegerIsEmpty(_NAVStackInteger stack) {
    return NAVStackIsEmpty(stack.Properties)
}


#END_IF // __NAV_FOUNDATION_STACK__
