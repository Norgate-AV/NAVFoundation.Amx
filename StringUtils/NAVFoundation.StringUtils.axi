PROGRAM_NAME='NAVFoundation.StringUtils'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2022 Norgate AV Solutions Ltd

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

#IF_NOT_DEFINED __NAV_FOUNDATION_STRINGUTILS__
#DEFINE __NAV_FOUNDATION_STRINGUTILS__

#include 'NAVFoundation.Core.axi'


DEFINE_CONSTANT

constant integer NAV_CASE_INSENSITIVE =   0
constant integer NAV_CASE_SENSITIVE =     1


define_function char[NAV_MAX_BUFFER] NAVStripCharsFromRight(char buffer[], integer count) {
    return left_string(buffer, length_array(buffer) - count)
}


define_function char[NAV_MAX_BUFFER] NAVStripRight(char buffer[], integer count) {
    return left_string(buffer, length_array(buffer) - count)
}


define_function char[NAV_MAX_BUFFER] NAVStripCharsFromLeft(char buffer[], integer count) {
    return right_string(buffer, length_array(buffer) - count)
}


define_function char[NAV_MAX_BUFFER] NAVStripLeft(char buffer[], integer count) {
    return right_string(buffer, length_array(buffer) - count)
}


define_function char[NAV_MAX_BUFFER] NAVRemoveStringByLength(char buffer[], integer count) {
    return remove_string(buffer, left_string(buffer, count), 1)
}


define_function char[NAV_MAX_BUFFER] NAVStringSubstring(char buffer[], integer index, integer count) {
    return mid_string(buffer, index, count)
}


define_function char[NAV_MAX_BUFFER] NAVFindAndReplace(char buffer[], char match[], char value[]) {
    stack_var integer index
    stack_var char result[NAV_MAX_BUFFER]

    result = buffer

    while (NAVContains(result, match)) {
        index = NAVIndexOf(result, match, 1) - 1

        result = "left_string(buffer, index), value, NAVStripLeft(buffer, index)"
    }

    return result
}


define_function integer NAVStringCount(char buffer[], char value[], integer caseSensitivity) {
    stack_var integer x
    stack_var integer index
    stack_var integer result
    stack_var char tempBuffer[65534]
    stack_var char tempValue[NAV_MAX_BUFFER]

    result = 0

    if (!length_array(buffer) || !length_array(value)) {
        return result
    }

    tempBuffer = buffer
    tempValue = value

    if (caseSensitivity = NAV_CASE_INSENSITIVE) {
        tempBuffer = lower_string(tempBuffer)
        tempValue = lower_string(tempValue)
    }

    for (x = 1; x <= length_array(tempBuffer); x++) {
        index = NAVIndexOf(tempBuffer, tempValue, x)

        if (index) {
            result++
            x = (index + length_array(tempValue))
        }
    }

    return result
}


define_function integer NAVIsWhitespace(integer byte) {
    return (byte == $20 || byte == $0D || byte == $0A || byte == $09 || byte == $0B || byte == $0C)
}


define_function char[NAV_MAX_BUFFER] NAVTrimStringLeft(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer count
    stack_var integer byte

    result = buffer

    for (count = 1; count <= length_array(result); count++) {
        byte = result[count]

        if (!NAVIsWhitespace(byte)) {
            break
        }
    }

    if(count > 1) {
        result = NAVStripCharsFromLeft(result, count - 1)
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVTrimStringRight(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer count
    stack_var integer byte
    stack_var integer length

    result = buffer
    length = length_array(result)

    for (count = length; count > 1; count--) {
        byte = result[count]

        if (!NAVIsWhitespace(byte)) {
            break
        }
    }

    if(count < length) {
        result = NAVStripCharsFromRight(result, length - count)
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVTrimString(char buffer[]) {
    return NAVTrimStringLeft(NAVTrimStringRight(buffer))
}


define_function NAVTrimStringArray(char array[][]) {
    stack_var integer length
    stack_var integer x

    length = length_array(array)

    for(x = 1; x <= length; x++) {
        array[x] = NAVTrimString(array[x])
    }
}


define_function char[NAV_MAX_BUFFER] NAVGetStringBefore(char buffer[], char token[]) {
    stack_var integer index

    if (!length_array(buffer) || !length_array(token)) {
        return buffer
    }

    index = NAVIndexOf(buffer, token, 1)

    if (index == 0) {
        return buffer
    }

    return NAVStringSubstring(buffer, 1, index - 1)
}


define_function char[NAV_MAX_BUFFER] NAVGetStringAfter(char buffer[], char token[]) {
    stack_var integer index

    if (!length_array(buffer) || !length_array(token)) {
        return buffer
    }

    index = NAVIndexOf(buffer, token, 1)

    if (index == 0) {
        return buffer
    }

    return NAVStringSubstring(buffer, index + length_array(token), length_array(buffer))
}


define_function char[NAV_MAX_BUFFER] NAVGetStringBetween(char buffer[], char token1[], char token2[]) {
    stack_var integer tokenIndex[2]
    stack_var integer startIndex
    stack_var char result[NAV_MAX_BUFFER]

    result = ""

    if(!length_array(buffer)) {
        return result
    }

    tokenIndex[1] = NAVIndexOf(buffer, token1, 1)

    if (!tokenIndex[1]) {
        return result
    }

    startIndex = tokenIndex[1] + length_array(token1)
    tokenIndex[2] = NAVIndexOf(buffer, token2, startIndex)

    if (!tokenIndex[2]) {
        return result
    }

    if (tokenIndex[1] < tokenIndex[2]) {
        result = mid_string(buffer, startIndex, tokenIndex[2] - tokenIndex[1])
    }

    return result
}


define_function integer NAVStartsWith(char buffer[], char match[]) {
    return (find_string(buffer, match, 1) == 1)
}


define_function integer NAVContains(char buffer[], char match[]) {
    return (find_string(buffer, match, 1) > 0)
}


define_function integer NAVEndsWith(char buffer[], char match[]) {
    return (find_string(buffer, match, 1) == length_array(buffer) - length_array(match) + 1)
}


define_function integer NAVIndexOf(char buffer[], char match[], integer tokenIndex) {
    return find_string(buffer, match, tokenIndex)
}


define_function integer NAVSplitString(char buffer[], char separator[], char result[][]) {
    stack_var char bufferCopy[NAV_MAX_BUFFER]
    stack_var integer count
    stack_var char token[NAV_MAX_BUFFER]

    count = 0

    if (!NAVContains(buffer, separator)) {
        return count
    }

    bufferCopy = buffer

    while (NAVContains(bufferCopy, separator)) {
        token = NAVStripCharsFromRight(remove_string(bufferCopy, separator, 1), length_array(separator))

        if (!length_array(token)) {
            continue
        }

        count++
        set_length_array(result, count)
        result[count] = token
    }

    if (!length_array(bufferCopy)) {
        return count
    }

    count++
    set_length_array(result, count)
    result[count] = bufferCopy

    return count
}


define_function char[NAV_MAX_BUFFER] NAVArrayJoinString(char array[][], char separator[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x

    length = length_array(array)

    if (!length) {
        return result
    }

    if (!length_array(separator)) {
        separator = ' '
    }

    result = array[1]

    for (x = 2; x <= length; x++) {
        result = "result, separator, array[x]"
    }

    return result
}


define_function long NAVStringToLongMilliseconds(char duration[]) {
    stack_var long result
    stack_var char timeFormat[1]
    stack_var integer value
    stack_var char durationCopy[NAV_MAX_CHARS]

    result = 0
    if (!length_array(duration)) {
        return result
    }

    durationCopy = duration
    timeFormat = right_string(durationCopy, 1)
    durationCopy = NAVStripCharsFromRight(durationCopy, 1)

    value = atoi(durationCopy);

    switch (lower_string(timeFormat)) {
        case 'h': {
            result = value * 3600000
        }
        case 'm': {
            result = value * 60000
        }
        case 's': {
            result = value * 1000
        }
        default: {
            NAVLog("'An invalid format ("', timeFormat, '") was specified. Valid format is hours (H/h), minutes (M/m), or seconds (S/s)'")
        }
    }

    return result
}


define_function char[NAV_MAX_CHARS] NAVGetTimeSpan(long value) {
    stack_var long milliseconds
    stack_var long seconds
    stack_var long minutes
    stack_var long hours
    stack_var char result[NAV_MAX_CHARS]

    milliseconds = value % 1000
    seconds = value / 1000
    minutes = seconds / 60 % 60
    hours = minutes / 60 % 60

    result = "itoa(seconds), 's ', itoa(milliseconds % 1000), 'ms'"

    if (minutes > 0) {
        result = "itoa(minutes), 'm ', result"
    }

    if (hours > 0) {
        result = "itoa(hours), 'h ', result"
    }

    return result
}


define_function sinteger NAVStringCompare(char string1[], char string2[]) {
    stack_var integer x

    x = 1
    while (x <= length_array(string1)) {
        if (string1[x] != string2[x]) {
            break
        }

        x++
    }

    return string1[x] - string2[x]
}


define_function char[NAV_MAX_BUFFER] NAVStringSurroundWith(char buffer[], char left[], char right[]) {
    return "left, buffer, right"
}


#END_IF // __NAV_FOUNDATION_STRINGUTILS__
