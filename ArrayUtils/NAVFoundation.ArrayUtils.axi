PROGRAM_NAME='NAVFoundation.ArrayUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ARRAYUTILS__
#DEFINE __NAV_FOUNDATION_ARRAYUTILS__

#include 'NAVFoundation.Math.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.Stack.axi'


define_function integer NAVFindInArrayINTEGER(integer array[], integer value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


define_function integer NAVFindInArraySINTEGER(sinteger array[], sinteger value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


define_function integer NAVFindInArrayLONG(long array[], long value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


define_function integer NAVFindInArraySLONG(slong array[], slong value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


define_function integer NAVFindInArrayWIDECHAR(widechar array[], widechar value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


define_function integer NAVFindInArrayFLOAT(float array[], float value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


define_function integer NAVFindInArrayDOUBLE(double array[], double value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


define_function integer NAVFindInArrayCHAR(char array[], char value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


define_function integer NAVFindInArrayDEV(dev array[], dev value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


define_function integer NAVFindInArraySTRING(char array[][], char value[]) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


define_function char[NAV_MAX_BUFFER] NAVFormatArrayString(char array[][]) {
    stack_var integer x
    stack_var integer length
    stack_var char result[NAV_MAX_BUFFER]
    stack_var char element[NAV_MAX_BUFFER]

    length = length_array(array)
    result = ""

    for (x = 1; x <= length; x++) {

        element = array[x]
        result = "result, element"

        if (x < length) {
            result = "result, ', '"
        }
    }

    return NAVFormatHex("'[ ', result, ' ]'")
}


define_function char[NAV_MAX_BUFFER] NAVFormatArrayInteger(integer array[]) {
    stack_var integer x
    stack_var integer length
    stack_var char result[NAV_MAX_BUFFER]
    stack_var char element[NAV_MAX_BUFFER]

    length = length_array(array)
    result = ""

    for (x = 1; x <= length; x++) {

        element = itoa(array[x])
        result = "result, element"

        if (x < length) {
            result = "result, ', '"
        }
    }

    return "'[ ', result, ' ]'"
}


define_function NAVPrintArrayInteger(integer array[]) {
    NAVLog(NAVFormatArrayInteger(array))
}


define_function NAVPrintArrayString(char array[][]) {
    NAVLog(NAVFormatArrayString(array))
}


define_function NAVArraySwapInteger(integer array[], integer index1, integer index2) {
    stack_var integer temp

    temp = array[index1]
    array[index1] = array[index2]
    array[index2] = temp
}


define_function NAVArraySwapString(char array[][], integer index1, integer index2) {
    stack_var char temp[NAV_MAX_BUFFER]

    temp = array[index1]
    array[index1] = array[index2]
    array[index2] = temp
}


define_function integer NAVArrayPartitionInteger(integer array[], integer startIndex, integer endIndex) {
    stack_var integer pivot
    stack_var integer boundary
    stack_var integer x

    pivot = array[endIndex]
    boundary = startIndex - 1

    for (x = startIndex; x <= endIndex; x++) {
        if (array[x] <= pivot) {
            boundary++
            NAVArraySwapInteger(array, x, boundary)
        }
    }

    return boundary
}


define_function integer NAVArrayGetMinIndexInteger(integer array[], integer index) {
    stack_var integer x
    stack_var integer minIndex

    minIndex = index

    for (x = index + 1; x <= length_array(array); x++) {
        if (array[x] < array[minIndex]) {
            minIndex = x
        }
    }

    return minIndex
}


define_function integer NAVArrayGetMinIndexString(char array[][], integer index) {
    stack_var integer x
    stack_var integer minIndex

    minIndex = index

    for (x = index + 1; x <= length_array(array); x++) {
        if (NAVStringCompare(array[x], array[minIndex]) < 0) {
            minIndex = x
        }
    }

    return minIndex
}


define_function NAVArrayBubbleSortInteger(integer array[]) {
    stack_var integer x
    stack_var integer j
    stack_var integer isSorted
    stack_var integer arrayLength;

    arrayLength = length_array(array)

    for (x = 1; x <= arrayLength; x++) {
        isSorted = true

        for (j = 2; j <= arrayLength; j++) {
            if (array[j] < array[j - 1]) {
                NAVArraySwapInteger(array, j, j - 1)
                isSorted = false
            }
        }

        if (isSorted) {
            return
        }
    }
}


define_function NAVArraySelectionSortInteger(integer array[]) {
    stack_var integer x
    stack_var integer arrayLength
    stack_var integer minIndex

    arrayLength = length_array(array)

    for (x = 1; x <= arrayLength; x++) {
        minIndex = NAVArrayGetMinIndexInteger(array, x)

        if (minIndex == x) {
            continue
        }

        NAVArraySwapInteger(array, minIndex, x)
    }
}


define_function NAVArraySelectionSortString(char array[][]) {
    stack_var integer x
    stack_var integer arrayLength
    stack_var integer minIndex

    arrayLength = length_array(array)

    for (x = 1; x <= arrayLength - 1; x++) {
        minIndex = NAVArrayGetMinIndexString(array, x)

        if (minIndex == x) {
            continue
        }

        NAVArraySwapString(array, minIndex, x)
    }
}


define_function NAVArrayInsertionSortInteger(integer array[]) {
    stack_var integer x
    stack_var integer j
    stack_var integer current

    for (x = 2; x <= length_array(array); x++) {
        current = array[x]
        j = x - 1

        while (j >= 1 && array[j] > current) {
            array[j + 1] = array[j]
            j--
        }

        array[j + 1] = current
    }
}


define_function NAVArrayQuickSortRangeInteger(integer array[], integer startIndex, integer endIndex) {
    stack_var integer boundary

    if (startIndex >= endIndex) {
        return
    }

    boundary = NAVArrayPartitionInteger(array, startIndex, endIndex)

    NAVArrayQuickSortRangeInteger(array, startIndex, boundary - 1)
    NAVArrayQuickSortRangeInteger(array, boundary + 1, endIndex)
}


define_function NAVArrayQuickSortInteger(integer array[]) {
    NAVArrayQuickSortRangeInteger(array, 1, length_array(array))
}


define_function NAVArrayMergeSortMergeInteger(integer left[], integer right[], integer result[]) {
    stack_var integer x
    stack_var integer j
    stack_var integer k
    stack_var integer leftLength
    stack_var integer rightLength

    leftLength = length_array(left)
    rightLength = length_array(right)

    x = 1
    j = 1
    k = 1

    while (x <= leftLength && j <= rightLength) {
        if (left[x] <= right[j]) {
            result[k] = left[x]
            x++
            k++
        }
        else {
            result[k] = right[j]
            j++
            k++
        }
    }

    while (x <= leftLength) {
        result[k] = left[x]
        x++
        k++
    }

    while (j <= rightLength) {
        result[k] = right[j]
        j++
        k++
    }
}


define_function NAVArrayMergeSortInteger(integer array[]) {
    stack_var integer middle
    stack_var integer arrayLength
    stack_var integer left[1]
    stack_var integer right[1]
    stack_var integer x

    arrayLength = length_array(array)

    if(arrayLength < 2) {
        return
    }

    middle = arrayLength / 2

    set_length_array(left, middle)
    for (x = 1; x <= middle; x++) {
        left[x] = array[x]
    }

    set_length_array(left, arrayLength - middle)
    for (x = (middle + 1); x <= arrayLength; x++) {
        right[x - middle] = array[x]
    }

    NAVArrayMergeSortInteger(left)
    NAVArrayMergeSortInteger(right)

    NAVArrayMergeSortMergeInteger(left, right, array)
}


define_function NAVArrayCountingSortInteger(integer array[], integer maxValue) {
    stack_var integer counts[1]
    stack_var integer x
    stack_var integer j
    stack_var integer k

    set_length_array(counts, maxValue)
    for (x = 1; x <= length_array(counts); x++) {
        counts[x] = 0
    }

    for (x = 1; x <= length_array(array); x++) {
        counts[array[x]]++
    }

    k = 1
    for (x = 1; x <= length_array(counts); x++) {
        for (j = 1; j <= counts[x]; j++) {
            array[k] = x
            k++
        }
    }
}


define_function integer NAVArrayBinarySearchRangeIntegerRecursive(integer array[], integer target, integer left, integer right) {
    stack_var integer middle

    if (right < left) {
        return 0
    }

    middle = (left + right) / 2

    if (array[middle] == target) {
        return middle
    }

    if (target < array[middle]) {
        return NAVArrayBinarySearchRangeIntegerRecursive(array, target, left, middle - 1)
    }

    return NAVArrayBinarySearchRangeIntegerRecursive(array, target, middle + 1, right)
}


define_function integer NAVArrayBinarySearchIntegerRecursive(integer array[], integer target) {
    return NAVArrayBinarySearchRangeIntegerRecursive(array, target, 1, length_array(array))
}


define_function integer NAVArrayBinarySearchIntegerIterative(integer array[], integer target) {
    stack_var integer left
    stack_var integer right
    stack_var integer middle

    left = 1
    right = length_array(array)

    while (left <= right) {
        middle = (left + right) / 2

        if (array[middle] == target) {
            return middle
        }

        if (target < array[middle]) {
            right = middle - 1
        }
        else {
            left = middle + 1
        }
    }

    return 0
}


define_function integer NAVArrayTernarySearchRangeInteger(integer array[], integer target, integer left, integer right) {
    stack_var integer partitionSize
    stack_var integer middle1
    stack_var integer middle2

    if (left > right) {
        return 0
    }

    partitionSize = (right - left) / 3
    middle1 = left + partitionSize
    middle2 = right - partitionSize

    if (array[middle1] == target) {
        return middle1
    }

    if (array[middle2] == target) {
        return middle2
    }

    if (target < array[middle1]) {
        return NAVArrayTernarySearchRangeInteger(array, target, left, middle1 - 1)
    }

    if (target > array[middle2]) {
        return NAVArrayTernarySearchRangeInteger(array, target, middle2 + 1, right)
    }

    return NAVArrayTernarySearchRangeInteger(array, target, middle1 + 1, middle2 - 1)
}


define_function integer NAVArrayTernarySearchInteger(integer array[], integer target) {
    return NAVArrayTernarySearchRangeInteger(array, target, 1, length_array(array))
}


define_function integer NAVArrayJumpSearchInteger(integer array[], integer target) {
    stack_var integer blockSize
    stack_var integer start
    stack_var integer next
    stack_var integer arrayLength
    stack_var integer x

    arrayLength = length_array(array)
    blockSize = type_cast(NAVSquareRoot(arrayLength))
    start = 1
    next = blockSize

    while (start < arrayLength && array[next] < target) {
        start = next
        next = next + blockSize

        if (next > arrayLength) {
            next = arrayLength
        }
    }

    for (x = start; x <= next; x++) {
        if (array[x] == target) {
            return x
        }
    }

    return 0
}


define_function integer NAVArrayExponentialSearchInteger(integer array[], integer target) {
    stack_var integer bound
    stack_var integer left
    stack_var integer right
    stack_var integer arrayLength

    arrayLength = length_array(array)

    bound = 1

    while (bound <= arrayLength && array[bound] < target) {
        bound = bound * 2
    }

    left = bound / 2
    right = min_value(bound, arrayLength)
    return NAVArrayBinarySearchRangeIntegerRecursive(array, target, left, right)
}


define_function NAVArrayReverseString(char array[][]) {
    stack_var _NAVStackString stack
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    NAVStackInitString(stack, length)

    for (x = 1; x <= length; x++) {
        NAVStackPushString(stack, array[x])
    }

    for (x = 1; x <= length; x++) {
        array[x] = NAVStackPopString(stack)
    }
}


#END_IF // __NAV_FOUNDATION_ARRAYUTILS__
