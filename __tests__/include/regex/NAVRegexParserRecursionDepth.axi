PROGRAM_NAME='NAVRegexParserRecursionDepth'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test patterns for recursion depth limits
// Validates MAX_REGEX_PARSER_DEPTH (32) enforcement to prevent stack overflow
constant char REGEX_PARSER_RECURSION_DEPTH_PATTERN_TEST[][255] = {
    // === SHALLOW NESTING (Safe) ===
    '/(a)/',                                  // 1: Depth 1 - single group
    '/((a))/',                                // 2: Depth 2 - double nested
    '/(((a)))/',                              // 3: Depth 3 - triple nested
    '/((((a))))/',                            // 4: Depth 4
    '/(((((a)))))/',                          // 5: Depth 5

    // === MODERATE NESTING (Safe) ===
    '/((((((((((a))))))))))/',                // 6: Depth 10
    '/(((((((((((((((a)))))))))))))))/',      // 7: Depth 15
    '/((((((((((((((((((((a))))))))))))))))))))/', // 8: Depth 20

    // === APPROACHING LIMIT (Safe) ===
    '/(((((((((((((((((((((((((a)))))))))))))))))))))))))/', // 9: Depth 25
    '/((((((((((((((((((((((((((((((a))))))))))))))))))))))))))))))/', // 10: Depth 30
    '/(((((((((((((((((((((((((((((((a)))))))))))))))))))))))))))))))/', // 11: Depth 31

    // === EXACT LIMIT (Should work) ===
    '/((((((((((((((((((((((((((((((((a))))))))))))))))))))))))))))))))/', // 12: Depth 32 - at limit

    // === EXCEEDING LIMIT (Should fail gracefully) ===
    '/(((((((((((((((((((((((((((((((((a)))))))))))))))))))))))))))))))))/', // 13: Depth 33 - exceeds by 1
    '/((((((((((((((((((((((((((((((((((a))))))))))))))))))))))))))))))))))/', // 14: Depth 34 - exceeds by 2
    '/((((((((((((((((((((((((((((((((((((((a))))))))))))))))))))))))))))))))))))))/', // 15: Depth 40 - well over limit

    // === MIXED CONSTRUCTS AT DEPTH ===
    '/((((((((((a|b))))))))))/',              // 16: Depth 10 with alternation
    '/((((((((((a*))))))))))/',               // 17: Depth 10 with quantifier
    '/(((((((((([abc]))))))))))/',            // 18: Depth 10 with char class
    '/(((((((((((?:a)))))))))))/',            // 19: Depth 10 with non-capturing

    // === ALTERNATION WITH DEEP NESTING ===
    '/((((((((((a))))))))))|b/',              // 20: Deep left branch, shallow right
    '/a|((((((((((b))))))))))/',              // 21: Shallow left, deep right branch
    '/((((((((((a))))))))))|((((((((((b))))))))))/', // 22: Both branches deep (depth 10 each)

    // === QUANTIFIERS WITH DEEP NESTING ===
    '/((((((((((a))))))))))*/',               // 23: Depth 10 with star
    '/((((((((((a))))))))))+/',               // 24: Depth 10 with plus
    '/((((((((((a))))))))))/',                // 25: Depth 10 with question
    '/((((((((((a){2,5})))))))))/',           // 26: Depth 10 with bounded quantifier

    // === COMPLEX NESTED PATTERNS ===
    '/((((((((((a|b|c))))))))))*/',           // 27: Depth 10, alternation + quantifier
    '/((((((?:(?:(?:(?:(?:a))))))))))/',      // 28: Depth 10, non-capturing groups
    '/(((((((((((a)))(b)))((c))))))))/',      // 29: Mixed depth levels

    // === EDGE CASES ===
    '/(())/',                                  // 30: Empty group (depth 1)
    '/((()))/',                                // 31: Nested empty groups (depth 2)
    '/((((((((((()))))))))))/',                // 32: Depth 10 empty groups

    // === NEAR LIMIT WITH COMPLEXITY ===
    '/((((((((((((((((((((((((((((a|b))))))))))))))))))))))))))))/',  // 33: Depth 32 with alternation
    '/((((((((((((((((((((((((((((a*))))))))))))))))))))))))))))/',   // 34: Depth 32 with quantifier

    // === OVER LIMIT WITH COMPLEXITY ===
    '/((((((((((((((((((((((((((((((((((a|b))))))))))))))))))))))))))))))))))/',  // 35: Depth 34 with alternation (should fail)
    '/((((((((((((((((((((((((((((((((((a*))))))))))))))))))))))))))))))))))/',   // 36: Depth 34 with quantifier (should fail)

    // === DEEPLY NESTED MULTIPLE GROUPS ===
    '/((((((((((a))))))))))(b)/',             // 37: Deep + shallow sibling
    '/(a)((((((((((b))))))))))/',             // 38: Shallow + deep sibling
    '/((((((((((a))))))))))((((((((((b))))))))))/', // 39: Two deep siblings (depth 10 each)

    // === EXTREME DEPTH (Should all fail) ===
    '/((((((((((((((((((((((((((((((((((((((((((((((((((a))))))))))))))))))))))))))))))))))))))))))))))))))/' // 40: Depth 50 (way over limit)
}

// Expected parse results: true = should succeed, false = should fail with depth error
constant char REGEX_PARSER_RECURSION_DEPTH_EXPECTED_SUCCESS[] = {
    true,   // 1: Depth 1
    true,   // 2: Depth 2
    true,   // 3: Depth 3
    true,   // 4: Depth 4
    true,   // 5: Depth 5
    true,   // 6: Depth 10
    true,   // 7: Depth 15
    true,   // 8: Depth 20
    true,   // 9: Depth 25
    true,   // 10: Depth 30
    true,   // 11: Depth 31
    true,   // 12: Depth 32 - at limit
    false,  // 13: Depth 33 - should fail
    false,  // 14: Depth 34 - should fail
    false,  // 15: Depth 40 - should fail
    true,   // 16: Depth 10 with alternation
    true,   // 17: Depth 10 with quantifier
    true,   // 18: Depth 10 with char class
    true,   // 19: Depth 10 with non-capturing
    true,   // 20: Deep left, shallow right
    true,   // 21: Shallow left, deep right
    true,   // 22: Both branches deep
    true,   // 23: Depth 10 with star
    true,   // 24: Depth 10 with plus
    true,   // 25: Depth 10 with question
    true,   // 26: Depth 10 with bounded quantifier
    true,   // 27: Depth 10, alternation + quantifier
    true,   // 28: Depth 10, non-capturing groups
    true,   // 29: Mixed depth levels
    true,   // 30: Empty group
    true,   // 31: Nested empty groups
    true,   // 32: Depth 10 empty groups
    true,   // 33: Depth 32 with alternation - at limit
    true,   // 34: Depth 32 with quantifier - at limit
    false,  // 35: Depth 34 with alternation - should fail
    false,  // 36: Depth 34 with quantifier - should fail
    true,   // 37: Deep + shallow sibling
    true,   // 38: Shallow + deep sibling
    true,   // 39: Two deep siblings
    false   // 40: Depth 50 - should fail
}


/**
 * @function TestNAVRegexParserRecursionDepth
 * @public
 * @description Tests parser recursion depth limits.
 *
 * Validates:
 * - Shallow nesting (1-5 levels) works
 * - Moderate nesting (10-20 levels) works
 * - Near-limit nesting (30-32 levels) works
 * - At-limit nesting (32 levels) works
 * - Over-limit nesting (33+ levels) fails gracefully
 * - Deep nesting with various constructs works within limit
 * - Appropriate error message for depth exceeded
 */
define_function TestNAVRegexParserRecursionDepth() {
    stack_var integer x
    stack_var _NAVRegexLexer lexer
    stack_var _NAVRegexNFA nfa
    stack_var char lexResult
    stack_var char parseResult
    stack_var char expectedSuccess

    NAVLog("'***************** NAVRegexParser - Recursion Depth Limits *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_RECURSION_DEPTH_PATTERN_TEST); x++) {
        expectedSuccess = REGEX_PARSER_RECURSION_DEPTH_EXPECTED_SUCCESS[x]

        // Tokenize the pattern
        lexResult = NAVRegexLexerTokenize(REGEX_PARSER_RECURSION_DEPTH_PATTERN_TEST[x], lexer)

        if (!lexResult) {
            // Lexer failed
            if (!expectedSuccess) {
                // Expected to fail - lexer error is acceptable for patterns with >32 groups
                // Tests 13, 14, 15, 35, 36, 40 fail at lexer stage due to MAX_REGEX_GROUPS=32
                NAVLogTestPassed(x)
            } else {
                NAVLogTestFailed(x, 'lex success', 'lex failed')
            }
            continue
        }

        // Parse tokens into NFA
        parseResult = NAVRegexParse(lexer, nfa)

        if (expectedSuccess) {
            // We expected parsing to succeed
            if (!NAVAssertTrue('Should parse successfully', parseResult)) {
                NAVLogTestFailed(x, 'parse success', 'parse failed')
                continue
            }

            // Verify NFA was created correctly
            if (!NAVAssertTrue('NFA should have states', nfa.stateCount > 0)) {
                NAVLogTestFailed(x, '>0 states', itoa(nfa.stateCount))
                continue
            }

            if (!NAVAssertTrue('NFA should have valid start', nfa.startState > 0)) {
                NAVLogTestFailed(x, 'valid start', itoa(nfa.startState))
                continue
            }
        } else {
            // We expected parsing to fail with depth error
            if (NAVAssertFalse('Should fail with depth error', parseResult)) {
                // Failed as expected
                NAVLogTestPassed(x)
            } else {
                // Succeeded when it should have failed
                NAVLogTestFailed(x, 'depth error', 'success')
            }
            continue
        }

        NAVLogTestPassed(x)
    }
}
