PROGRAM_NAME='NAVCsvParser'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

define_function TestNAVCsvParserInit() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var integer x
    stack_var _NAVCsvToken emptyTokens[1]

    NAVLog("'***************** NAVCsvParserInit *****************'")

    // Create some test tokens
    for (x = 1; x <= 5; x++) {
        tokens[x].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
        tokens[x].value = "'token', itoa(x)"
    }

    set_length_array(tokens, 5)

    // Initialize parser
    NAVCsvParserInit(parser, tokens)

    // Verify initialization
    if (parser.tokenCount == 5 && parser.cursor == 0 && parser.rowCount == 0 && parser.columnCount == 0) {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, 'initialized', 'failed')
    }

    // Test with empty token array
    set_length_array(emptyTokens, 0)
    NAVCsvParserInit(parser, emptyTokens)

    if (parser.tokenCount == 0 && parser.cursor == 0) {
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, 'initialized', 'failed')
    }
}

define_function TestNAVCsvParserParse() {
    NAVLog("'***************** NAVCsvParserParse *****************'")

    // Test 1: Simple single row
    TestParseSingleRow()

    // Test 2: Multiple rows
    TestParseMultipleRows()

    // Test 3: Quoted fields
    TestParseQuotedFields()

    // Test 4: Empty fields
    TestParseEmptyFields()

    // Test 5: Mixed content
    TestParseMixedContent()
}

define_function TestParseSingleRow() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result

    NAVLog("'--- Single Row Parse ---'")

    // Create tokens for: name,age,city
    tokens[1].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[1].value = 'name'
    tokens[2].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[2].value = ','
    tokens[3].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[3].value = 'age'
    tokens[4].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[4].value = ','
    tokens[5].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[5].value = 'city'
    tokens[6].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, 6)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'name' &&
        data[1][2] == 'age' &&
        data[1][3] == 'city') {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, 'name,age,city', "'Failed to parse'")
    }
}

define_function TestParseMultipleRows() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Multiple Rows Parse ---'")

    // Create tokens for:
    // name,age
    // John,30
    tokenIndex = 1

    // Row 1: name,age
    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'name'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'age'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "NAV_LF"
    tokenIndex++

    // Row 2: John,30
    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'John'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = '30'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 2 &&
        length_array(data[2]) == 2 &&
        data[1][1] == 'name' &&
        data[1][2] == 'age' &&
        data[2][1] == 'John' &&
        data[2][2] == '30') {
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, 'name,age / John,30', "'Failed to parse'")
    }
}

define_function TestParseQuotedFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Quoted Fields Parse ---'")

    // Create tokens for: "First Name","Last Name"
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[tokenIndex].value = 'First Name'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[tokenIndex].value = 'Last Name'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 2 &&
        data[1][1] == 'First Name' &&
        data[1][2] == 'Last Name') {
        NAVLogTestPassed(3)
    }
    else {
        NAVLogTestFailed(3, 'First Name,Last Name', "'Failed to parse'")
    }
}

define_function TestParseEmptyFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Empty Fields Parse ---'")

    // Create tokens for: field1,,field3
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'field1'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'field3'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'field1' &&
        data[1][2] == '' &&
        data[1][3] == 'field3') {
        NAVLogTestPassed(4)
    }
    else {
        NAVLogTestFailed(4, 'field1,,field3', "'Failed to parse'")
    }
}

define_function TestParseMixedContent() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[30]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Mixed Content Parse ---'")

    // Create tokens for:
    // id,"name",active
    // 1,"John Doe",true
    tokenIndex = 1

    // Row 1: id,"name",active
    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'id'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[tokenIndex].value = 'name'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'active'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "NAV_LF"
    tokenIndex++

    // Row 2: 1,"John Doe",true
    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = '1'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[tokenIndex].value = 'John Doe'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'true'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 3 &&
        length_array(data[2]) == 3 &&
        data[1][1] == 'id' &&
        data[1][2] == 'name' &&
        data[1][3] == 'active' &&
        data[2][1] == '1' &&
        data[2][2] == 'John Doe' &&
        data[2][3] == 'true') {
        NAVLogTestPassed(5)
    }
    else {
        NAVLogTestFailed(5, 'Mixed content', "'Failed to parse'")
    }
}

define_function TestNAVCsvParserWhitespaceHandling() {
    NAVLog("'***************** NAVCsvParserWhitespaceHandling *****************'")

    // Test 1: Whitespace before quoted field
    TestParseWhitespaceBeforeQuoted()

    // Test 2: Whitespace after quoted field
    TestParseWhitespaceAfterQuoted()

    // Test 3: Whitespace in unquoted field
    TestParseWhitespaceInUnquoted()
}

define_function TestParseWhitespaceBeforeQuoted() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Whitespace Before Quoted Field ---'")

    // Create tokens for:  "value"  (whitespace before quoted field)
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[tokenIndex].value = '  '
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[tokenIndex].value = 'value'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 1 &&
        data[1][1] == 'value') {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, 'value', data[1][1])
    }
}

define_function TestParseWhitespaceAfterQuoted() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Whitespace After Quoted Field ---'")

    // Create tokens for: "value"  ,next
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[tokenIndex].value = 'value'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[tokenIndex].value = '  '
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'next'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 2 &&
        data[1][1] == 'value' &&
        data[1][2] == 'next') {
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, 'value,next', "'Failed to parse'")
    }
}

define_function TestParseWhitespaceInUnquoted() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Whitespace In Unquoted Field ---'")

    // Create tokens for: Hello World (identifier with whitespace)
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'Hello'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[tokenIndex].value = ' '
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'World'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 1 &&
        data[1][1] == 'Hello World') {
        NAVLogTestPassed(3)
    }
    else {
        NAVLogTestFailed(3, 'Hello World', data[1][1])
    }
}

define_function TestNAVCsvParserEdgeCases() {
    NAVLog("'***************** NAVCsvParserEdgeCases *****************'")

    // Test 1: Trailing comma
    TestParseTrailingComma()

    // Test 2: Empty row
    TestParseEmptyRow()

    // Test 3: Single field
    TestParseSingleField()
}

define_function TestParseTrailingComma() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Trailing Comma ---'")

    // Create tokens for: value1,value2,
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'value1'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'value2'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'value1' &&
        data[1][2] == 'value2' &&
        data[1][3] == '') {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, 'value1,value2,', "'Failed to parse'")
    }
}

define_function TestParseEmptyRow() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Empty Row ---'")

    // Create tokens for: value1\n\nvalue2
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'value1'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "NAV_LF"
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "NAV_LF"
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'value2'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        data[1][1] == 'value1' &&
        data[3][1] == 'value2') {
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, 'value1/empty/value2', "'Failed to parse'")
    }
}

define_function TestParseSingleField() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result

    NAVLog("'--- Single Field ---'")

    // Create tokens for: value
    tokens[1].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[1].value = 'value'
    tokens[2].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, 2)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 1 &&
        data[1][1] == 'value') {
        NAVLogTestPassed(3)
    }
    else {
        NAVLogTestFailed(3, 'value', data[1][1])
    }
}

define_function TestNAVCsvParserComplexScenarios() {
    NAVLog("'***************** NAVCsvParserComplexScenarios *****************'")

    // Test 1: All empty fields
    TestParseAllEmptyFields()

    // Test 2: Leading empty fields
    TestParseLeadingEmptyFields()

    // Test 3: Many columns
    TestParseManyColumns()

    // Test 4: Many rows
    TestParseManyRows()

    // Test 5: Mixed empty and filled fields
    TestParseMixedEmptyFilled()
}

define_function TestParseAllEmptyFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- All Empty Fields ---'")

    // Create tokens for: ,,,
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 4 &&
        data[1][1] == '' &&
        data[1][2] == '' &&
        data[1][3] == '' &&
        data[1][4] == '') {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, ',,,', "'Failed to parse'")
    }
}

define_function TestParseLeadingEmptyFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Leading Empty Fields ---'")

    // Create tokens for: ,,value
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'value'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 3 &&
        data[1][1] == '' &&
        data[1][2] == '' &&
        data[1][3] == 'value') {
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, ',,value', "'Failed to parse'")
    }
}

define_function TestParseManyColumns() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[30]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex
    stack_var integer i

    NAVLog("'--- Many Columns (10 fields) ---'")

    // Create tokens for: col1,col2,col3,col4,col5,col6,col7,col8,col9,col10
    tokenIndex = 1

    for (i = 1; i <= 10; i++) {
        if (i > 1) {
            tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
            tokens[tokenIndex].value = ','
            tokenIndex++
        }

        tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
        tokens[tokenIndex].value = "'col', itoa(i)"
        tokenIndex++
    }

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 10 &&
        data[1][1] == 'col1' &&
        data[1][5] == 'col5' &&
        data[1][10] == 'col10') {
        NAVLogTestPassed(3)
    }
    else {
        NAVLogTestFailed(3, '10 columns', "'Failed to parse'")
    }
}

define_function TestParseManyRows() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[50]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex
    stack_var integer i

    NAVLog("'--- Many Rows (10 rows x 2 cols) ---'")

    tokenIndex = 1

    for (i = 1; i <= 10; i++) {
        if (i > 1) {
            tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_NEWLINE
            tokens[tokenIndex].value = "NAV_LF"
            tokenIndex++
        }

        // First column
        tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
        tokens[tokenIndex].value = "'row', itoa(i)"
        tokenIndex++

        tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
        tokens[tokenIndex].value = ','
        tokenIndex++

        // Second column
        tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
        tokens[tokenIndex].value = "'data', itoa(i)"
        tokenIndex++
    }

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        data[1][1] == 'row1' &&
        data[1][2] == 'data1' &&
        data[5][1] == 'row5' &&
        data[10][1] == 'row10' &&
        data[10][2] == 'data10') {
        NAVLogTestPassed(4)
    }
    else {
        NAVLogTestFailed(4, '10 rows', "'Failed to parse'")
    }
}

define_function TestParseMixedEmptyFilled() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[30]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Mixed Empty and Filled Fields ---'")

    // Create tokens for:
    // a,,c,
    // ,b,,d
    tokenIndex = 1

    // Row 1: a,,c,
    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'a'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'c'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "NAV_LF"
    tokenIndex++

    // Row 2: ,b,,d
    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'b'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'd'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        data[1][1] == 'a' &&
        data[1][2] == '' &&
        data[1][3] == 'c' &&
        data[1][4] == '' &&
        data[2][1] == '' &&
        data[2][2] == 'b' &&
        data[2][3] == '' &&
        data[2][4] == 'd') {
        NAVLogTestPassed(5)
    }
    else {
        NAVLogTestFailed(5, 'Mixed pattern', "'Failed to parse'")
    }
}

define_function TestNAVCsvParserSpecialCharacters() {
    NAVLog("'***************** NAVCsvParserSpecialCharacters *****************'")

    // Test 1: Quoted field with comma
    TestParseQuotedFieldWithComma()

    // Test 2: Quoted field with newline
    TestParseQuotedFieldWithNewline()

    // Test 3: Quoted field with quotes (escaped)
    TestParseQuotedFieldWithQuotes()

    // Test 4: Tabs in fields
    TestParseFieldsWithTabs()

    // Test 5: Long field value
    TestParseLongField()
}

define_function TestParseQuotedFieldWithComma() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Quoted Field With Comma ---'")

    // Create tokens for: "Last, First",Age
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[tokenIndex].value = 'Last, First'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'Age'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 2 &&
        data[1][1] == 'Last, First' &&
        data[1][2] == 'Age') {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, 'Last, First,Age', "'Failed to parse'")
    }
}

define_function TestParseQuotedFieldWithNewline() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex
    stack_var char fieldValue[50]

    NAVLog("'--- Quoted Field With Newline ---'")

    // Create tokens for: "Line1\nLine2",Value
    tokenIndex = 1

    fieldValue = "'Line1', NAV_LF, 'Line2'"

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[tokenIndex].value = fieldValue
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'Value'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 2 &&
        find_string(data[1][1], 'Line1', 1) > 0 &&
        find_string(data[1][1], 'Line2', 1) > 0 &&
        data[1][2] == 'Value') {
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, 'Line1\nLine2,Value', "'Failed to parse'")
    }
}

define_function TestParseQuotedFieldWithQuotes() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Quoted Field With Escaped Quotes ---'")

    // Create tokens for: "He said ""Hello""",Response
    // Lexer would have processed "" to "
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[tokenIndex].value = 'He said "Hello"'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'Response'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 2 &&
        data[1][1] == 'He said "Hello"' &&
        data[1][2] == 'Response') {
        NAVLogTestPassed(3)
    }
    else {
        NAVLogTestFailed(3, 'Escaped quotes', data[1][1])
    }
}

define_function TestParseFieldsWithTabs() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Fields With Tabs ---'")

    // Create tokens for: Field1<TAB>Field2,Value
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'Field1'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[tokenIndex].value = "NAV_TAB"
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'Field2'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'Value'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 2 &&
        find_string(data[1][1], 'Field1', 1) > 0 &&
        find_string(data[1][1], 'Field2', 1) > 0 &&
        data[1][2] == 'Value') {
        NAVLogTestPassed(4)
    }
    else {
        NAVLogTestFailed(4, 'Fields with tabs', "'Failed to parse'")
    }
}

define_function TestParseLongField() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var char longValue[200]
    stack_var integer i

    NAVLog("'--- Long Field Value ---'")

    // Create a long string (100+ characters)
    for (i = 1; i <= 10; i++) {
        longValue = "longValue, '0123456789'"
    }

    tokens[1].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[1].value = longValue
    tokens[2].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[2].value = ','
    tokens[3].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[3].value = 'short'
    tokens[4].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, 4)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        length_array(data[1]) == 2 &&
        length_array(data[1][1]) >= 100 &&
        data[1][2] == 'short') {
        NAVLogTestPassed(5)
    }
    else {
        NAVLogTestFailed(5, 'Long field', "'Failed to parse'")
    }
}

define_function TestNAVCsvParserRFC4180Compliance() {
    NAVLog("'***************** NAVCsvParserRFC4180Compliance *****************'")

    // Test 1: CRLF line endings
    TestParseCRLFLineEndings()

    // Test 2: Optional trailing CRLF
    TestParseOptionalTrailingNewline()

    // Test 3: Header row with data rows
    TestParseWithHeader()
}

define_function TestParseCRLFLineEndings() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- CRLF Line Endings ---'")

    // Create tokens for: field1\r\nfield2
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'field1'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "NAV_CR, NAV_LF"  // CRLF
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'field2'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        data[1][1] == 'field1' &&
        data[2][1] == 'field2') {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, 'CRLF endings', "'Failed to parse'")
    }
}

define_function TestParseOptionalTrailingNewline() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Optional Trailing Newline ---'")

    // Create tokens for: row1\nrow2\n (trailing newline)
    tokenIndex = 1

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'row1'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "NAV_LF"
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'row2'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "NAV_LF"
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        data[1][1] == 'row1' &&
        data[2][1] == 'row2') {
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, 'Trailing newline', "'Failed to parse'")
    }
}

define_function TestParseWithHeader() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[30]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- CSV With Header Row ---'")

    // Create tokens for:
    // Name,Age,City
    // John,30,NYC
    tokenIndex = 1

    // Header row
    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'Name'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'Age'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'City'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "NAV_LF"
    tokenIndex++

    // Data row
    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'John'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = '30'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[tokenIndex].value = ','
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'NYC'
    tokenIndex++

    tokens[tokenIndex].type = NAV_CSV_TOKEN_TYPE_EOF
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVCsvParserInit(parser, tokens)
    result = NAVCsvParserParse(parser, data)

    if (result &&
        data[1][1] == 'Name' &&
        data[1][2] == 'Age' &&
        data[1][3] == 'City' &&
        data[2][1] == 'John' &&
        data[2][2] == '30' &&
        data[2][3] == 'NYC') {
        NAVLogTestPassed(3)
    }
    else {
        NAVLogTestFailed(3, 'Header + data', "'Failed to parse'")
    }
}
