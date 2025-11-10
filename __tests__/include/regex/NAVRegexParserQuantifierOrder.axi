PROGRAM_NAME='NAVRegexParserQuantifierOrder'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test type constants
constant integer QUANTIFIER_ORDER_GREEDY    = 1
constant integer QUANTIFIER_ORDER_LAZY      = 2

// Test patterns for greedy vs lazy quantifiers
constant char REGEX_PARSER_QUANTIFIER_ORDER_PATTERN[][255] = {
    '/a*/',             // 1: Greedy zero-or-more
    '/a*?/',            // 2: Lazy zero-or-more
    '/a+/',             // 3: Greedy one-or-more
    '/a+?/',            // 4: Lazy one-or-more
    '/a?/',             // 5: Greedy zero-or-one
    '/a??/',            // 6: Lazy zero-or-one
    '/a{2,5}/',         // 7: Greedy bounded
    '/a{2,5}?/',        // 8: Lazy bounded
    '/a{3,}/',          // 9: Greedy unbounded
    '/a{3,}?/',         // 10: Lazy unbounded
    '/(a|b)*/',         // 11: Greedy with alternation
    '/(a|b)*?/',        // 12: Lazy with alternation
    '/[abc]*/',         // 13: Greedy with char class
    '/[abc]*?/',        // 14: Lazy with char class
    '/\d+/',            // 15: Greedy with predefined class
    '/\d+?/',           // 16: Lazy with predefined class
    '/.+/',             // 17: Greedy with dot
    '/.+?/',            // 18: Lazy with dot
    '/(a*b*)*/',        // 19: Nested greedy
    '/(a*b*)*?/',       // 20: Nested with outer lazy
    '/a{0,}/',          // 21: Greedy unbounded from zero
    '/a{0,}?/'          // 22: Lazy unbounded from zero
}

constant integer REGEX_PARSER_QUANTIFIER_ORDER_TYPE[] = {
    QUANTIFIER_ORDER_GREEDY,    // 1
    QUANTIFIER_ORDER_LAZY,      // 2
    QUANTIFIER_ORDER_GREEDY,    // 3
    QUANTIFIER_ORDER_LAZY,      // 4
    QUANTIFIER_ORDER_GREEDY,    // 5
    QUANTIFIER_ORDER_LAZY,      // 6
    QUANTIFIER_ORDER_GREEDY,    // 7
    QUANTIFIER_ORDER_LAZY,      // 8
    QUANTIFIER_ORDER_GREEDY,    // 9
    QUANTIFIER_ORDER_LAZY,      // 10
    QUANTIFIER_ORDER_GREEDY,    // 11
    QUANTIFIER_ORDER_LAZY,      // 12
    QUANTIFIER_ORDER_GREEDY,    // 13
    QUANTIFIER_ORDER_LAZY,      // 14
    QUANTIFIER_ORDER_GREEDY,    // 15
    QUANTIFIER_ORDER_LAZY,      // 16
    QUANTIFIER_ORDER_GREEDY,    // 17
    QUANTIFIER_ORDER_LAZY,      // 18
    QUANTIFIER_ORDER_GREEDY,    // 19
    QUANTIFIER_ORDER_LAZY,      // 20
    QUANTIFIER_ORDER_GREEDY,    // 21
    QUANTIFIER_ORDER_LAZY       // 22
}


/**
 * @function TestNAVRegexParserQuantifierOrder
 * @public
 * @description Validates that SPLIT state transitions are in correct order.
 *
 * For greedy quantifiers (\*, +, ?, {n,m}):
 * - First transition should prefer matching (greedy = match more)
 * - Second transition should be the exit/skip path
 *
 * For lazy quantifiers (\*?, +?, ??, {n,m}?):
 * - First transition should prefer skipping (lazy = match less)
 * - Second transition should be the match path
 *
 * Why this matters:
 * - The matcher processes transitions in order
 * - Thread priority is assigned based on transition index
 * - Wrong order = greedy behaves like lazy or vice versa
 * - This affects which match is selected when multiple matches are possible
 *
 * Example: /a*\/ matching "aaa"
 * - Greedy: Should match "aaa" (try to match more)
 * - Lazy: Should match "" (try to match less)
 *
 * The SPLIT state determines this behavior through transition order.
 *
 * Note: This test uses heuristics to identify match vs skip paths. It may
 * need adjustment if parser implementation changes, but the principle of
 * validating transition order remains important.
 */
define_function TestNAVRegexParserQuantifierOrder() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Quantifier SPLIT Ordering *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_QUANTIFIER_ORDER_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer splitStateId
        stack_var char foundSplit
        stack_var integer orderType
        stack_var char matchPathFirst

        orderType = REGEX_PARSER_QUANTIFIER_ORDER_TYPE[x]

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_QUANTIFIER_ORDER_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Find the SPLIT state for the quantifier
        foundSplit = FindQuantifierSplitState(nfa, splitStateId)

        if (!NAVAssertTrue('Should find SPLIT state for quantifier', foundSplit)) {
            NAVLogTestFailed(x, 'SPLIT state found', 'SPLIT state not found')
            continue
        }

        // Analyze the transition order
        matchPathFirst = IsMatchPathFirst(nfa, splitStateId)

        // Validate based on expected order
        switch (orderType) {
            case QUANTIFIER_ORDER_GREEDY: {
                // Greedy: match path should be first (prefer more matches)
                if (!NAVAssertTrue('Greedy quantifier should have match path first', matchPathFirst)) {
                    NAVLogTestFailed(x,
                        "'Pattern ', REGEX_PARSER_QUANTIFIER_ORDER_PATTERN[x], ': SPLIT transitions[1] = match path'",
                        "'Pattern ', REGEX_PARSER_QUANTIFIER_ORDER_PATTERN[x], ': SPLIT transitions[1] = skip path (wrong for greedy)'")
                    continue
                }
            }

            case QUANTIFIER_ORDER_LAZY: {
                // Lazy: skip path should be first (prefer fewer matches)
                if (!NAVAssertFalse('Lazy quantifier should have skip path first', matchPathFirst)) {
                    NAVLogTestFailed(x,
                        "'Pattern ', REGEX_PARSER_QUANTIFIER_ORDER_PATTERN[x], ': SPLIT transitions[1] = skip path'",
                        "'Pattern ', REGEX_PARSER_QUANTIFIER_ORDER_PATTERN[x], ': SPLIT transitions[1] = match path (wrong for lazy)'")
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
