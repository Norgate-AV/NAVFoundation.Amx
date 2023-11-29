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
    stack_var char cipher[NAV_MAX_BUFFER]
    stack_var integer x
    stack_var integer z

    cipher = ''

    if (!length_array(value)) {
        return cipher
    }

    count = 1
    z = 1

    for (x = 1; x <= length_array(value); x++) {
        buffer[count] = value[x]
        count++

        if (count < 3) {
            continue
        }

        cipher[z] = type_cast(NAV_BASE64_MAP[(buffer[1] >> 2)]); z++
        cipher[z] = type_cast(NAV_BASE64_MAP[((buffer[1] & $03) << 4) | (buffer[2] >> 4)]); z++
        cipher[z] = type_cast(NAV_BASE64_MAP[((buffer[2] & $0F) << 2) | (buffer[3] >> 6)]); z++
        cipher[z] = type_cast(NAV_BASE64_MAP[(buffer[3] & $3F)]); z++

        count = 1
    }

    if (count > 1) {
        cipher[z] = type_cast(NAV_BASE64_MAP[(buffer[1] >> 2)]); z++

        if (count == 2) {
            cipher[z] = type_cast(NAV_BASE64_MAP[((buffer[1] & $03) << 4)]); z++
            cipher[z] = '='; z++
        }
        else {
            cipher[z] = type_cast(NAV_BASE64_MAP[((buffer[1] & $03) << 4) | (buffer[2] >> 4)]); z++
            cipher[z] = type_cast(NAV_BASE64_MAP[((buffer[2] & $0F) << 2)]); z++
        }

        cipher[z] = '='; z++
    }

    return cipher
}


define_function char[NAV_MAX_BUFFER] NAVBase64Decode(char value[]) {
    stack_var integer count
    stack_var char buffer[4]
    stack_var char plain[NAV_MAX_BUFFER]
    stack_var integer x
    stack_var integer z

    plain = ''

    if (!length_array(value)) {
        return plain
    }

    count = 1
    z = 1

    // for (x = 1; x <= length_array(value); x++) {
    //     buffer[count] = type_cast(NAV_BASE64_MAP[value[x]])
    //     count++

    //     if (count < 4) {
    //         continue
    //     }

    //     plain[z] = type_cast((buffer[1] << 2) | (buffer[2] >> 4)); z++
    //     plain[z] = type_cast((buffer[2] << 4) | (buffer[3] >> 2)); z++
    //     plain[z] = type_cast((buffer[3] << 6) | (buffer[4])); z++

    //     count = 1
    // }

    for (x = 1; x <= length_array(value); x++) {
        stack_var integer j
        stack_var integer size

        size = length_array(NAV_BASE64_MAP)

        for (j = 1; j <= size && NAV_BASE64_MAP[j] != value[x]; j++) {
            buffer[count] = type_cast(j)
            count++

            if (count < 4) {
                continue
            }

            plain[z] = type_cast((buffer[1] << 2) | (buffer[2] >> 4)); z++

            if (buffer[3] != size) {
                plain[z] = type_cast((buffer[2] << 4) | (buffer[3] >> 2)); z++
            }

            if (buffer[4] != size) {
                plain[z] = type_cast((buffer[3] << 6) | (buffer[4])); z++
            }

            count = 1
        }
    }

    return plain
}


#END_IF // __NAV_FOUNDATION_ENCODING_BASE64__
