PROGRAM_NAME='NAVJwtCreate'

DEFINE_CONSTANT

// Test payloads for creation tests
constant char JWT_CREATE_TEST_PAYLOADS[][1024] = {
    '{"sub":"1234567890","name":"John Doe","iat":1516239022}',     // Simple payload
    '{"sub":"user123"}',                                            // Minimal payload
    '{"sub":"1234567890","name":"John Doe","email":"john.doe@example.com","role":"admin","permissions":["read","write","delete"],"iat":1516239022}', // Complex
    '',                                                             // Empty (should fail)
    '{"exp":0}',                                                    // Zero timestamp
    '{"sub":"very_long_subject_string_with_lots_of_characters_to_test_boundary_conditions_in_the_jwt_implementation"}' // Long value
}

// Expected success/failure for create tests
constant char JWT_CREATE_TEST_EXPECTED_RESULT[] = {
    true,
    true,
    true,
    false,
    true,
    true
}

constant char JWT_CREATE_TEST_EXPECTED_HEADER[][255] = {
    '{"alg":"HS256","typ":"JWT"}',
    '{"alg":"HS256","typ":"JWT"}',
    '{"alg":"HS512","typ":"JWT"}',
    '{"alg":"HS256","typ":"JWT"}',
    '{"alg":"HS512","typ":"JWT"}',
    '{"alg":"HS256","typ":"JWT"}'
}

constant char JWT_CREATE_TEST_EXPECTED_TOKEN[][NAV_JWT_MAX_TOKEN_LENGTH] = {
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.wy2x0PggFVbsBBSMKYNE2OwRzvGvZAn0kfzx0VT3VqQ',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c2VyMTIzIn0.7w8IDk7KV2rJ_JKsJXrGR5d5ypZBrJp1Z1CL6y-0ViU',
    'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiZW1haWwiOiJqb2huLmRvZUBleGFtcGxlLmNvbSIsInJvbGUiOiJhZG1pbiIsInBlcm1pc3Npb25zIjpbInJlYWQiLCJ3cml0ZSIsImRlbGV0ZSJdLCJpYXQiOjE1MTYyMzkwMjJ9.rNdpOMrWSuLXkM-ZpDf5h105WbtNUJK8wDBJu-OtII22JCSUb6KwRlLYHfTIHsNCj1fFvuVsEW03jXz8npo-pA',
    '',
    'eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjB9.S2L6nE_7uhQhro2FiY-nx1o1c1mpdZ8Txy1zzI_KoKm-9O46rmSAmiUJFz8Ur9WFtiSJ88xqYuab_ecoiwEIYA',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ2ZXJ5X2xvbmdfc3ViamVjdF9zdHJpbmdfd2l0aF9sb3RzX29mX2NoYXJhY3RlcnNfdG9fdGVzdF9ib3VuZGFyeV9jb25kaXRpb25zX2luX3RoZV9qd3RfaW1wbGVtZW50YXRpb24ifQ.qLdhVATRZUtc7X9C9E1u0MFwnIkU5-5rOFBfO3COmes'
}

// Test algorithms for creation
constant char JWT_CREATE_TEST_ALGORITHMS[][32] = {
    'HS256',
    'HS256',
    'HS512',
    'HS256',
    'HS512',
    'HS256'
}

// Test secrets for creation (RFC 7518 compliant lengths)
constant char JWT_CREATE_TEST_SECRETS[][128] = {
    'your-256-bit-secret-1234567890ab',                                                      // 32 bytes for HS256
    'your-256-bit-secret-1234567890ab',                                                      // 32 bytes for HS256
    'your-512-bit-secret-key-with-lots-of-entropy-and-more-padding-1234',                   // 64 bytes for HS512
    'your-256-bit-secret-1234567890ab',                                                      // 32 bytes for HS256
    'your-512-bit-secret-key-with-lots-of-entropy-and-more-padding-1234',                   // 64 bytes for HS512
    'your-256-bit-secret-1234567890ab'                                                       // 32 bytes for HS256
}

define_function TestNAVJwtCreate() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVJwtCreate')

    for (x = 1; x <= length_array(JWT_CREATE_TEST_PAYLOADS); x++) {
        stack_var char token[NAV_JWT_MAX_TOKEN_LENGTH]
        stack_var char header[NAV_JWT_MAX_JSON_LENGTH]
        stack_var char result

        header = NAVJwtCreateHeader(JWT_CREATE_TEST_ALGORITHMS[x], NAV_JWT_TYP_JWT)

        // Need to assert header value!!!
        if (!NAVAssertStringEqual('Should have expected header', JWT_CREATE_TEST_EXPECTED_HEADER[x], header)) {
            NAVLogTestFailed(x, JWT_CREATE_TEST_EXPECTED_HEADER[x], header)
            continue
        }

        result = NAVJwtCreate(header, JWT_CREATE_TEST_PAYLOADS[x], JWT_CREATE_TEST_SECRETS[x], token)

        if (!NAVAssertBooleanEqual('Should have expected create result', JWT_CREATE_TEST_EXPECTED_RESULT[x], result)) {
            NAVLogTestFailed(x, NAVBooleanToString(JWT_CREATE_TEST_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!JWT_CREATE_TEST_EXPECTED_RESULT[x]) {
            // If we expected failure, we can skip further checks
            NAVLogTestPassed(x)
            continue
        }

        if (!NAVAssertStringEqual('Should have expected token', JWT_CREATE_TEST_EXPECTED_TOKEN[x], token)) {
            NAVLogTestFailed(x, JWT_CREATE_TEST_EXPECTED_TOKEN[x], token)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVJwtCreate')
}
