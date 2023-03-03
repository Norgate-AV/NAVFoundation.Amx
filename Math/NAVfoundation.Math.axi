PROGRAM_NAME='NAVFoundation.Math'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2023 Norgate AV Solutions Ltd

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


/////////////////////////////////////////////////////////////
// Sum of bytes checksum
/////////////////////////////////////////////////////////////
define_function integer NAVCalculateSumOfBytesChecksum(integer start, char value[]) {
    stack_var integer x
    stack_var integer sum

    for(x = start; x <= length_array(value); x++) {
        sum = sum + value[x]
    }

    return NAVLow(sum)
}


/////////////////////////////////////////////////////////////
// XOR of bytes checksum
/////////////////////////////////////////////////////////////
define_function integer NAVCalculateXOROfBytesChecksum(integer start, char value[]) {
    stack_var integer x
    stack_var integer sum

    for(x = start; x <= length_array(value); x++) {
        sum = sum ^ value[x]
    }

    return NAVLow(sum)
}


/////////////////////////////////////////////////////////////
// OR of bytes checksum
/////////////////////////////////////////////////////////////
define_function integer NAVCalculateOROfBytesChecksum(integer start, char value[]) {
    stack_var integer x
    stack_var integer sum

    for(x = start; x <= length_array(value); x++) {
        sum = sum | value[x]
    }

    return NAVLow(sum)
}


/////////////////////////////////////////////////////////////
// One's compliment checksum
/////////////////////////////////////////////////////////////
define_function integer NAVCalculateOnesComplimentChecksum(integer start, char value[]) {
    stack_var integer x
    stack_var integer sum

    for(x = start; x <= length_array(value); x++) {
        sum = sum + value[x]
    }

    sum = -sum

    return NAVLow(sum)
}


/////////////////////////////////////////////////////////////
// Two's compliment checksum
/////////////////////////////////////////////////////////////
define_function integer NAVCalculateTwosComplimentChecksum(integer start, char value[]) {
    stack_var integer x
    stack_var integer sum

    for(x = start; x <= length_array(value); x++) {
        sum = sum + value[x]
    }

    sum = (-sum) + 1

    return NAVLow(sum)
}


/////////////////////////////////////////////////////////////
// Scale value
/////////////////////////////////////////////////////////////
define_function sinteger NAVScaleValue(
                                        sinteger value,
                                        sinteger inputRange,
                                        sinteger outputRange,
                                        sinteger offset) {
    return value * outputRange / inputRange + offset
}


/////////////////////////////////////////////////////////////
// Half range point
/////////////////////////////////////////////////////////////
define_function sinteger NAVHalfPointOfRange(sinteger top, sinteger bottom) {
    return (top - bottom) / 2 + bottom
}


/////////////////////////////////////////////////////////////
// Quarter range point
/////////////////////////////////////////////////////////////
define_function sinteger NAVQuarterPointOfRange(sinteger top, sinteger bottom) {
    return (top - bottom) / 4 + bottom
}


/////////////////////////////////////////////////////////////
// Three quarter range point
/////////////////////////////////////////////////////////////
define_function sinteger NAVThreeQuarterPointOfRange(sinteger top, sinteger bottom) {
    return (((top - bottom) / 4) * 3) + bottom
}


define_function integer NAVLow(integer value) {
    return value band $FF
}


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


define_function integer NAVIsOdd(integer value) {
    return value % 2 == 1
}


define_function integer NAVIsEven(integer value) {
    return value % 2 == 0
}


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
