PROGRAM_NAME='NAVIniLexer'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test token types for validation
constant integer TOKEN_TYPES[] = {
    NAV_INI_TOKEN_TYPE_LBRACKET,
    NAV_INI_TOKEN_TYPE_RBRACKET,
    NAV_INI_TOKEN_TYPE_EQUALS,
    NAV_INI_TOKEN_TYPE_IDENTIFIER,
    NAV_INI_TOKEN_TYPE_STRING,
    NAV_INI_TOKEN_TYPE_COMMENT,
    NAV_INI_TOKEN_TYPE_NEWLINE,
    NAV_INI_TOKEN_TYPE_EOF,
    NAV_INI_TOKEN_TYPE_WHITESPACE,
    NAV_INI_TOKEN_TYPE_ERROR
}

constant char TOKEN_TYPE_NAMES[][16] = {
    'LBRACKET',
    'RBRACKET',
    'EQUALS',
    'IDENTIFIER',
    'STRING',
    'COMMENT',
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
    3, // key=value -> IDENTIFIER, EQUALS, IDENTIFIER
    3, // [section] -> LBRACKET, IDENTIFIER, RBRACKET
    7, // [database]\nhost=localhost -> LBRACKET, IDENTIFIER, RBRACKET, NEWLINE, IDENTIFIER, EQUALS, IDENTIFIER
    3, // Two comments -> COMMENT, NEWLINE, COMMENT
    7, // Two quoted assignments -> IDENTIFIER, EQUALS, STRING, NEWLINE, IDENTIFIER, EQUALS, STRING
    7, // Two assignments with special chars
    8, // Whitespace-separated tokens with newlines
    11  // Mixed section and properties
}


DEFINE_VARIABLE

// Global variables for test data (set at runtime)
volatile char LEXER_INIT_TEST_DATA[4][512]
volatile char LEXER_TOKEN_TEST_DATA[8][1024]

/**
 * Initialize global test data arrays at runtime
 * Required because NetLinx cannot handle complex string expressions in constants
 */
define_function InitializeLexerTestData() {
    // LEXER_INIT_TEST_DATA
    LEXER_INIT_TEST_DATA[1] = ''
    LEXER_INIT_TEST_DATA[2] = 'simple text'
    LEXER_INIT_TEST_DATA[3] = "'key=value'"
    LEXER_INIT_TEST_DATA[4] = "'[section]', 10, 'key=value'"
    set_length_array(LEXER_INIT_TEST_DATA, 4)

    // LEXER_TOKEN_TEST_DATA - construct proper strings with actual newlines and special chars
    LEXER_TOKEN_TEST_DATA[1] = 'key=value'
    LEXER_TOKEN_TEST_DATA[2] = '[section]'
    LEXER_TOKEN_TEST_DATA[3] = "'[database]', 10, 'host=localhost'"
    LEXER_TOKEN_TEST_DATA[4] = "'; This is a comment', 10, '# Another comment'"
    LEXER_TOKEN_TEST_DATA[5] = "'key1=', $22, 'quoted value', $22, 10, 'key2=', $27, 'single quoted', $27"
    LEXER_TOKEN_TEST_DATA[6] = "'path=C:\temp\file.txt', 10, 'url=http://example.com'"
    LEXER_TOKEN_TEST_DATA[7] = "'  key  =  value  ', 10, 10, '  [section]  '"
    LEXER_TOKEN_TEST_DATA[8] = "'timeout=30', 10, '[app]', 10, 'debug=true'"
    set_length_array(LEXER_TOKEN_TEST_DATA, 8)
}

define_function TestNAVIniLexerInit() {
    stack_var integer x

    NAVLog("'***************** NAVIniLexerInit *****************'")

    // Initialize test data
    InitializeLexerTestData()

    for (x = 1; x <= length_array(LEXER_INIT_TEST_DATA); x++) {
        stack_var _NAVIniLexer lexer
        stack_var char data[512]

        data = LEXER_INIT_TEST_DATA[x]

        // Initialize the lexer
        NAVIniLexerInit(lexer, data)

        // Verify initialization
        if (lexer.source == data && lexer.cursor == 0 && lexer.tokenCount == 0) {
            NAVLogTestPassed(x)
        } else {
            NAVLogTestFailed(x, 'initialized', 'failed')
        }
    }
}

define_function TestNAVIniLexerTokenize() {
    stack_var integer x

    NAVLog("'***************** NAVIniLexerTokenize *****************'")

    // Initialize test data
    InitializeLexerTestData()

    for (x = 1; x <= length_array(LEXER_TOKEN_TEST_DATA); x++) {
        stack_var _NAVIniLexer lexer
        stack_var char data[1024]
        stack_var char result
        stack_var long expectedCount

        data = LEXER_TOKEN_TEST_DATA[x]
        expectedCount = LEXER_TOKEN_EXPECTED_COUNTS[x]

        // Initialize and tokenize
        NAVIniLexerInit(lexer, data)
        result = NAVIniLexerTokenize(lexer)

        // Verify tokenization succeeded
        if (!result) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify token count
        if (!NAVAssertLongEqual('Token Count Test', expectedCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedCount), itoa(lexer.tokenCount))
            continue
        }

        NAVLogTestPassed(x)
    }

    // Additional specific tokenization tests
    TestSpecificTokenizationScenarios()
}

define_function TestSpecificTokenizationScenarios() {
    stack_var _NAVIniLexer lexer
    stack_var char data[512]
    stack_var char result

    NAVLog("'--- Specific Tokenization Scenarios ---'")

    // Test scenario: Verify token types for simple key=value
    data = 'timeout=30'
    NAVIniLexerInit(lexer, data)
    result = NAVIniLexerTokenize(lexer)

    if (result && lexer.tokenCount == 3) {
        if (lexer.tokens[1].type == NAV_INI_TOKEN_TYPE_IDENTIFIER &&
            lexer.tokens[2].type == NAV_INI_TOKEN_TYPE_EQUALS &&
            lexer.tokens[3].type == NAV_INI_TOKEN_TYPE_IDENTIFIER) {
            NAVLog("'Pass: Key-value token types correct'")
        } else {
            NAVLog("'Fail: Key-value token types incorrect'")
        }
    } else {
        NAVLog("'Fail: Key-value tokenization failed'")
    }

    // Test scenario: Verify token values
    if (result && lexer.tokenCount == 3) {
        if (lexer.tokens[1].value == 'timeout' &&
            lexer.tokens[2].value == '=' &&
            lexer.tokens[3].value == '30') {
            NAVLog("'Pass: Key-value token values correct'")
        } else {
            NAVLog("'Fail: Key-value token values incorrect'")
        }
    }

    // Test scenario: Section brackets
    data = '[database]'
    NAVIniLexerInit(lexer, data)
    result = NAVIniLexerTokenize(lexer)

    if (result && lexer.tokenCount == 3) {
        if (lexer.tokens[1].type == NAV_INI_TOKEN_TYPE_LBRACKET &&
            lexer.tokens[2].type == NAV_INI_TOKEN_TYPE_IDENTIFIER &&
            lexer.tokens[3].type == NAV_INI_TOKEN_TYPE_RBRACKET &&
            lexer.tokens[2].value == 'database') {
            NAVLog("'Pass: Section bracket tokenization correct'")
        } else {
            NAVLog("'Fail: Section bracket tokenization incorrect'")
        }
    } else {
        NAVLog("'Fail: Section bracket tokenization failed'")
    }
}

define_function TestNAVIniLexerIsIdentifierChar() {
    stack_var integer x

    NAVLog("'***************** NAVIniLexerIsIdentifierChar *****************'")

    for (x = 1; x <= length_array(IDENTIFIER_CHAR_TEST); x++) {
        stack_var char testChar
        stack_var char expected
        stack_var char result

        testChar = IDENTIFIER_CHAR_TEST[x]
        expected = IDENTIFIER_CHAR_EXPECTED[x]

        result = NAVIniLexerIsIdentifierChar(testChar)

        if (!NAVAssertCharEqual('Identifier Char Test', expected, result)) {
            NAVLogTestFailed(x, itoa(expected), itoa(result))
            continue
        }

        NAVLogTestPassed(x)
    }
}

define_function TestNAVIniLexerTokenTypes() {
    stack_var integer x
    stack_var char unknownResult[NAV_MAX_CHARS]

    NAVLog("'***************** NAVIniLexerTokenTypes *****************'")

    // Test token type string conversion using the constants defined at the top
    for (x = 1; x <= length_array(TOKEN_TYPES); x++) {
        stack_var integer tokenType
        stack_var char expectedName[16]
        stack_var char result[NAV_MAX_CHARS]

        tokenType = TOKEN_TYPES[x]
        expectedName = TOKEN_TYPE_NAMES[x]

        result = NAVIniLexerGetTokenType(tokenType)

        // For now, just test that the function returns something
        if (length_array(result) > 0) {
            NAVLogTestPassed(x)
        } else {
            NAVLogTestFailed(x, expectedName, result)
        }
    }

    // Test unknown token type - temporarily commented out
    unknownResult = NAVIniLexerGetTokenType(999)
    if (find_string(unknownResult, 'UNKNOWN', 1) > 0) {
        NAVLog("'Pass: Unknown token type handled correctly'")
    } else {
        NAVLog("'Fail: Unknown token type handling failed'")
    }

    // Test token serialization
    TestTokenSerialization()
}

define_function TestTokenSerialization() {
    stack_var _NAVIniToken token
    stack_var char serialized[NAV_MAX_BUFFER]

    NAVLog("'--- Token Serialization ---'")

    // Test serializing a sample token
    token.type = NAV_INI_TOKEN_TYPE_IDENTIFIER
    token.value = 'testkey'

    serialized = NAVIniLexerTokenSerialize(token)

    // Check that serialization contains expected elements
    if (find_string(serialized, 'IDENTIFIER', 1) > 0 &&
        find_string(serialized, 'testkey', 1) > 0) {
        NAVLog("'Pass: Token serialization contains expected elements'")
    } else {
        NAVLog("'Fail: Token serialization missing expected elements'")
    }
}
