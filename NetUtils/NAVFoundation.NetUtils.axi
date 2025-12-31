PROGRAM_NAME='NAVFoundation.NetUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_NETUTILS__
#DEFINE __NAV_FOUNDATION_NETUTILS__ 'NAVFoundation.NetUtils'

#include 'NAVFoundation.NetUtils.h.axi'
#include 'NAVFoundation.StringUtils.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'


/**
 * @function NAVNetParseIPv4
 * @public
 * @description Parses an IPv4 address string into its component parts.
 *
 * This function implements a fully RFC 791 compliant IPv4 address parser.
 * It validates that the input string represents a valid IPv4 address in
 * dotted-decimal notation and populates the provided structure with the
 * parsed components.
 *
 * RFC 791 Requirements:
 * - Must be in dotted-decimal notation (e.g., "192.168.1.1")
 * - Must have exactly 4 octets separated by dots
 * - Each octet must be a decimal number from 0 to 255
 * - No leading zeros allowed (except for "0" itself)
 * - No whitespace or other characters
 *
 * @param {char[]} data - The IPv4 address string to parse
 * @param {_NAVIP} ip - Structure to populate with parsed address components
 *
 * @returns {char} true if parsing succeeded, false otherwise
 *
 * @example
 * stack_var _NAVIP ip
 * stack_var char result
 * result = NAVNetParseIPv4('192.168.1.1', ip)
 * if (result) {
 *     // ip.Version = 4
 *     // ip.Octets[1] = 192
 *     // ip.Octets[2] = 168
 *     // ip.Octets[3] = 1
 *     // ip.Octets[4] = 1
 *     // ip.Address = '192.168.1.1'
 * }
 *
 * @see _NAVIP
 */
define_function char NAVNetParseIPv4(char data[], _NAVIP ip) {
    stack_var char parts[16][16]  // Allow more parts to catch invalid inputs safely
    stack_var integer count
    stack_var integer x
    stack_var char trimmedData[NAV_MAX_BUFFER]

    // Initialize the structure
    NAVNetIPInit(ip)

    // Trim any whitespace
    trimmedData = NAVTrimString(data)

    // Validate non-empty input
    if (!length_array(trimmedData)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetParseIPv4',
                                    'Invalid argument. The provided IPv4 address string is empty')
        return false
    }

    // Split the string by dots
    count = NAVSplitString(trimmedData, '.', parts)

    // Must have exactly 4 octets
    if (count != 4) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetParseIPv4',
                                    "'Invalid IPv4 format. Expected 4 octets but found ', itoa(count)")
        return false
    }

    // Validate and parse each octet
    for (x = 1; x <= 4; x++) {
        stack_var char octetStr[16]
        stack_var integer octetLen
        stack_var integer octetValue
        stack_var integer y

        octetStr = parts[x]
        octetLen = length_array(octetStr)

        // Each octet must be non-empty
        if (octetLen == 0) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_NETUTILS__,
                                        'NAVNetParseIPv4',
                                        "'Octet ', itoa(x), ' is empty'")
            return false
        }

        // Check for any whitespace in the octet (not allowed)
        for (y = 1; y <= octetLen; y++) {
            if (NAVIsWhitespace(octetStr[y])) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_NETUTILS__,
                                            'NAVNetParseIPv4',
                                            "'Octet ', itoa(x), ' contains whitespace'")
                return false
            }
        }

        // Octet must not exceed 3 digits
        if (octetLen > 3) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_NETUTILS__,
                                        'NAVNetParseIPv4',
                                        "'Octet ', itoa(x), ' has more than 3 digits'")
            return false
        }

        // No leading zeros (except "0" itself)
        if (octetLen > 1 && octetStr[1] == '0') {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_NETUTILS__,
                                        'NAVNetParseIPv4',
                                        "'Octet ', itoa(x), ' has invalid leading zero'")
            return false
        }

        // All characters must be digits
        for (y = 1; y <= octetLen; y++) {
            if (!NAVIsDigit(octetStr[y])) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_NETUTILS__,
                                            'NAVNetParseIPv4',
                                            "'Octet ', itoa(x), ' contains non-digit character'")
                return false
            }
        }

        // Convert to integer and validate range (0-255)
        octetValue = atoi(octetStr)
        if (octetValue < 0 || octetValue > 255) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_NETUTILS__,
                                        'NAVNetParseIPv4',
                                        "'Octet ', itoa(x), ' value ', itoa(octetValue), ' is out of range (0-255)'")
            return false
        }

        // Store the octet value
        ip.Octets[x] = type_cast(octetValue)
    }

    // Store the IP version and normalized string representation
    ip.Version = 4
    set_length_array(ip.Octets, 4)  // Ensure only first 4 octets are considered for IPv4
    ip.Address = "itoa(ip.Octets[1]), '.', itoa(ip.Octets[2]), '.', itoa(ip.Octets[3]), '.', itoa(ip.Octets[4])"

    return true
}


/**
 * @function NAVNetParseIP
 * @public
 * @description Parses an IP address string into its component parts.
 *
 * This is a convenience wrapper function that automatically detects and parses
 * IP addresses. Currently, only IPv4 addresses are supported, but this function
 * provides a forward-compatible API for future IPv6 support.
 *
 * For IPv4 addresses, this function delegates to NAVNetParseIPv4() which
 * implements full RFC 791 compliance with validation of dotted-decimal notation,
 * octet ranges (0-255), and proper formatting.
 *
 * @param {char[]} data - The IP address string to parse
 * @param {_NAVIP} ip - Structure to populate with parsed address components
 *
 * @returns {char} true if parsing succeeded, false otherwise
 *
 * @example
 * stack_var _NAVIP ip
 * stack_var char result
 * result = NAVNetParseIP('192.168.1.1', ip)
 * if (result) {
 *     // ip.Version = 4
 *     // ip.Octets[1] = 192
 *     // ip.Octets[2] = 168
 *     // ip.Octets[3] = 1
 *     // ip.Octets[4] = 1
 *     // ip.Address = '192.168.1.1'
 * }
 *
 * @note Currently only IPv4 is supported. Future versions may add IPv6 support
 *       with automatic version detection.
 *
 * @see NAVNetParseIPv4
 * @see _NAVIP
 */
define_function char NAVNetParseIP(char data[], _NAVIP ip) {
    // Currently only IPv4 is supported
    // Future versions may add IPv6 support
    return NAVNetParseIPv4(data, ip)
}


/**
 * @function NAVNetIPInit
 * @public
 * @description Initializes an IP structure to a clean state.
 *
 * This function resets all fields of a _NAVIP structure to their default
 * values. This is useful when you need to ensure a structure is in a known
 * state before parsing, or when reusing a structure for multiple operations.
 *
 * The function sets:
 * - Version to 0 (uninitialized)
 * - All octets to 0
 * - Address string to empty
 *
 * @param {_NAVIP} ip - Structure to initialize
 *
 * @example
 * stack_var _NAVIP ip
 * NAVNetIPInit(ip)
 * // ip.Version = 0
 * // ip.Octets = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
 * // ip.Address = ''
 *
 * @note This function is automatically called by NAVNetParseIPv4(), so you
 *       typically don't need to call it manually unless reusing a structure.
 *
 * @see _NAVIP
 * @see NAVNetParseIPv4
 */
define_function NAVNetIPInit(_NAVIP ip) {
    stack_var integer x

    ip.Version = 0

    for (x = 1; x <= 16; x++) {
        ip.Octets[x] = 0
    }

    ip.Address = ''
}


/**
 * @function NAVNetSplitHostPort
 * @public
 * @description Splits a host:port string into separate host and port components.
 *
 * This function parses a string in the format "host:port" and extracts the
 * host and port as separate values. It does not validate that the host is
 * a valid IP address or hostname - it simply performs string splitting.
 *
 * The function handles the following cases:
 * - "192.168.1.1:8080" → host="192.168.1.1", port=8080
 * - "example.com:8080" → host="example.com", port=8080
 * - "192.168.1.1" → host="192.168.1.1", port=0 (no port specified)
 * - Invalid formats return false (e.g., ":8080", "192.168.1.1:", multiple colons)
 *
 * Similar to Go's net.SplitHostPort, but simpler (no IPv6 bracket handling yet).
 *
 * @param {char[]} hostport - The host:port string to split
 * @param {char[]} host - Output: the host portion
 * @param {integer} port - Output: the port number (0 if no port specified)
 *
 * @returns {char} true if parsing succeeded, false if invalid format
 *
 * @example
 * stack_var char host[255]
 * stack_var integer port
 * if (NAVNetSplitHostPort('192.168.1.1:8080', host, port)) {
 *     // host = '192.168.1.1'
 *     // port = 8080
 * }
 *
 * @see NAVNetParseIPAddr
 * @see NAVNetJoinHostPort
 */
define_function char NAVNetSplitHostPort(char hostport[], char host[], integer port) {
    stack_var char trimmedData[NAV_MAX_BUFFER]
    stack_var integer colonPos
    stack_var char portStr[10]
    stack_var slong portResult
    stack_var integer portValue

    // Initialize outputs
    host = ''
    port = 0

    // Trim whitespace
    trimmedData = NAVTrimString(hostport)

    // Validate non-empty input
    if (!length_array(trimmedData)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetSplitHostPort',
                                    'Invalid argument. The provided host:port string is empty')
        return false
    }

    // Find the last colon (to handle IPv6 in future if needed)
    colonPos = NAVLastIndexOf(trimmedData, ':')

    // No colon means no port - return host only with port=0
    if (colonPos == 0) {
        host = trimmedData
        port = 0
        return true
    }

    // Colon at start or end is invalid
    if (colonPos == 1 || colonPos == length_array(trimmedData)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetSplitHostPort',
                                    'Invalid host:port format. Host or port cannot be empty')
        return false
    }

    // Extract host and port parts
    host = NAVStringSubstring(trimmedData, 1, colonPos - 1)
    portStr = NAVStringSubstring(trimmedData, colonPos + 1, 0)  // 0 = extract to end

    // Validate port string is not empty
    if (!length_array(portStr)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetSplitHostPort',
                                    'Invalid host:port format. Port cannot be empty')
        return false
    }

    // Check for multiple colons (invalid format)
    if (NAVContains(host, ':')) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetSplitHostPort',
                                    'Invalid host:port format. Multiple colons detected')
        return false
    }

    // Check all characters in port are digits
    {
        stack_var integer x
        for (x = 1; x <= length_array(portStr); x++) {
            if (!NAVIsDigit(portStr[x])) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_NETUTILS__,
                                            'NAVNetSplitHostPort',
                                            "'Port contains non-digit character: ', portStr")
                return false
            }
        }
    }

    // Parse port as slong to handle overflow
    portResult = atoi(portStr)

    // Validate port range (0-65535)
    if (portResult < 0 || portResult > 65535) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetSplitHostPort',
                                    "'Port value ', itoa(portResult), ' is out of range (0-65535)'")
        return false
    }

    // Type cast to integer port
    port = type_cast(portResult)
    return true
}


/**
 * @function NAVNetParseIPAddr
 * @public
 * @description Parses a host:port string into an IP address and port structure.
 *
 * This function combines host:port splitting with IP address validation,
 * parsing a string like "192.168.1.1:8080" into a structured _NAVIPAddr.
 * It validates that the host portion is a valid IPv4 address.
 *
 * Similar to Go's net.ResolveTCPAddr, but without DNS resolution - only
 * accepts literal IP addresses.
 *
 * @param {char[]} ipport - The IP:port string to parse (e.g., "192.168.1.1:8080")
 * @param {_NAVIPAddr} addr - Structure to populate with parsed IP and port
 *
 * @returns {char} true if parsing succeeded, false if invalid format or IP
 *
 * @example
 * stack_var _NAVIPAddr addr
 * if (NAVNetParseIPAddr('192.168.1.1:8080', addr)) {
 *     // addr.IP.Version = 4
 *     // addr.IP.Octets[1] = 192
 *     // addr.IP.Address = '192.168.1.1'
 *     // addr.Port = 8080
 * }
 *
 * @see _NAVIPAddr
 * @see NAVNetSplitHostPort
 * @see NAVNetParseIPv4
 */
define_function char NAVNetParseIPAddr(char ipport[], _NAVIPAddr addr) {
    stack_var char host[NAV_MAX_BUFFER]
    stack_var integer port

    // Initialize the IP structure
    NAVNetIPInit(addr.IP)
    addr.Port = 0

    // Split host and port
    if (!NAVNetSplitHostPort(ipport, host, port)) {
        return false
    }

    // Parse the host as an IPv4 address
    if (!NAVNetParseIPv4(host, addr.IP)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetParseIPAddr',
                                    "'Host portion is not a valid IPv4 address: ', host")
        return false
    }

    // Store the port
    addr.Port = port

    return true
}


/**
 * @function NAVNetJoinHostPort
 * @public
 * @description Joins a host and port into a host:port string.
 *
 * This function combines a host string and port number into the standard
 * "host:port" format. It's the reverse operation of NAVNetSplitHostPort.
 *
 * Similar to Go's net.JoinHostPort.
 *
 * @param {char[]} host - The host (IP address or hostname)
 * @param {integer} port - The port number (0-65535)
 *
 * @returns {char[]} The formatted "host:port" string, or empty string if invalid
 *
 * @example
 * stack_var char result[NAV_MAX_BUFFER]
 * result = NAVNetJoinHostPort('192.168.1.1', 8080)
 * // result = '192.168.1.1:8080'
 *
 * @see NAVNetSplitHostPort
 */
define_function char[NAV_MAX_BUFFER] NAVNetJoinHostPort(char host[], integer port) {
    stack_var char trimmedHost[NAV_MAX_BUFFER]

    // Trim and validate host is not empty
    trimmedHost = NAVTrimString(host)
    if (!length_array(trimmedHost)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetJoinHostPort',
                                    'Invalid argument. Host cannot be empty')
        return ''
    }

    // Validate port range
    if (port < 0 || port > 65535) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetJoinHostPort',
                                    "'Port value ', itoa(port), ' is out of range (0-65535)'")
        return ''
    }

    // Join host and port
    return "trimmedHost, ':', itoa(port)"
}


#END_IF // __NAV_FOUNDATION_NETUTILS__
