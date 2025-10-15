/**
 * Tests for NAVFoundation CSV Lexer Backslash Escape Extension
 *
 * This test suite validates the extended backslash escape functionality
 * that goes beyond RFC 4180 compliance.
 */

define_function TestNAVCsvLexerBackslashEscapes() {
    NAVLog("'***************** NAVCsvLexerBackslashEscapes *****************'")

    // Test 1: Backslash-n escape for newline
    TestBackslashEscapeNewline()

    // Test 2: Backslash-r escape for carriage return
    TestBackslashEscapeCarriageReturn()

    // Test 3: Backslash-t escape for tab
    TestBackslashEscapeTab()

    // Test 4: Backslash-backslash for literal backslash
    TestBackslashEscapeLiteralBackslash()

    // Test 5: Backslash-quote for literal quote
    TestBackslashEscapeLiteralQuote()

    // Test 6: Unknown escape sequence (backslash preserved)
    TestBackslashEscapeUnknownSequence()

    // Test 7: Multiple escapes in single field
    TestBackslashEscapeMultipleInField()

    // Test 8: Backslash at end of string (no escape)
    TestBackslashEscapeAtEnd()

    // Test 9: Mixed RFC 4180 and backslash escapes
    TestBackslashEscapeMixedWithDoubleQuote()

    // Test 10: Complex real-world scenario
    TestBackslashEscapeComplexScenario()
}

define_function TestBackslashEscapeNewline() {
    stack_var _NAVCsvLexer lexer
    stack_var char result

    NAVCsvLexerInit(lexer, '"line1\nline2"')
    result = NAVCsvLexerTokenize(lexer)

    if (!result) {
        NAVLogTestFailed(1, 'tokenization should succeed', 'failed')
    } else if (lexer.tokenCount != 2) {
        NAVLogTestFailed(1, '2 tokens expected (STRING + EOF)', itoa(lexer.tokenCount))
    } else if (lexer.tokens[1].type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLogTestFailed(1, 'token should be STRING', NAVCsvLexerTokenSerialize(lexer.tokens[1]))
    } else if (lexer.tokens[1].value != "'line1', NAV_LF, 'line2'") {
        NAVLogTestFailed(1, "'line1<LF>line2'", lexer.tokens[1].value)
    } else {
        NAVLogTestPassed(1)
    }
}

define_function TestBackslashEscapeCarriageReturn() {
    stack_var _NAVCsvLexer lexer
    stack_var char result

    NAVCsvLexerInit(lexer, '"line1\rline2"')
    result = NAVCsvLexerTokenize(lexer)

    if (!result) {
        NAVLogTestFailed(2, 'tokenization should succeed', 'failed')
    } else if (lexer.tokenCount != 2) {
        NAVLogTestFailed(2, '2 tokens expected (STRING + EOF)', itoa(lexer.tokenCount))
    } else if (lexer.tokens[1].type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLogTestFailed(2, 'token should be STRING', NAVCsvLexerTokenSerialize(lexer.tokens[1]))
    } else if (lexer.tokens[1].value != "'line1', NAV_CR, 'line2'") {
        NAVLogTestFailed(2, "'line1<CR>line2'", lexer.tokens[1].value)
    } else {
        NAVLogTestPassed(2)
    }
}

define_function TestBackslashEscapeTab() {
    stack_var _NAVCsvLexer lexer
    stack_var char result

    NAVCsvLexerInit(lexer, '"col1\tcol2"')
    result = NAVCsvLexerTokenize(lexer)

    if (!result) {
        NAVLogTestFailed(3, 'tokenization should succeed', 'failed')
    } else if (lexer.tokenCount != 2) {
        NAVLogTestFailed(3, '2 tokens expected (STRING + EOF)', itoa(lexer.tokenCount))
    } else if (lexer.tokens[1].type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLogTestFailed(3, 'token should be STRING', NAVCsvLexerTokenSerialize(lexer.tokens[1]))
    } else if (lexer.tokens[1].value != "'col1', NAV_TAB, 'col2'") {
        NAVLogTestFailed(3, "'col1<TAB>col2'", lexer.tokens[1].value)
    } else {
        NAVLogTestPassed(3)
    }
}

define_function TestBackslashEscapeLiteralBackslash() {
    stack_var _NAVCsvLexer lexer
    stack_var char result

    NAVCsvLexerInit(lexer, '"path\\file"')
    result = NAVCsvLexerTokenize(lexer)

    if (!result) {
        NAVLogTestFailed(4, 'tokenization should succeed', 'failed')
    } else if (lexer.tokenCount != 2) {
        NAVLogTestFailed(4, '2 tokens expected (STRING + EOF)', itoa(lexer.tokenCount))
    } else if (lexer.tokens[1].type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLogTestFailed(4, 'token should be STRING', NAVCsvLexerTokenSerialize(lexer.tokens[1]))
    } else if (lexer.tokens[1].value != 'path\file') {
        NAVLogTestFailed(4, "'path\file'", lexer.tokens[1].value)
    } else {
        NAVLogTestPassed(4)
    }
}

define_function TestBackslashEscapeLiteralQuote() {
    stack_var _NAVCsvLexer lexer
    stack_var char result

    NAVCsvLexerInit(lexer, '"say \"hello\""')
    result = NAVCsvLexerTokenize(lexer)

    if (!result) {
        NAVLogTestFailed(5, 'tokenization should succeed', 'failed')
    } else if (lexer.tokenCount != 2) {
        NAVLogTestFailed(5, '2 tokens expected (STRING + EOF)', itoa(lexer.tokenCount))
    } else if (lexer.tokens[1].type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLogTestFailed(5, 'token should be STRING', NAVCsvLexerTokenSerialize(lexer.tokens[1]))
    } else if (lexer.tokens[1].value != 'say "hello"') {
        NAVLogTestFailed(5, 'say "hello"', lexer.tokens[1].value)
    } else {
        NAVLogTestPassed(5)
    }
}

define_function TestBackslashEscapeUnknownSequence() {
    stack_var _NAVCsvLexer lexer
    stack_var char result

    NAVCsvLexerInit(lexer, '"test\xvalue"')
    result = NAVCsvLexerTokenize(lexer)

    if (!result) {
        NAVLogTestFailed(6, 'tokenization should succeed', 'failed')
    } else if (lexer.tokenCount != 2) {
        NAVLogTestFailed(6, '2 tokens expected (STRING + EOF)', itoa(lexer.tokenCount))
    } else if (lexer.tokens[1].type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLogTestFailed(6, 'token should be STRING', NAVCsvLexerTokenSerialize(lexer.tokens[1]))
    } else if (lexer.tokens[1].value != 'test\xvalue') {
        NAVLogTestFailed(6, "'test\xvalue (backslash preserved)'", lexer.tokens[1].value)
    } else {
        NAVLogTestPassed(6)
    }
}

define_function TestBackslashEscapeMultipleInField() {
    stack_var _NAVCsvLexer lexer
    stack_var char result

    NAVCsvLexerInit(lexer, '"line1\nline2\ttab\rcarriage"')
    result = NAVCsvLexerTokenize(lexer)

    if (!result) {
        NAVLogTestFailed(7, 'tokenization should succeed', 'failed')
    } else if (lexer.tokenCount != 2) {
        NAVLogTestFailed(7, '2 tokens expected (STRING + EOF)', itoa(lexer.tokenCount))
    } else if (lexer.tokens[1].type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLogTestFailed(7, 'token should be STRING', NAVCsvLexerTokenSerialize(lexer.tokens[1]))
    } else if (lexer.tokens[1].value != "'line1', NAV_LF, 'line2', NAV_TAB, 'tab', NAV_CR, 'carriage'") {
        NAVLogTestFailed(7, "'line1<LF>line2<TAB>tab<CR>carriage'", lexer.tokens[1].value)
    } else {
        NAVLogTestPassed(7)
    }
}

define_function TestBackslashEscapeAtEnd() {
    stack_var _NAVCsvLexer lexer
    stack_var char result

    NAVCsvLexerInit(lexer, '"test\"')
    result = NAVCsvLexerTokenize(lexer)

    if (!result) {
        NAVLogTestFailed(8, 'tokenization should succeed', 'failed')
    } else if (lexer.tokenCount != 2) {
        NAVLogTestFailed(8, '2 tokens expected (STRING + EOF)', itoa(lexer.tokenCount))
    } else if (lexer.tokens[1].type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLogTestFailed(8, 'token should be STRING', NAVCsvLexerTokenSerialize(lexer.tokens[1]))
    } else if (lexer.tokens[1].value != 'test\') {
        NAVLogTestFailed(8, "'test\ (backslash at end)'", lexer.tokens[1].value)
    } else {
        NAVLogTestPassed(8)
    }
}

define_function TestBackslashEscapeMixedWithDoubleQuote() {
    stack_var _NAVCsvLexer lexer
    stack_var char result

    NAVCsvLexerInit(lexer, '"say ""hi"" or \"hello\""')
    result = NAVCsvLexerTokenize(lexer)

    if (!result) {
        NAVLogTestFailed(9, 'tokenization should succeed', 'failed')
    } else if (lexer.tokenCount != 2) {
        NAVLogTestFailed(9, '2 tokens expected (STRING + EOF)', itoa(lexer.tokenCount))
    } else if (lexer.tokens[1].type != NAV_CSV_TOKEN_TYPE_STRING) {
        NAVLogTestFailed(9, 'token should be STRING', NAVCsvLexerTokenSerialize(lexer.tokens[1]))
    } else if (lexer.tokens[1].value != 'say "hi" or "hello"') {
        NAVLogTestFailed(9, 'say "hi" or "hello"', lexer.tokens[1].value)
    } else {
        NAVLogTestPassed(9)
    }
}

define_function TestBackslashEscapeComplexScenario() {
    stack_var _NAVCsvLexer lexer
    stack_var char result

    // CSV: "name","path","notes"
    // Row: "John Doe","C:\\Users\\john","Line1\nLine2\tTabbed"
    NAVCsvLexerInit(lexer, "'"name","path","notes"', 13, 10, '"John Doe","C:\\Users\\john","Line1\nLine2\tTabbed"'")
    result = NAVCsvLexerTokenize(lexer)

    if (!result) {
        NAVLogTestFailed(10, 'tokenization should succeed', 'failed')
    } else if (lexer.tokenCount != 12) {
        NAVLogTestFailed(10, '12 tokens expected', itoa(lexer.tokenCount))
    } else if (lexer.tokens[1].type != NAV_CSV_TOKEN_TYPE_STRING ||
               lexer.tokens[1].value != 'name') {
        NAVLogTestFailed(10, 'first field should be "name"', lexer.tokens[1].value)
    } else if (lexer.tokens[9].type != NAV_CSV_TOKEN_TYPE_STRING ||
               lexer.tokens[9].value != 'C:\Users\john') {
        NAVLogTestFailed(10, 'path should be "C:\Users\john"', lexer.tokens[9].value)
    } else if (lexer.tokens[11].type != NAV_CSV_TOKEN_TYPE_STRING ||
               lexer.tokens[11].value != "'Line1', NAV_LF, 'Line2', NAV_TAB, 'Tabbed'") {
        NAVLogTestFailed(10, 'notes should have LF and TAB', lexer.tokens[11].value)
    } else {
        NAVLogTestPassed(10)
    }
}
