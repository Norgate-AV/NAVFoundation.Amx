PROGRAM_NAME='NAVRegexParserAlternationGroupContext'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test patterns for alternation inside groups with surrounding context
// This tests for a critical bug where ProcessBranch resets fragment stack depth
// globally, wiping out fragments from parent parse context
//
// IMPORTANT: These tests must include MATCHING validation, not just parsing!
// The bug causes incorrect NFA state connections that only show up during matching.
constant char REGEX_PARSER_ALTERNATION_GROUP_PATTERN[][255] = {
    '/^(a|b)$/',                    // 1: Simple - anchors + group with alternation
    '/x(a|b)y/',                    // 2: Literals before and after group
    '/^(ftp|http|https):\/\//',     // 3: Real-world URL pattern (FTP bug case)
    '/(a|b)(c|d)/',                 // 4: Two sequential groups with alternation
    '/x(a|b)y(c|d)z/',              // 5: Multiple groups with surrounding literals
    '/^start(a|b|c)end$/',          // 6: Three-way alternation with anchors
    '/(red|green|blue)\d+/',        // 7: Word alternation + digit pattern
    '/\d+(alpha|beta)\w+/',         // 8: Digit + word alternation + word chars
    '/^(GET|POST|PUT|DELETE)\s/',   // 9: HTTP method pattern
    '/(a|b)x(c|d)y(e|f)z/',         // 10: Three alternation groups with separators
    '/prefix(a|b)middle(c|d)suffix/', // 11: Descriptive literals around groups
    '/^(on|off):(true|false)$/',    // 12: Boolean-like pattern
    '/(a|)x/',                      // 13: Empty right branch with trailing literal
    '/x(|b)/',                      // 14: Empty left branch with preceding literal
    '/^(a|b|c)/',                   // 15: Anchor only on left
    '/(a|b|c)$/',                   // 16: Anchor only on right
    '/\b(cat|dog|bird)\b/',         // 17: Word boundaries around alternation
    '/^(\d{1,3}|\w+)$/',            // 18: Quantified alternation with anchors
    '/(a+|b*)c/',                   // 19: Quantifiers in branches + trailing literal
    '/x(a|b)+y/',                   // 20: Quantified group with alternation
    '/((a|b))/',                    // 21: Nested groups with alternation
    '/x((a|b))y/',                  // 22: Nested groups with alternation + context
    '/(a(b|c)d)/',                  // 23: Alternation in nested inner group
    '/^((yes|no))$/',               // 24: Double-nested with anchors
    '/a(b|(c|d))e/'                 // 25: Deep alternation nesting with context
}

// Expected minimum state counts for these patterns
// Used to validate that NFA is actually being built (not returning early/failing silently)
constant integer REGEX_PARSER_ALTERNATION_GROUP_EXPECTED_MIN_STATES[] = {
    7,   // 1: ^(a|b)$ - anchor + group_start + split + 2 literals + group_end + anchor + accept
    8,   // 2: x(a|b)y - literal + group + split + 2 literals + group_end + literal + accept
    15,  // 3: ^(ftp|http|https):// - complex with 3 branches
    10,  // 4: (a|b)(c|d) - 2 groups with 2 splits
    14,  // 5: x(a|b)y(c|d)z - literals + 2 groups
    12,  // 6: ^start(a|b|c)end$ - 2 splits for 3 branches
    12,  // 7: (red|green|blue)\d+ - word split + char class
    12,  // 8: \d+(alpha|beta)\w+ - char classes + word split
    18,  // 9: ^(GET|POST|PUT|DELETE)\s - 3 splits for 4 branches
    14,  // 10: Three groups - multiple splits
    16,  // 11: Longer literals around groups
    12,  // 12: Two groups with anchors
    6,   // 13: Empty branch case
    6,   // 14: Empty branch case
    8,   // 15: Anchor + 2 splits
    8,   // 16: 2 splits + anchor
    10,  // 17: Boundaries + split
    10,  // 18: Quantified alternation
    8,   // 19: Quantifiers in branches
    9,   // 20: Group quantifier
    8,   // 21: Nested groups
    10,  // 22: Nested groups with context
    10,  // 23: Inner alternation
    9,   // 24: Double nested
    12   // 25: Deep nesting
}

// Expected capture group counts
constant integer REGEX_PARSER_ALTERNATION_GROUP_EXPECTED_GROUPS[] = {
    1,   // 1: One group
    1,   // 2: One group
    1,   // 3: One group
    2,   // 4: Two groups
    2,   // 5: Two groups
    1,   // 6: One group
    1,   // 7: One group
    1,   // 8: One group
    1,   // 9: One group
    3,   // 10: Three groups
    2,   // 11: Two groups
    2,   // 12: Two groups
    1,   // 13: One group
    1,   // 14: One group
    1,   // 15: One group
    1,   // 16: One group
    1,   // 17: One group
    1,   // 18: One group
    1,   // 19: One group
    1,   // 20: One group
    2,   // 21: Two groups (nested)
    2,   // 22: Two groups (nested)
    2,   // 23: Two groups (nested - inner alternation)
    2,   // 24: Two groups (double nested)
    2    // 25: Two groups (deep nesting)
}


/**
 * @function TestNAVRegexParserAlternationGroupContext
 * @public
 * @description Tests alternation inside groups with surrounding context.
 *
 * This test specifically targets a critical bug where ProcessBranch resets
 * the global fragment stack depth to 0, wiping out fragments pushed by
 * the parent parse context (like anchors or literals before the group).
 *
 * Bug manifestation in NFA structure:
 * - Pattern: /^(ftp|http|https):\/\//
 * - Expected: Start state → ANCHOR(^) → GROUP_START → SPLIT → branches
 * - Actual (bug): Start state connects directly to branch content, bypassing anchor
 * - Cause: ProcessBranch sets parser.fragmentStackDepth = 0, clearing parent's fragments
 *
 * This is a PARSER test - we validate NFA structure, not matching behavior.
 * Key validation: For patterns with anchors/literals before groups, the start state
 * MUST connect to those anchors/literals first, not directly to group content.
 */
define_function TestNAVRegexParserAlternationGroupContext() {
    stack_var integer x
    stack_var integer i
    stack_var _NAVRegexLexer lexer
    stack_var _NAVRegexNFA nfa
    stack_var integer startStateType
    stack_var char expectedStateFound

    NAVLog("'***************** NAVRegexParser - Alternation in Group Context *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_ALTERNATION_GROUP_PATTERN); x++) {

        // Tokenize the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_ALTERNATION_GROUP_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        // Parse tokens into NFA
        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Basic validation: NFA has states
        if (!NAVAssertTrue('NFA should have states', nfa.stateCount > 0)) {
            NAVLogTestFailed(x, '>0 states', itoa(nfa.stateCount))
            continue
        }

        // Verify NFA has valid start state
        if (!NAVAssertTrue('NFA should have valid start state', nfa.startState > 0 && nfa.startState <= nfa.stateCount)) {
            NAVLogTestFailed(x, 'valid start state', itoa(nfa.startState))
            continue
        }

        // CRITICAL BUG TEST: Verify what state type the START state connects to
        // For patterns starting with ^ anchor, the start state MUST connect to an ANCHOR state
        // For patterns starting with a literal (like 'x'), start MUST connect to LITERAL
        // If the bug exists, start will incorrectly connect to group internals

        // Determine expected first state type based on pattern
        expectedStateFound = false

        select {
            // Patterns starting with ^ anchor
            active (find_string(REGEX_PARSER_ALTERNATION_GROUP_PATTERN[x], '/^', 1) == 1): {
                // Start state should connect to BEGIN anchor
                if (nfa.states[nfa.startState].transitionCount > 0) {
                    stack_var integer firstTargetState
                    firstTargetState = nfa.states[nfa.startState].transitions[1].targetState
                    if (firstTargetState > 0 && firstTargetState <= nfa.stateCount) {
                        startStateType = nfa.states[firstTargetState].type
                        if (startStateType == NFA_STATE_BEGIN) {
                            expectedStateFound = true
                        }
                    }
                }

                if (!NAVAssertTrue('START should connect to BEGIN anchor', expectedStateFound)) {
                    NAVLogTestFailed(x, "'START -> BEGIN anchor'", "'START -> ', itoa(startStateType), ' (BUG: fragment stack corruption bypassed anchor)'")
                    continue
                }
            }

            // Patterns starting with word boundary
            active (find_string(REGEX_PARSER_ALTERNATION_GROUP_PATTERN[x], '/\b', 1) == 1): {
                if (nfa.states[nfa.startState].transitionCount > 0) {
                    stack_var integer firstTargetState
                    firstTargetState = nfa.states[nfa.startState].transitions[1].targetState
                    if (firstTargetState > 0 && firstTargetState <= nfa.stateCount) {
                        startStateType = nfa.states[firstTargetState].type
                        if (startStateType == NFA_STATE_WORD_BOUNDARY) {
                            expectedStateFound = true
                        }
                    }
                }

                if (!NAVAssertTrue('START should connect to WORD_BOUNDARY', expectedStateFound)) {
                    NAVLogTestFailed(x, "'START -> WORD_BOUNDARY'", "'START -> ', itoa(startStateType), ' (BUG detected)'")
                    continue
                }
            }

            // Patterns starting with literal before group (e.g., /x(a|b)y/)
            active (find_string(REGEX_PARSER_ALTERNATION_GROUP_PATTERN[x], '/x', 1) == 1): {
                if (nfa.states[nfa.startState].transitionCount > 0) {
                    stack_var integer firstTargetState
                    firstTargetState = nfa.states[nfa.startState].transitions[1].targetState
                    if (firstTargetState > 0 && firstTargetState <= nfa.stateCount) {
                        startStateType = nfa.states[firstTargetState].type
                        if (startStateType == NFA_STATE_LITERAL) {
                            expectedStateFound = true
                        }
                    }
                }

                if (!NAVAssertTrue('START should connect to LITERAL before group', expectedStateFound)) {
                    NAVLogTestFailed(x, "'START -> LITERAL(x)'", "'START -> ', itoa(startStateType), ' (BUG: should connect to literal before group)'")
                    continue
                }
            }

            // Patterns starting with 'a' literal (e.g., /a(b|(c|d))e/)
            active (find_string(REGEX_PARSER_ALTERNATION_GROUP_PATTERN[x], '/a', 1) == 1): {
                if (nfa.states[nfa.startState].transitionCount > 0) {
                    stack_var integer firstTargetState
                    firstTargetState = nfa.states[nfa.startState].transitions[1].targetState
                    if (firstTargetState > 0 && firstTargetState <= nfa.stateCount) {
                        startStateType = nfa.states[firstTargetState].type
                        if (startStateType == NFA_STATE_LITERAL) {
                            expectedStateFound = true
                        }
                    }
                }

                if (!NAVAssertTrue('START should connect to LITERAL before group', expectedStateFound)) {
                    NAVLogTestFailed(x, "'START -> LITERAL(a)'", "'START -> ', itoa(startStateType), ' (BUG: should connect to literal before group)'")
                    continue
                }
            }

            // Patterns starting with 'p' literal (e.g., /prefix(a|b).../)
            active (find_string(REGEX_PARSER_ALTERNATION_GROUP_PATTERN[x], '/p', 1) == 1): {
                if (nfa.states[nfa.startState].transitionCount > 0) {
                    stack_var integer firstTargetState
                    firstTargetState = nfa.states[nfa.startState].transitions[1].targetState
                    if (firstTargetState > 0 && firstTargetState <= nfa.stateCount) {
                        startStateType = nfa.states[firstTargetState].type
                        if (startStateType == NFA_STATE_LITERAL) {
                            expectedStateFound = true
                        }
                    }
                }

                if (!NAVAssertTrue('START should connect to LITERAL before group', expectedStateFound)) {
                    NAVLogTestFailed(x, "'START -> LITERAL(p)'", "'START -> ', itoa(startStateType), ' (BUG: should connect to literal before group)'")
                    continue
                }
            }

            // Patterns starting with \d (may be quantified like \d+)
            active (find_string(REGEX_PARSER_ALTERNATION_GROUP_PATTERN[x], '/\d', 1) == 1): {
                if (nfa.states[nfa.startState].transitionCount > 0) {
                    stack_var integer firstTargetState
                    firstTargetState = nfa.states[nfa.startState].transitions[1].targetState
                    if (firstTargetState > 0 && firstTargetState <= nfa.stateCount) {
                        startStateType = nfa.states[firstTargetState].type
                        // Accept CHAR_CLASS (generic), DIGIT (specific \d), or SPLIT (quantified like \d+)
                        if (startStateType == NFA_STATE_CHAR_CLASS ||
                            startStateType == NFA_STATE_DIGIT ||
                            startStateType == NFA_STATE_SPLIT) {
                            expectedStateFound = true
                        }
                    }
                }

                if (!NAVAssertTrue('START should connect to CHAR_CLASS, DIGIT, or SPLIT', expectedStateFound)) {
                    NAVLogTestFailed(x, "'START -> CHAR_CLASS/DIGIT/SPLIT'", "'START -> ', itoa(startStateType), ' (BUG detected)'")
                    continue
                }
            }

            // Default: patterns starting with group - start should connect to GROUP_START
            active (1): {
                if (nfa.states[nfa.startState].transitionCount > 0) {
                    stack_var integer firstTargetState
                    firstTargetState = nfa.states[nfa.startState].transitions[1].targetState
                    if (firstTargetState > 0 && firstTargetState <= nfa.stateCount) {
                        startStateType = nfa.states[firstTargetState].type
                        if (startStateType == NFA_STATE_CAPTURE_START || startStateType == NFA_STATE_SPLIT) {
                            expectedStateFound = true
                        }
                    }
                }

                if (!NAVAssertTrue('START should connect to GROUP_START or SPLIT', expectedStateFound)) {
                    NAVLogTestFailed(x, "'START -> GROUP_START or SPLIT'", "'START -> ', itoa(startStateType), ' (unexpected state type)'")
                    continue
                }
            }
        }

        // Verify state count meets minimum expected
        if (!NAVAssertTrue('NFA should have minimum states', nfa.stateCount >= REGEX_PARSER_ALTERNATION_GROUP_EXPECTED_MIN_STATES[x])) {
            NAVLogTestFailed(x, "'>= ', itoa(REGEX_PARSER_ALTERNATION_GROUP_EXPECTED_MIN_STATES[x]), ' states'", "itoa(nfa.stateCount), ' states'")
            continue
        }

        // Verify capture group count
        if (!NAVAssertIntegerEqual('Capture group count should match expected', REGEX_PARSER_ALTERNATION_GROUP_EXPECTED_GROUPS[x], nfa.captureGroupCount)) {
            NAVLogTestFailed(x, "itoa(REGEX_PARSER_ALTERNATION_GROUP_EXPECTED_GROUPS[x]), ' groups'", "itoa(nfa.captureGroupCount), ' groups'")
            continue
        }

        NAVLogTestPassed(x)
    }
}
