PROGRAM_NAME='NAVFoundation.ArrayUtils.h'

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


#IF_NOT_DEFINED __NAV_FOUNDATION_ARRAYUTILS_H__
#DEFINE __NAV_FOUNDATION_ARRAYUTILS_H__ 'NAVFoundation.ArrayUtils.h'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

/**
 * @constant NAV_MAX_ARRAY_SET_SIZE
 * @description Maximum capacity for array set collections.
 * This limits the number of elements that can be stored in any array set.
 */
#IF_NOT_DEFINED NAV_MAX_ARRAY_SET_SIZE
constant integer NAV_MAX_ARRAY_SET_SIZE = 255
#END_IF


DEFINE_TYPE

/**
 * @struct _NAVArrayCharSet
 * @description A set data structure for char values that prevents duplicates.
 *
 * @property {integer} size - Current number of elements in the set
 * @property {integer} capacity - Maximum number of elements the set can hold
 * @property {char[]} free - Tracks which slots are available (true) or occupied (false)
 * @property {char[]} data - The actual stored values
 *
 * @example
 * stack_var _NAVArrayCharSet charSet
 * NAVArrayCharSetInit(charSet, 10)
 * NAVArrayCharSetAdd(charSet, 'A')
 * NAVArrayCharSetAdd(charSet, 'B')
 *
 * @see NAVArrayCharSetInit
 * @see NAVArrayCharSetAdd
 */
struct _NAVArrayCharSet {
    integer size
    integer capacity

    char free[NAV_MAX_ARRAY_SET_SIZE]
    char data[NAV_MAX_ARRAY_SET_SIZE]
}


/**
 * @struct _NAVArrayIntegerSet
 * @description A set data structure for integer values that prevents duplicates.
 *
 * @property {integer} size - Current number of elements in the set
 * @property {integer} capacity - Maximum number of elements the set can hold
 * @property {char[]} free - Tracks which slots are available (true) or occupied (false)
 * @property {integer[]} data - The actual stored values
 *
 * @example
 * stack_var _NAVArrayIntegerSet intSet
 * NAVArrayIntegerSetInit(intSet, 10)
 * NAVArrayIntegerSetAdd(intSet, 42)
 * NAVArrayIntegerSetAdd(intSet, 100)
 *
 * @see NAVArrayIntegerSetInit
 * @see NAVArrayIntegerSetAdd
 */
struct _NAVArrayIntegerSet {
    integer size
    integer capacity

    char free[NAV_MAX_ARRAY_SET_SIZE]
    integer data[NAV_MAX_ARRAY_SET_SIZE]
}


/**
 * @struct _NAVArraySignedIntegerSet
 * @description A set data structure for signed integer values that prevents duplicates.
 *
 * @property {integer} size - Current number of elements in the set
 * @property {integer} capacity - Maximum number of elements the set can hold
 * @property {char[]} free - Tracks which slots are available (true) or occupied (false)
 * @property {sinteger[]} data - The actual stored values
 *
 * @example
 * stack_var _NAVArraySignedIntegerSet sintSet
 * NAVArraySignedIntegerSetInit(sintSet, 10)
 * NAVArraySignedIntegerSetAdd(sintSet, -42)
 * NAVArraySignedIntegerSetAdd(sintSet, 100)
 *
 * @see NAVArraySignedIntegerSetInit
 * @see NAVArraySignedIntegerSetAdd
 */
struct _NAVArraySignedIntegerSet {
    integer size
    integer capacity

    char free[NAV_MAX_ARRAY_SET_SIZE]
    sinteger data[NAV_MAX_ARRAY_SET_SIZE]
}


/**
 * @struct _NAVArrayLongSet
 * @description A set data structure for long values that prevents duplicates.
 *
 * @property {integer} size - Current number of elements in the set
 * @property {integer} capacity - Maximum number of elements the set can hold
 * @property {char[]} free - Tracks which slots are available (true) or occupied (false)
 * @property {long[]} data - The actual stored values
 *
 * @example
 * stack_var _NAVArrayLongSet longSet
 * NAVArrayLongSetInit(longSet, 10)
 * NAVArrayLongSetAdd(longSet, $FFFFFFFF)
 *
 * @see NAVArrayLongSetInit
 * @see NAVArrayLongSetAdd
 */
struct _NAVArrayLongSet {
    integer size
    integer capacity

    char free[NAV_MAX_ARRAY_SET_SIZE]
    long data[NAV_MAX_ARRAY_SET_SIZE]
}


/**
 * @struct _NAVArraySignedLongSet
 * @description A set data structure for signed long values that prevents duplicates.
 *
 * @property {integer} size - Current number of elements in the set
 * @property {integer} capacity - Maximum number of elements the set can hold
 * @property {char[]} free - Tracks which slots are available (true) or occupied (false)
 * @property {slong[]} data - The actual stored values
 *
 * @example
 * stack_var _NAVArraySignedLongSet slongSet
 * NAVArraySignedLongSetInit(slongSet, 10)
 * NAVArraySignedLongSetAdd(slongSet, -100000)
 *
 * @see NAVArraySignedLongSetInit
 * @see NAVArraySignedLongSetAdd
 */
struct _NAVArraySignedLongSet {
    integer size
    integer capacity

    char free[NAV_MAX_ARRAY_SET_SIZE]
    slong data[NAV_MAX_ARRAY_SET_SIZE]
}


/**
 * @struct _NAVArrayFloatSet
 * @description A set data structure for float values that prevents duplicates.
 *
 * @property {integer} size - Current number of elements in the set
 * @property {integer} capacity - Maximum number of elements the set can hold
 * @property {char[]} free - Tracks which slots are available (true) or occupied (false)
 * @property {float[]} data - The actual stored values
 *
 * @example
 * stack_var _NAVArrayFloatSet floatSet
 * NAVArrayFloatSetInit(floatSet, 10)
 * NAVArrayFloatSetAdd(floatSet, 3.14159)
 *
 * @see NAVArrayFloatSetInit
 * @see NAVArrayFloatSetAdd
 */
struct _NAVArrayFloatSet {
    integer size
    integer capacity

    char free[NAV_MAX_ARRAY_SET_SIZE]
    float data[NAV_MAX_ARRAY_SET_SIZE]
}


/**
 * @struct _NAVArrayDoubleSet
 * @description A set data structure for double values that prevents duplicates.
 *
 * @property {integer} size - Current number of elements in the set
 * @property {integer} capacity - Maximum number of elements the set can hold
 * @property {char[]} free - Tracks which slots are available (true) or occupied (false)
 * @property {double[]} data - The actual stored values
 *
 * @example
 * stack_var _NAVArrayDoubleSet doubleSet
 * NAVArrayDoubleSetInit(doubleSet, 10)
 * NAVArrayDoubleSetAdd(doubleSet, 3.14159265359)
 *
 * @see NAVArrayDoubleSetInit
 * @see NAVArrayDoubleSetAdd
 */
struct _NAVArrayDoubleSet {
    integer size
    integer capacity

    char free[NAV_MAX_ARRAY_SET_SIZE]
    double data[NAV_MAX_ARRAY_SET_SIZE]
}


/**
 * @struct _NAVArrayStringSet
 * @description A set data structure for string values that prevents duplicates.
 *
 * @property {integer} size - Current number of elements in the set
 * @property {integer} capacity - Maximum number of elements the set can hold
 * @property {char[]} free - Tracks which slots are available (true) or occupied (false)
 * @property {char[][]} data - The actual stored string values
 *
 * @example
 * stack_var _NAVArrayStringSet stringSet
 * NAVArrayStringSetInit(stringSet, 10)
 * NAVArrayStringSetAdd(stringSet, 'Hello')
 * NAVArrayStringSetAdd(stringSet, 'World')
 *
 * @see NAVArrayStringSetInit
 * @see NAVArrayStringSetAdd
 */
struct _NAVArrayStringSet {
    integer size
    integer capacity

    char free[NAV_MAX_ARRAY_SET_SIZE]
    char data[NAV_MAX_ARRAY_SET_SIZE][255]
}


#END_IF // __NAV_FOUNDATION_ARRAYUTILS_H__
