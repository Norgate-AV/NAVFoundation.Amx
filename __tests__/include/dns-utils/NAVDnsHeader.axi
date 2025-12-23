PROGRAM_NAME='NAVDnsHeader'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.DnsUtils.axi'

DEFINE_CONSTANT

// Test transaction IDs
constant integer DNS_HEADER_TEST_TRANSACTION_IDS[] = {
    $1234,
    $0000,
    $FFFF,
    $ABCD,
    $5678,
    $0001,
    $FFFE
}

// Test flag combinations
constant integer DNS_HEADER_TEST_FLAGS[] = {
    $0100,      // Standard query (RD=1)
    $8180,      // Standard response (QR=1, RD=1, RA=1)
    $8583,      // Response with error (QR=1, RD=1, RA=1, RCODE=3 NXDOMAIN)
    $8582,      // Response with SERVFAIL (QR=1, RD=1, RA=1, RCODE=2)
    $0000,      // All flags clear
    $FFFF,      // All flags set (invalid but test encoding)
    $8400,      // Authoritative answer (QR=1, AA=1)
    $8200       // Truncated response (QR=1, TC=1)
}

// Expected QR bit (0=query, 1=response)
constant integer DNS_HEADER_EXPECTED_QR[] = {
    0, 1, 1, 1, 0, 1, 1, 1
}

// Expected RD bit (recursion desired)
constant integer DNS_HEADER_EXPECTED_RD[] = {
    1, 1, 1, 1, 0, 1, 0, 0
}

// Expected RA bit (recursion available)
constant integer DNS_HEADER_EXPECTED_RA[] = {
    0, 1, 1, 1, 0, 1, 0, 0
}

// Expected AA bit (authoritative answer)
constant integer DNS_HEADER_EXPECTED_AA[] = {
    0, 0, 0, 0, 0, 0, 1, 0
}

// Expected TC bit (truncation)
constant integer DNS_HEADER_EXPECTED_TC[] = {
    0, 0, 0, 0, 0, 0, 0, 1
}

// Expected RCODE (response code)
constant integer DNS_HEADER_EXPECTED_RCODE[] = {
    0, 0, 3, 2, 0, 15, 0, 0
}

// Test section counts
constant integer DNS_HEADER_TEST_QDCOUNT[] = { 1, 1, 1, 1, 0, 2, 1, 1 }
constant integer DNS_HEADER_TEST_ANCOUNT[] = { 0, 1, 0, 0, 0, 3, 2, 1 }
constant integer DNS_HEADER_TEST_NSCOUNT[] = { 0, 0, 0, 0, 0, 1, 0, 0 }
constant integer DNS_HEADER_TEST_ARCOUNT[] = { 0, 0, 0, 0, 0, 2, 1, 0 }

// Pre-encoded test headers (12 bytes each)
constant char DNS_HEADER_BINARY_1[] = {
    $12, $34,           // Transaction ID: 0x1234
    $01, $00,           // Flags: 0x0100 (RD=1)
    $00, $01,           // QDCOUNT: 1
    $00, $00,           // ANCOUNT: 0
    $00, $00,           // NSCOUNT: 0
    $00, $00            // ARCOUNT: 0
}

constant char DNS_HEADER_BINARY_2[] = {
    $AB, $CD,           // Transaction ID: 0xABCD
    $81, $80,           // Flags: 0x8180 (QR=1, RD=1, RA=1)
    $00, $01,           // QDCOUNT: 1
    $00, $01,           // ANCOUNT: 1
    $00, $00,           // NSCOUNT: 0
    $00, $00            // ARCOUNT: 0
}

constant char DNS_HEADER_BINARY_3[] = {
    $56, $78,           // Transaction ID: 0x5678
    $85, $83,           // Flags: 0x8583 (QR=1, RD=1, RA=1, RCODE=3)
    $00, $01,           // QDCOUNT: 1
    $00, $00,           // ANCOUNT: 0
    $00, $00,           // NSCOUNT: 0
    $00, $00            // ARCOUNT: 0
}

constant char DNS_HEADER_BINARY_4[] = {
    $00, $00,           // Transaction ID: 0x0000
    $00, $00,           // Flags: 0x0000 (all clear)
    $00, $00,           // QDCOUNT: 0
    $00, $00,           // ANCOUNT: 0
    $00, $00,           // NSCOUNT: 0
    $00, $00            // ARCOUNT: 0
}

constant char DNS_HEADER_BINARY_5[] = {
    $FF, $FF,           // Transaction ID: 0xFFFF
    $FF, $FF,           // Flags: 0xFFFF (all set)
    $00, $02,           // QDCOUNT: 2
    $00, $03,           // ANCOUNT: 3
    $00, $01,           // NSCOUNT: 1
    $00, $02            // ARCOUNT: 2
}

constant char DNS_HEADER_BINARY_6[] = {
    $00, $01,           // Transaction ID: 0x0001
    $84, $00,           // Flags: 0x8400 (QR=1, AA=1)
    $00, $01,           // QDCOUNT: 1
    $00, $02,           // ANCOUNT: 2
    $00, $00,           // NSCOUNT: 0
    $00, $01            // ARCOUNT: 1
}

constant char DNS_HEADER_BINARY_7[] = {
    $FF, $FE,           // Transaction ID: 0xFFFE
    $82, $00,           // Flags: 0x8200 (QR=1, TC=1)
    $00, $01,           // QDCOUNT: 1
    $00, $01,           // ANCOUNT: 1
    $00, $00,           // NSCOUNT: 0
    $00, $00            // ARCOUNT: 0
}

/**
 * Test NAVDnsHeaderInit()
 */
define_function TestNAVDnsHeaderInit() {
    stack_var _NAVDnsHeader header
    stack_var integer x

    NAVLog("'***************** NAVDnsHeaderInit *****************'")

    for (x = 1; x <= length_array(DNS_HEADER_TEST_TRANSACTION_IDS); x++) {
        NAVDnsHeaderInit(header, DNS_HEADER_TEST_TRANSACTION_IDS[x])

        // Verify transaction ID was set
        if (!NAVAssertIntegerEqual('Should set transaction ID',
                                   DNS_HEADER_TEST_TRANSACTION_IDS[x],
                                   header.transactionId)) {
            NAVLogTestFailed(x,
                "'$', format('%04X', DNS_HEADER_TEST_TRANSACTION_IDS[x])",
                "'$', format('%04X', header.transactionId)")
            continue
        }

        // Verify counts are zero
        if (!NAVAssertIntegerEqual('Question count should be 0', 0, header.questionCount) ||
            !NAVAssertIntegerEqual('Answer count should be 0', 0, header.answerCount) ||
            !NAVAssertIntegerEqual('Authority count should be 0', 0, header.authorityCount) ||
            !NAVAssertIntegerEqual('Additional count should be 0', 0, header.additionalCount)) {
            NAVLogTestFailed(x, 'All counts = 0', 'Some counts non-zero')
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsHeaderPackFlags() and NAVDnsHeaderUnpackFlags()
 */
define_function TestNAVDnsHeaderFlags() {
    stack_var _NAVDnsHeader header
    stack_var integer x

    NAVLog("'***************** NAVDnsHeader Flag Pack/Unpack *****************'")

    for (x = 1; x <= length_array(DNS_HEADER_TEST_FLAGS); x++) {
        // Initialize and set flags value
        NAVDnsHeaderInit(header, $1234)
        header.flags = DNS_HEADER_TEST_FLAGS[x]

        // Unpack flags into individual fields
        NAVDnsHeaderUnpackFlags(header)

        // Verify unpacked QR bit
        if (!NAVAssertIntegerEqual('Should unpack QR bit correctly',
                                   DNS_HEADER_EXPECTED_QR[x],
                                   header.qr)) {
            NAVLogTestFailed(x, itoa(DNS_HEADER_EXPECTED_QR[x]), itoa(header.qr))
            continue
        }

        // Verify unpacked RD bit
        if (!NAVAssertIntegerEqual('Should unpack RD bit correctly',
                                   DNS_HEADER_EXPECTED_RD[x],
                                   header.rd)) {
            NAVLogTestFailed(x, itoa(DNS_HEADER_EXPECTED_RD[x]), itoa(header.rd))
            continue
        }

        // Verify unpacked RA bit
        if (!NAVAssertIntegerEqual('Should unpack RA bit correctly',
                                   DNS_HEADER_EXPECTED_RA[x],
                                   header.ra)) {
            NAVLogTestFailed(x, itoa(DNS_HEADER_EXPECTED_RA[x]), itoa(header.ra))
            continue
        }

        // Verify unpacked AA bit
        if (!NAVAssertIntegerEqual('Should unpack AA bit correctly',
                                   DNS_HEADER_EXPECTED_AA[x],
                                   header.aa)) {
            NAVLogTestFailed(x, itoa(DNS_HEADER_EXPECTED_AA[x]), itoa(header.aa))
            continue
        }

        // Verify unpacked TC bit
        if (!NAVAssertIntegerEqual('Should unpack TC bit correctly',
                                   DNS_HEADER_EXPECTED_TC[x],
                                   header.tc)) {
            NAVLogTestFailed(x, itoa(DNS_HEADER_EXPECTED_TC[x]), itoa(header.tc))
            continue
        }

        // Verify unpacked RCODE
        if (!NAVAssertIntegerEqual('Should unpack RCODE correctly',
                                   DNS_HEADER_EXPECTED_RCODE[x],
                                   header.responseCode)) {
            NAVLogTestFailed(x, itoa(DNS_HEADER_EXPECTED_RCODE[x]), itoa(header.responseCode))
            continue
        }

        // Now test packing: set individual fields and pack back
        header.qr = type_cast(DNS_HEADER_EXPECTED_QR[x])
        header.aa = type_cast(DNS_HEADER_EXPECTED_AA[x])
        header.tc = type_cast(DNS_HEADER_EXPECTED_TC[x])
        header.rd = type_cast(DNS_HEADER_EXPECTED_RD[x])
        header.ra = type_cast(DNS_HEADER_EXPECTED_RA[x])
        header.responseCode = type_cast(DNS_HEADER_EXPECTED_RCODE[x])

        NAVDnsHeaderPackFlags(header)

        // Verify packed flags match original
        if (!NAVAssertIntegerEqual('Should pack flags correctly',
                                   DNS_HEADER_TEST_FLAGS[x],
                                   header.flags)) {
            NAVLogTestFailed(x,
                "'$', format('%04X', DNS_HEADER_TEST_FLAGS[x])",
                "'$', format('%04X', header.flags)")
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsHeaderEncode()
 */
define_function TestNAVDnsHeaderEncode() {
    stack_var _NAVDnsHeader header
    stack_var char encoded[NAV_DNS_HEADER_SIZE]
    stack_var integer resultLen
    stack_var integer x
    stack_var char expectedBinary[NAV_DNS_HEADER_SIZE]

    NAVLog("'***************** NAVDnsHeaderEncode *****************'")

    // Test 1: Standard query
    x = 1
    NAVDnsHeaderInit(header, $1234)
    header.flags = $0100
    header.questionCount = 1
    header.answerCount = 0
    header.authorityCount = 0
    header.additionalCount = 0

    resultLen = NAVDnsHeaderEncode(header, encoded)

    if (!NAVAssertIntegerEqual('Should return header size', NAV_DNS_HEADER_SIZE, resultLen)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_HEADER_SIZE), itoa(resultLen))
    }
    else if (!NAVAssertStringEqual('Should encode header correctly',
                                   DNS_HEADER_BINARY_1,
                                   encoded)) {
        NAVLogTestFailed(x, 'Correct binary encoding', 'Mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: Standard response
    x = 2
    NAVDnsHeaderInit(header, $ABCD)
    header.flags = $8180
    header.questionCount = 1
    header.answerCount = 1
    header.authorityCount = 0
    header.additionalCount = 0

    resultLen = NAVDnsHeaderEncode(header, encoded)

    if (!NAVAssertStringEqual('Should encode response header correctly',
                              DNS_HEADER_BINARY_2,
                              encoded)) {
        NAVLogTestFailed(x, 'Correct binary encoding', 'Mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 3: Error response (NXDOMAIN)
    x = 3
    NAVDnsHeaderInit(header, $5678)
    header.flags = $8583
    header.questionCount = 1
    header.answerCount = 0
    header.authorityCount = 0
    header.additionalCount = 0

    resultLen = NAVDnsHeaderEncode(header, encoded)

    if (!NAVAssertStringEqual('Should encode error response correctly',
                              DNS_HEADER_BINARY_3,
                              encoded)) {
        NAVLogTestFailed(x, 'Correct binary encoding', 'Mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 4: All zeros
    x = 4
    NAVDnsHeaderInit(header, $0000)
    header.flags = $0000

    resultLen = NAVDnsHeaderEncode(header, encoded)

    if (!NAVAssertStringEqual('Should encode all-zero header correctly',
                              DNS_HEADER_BINARY_4,
                              encoded)) {
        NAVLogTestFailed(x, 'Correct binary encoding', 'Mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 5: Maximum values
    x = 5
    NAVDnsHeaderInit(header, $FFFF)
    header.flags = $FFFF
    header.questionCount = 2
    header.answerCount = 3
    header.authorityCount = 1
    header.additionalCount = 2

    resultLen = NAVDnsHeaderEncode(header, encoded)

    if (!NAVAssertStringEqual('Should encode max-value header correctly',
                              DNS_HEADER_BINARY_5,
                              encoded)) {
        NAVLogTestFailed(x, 'Correct binary encoding', 'Mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsHeaderDecode()
 */
define_function TestNAVDnsHeaderDecode() {
    stack_var _NAVDnsHeader header
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsHeaderDecode *****************'")

    // Test 1: Decode standard query
    x = 1
    result = NAVDnsHeaderDecode(DNS_HEADER_BINARY_1, header)

    if (!NAVAssertTrue('Should decode successfully', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertIntegerEqual('Should decode transaction ID', $1234, header.transactionId) ||
             !NAVAssertIntegerEqual('Should decode flags', $0100, header.flags) ||
             !NAVAssertIntegerEqual('Should decode question count', 1, header.questionCount) ||
             !NAVAssertIntegerEqual('Should decode answer count', 0, header.answerCount)) {
        NAVLogTestFailed(x, 'Correct header fields', 'Field mismatch')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: Decode standard response
    x = 2
    result = NAVDnsHeaderDecode(DNS_HEADER_BINARY_2, header)

    if (!NAVAssertTrue('Should decode successfully', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertIntegerEqual('Should decode transaction ID', $ABCD, header.transactionId) ||
             !NAVAssertIntegerEqual('Should decode flags', $8180, header.flags) ||
             !NAVAssertIntegerEqual('Should decode answer count', 1, header.answerCount)) {
        NAVLogTestFailed(x, 'Correct header fields', 'Field mismatch')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 3: Decode error response
    x = 3
    result = NAVDnsHeaderDecode(DNS_HEADER_BINARY_3, header)

    if (!NAVAssertTrue('Should decode successfully', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertIntegerEqual('Should decode transaction ID', $5678, header.transactionId) ||
             !NAVAssertIntegerEqual('Should decode flags', $8583, header.flags)) {
        NAVLogTestFailed(x, 'Correct header fields', 'Field mismatch')
    }
    else {
        NAVLogTestPassed(x)
    }
}

/**
 * Test header encode/decode round-trip
 */
define_function TestNAVDnsHeaderRoundTrip() {
    stack_var _NAVDnsHeader original
    stack_var _NAVDnsHeader decoded
    stack_var char encoded[NAV_DNS_HEADER_SIZE]
    stack_var integer x
    stack_var char result

    NAVLog("'***************** NAVDnsHeader Round-Trip *****************'")

    for (x = 1; x <= length_array(DNS_HEADER_TEST_TRANSACTION_IDS); x++) {
        // Create header with test data
        NAVDnsHeaderInit(original, DNS_HEADER_TEST_TRANSACTION_IDS[x])
        original.flags = DNS_HEADER_TEST_FLAGS[x]
        original.questionCount = DNS_HEADER_TEST_QDCOUNT[x]
        original.answerCount = DNS_HEADER_TEST_ANCOUNT[x]
        original.authorityCount = DNS_HEADER_TEST_NSCOUNT[x]
        original.additionalCount = DNS_HEADER_TEST_ARCOUNT[x]

        // Encode
        NAVDnsHeaderEncode(original, encoded)

        // Decode
        result = NAVDnsHeaderDecode(encoded, decoded)

        if (!NAVAssertTrue('Should decode successfully', result)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify all fields match
        if (!NAVAssertIntegerEqual('Transaction ID should match',
                                   original.transactionId,
                                   decoded.transactionId) ||
            !NAVAssertIntegerEqual('Flags should match',
                                   original.flags,
                                   decoded.flags) ||
            !NAVAssertIntegerEqual('Question count should match',
                                   original.questionCount,
                                   decoded.questionCount) ||
            !NAVAssertIntegerEqual('Answer count should match',
                                   original.answerCount,
                                   decoded.answerCount) ||
            !NAVAssertIntegerEqual('Authority count should match',
                                   original.authorityCount,
                                   decoded.authorityCount) ||
            !NAVAssertIntegerEqual('Additional count should match',
                                   original.additionalCount,
                                   decoded.additionalCount)) {
            NAVLogTestFailed(x, 'All fields match', 'Field mismatch')
            NAVLog("'Original:'")
            NAVLog("'Decoded:'")
            continue
        }

        NAVLogTestPassed(x)
    }
}
