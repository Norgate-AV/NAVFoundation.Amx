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

#IF_NOT_DEFINED __NAV_FOUNDATION_STACK__
#DEFINE __NAV_FOUNDATION_STACK__ 'NAVFoundation.Stack'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

#IF_NOT_DEFINED NAV_MAX_STACK_SIZE
constant integer NAV_MAX_STACK_SIZE = 500
#END_IF

constant integer NAV_STACK_EMPTY = 0


DEFINE_TYPE

struct _NAVStackProperties {
    integer Top
    integer Capacity
}


struct _NAVStackString {
    _NAVStackProperties Properties
    char Items[NAV_MAX_STACK_SIZE][NAV_MAX_BUFFER]
}


struct _NAVStackInteger {
    _NAVStackProperties Properties
    integer Items[NAV_MAX_STACK_SIZE]
}


define_function NAVStackInitString(_NAVStackString stack, integer capacity) {
    stack_var integer x

    if (capacity <= 0 || capacity > NAV_MAX_STACK_SIZE) {
        capacity = NAV_MAX_STACK_SIZE
    }

    stack.Properties.Top = NAV_STACK_EMPTY
    stack.Properties.Capacity = capacity

    set_length_array(stack.Items, capacity)

    for (x = 1; x <= length_array(stack.Items); x++) {
        stack.Items[x] = ""
    }
}


define_function integer NAVStackPushString(_NAVStackString stack, char item[]) {
    stack_var integer x

    if (NAVStackIsFull(stack.Properties)) {
        NAVLog("'NAVStackPush(): Error: Stack is full'")
        return false
    }

    if (!length_array(item)) {
        NAVLog("'NAVStackPush(): Warning: Item is an empty string'")
    }

    stack.Properties.Top++
    stack.Items[stack.Properties.Top] = item

    return true
}


define_function char[NAV_MAX_BUFFER] NAVStackPopString(_NAVStackString stack) {
    stack_var integer x
    stack_var char item[NAV_MAX_BUFFER]

    if (NAVStackIsEmpty(stack.Properties)) {
        NAVLog("'NAVStackPop(): Error: Stack is empty'")
        return ""
    }

    item = stack.Items[stack.Properties.Top]
    stack.Items[stack.Properties.Top] = ""
    stack.Properties.Top--

    return item
}


define_function char[NAV_MAX_BUFFER] NAVStackPeekString(_NAVStackString stack) {
    stack_var integer x
    stack_var char item[NAV_MAX_BUFFER]

    if (NAVStackIsEmpty(stack.Properties)) {
        NAVLog("'NAVStackPeek(): Error: Stack is empty'")
        return ""
    }

    item = stack.Items[stack.Properties.Top]

    return item
}


define_function integer NAVStackGetCount(_NAVStackProperties stack) {
    return stack.Top
}


define_function integer NAVStackIsFull(_NAVStackProperties stack) {
    return stack.Top == stack.Capacity
}


define_function integer NAVStackGetCapacity(_NAVStackProperties stack) {
    return stack.Capacity
}


define_function integer NAVStackIsEmpty(_NAVStackProperties stack) {
    return stack.Top == NAV_STACK_EMPTY
}


define_function integer NAVStackStringGetCount(_NAVStackString stack) {
    return NAVStackGetCount(stack.Properties)
}


define_function integer NAVStackStringIsFull(_NAVStackString stack) {
    return NAVStackIsFull(stack.Properties)
}


define_function integer NAVStackStringGetCapacity(_NAVStackString stack) {
    return NAVStackGetCapacity(stack.Properties)
}


define_function integer NAVStackStringIsEmpty(_NAVStackString stack) {
    return NAVStackIsEmpty(stack.Properties)
}


#END_IF // __NAV_FOUNDATION_STACK__
