PROGRAM_NAME='NAVRegexParserFlags'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test patterns for flag handling
constant char REGEX_PARSER_FLAG_PATTERN_TEST[][255] = {
    // Case-insensitive flag
    '/(?i)a/',              // 1: Case-insensitive literal
    '/(?i)[a-z]/',          // 2: Case-insensitive with char class
    '/(?i)test/',           // 3: Case-insensitive multi-char

    // Multiline flag
    '/(?m)^test/',          // 4: Multiline with start anchor
    '/(?m)test$/',          // 5: Multiline with end anchor

    // Dotall flag
    '/(?s)./',              // 6: Dotall with single dot
    '/(?s).+/',             // 7: Dotall with quantified dot

    // Combined flags
    '/(?im)test/',          // 8: Case-insensitive + multiline
    '/(?is)a.b/',           // 9: Case-insensitive + dotall
    '/(?ims)test/',         // 10: All three main flags

    // Flag in middle of pattern
    '/a(?i)b/'              // 11: Flag after literal
}

// Expected active flags after processing pattern
constant integer REGEX_PARSER_FLAG_EXPECTED_FLAGS[] = {
    PARSER_FLAG_CASE_INSENSITIVE,                                   // 1
    PARSER_FLAG_CASE_INSENSITIVE,                                   // 2
    PARSER_FLAG_CASE_INSENSITIVE,                                   // 3
    PARSER_FLAG_MULTILINE,                                          // 4
    PARSER_FLAG_MULTILINE,                                          // 5
    PARSER_FLAG_DOTALL,                                             // 6
    PARSER_FLAG_DOTALL,                                             // 7
    (PARSER_FLAG_CASE_INSENSITIVE bor PARSER_FLAG_MULTILINE),      // 8
    (PARSER_FLAG_CASE_INSENSITIVE bor PARSER_FLAG_DOTALL),         // 9
    (PARSER_FLAG_CASE_INSENSITIVE bor PARSER_FLAG_MULTILINE bor PARSER_FLAG_DOTALL), // 10
    PARSER_FLAG_CASE_INSENSITIVE                                    // 11
}


/**
 * @function TestNAVRegexParserFlags
 * @public
 * @description Tests flag handling in the parser.
 *
 * Validates:
 * - Flags can be set and checked
 * - Multiple flags can be combined
 * - Flag stack operations (push/pop)
 * - Flags are applied to states during construction
 */
define_function TestNAVRegexParserFlags() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Flag Handling *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_FLAG_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment result
        stack_var integer y
        stack_var integer expectedFlags

        // Tokenize the pattern
        if (!NAVRegexLexerTokenize(REGEX_PARSER_FLAG_PATTERN_TEST[x], lexer)) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        // Initialize parser
        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'parser init success', 'parser init failed')
            continue
        }

        // NEW: Verify lexer set flag group metadata correctly for GROUP_START tokens
        for (y = 1; y <= lexer.tokenCount; y++) {
            if (lexer.tokens[y].type == REGEX_TOKEN_GROUP_START) {
                // All patterns in this test are global flag groups (no colon)
                // They should have isGlobalFlagGroup=true, isScopedFlagGroup=false
                if (y + 1 <= lexer.tokenCount &&
                    (lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_CASE_INSENSITIVE ||
                     lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_MULTILINE ||
                     lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_DOTALL ||
                     lexer.tokens[y + 1].type == REGEX_TOKEN_FLAG_EXTENDED)) {

                    // This is a flag group - verify it's marked as global
                    if (!NAVAssertIntegerEqual('isFlagGroup should be true', 1, lexer.tokens[y].groupInfo.isFlagGroup)) {
                        NAVLogTestFailed(x, '1', '0')
                        break
                    }

                    if (!NAVAssertIntegerEqual('isGlobalFlagGroup should be true', 1, lexer.tokens[y].groupInfo.isGlobalFlagGroup)) {
                        NAVLogTestFailed(x, '1', '0')
                        break
                    }

                    if (!NAVAssertIntegerEqual('isScopedFlagGroup should be false', 0, lexer.tokens[y].groupInfo.isScopedFlagGroup)) {
                        NAVLogTestFailed(x, '0', '1')
                        break
                    }

                    if (!NAVAssertIntegerEqual('hasColon should be false', 0, lexer.tokens[y].groupInfo.hasColon)) {
                        NAVLogTestFailed(x, '0', '1')
                        break
                    }
                }
            }
        }

        // Parse the full expression to test parser's use of metadata
        if (!NAVRegexParserParseExpression(parser, 1, lexer.tokenCount - 1, result)) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Verify final flag state matches expected
        expectedFlags = REGEX_PARSER_FLAG_EXPECTED_FLAGS[x]

        if (!NAVAssertIntegerEqual('Active flags should match expected', expectedFlags, parser.activeFlags)) {
            NAVLogTestFailed(x, itoa(expectedFlags), itoa(parser.activeFlags))
            continue
        }

        // Verify flag stack is back to zero (all scopes closed)
        // Global flags don't use the stack, so this should always be 0
        if (!NAVAssertIntegerEqual('Flag stack depth should be 0', 0, parser.flagStackDepth)) {
            NAVLogTestFailed(x, '0', itoa(parser.flagStackDepth))
            continue
        }

        // CRITICAL: Verify at least one state has the expected flags applied
        // This ensures the parser actually applied activeFlags to NFA states during construction,
        // not just tracked them in parser.activeFlags
        //
        // Note: DOTALL flag affects DOT states via matchesNewline field, not stateFlags
        if (expectedFlags != 0) {
            stack_var char foundStateWithFlags
            stack_var char foundApplicableState
            stack_var char shouldCheckLiterals
            stack_var char shouldCheckCharClasses
            stack_var char shouldCheckDotall
            stack_var char shouldCheckAnchors
            stack_var integer z

            foundStateWithFlags = false
            foundApplicableState = false

            // Determine what to check based on flags
            shouldCheckLiterals = ((expectedFlags band (PARSER_FLAG_CASE_INSENSITIVE bor PARSER_FLAG_MULTILINE)) != 0)
            shouldCheckCharClasses = ((expectedFlags band PARSER_FLAG_CASE_INSENSITIVE) != 0)
            shouldCheckDotall = ((expectedFlags band PARSER_FLAG_DOTALL) != 0)
            shouldCheckAnchors = ((expectedFlags band PARSER_FLAG_MULTILINE) != 0)

            // Check LITERAL states for case-insensitive/multiline flags
            if (shouldCheckLiterals) {
                for (z = 1; z <= parser.stateCount; z++) {
                    if (parser.states[z].type == NFA_STATE_LITERAL) {
                        foundApplicableState = true
                        // For LITERAL states, check if they have the expected flags
                        // (ignoring DOTALL flag which doesn't affect LITERALs)
                        if ((parser.states[z].stateFlags band (PARSER_FLAG_CASE_INSENSITIVE bor PARSER_FLAG_MULTILINE)) ==
                            (expectedFlags band (PARSER_FLAG_CASE_INSENSITIVE bor PARSER_FLAG_MULTILINE))) {
                            foundStateWithFlags = true
                            break
                        }
                    }
                }
            }

            // Check CHAR_CLASS states for case-insensitive flag
            // Character classes need CASE_INSENSITIVE flag for case folding (e.g., [a-z] matching 'A')
            if (!foundStateWithFlags && shouldCheckCharClasses) {
                for (z = 1; z <= parser.stateCount; z++) {
                    if (parser.states[z].type == NFA_STATE_CHAR_CLASS) {
                        foundApplicableState = true
                        // Check if char class has CASE_INSENSITIVE flag set
                        if ((parser.states[z].stateFlags band PARSER_FLAG_CASE_INSENSITIVE) != 0) {
                            foundStateWithFlags = true
                            break
                        }
                    }
                }
            }

            // Check DOT states for DOTALL flag (matchesNewline field)
            if (!foundStateWithFlags && shouldCheckDotall) {
                for (z = 1; z <= parser.stateCount; z++) {
                    if (parser.states[z].type == NFA_STATE_DOT) {
                        foundApplicableState = true
                        if (parser.states[z].matchesNewline) {
                            foundStateWithFlags = true
                            break
                        }
                    }
                }
            }

            // Check ANCHOR states for MULTILINE flag
            // Anchors (^ and $) need MULTILINE flag to match line boundaries
            if (!foundStateWithFlags && shouldCheckAnchors) {
                for (z = 1; z <= parser.stateCount; z++) {
                    if (parser.states[z].type == NFA_STATE_BEGIN ||
                        parser.states[z].type == NFA_STATE_END) {
                        foundApplicableState = true
                        // Check if anchor has MULTILINE flag set
                        if ((parser.states[z].stateFlags band PARSER_FLAG_MULTILINE) != 0) {
                            foundStateWithFlags = true
                            break
                        }
                    }
                }
            }

            // Verify we found at least one state with the expected flags
            if (foundApplicableState) {
                if (!NAVAssertTrue('At least one state should have expected flags applied', foundStateWithFlags)) {
                    NAVLogTestFailed(x, "'State with flags 0x', format('%02X', expectedFlags)", 'No state found with expected flags')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
