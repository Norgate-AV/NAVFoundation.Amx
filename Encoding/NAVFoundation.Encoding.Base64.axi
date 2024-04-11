PROGRAM_NAME='NAVFoundation.Encoding.Base64'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENCODING_BASE64__
#DEFINE __NAV_FOUNDATION_ENCODING_BASE64__ 'NAVFoundation.Encoding.Base64'

#include 'NAVFoundation.Encoding.Base64.h.axi'


define_function char[NAV_MAX_BUFFER] NAVBase64Encode(char value[]) {
    stack_var integer count
    stack_var char buffer[3]
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer i
    stack_var integer j

    length = length_array(value)

    if (length <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_ENCODING_BASE64__,
                                    'NAVBase64Encode',
                                    "'Attempted to encode an empty string'")

        return value
    }

    count = 0
    j = 0

    for (i = 0; i < length; i++) {
        buffer[(count + 1)] = value[(i + 1)]
        count++

        if (count < 3) {
            continue
        }

        result[(j + 1)] = type_cast(NAV_BASE64_MAP[((buffer[1] >> 2) + 1)]); j++
        result[(j + 1)] = type_cast(NAV_BASE64_MAP[(((buffer[1] & $03) << 4) | (buffer[2] >> 4) + 1)]); j++
        result[(j + 1)] = type_cast(NAV_BASE64_MAP[(((buffer[2] & $0F) << 2) | (buffer[3] >> 6) + 1)]); j++
        result[(j + 1)] = type_cast(NAV_BASE64_MAP[((buffer[3] & $3F) + 1)]); j++

        count = 0
    }

    if (count > 0) {
        result[(j + 1)] = type_cast(NAV_BASE64_MAP[((buffer[1] >> 2) + 1)]); j++

        if (count == 1) {
            result[(j + 1)] = type_cast(NAV_BASE64_MAP[(((buffer[1] & $03) << 4) + 1)]); j++
            result[(j + 1)] = '='; j++
        }
        else {
            result[(j + 1)] = type_cast(NAV_BASE64_MAP[(((buffer[1] & $03) << 4) | (buffer[2] >> 4) + 1)]); j++
            result[(j + 1)] = type_cast(NAV_BASE64_MAP[(((buffer[2] & $0F) << 2) + 1)]); j++
        }

        result[(j + 1)] = '='; j++
    }

    set_length_array(result, j)

    return result
}


define_function char[NAV_MAX_BUFFER] NAVBase64Decode(char value[]) {
    stack_var integer count
    stack_var char buffer[4]
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer i
    stack_var integer j
    stack_var char k

    length = length_array(value)

    if (length <= 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                    __NAV_FOUNDATION_ENCODING_BASE64__,
                                    'NAVBase64Decode',
                                    "'Attempted to decode an empty string'")

        return value
    }

    count = 0
    j = 0

    for (i = 0; i < length; i++) {
        for (k = 0; k < 64; k++) {
            if (NAV_BASE64_MAP[(k + 1)] == value[(i + 1)]) {
                break
            }
        }

        buffer[(count + 1)] = k
        count++

        if (count < 4) {
            continue
        }

        result[(j + 1)] = type_cast((buffer[1] << 2) | (buffer[2] >> 4)); j++

        if (buffer[3] != 64) {
            result[(j + 1)] = type_cast((buffer[2] << 4) | (buffer[3] >> 2)); j++
        }

        if (buffer[4] != 64) {
            result[(j + 1)] = type_cast((buffer[3] << 6) | (buffer[4])); j++
        }

        count = 0
    }

    set_length_array(result, j)

    return result
}


#END_IF // __NAV_FOUNDATION_ENCODING_BASE64__
