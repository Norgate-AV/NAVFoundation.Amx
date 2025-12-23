PROGRAM_NAME='NAVDnsQuery'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.DnsUtils.axi'

DEFINE_CONSTANT

// Test domains for queries
constant char DNS_QUERY_TEST_DOMAINS[][255] = {
    'example.com',
    'www.google.com',
    'dns.google',
    'mail.example.org',
    '1.1.1.1.in-addr.arpa',
    'test.local',
    'sub.domain.test.org',
    'ipv6.google.com'
}

// Test query types
constant integer DNS_QUERY_TEST_TYPES[] = {
    NAV_DNS_TYPE_A,
    NAV_DNS_TYPE_A,
    NAV_DNS_TYPE_AAAA,
    NAV_DNS_TYPE_MX,
    NAV_DNS_TYPE_PTR,
    NAV_DNS_TYPE_A,
    NAV_DNS_TYPE_CNAME,
    NAV_DNS_TYPE_AAAA
}

// Test transaction IDs
constant integer DNS_QUERY_TEST_TX_IDS[] = {
    $1234,
    $ABCD,
    $5678,
    $9ABC,
    $DEF0,
    $0001,
    $FFFF,
    $8765
}

// Pre-built expected DNS queries (binary format)
// Query 1: example.com A record, TX ID 0x1234
constant char DNS_QUERY_EXPECTED_1[] = {
    // Header: ID=0x1234, Flags=0x0100 (RD=1), QDCOUNT=1, others=0
    $12, $34, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: example.com
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $01,  // TYPE A
    $00, $01   // CLASS IN
}

// Query 2: www.google.com A record, TX ID 0xABCD
constant char DNS_QUERY_EXPECTED_2[] = {
    // Header
    $AB, $CD, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: www.google.com
    $03, 'w','w','w', $06, 'g','o','o','g','l','e', $03, 'c','o','m', $00,
    $00, $01,  // TYPE A
    $00, $01   // CLASS IN
}

// Query 3: dns.google AAAA record, TX ID 0x5678
constant char DNS_QUERY_EXPECTED_3[] = {
    // Header
    $56, $78, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: dns.google
    $03, 'd','n','s', $06, 'g','o','o','g','l','e', $00,
    $00, $1C,  // TYPE AAAA (28)
    $00, $01   // CLASS IN
}

// Query 4: mail.example.org MX record, TX ID 0x9ABC
constant char DNS_QUERY_EXPECTED_4[] = {
    // Header
    $9A, $BC, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: mail.example.org
    $04, 'm','a','i','l', $07, 'e','x','a','m','p','l','e', $03, 'o','r','g', $00,
    $00, $0F,  // TYPE MX (15)
    $00, $01   // CLASS IN
}

// Query 5: 1.1.1.1.in-addr.arpa PTR record, TX ID 0xDEF0
constant char DNS_QUERY_EXPECTED_5[] = {
    // Header
    $DE, $F0, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: 1.1.1.1.in-addr.arpa
    $01, '1', $01, '1', $01, '1', $01, '1', $07, 'i','n','-','a','d','d','r', $04, 'a','r','p','a', $00,
    $00, $0C,  // TYPE PTR (12)
    $00, $01   // CLASS IN
}

// Query 6: test.local A record, TX ID 0x0001
constant char DNS_QUERY_EXPECTED_6[] = {
    // Header
    $00, $01, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: test.local
    $04, 't','e','s','t', $05, 'l','o','c','a','l', $00,
    $00, $01,  // TYPE A
    $00, $01   // CLASS IN
}

// Query 7: sub.domain.test.org CNAME record, TX ID 0xFFFF
constant char DNS_QUERY_EXPECTED_7[] = {
    // Header
    $FF, $FF, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: sub.domain.test.org
    $03, 's','u','b', $06, 'd','o','m','a','i','n', $04, 't','e','s','t', $03, 'o','r','g', $00,
    $00, $05,  // TYPE CNAME (5)
    $00, $01   // CLASS IN
}

// Query 8: ipv6.google.com AAAA record, TX ID 0x8765
constant char DNS_QUERY_EXPECTED_8[] = {
    // Header
    $87, $65, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: ipv6.google.com
    $04, 'i','p','v','6', $06, 'g','o','o','g','l','e', $03, 'c','o','m', $00,
    $00, $1C,  // TYPE AAAA (28)
    $00, $01   // CLASS IN
}

// Additional query types for comprehensive testing
constant char DNS_QUERY_TXT_EXPECTED[] = {
    // Header: ID=0x1111, standard query
    $11, $11, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: test.example.com TXT
    $04, 't','e','s','t', $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $10,  // TYPE TXT (16)
    $00, $01   // CLASS IN
}

constant char DNS_QUERY_NS_EXPECTED[] = {
    // Header: ID=0x2222, standard query
    $22, $22, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: example.com NS
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $02,  // TYPE NS (2)
    $00, $01   // CLASS IN
}

constant char DNS_QUERY_SOA_EXPECTED[] = {
    // Header: ID=0x3333, standard query
    $33, $33, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: example.com SOA
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $06,  // TYPE SOA (6)
    $00, $01   // CLASS IN
}

/**
 * Test NAVDnsQueryInit()
 */
define_function TestNAVDnsQueryInit() {
    stack_var _NAVDnsQuery query
    stack_var integer x

    NAVLog("'***************** NAVDnsQueryInit *****************'")

    for (x = 1; x <= 5; x++) {
        NAVDnsQueryInit(query)

        // Verify initialization
        if (!NAVAssertIntegerEqual('Question count should be 0', 0, query.questionCount)) {
            NAVLogTestFailed(x, '0', itoa(query.questionCount))
            continue
        }

        if (!NAVAssertIntegerEqual('Packet length should be 0', 0, query.packetLength)) {
            NAVLogTestFailed(x, '0', itoa(query.packetLength))
            continue
        }

        if (!NAVAssertIntegerEqual('Header question count should be 0', 0, query.header.questionCount)) {
            NAVLogTestFailed(x, '0', itoa(query.header.questionCount))
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsQueryAddQuestion()
 */
define_function TestNAVDnsQueryAddQuestion() {
    stack_var _NAVDnsQuery query
    stack_var integer x
    stack_var char result

    NAVLog("'***************** NAVDnsQueryAddQuestion *****************'")

    for (x = 1; x <= length_array(DNS_QUERY_TEST_DOMAINS); x++) {
        NAVDnsQueryInit(query)

        result = NAVDnsQueryAddQuestion(query,
                                       DNS_QUERY_TEST_DOMAINS[x],
                                       DNS_QUERY_TEST_TYPES[x],
                                       NAV_DNS_CLASS_IN)

        if (!NAVAssertTrue('Should add question successfully', result)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVAssertIntegerEqual('Question count should be 1', 1, query.questionCount)) {
            NAVLogTestFailed(x, '1', itoa(query.questionCount))
            continue
        }

        if (!NAVAssertStringEqual('Question name should match',
                                  DNS_QUERY_TEST_DOMAINS[x],
                                  query.questions[1].name)) {
            NAVLogTestFailed(x, DNS_QUERY_TEST_DOMAINS[x], query.questions[1].name)
            continue
        }

        if (!NAVAssertIntegerEqual('Question type should match',
                                   DNS_QUERY_TEST_TYPES[x],
                                   query.questions[1].type)) {
            NAVLogTestFailed(x, itoa(DNS_QUERY_TEST_TYPES[x]), itoa(query.questions[1].type))
            continue
        }

        if (!NAVAssertIntegerEqual('Question class should be IN',
                                   NAV_DNS_CLASS_IN,
                                   query.questions[1].qclass)) {
            NAVLogTestFailed(x, itoa(NAV_DNS_CLASS_IN), itoa(query.questions[1].qclass))
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsQueryAddQuestion() with multiple questions
 */
define_function TestNAVDnsQueryAddMultipleQuestions() {
    stack_var _NAVDnsQuery query
    stack_var char result

    NAVLog("'***************** NAVDnsQueryAddQuestion (Multiple) *****************'")

    NAVDnsQueryInit(query)

    // Add first question
    result = NAVDnsQueryAddQuestion(query, 'example.com', NAV_DNS_TYPE_A, NAV_DNS_CLASS_IN)
    if (!NAVAssertTrue('Should add first question', result) ||
        !NAVAssertIntegerEqual('Question count should be 1', 1, query.questionCount)) {
        NAVLogTestFailed(1, 'Success', 'Failed')
        return
    }
    NAVLogTestPassed(1)

    // Add second question
    result = NAVDnsQueryAddQuestion(query, 'example.com', NAV_DNS_TYPE_AAAA, NAV_DNS_CLASS_IN)
    if (!NAVAssertTrue('Should add second question', result) ||
        !NAVAssertIntegerEqual('Question count should be 2', 2, query.questionCount)) {
        NAVLogTestFailed(2, 'Success', 'Failed')
        return
    }
    NAVLogTestPassed(2)

    // Verify both questions are stored correctly
    if (!NAVAssertIntegerEqual('First question type', NAV_DNS_TYPE_A, query.questions[1].type) ||
        !NAVAssertIntegerEqual('Second question type', NAV_DNS_TYPE_AAAA, query.questions[2].type)) {
        NAVLogTestFailed(3, 'Correct types', 'Type mismatch')
        return
    }
    NAVLogTestPassed(3)
}

/**
 * Test NAVDnsQueryBuild()
 */
define_function TestNAVDnsQueryBuild() {
    stack_var _NAVDnsQuery query
    stack_var integer x
    stack_var char result

    NAVLog("'***************** NAVDnsQueryBuild *****************'")

    for (x = 1; x <= length_array(DNS_QUERY_TEST_DOMAINS); x++) {
        NAVDnsQueryInit(query)
        NAVDnsQueryAddQuestion(query,
                              DNS_QUERY_TEST_DOMAINS[x],
                              DNS_QUERY_TEST_TYPES[x],
                              NAV_DNS_CLASS_IN)

        result = NAVDnsQueryBuild(query, DNS_QUERY_TEST_TX_IDS[x])

        if (!NAVAssertTrue('Should build query successfully', result)) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        if (!NAVAssertIntegerGreaterThan('Packet length should be > 0', 0, query.packetLength)) {
            NAVLogTestFailed(x, '>0', itoa(query.packetLength))
            continue
        }

        if (!NAVAssertIntegerEqual('Header should have correct TX ID',
                                   DNS_QUERY_TEST_TX_IDS[x],
                                   query.header.transactionId)) {
            NAVLogTestFailed(x,
                "'$', format('%04X', DNS_QUERY_TEST_TX_IDS[x])",
                "'$', format('%04X', query.header.transactionId)")
            continue
        }

        if (!NAVAssertIntegerEqual('Header should have 1 question',
                                   1,
                                   query.header.questionCount)) {
            NAVLogTestFailed(x, '1', itoa(query.header.questionCount))
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsQueryCreate() convenience function
 */
define_function TestNAVDnsQueryCreate() {
    stack_var _NAVDnsQuery query
    stack_var integer x
    stack_var char result
    stack_var char expectedPacket[NAV_DNS_MAX_PACKET_SIZE]

    NAVLog("'***************** NAVDnsQueryCreate *****************'")

    // Test 1: example.com A
    x = 1
    result = NAVDnsQueryCreate(query, DNS_QUERY_TEST_DOMAINS[1], DNS_QUERY_TEST_TYPES[1], DNS_QUERY_TEST_TX_IDS[1])

    if (!NAVAssertTrue('Should create query', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertStringEqual('Should match expected packet',
                                   DNS_QUERY_EXPECTED_1,
                                   query.packetData)) {
        NAVLogTestFailed(x, 'Correct packet', 'Packet mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: www.google.com A
    x = 2
    result = NAVDnsQueryCreate(query, DNS_QUERY_TEST_DOMAINS[2], DNS_QUERY_TEST_TYPES[2], DNS_QUERY_TEST_TX_IDS[2])

    if (!NAVAssertStringEqual('Should match expected packet',
                              DNS_QUERY_EXPECTED_2,
                              query.packetData)) {
        NAVLogTestFailed(x, 'Correct packet', 'Packet mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 3: dns.google AAAA
    x = 3
    result = NAVDnsQueryCreate(query, DNS_QUERY_TEST_DOMAINS[3], DNS_QUERY_TEST_TYPES[3], DNS_QUERY_TEST_TX_IDS[3])

    if (!NAVAssertStringEqual('Should match expected packet',
                              DNS_QUERY_EXPECTED_3,
                              query.packetData)) {
        NAVLogTestFailed(x, 'Correct packet', 'Packet mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 4: mail.example.org MX
    x = 4
    result = NAVDnsQueryCreate(query, DNS_QUERY_TEST_DOMAINS[4], DNS_QUERY_TEST_TYPES[4], DNS_QUERY_TEST_TX_IDS[4])

    if (!NAVAssertStringEqual('Should match expected packet',
                              DNS_QUERY_EXPECTED_4,
                              query.packetData)) {
        NAVLogTestFailed(x, 'Correct packet', 'Packet mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 5: PTR query
    x = 5
    result = NAVDnsQueryCreate(query, DNS_QUERY_TEST_DOMAINS[5], DNS_QUERY_TEST_TYPES[5], DNS_QUERY_TEST_TX_IDS[5])

    if (!NAVAssertStringEqual('Should match expected packet',
                              DNS_QUERY_EXPECTED_5,
                              query.packetData)) {
        NAVLogTestFailed(x, 'Correct packet', 'Packet mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 6-8: Remaining queries
    x = 6
    result = NAVDnsQueryCreate(query, DNS_QUERY_TEST_DOMAINS[6], DNS_QUERY_TEST_TYPES[6], DNS_QUERY_TEST_TX_IDS[6])
    if (!NAVAssertStringEqual('Should match expected packet', DNS_QUERY_EXPECTED_6, query.packetData)) {
        NAVLogTestFailed(x, 'Correct packet', 'Packet mismatch')
    } else {
        NAVLogTestPassed(x)
    }

    x = 7
    result = NAVDnsQueryCreate(query, DNS_QUERY_TEST_DOMAINS[7], DNS_QUERY_TEST_TYPES[7], DNS_QUERY_TEST_TX_IDS[7])
    if (!NAVAssertStringEqual('Should match expected packet', DNS_QUERY_EXPECTED_7, query.packetData)) {
        NAVLogTestFailed(x, 'Correct packet', 'Packet mismatch')
    } else {
        NAVLogTestPassed(x)
    }

    x = 8
    result = NAVDnsQueryCreate(query, DNS_QUERY_TEST_DOMAINS[8], DNS_QUERY_TEST_TYPES[8], DNS_QUERY_TEST_TX_IDS[8])
    if (!NAVAssertStringEqual('Should match expected packet', DNS_QUERY_EXPECTED_8, query.packetData)) {
        NAVLogTestFailed(x, 'Correct packet', 'Packet mismatch')
    } else {
        NAVLogTestPassed(x)
    }
}

/**
 * Test additional query types (TXT, NS, SOA)
 */
define_function TestNAVDnsQueryAdditionalTypes() {
    stack_var _NAVDnsQuery query
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsQuery Additional Types *****************'")

    // Test TXT record query
    x = 1
    result = NAVDnsQueryCreate(query, 'test.example.com', NAV_DNS_TYPE_TXT, $1111)

    if (!NAVAssertStringEqual('Should create TXT query correctly',
                              DNS_QUERY_TXT_EXPECTED,
                              query.packetData)) {
        NAVLogTestFailed(x, 'Correct TXT query', 'Packet mismatch')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test NS record query
    x = 2
    result = NAVDnsQueryCreate(query, 'example.com', NAV_DNS_TYPE_NS, $2222)

    if (!NAVAssertStringEqual('Should create NS query correctly',
                              DNS_QUERY_NS_EXPECTED,
                              query.packetData)) {
        NAVLogTestFailed(x, 'Correct NS query', 'Packet mismatch')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test SOA record query
    x = 3
    result = NAVDnsQueryCreate(query, 'example.com', NAV_DNS_TYPE_SOA, $3333)

    if (!NAVAssertStringEqual('Should create SOA query correctly',
                              DNS_QUERY_SOA_EXPECTED,
                              query.packetData)) {
        NAVLogTestFailed(x, 'Correct packet', 'Packet mismatch - see error log')
    }
    else {
        NAVLogTestPassed(x)
    }
}
