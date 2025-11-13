PROGRAM_NAME='NAVFoundation.DnsUtils.h'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_DNSUTILS_H__
#DEFINE __NAV_FOUNDATION_DNSUTILS_H__ 'NAVFoundation.DnsUtils.h'


DEFINE_CONSTANT

/**
 * @constant NAV_DNS_PORT
 * @description Standard DNS port (UDP/TCP)
 */
constant integer NAV_DNS_PORT = 53

/**
 * @constant NAV_DNS_MAX_PACKET_SIZE
 * @description Maximum DNS packet size for UDP (RFC 1035)
 */
constant integer NAV_DNS_MAX_PACKET_SIZE = 512

/**
 * @constant NAV_DNS_MAX_LABEL_LENGTH
 * @description Maximum length of a single DNS label
 */
constant integer NAV_DNS_MAX_LABEL_LENGTH = 63

/**
 * @constant NAV_DNS_MAX_DOMAIN_LENGTH
 * @description Maximum length of a complete domain name
 */
constant integer NAV_DNS_MAX_DOMAIN_LENGTH = 255

/**
 * @constant NAV_DNS_HEADER_SIZE
 * @description Size of DNS header in bytes
 */
constant integer NAV_DNS_HEADER_SIZE = 12


// ========================================
// DNS Header Flags
// ========================================

/**
 * @constant NAV_DNS_FLAG_QR_QUERY
 * @description Query/Response flag - Query (0)
 */
constant integer NAV_DNS_FLAG_QR_QUERY = 0

/**
 * @constant NAV_DNS_FLAG_QR_RESPONSE
 * @description Query/Response flag - Response (1)
 */
constant integer NAV_DNS_FLAG_QR_RESPONSE = 1

/**
 * @constant NAV_DNS_OPCODE_QUERY
 * @description Standard query
 */
constant integer NAV_DNS_OPCODE_QUERY = 0

/**
 * @constant NAV_DNS_OPCODE_IQUERY
 * @description Inverse query (obsolete)
 */
constant integer NAV_DNS_OPCODE_IQUERY = 1

/**
 * @constant NAV_DNS_OPCODE_STATUS
 * @description Server status request
 */
constant integer NAV_DNS_OPCODE_STATUS = 2

/**
 * @constant NAV_DNS_FLAG_AA
 * @description Authoritative Answer flag
 */
constant integer NAV_DNS_FLAG_AA = $0400

/**
 * @constant NAV_DNS_FLAG_TC
 * @description Truncated flag
 */
constant integer NAV_DNS_FLAG_TC = $0200

/**
 * @constant NAV_DNS_FLAG_RD
 * @description Recursion Desired flag
 */
constant integer NAV_DNS_FLAG_RD = $0100

/**
 * @constant NAV_DNS_FLAG_RA
 * @description Recursion Available flag
 */
constant integer NAV_DNS_FLAG_RA = $0080


// ========================================
// DNS Response Codes (RCODE)
// ========================================

/**
 * @constant NAV_DNS_RCODE_NO_ERROR
 * @description No error condition
 */
constant integer NAV_DNS_RCODE_NO_ERROR = 0

/**
 * @constant NAV_DNS_RCODE_FORMAT_ERROR
 * @description Format error - server unable to interpret query
 */
constant integer NAV_DNS_RCODE_FORMAT_ERROR = 1

/**
 * @constant NAV_DNS_RCODE_SERVER_FAILURE
 * @description Server failure
 */
constant integer NAV_DNS_RCODE_SERVER_FAILURE = 2

/**
 * @constant NAV_DNS_RCODE_NAME_ERROR
 * @description Name error - domain name does not exist
 */
constant integer NAV_DNS_RCODE_NAME_ERROR = 3

/**
 * @constant NAV_DNS_RCODE_NOT_IMPLEMENTED
 * @description Not implemented - server does not support request
 */
constant integer NAV_DNS_RCODE_NOT_IMPLEMENTED = 4

/**
 * @constant NAV_DNS_RCODE_REFUSED
 * @description Refused - server refuses to perform operation
 */
constant integer NAV_DNS_RCODE_REFUSED = 5

/**
 * @constant NAV_DNS_RCODE_NAMES
 * @description Human-readable response code names
 */
constant char NAV_DNS_RCODE_NAMES[][32] = {
    'No Error',
    'Format Error',
    'Server Failure',
    'Name Error',
    'Not Implemented',
    'Refused'
}


// ========================================
// DNS Query Types (QTYPE)
// ========================================

/**
 * @constant NAV_DNS_TYPE_A
 * @description Host address (IPv4)
 */
constant integer NAV_DNS_TYPE_A = 1

/**
 * @constant NAV_DNS_TYPE_NS
 * @description Authoritative name server
 */
constant integer NAV_DNS_TYPE_NS = 2

/**
 * @constant NAV_DNS_TYPE_CNAME
 * @description Canonical name for an alias
 */
constant integer NAV_DNS_TYPE_CNAME = 5

/**
 * @constant NAV_DNS_TYPE_SOA
 * @description Start of authority zone
 */
constant integer NAV_DNS_TYPE_SOA = 6

/**
 * @constant NAV_DNS_TYPE_PTR
 * @description Domain name pointer (reverse lookup)
 */
constant integer NAV_DNS_TYPE_PTR = 12

/**
 * @constant NAV_DNS_TYPE_MX
 * @description Mail exchange
 */
constant integer NAV_DNS_TYPE_MX = 15

/**
 * @constant NAV_DNS_TYPE_TXT
 * @description Text strings
 */
constant integer NAV_DNS_TYPE_TXT = 16

/**
 * @constant NAV_DNS_TYPE_AAAA
 * @description IPv6 address
 */
constant integer NAV_DNS_TYPE_AAAA = 28

/**
 * @constant NAV_DNS_TYPE_SRV
 * @description Service locator
 */
constant integer NAV_DNS_TYPE_SRV = 33

/**
 * @constant NAV_DNS_TYPE_ANY
 * @description Request for all records
 */
constant integer NAV_DNS_TYPE_ANY = 255


// ========================================
// DNS Query Classes (QCLASS)
// ========================================

/**
 * @constant NAV_DNS_CLASS_IN
 * @description Internet
 */
constant integer NAV_DNS_CLASS_IN = 1

/**
 * @constant NAV_DNS_CLASS_CS
 * @description CSNET (obsolete)
 */
constant integer NAV_DNS_CLASS_CS = 2

/**
 * @constant NAV_DNS_CLASS_CH
 * @description CHAOS
 */
constant integer NAV_DNS_CLASS_CH = 3

/**
 * @constant NAV_DNS_CLASS_HS
 * @description Hesiod
 */
constant integer NAV_DNS_CLASS_HS = 4

/**
 * @constant NAV_DNS_CLASS_ANY
 * @description Any class
 */
constant integer NAV_DNS_CLASS_ANY = 255


// ========================================
// DNS Label Compression
// ========================================

/**
 * @constant NAV_DNS_LABEL_POINTER_MASK
 * @description Mask for detecting compression pointer (11xxxxxx xxxxxxxx)
 */
constant integer NAV_DNS_LABEL_POINTER_MASK = $C000

/**
 * @constant NAV_DNS_LABEL_OFFSET_MASK
 * @description Mask for extracting pointer offset (00111111 11111111)
 */
constant integer NAV_DNS_LABEL_OFFSET_MASK = $3FFF


DEFINE_TYPE

/**
 * @struct _NAVDnsHeader
 * @description DNS message header (12 bytes)
 *
 * Header format (RFC 1035 Section 4.1.1):
 *                                  1  1  1  1  1  1
 *    0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |                      ID                       |
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |QR|   Opcode  |AA|TC|RD|RA|   Z    |   RCODE   |
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |                    QDCOUNT                    |
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |                    ANCOUNT                    |
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |                    NSCOUNT                    |
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |                    ARCOUNT                    |
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 */
struct _NAVDnsHeader {
    integer transactionId           // Identifier for matching queries/responses
    integer flags                   // Combined flags field
    integer questionCount           // Number of entries in question section
    integer answerCount             // Number of resource records in answer section
    integer authorityCount          // Number of name server records in authority section
    integer additionalCount         // Number of resource records in additional section

    // Decoded flag fields
    char qr                         // Query (0) or Response (1)
    char opcode                     // Kind of query
    char aa                         // Authoritative Answer
    char tc                         // Truncated
    char rd                         // Recursion Desired
    char ra                         // Recursion Available
    char responseCode               // Response code (RCODE)
}

/**
 * @struct _NAVDnsQuestion
 * @description DNS question section
 */
struct _NAVDnsQuestion {
    char name[NAV_DNS_MAX_DOMAIN_LENGTH]    // Domain name
    integer type                             // Query type (QTYPE)
    integer qclass                           // Query class (QCLASS)
}

/**
 * @struct _NAVDnsResourceRecord
 * @description DNS resource record (for answers, authority, additional sections)
 *
 * Resource Record format (RFC 1035 Section 4.1.3):
 *                                  1  1  1  1  1  1
 *    0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |                                               |
 *  /                      NAME                     /
 *  /                                               /
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |                      TYPE                     |
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |                     CLASS                     |
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |                      TTL                      |
 *  |                                               |
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 *  |                   RDLENGTH                    |
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
 *  /                     RDATA                     /
 *  /                                               /
 *  +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
 */
struct _NAVDnsResourceRecord {
    char name[NAV_DNS_MAX_DOMAIN_LENGTH]    // Domain name
    integer type                             // Resource record type
    integer qclass                           // Resource record class
    long ttl                                 // Time to live (seconds)
    integer dataLength                       // Length of RDATA field
    char data[512]                           // Resource data (raw format)

    // Type-specific decoded data
    char address[50]                         // For A/AAAA: IP address string
    char cname[NAV_DNS_MAX_DOMAIN_LENGTH]    // For CNAME/PTR: canonical name
    integer priority                         // For MX/SRV: priority/preference
    char target[NAV_DNS_MAX_DOMAIN_LENGTH]   // For MX/SRV: target host
}

/**
 * @struct _NAVDnsQuery
 * @description Complete DNS query message
 */
struct _NAVDnsQuery {
    _NAVDnsHeader header
    _NAVDnsQuestion questions[10]            // Support up to 10 questions
    integer questionCount
    char packetData[NAV_DNS_MAX_PACKET_SIZE] // Encoded packet ready for transmission
    integer packetLength                      // Actual packet length
}

/**
 * @struct _NAVDnsResponse
 * @description Complete DNS response message
 */
struct _NAVDnsResponse {
    _NAVDnsHeader header
    _NAVDnsQuestion questions[10]
    _NAVDnsResourceRecord answers[20]        // Support up to 20 answer records
    _NAVDnsResourceRecord authority[10]      // Support up to 10 authority records
    _NAVDnsResourceRecord additional[10]     // Support up to 10 additional records
    char rawData[4096]                       // Store original response for pointer resolution
    integer rawDataLength
}


#END_IF // __NAV_FOUNDATION_DNSUTILS_H__
