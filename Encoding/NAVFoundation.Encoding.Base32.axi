PROGRAM_NAME='NAVFoundation.Encoding.Base32'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENCODING_BASE32__
#DEFINE __NAV_FOUNDATION_ENCODING_BASE32__ 'NAVFoundation.Encoding.Base32'

// #DEFINE NAV_BASE32_DEBUG  // Uncomment for debugging

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.Encoding.Base32.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'

#IF_DEFINED NAV_BASE32_DEBUG
/**
 * @function NAVBase32DebugLog
 * @private
 * @description Outputs debug log messages only when NAV_BASE32_DEBUG is defined
 *
 * @param {char} message - The message to log
 * @note This function is only compiled when NAV_BASE32_DEBUG is defined
 */
define_function NAVBase32DebugLog(char message[]) {
    NAVErrorLog(NAV_LOG_LEVEL_DEBUG, message)
}
#END_IF

/**
 * @function NAVBase32Encode
 * @public
 * @description Encodes binary data using standard Base32 encoding according to RFC 4648.
 *
 * @param {char[]} value - Binary data to encode
 *
 * @returns {char[]} Base32 encoded string
 *
 * @example
 * stack_var char binary[10]
 * stack_var char encoded[NAV_MAX_BUFFER]
 *
 * // Fill binary with some data
 * binary = "Hello!!!"
 * encoded = NAVBase32Encode(binary)  // Returns "JBSWY3DPEBLW===="
 *
 * @note Base32 encoding increases size significantly compared to the original data
 * @note This function correctly handles negative byte values (e.g., $FF = -1 in NetLinx)
 */
define_function char[NAV_MAX_BUFFER] NAVBase32Encode(char value[]) {
    stack_var integer length
    stack_var integer i, j
    stack_var integer count
    stack_var char buffer[5]  // Up to 5 bytes for 8 Base32 characters
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer bytes[5]
    stack_var integer index

    length = length_array(value)

    if (length <= 0) {
        return value
    }

    count = 0
    j = 0

    // Process input in chunks of 5 bytes (40 bits) to produce 8 Base32 chars
    for (i = 0; i < length; i++) {
        // Read next byte
        buffer[count+1] = value[i+1]
        count++

        // If we have 5 bytes, convert them to 8 Base32 chars
        if (count == 5) {
            // Convert signed chars to unsigned bytes (0-255)
            bytes[1] = type_cast(buffer[1]); if (bytes[1] < 0) bytes[1] = bytes[1] + 256
            bytes[2] = type_cast(buffer[2]); if (bytes[2] < 0) bytes[2] = bytes[2] + 256
            bytes[3] = type_cast(buffer[3]); if (bytes[3] < 0) bytes[3] = bytes[3] + 256
            bytes[4] = type_cast(buffer[4]); if (bytes[4] < 0) bytes[4] = bytes[4] + 256
            bytes[5] = type_cast(buffer[5]); if (bytes[5] < 0) bytes[5] = bytes[5] + 256

            // Byte 1: bits 1-5
            index = type_cast(((bytes[1] >> 3) & $1F)) + 1
            result[j+1] = NAV_BASE32_MAP[index]; j++

            // Byte 1: bits 6-8, Byte 2: bits 1-2
            index = type_cast((((bytes[1] & $07) << 2) | ((bytes[2] >> 6) & $03))) + 1
            result[j+1] = NAV_BASE32_MAP[index]; j++

            // Byte 2: bits 3-7
            index = type_cast(((bytes[2] >> 1) & $1F)) + 1
            result[j+1] = NAV_BASE32_MAP[index]; j++

            // Byte 2: bit 8, Byte 3: bits 1-4
            index = type_cast((((bytes[2] & $01) << 4) | ((bytes[3] >> 4) & $0F))) + 1
            result[j+1] = NAV_BASE32_MAP[index]; j++

            // Byte 3: bits 5-8, Byte 4: bit 1
            index = type_cast((((bytes[3] & $0F) << 1) | ((bytes[4] >> 7) & $01))) + 1
            result[j+1] = NAV_BASE32_MAP[index]; j++

            // Byte 4: bits 2-6
            index = type_cast(((bytes[4] >> 2) & $1F)) + 1
            result[j+1] = NAV_BASE32_MAP[index]; j++

            // Byte 4: bits 7-8, Byte 5: bits 1-3
            index = type_cast((((bytes[4] & $03) << 3) | ((bytes[5] >> 5) & $07))) + 1
            result[j+1] = NAV_BASE32_MAP[index]; j++

            // Byte 5: bits 4-8
            index = type_cast((bytes[5] & $1F)) + 1
            result[j+1] = NAV_BASE32_MAP[index]; j++

            count = 0  // Reset the counter
        }
    }

    // Handle any remaining bytes (1, 2, 3, or 4)
    if (count > 0) {
        // Initialize all bytes to 0
        bytes[1] = 0; bytes[2] = 0; bytes[3] = 0; bytes[4] = 0; bytes[5] = 0

        // Convert signed chars to unsigned bytes for the bytes we have
        for (i = 1; i <= count; i++) {
            bytes[i] = type_cast(buffer[i])
            if (bytes[i] < 0) bytes[i] = bytes[i] + 256
        }

        // Now encode based on how many bytes we have
        if (count >= 1) {
            // Byte 1: bits 1-5
            index = type_cast(((bytes[1] >> 3) & $1F)) + 1
            result[j+1] = NAV_BASE32_MAP[index]; j++

            // Byte 1: bits 6-8, Byte 2: bits 1-2 (if available)
            if (count >= 2) {
                index = type_cast((((bytes[1] & $07) << 2) | ((bytes[2] >> 6) & $03))) + 1
            } else {
                index = type_cast(((bytes[1] & $07) << 2)) + 1
            }
            result[j+1] = NAV_BASE32_MAP[index]; j++

            // Add padding or continue encoding depending on count
            if (count == 1) {
                // Only 1 byte - need 6 padding chars
                result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                result[j+1] = NAV_BASE32_PADDING_CHAR; j++
            } else if (count >= 2) {
                // Byte 2: bits 3-7
                index = type_cast(((bytes[2] >> 1) & $1F)) + 1
                result[j+1] = NAV_BASE32_MAP[index]; j++

                // Byte 2: bit 8, Byte 3: bits 1-4 (if available)
                if (count >= 3) {
                    index = type_cast((((bytes[2] & $01) << 4) | ((bytes[3] >> 4) & $0F))) + 1
                } else {
                    index = type_cast(((bytes[2] & $01) << 4)) + 1
                }
                result[j+1] = NAV_BASE32_MAP[index]; j++

                if (count == 2) {
                    // Only 2 bytes - need 4 padding chars
                    result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                    result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                    result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                    result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                } else if (count >= 3) {
                    // Byte 3: bits 5-8, Byte 4: bit 1 (if available)
                    if (count >= 4) {
                        index = type_cast((((bytes[3] & $0F) << 1) | ((bytes[4] >> 7) & $01))) + 1
                    } else {
                        index = type_cast(((bytes[3] & $0F) << 1)) + 1
                    }
                    result[j+1] = NAV_BASE32_MAP[index]; j++

                    if (count == 3) {
                        // Only 3 bytes - need 3 padding chars
                        result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                        result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                        result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                    } else if (count == 4) {
                        // Byte 4: bits 2-6
                        index = type_cast(((bytes[4] >> 2) & $1F)) + 1
                        result[j+1] = NAV_BASE32_MAP[index]; j++

                        // Byte 4: bits 7-8, Byte 5: bits 1-3 (no byte 5)
                        index = type_cast(((bytes[4] & $03) << 3)) + 1
                        result[j+1] = NAV_BASE32_MAP[index]; j++

                        // Only 4 bytes - need 1 padding char
                        result[j+1] = NAV_BASE32_PADDING_CHAR; j++
                    }
                }
            }
        }
    }

    set_length_array(result, j)
    return result
}

/**
 * @function NAVBase32GetCharValue
 * @private
 * @description Gets the 5-bit value for a Base32 character
 *
 * @param {char} c - The Base32 character
 * @returns {sinteger} The 5-bit value (0-31) or NAV_BASE32_INVALID_VALUE if invalid
 *
 * @note This function handles special cases like padding characters ('=')
 * @note Whitespace characters (CR, LF, space, tab) are skipped per RFC 4648
 * @note Invalid characters are logged with a warning
 */
define_function sinteger NAVBase32GetCharValue(char c) {
    stack_var integer i
    stack_var char description[100]

    // Handle padding character separately
    if (c == NAV_BASE32_PADDING_CHAR) {
        return 0  // Padding has special handling
    }

    // Convert lowercase to uppercase for case-insensitive matching
    if (c >= 'a' && c <= 'z') {
        c = c - 32  // ASCII conversion lowercase to uppercase
    }

    // Search in character map
    for (i = 1; i <= 32; i++) {
        if (NAV_BASE32_MAP[i] == c) {
            return type_cast(i - 1)  // Return 0-based index
        }
    }

    // Skip whitespace characters, which are allowed in Base32 per RFC
    if (c == $0D || c == $0A || c == $20 || c == $09) {
        return NAV_BASE32_INVALID_VALUE
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
                              __NAV_FOUNDATION_ENCODING_BASE32__,
                              'NAVBase32GetCharValue',
                              "'Invalid Base32 character: ', description")
    return NAV_BASE32_INVALID_VALUE
}

/**
 * @function NAVBase32Decode
 * @public
 * @description Decodes a Base32 encoded string back to binary data according to RFC 4648.
 *
 * @param {char[]} value - Base32 encoded string
 *
 * @returns {char[]} Decoded binary data
 *
 * @example
 * stack_var char encoded[20]
 * stack_var char decoded[NAV_MAX_BUFFER]
 *
 * encoded = 'JBSWY3DPEBLW===='  // Base32 for "Hello!!!"
 * decoded = NAVBase32Decode(encoded)
 *
 * @note This function handles padding ('=') characters at the end of the input
 * @note Whitespace characters (CR, LF, space, tab) are automatically ignored
 * @note Invalid characters are skipped and logged with warnings
 * @note Supports case-insensitive decoding (both 'a' and 'A' are treated the same)
 */
define_function char[NAV_MAX_BUFFER] NAVBase32Decode(char value[]) {
    stack_var integer length
    stack_var integer i, j
    stack_var integer count
    stack_var char result[NAV_MAX_BUFFER]
    stack_var sinteger charValue
    stack_var integer buffer[8]
    stack_var integer padding_count

    length = length_array(value)

    if (length <= 0) {
        return value
    }

    count = 0
    j = 0
    padding_count = 0

    // Count padding characters and check validity
    for (i = length; i >= 1; i--) {
        if (value[i] == NAV_BASE32_PADDING_CHAR) {
            padding_count++
        } else if (value[i] != $0D && value[i] != $0A && value[i] != $20 && value[i] != $09) {
            // Found a non-padding, non-whitespace character, so stop counting
            break
        }
    }

    // Process each character in the input
    for (i = 1; i <= length; i++) {
        // Skip whitespace characters (CR, LF, space, tab)
        if (value[i] == $0D || value[i] == $0A || value[i] == $20 || value[i] == $09) {
            continue
        }

        // Process padding characters
        if (value[i] == NAV_BASE32_PADDING_CHAR) {
            continue
        }

        // Get the 5-bit value for this Base32 character
        charValue = NAVBase32GetCharValue(value[i])

        // Skip invalid characters
        if (charValue == NAV_BASE32_INVALID_VALUE) {
            continue
        }

        // Add the value to our buffer
        count++
        buffer[count] = type_cast(charValue)

        // Process when we have 8 values in the buffer (40 bits = 5 bytes)
        if (count == 8) {
            // Convert back to bytes
            result[j+1] = type_cast(((buffer[1] << 3) | (buffer[2] >> 2)) & $FF); j++
            result[j+1] = type_cast(((buffer[2] << 6) | (buffer[3] << 1) | (buffer[4] >> 4)) & $FF); j++
            result[j+1] = type_cast(((buffer[4] << 4) | (buffer[5] >> 1)) & $FF); j++
            result[j+1] = type_cast(((buffer[5] << 7) | (buffer[6] << 2) | (buffer[7] >> 3)) & $FF); j++
            result[j+1] = type_cast(((buffer[7] << 5) | buffer[8]) & $FF); j++

            count = 0
        }
    }

    // Handle partial data based on padding
    if (count > 0) {
        // Handle partial decoding based on the number of valid characters and padding
        if (count >= 2) {
            result[j+1] = type_cast(((buffer[1] << 3) | (buffer[2] >> 2)) & $FF); j++

            if (count >= 4) {
                result[j+1] = type_cast(((buffer[2] << 6) | (buffer[3] << 1) | (buffer[4] >> 4)) & $FF); j++

                if (count >= 5) {
                    result[j+1] = type_cast(((buffer[4] << 4) | (buffer[5] >> 1)) & $FF); j++

                    if (count >= 7) {
                        result[j+1] = type_cast(((buffer[5] << 7) | (buffer[6] << 2) | (buffer[7] >> 3)) & $FF); j++

                        // We only use the complete byte when padding doesn't indicate the end
                        if (padding_count < 1 && count == 8) {
                            result[j+1] = type_cast(((buffer[7] << 5) | buffer[8]) & $FF); j++
                        }
                    }
                }
            }
        }
    }

    set_length_array(result, j)
    return result
}

#END_IF // __NAV_FOUNDATION_ENCODING_BASE32__
