PROGRAM_NAME='NAVFoundation.Stack.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_STACK_H__
#DEFINE __NAV_FOUNDATION_STACK_H__ 'NAVFoundation.Stack.h'

DEFINE_CONSTANT

/**
 * @constant NAV_MAX_STACK_SIZE
 * @description Maximum size of a stack. This defines the maximum number of items
 *              that can be stored in a stack instance.
 * @default 500
 */
#IF_NOT_DEFINED NAV_MAX_STACK_SIZE
constant integer NAV_MAX_STACK_SIZE = 500
#END_IF

/**
 * @constant NAV_STACK_EMPTY
 * @description Indicates an empty stack. When Top equals this value, the stack is empty.
 * @default 0
 */
constant integer NAV_STACK_EMPTY = 0


DEFINE_TYPE

/**
 * @struct _NAVStackProperties
 * @description Internal structure that maintains the state of a stack.
 *              Used by both string and integer stack implementations.
 * @field {integer} Top - Current position of the top element (0 = empty)
 * @field {integer} Capacity - Maximum number of items the stack can hold
 */
struct _NAVStackProperties {
    integer Top
    integer Capacity
}


/**
 * @struct _NAVStackString
 * @description Stack data structure for storing string values in LIFO order.
 *              Implements a Last-In-First-Out (LIFO) data structure where the most
 *              recently added item is the first one to be removed.
 * @field {_NAVStackProperties} Properties - Stack state (top position and capacity)
 * @field {char[][]} Items - Array of string items stored in the stack
 *
 * @example
 * stack_var _NAVStackString myStack
 * NAVStackInitString(myStack, 10)
 * NAVStackPushString(myStack, 'Item1')
 */
struct _NAVStackString {
    _NAVStackProperties Properties
    char Items[NAV_MAX_STACK_SIZE][NAV_MAX_BUFFER]
}


/**
 * @struct _NAVStackInteger
 * @description Stack data structure for storing integer values in LIFO order.
 *              Implements a Last-In-First-Out (LIFO) data structure where the most
 *              recently added item is the first one to be removed.
 * @field {_NAVStackProperties} Properties - Stack state (top position and capacity)
 * @field {integer[]} Items - Array of integer items stored in the stack
 *
 * @example
 * stack_var _NAVStackInteger myStack
 * NAVStackInitInteger(myStack, 10)
 * NAVStackPushInteger(myStack, 42)
 */
struct _NAVStackInteger {
    _NAVStackProperties Properties
    integer Items[NAV_MAX_STACK_SIZE]
}


#END_IF // __NAV_FOUNDATION_STACK_H__
