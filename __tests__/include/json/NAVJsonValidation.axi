PROGRAM_NAME='NAVJsonValidation'

#include 'NAVFoundation.Json.axi'


DEFINE_VARIABLE

volatile char JSON_VALIDATION_TEST[10][512]


define_function InitializeJsonValidationTestData() {
    // Test 1: Valid simple object
    JSON_VALIDATION_TEST[1] = '{"name":"test"}'

    // Test 2: Invalid - missing closing brace
    JSON_VALIDATION_TEST[2] = '{"name":"test"'

    // Test 3: Valid array
    JSON_VALIDATION_TEST[3] = '[1,2,3]'

    // Test 4: Invalid - missing closing bracket
    JSON_VALIDATION_TEST[4] = '[1,2,3'

    // Test 5: Invalid - missing colon
    JSON_VALIDATION_TEST[5] = '{"name""test"}'

    // Test 6: Invalid - trailing comma
    JSON_VALIDATION_TEST[6] = '{"name":"test",}'

    // Test 7: Valid nested structure
    JSON_VALIDATION_TEST[7] = '{"data":{"values":[1,2,3]}}'

    // Test 8: Invalid - unexpected character
    JSON_VALIDATION_TEST[8] = '{"name":test}'

    // Test 9: Empty object (valid)
    JSON_VALIDATION_TEST[9] = '{}'

    // Test 10: Invalid - comma instead of colon
    JSON_VALIDATION_TEST[10] = '{"name","test"}'

    set_length_array(JSON_VALIDATION_TEST, 10)
}


DEFINE_CONSTANT

// Expected validation results
constant char JSON_VALIDATION_EXPECTED_VALID[10] = {
    true,   // Test 1: Valid
    false,  // Test 2: Invalid - missing closing brace
    true,   // Test 3: Valid
    false,  // Test 4: Invalid - missing closing bracket
    false,  // Test 5: Invalid - missing colon
    false,  // Test 6: Invalid - trailing comma
    true,   // Test 7: Valid
    false,  // Test 8: Invalid - unexpected character
    true,   // Test 9: Valid
    false   // Test 10: Invalid - comma instead of colon
}

// Expected to have error message (inverse of valid)
constant char JSON_VALIDATION_EXPECTED_HAS_ERROR[10] = {
    false,  // Test 1: No error
    true,   // Test 2: Has error
    false,  // Test 3: No error
    true,   // Test 4: Has error
    true,   // Test 5: Has error
    true,   // Test 6: Has error
    false,  // Test 7: No error
    true,   // Test 8: Has error
    false,  // Test 9: No error
    true    // Test 10: Has error
}

// Expected error line numbers (0 means no error)
constant integer JSON_VALIDATION_EXPECTED_ERROR_LINE[10] = {
    0,  // Test 1: No error
    1,  // Test 2: Error on line 1
    0,  // Test 3: No error
    1,  // Test 4: Error on line 1
    1,  // Test 5: Error on line 1
    1,  // Test 6: Error on line 1
    0,  // Test 7: No error
    1,  // Test 8: Error on line 1
    0,  // Test 9: No error
    1   // Test 10: Error on line 1
}

// Expected error column numbers (0 means no error)
constant integer JSON_VALIDATION_EXPECTED_ERROR_COLUMN[10] = {
    0,   // Test 1: No error
    15,  // Test 2: Column 15 (missing brace)
    0,   // Test 3: No error
    7,   // Test 4: Column 7 (missing bracket)
    8,   // Test 5: Column 8 (missing colon)
    16,  // Test 6: Column 16 (trailing comma)
    0,   // Test 7: No error
    10,  // Test 8: Column 10 (unexpected character)
    0,   // Test 9: No error
    8    // Test 10: Column 8 (comma instead of colon)
}


define_function TestNAVJsonValidation() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVJsonValidation'")

    InitializeJsonValidationTestData()

    for (x = 1; x <= length_array(JSON_VALIDATION_TEST); x++) {
        stack_var _NAVJson json
        stack_var char isValid
        stack_var char errorMsg[256]
        stack_var integer errorLine
        stack_var integer errorColumn

        // Parse the JSON (will succeed or fail)
        NAVJsonParse(JSON_VALIDATION_TEST[x], json)

        // Test NAVJsonIsValid
        isValid = NAVJsonIsValid(json)
        if (!NAVAssertBooleanEqual('NAVJsonIsValid',
                                    JSON_VALIDATION_EXPECTED_VALID[x],
                                    isValid)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(JSON_VALIDATION_EXPECTED_VALID[x]),
                            NAVBooleanToString(isValid))
            continue
        }

        // Test NAVJsonGetError
        errorMsg = NAVJsonGetError(json)
        if (JSON_VALIDATION_EXPECTED_HAS_ERROR[x]) {
            if (length_array(errorMsg) == 0) {
                NAVLogTestFailed(x, 'Error message present', 'Error message empty')
                continue
            }
        }
        else {
            if (length_array(errorMsg) > 0) {
                NAVLogTestFailed(x, 'No error message', errorMsg)
                continue
            }
        }

        // Test NAVJsonGetErrorLine
        errorLine = NAVJsonGetErrorLine(json)
        if (!NAVAssertIntegerEqual('NAVJsonGetErrorLine',
                                    JSON_VALIDATION_EXPECTED_ERROR_LINE[x],
                                    errorLine)) {
            NAVLogTestFailed(x,
                            itoa(JSON_VALIDATION_EXPECTED_ERROR_LINE[x]),
                            itoa(errorLine))
            continue
        }

        // Test NAVJsonGetErrorColumn
        errorColumn = NAVJsonGetErrorColumn(json)
        if (!NAVAssertIntegerEqual('NAVJsonGetErrorColumn',
                                    JSON_VALIDATION_EXPECTED_ERROR_COLUMN[x],
                                    errorColumn)) {
            NAVLogTestFailed(x,
                            itoa(JSON_VALIDATION_EXPECTED_ERROR_COLUMN[x]),
                            itoa(errorColumn))
            continue
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVJsonValidation'")
}
