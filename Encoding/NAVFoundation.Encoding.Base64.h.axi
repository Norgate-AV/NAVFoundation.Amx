PROGRAM_NAME='NAVFoundation.Encoding.Base64.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENCODING_BASE64_H__
#DEFINE __NAV_FOUNDATION_ENCODING_BASE64_H__ 'NAVFoundation.Encoding.Base64.h'

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

/**
 * @constant NAV_BASE64_MAP
 * @description Standard Base64 encoding character set as defined in RFC 4648.
 * Contains the 64 characters used in Base64 encoding (A-Z, a-z, 0-9, +, /).
 *
 * @note The index in this array (1-based) corresponds to the 6-bit value being encoded plus 1
 * @note Array is 1-indexed to match NetLinx array indexing (first element at position 1)
 */
constant char NAV_BASE64_MAP[]  =   {
                                        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
                                        'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
                                        'U', 'V', 'W', 'X', 'Y', 'Z',

                                        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j',
                                        'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't',
                                        'u', 'v', 'w', 'x', 'y', 'z',

                                        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',

                                        '+', '/'
                                    }

/**
 * @constant NAV_BASE64_PADDING_CHAR
 * @description The character used for padding in Base64 encoding ('=')
 *
 * @note Padding is used when the input length is not divisible by 3
 */
constant char NAV_BASE64_PADDING_CHAR = '='

/**
 * @constant NAV_BASE64_INVALID_VALUE
 * @description Value indicating an invalid Base64 character
 *
 * @note Used as a return value from NAVBase64GetCharValue for error handling
 */
constant sinteger NAV_BASE64_INVALID_VALUE = -1


#END_IF // __NAV_FOUNDATION_ENCODING_BASE64_H__
