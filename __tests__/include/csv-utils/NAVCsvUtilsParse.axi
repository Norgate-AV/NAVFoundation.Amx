/**
 * Tests for NAVFoundation High-Level CsvParse Function
 *
 * This test suite validates the high-level convenience function
 * NAVCsvParse() which combines lexer and parser operations.
 */

define_function TestNAVCsvUtilsParse() {
    NAVLog("'***************** NAVCsvUtilsParse *****************'")

    // Test 1: Basic parsing - simple CSV
    TestCsvParseBasic()

    // Test 2: Empty data input
    TestCsvParseEmptyData()

    // Test 3: Multi-row CSV
    TestCsvParseMultipleRows()

    // Test 4: CSV with quoted fields
    TestCsvParseQuotedFields()

    // Test 5: CSV with empty fields
    TestCsvParseEmptyFields()

    // Test 6: CSV with escaped quotes (RFC 4180)
    TestCsvParseEscapedQuotes()

    // Test 7: CSV with backslash escapes (extension)
    TestCsvParseBackslashEscapes()

    // Test 8: Real-world scenario - header + data rows
    TestCsvParseRealWorld()

    // Test 9: Single field CSV
    TestCsvParseSingleField()

    // Test 10: CSV with trailing comma
    TestCsvParseTrailingComma()
}

define_function TestCsvParseBasic() {
    stack_var char data[1024]
    stack_var char csv[10][10][255]
    stack_var char result

    data = 'a,b,c'
    result = NAVCsvParse(data, csv)

    if (!result) {
        NAVLogTestFailed(1, 'parsing should succeed', 'failed')
    } else if (csv[1][1] != 'a') {
        NAVLogTestFailed(1, 'csv[1][1] should be "a"', csv[1][1])
    } else if (csv[1][2] != 'b') {
        NAVLogTestFailed(1, 'csv[1][2] should be "b"', csv[1][2])
    } else if (csv[1][3] != 'c') {
        NAVLogTestFailed(1, 'csv[1][3] should be "c"', csv[1][3])
    } else if (length_array(csv) != 1) {
        NAVLogTestFailed(1, '1 row expected', itoa(length_array(csv)))
    } else if (length_array(csv[1]) != 3) {
        NAVLogTestFailed(1, '3 columns expected', itoa(length_array(csv[1])))
    } else {
        NAVLogTestPassed(1)
    }
}

define_function TestCsvParseEmptyData() {
    stack_var char data[1024]
    stack_var char csv[10][10][255]
    stack_var char result

    data = ''
    result = NAVCsvParse(data, csv)

    if (result) {
        NAVLogTestFailed(2, 'parsing empty data should fail', 'succeeded')
    } else {
        NAVLogTestPassed(2)
    }
}

define_function TestCsvParseMultipleRows() {
    stack_var char data[1024]
    stack_var char csv[10][10][255]
    stack_var char result

    data = "'a,b', NAV_LF, 'c,d'"
    result = NAVCsvParse(data, csv)

    if (!result) {
        NAVLogTestFailed(3, 'parsing should succeed', 'failed')
    } else if (csv[1][1] != 'a') {
        NAVLogTestFailed(3, 'csv[1][1] should be "a"', csv[1][1])
    } else if (csv[1][2] != 'b') {
        NAVLogTestFailed(3, 'csv[1][2] should be "b"', csv[1][2])
    } else if (csv[2][1] != 'c') {
        NAVLogTestFailed(3, 'csv[2][1] should be "c"', csv[2][1])
    } else if (csv[2][2] != 'd') {
        NAVLogTestFailed(3, 'csv[2][2] should be "d"', csv[2][2])
    } else if (length_array(csv) != 2) {
        NAVLogTestFailed(3, '2 rows expected', itoa(length_array(csv)))
    } else if (length_array(csv[1]) != 2) {
        NAVLogTestFailed(3, '2 columns expected', itoa(length_array(csv[1])))
    } else {
        NAVLogTestPassed(3)
    }
}

define_function TestCsvParseQuotedFields() {
    stack_var char data[1024]
    stack_var char csv[10][10][255]
    stack_var char result

    data = '"hello","world"'
    result = NAVCsvParse(data, csv)

    if (!result) {
        NAVLogTestFailed(4, 'parsing should succeed', 'failed')
    } else if (csv[1][1] != 'hello') {
        NAVLogTestFailed(4, 'csv[1][1] should be "hello"', csv[1][1])
    } else if (csv[1][2] != 'world') {
        NAVLogTestFailed(4, 'csv[1][2] should be "world"', csv[1][2])
    } else {
        NAVLogTestPassed(4)
    }
}

define_function TestCsvParseEmptyFields() {
    stack_var char data[1024]
    stack_var char csv[10][10][255]
    stack_var char result

    data = 'a,,c'
    result = NAVCsvParse(data, csv)

    if (!result) {
        NAVLogTestFailed(5, 'parsing should succeed', 'failed')
    } else if (csv[1][1] != 'a') {
        NAVLogTestFailed(5, 'csv[1][1] should be "a"', csv[1][1])
    } else if (csv[1][2] != '') {
        NAVLogTestFailed(5, 'csv[1][2] should be empty', csv[1][2])
    } else if (csv[1][3] != 'c') {
        NAVLogTestFailed(5, 'csv[1][3] should be "c"', csv[1][3])
    } else if (length_array(csv[1]) != 3) {
        NAVLogTestFailed(5, '3 columns expected', itoa(length_array(csv[1])))
    } else {
        NAVLogTestPassed(5)
    }
}

define_function TestCsvParseEscapedQuotes() {
    stack_var char data[1024]
    stack_var char csv[10][10][255]
    stack_var char result

    data = '"say ""hello"""'
    result = NAVCsvParse(data, csv)

    if (!result) {
        NAVLogTestFailed(6, 'parsing should succeed', 'failed')
    } else if (csv[1][1] != 'say "hello"') {
        NAVLogTestFailed(6, 'csv[1][1] should be "say "hello""', csv[1][1])
    } else {
        NAVLogTestPassed(6)
    }
}

define_function TestCsvParseBackslashEscapes() {
    stack_var char data[1024]
    stack_var char csv[10][10][255]
    stack_var char result

    data = '"line1\nline2"'
    result = NAVCsvParse(data, csv)

    if (!result) {
        NAVLogTestFailed(7, 'parsing should succeed', 'failed')
    } else if (csv[1][1] != "'line1', NAV_LF, 'line2'") {
        NAVLogTestFailed(7, 'csv[1][1] should contain newline', csv[1][1])
    } else {
        NAVLogTestPassed(7)
    }
}

define_function TestCsvParseRealWorld() {
    stack_var char data[2048]
    stack_var char csv[10][10][255]
    stack_var char result

    // Simulate real CSV data with header and data rows
    data = "'"Name","Age","City"', NAV_LF, '"Alice","30","New York"', NAV_LF, '"Bob","25","Los Angeles"'"
    result = NAVCsvParse(data, csv)

    if (!result) {
        NAVLogTestFailed(8, 'parsing should succeed', 'failed')
    } else if (csv[1][1] != 'Name') {
        NAVLogTestFailed(8, 'csv[1][1] should be "Name"', csv[1][1])
    } else if (csv[1][2] != 'Age') {
        NAVLogTestFailed(8, 'csv[1][2] should be "Age"', csv[1][2])
    } else if (csv[1][3] != 'City') {
        NAVLogTestFailed(8, 'csv[1][3] should be "City"', csv[1][3])
    } else if (csv[2][1] != 'Alice') {
        NAVLogTestFailed(8, 'csv[2][1] should be "Alice"', csv[2][1])
    } else if (csv[2][2] != '30') {
        NAVLogTestFailed(8, 'csv[2][2] should be "30"', csv[2][2])
    } else if (csv[2][3] != 'New York') {
        NAVLogTestFailed(8, 'csv[2][3] should be "New York"', csv[2][3])
    } else if (csv[3][1] != 'Bob') {
        NAVLogTestFailed(8, 'csv[3][1] should be "Bob"', csv[3][1])
    } else if (csv[3][2] != '25') {
        NAVLogTestFailed(8, 'csv[3][2] should be "25"', csv[3][2])
    } else if (csv[3][3] != 'Los Angeles') {
        NAVLogTestFailed(8, 'csv[3][3] should be "Los Angeles"', csv[3][3])
    } else if (length_array(csv) != 3) {
        NAVLogTestFailed(8, '3 rows expected', itoa(length_array(csv)))
    } else if (length_array(csv[1]) != 3) {
        NAVLogTestFailed(8, '3 columns expected', itoa(length_array(csv[1])))
    } else {
        NAVLogTestPassed(8)
    }
}

define_function TestCsvParseSingleField() {
    stack_var char data[1024]
    stack_var char csv[10][10][255]
    stack_var char result

    data = 'single'
    result = NAVCsvParse(data, csv)

    if (!result) {
        NAVLogTestFailed(9, 'parsing should succeed', 'failed')
    } else if (csv[1][1] != 'single') {
        NAVLogTestFailed(9, 'csv[1][1] should be "single"', csv[1][1])
    } else if (length_array(csv) != 1) {
        NAVLogTestFailed(9, '1 row expected', itoa(length_array(csv)))
    } else if (length_array(csv[1]) != 1) {
        NAVLogTestFailed(9, '1 column expected', itoa(length_array(csv[1])))
    } else {
        NAVLogTestPassed(9)
    }
}

define_function TestCsvParseTrailingComma() {
    stack_var char data[1024]
    stack_var char csv[10][10][255]
    stack_var char result

    data = 'a,b,'
    result = NAVCsvParse(data, csv)

    if (!result) {
        NAVLogTestFailed(10, 'parsing should succeed', 'failed')
    } else if (csv[1][1] != 'a') {
        NAVLogTestFailed(10, 'csv[1][1] should be "a"', csv[1][1])
    } else if (csv[1][2] != 'b') {
        NAVLogTestFailed(10, 'csv[1][2] should be "b"', csv[1][2])
    } else if (csv[1][3] != '') {
        NAVLogTestFailed(10, 'csv[1][3] should be empty', csv[1][3])
    } else if (length_array(csv[1]) != 3) {
        NAVLogTestFailed(10, '3 columns expected (including trailing empty)', itoa(length_array(csv[1])))
    } else {
        NAVLogTestPassed(10)
    }
}
