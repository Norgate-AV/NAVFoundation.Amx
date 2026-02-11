PROGRAM_NAME='NAVFoundation.Encoding.Base64Url'

/*
 _   _                       _          ___     __
| \ | | ___  _ __ __ _  __ _| |_ ___   / \ \   / /
|  \| |/ _ \| '__/ _` |/ _` | __/ _ \ / _ \ \ / /
| |\  | (_) | | | (_| | (_| | ||  __// ___ \ V /
|_| \_|\___/|_|  \__, |\__,_|\__\___/_/   \_\_/
                 |___/

MIT License

Copyright (c) 2010-2026 Norgate AV

Permission is hereby granted, free of charge, to any person obtaining a valueCopy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, valueCopy, modify, merge, publish, distribute, sublicense, and/or sell
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

#IF_NOT_DEFINED __NAV_FOUNDATION_ENCODING_BASE64URL__
#DEFINE __NAV_FOUNDATION_ENCODING_BASE64URL__ 'NAVFoundation.Encoding.Base64Url'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.Encoding.Base64Url.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


/**
 * @function NAVBase64UrlEncode
 * @public
 * @description Encodes binary data using URL-safe Base64 encoding (Base64Url) according to RFC 4648 Section 5.
 * This encoding is required for JWT tokens and other URL-safe applications.
 * Padding is omitted by default as per JWT specification (RFC 7515).
 *
 * @param {char[]} value - Binary data to encode
 *
 * @returns {char[]} Base64Url encoded string without padding
 *
 * @example
 * stack_var char binary[10]
 * stack_var char encoded[NAV_MAX_BUFFER]
 *
 * binary = 'Hello!'
 * encoded = NAVBase64UrlEncode(binary)  // Returns "SGVsbG8h" (no padding)
 *
 * @note Base64Url replaces '+' with '-' and '/' with '_' from standard Base64
 * @note Padding ('=') is omitted for JWT compatibility
 * @note For padded output, use NAVBase64UrlEncodePadded()
 */
define_function char[NAV_MAX_BUFFER] NAVBase64UrlEncode(char value[]) {
    stack_var integer count
    stack_var char buffer[3]
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer i
    stack_var integer j
    stack_var integer b1, b2, b3

    length = length_array(value)

    if (length <= 0) {
        return value
    }

    count = 0
    j = 0

    for (i = 0; i < length; i++) {
        stack_var integer idx1, idx2, idx3, idx4

        buffer[(count + 1)] = value[(i + 1)]
        count++

        if (count < 3) {
            continue
        }

        // Convert signed chars to unsigned integers
        b1 = type_cast(buffer[1])
        if (b1 < 0) { b1 = b1 + 256 }

        b2 = type_cast(buffer[2])
        if (b2 < 0) { b2 = b2 + 256 }

        b3 = type_cast(buffer[3])
        if (b3 < 0) { b3 = b3 + 256 }

        idx1 = type_cast((b1 >> 2) + 1)
        idx2 = type_cast((((b1 & $03) << 4) | ((b2 >> 4) & $0F)) + 1)
        idx3 = type_cast((((b2 & $0F) << 2) | ((b3 >> 6) & $03)) + 1)
        idx4 = type_cast((b3 & $3F) + 1)

        result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx1]); j++
        result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx2]); j++
        result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx3]); j++
        result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx4]); j++

        count = 0
    }

    // Process any remaining bytes (1 or 2) - NO PADDING
    if (count > 0) {
        stack_var integer idx1, idx2, idx3

        b1 = type_cast(buffer[1])
        if (b1 < 0) { b1 = b1 + 256 }

        idx1 = type_cast((b1 >> 2) + 1)
        result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx1]); j++

        if (count == 1) {
            idx2 = type_cast((((b1 & $03) << 4) & $3F) + 1)
            result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx2]); j++
            // NO PADDING for JWT
        }
        else {
            b2 = type_cast(buffer[2])
            if (b2 < 0) { b2 = b2 + 256 }

            idx2 = type_cast((((b1 & $03) << 4) | ((b2 >> 4) & $0F)) + 1)
            idx3 = type_cast((((b2 & $0F) << 2) & $3F) + 1)

            result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx2]); j++
            result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx3]); j++
            // NO PADDING for JWT
        }
    }

    set_length_array(result, j)
    return result
}


/**
 * @function NAVBase64UrlEncodePadded
 * @public
 * @description Encodes binary data using URL-safe Base64 encoding with padding.
 * This variant includes padding characters for compatibility with systems that require it.
 *
 * @param {char[]} value - Binary data to encode
 *
 * @returns {char[]} Base64Url encoded string with padding
 *
 * @example
 * stack_var char binary[10]
 * stack_var char encoded[NAV_MAX_BUFFER]
 *
 * binary = 'Hello!'
 * encoded = NAVBase64UrlEncodePadded(binary)  // Returns "SGVsbG8h==" (with padding)
 *
 * @note Most JWT implementations do not require padding
 */
define_function char[NAV_MAX_BUFFER] NAVBase64UrlEncodePadded(char value[]) {
    stack_var integer count
    stack_var char buffer[3]
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer i
    stack_var integer j
    stack_var integer b1, b2, b3

    length = length_array(value)

    if (length <= 0) {
        return value
    }

    count = 0
    j = 0

    for (i = 0; i < length; i++) {
        stack_var integer idx1, idx2, idx3, idx4

        buffer[(count + 1)] = value[(i + 1)]
        count++

        if (count < 3) {
            continue
        }

        // Convert signed chars to unsigned integers
        b1 = type_cast(buffer[1])
        if (b1 < 0) { b1 = b1 + 256 }

        b2 = type_cast(buffer[2])
        if (b2 < 0) { b2 = b2 + 256 }

        b3 = type_cast(buffer[3])
        if (b3 < 0) { b3 = b3 + 256 }

        idx1 = type_cast((b1 >> 2) + 1)
        idx2 = type_cast((((b1 & $03) << 4) | ((b2 >> 4) & $0F)) + 1)
        idx3 = type_cast((((b2 & $0F) << 2) | ((b3 >> 6) & $03)) + 1)
        idx4 = type_cast((b3 & $3F) + 1)

        result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx1]); j++
        result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx2]); j++
        result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx3]); j++
        result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx4]); j++

        count = 0
    }

    // Process any remaining bytes (1 or 2) WITH PADDING
    if (count > 0) {
        stack_var integer idx1, idx2, idx3

        b1 = type_cast(buffer[1])
        if (b1 < 0) { b1 = b1 + 256 }

        idx1 = type_cast((b1 >> 2) + 1)
        result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx1]); j++

        if (count == 1) {
            idx2 = type_cast((((b1 & $03) << 4) & $3F) + 1)
            result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx2]); j++
            result[(j + 1)] = NAV_BASE64URL_PADDING_CHAR; j++
        }
        else {
            b2 = type_cast(buffer[2])
            if (b2 < 0) { b2 = b2 + 256 }

            idx2 = type_cast((((b1 & $03) << 4) | ((b2 >> 4) & $0F)) + 1)
            idx3 = type_cast((((b2 & $0F) << 2) & $3F) + 1)

            result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx2]); j++
            result[(j + 1)] = type_cast(NAV_BASE64URL_MAP[idx3]); j++
        }

        result[(j + 1)] = NAV_BASE64URL_PADDING_CHAR; j++
    }

    set_length_array(result, j)
    return result
}


/**
 * @function NAVBase64UrlGetCharValue
 * @private
 * @description Gets the 6-bit value for a Base64Url character
 *
 * @param {char} c - The Base64Url character
 * @returns {sinteger} The 6-bit value (0-63) or NAV_BASE64URL_INVALID_VALUE if invalid
 *
 * @note This function handles special cases like padding characters ('=')
 * @note Whitespace characters (CR, LF, space, tab) are skipped per RFC 4648
 */
define_function sinteger NAVBase64UrlGetCharValue(char c) {
    stack_var integer i
    stack_var char description[100]

    // Handle padding character separately
    if (c == NAV_BASE64URL_PADDING_CHAR) {
        return 0  // Padding has special handling
    }

    // Search in character map
    for (i = 1; i <= 64; i++) {
        if (NAV_BASE64URL_MAP[i] == c) {
            return type_cast(i - 1)  // Return 0-based index
        }
    }

    // Skip whitespace characters
    if (c == $0D || c == $0A || c == $20 || c == $09) {
        return NAV_BASE64URL_INVALID_VALUE
    }

    // Format character description
    if (c >= 32 && c <= 126) {
        description = "'"', c, '"', ' (', itoa(c), ')'"
    } else {
        description = "'$', format('%02X', c), ' (', itoa(c), ')'"
    }

    NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                              __NAV_FOUNDATION_ENCODING_BASE64URL__,
                              'NAVBase64UrlGetCharValue',
                              "'Invalid Base64Url character: ', description")
    return NAV_BASE64URL_INVALID_VALUE
}


/**
 * @function NAVBase64UrlDecode
 * @public
 * @description Decodes a Base64Url encoded string back to binary data according to RFC 4648 Section 5.
 * Automatically handles missing padding by calculating and adding it as needed.
 *
 * @param {char[]} value - Base64Url encoded string (with or without padding)
 *
 * @returns {char[]} Decoded binary data
 *
 * @example
 * stack_var char encoded[20]
 * stack_var char decoded[NAV_MAX_BUFFER]
 *
 * encoded = 'SGVsbG8h'  // Base64Url for "Hello!" (no padding)
 * decoded = NAVBase64UrlDecode(encoded)
 *
 * @note This function automatically adds padding if missing (required for JWT)
 * @note Whitespace characters are automatically ignored
 * @note Invalid characters are skipped and logged with warnings
 */
define_function char[NAV_MAX_BUFFER] NAVBase64UrlDecode(char value[]) {
    stack_var integer count
    stack_var integer buffer[4]
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer length
    stack_var integer i, j
    stack_var sinteger charValue
    stack_var integer paddingNeeded
    stack_var char paddedValue[NAV_MAX_BUFFER]
    stack_var char valueCopy[NAV_MAX_BUFFER]

    // Make a copy of the input to work with
    valueCopy = value

    length = length_array(valueCopy)

    if (length <= 0) {
        return valueCopy
    }

    // Calculate padding needed (JWT tokens omit padding)
    paddingNeeded = (4 - (length % 4)) % 4

    if (paddingNeeded > 0) {
        // Add padding
        paddedValue = valueCopy
        for (i = 1; i <= paddingNeeded; i++) {
            paddedValue = "paddedValue, NAV_BASE64URL_PADDING_CHAR"
        }

        valueCopy = paddedValue
        length = length_array(valueCopy)
    }

    count = 0
    j = 0

    // Process each character in the input
    for (i = 1; i <= length; i++) {
        // Skip whitespace characters
        if (valueCopy[i] == $0D || valueCopy[i] == $0A || valueCopy[i] == $20 || valueCopy[i] == $09) {
            continue
        }

        // Process padding characters
        if (valueCopy[i] == NAV_BASE64URL_PADDING_CHAR) {
            continue
        }

        // Get the 6-bit value for this Base64Url character
        charValue = NAVBase64UrlGetCharValue(valueCopy[i])

        // Skip invalid characters
        if (charValue == NAV_BASE64URL_INVALID_VALUE) {
            continue
        }

        // Add the value to our buffer
        count++
        buffer[count] = type_cast(charValue)

        // Process when we have 4 values in the buffer
        if (count == 4) {
            // First byte
            result[j+1] = type_cast(((buffer[1] << 2) | (buffer[2] >> 4)) & $FF);
            j++

            // Second byte
            result[j+1] = type_cast(((buffer[2] << 4) | (buffer[3] >> 2)) & $FF);
            j++

            // Third byte
            result[j+1] = type_cast(((buffer[3] << 6) | buffer[4]) & $FF);
            j++

            count = 0
        }
    }

    // Handle any remaining bytes from partial quartets
    if (count > 0) {
        if (count == 2) {
            result[j+1] = type_cast(((buffer[1] << 2) | (buffer[2] >> 4)) & $FF);
            j++;
        }
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


/**
 * @function NAVBase64ToBase64Url
 * @public
 * @description Converts standard Base64 encoding to Base64Url encoding.
 * Replaces '+' with '-', '/' with '_', and removes padding.
 *
 * @param {char[]} base64 - Standard Base64 encoded string
 *
 * @returns {char[]} Base64Url encoded string
 *
 * @example
 * stack_var char standard[50]
 * stack_var char urlSafe[NAV_MAX_BUFFER]
 *
 * standard = 'SGVsbG8+Pz8/Pw=='  // Contains '+', '/', and '='
 * urlSafe = NAVBase64ToBase64Url(standard)  // Returns "SGVsbG8-Pz8_Pw"
 *
 * @note Useful for converting existing Base64 strings to JWT-compatible format
 */
define_function char[NAV_MAX_BUFFER] NAVBase64ToBase64Url(char base64[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer length

    result = base64
    length = length_array(result)

    // Handle empty string
    if (!length) {
        return result
    }

    // Replace '+' with '-' and '/' with '_'
    for (i = 1; i <= length; i++) {
        if (result[i] == '+') {
            result[i] = '-'
        }
        else if (result[i] == '/') {
            result[i] = '_'
        }
    }

    // Remove padding
    while (length > 0) {
        if (result[length] != '=') {
            break
        }

        length--
    }

    set_length_array(result, length)
    return result
}


/**
 * @function NAVBase64UrlToBase64
 * @public
 * @description Converts Base64Url encoding to standard Base64 encoding.
 * Replaces '-' with '+', '_' with '/', and adds padding.
 *
 * @param {char[]} base64url - Base64Url encoded string
 *
 * @returns {char[]} Standard Base64 encoded string with padding
 *
 * @example
 * stack_var char urlSafe[50]
 * stack_var char standard[NAV_MAX_BUFFER]
 *
 * urlSafe = 'SGVsbG8-Pz8_Pw'  // No padding, has '-' and '_'
 * standard = NAVBase64UrlToBase64(urlSafe)  // Returns "SGVsbG8+Pz8/Pw=="
 *
 * @note Useful for systems that only accept standard Base64
 */
define_function char[NAV_MAX_BUFFER] NAVBase64UrlToBase64(char base64url[]) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer length
    stack_var integer paddingNeeded

    result = base64url
    length = length_array(result)

    // Handle empty string
    if (!length) {
        return result
    }

    // Replace '-' with '+' and '_' with '/'
    for (i = 1; i <= length; i++) {
        if (result[i] == '-') {
            result[i] = '+'
        }
        else if (result[i] == '_') {
            result[i] = '/'
        }
    }

    // Add padding
    paddingNeeded = (4 - (length % 4)) % 4

    for (i = 1; i <= paddingNeeded; i++) {
        result = "result, '='"
    }

    return result
}


#END_IF // __NAV_FOUNDATION_ENCODING_BASE64URL__
