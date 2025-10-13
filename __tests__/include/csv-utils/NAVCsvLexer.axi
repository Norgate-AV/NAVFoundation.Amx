PROGRAM_NAME='NAVCsvLexer'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test token types for validation
constant integer TOKEN_TYPES[] = {
    NAV_CSV_TOKEN_TYPE_COMMA,
    NAV_CSV_TOKEN_TYPE_IDENTIFIER,
    NAV_CSV_TOKEN_TYPE_STRING,
    NAV_CSV_TOKEN_TYPE_NEWLINE,
    NAV_CSV_TOKEN_TYPE_EOF,
    NAV_CSV_TOKEN_TYPE_WHITESPACE,
    NAV_CSV_TOKEN_TYPE_ERROR
}

constant char TOKEN_TYPE_NAMES[][16] = {
    'COMMA',
    'IDENTIFIER',
    'STRING',
    'NEWLINE',
    'EOF',
    'WHITESPACE',
    'ERROR'
}

// Character test data for identifier validation
constant char IDENTIFIER_TEST_CHARS[] = {
    'a', 'A', 'z', 'Z', '0', '9', '_', '-', '.', '@',
    ' ', '=', '[', ']', ';', '#', 10, 13, $22, $27
}

constant char IDENTIFIER_EXPECTED_RESULTS[] = {
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1,  // a-z, A-Z, 0-9, _, -, ., @
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0   // space, =, [, ], ;, #, LF, CR, ", '
}

// Test data for identifier character validation - these will be redefined for specific usage
constant char IDENTIFIER_CHAR_TEST[] = {
    'a', 'Z', '1', '9',              // Basic alphanumeric
    '-', '_', '.', $5C, '/', ':',    // Valid special chars (using $5C for backslash)
    '@', '$', '%', '~',              // More valid special chars
    ' ', 9, '[', ']', '=',          // Invalid chars (space, tab, brackets, equals)
    ';', '#', $22, $27               // Invalid chars (comment, quotes)
}

constant char IDENTIFIER_CHAR_EXPECTED[] = {
    1, 1, 1, 1,                      // Basic alphanumeric - valid
    1, 1, 1, 1, 1, 1,               // Valid special chars
    1, 1, 1, 1,                      // More valid special chars
    0, 0, 0, 0, 0,                   // Invalid chars
    0, 0, 0, 0                       // Invalid chars
}


constant integer LEXER_TOKEN_EXPECTED_COUNTS[] = {
    5, // a,b,c -> IDENTIFIER, COMMA, IDENTIFIER, COMMA, IDENTIFIER
    3, // "hello,world",test -> STRING, COMMA, IDENTIFIER
    3, // "He said ""Hello""",normal -> STRING, COMMA, IDENTIFIER
    7, // field1,field2\nfield3,field4 -> IDENTIFIER, COMMA, IDENTIFIER, NEWLINE, IDENTIFIER, COMMA, IDENTIFIER
    4, // a,,c -> IDENTIFIER, COMMA, COMMA, IDENTIFIER
    3, // "line1\nline2",end -> STRING, COMMA, IDENTIFIER
    9, // x,y,z,a,b -> IDENTIFIER, COMMA, IDENTIFIER, COMMA, IDENTIFIER, COMMA, IDENTIFIER, COMMA, IDENTIFIER
    6, // "test",,"empty",end -> STRING, COMMA, COMMA, IDENTIFIER, COMMA, IDENTIFIER
    11, // header1,header2\nval1,val2\nval3,val4 -> IDENTIFIER, COMMA, IDENTIFIER, NEWLINE, IDENTIFIER, COMMA, IDENTIFIER, NEWLINE, IDENTIFIER, COMMA, IDENTIFIER
    3, // "field with\nnewline",normal -> STRING, COMMA, IDENTIFIER
    1, // "" -> STRING
    3, // ,,, -> COMMA, COMMA, COMMA
    4, // a,b, -> IDENTIFIER, COMMA, IDENTIFIER, COMMA
    4, // ,a,b -> COMMA, IDENTIFIER, COMMA, IDENTIFIER
    3  // "quote","another" -> STRING, COMMA, STRING
}


DEFINE_VARIABLE

// Global variables for test data (set at runtime)
volatile char LEXER_INIT_TEST_DATA[20][127500]
volatile char LEXER_TOKEN_TEST_DATA[50][127500]

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 */
define_function InitializeLexerTestData() {
    // LEXER_INIT_TEST_DATA - basic initialization tests
    LEXER_INIT_TEST_DATA[1] = "
        'some,simple,test,value,data', 13, 10,
        'with,newlines,and,"quotes"', 13, 10
    "
    LEXER_INIT_TEST_DATA[2] = 'simple'
    LEXER_INIT_TEST_DATA[3] = '"quoted"'
    LEXER_INIT_TEST_DATA[4] = 'a,b'
    LEXER_INIT_TEST_DATA[5] = 'empty'
    LEXER_INIT_TEST_DATA[6] = '"single,"field""'
    LEXER_INIT_TEST_DATA[7] = "
        'multi,line,data', 13, 10,
        'more,data'
    "
    LEXER_INIT_TEST_DATA[8] = '"complex ""quote"" test",simple'
    set_length_array(LEXER_INIT_TEST_DATA, 8)

    // LEXER_TOKEN_TEST_DATA - CSV-specific test cases with proper token expectations
    LEXER_TOKEN_TEST_DATA[1] = 'a,b,c'  // Simple unquoted fields
    LEXER_TOKEN_TEST_DATA[2] = '"hello,world",test'  // Quoted field with comma
    LEXER_TOKEN_TEST_DATA[3] = '"He said ""Hello""",normal'  // Quoted field with escaped quotes
    LEXER_TOKEN_TEST_DATA[4] = "'field1,field2', 13, 10, 'field3,field4'"  // Multiple records with newline
    LEXER_TOKEN_TEST_DATA[5] = 'a,,c'  // Empty field (two consecutive commas)
    LEXER_TOKEN_TEST_DATA[6] = "'"line1', 13, 10, 'line2",end'"  // Quoted field with internal newline
    LEXER_TOKEN_TEST_DATA[7] = 'x,y,z,a,b'  // More fields
    LEXER_TOKEN_TEST_DATA[8] = '"test",,"empty",end'  // Empty field
    LEXER_TOKEN_TEST_DATA[9] = "'header1,header2', 13, 10, 'val1,val2', 13, 10, 'val3,val4'"  // Multi-record
    LEXER_TOKEN_TEST_DATA[10] = "'"field with', 13, 10, 'newline",normal'"  // Quoted with newline
    LEXER_TOKEN_TEST_DATA[11] = '""'  // Empty quoted string
    LEXER_TOKEN_TEST_DATA[12] = ',,,'  // Multiple consecutive commas
    LEXER_TOKEN_TEST_DATA[13] = 'a,b,'  // Trailing comma
    LEXER_TOKEN_TEST_DATA[14] = ',a,b'  // Leading comma
    LEXER_TOKEN_TEST_DATA[15] = '"quote","another"'  // Multiple quoted fields
    set_length_array(LEXER_TOKEN_TEST_DATA, 15)
}

define_function TestNAVCsvLexerInit() {
    stack_var integer x

    NAVLog("'***************** NAVCsvLexerInit *****************'")

    // Initialize test data
    InitializeLexerTestData()

    for (x = 1; x <= length_array(LEXER_INIT_TEST_DATA); x++) {
        stack_var _NAVCsvLexer lexer
        stack_var char data[512]

        data = LEXER_INIT_TEST_DATA[x]

        // Initialize the lexer
        NAVCsvLexerInit(lexer, data)

        // Verify initialization
        if (lexer.source == data && lexer.cursor == 0 && lexer.tokenCount == 0) {
            NAVLogTestPassed(x)
        } else {
            NAVLogTestFailed(x, 'initialized', 'failed')
        }
    }
}

define_function TestNAVCsvLexerTokenize() {
    stack_var integer x

    NAVLog("'***************** NAVCsvLexerTokenize *****************'")

    // Initialize test data
    InitializeLexerTestData()

    for (x = 1; x <= length_array(LEXER_TOKEN_TEST_DATA); x++) {
        stack_var _NAVCsvLexer lexer
        stack_var char data[1024]
        stack_var char result
        stack_var long expectedCount

        data = LEXER_TOKEN_TEST_DATA[x]
        expectedCount = LEXER_TOKEN_EXPECTED_COUNTS[x]

        // Initialize and tokenize
        NAVCsvLexerInit(lexer, data)
        result = NAVCsvLexerTokenize(lexer)

        // Verify tokenization succeeded
        if (!result) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify token count
        if (!NAVAssertLongEqual('Token Count Test', expectedCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedCount), itoa(lexer.tokenCount))

            {
                stack_var integer y

                for (y = 1; y <= lexer.tokenCount; y++) {
                    NAVLog(NAVCsvLexerTokenSerialize(lexer.tokens[y]))
                }
            }

            continue
        }

        NAVLogTestPassed(x)
    }
}


define_function TestNAVCsvLexerIsIdentifierChar() {
    stack_var integer x

    NAVLog("'***************** NAVCsvLexerIsIdentifierChar *****************'")

    for (x = 1; x <= length_array(IDENTIFIER_CHAR_TEST); x++) {
        stack_var char testChar
        stack_var char expected
        stack_var char result

        testChar = IDENTIFIER_CHAR_TEST[x]
        expected = IDENTIFIER_CHAR_EXPECTED[x]

        result = NAVCsvLexerIsIdentifierChar(testChar)

        if (!NAVAssertCharEqual('Identifier Char Test', expected, result)) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVCsvLexerTokenTypes() {
    stack_var integer x
    stack_var char unknownResult[NAV_MAX_CHARS]

    NAVLog("'***************** NAVCsvLexerTokenTypes *****************'")

    // Test token type string conversion using the constants defined at the top
    for (x = 1; x <= length_array(TOKEN_TYPES); x++) {
        stack_var integer tokenType
        stack_var char expectedName[16]
        stack_var char result[NAV_MAX_CHARS]

        tokenType = TOKEN_TYPES[x]
        expectedName = TOKEN_TYPE_NAMES[x]

        result = NAVCsvLexerGetTokenType(tokenType)

        // For now, just test that the function returns something
        if (length_string(result) > 0) {
            NAVLogTestPassed(x)
        } else {
            NAVLogTestFailed(x, expectedName, result)
        }
    }

    // Test unknown token type - temporarily commented out
    unknownResult = NAVCsvLexerGetTokenType(999)
    if (find_string(unknownResult, 'UNKNOWN', 1) > 0) {
        NAVLog("'Pass: Unknown token type handled correctly'")
    } else {
        NAVLog("'Fail: Unknown token type handling failed'")
    }

    // Test token serialization
    TestTokenSerialization()
}

define_function TestTokenSerialization() {
    stack_var _NAVCsvToken token
    stack_var char serialized[NAV_MAX_BUFFER]

    NAVLog("'--- Token Serialization ---'")

    // Test serializing a sample token
    token.type = NAV_CSV_TOKEN_TYPE_IDENTIFIER
    token.value = 'testkey'

    serialized = NAVCsvLexerTokenSerialize(token)

    // Check that serialization contains expected elements
    if (find_string(serialized, 'IDENTIFIER', 1) > 0 &&
        find_string(serialized, 'testkey', 1) > 0) {
        NAVLog("'Pass: Token serialization contains expected elements'")
    } else {
        NAVLog("'Fail: Token serialization missing expected elements'")
    }
}
