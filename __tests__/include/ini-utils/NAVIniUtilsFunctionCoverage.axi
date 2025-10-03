PROGRAM_NAME='NAVIniUtilsFunctionCoverage'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Test previously untested public functions
 */
define_function TestNAVIniUtilsFunctionCoverage() {
    NAVLog("'***************** NAVIniUtilsFunctionCoverage *****************'")

    TestNAVIniLexerHasMoreTokens()
    TestNAVIniParserHasMoreTokens()
    TestNAVIniLexerGetTokenType()
}

define_function TestNAVIniLexerHasMoreTokens() {
    stack_var _NAVIniLexer lexer
    stack_var char data[100]

    // Test 1: Empty source
    data = ''
    NAVIniLexerInit(lexer, data)
    if (!NAVIniLexerHasMoreTokens(lexer)) {
        NAVLogTestPassed(1)
    } else {
        NAVLogTestFailed(1, 'false', 'true')
    }

    // Test 2: Non-empty source
    data = 'key=value'
    NAVIniLexerInit(lexer, data)
    if (NAVIniLexerHasMoreTokens(lexer)) {
        NAVLogTestPassed(2)
    } else {
        NAVLogTestFailed(2, 'true', 'false')
    }

    // Test 3: After tokenization
    NAVIniLexerTokenize(lexer)
    if (!NAVIniLexerHasMoreTokens(lexer)) {
        NAVLogTestPassed(3)
    } else {
        NAVLogTestFailed(3, 'false', 'true')
    }
}

define_function TestNAVIniParserHasMoreTokens() {
    stack_var _NAVIniLexer lexer
    stack_var _NAVIniParser parser
    stack_var char data[100]

    // Test 1: Empty token array
    data = ''
    NAVIniLexerInit(lexer, data)
    NAVIniLexerTokenize(lexer)
    NAVIniParserInit(parser, lexer.tokens)

    if (!NAVIniParserHasMoreTokens(parser)) {
        NAVLogTestPassed(4)
    } else {
        NAVLogTestFailed(4, 'false', 'true')
    }

    // Test 2: With tokens
    data = 'key=value'
    NAVIniLexerInit(lexer, data)
    NAVIniLexerTokenize(lexer)
    NAVIniParserInit(parser, lexer.tokens)

    if (NAVIniParserHasMoreTokens(parser)) {
        NAVLogTestPassed(5)
    } else {
        NAVLogTestFailed(5, 'true', 'false')
    }
}

define_function TestNAVIniLexerGetTokenType() {
    stack_var char result[20]

    // Test all token types
    result = NAVIniLexerGetTokenType(NAV_INI_TOKEN_TYPE_LBRACKET)
    if (result == 'LBRACKET') {
        NAVLogTestPassed(6)
    } else {
        NAVLogTestFailed(6, 'LBRACKET', result)
    }

    result = NAVIniLexerGetTokenType(NAV_INI_TOKEN_TYPE_EOF)
    if (result == 'EOF') {
        NAVLogTestPassed(7)
    } else {
        NAVLogTestFailed(7, 'EOF', result)
    }

    // Test unknown token type
    result = NAVIniLexerGetTokenType(999)
    if (result == 'UNKNOWN') {
        NAVLogTestPassed(8)
    } else {
        NAVLogTestFailed(8, 'UNKNOWN', result)
    }
}
