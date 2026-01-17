PROGRAM_NAME='NAVFoundation.BinaryUtils'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

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

#IF_NOT_DEFINED __NAV_FOUNDATION_BINARYUTILS__
#DEFINE __NAV_FOUNDATION_BINARYUTILS__ 'NAVFoundation.BinaryUtils'

#include 'NAVFoundation.Core.h.axi'


/**
 * @function NAVBinaryRotateLeft
 * @public
 * @description Rotates bits of a 32-bit value to the left by the specified count.
 * Bits that are rotated off the left end appear at the right end.
 *
 * @param {long} value - The value to rotate
 * @param {long} count - Number of positions to rotate left
 *
 * @returns {long} The rotated value
 *
 * @example
 * stack_var long original
 * stack_var long rotated
 *
 * original = $01  // Binary: 00000000 00000000 00000000 00000001
 * rotated = NAVBinaryRotateLeft(original, 4)  // Binary: 00000000 00000000 00000000 00010000
 *
 * @note Count should typically be between 1 and 31 for meaningful results
 */
define_function long NAVBinaryRotateLeft(long value, long count) {
    return (value << count) | (value >> (32 - count))
}


/**
 * @function NAVBitRotateLeft
 * @public
 * @description Alias for NAVBinaryRotateLeft. Rotates bits of a 32-bit value to the left.
 *
 * @param {long} value - The value to rotate
 * @param {long} count - Number of positions to rotate left
 *
 * @returns {long} The rotated value
 *
 * @example
 * stack_var long original
 * stack_var long rotated
 *
 * original = $01  // Binary: 00000000 00000000 00000000 00000001
 * rotated = NAVBitRotateLeft(original, 4)  // Binary: 00000000 00000000 00000000 00010000
 *
 * @see NAVBinaryRotateLeft
 */
define_function long NAVBitRotateLeft(long value, long count) {
    return NAVBinaryRotateLeft(value, count)
}


/**
 * @function NAVBinaryRotateRight
 * @public
 * @description Rotates bits of a 32-bit value to the right by the specified count.
 * Bits that are rotated off the right end appear at the left end.
 *
 * @param {long} value - The value to rotate
 * @param {long} count - Number of positions to rotate right
 *
 * @returns {long} The rotated value
 *
 * @example
 * stack_var long original
 * stack_var long rotated
 *
 * original = $10  // Binary: 00000000 00000000 00000000 00010000
 * rotated = NAVBinaryRotateRight(original, 4)  // Binary: 00000000 00000000 00000000 00000001
 *
 * @note Count should typically be between 1 and 31 for meaningful results
 */
define_function long NAVBinaryRotateRight(long value, long count) {
    return (value >> count) | (value << (32 - count))
}


/**
 * @function NAVBitRotateRight
 * @public
 * @description Alias for NAVBinaryRotateRight. Rotates bits of a 32-bit value to the right.
 *
 * @param {long} value - The value to rotate
 * @param {long} count - Number of positions to rotate right
 *
 * @returns {long} The rotated value
 *
 * @example
 * stack_var long original
 * stack_var long rotated
 *
 * original = $10  // Binary: 00000000 00000000 00000000 00010000
 * rotated = NAVBitRotateRight(original, 4)  // Binary: 00000000 00000000 00000000 00000001
 *
 * @see NAVBinaryRotateRight
 */
define_function long NAVBitRotateRight(long value, long count) {
    return NAVBinaryRotateRight(value, count)
}


/**
 * @function NAVBinaryGetBit
 * @public
 * @description Extracts a single bit from a 32-bit value at the specified position.
 *
 * @param {long} value - The value to extract a bit from
 * @param {long} bit - The bit position to extract (0-31)
 *
 * @returns {long} 1 if the specified bit is set, 0 otherwise
 *
 * @example
 * stack_var long value
 * stack_var long bitValue
 *
 * value = $05  // Binary: 00000000 00000000 00000000 00000101
 * bitValue = NAVBinaryGetBit(value, 0)  // Returns 1 (rightmost bit)
 * bitValue = NAVBinaryGetBit(value, 1)  // Returns 0 (second bit from right)
 * bitValue = NAVBinaryGetBit(value, 2)  // Returns 1 (third bit from right)
 *
 * @note Bit position 0 is the least significant (rightmost) bit
 */
define_function long NAVBinaryGetBit(long value, long bit) {
    return (value >> bit) & 1
}


/**
 * @function NAVByteToBitArray
 * @public
 * @description Converts a byte to an array of individual bit values.
 * Each bit is represented as a numeric value (0 or 1) in the returned array.
 *
 * @param {char} value - The byte value to convert
 *
 * @returns {char[]} Array of 8 bit values (0 or 1)
 *
 * @example
 * stack_var char value
 * stack_var char result[8]
 *
 * value = $A5  // Binary: 10100101
 * result = NAVByteToBitArray(value)  // Returns {1, 0, 1, 0, 0, 1, 0, 1}
 */
define_function char[8] NAVByteToBitArray(char value) {
    stack_var integer msb
    stack_var integer lsb
    stack_var char binary[8]

    msb = value / $10
    lsb = value % $10

    switch (msb) {
        case $00: binary = "0,0,0,0"
        case $01: binary = "0,0,0,1"
        case $02: binary = "0,0,1,0"
        case $03: binary = "0,0,1,1"
        case $04: binary = "0,1,0,0"
        case $05: binary = "0,1,0,1"
        case $06: binary = "0,1,1,0"
        case $07: binary = "0,1,1,1"
        case $08: binary = "1,0,0,0"
        case $09: binary = "1,0,0,1"
        case $0A: binary = "1,0,1,0"
        case $0B: binary = "1,0,1,1"
        case $0C: binary = "1,1,0,0"
        case $0D: binary = "1,1,0,1"
        case $0E: binary = "1,1,1,0"
        case $0F: binary = "1,1,1,1"
    }

    switch (lsb) {
        case $00: binary = "binary,0,0,0,0"
        case $01: binary = "binary,0,0,0,1"
        case $02: binary = "binary,0,0,1,0"
        case $03: binary = "binary,0,0,1,1"
        case $04: binary = "binary,0,1,0,0"
        case $05: binary = "binary,0,1,0,1"
        case $06: binary = "binary,0,1,1,0"
        case $07: binary = "binary,0,1,1,1"
        case $08: binary = "binary,1,0,0,0"
        case $09: binary = "binary,1,0,0,1"
        case $0A: binary = "binary,1,0,1,0"
        case $0B: binary = "binary,1,0,1,1"
        case $0C: binary = "binary,1,1,0,0"
        case $0D: binary = "binary,1,1,0,1"
        case $0E: binary = "binary,1,1,1,0"
        case $0F: binary = "binary,1,1,1,1"
    }

    return binary
}


/**
 * @function NAVBinaryToBcd
 * @public
 * @description Converts a binary integer to BCD (Binary Coded Decimal) format.
 * This performs binary to BCD conversion using the double-dabble algorithm.
 *
 * @param {integer} value - The binary integer to convert
 *
 * @returns {long} BCD representation of the value
 *
 * @example
 * stack_var integer decimal
 * stack_var long bcd
 *
 * decimal = 42
 * bcd = NAVBinaryToBcd(decimal)  // Returns 0x42 (BCD format)
 *
 * @note This implements the double-dabble algorithm for BCD conversion.
 * @note Use when sending decimal values to hardware that expects BCD encoding.
 */
define_function long NAVBinaryToBcd(integer value) {
    stack_var long result
    stack_var char x
    stack_var char j

    result = 0

    for (x = 16; x; x--) {
        for (j = 0; j < 5; j++) {
            if ((result >> (4 * j) & $0F) > 4) {
                result = result + (3 << (4 * j))
            }
        }

        result = result << 1 | (value >> (x - 1) & 1)
    }

    return result
}


/**
 * @function NAVByteToBinaryString
 * @public
 * @description Converts a byte to its binary representation as a string.
 * Returns an 8-character string representing the binary value.
 *
 * @param {char} value - The byte value to convert
 *
 * @returns {char[]} Binary representation as an 8-character string
 *
 * @example
 * stack_var char value
 * stack_var char result[8]
 *
 * value = $A5  // Binary: 10100101
 * result = NAVByteToBinaryString(value)  // Returns '10100101'
 *
 * @note Useful for debugging and logging binary data
 */
define_function char[8] NAVByteToBinaryString(char value) {
    stack_var integer msb
    stack_var integer lsb
    stack_var char binary[8]

    msb = value / $10
    lsb = value % $10

    switch (msb) {
        case $00: binary = "'0000'"
        case $01: binary = "'0001'"
        case $02: binary = "'0010'"
        case $03: binary = "'0011'"
        case $04: binary = "'0100'"
        case $05: binary = "'0101'"
        case $06: binary = "'0110'"
        case $07: binary = "'0111'"
        case $08: binary = "'1000'"
        case $09: binary = "'1001'"
        case $0A: binary = "'1010'"
        case $0B: binary = "'1011'"
        case $0C: binary = "'1100'"
        case $0D: binary = "'1101'"
        case $0E: binary = "'1110'"
        case $0F: binary = "'1111'"
    }

    switch (lsb) {
        case $00: binary = "binary,'0000'"
        case $01: binary = "binary,'0001'"
        case $02: binary = "binary,'0010'"
        case $03: binary = "binary,'0011'"
        case $04: binary = "binary,'0100'"
        case $05: binary = "binary,'0101'"
        case $06: binary = "binary,'0110'"
        case $07: binary = "binary,'0111'"
        case $08: binary = "binary,'1000'"
        case $09: binary = "binary,'1001'"
        case $0A: binary = "binary,'1010'"
        case $0B: binary = "binary,'1011'"
        case $0C: binary = "binary,'1100'"
        case $0D: binary = "binary,'1101'"
        case $0E: binary = "binary,'1110'"
        case $0F: binary = "binary,'1111'"
    }

    return binary
}


/**
 * @function NAVBcdToBinary
 * @public
 * @description Converts a BCD (Binary Coded Decimal) byte to its binary integer value.
 * Each nibble (4 bits) of the input represents a decimal digit (0-9).
 *
 * @param {char} value - The BCD-encoded byte to convert
 *
 * @returns {integer} Binary integer representation
 *
 * @example
 * stack_var char bcdValue
 * stack_var integer decimal
 *
 * bcdValue = $42  // BCD representation of 42
 * decimal = NAVBcdToBinary(bcdValue)  // Returns 42
 *
 * bcdValue = $99  // BCD representation of 99
 * decimal = NAVBcdToBinary(bcdValue)  // Returns 99
 *
 * @note Use when reading BCD-encoded data from hardware (RTCs, displays, etc.)
 * @note Input values should only use digits 0-9 in each nibble (0x00-0x99)
 */
define_function integer NAVBcdToBinary(char value) {
    return type_cast(((value >> 4) * 10) + (value & $0F))
}


#END_IF // __NAV_FOUNDATION_BINARYUTILS__
