PROGRAM_NAME='NAVFoundation.ArrayUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ARRAYUTILS__
#DEFINE __NAV_FOUNDATION_ARRAYUTILS__ 'NAVFoundation.ArrayUtils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.ArrayUtils.h.axi'
#include 'NAVFoundation.Stack.axi'
#include 'NAVFoundation.Math.axi'
#include 'NAVFoundation.StringUtils.axi'


/**
 * @function NAVSetArrayChar
 * @public
 * @description Sets all elements of a char array to the specified value.
 *
 * @param {char[]} array - Array to be modified
 * @param {char} value - Value to set for all elements
 *
 * @returns {void}
 *
 * @example
 * stack_var char buffer[10]
 * NAVSetArrayChar(buffer, $FF) // Sets all 10 elements to $FF
 */
define_function NAVSetArrayChar(char array[], char value) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = value
    }
}


/**
 * @function NAVSetArrayInteger
 * @public
 * @description Sets all elements of an integer array to the specified value.
 *
 * @param {integer[]} array - Array to be modified
 * @param {integer} value - Value to set for all elements
 *
 * @returns {void}
 *
 * @example
 * stack_var integer values[5]
 * NAVSetArrayInteger(values, 42) // Sets all 5 elements to 42
 */
define_function NAVSetArrayInteger(integer array[], integer value) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = value
    }
}


/**
 * @function NAVSetArraySignedInteger
 * @public
 * @description Sets all elements of a signed integer array to the specified value.
 *
 * @param {sinteger[]} array - Array to be modified
 * @param {sinteger} value - Value to set for all elements
 *
 * @returns {void}
 *
 * @example
 * stack_var sinteger values[5]
 * NAVSetArraySignedInteger(values, -10) // Sets all 5 elements to -10
 */
define_function NAVSetArraySignedInteger(sinteger array[], sinteger value) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = value
    }
}


/**
 * @function NAVSetArrayLong
 * @public
 * @description Sets all elements of a long array to the specified value.
 *
 * @param {long[]} array - Array to be modified
 * @param {long} value - Value to set for all elements
 *
 * @returns {void}
 *
 * @example
 * stack_var long values[5]
 * NAVSetArrayLong(values, $FFFFFFFF) // Sets all 5 elements to $FFFFFFFF
 */
define_function NAVSetArrayLong(long array[], long value) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = value
    }
}


/**
 * @function NAVSetArraySignedLong
 * @public
 * @description Sets all elements of a signed long array to the specified value.
 *
 * @param {slong[]} array - Array to be modified
 * @param {slong} value - Value to set for all elements
 *
 * @returns {void}
 *
 * @example
 * stack_var slong values[5]
 * NAVSetArraySignedLong(values, -100000) // Sets all 5 elements to -100000
 */
define_function NAVSetArraySignedLong(slong array[], slong value) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = value
    }
}


/**
 * @function NAVSetArrayFloat
 * @public
 * @description Sets all elements of a float array to the specified value.
 *
 * @param {float[]} array - Array to be modified
 * @param {float} value - Value to set for all elements
 *
 * @returns {void}
 *
 * @example
 * stack_var float values[5]
 * NAVSetArrayFloat(values, 3.14159) // Sets all 5 elements to 3.14159
 */
define_function NAVSetArrayFloat(float array[], float value) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = value
    }
}


/**
 * @function NAVSetArrayDouble
 * @public
 * @description Sets all elements of a double array to the specified value.
 *
 * @param {double[]} array - Array to be modified
 * @param {double} value - Value to set for all elements
 *
 * @returns {void}
 *
 * @example
 * stack_var double values[5]
 * NAVSetArrayDouble(values, 3.14159265359) // Sets all 5 elements to 3.14159265359
 */
define_function NAVSetArrayDouble(double array[], double value) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = value
    }
}


/**
 * @function NAVSetArrayString
 * @public
 * @description Sets all elements of a string array to the specified value.
 *
 * @param {char[][]} array - Array to be modified
 * @param {char[]} value - Value to set for all elements
 *
 * @returns {void}
 *
 * @example
 * stack_var char names[5][20]
 * NAVSetArrayString(names, 'Default') // Sets all 5 elements to "Default"
 */
define_function NAVSetArrayString(char array[][], char value[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = value
    }
}


/**
 * @function NAVFindInArrayINTEGER
 * @public
 * @description Searches for a value in an integer array and returns its index.
 *
 * @param {integer[]} array - Array to search in
 * @param {integer} value - Value to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var integer values[3] = {10, 20, 30}
 * stack_var integer index
 *
 * index = NAVFindInArrayINTEGER(values, 20) // Returns 2
 */
define_function integer NAVFindInArrayINTEGER(integer array[], integer value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFindInArraySINTEGER
 * @public
 * @description Searches for a value in a signed integer array and returns its index.
 *
 * @param {sinteger[]} array - Array to search in
 * @param {sinteger} value - Value to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var sinteger values[3] = {-10, 0, 10}
 * stack_var integer index
 *
 * index = NAVFindInArraySINTEGER(values, 0) // Returns 2
 */
define_function integer NAVFindInArraySINTEGER(sinteger array[], sinteger value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFindInArrayLONG
 * @public
 * @description Searches for a value in a long array and returns its index.
 *
 * @param {long[]} array - Array to search in
 * @param {long} value - Value to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var long values[3] = {$01000000, $02000000, $03000000}
 * stack_var integer index
 *
 * index = NAVFindInArrayLONG(values, $02000000) // Returns 2
 */
define_function integer NAVFindInArrayLONG(long array[], long value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFindInArraySLONG
 * @public
 * @description Searches for a value in a signed long array and returns its index.
 *
 * @param {slong[]} array - Array to search in
 * @param {slong} value - Value to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var slong values[3] = {-1000000, 0, 1000000}
 * stack_var integer index
 *
 * index = NAVFindInArraySLONG(values, -1000000) // Returns 1
 */
define_function integer NAVFindInArraySLONG(slong array[], slong value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFindInArrayWIDECHAR
 * @public
 * @description Searches for a value in a widechar array and returns its index.
 *
 * @param {widechar[]} array - Array to search in
 * @param {widechar} value - Value to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 */
define_function integer NAVFindInArrayWIDECHAR(widechar array[], widechar value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFindInArrayFLOAT
 * @public
 * @description Searches for a value in a float array and returns its index.
 *
 * @param {float[]} array - Array to search in
 * @param {float} value - Value to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var float values[3] = {1.1, 2.2, 3.3}
 * stack_var integer index
 *
 * index = NAVFindInArrayFLOAT(values, 2.2) // Returns 2
 */
define_function integer NAVFindInArrayFLOAT(float array[], float value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFindInArrayDOUBLE
 * @public
 * @description Searches for a value in a double array and returns its index.
 *
 * @param {double[]} array - Array to search in
 * @param {double} value - Value to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var double values[3] = {1.111, 2.222, 3.333}
 * stack_var integer index
 *
 * index = NAVFindInArrayDOUBLE(values, 2.222) // Returns 2
 */
define_function integer NAVFindInArrayDOUBLE(double array[], double value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFindInArrayCHAR
 * @public
 * @description Searches for a value in a char array and returns its index.
 *
 * @param {char[]} array - Array to search in
 * @param {char} value - Value to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var char values[5] = {'A', 'B', 'C', 'D', 'E'}
 * stack_var integer index
 *
 * index = NAVFindInArrayCHAR(values, 'C') // Returns 3
 */
define_function integer NAVFindInArrayCHAR(char array[], char value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFindInArrayDEV
 * @public
 * @description Searches for a device in a device array and returns its index.
 *
 * @param {dev[]} array - Array to search in
 * @param {dev} value - Device to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var dev devices[3] = {dvTP, dvMaster, dvMatrix}
 * stack_var integer index
 *
 * index = NAVFindInArrayDEV(devices, dvTP) // Returns 1
 */
define_function integer NAVFindInArrayDEV(dev array[], dev value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFindInArrayDEVICE
 * @public
 * @description Alias for NAVFindInArrayDEV - searches for a device in a device array.
 *
 * @param {dev[]} array - Array to search in
 * @param {dev} value - Device to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 *
 * @see NAVFindInArrayDEV
 */
define_function integer NAVFindInArrayDEVICE(dev array[], dev value) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFindInArraySTRING
 * @public
 * @description Searches for a string in a string array and returns its index.
 *
 * @param {char[][]} array - Array to search in
 * @param {char[]} value - String to find
 *
 * @returns {integer} Index of the first occurrence (1-based), or 0 if not found
 *
 * @example
 * stack_var char names[3][20] = {'Alice', 'Bob', 'Charlie'}
 * stack_var integer index
 *
 * index = NAVFindInArraySTRING(names, 'Bob') // Returns 2
 */
define_function integer NAVFindInArraySTRING(char array[][], char value[]) {
    stack_var integer x

    for (x = 1; x <= length_array(array); x++) {
        if (array[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVFormatArrayString
 * @public
 * @description Formats a string array as a readable string representation.
 *
 * @param {char[][]} array - Array to format
 *
 * @returns {char[]} Formatted string representation of the array
 *
 * @example
 * stack_var char names[3][20] = {'Alice', 'Bob', 'Charlie'}
 * stack_var char output[200]
 *
 * output = NAVFormatArrayString(names) // Returns "[Alice, Bob, Charlie]"
 */
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

    return "'[', result, ']'"
}


/**
 * @function NAVFormatArrayInteger
 * @public
 * @description Formats an integer array as a readable string representation.
 *
 * @param {integer[]} array - Array to format
 *
 * @returns {char[]} Formatted string representation of the array
 *
 * @example
 * stack_var integer values[3] = {10, 20, 30}
 * stack_var char output[200]
 *
 * output = NAVFormatArrayInteger(values) // Returns "[10, 20, 30]"
 */
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

    return "'[', result, ']'"
}


/**
 * @function NAVPrintArrayInteger
 * @public
 * @description Logs an integer array to the debug log.
 *
 * @param {integer[]} array - Array to print
 *
 * @returns {void}
 *
 * @example
 * stack_var integer values[3] = {10, 20, 30}
 * NAVPrintArrayInteger(values) // Logs "[10, 20, 30]" to the debug log
 *
 * @see NAVFormatArrayInteger
 */
define_function NAVPrintArrayInteger(integer array[]) {
    NAVLog(NAVFormatArrayInteger(array))
}


/**
 * @function NAVPrintArrayString
 * @public
 * @description Logs a string array to the debug log.
 *
 * @param {char[][]} array - Array to print
 *
 * @returns {void}
 *
 * @example
 * stack_var char names[3][20] = {'Alice', 'Bob', 'Charlie'}
 * NAVPrintArrayString(names) // Logs "[Alice, Bob, Charlie]" to the debug log
 *
 * @see NAVFormatArrayString
 */
define_function NAVPrintArrayString(char array[][]) {
    NAVLog(NAVFormatArrayString(array))
}


/**
 * @function NAVArraySwapInteger
 * @public
 * @description Swaps two elements in an integer array.
 *
 * @param {integer[]} array - Array containing elements to swap
 * @param {integer} index1 - Index of first element
 * @param {integer} index2 - Index of second element
 *
 * @returns {void}
 *
 * @example
 * stack_var integer values[3] = {10, 20, 30}
 * NAVArraySwapInteger(values, 1, 3) // values becomes {30, 20, 10}
 */
define_function NAVArraySwapInteger(integer array[], integer index1, integer index2) {
    stack_var integer temp

    temp = array[index1]
    array[index1] = array[index2]
    array[index2] = temp
}


/**
 * @function NAVArraySwapString
 * @public
 * @description Swaps two elements in a string array.
 *
 * @param {char[][]} array - Array containing elements to swap
 * @param {integer} index1 - Index of first element
 * @param {integer} index2 - Index of second element
 *
 * @returns {void}
 *
 * @example
 * stack_var char names[3][20] = {'Alice', 'Bob', 'Charlie'}
 * NAVArraySwapString(names, 1, 3) // names becomes {'Charlie', 'Bob', 'Alice'}
 */
define_function NAVArraySwapString(char array[][], integer index1, integer index2) {
    stack_var char temp[NAV_MAX_BUFFER]

    temp = array[index1]
    array[index1] = array[index2]
    array[index2] = temp
}


/**
 * @function NAVArrayPartitionInteger
 * @internal
 * @description Partitions an integer array for quicksort algorithm.
 *
 * @param {integer[]} array - Array to partition
 * @param {integer} startIndex - Start index of the partition
 * @param {integer} endIndex - End index of the partition
 *
 * @returns {integer} Boundary index of the partition
 *
 * @see NAVArrayQuickSortInteger
 */
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


/**
 * @function NAVArrayGetMinIndexInteger
 * @internal
 * @description Finds the index of the minimum value in a portion of an integer array.
 *
 * @param {integer[]} array - Array to search
 * @param {integer} index - Starting index for the search
 *
 * @returns {integer} Index of the minimum value
 *
 * @see NAVArraySelectionSortInteger
 */
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


/**
 * @function NAVArrayGetMinIndexString
 * @internal
 * @description Finds the index of the lexicographically smallest string in a portion of a string array.
 *
 * @param {char[][]} array - Array to search
 * @param {integer} index - Starting index for the search
 *
 * @returns {integer} Index of the minimum value
 *
 * @see NAVArraySelectionSortString
 */
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


/**
 * @function NAVArrayBubbleSortInteger
 * @public
 * @description Sorts an integer array using the bubble sort algorithm.
 *
 * @param {integer[]} array - Array to sort
 *
 * @returns {void}
 *
 * @example
 * stack_var integer values[5] = {5, 3, 1, 4, 2}
 * NAVArrayBubbleSortInteger(values) // values becomes {1, 2, 3, 4, 5}
 *
 * @note Bubble sort has O(n²) time complexity, suitable only for small arrays
 */
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


/**
 * @function NAVArraySelectionSortInteger
 * @public
 * @description Sorts an integer array using the selection sort algorithm.
 *
 * @param {integer[]} array - Array to sort
 *
 * @returns {void}
 *
 * @example
 * stack_var integer values[5] = {5, 3, 1, 4, 2}
 * NAVArraySelectionSortInteger(values) // values becomes {1, 2, 3, 4, 5}
 *
 * @note Selection sort has O(n²) time complexity, suitable only for small arrays
 */
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


/**
 * @function NAVArraySelectionSortString
 * @public
 * @description Sorts a string array using the selection sort algorithm.
 *
 * @param {char[][]} array - Array to sort
 *
 * @returns {void}
 *
 * @example
 * stack_var char names[3][20] = {'Charlie', 'Alice', 'Bob'}
 * NAVArraySelectionSortString(names) // names becomes {'Alice', 'Bob', 'Charlie'}
 *
 * @note Selection sort has O(n²) time complexity, suitable only for small arrays
 */
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


/**
 * @function NAVArrayInsertionSortInteger
 * @public
 * @description Sorts an integer array using the insertion sort algorithm.
 *
 * @param {integer[]} array - Array to sort
 *
 * @returns {void}
 *
 * @example
 * stack_var integer values[5] = {5, 3, 1, 4, 2}
 * NAVArrayInsertionSortInteger(values) // values becomes {1, 2, 3, 4, 5}
 *
 * @note Insertion sort has O(n²) time complexity in worst case, but performs well on small or nearly sorted arrays
 */
define_function NAVArrayInsertionSortInteger(integer array[]) {
    stack_var integer x
    stack_var integer j
    stack_var integer current

    for (x = 2; x <= length_array(array); x++) {
        current = array[x]
        j = x - 1

        while (j >= 1) {
            if (array[j] <= current) {
                break
            }
            array[j + 1] = array[j]
            j--
        }

        array[j + 1] = current
    }
}


/**
 * @function NAVArrayQuickSortRangeInteger
 * @internal
 * @description Helper function for quick sort that recursively sorts a range within an integer array.
 *
 * @param {integer[]} array - Array to sort
 * @param {integer} startIndex - Start index of the range to sort
 * @param {integer} endIndex - End index of the range to sort
 *
 * @returns {void}
 *
 * @see NAVArrayQuickSortInteger
 */
define_function NAVArrayQuickSortRangeInteger(integer array[], integer startIndex, integer endIndex) {
    stack_var integer boundary

    if (startIndex >= endIndex) {
        return
    }

    boundary = NAVArrayPartitionInteger(array, startIndex, endIndex)

    NAVArrayQuickSortRangeInteger(array, startIndex, boundary - 1)
    NAVArrayQuickSortRangeInteger(array, boundary + 1, endIndex)
}


/**
 * @function NAVArrayQuickSortInteger
 * @public
 * @description Sorts an integer array using the quick sort algorithm.
 *
 * @param {integer[]} array - Array to sort
 *
 * @returns {void}
 *
 * @example
 * stack_var integer values[5] = {5, 3, 1, 4, 2}
 * NAVArrayQuickSortInteger(values) // values becomes {1, 2, 3, 4, 5}
 *
 * @note Quick sort has O(n log n) average time complexity, making it efficient for larger arrays
 */
define_function NAVArrayQuickSortInteger(integer array[]) {
    NAVArrayQuickSortRangeInteger(array, 1, length_array(array))
}


/**
 * @function NAVArrayMergeSortMergeInteger
 * @internal
 * @description Merges two sorted integer arrays as part of the merge sort algorithm.
 *
 * @param {integer[]} left - First sorted array
 * @param {integer[]} right - Second sorted array
 * @param {integer[]} result - Result array where merged values are stored
 *
 * @returns {void}
 *
 * @see NAVArrayMergeSortInteger
 */
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


/**
 * @function NAVArrayMergeSortInteger
 * @public
 * @description Sorts an integer array using the merge sort algorithm.
 *
 * @param {integer[]} array - Array to sort
 *
 * @returns {void}
 *
 * @example
 * stack_var integer values[5] = {5, 3, 1, 4, 2}
 * NAVArrayMergeSortInteger(values) // values becomes {1, 2, 3, 4, 5}
 *
 * @note Merge sort has O(n log n) time complexity and is stable, but requires extra space
 */
define_function NAVArrayMergeSortInteger(integer array[]) {
    stack_var integer middle
    stack_var integer arrayLength
    stack_var integer left[100]
    stack_var integer right[100]
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

    set_length_array(right, arrayLength - middle)
    for (x = (middle + 1); x <= arrayLength; x++) {
        right[x - middle] = array[x]
    }

    NAVArrayMergeSortInteger(left)
    NAVArrayMergeSortInteger(right)

    NAVArrayMergeSortMergeInteger(left, right, array)
}


/**
 * @function NAVArrayCountingSortInteger
 * @public
 * @description Sorts an integer array using the counting sort algorithm.
 * Only suitable for arrays with small integers (values must be less than or equal to maxValue).
 *
 * @param {integer[]} array - Array to sort
 * @param {integer} maxValue - Maximum possible value in the array
 *
 * @returns {void}
 *
 * @example
 * stack_var integer values[5] = {5, 3, 1, 4, 2}
 * NAVArrayCountingSortInteger(values, 10) // values becomes {1, 2, 3, 4, 5}
 *
 * @note Counting sort has O(n+k) time complexity where k is the range of values
 */
define_function NAVArrayCountingSortInteger(integer array[], integer maxValue) {
    stack_var integer counts[1000]
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


/**
 * @function NAVArrayBinarySearchRangeIntegerRecursive
 * @internal
 * @description Helper function for binary search that recursively searches a range within a sorted integer array.
 *
 * @param {integer[]} array - Sorted array to search
 * @param {integer} target - Value to find
 * @param {integer} left - Start index of the range to search
 * @param {integer} right - End index of the range to search
 *
 * @returns {integer} Index of the target value (1-based), or 0 if not found
 *
 * @see NAVArrayBinarySearchIntegerRecursive
 */
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


/**
 * @function NAVArrayBinarySearchIntegerRecursive
 * @public
 * @description Searches for a value in a sorted integer array using recursive binary search.
 *
 * @param {integer[]} array - Sorted array to search
 * @param {integer} target - Value to find
 *
 * @returns {integer} Index of the target value (1-based), or 0 if not found
 *
 * @example
 * stack_var integer values[5] = {10, 20, 30, 40, 50}
 * stack_var integer index
 *
 * index = NAVArrayBinarySearchIntegerRecursive(values, 30) // Returns 3
 *
 * @note Array must be sorted in ascending order
 * @see NAVArrayBinarySearchIntegerIterative
 */
define_function integer NAVArrayBinarySearchIntegerRecursive(integer array[], integer target) {
    return NAVArrayBinarySearchRangeIntegerRecursive(array, target, 1, length_array(array))
}


/**
 * @function NAVArrayBinarySearchIntegerIterative
 * @public
 * @description Searches for a value in a sorted integer array using iterative binary search.
 *
 * @param {integer[]} array - Sorted array to search
 * @param {integer} target - Value to find
 *
 * @returns {integer} Index of the target value (1-based), or 0 if not found
 *
 * @example
 * stack_var integer values[5] = {10, 20, 30, 40, 50}
 * stack_var integer index
 *
 * index = NAVArrayBinarySearchIntegerIterative(values, 30) // Returns 3
 *
 * @note Array must be sorted in ascending order
 * @see NAVArrayBinarySearchIntegerRecursive
 */
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


/**
 * @function NAVArrayTernarySearchRangeInteger
 * @internal
 * @description Helper function for ternary search that recursively searches a range within a sorted integer array.
 *
 * @param {integer[]} array - Sorted array to search
 * @param {integer} target - Value to find
 * @param {integer} left - Start index of the range to search
 * @param {integer} right - End index of the range to search
 *
 * @returns {integer} Index of the target value (1-based), or 0 if not found
 *
 * @see NAVArrayTernarySearchInteger
 */
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


/**
 * @function NAVArrayTernarySearchInteger
 * @public
 * @description Searches for a value in a sorted integer array using ternary search.
 *
 * @param {integer[]} array - Sorted array to search
 * @param {integer} target - Value to find
 *
 * @returns {integer} Index of the target value (1-based), or 0 if not found
 *
 * @example
 * stack_var integer values[5] = {10, 20, 30, 40, 50}
 * stack_var integer index
 *
 * index = NAVArrayTernarySearchInteger(values, 30) // Returns 3
 *
 * @note Array must be sorted in ascending order
 * @see NAVArrayTernarySearchRangeInteger
 */
define_function integer NAVArrayTernarySearchInteger(integer array[], integer target) {
    return NAVArrayTernarySearchRangeInteger(array, target, 1, length_array(array))
}


/**
 * @function NAVArrayJumpSearchInteger
 * @public
 * @description Searches for a value in a sorted integer array using jump search.
 *
 * @param {integer[]} array - Sorted array to search
 * @param {integer} target - Value to find
 *
 * @returns {integer} Index of the target value (1-based), or 0 if not found
 *
 * @example
 * stack_var integer values[5] = {10, 20, 30, 40, 50}
 * stack_var integer index
 *
 * index = NAVArrayJumpSearchInteger(values, 30) // Returns 3
 *
 * @note Array must be sorted in ascending order
 */
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


/**
 * @function NAVArrayExponentialSearchInteger
 * @public
 * @description Searches for a value in a sorted integer array using exponential search.
 *
 * @param {integer[]} array - Sorted array to search
 * @param {integer} target - Value to find
 *
 * @returns {integer} Index of the target value (1-based), or 0 if not found
 *
 * @example
 * stack_var integer values[5] = {10, 20, 30, 40, 50}
 * stack_var integer index
 *
 * index = NAVArrayExponentialSearchInteger(values, 30) // Returns 3
 *
 * @note Array must be sorted in ascending order
 */
define_function integer NAVArrayExponentialSearchInteger(integer array[], integer target) {
    stack_var integer bound
    stack_var integer left
    stack_var integer right
    stack_var integer arrayLength

    arrayLength = length_array(array)

    bound = 1

    while (bound <= arrayLength) {
        if (array[bound] >= target) {
            break
        }
        bound = bound * 2
    }

    left = bound / 2
    right = min_value(bound, arrayLength)
    return NAVArrayBinarySearchRangeIntegerRecursive(array, target, left, right)
}


/**
 * @function NAVArrayReverseString
 * @public
 * @description Reverses the order of elements in a string array.
 *
 * @param {char[][]} array - Array to reverse
 *
 * @returns {void}
 *
 * @example
 * stack_var char names[3][20] = {'Alice', 'Bob', 'Charlie'}
 * NAVArrayReverseString(names) // names becomes {'Charlie', 'Bob', 'Alice'}
 */
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


/**
 * @function NAVArrayCopyString
 * @public
 * @description Copies elements from one string array to another.
 *
 * @param {char[][]} source - Source array
 * @param {char[][]} destination - Destination array
 *
 * @returns {void}
 *
 * @example
 * stack_var char source[3][20] = {'Alice', 'Bob', 'Charlie'}
 * stack_var char destination[3][20]
 * NAVArrayCopyString(source, destination) // destination becomes {'Alice', 'Bob', 'Charlie'}
 */
define_function NAVArrayCopyString(char source[][], char destination[][]) {
    stack_var integer x
    stack_var integer length

    length = length_array(source)

    if (!length) {
        return
    }

    set_length_array(destination, length)

    for (x = 1; x <= length; x++) {
        destination[x] = source[x]
    }
}


/**
 * @function NAVArrayReverseInteger
 * @public
 * @description Reverses the order of elements in an integer array.
 *
 * @param {integer[]} array - Array to reverse
 *
 * @returns {void}
 *
 * @example
 * stack_var integer values[5] = {1, 2, 3, 4, 5}
 * NAVArrayReverseInteger(values) // values becomes {5, 4, 3, 2, 1}
 */
define_function NAVArrayReverseInteger(integer array[]) {
    stack_var _NAVStackInteger stack
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    NAVStackInitInteger(stack, length)

    for (x = 1; x <= length; x++) {
        NAVStackPushInteger(stack, array[x])
    }

    for (x = 1; x <= length; x++) {
        array[x] = NAVStackPopInteger(stack)
    }
}


/**
 * @function NAVArrayCopyInteger
 * @public
 * @description Copies elements from one integer array to another.
 *
 * @param {integer[]} source - Source array
 * @param {integer[]} destination - Destination array
 *
 * @returns {void}
 *
 * @example
 * stack_var integer source[3] = {10, 20, 30}
 * stack_var integer destination[3]
 * NAVArrayCopyInteger(source, destination) // destination becomes {10, 20, 30}
 */
define_function NAVArrayCopyInteger(integer source[], integer destination[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(source)

    if (!length) {
        return
    }

    set_length_array(destination, length)

    for (x = 1; x <= length; x++) {
        destination[x] = source[x]
    }
}


/**
 * @function NAVArrayIsSortedString
 * @public
 * @description Checks if a string array is sorted in ascending order.
 *
 * @param {char[][]} array - Array to check
 *
 * @returns {char} True if sorted, false otherwise
 *
 * @example
 * stack_var char names[3][20] = {'Alice', 'Bob', 'Charlie'}
 * stack_var char isSorted
 *
 * isSorted = NAVArrayIsSortedString(names) // Returns true
 */
define_function char NAVArrayIsSortedString(char array[][]) {
    return NAVArrayIsSortedAscendingString(array)
}


/**
 * @function NAVArrayIsSortedInteger
 * @public
 * @description Checks if an integer array is sorted in ascending order.
 *
 * @param {integer[]} array - Array to check
 *
 * @returns {char} True if sorted, false otherwise
 *
 * @example
 * stack_var integer values[5] = {1, 2, 3, 4, 5}
 * stack_var char isSorted
 *
 * isSorted = NAVArrayIsSortedInteger(values) // Returns true
 */
define_function char NAVArrayIsSortedInteger(integer array[]) {
    return NAVArrayIsSortedAscendingInteger(array)
}


/**
 * @function NAVArrayIsSortedAscendingString
 * @public
 * @description Checks if a string array is sorted in ascending order.
 *
 * @param {char[][]} array - Array to check
 *
 * @returns {char} True if sorted, false otherwise
 *
 * @example
 * stack_var char names[3][20] = {'Alice', 'Bob', 'Charlie'}
 * stack_var char isSorted
 *
 * isSorted = NAVArrayIsSortedAscendingString(names) // Returns true
 */
define_function char NAVArrayIsSortedAscendingString(char array[][]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x < length; x++) {
        if (NAVStringCompare(array[x], array[x + 1]) > 0) {
            return false
        }
    }

    return true
}


/**
 * @function NAVArrayIsSortedAscendingInteger
 * @public
 * @description Checks if an integer array is sorted in ascending order.
 *
 * @param {integer[]} array - Array to check
 *
 * @returns {char} True if sorted, false otherwise
 *
 * @example
 * stack_var integer values[5] = {1, 2, 3, 4, 5}
 * stack_var char isSorted
 *
 * isSorted = NAVArrayIsSortedAscendingInteger(values) // Returns true
 */
define_function char NAVArrayIsSortedAscendingInteger(integer array[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x < length; x++) {
        if (array[x] > array[x + 1]) {
            return false
        }
    }

    return true
}


/**
 * @function NAVArrayIsSortedDescendingString
 * @public
 * @description Checks if a string array is sorted in descending order.
 *
 * @param {char[][]} array - Array to check
 *
 * @returns {char} True if sorted, false otherwise
 *
 * @example
 * stack_var char names[3][20] = {'Charlie', 'Bob', 'Alice'}
 * stack_var char isSorted
 *
 * isSorted = NAVArrayIsSortedDescendingString(names) // Returns true
 */
define_function char NAVArrayIsSortedDescendingString(char array[][]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x < length; x++) {
        if (NAVStringCompare(array[x], array[x + 1]) < 0) {
            return false
        }
    }

    return true
}


/**
 * @function NAVArrayIsSortedDescendingInteger
 * @public
 * @description Checks if an integer array is sorted in descending order.
 *
 * @param {integer[]} array - Array to check
 *
 * @returns {char} True if sorted, false otherwise
 *
 * @example
 * stack_var integer values[5] = {5, 4, 3, 2, 1}
 * stack_var char isSorted
 *
 * isSorted = NAVArrayIsSortedDescendingInteger(values) // Returns true
 */
define_function char NAVArrayIsSortedDescendingInteger(integer array[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x < length; x++) {
        if (array[x] < array[x + 1]) {
            return false
        }
    }

    return true
}


/**
 * @function NAVArrayToLowerString
 * @public
 * @description Converts all strings in a string array to lowercase.
 *
 * @param {char[][]} array - Array to modify
 *
 * @returns {void}
 *
 * @example
 * stack_var char names[3][20] = {'Alice', 'Bob', 'Charlie'}
 * NAVArrayToLowerString(names) // names becomes {'alice', 'bob', 'charlie'}
 */
define_function NAVArrayToLowerString(char array[][]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = lower_string(array[x])
    }
}


/**
 * @function NAVArrayToUpperString
 * @public
 * @description Converts all strings in a string array to uppercase.
 *
 * @param {char[][]} array - Array to modify
 *
 * @returns {void}
 *
 * @example
 * stack_var char names[3][20] = {'Alice', 'Bob', 'Charlie'}
 * NAVArrayToUpperString(names) // names becomes {'ALICE', 'BOB', 'CHARLIE'}
 */
define_function NAVArrayToUpperString(char array[][]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = upper_string(array[x])
    }
}


/**
 * @function NAVArrayTrimString
 * @public
 * @description Trims whitespace from all strings in a string array.
 *
 * @param {char[][]} array - Array to modify
 *
 * @returns {void}
 *
 * @example
 * stack_var char names[3][20] = {' Alice ', ' Bob ', ' Charlie '}
 * NAVArrayTrimString(names) // names becomes {'Alice', 'Bob', 'Charlie'}
 */
define_function NAVArrayTrimString(char array[][]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        array[x] = NAVTrimString(array[x])
    }
}


/**
 * @function NAVArraySumInteger
 * @public
 * @description Calculates the sum of all elements in an integer array.
 *
 * @param {integer[]} array - Array to sum
 *
 * @returns {double} Sum of all elements
 *
 * @example
 * stack_var integer values[5] = {1, 2, 3, 4, 5}
 * stack_var double sum
 *
 * sum = NAVArraySumInteger(values) // Returns 15.0
 */
define_function double NAVArraySumInteger(integer array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum
}


/**
 * @function NAVArraySumSignedInteger
 * @public
 * @description Calculates the sum of all elements in a signed integer array.
 *
 * @param {sinteger[]} array - Array to sum
 *
 * @returns {double} Sum of all elements
 *
 * @example
 * stack_var sinteger values[5] = {-1, -2, -3, -4, -5}
 * stack_var double sum
 *
 * sum = NAVArraySumSignedInteger(values) // Returns -15.0
 */
define_function double NAVArraySumSignedInteger(sinteger array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum
}


/**
 * @function NAVArraySumLong
 * @public
 * @description Calculates the sum of all elements in a long array.
 *
 * @param {long[]} array - Array to sum
 *
 * @returns {double} Sum of all elements
 *
 * @example
 * stack_var long values[5] = {1, 2, 3, 4, 5}
 * stack_var double sum
 *
 * sum = NAVArraySumLong(values) // Returns 15.0
 */
define_function double NAVArraySumLong(long array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum
}


/**
 * @function NAVArraySumSignedLong
 * @public
 * @description Calculates the sum of all elements in a signed long array.
 *
 * @param {slong[]} array - Array to sum
 *
 * @returns {double} Sum of all elements
 *
 * @example
 * stack_var slong values[5] = {-1, -2, -3, -4, -5}
 * stack_var double sum
 *
 * sum = NAVArraySumSignedLong(values) // Returns -15.0
 */
define_function double NAVArraySumSignedLong(slong array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum
}


/**
 * @function NAVArraySumFloat
 * @public
 * @description Calculates the sum of all elements in a float array.
 *
 * @param {float[]} array - Array to sum
 *
 * @returns {double} Sum of all elements
 *
 * @example
 * stack_var float values[5] = {1.1, 2.2, 3.3, 4.4, 5.5}
 * stack_var double sum
 *
 * sum = NAVArraySumFloat(values) // Returns 16.5
 */
define_function double NAVArraySumFloat(float array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum
}


/**
 * @function NAVArraySumDouble
 * @public
 * @description Calculates the sum of all elements in a double array.
 *
 * @param {double[]} array - Array to sum
 *
 * @returns {double} Sum of all elements
 *
 * @example
 * stack_var double values[5] = {1.1, 2.2, 3.3, 4.4, 5.5}
 * stack_var double sum
 *
 * sum = NAVArraySumDouble(values) // Returns 16.5
 */
define_function double NAVArraySumDouble(double array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum
}


/**
 * @function NAVArrayAverageInteger
 * @public
 * @description Calculates the average of all elements in an integer array.
 *
 * @param {integer[]} array - Array to average
 *
 * @returns {double} Average of all elements
 *
 * @example
 * stack_var integer values[5] = {1, 2, 3, 4, 5}
 * stack_var double average
 *
 * average = NAVArrayAverageInteger(values) // Returns 3.0
 */
define_function double NAVArrayAverageInteger(integer array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum / length
}


/**
 * @function NAVArrayAverageSignedInteger
 * @public
 * @description Calculates the average of all elements in a signed integer array.
 *
 * @param {sinteger[]} array - Array to average
 *
 * @returns {double} Average of all elements
 *
 * @example
 * stack_var sinteger values[5] = {-1, -2, -3, -4, -5}
 * stack_var double average
 *
 * average = NAVArrayAverageSignedInteger(values) // Returns -3.0
 */
define_function double NAVArrayAverageSignedInteger(sinteger array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum / length
}


/**
 * @function NAVArrayAverageLong
 * @public
 * @description Calculates the average of all elements in a long array.
 *
 * @param {long[]} array - Array to average
 *
 * @returns {double} Average of all elements
 *
 * @example
 * stack_var long values[5] = {1, 2, 3, 4, 5}
 * stack_var double average
 *
 * average = NAVArrayAverageLong(values) // Returns 3.0
 */
define_function double NAVArrayAverageLong(long array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum / length
}


/**
 * @function NAVArrayAverageSignedLong
 * @public
 * @description Calculates the average of all elements in a signed long array.
 *
 * @param {slong[]} array - Array to average
 *
 * @returns {double} Average of all elements
 *
 * @example
 * stack_var slong values[5] = {-1, -2, -3, -4, -5}
 * stack_var double average
 *
 * average = NAVArrayAverageSignedLong(values) // Returns -3.0
 */
define_function double NAVArrayAverageSignedLong(slong array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum / length
}


/**
 * @function NAVArrayAverageFloat
 * @public
 * @description Calculates the average of all elements in a float array.
 *
 * @param {float[]} array - Array to average
 *
 * @returns {double} Average of all elements
 *
 * @example
 * stack_var float values[5] = {1.1, 2.2, 3.3, 4.4, 5.5}
 * stack_var double average
 *
 * average = NAVArrayAverageFloat(values) // Returns 3.3
 */
define_function double NAVArrayAverageFloat(float array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum / length
}


/**
 * @function NAVArrayAverageDouble
 * @public
 * @description Calculates the average of all elements in a double array.
 *
 * @param {double[]} array - Array to average
 *
 * @returns {double} Average of all elements
 *
 * @example
 * stack_var double values[5] = {1.1, 2.2, 3.3, 4.4, 5.5}
 * stack_var double average
 *
 * average = NAVArrayAverageDouble(values) // Returns 3.3
 */
define_function double NAVArrayAverageDouble(double array[]) {
    stack_var integer x
    stack_var integer length
    stack_var double sum

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        sum = sum + array[x]
    }

    return sum / length
}


/**
 * @function NAVArraySliceString
 * @public
 * @description Extracts a portion of a string array into a new array.
 *
 * @param {char[][]} array - Array to slice
 * @param {integer} start - Start index of the slice (1-based)
 * @param {integer} end - End index of the slice (1-based)
 * @param {char[][]} slice - Resulting slice array
 *
 * @returns {integer} Length of the resulting slice
 *
 * @example
 * stack_var char names[5][20] = {'Alice', 'Bob', 'Charlie', 'David', 'Eve'}
 * stack_var char slice[3][20]
 * stack_var integer sliceLength
 *
 * sliceLength = NAVArraySliceString(names, 2, 4, slice) // slice becomes {'Bob', 'Charlie', 'David'}
 */
define_function integer NAVArraySliceString(char array[][], integer start, integer end, char slice[][]) {
    stack_var integer x
    stack_var integer length
    stack_var integer sliceLength

    length = length_array(array)
    sliceLength = end - start + 1

    if (sliceLength < 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_ARRAYUTILS__,
                                    'NAVArraySliceString',
                                    "'Slice length must be greater than 0'")
        return sliceLength
    }

    set_length_array(slice, sliceLength)

    for (x = 1; x <= sliceLength; x++) {
        slice[x] = array[start]
        start++
    }

    return sliceLength
}


/**
 * @function NAVArraySliceInteger
 * @public
 * @description Extracts a portion of an integer array into a new array.
 *
 * @param {integer[]} array - Array to slice
 * @param {integer} start - Start index of the slice (1-based)
 * @param {integer} end - End index of the slice (1-based)
 * @param {integer[]} slice - Resulting slice array
 *
 * @returns {integer} Length of the resulting slice
 *
 * @example
 * stack_var integer values[5] = {1, 2, 3, 4, 5}
 * stack_var integer slice[3]
 * stack_var integer sliceLength
 *
 * sliceLength = NAVArraySliceInteger(values, 2, 4, slice) // slice becomes {2, 3, 4}
 */
define_function integer NAVArraySliceInteger(integer array[], integer start, integer end, integer slice[]) {
    stack_var integer x
    stack_var integer length
    stack_var integer sliceLength

    length = length_array(array)
    sliceLength = end - start + 1

    if (sliceLength < 1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_ARRAYUTILS__,
                                    'NAVArraySliceInteger',
                                    "'Slice length must be greater than 0'")
        return sliceLength
    }

    set_length_array(slice, sliceLength)

    for (x = 1; x <= sliceLength; x++) {
        slice[x] = array[start]
        start++
    }

    return sliceLength
}


/**
 * @function NAVArrayCharSetInit
 * @public
 * @description Initializes a char set with a specified capacity.
 *
 * @param {_NAVArrayCharSet} set - Set to initialize
 * @param {integer} capacity - Capacity of the set
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVArrayCharSet set
 * NAVArrayCharSetInit(set, 10) // Initializes set with capacity 10
 */
define_function NAVArrayCharSetInit(_NAVArrayCharSet set, integer capacity) {
    set.size = 0
    set.capacity = capacity

    set_length_array(set.free, capacity)
    set_length_array(set.data, capacity)

    NAVSetArrayChar(set.free, true)
    NAVSetArrayChar(set.data, 0)
}


/**
 * @function NAVArrayCharSetAdd
 * @public
 * @description Adds a value to a char set.
 *
 * @param {_NAVArrayCharSet} set - Set to add value to
 * @param {char} value - Value to add
 *
 * @returns {char} True if value was added, false if already in the set or set is full
 *
 * @example
 * stack_var _NAVArrayCharSet set
 * NAVArrayCharSetInit(set, 10)
 * NAVArrayCharSetAdd(set, 'A') // Adds 'A' to the set
 */
define_function char NAVArrayCharSetAdd(_NAVArrayCharSet set, char value) {
    stack_var integer index

    // Check if value already exists using NAVArrayCharSetFind
    index = NAVArrayCharSetFind(set, value)

    if (index > 0) {
        // Already in the set
        return false
    }

    if (set.size >= set.capacity) {
        // Set is full
        return false
    }

    set.size++

    // Get the first free index
    index = NAVFindInArrayChar(set.free, true)

    if (index == 0) {
        // No free index
        // Should never happen, but just in case
        return false
    }

    set.data[index] = value
    set.free[index] = false

    return true
}


/**
 * @function NAVArrayCharSetRemove
 * @public
 * @description Removes a value from a char set.
 *
 * @param {_NAVArrayCharSet} set - Set to remove value from
 * @param {char} value - Value to remove
 *
 * @returns {char} True if value was removed, false if not in the set
 *
 * @example
 * stack_var _NAVArrayCharSet set
 * NAVArrayCharSetInit(set, 10)
 * NAVArrayCharSetAdd(set, 'A')
 * NAVArrayCharSetRemove(set, 'A') // Removes 'A' from the set
 */
define_function char NAVArrayCharSetRemove(_NAVArrayCharSet set, char value) {
    stack_var integer index

    index = NAVArrayCharSetFind(set, value)

    if (index == 0) {
        // Not in the set
        return false
    }

    set.size--

    set.free[index] = true
    set.data[index] = 0

    return true
}


/**
 * @function NAVArrayCharSetFrom
 * @public
 * @description Initializes a char set from an array.
 *
 * @param {_NAVArrayCharSet} set - Set to initialize
 * @param {char[]} array - Array to initialize set from
 *
 * @returns {char} True if set was initialized, false if array is larger than set capacity
 *
 * @example
 * stack_var _NAVArrayCharSet set
 * stack_var char values[5] = {'A', 'B', 'C', 'D', 'E'}
 * NAVArrayCharSetInit(set, 10)
 * NAVArrayCharSetFrom(set, values) // Initializes set with values from array
 */
define_function char NAVArrayCharSetFrom(_NAVArrayCharSet set, char array[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    if (length > set.capacity) {
        return false
    }

    NAVArrayCharSetInit(set, set.capacity)

    for (x = 1; x <= length; x++) {
        NAVArrayCharSetAdd(set, array[x])
    }

    return true
}


/**
 * @function NAVArrayCharSetFind
 * @public
 * @description Finds the index of a value in a char set.
 *
 * @param {_NAVArrayCharSet} set - Set to search in
 * @param {char} value - Value to find
 *
 * @returns {integer} Index of the value (1-based), or 0 if not found
 *
 * @example
 * stack_var _NAVArrayCharSet set
 * NAVArrayCharSetInit(set, 10)
 * NAVArrayCharSetAdd(set, 'A')
 * stack_var integer index
 * index = NAVArrayCharSetFind(set, 'A') // Returns 1
 */
define_function integer NAVArrayCharSetFind(_NAVArrayCharSet set, char value) {
    stack_var integer x

    for (x = 1; x <= set.capacity; x++) {
        if (set.free[x]) {
            continue
        }

        if (set.data[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVArrayCharSetContains
 * @public
 * @description Checks if a char set contains a value.
 *
 * @param {_NAVArrayCharSet} set - Set to check
 * @param {char} value - Value to check for
 *
 * @returns {char} True if set contains the value, false otherwise
 *
 * @example
 * stack_var _NAVArrayCharSet set
 * NAVArrayCharSetInit(set, 10)
 * NAVArrayCharSetAdd(set, 'A')
 * stack_var char contains
 * contains = NAVArrayCharSetContains(set, 'A') // Returns true
 */
define_function char NAVArrayCharSetContains(_NAVArrayCharSet set, char value) {
    return NAVArrayCharSetFind(set, value) > 0
}


/**
 * @function NAVArrayIntegerSetInit
 * @public
 * @description Initializes an integer set with a specified capacity.
 *
 * @param {_NAVArrayIntegerSet} set - Set to initialize
 * @param {integer} capacity - Capacity of the set
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVArrayIntegerSet set
 * NAVArrayIntegerSetInit(set, 10) // Initializes set with capacity 10
 */
define_function NAVArrayIntegerSetInit(_NAVArrayIntegerSet set, integer capacity) {
    set.size = 0
    set.capacity = capacity

    set_length_array(set.free, capacity)
    set_length_array(set.data, capacity)

    NAVSetArrayChar(set.free, true)
    NAVSetArrayInteger(set.data, 0)
}


/**
 * @function NAVArrayIntegerSetAdd
 * @public
 * @description Adds a value to an integer set.
 *
 * @param {_NAVArrayIntegerSet} set - Set to add value to
 * @param {integer} value - Value to add
 *
 * @returns {char} True if value was added, false if already in the set or set is full
 *
 * @example
 * stack_var _NAVArrayIntegerSet set
 * NAVArrayIntegerSetInit(set, 10)
 * NAVArrayIntegerSetAdd(set, 42) // Adds 42 to the set
 */
define_function char NAVArrayIntegerSetAdd(_NAVArrayIntegerSet set, integer value) {
    stack_var integer index

    // Check if value already exists using NAVArrayIntegerSetFind
    index = NAVArrayIntegerSetFind(set, value)

    if (index > 0) {
        // Already in the set
        return false
    }

    if (set.size >= set.capacity) {
        // Set is full
        return false
    }

    set.size++

    // Get the first free index
    index = NAVFindInArrayChar(set.free, true)

    if (index == 0) {
        // No free index
        // Should never happen, but just in case
        return false
    }

    set.data[index] = value
    set.free[index] = false

    return true
}


/**
 * @function NAVArrayIntegerSetRemove
 * @public
 * @description Removes a value from an integer set.
 *
 * @param {_NAVArrayIntegerSet} set - Set to remove value from
 * @param {integer} value - Value to remove
 *
 * @returns {char} True if value was removed, false if not in the set
 *
 * @example
 * stack_var _NAVArrayIntegerSet set
 * NAVArrayIntegerSetInit(set, 10)
 * NAVArrayIntegerSetAdd(set, 42)
 * NAVArrayIntegerSetRemove(set, 42) // Removes 42 from the set
 */
define_function char NAVArrayIntegerSetRemove(_NAVArrayIntegerSet set, integer value) {
    stack_var integer index

    index = NAVArrayIntegerSetFind(set, value)

    if (index == 0) {
        // Not in the set
        return false
    }

    set.size--

    set.free[index] = true
    set.data[index] = 0

    return true
}


/**
 * @function NAVArrayIntegerSetFrom
 * @public
 * @description Initializes an integer set from an array.
 *
 * @param {_NAVArrayIntegerSet} set - Set to initialize
 * @param {integer[]} array - Array to initialize set from
 *
 * @returns {char} True if set was initialized, false if array is larger than set capacity
 *
 * @example
 * stack_var _NAVArrayIntegerSet set
 * stack_var integer values[5] = {1, 2, 3, 4, 5}
 * NAVArrayIntegerSetInit(set, 10)
 * NAVArrayIntegerSetFrom(set, values) // Initializes set with values from array
 */
define_function char NAVArrayIntegerSetFrom(_NAVArrayIntegerSet set, integer array[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    if (length > set.capacity) {
        return false
    }

    NAVArrayIntegerSetInit(set, set.capacity)

    for (x = 1; x <= length; x++) {
        NAVArrayIntegerSetAdd(set, array[x])
    }

    return true
}


/**
 * @function NAVArrayIntegerSetFind
 * @public
 * @description Finds the index of a value in an integer set.
 *
 * @param {_NAVArrayIntegerSet} set - Set to search in
 * @param {integer} value - Value to find
 *
 * @returns {integer} Index of the value (1-based), or 0 if not found
 *
 * @example
 * stack_var _NAVArrayIntegerSet set
 * NAVArrayIntegerSetInit(set, 10)
 * NAVArrayIntegerSetAdd(set, 42)
 * stack_var integer index
 * index = NAVArrayIntegerSetFind(set, 42) // Returns 1
 */
define_function integer NAVArrayIntegerSetFind(_NAVArrayIntegerSet set, integer value) {
    stack_var integer x

    for (x = 1; x <= set.capacity; x++) {
        if (set.free[x]) {
            continue
        }

        if (set.data[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVArrayIntegerSetContains
 * @public
 * @description Checks if an integer set contains a value.
 *
 * @param {_NAVArrayIntegerSet} set - Set to check
 * @param {integer} value - Value to check for
 *
 * @returns {char} True if set contains the value, false otherwise
 *
 * @example
 * stack_var _NAVArrayIntegerSet set
 * NAVArrayIntegerSetInit(set, 10)
 * NAVArrayIntegerSetAdd(set, 42)
 * stack_var char contains
 * contains = NAVArrayIntegerSetContains(set, 42) // Returns true
 */
define_function char NAVArrayIntegerSetContains(_NAVArrayIntegerSet set, integer value) {
    return NAVArrayIntegerSetFind(set, value) > 0
}


/**
 * @function NAVArraySignedIntegerSetInit
 * @public
 * @description Initializes a signed integer set with a specified capacity.
 *
 * @param {_NAVArraySignedIntegerSet} set - Set to initialize
 * @param {integer} capacity - Capacity of the set
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVArraySignedIntegerSet set
 * NAVArraySignedIntegerSetInit(set, 10) // Initializes set with capacity 10
 */
define_function NAVArraySignedIntegerSetInit(_NAVArraySignedIntegerSet set, integer capacity) {
    set.size = 0
    set.capacity = capacity

    set_length_array(set.free, capacity)
    set_length_array(set.data, capacity)

    NAVSetArrayChar(set.free, true)
    NAVSetArraySignedInteger(set.data, 0)
}


/**
 * @function NAVArraySignedIntegerSetAdd
 * @public
 * @description Adds a value to a signed integer set.
 *
 * @param {_NAVArraySignedIntegerSet} set - Set to add value to
 * @param {sinteger} value - Value to add
 *
 * @returns {char} True if value was added, false if already in the set or set is full
 *
 * @example
 * stack_var _NAVArraySignedIntegerSet set
 * NAVArraySignedIntegerSetInit(set, 10)
 * NAVArraySignedIntegerSetAdd(set, -42) // Adds -42 to the set
 */
define_function char NAVArraySignedIntegerSetAdd(_NAVArraySignedIntegerSet set, sinteger value) {
    stack_var integer index

    index = NAVFindInArraySinteger(set.data, value)

    if (index && !set.free[index]) {
        // Already in the set
        return false
    }

    if (set.size >= set.capacity) {
        // Set is full
        return false
    }

    set.size++

    // Get the first free index
    index = NAVFindInArrayChar(set.free, true)

    if (!index) {
        // No free index
        // Should never happen, but just in case
        return false
    }

    set.data[index] = value
    set.free[index] = false

    return true
}


/**
 * @function NAVArraySignedIntegerSetRemove
 * @public
 * @description Removes a value from a signed integer set.
 *
 * @param {_NAVArraySignedIntegerSet} set - Set to remove value from
 * @param {sinteger} value - Value to remove
 *
 * @returns {char} True if value was removed, false if not in the set
 *
 * @example
 * stack_var _NAVArraySignedIntegerSet set
 * NAVArraySignedIntegerSetInit(set, 10)
 * NAVArraySignedIntegerSetAdd(set, -42)
 * NAVArraySignedIntegerSetRemove(set, -42) // Removes -42 from the set
 */
define_function char NAVArraySignedIntegerSetRemove(_NAVArraySignedIntegerSet set, sinteger value) {
    stack_var integer index

    index = NAVFindInArraySinteger(set.data, value)

    if (!index || (index && set.free[index])) {
        // Not in the set
        return false
    }

    set.size--

    set.free[index] = true
    set.data[index] = 0

    return true
}


/**
 * @function NAVArraySignedIntegerSetFrom
 * @public
 * @description Initializes a signed integer set from an array.
 *
 * @param {_NAVArraySignedIntegerSet} set - Set to initialize
 * @param {sinteger[]} array - Array to initialize set from
 *
 * @returns {char} True if set was initialized, false if array is larger than set capacity
 *
 * @example
 * stack_var _NAVArraySignedIntegerSet set
 * stack_var sinteger values[5] = {-1, -2, -3, -4, -5}
 * NAVArraySignedIntegerSetInit(set, 10)
 * NAVArraySignedIntegerSetFrom(set, values) // Initializes set with values from array
 */
define_function char NAVArraySignedIntegerSetFrom(_NAVArraySignedIntegerSet set, sinteger array[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    if (length > set.capacity) {
        return false
    }

    NAVArraySignedIntegerSetInit(set, set.capacity)

    for (x = 1; x <= length; x++) {
        NAVArraySignedIntegerSetAdd(set, array[x])
    }

    return true
}


/**
 * @function NAVArraySignedIntegerSetFind
 * @public
 * @description Finds the index of a value in a signed integer set.
 *
 * @param {_NAVArraySignedIntegerSet} set - Set to search in
 * @param {sinteger} value - Value to find
 *
 * @returns {integer} Index of the value (1-based), or 0 if not found
 *
 * @example
 * stack_var _NAVArraySignedIntegerSet set
 * NAVArraySignedIntegerSetInit(set, 10)
 * NAVArraySignedIntegerSetAdd(set, -42)
 * stack_var integer index
 * index = NAVArraySignedIntegerSetFind(set, -42) // Returns 1
 */
define_function integer NAVArraySignedIntegerSetFind(_NAVArraySignedIntegerSet set, sinteger value) {
    stack_var integer x

    for (x = 1; x <= set.capacity; x++) {
        if (set.free[x]) {
            continue
        }

        if (set.data[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVArraySignedIntegerSetContains
 * @public
 * @description Checks if a signed integer set contains a value.
 *
 * @param {_NAVArraySignedIntegerSet} set - Set to check
 * @param {sinteger} value - Value to check for
 *
 * @returns {char} True if set contains the value, false otherwise
 *
 * @example
 * stack_var _NAVArraySignedIntegerSet set
 * NAVArraySignedIntegerSetInit(set, 10)
 * NAVArraySignedIntegerSetAdd(set, -42)
 * stack_var char contains
 * contains = NAVArraySignedIntegerSetContains(set, -42) // Returns true
 */
define_function char NAVArraySignedIntegerSetContains(_NAVArraySignedIntegerSet set, sinteger value) {
    return NAVArraySignedIntegerSetFind(set, value) > 0
}


/**
 * @function NAVArrayLongSetInit
 * @public
 * @description Initializes a long set with a specified capacity.
 *
 * @param {_NAVArrayLongSet} set - Set to initialize
 * @param {integer} capacity - Capacity of the set
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVArrayLongSet set
 * NAVArrayLongSetInit(set, 10) // Initializes set with capacity 10
 */
define_function NAVArrayLongSetInit(_NAVArrayLongSet set, integer capacity) {
    set.size = 0
    set.capacity = capacity

    set_length_array(set.free, capacity)
    set_length_array(set.data, capacity)

    NAVSetArrayChar(set.free, true)
    NAVSetArrayLong(set.data, 0)
}


/**
 * @function NAVArrayLongSetAdd
 * @public
 * @description Adds a value to a long set.
 *
 * @param {_NAVArrayLongSet} set - Set to add value to
 * @param {long} value - Value to add
 *
 * @returns {char} True if value was added, false if already in the set or set is full
 *
 * @example
 * stack_var _NAVArrayLongSet set
 * NAVArrayLongSetInit(set, 10)
 * NAVArrayLongSetAdd(set, $FFFFFFFF) // Adds $FFFFFFFF to the set
 */
define_function char NAVArrayLongSetAdd(_NAVArrayLongSet set, long value) {
    stack_var integer index

    index = NAVFindInArrayLong(set.data, value)

    if (index && !set.free[index]) {
        // Already in the set
        return false
    }

    if (set.size >= set.capacity) {
        // Set is full
        return false
    }

    set.size++

    // Get the first free index
    index = NAVFindInArrayChar(set.free, true)

    if (!index) {
        // No free index
        // Should never happen, but just in case
        return false
    }

    set.data[index] = value
    set.free[index] = false

    return true
}


/**
 * @function NAVArrayLongSetRemove
 * @public
 * @description Removes a value from a long set.
 *
 * @param {_NAVArrayLongSet} set - Set to remove value from
 * @param {long} value - Value to remove
 *
 * @returns {char} True if value was removed, false if not in the set
 *
 * @example
 * stack_var _NAVArrayLongSet set
 * NAVArrayLongSetInit(set, 10)
 * NAVArrayLongSetAdd(set, $FFFFFFFF)
 * NAVArrayLongSetRemove(set, $FFFFFFFF) // Removes $FFFFFFFF from the set
 */
define_function char NAVArrayLongSetRemove(_NAVArrayLongSet set, long value) {
    stack_var integer index

    index = NAVFindInArrayLong(set.data, value)

    if (!index || (index && set.free[index])) {
        // Not in the set
        return false
    }

    set.size--

    set.free[index] = true
    set.data[index] = 0

    return true
}


/**
 * @function NAVArrayLongSetFrom
 * @public
 * @description Initializes a long set from an array.
 *
 * @param {_NAVArrayLongSet} set - Set to initialize
 * @param {long[]} array - Array to initialize set from
 *
 * @returns {char} True if set was initialized, false if array is larger than set capacity
 *
 * @example
 * stack_var _NAVArrayLongSet set
 * stack_var long values[5] = {1, 2, 3, 4, 5}
 * NAVArrayLongSetInit(set, 10)
 * NAVArrayLongSetFrom(set, values) // Initializes set with values from array
 */
define_function char NAVArrayLongSetFrom(_NAVArrayLongSet set, long array[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    if (length > set.capacity) {
        return false
    }

    NAVArrayLongSetInit(set, set.capacity)

    for (x = 1; x <= length; x++) {
        NAVArrayLongSetAdd(set, array[x])
    }

    return true
}


/**
 * @function NAVArrayLongSetFind
 * @public
 * @description Finds the index of a value in a long set.
 *
 * @param {_NAVArrayLongSet} set - Set to search in
 * @param {long} value - Value to find
 *
 * @returns {integer} Index of the value (1-based), or 0 if not found
 *
 * @example
 * stack_var _NAVArrayLongSet set
 * NAVArrayLongSetInit(set, 10)
 * NAVArrayLongSetAdd(set, $FFFFFFFF)
 * stack_var integer index
 * index = NAVArrayLongSetFind(set, $FFFFFFFF) // Returns 1
 */
define_function integer NAVArrayLongSetFind(_NAVArrayLongSet set, long value) {
    stack_var integer x

    for (x = 1; x <= set.capacity; x++) {
        if (set.free[x]) {
            continue
        }

        if (set.data[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVArrayLongSetContains
 * @public
 * @description Checks if a long set contains a value.
 *
 * @param {_NAVArrayLongSet} set - Set to check
 * @param {long} value - Value to check for
 *
 * @returns {char} True if set contains the value, false otherwise
 *
 * @example
 * stack_var _NAVArrayLongSet set
 * NAVArrayLongSetInit(set, 10)
 * NAVArrayLongSetAdd(set, $FFFFFFFF)
 * stack_var char contains
 * contains = NAVArrayLongSetContains(set, $FFFFFFFF) // Returns true
 */
define_function char NAVArrayLongSetContains(_NAVArrayLongSet set, long value) {
    return NAVArrayLongSetFind(set, value) > 0
}


/**
 * @function NAVArraySignedLongSetInit
 * @public
 * @description Initializes a signed long set with a specified capacity.
 *
 * @param {_NAVArraySignedLongSet} set - Set to initialize
 * @param {integer} capacity - Capacity of the set
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVArraySignedLongSet set
 * NAVArraySignedLongSetInit(set, 10) // Initializes set with capacity 10
 */
define_function NAVArraySignedLongSetInit(_NAVArraySignedLongSet set, integer capacity) {
    set.size = 0
    set.capacity = capacity

    set_length_array(set.free, capacity)
    set_length_array(set.data, capacity)

    NAVSetArrayChar(set.free, true)
    NAVSetArraySignedLong(set.data, 0)
}


/**
 * @function NAVArraySignedLongSetAdd
 * @public
 * @description Adds a value to a signed long set.
 *
 * @param {_NAVArraySignedLongSet} set - Set to add value to
 * @param {slong} value - Value to add
 *
 * @returns {char} True if value was added, false if already in the set or set is full
 *
 * @example
 * stack_var _NAVArraySignedLongSet set
 * NAVArraySignedLongSetInit(set, 10)
 * NAVArraySignedLongSetAdd(set, -100000) // Adds -100000 to the set
 */
define_function char NAVArraySignedLongSetAdd(_NAVArraySignedLongSet set, slong value) {
    stack_var integer index

    index = NAVFindInArraySlong(set.data, value)

    if (index && !set.free[index]) {
        // Already in the set
        return false
    }

    if (set.size >= set.capacity) {
        // Set is full
        return false
    }

    set.size++

    // Get the first free index
    index = NAVFindInArrayChar(set.free, true)

    if (!index) {
        // No free index
        // Should never happen, but just in case
        return false
    }

    set.data[index] = value
    set.free[index] = false

    return true
}


/**
 * @function NAVArraySignedLongSetRemove
 * @public
 * @description Removes a value from a signed long set.
 *
 * @param {_NAVArraySignedLongSet} set - Set to remove value from
 * @param {slong} value - Value to remove
 *
 * @returns {char} True if value was removed, false if not in the set
 *
 * @example
 * stack_var _NAVArraySignedLongSet set
 * NAVArraySignedLongSetInit(set, 10)
 * NAVArraySignedLongSetAdd(set, -100000)
 * NAVArraySignedLongSetRemove(set, -100000) // Removes -100000 from the set
 */
define_function char NAVArraySignedLongSetRemove(_NAVArraySignedLongSet set, slong value) {
    stack_var integer index

    index = NAVFindInArraySlong(set.data, value)

    if (!index || (index && set.free[index])) {
        // Not in the set
        return false
    }

    set.size--

    set.free[index] = true
    set.data[index] = 0

    return true
}


/**
 * @function NAVArraySignedLongSetFrom
 * @public
 * @description Initializes a signed long set from an array.
 *
 * @param {_NAVArraySignedLongSet} set - Set to initialize
 * @param {slong[]} array - Array to initialize set from
 *
 * @returns {char} True if set was initialized, false if array is larger than set capacity
 *
 * @example
 * stack_var _NAVArraySignedLongSet set
 * stack_var slong values[5] = {-1, -2, -3, -4, -5}
 * NAVArraySignedLongSetInit(set, 10)
 * NAVArraySignedLongSetFrom(set, values) // Initializes set with values from array
 */
define_function char NAVArraySignedLongSetFrom(_NAVArraySignedLongSet set, slong array[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    if (length > set.capacity) {
        return false
    }

    NAVArraySignedLongSetInit(set, set.capacity)

    for (x = 1; x <= length; x++) {
        NAVArraySignedLongSetAdd(set, array[x])
    }

    return true
}


/**
 * @function NAVArraySignedLongSetFind
 * @public
 * @description Finds the index of a value in a signed long set.
 *
 * @param {_NAVArraySignedLongSet} set - Set to search in
 * @param {slong} value - Value to find
 *
 * @returns {integer} Index of the value (1-based), or 0 if not found
 *
 * @example
 * stack_var _NAVArraySignedLongSet set
 * NAVArraySignedLongSetInit(set, 10)
 * NAVArraySignedLongSetAdd(set, -100000)
 * stack_var integer index
 * index = NAVArraySignedLongSetFind(set, -100000) // Returns 1
 */
define_function integer NAVArraySignedLongSetFind(_NAVArraySignedLongSet set, slong value) {
    stack_var integer x

    for (x = 1; x <= set.capacity; x++) {
        if (set.free[x]) {
            continue
        }

        if (set.data[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVArraySignedLongSetContains
 * @public
 * @description Checks if a signed long set contains a value.
 *
 * @param {_NAVArraySignedLongSet} set - Set to check
 * @param {slong} value - Value to check for
 *
 * @returns {char} True if set contains the value, false otherwise
 *
 * @example
 * stack_var _NAVArraySignedLongSet set
 * NAVArraySignedLongSetInit(set, 10)
 * NAVArraySignedLongSetAdd(set, -100000)
 * stack_var char contains
 * contains = NAVArraySignedLongSetContains(set, -100000) // Returns true
 */
define_function char NAVArraySignedLongSetContains(_NAVArraySignedLongSet set, slong value) {
    return NAVArraySignedLongSetFind(set, value) > 0
}


/**
 * @function NAVArrayFloatSetInit
 * @public
 * @description Initializes a float set with a specified capacity.
 *
 * @param {_NAVArrayFloatSet} set - Set to initialize
 * @param {integer} capacity - Capacity of the set
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVArrayFloatSet set
 * NAVArrayFloatSetInit(set, 10) // Initializes set with capacity 10
 */
define_function NAVArrayFloatSetInit(_NAVArrayFloatSet set, integer capacity) {
    set.size = 0
    set.capacity = capacity

    set_length_array(set.free, capacity)
    set_length_array(set.data, capacity)

    NAVSetArrayChar(set.free, true)
    NAVSetArrayFloat(set.data, 0)
}


/**
 * @function NAVArrayFloatSetAdd
 * @public
 * @description Adds a value to a float set.
 *
 * @param {_NAVArrayFloatSet} set - Set to add value to
 * @param {float} value - Value to add
 *
 * @returns {char} True if value was added, false if already in the set or set is full
 *
 * @example
 * stack_var _NAVArrayFloatSet set
 * NAVArrayFloatSetInit(set, 10)
 * NAVArrayFloatSetAdd(set, 3.14) // Adds 3.14 to the set
 */
define_function char NAVArrayFloatSetAdd(_NAVArrayFloatSet set, float value) {
    stack_var integer index

    index = NAVFindInArrayFloat(set.data, value)

    if (index && !set.free[index]) {
        // Already in the set
        return false
    }

    if (set.size >= set.capacity) {
        // Set is full
        return false
    }

    set.size++

    // Get the first free index
    index = NAVFindInArrayChar(set.free, true)

    if (!index) {
        // No free index
        // Should never happen, but just in case
        return false
    }

    set.data[index] = value
    set.free[index] = false

    return true
}


/**
 * @function NAVArrayFloatSetRemove
 * @public
 * @description Removes a value from a float set.
 *
 * @param {_NAVArrayFloatSet} set - Set to remove value from
 * @param {float} value - Value to remove
 *
 * @returns {char} True if value was removed, false if not in the set
 *
 * @example
 * stack_var _NAVArrayFloatSet set
 * NAVArrayFloatSetInit(set, 10)
 * NAVArrayFloatSetAdd(set, 3.14)
 * NAVArrayFloatSetRemove(set, 3.14) // Removes 3.14 from the set
 */
define_function char NAVArrayFloatSetRemove(_NAVArrayFloatSet set, float value) {
    stack_var integer index

    index = NAVFindInArrayFloat(set.data, value)

    if (!index || (index && set.free[index])) {
        // Not in the set
        return false
    }

    set.size--

    set.free[index] = true
    set.data[index] = 0

    return true
}


/**
 * @function NAVArrayFloatSetFrom
 * @public
 * @description Initializes a float set from an array.
 *
 * @param {_NAVArrayFloatSet} set - Set to initialize
 * @param {float[]} array - Array to initialize set from
 *
 * @returns {char} True if set was initialized, false if array is larger than set capacity
 *
 * @example
 * stack_var _NAVArrayFloatSet set
 * stack_var float values[5] = {1.1, 2.2, 3.3, 4.4, 5.5}
 * NAVArrayFloatSetInit(set, 10)
 * NAVArrayFloatSetFrom(set, values) // Initializes set with values from array
 */
define_function char NAVArrayFloatSetFrom(_NAVArrayFloatSet set, float array[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    if (length > set.capacity) {
        return false
    }

    NAVArrayFloatSetInit(set, set.capacity)

    for (x = 1; x <= length; x++) {
        NAVArrayFloatSetAdd(set, array[x])
    }

    return true
}


/**
 * @function NAVArrayFloatSetFind
 * @public
 * @description Finds the index of a value in a float set.
 *
 * @param {_NAVArrayFloatSet} set - Set to search in
 * @param {float} value - Value to find
 *
 * @returns {integer} Index of the value (1-based), or 0 if not found
 *
 * @example
 * stack_var _NAVArrayFloatSet set
 * NAVArrayFloatSetInit(set, 10)
 * NAVArrayFloatSetAdd(set, 3.14)
 * stack_var integer index
 * index = NAVArrayFloatSetFind(set, 3.14) // Returns 1
 */
define_function integer NAVArrayFloatSetFind(_NAVArrayFloatSet set, float value) {
    stack_var integer x

    for (x = 1; x <= set.capacity; x++) {
        if (set.free[x]) {
            continue
        }

        if (set.data[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVArrayFloatSetContains
 * @public
 * @description Checks if a float set contains a value.
 *
 * @param {_NAVArrayFloatSet} set - Set to check
 * @param {float} value - Value to check for
 *
 * @returns {char} True if set contains the value, false otherwise
 *
 * @example
 * stack_var _NAVArrayFloatSet set
 * NAVArrayFloatSetInit(set, 10)
 * NAVArrayFloatSetAdd(set, 3.14)
 * stack_var char contains
 * contains = NAVArrayFloatSetContains(set, 3.14) // Returns true
 */
define_function char NAVArrayFloatSetContains(_NAVArrayFloatSet set, float value) {
    return NAVArrayFloatSetFind(set, value) > 0
}


/**
 * @function NAVArrayDoubleSetInit
 * @public
 * @description Initializes a double set with a specified capacity.
 *
 * @param {_NAVArrayDoubleSet} set - Set to initialize
 * @param {integer} capacity - Capacity of the set
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVArrayDoubleSet set
 * NAVArrayDoubleSetInit(set, 10) // Initializes set with capacity 10
 */
define_function NAVArrayDoubleSetInit(_NAVArrayDoubleSet set, integer capacity) {
    set.size = 0
    set.capacity = capacity

    set_length_array(set.free, capacity)
    set_length_array(set.data, capacity)

    NAVSetArrayChar(set.free, true)
    NAVSetArrayDouble(set.data, 0)
}


/**
 * @function NAVArrayDoubleSetAdd
 * @public
 * @description Adds a value to a double set.
 *
 * @param {_NAVArrayDoubleSet} set - Set to add value to
 * @param {double} value - Value to add
 *
 * @returns {char} True if value was added, false if already in the set or set is full
 *
 * @example
 * stack_var _NAVArrayDoubleSet set
 * NAVArrayDoubleSetInit(set, 10)
 * NAVArrayDoubleSetAdd(set, 3.14159) // Adds 3.14159 to the set
 */
define_function char NAVArrayDoubleSetAdd(_NAVArrayDoubleSet set, double value) {
    stack_var integer index

    index = NAVFindInArrayDouble(set.data, value)

    if (index && !set.free[index]) {
        // Already in the set
        return false
    }

    if (set.size >= set.capacity) {
        // Set is full
        return false
    }

    set.size++

    // Get the first free index
    index = NAVFindInArrayChar(set.free, true)

    if (!index) {
        // No free index
        // Should never happen, but just in case
        return false
    }

    set.data[index] = value
    set.free[index] = false

    return true
}


/**
 * @function NAVArrayDoubleSetRemove
 * @public
 * @description Removes a value from a double set.
 *
 * @param {_NAVArrayDoubleSet} set - Set to remove value from
 * @param {double} value - Value to remove
 *
 * @returns {char} True if value was removed, false if not in the set
 *
 * @example
 * stack_var _NAVArrayDoubleSet set
 * NAVArrayDoubleSetInit(set, 10)
 * NAVArrayDoubleSetAdd(set, 3.14159)
 * NAVArrayDoubleSetRemove(set, 3.14159) // Removes 3.14159 from the set
 */
define_function char NAVArrayDoubleSetRemove(_NAVArrayDoubleSet set, double value) {
    stack_var integer index

    index = NAVFindInArrayDouble(set.data, value)

    if (!index || (index && set.free[index])) {
        // Not in the set
        return false
    }

    set.size--

    set.free[index] = true
    set.data[index] = 0

    return true
}


/**
 * @function NAVArrayDoubleSetFrom
 * @public
 * @description Initializes a double set from an array.
 *
 * @param {_NAVArrayDoubleSet} set - Set to initialize
 * @param {double[]} array - Array to initialize set from
 *
 * @returns {char} True if set was initialized, false if array is larger than set capacity
 *
 * @example
 * stack_var _NAVArrayDoubleSet set
 * stack_var double values[5] = {1.1, 2.2, 3.3, 4.4, 5.5}
 * NAVArrayDoubleSetInit(set, 10)
 * NAVArrayDoubleSetFrom(set, values) // Initializes set with values from array
 */
define_function char NAVArrayDoubleSetFrom(_NAVArrayDoubleSet set, double array[]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    if (length > set.capacity) {
        return false
    }

    NAVArrayDoubleSetInit(set, set.capacity)

    for (x = 1; x <= length; x++) {
        NAVArrayDoubleSetAdd(set, array[x])
    }

    return true
}


/**
 * @function NAVArrayDoubleSetFind
 * @public
 * @description Finds the index of a value in a double set.
 *
 * @param {_NAVArrayDoubleSet} set - Set to search in
 * @param {double} value - Value to find
 *
 * @returns {integer} Index of the value (1-based), or 0 if not found
 *
 * @example
 * stack_var _NAVArrayDoubleSet set
 * NAVArrayDoubleSetInit(set, 10)
 * NAVArrayDoubleSetAdd(set, 3.14159)
 * stack_var integer index
 * index = NAVArrayDoubleSetFind(set, 3.14159) // Returns 1
 */
define_function integer NAVArrayDoubleSetFind(_NAVArrayDoubleSet set, double value) {
    stack_var integer x

    for (x = 1; x <= set.capacity; x++) {
        if (set.free[x]) {
            continue
        }

        if (set.data[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVArrayDoubleSetContains
 * @public
 * @description Checks if a double set contains a value.
 *
 * @param {_NAVArrayDoubleSet} set - Set to check
 * @param {double} value - Value to check for
 *
 * @returns {char} True if set contains the value, false otherwise
 *
 * @example
 * stack_var _NAVArrayDoubleSet set
 * NAVArrayDoubleSetInit(set, 10)
 * NAVArrayDoubleSetAdd(set, 3.14159)
 * stack_var char contains
 * contains = NAVArrayDoubleSetContains(set, 3.14159) // Returns true
 */
define_function char NAVArrayDoubleSetContains(_NAVArrayDoubleSet set, double value) {
    return NAVArrayDoubleSetFind(set, value) > 0
}


/**
 * @function NAVArrayStringSetInit
 * @public
 * @description Initializes a string set with a specified capacity.
 *
 * @param {_NAVArrayStringSet} set - Set to initialize
 * @param {integer} capacity - Capacity of the set
 *
 * @returns {void}
 *
 * @example
 * stack_var _NAVArrayStringSet set
 * NAVArrayStringSetInit(set, 10) // Initializes set with capacity 10
 */
define_function NAVArrayStringSetInit(_NAVArrayStringSet set, integer capacity) {
    set.size = 0
    set.capacity = capacity

    set_length_array(set.free, capacity)
    set_length_array(set.data, capacity)

    NAVSetArrayChar(set.free, true)
    NAVSetArrayString(set.data, "")
}


/**
 * @function NAVArrayStringSetAdd
 * @public
 * @description Adds a value to a string set.
 *
 * @param {_NAVArrayStringSet} set - Set to add value to
 * @param {char[]} value - Value to add
 *
 * @returns {char} True if value was added, false if already in the set or set is full
 *
 * @example
 * stack_var _NAVArrayStringSet set
 * NAVArrayStringSetInit(set, 10)
 * NAVArrayStringSetAdd(set, 'Hello') // Adds 'Hello' to the set
 */
define_function char NAVArrayStringSetAdd(_NAVArrayStringSet set, char value[]) {
    stack_var integer index

    index = NAVFindInArrayString(set.data, value)

    if (index && !set.free[index]) {
        // Already in the set
        return false
    }

    if (set.size >= set.capacity) {
        // Set is full
        return false
    }

    set.size++

    // Get the first free index
    index = NAVFindInArrayChar(set.free, true)

    if (!index) {
        // No free index
        // Should never happen, but just in case
        return false
    }

    set.data[index] = value
    set.free[index] = false

    return true
}


/**
 * @function NAVArrayStringSetRemove
 * @public
 * @description Removes a value from a string set.
 *
 * @param {_NAVArrayStringSet} set - Set to remove value from
 * @param {char[]} value - Value to remove
 *
 * @returns {char} True if value was removed, false if not in the set
 *
 * @example
 * stack_var _NAVArrayStringSet set
 * NAVArrayStringSetInit(set, 10)
 * NAVArrayStringSetAdd(set, 'Hello')
 * NAVArrayStringSetRemove(set, 'Hello') // Removes 'Hello' from the set
 */
define_function char NAVArrayStringSetRemove(_NAVArrayStringSet set, char value[]) {
    stack_var integer index

    index = NAVFindInArrayString(set.data, value)

    if (!index || (index && set.free[index])) {
        // Not in the set
        return false
    }

    set.size--

    set.free[index] = true
    set.data[index] = ""

    return true
}


/**
 * @function NAVArrayStringSetFrom
 * @public
 * @description Initializes a string set from an array.
 *
 * @param {_NAVArrayStringSet} set - Set to initialize
 * @param {char[][]} array - Array to initialize set from
 *
 * @returns {char} True if set was initialized, false if array is larger than set capacity
 *
 * @example
 * stack_var _NAVArrayStringSet set
 * stack_var char values[5][20] = {'Alice', 'Bob', 'Charlie', 'David', 'Eve'}
 * NAVArrayStringSetInit(set, 10)
 * NAVArrayStringSetFrom(set, values) // Initializes set with values from array
 */
define_function char NAVArrayStringSetFrom(_NAVArrayStringSet set, char array[][]) {
    stack_var integer x
    stack_var integer length

    length = length_array(array)

    if (length > set.capacity) {
        return false
    }

    NAVArrayStringSetInit(set, set.capacity)

    for (x = 1; x <= length; x++) {
        NAVArrayStringSetAdd(set, array[x])
    }

    return true
}


/**
 * @function NAVArrayStringSetFind
 * @public
 * @description Finds the index of a value in a string set.
 *
 * @param {_NAVArrayStringSet} set - Set to search in
 * @param {char[]} value - Value to find
 *
 * @returns {integer} Index of the value (1-based), or 0 if not found
 *
 * @example
 * stack_var _NAVArrayStringSet set
 * NAVArrayStringSetInit(set, 10)
 * NAVArrayStringSetAdd(set, 'Hello')
 * stack_var integer index
 * index = NAVArrayStringSetFind(set, 'Hello') // Returns 1
 */
define_function integer NAVArrayStringSetFind(_NAVArrayStringSet set, char value[]) {
    stack_var integer x

    for (x = 1; x <= set.capacity; x++) {
        if (set.free[x]) {
            continue
        }

        if (set.data[x] == value) {
            return x
        }
    }

    return 0
}


/**
 * @function NAVArrayStringSetContains
 * @public
 * @description Checks if a string set contains a value.
 *
 * @param {_NAVArrayStringSet} set - Set to check
 * @param {char[]} value - Value to check for
 *
 * @returns {char} True if set contains the value, false otherwise
 *
 * @example
 * stack_var _NAVArrayStringSet set
 * NAVArrayStringSetInit(set, 10)
 * NAVArrayStringSetAdd(set, 'Hello')
 * stack_var char contains
 * contains = NAVArrayStringSetContains(set, 'Hello') // Returns true
 */
define_function char NAVArrayStringSetContains(_NAVArrayStringSet set, char value[]) {
    return NAVArrayStringSetFind(set, value) > 0
}


#END_IF // __NAV_FOUNDATION_ARRAYUTILS__
