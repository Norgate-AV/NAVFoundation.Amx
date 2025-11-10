PROGRAM_NAME='NAVRegexParserDiagnose'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

/**
 * Diagnostic test to examine what NFA the parser creates for specific patterns
 * This helps diagnose issues between parser and matcher
 */
define_function TestNAVRegexParserDiagnose() {
    stack_var _NAVRegexLexer lexer
    stack_var _NAVRegexNFA nfa
    stack_var _NAVRegexNFAFragment result
    stack_var char pattern[255]
    stack_var integer i, j

    NAVLog("'***************** NAVRegexParser - Diagnostic *****************'")

    // Test case 4 from the matcher tests that's failing: /(a)(b)/
    pattern = '/(a)(b)/'

    // Tokenize the pattern
    if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(pattern, lexer))) {
        NAVLogTestFailed(1, 'tokenize success', 'tokenize failed')
        return
    }

    // Parse tokens into NFA
    if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
        NAVLogTestFailed(1, 'parse success', 'parse failed')
        return
    }

    NAVLog("'========================================='")
    NAVLog("'Pattern: ', pattern")
    NAVLog("'========================================='")
    NAVLog("'NFA State Count: ', itoa(nfa.stateCount)")
    NAVLog("'NFA Start State: ', itoa(nfa.startState)")
    NAVLog("'NFA Accept State: ', itoa(nfa.acceptState)")
    NAVLog("'Current Group Number: ', itoa(nfa.currentGroup)")
    NAVLog("'========================================='")

    // Print all states with their details
    for (i = 1; i <= nfa.stateCount; i++) {
        NAVLog("'State ', format('%02d', i), ': type=', itoa(nfa.states[i].type), ' (', NAVRegexParserDiagnoseGetStateTypeName(nfa.states[i].type), ')'")

        if (nfa.states[i].type == NFA_STATE_LITERAL) {
            NAVLog("'         matchChar: ''', nfa.states[i].matchChar, ''' (ASCII ', format('%d', nfa.states[i].matchChar), ')'")
        }

        if (nfa.states[i].groupNumber > 0) {
            NAVLog("'         groupNumber: ', itoa(nfa.states[i].groupNumber)")
        }

        if (nfa.states[i].transitionCount > 0) {
            for (j = 1; j <= nfa.states[i].transitionCount; j++) {
                if (nfa.states[i].transitions[j].isEpsilon) {
                    NAVLog("'         --> [epsilon] --> state ', itoa(nfa.states[i].transitions[j].targetState)")
                } else {
                    NAVLog("'         --> [consume] --> state ', itoa(nfa.states[i].transitions[j].targetState)")
                }
            }
        } else {
            NAVLog("'         (no transitions)'")
        }
    }

    NAVLog("'========================================='")
    NAVLog("'Expected Structure for /(a)(b)/:'")
    NAVLog("'  Start -> CAPTURE_START(#1) -> LITERAL(a) -> CAPTURE_END(#1)'")
    NAVLog("'       -> CAPTURE_START(#2) -> LITERAL(b) -> CAPTURE_END(#2) -> Accept'")
    NAVLog("'========================================='")

    // Verify the structure looks reasonable
    NAVAssertTrue('Should have states', nfa.stateCount > 0)
    NAVAssertTrue('Should have start state', nfa.startState > 0)
    NAVAssertTrue('Should have accept state', nfa.acceptState > 0)
    NAVAssertTrue('Should have 2 capture groups', nfa.currentGroup == 2)
}

/**
 * Helper to get human-readable state type names
 */
define_function char[30] NAVRegexParserDiagnoseGetStateTypeName(integer stateType) {
    switch (stateType) {
        case NFA_STATE_EPSILON:              return 'EPSILON'
        case NFA_STATE_LITERAL:              return 'LITERAL'
        case NFA_STATE_DOT:                  return 'DOT'
        case NFA_STATE_CHAR_CLASS:           return 'CHAR_CLASS'
        case NFA_STATE_DIGIT:                return 'DIGIT'
        case NFA_STATE_NOT_DIGIT:            return 'NOT_DIGIT'
        case NFA_STATE_WORD:                 return 'WORD'
        case NFA_STATE_NOT_WORD:             return 'NOT_WORD'
        case NFA_STATE_WHITESPACE:           return 'WHITESPACE'
        case NFA_STATE_NOT_WHITESPACE:       return 'NOT_WHITESPACE'
        case NFA_STATE_SPLIT:                return 'SPLIT'
        case NFA_STATE_MATCH:                return 'MATCH'
        case NFA_STATE_CAPTURE_START:        return 'CAPTURE_START'
        case NFA_STATE_CAPTURE_END:          return 'CAPTURE_END'
        case NFA_STATE_BEGIN:                return 'BEGIN'
        case NFA_STATE_END:                  return 'END'
        case NFA_STATE_WORD_BOUNDARY:        return 'WORD_BOUNDARY'
        case NFA_STATE_NOT_WORD_BOUNDARY:    return 'NOT_WORD_BOUNDARY'
        case NFA_STATE_BACKREF:              return 'BACKREF'
        default:                             return 'UNKNOWN'
    }
}