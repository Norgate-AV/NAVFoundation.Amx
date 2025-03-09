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

// #DEFINE NAV_BASE64_DEBUG // Uncomment for debugging

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.Encoding.Base64.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'

#IF_DEFINED NAV_BASE64_DEBUG
/**
 * @function NAVBase64DebugLog
 * @private
 * @description Outputs debug log messages only when NAV_BASE64_DEBUG is defined
 *
 * @param {char} message - The message to log
 * @note This function is only compiled when NAV_BASE64_DEBUG is defined
 */
define_function NAVBase64DebugLog(char message[]) {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, message)
}
#END_IF

/**
 * @function NAVBase64Encode
 * @public
 * @description Encodes binary data using standard Base64 encoding according to RFC 4648.
 *
 * @param {char[]} value - Binary data to encode
 *
 * @returns {char[]} Base64 encoded string
 *
 * @example
 * stack_var char binary[10]
 * stack_var char encoded[NAV_MAX_BUFFER]
 *
 * // Fill binary with some data
 * binary = "$01, $02, $03, $04, $05, $FF, $FE, $FD, $FC, $FB"
 * encoded = NAVBase64Encode(binary)  // Returns "AQIDBP/+/fw7"
 *
 * @note Base64 encoding increases size by approximately 33% (4 output bytes for every 3 input bytes)
 * @note This function correctly handles negative byte values (e.g., $FF = -1 in NetLinx)
 */
define_function char[NAV_MAX_BUFFER] NAVBase64Encode(char value[]) {
    stack_var integer count
    stack_var char buffer[3]
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer i
    stack_var integer j
    stack_var integer b1, b2, b3 // Use integer variables for calculations

    length = length_array(value)

    #IF_DEFINED NAV_BASE64_DEBUG
    NAVBase64DebugLog("'Encoding input of length: ', itoa(length)")

    // Log the hex values of all input bytes for binary data tests
    if (length <= 20) {  // Only for reasonably small inputs
        stack_var char hexLog[NAV_MAX_BUFFER]
        hexLog = "'Input bytes: '"
        for (i = 1; i <= length; i++) {
            hexLog = "hexLog, ' 0x', format('%02X', value[i])"
        }
        NAVBase64DebugLog(hexLog)
    }
    #END_IF

    if (length <= 0) {
        return value
    }

    count = 0
    j = 0

    for (i = 0; i < length; i++) {
        // Calculate the Base64 indices
        stack_var integer idx1, idx2, idx3, idx4

        buffer[(count + 1)] = value[(i + 1)]
        count++

        if (count < 3) {
            continue
        }

        #IF_DEFINED NAV_BASE64_DEBUG
        // Log the three bytes being processed
        NAVBase64DebugLog("'Processing bytes: 0x', format('%02X', buffer[1]),
                          ' 0x', format('%02X', buffer[2]),
                          ' 0x', format('%02X', buffer[3])")
        #END_IF

        // Convert signed chars to unsigned integers by adding 256 to negative values
        b1 = type_cast(buffer[1])
        if (b1 < 0) {
            b1 = b1 + 256
            #IF_DEFINED NAV_BASE64_DEBUG
            NAVBase64DebugLog("'Adjusted b1 from negative to: ', itoa(b1)")
            #END_IF
        }

        b2 = type_cast(buffer[2])
        if (b2 < 0) {
            b2 = b2 + 256
            #IF_DEFINED NAV_BASE64_DEBUG
            NAVBase64DebugLog("'Adjusted b2 from negative to: ', itoa(b2)")
            #END_IF
        }

        b3 = type_cast(buffer[3])
        if (b3 < 0) {
            b3 = b3 + 256
            #IF_DEFINED NAV_BASE64_DEBUG
            NAVBase64DebugLog("'Adjusted b3 from negative to: ', itoa(b3)")
            #END_IF
        }

        #IF_DEFINED NAV_BASE64_DEBUG
        // Log the byte values after adjustment
        NAVBase64DebugLog("'Adjusted values: b1=', itoa(b1), ' b2=', itoa(b2), ' b3=', itoa(b3)")
        #END_IF

        idx1 = type_cast((b1 >> 2) + 1)
        idx2 = type_cast((((b1 & $03) << 4) | ((b2 >> 4) & $0F)) + 1)
        idx3 = type_cast((((b2 & $0F) << 2) | ((b3 >> 6) & $03)) + 1)
        idx4 = type_cast((b3 & $3F) + 1)

        #IF_DEFINED NAV_BASE64_DEBUG
        // Log the indices and characters
        NAVBase64DebugLog("'Base64 indices: ', itoa(idx1), ' ', itoa(idx2), ' ', itoa(idx3), ' ', itoa(idx4)")
        NAVBase64DebugLog("'Base64 chars: ', NAV_BASE64_MAP[idx1], NAV_BASE64_MAP[idx2], NAV_BASE64_MAP[idx3], NAV_BASE64_MAP[idx4]")
        #END_IF

        result[(j + 1)] = type_cast(NAV_BASE64_MAP[idx1]); j++
        result[(j + 1)] = type_cast(NAV_BASE64_MAP[idx2]); j++
        result[(j + 1)] = type_cast(NAV_BASE64_MAP[idx3]); j++
        result[(j + 1)] = type_cast(NAV_BASE64_MAP[idx4]); j++

        count = 0
    }

    // Process any remaining bytes (1 or 2)
    if (count > 0) {
        stack_var integer idx1, idx2, idx3

        #IF_DEFINED NAV_BASE64_DEBUG
        NAVBase64DebugLog("'Processing remaining bytes: ', itoa(count)")
        #END_IF

        b1 = type_cast(buffer[1])
        if (b1 < 0) {
            b1 = b1 + 256
            #IF_DEFINED NAV_BASE64_DEBUG
            NAVBase64DebugLog("'Adjusted remaining b1 from negative to: ', itoa(b1)")
            #END_IF
        }

        idx1 = type_cast((b1 >> 2) + 1)

        #IF_DEFINED NAV_BASE64_DEBUG
        // Log the first index and character
        NAVBase64DebugLog("'First index: ', itoa(idx1), ' char: ', NAV_BASE64_MAP[idx1]")
        #END_IF

        result[(j + 1)] = type_cast(NAV_BASE64_MAP[idx1]); j++

        if (count == 1) {
            idx2 = type_cast((((b1 & $03) << 4) & $3F) + 1)
            #IF_DEFINED NAV_BASE64_DEBUG
            NAVBase64DebugLog("'Second index (1 remaining byte): ', itoa(idx2), ' char: ', NAV_BASE64_MAP[idx2]")
            #END_IF

            result[(j + 1)] = type_cast(NAV_BASE64_MAP[idx2]); j++
            result[(j + 1)] = NAV_BASE64_PADDING_CHAR; j++
        }
        else {
            b2 = type_cast(buffer[2])
            if (b2 < 0) {
                b2 = b2 + 256
                #IF_DEFINED NAV_BASE64_DEBUG
                NAVBase64DebugLog("'Adjusted remaining b2 from negative to: ', itoa(b2)")
                #END_IF
            }

            idx2 = type_cast((((b1 & $03) << 4) | ((b2 >> 4) & $0F)) + 1)
            idx3 = type_cast((((b2 & $0F) << 2) & $3F) + 1)

            #IF_DEFINED NAV_BASE64_DEBUG
            NAVBase64DebugLog("'Second index (2 remaining bytes): ', itoa(idx2), ' char: ', NAV_BASE64_MAP[idx2]")
            NAVBase64DebugLog("'Third index (2 remaining bytes): ', itoa(idx3), ' char: ', NAV_BASE64_MAP[idx3]")
            #END_IF

            result[(j + 1)] = type_cast(NAV_BASE64_MAP[idx2]); j++
            result[(j + 1)] = type_cast(NAV_BASE64_MAP[idx3]); j++
        }

        result[(j + 1)] = NAV_BASE64_PADDING_CHAR; j++
    }

    set_length_array(result, j)

    #IF_DEFINED NAV_BASE64_DEBUG
    NAVBase64DebugLog("'Output: "', result, '"'")
    #END_IF

    return result
}


/**
 * @function NAVBase64GetCharValue
 * @private
 * @description Gets the 6-bit value for a Base64 character
 *
 * @param {char} c - The Base64 character
 * @returns {sinteger} The 6-bit value (0-63) or NAV_BASE64_INVALID_VALUE if invalid
 *
 * @note This function handles special cases like padding characters ('=')
 * @note Whitespace characters (CR, LF, space, tab) are skipped per RFC 4648
 * @note Invalid characters are logged with a warning
 */
define_function sinteger NAVBase64GetCharValue(char c) {
    stack_var integer i
    stack_var char description[100]

    // Handle padding character separately
    if (c == NAV_BASE64_PADDING_CHAR) {
        return 0  // Padding has special handling
    }

    // Search in character map
    for (i = 1; i <= 64; i++) {
        if (NAV_BASE64_MAP[i] == c) {
            return type_cast(i - 1)  // Return 0-based index
        }
    }

    // Skip whitespace characters, which are allowed in Base64 per RFC
    if (c == $0D || c == $0A || c == $20 || c == $09) {
        return NAV_BASE64_INVALID_VALUE
    }

    // Format character description based on whether it's printable or not
    if (c >= 32 && c <= 126) {
        // Printable ASCII character
        description = "'"', c, '"', ' (', itoa(c), ')'"
    } else {
        // Non-printable character, show hex value
        description = "'$', format('%02X', c), ' (', itoa(c), ')'"
    }

    // Invalid character
    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                              __NAV_FOUNDATION_ENCODING_BASE64__,
                              'NAVBase64GetCharValue',
                              "'Invalid Base64 character: ', description")
    return NAV_BASE64_INVALID_VALUE
}

/**
 * @function NAVBase64Decode
 * @public
 * @description Decodes a Base64 encoded string back to binary data according to RFC 4648.
 *
 * @param {char[]} value - Base64 encoded string
 *
 * @returns {char[]} Decoded binary data
 *
 * @example
 * stack_var char encoded[20]
 * stack_var char decoded[NAV_MAX_BUFFER]
 *
 * encoded = 'SGVsbG8gV29ybGQ='  // Base64 for "Hello World"
 * decoded = NAVBase64Decode(encoded)
 *
 * @note This function handles padding ('=') characters at the end of the input
 * @note Whitespace characters (CR, LF, space, tab) are automatically ignored
 * @note Invalid characters are skipped and logged with warnings
 * @note Handles partial quartets appropriately with proper bit shifting
 */
define_function char[NAV_MAX_BUFFER] NAVBase64Decode(char value[]) {
    stack_var integer count
    stack_var integer buffer[4]
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer i, j, index
    stack_var sinteger charValue

    length = length_array(value)

    if (length <= 0) {
        return value
    }

    count = 0
    j = 0

    // Process each character in the input
    for (i = 1; i <= length; i++) {
        // Skip whitespace characters (CR, LF, space, tab)
        if (value[i] == $0D || value[i] == $0A || value[i] == $20 || value[i] == $09) {
            continue
        }

        // Process padding characters
        if (value[i] == NAV_BASE64_PADDING_CHAR) {
            continue
        }

        // Get the 6-bit value for this Base64 character
        charValue = NAVBase64GetCharValue(value[i])

        // Skip invalid characters
        if (charValue == NAV_BASE64_INVALID_VALUE) {
            continue
        }

        // Add the value to our buffer
        count++
        buffer[count] = type_cast(charValue)

        // Process when we have 4 values in the buffer
        if (count == 4) {
            // First byte (6 bits from first char + 2 bits from second char)
            result[j+1] = type_cast(((buffer[1] << 2) | (buffer[2] >> 4)) & $FF);
            j++

            // Second byte (4 bits from second char + 4 bits from third char)
            result[j+1] = type_cast(((buffer[2] << 4) | (buffer[3] >> 2)) & $FF);
            j++

            // Third byte (2 bits from third char + 6 bits from fourth char)
            result[j+1] = type_cast(((buffer[3] << 6) | buffer[4]) & $FF);
            j++

            count = 0
        }
    }

    // Handle any remaining bytes from partial quartets
    if (count > 0) {
        // For 2 values: we have 8 bits total which makes 1 byte
        if (count == 2) {
            result[j+1] = type_cast(((buffer[1] << 2) | (buffer[2] >> 4)) & $FF);
            j++;
        }
        // For 3 values: we have 16 bits total which makes 2 bytes
        else if (count == 3) {
            result[j+1] = type_cast(((buffer[1] << 2) | (buffer[2] >> 4)) & $FF);
            j++;
            result[j+1] = type_cast(((buffer[2] << 4) | (buffer[3] >> 2)) & $FF);
            j++;
        }
    }

    set_length_array(result, j)
    return result
}

#END_IF // __NAV_FOUNDATION_ENCODING_BASE64__
