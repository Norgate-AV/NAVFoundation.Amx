PROGRAM_NAME='NAVRegexParserCharClass'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test configurations for character class building
constant char REGEX_PARSER_CHARCLASS_PATTERN[][255] = {
    '/[abc]/',          // 1: Simple character class
    '/[^abc]/',         // 2: Negated character class
    '/[a-z]/',          // 3: Range character class
    '/[^a-z]/',         // 4: Negated range character class
    '/[a-zA-Z]/',       // 5: Multiple ranges
    '/[^a-zA-Z]/',      // 6: Negated multiple ranges
    '/[0-9]/',          // 7: Numeric range
    '/[^0-9]/',         // 8: Negated numeric range
    '/[a-z0-9]/',       // 9: Mixed ranges
    '/[^a-z0-9]/',      // 10: Negated mixed ranges
    '/[.]/',            // 11: Literal dot in class
    '/[^.]/',           // 12: Negated literal dot
    '/[\d]/',           // 13: Escaped digit in class
    '/[^\d]/',          // 14: Negated escaped digit
    '/[a]/',            // 15: Single character
    '/[^a]/'            // 16: Negated single character
}

// Expected negation flag for each test
constant char REGEX_PARSER_CHARCLASS_EXPECTED_NEGATED[] = {
    false,  // 1: [abc] - not negated
    true,   // 2: [^abc] - negated
    false,  // 3: [a-z] - not negated
    true,   // 4: [^a-z] - negated
    false,  // 5: [a-zA-Z] - not negated
    true,   // 6: [^a-zA-Z] - negated
    false,  // 7: [0-9] - not negated
    true,   // 8: [^0-9] - negated
    false,  // 9: [a-z0-9] - not negated
    true,   // 10: [^a-z0-9] - negated
    false,  // 11: [.] - not negated
    true,   // 12: [^.] - negated
    false,  // 13: [\d] - not negated
    true,   // 14: [^\d] - negated
    false,  // 15: [a] - not negated
    true    // 16: [^a] - negated
}


/**
 * @function TestNAVRegexParserCharClass
 * @public
 * @description Unit tests for character class NFA state building.
 *
 * This test was added to catch Bug #7 where the parser's BuildCharClass
 * function was not synchronizing the state-level isNegated flag with the
 * charClass-level isNegated flag. The matcher relies on state.isNegated
 * but the parser only set charClass.isNegated.
 *
 * Validates:
 * - NAVRegexParserBuildCharClass() creates CHAR_CLASS states correctly
 * - State.isNegated flag is properly synchronized with charClass.isNegated
 * - Both normal and negated character classes are handled
 * - The internal state structure matches the lexer token
 */
define_function TestNAVRegexParserCharClass() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Character Class Building *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_CHARCLASS_PATTERN); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexNFA nfa
        stack_var integer charClassStateId
        stack_var char foundCharClassState

        // Tokenize the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_CHARCLASS_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        // Parse tokens into NFA
        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Find the CHAR_CLASS state in the NFA
        // It should be one of the first states created (usually state 2)
        foundCharClassState = false
        {
            stack_var integer stateIdx
            for (stateIdx = 1; stateIdx <= nfa.stateCount; stateIdx++) {
                if (nfa.states[stateIdx].type == NFA_STATE_CHAR_CLASS) {
                    charClassStateId = stateIdx
                    foundCharClassState = true
                    break
                }
            }
        }

        if (!NAVAssertTrue('Should have created CHAR_CLASS state', foundCharClassState)) {
            NAVLogTestFailed(x, 'CHAR_CLASS state found', 'no CHAR_CLASS state')
            continue
        }

        // CRITICAL TEST: Verify state.isNegated matches expected value
        if (!NAVAssertBooleanEqual('State.isNegated should match expected negation flag',
                                    REGEX_PARSER_CHARCLASS_EXPECTED_NEGATED[x],
                                    nfa.states[charClassStateId].isNegated)) {
            NAVLogTestFailed(x,
                           NAVBooleanToString(REGEX_PARSER_CHARCLASS_EXPECTED_NEGATED[x]),
                           NAVBooleanToString(nfa.states[charClassStateId].isNegated))
            continue
        }

        // Verify character class has valid content (either ranges or predefined classes)
        // Note: [\d] has rangeCount=0 but hasDigits=true
        {
            stack_var char hasContent
            hasContent = (nfa.states[charClassStateId].charClass.rangeCount > 0 ||
                         nfa.states[charClassStateId].charClass.hasDigits ||
                         nfa.states[charClassStateId].charClass.hasNonDigits ||
                         nfa.states[charClassStateId].charClass.hasWordChars ||
                         nfa.states[charClassStateId].charClass.hasNonWordChars ||
                         nfa.states[charClassStateId].charClass.hasWhitespace ||
                         nfa.states[charClassStateId].charClass.hasNonWhitespace)

            if (!NAVAssertTrue('CharClass should have ranges or predefined classes', hasContent)) {
                NAVLogTestFailed(x, 'has content', 'empty')
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
