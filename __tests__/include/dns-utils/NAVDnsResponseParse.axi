PROGRAM_NAME='NAVDnsResponseParse'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.DnsUtils.axi'

DEFINE_CONSTANT

// Mock DNS response 1: Simple A record response for example.com -> 93.184.216.34
constant char DNS_RESPONSE_A_RECORD[] = {
    // Header: ID=0x1234, Flags=0x8180 (QR=1, RD=1, RA=1), QD=1, AN=1, NS=0, AR=0
    $12, $34, $81, $80, $00, $01, $00, $01, $00, $00, $00, $00,
    // Question: example.com A IN
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $01,  // TYPE A
    $00, $01,  // CLASS IN
    // Answer: example.com A 93.184.216.34 TTL=3600
    $C0, $0C,  // Pointer to name at offset 12
    $00, $01,  // TYPE A
    $00, $01,  // CLASS IN
    $00, $00, $0E, $10,  // TTL = 3600
    $00, $04,  // RDLENGTH = 4
    $5D, $B8, $D8, $22  // 93.184.216.34
}

// Mock DNS response 2: AAAA record for ipv6.google.com
constant char DNS_RESPONSE_AAAA_RECORD[] = {
    // Header: ID=0x5678, Flags=0x8180, QD=1, AN=1
    $56, $78, $81, $80, $00, $01, $00, $01, $00, $00, $00, $00,
    // Question: ipv6.google.com AAAA IN
    $04, 'i','p','v','6', $06, 'g','o','o','g','l','e', $03, 'c','o','m', $00,
    $00, $1C,  // TYPE AAAA
    $00, $01,  // CLASS IN
    // Answer: ipv6.google.com AAAA 2607:f8b0:4004:0c07::0066 TTL=300
    $C0, $0C,  // Pointer
    $00, $1C,  // TYPE AAAA
    $00, $01,  // CLASS IN
    $00, $00, $01, $2C,  // TTL = 300
    $00, $10,  // RDLENGTH = 16
    $26, $07, $F8, $B0, $40, $04, $0C, $07, $00, $00, $00, $00, $00, $00, $00, $66
}

// Mock DNS response 3: CNAME record
constant char DNS_RESPONSE_CNAME_RECORD[] = {
    // Header: ID=0xABCD, Flags=0x8180, QD=1, AN=2 (CNAME + A)
    $AB, $CD, $81, $80, $00, $01, $00, $02, $00, $00, $00, $00,
    // Question: www.example.com A IN
    $03, 'w','w','w', $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $01,  // TYPE A
    $00, $01,  // CLASS IN
    // Answer 1: www.example.com CNAME example.com TTL=3600
    $C0, $0C,  // Pointer to www.example.com
    $00, $05,  // TYPE CNAME
    $00, $01,  // CLASS IN
    $00, $00, $0E, $10,  // TTL = 3600
    $00, $0E,  // RDLENGTH = 14
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,  // example.com (no compression here)
    // Answer 2: example.com A 93.184.216.34 TTL=3600
    $C0, $32,  // Pointer to example.com in previous answer
    $00, $01,  // TYPE A
    $00, $01,  // CLASS IN
    $00, $00, $0E, $10,  // TTL = 3600
    $00, $04,  // RDLENGTH = 4
    $5D, $B8, $D8, $22  // 93.184.216.34
}

// Mock DNS response 4: MX records (multiple answers)
constant char DNS_RESPONSE_MX_RECORDS[] = {
    // Header: ID=0x9999, Flags=0x8180, QD=1, AN=2
    $99, $99, $81, $80, $00, $01, $00, $02, $00, $00, $00, $00,
    // Question: example.com MX IN
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $0F,  // TYPE MX
    $00, $01,  // CLASS IN
    // Answer 1: example.com MX 10 mail1.example.com TTL=3600
    $C0, $0C,  // Pointer to example.com
    $00, $0F,  // TYPE MX
    $00, $01,  // CLASS IN
    $00, $00, $0E, $10,  // TTL = 3600
    $00, $14,  // RDLENGTH = 20
    $00, $0A,  // Priority = 10
    $05, 'm','a','i','l','1', $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    // Answer 2: example.com MX 20 mail2.example.com TTL=3600
    $C0, $0C,  // Pointer to example.com
    $00, $0F,  // TYPE MX
    $00, $01,  // CLASS IN
    $00, $00, $0E, $10,  // TTL = 3600
    $00, $14,  // RDLENGTH = 20
    $00, $14,  // Priority = 20
    $05, 'm','a','i','l','2', $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00
}

// Mock DNS response 5: PTR record
constant char DNS_RESPONSE_PTR_RECORD[] = {
    // Header: ID=0x7777, Flags=0x8180, QD=1, AN=1
    $77, $77, $81, $80, $00, $01, $00, $01, $00, $00, $00, $00,
    // Question: 34.216.184.93.in-addr.arpa PTR IN
    $02, '3','4', $03, '2','1','6', $03, '1','8','4', $02, '9','3',
    $07, 'i','n','-','a','d','d','r', $04, 'a','r','p','a', $00,
    $00, $0C,  // TYPE PTR
    $00, $01,  // CLASS IN
    // Answer: PTR example.com TTL=3600
    $C0, $0C,  // Pointer
    $00, $0C,  // TYPE PTR
    $00, $01,  // CLASS IN
    $00, $00, $0E, $10,  // TTL = 3600
    $00, $0D,  // RDLENGTH = 13
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00
}

// Mock DNS response 6: NXDOMAIN error
constant char DNS_RESPONSE_NXDOMAIN[] = {
    // Header: ID=0x4444, Flags=0x8183 (QR=1, RD=1, RA=1, RCODE=3), QD=1, AN=0
    $44, $44, $81, $83, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: nonexistent.example.com A IN
    $0B, 'n','o','n','e','x','i','s','t','e','n','t',
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $01,  // TYPE A
    $00, $01   // CLASS IN
}

// Mock DNS response 7: SERVFAIL error
constant char DNS_RESPONSE_SERVFAIL[] = {
    // Header: ID=0x5555, Flags=0x8182 (QR=1, RD=1, RA=1, RCODE=2), QD=1, AN=0
    $55, $55, $81, $82, $00, $01, $00, $00, $00, $00, $00, $00,
    // Question: test.example.com A IN
    $04, 't','e','s','t', $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $01,  // TYPE A
    $00, $01   // CLASS IN
}

// Mock DNS response 8: Response with authority and additional sections
constant char DNS_RESPONSE_FULL_SECTIONS[] = {
    // Header: ID=0x8888, Flags=0x8180, QD=1, AN=1, NS=1, AR=1
    $88, $88, $81, $80, $00, $01, $00, $01, $00, $01, $00, $01,
    // Question: example.com A IN
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $01, $00, $01,
    // Answer: example.com A 93.184.216.34
    $C0, $0C,  // Pointer
    $00, $01, $00, $01,
    $00, $00, $0E, $10,
    $00, $04,
    $5D, $B8, $D8, $22,
    // Authority: example.com NS ns1.example.com
    $C0, $0C,  // Pointer to example.com
    $00, $02,  // TYPE NS
    $00, $01,  // CLASS IN
    $00, $01, $51, $80,  // TTL = 86400
    $00, $11,  // RDLENGTH = 17
    $03, 'n','s','1', $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    // Additional: ns1.example.com A 192.0.2.1
    $C0, $3A,  // Pointer to ns1.example.com
    $00, $01,  // TYPE A
    $00, $01,  // CLASS IN
    $00, $01, $51, $80,  // TTL = 86400
    $00, $04,  // RDLENGTH = 4
    $C0, $00, $02, $01  // 192.0.2.1
}

/**
 * Test NAVDnsResponseInit()
 */
define_function TestNAVDnsResponseInit() {
    stack_var _NAVDnsResponse response
    stack_var integer x

    NAVLog("'***************** NAVDnsResponseInit *****************'")

    for (x = 1; x <= 3; x++) {
        NAVDnsResponseInit(response)

        // Verify initialization
        if (!NAVAssertIntegerEqual('Header question count should be 0', 0, response.header.questionCount) ||
            !NAVAssertIntegerEqual('Header answer count should be 0', 0, response.header.answerCount) ||
            !NAVAssertIntegerEqual('Header authority count should be 0', 0, response.header.authorityCount) ||
            !NAVAssertIntegerEqual('Header additional count should be 0', 0, response.header.additionalCount)) {
            NAVLogTestFailed(x, 'All counts = 0', 'Some counts non-zero')
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsResponseParse() with A record
 */
define_function TestNAVDnsResponseParseARecord() {
    stack_var _NAVDnsResponse response
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsResponseParse (A Record) *****************'")

    x = 1
    result = NAVDnsResponseParse(DNS_RESPONSE_A_RECORD, response)

    if (!NAVAssertTrue('Should parse response successfully', result)) {
        NAVLogTestFailed(x, 'true', 'false')
        return
    }
    NAVLogTestPassed(x)

    // Test header fields
    x = 2
    if (!NAVAssertIntegerEqual('Transaction ID should be 0x1234', $1234, response.header.transactionId)) {
        NAVLogTestFailed(x, '$1234', "'$', format('%04X', response.header.transactionId)")
        return
    }
    NAVLogTestPassed(x)

    x = 3
    if (!NAVAssertIntegerEqual('Should have 1 question', 1, response.header.questionCount)) {
        NAVLogTestFailed(x, '1', itoa(response.header.questionCount))
        return
    }
    NAVLogTestPassed(x)

    x = 4
    if (!NAVAssertIntegerEqual('Should have 1 answer', 1, response.header.answerCount)) {
        NAVLogTestFailed(x, '1', itoa(response.header.answerCount))
        return
    }
    NAVLogTestPassed(x)

    // Test question
    x = 5
    if (!NAVAssertStringEqual('Question name should be example.com', 'example.com', response.questions[1].name)) {
        NAVLogTestFailed(x, 'example.com', response.questions[1].name)
        return
    }
    NAVLogTestPassed(x)

    x = 6
    if (!NAVAssertIntegerEqual('Question type should be A', NAV_DNS_TYPE_A, response.questions[1].type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_A), itoa(response.questions[1].type))
        return
    }
    NAVLogTestPassed(x)

    // Test answer
    x = 7
    if (!NAVAssertStringEqual('Answer name should be example.com', 'example.com', response.answers[1].name)) {
        NAVLogTestFailed(x, 'example.com', response.answers[1].name)
        return
    }
    NAVLogTestPassed(x)

    x = 8
    if (!NAVAssertIntegerEqual('Answer type should be A', NAV_DNS_TYPE_A, response.answers[1].type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_A), itoa(response.answers[1].type))
        return
    }
    NAVLogTestPassed(x)

    x = 9
    if (!NAVAssertLongEqual('TTL should be 3600', 3600, response.answers[1].ttl)) {
        NAVLogTestFailed(x, '3600', itoa(response.answers[1].ttl))
        return
    }
    NAVLogTestPassed(x)

    x = 10
    if (!NAVAssertStringEqual('IP address should be 93.184.216.34', '93.184.216.34', response.answers[1].address)) {
        NAVLogTestFailed(x, '93.184.216.34', response.answers[1].address)
        return
    }
    NAVLogTestPassed(x)
}

/**
 * Test NAVDnsResponseParse() with AAAA record
 */
define_function TestNAVDnsResponseParseAAAARecord() {
    stack_var _NAVDnsResponse response
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsResponseParse (AAAA Record) *****************'")

    x = 1
    result = NAVDnsResponseParse(DNS_RESPONSE_AAAA_RECORD, response)

    if (!NAVAssertTrue('Should parse AAAA response successfully', result)) {
        NAVLogTestFailed(x, 'true', 'false')
        return
    }
    NAVLogTestPassed(x)

    x = 2
    if (!NAVAssertIntegerEqual('Should have 1 answer', 1, response.header.answerCount)) {
        NAVLogTestFailed(x, '1', itoa(response.header.answerCount))
        return
    }
    NAVLogTestPassed(x)

    x = 3
    if (!NAVAssertIntegerEqual('Answer type should be AAAA', NAV_DNS_TYPE_AAAA, response.answers[1].type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_AAAA), itoa(response.answers[1].type))
        return
    }
    NAVLogTestPassed(x)

    x = 4
    if (!NAVAssertStringEqual('IPv6 address should be parsed', '2607:f8b0:4004:c07::66', response.answers[1].address)) {
        NAVLogTestFailed(x, '2607:f8b0:4004:c07::66', response.answers[1].address)
        return
    }
    NAVLogTestPassed(x)
}

/**
 * Test NAVDnsResponseParse() with CNAME record
 */
define_function TestNAVDnsResponseParseCNAMERecord() {
    stack_var _NAVDnsResponse response
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsResponseParse (CNAME Record) *****************'")

    x = 1
    result = NAVDnsResponseParse(DNS_RESPONSE_CNAME_RECORD, response)

    if (!NAVAssertTrue('Should parse CNAME response successfully', result)) {
        NAVLogTestFailed(x, 'true', 'false')
        return
    }
    NAVLogTestPassed(x)

    x = 2
    if (!NAVAssertIntegerEqual('Should have 2 answers', 2, response.header.answerCount)) {
        NAVLogTestFailed(x, '2', itoa(response.header.answerCount))
        return
    }
    NAVLogTestPassed(x)

    // First answer should be CNAME
    x = 3
    if (!NAVAssertIntegerEqual('First answer type should be CNAME', NAV_DNS_TYPE_CNAME, response.answers[1].type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_CNAME), itoa(response.answers[1].type))
        return
    }
    NAVLogTestPassed(x)

    x = 4
    if (!NAVAssertStringEqual('CNAME target should be example.com', 'example.com', response.answers[1].cname)) {
        NAVLogTestFailed(x, 'example.com', response.answers[1].cname)
        return
    }
    NAVLogTestPassed(x)

    // Second answer should be A record
    x = 5
    if (!NAVAssertIntegerEqual('Second answer type should be A', NAV_DNS_TYPE_A, response.answers[2].type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_A), itoa(response.answers[2].type))
        return
    }
    NAVLogTestPassed(x)

    x = 6
    if (!NAVAssertStringEqual('A record IP should be 93.184.216.34', '93.184.216.34', response.answers[2].address)) {
        NAVLogTestFailed(x, '93.184.216.34', response.answers[2].address)
        return
    }
    NAVLogTestPassed(x)
}

/**
 * Test NAVDnsResponseParse() with MX records
 */
define_function TestNAVDnsResponseParseMXRecords() {
    stack_var _NAVDnsResponse response
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsResponseParse (MX Records) *****************'")

    x = 1
    result = NAVDnsResponseParse(DNS_RESPONSE_MX_RECORDS, response)

    if (!NAVAssertTrue('Should parse MX response successfully', result)) {
        NAVLogTestFailed(x, 'true', 'false')
        return
    }
    NAVLogTestPassed(x)

    x = 2
    if (!NAVAssertIntegerEqual('Should have 2 answers', 2, response.header.answerCount)) {
        NAVLogTestFailed(x, '2', itoa(response.header.answerCount))
        return
    }
    NAVLogTestPassed(x)

    // First MX record
    x = 3
    if (!NAVAssertIntegerEqual('First answer type should be MX', NAV_DNS_TYPE_MX, response.answers[1].type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_MX), itoa(response.answers[1].type))
        return
    }
    NAVLogTestPassed(x)

    x = 4
    if (!NAVAssertIntegerEqual('First MX priority should be 10', 10, response.answers[1].priority)) {
        NAVLogTestFailed(x, '10', itoa(response.answers[1].priority))
        return
    }
    NAVLogTestPassed(x)

    x = 5
    if (!NAVAssertStringEqual('First MX target should be mail1.example.com', 'mail1.example.com', response.answers[1].target)) {
        NAVLogTestFailed(x, 'mail1.example.com', response.answers[1].target)
        return
    }
    NAVLogTestPassed(x)

    // Second MX record
    x = 6
    if (!NAVAssertIntegerEqual('Second MX priority should be 20', 20, response.answers[2].priority)) {
        NAVLogTestFailed(x, '20', itoa(response.answers[2].priority))
        return
    }
    NAVLogTestPassed(x)

    x = 7
    if (!NAVAssertStringEqual('Second MX target should be mail2.example.com', 'mail2.example.com', response.answers[2].target)) {
        NAVLogTestFailed(x, 'mail2.example.com', response.answers[2].target)
        return
    }
    NAVLogTestPassed(x)
}

/**
 * Test NAVDnsResponseParse() with PTR record
 */
define_function TestNAVDnsResponseParsePTRRecord() {
    stack_var _NAVDnsResponse response
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsResponseParse (PTR Record) *****************'")

    x = 1
    result = NAVDnsResponseParse(DNS_RESPONSE_PTR_RECORD, response)

    if (!NAVAssertTrue('Should parse PTR response successfully', result)) {
        NAVLogTestFailed(x, 'true', 'false')
        return
    }
    NAVLogTestPassed(x)

    x = 2
    if (!NAVAssertIntegerEqual('Should have 1 answer', 1, response.header.answerCount)) {
        NAVLogTestFailed(x, '1', itoa(response.header.answerCount))
        return
    }
    NAVLogTestPassed(x)

    x = 3
    if (!NAVAssertIntegerEqual('Answer type should be PTR', NAV_DNS_TYPE_PTR, response.answers[1].type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_PTR), itoa(response.answers[1].type))
        return
    }
    NAVLogTestPassed(x)

    x = 4
    if (!NAVAssertStringEqual('PTR target should be example.com', 'example.com', response.answers[1].cname)) {
        NAVLogTestFailed(x, 'example.com', response.answers[1].cname)
        return
    }
    NAVLogTestPassed(x)
}

/**
 * Test NAVDnsResponseParse() with error responses
 */
define_function TestNAVDnsResponseParseErrors() {
    stack_var _NAVDnsResponse response
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsResponseParse (Errors) *****************'")

    // Test NXDOMAIN
    x = 1
    result = NAVDnsResponseParse(DNS_RESPONSE_NXDOMAIN, response)

    if (!NAVAssertTrue('Should parse NXDOMAIN response', result)) {
        NAVLogTestFailed(x, 'true', 'false')
        return
    }
    NAVLogTestPassed(x)

    x = 2
    if (!NAVAssertIntegerEqual('RCODE should be NXDOMAIN (3)', NAV_DNS_RCODE_NAME_ERROR, response.header.responseCode)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_RCODE_NAME_ERROR), itoa(response.header.responseCode))
        return
    }
    NAVLogTestPassed(x)

    x = 3
    if (!NAVAssertIntegerEqual('Should have 0 answers', 0, response.header.answerCount)) {
        NAVLogTestFailed(x, '0', itoa(response.header.answerCount))
        return
    }
    NAVLogTestPassed(x)

    // Test SERVFAIL
    x = 4
    result = NAVDnsResponseParse(DNS_RESPONSE_SERVFAIL, response)

    if (!NAVAssertTrue('Should parse SERVFAIL response', result)) {
        NAVLogTestFailed(x, 'true', 'false')
        return
    }
    NAVLogTestPassed(x)

    x = 5
    if (!NAVAssertIntegerEqual('RCODE should be SERVFAIL (2)', NAV_DNS_RCODE_SERVER_FAILURE, response.header.responseCode)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_RCODE_SERVER_FAILURE), itoa(response.header.responseCode))
        return
    }
    NAVLogTestPassed(x)
}

/**
 * Test NAVDnsResponseParse() with all sections (answer, authority, additional)
 */
define_function TestNAVDnsResponseParseFullSections() {
    stack_var _NAVDnsResponse response
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsResponseParse (Full Sections) *****************'")

    x = 1
    result = NAVDnsResponseParse(DNS_RESPONSE_FULL_SECTIONS, response)

    if (!NAVAssertTrue('Should parse response with all sections', result)) {
        NAVLogTestFailed(x, 'true', 'false')
        return
    }
    NAVLogTestPassed(x)

    x = 2
    if (!NAVAssertIntegerEqual('Should have 1 answer', 1, response.header.answerCount)) {
        NAVLogTestFailed(x, '1', itoa(response.header.answerCount))
        return
    }
    NAVLogTestPassed(x)

    x = 3
    if (!NAVAssertIntegerEqual('Should have 1 authority record', 1, response.header.authorityCount)) {
        NAVLogTestFailed(x, '1', itoa(response.header.authorityCount))
        return
    }
    NAVLogTestPassed(x)

    x = 4
    if (!NAVAssertIntegerEqual('Should have 1 additional record', 1, response.header.additionalCount)) {
        NAVLogTestFailed(x, '1', itoa(response.header.additionalCount))
        return
    }
    NAVLogTestPassed(x)

    // Verify authority section (NS record)
    x = 5
    if (!NAVAssertIntegerEqual('Authority record type should be NS', NAV_DNS_TYPE_NS, response.authority[1].type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_NS), itoa(response.authority[1].type))
        return
    }
    NAVLogTestPassed(x)

    // Verify additional section (A record)
    x = 6
    if (!NAVAssertIntegerEqual('Additional record type should be A', NAV_DNS_TYPE_A, response.additional[1].type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_A), itoa(response.additional[1].type))
        return
    }
    NAVLogTestPassed(x)

    x = 7
    if (!NAVAssertStringEqual('Additional A record should be 192.0.2.1', '192.0.2.1', response.additional[1].address)) {
        NAVLogTestFailed(x, '192.0.2.1', response.additional[1].address)
        return
    }
    NAVLogTestPassed(x)
}
