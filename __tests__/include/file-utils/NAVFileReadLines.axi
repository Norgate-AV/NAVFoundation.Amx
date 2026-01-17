PROGRAM_NAME='NAVFileReadLines'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileReadLines
constant char FILE_READ_LINES_TESTS[][255] = {
    '',                                   // Test 1: Empty path
    '/testreadlines/empty.txt',           // Test 2: Empty file
    '/testreadlines/single.txt',          // Test 3: Single line
    '/testreadlines/multiple.txt',        // Test 4: Multiple lines
    '/testreadlines/crlf.txt',            // Test 5: CRLF line endings
    '/testreadlines/lf.txt',              // Test 6: LF line endings
    '/testreadlines/mixed-endings.txt',   // Test 7: Mixed line endings
    '/testreadlines/empty-lines.txt',     // Test 8: Empty lines
    '/testreadlines/many.txt',            // Test 9: Many lines (100)
    '/testreadlines/long-lines.txt',      // Test 10: Long lines
    '/testreadlines/overflow.txt',        // Test 11: More lines than array capacity
    '/testreadlines/nonexistent.txt'      // Test 12: Non-existent file
}

constant slong FILE_READ_LINES_EXPECTED_RESULT[] = {
    -2,     // Test 1: NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: 0 lines
    1,      // Test 3: 1 line
    5,      // Test 4: 5 lines
    3,      // Test 5: 3 lines
    3,      // Test 6: 3 lines
    4,      // Test 7: 4 lines
    5,      // Test 8: 5 lines (2 empty)
    10,     // Test 9: 10 lines (limited by array capacity)
    3,      // Test 10: 3 lines
    10,     // Test 11: 10 lines (limited by array capacity)
    -2      // Test 12: NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
}

constant char FILE_READ_LINES_EXPECTED_CONTENT[12][10][NAV_MAX_BUFFER] = {
    // Test 1: Empty path (N/A)
    {
        ''
    },
    // Test 2: Empty file (N/A)
    {
        ''
    },
    // Test 3: Single line
    {
        'This is a single line'
    },
    // Test 4: Multiple lines (5)
    {
        'Line 1',
        'Line 2',
        'Line 3',
        'Line 4',
        'Line 5'
    },
    // Test 5: CRLF line endings
    {
        'First line',
        'Second line',
        'Third line'
    },
    // Test 6: LF line endings
    {
        'First line',
        'Second line',
        'Third line'
    },
    // Test 7: Mixed endings (CRLF and LF)
    {
        'Line with CRLF',
        'Line with LF',
        'Line with CRLF',
        'Line with LF'
    },
    // Test 8: Empty lines
    {
        'Content line 1',
        '',
        'Content line 2',
        '',
        'Content line 3'
    },
    // Test 9: Many lines - verify first 3
    {
        'Line 1 of 100',
        'Line 2 of 100',
        'Line 3 of 100'
    },
    // Test 10: Long lines
    {
        'This is a very long line that contains quite a bit of text to test the handling of longer content within the file reading functionality and ensuring buffer sizes are adequate',
        'Another long line with different content to verify that multiple long lines can be processed correctly without issues or truncation problems',
        'Final long line to complete the test case'
    },
    // Test 11: Overflow - verify first 3 of 10 capacity
    {
        'Overflow line 1',
        'Overflow line 2',
        'Overflow line 3'
    },
    // Test 12: Non-existent (N/A)
    {
        ''
    }
}

DEFINE_VARIABLE

volatile char FILE_READ_LINES_SETUP_REQUIRED = false

/**
 * Initialize test data and create test files
 */
define_function InitializeFileReadLinesTestData() {
    stack_var integer i
    stack_var long handle
    stack_var slong result
    stack_var char buffer[NAV_MAX_BUFFER]

    // Create test directory
    NAVDirectoryCreate('/testreadlines')

    // Test 2: Empty file
    NAVFileWrite(FILE_READ_LINES_TESTS[2], '')

    // Test 3: Single line
    NAVFileWriteLine(FILE_READ_LINES_TESTS[3], 'This is a single line')

    // Test 4: Multiple lines (5)
    result = NAVFileOpen(FILE_READ_LINES_TESTS[4], 'rw')
    handle = type_cast(result)
    NAVFileWriteLineHandle(handle, 'Line 1')
    NAVFileWriteLineHandle(handle, 'Line 2')
    NAVFileWriteLineHandle(handle, 'Line 3')
    NAVFileWriteLineHandle(handle, 'Line 4')
    NAVFileWriteLineHandle(handle, 'Line 5')
    NAVFileClose(handle)

    // Test 5: CRLF line endings (explicit)
    result = NAVFileOpen(FILE_READ_LINES_TESTS[5], 'rw')
    handle = type_cast(result)
    NAVFileWriteLineHandle(handle, 'First line')
    NAVFileWriteLineHandle(handle, 'Second line')
    NAVFileWriteLineHandle(handle, 'Third line')
    NAVFileClose(handle)

    // Test 6: LF line endings (write manually with only LF)
    result = NAVFileOpen(FILE_READ_LINES_TESTS[6], 'rw')
    handle = type_cast(result)
    buffer = "'First line', $0A, 'Second line', $0A, 'Third line', $0A"
    file_write(handle, buffer, length_array(buffer))
    NAVFileClose(handle)

    // Test 7: Mixed line endings (CRLF and LF)
    result = NAVFileOpen(FILE_READ_LINES_TESTS[7], 'rw')
    handle = type_cast(result)
    buffer = "'Line with CRLF', $0D, $0A, 'Line with LF', $0A, 'Line with CRLF', $0D, $0A, 'Line with LF', $0A"
    file_write(handle, buffer, length_array(buffer))
    NAVFileClose(handle)

    // Test 8: Empty lines mixed with content
    result = NAVFileOpen(FILE_READ_LINES_TESTS[8], 'rw')
    handle = type_cast(result)
    NAVFileWriteLineHandle(handle, 'Content line 1')
    NAVFileWriteLineHandle(handle, '')
    NAVFileWriteLineHandle(handle, 'Content line 2')
    NAVFileWriteLineHandle(handle, '')
    NAVFileWriteLineHandle(handle, 'Content line 3')
    NAVFileClose(handle)

    // Test 9: Many lines (100)
    result = NAVFileOpen(FILE_READ_LINES_TESTS[9], 'rw')
    handle = type_cast(result)
    for (i = 1; i <= 100; i++) {
        NAVFileWriteLineHandle(handle, "'Line ', itoa(i), ' of 100'")
    }
    NAVFileClose(handle)

    // Test 10: Long lines (3 lines with 150+ characters each)
    result = NAVFileOpen(FILE_READ_LINES_TESTS[10], 'rw')
    handle = type_cast(result)
    NAVFileWriteLineHandle(handle, 'This is a very long line that contains quite a bit of text to test the handling of longer content within the file reading functionality and ensuring buffer sizes are adequate')
    NAVFileWriteLineHandle(handle, 'Another long line with different content to verify that multiple long lines can be processed correctly without issues or truncation problems')
    NAVFileWriteLineHandle(handle, 'Final long line to complete the test case')
    NAVFileClose(handle)

    // Test 11: More lines than array capacity (20 lines, array capacity 10)
    result = NAVFileOpen(FILE_READ_LINES_TESTS[11], 'rw')
    handle = type_cast(result)
    for (i = 1; i <= 20; i++) {
        NAVFileWriteLineHandle(handle, "'Overflow line ', itoa(i)")
    }
    NAVFileClose(handle)

    // Test 12: Non-existent file (don't create)

    FILE_READ_LINES_SETUP_REQUIRED = true
}

/**
 * Setup function called before tests
 */
define_function SetupFileReadLinesTest() {
    if (!FILE_READ_LINES_SETUP_REQUIRED) {
        InitializeFileReadLinesTestData()
    }
}

/**
 * Main test function
 */
define_function TestNAVFileReadLines() {
    stack_var integer x
    stack_var slong result
    stack_var char readLines[10][NAV_MAX_BUFFER]  // Limited capacity for overflow test
    stack_var integer i
    stack_var char pass

    NAVLog("'***************** NAVFileReadLines *****************'")

    SetupFileReadLinesTest()

    for (x = 1; x <= length_array(FILE_READ_LINES_TESTS); x++) {
        // Clear array for each test
        for (i = 1; i <= max_length_array(readLines); i++) {
            readLines[i] = ''
        }
        set_length_array(readLines, 0)

        // Execute function
        result = NAVFileReadLines(FILE_READ_LINES_TESTS[x], readLines)

        // Verify result
        if (!NAVAssertSignedLongEqual('Should return expected line count',
                                      FILE_READ_LINES_EXPECTED_RESULT[x],
                                      result)) {
            NAVLogTestFailed(x, "itoa(FILE_READ_LINES_EXPECTED_RESULT[x])", "itoa(result)")
            continue
        }

        // For successful reads, verify content (where applicable)
        pass = true
        if (result > 0) {
            select {
                active (x == 3):  // Single line
                    pass = NAVAssertStringEqual('Should read correct content',
                                               FILE_READ_LINES_EXPECTED_CONTENT[x][1],
                                               readLines[1])

                active (x == 4):  // Multiple lines - verify all 5
                    for (i = 1; i <= 5; i++) {
                        if (!NAVAssertStringEqual("'Line ', itoa(i), ' should match'",
                                                  FILE_READ_LINES_EXPECTED_CONTENT[x][i],
                                                  readLines[i])) {
                            pass = false
                            break
                        }
                    }

                active (x == 5 || x == 6):  // CRLF or LF endings - verify all 3
                    for (i = 1; i <= 3; i++) {
                        if (!NAVAssertStringEqual("'Line ', itoa(i), ' should match'",
                                                  FILE_READ_LINES_EXPECTED_CONTENT[x][i],
                                                  readLines[i])) {
                            pass = false
                            break
                        }
                    }

                active (x == 7):  // Mixed endings - verify all 4
                    for (i = 1; i <= 4; i++) {
                        if (!NAVAssertStringEqual("'Line ', itoa(i), ' should match'",
                                                  FILE_READ_LINES_EXPECTED_CONTENT[x][i],
                                                  readLines[i])) {
                            pass = false
                            break
                        }
                    }

                active (x == 8):  // Empty lines - verify all 5
                    for (i = 1; i <= 5; i++) {
                        if (!NAVAssertStringEqual("'Line ', itoa(i), ' should match'",
                                                  FILE_READ_LINES_EXPECTED_CONTENT[x][i],
                                                  readLines[i])) {
                            pass = false
                            break
                        }
                    }

                active (x == 9):  // Many lines - verify first 3
                    for (i = 1; i <= 3; i++) {
                        if (!NAVAssertStringEqual("'Line ', itoa(i), ' should match'",
                                                  FILE_READ_LINES_EXPECTED_CONTENT[x][i],
                                                  readLines[i])) {
                            pass = false
                            break
                        }
                    }

                active (x == 10):  // Long lines - verify all 3
                    for (i = 1; i <= 3; i++) {
                        if (!NAVAssertStringEqual("'Line ', itoa(i), ' should match'",
                                                  FILE_READ_LINES_EXPECTED_CONTENT[x][i],
                                                  readLines[i])) {
                            pass = false
                            break
                        }
                    }

                active (x == 11):  // Overflow - verify first 3 of 10 capacity
                    for (i = 1; i <= 3; i++) {
                        if (!NAVAssertStringEqual("'Line ', itoa(i), ' should match'",
                                                  FILE_READ_LINES_EXPECTED_CONTENT[x][i],
                                                  readLines[i])) {
                            pass = false
                            break
                        }
                    }
            }
        }

        if (!pass) {
            NAVLogTestFailed(x, "'Content should match'", "'Content mismatch'")
            continue
        }

        NAVLogTestPassed(x)
    }
}
