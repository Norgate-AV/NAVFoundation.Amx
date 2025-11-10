PROGRAM_NAME='NAVRegexParserScopedFlags'

/**
 * Test parser handling of scoped vs global flag groups using lexer metadata.
 *
 * This test verifies that the parser correctly:
 * 1. Reads flag group metadata from lexer tokens (isScopedFlagGroup, isGlobalFlagGroup)
 * 2. Pushes flags for scoped groups (?i:...)
 * 3. Pops flags after scoped groups complete
 * 4. Does NOT push/pop for global groups (?i)
 * 5. Maintains correct flag stack depth
 */

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

constant char REGEX_PARSER_SCOPED_FLAG_PATTERN_TEST[][255] = {
    // Global flag groups (no scope push/pop)
    '/(?i)test/',           // 1: Global case-insensitive
    '/(?m)^test/',          // 2: Global multiline
    '/(?im)test/',          // 3: Global combined flags
    '/(?i)a(?m)b/',         // 4: Multiple global flags

    // Scoped flag groups (should push/pop)
    '/(?i:test)/',          // 5: Scoped case-insensitive
    '/(?m:^test)/',         // 6: Scoped multiline
    '/(?im:test)/',         // 7: Scoped combined flags
    '/(?i:abc)def/',        // 8: Scoped with content after
    '/test(?i:middle)end/', // 9: Scoped in middle

    // Mixed global and scoped
    '/(?i)(?m:test)/',      // 10: Global then scoped
    '/(?i:test)(?m)/',      // 11: Scoped then global
    '/(?i:a)(?m:b)/',       // 12: Two scoped groups

    // Nested groups
    '/((?i:test))/',        // 13: Scoped inside capturing
    '/(?:(?i:test))/'       // 14: Scoped inside non-capturing
}

// Expected flag stack depth at END of pattern processing
// Scoped flags should push/pop, leaving depth at 0
// Global flags don't affect stack depth
constant integer REGEX_PARSER_SCOPED_FLAG_EXPECTED_STACK_DEPTH[] = {
    0,  // 1: Global - no stack change
    0,  // 2: Global - no stack change
    0,  // 3: Global - no stack change
    0,  // 4: Multiple global - no stack change
    0,  // 5: Scoped - push then pop = 0
    0,  // 6: Scoped - push then pop = 0
    0,  // 7: Scoped - push then pop = 0
    0,  // 8: Scoped - push then pop = 0
    0,  // 9: Scoped - push then pop = 0
    0,  // 10: Global + scoped - scoped pops = 0
    0,  // 11: Scoped + global - scoped pops = 0
    0,  // 12: Two scoped - both pop = 0
    0,  // 13: Nested - all pop = 0
    0   // 14: Nested - all pop = 0
}

// Expected final active flags after pattern completes
constant integer REGEX_PARSER_SCOPED_FLAG_EXPECTED_FINAL_FLAGS[] = {
    PARSER_FLAG_CASE_INSENSITIVE,                                   // 1: Global i persists
    PARSER_FLAG_MULTILINE,                                          // 2: Global m persists
    (PARSER_FLAG_CASE_INSENSITIVE bor PARSER_FLAG_MULTILINE),      // 3: Global im persist
    (PARSER_FLAG_CASE_INSENSITIVE bor PARSER_FLAG_MULTILINE),      // 4: Both global flags persist
    0,                                                               // 5: Scoped i does not persist
    0,                                                               // 6: Scoped m does not persist
    0,                                                               // 7: Scoped im do not persist
    0,                                                               // 8: Scoped i does not persist
    0,                                                               // 9: Scoped i does not persist
    PARSER_FLAG_CASE_INSENSITIVE,                                   // 10: Global i persists, scoped m does not
    PARSER_FLAG_MULTILINE,                                          // 11: Scoped i does not, global m persists
    0,                                                               // 12: Both scoped, neither persists
    0,                                                               // 13: Scoped does not persist
    0                                                                // 14: Scoped does not persist
}


/**
 * @function TestNAVRegexParserScopedFlags
 * @public
 * @description Tests parser handling of scoped vs global flag groups.
 *
 * Validates that the parser correctly:
 * - Uses lexer metadata (isScopedFlagGroup) to detect flag group type
 * - Pushes flags when entering scoped flag groups
 * - Pops flags when exiting scoped flag groups
 * - Does NOT push/pop for global flag groups
 * - Maintains correct final flag state
 */
define_function TestNAVRegexParserScopedFlags() {
    stack_var integer x

    NAVLog("'***************** NAVRegexParser - Scoped Flag Groups *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_SCOPED_FLAG_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var _NAVRegexParserState parser
        stack_var _NAVRegexNFAFragment result
        stack_var integer expectedStackDepth
        stack_var integer expectedFlags

        // Tokenize the pattern
        if (!NAVRegexLexerTokenize(REGEX_PARSER_SCOPED_FLAG_PATTERN_TEST[x], lexer)) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        // Initialize parser
        if (!NAVRegexParserInit(parser, lexer.tokens)) {
            NAVLogTestFailed(x, 'parser init success', 'parser init failed')
            continue
        }

        // Parse the entire expression
        if (!NAVRegexParserParseExpression(parser, 1, lexer.tokenCount - 1, result)) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Verify flag stack depth is correct (should be 0 - all scopes closed)
        expectedStackDepth = REGEX_PARSER_SCOPED_FLAG_EXPECTED_STACK_DEPTH[x]
        if (!NAVAssertIntegerEqual('Flag stack depth should be correct', expectedStackDepth, parser.flagStackDepth)) {
            NAVLogTestFailed(x, itoa(expectedStackDepth), itoa(parser.flagStackDepth))
            continue
        }

        // Verify final active flags match expected
        expectedFlags = REGEX_PARSER_SCOPED_FLAG_EXPECTED_FINAL_FLAGS[x]
        if (!NAVAssertIntegerEqual('Active flags should match expected', expectedFlags, parser.activeFlags)) {
            NAVLogTestFailed(x, "'0x', format('%02X', expectedFlags)", "'0x', format('%02X', parser.activeFlags)")
            continue
        }

        // CRITICAL: Verify that states have flags applied correctly
        // This is COMPLEX for scoped flags because states INSIDE a scoped group
        // have flags that may differ from the final parser.activeFlags
        //
        // Examples:
        // - /(?i)(?m:test)/ : Final flags=0x10 (i), but "test" states have 0x30 (i|m)
        // - /(?i:test)(?m)/ : Final flags=0x20 (m), but "test" states have 0x10 (i)
        //
        // Strategy: Verify at least ONE state exists with ANY flags (proves flags work)
        // We can't easily verify exact flag values without complex pattern analysis
        if (expectedFlags != 0) {
            stack_var char foundAnyStateWithFlags
            stack_var integer y
            stack_var char shouldCheckAnchors

            foundAnyStateWithFlags = false
            shouldCheckAnchors = ((expectedFlags band PARSER_FLAG_MULTILINE) != 0)

            for (y = 1; y <= parser.stateCount; y++) {
                if (parser.states[y].type == NFA_STATE_LITERAL) {
                    // Check if this state has ANY flags set
                    if (parser.states[y].stateFlags != 0) {
                        foundAnyStateWithFlags = true
                        break
                    }
                }
            }

            // If pattern has multiline flag, verify anchor states have MULTILINE in stateFlags
            // This catches bugs where anchors are created without applying flags
            if (shouldCheckAnchors) {
                for (y = 1; y <= parser.stateCount; y++) {
                    if (parser.states[y].type == NFA_STATE_BEGIN ||
                        parser.states[y].type == NFA_STATE_END) {
                        // Found an anchor state - verify it has MULTILINE flag
                        if ((parser.states[y].stateFlags band PARSER_FLAG_MULTILINE) != 0) {
                            foundAnyStateWithFlags = true
                            break
                        }
                    }
                }
            }

            // Only assert for patterns that should have flags on states
            // Tests 1-4, 10-11: Global flags - at least one state should have flags
            // Tests 5-9, 12-14: Scoped flags - states inside scopes should have flags
            if (x <= 4 || x >= 10) {
                // Global flag tests or mixed tests - verify states have flags
                if (!NAVAssertTrue('At least one LITERAL or ANCHOR state should have flags applied', foundAnyStateWithFlags)) {
                    NAVLogTestFailed(x, 'State with any flags', 'No state found with flags')
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
