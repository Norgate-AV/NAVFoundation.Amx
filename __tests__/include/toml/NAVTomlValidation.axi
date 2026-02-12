PROGRAM_NAME='NAVTomlValidation'

#include 'NAVFoundation.Toml.axi'


DEFINE_VARIABLE

volatile char TOML_VALIDATION_TEST[10][512]


define_function InitializeTomlValidationTestData() {
    // Test 1: Valid simple key-value
    TOML_VALIDATION_TEST[1] = 'name = "test"'

    // Test 2: Invalid - missing equals sign
    TOML_VALIDATION_TEST[2] = 'name "test"'

    // Test 3: Valid array
    TOML_VALIDATION_TEST[3] = 'items = [1, 2, 3]'

    // Test 4: Invalid - unclosed string
    TOML_VALIDATION_TEST[4] = 'text = "unclosed'

    // Test 5: Invalid - invalid escape sequence
    TOML_VALIDATION_TEST[5] = "'text = \"invalid ', 92, 'x escape\"'"

    // Test 6: Invalid - duplicate key in same table
    TOML_VALIDATION_TEST[6] = "'name = "first"', 13, 10, 'name = "second"'"

    // Test 7: Valid nested table
    TOML_VALIDATION_TEST[7] = "'[server]', 13, 10, 'host = "localhost"', 13, 10, 'port = 8080'"

    // Test 8: Invalid - table header after array of tables with same name
    TOML_VALIDATION_TEST[8] = "'[[products]]', 13, 10, 'name = "A"', 13, 10, '[products]', 13, 10, 'count = 1'"

    // Test 9: Valid inline table
    TOML_VALIDATION_TEST[9] = 'point = { x = 10, y = 20 }'

    // Test 10: Valid - newline in inline table (TOML 1.1.0)
    TOML_VALIDATION_TEST[10] = "'point = { x = 10,', 13, 10, 'y = 20 }'"

    set_length_array(TOML_VALIDATION_TEST, 10)
}


DEFINE_CONSTANT

// Expected validation results
constant char TOML_VALIDATION_EXPECTED_VALID[10] = {
    true,   // Test 1: Valid
    false,  // Test 2: Invalid - missing equals
    true,   // Test 3: Valid
    false,  // Test 4: Invalid - unclosed string
    false,  // Test 5: Invalid - invalid escape
    false,  // Test 6: Invalid - duplicate key
    true,   // Test 7: Valid
    false,  // Test 8: Invalid - table after array of tables
    true,   // Test 9: Valid
    true    // Test 10: Valid - newline in inline table (TOML 1.1.0)
}

// Expected to have error message (inverse of valid)
constant char TOML_VALIDATION_EXPECTED_HAS_ERROR[10] = {
    false,  // Test 1: No error
    true,   // Test 2: Has error
    false,  // Test 3: No error
    true,   // Test 4: Has error
    true,   // Test 5: Has error
    true,   // Test 6: Has error
    false,  // Test 7: No error
    true,   // Test 8: Has error
    false,  // Test 9: No error
    false   // Test 10: No error (TOML 1.1.0)
}

// Expected error line numbers (0 means no error or don't validate)
constant integer TOML_VALIDATION_EXPECTED_ERROR_LINE[10] = {
    0,  // Test 1: No error
    1,  // Test 2: Error on line 1
    0,  // Test 3: No error
    1,  // Test 4: Error on line 1
    1,  // Test 5: Error on line 1
    2,  // Test 6: Error on line 2 (duplicate key)
    0,  // Test 7: No error
    3,  // Test 8: Error on line 3 (table after array of tables)
    0,  // Test 9: No error
    0   // Test 10: No error (TOML 1.1.0)
}

// Expected error column numbers (0 means any column - don't validate)
constant integer TOML_VALIDATION_EXPECTED_ERROR_COLUMN[10] = {
    0,   // Test 1: No error
    0,   // Test 2: Any column
    0,   // Test 3: No error
    0,   // Test 4: Any column
    0,   // Test 5: Any column
    0,   // Test 6: Any column
    0,   // Test 7: No error
    0,   // Test 8: Any column
    0,   // Test 9: No error
    0    // Test 10: Any column
}


define_function TestNAVTomlValidation() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVTomlValidation'")

    InitializeTomlValidationTestData()

    for (x = 1; x <= length_array(TOML_VALIDATION_TEST); x++) {
        stack_var _NAVToml toml
        stack_var char isValid
        stack_var char errorMsg[256]
        stack_var integer errorLine
        stack_var integer errorColumn

        // Parse the TOML (will succeed or fail)
        isValid = NAVTomlParse(TOML_VALIDATION_TEST[x], toml)

        // Test parse result
        if (!NAVAssertBooleanEqual('NAVTomlParse',
                                    TOML_VALIDATION_EXPECTED_VALID[x],
                                    isValid)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(TOML_VALIDATION_EXPECTED_VALID[x]),
                            NAVBooleanToString(isValid))
            continue
        }

        // Test NAVTomlGetError
        errorMsg = NAVTomlGetError(toml)
        if (TOML_VALIDATION_EXPECTED_HAS_ERROR[x]) {
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

        // Test NAVTomlGetErrorLine (only validate if expected line > 0)
        errorLine = NAVTomlGetErrorLine(toml)
        if (TOML_VALIDATION_EXPECTED_ERROR_LINE[x] > 0) {
            if (!NAVAssertIntegerEqual('NAVTomlGetErrorLine',
                                        TOML_VALIDATION_EXPECTED_ERROR_LINE[x],
                                        errorLine)) {
                NAVLogTestFailed(x,
                                itoa(TOML_VALIDATION_EXPECTED_ERROR_LINE[x]),
                                itoa(errorLine))
                continue
            }
        }

        // Test NAVTomlGetErrorColumn (skip validation if expected column is 0)
        errorColumn = NAVTomlGetErrorColumn(toml)
        if (TOML_VALIDATION_EXPECTED_ERROR_COLUMN[x] > 0) {
            if (!NAVAssertIntegerEqual('NAVTomlGetErrorColumn',
                                        TOML_VALIDATION_EXPECTED_ERROR_COLUMN[x],
                                        errorColumn)) {
                NAVLogTestFailed(x,
                                itoa(TOML_VALIDATION_EXPECTED_ERROR_COLUMN[x]),
                                itoa(errorColumn))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVTomlValidation'")
}
