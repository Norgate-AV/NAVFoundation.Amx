PROGRAM_NAME='NAVJwtDecode'

DEFINE_CONSTANT

// Tokens for decode tests (reusing verified tokens from Create tests)
constant char JWT_DECODE_TEST_TOKENS[][NAV_JWT_MAX_TOKEN_LENGTH] = {
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.wy2x0PggFVbsBBSMKYNE2OwRzvGvZAn0kfzx0VT3VqQ',  // Test 1 from Create
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyMTIzIn0.7w8IDk7KV2rJ_JKsJXrGR5d5ypZBrJp1Z1CL6y-0ViU',  // Test 2 from Create
    'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqb2huLmRvZUBleGFtcGxlLmNvbSIsInJvbGUiOiJhZG1pbiIsInBlcm1pc3Npb25zIjpbInJlYWQiLCJ3cml0ZSIsImRlbGV0ZSJdLCJpYXQiOjE1MTYyMzkwMjJ9.rNdpOMrWSuLXkM-ZpDf5h105WbtNUJK8wDBJu-OtII22JCSUb6KwRlLYHfTIHsNCj1fFvuVsEW03jXz8npo-pA',  // Test 3 from Create
    '',                                     // Empty
    'invalid.token',                        // Malformed (only 2 parts)
    'a.b.c'                                 // Invalid base64
}

// Expected decode results
constant char JWT_DECODE_EXPECTED_RESULT[] = {
    true,
    true,
    true,
    false,
    false,
    false
}

// Expected decoded headers
constant char JWT_DECODE_EXPECTED_HEADER[][255] = {
    '{"alg":"HS256","typ":"JWT"}',
    '{"alg":"HS256","typ":"JWT"}',
    '{"alg":"HS512","typ":"JWT"}',
    '',
    '',
    ''
}

// Expected decoded payloads
constant char JWT_DECODE_EXPECTED_PAYLOAD[][1024] = {
    '{"sub":"1234567890","name":"John Doe","iat":1516239022}',
    '{"sub":"user123"}',
    '{"sub":"1234567890","name":"John Doe","email":"john.doe@example.com","role":"admin","permissions":["read","write","delete"],"iat":1516239022}',
    '',
    '',
    ''
}

constant sinteger JWT_DECODE_EXPECTED_ERRORS[] = {
    NAV_JWT_SUCCESS,
    NAV_JWT_SUCCESS,
    NAV_JWT_SUCCESS,
    NAV_JWT_ERROR_EMPTY_TOKEN,
    NAV_JWT_ERROR_INVALID_FORMAT,
    NAV_JWT_ERROR_INVALID_HEADER
}

define_function TestNAVJwtDecode() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVJwtDecode')

    for (x = 1; x <= length_array(JWT_DECODE_TEST_TOKENS); x++) {
        stack_var _NAVJwtToken jwtToken
        stack_var char result
        stack_var char decodedHeader[NAV_JWT_MAX_JSON_LENGTH]
        stack_var char decodedPayload[NAV_JWT_MAX_JSON_LENGTH]

        result = NAVJwtDecode(JWT_DECODE_TEST_TOKENS[x], jwtToken)

        if (!NAVAssertBooleanEqual('Should decode with expected result', JWT_DECODE_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(JWT_DECODE_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!JWT_DECODE_EXPECTED_RESULT[x]) {
            // If we expected failure, assert the error code
            if (!NAVAssertSignedIntegerEqual('Should have expected error code', JWT_DECODE_EXPECTED_ERRORS[x], jwtToken.errorCode)) {
                NAVLogTestFailed(x, NAVJwtGetErrorMessage(JWT_DECODE_EXPECTED_ERRORS[x]), NAVJwtGetErrorMessage(jwtToken.errorCode))
                continue
            }

            NAVLogTestPassed(x)
            continue
        }

        // For successful decodes, assert header and payload match expected values
        decodedHeader = NAVBase64UrlDecode(jwtToken.header)
        if (!NAVAssertStringEqual('Should have expected decoded header', JWT_DECODE_EXPECTED_HEADER[x], decodedHeader)) {
            NAVLogTestFailed(x, JWT_DECODE_EXPECTED_HEADER[x], decodedHeader)
            continue
        }

        decodedPayload = NAVBase64UrlDecode(jwtToken.payload)
        if (!NAVAssertStringEqual('Should have expected decoded payload', JWT_DECODE_EXPECTED_PAYLOAD[x], decodedPayload)) {
            NAVLogTestFailed(x, JWT_DECODE_EXPECTED_PAYLOAD[x], decodedPayload)
            continue
        }

        // Assert signature field is populated for valid tokens
        if (!NAVAssertTrue('Should have signature populated', length_array(jwtToken.signature) > 0)) {
            NAVLogTestFailed(x, 'non-empty signature', 'empty signature')
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVJwtDecode')
}
