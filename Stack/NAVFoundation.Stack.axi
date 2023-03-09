PROGRAM_NAME='NAVFoundation.Stack'

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


define_function NAVStackInitString(_NAVStackString stack, integer capacity) {
    stack_var integer x

    if (capacity <= 0 || capacity > NAV_MAX_STACK_SIZE) {
        capacity = NAV_MAX_STACK_SIZE
    }

    stack.Properties.Top = NAV_STACK_EMPTY
    stack.Properties.Capacity = capacity
}


define_function integer NAVStackPushString(_NAVStackString stack, char item[]) {
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


define_function NAVStackInitInteger(_NAVStackInteger stack, integer capacity) {
    stack_var integer x

    if (capacity <= 0 || capacity > NAV_MAX_STACK_SIZE) {
        capacity = NAV_MAX_STACK_SIZE
    }

    stack.Properties.Top = NAV_STACK_EMPTY
    stack.Properties.Capacity = capacity
}


define_function integer NAVStackPushInteger(_NAVStackInteger stack, integer item) {
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


define_function integer NAVStackIntegerGetCount(_NAVStackInteger stack) {
    return NAVStackGetCount(stack.Properties)
}


define_function integer NAVStackIntegerIsFull(_NAVStackInteger stack) {
    return NAVStackIsFull(stack.Properties)
}


define_function integer NAVStackIntegerGetCapacity(_NAVStackInteger stack) {
    return NAVStackGetCapacity(stack.Properties)
}


define_function integer NAVStackIntegerIsEmpty(_NAVStackInteger stack) {
    return NAVStackIsEmpty(stack.Properties)
}


#END_IF // __NAV_FOUNDATION_STACK__
