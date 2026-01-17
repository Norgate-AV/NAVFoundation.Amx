PROGRAM_NAME='NAVFoundation.Url'

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

/**
 * @file NAVFoundation.Url.axi
 * @brief Implementation for URL manipulation and parsing.
 *
 * This module provides functions to work with URLs, including parsing URLs
 * into their component parts and building URLs from structured data.
 * It supports all standard URL components: scheme, host, port, path,
 * query parameters, and fragments.
 */

#IF_NOT_DEFINED __NAV_FOUNDATION_URL__
#DEFINE __NAV_FOUNDATION_URL__ 'NAVFoundation.Url'

#include 'NAVFoundation.Core.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.PathUtils.axi'
#include 'NAVFoundation.Url.h.axi'


/**
 * @function NAVUrlIsUnreserved
 * @internal
 * @description Checks if a character is unreserved according to RFC 3986.
 *
 * RFC 3986 Section 2.3: Unreserved characters do not need to be percent-encoded.
 * unreserved = ALPHA / DIGIT / "-" / "." / "_" / "~"
 *
 * @param {char} c - Character to check
 *
 * @returns {char} TRUE if character is unreserved, FALSE otherwise
 */
define_function char NAVUrlIsUnreserved(char c) {
    // ALPHA (A-Z, a-z)
    if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z')) {
        return true
    }

    // DIGIT (0-9)
    if (c >= '0' && c <= '9') {
        return true
    }

    // Special unreserved characters: - . _ ~
    if (c == '-' || c == '.' || c == '_' || c == '~') {
        return true
    }

    return false
}


/**
 * @function NAVUrlHexCharToValue
 * @internal
 * @description Converts a hexadecimal character to its numeric value.
 *
 * @param {char} c - Hexadecimal character ('0'-'9', 'A'-'F', 'a'-'f')
 *
 * @returns {char} Numeric value (0-15), or 0 if invalid
 *
 * @example
 * value = NAVUrlHexCharToValue('A')  // Returns 10
 * value = NAVUrlHexCharToValue('f')  // Returns 15
 * value = NAVUrlHexCharToValue('5')  // Returns 5
 */
define_function char NAVUrlHexCharToValue(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0'
    }

    if (c >= 'A' && c <= 'F') {
        return c - 'A' + 10
    }

    if (c >= 'a' && c <= 'f') {
        return c - 'a' + 10
    }

    return 0
}


/**
 * @function NAVUrlValueToHexChar
 * @internal
 * @description Converts a numeric value (0-15) to a hexadecimal character.
 *
 * @param {char} value - Numeric value (0-15)
 *
 * @returns {char} Hexadecimal character ('0'-'9', 'A'-'F')
 *
 * @example
 * hex = NAVUrlValueToHexChar(10)  // Returns 'A'
 * hex = NAVUrlValueToHexChar(15)  // Returns 'F'
 * hex = NAVUrlValueToHexChar(5)   // Returns '5'
 */
define_function char NAVUrlValueToHexChar(char value) {
    stack_var char hexDigits[16]

    hexDigits = '0123456789ABCDEF'

    if (value < 16) {
        return hexDigits[value + 1]
    }

    return '0'
}


/**
 * @function NAVUrlEncode
 * @public
 * @description Percent-encodes a string for use in URLs according to RFC 3986.
 *
 * This function converts characters that are not allowed in URLs into their
 * percent-encoded form (%XX where XX is the hexadecimal value of the byte).
 * Unreserved characters (ALPHA, DIGIT, "-", ".", "_", "~") are not encoded.
 *
 * @param {char[]} input - String to encode
 *
 * @returns {char[NAV_MAX_BUFFER]} Percent-encoded string
 *
 * @example
 * stack_var char encoded[NAV_MAX_BUFFER]
 *
 * encoded = NAVUrlEncode('hello world')
 * // Returns 'hello%20world'
 *
 * encoded = NAVUrlEncode('user@example.com')
 * // Returns 'user%40example.com'
 *
 * encoded = NAVUrlEncode('path/to/file')
 * // Returns 'path%2Fto%2Ffile'
 *
 * @note Space is encoded as %20 (not + sign)
 * @note Per RFC 3986 Section 2.1, all characters except unreserved must be encoded
 * @see NAVUrlDecode
 */
define_function char[NAV_MAX_BUFFER] NAVUrlEncode(char input[]) {
    stack_var char output[NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer length
    stack_var char c
    stack_var char highNibble
    stack_var char lowNibble

    output = ''
    length = length_array(input)

    for (i = 1; i <= length; i++) {
        c = input[i]

        // Check if character is unreserved (doesn't need encoding)
        if (NAVUrlIsUnreserved(c)) {
            output = "output, c"
        }
        else {
            // Percent-encode the character
            highNibble = type_cast((c >> 4) & $0F)
            lowNibble = c & $0F

            output = "output, '%', NAVUrlValueToHexChar(highNibble), NAVUrlValueToHexChar(lowNibble)"
        }
    }

    return output
}


/**
 * @function NAVUrlDecode
 * @public
 * @description Decodes a percent-encoded URL string according to RFC 3986.
 *
 * This function converts percent-encoded sequences (%XX) back to their
 * original characters. Invalid sequences are left as-is.
 *
 * @param {char[]} input - Percent-encoded string to decode
 *
 * @returns {char[NAV_MAX_BUFFER]} Decoded string
 *
 * @example
 * stack_var char decoded[NAV_MAX_BUFFER]
 *
 * decoded = NAVUrlDecode('hello%20world')
 * // Returns 'hello world'
 *
 * decoded = NAVUrlDecode('user%40example.com')
 * // Returns 'user@example.com'
 *
 * decoded = NAVUrlDecode('path%2Fto%2Ffile')
 * // Returns 'path/to/file'
 *
 * @note Plus signs (+) are not converted to spaces (use %20 for spaces)
 * @note Invalid percent sequences are left unchanged
 * @see NAVUrlEncode
 */
define_function char[NAV_MAX_BUFFER] NAVUrlDecode(char input[]) {
    stack_var char output[NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer length
    stack_var char c
    stack_var char hex1
    stack_var char hex2
    stack_var char value

    output = ''
    length = length_array(input)
    i = 1

    while (i <= length) {
        c = input[i]

        if (c == '%' && i + 2 <= length) {
            // Try to decode percent sequence
            hex1 = input[i + 1]
            hex2 = input[i + 2]

            // Check if both characters are valid hex digits
            if (((hex1 >= '0' && hex1 <= '9') || (hex1 >= 'A' && hex1 <= 'F') || (hex1 >= 'a' && hex1 <= 'f')) &&
                ((hex2 >= '0' && hex2 <= '9') || (hex2 >= 'A' && hex2 <= 'F') || (hex2 >= 'a' && hex2 <= 'f'))) {

                // Decode the hex sequence
                value = type_cast((NAVUrlHexCharToValue(hex1) << 4) | NAVUrlHexCharToValue(hex2))
                output = "output, value"

                // Skip the two hex digits
                i = i + 3
                continue
            }
        }

        // Not a valid percent sequence, copy as-is
        output = "output, c"
        i++
    }

    return output
}


/**
 * @function NAVUrlIsValidPort
 * @private
 * @description Validates if a port number is within the valid range (0-65535).
 *
 * Per IETF RFC 6335, port numbers must be in the range 0-65535.
 * Port 0 has special meaning (system-assigned port) but is technically valid.
 * This matches the behavior of JavaScript WHATWG URL API and C# System.Uri.
 *
 * @param {integer} port - Port number to validate
 *
 * @returns {char} TRUE if port is valid (0-65535), FALSE otherwise
 *
 * @note Matches industry-standard behavior:
 *       - JavaScript: Throws TypeError for ports outside 0-65535
 *       - C#: Throws UriFormatException for invalid ports
 *       - Go: Accepts any value (lenient)
 *       - Python: Accepts any value (lenient)
 */
define_function char NAVUrlIsValidPort(integer port) {
    // NetLinx integers are 16-bit unsigned (0-65535), so any integer is valid
    // However, we document the logical range for port numbers per RFC 6335
    return (port >= 0 && port <= 65535)
}


/**
 * @function NAVUrlIsValidPortString
 * @private
 * @description Validates if a port string represents a valid port number (0-65535).
 *
 * This function checks the port BEFORE conversion to integer to detect overflow.
 * Since NetLinx integers are 16-bit unsigned (0-65535), we need to validate
 * the string representation to catch values like "65536" or "99999" before
 * they wrap around during atoi() conversion.
 *
 * @param {char[]} portStr - Port string to validate
 *
 * @returns {char} TRUE if port string is valid, FALSE otherwise
 */
define_function char NAVUrlIsValidPortString(char portStr[]) {
    stack_var slong portValue

    if (!length_array(portStr)) {
        return false
    }

    // Convert to long to check range without overflow
    portValue = atol(portStr)

    // Check if port is within valid range
    return (portValue >= 0 && portValue <= 65535)
}


/**
 * @function NAVUrlIsValidScheme
 * @private
 * @description Validates if a scheme conforms to RFC 3986 Section 3.1.
 *
 * Per RFC 3986, scheme must:
 * - Start with ALPHA (a-z, A-Z)
 * - Followed by any number of ALPHA / DIGIT / "+" / "-" / "."
 *
 * This matches the behavior of JavaScript WHATWG URL API and C# System.Uri.
 *
 * @param {char[]} scheme - Scheme to validate
 *
 * @returns {char} TRUE if scheme is valid, FALSE otherwise
 *
 * @note Matches industry-standard behavior:
 *       - JavaScript: Throws TypeError for invalid schemes
 *       - C#: Throws UriFormatException for invalid schemes
 *       - Java: Throws URISyntaxException for invalid schemes
 */
define_function char NAVUrlIsValidScheme(char scheme[]) {
    stack_var integer length
    stack_var integer i
    stack_var char c

    length = length_array(scheme)

    // Empty scheme is invalid
    if (!length) {
        return false
    }

    // First character must be ALPHA
    c = scheme[1]
    if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'))) {
        return false
    }

    // Remaining characters must be ALPHA / DIGIT / "+" / "-" / "."
    for (i = 2; i <= length; i++) {
        c = scheme[i]
        if (!((c >= 'a' && c <= 'z') ||
              (c >= 'A' && c <= 'Z') ||
              (c >= '0' && c <= '9') ||
              c == '+' || c == '-' || c == '.')) {
            return false
        }
    }

    return true
}


/**
 * @function NAVUrlHasInvalidCharacters
 * @private
 * @description Checks if a URL contains unencoded invalid characters.
 *
 * Per RFC 3986, URLs must not contain:
 * - Control characters (0x00-0x1F, 0x7F)
 * - Unencoded space (0x20) - should be %20 or +
 * - Non-ASCII characters without percent-encoding
 *
 * This is a basic validation to catch common errors. More lenient than
 * strict RFC 3986 to maintain compatibility with real-world URLs.
 *
 * @param {char[]} buffer - URL string to check
 *
 * @returns {char} TRUE if invalid characters found, FALSE otherwise
 *
 * @note Matches MODERATE validation approach (JavaScript/C#)
 */
define_function char NAVUrlHasInvalidCharacters(char buffer[]) {
    stack_var integer length
    stack_var integer i
    stack_var char c

    length = length_array(buffer)

    for (i = 1; i <= length; i++) {
        c = buffer[i]

        // Check for control characters (0x00-0x1F)
        if (c <= $1F) {
            return true
        }

        // Check for DEL character (0x7F)
        if (c == $7F) {
            return true
        }

        // Check for unencoded space
        if (c == ' ') {
            return true
        }
    }

    return false
}


/**
 * @function NAVUrlNormalizePercentEncoding
 * @public
 * @description Normalizes percent-encoding in a URL string per RFC 3986 Section 6.2.2.3.
 *
 * This function performs two normalization operations:
 * 1. Converts percent-encoded triplets to uppercase hexadecimal digits (e.g., %2f → %2F)
 * 2. Decodes unnecessarily percent-encoded unreserved characters (e.g., %41 → A)
 *
 * Per RFC 3986, unreserved characters are: A-Z, a-z, 0-9, -, ., _, ~
 * These characters should not be percent-encoded in normalized URLs.
 *
 * @param {char[]} input - The URL string or component to normalize
 *
 * @returns {char[NAV_MAX_BUFFER]} The normalized string
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVUrlNormalizePercentEncoding('http://example.com/%7euser')
 * // Returns 'http://example.com/~user'
 *
 * result = NAVUrlNormalizePercentEncoding('path%2fto%2ffile')
 * // Returns 'path%2Fto%2Ffile'
 *
 * result = NAVUrlNormalizePercentEncoding('%41%42%43')
 * // Returns 'ABC'
 *
 * result = NAVUrlNormalizePercentEncoding('hello%20world')
 * // Returns 'hello%20world' (space must remain encoded)
 *
 * @note This should be called on individual URL components (path, query, etc.)
 *       not on the complete URL, to avoid normalizing the scheme delimiter
 * @note Reserved characters (like /, ?, #, etc.) remain percent-encoded
 * @note Invalid percent sequences are left unchanged
 *
 * @see NAVUrlEncode
 * @see NAVUrlDecode
 */
define_function char[NAV_MAX_BUFFER] NAVUrlNormalizePercentEncoding(char input[]) {
    stack_var char output[NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer length
    stack_var char c
    stack_var char hex1
    stack_var char hex2
    stack_var char value

    output = ''
    length = length_array(input)
    i = 1

    while (i <= length) {
        c = input[i]

        if (c == '%' && i + 2 <= length) {
            hex1 = input[i + 1]
            hex2 = input[i + 2]

            // Check if both characters are valid hex digits
            if (((hex1 >= '0' && hex1 <= '9') || (hex1 >= 'A' && hex1 <= 'F') || (hex1 >= 'a' && hex1 <= 'f')) &&
                ((hex2 >= '0' && hex2 <= '9') || (hex2 >= 'A' && hex2 <= 'F') || (hex2 >= 'a' && hex2 <= 'f'))) {

                // Decode the hex sequence to get the character value
                value = type_cast((NAVUrlHexCharToValue(hex1) << 4) | NAVUrlHexCharToValue(hex2))

                // Check if this is an unreserved character that should not be encoded
                if (NAVUrlIsUnreserved(value)) {
                    // Decode it - unreserved characters should not be percent-encoded
                    output = "output, value"
                }
                else {
                    // Keep it encoded, but normalize to uppercase hex digits
                    output = "output, '%', NAVUrlValueToHexChar(type_cast((value >> 4) & $0F)), NAVUrlValueToHexChar(type_cast(value & $0F))"
                }

                // Skip the two hex digits
                i = i + 3
                continue
            }
        }

        // Not a valid percent sequence, copy as-is
        output = "output, c"
        i++
    }

    return output
}


/**
 * @function NAVUrlNormalizePath
 * @public
 * @description Normalizes a URL path by removing dot-segments per RFC 3986 Section 5.2.4.
 *
 * This function removes '.' and '..' segments from URL paths to create a normalized
 * canonical form. This is essential for URL comparison, caching, and security.
 *
 * Normalization operations:
 * - Removes '.' (current directory) segments
 * - Removes '..' (parent directory) segments along with their preceding segment
 * - Removes duplicate slashes
 * - Preserves leading and trailing slashes
 * - Handles both absolute and relative paths
 *
 * @param {char[]} path - The URL path to normalize
 *
 * @returns {char[NAV_MAX_BUFFER]} The normalized path
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * result = NAVUrlNormalizePath('/a/b/c/./../../g')
 * // Returns '/a/g'
 *
 * result = NAVUrlNormalizePath('mid/content=5/../6')
 * // Returns 'mid/6'
 *
 * result = NAVUrlNormalizePath('/a/./b/../c')
 * // Returns '/a/c'
 *
 * @note This function uses NAVPathNormalize() which implements the algorithm
 *       specified in RFC 3986 Section 5.2.4 for removing dot-segments.
 * @note Empty paths return '.' (current directory)
 * @note This should be called on the path component only, not on query strings or fragments
 *
 * @see NAVParseUrl
 * @see NAVPathNormalize
 */
define_function char[NAV_MAX_BUFFER] NAVUrlNormalizePath(char path[]) {
    // RFC 3986 Section 5.2.4: Remove dot-segments from path
    // URL paths use forward slashes like POSIX paths
    // NAVPathNormalize already implements the RFC 3986 algorithm

    if (!length_array(path)) {
        return path
    }

    // NAVPathNormalize handles:
    // - Remove . segments (e.g., /a/./b -> /a/b)
    // - Remove .. segments (e.g., /a/b/../c -> /a/c)
    // - Remove duplicate slashes (e.g., /a//b -> /a/b)
    // - Preserve leading/trailing slashes
    // - Handle relative paths
    return NAVPathNormalize(path)
}


/**
 * @function NAVUrlGetDefaultPort
 * @public
 * @description Returns the default port for a URL scheme per RFC 3986 Section 6.2.3.
 *
 * This function determines the standard default port for a given URL scheme.
 * When a URL uses the default port for its scheme, that port should be omitted
 * during normalization to create a canonical URL form.
 *
 * @param {char[]} scheme - The URL scheme (e.g., 'http', 'https', 'ftp')
 *
 * @returns {integer} The default port number for the scheme, or 0 if no default exists
 *
 * @example
 * stack_var integer port
 *
 * port = NAVUrlGetDefaultPort(NAV_URL_SCHEME_HTTP)
 * // Returns 80
 *
 * port = NAVUrlGetDefaultPort(NAV_URL_SCHEME_HTTPS)
 * // Returns 443
 *
 * port = NAVUrlGetDefaultPort('unknown')
 * // Returns 0
 *
 * @note Scheme comparison is case-insensitive per RFC 3986
 * @note Returns 0 for schemes without standard default ports
 *
 * @see NAVBuildUrl
 * @see NAV_URL_DEFAULT_PORT_HTTP
 * @see NAV_URL_DEFAULT_PORT_HTTPS
 */
define_function integer NAVUrlGetDefaultPort(char scheme[]) {
    stack_var char normalizedScheme[NAV_MAX_URL_SCHEME]

    // Normalize scheme to lowercase for comparison (RFC 3986 Section 6.2.2.1)
    normalizedScheme = lower_string(scheme)

    select {
        active (normalizedScheme == NAV_URL_SCHEME_HTTP):
            return NAV_URL_DEFAULT_PORT_HTTP
        active (normalizedScheme == NAV_URL_SCHEME_HTTPS):
            return NAV_URL_DEFAULT_PORT_HTTPS
        active (normalizedScheme == NAV_URL_SCHEME_FTP):
            return NAV_URL_DEFAULT_PORT_FTP
        active (normalizedScheme == NAV_URL_SCHEME_SFTP):
            return NAV_URL_DEFAULT_PORT_SFTP
        active (normalizedScheme == NAV_URL_SCHEME_RTSP):
            return NAV_URL_DEFAULT_PORT_RTSP
        active (normalizedScheme == NAV_URL_SCHEME_RTSPS):
            return NAV_URL_DEFAULT_PORT_RTSPS
        active (normalizedScheme == NAV_URL_SCHEME_WS):
            return NAV_URL_DEFAULT_PORT_WS
        active (normalizedScheme == NAV_URL_SCHEME_WSS):
            return NAV_URL_DEFAULT_PORT_WSS
    }

    // No default port for this scheme
    return 0
}


/**
 * @function NAVBuildUrl
 * @public
 * @description Builds a complete URL string from a structured URL object.
 *
 * This function takes a populated _NAVUrl structure and converts it into
 * a properly formatted URL string. Per RFC 3986 Section 6.2.3, default ports
 * for a scheme are omitted from the canonical URL form.
 *
 * @param {_NAVUrl} url - The URL structure to convert to a string
 *
 * @returns {char[NAV_MAX_BUFFER]} The complete URL as a string
 *
 * @example
 * stack_var _NAVUrl url
 * stack_var char urlString[NAV_MAX_BUFFER]
 *
 * url.Scheme = 'https'
 * url.Host = 'example.com'
 * url.Port = 8080
 * url.Path = '/api/v1/data'
 * url.Queries[1].Key = 'param1'
 * url.Queries[1].Value = 'value1'
 * url.Fragment = 'section2'
 * set_length_array(url.Queries, 1)
 *
 * urlString = NAVBuildUrl(url)
 * // urlString will be 'https://example.com:8080/api/v1/data?param1=value1#section2'
 *
 * url.Port = 443
 * urlString = NAVBuildUrl(url)
 * // urlString will be 'https://example.com/api/v1/data?param1=value1#section2'
 * // (port 443 is omitted as it's the default for HTTPS)
 *
 * @note Per RFC 3986 Section 6.2.3, default ports are omitted for scheme-based normalization
 *
 * @see NAVParseUrl
 * @see NAVUrlGetDefaultPort
 */
define_function char[NAV_MAX_BUFFER] NAVBuildUrl(_NAVUrl url) {
    stack_var char result[NAV_MAX_BUFFER]
    stack_var integer defaultPort

    result = ''

    if (url.Scheme) {
        result = "url.Scheme, NAV_URL_SCHEME_TOKEN"
    }

    if (url.Host) {
        // Add userinfo if present
        if (url.HasUserInfo) {
            result = "result, url.UserInfo.Username"

            if (length_array(url.UserInfo.Password)) {
                result = "result, ':', url.UserInfo.Password"
            }

            result = "result, '@'"
        }

        result = "result, url.Host"

        // RFC 3986 Section 6.2.3: Omit port if it's the default for the scheme
        if (url.Port) {
            defaultPort = NAVUrlGetDefaultPort(url.Scheme)

            // Only include port if it's not the default
            if (url.Port != defaultPort) {
                result = "result, NAV_URL_PORT_TOKEN, itoa(url.Port)"
            }
        }
    }

    if (length_array(url.Path)) {
        if (!NAVStartsWith(url.Path, '/')) {
            result = "result, NAV_URL_PATH_TOKEN"
        }

        result = "result, url.Path"
    }

    if (length_array(url.Queries)) {
        stack_var integer x

        for (x = 1; x <= length_array(url.Queries); x++) {
            if (x == 1) {
                result = "result, NAV_URL_QUERY_TOKEN"
            }
            else {
                result = "result, '&'"
            }

            result = "result, url.Queries[x].Key"
            if (length_array(url.Queries[x].Value)) {
                result = "result, '=', url.Queries[x].Value"
            }
        }
    }

    if (length_array(url.Fragment)) {
        result = "result, NAV_URL_FRAGMENT_TOKEN, url.Fragment"
    }

    return result
}


/**
 * @function NAVParseScheme
 * @internal
 * @description Parses the scheme from a URL and returns the authority position.
 *
 * Per RFC 3986 Section 6.2.2.1, the scheme is case-insensitive and normalized to lowercase.
 *
 * @param {char[]} buffer - The URL string
 * @param {_NAVUrl} url - The URL structure to populate
 *
 * @returns {integer} The position where the authority section begins
 */
define_function integer NAVParseScheme(char buffer[], _NAVUrl url) {
    stack_var integer scheme
    stack_var integer length

    length = length_array(buffer)
    scheme = NAVIndexOf(buffer, NAV_URL_SCHEME_TOKEN, 1)

    if (scheme) {
        // RFC 3986 6.2.2.1: Normalize scheme to lowercase
        url.Scheme = lower_string(NAVGetStringBefore(buffer, NAV_URL_SCHEME_TOKEN))
        return scheme + 3  // Start after '://'
    }
    else {
        url.Scheme = ''

        // Check for protocol-relative URL (starts with '//')
        if (length >= 2 && buffer[1] == '/' && buffer[2] == '/') {
            return 3  // Start after '//'
        }
        else {
            return 1
        }
    }
}


/**
 * @function NAVParseUserInfo
 * @internal
 * @description Extracts userinfo (username:password) from authority section.
 *
 * @param {char[]} buffer - The URL string
 * @param {integer} authorityStart - Start position of authority section
 * @param {integer} authorityEnd - End position of authority section
 * @param {_NAVUrl} url - The URL structure to populate
 *
 * @returns {integer} The position where the host begins (after userinfo if present)
 */
define_function integer NAVParseUserInfo(char buffer[], integer authorityStart, integer authorityEnd, _NAVUrl url) {
    stack_var integer i
    stack_var integer userInfoEnd
    stack_var char userinfo[256]
    stack_var integer colonPos

    // Check for userinfo (user:pass@host)
    userInfoEnd = 0
    for (i = authorityStart; i < authorityEnd; i++) {
        if (buffer[i] == '@') {
            userInfoEnd = i
        }
    }

    // If userinfo exists, extract username and password
    if (userInfoEnd) {
        userinfo = NAVStringSubstring(buffer, authorityStart, userInfoEnd - authorityStart)
        colonPos = NAVIndexOf(userinfo, ':', 1)

        if (colonPos) {
            // Username and password present
            url.UserInfo.Username = NAVStringSubstring(userinfo, 1, colonPos - 1)
            url.UserInfo.Password = NAVStringSubstring(userinfo, colonPos + 1, length_array(userinfo) - colonPos)
        }
        else {
            // Username only
            url.UserInfo.Username = userinfo
            url.UserInfo.Password = ''
        }

        url.HasUserInfo = true
        return userInfoEnd + 1
    }
    else {
        url.UserInfo.Username = ''
        url.UserInfo.Password = ''
        url.HasUserInfo = false
        return authorityStart
    }
}


/**
 * @function NAVParseHost
 * @internal
 * @description Extracts the host from the authority section.
 *
 * Handles IPv6 addresses (enclosed in brackets) and finds the port separator.
 * Per RFC 3986 Section 6.2.2.1, the host is case-insensitive and normalized to lowercase.
 *
 * @param {char[]} buffer - The URL string
 * @param {integer} hostStart - Start position of host
 * @param {integer} hostEnd - End position of authority section
 * @param {_NAVUrl} url - The URL structure to populate
 *
 * @returns {char} TRUE if successful, FALSE if port is invalid
 */
define_function char NAVParseHost(char buffer[], integer hostStart, integer hostEnd, _NAVUrl url) {
    stack_var integer i
    stack_var integer port
    stack_var integer bracketDepth
    stack_var integer portEnd
    stack_var char portStr[10]
    stack_var slong portValue

    // Find port separator ':' but be IPv6-aware (skip colons inside [...])
    port = 0
    bracketDepth = 0

    for (i = hostStart; i < hostEnd; i++) {
        if (buffer[i] == '[') {
            bracketDepth++
        }
        else if (buffer[i] == ']') {
            bracketDepth--
        }
        else if (buffer[i] == ':' && bracketDepth == 0) {
            // Found port separator outside IPv6 brackets
            port = i
        }
    }

    // Extract host (handle empty host case)
    if (port && port > hostStart) {
        url.Host = NAVStringSubstring(buffer, hostStart, port - hostStart)
    }
    else if (hostEnd > hostStart) {
        url.Host = NAVStringSubstring(buffer, hostStart, hostEnd - hostStart)
    }
    else {
        url.Host = ''
    }

    // RFC 3986 6.2.2.1: Normalize host to lowercase (case-insensitive)
    // IPv6 addresses in brackets are already lowercase hex in practice
    if (length_array(url.Host)) {
        url.Host = lower_string(url.Host)
    }

    // Extract port if found
    if (port) {
        portEnd = hostEnd - 1
        portStr = NAVStringSubstring(buffer, port + 1, portEnd - port)

        // Validate port string before conversion
        if (!NAVUrlIsValidPortString(portStr)) {
            // Invalid port
            url.Port = 0
            return false
        }

        // Convert to long first, then cast to integer
        portValue = type_cast(atol(portStr))
        url.Port = type_cast(portValue)
    }
    else {
        url.Port = 0
    }

    return true
}


/**
 * @function NAVParseAuthority
 * @internal
 * @description Parses the authority section (userinfo, host, port).
 *
 * @param {char[]} buffer - The URL string
 * @param {integer} authorityStart - Start position of authority section
 * @param {integer} length - Total length of buffer
 * @param {integer} scheme - Position of scheme (0 if no scheme)
 * @param {_NAVUrl} url - The URL structure to populate
 *
 * @returns {integer} The position where path/query/fragment might start, or -1 if port is invalid
 */
define_function slong NAVParseAuthority(char buffer[], integer authorityStart, integer length, integer scheme, _NAVUrl url) {
    stack_var integer hostStart
    stack_var integer hostEnd
    stack_var integer path
    stack_var integer query
    stack_var integer fragment
    stack_var char portValid

    // Check for empty host (file:///path or http:///path)
    if (scheme && authorityStart <= length && buffer[authorityStart] == '/') {
        url.Host = ''
        url.Port = 0
        url.UserInfo.Username = ''
        url.UserInfo.Password = ''
        url.HasUserInfo = false
        return authorityStart
    }

    // Find the end of authority section (before path, query, or fragment)
    path = NAVIndexOf(buffer, NAV_URL_PATH_TOKEN, authorityStart)
    query = NAVIndexOf(buffer, NAV_URL_QUERY_TOKEN, authorityStart)
    fragment = NAVIndexOf(buffer, NAV_URL_FRAGMENT_TOKEN, authorityStart)

    // Determine where authority section ends
    hostEnd = 0
    if (path) { hostEnd = path }
    if (query && (!hostEnd || query < hostEnd)) { hostEnd = query }
    if (fragment && (!hostEnd || fragment < hostEnd)) { hostEnd = fragment }
    if (!hostEnd) { hostEnd = length + 1 }

    // Parse userinfo and get host start position
    hostStart = NAVParseUserInfo(buffer, authorityStart, hostEnd, url)

    // Parse host and port
    portValid = NAVParseHost(buffer, hostStart, hostEnd, url)

    if (!portValid) {
        return -1  // Invalid port
    }

    return hostStart
}


/**
 * @function NAVParsePath
 * @internal
 * @description Extracts the path from the URL.
 *
 * @param {char[]} buffer - The URL string
 * @param {integer} hostStart - Position where host begins
 * @param {integer} length - Total length of buffer
 * @param {_NAVUrl} url - The URL structure to populate
 * @param {integer} pathPos - Output: position of path (by reference)
 * @param {integer} queryPos - Output: position of query (by reference)
 * @param {integer} fragmentPos - Output: position of fragment (by reference)
 */
define_function NAVParsePath(char buffer[], integer hostStart, integer length, _NAVUrl url, integer pathPos, integer queryPos, integer fragmentPos) {
    stack_var integer pathEnd
    stack_var integer startPos

    // Re-find path, query, fragment from their actual positions
    if (!pathPos) {
        pathPos = NAVIndexOf(buffer, NAV_URL_PATH_TOKEN, hostStart)
    }
    if (!queryPos) {
        queryPos = NAVIndexOf(buffer, NAV_URL_QUERY_TOKEN, hostStart)
    }
    if (!fragmentPos) {
        fragmentPos = NAVIndexOf(buffer, NAV_URL_FRAGMENT_TOKEN, hostStart)
    }

    // Extract path
    if (pathPos) {
        url.FullPath = NAVStringSubstring(buffer, pathPos, (length - pathPos) + 1)

        select {
            // Fragment comes first (even if query exists after it)
            active (fragmentPos && fragmentPos > pathPos && (!queryPos || fragmentPos < queryPos)): {
                pathEnd = fragmentPos - 1
            }
            // Query comes first
            active (queryPos && queryPos > pathPos): {
                pathEnd = queryPos - 1
            }
            active (true): {
                pathEnd = length
            }
        }

        url.Path = NAVStringSubstring(buffer, pathPos, (pathEnd - pathPos) + 1)

        // RFC 3986 Section 5.2.4: Normalize path by removing dot-segments
        if (length_array(url.Path)) {
            url.Path = NAVUrlNormalizePath(url.Path)

            // Rebuild FullPath with normalized path + query + fragment
            if (queryPos || fragmentPos) {
                stack_var integer componentsStart

                // Use whichever comes first (query or fragment)
                if (queryPos && fragmentPos) {
                    if (queryPos < fragmentPos) {
                        componentsStart = queryPos
                    }
                    else {
                        componentsStart = fragmentPos
                    }
                }
                else if (queryPos) {
                    componentsStart = queryPos
                }
                else {
                    componentsStart = fragmentPos
                }

                url.FullPath = "url.Path, NAVStringSubstring(buffer, componentsStart, (length - componentsStart) + 1)"
            }
            else {
                url.FullPath = url.Path
            }
        }
    }
    else {
        url.Path = ''

        // Handle query or fragment without path (e.g., "http://example.com?query")
        if (queryPos || fragmentPos) {
            if (queryPos) {
                startPos = queryPos
            }
            else {
                startPos = fragmentPos
            }

            url.FullPath = NAVStringSubstring(buffer, startPos, (length - startPos) + 1)
        }
        else {
            url.FullPath = ''
        }
    }
}


/**
 * @function NAVParseQuery
 * @internal
 * @description Extracts query parameters from the URL.
 *
 * @param {char[]} buffer - The URL string
 * @param {integer} queryPos - Position of query marker
 * @param {integer} fragmentPos - Position of fragment marker
 * @param {integer} length - Total length of buffer
 * @param {_NAVUrl} url - The URL structure to populate
 */
define_function NAVParseQuery(char buffer[], integer queryPos, integer fragmentPos, integer length, _NAVUrl url) {
    stack_var char queries[1024]

    // Only extract if query marker comes before fragment marker (or no fragment)
    if (queryPos && (!fragmentPos || queryPos < fragmentPos)) {
        if (fragmentPos && fragmentPos > queryPos) {
            queries = NAVStringSubstring(buffer, queryPos + 1, fragmentPos - queryPos - 1)
        }
        else {
            queries = NAVStringSubstring(buffer, queryPos + 1, length - queryPos)
        }

        NAVParseQueryString(queries, url.Queries)
    }
}


/**
 * @function NAVParseFragment
 * @internal
 * @description Extracts the fragment from the URL.
 *
 * @param {char[]} buffer - The URL string
 * @param {integer} fragmentPos - Position of fragment marker
 * @param {integer} length - Total length of buffer
 * @param {_NAVUrl} url - The URL structure to populate
 */
define_function NAVParseFragment(char buffer[], integer fragmentPos, integer length, _NAVUrl url) {
    if (fragmentPos) {
        url.Fragment = right_string(buffer, length - fragmentPos)
    }
    else {
        url.Fragment = ''
    }
}


/**
 * @function NAVParseUrl
 * @public
 * @description Parses a URL string into a structured _NAVUrl object.
 *
 * This function breaks down a URL into its component parts: scheme, host,
 * port, path, query parameters, and fragment.
 *
 * @param {char[]} buffer - The URL string to parse
 * @param {_NAVUrl} url - The URL structure to populate with parsed data
 *
 * @returns {char} TRUE if parsing was successful, FALSE otherwise
 *
 * @example
 * stack_var char urlString[NAV_MAX_BUFFER]
 * stack_var _NAVUrl parsedUrl
 * stack_var char success
 *
 * urlString = 'https://example.com:8080/path/to/resource?param=value#section'
 * success = NAVParseUrl(urlString, parsedUrl)
 *
 * // If successful, parsedUrl will contain:
 * // parsedUrl.Scheme = 'https'
 * // parsedUrl.Host = 'example.com'
 * // parsedUrl.Port = 8080
 * // parsedUrl.Path = '/path/to/resource'
 * // parsedUrl.Queries[1].Key = 'param'
 * // parsedUrl.Queries[1].Value = 'value'
 * // parsedUrl.Fragment = 'section'
 *
 * @see NAVBuildUrl
 * @see NAVParseQueryString
 */
define_function char NAVParseUrl(char buffer[], _NAVUrl url) {
    stack_var integer scheme
    stack_var integer authority
    stack_var integer hostStart
    stack_var integer path
    stack_var integer query
    stack_var integer fragment
    stack_var integer length
    stack_var slong result

    length = length_array(buffer)

    if (!length) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_URL__,
                                    'NAVParseUrl',
                                    "'Buffer is empty'")

        return false
    }

    // Validate: Check for invalid characters (control chars, unencoded spaces)
    if (NAVUrlHasInvalidCharacters(buffer)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_URL__,
                                    'NAVParseUrl',
                                    "'URL contains invalid characters (control characters or unencoded spaces)'")

        return false
    }

    // Parse scheme and get authority start position
    scheme = NAVIndexOf(buffer, NAV_URL_SCHEME_TOKEN, 1)
    authority = NAVParseScheme(buffer, url)

    // Validate: Check scheme format if scheme exists
    if (length_array(url.Scheme) > 0) {
        if (!NAVUrlIsValidScheme(url.Scheme)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_URL__,
                                        'NAVParseUrl',
                                        "'Invalid scheme format: scheme must start with ALPHA and contain only ALPHA/DIGIT/+/-/.'")

            return false
        }
    }

    // Parse authority section (userinfo, host, port)
    result = NAVParseAuthority(buffer, authority, length, scheme, url)

    // Check if port validation failed
    if (result == -1) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_URL__,
                                    'NAVParseUrl',
                                    "'Invalid port: port must be in range 0-65535'")

        return false
    }

    hostStart = type_cast(result)

    // Validate: Check port range if port exists (redundant but kept for consistency)
    if (url.Port != 0) {
        if (!NAVUrlIsValidPort(url.Port)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_URL__,
                                        'NAVParseUrl',
                                        "'Invalid port: port must be in range 0-65535'")

            return false
        }
    }

    // Initialize positions for path, query, fragment
    path = NAVIndexOf(buffer, NAV_URL_PATH_TOKEN, hostStart)
    query = NAVIndexOf(buffer, NAV_URL_QUERY_TOKEN, hostStart)
    fragment = NAVIndexOf(buffer, NAV_URL_FRAGMENT_TOKEN, hostStart)

    // Parse path
    NAVParsePath(buffer, hostStart, length, url, path, query, fragment)

    // Parse query parameters
    NAVParseQuery(buffer, query, fragment, length, url)

    // Parse fragment
    NAVParseFragment(buffer, fragment, length, url)

    return true
}


/**
 * @function NAVParseQueryString
 * @internal
 * @description Parses a query string into key-value pairs.
 *
 * This function takes a query string (without the leading '?')
 * and splits it into an array of key-value pairs.
 *
 * @param {char[]} buffer - The query string to parse (without '?')
 * @param {_NAVKeyStringValuePair[]} queries - Array to populate with parsed query parameters
 *
 * @returns {void}
 *
 * @example
 * stack_var char queryString[100]
 * stack_var _NAVKeyStringValuePair queries[NAV_URL_MAX_QUERIES]
 *
 * queryString = 'param1=value1&param2=value2&param3='
 * NAVParseQueryString(queryString, queries)
 * // queries will contain:
 * // queries[1].Key = 'param1', queries[1].Value = 'value1'
 * // queries[2].Key = 'param2', queries[2].Value = 'value2'
 * // queries[3].Key = 'param3', queries[3].Value = ''
 *
 * @note This function is used internally by NAVParseUrl
 * @see NAVParseUrl
 */
define_function NAVParseQueryString(char buffer[], _NAVKeyStringValuePair queries[]) {
    stack_var integer x
    stack_var char pairs[NAV_URL_MAX_QUERIES][255]
    stack_var integer count

    count = NAVSplitString(buffer, '&', pairs)

    if (count <= 0) {
        return
    }

    for (x = 1; x <= count; x++) {
        stack_var integer index

        index = NAVIndexOf(pairs[x], '=', 1)

        if (index) {
            queries[x].Key = NAVStringSubstring(pairs[x], 1, index - 1)
            queries[x].Value = NAVStringSubstring(pairs[x], index + 1, length_array(pairs[x]) - index)
        }
        else {
            queries[x].Key = pairs[x]
            queries[x].Value = ''
        }
    }

    set_length_array(queries, count)
}


/**
 * @function NAVValidateUrl
 * @description Validates a URL string according to specified criteria.
 *
 * This function performs validation checks on a URL to ensure it meets
 * the requirements for a valid URL. It can optionally check that the
 * scheme matches one from a list of allowed schemes, validate port ranges,
 * and ensure required components are present.
 *
 * @param {char[]} buffer - The URL string to validate
 * @param {char[][]} allowedSchemes - Array of allowed schemes (e.g., 'http', 'https').
 *                                     Pass an empty array to skip scheme validation.
 * @param {integer} requireScheme - If true, URL must have a scheme (default: false)
 * @param {integer} requireHost - If true, URL must have a non-empty host (default: true)
 *
 * @returns {integer} - Returns true if the URL is valid, false otherwise
 *
 * @example
 * stack_var char url[255]
 * stack_var char schemes[2][10]
 * stack_var integer result
 *
 * // Validate HTTP/HTTPS URL
 * url = 'https://example.com:8080/path'
 * schemes[1] = 'http'
 * schemes[2] = 'https'
 * set_length_array(schemes, 2)
 * result = NAVValidateUrl(url, schemes, true, true)
 * // Returns true - valid HTTPS URL with proper port
 *
 * @example
 * // Invalid port range
 * url = 'http://example.com:99999/path'
 * result = NAVValidateUrl(url, schemes, true, true)
 * // Returns false - port exceeds 65535
 *
 * @example
 * // Invalid scheme
 * url = 'ftp://example.com/file'
 * result = NAVValidateUrl(url, schemes, true, true)
 * // Returns false - 'ftp' not in allowed schemes
 *
 * @note This function uses NAVParseUrl internally, so the URL must be parseable
 * @note Port validation checks that port is in range 1-65535 if specified
 * @note Scheme validation is case-insensitive
 * @see NAVParseUrl
 */
define_function integer NAVValidateUrl(char buffer[], char allowedSchemes[][], integer requireScheme, integer requireHost) {
    stack_var _NAVUrl url
    stack_var integer x
    stack_var integer schemeValid

    // First, try to parse the URL
    if (!NAVParseUrl(buffer, url)) {
        return false
    }

    // Check if scheme is required
    if (requireScheme && !length_array(url.Scheme)) {
        return false
    }

    // Check if scheme is in allowed list (if provided)
    if (max_length_array(allowedSchemes) > 0 && length_array(url.Scheme)) {
        schemeValid = false

        for (x = 1; x <= max_length_array(allowedSchemes); x++) {
            if (lower_string(url.Scheme) == lower_string(allowedSchemes[x])) {
                schemeValid = true
                break
            }
        }

        if (!schemeValid) {
            return false
        }
    }

    // Check if host is required and present
    if (requireHost && !length_array(url.Host)) {
        return false
    }

    // Validate port range if port is specified
    if (url.Port > 0 && (url.Port < 1 || url.Port > 65535)) {
        return false
    }

    return true
}


/**
 * @function NAVResolveUrl
 * @public
 * @description Resolves a relative URL reference against a base URL per RFC 3986 Section 5.
 *
 * This function implements the reference resolution algorithm defined in RFC 3986,
 * which combines a base URL with a relative reference to produce a target URL.
 * This is essential for handling relative links in HTML documents, APIs, and
 * other contexts where URLs may be relative to a base location.
 *
 * Resolution types supported:
 * - Absolute URLs: Returned as-is (e.g., "http://other.com/path")
 * - Protocol-relative: Uses base scheme (e.g., "//example.com/path")
 * - Absolute path: Uses base scheme/host (e.g., "/absolute/path")
 * - Relative path: Resolves against base path (e.g., "relative/path", "../parent")
 * - Query-only: Replaces base query (e.g., "?newquery")
 * - Fragment-only: Replaces base fragment (e.g., "#newfragment")
 *
 * @param {char[]} base - The base URL to resolve against
 * @param {char[]} reference - The relative or absolute URL reference to resolve
 *
 * @returns {char[NAV_MAX_BUFFER]} The resolved absolute URL
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 *
 * // Relative path
 * result = NAVResolveUrl('http://example.com/a/b/c', '../d')
 * // Returns 'http://example.com/a/d'
 *
 * // Absolute path
 * result = NAVResolveUrl('http://example.com/a/b/c', '/x/y')
 * // Returns 'http://example.com/x/y'
 *
 * // Protocol-relative
 * result = NAVResolveUrl('https://example.com/path', '//other.com/file')
 * // Returns 'https://other.com/file'
 *
 * // Query replacement
 * result = NAVResolveUrl('http://example.com/path?old=1', '?new=2')
 * // Returns 'http://example.com/path?new=2'
 *
 * // Fragment replacement
 * result = NAVResolveUrl('http://example.com/page#old', '#new')
 * // Returns 'http://example.com/page#new'
 *
 * @note Per RFC 3986, if the reference is an absolute URL, it is returned as-is
 * @note Path normalization (removing . and ..) is automatically applied
 * @note Empty reference returns the base URL without fragment
 *
 * @see NAVParseUrl
 * @see NAVBuildUrl
 * @see NAVUrlNormalizePath
 */
define_function char[NAV_MAX_BUFFER] NAVResolveUrl(char base[], char reference[]) {
    stack_var _NAVUrl baseUrl
    stack_var _NAVUrl targetUrl
    stack_var char targetPath[NAV_MAX_BUFFER]
    stack_var char basePath[NAV_MAX_BUFFER]
    stack_var char mergePath[NAV_MAX_BUFFER]
    stack_var integer lastSlash
    stack_var integer schemePos
    stack_var integer authorityPos
    stack_var integer queryPos
    stack_var integer fragmentPos
    stack_var char refScheme[NAV_MAX_URL_SCHEME]
    stack_var char refPath[NAV_MAX_BUFFER]
    stack_var char refQuery[NAV_MAX_BUFFER]
    stack_var char refFragment[NAV_MAX_BUFFER]

    // RFC 3986 Section 5.2: Reference Resolution Algorithm

    // Handle empty reference (return base without fragment)
    if (!length_array(reference)) {
        if (NAVParseUrl(base, baseUrl)) {
            baseUrl.Fragment = ''
            return NAVBuildUrl(baseUrl)
        }
        return ''
    }

    // Check if reference has a scheme (absolute URL)
    schemePos = NAVIndexOf(reference, NAV_URL_SCHEME_TOKEN, 1)

    if (schemePos > 0) {
        // Has scheme - it's an absolute URL, parse and return
        stack_var _NAVUrl absUrl
        if (NAVParseUrl(reference, absUrl)) {
            absUrl.Path = NAVUrlNormalizePath(absUrl.Path)
            return NAVBuildUrl(absUrl)
        }
        return ''
    }

    // Parse the base URL
    if (!NAVParseUrl(base, baseUrl)) {
        return ''
    }

    // Reference is relative - use base scheme
    targetUrl.Scheme = baseUrl.Scheme

    // Check for protocol-relative URL (starts with //)
    if (NAVStartsWith(reference, '//')) {
        // Parse authority from reference
        stack_var char authorityAndPath[NAV_MAX_BUFFER]
        stack_var _NAVUrl tempUrl

        authorityAndPath = "'http:', reference"  // Add temp scheme to parse
        if (NAVParseUrl(authorityAndPath, tempUrl)) {
            targetUrl.Host = tempUrl.Host
            targetUrl.Port = tempUrl.Port
            targetUrl.UserInfo = tempUrl.UserInfo
            targetUrl.HasUserInfo = tempUrl.HasUserInfo
            targetUrl.Path = NAVUrlNormalizePath(tempUrl.Path)
            set_length_array(targetUrl.Queries, length_array(tempUrl.Queries))
            targetUrl.Queries = tempUrl.Queries
            targetUrl.Fragment = tempUrl.Fragment
            return NAVBuildUrl(targetUrl)
        }
        return ''
    }

    // Use base authority
    targetUrl.Host = baseUrl.Host
    targetUrl.Port = baseUrl.Port
    targetUrl.UserInfo = baseUrl.UserInfo
    targetUrl.HasUserInfo = baseUrl.HasUserInfo

    // Check for query-only reference (starts with ?)
    if (NAVStartsWith(reference, '?')) {
        // Use base path, replace query, no fragment from reference
        targetUrl.Path = baseUrl.Path
        refQuery = NAVStringSubstring(reference, 2, length_array(reference) - 1)

        // Check if there's a fragment in the query-only reference
        fragmentPos = NAVIndexOf(refQuery, '#', 1)
        if (fragmentPos > 0) {
            refFragment = NAVStringSubstring(refQuery, fragmentPos + 1, length_array(refQuery) - fragmentPos)
            refQuery = NAVStringSubstring(refQuery, 1, fragmentPos - 1)
        }

        // Parse query
        if (length_array(refQuery)) {
            stack_var char tempUrlStr[NAV_MAX_BUFFER]
            stack_var _NAVUrl tempUrl
            tempUrlStr = "'http://h/?', refQuery"
            if (NAVParseUrl(tempUrlStr, tempUrl)) {
                set_length_array(targetUrl.Queries, length_array(tempUrl.Queries))
                targetUrl.Queries = tempUrl.Queries
            }
        }

        targetUrl.Fragment = refFragment
        return NAVBuildUrl(targetUrl)
    }

    // Check for fragment-only reference (starts with #)
    if (NAVStartsWith(reference, '#')) {
        // Use base path and query, replace only fragment
        targetUrl.Path = baseUrl.Path
        set_length_array(targetUrl.Queries, length_array(baseUrl.Queries))
        targetUrl.Queries = baseUrl.Queries
        targetUrl.Fragment = NAVStringSubstring(reference, 2, length_array(reference) - 1)
        return NAVBuildUrl(targetUrl)
    }

    // Parse query and fragment from reference
    queryPos = NAVIndexOf(reference, '?', 1)
    fragmentPos = NAVIndexOf(reference, '#', 1)

    if (fragmentPos > 0 && (queryPos == 0 || fragmentPos < queryPos)) {
        // Fragment found
        refFragment = NAVStringSubstring(reference, fragmentPos + 1, length_array(reference) - fragmentPos)

        if (queryPos > 0 && queryPos < fragmentPos) {
            // Query before fragment
            refQuery = NAVStringSubstring(reference, queryPos + 1, fragmentPos - queryPos - 1)
            refPath = NAVStringSubstring(reference, 1, queryPos - 1)
        }
        else {
            // No query or query after fragment (shouldn't happen, but handle it)
            refPath = NAVStringSubstring(reference, 1, fragmentPos - 1)
        }
    }
    else if (queryPos > 0) {
        // Query found, no fragment or fragment after query
        if (fragmentPos > queryPos) {
            refFragment = NAVStringSubstring(reference, fragmentPos + 1, length_array(reference) - fragmentPos)
            refQuery = NAVStringSubstring(reference, queryPos + 1, fragmentPos - queryPos - 1)
        }
        else {
            refQuery = NAVStringSubstring(reference, queryPos + 1, length_array(reference) - queryPos)
        }
        refPath = NAVStringSubstring(reference, 1, queryPos - 1)
    }
    else {
        // No query or fragment markers, entire reference is path
        refPath = reference
    }

    // Handle based on path type
    if (!length_array(refPath)) {
        // Empty path - use base path
        targetUrl.Path = baseUrl.Path

        if (length_array(refQuery)) {
            // Parse query from reference
            stack_var char tempUrlStr[NAV_MAX_BUFFER]
            stack_var _NAVUrl tempUrl2
            tempUrlStr = "'http://h/?', refQuery"
            if (NAVParseUrl(tempUrlStr, tempUrl2)) {
                set_length_array(targetUrl.Queries, length_array(tempUrl2.Queries))
                targetUrl.Queries = tempUrl2.Queries
            }
        }
        else {
            // Use base query
            set_length_array(targetUrl.Queries, length_array(baseUrl.Queries))
            targetUrl.Queries = baseUrl.Queries
        }
    }
    else if (NAVStartsWith(refPath, '/')) {
        // Absolute path
        // Ensure paths ending in dot-segments have trailing slash before normalization
        if (NAVEndsWith(refPath, '/.') || NAVEndsWith(refPath, '/..')) {
            refPath = "refPath, '/'"
        }
        else if (refPath == '.' || refPath == '..') {
            refPath = "refPath, '/'"
        }

        targetPath = NAVUrlNormalizePath(refPath)
        targetUrl.Path = targetPath

        if (length_array(refQuery)) {
            stack_var char tempUrlStr2[NAV_MAX_BUFFER]
            stack_var _NAVUrl tempUrl3
            tempUrlStr2 = "'http://h/?', refQuery"
            if (NAVParseUrl(tempUrlStr2, tempUrl3)) {
                set_length_array(targetUrl.Queries, length_array(tempUrl3.Queries))
                targetUrl.Queries = tempUrl3.Queries
            }
        }
    }
    else {
        // Relative path - merge with base
        if (length_array(baseUrl.Host) && !length_array(baseUrl.Path)) {
            // Base has authority but no path: prepend /
            mergePath = "'/', refPath"
        }
        else {
            // Remove last segment from base path
            basePath = baseUrl.Path
            lastSlash = NAVLastIndexOf(basePath, '/')

            if (lastSlash > 0) {
                // Keep everything up to and including the last slash
                mergePath = NAVStringSubstring(basePath, 1, lastSlash)
                mergePath = "mergePath, refPath"
            }
            else {
                // No slash in base path
                mergePath = refPath
            }
        }

        // Ensure paths ending in dot-segments have trailing slash before normalization
        if (NAVEndsWith(mergePath, '/.') || NAVEndsWith(mergePath, '/..')) {
            mergePath = "mergePath, '/'"
        }
        else if (mergePath == '.' || mergePath == '..') {
            mergePath = "mergePath, '/'"
        }

        targetPath = NAVUrlNormalizePath(mergePath)
        targetUrl.Path = targetPath

        if (length_array(refQuery)) {
            stack_var char tempUrlStr3[NAV_MAX_BUFFER]
            stack_var _NAVUrl tempUrl4
            tempUrlStr3 = "'http://h/?', refQuery"
            if (NAVParseUrl(tempUrlStr3, tempUrl4)) {
                set_length_array(targetUrl.Queries, length_array(tempUrl4.Queries))
                targetUrl.Queries = tempUrl4.Queries
            }
        }
    }

    // Fragment is always from reference
    targetUrl.Fragment = refFragment

    return NAVBuildUrl(targetUrl)
}


#END_IF // __NAV_FOUNDATION_URL__
