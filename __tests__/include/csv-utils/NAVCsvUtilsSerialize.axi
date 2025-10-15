/**
 * Tests for NAVFoundation High-Level CsvSerialize Function
 *
 * This test suite validates the high-level convenience function
 * NAVCsvSerialize() which converts 2D arrays to CSV strings.
 */

define_function TestNAVCsvUtilsSerialize() {
    NAVLog("'***************** NAVCsvUtilsSerialize *****************'")

    // Test 1: Basic serialization - simple data
    TestCsvSerializeBasic()

    // Test 2: Empty data input
    TestCsvSerializeEmptyData()

    // Test 3: Multi-row data
    TestCsvSerializeMultipleRows()

    // Test 4: Fields with commas (require quoting)
    TestCsvSerializeFieldsWithCommas()

    // Test 5: Fields with quotes (require escaping and quoting)
    TestCsvSerializeFieldsWithQuotes()

    // Test 6: Fields with newlines (require quoting)
    TestCsvSerializeFieldsWithNewlines()

    // Test 7: Empty fields
    TestCsvSerializeEmptyFields()

    // Test 8: Empty rows
    TestCsvSerializeEmptyRows()

    // Test 9: Real-world scenario - header + data
    TestCsvSerializeRealWorld()

    // Test 10: Single field
    TestCsvSerializeSingleField()

    // Test 11: Mixed - some fields need quoting, some don't
    TestCsvSerializeMixedQuoting()

    // Test 12: Round-trip test (serialize then parse)
    TestCsvSerializeRoundTrip()
}

define_function TestCsvSerializeBasic() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    data[1][1] = 'a'
    data[1][2] = 'b'
    data[1][3] = 'c'
    set_length_array(data, 1)  // Only 1 row
    set_length_array(data[1], 3)  // 3 fields in row 1

    success = NAVCsvSerialize(data, result)

    if (!success) {
        NAVLogTestFailed(1, 'serialization should succeed', 'failed')
    } else if (result != "'a,b,c', NAV_CR, NAV_LF") {
        NAVLogTestFailed(1, 'result should be "a,b,c<CRLF>"', result)
    } else {
        NAVLogTestPassed(1)
    }
}

define_function TestCsvSerializeEmptyData() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    // Don't populate data array - it's empty
    success = NAVCsvSerialize(data, result)

    if (success) {
        NAVLogTestFailed(2, 'serialization of empty data should fail', 'succeeded')
    } else {
        NAVLogTestPassed(2)
    }
}

define_function TestCsvSerializeMultipleRows() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    data[1][1] = 'a'
    data[1][2] = 'b'
    data[2][1] = 'c'
    data[2][2] = 'd'
    set_length_array(data, 2)  // 2 rows
    set_length_array(data[1], 2)  // 2 fields in row 1
    set_length_array(data[2], 2)  // 2 fields in row

    success = NAVCsvSerialize(data, result)

    if (!success) {
        NAVLogTestFailed(3, 'serialization should succeed', 'failed')
    } else if (result != "'a,b', NAV_CR, NAV_LF, 'c,d', NAV_CR, NAV_LF") {
        NAVLogTestFailed(3, 'result should be "a,b<CRLF>c,d<CRLF>"', result)
    } else {
        NAVLogTestPassed(3)
    }
}

define_function TestCsvSerializeFieldsWithCommas() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    data[1][1] = 'hello'
    data[1][2] = 'world, test'  // Contains comma - should be quoted
    set_length_array(data, 1)  // Only 1 row
    set_length_array(data[1], 2)  // 2 fields in row

    success = NAVCsvSerialize(data, result)

    if (!success) {
        NAVLogTestFailed(4, 'serialization should succeed', 'failed')
    } else if (result != "'hello,', '"', 'world, test', '"', NAV_CR, NAV_LF") {
        NAVLogTestFailed(4, 'field with comma should be quoted', result)
    } else {
        NAVLogTestPassed(4)
    }
}

define_function TestCsvSerializeFieldsWithQuotes() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    data[1][1] = 'say "hello"'  // Contains quote - should be escaped and quoted
    set_length_array(data, 1)  // Only 1 row
    set_length_array(data[1], 1)  // 1 field in row

    success = NAVCsvSerialize(data, result)

    if (!success) {
        NAVLogTestFailed(5, 'serialization should succeed', 'failed')
    } else if (result != "'"say ""hello"""', NAV_CR, NAV_LF") {
        NAVLogTestFailed(5, 'field with quote should be escaped and quoted', result)
    } else {
        NAVLogTestPassed(5)
    }
}

define_function TestCsvSerializeFieldsWithNewlines() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    data[1][1] = "'line1', NAV_LF, 'line2'"  // Contains newline - should be quoted
    set_length_array(data, 1)  // Only 1 row
    set_length_array(data[1], 1)  // 1 field in row

    success = NAVCsvSerialize(data, result)

    if (!success) {
        NAVLogTestFailed(6, 'serialization should succeed', 'failed')
    } else if (!NAVContains(result, '"')) {
        NAVLogTestFailed(6, 'field with newline should be quoted', result)
    } else if (!NAVContains(result, "NAV_LF")) {
        NAVLogTestFailed(6, 'newline should be preserved in field', result)
    } else {
        NAVLogTestPassed(6)
    }
}

define_function TestCsvSerializeEmptyFields() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    data[1][1] = 'a'
    data[1][2] = ''      // Empty field
    data[1][3] = 'c'
    set_length_array(data, 1)  // Only 1 row
    set_length_array(data[1], 3)  // 3 fields in row

    success = NAVCsvSerialize(data, result)

    if (!success) {
        NAVLogTestFailed(7, 'serialization should succeed', 'failed')
    } else if (result != "'a,,c', NAV_CR, NAV_LF") {
        NAVLogTestFailed(7, 'result should be "a,,c<CRLF>"', result)
    } else {
        NAVLogTestPassed(7)
    }
}

define_function TestCsvSerializeEmptyRows() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    data[1][1] = 'a'
    data[1][2] = 'b'
    // Row 2 is empty (length_array(data[2]) == 0)
    data[3][1] = 'c'
    data[3][2] = 'd'
    set_length_array(data, 3)  // 3 rows
    set_length_array(data[1], 2)  // 2 fields in row 1
    set_length_array(data[2], 0)  // Row 2 is empty
    set_length_array(data[3], 2)  // 2 fields in

    success = NAVCsvSerialize(data, result)

    if (!success) {
        NAVLogTestFailed(8, 'serialization should succeed', 'failed')
    } else if (result != "'a,b', NAV_CR, NAV_LF, NAV_CR, NAV_LF, 'c,d', NAV_CR, NAV_LF") {
        NAVLogTestFailed(8, 'empty row should output blank line', result)
    } else {
        NAVLogTestPassed(8)
    }
}

define_function TestCsvSerializeRealWorld() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    // Header row
    data[1][1] = 'Name'
    data[1][2] = 'Age'
    data[1][3] = 'City'
    set_length_array(data, 3)  // 3 rows
    set_length_array(data[1], 3)  // 3 fields in header

    // Data rows
    data[2][1] = 'Alice'
    data[2][2] = '30'
    data[2][3] = 'New York'
    set_length_array(data[2], 3)  // 3 fields in row 2

    data[3][1] = 'Bob'
    data[3][2] = '25'
    data[3][3] = 'Los Angeles'
    set_length_array(data[3], 3)  // 3 fields in row 3

    success = NAVCsvSerialize(data, result)

    if (!success) {
        NAVLogTestFailed(9, 'serialization should succeed', 'failed')
    } else if (!NAVContains(result, 'Name,Age,City')) {
        NAVLogTestFailed(9, 'result should contain header row', result)
    } else if (!NAVContains(result, 'Alice,30')) {
        NAVLogTestFailed(9, 'result should contain first data row', result)
    } else if (!NAVContains(result, 'Bob,25')) {
        NAVLogTestFailed(9, 'result should contain second data row', result)
    } else {
        NAVLogTestPassed(9)
    }
}

define_function TestCsvSerializeSingleField() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    data[1][1] = 'single'
    set_length_array(data, 1)  // Only 1 row
    set_length_array(data[1], 1)  // 1 field in row

    success = NAVCsvSerialize(data, result)

    if (!success) {
        NAVLogTestFailed(10, 'serialization should succeed', 'failed')
    } else if (result != "'single', NAV_CR, NAV_LF") {
        NAVLogTestFailed(10, 'result should be "single<CRLF>"', result)
    } else {
        NAVLogTestPassed(10)
    }
}

define_function TestCsvSerializeMixedQuoting() {
    stack_var char data[10][10][255]
    stack_var char result[2048]
    stack_var char success

    data[1][1] = 'plain'           // No quoting needed
    data[1][2] = 'has, comma'      // Needs quoting
    data[1][3] = 'also plain'      // No quoting needed
    set_length_array(data, 1)  // Only 1 row
    set_length_array(data[1], 3)  // 3 fields in row

    success = NAVCsvSerialize(data, result)

    if (!success) {
        NAVLogTestFailed(11, 'serialization should succeed', 'failed')
    } else if (!NAVContains(result, 'plain,')) {
        NAVLogTestFailed(11, 'plain field should not be quoted', result)
    } else if (!NAVContains(result, '"has, comma"')) {
        NAVLogTestFailed(11, 'field with comma should be quoted', result)
    } else if (!NAVContains(result, ',also plain')) {
        NAVLogTestFailed(11, 'second plain field should not be quoted', result)
    } else {
        NAVLogTestPassed(11)
    }
}

define_function TestCsvSerializeRoundTrip() {
    stack_var char originalData[10][10][255]
    stack_var char serialized[2048]
    stack_var char parsedData[10][10][255]
    stack_var char success

    // Create test data
    originalData[1][1] = 'Name'
    originalData[1][2] = 'Description'
    originalData[2][1] = 'Product A'
    originalData[2][2] = 'High quality, affordable'  // Has comma
    set_length_array(originalData, 2)  // 2 rows
    set_length_array(originalData[1], 2)  // 2 fields in row
    set_length_array(originalData[2], 2)  // 2 fields in row

    // Serialize
    success = NAVCsvSerialize(originalData, serialized)

    if (!success) {
        NAVLogTestFailed(12, 'serialization should succeed', 'failed')
        return
    }

    // Parse back
    success = NAVCsvParse(serialized, parsedData)

    if (!success) {
        NAVLogTestFailed(12, 'parsing should succeed', 'failed')
    } else if (parsedData[1][1] != originalData[1][1]) {
        NAVLogTestFailed(12, 'round-trip [1][1] should match', "parsedData[1][1]")
    } else if (parsedData[1][2] != originalData[1][2]) {
        NAVLogTestFailed(12, 'round-trip [1][2] should match', "parsedData[1][2]")
    } else if (parsedData[2][1] != originalData[2][1]) {
        NAVLogTestFailed(12, 'round-trip [2][1] should match', "parsedData[2][1]")
    } else if (parsedData[2][2] != originalData[2][2]) {
        NAVLogTestFailed(12, 'round-trip [2][2] should match', "parsedData[2][2]")
    } else {
        NAVLogTestPassed(12)
    }
}
