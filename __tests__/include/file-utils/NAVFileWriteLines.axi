PROGRAM_NAME='NAVFileWriteLines'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test cases for NAVFileWriteLines
constant char FILE_WRITE_LINES_TESTS[][255] = {
    '',                                  // Test 1: Empty path
    '/testwritelines/single.txt',        // Test 2: Single line
    '/testwritelines/multiple.txt',      // Test 3: Multiple lines (3)
    '/testwritelines/empty-array.txt',   // Test 4: Empty array
    '/testwritelines/overwrite.txt',     // Test 5: Overwrite existing
    '/testwritelines/special.txt',       // Test 6: Special characters
    '/testwritelines/unicode.txt',       // Test 7: Unicode content
    '/testwritelines/many.txt',          // Test 8: Many lines (50)
    '/testwritelines/empty-lines.txt',   // Test 9: Contains empty lines
    '/nonexistent/dir/file.txt'          // Test 10: Invalid path
}

constant slong FILE_WRITE_LINES_EXPECTED_RESULT[] = {
    -2,     // Test 1: NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
    0,      // Test 2: Success
    0,      // Test 3: Success
    0,      // Test 4: Success (creates empty file)
    0,      // Test 5: Success (overwrites)
    0,      // Test 6: Success
    0,      // Test 7: Success
    0,      // Test 8: Success
    0,      // Test 9: Success
    -2      // Test 10: NAV_FILE_ERROR_INVALID_FILE_PATH_OR_NAME
}

constant integer FILE_WRITE_LINES_EXPECTED_LINE_COUNT[] = {
    0,      // Test 1: N/A
    1,      // Test 2: 1 line
    3,      // Test 3: 3 lines
    0,      // Test 4: 0 lines (empty file)
    3,      // Test 5: 3 lines (overwrite replaces old content)
    3,      // Test 6: 3 lines
    2,      // Test 7: 2 lines
    50,     // Test 8: 50 lines
    5,      // Test 9: 5 lines (including 2 empty)
    0       // Test 10: N/A
}

DEFINE_VARIABLE

volatile char FILE_WRITE_LINES_SETUP_REQUIRED = false
volatile char FILE_WRITE_LINES_RUNTIME_DATA[10][50][NAV_MAX_BUFFER]

/**
 * Initialize test data
 */
define_function InitializeFileWriteLinesTestData() {
    stack_var integer i

    // Create test directory
    NAVDirectoryCreate('/testwritelines')

    // Test 2: Single line
    FILE_WRITE_LINES_RUNTIME_DATA[2][1] = 'This is a single line'
    set_length_array(FILE_WRITE_LINES_RUNTIME_DATA[2], 1)

    // Test 3: Multiple lines
    FILE_WRITE_LINES_RUNTIME_DATA[3][1] = 'First line'
    FILE_WRITE_LINES_RUNTIME_DATA[3][2] = 'Second line'
    FILE_WRITE_LINES_RUNTIME_DATA[3][3] = 'Third line'
    set_length_array(FILE_WRITE_LINES_RUNTIME_DATA[3], 3)

    // Test 4: Empty array
    set_length_array(FILE_WRITE_LINES_RUNTIME_DATA[4], 0)

    // Test 5: Content for overwrite test (will create initial file)
    FILE_WRITE_LINES_RUNTIME_DATA[5][1] = 'New line 1'
    FILE_WRITE_LINES_RUNTIME_DATA[5][2] = 'New line 2'
    FILE_WRITE_LINES_RUNTIME_DATA[5][3] = 'New line 3'
    set_length_array(FILE_WRITE_LINES_RUNTIME_DATA[5], 3)

    // Test 6: Special characters
    FILE_WRITE_LINES_RUNTIME_DATA[6][1] = 'Special: !@#$%^&*()'
    FILE_WRITE_LINES_RUNTIME_DATA[6][2] = 'Quotes: "double" and ''single'''
    FILE_WRITE_LINES_RUNTIME_DATA[6][3] = 'Symbols: <>=+-*/\'
    set_length_array(FILE_WRITE_LINES_RUNTIME_DATA[6], 3)

    // Test 7: Unicode content
    FILE_WRITE_LINES_RUNTIME_DATA[7][1] = 'Unicode: café résumé'
    FILE_WRITE_LINES_RUNTIME_DATA[7][2] = 'Données spéciales'
    set_length_array(FILE_WRITE_LINES_RUNTIME_DATA[7], 2)

    // Test 8: Many lines (50)
    for (i = 1; i <= 50; i++) {
        FILE_WRITE_LINES_RUNTIME_DATA[8][i] = "'Line ', itoa(i), ' of 50'"
    }
    set_length_array(FILE_WRITE_LINES_RUNTIME_DATA[8], 50)

    // Test 9: Empty lines mixed with content
    FILE_WRITE_LINES_RUNTIME_DATA[9][1] = 'First line'
    FILE_WRITE_LINES_RUNTIME_DATA[9][2] = ''  // Empty line
    FILE_WRITE_LINES_RUNTIME_DATA[9][3] = 'Third line'
    FILE_WRITE_LINES_RUNTIME_DATA[9][4] = ''  // Empty line
    FILE_WRITE_LINES_RUNTIME_DATA[9][5] = 'Fifth line'
    set_length_array(FILE_WRITE_LINES_RUNTIME_DATA[9], 5)

    // Test 10: Invalid path (no data needed)
    FILE_WRITE_LINES_RUNTIME_DATA[10][1] = 'Should fail'
    set_length_array(FILE_WRITE_LINES_RUNTIME_DATA[10], 1)

    FILE_WRITE_LINES_SETUP_REQUIRED = true
}

/**
 * Setup function called before each test
 */
define_function SetupFileWriteLinesTest(integer testIndex) {
    if (!FILE_WRITE_LINES_SETUP_REQUIRED) {
        InitializeFileWriteLinesTestData()
    }

    // Test 5: Create initial file to overwrite
    if (testIndex == 5) {
        NAVFileWriteLine(FILE_WRITE_LINES_TESTS[testIndex], 'Old content line 1')
        NAVFileAppendLine(FILE_WRITE_LINES_TESTS[testIndex], 'Old content line 2')
        NAVFileAppendLine(FILE_WRITE_LINES_TESTS[testIndex], 'Old content line 3')
        NAVFileAppendLine(FILE_WRITE_LINES_TESTS[testIndex], 'Old content line 4')
        NAVFileAppendLine(FILE_WRITE_LINES_TESTS[testIndex], 'Old content line 5')
    }
}

/**
 * Main test function
 */
define_function TestNAVFileWriteLines() {
    stack_var integer x
    stack_var slong result
    stack_var integer actualLineCount
    stack_var slong expectedResult

    NAVLog("'***************** NAVFileWriteLines *****************'")

    for (x = 1; x <= length_array(FILE_WRITE_LINES_TESTS); x++) {
        SetupFileWriteLinesTest(x)

        expectedResult = FILE_WRITE_LINES_EXPECTED_RESULT[x]

        // Execute function
        result = NAVFileWriteLines(FILE_WRITE_LINES_TESTS[x], FILE_WRITE_LINES_RUNTIME_DATA[x])

        // Verify result
        if (!NAVAssertSignedLongEqual('Should return expected result', expectedResult, result)) {
            NAVLogTestFailed(x, "itoa(expectedResult)", "itoa(result)")
            continue
        }

        // For successful writes, verify line count
        if (expectedResult == 0) {
            actualLineCount = CountLinesInFile(FILE_WRITE_LINES_TESTS[x])

            if (!NAVAssertIntegerEqual('Should write expected number of lines',
                                       FILE_WRITE_LINES_EXPECTED_LINE_COUNT[x],
                                       actualLineCount)) {
                NAVLogTestFailed(x,
                                "itoa(FILE_WRITE_LINES_EXPECTED_LINE_COUNT[x])",
                                "itoa(actualLineCount)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
