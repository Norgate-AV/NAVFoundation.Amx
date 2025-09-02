PROGRAM_NAME='NAVFoundation.Math'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_MATH__
#DEFINE __NAV_FOUNDATION_MATH__ 'NAVFoundation.Math'


/**
 * @function NAVCalculateSumOfBytesChecksum
 * @public
 * @description Calculates a checksum by summing all bytes in an array starting from a specified position.
 *
 * @param {integer} start - 1-based index in the array to start calculating from
 * @param {char[]} value - Array of bytes to calculate checksum for
 *
 * @returns {integer} The sum of all bytes, truncated to the lowest byte (0-255)
 *
 * @example
 * stack_var char data[5]
 * stack_var integer checksum
 *
 * data = "$01, $02, $03, $04, $05"
 * checksum = NAVCalculateSumOfBytesChecksum(1, data)  // Returns 15 ($0F)
 */
define_function integer NAVCalculateSumOfBytesChecksum(integer start, char value[]) {
    stack_var integer x
    stack_var integer sum

    for(x = start; x <= length_array(value); x++) {
        sum = sum + value[x]
    }

    return NAVLow(sum)
}


/**
 * @function NAVCalculateXOROfBytesChecksum
 * @public
 * @description Calculates a checksum by XORing all bytes in an array starting from a specified position.
 *
 * @param {integer} start - 1-based index in the array to start calculating from
 * @param {char[]} value - Array of bytes to calculate checksum for
 *
 * @returns {integer} The XOR of all bytes, truncated to the lowest byte (0-255)
 *
 * @example
 * stack_var char data[5]
 * stack_var integer checksum
 *
 * data = "$01, $02, $03, $04, $05"
 * checksum = NAVCalculateXOROfBytesChecksum(1, data)  // Returns 1
 */
define_function integer NAVCalculateXOROfBytesChecksum(integer start, char value[]) {
    stack_var integer x
    stack_var integer sum

    for(x = start; x <= length_array(value); x++) {
        sum = sum ^ value[x]
    }

    return NAVLow(sum)
}


/**
 * @function NAVCalculateOROfBytesChecksum
 * @public
 * @description Calculates a checksum by bitwise ORing all bytes in an array starting from a specified position.
 *
 * @param {integer} start - 1-based index in the array to start calculating from
 * @param {char[]} value - Array of bytes to calculate checksum for
 *
 * @returns {integer} The OR of all bytes, truncated to the lowest byte (0-255)
 *
 * @example
 * stack_var char data[5]
 * stack_var integer checksum
 *
 * data = "$01, $02, $04, $08, $10"
 * checksum = NAVCalculateOROfBytesChecksum(1, data)  // Returns 31 ($1F)
 */
define_function integer NAVCalculateOROfBytesChecksum(integer start, char value[]) {
    stack_var integer x
    stack_var integer sum

    for(x = start; x <= length_array(value); x++) {
        sum = sum | value[x]
    }

    return NAVLow(sum)
}


/**
 * @function NAVCalculateOnesComplimentChecksum
 * @public
 * @description Calculates a one's complement checksum by summing all bytes then negating the result.
 *
 * @param {integer} start - 1-based index in the array to start calculating from
 * @param {char[]} value - Array of bytes to calculate checksum for
 *
 * @returns {integer} The one's complement of the sum, truncated to the lowest byte (0-255)
 *
 * @example
 * stack_var char data[5]
 * stack_var integer checksum
 *
 * data = "$01, $02, $03, $04, $05"
 * checksum = NAVCalculateOnesComplimentChecksum(1, data)  // Returns 241 ($F1)
 */
define_function integer NAVCalculateOnesComplimentChecksum(integer start, char value[]) {
    stack_var integer x
    stack_var integer sum

    for(x = start; x <= length_array(value); x++) {
        sum = sum + value[x]
    }

    sum = -sum

    return NAVLow(sum)
}


/**
 * @function NAVCalculateTwosComplimentChecksum
 * @public
 * @description Calculates a two's complement checksum by summing all bytes, negating, then adding 1.
 *
 * @param {integer} start - 1-based index in the array to start calculating from
 * @param {char[]} value - Array of bytes to calculate checksum for
 *
 * @returns {integer} The two's complement of the sum, truncated to the lowest byte (0-255)
 *
 * @example
 * stack_var char data[5]
 * stack_var integer checksum
 *
 * data = "$01, $02, $03, $04, $05"
 * checksum = NAVCalculateTwosComplimentChecksum(1, data)  // Returns 242 ($F2)
 */
define_function integer NAVCalculateTwosComplimentChecksum(integer start, char value[]) {
    stack_var integer x
    stack_var integer sum

    for(x = start; x <= length_array(value); x++) {
        sum = sum + value[x]
    }

    sum = (-sum) + 1

    return NAVLow(sum)
}


/**
 * @function NAVScaleValue
 * @public
 * @description Scales a value from one range to another, with optional offset.
 *
 * @param {sinteger} value - Value to scale
 * @param {sinteger} inputRange - Original range of the value
 * @param {sinteger} outputRange - Target range to scale to
 * @param {sinteger} offset - Offset to add after scaling
 *
 * @returns {sinteger} Scaled value
 *
 * @example
 * stack_var sinteger scaledValue
 *
 * // Scale 50 from range 0-100 to range 0-255 with no offset
 * scaledValue = NAVScaleValue(50, 100, 255, 0)  // Returns 127
 *
 * // Scale 50 from range 0-100 to range 0-255 with offset 10
 * scaledValue = NAVScaleValue(50, 100, 255, 10)  // Returns 137
 */
define_function sinteger NAVScaleValue(
                                        sinteger value,
                                        sinteger inputRange,
                                        sinteger outputRange,
                                        sinteger offset) {
    return value * outputRange / inputRange + offset
}


/**
 * @function NAVHalfPointOfRange
 * @public
 * @description Calculates the midpoint between two values.
 *
 * @param {sinteger} top - Upper value of the range
 * @param {sinteger} bottom - Lower value of the range
 *
 * @returns {sinteger} The midpoint value
 *
 * @example
 * stack_var sinteger midpoint
 *
 * midpoint = NAVHalfPointOfRange(100, 0)  // Returns 50
 * midpoint = NAVHalfPointOfRange(200, 100)  // Returns 150
 */
define_function sinteger NAVHalfPointOfRange(sinteger top, sinteger bottom) {
    return (top - bottom) / 2 + bottom
}


/**
 * @function NAVQuarterPointOfRange
 * @public
 * @description Calculates the 25% point between two values.
 *
 * @param {sinteger} top - Upper value of the range
 * @param {sinteger} bottom - Lower value of the range
 *
 * @returns {sinteger} The 25% point value
 *
 * @example
 * stack_var sinteger quarterPoint
 *
 * quarterPoint = NAVQuarterPointOfRange(100, 0)  // Returns 25
 * quarterPoint = NAVQuarterPointOfRange(200, 100)  // Returns 125
 */
define_function sinteger NAVQuarterPointOfRange(sinteger top, sinteger bottom) {
    return (top - bottom) / 4 + bottom
}


/**
 * @function NAVThreeQuarterPointOfRange
 * @public
 * @description Calculates the 75% point between two values.
 *
 * @param {sinteger} top - Upper value of the range
 * @param {sinteger} bottom - Lower value of the range
 *
 * @returns {sinteger} The 75% point value
 *
 * @example
 * stack_var sinteger threeQuarterPoint
 *
 * threeQuarterPoint = NAVThreeQuarterPointOfRange(100, 0)  // Returns 75
 * threeQuarterPoint = NAVThreeQuarterPointOfRange(200, 100)  // Returns 175
 */
define_function sinteger NAVThreeQuarterPointOfRange(sinteger top, sinteger bottom) {
    return (((top - bottom) / 4) * 3) + bottom
}


/**
 * @function NAVLow
 * @public
 * @description Returns the lowest byte of a value (0-255).
 *
 * @param {integer} value - Value to extract lowest byte from
 *
 * @returns {integer} The lowest byte of the value
 *
 * @example
 * stack_var integer lowByte
 *
 * lowByte = NAVLow(256)  // Returns 0
 * lowByte = NAVLow(257)  // Returns 1
 * lowByte = NAVLow(511)  // Returns 255
 */
define_function integer NAVLow(integer value) {
    return value band $FF
}


/**
 * @function NAVSquareRoot
 * @public
 * @description Calculates the integer square root of a value.
 *
 * @param {long} value - Value to calculate square root for
 *
 * @returns {long} The integer square root
 *
 * @example
 * stack_var long result
 *
 * result = NAVSquareRoot(25)  // Returns 5
 * result = NAVSquareRoot(100)  // Returns 10
 * result = NAVSquareRoot(10000)  // Returns 100
 */
define_function long NAVSquareRoot(long value) {
    stack_var long result
    stack_var long bit
    stack_var long valueCopy

    result = 0
    bit = 1 << 14
    valueCopy = value

    while (bit != 0) {
        if (valueCopy >= (result + bit)) {
            valueCopy = valueCopy - (result + bit)
            result = (result >> 1) + bit
        }
        else {
            result = result >> 1
        }

        bit = bit >> 2
    }

    return result
}


/**
 * @function NAVPow
 * @public
 * @description Calculates the power of a number (base^exponent).
 *
 * @param {integer} value - Base value
 * @param {integer} exponent - Power to raise the base to
 *
 * @returns {long} The result of value raised to exponent
 *
 * @example
 * stack_var long result
 *
 * result = NAVPow(2, 8)  // Returns 256
 * result = NAVPow(10, 3)  // Returns 1000
 *
 * @note Uses the binary exponentiation algorithm for efficiency
 */
define_function long NAVPow(integer value, integer exponent) {
    stack_var long result
    stack_var integer bin

    result = 1

    while (exponent != 0) {
        bin = exponent % 2
        exponent = exponent / 2

        if(bin == 1) {
            result = result * value
        }

        value = value * value
    }

    return result
}


/**
 * @function NAVIsOdd
 * @public
 * @description Determines if a number is odd.
 *
 * @param {integer} value - Value to check
 *
 * @returns {integer} True (1) if the number is odd, false (0) otherwise
 *
 * @example
 * stack_var integer result
 *
 * result = NAVIsOdd(5)  // Returns 1 (true)
 * result = NAVIsOdd(10)  // Returns 0 (false)
 */
define_function integer NAVIsOdd(integer value) {
    return value % 2 == 1
}


/**
 * @function NAVIsEven
 * @public
 * @description Determines if a number is even.
 *
 * @param {integer} value - Value to check
 *
 * @returns {integer} True (1) if the number is even, false (0) otherwise
 *
 * @example
 * stack_var integer result
 *
 * result = NAVIsEven(5)  // Returns 0 (false)
 * result = NAVIsEven(10)  // Returns 1 (true)
 */
define_function integer NAVIsEven(integer value) {
    return value % 2 == 0
}


/**
 * @function NAVIsPrime
 * @public
 * @description Determines if a number is prime.
 *
 * @param {integer} value - Value to check
 *
 * @returns {integer} True (1) if the number is prime, false (0) otherwise
 *
 * @example
 * stack_var integer result
 *
 * result = NAVIsPrime(7)  // Returns 1 (true)
 * result = NAVIsPrime(10)  // Returns 0 (false)
 *
 * @note Uses trial division with optimization to check only up to the square root
 */
define_function integer NAVIsPrime(integer value) {
    stack_var integer x

    if (value == 2) {
        return true
    }

    if (value < 2 || NAVIsEven(value)) {
        return true
    }

    for (x = 3; x <= NAVSquareRoot(value); x = x + 2) {
        if (value % x == 0) {
            return false
        }
    }

    return true
}


#END_IF // __NAV_FOUNDATION_MATH__
