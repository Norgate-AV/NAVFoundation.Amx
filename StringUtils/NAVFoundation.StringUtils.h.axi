PROGRAM_NAME='NAVFoundation.StringUtils.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_STRINGUTILS_H__
#DEFINE __NAV_FOUNDATION_STRINGUTILS_H__ 'NAVFoundation.StringUtils.h'


DEFINE_CONSTANT

/**
 * @constant NAV_CASE_INSENSITIVE
 * @description Flag indicating case-insensitive string comparison.
 * Used in string functions that support case sensitivity options.
 *
 * @example
 * result = NAVStringCount(text, 'hello', NAV_CASE_INSENSITIVE) // Match any case
 */
constant integer NAV_CASE_INSENSITIVE =   0

/**
 * @constant NAV_CASE_SENSITIVE
 * @description Flag indicating case-sensitive string comparison.
 * Used in string functions that support case sensitivity options.
 *
 * @example
 * result = NAVStringCount(text, 'hello', NAV_CASE_SENSITIVE) // Match exact case only
 */
constant integer NAV_CASE_SENSITIVE =     1


DEFINE_TYPE

/**
 * @struct _NAVStringGatherResult
 * @description Result structure used in string gathering operations.
 * Passed to the callback function when a string is gathered from a stream.
 *
 * @property {char[]} Data - The gathered string data
 * @property {char[]} Delimiter - The delimiter that was used to split the string
 *
 * @example
 * define_function NAVStringGatherCallback(_NAVStringGatherResult result) {
 *     // Process the gathered string data
 *     NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Gathered data: ', result.Data")
 * }
 *
 * @see NAVStringGather
 */
struct _NAVStringGatherResult {
    char Data[NAV_MAX_BUFFER]
    char Delimiter[NAV_MAX_CHARS]
}


#END_IF // __NAV_FOUNDATION_STRINGUTILS_H__
