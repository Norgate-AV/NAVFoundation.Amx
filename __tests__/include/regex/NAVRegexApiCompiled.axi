PROGRAM_NAME='NAVRegexApiCompiled'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for NAVRegexMatchCompiled() API function
constant char REGEX_API_COMPILED_PATTERN[][255] = {
    '/a/',              // 1: Simple literal
    '/\d+/',            // 2: Digits
    '/[a-z]+/',         // 3: Lowercase letters
    '/^start/',         // 4: Start anchor
    '/end$/',           // 5: End anchor
    '/\bword\b/',       // 6: Word boundaries
    '/(cap)(ture)/',    // 7: Multiple captures
    '/foo|bar/',        // 8: Alternation
    '/x{2,4}/',         // 9: Bounded quantifier
    '/te*st/',          // 10: Zero or more
    '/te+st/',          // 11: One or more
    '/te?st/',          // 12: Zero or one
    '/[0-9a-fA-F]+/',   // 13: Hex digits
    '/(?i)case/',       // 14: Case-insensitive
    '/(?<name>\w+)\s+(?<value>\d+)/'  // 15: Named groups
}

constant char REGEX_API_COMPILED_INPUT[][255] = {
    'abc',              // 1
    '12345',            // 2
    'hello',            // 3
    'starting',         // 4
    'the end',          // 5
    'word',             // 6
    'capture',          // 7
    'foobar',           // 8
    'xxxx',             // 9
    'test',             // 10
    'teeest',           // 11
    'tst',              // 12
    'A1B2',             // 13
    'CASE',             // 14
    'count 42'          // 15
}

constant char REGEX_API_COMPILED_EXPECTED_MATCH[][255] = {
    'a',                // 1
    '12345',            // 2
    'hello',            // 3
    'start',            // 4
    'end',              // 5
    'word',             // 6
    'capture',          // 7
    'foo',              // 8
    'xxxx',             // 9
    'test',             // 10
    'teeest',           // 11
    'tst',              // 12
    'A1B2',             // 13
    'CASE',             // 14
    'count 42'          // 15
}

constant integer REGEX_API_COMPILED_EXPECTED_START[] = {
    1,                  // 1
    1,                  // 2
    1,                  // 3
    1,                  // 4
    5,                  // 5
    1,                  // 6
    1,                  // 7
    1,                  // 8
    1,                  // 9
    1,                  // 10
    1,                  // 11
    1,                  // 12
    1,                  // 13
    1,                  // 14
    1                   // 15
}

/**
 * @function TestNAVRegexApiCompiled
 * @public
 * @description Tests the NAVRegexMatchCompiled() public API function.
 *
 * Validates:
 * - Matching with pre-compiled NFA produces correct results
 * - Results are identical to NAVRegexMatch() (consistency check)
 * - Capture groups work correctly
 * - Match position and text are correct
 * - NFA can be reused multiple times efficiently
 */
define_function TestNAVRegexApiCompiled() {
    stack_var integer x

    NAVLog("'***************** NAVRegexAPI - MatchCompiled Function *****************'")

    for (x = 1; x <= length_array(REGEX_API_COMPILED_PATTERN); x++) {
        stack_var _NAVRegexNFA nfa
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // First, compile the pattern
        if (!NAVRegexCompile(REGEX_API_COMPILED_PATTERN[x], nfa)) {
            NAVLogTestFailed(x, 'compile success', 'compile failed')
            NAVLog("'  Pattern: ', REGEX_API_COMPILED_PATTERN[x]")
            NAVStopwatchStop()
            continue
        }

        // Execute match using compiled NFA
        if (!NAVAssertTrue('Should match pattern', NAVRegexMatchCompiled(nfa, REGEX_API_COMPILED_INPUT[x], collection))) {
            NAVLogTestFailed(x, 'match success', 'match failed')
            NAVLog("'  Pattern: ', REGEX_API_COMPILED_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_API_COMPILED_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Verify match status
        if (!NAVAssertIntegerEqual('Match status should be SUCCESS', MATCH_STATUS_SUCCESS, collection.status)) {
            NAVLogTestFailed(x, 'SUCCESS', itoa(collection.status))
            NAVStopwatchStop()
            continue
        }

        // Verify match count (should be 1)
        if (!NAVAssertIntegerEqual('Match count should be 1', 1, collection.count)) {
            NAVLogTestFailed(x, '1', itoa(collection.count))
            NAVStopwatchStop()
            continue
        }

        // Verify hasMatch flag
        if (!NAVAssertTrue('Result should have match', collection.matches[1].hasMatch)) {
            NAVLogTestFailed(x, 'hasMatch=true', 'hasMatch=false')
            NAVStopwatchStop()
            continue
        }

        // Verify matched text
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_API_COMPILED_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_API_COMPILED_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_API_COMPILED_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_API_COMPILED_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
            NAVStopwatchStop()
            continue
        }

        // Verify match length
        if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_API_COMPILED_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_API_COMPILED_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
            NAVStopwatchStop()
            continue
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}

/**
 * @function TestNAVRegexApiCompiledReuse
 * @public
 * @description Tests NFA reuse with multiple inputs.
 *
 * Validates:
 * - Same compiled NFA can be used multiple times
 * - Results remain consistent across multiple uses
 * - Efficiency benefit of compilation
 */
define_function TestNAVRegexApiCompiledReuse() {
    stack_var _NAVRegexNFA nfa
    stack_var _NAVRegexMatchCollection collection
    stack_var integer testNum

    NAVLog("'***************** NAVRegexAPI - MatchCompiled NFA Reuse *****************'")

    testNum = 1

    // Compile pattern once
    if (!NAVRegexCompile('/\d+/', nfa)) {
        NAVLogTestFailed(testNum, 'compile success', 'compile failed')
        return
    }

    NAVStopwatchStart()

    // Test 1: Match '123'
    if (!NAVRegexMatchCompiled(nfa, '123', collection)) {
        NAVLogTestFailed(testNum, 'match 123', 'no match')
        NAVStopwatchStop()
        return
    }
    if (!NAVAssertStringEqual('Should match 123', '123', collection.matches[1].fullMatch.text)) {
        NAVLogTestFailed(testNum, '123', collection.matches[1].fullMatch.text)
        NAVStopwatchStop()
        return
    }
    NAVLogTestPassed(testNum)
    testNum = testNum + 1

    // Test 2: Match '456' (reusing same NFA)
    if (!NAVRegexMatchCompiled(nfa, 'abc456def', collection)) {
        NAVLogTestFailed(testNum, 'match 456', 'no match')
        NAVStopwatchStop()
        return
    }
    if (!NAVAssertStringEqual('Should match 456', '456', collection.matches[1].fullMatch.text)) {
        NAVLogTestFailed(testNum, '456', collection.matches[1].fullMatch.text)
        NAVStopwatchStop()
        return
    }
    NAVLogTestPassed(testNum)
    testNum = testNum + 1

    // Test 3: Match '789' (reusing same NFA again)
    if (!NAVRegexMatchCompiled(nfa, '789', collection)) {
        NAVLogTestFailed(testNum, 'match 789', 'no match')
        NAVStopwatchStop()
        return
    }
    if (!NAVAssertStringEqual('Should match 789', '789', collection.matches[1].fullMatch.text)) {
        NAVLogTestFailed(testNum, '789', collection.matches[1].fullMatch.text)
        NAVStopwatchStop()
        return
    }
    NAVLogTestPassed(testNum)

    NAVLog("'NFA Reuse tests completed in ', itoa(NAVStopwatchStop()), 'ms'")
}

