PROGRAM_NAME='NAVJwtTimeValidation'

DEFINE_CONSTANT

// Payloads for time validation
constant char JWT_TIME_VALIDATION_PAYLOADS[][512] = {
    '{"sub":"user123"}',                                                    // No time claims (should succeed)
    '{"sub":"user123","exp":1516242622}',                                  // Valid exp
    '{"sub":"user123","exp":1516235422}',                                  // Expired
    '{"sub":"user123","nbf":1516235422}',                                  // Valid nbf
    '{"sub":"user123","nbf":1516242622}',                                  // Not yet valid
    '{"sub":"user123","exp":1516242622,"nbf":1516235422}',                // Both valid
    '{"sub":"user123","exp":1516235423}',                                  // Expired (with skew should succeed)
    '{"sub":"user123","nbf":1516242621}'                                   // Not yet (with skew should succeed)
}

// Current time for validation tests
constant slong JWT_TIME_VALIDATION_CURRENT_TIMES[] = {
    1516239022,     // Current time
    1516239022,     // Before expiry
    1516239022,     // After expiry
    1516239022,     // After nbf
    1516239022,     // Before nbf
    1516239022,     // Between nbf and exp
    1516239022,     // Just expired
    1516239022      // Just before nbf
}

// Clock skew for validation tests
constant integer JWT_TIME_VALIDATION_CLOCK_SKEWS[] = {
    0,
    0,
    0,
    0,
    0,
    0,
    3600,
    3600
}

// Expected time validation results
constant char JWT_TIME_VALIDATION_EXPECTED_RESULT[] = {
    true,
    true,
    false,
    true,
    false,
    true,
    true,
    true
}

define_function TestNAVJwtTimeValidation() {
    stack_var integer x

    NAVLogTestSuiteStart('NAVJwtTimeValidation')

    for (x = 1; x <= length_array(JWT_TIME_VALIDATION_PAYLOADS); x++) {
        stack_var char result

        result = NAVJwtValidateTime(JWT_TIME_VALIDATION_PAYLOADS[x], JWT_TIME_VALIDATION_CURRENT_TIMES[x], JWT_TIME_VALIDATION_CLOCK_SKEWS[x])

        if (!NAVAssertBooleanEqual('Should validate time with expected result', result, JWT_TIME_VALIDATION_EXPECTED_RESULT[x])) {
            NAVLogTestFailed(x, NAVBooleanToString(JWT_TIME_VALIDATION_EXPECTED_RESULT[x]), NAVBooleanToString(result))
            continue
        }

        if (!JWT_TIME_VALIDATION_EXPECTED_RESULT[x]) {
            // If we expected failure, we can skip further checks
            NAVLogTestPassed(x)
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd('NAVJwtTimeValidation')
}
