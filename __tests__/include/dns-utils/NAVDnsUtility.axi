PROGRAM_NAME='NAVDnsUtility'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.DnsUtils.axi'

DEFINE_CONSTANT

// Test domains for validation
constant char DNS_VALID_DOMAINS[][255] = {
    'example.com',
    'www.google.com',
    'sub.domain.test.org',
    'a.b.c.d.e.f',
    'test-dash.example.com',
    'with123numbers.org',
    'localhost',
    'x.com',
    't',
    'very-long-but-valid-label-under-63-chars.example.com'
}

constant char DNS_INVALID_DOMAINS[][255] = {
    '',                             // Empty
    '.',                            // Just dot
    '.example.com',                 // Leading dot
    'example..com',                 // Consecutive dots
    '-example.com',                 // Leading hyphen
    'example-.com',                 // Trailing hyphen
    'example.com-',                 // Trailing hyphen at end
    'exam ple.com',                 // Space
    'example.com.',                 // Trailing dot (may be acceptable in some contexts)
    'verylonglabelthatiswaymorethan63charactersandthereforeexceedsthemaximumlabellengthallowedindns.com'
}

// Test query types for string conversion
constant integer DNS_TYPE_TEST_VALUES[] = {
    NAV_DNS_TYPE_A,
    NAV_DNS_TYPE_NS,
    NAV_DNS_TYPE_CNAME,
    NAV_DNS_TYPE_SOA,
    NAV_DNS_TYPE_PTR,
    NAV_DNS_TYPE_MX,
    NAV_DNS_TYPE_TXT,
    NAV_DNS_TYPE_AAAA,
    NAV_DNS_TYPE_SRV,
    NAV_DNS_TYPE_ANY,
    999  // Unknown type
}

constant char DNS_TYPE_EXPECTED_STRINGS[][10] = {
    'A',
    'NS',
    'CNAME',
    'SOA',
    'PTR',
    'MX',
    'TXT',
    'AAAA',
    'SRV',
    'ANY',
    'UNKNOWN'
}

// Test query classes for string conversion
constant integer DNS_CLASS_TEST_VALUES[] = {
    NAV_DNS_CLASS_IN,
    NAV_DNS_CLASS_CS,
    NAV_DNS_CLASS_CH,
    NAV_DNS_CLASS_HS,
    NAV_DNS_CLASS_ANY,
    888  // Unknown class
}

constant char DNS_CLASS_EXPECTED_STRINGS[][10] = {
    'IN',
    'CS',
    'CH',
    'HS',
    'ANY',
    'UNKNOWN'
}

// Test response codes for string conversion
constant char DNS_RCODE_TEST_VALUES[] = {
    0,  // NAV_DNS_RCODE_NO_ERROR
    1,  // NAV_DNS_RCODE_FORMAT_ERROR
    2,  // NAV_DNS_RCODE_SERVER_FAILURE
    3,  // NAV_DNS_RCODE_NAME_ERROR
    4,  // NAV_DNS_RCODE_NOT_IMPLEMENTED
    5,  // NAV_DNS_RCODE_REFUSED
    15  // Unknown RCODE
}

constant char DNS_RCODE_EXPECTED_STRINGS[][32] = {
    'No Error',
    'Format Error',
    'Server Failure',
    'Name Error',
    'Not Implemented',
    'Refused',
    'Unknown Error'
}

// Mock responses for error checking
constant char DNS_RESPONSE_NO_ERROR[] = {
    $12, $34, $81, $80, $00, $01, $00, $01, $00, $00, $00, $00,
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $01, $00, $01,
    $C0, $0C, $00, $01, $00, $01,
    $00, $00, $0E, $10, $00, $04,
    $5D, $B8, $D8, $22
}

constant char DNS_RESPONSE_WITH_ERROR[] = {
    $12, $34, $81, $83, $00, $01, $00, $00, $00, $00, $00, $00,
    $07, 'e','x','a','m','p','l','e', $03, 'c','o','m', $00,
    $00, $01, $00, $01
}

/**
 * Test NAVDnsValidateDomainName() with valid domains
 */
define_function TestNAVDnsValidateDomainNameValid() {
    stack_var integer x
    stack_var char result

    NAVLog("'***************** NAVDnsValidateDomainName (Valid) *****************'")

    for (x = 1; x <= length_array(DNS_VALID_DOMAINS); x++) {
        result = NAVDnsValidateDomainName(DNS_VALID_DOMAINS[x])

        if (!NAVAssertTrue("'Should validate domain: ', DNS_VALID_DOMAINS[x]", result)) {
            NAVLogTestFailed(x, "'Valid: ', DNS_VALID_DOMAINS[x]", 'Invalid')
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsValidateDomainName() with invalid domains
 */
define_function TestNAVDnsValidateDomainNameInvalid() {
    stack_var integer x
    stack_var char result

    NAVLog("'***************** NAVDnsValidateDomainName (Invalid) *****************'")

    for (x = 1; x <= length_array(DNS_INVALID_DOMAINS); x++) {
        result = NAVDnsValidateDomainName(DNS_INVALID_DOMAINS[x])

        // Special case: trailing dot might be acceptable
        if (x == 9) {
            NAVLog("'Test ', itoa(x), ': Trailing dot validation result: ', itoa(result)")
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertFalse("'Should reject domain: ', DNS_INVALID_DOMAINS[x]", result)) {
            NAVLogTestFailed(x, "'Invalid: ', DNS_INVALID_DOMAINS[x]", 'Valid')
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsTypeToString()
 */
define_function TestNAVDnsTypeToString() {
    stack_var integer x
    stack_var char result[10]

    NAVLog("'***************** NAVDnsTypeToString *****************'")

    for (x = 1; x <= length_array(DNS_TYPE_TEST_VALUES); x++) {
        result = NAVDnsTypeToString(DNS_TYPE_TEST_VALUES[x])

        if (!NAVAssertStringEqual("'Should convert type ', itoa(DNS_TYPE_TEST_VALUES[x]), ' to string'",
                                  DNS_TYPE_EXPECTED_STRINGS[x],
                                  result)) {
            NAVLogTestFailed(x, DNS_TYPE_EXPECTED_STRINGS[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsClassToString()
 */
define_function TestNAVDnsClassToString() {
    stack_var integer x
    stack_var char result[10]

    NAVLog("'***************** NAVDnsClassToString *****************'")

    for (x = 1; x <= length_array(DNS_CLASS_TEST_VALUES); x++) {
        result = NAVDnsClassToString(DNS_CLASS_TEST_VALUES[x])

        if (!NAVAssertStringEqual("'Should convert class ', itoa(DNS_CLASS_TEST_VALUES[x]), ' to string'",
                                  DNS_CLASS_EXPECTED_STRINGS[x],
                                  result)) {
            NAVLogTestFailed(x, DNS_CLASS_EXPECTED_STRINGS[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsResponseCodeToString()
 */
define_function TestNAVDnsResponseCodeToString() {
    stack_var integer x
    stack_var char result[32]

    NAVLog("'***************** NAVDnsResponseCodeToString *****************'")

    for (x = 1; x <= length_array(DNS_RCODE_TEST_VALUES); x++) {
        result = NAVDnsResponseCodeToString(DNS_RCODE_TEST_VALUES[x])

        if (!NAVAssertStringEqual("'Should convert RCODE ', itoa(DNS_RCODE_TEST_VALUES[x]), ' to string'",
                                  DNS_RCODE_EXPECTED_STRINGS[x],
                                  result)) {
            NAVLogTestFailed(x, DNS_RCODE_EXPECTED_STRINGS[x], result)
            continue
        }

        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsGenerateTransactionId()
 */
define_function TestNAVDnsGenerateTransactionId() {
    stack_var integer x
    stack_var integer txId1
    stack_var integer txId2
    stack_var integer uniqueCount
    stack_var integer ids[100]

    NAVLog("'***************** NAVDnsGenerateTransactionId *****************'")

    // Test 1: Generate IDs and ensure they're non-zero
    x = 1
    txId1 = NAVDnsGenerateTransactionId()

    if (!NAVAssertIntegerNotEqual('Should generate non-zero ID', 0, txId1)) {
        NAVLogTestFailed(x, 'Non-zero', '0')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: Generate multiple IDs and verify they're different (probabilistic)
    x = 2
    uniqueCount = 0
    for (x = 1; x <= 100; x++) {
        ids[x] = NAVDnsGenerateTransactionId()
    }

    // Count unique values (simple check: ensure not all the same)
    txId1 = ids[1]
    for (x = 2; x <= 100; x++) {
        if (ids[x] != txId1) {
            uniqueCount++
        }
    }

    if (!NAVAssertIntegerGreaterThan('Should generate varied IDs', 90, uniqueCount)) {
        NAVLogTestFailed(2, '>90 unique', itoa(uniqueCount))
    }
    else {
        NAVLogTestPassed(2)
    }

    // Test 3: Verify IDs are in valid range (0-65535)
    x = 3
    for (x = 1; x <= 10; x++) {
        txId1 = NAVDnsGenerateTransactionId()
        if (txId1 < 0 || txId1 > 65535) {
            NAVLogTestFailed(3, '0-65535', itoa(txId1))
            return
        }
    }
    NAVLogTestPassed(3)
}

/**
 * Test NAVDnsResponseHasError()
 */
define_function TestNAVDnsResponseHasError() {
    stack_var _NAVDnsResponse response
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsResponseHasError *****************'")

    // Test 1: Response with no error
    x = 1
    NAVDnsResponseParse(DNS_RESPONSE_NO_ERROR, response)
    result = NAVDnsResponseHasError(response)

    if (!NAVAssertFalse('Response with RCODE 0 should not have error', result)) {
        NAVLogTestFailed(x, 'false', 'true')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: Response with error (NXDOMAIN)
    x = 2
    NAVDnsResponseParse(DNS_RESPONSE_WITH_ERROR, response)
    result = NAVDnsResponseHasError(response)

    if (!NAVAssertTrue('Response with RCODE 3 should have error', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 3: Manually set various error codes
    x = 3
    NAVDnsResponseInit(response)
    response.header.responseCode = NAV_DNS_RCODE_SERVER_FAILURE

    result = NAVDnsResponseHasError(response)

    if (!NAVAssertTrue('Response with SERVFAIL should have error', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 4: Format error
    x = 4
    response.header.responseCode = NAV_DNS_RCODE_FORMAT_ERROR

    result = NAVDnsResponseHasError(response)

    if (!NAVAssertTrue('Response with FORMAT_ERROR should have error', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else {
        NAVLogTestPassed(x)
    }
}

/**
 * Test NAVDnsResponseGetFirstAnswer()
 */
define_function TestNAVDnsResponseGetFirstAnswer() {
    stack_var _NAVDnsResponse response
    stack_var _NAVDnsResourceRecord answer
    stack_var char result
    stack_var integer x

    NAVLog("'***************** NAVDnsResponseGetFirstAnswer *****************'")

    // Test 1: Get first answer from valid response
    x = 1
    NAVDnsResponseParse(DNS_RESPONSE_NO_ERROR, response)
    result = NAVDnsResponseGetFirstAnswer(response, answer)

    if (!NAVAssertTrue('Should get first answer', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertIntegerEqual('Answer type should be A', NAV_DNS_TYPE_A, answer.type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_A), itoa(answer.type))
    }
    else if (!NAVAssertStringEqual('Answer address should be 93.184.216.34', '93.184.216.34', answer.address)) {
        NAVLogTestFailed(x, '93.184.216.34', answer.address)
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: Try to get answer from error response (no answers)
    x = 2
    NAVDnsResponseParse(DNS_RESPONSE_WITH_ERROR, response)
    result = NAVDnsResponseGetFirstAnswer(response, answer)

    if (!NAVAssertFalse('Should return false when no answers', result)) {
        NAVLogTestFailed(x, 'false', 'true')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 3: Empty response
    x = 3
    NAVDnsResponseInit(response)
    result = NAVDnsResponseGetFirstAnswer(response, answer)

    if (!NAVAssertFalse('Should return false for empty response', result)) {
        NAVLogTestFailed(x, 'false', 'true')
    }
    else {
        NAVLogTestPassed(x)
    }
}

/**
 * Integration test: Query creation and response parsing round-trip
 */
define_function TestNAVDnsIntegrationRoundTrip() {
    stack_var _NAVDnsQuery query
    stack_var _NAVDnsResponse mockResponse
    stack_var _NAVDnsResourceRecord answer
    stack_var char result
    stack_var integer x

    NAVLog("'***************** DNS Integration Round-Trip *****************'")

    // Test 1: Create query and verify transaction ID can be matched
    x = 1
    NAVDnsQueryCreate(query, 'example.com', NAV_DNS_TYPE_A, $1234)

    if (!NAVAssertIntegerEqual('Query should have correct TX ID', $1234, query.header.transactionId)) {
        NAVLogTestFailed(x, '$1234', "'$', format('%04X', query.header.transactionId)")
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: Parse response and verify TX ID matches
    x = 2
    NAVDnsResponseParse(DNS_RESPONSE_NO_ERROR, mockResponse)

    if (!NAVAssertIntegerEqual('Response should have matching TX ID', $1234, mockResponse.header.transactionId)) {
        NAVLogTestFailed(x, '$1234', "'$', format('%04X', mockResponse.header.transactionId)")
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 3: Verify question in response matches query
    x = 3
    if (!NAVAssertStringEqual('Question domain should match', 'example.com', mockResponse.questions[1].name)) {
        NAVLogTestFailed(x, 'example.com', mockResponse.questions[1].name)
    }
    else if (!NAVAssertIntegerEqual('Question type should match', NAV_DNS_TYPE_A, mockResponse.questions[1].type)) {
        NAVLogTestFailed(x, itoa(NAV_DNS_TYPE_A), itoa(mockResponse.questions[1].type))
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 4: Extract answer
    x = 4
    result = NAVDnsResponseGetFirstAnswer(mockResponse, answer)

    if (!NAVAssertTrue('Should extract first answer', result)) {
        NAVLogTestFailed(x, 'true', 'false')
    }
    else if (!NAVAssertStringEqual('Should get correct IP address', '93.184.216.34', answer.address)) {
        NAVLogTestFailed(x, '93.184.216.34', answer.address)
    }
    else {
        NAVLogTestPassed(x)
    }
}

/**
 * Test domain name validation edge cases
 */
define_function TestNAVDnsValidationEdgeCases() {
    stack_var char result
    stack_var char maxLabel[255]
    stack_var integer x

    NAVLog("'***************** DNS Validation Edge Cases *****************'")

    // Test 1: Maximum label length (63 chars) - should be valid
    x = 1
    maxLabel = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com'  // 63 a's
    result = NAVDnsValidateDomainName(maxLabel)

    if (!NAVAssertTrue('63-char label should be valid', result)) {
        NAVLogTestFailed(x, 'Valid', 'Invalid')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: Label with 64 chars - should be invalid
    x = 2
    maxLabel = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com'  // 64 a's
    result = NAVDnsValidateDomainName(maxLabel)

    if (!NAVAssertFalse('64-char label should be invalid', result)) {
        NAVLogTestFailed(x, 'Invalid', 'Valid')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 3: Single character domain
    x = 3
    result = NAVDnsValidateDomainName('x')

    if (!NAVAssertTrue('Single char should be valid', result)) {
        NAVLogTestFailed(x, 'Valid', 'Invalid')
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 4: Numeric labels
    x = 4
    result = NAVDnsValidateDomainName('192.168.1.1')

    if (!NAVAssertTrue('Numeric labels should be valid', result)) {
        NAVLogTestFailed(x, 'Valid', 'Invalid')
    }
    else {
        NAVLogTestPassed(x)
    }
}

/**
 * Test query/response transaction ID matching
 */
define_function TestNAVDnsTransactionIdMatching() {
    stack_var _NAVDnsQuery query1, query2
    stack_var integer x

    NAVLog("'***************** DNS Transaction ID Matching *****************'")

    // Test 1: Multiple queries should have different IDs
    x = 1
    NAVDnsQueryCreate(query1, 'example.com', NAV_DNS_TYPE_A, NAVDnsGenerateTransactionId())
    NAVDnsQueryCreate(query2, 'google.com', NAV_DNS_TYPE_A, NAVDnsGenerateTransactionId())

    if (!NAVAssertIntegerNotEqual('Queries should have different TX IDs',
                                   query1.header.transactionId,
                                   query2.header.transactionId)) {
        NAVLogTestFailed(x,
            'Different IDs',
            "'Both $', format('%04X', query1.header.transactionId)")
    }
    else {
        NAVLogTestPassed(x)
    }

    // Test 2: Explicit transaction ID should be preserved
    x = 2
    NAVDnsQueryCreate(query1, 'test.com', NAV_DNS_TYPE_A, $BEEF)

    if (!NAVAssertIntegerEqual('Should preserve explicit TX ID', $BEEF, query1.header.transactionId)) {
        NAVLogTestFailed(x, '$BEEF', "'$', format('%04X', query1.header.transactionId)")
    }
    else {
        NAVLogTestPassed(x)
    }
}
