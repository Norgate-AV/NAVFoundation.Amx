PROGRAM_NAME='NAVFoundation.Encoding'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENCODING__
#DEFINE __NAV_FOUNDATION_ENCODING__ 'NAVFoundation.Encoding'


define_function long NAVNetworkToHostLong(long value) {
    stack_var long result

    result = result | ((value >> 00) & $FF) << 24
    result = result | ((value >> 08) & $FF) << 16
    result = result | ((value >> 16) & $FF) << 08
    result = result | ((value >> 24) & $FF) << 00

    return result
}


define_function long NAVHostToNetworkShort(long value) {
    stack_var long result

    result = (value & $FF) << 8
    result = result | ((value >> 8) & $FF) << 0

    return result
}


define_function long NAVToLittleEndian(long value) {
    return NAVNetworkToHostLong(value)
}


define_function long NAVToBigEndian(long value) {
    return NAVHostToNetworkShort(value)
}


define_function char[2] NAVIntegerToByteArray(integer value) {
    return NAVIntegerToByteArrayLE(value)
}


define_function char[2] NAVIntegerToByteArrayLE(integer value) {
    return "
        type_cast((value >> 00) & $FF),
        type_cast((value >> 08) & $FF)
    "
}


define_function char[2] NAVIntegerToByteArrayBE(integer value) {
    return "
        type_cast((value >> 08) & $FF),
        type_cast((value >> 00) & $FF)
    "
}


define_function char[4] NAVLongToByteArray(long value) {
    return NAVLongToByteArrayLE(value)
}


define_function char[4] NAVLongToByteArrayLE(long value) {
    return "
        type_cast((value >> 00) & $FF),
        type_cast((value >> 08) & $FF),
        type_cast((value >> 16) & $FF),
        type_cast((value >> 24) & $FF)
    "
}


define_function char[4] NAVLongToByteArrayBE(long value) {
    return "
        type_cast((value >> 24) & $FF),
        type_cast((value >> 16) & $FF),
        type_cast((value >> 08) & $FF),
        type_cast((value >> 00) & $FF)
    "
}


define_function NAVCharToLong(long output[], char input[], integer length) {
    stack_var integer i
    stack_var integer j

    for (i = 0, j = 0; j < length; i++, j = j + 4) {
        output[(i + 1)] =   input[(j + 1) + 0] << 00 |
                            input[(j + 1) + 1] << 08 |
                            input[(j + 1) + 2] << 16 |
                            input[(j + 1) + 3] << 24
    }

    set_length_array(output, j)
}


#END_IF // __NAV_FOUNDATION_ENCODING__
