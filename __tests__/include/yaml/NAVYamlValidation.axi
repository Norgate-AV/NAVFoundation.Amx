PROGRAM_NAME='NAVYamlValidation'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_VALIDATION_TEST[10][512]


define_function InitializeYamlValidationTestData() {
    // Test 1: Valid simple mapping
    YAML_VALIDATION_TEST[1] = "'name: test'"

    // Test 2: Invalid - inconsistent indentation
    YAML_VALIDATION_TEST[2] = "'data:', 13, 10, '  items:', 13, 10, '   - 1'"

    // Test 3: Valid sequence
    YAML_VALIDATION_TEST[3] = "'- 1', 13, 10, '- 2', 13, 10, '- 3'"

    // Test 4: Invalid - mixing tabs and spaces (simulated with extra spaces)
    YAML_VALIDATION_TEST[4] = "'data:', 13, 10, '     value: test'"

    // Test 5: Invalid - colon without space
    YAML_VALIDATION_TEST[5] = "'name:test'"

    // Test 6: Invalid - sequence without proper dash spacing
    YAML_VALIDATION_TEST[6] = "'-item1', 13, 10, '- item2'"

    // Test 7: Valid nested structure
    YAML_VALIDATION_TEST[7] = "'data:', 13, 10, '  values:', 13, 10, '    - 1', 13, 10, '    - 2', 13, 10, '    - 3'"

    // Test 8: Invalid - unexpected character in flow sequence
    YAML_VALIDATION_TEST[8] = "'[1, 2, 3,,]'"

    // Test 9: Valid empty mapping
    YAML_VALIDATION_TEST[9] = "'{}'"

    // Test 10: Invalid - malformed flow mapping
    YAML_VALIDATION_TEST[10] = "'{name: test,}'"

    set_length_array(YAML_VALIDATION_TEST, 10)
}


DEFINE_CONSTANT

// Expected validation results
constant char YAML_VALIDATION_EXPECTED_VALID[10] = {
    true,   // Test 1: Valid
    false,  // Test 2: Invalid - inconsistent indentation
    true,   // Test 3: Valid
    false,  // Test 4: Invalid - odd indentation
    false,  // Test 5: Invalid - colon without space
    false,  // Test 6: Invalid - dash spacing issue
    true,   // Test 7: Valid
    false,  // Test 8: Invalid - double comma
    true,   // Test 9: Valid
    false   // Test 10: Invalid - trailing comma
}

// Expected to have error message (inverse of valid)
constant char YAML_VALIDATION_EXPECTED_HAS_ERROR[10] = {
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
constant integer YAML_VALIDATION_EXPECTED_ERROR_LINE[10] = {
    0,  // Test 1: No error
    3,  // Test 2: Error on line 3 (inconsistent indentation)
    0,  // Test 3: No error
    2,  // Test 4: Error on line 2 (odd indentation)
    1,  // Test 5: Error on line 1
    1,  // Test 6: Error on line 1
    0,  // Test 7: No error
    1,  // Test 8: Error on line 1
    0,  // Test 9: No error
    1   // Test 10: Error on line 1
}

// Expected error column numbers (0 means any column - don't validate)
constant integer YAML_VALIDATION_EXPECTED_ERROR_COLUMN[10] = {
    0,   // Test 1: No error
    0,   // Test 2: Any column (indentation error)
    0,   // Test 3: No error
    0,   // Test 4: Any column (indentation error)
    0,   // Test 5: Any column
    0,   // Test 6: Any column
    0,   // Test 7: No error
    0,   // Test 8: Any column
    0,   // Test 9: No error
    0    // Test 10: Any column
}


define_function TestNAVYamlValidation() {
    stack_var integer x

    NAVLogTestSuiteStart("'NAVYamlValidation'")

    InitializeYamlValidationTestData()

    for (x = 1; x <= length_array(YAML_VALIDATION_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var char isValid
        stack_var char errorMsg[256]
        stack_var integer errorLine
        stack_var integer errorColumn

        // Parse the YAML (will succeed or fail)
        isValid = NAVYamlParse(YAML_VALIDATION_TEST[x], yaml)

        // Test parse result
        if (!NAVAssertBooleanEqual('NAVYamlParse',
                                    YAML_VALIDATION_EXPECTED_VALID[x],
                                    isValid)) {
            NAVLogTestFailed(x,
                            NAVBooleanToString(YAML_VALIDATION_EXPECTED_VALID[x]),
                            NAVBooleanToString(isValid))
            continue
        }

        // Test NAVYamlGetError
        errorMsg = NAVYamlGetError(yaml)
        if (YAML_VALIDATION_EXPECTED_HAS_ERROR[x]) {
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

        // Test NAVYamlGetErrorLine
        errorLine = NAVYamlGetErrorLine(yaml)
        if (!NAVAssertIntegerEqual('NAVYamlGetErrorLine',
                                    YAML_VALIDATION_EXPECTED_ERROR_LINE[x],
                                    errorLine)) {
            NAVLogTestFailed(x,
                            itoa(YAML_VALIDATION_EXPECTED_ERROR_LINE[x]),
                            itoa(errorLine))
            continue
        }

        // Test NAVYamlGetErrorColumn (skip validation if expected column is 0)
        errorColumn = NAVYamlGetErrorColumn(yaml)
        if (YAML_VALIDATION_EXPECTED_ERROR_COLUMN[x] > 0) {
            if (!NAVAssertIntegerEqual('NAVYamlGetErrorColumn',
                                        YAML_VALIDATION_EXPECTED_ERROR_COLUMN[x],
                                        errorColumn)) {
                NAVLogTestFailed(x,
                                itoa(YAML_VALIDATION_EXPECTED_ERROR_COLUMN[x]),
                                itoa(errorColumn))
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlValidation'")
}

