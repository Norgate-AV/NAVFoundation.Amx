PROGRAM_NAME='NAVDnsDomainNameCodec'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.DnsUtils.axi'

DEFINE_CONSTANT

// Test domains for encoding
constant char DNS_ENCODE_TEST_DOMAINS[][255] = {
    'example.com',
    'www.google.com',
    'test.org',
    'sub.domain.test.org',
    'a.b.c.d',
    'single',
    'with-dash.example.com',
    'number123.test.org',
    'localhost'
}

// Expected encoded results (in hex notation)
// Format: [length]label[length]label...[0]
// example.com = $07 'example' $03 'com' $00
constant char DNS_ENCODE_EXPECTED[9][255] = {
    // example.com
    {$07,'e','x','a','m','p','l','e',$03,'c','o','m',$00},
    // www.google.com
    {$03,'w','w','w',$06,'g','o','o','g','l','e',$03,'c','o','m',$00},
    // test.org
    {$04,'t','e','s','t',$03,'o','r','g',$00},
    // sub.domain.test.org
    {$03,'s','u','b',$06,'d','o','m','a','i','n',$04,'t','e','s','t',$03,'o','r','g',$00},
    // a.b.c.d
    {$01,'a',$01,'b',$01,'c',$01,'d',$00},
    // single
    {$06,'s','i','n','g','l','e',$00},
    // with-dash.example.com
    {$09,'w','i','t','h','-','d','a','s','h',$07,'e','x','a','m','p','l','e',$03,'c','o','m',$00},
    // number123.test.org
    {$09,'n','u','m','b','e','r','1','2','3',$04,'t','e','s','t',$03,'o','r','g',$00},
    // localhost
    {$09,'l','o','c','a','l','h','o','s','t',$00}
}

// Binary encoded expectations (manually crafted hex arrays)
constant char DNS_ENCODE_BINARY_EXAMPLE_COM[] = {
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00
}

constant char DNS_ENCODE_BINARY_WWW_GOOGLE_COM[] = {
    $03, 'w','w','w', $06, 'g','o','o','g','l','e', $03, 'c','o','m', $00
}

constant char DNS_ENCODE_BINARY_TEST_ORG[] = {
    $04, 't','e','s','t', $03, 'o','r','g', $00
}

constant char DNS_ENCODE_BINARY_SUB_DOMAIN_TEST_ORG[] = {
    $03, 's','u','b', $06, 'd','o','m','a','i','n', $04, 't','e','s','t', $03, 'o','r','g', $00
}

constant char DNS_ENCODE_BINARY_A_B_C_D[] = {
    $01, 'a', $01, 'b', $01, 'c', $01, 'd', $00
}

constant char DNS_ENCODE_BINARY_SINGLE[] = {
    $06, 's','i','n','g','l','e', $00
}

constant char DNS_ENCODE_BINARY_WITH_DASH[] = {
    $09, 'w','i','t','h','-','d','a','s','h', $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00
}

constant char DNS_ENCODE_BINARY_NUMBER123[] = {
    $09, 'n','u','m','b','e','r','1','2','3', $04, 't','e','s','t', $03, 'o','r','g', $00
}

constant char DNS_ENCODE_BINARY_LOCALHOST[] = {
    $09, 'l','o','c','a','l','h','o','s','t', $00
}

// Expected lengths for encoded domains
constant integer DNS_ENCODE_EXPECTED_LENGTHS[] = {
    13,     // example.com
    16,     // www.google.com
    10,     // test.org
    22,     // sub.domain.test.org
    10,     // a.b.c.d
    8,      // single
    24,     // with-dash.example.com
    20,     // number123.test.org
    11      // localhost
}

// Invalid domain test cases
constant char DNS_ENCODE_INVALID_DOMAINS[][255] = {
    '',                                 // Empty
    '.example.com',                     // Leading dot
    'example..com',                     // Double dot
    'example.com.',                     // Trailing dot (should be handled)
    'verylonglabelverylonglabelverylonglabelverylonglabelverylonglabel.com'  // Label > 63 chars
}

// Test data for decoding with compression
// Simple packet for testing: Contains "example.com" at offset 12
constant char DNS_DECODE_TEST_PACKET_1[] = {
    // Header (12 bytes) - not used for decoding tests
    $12, $34, $81, $80, $00, $01, $00, $01, $00, $00, $00, $00,
    // Question: example.com at offset 12
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $01, $00, $01,
    // Answer: pointer to offset 12 (example.com)
    $C0, $0C,  // Compression pointer to offset 12
    $00, $01, $00, $01,
    $00, $00, $0E, $10,
    $00, $04,
    $5D, $B8, $D8, $22
}

// Packet with multiple compression pointers
constant char DNS_DECODE_TEST_PACKET_2[] = {
    // Header
    $12, $34, $81, $80, $00, $01, $00, $02, $00, $00, $00, $00,
    // Question: www.example.com at offset 12
    $03, 'w','w','w', $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $01, $00, $01,
    // Answer 1: www.example.com (pointer to offset 12)
    $C0, $0C,
    $00, $05, $00, $01,  // CNAME
    $00, $00, $0E, $10,
    $00, $02,
    $C0, $10,  // Pointer to "example.com" (offset 16)
    // Answer 2: example.com (pointer to offset 16)
    $C0, $10,
    $00, $01, $00, $01,  // A record
    $00, $00, $0E, $10,
    $00, $04,
    $5D, $B8, $D8, $22
}

// Expected decode results
constant char DNS_DECODE_EXPECTED_DOMAINS[][255] = {
    'example.com',
    'www.example.com',
    'example.com'
}

/**
 * Test NAVDnsDomainNameEncode() with valid domains
 */
define_function TestNAVDnsDomainNameEncode() {
    stack_var integer x
    stack_var char encoded[NAV_DNS_MAX_DOMAIN_LENGTH]
    stack_var integer resultLen
    stack_var char expectedBinary[NAV_DNS_MAX_DOMAIN_LENGTH]

    NAVLog("'***************** NAVDnsDomainNameEncode *****************'")

    for (x = 1; x <= length_array(DNS_ENCODE_TEST_DOMAINS); x++) {
        resultLen = NAVDnsDomainNameEncode(DNS_ENCODE_TEST_DOMAINS[x], encoded)

        // Test 1: Verify length
        if (!NAVAssertIntegerEqual('Should return correct encoded length',
                                   DNS_ENCODE_EXPECTED_LENGTHS[x],
                                   resultLen)) {
            NAVLogTestFailed(x, itoa(DNS_ENCODE_EXPECTED_LENGTHS[x]), itoa(resultLen))
            continue
        }

        // Test 2: Verify actual encoding against binary expectations
        select {
            active (x == 1): expectedBinary = DNS_ENCODE_BINARY_EXAMPLE_COM
            active (x == 2): expectedBinary = DNS_ENCODE_BINARY_WWW_GOOGLE_COM
            active (x == 3): expectedBinary = DNS_ENCODE_BINARY_TEST_ORG
            active (x == 4): expectedBinary = DNS_ENCODE_BINARY_SUB_DOMAIN_TEST_ORG
            active (x == 5): expectedBinary = DNS_ENCODE_BINARY_A_B_C_D
            active (x == 6): expectedBinary = DNS_ENCODE_BINARY_SINGLE
            active (x == 7): expectedBinary = DNS_ENCODE_BINARY_WITH_DASH
            active (x == 8): expectedBinary = DNS_ENCODE_BINARY_NUMBER123
            active (x == 9): expectedBinary = DNS_ENCODE_BINARY_LOCALHOST
        }

        if (!NAVAssertStringEqual('Should encode domain correctly',
                                  expectedBinary,
                                  encoded)) {
            NAVLogTestFailed(x, "'Binary mismatch for ', DNS_ENCODE_TEST_DOMAINS[x]", "'See error log'")
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsDomainNameEncode() with invalid domains
 */
define_function TestNAVDnsDomainNameEncodeInvalid() {
    stack_var integer x
    stack_var char encoded[NAV_DNS_MAX_DOMAIN_LENGTH]
    stack_var integer resultLen

    NAVLog("'***************** NAVDnsDomainNameEncode (Invalid) *****************'")

    for (x = 1; x <= length_array(DNS_ENCODE_INVALID_DOMAINS); x++) {
        resultLen = NAVDnsDomainNameEncode(DNS_ENCODE_INVALID_DOMAINS[x], encoded)

        // Most invalid domains should return 0
        // Exception: trailing dot might be handled gracefully
        if (x == 4) {
            // Trailing dot case - may or may not be handled, skip strict check
            NAVLog("'Test ', itoa(x), ': Trailing dot returned ', itoa(resultLen)")
            continue
        }

        if (!NAVAssertIntegerEqual("'Should reject invalid domain: ', DNS_ENCODE_INVALID_DOMAINS[x]",
                                   0,
                                   resultLen)) {
            NAVLogTestFailed(x, '0', itoa(resultLen))
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsDomainNameDecode() without compression
 */
define_function TestNAVDnsDomainNameDecodeSimple() {
    stack_var integer x
    stack_var char decoded[NAV_DNS_MAX_DOMAIN_LENGTH]
    stack_var integer bytesRead
    stack_var char result
    stack_var char testPacket[255]

    NAVLog("'***************** NAVDnsDomainNameDecode (Simple) *****************'")

    // Test 1: Decode example.com from offset 0
    x = 1
    testPacket = DNS_ENCODE_BINARY_EXAMPLE_COM
    result = NAVDnsDomainNameDecode(testPacket, 1, decoded, bytesRead)

    if (!NAVAssertTrue('Should decode example.com', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertStringEqual('Should decode to example.com',
                                   'example.com',
                                   decoded)) {
        NAVLogTestFailed(x, 'example.com', decoded)
    }
    else if (!NAVAssertIntegerEqual('Should read 13 bytes', 13, bytesRead)) {
        NAVLogTestFailed(x, '13', itoa(bytesRead))
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: Decode www.google.com from offset 0
    x = 2
    testPacket = DNS_ENCODE_BINARY_WWW_GOOGLE_COM
    result = NAVDnsDomainNameDecode(testPacket, 1, decoded, bytesRead)

    if (!NAVAssertTrue('Should decode www.google.com', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertStringEqual('Should decode to www.google.com',
                                   'www.google.com',
                                   decoded)) {
        NAVLogTestFailed(x, 'www.google.com', decoded)
    }
    else if (!NAVAssertIntegerEqual('Should read 16 bytes', 16, bytesRead)) {
        NAVLogTestFailed(x, '16', itoa(bytesRead))
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 3: Single label domain
    x = 3
    testPacket = DNS_ENCODE_BINARY_SINGLE
    result = NAVDnsDomainNameDecode(testPacket, 1, decoded, bytesRead)

    if (!NAVAssertTrue('Should decode single', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertStringEqual('Should decode to single',
                                   'single',
                                   decoded)) {
        NAVLogTestFailed(x, 'single', decoded)
    }
    else if (!NAVAssertIntegerEqual('Should read 8 bytes', 8, bytesRead)) {
        NAVLogTestFailed(x, '8', itoa(bytesRead))
    }
    else {
        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsDomainNameDecode() with compression pointers
 */
define_function TestNAVDnsDomainNameDecodeCompression() {
    stack_var char decoded[NAV_DNS_MAX_DOMAIN_LENGTH]
    stack_var integer bytesRead
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsDomainNameDecode (Compression) *****************'")

    // Test 1: Decode from packet 1 at offset 12 (question section)
    x = 1
    result = NAVDnsDomainNameDecode(DNS_DECODE_TEST_PACKET_1, 13, decoded, bytesRead)

    if (!NAVAssertTrue('Should decode question', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertStringEqual('Should decode to example.com',
                                   'example.com',
                                   decoded)) {
        NAVLogTestFailed(x, 'example.com', decoded)
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: Decode compression pointer in answer (offset 28, points to offset 12)
    x = 2
    result = NAVDnsDomainNameDecode(DNS_DECODE_TEST_PACKET_1, 29, decoded, bytesRead)

    if (!NAVAssertTrue('Should decode compressed name', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertStringEqual('Should decode to example.com via pointer',
                                   'example.com',
                                   decoded)) {
        NAVLogTestFailed(x, 'example.com', decoded)
    }
    else if (!NAVAssertIntegerEqual('Should read 2 bytes (pointer)', 2, bytesRead)) {
        NAVLogTestFailed(x, '2', itoa(bytesRead))
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 3: Decode from packet 2 with multiple pointers
    x = 3
    result = NAVDnsDomainNameDecode(DNS_DECODE_TEST_PACKET_2, 13, decoded, bytesRead)

    if (!NAVAssertTrue('Should decode www.example.com', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertStringEqual('Should decode to www.example.com',
                                   'www.example.com',
                                   decoded)) {
        NAVLogTestFailed(x, 'www.example.com', decoded)
    }
    else {
        NAVLogTestPassed(x)
    }
}

/**
 * Test round-trip: encode then decode
 */
define_function TestNAVDnsDomainNameRoundTrip() {
    stack_var integer x
    stack_var char encoded[NAV_DNS_MAX_DOMAIN_LENGTH]
    stack_var char decoded[NAV_DNS_MAX_DOMAIN_LENGTH]
    stack_var integer encodeLen
    stack_var integer bytesRead
    stack_var char result

    NAVLog("'***************** NAVDnsDomainName Round-Trip *****************'")

    for (x = 1; x <= length_array(DNS_ENCODE_TEST_DOMAINS); x++) {
        // Encode
        encodeLen = NAVDnsDomainNameEncode(DNS_ENCODE_TEST_DOMAINS[x], encoded)

        if (encodeLen == 0) {
            NAVLogTestFailed(x, 'Successful encode', 'Failed to encode')
            continue
        }

        // Decode
        result = NAVDnsDomainNameDecode(encoded, 1, decoded, bytesRead)

        if (!NAVAssertTrue("'Should decode encoded domain: ', DNS_ENCODE_TEST_DOMAINS[x]",
                          result)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify decoded matches original
        if (!NAVAssertStringEqual('Should round-trip correctly',
                                  DNS_ENCODE_TEST_DOMAINS[x],
                                  decoded)) {
            NAVLogTestFailed(x, DNS_ENCODE_TEST_DOMAINS[x], decoded)
            continue
        }

        // Verify bytes read matches encode length
        if (!NAVAssertIntegerEqual('Bytes read should match encode length',
                                   encodeLen,
                                   bytesRead)) {
            NAVLogTestFailed(x, itoa(encodeLen), itoa(bytesRead))
            continue
        }

        NAVLogTestPassed(x)
    }
}
