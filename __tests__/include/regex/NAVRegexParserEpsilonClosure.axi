PROGRAM_NAME='NAVRegexParserEpsilonClosure'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Maximum depth for epsilon-closure simulation (safety limit)
constant integer EPSILON_CLOSURE_MAX_DEPTH = 1000

// Test patterns that could potentially create epsilon loops
constant char REGEX_PARSER_EPSILON_CLOSURE_PATTERN[][255] = {
    '/a/',              // 1: Simple literal (baseline)
    '/a*/',             // 2: Zero-or-more (basic quantifier)
    '/a+/',             // 3: One-or-more
    '/a?/',             // 4: Zero-or-one
    '/(a)*/',           // 5: Group in quantifier
    '/(a|b)*/',         // 6: Alternation in quantifier
    '/(?:a|b)*/',       // 7: Non-capturing alternation in quantifier
    '/(a*)*/',          // 8: Nested star (epsilon loop risk)
    '/(a+)*/',          // 9: Nested plus (epsilon loop risk)
    '/(a?)*/',          // 10: Nested optional (epsilon loop risk)
    '/((a)*)*/',        // 11: Deeply nested quantifiers
    '/(a|b|c)*/',       // 12: Multi-way alternation in quantifier
    '/a*b*/',           // 13: Sequential quantifiers
    '/a*b*c*/',         // 14: Three sequential quantifiers
    '/(a*b*)*/',        // 15: Nested sequential quantifiers
    '/a{0,5}/',         // 16: Bounded quantifier including zero
    '/a{0,}/',          // 17: Unbounded quantifier from zero
    '/(a{0,})*/',       // 18: Nested unbounded quantifier
    '/(?:)*/',          // 19: Empty non-capturing group with quantifier
    '/()*/',            // 20: Empty capturing group with quantifier (edge case)
    '/^*/',             // 21: Anchor with quantifier (should fail tokenization, but test parser robustness)
    '/(a|)*/',          // 22: Alternation with empty branch in quantifier
    '/a**/',            // 23: Double quantifier (should fail lexing, but test parser)
    '/(a|b)(c|d)*/',    // 24: Mixed alternation and quantifier
    '/a(b|c)*d/',       // 25: Quantifier in middle of sequence
    '/((a|b)*)*/',      // 26: Nested alternation-quantifier
    '/(a*)+(b*)*/',     // 27: Multiple quantified groups
    '/a{2,}*/',         // 28: Quantifier on quantified pattern (lexer may fail)
    '/(a?)+/',          // 29: Plus on optional
    '/(a+)?/'           // 30: Optional on plus
}

// Expected result for epsilon-closure termination
// Most should terminate; some may fail during lexing/parsing
constant char REGEX_PARSER_EPSILON_CLOSURE_SHOULD_TERMINATE[] = {
    true,   // 1: Simple literal
    true,   // 2: a*
    true,   // 3: a+
    true,   // 4: a?
    true,   // 5: (a)*
    true,   // 6: (a|b)*
    true,   // 7: (?:a|b)*
    true,   // 8: (a*)* - should terminate despite nesting
    true,   // 9: (a+)*
    true,   // 10: (a?)*
    true,   // 11: ((a)*)*
    true,   // 12: (a|b|c)*
    true,   // 13: a*b*
    true,   // 14: a*b*c*
    true,   // 15: (a*b*)*
    true,   // 16: a{0,5}
    true,   // 17: a{0,}
    true,   // 18: (a{0,})*
    true,   // 19: (?:)* - empty group
    true,   // 20: ()* - empty capture
    false,  // 21: ^* - should fail during tokenization
    true,   // 22: (a|)* - alternation with empty
    false,  // 23: a** - should fail during tokenization
    true,   // 24: (a|b)(c|d)*
    true,   // 25: a(b|c)*d
    true,   // 26: ((a|b)*)*
    true,   // 27: (a*)+(b*)*
    false,  // 28: a{2,}* - should fail during tokenization
    true,   // 29: (a?)+
    true    // 30: (a+)?
}


/**
 * @function TestNAVRegexParserEpsilonClosure
 * @public
 * @description Validates that epsilon-closure always terminates.
 *
 * This test detects infinite loops in epsilon transitions that would cause
 * the matcher to hang. It simulates the epsilon-closure algorithm starting
 * from the NFA start state and verifies:
 * - Epsilon-closure terminates (no infinite loops)
 * - Visited state count is reasonable (< stateCount * 2)
 * - No cycles in epsilon-only paths
 *
 * Why this matters:
 * - Infinite epsilon loop = matcher hangs forever
 * - The matcher relies on epsilon-closure completing to initialize thread lists
 * - Patterns like (a*\)* are prone to creating epsilon loops if parser is buggy
 *
 * Note: This test focuses on structural infinite loops. The recursion depth
 * test validates stack overflow prevention, which is a different concern.
 */
define_function TestNAVRegexParserEpsilonClosure() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Epsilon-Closure Termination *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_EPSILON_CLOSURE_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer visited[MAX_REGEX_NFA_STATES]
        stack_var integer visitedCount
        stack_var char terminated
        stack_var char shouldTerminate

        shouldTerminate = REGEX_PARSER_EPSILON_CLOSURE_SHOULD_TERMINATE[x]

        // Tokenize the pattern
        if (!NAVRegexLexerTokenize(REGEX_PARSER_EPSILON_CLOSURE_PATTERN[x], lexer)) {
            // Tokenization failed (expected for some patterns like ^*, a**)
            if (!shouldTerminate) {
                // Expected to fail
                NAVLogTestPassed(x)
                continue
            }
            else {
                NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
                continue
            }
        }

        // Parse tokens into NFA
        if (!NAVRegexParse(lexer, nfa)) {
            // Parsing failed (expected for some edge cases)
            if (!shouldTerminate) {
                // Expected to fail
                NAVLogTestPassed(x)
                continue
            }
            else {
                NAVLogTestFailed(x, 'parse success', 'parse failed')
                continue
            }
        }

        // Simulate epsilon-closure from start state
        visitedCount = 0
        terminated = SimulateEpsilonClosure(nfa, nfa.startState, visited, visitedCount, 1)

        if (!NAVAssertTrue('Epsilon-closure should terminate', terminated)) {
            NAVLogTestFailed(x,
                'epsilon-closure terminates',
                "'epsilon-closure infinite loop detected (depth > ', itoa(EPSILON_CLOSURE_MAX_DEPTH), ')'")
            continue
        }

        // Verify visited count is reasonable
        // In a well-formed NFA, epsilon-closure should visit at most 2x the number of states
        // (in worst case with many SPLIT states creating multiple paths)
        if (!NAVAssertTrue('Epsilon-closure should visit reasonable number of states',
                          visitedCount <= (nfa.stateCount * 2))) {
            NAVLogTestFailed(x,
                "'visited <= ', itoa(nfa.stateCount * 2)",
                "'visited = ', itoa(visitedCount), ' (stateCount = ', itoa(nfa.stateCount), ')'")
            continue
        }

        NAVLogTestPassed(x)
    }
}
