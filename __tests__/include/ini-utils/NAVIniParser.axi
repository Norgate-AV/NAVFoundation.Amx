PROGRAM_NAME='NAVIniParser'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

// Helper function to create tokens for testing
define_function CreateTestTokens(_NAVIniToken tokens[], char tokenData[][2][NAV_INI_LEXER_MAX_TOKEN_LENGTH], integer count) {
    stack_var integer i

    for (i = 1; i <= count; i++) {
        stack_var integer tokenType
        stack_var char tokenValue[NAV_INI_LEXER_MAX_TOKEN_LENGTH]

        tokenType = atoi(tokenData[i][1])
        tokenValue = tokenData[i][2]

        tokens[i].type = tokenType
        tokens[i].value = tokenValue
    }

    set_length_array(tokens, count)
}

define_function TestNAVIniParserInit() {
    stack_var _NAVIniParser parser
    stack_var _NAVIniToken tokens[10]
    stack_var integer x
    stack_var _NAVIniToken emptyTokens[1]

    NAVLog("'***************** NAVIniParserInit *****************'")

    // Create some test tokens
    for (x = 1; x <= 5; x++) {
        tokens[x].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
        tokens[x].value = "'token', itoa(x)"
    }

    set_length_array(tokens, 5)

    // Initialize parser
    NAVIniParserInit(parser, tokens)

    // Verify initialization
    if (parser.tokenCount == 5 && parser.cursor == 0) {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, 'initialized', 'failed')
    }

    // Test with empty token array
    set_length_array(emptyTokens, 0)
    NAVIniParserInit(parser, emptyTokens)

    if (parser.tokenCount == 0 && parser.cursor == 0) {
        NAVLogTestPassed(2)
    }
    else {
        NAVLogTestFailed(2, 'initialized', 'failed')
    }
}

define_function TestNAVIniParserParse() {
    NAVLog("'***************** NAVIniParserParse *****************'")

    // Test 1: Simple key-value pair (creates default section)
    TestParseSimpleKeyValue()

    // Test 2: Section with properties
    TestParseSectionWithProperties()

    // Test 3: Multiple sections
    TestParseMultipleSections()

    // Test 4: Error handling
    TestParseErrorHandling()
}

define_function TestParseSimpleKeyValue() {
    stack_var _NAVIniParser parser
    stack_var _NAVIniToken tokens[10]
    stack_var _NAVIniFile iniFile
    stack_var char result

    NAVLog("'--- Simple Key-Value Parse ---'")

    // Create tokens for: key=value
    tokens[1].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[1].value = 'timeout'
    tokens[2].type = NAV_INI_TOKEN_TYPE_EQUALS
    tokens[2].value = '='
    tokens[3].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[3].value = '30'
    set_length_array(tokens, 3)

    NAVIniParserInit(parser, tokens)
    result = NAVIniParserParse(parser, iniFile)

    if (result && iniFile.sectionCount == 1 &&
        iniFile.sections[1].name == 'default' &&
        iniFile.sections[1].propertyCount == 1 &&
        iniFile.sections[1].properties[1].key == 'timeout' &&
        iniFile.sections[1].properties[1].value == '30') {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, 'true', 'false')
    }
}

define_function TestParseSectionWithProperties() {
    stack_var _NAVIniParser parser
    stack_var _NAVIniToken tokens[20]
    stack_var _NAVIniFile iniFile
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Section With Properties Parse ---'")

    // Create tokens for: [database]\nhost=localhost\nport=5432
    tokenIndex = 1

    // [database]
    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_LBRACKET
    tokens[tokenIndex].value = '['
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'database'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_RBRACKET
    tokens[tokenIndex].value = ']'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "10"
    tokenIndex++

    // host=localhost
    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'host'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_EQUALS
    tokens[tokenIndex].value = '='
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'localhost'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "10"
    tokenIndex++

    // port=5432
    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'port'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_EQUALS
    tokens[tokenIndex].value = '='
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = '5432'
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVIniParserInit(parser, tokens)
    result = NAVIniParserParse(parser, iniFile)

    if (result && iniFile.sectionCount == 1 &&
        iniFile.sections[1].name == 'database' &&
        iniFile.sections[1].propertyCount == 2) {

        if (iniFile.sections[1].properties[1].key == 'host' &&
            iniFile.sections[1].properties[1].value == 'localhost' &&
            iniFile.sections[1].properties[2].key == 'port' &&
            iniFile.sections[1].properties[2].value == '5432') {
            NAVLogTestPassed(2)
        }
        else {
            NAVLogTestFailed(2, 'host=localhost,port=5432', 'different_values')
        }
    }
    else {
        NAVLogTestFailed(2, 'true', 'false')
    }
}

define_function TestParseMultipleSections() {
    stack_var _NAVIniParser parser
    stack_var _NAVIniToken tokens[30]
    stack_var _NAVIniFile iniFile
    stack_var char result
    stack_var integer tokenIndex

    NAVLog("'--- Multiple Sections Parse ---'")

    // Create tokens for: [section1]\nkey1=value1\n[section2]\nkey2=value2
    tokenIndex = 1

    // [section1]
    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_LBRACKET
    tokens[tokenIndex].value = '['
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'section1'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_RBRACKET
    tokens[tokenIndex].value = ']'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "10"
    tokenIndex++

    // key1=value1
    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'key1'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_EQUALS
    tokens[tokenIndex].value = '='
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'value1'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "10"
    tokenIndex++

    // [section2]
    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_LBRACKET
    tokens[tokenIndex].value = '['
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'section2'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_RBRACKET
    tokens[tokenIndex].value = ']'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_NEWLINE
    tokens[tokenIndex].value = "10"
    tokenIndex++

    // key2=value2
    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'key2'
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_EQUALS
    tokens[tokenIndex].value = '='
    tokenIndex++

    tokens[tokenIndex].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[tokenIndex].value = 'value2'
    tokenIndex++

    set_length_array(tokens, tokenIndex - 1)

    NAVIniParserInit(parser, tokens)
    result = NAVIniParserParse(parser, iniFile)

    if (result && iniFile.sectionCount == 2) {
        if (iniFile.sections[1].name == 'section1' &&
            iniFile.sections[1].propertyCount == 1 &&
            iniFile.sections[1].properties[1].key == 'key1' &&
            iniFile.sections[2].name == 'section2' &&
            iniFile.sections[2].propertyCount == 1 &&
            iniFile.sections[2].properties[1].key == 'key2') {
            NAVLogTestPassed(3)
        }
        else {
            NAVLogTestFailed(3, 'section1,section2', 'content_differs')
        }
    }
    else {
        NAVLog(itoa(iniFile.sectionCount))
        NAVLogTestFailed(3, '2', itoa(iniFile.sectionCount))
    }
}

define_function TestParseErrorHandling() {
    stack_var _NAVIniParser parser
    stack_var _NAVIniToken tokens[10]
    stack_var _NAVIniFile iniFile
    stack_var char result

    NAVLog("'--- Parse Error Handling ---'")

    // Test 1: Invalid token after section bracket
    tokens[1].type = NAV_INI_TOKEN_TYPE_LBRACKET
    tokens[1].value = '['
    tokens[2].type = NAV_INI_TOKEN_TYPE_EQUALS  // Invalid - should be identifier
    tokens[2].value = '='
    set_length_array(tokens, 2)

    NAVIniParserInit(parser, tokens)
    result = NAVIniParserParse(parser, iniFile)

    if (!result) {
        NAVLogTestPassed(4)
    }
    else {
        NAVLogTestFailed(4, 'false', 'true')
    }

    // Test 2: Missing equals in property
    tokens[1].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[1].value = 'key'
    tokens[2].type = NAV_INI_TOKEN_TYPE_RBRACKET  // Invalid - should be equals
    tokens[2].value = ']'
    set_length_array(tokens, 2)

    NAVIniParserInit(parser, tokens)
    result = NAVIniParserParse(parser, iniFile)

    if (!result) {
        NAVLogTestPassed(5)
    }
    else {
        NAVLogTestFailed(5, 'false', 'true')
    }
}

define_function TestNAVIniParserParseSection() {
    NAVLog("'***************** NAVIniParserParseSection *****************'")

    // This function is tested implicitly in the other parser tests
    // but we can add specific edge case tests here
    TestParseSectionEdgeCases()
}

define_function TestParseSectionEdgeCases() {
    stack_var _NAVIniParser parser
    stack_var _NAVIniToken tokens[10]
    stack_var _NAVIniFile iniFile
    stack_var char result

    NAVLog("'--- Section Parse Edge Cases ---'")

    // Test: Section with string name (quoted)
    tokens[1].type = NAV_INI_TOKEN_TYPE_LBRACKET
    tokens[1].value = '['
    tokens[2].type = NAV_INI_TOKEN_TYPE_STRING
    tokens[2].value = 'quoted section'
    tokens[3].type = NAV_INI_TOKEN_TYPE_RBRACKET
    tokens[3].value = ']'
    set_length_array(tokens, 3)

    NAVIniParserInit(parser, tokens)
    result = NAVIniParserParse(parser, iniFile)

    if (result && iniFile.sectionCount == 1 &&
        iniFile.sections[1].name == 'quoted section') {
        NAVLogTestPassed(1)
    }
    else {
        NAVLogTestFailed(1, 'quoted section', iniFile.sections[1].name)
    }
}

define_function TestNAVIniParserParseProperty() {
    NAVLog("'***************** NAVIniParserParseProperty *****************'")

    // This function is tested implicitly in the other parser tests
    // but we can add specific edge case tests here
    TestParsePropertyEdgeCases()
}

define_function TestParsePropertyEdgeCases() {
    stack_var _NAVIniParser parser
    stack_var _NAVIniToken tokens[20]
    stack_var _NAVIniFile iniFile
    stack_var char result

    NAVLog("'--- Property Parse Edge Cases ---'")

    // Test: Property with multiple value tokens (spaces between)
    tokens[1].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[1].value = 'title'
    tokens[2].type = NAV_INI_TOKEN_TYPE_EQUALS
    tokens[2].value = '='
    tokens[3].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[3].value = 'My'
    tokens[4].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[4].value = 'Application'
    tokens[5].type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    tokens[5].value = 'Name'
    set_length_array(tokens, 5)

    NAVIniParserInit(parser, tokens)
    result = NAVIniParserParse(parser, iniFile)

    if (result && iniFile.sectionCount == 1 &&
        iniFile.sections[1].propertyCount == 1) {
        stack_var char propertyValue[255]
        propertyValue = iniFile.sections[1].properties[1].value

        // Should combine multiple tokens with spaces
        if (find_string(propertyValue, 'My', 1) > 0 &&
            find_string(propertyValue, 'Application', 1) > 0 &&
            find_string(propertyValue, 'Name', 1) > 0) {
            NAVLogTestPassed(1)
        }
        else {
            NAVLogTestFailed(1, 'My Application Name', propertyValue)
        }
    }
    else {
        NAVLogTestFailed(1, 'true', 'false')
    }
}
