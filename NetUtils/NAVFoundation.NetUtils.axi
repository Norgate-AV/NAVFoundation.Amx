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


/**
 * @function NAVNetHostnameInit
 * @public
 * @description Initializes a hostname structure to a clean state.
 *
 * This function resets all fields of a _NAVHostname structure to their default
 * values. This is useful when you need to ensure a structure is in a known
 * state before parsing, or when reusing a structure for multiple operations.
 *
 * The function sets:
 * - Hostname to empty string
 * - All labels to empty strings
 * - LabelCount to 0
 *
 * @param {_NAVHostname} hostname - Structure to initialize
 *
 * @example
 * stack_var _NAVHostname host
 * NAVNetHostnameInit(host)
 * // host.Hostname = ''
 * // host.LabelCount = 0
 *
 * @note This function is automatically called by NAVNetParseHostname(), so you
 *       typically don't need to call it manually unless reusing a structure.
 *
 * @see _NAVHostname
 * @see NAVNetParseHostname
 */
define_function NAVNetHostnameInit(_NAVHostname hostname) {
    stack_var integer x

    hostname.Hostname = ''
    hostname.LabelCount = 0

    for (x = 1; x <= 127; x++) {
        hostname.Labels[x] = ''
    }
}


/**
 * @function NAVNetParseHostname
 * @public
 * @description Parses and validates a hostname string according to RFC 1123/952.
 *
 * This function implements an RFC 1123/952 compliant hostname parser and validator.
 * It validates that the input string represents a valid hostname and populates
 * the provided structure with the parsed components.
 *
 * RFC 1123/952 Requirements:
 * - Total length must not exceed 253 characters
 * - Labels separated by dots (e.g., "sub.example.com" has 3 labels)
 * - Each label must be 1-63 characters long
 * - Labels must start and end with alphanumeric characters (a-z, A-Z, 0-9)
 * - Labels may contain hyphens in the middle
 * - Hostname must not start or end with a dot or hyphen
 * - At least one label required (empty hostnames are invalid)
 *
 * Valid Examples:
 * - "example.com"
 * - "sub.example.com"
 * - "my-device.local"
 * - "localhost"
 * - "server1"
 * - "web-01.prod.example.com"
 *
 * Invalid Examples:
 * - "-invalid.com" (starts with hyphen)
 * - "invalid-.com" (label ends with hyphen)
 * - ".example.com" (starts with dot)
 * - "example.com." (ends with dot)
 * - "ex ample.com" (contains space)
 * - "" (empty string)
 * - "a.b.c..." (consecutive dots)
 *
 * @param {char[]} data - The hostname string to parse
 * @param {_NAVHostname} hostname - Structure to populate with parsed hostname components
 *
 * @returns {char} true if parsing succeeded, false otherwise
 *
 * @example
 * stack_var _NAVHostname host
 * stack_var char result
 * result = NAVNetParseHostname('example.com', host)
 * if (result) {
 *     // host.Hostname = 'example.com'
 *     // host.Labels[1] = 'example'
 *     // host.Labels[2] = 'com'
 *     // host.LabelCount = 2
 * }
 *
 * @see _NAVHostname
 * @see NAVNetHostnameInit
 */
define_function char NAVNetParseHostname(char data[], _NAVHostname hostname) {
    stack_var char trimmedData[255]
    stack_var integer dataLen
    stack_var integer x
    stack_var integer labelCount

    // Initialize the structure
    NAVNetHostnameInit(hostname)

    // Trim any whitespace
    trimmedData = NAVTrimString(data)
    dataLen = length_array(trimmedData)

    // Validate non-empty input
    if (dataLen == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetParseHostname',
                                    'Invalid argument. The provided hostname string is empty')
        return false
    }

    // Check maximum length (RFC 1123: 253 characters)
    if (dataLen > 253) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetParseHostname',
                                    "'Hostname exceeds maximum length of 253 characters (', itoa(dataLen), ' characters)'")
        return false
    }

    // Check for leading or trailing dots
    if (trimmedData[1] == '.' || trimmedData[dataLen] == '.') {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetParseHostname',
                                    'Hostname cannot start or end with a dot')
        return false
    }

    // Check for leading or trailing hyphens
    if (trimmedData[1] == '-' || trimmedData[dataLen] == '-') {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetParseHostname',
                                    'Hostname cannot start or end with a hyphen')
        return false
    }

    // Split into labels by dots
    labelCount = NAVSplitString(trimmedData, '.', hostname.Labels)

    if (labelCount == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetParseHostname',
                                    'Hostname must contain at least one label')
        return false
    }

    // Validate each label
    for (x = 1; x <= labelCount; x++) {
        stack_var char label[64]
        stack_var integer labelLen
        stack_var integer y

        label = hostname.Labels[x]
        labelLen = length_array(label)

        // Each label must be non-empty (catches consecutive dots like "a..b")
        if (labelLen == 0) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_NETUTILS__,
                                        'NAVNetParseHostname',
                                        "'Label ', itoa(x), ' is empty (consecutive dots detected)'")
            return false
        }

        // Each label must be 1-63 characters (RFC 1123)
        if (labelLen > 63) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_NETUTILS__,
                                        'NAVNetParseHostname',
                                        "'Label ', itoa(x), ' exceeds maximum length of 63 characters (', itoa(labelLen), ' characters)'")
            return false
        }

        // First character must be alphanumeric (letters or digits only, no underscore per RFC 952/1123)
        if (!NAVIsAlpha(label[1]) && !NAVIsDigit(label[1])) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_NETUTILS__,
                                        'NAVNetParseHostname',
                                        "'Label ', itoa(x), ' must start with an alphanumeric character'")
            return false
        }

        // Last character must be alphanumeric (letters or digits only, no underscore per RFC 952/1123)
        if (!NAVIsAlpha(label[labelLen]) && !NAVIsDigit(label[labelLen])) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_NETUTILS__,
                                        'NAVNetParseHostname',
                                        "'Label ', itoa(x), ' must end with an alphanumeric character'")
            return false
        }

        // Middle characters (if any) must be alphanumeric or hyphen (no underscore per RFC 952/1123)
        for (y = 2; y < labelLen; y++) {
            if (!NAVIsAlpha(label[y]) && !NAVIsDigit(label[y]) && label[y] != '-') {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_NETUTILS__,
                                            'NAVNetParseHostname',
                                            "'Label ', itoa(x), ' contains invalid character at position ', itoa(y)")
                return false
            }
        }
    }

    // All validations passed - store the hostname and label count
    hostname.Hostname = trimmedData
    hostname.LabelCount = labelCount

    return true
}


/**
 * @function NAVNetIsMalformedIP
 * @public
 * @description Determines if a string appears to be a malformed IP address.
 *
 * This function checks if a string contains only digits and dots, which
 * indicates it was intended to be an IP address but failed validation
 * (e.g., "256.1.1.1", "192.168.1", "..."). This is useful for distinguishing
 * between malformed IP addresses and valid hostnames after NAVNetParseIP fails.
 *
 * Typical usage pattern:
 * 1. Try NAVNetParseIP first
 * 2. If it fails, use NAVNetIsMalformedIP to determine why
 * 3. If true, it's a malformed IP (reject it)
 * 4. If false, it might be a valid hostname (try NAVNetParseHostname)
 *
 * @param {char[]} address - String to check
 *
 * @returns {char} true if string contains only digits and dots (malformed IP),
 *                 false if it contains other characters (could be hostname)
 *
 * @example
 * stack_var _NAVIP ip
 * if (!NAVNetParseIP('256.1.1.1', ip)) {
 *     if (NAVNetIsMalformedIP('256.1.1.1')) {
 *         // This is a malformed IP address
 *     }
 * }
 *
 * @see NAVNetParseIP
 * @see NAVNetParseHostname
 */
define_function char NAVNetIsMalformedIP(char address[]) {
    stack_var integer i

    if (!length_array(address)) {
        return false
    }

    for (i = 1; i <= length_array(address); i++) {
        if (!NAVIsDigit(address[i]) && address[i] != '.') {
            return false
        }
    }

    return true
}


/**
 * @function NAVNetSubnetMaskToPrefix
 * @public
 * @description Converts a subnet mask in dotted-decimal notation to its CIDR prefix length.
 *
 * This function parses a subnet mask string (e.g., "255.255.254.0") and returns
 * the equivalent CIDR prefix length (e.g., 23). The mask must be a valid contiguous
 * mask where all network bits (1s) precede all host bits (0s).
 *
 * Valid subnet mask octets are: 0, 128, 192, 224, 240, 248, 252, 254, 255.
 * Any other octet value, or a non-contiguous ordering (e.g., a non-zero octet
 * appearing after a zero octet), is considered invalid.
 *
 * @param {char[]} mask - The subnet mask string in dotted-decimal notation
 *
 * @returns {integer} The CIDR prefix length (0-32) on success, or 255 on failure
 *
 * @example
 * stack_var integer prefix
 * prefix = NAVNetSubnetMaskToPrefix('255.255.255.0')    // 24
 * prefix = NAVNetSubnetMaskToPrefix('255.255.254.0')    // 23
 * prefix = NAVNetSubnetMaskToPrefix('255.255.255.128')  // 25
 * prefix = NAVNetSubnetMaskToPrefix('255.0.0.0')        // 8
 * prefix = NAVNetSubnetMaskToPrefix('0.0.0.0')          // 0
 * prefix = NAVNetSubnetMaskToPrefix('255.255.255.255')  // 32
 * prefix = NAVNetSubnetMaskToPrefix('255.255.1.0')      // 255 (invalid)
 *
 * @see NAVNetCalculateBroadcast
 * @see NAVNetCalculateBroadcastFromPrefix
 */
define_function integer NAVNetSubnetMaskToPrefix(char mask[]) {
    stack_var _NAVIP maskIP
    stack_var integer prefix
    stack_var integer x
    stack_var integer octet
    stack_var char foundZeroByte

    if (!NAVNetParseIPv4(mask, maskIP)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetSubnetMaskToPrefix',
                                    "'Invalid subnet mask format: ', mask")
        return 255
    }

    prefix = 0
    foundZeroByte = false

    for (x = 1; x <= 4; x++) {
        octet = type_cast(maskIP.Octets[x])

        if (foundZeroByte && octet != 0) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_NETUTILS__,
                                        'NAVNetSubnetMaskToPrefix',
                                        "'Invalid subnet mask: non-contiguous bits in mask: ', mask")
            return 255
        }

        switch (octet) {
            case 255: { prefix = prefix + 8 }
            case 254: { prefix = prefix + 7; foundZeroByte = true }
            case 252: { prefix = prefix + 6; foundZeroByte = true }
            case 248: { prefix = prefix + 5; foundZeroByte = true }
            case 240: { prefix = prefix + 4; foundZeroByte = true }
            case 224: { prefix = prefix + 3; foundZeroByte = true }
            case 192: { prefix = prefix + 2; foundZeroByte = true }
            case 128: { prefix = prefix + 1; foundZeroByte = true }
            case 0:   { foundZeroByte = true }
            default: {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_NETUTILS__,
                                            'NAVNetSubnetMaskToPrefix',
                                            "'Invalid subnet mask octet value ', itoa(octet), ' in mask: ', mask")
                return 255
            }
        }
    }

    return prefix
}


/**
 * @function NAVNetCalculateBroadcastFromPrefix
 * @public
 * @description Calculates the IPv4 broadcast address for a given IP address and CIDR prefix length.
 *
 * The broadcast address is the highest address in the subnet and is computed as:
 *   broadcast = IP OR (NOT mask)
 * where the subnet mask is derived from the prefix length, and NOT mask is the
 * wildcard mask (i.e., 255 - mask_octet for each octet).
 *
 * @param {char[]} ip - The IP address in dotted-decimal notation (e.g., "192.168.1.100")
 * @param {integer} prefix - The CIDR prefix length, 0-32 (e.g., 24)
 *
 * @returns {char[16]} The broadcast address string on success, or empty string on failure
 *
 * @example
 * stack_var char broadcast[16]
 * broadcast = NAVNetCalculateBroadcastFromPrefix('192.168.1.100', 24)
 * // broadcast = '192.168.1.255'
 *
 * broadcast = NAVNetCalculateBroadcastFromPrefix('10.0.0.50', 23)
 * // broadcast = '10.0.1.255'
 *
 * broadcast = NAVNetCalculateBroadcastFromPrefix('172.16.5.1', 16)
 * // broadcast = '172.16.255.255'
 *
 * @see NAVNetCalculateBroadcast
 * @see NAVNetSubnetMaskToPrefix
 */
define_function char[16] NAVNetCalculateBroadcastFromPrefix(char ip[], integer prefix) {
    stack_var _NAVIP ipParsed
    stack_var integer prefixRemaining
    stack_var integer results[4]
    stack_var integer x

    if (prefix > 32) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetCalculateBroadcastFromPrefix',
                                    "'Invalid prefix length: ', itoa(prefix), '. Must be 0-32'")
        return ''
    }

    if (!NAVNetParseIPv4(ip, ipParsed)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetCalculateBroadcastFromPrefix',
                                    "'Invalid IP address: ', ip")
        return ''
    }

    // For each octet, compute how many host bits remain, then:
    //   wildcard = (1 << hostBits) - 1
    //   broadcast = ip | wildcard
    prefixRemaining = prefix

    for (x = 1; x <= 4; x++) {
        stack_var integer hostBits

        if (prefixRemaining >= 8) {
            hostBits = 0
            prefixRemaining = prefixRemaining - 8
        } else {
            hostBits = 8 - prefixRemaining
            prefixRemaining = 0
        }

        results[x] = type_cast(ipParsed.Octets[x]) | (type_cast(1 << hostBits) - 1)
    }

    return "itoa(results[1]), '.', itoa(results[2]), '.', itoa(results[3]), '.', itoa(results[4])"
}


/**
 * @function NAVNetCalculateBroadcast
 * @public
 * @description Calculates the IPv4 broadcast address for a given IP address and subnet mask.
 *
 * This is a convenience wrapper around NAVNetCalculateBroadcastFromPrefix that
 * accepts a subnet mask in dotted-decimal notation. The mask is validated and
 * converted to a prefix length, then the broadcast is computed as:
 *   broadcast = IP OR (NOT mask)
 *
 * @param {char[]} ip - The IP address in dotted-decimal notation (e.g., "192.168.1.100")
 * @param {char[]} mask - The subnet mask in dotted-decimal notation (e.g., "255.255.255.0")
 *
 * @returns {char[16]} The broadcast address string on success, or empty string on failure
 *
 * @example
 * stack_var char broadcast[16]
 * broadcast = NAVNetCalculateBroadcast('192.168.1.100', '255.255.255.0')
 * // broadcast = '192.168.1.255'
 *
 * broadcast = NAVNetCalculateBroadcast('10.0.0.50', '255.255.254.0')
 * // broadcast = '10.0.1.255'
 *
 * broadcast = NAVNetCalculateBroadcast('172.16.5.1', '255.255.0.0')
 * // broadcast = '172.16.255.255'
 *
 * @see NAVNetCalculateBroadcastFromPrefix
 * @see NAVNetSubnetMaskToPrefix
 */
define_function char[16] NAVNetCalculateBroadcast(char ip[], char mask[]) {
    stack_var integer prefix

    prefix = NAVNetSubnetMaskToPrefix(mask)

    if (prefix == 255) {
        // Error already logged by NAVNetSubnetMaskToPrefix
        return ''
    }

    return NAVNetCalculateBroadcastFromPrefix(ip, prefix)
}


/**
 * @function NAVNetPrefixToSubnetMask
 * @public
 * @description Converts a CIDR prefix length to a subnet mask in dotted-decimal notation.
 *
 * This is the reverse operation of NAVNetSubnetMaskToPrefix, completing the
 * bidirectional prefix/mask conversion API.
 *
 * @param {integer} prefix - The CIDR prefix length (0-32)
 *
 * @returns {char[16]} The subnet mask string on success, or empty string on failure
 *
 * @example
 * stack_var char mask[16]
 * mask = NAVNetPrefixToSubnetMask(24)   // '255.255.255.0'
 * mask = NAVNetPrefixToSubnetMask(23)   // '255.255.254.0'
 * mask = NAVNetPrefixToSubnetMask(16)   // '255.255.0.0'
 * mask = NAVNetPrefixToSubnetMask(0)    // '0.0.0.0'
 * mask = NAVNetPrefixToSubnetMask(32)   // '255.255.255.255'
 *
 * @see NAVNetSubnetMaskToPrefix
 */
define_function char[16] NAVNetPrefixToSubnetMask(integer prefix) {
    stack_var integer octets[4]
    stack_var integer prefixRemaining
    stack_var integer x

    if (prefix > 32) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetPrefixToSubnetMask',
                                    "'Invalid prefix length: ', itoa(prefix), '. Must be 0-32'")
        return ''
    }

    prefixRemaining = prefix

    for (x = 1; x <= 4; x++) {
        if (prefixRemaining >= 8) {
            octets[x] = 255
            prefixRemaining = prefixRemaining - 8
        } else if (prefixRemaining > 0) {
            octets[x] = 256 - type_cast(1 << (8 - prefixRemaining))
            prefixRemaining = 0
        } else {
            octets[x] = 0
        }
    }

    return "itoa(octets[1]), '.', itoa(octets[2]), '.', itoa(octets[3]), '.', itoa(octets[4])"
}


/**
 * @function NAVNetIPToLong
 * @public
 * @description Packs an IPv4 address string into a 32-bit unsigned integer.
 *
 * Converts a dotted-decimal IPv4 address into its 32-bit integer representation,
 * with the most significant byte being the first octet. This is useful for range
 * comparisons and bitwise subnet calculations without string manipulation.
 *
 * @param {char[]} ip - The IPv4 address string in dotted-decimal notation
 *
 * @returns {long} The 32-bit packed representation on success, or 0 on failure
 *
 * @example
 * stack_var long value
 * value = NAVNetIPToLong('192.168.1.1')    // $C0A80101 (3232235777)
 * value = NAVNetIPToLong('10.0.0.1')       // $0A000001 (167772161)
 * value = NAVNetIPToLong('255.255.255.255') // $FFFFFFFF (4294967295)
 * value = NAVNetIPToLong('0.0.0.0')        // $00000000 (0)
 *
 * @see NAVNetLongToIP
 */
define_function long NAVNetIPToLong(char ip[]) {
    stack_var _NAVIP ipParsed
    stack_var long result

    if (!NAVNetParseIPv4(ip, ipParsed)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetIPToLong',
                                    "'Invalid IP address: ', ip")
        return 0
    }

    result = type_cast(ipParsed.Octets[1])
    result = (result << 8) | type_cast(ipParsed.Octets[2])
    result = (result << 8) | type_cast(ipParsed.Octets[3])
    result = (result << 8) | type_cast(ipParsed.Octets[4])

    return result
}


/**
 * @function NAVNetLongToIP
 * @public
 * @description Unpacks a 32-bit unsigned integer into a dotted-decimal IPv4 address string.
 *
 * This is the reverse of NAVNetIPToLong, converting a 32-bit packed value back
 * into its human-readable dotted-decimal representation.
 *
 * @param {long} value - The 32-bit packed IPv4 address
 *
 * @returns {char[16]} The dotted-decimal IPv4 address string
 *
 * @example
 * stack_var char ip[16]
 * ip = NAVNetLongToIP($C0A80101)   // '192.168.1.1'
 * ip = NAVNetLongToIP($0A000001)   // '10.0.0.1'
 * ip = NAVNetLongToIP($FFFFFFFF)   // '255.255.255.255'
 * ip = NAVNetLongToIP(0)           // '0.0.0.0'
 *
 * @see NAVNetIPToLong
 */
define_function char[16] NAVNetLongToIP(long value) {
    stack_var integer octets[4]

    octets[1] = type_cast((value >> 24) & $FF)
    octets[2] = type_cast((value >> 16) & $FF)
    octets[3] = type_cast((value >> 8)  & $FF)
    octets[4] = type_cast(value & $FF)

    return "itoa(octets[1]), '.', itoa(octets[2]), '.', itoa(octets[3]), '.', itoa(octets[4])"
}


/**
 * @function NAVNetCalculateNetworkAddress
 * @public
 * @description Calculates the IPv4 network address for a given IP address and subnet mask.
 *
 * The network address is the lowest address in the subnet and is computed as:
 *   network = IP AND mask
 *
 * @param {char[]} ip - The IP address in dotted-decimal notation (e.g., "192.168.1.100")
 * @param {char[]} mask - The subnet mask in dotted-decimal notation (e.g., "255.255.255.0")
 *
 * @returns {char[16]} The network address string on success, or empty string on failure
 *
 * @example
 * stack_var char network[16]
 * network = NAVNetCalculateNetworkAddress('192.168.1.100', '255.255.255.0')
 * // network = '192.168.1.0'
 *
 * network = NAVNetCalculateNetworkAddress('10.0.0.50', '255.255.254.0')
 * // network = '10.0.0.0'
 *
 * @see NAVNetCalculateNetworkAddressFromPrefix
 * @see NAVNetCalculateBroadcast
 */
define_function char[16] NAVNetCalculateNetworkAddress(char ip[], char mask[]) {
    stack_var _NAVIP ipParsed
    stack_var long maskLong

    if (!NAVNetParseIPv4(ip, ipParsed)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetCalculateNetworkAddress',
                                    "'Invalid IP address: ', ip")
        return ''
    }

    // Validate mask is a proper subnet mask before using it
    if (NAVNetSubnetMaskToPrefix(mask) == 255) {
        // Error already logged by NAVNetSubnetMaskToPrefix
        return ''
    }

    maskLong = NAVNetIPToLong(mask)

    return NAVNetLongToIP(NAVNetIPToLong(ip) & maskLong)
}


/**
 * @function NAVNetCalculateNetworkAddressFromPrefix
 * @public
 * @description Calculates the IPv4 network address for a given IP address and CIDR prefix length.
 *
 * Derives the subnet mask from the prefix length, then computes network = IP AND mask.
 *
 * @param {char[]} ip - The IP address in dotted-decimal notation (e.g., "192.168.1.100")
 * @param {integer} prefix - The CIDR prefix length, 0-32 (e.g., 24)
 *
 * @returns {char[16]} The network address string on success, or empty string on failure
 *
 * @example
 * stack_var char network[16]
 * network = NAVNetCalculateNetworkAddressFromPrefix('192.168.1.100', 24)
 * // network = '192.168.1.0'
 *
 * network = NAVNetCalculateNetworkAddressFromPrefix('10.0.0.50', 23)
 * // network = '10.0.0.0'
 *
 * @see NAVNetCalculateNetworkAddress
 * @see NAVNetCalculateBroadcastFromPrefix
 */
define_function char[16] NAVNetCalculateNetworkAddressFromPrefix(char ip[], integer prefix) {
    stack_var char mask[16]

    mask = NAVNetPrefixToSubnetMask(prefix)

    if (!length_array(mask)) {
        // Error already logged by NAVNetPrefixToSubnetMask
        return ''
    }

    return NAVNetCalculateNetworkAddress(ip, mask)
}


/**
 * @function NAVNetCalculateHostCount
 * @public
 * @description Returns the number of usable host addresses in a subnet.
 *
 * Usable hosts are all addresses except the network address and broadcast address:
 *   usable = 2^(32 - prefix) - 2
 *
 * For prefix lengths of 31 and 32, returns 0 (point-to-point and host routes
 * have no usable address range in the traditional sense).
 *
 * @param {integer} prefix - The CIDR prefix length (0-32)
 *
 * @returns {long} The number of usable host addresses
 *
 * @example
 * stack_var long count
 * count = NAVNetCalculateHostCount(24)   // 254
 * count = NAVNetCalculateHostCount(23)   // 510
 * count = NAVNetCalculateHostCount(16)   // 65534
 * count = NAVNetCalculateHostCount(30)   // 2
 * count = NAVNetCalculateHostCount(32)   // 0
 * count = NAVNetCalculateHostCount(0)    // 4294967294
 *
 * @see NAVNetCalculateBroadcastFromPrefix
 * @see NAVNetCalculateNetworkAddressFromPrefix
 */
define_function long NAVNetCalculateHostCount(integer prefix) {
    stack_var integer hostBits
    stack_var integer x
    stack_var long wildcard

    if (prefix > 32) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_NETUTILS__,
                                    'NAVNetCalculateHostCount',
                                    "'Invalid prefix length: ', itoa(prefix), '. Must be 0-32'")
        return 0
    }

    if (prefix >= 31) {
        return 0
    }

    // Build the 32-bit wildcard mask as (2^hostBits) - 1, bit by bit to avoid overflow
    hostBits = 32 - prefix
    wildcard = 0

    for (x = 1; x <= hostBits; x++) {
        wildcard = (wildcard << 1) | 1
    }

    // usable = total - 2 = (wildcard + 1) - 2 = wildcard - 1
    return wildcard - 1
}


/**
 * @function NAVNetIsIPInSubnet
 * @public
 * @description Tests whether an IPv4 address belongs to a given subnet.
 *
 * The check is: (ip AND mask) == (network AND mask)
 * Both ip and network are masked before comparison, so network can be any
 * address within the subnet — it does not need to be the network address itself.
 *
 * @param {char[]} ip - The IP address to test
 * @param {char[]} network - Any address within the target subnet (e.g., network address or gateway)
 * @param {char[]} mask - The subnet mask in dotted-decimal notation
 *
 * @returns {char} true if ip is within the subnet, false otherwise
 *
 * @example
 * stack_var char result
 * result = NAVNetIsIPInSubnet('192.168.1.100', '192.168.1.0', '255.255.255.0')   // true
 * result = NAVNetIsIPInSubnet('192.168.2.1',   '192.168.1.0', '255.255.255.0')   // false
 * result = NAVNetIsIPInSubnet('10.0.0.50',     '10.0.1.0',    '255.255.254.0')   // true  (/23)
 *
 * @see NAVNetIsIPInSubnetFromPrefix
 */
define_function char NAVNetIsIPInSubnet(char ip[], char network[], char mask[]) {
    stack_var long maskLong
    stack_var integer prefix

    // Validate mask is a proper subnet mask
    prefix = NAVNetSubnetMaskToPrefix(mask)
    if (prefix == 255) {
        return false
    }

    maskLong = NAVNetIPToLong(mask)

    return type_cast((NAVNetIPToLong(ip) & maskLong) == (NAVNetIPToLong(network) & maskLong))
}


/**
 * @function NAVNetIsIPInSubnetFromPrefix
 * @public
 * @description Tests whether an IPv4 address belongs to a given subnet using a CIDR prefix length.
 *
 * Convenience wrapper around NAVNetIsIPInSubnet that accepts a prefix length
 * instead of a dotted-decimal subnet mask.
 *
 * @param {char[]} ip - The IP address to test
 * @param {char[]} network - Any address within the target subnet
 * @param {integer} prefix - The CIDR prefix length (0-32)
 *
 * @returns {char} true if ip is within the subnet, false otherwise
 *
 * @example
 * stack_var char result
 * result = NAVNetIsIPInSubnetFromPrefix('192.168.1.100', '192.168.1.0', 24)   // true
 * result = NAVNetIsIPInSubnetFromPrefix('192.168.2.1',   '192.168.1.0', 24)   // false
 * result = NAVNetIsIPInSubnetFromPrefix('10.0.0.50',     '10.0.1.0',    23)   // true
 *
 * @see NAVNetIsIPInSubnet
 */
define_function char NAVNetIsIPInSubnetFromPrefix(char ip[], char network[], integer prefix) {
    stack_var char mask[16]

    mask = NAVNetPrefixToSubnetMask(prefix)

    if (!length_array(mask)) {
        return false
    }

    return NAVNetIsIPInSubnet(ip, network, mask)
}


/**
 * @function NAVNetIsPrivateIP
 * @public
 * @description Determines whether an IPv4 address falls within an RFC 1918 private range.
 *
 * RFC 1918 defines three private address ranges:
 * - 10.0.0.0/8      (10.0.0.0   - 10.255.255.255)
 * - 172.16.0.0/12   (172.16.0.0 - 172.31.255.255)
 * - 192.168.0.0/16  (192.168.0.0 - 192.168.255.255)
 *
 * @param {char[]} ip - The IPv4 address string to test
 *
 * @returns {char} true if the address is in a private range, false otherwise
 *
 * @example
 * stack_var char result
 * result = NAVNetIsPrivateIP('192.168.1.1')   // true
 * result = NAVNetIsPrivateIP('10.0.0.1')      // true
 * result = NAVNetIsPrivateIP('172.20.5.1')    // true
 * result = NAVNetIsPrivateIP('8.8.8.8')       // false
 *
 * @see NAVNetIsLoopback
 * @see NAVNetIsLinkLocal
 */
define_function char NAVNetIsPrivateIP(char ip[]) {
    stack_var _NAVIP ipParsed
    stack_var integer o1
    stack_var integer o2

    if (!NAVNetParseIPv4(ip, ipParsed)) {
        return false
    }

    o1 = type_cast(ipParsed.Octets[1])
    o2 = type_cast(ipParsed.Octets[2])

    // 10.0.0.0/8
    if (o1 == 10) {
        return true
    }

    // 172.16.0.0/12  (172.16.x.x to 172.31.x.x)
    if (o1 == 172 && o2 >= 16 && o2 <= 31) {
        return true
    }

    // 192.168.0.0/16
    if (o1 == 192 && o2 == 168) {
        return true
    }

    return false
}


/**
 * @function NAVNetIsLoopback
 * @public
 * @description Determines whether an IPv4 address is a loopback address (127.0.0.0/8).
 *
 * RFC 5735 reserves 127.0.0.0/8 for loopback. The most common loopback
 * address is 127.0.0.1. All addresses in the 127.x.x.x range are loopback.
 *
 * @param {char[]} ip - The IPv4 address string to test
 *
 * @returns {char} true if the address is a loopback address, false otherwise
 *
 * @example
 * stack_var char result
 * result = NAVNetIsLoopback('127.0.0.1')   // true
 * result = NAVNetIsLoopback('127.1.2.3')   // true
 * result = NAVNetIsLoopback('192.168.1.1') // false
 *
 * @see NAVNetIsPrivateIP
 * @see NAVNetIsLinkLocal
 */
define_function char NAVNetIsLoopback(char ip[]) {
    stack_var _NAVIP ipParsed

    if (!NAVNetParseIPv4(ip, ipParsed)) {
        return false
    }

    return type_cast(ipParsed.Octets[1] == 127)
}


/**
 * @function NAVNetIsLinkLocal
 * @public
 * @description Determines whether an IPv4 address is a link-local address (169.254.0.0/16).
 *
 * RFC 3927 defines 169.254.0.0/16 as the link-local range, also known as
 * APIPA (Automatic Private IP Addressing). These addresses are assigned
 * automatically when DHCP is unavailable.
 *
 * @param {char[]} ip - The IPv4 address string to test
 *
 * @returns {char} true if the address is a link-local address, false otherwise
 *
 * @example
 * stack_var char result
 * result = NAVNetIsLinkLocal('169.254.1.5')  // true
 * result = NAVNetIsLinkLocal('169.253.1.1')  // false
 * result = NAVNetIsLinkLocal('192.168.1.1')  // false
 *
 * @see NAVNetIsPrivateIP
 * @see NAVNetIsLoopback
 */
define_function char NAVNetIsLinkLocal(char ip[]) {
    stack_var _NAVIP ipParsed

    if (!NAVNetParseIPv4(ip, ipParsed)) {
        return false
    }

    return type_cast(ipParsed.Octets[1] == 169 && ipParsed.Octets[2] == 254)
}


/**
 * @function NAVNetIsMulticast
 * @public
 * @description Determines whether an IPv4 address is a multicast address (224.0.0.0/4).
 *
 * RFC 5771 defines 224.0.0.0/4 (224.0.0.0 - 239.255.255.255) as the
 * multicast address range. These addresses are used for one-to-many
 * communication (e.g., mDNS at 224.0.0.251, SSDP at 239.255.255.250).
 *
 * @param {char[]} ip - The IPv4 address string to test
 *
 * @returns {char} true if the address is a multicast address, false otherwise
 *
 * @example
 * stack_var char result
 * result = NAVNetIsMulticast('224.0.0.251')    // true  (mDNS)
 * result = NAVNetIsMulticast('239.255.255.250') // true  (SSDP)
 * result = NAVNetIsMulticast('192.168.1.1')    // false
 *
 * @see NAVNetIsPrivateIP
 * @see NAVNetIsLinkLocal
 */
define_function char NAVNetIsMulticast(char ip[]) {
    stack_var _NAVIP ipParsed
    stack_var integer o1

    if (!NAVNetParseIPv4(ip, ipParsed)) {
        return false
    }

    o1 = type_cast(ipParsed.Octets[1])

    return type_cast(o1 >= 224 && o1 <= 239)
}


#END_IF // __NAV_FOUNDATION_NETUTILS__
