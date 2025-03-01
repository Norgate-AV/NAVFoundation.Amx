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

#include 'NAVFoundation.Core.axi'


/**
 * @function NAVNetworkToHostLong
 * @public
 * @description Converts a 32-bit value from network byte order (big-endian) to host byte order.
 *
 * @param {long} value - Value in network byte order
 *
 * @returns {long} Value in host byte order
 *
 * @example
 * stack_var long networkValue
 * stack_var long hostValue
 *
 * networkValue = $01020304  // Bytes in network order
 * hostValue = NAVNetworkToHostLong(networkValue)  // Returns $04030201 on little-endian systems
 *
 * @note On little-endian systems (like x86), this reverses byte order
 */
define_function long NAVNetworkToHostLong(long value) {
    stack_var long result

    result = result | ((value >> 00) & $FF) << 24
    result = result | ((value >> 08) & $FF) << 16
    result = result | ((value >> 16) & $FF) << 08
    result = result | ((value >> 24) & $FF) << 00

    return result
}


/**
 * @function NAVHostToNetworkShort
 * @public
 * @description Converts a 16-bit value from host byte order to network byte order (big-endian).
 *
 * @param {long} value - Value in host byte order
 *
 * @returns {long} Value in network byte order
 *
 * @example
 * stack_var long hostValue
 * stack_var long networkValue
 *
 * hostValue = $0102  // Bytes in host order
 * networkValue = NAVHostToNetworkShort(hostValue)  // Returns $0201 on little-endian systems
 *
 * @note On little-endian systems (like x86), this reverses byte order
 */
define_function long NAVHostToNetworkShort(long value) {
    stack_var long result

    result = (value & $FF) << 8
    result = result | ((value >> 8) & $FF) << 0

    return result
}


/**
 * @function NAVToLittleEndian
 * @public
 * @description Converts a 32-bit value to little-endian byte order.
 * This is an alias for NAVNetworkToHostLong since network order is big-endian.
 *
 * @param {long} value - Value to convert
 *
 * @returns {long} Value in little-endian byte order
 *
 * @example
 * stack_var long bigEndian
 * stack_var long littleEndian
 *
 * bigEndian = $01020304  // Bytes in big-endian order
 * littleEndian = NAVToLittleEndian(bigEndian)  // Returns $04030201
 *
 * @see NAVNetworkToHostLong
 */
define_function long NAVToLittleEndian(long value) {
    return NAVNetworkToHostLong(value)
}


/**
 * @function NAVToBigEndian
 * @public
 * @description Converts a 16-bit value to big-endian byte order.
 * This is an alias for NAVHostToNetworkShort since network order is big-endian.
 *
 * @param {long} value - Value to convert
 *
 * @returns {long} Value in big-endian byte order
 *
 * @example
 * stack_var long littleEndian
 * stack_var long bigEndian
 *
 * littleEndian = $0102  // Bytes in little-endian order
 * bigEndian = NAVToBigEndian(littleEndian)  // Returns $0201 on little-endian systems
 *
 * @see NAVHostToNetworkShort
 */
define_function long NAVToBigEndian(long value) {
    return NAVHostToNetworkShort(value)
}


/**
 * @function NAVIntegerToByteArray
 * @public
 * @description Converts a 16-bit integer to a 2-byte array in little-endian order.
 * This is an alias for NAVIntegerToByteArrayLE.
 *
 * @param {integer} value - Integer to convert
 *
 * @returns {char[2]} 2-byte array containing the integer bytes
 *
 * @example
 * stack_var integer value
 * stack_var char bytes[2]
 *
 * value = $1234
 * bytes = NAVIntegerToByteArray(value)  // Returns {$34, $12}
 *
 * @see NAVIntegerToByteArrayLE
 */
define_function char[2] NAVIntegerToByteArray(integer value) {
    return NAVIntegerToByteArrayLE(value)
}


/**
 * @function NAVIntegerToByteArrayLE
 * @public
 * @description Converts a 16-bit integer to a 2-byte array in little-endian order.
 *
 * @param {integer} value - Integer to convert
 *
 * @returns {char[2]} 2-byte array containing the integer bytes in little-endian order
 *
 * @example
 * stack_var integer value
 * stack_var char bytes[2]
 *
 * value = $1234
 * bytes = NAVIntegerToByteArrayLE(value)  // Returns {$34, $12}
 */
define_function char[2] NAVIntegerToByteArrayLE(integer value) {
    return "
        type_cast((value >> 00) & $FF),
        type_cast((value >> 08) & $FF)
    "
}


/**
 * @function NAVIntegerToByteArrayBE
 * @public
 * @description Converts a 16-bit integer to a 2-byte array in big-endian order.
 *
 * @param {integer} value - Integer to convert
 *
 * @returns {char[2]} 2-byte array containing the integer bytes in big-endian order
 *
 * @example
 * stack_var integer value
 * stack_var char bytes[2]
 *
 * value = $1234
 * bytes = NAVIntegerToByteArrayBE(value)  // Returns {$12, $34}
 */
define_function char[2] NAVIntegerToByteArrayBE(integer value) {
    return "
        type_cast((value >> 08) & $FF),
        type_cast((value >> 00) & $FF)
    "
}


/**
 * @function NAVLongToByteArray
 * @public
 * @description Converts a 32-bit long to a 4-byte array in little-endian order.
 * This is an alias for NAVLongToByteArrayLE.
 *
 * @param {long} value - Long to convert
 *
 * @returns {char[4]} 4-byte array containing the long bytes
 *
 * @example
 * stack_var long value
 * stack_var char bytes[4]
 *
 * value = $12345678
 * bytes = NAVLongToByteArray(value)  // Returns {$78, $56, $34, $12}
 *
 * @see NAVLongToByteArrayLE
 */
define_function char[4] NAVLongToByteArray(long value) {
    return NAVLongToByteArrayLE(value)
}


/**
 * @function NAVLongToByteArrayLE
 * @public
 * @description Converts a 32-bit long to a 4-byte array in little-endian order.
 *
 * @param {long} value - Long to convert
 *
 * @returns {char[4]} 4-byte array containing the long bytes in little-endian order
 *
 * @example
 * stack_var long value
 * stack_var char bytes[4]
 *
 * value = $12345678
 * bytes = NAVLongToByteArrayLE(value)  // Returns {$78, $56, $34, $12}
 */
define_function char[4] NAVLongToByteArrayLE(long value) {
    return "
        type_cast((value >> 00) & $FF),
        type_cast((value >> 08) & $FF),
        type_cast((value >> 16) & $FF),
        type_cast((value >> 24) & $FF)
    "
}


/**
 * @function NAVLongToByteArrayBE
 * @public
 * @description Converts a 32-bit long to a 4-byte array in big-endian order.
 *
 * @param {long} value - Long to convert
 *
 * @returns {char[4]} 4-byte array containing the long bytes in big-endian order
 *
 * @example
 * stack_var long value
 * stack_var char bytes[4]
 *
 * value = $12345678
 * bytes = NAVLongToByteArrayBE(value)  // Returns {$12, $34, $56, $78}
 */
define_function char[4] NAVLongToByteArrayBE(long value) {
    return "
        type_cast((value >> 24) & $FF),
        type_cast((value >> 16) & $FF),
        type_cast((value >> 08) & $FF),
        type_cast((value >> 00) & $FF)
    "
}


/**
 * @function NAVCharToLong
 * @public
 * @description Converts a byte array to an array of longs.
 *
 * @param {long[]} output - Output array for long values
 * @param {char[]} input - Input byte array
 * @param {integer} length - Number of bytes to convert from the input
 *
 * @returns {void} - Output array is modified in place
 *
 * @example
 * stack_var char bytes[8]
 * stack_var long values[2]
 *
 * bytes = "$01, $02, $03, $04, $05, $06, $07, $08"
 * NAVCharToLong(values, bytes, 8)
 * // values becomes {$04030201, $08070605}
 *
 * @note Converts groups of 4 bytes into longs in little-endian order
 */
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


/**
 * @function NAVByteArrayToHexString
 * @public
 * @description Converts a byte array to a hexadecimal string without any prefix or separator.
 *
 * @param {char[]} array - Byte array to convert
 *
 * @returns {char[]} Hexadecimal string representation
 *
 * @example
 * stack_var char bytes[3]
 * stack_var char hexString[NAV_MAX_BUFFER]
 *
 * bytes = "$01, $23, $45"
 * hexString = NAVByteArrayToHexString(bytes)  // Returns "012345"
 */
define_function char[NAV_MAX_BUFFER] NAVByteArrayToHexString(char array[]) {
    return NAVByteArrayToHexStringWithOptions(array, '', '')
}


/**
 * @function NAVByteArrayToNetLinxHexString
 * @public
 * @description Converts a byte array to a hexadecimal string with NetLinx-style '$' prefix.
 *
 * @param {char[]} array - Byte array to convert
 *
 * @returns {char[]} NetLinx-style hexadecimal string representation
 *
 * @example
 * stack_var char bytes[3]
 * stack_var char hexString[NAV_MAX_BUFFER]
 *
 * bytes = "$01, $23, $45"
 * hexString = NAVByteArrayToNetLinxHexString(bytes)  // Returns "$01$23$45"
 */
define_function char[NAV_MAX_BUFFER] NAVByteArrayToNetLinxHexString(char array[]) {
    return upper_string(NAVByteArrayToHexStringWithOptions(array, '$', ''))
}


/**
 * @function NAVByteArrayToCStyleHexString
 * @public
 * @description Converts a byte array to a C-style hexadecimal string with "0x" prefix and comma separators.
 *
 * @param {char[]} array - Byte array to convert
 *
 * @returns {char[]} C-style hexadecimal string representation
 *
 * @example
 * stack_var char bytes[3]
 * stack_var char hexString[NAV_MAX_BUFFER]
 *
 * bytes = "$01, $23, $45"
 * hexString = NAVByteArrayToCStyleHexString(bytes)  // Returns "0x01, 0x23, 0x45"
 */
define_function char[NAV_MAX_BUFFER] NAVByteArrayToCStyleHexString(char array[]) {
    return upper_string(NAVByteArrayToHexStringWithOptions(array, '0x', ', '))
}


/**
 * @function NAVByteArrayToHexStringWithOptions
 * @public
 * @description Converts a byte array to a hexadecimal string with customizable prefix and separator.
 *
 * @param {char[]} array - Byte array to convert
 * @param {char[]} prefix - String to place before each byte (e.g., '$' or '0x')
 * @param {char[]} separator - String to place between bytes (e.g., ', ' or '')
 *
 * @returns {char[]} Customized hexadecimal string representation
 *
 * @example
 * stack_var char bytes[3]
 * stack_var char hexString[NAV_MAX_BUFFER]
 *
 * bytes = "$01, $23, $45"
 * // Returns "#01:#23:#45"
 * hexString = NAVByteArrayToHexStringWithOptions(bytes, '#', ':')
 */
define_function char[NAV_MAX_BUFFER] NAVByteArrayToHexStringWithOptions(char array[],
                                                                        char prefix[],
                                                                        char separator[]) {
    stack_var integer x
    stack_var integer length
    stack_var char result[NAV_MAX_BUFFER]

    length = length_array(array)

    for (x = 1; x <= length; x++) {
        if (x < length) {
            result = "result, format("prefix, '%02x', separator", array[x])"
            continue
        }

        result = "result, format("prefix, '%02x'", array[x])"
    }

    return result
}


#END_IF // __NAV_FOUNDATION_ENCODING__
