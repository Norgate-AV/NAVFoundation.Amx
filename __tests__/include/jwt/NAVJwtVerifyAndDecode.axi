PROGRAM_NAME='NAVJwtVerifyAndDecode'

DEFINE_CONSTANT

// Tokens for verify and decode tests (reusing verified tokens from Create tests)
constant char JWT_VERIFY_AND_DECODE_TEST_TOKENS[][NAV_JWT_MAX_TOKEN_LENGTH] = {
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.wy2x0PggFVbsBBSMKYNE2OwRzvGvZAn0kfzx0VT3VqQ',  // Test 1 from Create - HS256
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyMTIzIn0.7w8IDk7KV2rJ_JKsJXrGR5d5ypZBrJp1Z1CL6y-0ViU',  // Test 2 from Create - HS256
    'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqb2huLmRvZUBleGFtcGxlLmNvbSIsInJvbGUiOiJhZG1pbiIsInBlcm1pc3Npb25zIjpbInJlYWQiLCJ3cml0ZSIsImRlbGV0ZSJdLCJpYXQiOjE1MTYyMzkwMjJ9.rNdpOMrWSuLXkM-ZpDf5h105WbtNUJK8wDBJu-OtII22JCSUb6KwRlLYHfTIHsNCj1fFvuVsEW03jXz8npo-pA',  // Test 3 from Create - HS512
    'eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0Mzg0IiwibmFtZSI6IkhTMzg0IFRlc3QifQ.MrCpeBpIKrmKcj78okchRkWdnV-szd4Iwyb0q5_sGzjCjY1Kpzi2fKdXP5BAeDZG',  // Test 7 from Create - HS384
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.wy2x0PggFVbsBBSMKYNE2OwRzvGvZAn0kfzx0VT3VqQ',  // Valid token with wrong secret
    '',                                     // Empty token
    'invalid.token',                        // Malformed (only 2 parts)
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.tampered_signature' // Tampered signature
}

// Secrets for tests (matching Create test secrets)
constant char JWT_VERIFY_AND_DECODE_TEST_SECRETS[][128] = {
    'your-256-bit-secret-1234567890ab',                                                      // 32 bytes for HS256 - correct
    'your-256-bit-secret-1234567890ab',                                                      // 32 bytes for HS256 - correct
    'your-512-bit-secret-key-with-lots-of-entropy-and-more-padding-1234',                   // 64 bytes for HS512 - correct
    'your-384-bit-secret-key-with-good-entropy-1234567890',                                 // 48+ bytes for HS384 - correct
    'wrong-secret-that-should-not-match',                                                    // Wrong secret
    'your-256-bit-secret-1234567890ab',                                                      // Doesn't matter for empty
    'your-256-bit-secret-1234567890ab',                                                      // Doesn't matter for malformed
    'your-256-bit-secret-1234567890ab'                                                       // Correct secret but tampered
}

// Expected function return values
constant char JWT_VERIFY_AND_DECODE_EXPECTED_RESULT[] = {
    true,   // Valid token with correct secret
    true,   // Valid token with correct secret
    true,   // Valid token with correct secret
    true,   // Valid HS384 token with correct secret
    false,  // Valid token with wrong secret (decodes but verification fails)
    false,  // Empty token (decode fails)
    false,  // Malformed token (decode fails)
    false   // Tampered signature (decodes but verification fails)
}

// Expected isValid field values
constant char JWT_VERIFY_AND_DECODE_EXPECTED_IS_VALID[] = {
    true,   // Verified and valid
    true,   // Verified and valid
    true,   // Verified and valid
    true,   // Verified and valid HS384
    false,  // Wrong secret - signature invalid
    false,  // Empty token - decode failed
    false,  // Malformed - decode failed
    false   // Tampered - signature invalid
}

// Expected error codes
constant sinteger JWT_VERIFY_AND_DECODE_EXPECTED_ERRORS[] = {
    NAV_JWT_SUCCESS,
    NAV_JWT_SUCCESS,
    NAV_JWT_SUCCESS,
    NAV_JWT_SUCCESS,
    NAV_JWT_ERROR_INVALID_SIGNATURE,
    NAV_JWT_ERROR_EMPTY_TOKEN,
    NAV_JWT_ERROR_INVALID_FORMAT,
    NAV_JWT_ERROR_INVALID_SIGNATURE
}

// Expected decoded headers
constant char JWT_VERIFY_AND_DECODE_EXPECTED_HEADER[][255] = {
    '{"alg":"HS256","typ":"JWT"}',
    '{"alg":"HS256","typ":"JWT"}',
    '{"alg":"HS512","typ":"JWT"}',
    '{"alg":"HS384","typ":"JWT"}',
    '{"alg":"HS256","typ":"JWT"}',
    '',  // Empty token - no header
    '',  // Malformed - no header
    '{"alg":"HS256","typ":"JWT"}'
}

// Expected decoded payloads
constant char JWT_VERIFY_AND_DECODE_EXPECTED_PAYLOAD[][1024] = {
    '{"sub":"1234567890","name":"John Doe","iat":1516239022}',
    '{"sub":"user123"}',
    '{"sub":"1234567890","name":"John Doe","email":"john.doe@example.com","role":"admin","permissions":["read","write","delete"],"iat":1516239022}',
    '{"sub":"test384","name":"HS384 Test"}',
    '{"sub":"1234567890","name":"John Doe","iat":1516239022}',
    '',  // Empty token - no payload
    '',  // Malformed - no payload
    '{"sub":"1234567890","name":"John Doe","iat":1516239022}'
}

// Expected parsed algorithm values
constant char JWT_VERIFY_AND_DECODE_EXPECTED_ALG[][32] = {
    'HS256',
    'HS256',
    'HS512',
    'HS384',
    'HS256',
    '',  // Empty token
    '',  // Malformed
    'HS256'
}

// Expected parsed algorithm types
constant sinteger JWT_VERIFY_AND_DECODE_EXPECTED_ALG_TYPE[] = {
    NAV_JWT_ALG_TYPE_HS256,
    NAV_JWT_ALG_TYPE_HS256,
    NAV_JWT_ALG_TYPE_HS512,
    NAV_JWT_ALG_TYPE_HS384,
    NAV_JWT_ALG_TYPE_HS256,
    NAV_JWT_ALG_TYPE_UNKNOWN,  // Empty token
    NAV_JWT_ALG_TYPE_UNKNOWN,  // Malformed
    NAV_JWT_ALG_TYPE_HS256
}

define_function TestNAVJwtVerifyAndDecode() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVJwtVerifyAndDecode')

    for (x = 1; x <= length_array(JWT_VERIFY_AND_DECODE_TEST_TOKENS); x++) {
        stack_var _NAVJwtToken jwtToken
        stack_var char result

        result = NAVJwtVerifyAndDecode(JWT_VERIFY_AND_DECODE_TEST_TOKENS[x], JWT_VERIFY_AND_DECODE_TEST_SECRETS[x], jwtToken)

        // Assert function result
        if (!NAVAssertBooleanEqual('Should have expected result', JWT_VERIFY_AND_DECODE_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(JWT_VERIFY_AND_DECODE_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        // Assert isValid field
        if (!NAVAssertBooleanEqual('Should have expected isValid', JWT_VERIFY_AND_DECODE_EXPECTED_IS_VALID[x], jwtToken.isValid)) {
            NAVLogTestFailed(x, NAVBooleanToString(JWT_VERIFY_AND_DECODE_EXPECTED_IS_VALID[x]), NAVBooleanToString(jwtToken.isValid))
            continue
        }

        // Assert error code
        if (!NAVAssertSignedIntegerEqual('Should have expected error code', JWT_VERIFY_AND_DECODE_EXPECTED_ERRORS[x], jwtToken.errorCode)) {
            NAVLogTestFailed(x, NAVJwtGetErrorMessage(JWT_VERIFY_AND_DECODE_EXPECTED_ERRORS[x]), NAVJwtGetErrorMessage(jwtToken.errorCode))
            continue
        }

        // For successful results, assert decoded content
        if (JWT_VERIFY_AND_DECODE_EXPECTED_RESULT[x]) {
            // Assert decoded header
            if (!NAVAssertStringEqual('Should have expected decoded header', JWT_VERIFY_AND_DECODE_EXPECTED_HEADER[x], jwtToken.headerJson)) {
                NAVLogTestFailed(x, JWT_VERIFY_AND_DECODE_EXPECTED_HEADER[x], jwtToken.headerJson)
                continue
            }

            // Assert decoded payload
            if (!NAVAssertStringEqual('Should have expected decoded payload', JWT_VERIFY_AND_DECODE_EXPECTED_PAYLOAD[x], jwtToken.payloadJson)) {
                NAVLogTestFailed(x, JWT_VERIFY_AND_DECODE_EXPECTED_PAYLOAD[x], jwtToken.payloadJson)
                continue
            }

            // Assert parsed algorithm
            if (!NAVAssertStringEqual('Should have expected algorithm', JWT_VERIFY_AND_DECODE_EXPECTED_ALG[x], jwtToken.headerParsed.alg)) {
                NAVLogTestFailed(x, JWT_VERIFY_AND_DECODE_EXPECTED_ALG[x], jwtToken.headerParsed.alg)
                continue
            }

            // Assert parsed algorithm type
            if (!NAVAssertSignedIntegerEqual('Should have expected algorithm type', JWT_VERIFY_AND_DECODE_EXPECTED_ALG_TYPE[x], jwtToken.headerParsed.algType)) {
                NAVLogTestFailed(x, itoa(JWT_VERIFY_AND_DECODE_EXPECTED_ALG_TYPE[x]), itoa(jwtToken.headerParsed.algType))
                continue
            }

            // Assert signature field is populated
            if (!NAVAssertTrue('Should have signature populated', length_array(jwtToken.signature) > 0)) {
                NAVLogTestFailed(x, 'non-empty signature', 'empty signature')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVJwtVerifyAndDecode')
}
