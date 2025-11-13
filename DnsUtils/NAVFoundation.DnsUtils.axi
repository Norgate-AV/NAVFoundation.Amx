PROGRAM_NAME='NAVFoundation.DnsUtils'

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

#IF_NOT_DEFINED __NAV_FOUNDATION_DNSUTILS__
#DEFINE __NAV_FOUNDATION_DNSUTILS__ 'NAVFoundation.DnsUtils'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.DnsUtils.h.axi'
#include 'NAVFoundation.ErrorLogUtils.axi'
#include 'NAVFoundation.StringUtils.axi'


// ========================================
// Domain Name Encoding/Decoding Functions
// ========================================

/**
 * Encodes a domain name into DNS wire format with length-prefixed labels.
 *
 * Converts "www.example.com" to: [3]www[7]example[3]com[0]
 * Each label is prefixed by its length as a single byte.
 *
 * @param domain - The domain name to encode (e.g., "www.example.com")
 * @param encoded - Output buffer for encoded domain name
 * @return Length of encoded data, or 0 on error
 */
define_function integer NAVDnsDomainNameEncode(char domain[], char encoded[]) {
    stack_var integer pos
    stack_var integer encPos
    stack_var integer labelStart
    stack_var integer labelLen
    stack_var char currentChar
    stack_var integer i

    pos = 1
    encPos = 1
    labelStart = 1
    labelLen = 0

    // Clear output buffer
    encoded = ''

    if (!length_array(domain) || length_array(domain) > NAV_DNS_MAX_DOMAIN_LENGTH) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDomainNameEncode',
                                    "'Invalid domain length', itoa(length_array(domain))")
        return 0
    }

    // Process each character in the domain
    for (i = 1; i <= length_array(domain); i++) {
        currentChar = domain[i]

        if (currentChar == '.') {
            // End of label - write length and label data
            if (labelLen == 0) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_DNSUTILS__,
                                            'NAVDnsDomainNameEncode',
                                            "'Empty label in domain: ', domain")
                return 0
            }

            if (labelLen > NAV_DNS_MAX_LABEL_LENGTH) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_DNSUTILS__,
                                            'NAVDnsDomainNameEncode',
                                            "'Label too long (', itoa(labelLen), '): ', domain")
                return 0
            }

            // Write label length
            encoded[encPos] = labelLen
            encPos++

            // Write label data
            encoded = "encoded, mid_string(domain, labelStart, labelLen)"
            encPos = encPos + labelLen

            // Reset for next label
            labelStart = i + 1
            labelLen = 0
        }
        else {
            labelLen++
        }
    }

    // Write final label if domain doesn't end with '.'
    if (labelLen > 0) {
        if (labelLen > NAV_DNS_MAX_LABEL_LENGTH) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsDomainNameEncode',
                                        "'Label too long (', itoa(labelLen), '): ', domain")
            return 0
        }

        encoded[encPos] = labelLen
        encPos++
        encoded = "encoded, mid_string(domain, labelStart, labelLen)"
        encPos = encPos + labelLen
    }

    // Append null terminator (zero-length label)
    encoded[encPos] = 0
    encPos++

    set_length_array(encoded, encPos - 1)
    return encPos - 1
}

/**
 * Decodes a domain name from DNS wire format.
 *
 * Converts [3]www[7]example[3]com[0] to "www.example.com"
 * Handles label compression pointers (RFC 1035 Section 4.1.4).
 *
 * @param data - The raw DNS packet data
 * @param offset - Starting offset of the domain name in data (1-indexed)
 * @param decoded - Output buffer for decoded domain name
 * @param bytesRead - Number of bytes consumed from data (output)
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsDomainNameDecode(char data[], integer offset, char decoded[], integer bytesRead) {
    stack_var integer pos
    stack_var integer labelLen
    stack_var integer jumpCount
    stack_var integer originalOffset
    stack_var integer pointer
    stack_var char jumped

    pos = offset
    decoded = ''
    jumpCount = 0
    originalOffset = offset
    jumped = false
    bytesRead = 0

    if (offset < 1 || offset > length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDomainNameDecode',
                                    "'Invalid offset: ', itoa(offset)")
        return false
    }

    // Process labels until we hit the null terminator
    while (pos <= length_array(data)) {
        labelLen = data[pos]

        // Check for compression pointer (top 2 bits set: 11xxxxxx)
        if ((labelLen & $C0) == $C0) {
            // This is a pointer - read 16-bit offset
            if (pos + 1 > length_array(data)) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_DNSUTILS__,
                                            'NAVDnsDomainNameDecode',
                                            'Truncated compression pointer')
                return false
            }

            // Extract pointer offset (lower 14 bits)
            pointer = ((labelLen & $3F) << 8) | data[pos + 1]
            pointer = pointer + 1  // Convert to 1-indexed

            if (!jumped) {
                bytesRead = (pos - originalOffset) + 2
                jumped = true
            }

            pos = pointer
            jumpCount++

            // Prevent infinite loops
            if (jumpCount > 20) {
                NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                            __NAV_FOUNDATION_DNSUTILS__,
                                            'NAVDnsDomainNameDecode',
                                            'Too many compression pointer jumps')
                return false
            }

            continue
        }

        // Null terminator - end of domain name
        if (labelLen == 0) {
            if (!jumped) {
                bytesRead = (pos - originalOffset) + 1
            }
            break
        }

        // Validate label length
        if (labelLen > NAV_DNS_MAX_LABEL_LENGTH) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsDomainNameDecode',
                                        "'Invalid label length: ', itoa(labelLen)")
            return false
        }

        // Check if we have enough data
        if (pos + labelLen > length_array(data)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsDomainNameDecode',
                                        'Truncated label data')
            return false
        }

        // Add dot separator if not first label
        if (length_array(decoded) > 0) {
            decoded = "decoded, '.'"
        }

        // Copy label data
        decoded = "decoded, mid_string(data, pos + 1, labelLen)"
        pos = pos + labelLen + 1

        // Check total length
        if (length_array(decoded) > NAV_DNS_MAX_DOMAIN_LENGTH) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsDomainNameDecode',
                                        'Domain name too long')
            return false
        }
    }

    return true
}


// ========================================
// DNS Header Functions
// ========================================

/**
 * Initializes a DNS header with default values.
 *
 * @param header - DNS header structure to initialize
 * @param transactionId - Transaction ID for the query
 */
define_function NAVDnsHeaderInit(_NAVDnsHeader header, integer transactionId) {
    header.transactionId = transactionId
    header.flags = 0
    header.questionCount = 0
    header.answerCount = 0
    header.authorityCount = 0
    header.additionalCount = 0

    header.qr = NAV_DNS_FLAG_QR_QUERY
    header.opcode = NAV_DNS_OPCODE_QUERY
    header.aa = 0
    header.tc = 0
    header.rd = 1  // Request recursion by default
    header.ra = 0
    header.responseCode = 0
}

/**
 * Packs DNS header flags into the 16-bit flags field.
 *
 * @param header - DNS header structure
 */
define_function NAVDnsHeaderPackFlags(_NAVDnsHeader header) {
    header.flags = 0

    // Pack flags into 16-bit field
    // Format: [QR|Opcode(4)|AA|TC|RD|RA|Z(3)|RCODE(4)]
    if (header.qr) {
        header.flags = header.flags | $8000  // QR bit (bit 15)
    }

    header.flags = header.flags | ((header.opcode & $0F) << 11)  // Opcode (bits 11-14)

    if (header.aa) {
        header.flags = header.flags | $0400  // AA bit (bit 10)
    }

    if (header.tc) {
        header.flags = header.flags | $0200  // TC bit (bit 9)
    }

    if (header.rd) {
        header.flags = header.flags | $0100  // RD bit (bit 8)
    }

    if (header.ra) {
        header.flags = header.flags | $0080  // RA bit (bit 7)
    }

    header.flags = header.flags | (header.responseCode & $0F)  // RCODE (bits 0-3)
}

/**
 * Unpacks the 16-bit flags field into individual flag fields.
 *
 * @param header - DNS header structure
 */
define_function NAVDnsHeaderUnpackFlags(_NAVDnsHeader header) {
    header.qr = (header.flags & $8000) >> 15
    header.opcode = (header.flags & $7800) >> 11
    header.aa = (header.flags & $0400) >> 10
    header.tc = (header.flags & $0200) >> 9
    header.rd = (header.flags & $0100) >> 8
    header.ra = (header.flags & $0080) >> 7
    header.responseCode = header.flags & $000F
}

/**
 * Encodes a DNS header into a 12-byte array.
 *
 * @param header - DNS header structure
 * @param data - Output buffer (must be at least 12 bytes)
 * @return Number of bytes written (always 12)
 */
define_function integer NAVDnsHeaderEncode(_NAVDnsHeader header, char data[]) {
    NAVDnsHeaderPackFlags(header)

    // Clear output
    data = ''

    // Transaction ID (2 bytes)
    data[1] = (header.transactionId >> 8) & $FF
    data[2] = header.transactionId & $FF

    // Flags (2 bytes)
    data[3] = (header.flags >> 8) & $FF
    data[4] = header.flags & $FF

    // Question count (2 bytes)
    data[5] = (header.questionCount >> 8) & $FF
    data[6] = header.questionCount & $FF

    // Answer count (2 bytes)
    data[7] = (header.answerCount >> 8) & $FF
    data[8] = header.answerCount & $FF

    // Authority count (2 bytes)
    data[9] = (header.authorityCount >> 8) & $FF
    data[10] = header.authorityCount & $FF

    // Additional count (2 bytes)
    data[11] = (header.additionalCount >> 8) & $FF
    data[12] = header.additionalCount & $FF

    set_length_array(data, NAV_DNS_HEADER_SIZE)
    return NAV_DNS_HEADER_SIZE
}

/**
 * Decodes a DNS header from a byte array.
 *
 * @param data - Raw DNS packet data
 * @param header - Output DNS header structure
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsHeaderDecode(char data[], _NAVDnsHeader header) {
    if (length_array(data) < NAV_DNS_HEADER_SIZE) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsHeaderDecode',
                                    "'Insufficient data (', itoa(length_array(data)), ' bytes)'")

        return false
    }

    // Transaction ID
    header.transactionId = (data[1] << 8) | data[2]

    // Flags
    header.flags = (data[3] << 8) | data[4]
    NAVDnsHeaderUnpackFlags(header)

    // Counts
    header.questionCount = (data[5] << 8) | data[6]
    header.answerCount = (data[7] << 8) | data[8]
    header.authorityCount = (data[9] << 8) | data[10]
    header.additionalCount = (data[11] << 8) | data[12]

    return true
}


// ========================================
// DNS Query Building Functions
// ========================================

/**
 * Initializes a DNS query structure.
 *
 * @param query - DNS query structure to initialize
 */
define_function NAVDnsQueryInit(_NAVDnsQuery query) {
    stack_var integer i

    NAVDnsHeaderInit(query.header, 0)
    query.questionCount = 0
    query.packetData = ''
    query.packetLength = 0

    for (i = 1; i <= 10; i++) {
        query.questions[i].name = ''
        query.questions[i].type = 0
        query.questions[i].qclass = 0
    }
}

/**
 * Adds a question to a DNS query.
 *
 * @param query - DNS query structure
 * @param domain - Domain name to query
 * @param qtype - Query type (e.g., NAV_DNS_TYPE_A)
 * @param qclass - Query class (usually NAV_DNS_CLASS_IN)
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsQueryAddQuestion(_NAVDnsQuery query, char domain[], integer qtype, integer qclass) {
    if (query.questionCount >= 10) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsQueryAddQuestion',
                                    'Maximum questions reached')
        return false
    }

    query.questionCount++
    query.questions[query.questionCount].name = domain
    query.questions[query.questionCount].type = qtype
    query.questions[query.questionCount].qclass = qclass
    query.header.questionCount = query.questionCount

    return true
}

/**
 * Builds a complete DNS query packet ready for transmission.
 *
 * @param query - DNS query structure
 * @param transactionId - Transaction ID for this query
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsQueryBuild(_NAVDnsQuery query, integer transactionId) {
    stack_var char headerData[NAV_DNS_HEADER_SIZE]
    stack_var char encodedName[NAV_DNS_MAX_DOMAIN_LENGTH]
    stack_var integer nameLen
    stack_var integer i
    stack_var char questionData[512]
    stack_var integer pos

    query.packetData = ''
    query.packetLength = 0

    if (query.questionCount == 0) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsQueryBuild',
                                    'No questions added')
        return false
    }

    // Set transaction ID and pack header
    query.header.transactionId = transactionId
    NAVDnsHeaderEncode(query.header, headerData)

    query.packetData = headerData
    query.packetLength = NAV_DNS_HEADER_SIZE

    // Encode each question
    for (i = 1; i <= query.questionCount; i++) {
        // Encode domain name
        nameLen = NAVDnsDomainNameEncode(query.questions[i].name, encodedName)
        if (nameLen == 0) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsQueryBuild',
                                        "'Failed to encode domain: ', query.questions[i].name")
            return false
        }

        // Build question section: NAME + TYPE (2 bytes) + CLASS (2 bytes)
        questionData = encodedName
        pos = nameLen + 1

        // Type (2 bytes, big-endian)
        questionData[pos] = (query.questions[i].type >> 8) & $FF
        questionData[pos + 1] = query.questions[i].type & $FF
        pos = pos + 2

        // Class (2 bytes, big-endian)
        questionData[pos] = (query.questions[i].qclass >> 8) & $FF
        questionData[pos + 1] = query.questions[i].qclass & $FF
        pos = pos + 2        set_length_array(questionData, pos - 1)

        // Append to packet
        query.packetData = "query.packetData, questionData"
        query.packetLength = query.packetLength + length_array(questionData)

        // Check packet size limit
        if (query.packetLength > NAV_DNS_MAX_PACKET_SIZE) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsQueryBuild',
                                        "'Packet too large (', itoa(query.packetLength), ' bytes)'")
            return false
        }
    }

    return true
}

/**
 * Creates a simple DNS query for a single domain and type.
 * This is a convenience function for the most common use case.
 *
 * @param query - DNS query structure to populate
 * @param domain - Domain name to query
 * @param qtype - Query type (e.g., NAV_DNS_TYPE_A)
 * @param transactionId - Transaction ID for this query
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsQueryCreate(_NAVDnsQuery query, char domain[], integer qtype, integer transactionId) {
    NAVDnsQueryInit(query)

    if (!NAVDnsQueryAddQuestion(query, domain, qtype, NAV_DNS_CLASS_IN)) {
        return false
    }

    return NAVDnsQueryBuild(query, transactionId)
}


// ========================================
// DNS Response Parsing Functions
// ========================================

/**
 * Initializes a DNS response structure.
 *
 * @param response - DNS response structure to initialize
 */
define_function NAVDnsResponseInit(_NAVDnsResponse response) {
    stack_var integer i

    NAVDnsHeaderInit(response.header, 0)

    for (i = 1; i <= 10; i++) {
        response.questions[i].name = ''
        response.questions[i].type = 0
        response.questions[i].qclass = 0
    }

    for (i = 1; i <= 20; i++) {
        response.answers[i].name = ''
        response.answers[i].type = 0
        response.answers[i].qclass = 0
        response.answers[i].ttl = 0
        response.answers[i].dataLength = 0
        response.answers[i].data = ''
        response.answers[i].address = ''
        response.answers[i].cname = ''
        response.answers[i].priority = 0
        response.answers[i].target = ''
    }

    for (i = 1; i <= 10; i++) {
        response.authority[i].name = ''
        response.authority[i].type = 0
        response.authority[i].qclass = 0
        response.authority[i].ttl = 0
        response.authority[i].dataLength = 0
        response.authority[i].data = ''

        response.additional[i].name = ''
        response.additional[i].type = 0
        response.additional[i].qclass = 0
        response.additional[i].ttl = 0
        response.additional[i].dataLength = 0
        response.additional[i].data = ''
    }

    response.rawData = ''
    response.rawDataLength = 0
}

/**
 * Parses a DNS question from raw data.
 *
 * @param data - Raw DNS packet data
 * @param offset - Starting offset (1-indexed)
 * @param question - Output question structure
 * @param bytesRead - Number of bytes consumed (output)
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsQuestionParse(char data[], integer offset, _NAVDnsQuestion question, integer bytesRead) {
    stack_var integer nameBytes
    stack_var integer pos

    // Decode domain name
    if (!NAVDnsDomainNameDecode(data, offset, question.name, nameBytes)) {
        return false
    }

    pos = offset + nameBytes

    // Check if we have enough data for type and class
    if (pos + 3 > length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsQuestionParse',
                                    'Insufficient data for type/class')
        return false
    }

    // Parse type (2 bytes)
    question.type = (data[pos] << 8) | data[pos + 1]
    pos = pos + 2

    // Parse class (2 bytes)
    question.qclass = (data[pos] << 8) | data[pos + 1]
    pos = pos + 2    bytesRead = pos - offset
    return true
}

/**
 * Parses a DNS resource record from raw data.
 *
 * @param data - Raw DNS packet data
 * @param offset - Starting offset (1-indexed)
 * @param rr - Output resource record structure
 * @param bytesRead - Number of bytes consumed (output)
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsResourceRecordParse(char data[], integer offset, _NAVDnsResourceRecord rr, integer bytesRead) {
    stack_var integer nameBytes
    stack_var integer pos
    stack_var integer i

    // Decode domain name
    if (!NAVDnsDomainNameDecode(data, offset, rr.name, nameBytes)) {
        return false
    }

    pos = offset + nameBytes

    // Check if we have enough data for fixed fields (10 bytes)
    if (pos + 9 > length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsResourceRecordParse',
                                    'Insufficient data for RR header')
        return false
    }

    // Parse type (2 bytes)
    rr.type = (data[pos] << 8) | data[pos + 1]
    pos = pos + 2

    // Parse class (2 bytes)
    rr.qclass = (data[pos] << 8) | data[pos + 1]
    pos = pos + 2    // Parse TTL (4 bytes)
    rr.ttl = (type_cast(data[pos]) << 24) | (type_cast(data[pos + 1]) << 16) | (type_cast(data[pos + 2]) << 8) | type_cast(data[pos + 3])
    pos = pos + 4

    // Parse RDLENGTH (2 bytes)
    rr.dataLength = (data[pos] << 8) | data[pos + 1]
    pos = pos + 2

    // Check if we have enough data for RDATA
    if (pos + rr.dataLength - 1 > length_array(data)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsResourceRecordParse',
                                    "'Insufficient data for RDATA (need ', itoa(rr.dataLength), ' bytes)'")
        return false
    }

    // Copy RDATA
    rr.data = ''
    for (i = 0; i < rr.dataLength; i++) {
        rr.data[i + 1] = data[pos + i]
    }
    set_length_array(rr.data, rr.dataLength)

    pos = pos + rr.dataLength
    bytesRead = pos - offset

    return true
}

/**
 * Parses a complete DNS response packet.
 *
 * @param data - Raw DNS response data
 * @param response - Output response structure
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsResponseParse(char data[], _NAVDnsResponse response) {
    stack_var integer pos
    stack_var integer i
    stack_var integer bytesRead

    NAVDnsResponseInit(response)

    // Store raw data for pointer resolution
    response.rawData = data
    response.rawDataLength = length_array(data)

    // Parse header
    if (!NAVDnsHeaderDecode(data, response.header)) {
        return false
    }

    pos = NAV_DNS_HEADER_SIZE + 1

    // Parse questions
    for (i = 1; i <= response.header.questionCount; i++) {
        if (i > 10) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsResponseParse',
                                        "'Too many questions (', itoa(response.header.questionCount), '), parsing first 10'")
            break
        }

        if (!NAVDnsQuestionParse(data, pos, response.questions[i], bytesRead)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsResponseParse',
                                        "'Failed to parse question ', itoa(i)")
            return false
        }
        pos = pos + bytesRead
    }

    // Parse answers
    for (i = 1; i <= response.header.answerCount; i++) {
        if (i > 20) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsResponseParse',
                                        "'Too many answers (', itoa(response.header.answerCount), '), parsing first 20'")
            break
        }

        if (!NAVDnsResourceRecordParse(data, pos, response.answers[i], bytesRead)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsResponseParse',
                                        "'Failed to parse answer ', itoa(i)")
            return false
        }
        pos = pos + bytesRead
    }

    // Parse authority records
    for (i = 1; i <= response.header.authorityCount; i++) {
        if (i > 10) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsResponseParse',
                                        "'Too many authority records (', itoa(response.header.authorityCount), '), parsing first 10'")
            break
        }

        if (!NAVDnsResourceRecordParse(data, pos, response.authority[i], bytesRead)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsResponseParse',
                                        "'Failed to parse authority record ', itoa(i)")
            return false
        }
        pos = pos + bytesRead
    }

    // Parse additional records
    for (i = 1; i <= response.header.additionalCount; i++) {
        if (i > 10) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_WARNING,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsResponseParse',
                                        "'Too many additional records (', itoa(response.header.additionalCount), '), parsing first 10'")
            break
        }

        if (!NAVDnsResourceRecordParse(data, pos, response.additional[i], bytesRead)) {
            NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                        __NAV_FOUNDATION_DNSUTILS__,
                                        'NAVDnsResponseParse',
                                        "'Failed to parse additional record ', itoa(i)")
            return false
        }
        pos = pos + bytesRead
    }

    return true
}


// ========================================
// Resource Record Type-Specific Parsers
// ========================================

/**
 * Decodes an A record (IPv4 address) from RDATA.
 *
 * @param rr - Resource record with A record data
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsDecodeARecord(_NAVDnsResourceRecord rr) {
    if (rr.type != NAV_DNS_TYPE_A) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodeARecord',
                                    'Not an A record')
        return false
    }

    if (rr.dataLength != 4) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodeARecord',
                                    "'Invalid A record length (', itoa(rr.dataLength), ')'")
        return false
    }

    rr.address = "itoa(type_cast(rr.data[1])), '.',
                   itoa(type_cast(rr.data[2])), '.',
                   itoa(type_cast(rr.data[3])), '.',
                   itoa(type_cast(rr.data[4]))"

    return true
}

/**
 * Decodes an AAAA record (IPv6 address) from RDATA.
 *
 * @param rr - Resource record with AAAA record data
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsDecodeAAAARecord(_NAVDnsResourceRecord rr) {
    stack_var integer i
    stack_var char hextet[5]

    if (rr.type != NAV_DNS_TYPE_AAAA) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodeAAAARecord',
                                    'Not an AAAA record')
        return false
    }

    if (rr.dataLength != 16) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodeAAAARecord',
                                    "'Invalid AAAA record length (', itoa(rr.dataLength), ')'")
        return false
    }

    rr.address = ''

    // Format as 8 groups of 4 hex digits separated by colons
    for (i = 0; i < 8; i++) {
        // hextet = format('%02x%02x', type_cast(rr.data[(i * 2) + 1]), type_cast(rr.data[(i * 2) + 2]))

        if (i > 0) {
            rr.address = "rr.address, ':'"
        }

        rr.address = "rr.address, hextet"
    }

    return true
}

/**
 * Decodes a CNAME record (canonical name) from RDATA.
 *
 * @param data - Raw DNS packet data (for pointer resolution)
 * @param rr - Resource record with CNAME record data
 * @param rrOffset - Offset where the RR's RDATA starts
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsDecodeCNAMERecord(char data[], _NAVDnsResourceRecord rr, integer rrOffset) {
    stack_var integer bytesRead

    if (rr.type != NAV_DNS_TYPE_CNAME) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodeCNAMERecord',
                                    'Not a CNAME record')
        return false
    }

    // CNAME RDATA is a domain name (may contain compression pointers)
    if (!NAVDnsDomainNameDecode(data, rrOffset, rr.cname, bytesRead)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodeCNAMERecord',
                                    'Failed to decode domain name')
        return false
    }

    return true
}

/**
 * Decodes a PTR record (reverse lookup) from RDATA.
 *
 * @param data - Raw DNS packet data (for pointer resolution)
 * @param rr - Resource record with PTR record data
 * @param rrOffset - Offset where the RR's RDATA starts
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsDecodePTRRecord(char data[], _NAVDnsResourceRecord rr, integer rrOffset) {
    stack_var integer bytesRead

    if (rr.type != NAV_DNS_TYPE_PTR) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodePTRRecord',
                                    'Not a PTR record')
        return false
    }

    // PTR RDATA is a domain name (may contain compression pointers)
    if (!NAVDnsDomainNameDecode(data, rrOffset, rr.cname, bytesRead)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodePTRRecord',
                                    'Failed to decode domain name')
        return false
    }

    return true
}

/**
 * Decodes an MX record (mail exchange) from RDATA.
 *
 * @param data - Raw DNS packet data (for pointer resolution)
 * @param rr - Resource record with MX record data
 * @param rrOffset - Offset where the RR's RDATA starts
 * @return 1 on success, 0 on error
 */
define_function char NAVDnsDecodeMXRecord(char data[], _NAVDnsResourceRecord rr, integer rrOffset) {
    stack_var integer bytesRead

    if (rr.type != NAV_DNS_TYPE_MX) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodeMXRecord',
                                    'Not an MX record')
        return false
    }

    if (rr.dataLength < 3) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodeMXRecord',
                                    "'Invalid MX record length (', itoa(rr.dataLength), ')'")
        return false
    }

    // MX RDATA format: PREFERENCE (2 bytes) + EXCHANGE (domain name)
    rr.priority = (rr.data[1] << 8) | rr.data[2]

    // Decode exchange domain name (starts at offset + 2)
    if (!NAVDnsDomainNameDecode(data, rrOffset + 2, rr.target, bytesRead)) {
        NAVLibraryFunctionErrorLog(NAV_LOG_LEVEL_ERROR,
                                    __NAV_FOUNDATION_DNSUTILS__,
                                    'NAVDnsDecodeMXRecord',
                                    'Failed to decode exchange domain')
        return false
    }

    return true
}

/**
 * Automatically decodes a resource record based on its type.
 * Populates type-specific fields in the resource record structure.
 *
 * @param data - Raw DNS packet data (for pointer resolution)
 * @param rr - Resource record to decode
 * @param rdataOffset - Offset where the RR's RDATA starts in the packet
 * @return 1 on success, 0 on error (unknown types return 1 without decoding)
 */
define_function char NAVDnsDecodeResourceRecord(char data[], _NAVDnsResourceRecord rr, integer rdataOffset) {
    switch (rr.type) {
        case NAV_DNS_TYPE_A: {
            return NAVDnsDecodeARecord(rr)
        }
        case NAV_DNS_TYPE_AAAA: {
            return NAVDnsDecodeAAAARecord(rr)
        }
        case NAV_DNS_TYPE_CNAME: {
            return NAVDnsDecodeCNAMERecord(data, rr, rdataOffset)
        }
        case NAV_DNS_TYPE_PTR: {
            return NAVDnsDecodePTRRecord(data, rr, rdataOffset)
        }
        case NAV_DNS_TYPE_MX: {
            return NAVDnsDecodeMXRecord(data, rr, rdataOffset)
        }
        default: {
            // Unknown type - raw data is already in rr.data, no decoding needed
            return true
        }
    }
}


// ========================================
// Utility Functions
// ========================================

/**
 * Converts a DNS response code to a human-readable string.
 *
 * @param responseCode - DNS response code (RCODE)
 * @return String description of the response code
 */
define_function char[32] NAVDnsResponseCodeToString(char responseCode) {
    if (responseCode >= 0 && responseCode <= 5) {
        return NAV_DNS_RCODE_NAMES[responseCode + 1]
    }

    return "'Unknown (', itoa(responseCode), ')'"
}

/**
 * Gets a string representation of a DNS query type.
 *
 * @param qtype - DNS query type
 * @return String name of the query type
 */
define_function char[10] NAVDnsTypeToString(integer qtype) {
    switch (qtype) {
        case NAV_DNS_TYPE_A:        return 'A'
        case NAV_DNS_TYPE_NS:       return 'NS'
        case NAV_DNS_TYPE_CNAME:    return 'CNAME'
        case NAV_DNS_TYPE_SOA:      return 'SOA'
        case NAV_DNS_TYPE_PTR:      return 'PTR'
        case NAV_DNS_TYPE_MX:       return 'MX'
        case NAV_DNS_TYPE_TXT:      return 'TXT'
        case NAV_DNS_TYPE_AAAA:     return 'AAAA'
        case NAV_DNS_TYPE_SRV:      return 'SRV'
        case NAV_DNS_TYPE_ANY:      return 'ANY'
        default:                     return itoa(qtype)
    }
}

/**
 * Gets a string representation of a DNS class.
 *
 * @param qclass - DNS query class
 * @return String name of the class
 */
define_function char[10] NAVDnsClassToString(integer qclass) {
    switch (qclass) {
        case NAV_DNS_CLASS_IN:  return 'IN'
        case NAV_DNS_CLASS_CS:  return 'CS'
        case NAV_DNS_CLASS_CH:  return 'CH'
        case NAV_DNS_CLASS_HS:  return 'HS'
        case NAV_DNS_CLASS_ANY: return 'ANY'
        default:                 return itoa(qclass)
    }
}

/**
 * Validates a domain name format.
 *
 * @param domain - Domain name to validate
 * @return 1 if valid, 0 if invalid
 */
define_function char NAVDnsValidateDomainName(char domain[]) {
    stack_var integer i
    stack_var integer labelLen
    stack_var char currentChar

    if (length_array(domain) == 0 || length_array(domain) > NAV_DNS_MAX_DOMAIN_LENGTH) {
        return false
    }

    labelLen = 0

    for (i = 1; i <= length_array(domain); i++) {
        currentChar = domain[i]

        if (currentChar == '.') {
            if (labelLen == 0 || labelLen > NAV_DNS_MAX_LABEL_LENGTH) {
                return false
            }
            labelLen = 0
        }
        else if ((currentChar >= 'a' && currentChar <= 'z') ||
                 (currentChar >= 'A' && currentChar <= 'Z') ||
                 (currentChar >= '0' && currentChar <= '9') ||
                 currentChar == '-' || currentChar == '_') {
            labelLen++
        }
        else {
            // Invalid character
            return false
        }
    }

    // Check final label
    if (labelLen > NAV_DNS_MAX_LABEL_LENGTH) {
        return false
    }

    return true
}

/**
 * Generates a random transaction ID for DNS queries.
 *
 * @return Random 16-bit transaction ID
 */
define_function integer NAVDnsGenerateTransactionId() {
    return type_cast(random_number(65535))
}

/**
 * Checks if a DNS response indicates an error.
 *
 * @param response - DNS response structure
 * @return 1 if error, 0 if no error
 */
define_function char NAVDnsResponseHasError(_NAVDnsResponse response) {
    return (response.header.responseCode != NAV_DNS_RCODE_NO_ERROR)
}

/**
 * Gets the first answer from a DNS response (convenience function).
 *
 * @param response - DNS response structure
 * @param answer - Output resource record
 * @return 1 if answer exists, 0 if no answers
 */
define_function char NAVDnsResponseGetFirstAnswer(_NAVDnsResponse response, _NAVDnsResourceRecord answer) {
    if (response.header.answerCount == 0) {
        return false
    }

    answer = response.answers[1]
    return true
}


#END_IF // __NAV_FOUNDATION_DNSUTILS__
