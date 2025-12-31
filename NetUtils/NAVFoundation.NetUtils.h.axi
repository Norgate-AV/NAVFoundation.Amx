PROGRAM_NAME='NAVFoundation.NetUtils.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_NETUTILS_H__
#DEFINE __NAV_FOUNDATION_NETUTILS_H__ 'NAVFoundation.NetUtils.h'


DEFINE_TYPE

/**
 * @struct _NAVIP
 * @description Structure for holding parsed IP address components (IPv4 or IPv6).
 *
 * This structure stores an IP address as both individual octets/bytes and
 * as a string representation. Designed to support both IPv4 and IPv6 addresses.
 *
 * IPv4 addresses (RFC 791) consist of 4 octets, each in the range 0-255,
 * represented in dotted-decimal notation (e.g., "192.168.1.1").
 *
 * IPv6 addresses (RFC 4291) consist of 16 bytes (128 bits),
 * represented in colon-hexadecimal notation (e.g., "2001:db8::1").
 *
 * @property {char} Version - IP version: 4 = IPv4, 6 = IPv6, 0 = uninitialized/invalid
 * @property {char[16]} Octets - Array of bytes representing the IP address
 *                               - First 4 bytes used for IPv4
 *                               - All 16 bytes used for IPv6
 * @property {char[45]} Address - String representation of the IP address
 *                                - Max 15 chars for IPv4 ("255.255.255.255")
 *                                - Max 45 chars for IPv6 ("ffff:ffff:ffff:ffff:ffff:ffff:255.255.255.255")
 *
 * @see NAVNetParseIPv4
 * @see NAVNetParseIP
 *
 * @example
 * stack_var _NAVIP ip
 * if (NAVNetParseIPv4('192.168.1.1', ip)) {
 *     // ip.Version = 4
 *     // ip.Octets[1] = 192
 *     // ip.Octets[2] = 168
 *     // ip.Octets[3] = 1
 *     // ip.Octets[4] = 1
 *     // ip.Address = '192.168.1.1'
 * }
 */
struct _NAVIP {
    char Version
    char Octets[16]
    char Address[45]
}

/**
 * @struct _NAVIPAddr
 * @description Structure for holding an IP address with port number.
 *
 * This structure represents a network endpoint consisting of an IP address
 * and a port number. It's useful for representing TCP/UDP endpoints, server
 * addresses, and other network locations that require both IP and port.
 *
 * Similar to Go's net.TCPAddr and net.UDPAddr, but protocol-agnostic.
 *
 * @property {_NAVIP} IP - The IP address (IPv4 or IPv6)
 * @property {integer} Port - Port number (0-65535)
 *
 * @see _NAVIP
 *
 * @example
 * stack_var _NAVIPAddr addr
 * if (NAVNetParseIPv4('192.168.1.1', addr.IP)) {
 *     addr.Port = 8080
 *     // addr represents 192.168.1.1:8080
 * }
 */
struct _NAVIPAddr {
    _NAVIP IP
    integer Port
}


#END_IF // __NAV_FOUNDATION_NETUTILS_H__
