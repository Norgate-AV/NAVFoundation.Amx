PROGRAM_NAME='NAVRegexParserBasic'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_PARSER_BASIC_PATTERN_TEST[][255] = {
    '/a/',              // 1: Single literal character
    '/abc/',            // 2: Multiple literal characters
    '/\d/',             // 3: Single predefined class
    '/\w/',             // 4: Word character class
    '/\s/',             // 5: Whitespace character class
    '/[abc]/',          // 6: Simple character class
    '/[a-z]/',          // 7: Character class with range
    '/./',              // 8: Dot metacharacter
    '/^/',              // 9: Start anchor
    '/$/'               // 10: End anchor
}


/**
 * @function TestNAVRegexParserBasic
 * @public
 * @description Tests basic parser initialization and state management.
 *
 * Validates:
 * - Parser can initialize successfully with valid token stream
 * - Parser state is correctly initialized (counters, flags, error state)
 * - Start state is created during initialization
 * - Token stream is properly copied to parser state
 */
define_function TestNAVRegexParserBasic() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Basic Infrastructure *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_BASIC_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser

        // First, tokenize the pattern
        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_PARSER_BASIC_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Initialize parser with token stream
        if (!NAVAssertTrue('Should initialize parser', NAVRegexParserInit(parser, lexer.tokens))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify parser state initialization
        if (!NAVAssertIntegerEqual('Token count should match lexer', lexer.tokenCount, parser.tokenCount)) {
            NAVLogTestFailed(x, itoa(lexer.tokenCount), itoa(parser.tokenCount))
            continue
        }

        if (!NAVAssertIntegerEqual('Current token should be 1', 1, parser.currentToken)) {
            NAVLogTestFailed(x, '1', itoa(parser.currentToken))
            continue
        }

        if (!NAVAssertIntegerEqual('State count should be 1 (start state)', 1, parser.stateCount)) {
            NAVLogTestFailed(x, '1', itoa(parser.stateCount))
            continue
        }

        if (!NAVAssertIntegerEqual('Current group should be 0', 0, parser.currentGroup)) {
            NAVLogTestFailed(x, '0', itoa(parser.currentGroup))
            continue
        }

        if (!NAVAssertIntegerEqual('Flag stack depth should be 0', 0, parser.flagStackDepth)) {
            NAVLogTestFailed(x, '0', itoa(parser.flagStackDepth))
            continue
        }

        if (!NAVAssertFalse('Should not have error', parser.hasError)) {
            NAVLogTestFailed(x, 'false', 'true')
            continue
        }

        NAVLogTestPassed(x)
    }
}
