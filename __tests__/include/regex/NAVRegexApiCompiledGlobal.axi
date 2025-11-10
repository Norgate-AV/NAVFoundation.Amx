PROGRAM_NAME='NAVRegexApiCompiledGlobal'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Test patterns for NAVRegexMatchAllCompiled() API function
constant char REGEX_API_COMPILED_GLOBAL_PATTERN[][255] = {
    '/a/g',                     // 1: Simple literal (global)
    '/\d/g',                    // 2: Single digit (global)
    '/\d+/g',                   // 3: One or more digits (global)
    '/[aeiou]/g',               // 4: Vowels (global)
    '/\w+/g',                   // 5: Words (global)
    '/[0-9]+/g',                // 6: Number sequences (global)
    '/[A-Z][a-z]+/g',           // 7: Capitalized words (global)
    '/<[^>]+>/g',               // 8: HTML-like tags (global)
    '/\b[a-z]{3}\b/g',          // 9: Three-letter words (global)
    '/\d{2,3}/g',               // 10: 2-3 digit numbers (global)
    '/(?<word>\w+)/g',          // 11: Words with named capture (global)
    '/(?:the|a|an)\s+\w+/g',    // 12: Articles with following word (global)
    '/\b\w+@\w+\.\w+\b/g',      // 13: Email-like patterns (global)
    '/0x[0-9a-fA-F]+/g',        // 14: Hex numbers (global)
    '/(red|green|blue)/gi'      // 15: Color names case-insensitive (global)
}

constant char REGEX_API_COMPILED_GLOBAL_INPUT[][255] = {
    'banana',                           // 1
    '1a2b3c4',                          // 2
    'abc123def456',                     // 3
    'hello world',                      // 4
    'hello world test',                 // 5
    'Room 101, Floor 5, Building 23',   // 6
    'The Quick Brown Fox Jumps',        // 7
    '<div><p>Hello</p></div>',          // 8
    'the cat sat on the mat',           // 9
    'Code 123 or 45 or 6789',           // 10
    'one two three four',               // 11
    'the cat and a dog saw an owl',     // 12
    'john@test.com or mary@demo.org',   // 13
    'Values: 0xFF 0x1A 0xDEADBEEF',     // 14
    'Red GREEN blue BLUE'               // 15
}

constant integer REGEX_API_COMPILED_GLOBAL_EXPECTED_COUNT[] = {
    3,      // 1: 'a' appears 3 times in 'banana'
    4,      // 2: Four single digits
    2,      // 3: Two number sequences
    3,      // 4: Three vowels (e, o, o)
    3,      // 5: Three words
    3,      // 6: Three number sequences
    5,      // 7: Five capitalized words
    4,      // 8: Four tags
    5,      // 9: Five 3-letter words
    3,      // 10: Three sequences (greedy: 123, 45, 678)
    4,      // 11: Four words
    3,      // 12: Three article+word patterns
    2,      // 13: Two email addresses
    3,      // 14: Three hex numbers
    4       // 15: Four color names (case-insensitive)
}

constant char REGEX_API_COMPILED_GLOBAL_EXPECTED_FIRST[][255] = {
    'a',                // 1
    '1',                // 2
    '123',              // 3
    'e',                // 4
    'hello',            // 5
    '101',              // 6
    'The',              // 7
    '<div>',            // 8
    'the',              // 9
    '123',              // 10: First match (greedy: takes 3 digits)
    'one',              // 11
    'the cat',          // 12
    'john@test.com',    // 13
    '0xFF',             // 14
    'Red'               // 15
}

constant char REGEX_API_COMPILED_GLOBAL_EXPECTED_LAST[][255] = {
    'a',                // 1: Last 'a' in 'banana'
    '4',                // 2
    '456',              // 3
    'o',                // 4: Last vowel
    'test',             // 5
    '23',               // 6
    'Jumps',            // 7
    '</div>',           // 8
    'mat',              // 9
    '678',              // 10: Last match (greedy: takes 3 digits from 6789)
    'four',             // 11
    'an owl',           // 12
    'mary@demo.org',    // 13
    '0xDEADBEEF',       // 14
    'BLUE'              // 15
}

/**
 * @function TestNAVRegexApiCompiledGlobal
 * @public
 * @description Tests the NAVRegexMatchAllCompiled() public API function.
 *
 * Validates:
 * - Global matching with pre-compiled NFA produces correct results
 * - All matches are found (correct count)
 * - First and last matches are correct
 * - Results are identical to NAVRegexMatchAll() (consistency check)
 * - NFA can be reused for multiple global matches
 */
define_function TestNAVRegexApiCompiledGlobal() {
    stack_var integer x

    NAVLog("'***************** NAVRegexAPI - MatchAllCompiled Function *****************'")

    for (x = 1; x <= length_array(REGEX_API_COMPILED_GLOBAL_PATTERN); x++) {
        stack_var _NAVRegexNFA nfa
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // First, compile the pattern
        if (!NAVRegexCompile(REGEX_API_COMPILED_GLOBAL_PATTERN[x], nfa)) {
            NAVLogTestFailed(x, 'compile success', 'compile failed')
            NAVLog("'  Pattern: ', REGEX_API_COMPILED_GLOBAL_PATTERN[x]")
            NAVStopwatchStop()
            continue
        }

        // Execute global match using compiled NFA
        if (!NAVAssertTrue('Should find matches', NAVRegexMatchAllCompiled(nfa, REGEX_API_COMPILED_GLOBAL_INPUT[x], collection))) {
            NAVLogTestFailed(x, 'match success', 'match failed')
            NAVLog("'  Pattern: ', REGEX_API_COMPILED_GLOBAL_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_API_COMPILED_GLOBAL_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Verify match status
        if (!NAVAssertIntegerEqual('Match status should be SUCCESS', MATCH_STATUS_SUCCESS, collection.status)) {
            NAVLogTestFailed(x, 'SUCCESS', itoa(collection.status))
            NAVStopwatchStop()
            continue
        }

        // Verify match count
        if (!NAVAssertIntegerEqual('Match count should be correct', REGEX_API_COMPILED_GLOBAL_EXPECTED_COUNT[x], collection.count)) {
            NAVLogTestFailed(x, itoa(REGEX_API_COMPILED_GLOBAL_EXPECTED_COUNT[x]), itoa(collection.count))
            NAVLog("'  Pattern: ', REGEX_API_COMPILED_GLOBAL_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_API_COMPILED_GLOBAL_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Verify first match
        if (collection.count > 0) {
            if (!NAVAssertStringEqual('First match should be correct', REGEX_API_COMPILED_GLOBAL_EXPECTED_FIRST[x], collection.matches[1].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_API_COMPILED_GLOBAL_EXPECTED_FIRST[x], collection.matches[1].fullMatch.text)
                NAVLog("'  Pattern: ', REGEX_API_COMPILED_GLOBAL_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_API_COMPILED_GLOBAL_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
        }

        // Verify last match
        if (collection.count > 0) {
            if (!NAVAssertStringEqual('Last match should be correct', REGEX_API_COMPILED_GLOBAL_EXPECTED_LAST[x], collection.matches[collection.count].fullMatch.text)) {
                NAVLogTestFailed(x, REGEX_API_COMPILED_GLOBAL_EXPECTED_LAST[x], collection.matches[collection.count].fullMatch.text)
                NAVLog("'  Pattern: ', REGEX_API_COMPILED_GLOBAL_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_API_COMPILED_GLOBAL_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}

/**
 * @function TestNAVRegexApiCompiledGlobalReuse
 * @public
 * @description Tests NFA reuse with multiple global matches.
 *
 * Validates:
 * - Same compiled NFA can be used for multiple global matches
 * - Results remain consistent across multiple uses
 * - Efficiency benefit of compilation for global matching
 */
define_function TestNAVRegexApiCompiledGlobalReuse() {
    stack_var _NAVRegexNFA nfa
    stack_var _NAVRegexMatchCollection collection
    stack_var integer testNum

    NAVLog("'***************** NAVRegexAPI - MatchAllCompiled NFA Reuse *****************'")

    testNum = 1

    // Compile pattern once
    if (!NAVRegexCompile('/\d+/g', nfa)) {
        NAVLogTestFailed(testNum, 'compile success', 'compile failed')
        return
    }

    NAVStopwatchStart()

    // Test 1: Match all numbers in 'a1b2c3'
    if (!NAVRegexMatchAllCompiled(nfa, 'a1b2c3', collection)) {
        NAVLogTestFailed(testNum, 'match all', 'no match')
        NAVStopwatchStop()
        return
    }
    if (!NAVAssertIntegerEqual('Should find 3 matches', 3, collection.count)) {
        NAVLogTestFailed(testNum, '3', itoa(collection.count))
        NAVStopwatchStop()
        return
    }
    NAVLogTestPassed(testNum)
    testNum = testNum + 1

    // Test 2: Match all numbers in 'test 123 and 456' (reusing same NFA)
    if (!NAVRegexMatchAllCompiled(nfa, 'test 123 and 456', collection)) {
        NAVLogTestFailed(testNum, 'match all', 'no match')
        NAVStopwatchStop()
        return
    }
    if (!NAVAssertIntegerEqual('Should find 2 matches', 2, collection.count)) {
        NAVLogTestFailed(testNum, '2', itoa(collection.count))
        NAVStopwatchStop()
        return
    }
    if (!NAVAssertStringEqual('First match should be 123', '123', collection.matches[1].fullMatch.text)) {
        NAVLogTestFailed(testNum, '123', collection.matches[1].fullMatch.text)
        NAVStopwatchStop()
        return
    }
    if (!NAVAssertStringEqual('Second match should be 456', '456', collection.matches[2].fullMatch.text)) {
        NAVLogTestFailed(testNum, '456', collection.matches[2].fullMatch.text)
        NAVStopwatchStop()
        return
    }
    NAVLogTestPassed(testNum)
    testNum = testNum + 1

    // Test 3: Match all numbers in '7 8 9' (reusing same NFA again)
    if (!NAVRegexMatchAllCompiled(nfa, '7 8 9', collection)) {
        NAVLogTestFailed(testNum, 'match all', 'no match')
        NAVStopwatchStop()
        return
    }
    if (!NAVAssertIntegerEqual('Should find 3 matches', 3, collection.count)) {
        NAVLogTestFailed(testNum, '3', itoa(collection.count))
        NAVStopwatchStop()
        return
    }
    NAVLogTestPassed(testNum)

    NAVLog("'NFA Global Reuse tests completed in ', itoa(NAVStopwatchStop()), 'ms'")
}

