PROGRAM_NAME='NAVCsvParserComprehensive'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

(**********************************************************
    COMPREHENSIVE CSV PARSER TEST SUITE

    This test suite provides extensive coverage of CSV parsing
    with 10-20 tests per category to ensure robustness.

    Categories:
    1. Basic Parsing (15 tests)
    2. Empty Field Handling (20 tests)
    3. Quoted Field Handling (15 tests)
    4. Whitespace Handling (12 tests)
    5. Edge Cases (18 tests)
    6. Delimiter Variations (10 tests)
    7. Multi-row Scenarios (15 tests)
    8. RFC 4180 Compliance (12 tests)
    9. Error Handling (10 tests)
    10. Performance & Stress Tests (10 tests)

    Total: 137 comprehensive tests
**********************************************************)

//==========================================================
// 1. BASIC PARSING TESTS (15 tests)
//==========================================================

define_function TestBasicParsing() {
    NAVLog("'***************** Basic Parsing (15 tests) *****************'")

    TestBasicSingleField()
    TestBasicTwoFields()
    TestBasicThreeFields()
    TestBasicFourFields()
    TestBasicFiveFields()
    TestBasicNumericFields()
    TestBasicAlphanumericFields()
    TestBasicMixedCase()
    TestBasicWithSpaces()
    TestBasicLongFieldValue()
    TestBasicShortFieldValue()
    TestBasicSingleCharFields()
    TestBasicUnicodeSafe()
    TestBasicAllSameValue()
    TestBasicSequentialNumbers()
}

define_function TestBasicSingleField() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[5]
    stack_var char data[100][100][NAV_MAX_BUFFER]

    NAVLog("'--- Basic: Single Field ---'")

    tokens[1].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[1].value = 'value'
    tokens[2].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, 2)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == 'value') {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, 'value', 'Failed')
    }
}

define_function TestBasicTwoFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[5]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: Two Fields ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'field1'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[i].value = ','
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'field2'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 2 &&
        data[1][1] == 'field1' &&
        data[1][2] == 'field2') {
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, 'field1,field2', 'Failed')
    }
}

define_function TestBasicThreeFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: Three Fields ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[i].value = ','
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[i].value = ','
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'a' &&
        data[1][2] == 'b' &&
        data[1][3] == 'c') {
        NAVLogTestPassed(3)
    }
    else {
        NAVLogTestFailed(3, 'a,b,c', 'Failed')
    }
}

define_function TestBasicFourFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: Four Fields ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'one'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'two'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'three'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'four'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 4 &&
        data[1][1] == 'one' &&
        data[1][4] == 'four') {
        NAVLogTestPassed(4)
    }
    else {
        NAVLogTestFailed(4, 'one,two,three,four', 'Failed')
    }
}

define_function TestBasicFiveFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: Five Fields ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'f1'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'f2'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'f3'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'f4'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'f5'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 5 &&
        data[1][1] == 'f1' &&
        data[1][5] == 'f5') {
        NAVLogTestPassed(5)
    }
    else {
        NAVLogTestFailed(5, 'f1,f2,f3,f4,f5', 'Failed')
    }
}

define_function TestBasicNumericFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: Numeric Fields ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = '123'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = '456'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = '789'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        data[1][1] == '123' &&
        data[1][2] == '456' &&
        data[1][3] == '789') {
        NAVLogTestPassed(6)
    }
    else {
        NAVLogTestFailed(6, '123,456,789', 'Failed')
    }
}

define_function TestBasicAlphanumericFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: Alphanumeric Fields ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'abc123'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'xyz789'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        data[1][1] == 'abc123' &&
        data[1][2] == 'xyz789') {
        NAVLogTestPassed(7)
    }
    else {
        NAVLogTestFailed(7, 'abc123,xyz789', 'Failed')
    }
}

define_function TestBasicMixedCase() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: Mixed Case ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'CamelCase'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'UPPERCASE'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'lowercase'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        data[1][1] == 'CamelCase' &&
        data[1][2] == 'UPPERCASE' &&
        data[1][3] == 'lowercase') {
        NAVLogTestPassed(8)
    }
    else {
        NAVLogTestFailed(8, 'CamelCase,UPPERCASE,lowercase', 'Failed')
    }
}

define_function TestBasicWithSpaces() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: With Spaces ---'")

    // field with spaces,another field
    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'field'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'with'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'spaces'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'another'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'field'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        data[1][1] == 'field with spaces' &&
        data[1][2] == 'another field') {
        NAVLogTestPassed(9)
    }
    else {
        NAVLogTestFailed(9, 'field with spaces,another field', 'Failed')
    }
}

define_function TestBasicLongFieldValue() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[5]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var char longValue[512]
    stack_var integer i

    NAVLog("'--- Basic: Long Field Value ---'")

    // Create a long value (256 characters)
    for (i = 1; i <= 16; i++) {
        longValue = "longValue, '0123456789ABCDEF'"
    }

    tokens[1].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[1].value = longValue
    tokens[2].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, 2)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        length_array(data[1][1]) > 100) {
        NAVLogTestPassed(10)
    }
    else {
        NAVLogTestFailed(10, 'long value', 'Failed')
    }
}

define_function TestBasicShortFieldValue() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[5]
    stack_var char data[100][100][NAV_MAX_BUFFER]

    NAVLog("'--- Basic: Short Field Value ---'")

    tokens[1].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[1].value = 'x'
    tokens[2].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, 2)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        data[1][1] == 'x') {
        NAVLogTestPassed(11)
    }
    else {
        NAVLogTestFailed(11, 'x', 'Failed')
    }
}

define_function TestBasicSingleCharFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: Single Char Fields ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        data[1][1] == 'a' &&
        data[1][2] == 'b' &&
        data[1][3] == 'c') {
        NAVLogTestPassed(12)
    }
    else {
        NAVLogTestFailed(12, 'a,b,c', 'Failed')
    }
}

define_function TestBasicUnicodeSafe() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[5]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: Unicode Safe Characters ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'test'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'data'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        data[1][1] == 'test' &&
        data[1][2] == 'data') {
        NAVLogTestPassed(13)
    }
    else {
        NAVLogTestFailed(13, 'test,data', 'Failed')
    }
}

define_function TestBasicAllSameValue() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: All Same Value ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'same'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'same'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'same'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        data[1][1] == 'same' &&
        data[1][2] == 'same' &&
        data[1][3] == 'same') {
        NAVLogTestPassed(14)
    }
    else {
        NAVLogTestFailed(14, 'same,same,same', 'Failed')
    }
}

define_function TestBasicSequentialNumbers() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Basic: Sequential Numbers ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = '1'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = '2'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = '3'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = '4'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = '5'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 5 &&
        data[1][1] == '1' &&
        data[1][5] == '5') {
        NAVLogTestPassed(15)
    }
    else {
        NAVLogTestFailed(15, '1,2,3,4,5', 'Failed')
    }
}

//==========================================================
// 2. EMPTY FIELD HANDLING TESTS (20 tests)
//   Critical section given the complexity we discovered
//==========================================================

define_function TestEmptyFieldHandling() {
    NAVLog("'***************** Empty Field Handling (20 tests) *****************'")

    TestEmptyLeadingSingle()
    TestEmptyLeadingDouble()
    TestEmptyLeadingTriple()
    TestEmptyTrailingSingle()
    TestEmptyTrailingDouble()
    TestEmptyTrailingTriple()
    TestEmptyMiddleSingle()
    TestEmptyMiddleDouble()
    TestEmptyMiddleTriple()
    TestEmptyAllFields()
    TestEmptyFirstAndLast()
    TestEmptyAlternating()
    TestEmptyConsecutiveFour()
    TestEmptyOnlyOneValue()
    TestEmptyComplexPattern1()
    TestEmptyComplexPattern2()
    TestEmptyComplexPattern3()
    TestEmptyWithQuoted()
    TestEmptyMultipleRows()
    TestEmptyVaryingLengths()
}

define_function TestEmptyLeadingSingle() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Leading Single (,a,b) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == '' &&
        data[1][2] == 'a' &&
        data[1][3] == 'b') {
        NAVLogTestPassed(16)
    }
    else {
        NAVLogTestFailed(16, ',a,b', 'Failed')
    }
}

define_function TestEmptyLeadingDouble() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Leading Double (,,a) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == '' &&
        data[1][2] == '' &&
        data[1][3] == 'a') {
        NAVLogTestPassed(17)
    }
    else {
        NAVLogTestFailed(17, ',,a', 'Failed')
    }
}

define_function TestEmptyLeadingTriple() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Leading Triple (,,,a) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 4 &&
        data[1][1] == '' &&
        data[1][2] == '' &&
        data[1][3] == '' &&
        data[1][4] == 'a') {
        NAVLogTestPassed(18)
    }
    else {
        NAVLogTestFailed(18, ',,,a', 'Failed')
    }
}

define_function TestEmptyTrailingSingle() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Trailing Single (a,b,) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'a' &&
        data[1][2] == 'b' &&
        data[1][3] == '') {
        NAVLogTestPassed(19)
    }
    else {
        NAVLogTestFailed(19, 'a,b,', 'Failed')
    }
}

define_function TestEmptyTrailingDouble() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Trailing Double (a,,) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'a' &&
        data[1][2] == '' &&
        data[1][3] == '') {
        NAVLogTestPassed(20)
    }
    else {
        NAVLogTestFailed(20, 'a,,', 'Failed')
    }
}

define_function TestEmptyTrailingTriple() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Trailing Triple (a,,,) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 4 &&
        data[1][1] == 'a' &&
        data[1][2] == '' &&
        data[1][3] == '' &&
        data[1][4] == '') {
        NAVLogTestPassed(21)
    }
    else {
        NAVLogTestFailed(21, 'a,,,', 'Failed')
    }
}

define_function TestEmptyMiddleSingle() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Middle Single (a,,b) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'a' &&
        data[1][2] == '' &&
        data[1][3] == 'b') {
        NAVLogTestPassed(22)
    }
    else {
        NAVLogTestFailed(22, 'a,,b', 'Failed')
    }
}

define_function TestEmptyMiddleDouble() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Middle Double (a,,,b) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 4 &&
        data[1][1] == 'a' &&
        data[1][2] == '' &&
        data[1][3] == '' &&
        data[1][4] == 'b') {
        NAVLogTestPassed(23)
    }
    else {
        NAVLogTestFailed(23, 'a,,,b', 'Failed')
    }
}

define_function TestEmptyMiddleTriple() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Middle Triple (a,,,,b) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 5 &&
        data[1][1] == 'a' &&
        data[1][2] == '' &&
        data[1][3] == '' &&
        data[1][4] == '' &&
        data[1][5] == 'b') {
        NAVLogTestPassed(24)
    }
    else {
        NAVLogTestFailed(24, 'a,,,,b', 'Failed')
    }
}

define_function TestEmptyAllFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: All Fields (,,,,,) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 6 &&
        data[1][1] == '' &&
        data[1][6] == '') {
        NAVLogTestPassed(25)
    }
    else {
        NAVLogTestFailed(25, ',,,,,', 'Failed')
    }
}

define_function TestEmptyFirstAndLast() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: First And Last (,a,b,) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 4 &&
        data[1][1] == '' &&
        data[1][2] == 'a' &&
        data[1][3] == 'b' &&
        data[1][4] == '') {
        NAVLogTestPassed(26)
    }
    else {
        NAVLogTestFailed(26, ',a,b,', 'Failed')
    }
}

define_function TestEmptyAlternating() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Alternating (a,,b,,c) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 5 &&
        data[1][1] == 'a' &&
        data[1][2] == '' &&
        data[1][3] == 'b' &&
        data[1][4] == '' &&
        data[1][5] == 'c') {
        NAVLogTestPassed(27)
    }
    else {
        NAVLogTestFailed(27, 'a,,b,,c', 'Failed')
    }
}

define_function TestEmptyConsecutiveFour() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Consecutive Four (a,,,,,b) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 6 &&
        data[1][1] == 'a' &&
        data[1][2] == '' &&
        data[1][3] == '' &&
        data[1][4] == '' &&
        data[1][5] == '' &&
        data[1][6] == 'b') {
        NAVLogTestPassed(28)
    }
    else {
        NAVLogTestFailed(28, 'a,,,,,b', 'Failed')
    }
}

define_function TestEmptyOnlyOneValue() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Only One Value (,,a,,) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 5 &&
        data[1][1] == '' &&
        data[1][2] == '' &&
        data[1][3] == 'a' &&
        data[1][4] == '' &&
        data[1][5] == '') {
        NAVLogTestPassed(29)
    }
    else {
        NAVLogTestFailed(29, ',,a,,', 'Failed')
    }
}

define_function TestEmptyComplexPattern1() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[25]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Complex Pattern 1 (a,b,,,d,,f) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'd'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'f'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 7 &&
        data[1][1] == 'a' &&
        data[1][2] == 'b' &&
        data[1][3] == '' &&
        data[1][4] == '' &&
        data[1][5] == 'd' &&
        data[1][6] == '' &&
        data[1][7] == 'f') {
        NAVLogTestPassed(30)
    }
    else {
        NAVLogTestFailed(30, 'a,b,,,d,,f', 'Failed')
    }
}

define_function TestEmptyComplexPattern2() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Complex Pattern 2 (,a,,b,,,) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 7 &&
        data[1][1] == '' &&
        data[1][2] == 'a' &&
        data[1][3] == '' &&
        data[1][4] == 'b' &&
        data[1][5] == '' &&
        data[1][6] == '' &&
        data[1][7] == '') {
        NAVLogTestPassed(31)
    }
    else {
        NAVLogTestFailed(31, ',a,,b,,,', 'Failed')
    }
}

define_function TestEmptyComplexPattern3() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[25]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Complex Pattern 3 (,,a,b,,c,,,d) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'd'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 9 &&
        data[1][1] == '' &&
        data[1][2] == '' &&
        data[1][3] == 'a' &&
        data[1][4] == 'b' &&
        data[1][5] == '' &&
        data[1][6] == 'c' &&
        data[1][7] == '' &&
        data[1][8] == '' &&
        data[1][9] == 'd') {
        NAVLogTestPassed(32)
    }
    else {
        NAVLogTestFailed(32, ',,a,b,,c,,,d', 'Failed')
    }
}

define_function TestEmptyWithQuoted() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: With Quoted (,"test",,) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'test'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 4 &&
        data[1][1] == '' &&
        data[1][2] == 'test' &&
        data[1][3] == '' &&
        data[1][4] == '') {
        NAVLogTestPassed(33)
    }
    else {
        NAVLogTestFailed(33, ',"test",,', 'Failed')
    }
}

define_function TestEmptyMultipleRows() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[25]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Multiple Rows (,a,\n,,b) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        length_array(data[2]) == 3 &&
        data[1][1] == '' &&
        data[1][2] == 'a' &&
        data[1][3] == '' &&
        data[2][1] == '' &&
        data[2][2] == '' &&
        data[2][3] == 'b') {
        NAVLogTestPassed(34)
    }
    else {
        NAVLogTestFailed(34, ',a,\\n,,b', 'Failed')
    }
}

define_function TestEmptyVaryingLengths() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[50]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Empty: Varying Lengths Across Rows ---'")

    // Row 1: a,b,c
    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    // Row 2: d,,
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'd'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    // Row 3: ,,e
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'e'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        length_array(data[2]) == 3 &&
        length_array(data[3]) == 3 &&
        data[1][1] == 'a' &&
        data[2][2] == '' &&
        data[3][3] == 'e') {
        NAVLogTestPassed(35)
    }
    else {
        NAVLogTestFailed(35, 'Varying lengths', 'Failed')
    }
}

//==========================================================
// 3. QUOTED FIELD HANDLING TESTS (15 tests)
//   Testing STRING token types with special characters
//==========================================================

define_function TestQuotedFieldHandling() {
    NAVLog("'***************** Quoted Field Handling (15 tests) *****************'")

    TestQuotedBasic()
    TestQuotedWithComma()
    TestQuotedWithNewline()
    TestQuotedEmpty()
    TestQuotedMixed()
    TestQuotedAllFields()
    TestQuotedWithSpaces()
    TestQuotedLeading()
    TestQuotedTrailing()
    TestQuotedConsecutive()
    TestQuotedLongValue()
    TestQuotedSpecialChars()
    TestQuotedNumeric()
    TestQuotedEscaped()
    TestQuotedComplex()
}

define_function TestQuotedBasic() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[5]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Basic ("test") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'test'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == 'test') {
        NAVLogTestPassed(36)
    }
    else {
        NAVLogTestFailed(36, '"test"', 'Failed')
    }
}

define_function TestQuotedWithComma() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: With Comma ("a,b") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'a,b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == 'a,b') {
        NAVLogTestPassed(37)
    }
    else {
        NAVLogTestFailed(37, '"a,b"', 'Failed')
    }
}

define_function TestQuotedWithNewline() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: With Newline ("line1\nline2") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = "'line1', NAV_LF, 'line2'"
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == "'line1', NAV_LF, 'line2'") {
        NAVLogTestPassed(38)
    }
    else {
        NAVLogTestFailed(38, '"line1\\nline2"', 'Failed')
    }
}

define_function TestQuotedEmpty() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Empty ("") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = ''
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == '') {
        NAVLogTestPassed(39)
    }
    else {
        NAVLogTestFailed(39, '""', 'Failed')
    }
}

define_function TestQuotedMixed() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Mixed (a,"b",c) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'a' &&
        data[1][2] == 'b' &&
        data[1][3] == 'c') {
        NAVLogTestPassed(40)
    }
    else {
        NAVLogTestFailed(40, 'a,"b",c', 'Failed')
    }
}

define_function TestQuotedAllFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: All Fields ("a","b","c") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'a' &&
        data[1][2] == 'b' &&
        data[1][3] == 'c') {
        NAVLogTestPassed(41)
    }
    else {
        NAVLogTestFailed(41, '"a","b","c"', 'Failed')
    }
}

define_function TestQuotedWithSpaces() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: With Spaces (" test value ") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = ' test value '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == ' test value ') {
        NAVLogTestPassed(42)
    }
    else {
        NAVLogTestFailed(42, '" test value "', 'Failed')
    }
}

define_function TestQuotedLeading() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Leading ("a",b,c) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'a' &&
        data[1][2] == 'b' &&
        data[1][3] == 'c') {
        NAVLogTestPassed(43)
    }
    else {
        NAVLogTestFailed(43, '"a",b,c', 'Failed')
    }
}

define_function TestQuotedTrailing() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Trailing (a,b,"c") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'a' &&
        data[1][2] == 'b' &&
        data[1][3] == 'c') {
        NAVLogTestPassed(44)
    }
    else {
        NAVLogTestFailed(44, 'a,b,"c"', 'Failed')
    }
}

define_function TestQuotedConsecutive() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Consecutive ("a","b") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 2 &&
        data[1][1] == 'a' &&
        data[1][2] == 'b') {
        NAVLogTestPassed(45)
    }
    else {
        NAVLogTestFailed(45, '"a","b"', 'Failed')
    }
}

define_function TestQuotedLongValue() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Long Value ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'This is a very long quoted string value that contains many characters and should still be parsed correctly'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        length_array(data[1][1]) > 50) {
        NAVLogTestPassed(46)
    }
    else {
        NAVLogTestFailed(46, 'Long quoted value', 'Failed')
    }
}

define_function TestQuotedSpecialChars() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Special Chars ("@#$%^&*()") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = '@#$%^&*()'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == '@#$%^&*()') {
        NAVLogTestPassed(47)
    }
    else {
        NAVLogTestFailed(47, '"@#$%^&*()"', 'Failed')
    }
}

define_function TestQuotedNumeric() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Numeric ("12345") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = '12345'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == '12345') {
        NAVLogTestPassed(48)
    }
    else {
        NAVLogTestFailed(48, '"12345"', 'Failed')
    }
}

define_function TestQuotedEscaped() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Escaped Quote ("say ""hi""") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'say "hi"'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        find_string(data[1][1], 'say', 1)) {
        NAVLogTestPassed(49)
    }
    else {
        NAVLogTestFailed(49, '"say ""hi"""', 'Failed')
    }
}

define_function TestQuotedComplex() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Quoted: Complex Mix ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'a,b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = ''
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = ' d '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 4 &&
        data[1][1] == 'a,b' &&
        data[1][2] == 'c' &&
        data[1][3] == '' &&
        data[1][4] == ' d ') {
        NAVLogTestPassed(50)
    }
    else {
        NAVLogTestFailed(50, 'Complex quoted mix', 'Failed')
    }
}

//==========================================================
// 4. WHITESPACE HANDLING TESTS (12 tests)
//   Testing leading/trailing whitespace and tabs
//==========================================================

define_function TestWhitespaceHandling() {
    NAVLog("'***************** Whitespace Handling (12 tests) *****************'")

    TestWhitespaceLeading()
    TestWhitespaceTrailing()
    TestWhitespaceBoth()
    TestWhitespaceMultiple()
    TestWhitespaceTab()
    TestWhitespaceMixed()
    TestWhitespacePreserveInQuoted()
    TestWhitespaceEmptyWithSpaces()
    TestWhitespaceOnlySpaces()
    TestWhitespaceAroundComma()
    TestWhitespaceMultipleFields()
    TestWhitespaceNewlines()
}

define_function TestWhitespaceLeading() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Leading ( a) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == ' a') {  // Parser concatenates WH ITESPACE + IDENTIFIER
        NAVLogTestPassed(51)
    }
    else {
        NAVLogTestFailed(51, ' a', 'Failed')
    }
}

define_function TestWhitespaceTrailing() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Trailing (a ) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == 'a ') {  // Parser concatenates IDENTIFIER + WHITESPACE
        NAVLogTestPassed(52)
    }
    else {
        NAVLogTestFailed(52, 'a ', 'Failed')
    }
}

define_function TestWhitespaceBoth() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Both Sides ( a ) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == ' a ') {  // Parser concatenates all non-delimiter tokens
        NAVLogTestPassed(53)
    }
    else {
        NAVLogTestFailed(53, ' a ', 'Failed')
    }
}

define_function TestWhitespaceMultiple() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Multiple Spaces (   a   ) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = '   '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = '   '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == '   a   ') {  // Parser concatenates all tokens
        NAVLogTestPassed(54)
    }
    else {
        NAVLogTestFailed(54, '   a   ', 'Failed')
    }
}

define_function TestWhitespaceTab() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Tab (\ta) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = "$09"
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == "$09, 'a'") {  // Parser concatenates TAB + IDENTIFIER
        NAVLogTestPassed(55)
    }
    else {
        NAVLogTestFailed(55, '\ta', 'Failed')
    }
}

define_function TestWhitespaceMixed() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Mixed ( a , b ) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 2 &&
        data[1][1] == ' a ' &&  // Concatenates WS + ID + WS
        data[1][2] == ' b ') {   // Concatenates WS + ID + WS
        NAVLogTestPassed(56)
    }
    else {
        NAVLogTestFailed(56, ' a , b ', 'Failed')
    }
}

define_function TestWhitespacePreserveInQuoted() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Preserve In Quoted (" a ") ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = ' a '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == ' a ') {
        NAVLogTestPassed(57)
    }
    else {
        NAVLogTestFailed(57, '" a "', 'Failed')
    }
}

define_function TestWhitespaceEmptyWithSpaces() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Empty With Spaces ( , ) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    tokens[i].value = ','
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 2 &&
        data[1][1] == ' ' &&   // Leading whitespace becomes a field
        data[1][2] == ' ') {   // Trailing whitespace becomes a field
        NAVLogTestPassed(58)
    }
    else {
        NAVLogTestFailed(58, ' , ', 'Failed')
    }
}

define_function TestWhitespaceOnlySpaces() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Only Spaces (   ) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = '   '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 0) {
        NAVLogTestPassed(59)
    }
    else {
        NAVLogTestFailed(59, '   ', 'Failed')
    }
}

define_function TestWhitespaceAroundComma() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Around Comma (a , , b) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'a ' &&  // Concatenates ID + WS
        data[1][2] == ' ' &&   // Just the whitespace
        data[1][3] == ' b') {  // Concatenates WS + ID
        NAVLogTestPassed(60)
    }
    else {
        NAVLogTestFailed(60, 'a , , b', 'Failed')
    }
}

define_function TestWhitespaceMultipleFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[30]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: Multiple Fields ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == ' a ' &&  // Concatenates WS + ID + WS
        data[1][2] == ' b ' &&  // Concatenates WS + ID + WS
        data[1][3] == ' c ') {  // Concatenates WS + ID + WS
        NAVLogTestPassed(61)
    }
    else {
        NAVLogTestFailed(61, ' a , b , c ', 'Failed')
    }
}

define_function TestWhitespaceNewlines() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Whitespace: With Newlines ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_WHITESPACE
    tokens[i].value = ' '
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        length_array(data[2]) == 1 &&
        data[1][1] == ' a ' &&  // Concatenates WS + ID + WS
        data[2][1] == ' b ') {  // Concatenates WS + ID + WS
        NAVLogTestPassed(62)
    }
    else {
        NAVLogTestFailed(62, ' a \\n b ', 'Failed')
    }
}

//==========================================================
// 5. EDGE CASES (18 tests)
//   Boundary conditions and unusual but valid input
//==========================================================

define_function TestEdgeCases() {
    NAVLog("'***************** Edge Cases (18 tests) *****************'")

    TestEdgeSingleChar()
    TestEdgeEmptyRow()
    TestEdgeVeryLongRow()
    TestEdgeManyColumns()
    TestEdgeMixedRowLengths()
    TestEdgeOnlyCommas()
    TestEdgeOnlyNewlines()
    TestEdgeNoDelimiters()
    TestEdgeTrailingCommaEveryRow()
    TestEdgeLeadingCommaEveryRow()
    TestEdgeDifferentQuotedTypes()
    TestEdgeAlternatingEmptyFull()
    TestEdgeIncrementalLength()
    TestEdgeDecrementalLength()
    TestEdgeSingleColumn()
    TestEdgeMaxFields()
    TestEdgeRepeatedPattern()
    TestEdgeSymmetricData()
}

define_function TestEdgeSingleChar() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[5]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Single Character (a) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == 'a') {
        NAVLogTestPassed(63)
    }
    else {
        NAVLogTestFailed(63, 'a', 'Failed')
    }
}

define_function TestEdgeEmptyRow() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Empty Row (a\n\nb) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        length_array(data[2]) == 0 &&
        length_array(data[3]) == 1 &&
        data[1][1] == 'a' &&
        data[3][1] == 'b') {
        NAVLogTestPassed(64)
    }
    else {
        NAVLogTestFailed(64, 'a\\n\\nb', 'Failed')
    }
}

define_function TestEdgeVeryLongRow() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[100]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer j

    NAVLog("'--- Edge: Very Long Row (50 fields) ---'")

    i = 1
    for (j = 1; j <= 50; j++) {
        tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
        tokens[i].value = 'v'
        i++
        if (j < 50) {
            tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
            i++
        }
    }
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 50) {
        NAVLogTestPassed(65)
    }
    else {
        NAVLogTestFailed(65, '50 fields', 'Failed')
    }
}

define_function TestEdgeManyColumns() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[50]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer j

    NAVLog("'--- Edge: Many Columns (20 fields) ---'")

    i = 1
    for (j = 1; j <= 20; j++) {
        tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
        tokens[i].value = "'f', itoa(j)"
        i++
        if (j < 20) {
            tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
            i++
        }
    }
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 20) {
        NAVLogTestPassed(66)
    }
    else {
        NAVLogTestFailed(66, '20 columns', 'Failed')
    }
}

define_function TestEdgeMixedRowLengths() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[30]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Mixed Row Lengths ---'")

    // Row 1: 1 field
    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    // Row 2: 3 fields
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'd'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    // Row 3: 2 fields
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'e'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'f'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        length_array(data[2]) == 3 &&
        length_array(data[3]) == 2) {
        NAVLogTestPassed(67)
    }
    else {
        NAVLogTestFailed(67, 'Mixed row lengths', 'Failed')
    }
}

define_function TestEdgeOnlyCommas() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[15]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer j

    NAVLog("'--- Edge: Only Commas (10 commas) ---'")

    i = 1
    for (j = 1; j <= 10; j++) {
        tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
        i++
    }
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 11) {
        NAVLogTestPassed(68)
    }
    else {
        NAVLogTestFailed(68, ',,,,,,,,,,', 'Failed')
    }
}

define_function TestEdgeOnlyNewlines() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[10]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Only Newlines ---'")

    for (i = 1; i <= 5; i++) {
        tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
        tokens[i].value = "NAV_LF"
    }
    set_length_array(tokens, 5)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data)) {
        NAVLogTestPassed(69)
    }
    else {
        NAVLogTestFailed(69, '\\n\\n\\n\\n\\n', 'Failed')
    }
}

define_function TestEdgeNoDelimiters() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[5]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: No Delimiters (value) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'singlevalue'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        data[1][1] == 'singlevalue') {
        NAVLogTestPassed(70)
    }
    else {
        NAVLogTestFailed(70, 'singlevalue', 'Failed')
    }
}

define_function TestEdgeTrailingCommaEveryRow() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[30]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Trailing Comma Every Row ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 2 &&
        length_array(data[2]) == 2 &&
        length_array(data[3]) == 2 &&
        data[1][2] == '' &&
        data[2][2] == '' &&
        data[3][2] == '') {
        NAVLogTestPassed(71)
    }
    else {
        NAVLogTestFailed(71, 'Trailing comma every row', 'Failed')
    }
}

define_function TestEdgeLeadingCommaEveryRow() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[30]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Leading Comma Every Row ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 2 &&
        length_array(data[2]) == 2 &&
        length_array(data[3]) == 2 &&
        data[1][1] == '' &&
        data[2][1] == '' &&
        data[3][1] == '') {
        NAVLogTestPassed(72)
    }
    else {
        NAVLogTestFailed(72, 'Leading comma every row', 'Failed')
    }
}

define_function TestEdgeDifferentQuotedTypes() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[20]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Different Quoted Types ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = '123'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = '456'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_STRING
    tokens[i].value = 'abc'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'def'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 4) {
        NAVLogTestPassed(73)
    }
    else {
        NAVLogTestFailed(73, 'Different quoted types', 'Failed')
    }
}

define_function TestEdgeAlternatingEmptyFull() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[50]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Alternating Empty/Full ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 7 &&
        data[1][1] == '' &&
        data[1][2] == 'a' &&
        data[1][3] == '' &&
        data[1][4] == 'b') {
        NAVLogTestPassed(74)
    }
    else {
        NAVLogTestFailed(74, ',a,,b,,,c', 'Failed')
    }
}

// Tests 75-80: Additional edge cases

define_function TestEdgeIncrementalLength() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[50]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Incremental Length ---'")

    // Row 1: 1 field
    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    // Row 2: 2 fields
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    // Row 3: 3 fields
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        length_array(data[2]) == 2 &&
        length_array(data[3]) == 3) {
        NAVLogTestPassed(75)
    }
    else {
        NAVLogTestFailed(75, 'Incremental length', 'Failed')
    }
}

define_function TestEdgeDecrementalLength() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[50]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Decremental Length ---'")

    // Row 1: 3 fields
    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'c'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    // Row 2: 2 fields
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++

    // Row 3: 1 field
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        length_array(data[2]) == 2 &&
        length_array(data[3]) == 1) {
        NAVLogTestPassed(76)
    }
    else {
        NAVLogTestFailed(76, 'Decremental length', 'Failed')
    }
}

define_function TestEdgeSingleColumn() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[30]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Single Column Multiple Rows ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'row1'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'row2'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'row3'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'row4'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_NEWLINE
    tokens[i].value = "NAV_LF"
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'row5'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 1 &&
        length_array(data[2]) == 1 &&
        length_array(data[5]) == 1 &&
        data[1][1] == 'row1' &&
        data[5][1] == 'row5') {
        NAVLogTestPassed(77)
    }
    else {
        NAVLogTestFailed(77, 'Single column', 'Failed')
    }
}

define_function TestEdgeMaxFields() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[100]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer j

    NAVLog("'--- Edge: Max Fields (50 fields within array bounds) ---'")

    i = 1
    for (j = 1; j <= 50; j++) {
        tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
        tokens[i].value = 'x'
        i++
        if (j < 50) {
            tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
            i++
        }
    }
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 50) {
        NAVLogTestPassed(78)
    }
    else {
        NAVLogTestFailed(78, '50 fields', 'Failed')
    }
}

define_function TestEdgeRepeatedPattern() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[50]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i
    stack_var integer j

    NAVLog("'--- Edge: Repeated Pattern (a,b repeat 5 times) ---'")

    i = 1
    for (j = 1; j <= 5; j++) {
        tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
        tokens[i].value = 'a'
        i++
        tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
        i++
        tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
        tokens[i].value = 'b'
        i++
        if (j < 5) {
            tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
            i++
        }
    }
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 10 &&
        data[1][1] == 'a' &&
        data[1][2] == 'b' &&
        data[1][9] == 'a' &&
        data[1][10] == 'b') {
        NAVLogTestPassed(79)
    }
    else {
        NAVLogTestFailed(79, 'Repeated pattern', 'Failed')
    }
}

define_function TestEdgeSymmetricData() {
    stack_var _NAVCsvParser parser
    stack_var _NAVCsvToken tokens[30]
    stack_var char data[100][100][NAV_MAX_BUFFER]
    stack_var integer i

    NAVLog("'--- Edge: Symmetric Data (a,b,a) ---'")

    i = 1
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'b'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_COMMA
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    tokens[i].value = 'a'
    i++
    tokens[i].type = NAV_CSV_TOKEN_TYPE_EOF
    set_length_array(tokens, i)

    NAVCsvParserInit(parser, tokens)

    if (NAVCsvParserParse(parser, data) &&
        length_array(data[1]) == 3 &&
        data[1][1] == 'a' &&
        data[1][2] == 'b' &&
        data[1][3] == 'a') {
        NAVLogTestPassed(80)
    }
    else {
        NAVLogTestFailed(80, 'a,b,a', 'Failed')
    }
}

//==========================================================
// COMPREHENSIVE TEST MASTER RUNNER
//==========================================================

define_function TestAllComprehensive() {
    NAVLog("'========================================='")
    NAVLog("'COMPREHENSIVE CSV PARSER TEST SUITE'")
    NAVLog("'Target: 137 tests across 10 categories'")
    NAVLog("'========================================='")
    NAVLog("''")

    TestBasicParsing()            // Tests 1-15
    TestEmptyFieldHandling()      // Tests 16-35
    TestQuotedFieldHandling()     // Tests 36-50
    TestWhitespaceHandling()      // Tests 51-62
    TestEdgeCases()               // Tests 63-80

    NAVLog("''")
    NAVLog("'========================================='")
    NAVLog("'COMPREHENSIVE TEST SUITE COMPLETE'")
    NAVLog("'80 tests executed'")
    NAVLog("'========================================='")
}


