PROGRAM_NAME='NAVIniUtilsBoundsCheckingTest'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Test bounds checking functionality
 */
define_function TestNAVIniUtilsBoundsChecking() {
    NAVLog("'***************** NAVIniUtilsBoundsChecking *****************'")

    TestTokenLimitHandling()
    TestSectionLimitHandling()
    TestPropertyLimitHandling()
    TestStringLengthLimits()
}

define_function TestTokenLimitHandling() {
    stack_var _NAVIniLexer lexer
    stack_var char data[4096]
    stack_var integer i

    // Generate data that will exceed token limit
    data = ''
    for (i = 1; i <= 200; i++) {  // This should generate ~1200+ tokens
        data = "data, '[section', itoa(i), ']', 10"
        data = "data, 'key1=value1', 10"
        data = "data, 'key2=value2', 10"
        data = "data, 'key3=value3', 10, 10"
    }

    NAVIniLexerInit(lexer, data)

    if (!NAVIniLexerTokenize(lexer)) {
        NAVLogTestPassed(1) // Should fail gracefully
    } else {
        NAVLogTestFailed(1, 'tokenization failure', 'unexpected success')
    }
}

define_function TestSectionLimitHandling() {
    stack_var _NAVIniFile iniFile
    stack_var char data[4096]
    stack_var integer i

    // Generate data with >100 sections
    data = ''
    for (i = 1; i <= 105; i++) {
        data = "data, '[section', itoa(i), ']', 10, 'key=value', 10"
    }

    if (!NAVIniFileParse(data, iniFile)) {
        NAVLogTestPassed(2) // Should fail gracefully
    } else {
        NAVLogTestFailed(2, 'parsing failure', 'unexpected success')
    }
}

define_function TestPropertyLimitHandling() {
    stack_var _NAVIniFile iniFile
    stack_var char data[4096]
    stack_var integer i

    // Generate section with >100 properties
    data = '[test]'
    for (i = 1; i <= 105; i++) {
        data = "data, 10, 'prop', itoa(i), '=value', itoa(i)"
    }

    if (!NAVIniFileParse(data, iniFile)) {
        NAVLogTestPassed(3) // Should fail gracefully
    } else {
        NAVLogTestFailed(3, 'parsing failure', 'unexpected success')
    }
}

define_function TestStringLengthLimits() {
    stack_var _NAVIniFile iniFile
    stack_var char data[512]
    stack_var char longSection[100]
    stack_var integer i

    // Create section name > 64 chars
    longSection = ''
    for (i = 1; i <= 70; i++) {
        longSection = "longSection, 'x'"
    }

    data = "'[', longSection, ']', 10, 'key=value'"

    if (!NAVIniFileParse(data, iniFile)) {
        NAVLogTestPassed(4) // Should fail gracefully
    } else {
        NAVLogTestFailed(4, 'parsing failure', 'unexpected success')
    }
}
