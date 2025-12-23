PROGRAM_NAME='DnsUtilsShared'

/*
 * Common utility functions and definitions for DNS utils tests
 */

#IF_NOT_DEFINED __DNS_UTILS_SHARED__
#DEFINE __DNS_UTILS_SHARED__ 'DnsUtilsShared'

#include 'NAVFoundation.DnsUtils.h.axi'
#include 'NAVFoundation.Encoding.axi'

/**
 * Helper to display DNS header for debugging
 */
define_function LogDnsHeader(_NAVDnsHeader header) {
    NAVLog("'  Transaction ID: ', itoa(header.transactionId)")
    NAVLog("'  Flags: $', format('%04X', header.flags)")
    if (header.qr) {
        NAVLog("'    QR: ', itoa(header.qr), ' (Response)'")
    }
    else {
        NAVLog("'    QR: ', itoa(header.qr), ' (Query)'")
    }
    NAVLog("'    Opcode: ', itoa(header.opcode)")
    NAVLog("'    AA: ', itoa(header.aa)")
    NAVLog("'    TC: ', itoa(header.tc)")
    NAVLog("'    RD: ', itoa(header.rd)")
    NAVLog("'    RA: ', itoa(header.ra)")
    NAVLog("'    Response Code: ', itoa(header.responseCode)")
    NAVLog("'  Questions: ', itoa(header.questionCount)")
    NAVLog("'  Answers: ', itoa(header.answerCount)")
    NAVLog("'  Authority: ', itoa(header.authorityCount)")
    NAVLog("'  Additional: ', itoa(header.additionalCount)")
}

/**
 * Helper to display query packet for debugging
 */
define_function LogDnsQueryPacket(_NAVDnsQuery query) {
    stack_var integer i
    stack_var char output[NAV_MAX_BUFFER]

    NAVLog("'  Transaction ID: $', format('%04X', query.header.transactionId)")
    NAVLog("'  Flags: $', format('%04X', query.header.flags)")
    NAVLog("'  Question Count: ', itoa(query.questionCount)")

    for (i = 1; i <= query.questionCount; i++) {
        NAVLog("'  Question ', itoa(i), ':'")
        NAVLog("'    Name: ', query.questions[i].name")
        NAVLog("'    Type: ', itoa(query.questions[i].type)")
        NAVLog("'    Class: ', itoa(query.questions[i].qclass)")
    }

    NAVLog("'  Packet Length: ', itoa(query.packetLength), ' bytes'")

    // Display first 32 bytes of packet in hex
    output = '  Packet: '
    for (i = 1; i <= min_value(32, query.packetLength); i++) {
        output = "output, format('%02X ', query.packetData[i])"
        if (i == 16) {
            NAVLog(output)
            output = '          '
        }
    }
    if (query.packetLength > 32) {
        output = "output, '...'"
    }
    NAVLog(output)
}

/**
 * Helper to display response for debugging
 */
define_function LogDnsResponse(_NAVDnsResponse response) {
    stack_var integer i

    NAVLog("'  Transaction ID: $', format('%04X', response.header.transactionId)")
    NAVLog("'  Flags: $', format('%04X', response.header.flags)")
    NAVLog("'  RCODE: ', itoa(response.header.responseCode)")
    NAVLog("'  Questions: ', itoa(response.header.questionCount)")
    NAVLog("'  Answers: ', itoa(response.header.answerCount)")
    NAVLog("'  Authority: ', itoa(response.header.authorityCount)")
    NAVLog("'  Additional: ', itoa(response.header.additionalCount)")

    for (i = 1; i <= response.header.answerCount; i++) {
        NAVLog("'  Answer ', itoa(i), ':'")
        NAVLog("'    Name: ', response.answers[i].name")
        NAVLog("'    Type: ', itoa(response.answers[i].type)")
        NAVLog("'    TTL: ', itoa(response.answers[i].ttl)")
        NAVLog("'    Data Length: ', itoa(response.answers[i].dataLength)")
        if (response.answers[i].type == NAV_DNS_TYPE_A) {
            NAVLog("'    Address: ', response.answers[i].address")
        }
        else if (response.answers[i].type == NAV_DNS_TYPE_CNAME || response.answers[i].type == NAV_DNS_TYPE_PTR) {
            NAVLog("'    Target: ', response.answers[i].cname")
        }
        else if (response.answers[i].type == NAV_DNS_TYPE_MX) {
            NAVLog("'    Priority: ', itoa(response.answers[i].priority)")
            NAVLog("'    Target: ', response.answers[i].target")
        }
    }
}

/**
 * Format integer as hex string for display
 * Converts 16-bit integer to byte array and formats for logging
 *
 * @param value - Integer value to format
 * @return Hex string like "$8180"
 */
define_function char[NAV_MAX_BUFFER] NAVDnsFormatIntegerHex(integer value) {
    return NAVFormatHex(NAVIntegerToByteArrayBE(value))
}

/**
 * Format long as hex string for display
 * Converts 32-bit long to byte array and formats for logging
 *
 * @param value - Long value to format
 * @return Hex string like "$12$34$56$78"
 */
define_function char[NAV_MAX_BUFFER] NAVDnsFormatLongHex(long value) {
    return NAVFormatHex(NAVLongToByteArrayBE(value))
}

/**
 * Assert integer equality with hex formatting for errors
 * Uses hex display for better DNS debugging
 *
 * @param testName - Name/description of test
 * @param expected - Expected integer value
 * @param actual - Actual integer value
 * @return true if equal, false otherwise
 */
define_function char NAVDnsAssertIntegerEqualHex(char testName[], integer expected, integer actual) {
    if (expected == actual) {
        return true
    } else {
        if (length_array(testName) > 0) {
            NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "testName")
        }

        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Expected: ', NAVDnsFormatIntegerHex(expected)")
        NAVErrorLog(NAV_LOG_LEVEL_DEBUG, "'Got     : ', NAVDnsFormatIntegerHex(actual)")
        return false
    }
}

#END_IF // __DNS_UTILS_SHARED__
