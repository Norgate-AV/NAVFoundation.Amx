PROGRAM_NAME='NAVFoundation.StringUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_STRINGUTILS__
#DEFINE __NAV_FOUNDATION_STRINGUTILS__ 'NAVFoundation.StringUtils'

#include 'NAVFoundation.Core.axi'


// #DEFINE USING_NAV_STRING_GATHER_CALLBACK
// define_function NAVStringGatherCallback(_NAVStringGatherResult args) {}


define_function char[NAV_MAX_BUFFER] NAVStripCharsFromRight(char buffer[], integer count) {
    stack_var integer length

    length = length_array(buffer)

    if (count <= 0 || !length) {
        return buffer
    }

    if (count >= length) {
        return buffer
    }

    return left_string(buffer, length_array(buffer) - count)
}


define_function char[NAV_MAX_BUFFER] NAVStripRight(char buffer[], integer count) {
    return NAVStripCharsFromRight(buffer, count)
}


define_function char[NAV_MAX_BUFFER] NAVStripCharsFromLeft(char buffer[], integer count) {
    stack_var integer length

    length = length_array(buffer)

    if (count <= 0 || !length) {
        return buffer
    }

    if (count >= length) {
        return buffer
    }

    return right_string(buffer, length_array(buffer) - count)
}


define_function char[NAV_MAX_BUFFER] NAVStripLeft(char buffer[], integer count) {
    return NAVStripCharsFromLeft(buffer, count)
}


define_function char[NAV_MAX_BUFFER] NAVRemoveStringByLength(char buffer[], integer count) {
    stack_var integer length

    length = length_array(buffer)

    if (count <= 0 || !length) {
        return buffer
    }

    if (count >= length) {
        return buffer
    }

    return remove_string(buffer, left_string(buffer, count), 1)
}


define_function char[NAV_MAX_BUFFER] NAVStringSubstring(char buffer[], integer start, integer count) {
    stack_var integer length

    length = length_array(buffer)

    if (start <= 0 || start > length) {
        return ''
    }

    if (count < 0) {
        return ''
    }

    if (count > 0) {
        return mid_string(buffer, start, count)
    }

    return mid_string(buffer, start, (length - start) + 1)
}


define_function char[NAV_MAX_BUFFER] NAVStringSlice(char buffer[], integer start, integer end) {
    if (start <= 0 || start > length_array(buffer)) {
        return ''
    }

    if (end == 0) {
        return NAVStringSubstring(buffer, start, end)
    }

    if (end < start) {
        return ''
    }

    if ((end - start) <= 0) {
        return ''
    }

    return NAVStringSubstring(buffer, start, end - start)
}


define_function char[NAV_MAX_BUFFER] NAVFindAndReplace(char buffer[], char match[], char value[]) {
    stack_var integer index
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer matchLength

    matchLength = length_array(match)

    if (!length_array(buffer) || !matchLength) {
        return buffer
    }

    result = buffer

    if (!NAVContains(result, match)) {
        return result
    }

    while (NAVContains(result, match)) {
        index = NAVIndexOf(result, match, 1)

        if (index == 1) {
            result = "value, right_string(result, length_array(result) - matchLength)"
            continue
        }

        result = "left_string(result, index - 1), value, right_string(result, (length_array(result) - (index + matchLength)) + 1)"
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVStringReplace(char buffer[], char match[], char value[]) {
    return NAVFindAndReplace(buffer, match, value)
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

    if (caseSensitivity == NAV_CASE_INSENSITIVE) {
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


define_function char NAVIsWhitespace(char byte) {
    return (
        (byte == NAV_NULL) ||
        (byte == NAV_TAB) ||
        (byte == NAV_LF)||
        (byte == NAV_VT) ||
        (byte == NAV_FF) ||
        (byte == NAV_CR) ||
        (byte == ' ')
    )
}


define_function char NAVIsSpace(char byte) {
    return NAVIsWhitespace(byte)
}


define_function char NAVIsAlpha(char byte) {
    return (
        ((byte >= 'a') && (byte <= 'z')) ||
        ((byte >= 'A') && (byte <= 'Z'))
    )
}


define_function char NAVIsDigit(char byte) {
    return ((byte >= '0') && (byte <= '9'))
}


define_function char NAVIsAlphaNumeric(char byte) {
    return (
        NAVIsAlpha(byte) ||
        NAVIsDigit(byte) ||
        (byte == '_')
    )
}


define_function char[NAV_MAX_BUFFER] NAVTrimStringLeft(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer count
    stack_var char byte

    result = buffer

    for (count = 1; count <= length_array(result); count++) {
        byte = NAVCharCodeAt(result, count)

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
    stack_var char byte
    stack_var integer length

    result = buffer
    length = length_array(result)

    for (count = length; count > 1; count--) {
        byte = NAVCharCodeAt(result, count)

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


define_function char[NAV_MAX_BUFFER] NAVStringBefore(char buffer[], char token[]) {
    return NAVGetStringBefore(buffer, token)
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


define_function char[NAV_MAX_BUFFER] NAVStringAfter(char buffer[], char token[]) {
    return NAVGetStringAfter(buffer, token)
}


define_function char[NAV_MAX_BUFFER] NAVGetStringBetween(char buffer[], char token1[], char token2[]) {
    stack_var integer tokenIndex[2]
    stack_var integer startIndex
    stack_var integer count

    if(!length_array(buffer)) {
        return ''
    }

    tokenIndex[1] = NAVIndexOf(buffer, token1, 1)

    if (!tokenIndex[1]) {
        return ''
    }

    startIndex = tokenIndex[1] + length_array(token1)
    tokenIndex[2] = NAVIndexOf(buffer, token2, startIndex)

    if (!tokenIndex[2]) {
        return ''
    }

    if (tokenIndex[1] >= tokenIndex[2]) {
        return ''
    }

    count = tokenIndex[2] - startIndex

    if (count <= 0) {
        return ''
    }

    return NAVStringSubstring(buffer, startIndex, count)
}


define_function char[NAV_MAX_BUFFER] NAVStringBetween(char buffer[], char token1[], char token2[]) {
    return NAVGetStringBetween(buffer, token1, token2)
}


/**
 * Get the string between two tokens
 * Greedy will return the string between the token1 and the "last" occurance of token2
 */
define_function char[NAV_MAX_BUFFER] NAVGetStringBetweenGreedy(char buffer[], char token1[], char token2[]) {
    stack_var integer tokenIndex[2]
    stack_var integer startIndex
    stack_var integer count

    if(!length_array(buffer)) {
        return ''
    }

    tokenIndex[1] = NAVIndexOf(buffer, token1, 1)

    if (!tokenIndex[1]) {
        return ''
    }

    startIndex = tokenIndex[1] + length_array(token1)
    tokenIndex[2] = NAVLastIndexOf(buffer, token2)

    if (!tokenIndex[2]) {
        return ''
    }

    if (tokenIndex[1] >= tokenIndex[2]) {
        return ''
    }

    count = tokenIndex[2] - startIndex

    if (count <= 0) {
        return ''
    }

    return NAVStringSubstring(buffer, startIndex, count)
}


define_function char[NAV_MAX_BUFFER] NAVStringBetweenGreedy(char buffer[], char token1[], char token2[]) {
    return NAVGetStringBetweenGreedy(buffer, token1, token2)
}


define_function char NAVStartsWith(char buffer[], char match[]) {
    return (find_string(buffer, match, 1) == 1)
}


define_function char NAVStringStartsWith(char buffer[], char match[]) {
    return NAVStartsWith(buffer, match)
}


define_function char NAVContains(char buffer[], char match[]) {
    return (find_string(buffer, match, 1) > 0)
}


define_function char NAVStringContains(char buffer[], char match[]) {
    return NAVContains(buffer, match)
}


define_function char NAVEndsWith(char buffer[], char match[]) {
    return right_string(buffer, length_array(match)) == match
}


define_function char NAVStringEndsWith(char buffer[], char match[]) {
    return NAVEndsWith(buffer, match)
}


define_function integer NAVIndexOf(char buffer[], char match[], integer start) {
    if (start <= 0 || start > length_array(buffer)) {
        return 0
    }

    return find_string(buffer, match, start)
}


define_function integer NAVLastIndexOf(char buffer[], char match[]) {
    stack_var integer index
    stack_var integer next

    index = NAVIndexOf(buffer, match, 1)

    if (!index) {
        return 0
    }

    while (index > 0) {
        next = NAVIndexOf(buffer, match, index + 1)

        if (!next) {
            break
        }

        index = next
    }

    return index
}


define_function integer NAVSplitString(char buffer[], char separator[], char result[][]) {
    stack_var char bufferCopy[NAV_MAX_BUFFER]
    stack_var integer count
    stack_var char token[NAV_MAX_BUFFER]

    count = 0

    if (!length_array(buffer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVSplitString',
                                    'Invalid argument. The provided argument "buffer" is an empty string')

        return count
    }

    if (!length_array(separator)) {
        separator = ' '
    }

    if (!NAVContains(buffer, separator)) {
        count++
        set_length_array(result, count)
        result[count] = buffer
        return count
    }

    bufferCopy = buffer

    while (NAVContains(bufferCopy, separator)) {
        token = NAVStripCharsFromRight(remove_string(bufferCopy, separator, 1), length_array(separator))

        if (!length_array(token)) {
            continue
        }

        count++
        result[count] = token
    }

    if (!length_array(bufferCopy)) {
        set_length_array(result, count)
        return count
    }

    count++
    result[count] = bufferCopy
    set_length_array(result, count)

    return count
}


define_function char[NAV_MAX_BUFFER] NAVArrayJoinString(char array[][], char separator[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x

    result = ""

    length = length_array(array)

    if (!length) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVArrayJoinString',
                                    'Invalid argument. The provided argument "array" is empty array')

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
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_STRINGUTILS__,
                                    'NAVStringToLongMilliseconds',
                                    'Invalid argument. The provided argument "duration" is an empty string')

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
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_STRINGUTILS__,
                                        'NAVStringToLongMilliseconds',
                                        "'An invalid format (', timeFormat, ') was specified. Valid format is hours (H/h), minutes (M/m), or seconds (S/s)'")
        }
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVGetTimeSpan(double value) {
    stack_var long milliseconds
    stack_var long seconds
    stack_var long minutes
    stack_var long hours
    stack_var long years
    stack_var long months
    stack_var long days
    stack_var char result[NAV_MAX_BUFFER]

    milliseconds = type_cast(value % 1000)
    seconds = type_cast(value / 1000 % 60)
    minutes = type_cast(value / 60000 % 60)
    hours = type_cast(value / 3600000 % 24)
    days = type_cast(value / 86400000 % 30)
    months = type_cast(value / 2629746000 % 12)
    years = type_cast(value / 31556952000)

    result = "itoa(seconds), 's ', itoa(milliseconds), 'ms'"

    if (minutes > 0) {
        result = "itoa(minutes), 'm ', result"
    }

    if (hours > 0) {
        result = "itoa(hours), 'h ', result"
    }

    if (days > 0) {
        result = "itoa(days), 'd ', result"
    }

    if (months > 0) {
        result = "itoa(months), 'mo ', result"
    }

    if (years > 0) {
        result = "itoa(years), 'y ', result"
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


define_function char[NAV_MAX_BUFFER] NAVStringSurround(char buffer[], char left[], char right[]) {
    return "left, buffer, right"
}


define_function NAVStringGather(_NAVRxBuffer buffer, char delimiter[]) {
    stack_var char data[NAV_MAX_BUFFER]

    if (buffer.Semaphore) {
        return
    }

    buffer.Semaphore = true

    while (length_array(buffer.Data) && NAVContains(buffer.Data, delimiter)) {
        data = remove_string(buffer.Data, delimiter, 1)

        if (!length_array(data)) {
            continue
        }

        #IF_DEFINED USING_NAV_STRING_GATHER_CALLBACK
        if (true) {
            stack_var _NAVStringGatherResult result

            result.Data = data
            result.Delimiter = delimiter

            NAVStringGatherCallback(result)
        }
        #END_IF
    }

    buffer.Semaphore = false
}


define_function char[NAV_MAX_BUFFER] NAVStringCapitalize(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var char byte

    result = buffer
    length = length_array(result)

    if (!length) {
        return result
    }

    result[1] = result[1] - 32

    for (x = 2; x <= length; x++) {
        byte = result[x]

        if (byte != $20) {
            continue
        }

        result[x + 1] = result[x + 1] - 32
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVStringPascalCase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var integer byte

    result = buffer
    length = length_array(result)

    if (!length) {
        return result
    }

    result[1] = result[1] - 32

    for (x = 2; x <= length; x++) {
        byte = result[x]

        if (byte != $20 && byte != $2D && byte != $5F) {
            continue
        }

        result[x + 1] = result[x + 1] - 32
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVStringCamelCase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var integer byte

    result = buffer
    length = length_array(result)

    if (!length) {
        return result
    }

    result[1] = result[1] + 32

    for (x = 2; x <= length; x++) {
        byte = result[x]

        if (byte != $20 && byte != $2D && byte != $5F) {
            continue
        }

        result[x + 1] = result[x + 1] - 32
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVStringSnakeCase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var integer byte

    result = lower_string(buffer)
    length = length_array(result)

    if (!length) {
        return result
    }

    for (x = 1; x <= length; x++) {
        byte = result[x]

        if (byte != $20 && byte != $2D) {
            continue
        }

        result[x] = $5F
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVStringKebabCase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var integer byte

    result = lower_string(buffer)
    length = length_array(result)

    if (!length) {
        return result
    }

    for (x = 1; x <= length; x++) {
        byte = result[x]

        if (byte != $20 && byte != $5F) {
            continue
        }

        result[x] = $2D
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVStringScreamKebabCase(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var integer byte

    result = upper_string(buffer)
    length = length_array(result)

    if (!length) {
        return result
    }

    for (x = 1; x <= length; x++) {
        byte = result[x]

        if (byte != $20 && byte != $5F) {
            continue
        }

        result[x] = $2D
    }

    return result
}


define_function char[NAV_MAX_BUFFER] NAVStringReverse(char buffer[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer x
    stack_var integer y

    result = buffer
    length = length_array(result)

    if (!length) {
        return result
    }

    for (x = 1, y = length; x <= length; x++, y--) {
        result[x] = buffer[y]
    }

    return result
}


define_function char NAVCharCodeAt(char buffer[], integer index) {
    if (index <= 0 || index > length_array(buffer)) {
        return 0
    }

    return buffer[index]
}


#END_IF // __NAV_FOUNDATION_STRINGUTILS__
