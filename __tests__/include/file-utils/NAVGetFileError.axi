PROGRAM_NAME='NAVGetFileError'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVGetFileError
constant slong GET_FILE_ERROR_TEST_CODES[] = {
    0,                                                  // Test 1: Success (no error)
    1,                                                  // Test 2: Positive value (no error)
    NAV_FILE_ERROR_INVALID_FILE_HANDLE,                 // Test 3: -1
    NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME,           // Test 4: -2
    NAV_FILE_ERROR_INVALID_VALUE_SUPPLIED_FOR_IO_FLAG,  // Test 5: -3
    NAV_FILE_ERROR_INVALID_FILE_PATH,                   // Test 6: -4
    NAV_FILE_ERROR_DISK_IO_ERROR,                       // Test 7: -5
    NAV_FILE_ERROR_INVALID_PARAMETER,                   // Test 8: -6
    NAV_FILE_ERROR_FILE_ALREADY_CLOSED,                 // Test 9: -7
    NAV_FILE_ERROR_FILE_NAME_EXISTS,                    // Test 10: -8
    NAV_FILE_ERROR_EOF_END_OF_FILE_REACHED,             // Test 11: -9
    NAV_FILE_ERROR_BUFFER_TOO_SMALL,                    // Test 12: -11
    NAV_FILE_ERROR_DISK_FULL,                           // Test 13: -12
    NAV_FILE_ERROR_FILE_PATH_NOT_LOADED,                // Test 14: -13
    NAV_FILE_ERROR_MAXIMUM_NUMBER_OF_FILES_ARE_ALREADY_OPEN,  // Test 15: -14
    NAV_FILE_ERROR_INVALID_FILE_FORMAT,                 // Test 16: -15
    -100                                                // Test 17: Unknown error code
}

constant char GET_FILE_ERROR_EXPECTED_MESSAGES[][NAV_MAX_BUFFER] = {
    '',                                                 // Test 1: Success returns empty string
    '',                                                 // Test 2: Positive returns empty string
    'Invalid file handle',                              // Test 3: -1
    'Invalid file path or name',                        // Test 4: -2
    'Invalid value supplied for IOFlag',                // Test 5: -3
    'Invalid file path',                                // Test 6: -4
    'Disk I/O error',                                   // Test 7: -5
    'Invalid parameter (buffer length must be greater than zero)',  // Test 8: -6
    'File already closed',                              // Test 9: -7
    'File name exists',                                 // Test 10: -8
    'EOF (end-of-file) reached',                        // Test 11: -9
    'Buffer too small',                                 // Test 12: -11
    'Disk full',                                        // Test 13: -12
    'File path not loaded',                             // Test 14: -13
    'Maximum number of files are already open (max is 10)',  // Test 15: -14
    'Invalid file format',                              // Test 16: -15
    'Unknown error (-100)'                              // Test 17: Unknown error
}

constant char GET_FILE_ERROR_CHECK_TYPE[] = {
    1,      // Test 1: Check for empty string
    1,      // Test 2: Check for empty string
    2,      // Test 3: Check exact match
    2,      // Test 4: Check exact match
    2,      // Test 5: Check exact match
    2,      // Test 6: Check exact match
    2,      // Test 7: Check exact match
    2,      // Test 8: Check exact match
    2,      // Test 9: Check exact match
    2,      // Test 10: Check exact match
    2,      // Test 11: Check exact match
    2,      // Test 12: Check exact match
    2,      // Test 13: Check exact match
    2,      // Test 14: Check exact match
    2,      // Test 15: Check exact match
    2,      // Test 16: Check exact match
    2       // Test 17: Check exact match (unknown error with code)
}


DEFINE_VARIABLE

// Global variables for test data
volatile char GET_FILE_ERROR_SETUP_REQUIRED = false

/**
 * Initialize global test data arrays at runtime
 */
define_function InitializeGetFileErrorTestData() {
    GET_FILE_ERROR_SETUP_REQUIRED = true
}

define_function TestNAVGetFileError() {
    stack_var integer x
    stack_var slong errorCode
    stack_var char result[NAV_MAX_BUFFER]
    stack_var char expected[NAV_MAX_BUFFER]
    stack_var char checkType

    NAVLog("'***************** NAVGetFileError *****************'")

    InitializeGetFileErrorTestData()

    for (x = 1; x <= length_array(GET_FILE_ERROR_TEST_CODES); x++) {
        errorCode = GET_FILE_ERROR_TEST_CODES[x]
        expected = GET_FILE_ERROR_EXPECTED_MESSAGES[x]
        checkType = GET_FILE_ERROR_CHECK_TYPE[x]

        result = NAVGetFileError(errorCode)
        NAVLog("'Test ', itoa(x), ': NAVGetFileError(', itoa(errorCode), ') returned: ', result")

        // Check type 1: Should return empty string (success cases)
        if (checkType == 1) {
            if (!NAVAssertStringEqual('Should return empty string for non-error', expected, result)) {
                NAVLogTestFailed(x, 'empty string', result)
                continue
            }
        }
        // Check type 2: Should return exact error message
        else if (checkType == 2) {
            if (!NAVAssertStringEqual('Should return correct error message', expected, result)) {
                NAVLogTestFailed(x, expected, result)
                continue
            }
        }
        // Check type 3: Should contain "Unknown error"
        else if (checkType == 3) {
            if (!NAVAssertTrue('Should return unknown error message', NAVContains(result, 'Unknown error'))) {
                NAVLogTestFailed(x, 'contains "Unknown error"', result)
                continue
            }

            // Also verify it includes the error code
            if (!NAVAssertTrue('Should include error code in message', NAVContains(result, itoa(errorCode)))) {
                NAVLogTestFailed(x, "'contains ', itoa(errorCode)", result)
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
