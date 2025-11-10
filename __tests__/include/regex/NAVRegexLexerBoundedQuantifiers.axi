PROGRAM_NAME='NAVRegexLexerBoundedQuantifiers'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_LEXER_BOUNDED_QUANTIFIERS_PATTERN_TEST[][255] = {
    '/a{3}/',           // 1: Bounded quantifier - exact count
    '/\d{5}/',          // 2: Bounded quantifier - exact count with metacharacter
    '/b{2,4}/',         // 3: Bounded quantifier - range
    '/\w{1,10}/',       // 4: Bounded quantifier - range with metacharacter
    '/c{1,}/',          // 5: Bounded quantifier - unlimited (one or more)
    '/\s{0,}/',         // 6: Bounded quantifier - unlimited (zero or more)
    '/d{0}/',           // 7: Bounded quantifier - zero occurrences
    '/e{100}/',         // 8: Bounded quantifier - large count
    '/\d{3}\.\d{3}/',   // 9: Bounded quantifier with literal character
    '/[a-z]{2,5}/',     // 10: Bounded quantifier with character class
    '/^\w{3,}$/'        // 11: Bounded quantifier with anchors
}

constant integer REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_TOKENS[][] = {
    {
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_WHITESPACE,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_DIGIT,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_EOF
    },
    {
        REGEX_TOKEN_BEGIN,
        REGEX_TOKEN_ALPHA,
        REGEX_TOKEN_QUANTIFIER,
        REGEX_TOKEN_END,
        REGEX_TOKEN_EOF
    }
}

// Expected min/max values for each quantifier
// Each test may have multiple quantifiers, so we use 2D arrays
constant sinteger REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_MIN[][] = {
    { 3 },              // 1: {3} - exact count
    { 5 },              // 2: {5} - exact count
    { 2 },              // 3: {2,4} - range
    { 1 },              // 4: {1,10} - range
    { 1 },              // 5: {1,} - unlimited
    { 0 },              // 6: {0,} - unlimited
    { 0 },              // 7: {0} - zero
    { 100 },            // 8: {100} - large count
    { 3, 3 },           // 9: {3} and {3} - two quantifiers
    { 2 },              // 10: {2,5} - range
    { 3 }               // 11: {3,} - unlimited
}

constant sinteger REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_MAX[][] = {
    { 3 },              // 1: {3} - exact count (min=max)
    { 5 },              // 2: {5} - exact count (min=max)
    { 4 },              // 3: {2,4} - range
    { 10 },             // 4: {1,10} - range
    { -1 },             // 5: {1,} - unlimited (-1 means no limit)
    { -1 },             // 6: {0,} - unlimited (-1 means no limit)
    { 0 },              // 7: {0} - zero
    { 100 },            // 8: {100} - large count (min=max)
    { 3, 3 },           // 9: {3} and {3} - two quantifiers
    { 5 },              // 10: {2,5} - range
    { -1 }              // 11: {3,} - unlimited (-1 means no limit)
}


define_function TestNAVRegexLexerBoundedQuantifiers() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Bounded Quantifiers *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_BOUNDED_QUANTIFIERS_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_BOUNDED_QUANTIFIERS_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, itoa(expectedTokenCount), itoa(lexer.tokenCount))
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, NAVRegexLexerGetTokenType(REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_TOKENS[x][y]), NAVRegexLexerGetTokenType(lexer.tokens[y].type))
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}


/**
 * @function TestNAVRegexLexerBoundedQuantifiersValues
 * @public
 * @description Validates that quantifier min/max values are correctly parsed.
 *
 * This test verifies that the lexer properly extracts the numeric bounds
 * from bounded quantifiers like {3}, {2,4}, {1,}, etc.
 *
 * For each test pattern:
 * - Finds all QUANTIFIER tokens
 * - Verifies the min value matches expected
 * - Verifies the max value matches expected (-1 for unlimited)
 *
 * Example validations:
 * - /a{3}/ → min=3, max=3
 * - /b{2,4}/ → min=2, max=4
 * - /c{1,}/ → min=1, max=-1 (unlimited)
 */
define_function TestNAVRegexLexerBoundedQuantifiersValues() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Bounded Quantifiers Values *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_MIN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer quantifierIndex
        stack_var integer y

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_BOUNDED_QUANTIFIERS_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, "'Pattern: ', REGEX_LEXER_BOUNDED_QUANTIFIERS_PATTERN_TEST[x]", "'Tokenization failed'")
            continue
        }

        // Find all QUANTIFIER tokens and validate their min/max values
        quantifierIndex = 0
        for (y = 1; y <= lexer.tokenCount; y++) {
            if (lexer.tokens[y].type == REGEX_TOKEN_QUANTIFIER) {
                quantifierIndex++

                // Validate min value
                if (!NAVAssertSignedIntegerEqual("'Quantifier ', itoa(quantifierIndex), ' min should be correct'",
                                          REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_MIN[x][quantifierIndex],
                                          lexer.tokens[y].min)) {
                    NAVLogTestFailed(x,
                                    itoa(REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_MIN[x][quantifierIndex]),
                                    itoa(lexer.tokens[y].min))
                    break
                }

                // Validate max value
                if (!NAVAssertSignedIntegerEqual("'Quantifier ', itoa(quantifierIndex), ' max should be correct'",
                                          REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_MAX[x][quantifierIndex],
                                          lexer.tokens[y].max)) {
                    NAVLogTestFailed(x,
                                    itoa(REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_MAX[x][quantifierIndex]),
                                    itoa(lexer.tokens[y].max))
                    break
                }
            }
        }

        // Verify we found the expected number of quantifiers
        if (!NAVAssertIntegerEqual('Should have correct number of quantifiers',
                                   length_array(REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_MIN[x]),
                                   quantifierIndex)) {
            NAVLogTestFailed(x,
                            itoa(length_array(REGEX_LEXER_BOUNDED_QUANTIFIERS_EXPECTED_MIN[x])),
                            itoa(quantifierIndex))
            continue
        }

        NAVLogTestPassed(x)
    }
}






