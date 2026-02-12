PROGRAM_NAME='NAVJwtVerify'

DEFINE_CONSTANT

// Tokens for verification tests (reusing verified tokens from Create tests)
constant char JWT_VERIFY_TEST_TOKENS[][NAV_JWT_MAX_TOKEN_LENGTH] = {
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.wy2x0PggFVbsBBSMKYNE2OwRzvGvZAn0kfzx0VT3VqQ',  // Test 1 from Create - HS256
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyMTIzIn0.7w8IDk7KV2rJ_JKsJXrGR5d5ypZBrJp1Z1CL6y-0ViU',  // Test 2 from Create - HS256
    'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqb2huLmRvZUBleGFtcGxlLmNvbSIsInJvbGUiOiJhZG1pbiIsInBlcm1pc3Npb25zIjpbInJlYWQiLCJ3cml0ZSIsImRlbGV0ZSJdLCJpYXQiOjE1MTYyMzkwMjJ9.rNdpOMrWSuLXkM-ZpDf5h105WbtNUJK8wDBJu-OtII22JCSUb6KwRlLYHfTIHsNCj1fFvuVsEW03jXz8npo-pA',  // Test 3 from Create - HS512
    'eyJhbGciOiJIUzM4NCIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0Mzg0IiwibmFtZSI6IkhTMzg0IFRlc3QifQ.MrCpeBpIKrmKcj78okchRkWdnV-szd4Iwyb0q5_sGzjCjY1Kpzi2fKdXP5BAeDZG',  // Test 7 from Create - HS384
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.wy2x0PggFVbsBBSMKYNE2OwRzvGvZAn0kfzx0VT3VqQ',  // Valid token with wrong secret
    '',                                     // Empty token (should fail)
    'invalid.token',                        // Only 2 parts (should fail)
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.tampered_signature' // Tampered signature (should fail)
}

// Secrets for verification tests (matching Create test secrets)
constant char JWT_VERIFY_TEST_SECRETS[][128] = {
    'your-256-bit-secret-1234567890ab',                                                      // 32 bytes for HS256 - correct
    'your-256-bit-secret-1234567890ab',                                                      // 32 bytes for HS256 - correct
    'your-512-bit-secret-key-with-lots-of-entropy-and-more-padding-1234',                   // 64 bytes for HS512 - correct
    'your-384-bit-secret-key-with-good-entropy-1234567890',                                 // 48+ bytes for HS384 - correct
    'wrong-secret-that-should-not-match',                                                    // Wrong secret (should fail)
    'your-256-bit-secret-1234567890ab',                                                      // Secret doesn't matter for empty token
    'your-256-bit-secret-1234567890ab',                                                      // Secret doesn't matter for malformed token
    'your-256-bit-secret-1234567890ab'                                                       // Correct secret but tampered signature
}

// Expected verification results
constant char JWT_VERIFY_EXPECTED_RESULT[] = {
    true,   // Valid token with correct secret
    true,   // Valid token with correct secret
    true,   // Valid token with correct secret
    true,   // Valid HS384 token with correct secret
    false,  // Valid token with wrong secret
    false,  // Empty token
    false,  // Malformed token
    false   // Tampered signature
}

define_function TestNAVJwtVerify() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVJwtVerify')

    for (x = 1; x <= length_array(JWT_VERIFY_TEST_TOKENS); x++) {
        stack_var char result

        result = NAVJwtVerify(JWT_VERIFY_TEST_TOKENS[x], JWT_VERIFY_TEST_SECRETS[x])

        if (!NAVAssertBooleanEqual('Should verify with expected result', result, JWT_VERIFY_EXPECTED_RESULT[x])) {
            NAVLogTestFailed(x, NAVBooleanToString(JWT_VERIFY_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!JWT_VERIFY_EXPECTED_RESULT[x]) {
            // If we expected failure, we can skip further checks
            NAVLogTestPassed(x)
            continue
        }

        // Other assertions here...

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVJwtVerify')
}
