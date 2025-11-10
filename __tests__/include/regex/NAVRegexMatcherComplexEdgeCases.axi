PROGRAM_NAME='NAVRegexMatcherComplexEdgeCases'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVFoundation.Stopwatch.axi'

DEFINE_CONSTANT

// Complex edge case patterns designed to stress-test the regex engine
// These are realistic patterns that are complex but within engine capabilities
constant char REGEX_COMPLEX_PATTERN[][255] = {
    // 1. Multiple nested groups with quantifiers
    '/^(a(b(c(d)*)*)*)*$/',

    // 2. Alternation with overlapping patterns
    '/^(abc|ab|a)d$/',

    // 3. Multiple backreferences
    '/^(\w+)-(\w+)-\1-\2$/',

    // 4. Character class edge cases
    '/^[a-zA-Z0-9_-]{3,}@[a-z]+\.[a-z]{2,4}$/',

    // 5. Greedy quantifiers followed by specific match
    '/^.*?(\d+)$/',

    // 6. Complex bounded quantifiers
    '/^(\d{2,4}-){2}\d{4}$/',

    // 7. Nested optional groups
    '/^(a(b(c)?)?)?d$/',

    // 8. Mixed character classes and groups
    '/^[A-Z][a-z]+(\s+[A-Z][a-z]+)*$/',

    // 9. Multiple alternations with groups
    '/^(foo|bar|baz)-(cat|dog|bird)$/',

    // 10. Backreference with quantifier
    '/^(\w)\1{2,4}$/',

    // 11. Complex nested alternation
    '/^((a|b)(c|d))+$/',

    // 12. Character class negation edge cases
    '/^[^0-9]*[0-9]+[^0-9]*$/',

    // 13. Word boundaries with complex content
    '/\b\w{3,}\b.*\b\w{3,}\b/',

    // 14. Multiple groups with different quantifiers
    '/^(a+)(b*)(c?)$/',

    // 15. Escaped characters in complex patterns
    '/^[\(\)\[\]\{\}]+$/',

    // 16. Lookahead with groups (if supported)
    '/^(?=.*\d)(?=.*[a-z])[a-z\d]{6,}$/',

    // 17. Complex hex pattern
    '/^0x[0-9a-fA-F]{2,8}$/',

    // 18. Multiple backreferences in sequence
    '/^(\d)(\d)\2\1$/',

    // 19. Nested quantifiers edge case
    '/^(a{2,3}){2,3}$/',

    // 20. Alternation with empty option
    '/^(hello|world|)!$/',

    // 21. Complex URL-like pattern
    '/^(https?):\/\/([a-z0-9.-]+)(:\d+)?(\/[^\s]*)?$/i',

    // 22. Repeated groups with backreferences
    '/^(([a-z])\2)-\1$/',

    // 23. Character class with special chars
    '/^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$/i',

    // 24. Multiple optional groups in sequence
    '/^a(b)?(c)?(d)?e$/',

    // 25. Complex bounded quantifier combinations
    '/^\d{1,3}(\.\d{1,3}){3}(:\d{1,5})?$/',

    // 26. Nested groups with alternation
    '/^((foo|bar)(baz|qux))+$/',

    // 27. Character range edge cases
    '/^[0-9a-fA-F_-]{8,16}$/',

    // 28. Multiple word boundaries
    '/\b[A-Z]\w*\b\s+\b[A-Z]\w*\b/',

    // 29. Complex negative character class
    '/^[^<>\/]+<\/[^>]+>$/',

    // 30. Greedy vs lazy quantifiers
    '/^".*?"/',

    // 31. Multiple levels of nested groups
    '/^(a(b(c(d)c)b)a)$/',

    // 32. Complex AMX channel pattern
    '/^(\d{1,5}):(\d{1,5}):(\d{1,5})-(CHAN|LVL|STR)$/',

    // 33. Alternation with quantified groups
    '/^(foo+|bar+|baz+)$/',

    // 34. Mixed anchors and groups
    '/^start-(.*?)-end$/',

    // 35. Complex password validation
    '/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/',

    // 36. Multiple backreferences with groups
    '/^([a-z]+)-(\d+)-\1-\2$/',

    // 37. Nested optional alternations
    '/^(a(b|c)?d)?e$/',

    // 38. Complex character escape sequences
    '/^\w+\s+\d+\s+\w+$/',

    // 39. Repeated pattern with boundary
    '/^(\b\w+\b\s*){3,5}$/',

    // 40. Complex log parsing pattern
    '/^\[(\d{4}-\d{2}-\d{2})\s+(\d{2}:\d{2}:\d{2})\]\s+(\w+):\s+(.+)$/',

    // 41. Quoted string with escapes
    '/"((?:[^"\\]|\\.)*)"/',

    // 42. Multiple character classes in sequence
    '/^[A-Z][a-z]+[0-9]+[A-Z]$/',

    // 43. Complex JSON-like key-value
    '/"(\w+)"\s*:\s*"([^"]*)"/',

    // 44. Nested quantifiers with groups
    '/^(a{2,}b{2,}){2,}$/',

    // 45. Multiple lookaheads (if supported)
    '/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/',

    // 46. Alternation with complex patterns
    '/^(([a-z]{3})|([0-9]{3}))$/',

    // 47. Backreference with nested groups
    '/^(([a-z])\2)-\1$/',

    // 48. Complex IP:Port pattern
    '/^((\d{1,3}\.){3}\d{1,3}):(\d{1,5})$/',

    // 49. Multiple word boundaries and groups
    '/\b(\w+)\s+and\s+\b(\w+)\b/',

    // 50. Complex version string
    '/^v?(\d+)\.(\d+)\.(\d+)(-([a-z]+)\.(\d+))?$/'
}

constant char REGEX_COMPLEX_INPUT[][255] = {
    'a',                                                            // 1
    'abcd',                                                         // 2
    'foo-bar-foo-bar',                                              // 3
    'test123@example.com',                                          // 4
    'abc123',                                                       // 5
    '12-34-5678',                                                   // 6
    'd',                                                            // 7
    'Hello World',                                                  // 8
    'foo-cat',                                                      // 9
    'aaaa',                                                         // 10
    'acbd',                                                         // 11
    'abc123def',                                                    // 12
    'hello world test',                                             // 13
    'aaabbbc',                                                      // 14: (c?) allows 0-1 'c', so input has exactly 1
    '()[]{}',                                                       // 15
    'abc123',                                                       // 16
    '0xDEADBEEF',                                                   // 17
    '1221',                                                         // 18
    'aaaaaa',                                                       // 19
    '!',                                                            // 20
    'https://example.com:8080/path',                                // 21
    'aa-aa',                                                        // 22
    'user@domain.com',                                              // 23
    'ae',                                                           // 24
    '192.168.1.1:8080',                                             // 25
    'foobazbarqux',                                                 // 26
    'DeadBeef1234',                                                 // 27: Valid hex chars only (o in Code is not hex)
    'Hello World',                                                  // 28
    'text</tag>',                                                   // 29
    '"hello"',                                                      // 30
    'abcdcba',                                                      // 31
    '1:2:3-CHAN',                                                   // 32
    'foooo',                                                        // 33
    'start-content-end',                                            // 34
    'P@ssw0rd',                                                     // 35
    'test-123-test-123',                                            // 36
    'e',                                                            // 37
    'hello 123 world',                                              // 38
    'one two three',                                                // 39
    '[2025-11-05 20:30:45] INFO: Test message',                     // 40
    '"test string"',                                                // 41
    'Hello123W',                                                    // 42
    '"key": "value"',                                               // 43
    'aabbaabb',                                                     // 44
    'Passw0rd',                                                     // 45
    'abc',                                                          // 46
    'aa-aa',                                                        // 47
    '192.168.1.100:8080',                                           // 48
    'foo and bar',                                                  // 49
    'v1.2.3-beta.5'                                                 // 50
}

constant char REGEX_COMPLEX_EXPECTED_MATCH[][255] = {
    'a',                                                            // 1
    'abcd',                                                         // 2
    'foo-bar-foo-bar',                                              // 3
    'test123@example.com',                                          // 4
    'abc123',                                                       // 5: Full match is entire string, not just captured group
    '12-34-5678',                                                   // 6
    'd',                                                            // 7
    'Hello World',                                                  // 8
    'foo-cat',                                                      // 9
    'aaaa',                                                         // 10
    'acbd',                                                         // 11
    'abc123def',                                                    // 12
    'hello world test',                                             // 13
    'aaabbbc',                                                      // 14: Changed to match input
    '()[]{}',                                                       // 15
    'abc123',                                                       // 16
    '0xDEADBEEF',                                                   // 17
    '1221',                                                         // 18
    'aaaaaa',                                                       // 19
    '!',                                                            // 20
    'https://example.com:8080/path',                                // 21
    'aa-aa',                                                        // 22
    'user@domain.com',                                              // 23
    'ae',                                                           // 24
    '192.168.1.1:8080',                                             // 25
    'foobazbarqux',                                                 // 26
    'DeadBeef1234',                                                 // 27: Changed to valid hex
    'Hello World',                                                  // 28
    'text</tag>',                                                   // 29
    '"hello"',                                                      // 30
    'abcdcba',                                                      // 31
    '1:2:3-CHAN',                                                   // 32
    'foooo',                                                        // 33
    'start-content-end',                                            // 34
    'P@ssw0rd',                                                     // 35
    'test-123-test-123',                                            // 36
    'e',                                                            // 37
    'hello 123 world',                                              // 38
    'one two three',                                                // 39
    '[2025-11-05 20:30:45] INFO: Test message',                     // 40
    '"test string"',                                                // 41
    'Hello123W',                                                    // 42
    '"key": "value"',                                               // 43
    'aabbaabb',                                                     // 44
    'Passw0rd',                                                     // 45
    'abc',                                                          // 46
    'aa-aa',                                                        // 47
    '192.168.1.100:8080',                                           // 48
    'foo and bar',                                                  // 49
    'v1.2.3-beta.5'                                                 // 50
}

constant integer REGEX_COMPLEX_EXPECTED_START[] = {
    1,  // 1
    1,  // 2
    1,  // 3
    1,  // 4
    1,  // 5: Full match "abc123" starts at position 1
    1,  // 6
    1,  // 7
    1,  // 8
    1,  // 9
    1,  // 10
    1,  // 11
    1,  // 12
    1,  // 13
    1,  // 14
    1,  // 15
    1,  // 16
    1,  // 17
    1,  // 18
    1,  // 19
    1,  // 20
    1,  // 21
    1,  // 22
    1,  // 23
    1,  // 24
    1,  // 25
    1,  // 26
    1,  // 27
    1,  // 28
    1,  // 29
    1,  // 30
    1,  // 31
    1,  // 32
    1,  // 33
    1,  // 34
    1,  // 35
    1,  // 36
    1,  // 37
    1,  // 38
    1,  // 39
    1,  // 40
    1,  // 41
    1,  // 42
    1,  // 43
    1,  // 44
    1,  // 45
    1,  // 46
    1,  // 47
    1,  // 48
    1,  // 49
    1   // 50
}

constant char REGEX_COMPLEX_SHOULD_MATCH[] = {
    true,   // 1: Nested groups
    true,   // 2: Alternation - /^(abc|ab|a)d$/ matches "abcd" (group captures "abc", then matches "d")
    true,   // 3: Multiple backreferences
    true,   // 4: Email-like pattern
    true,   // 5: Greedy quantifier with digits at end
    true,   // 6: Bounded quantifiers (phone-like)
    true,   // 7: Nested optional groups
    true,   // 8: Proper case name
    true,   // 9: Alternation with groups
    true,   // 10: Backreference with quantifier
    true,   // 11: Nested alternation repeated
    true,   // 12: Negated char class with digits
    true,   // 13: Word boundaries
    true,   // 14: Multiple groups with quantifiers
    true,   // 15: Escaped special chars
    true,   // 16: Lookahead password check
    true,   // 17: Hex number
    true,   // 18: Palindrome digits
    true,   // 19: Nested quantifiers
    true,   // 20: Alternation with empty
    true,   // 21: Complex URL
    true,   // 22: Repeated groups with backrefs
    true,   // 23: Email pattern
    true,   // 24: Multiple optionals
    true,   // 25: IP with port
    true,   // 26: Nested groups with alternation
    true,   // 27: Hex-like chars
    true,   // 28: Multiple word boundaries
    true,   // 29: Negative char class
    true,   // 30: Greedy vs lazy
    true,   // 31: Deep nesting
    true,   // 32: AMX channel format
    true,   // 33: Alternation with quantifiers
    true,   // 34: Anchors with lazy match
    true,   // 35: Complex password
    true,   // 36: Multiple backrefs with groups
    true,   // 37: Nested optional alternations
    true,   // 38: Escape sequences
    true,   // 39: Repeated pattern with boundary
    true,   // 40: Log parsing
    true,   // 41: Quoted string
    true,   // 42: Multiple char classes
    true,   // 43: JSON-like
    true,   // 44: Nested quantifiers with groups
    true,   // 45: Multiple lookaheads
    true,   // 46: Alternation with complex
    true,   // 47: Backref with nested groups
    true,   // 48: Complex IP:Port
    true,   // 49: Word boundaries and groups
    true    // 50: Complex version string
}

constant integer REGEX_COMPLEX_EXPECTED_GROUP_COUNT[] = {
    4,  // 1: (a(b(c(d)*)*)*)*
    0,  // 2: (abc|ab|a)d - groups but checking full match
    2,  // 3: (\w+)-(\w+)-\1-\2
    0,  // 4: Email - no groups to validate
    1,  // 5: .*?(\d+)
    1,  // 6: (\d{2,4}-){2}
    3,  // 7: (a(b(c)?)?)?d
    1,  // 8: [A-Z][a-z]+(\s+[A-Z][a-z]+)*
    2,  // 9: (foo|bar|baz)-(cat|dog|bird)
    1,  // 10: (\w)\1{2,4}
    3,  // 11: ((a|b)(c|d))+
    0,  // 12: Negated class - no groups to validate
    0,  // 13: Word boundary - groups but complex
    3,  // 14: (a+)(b*)(c?)
    0,  // 15: Escaped chars - no groups
    0,  // 16: Lookahead - complex
    0,  // 17: Hex - no groups
    2,  // 18: (\d)(\d)\2\1
    1,  // 19: (a{2,3}){2,3}
    1,  // 20: (hello|world|)!
    4,  // 21: URL pattern
    2,  // 22: (([a-z])\2)-\1
    0,  // 23: Email - complex groups
    3,  // 24: a(b)?(c)?(d)?e
    2,  // 25: IP with port
    3,  // 26: ((foo|bar)(baz|qux))+
    0,  // 27: Hex chars - no groups
    0,  // 28: Word boundaries - complex
    0,  // 29: Negative class - no groups
    0,  // 30: Quoted - complex
    4,  // 31: (a(b(c(d)c)b)a)
    4,  // 32: AMX channel
    1,  // 33: (foo+|bar+|baz+)
    1,  // 34: start-(.*?)-end
    0,  // 35: Password - complex lookaheads
    2,  // 36: ([a-z]+)-(\d+)-\1-\2
    2,  // 37: (a(b|c)?d)?e
    0,  // 38: Escape sequences - no groups
    1,  // 39: (\b\w+\b\s*){3,5}
    0,  // 40: Log pattern - complex, many groups
    0,  // 41: Quoted - complex
    0,  // 42: No groups
    0,  // 43: JSON - complex
    1,  // 44: (a{2,}b{2,}){2,}
    0,  // 45: Lookaheads - complex
    3,  // 46: (([a-z]{3})|([0-9]{3}))
    2,  // 47: (([a-z])\2)-\1
    3,  // 48: ((\d{1,3}\.){3}\d{1,3}):(\d{1,5})
    0,  // 49: Word boundaries - complex
    6   // 50: v?(\d+)\.(\d+)\.(\d+)(-([a-z]+)\.(\d+))?
}

// Expected group 1 text (empty string if undefined/null, or if not validating)
constant char REGEX_COMPLEX_EXPECTED_GROUP1[][50] = {
    'a',            // 1
    '',             // 2
    'foo',          // 3
    '',             // 4
    '123',          // 5
    '34-',          // 6
    '',             // 7: null/undefined
    ' World',       // 8
    'foo',          // 9
    'a',            // 10
    'bd',           // 11
    '',             // 12
    '',             // 13
    'aaa',          // 14
    '',             // 15
    '',             // 16
    '',             // 17
    '1',            // 18
    'aaa',          // 19
    '',             // 20: empty string captured
    'https',        // 21
    'aa',           // 22
    '',             // 23
    '',             // 24: null/undefined
    '.1',           // 25: Repeated groups capture LAST iteration only
    'barqux',       // 26
    '',             // 27
    '',             // 28
    '',             // 29
    '',             // 30
    'abcdcba',      // 31
    '1',            // 32
    'foooo',        // 33
    'content',      // 34
    '',             // 35
    'test',         // 36
    '',             // 37: null/undefined
    '',             // 38
    'three',        // 39
    '',             // 40
    '',             // 41
    '',             // 42
    '',             // 43
    'aabb',         // 44
    '',             // 45
    'abc',          // 46
    'aa',           // 47
    '192.168.1.100', // 48
    '',             // 49
    '1'             // 50
}

// Expected group 2 text (empty string if undefined/null, or if not validating)
constant char REGEX_COMPLEX_EXPECTED_GROUP2[][50] = {
    '',             // 1: null
    '',             // 2
    'bar',          // 3
    '',             // 4
    '',             // 5
    '',             // 6
    '',             // 7: null
    '',             // 8
    'cat',          // 9
    '',             // 10
    'b',            // 11
    '',             // 12
    '',             // 13
    'bbb',          // 14
    '',             // 15
    '',             // 16
    '',             // 17
    '2',            // 18
    '',             // 19
    '',             // 20
    'example.com',  // 21
    'a',            // 22
    '',             // 23
    '',             // 24: null
    ':8080',        // 25
    'bar',          // 26
    '',             // 27
    '',             // 28
    '',             // 29
    '',             // 30
    'bcdcb',        // 31
    '2',            // 32
    '',             // 33
    '',             // 34
    '',             // 35
    '123',          // 36
    '',             // 37: null
    '',             // 38
    '',             // 39
    '',             // 40
    '',             // 41
    '',             // 42
    '',             // 43
    '',             // 44
    '',             // 45
    'abc',          // 46
    'a',            // 47
    '1.',           // 48
    '',             // 49
    '2'             // 50
}

// Expected group 3 text (empty string if undefined/null, or if not validating)
constant char REGEX_COMPLEX_EXPECTED_GROUP3[][50] = {
    '',             // 1: null
    '',             // 2
    '',             // 3
    '',             // 4
    '',             // 5
    '',             // 6
    '',             // 7: null
    '',             // 8
    '',             // 9
    '',             // 10
    'd',            // 11
    '',             // 12
    '',             // 13
    'c',            // 14
    '',             // 15
    '',             // 16
    '',             // 17
    '',             // 18
    '',             // 19
    '',             // 20
    ':8080',        // 21
    '',             // 22
    '',             // 23
    '',             // 24: null
    '',             // 25
    'qux',          // 26
    '',             // 27
    '',             // 28
    '',             // 29
    '',             // 30
    'cdc',          // 31
    '3',            // 32
    '',             // 33
    '',             // 34
    '',             // 35
    '',             // 36
    '',             // 37
    '',             // 38
    '',             // 39
    '',             // 40
    '',             // 41
    '',             // 42
    '',             // 43
    '',             // 44
    '',             // 45
    '',             // 46: null
    '',             // 47
    '8080',         // 48
    '',             // 49
    '3'             // 50
}

/**
 * @function TestNAVRegexMatcherComplexEdgeCases
 * @public
 * @description Tests complex edge case patterns to stress-test the regex engine.
 *
 * Validates:
 * - Multiple nested groups with quantifiers
 * - Complex alternations with overlapping patterns
 * - Multiple backreferences in single patterns
 * - Character class edge cases and negations
 * - Greedy vs lazy quantifier combinations
 * - Nested optional groups and alternations
 * - Complex bounded quantifier combinations
 * - Word boundaries with complex content
 * - Deep nesting of groups and quantifiers
 * - Real-world complex patterns (URLs, emails, logs, etc.)
 */
define_function TestNAVRegexMatcherComplexEdgeCases() {
    stack_var integer x

    NAVLog("'***************** NAVRegexMatcher - Complex Edge Cases *****************'")

    for (x = 1; x <= length_array(REGEX_COMPLEX_PATTERN); x++) {
        stack_var _NAVRegexMatchCollection collection

        NAVStopwatchStart()

        // Execute match using simple API
        if (REGEX_COMPLEX_SHOULD_MATCH[x]) {
            if (!NAVAssertTrue('Should match pattern', NAVRegexMatch(REGEX_COMPLEX_PATTERN[x], REGEX_COMPLEX_INPUT[x], collection))) {
                NAVLogTestFailed(x, 'match success', 'match failed')
                NAVLog("'  Pattern: ', REGEX_COMPLEX_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_COMPLEX_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
        }
        else {
            if (!NAVAssertFalse('Should NOT match pattern', NAVRegexMatch(REGEX_COMPLEX_PATTERN[x], REGEX_COMPLEX_INPUT[x], collection))) {
                NAVLogTestFailed(x, 'no match', 'matched')
                NAVLog("'  Pattern: ', REGEX_COMPLEX_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_COMPLEX_INPUT[x]")
                NAVStopwatchStop()
                continue
            }
            NAVLogTestPassed(x)
            NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
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
        if (!NAVAssertStringEqual('Matched text should be correct', REGEX_COMPLEX_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)) {
            NAVLogTestFailed(x, REGEX_COMPLEX_EXPECTED_MATCH[x], collection.matches[1].fullMatch.text)
            NAVLog("'  Pattern: ', REGEX_COMPLEX_PATTERN[x]")
            NAVLog("'  Input:   ', REGEX_COMPLEX_INPUT[x]")
            NAVStopwatchStop()
            continue
        }

        // Verify match start position
        if (!NAVAssertIntegerEqual('Match start position should be correct', REGEX_COMPLEX_EXPECTED_START[x], type_cast(collection.matches[1].fullMatch.start))) {
            NAVLogTestFailed(x, itoa(REGEX_COMPLEX_EXPECTED_START[x]), itoa(type_cast(collection.matches[1].fullMatch.start)))
            NAVStopwatchStop()
            continue
        }

        // Verify match length
        if (!NAVAssertIntegerEqual('Match length should be correct', length_array(REGEX_COMPLEX_EXPECTED_MATCH[x]), type_cast(collection.matches[1].fullMatch.length))) {
            NAVLogTestFailed(x, itoa(length_array(REGEX_COMPLEX_EXPECTED_MATCH[x])), itoa(type_cast(collection.matches[1].fullMatch.length)))
            NAVStopwatchStop()
            continue
        }

        // Verify group count if pattern has groups
        if (REGEX_COMPLEX_EXPECTED_GROUP_COUNT[x] > 0) {
            if (!NAVAssertIntegerEqual('Group count should be correct', REGEX_COMPLEX_EXPECTED_GROUP_COUNT[x], collection.matches[1].groupCount)) {
                NAVLogTestFailed(x, itoa(REGEX_COMPLEX_EXPECTED_GROUP_COUNT[x]), itoa(collection.matches[1].groupCount))
                NAVLog("'  Pattern: ', REGEX_COMPLEX_PATTERN[x]")
                NAVLog("'  Input:   ', REGEX_COMPLEX_INPUT[x]")
                NAVStopwatchStop()
                continue
            }

            // Verify group 1 if expected
            if (REGEX_COMPLEX_EXPECTED_GROUP_COUNT[x] >= 1 && length_array(REGEX_COMPLEX_EXPECTED_GROUP1[x]) > 0) {
                if (!NAVAssertStringEqual('Group 1 text should be correct', REGEX_COMPLEX_EXPECTED_GROUP1[x], collection.matches[1].groups[1].text)) {
                    NAVLogTestFailed(x, REGEX_COMPLEX_EXPECTED_GROUP1[x], collection.matches[1].groups[1].text)
                    NAVLog("'  Pattern:  ', REGEX_COMPLEX_PATTERN[x]")
                    NAVLog("'  Input:    ', REGEX_COMPLEX_INPUT[x]")
                    NAVStopwatchStop()
                    continue
                }
            }

            // Verify group 2 if expected
            if (REGEX_COMPLEX_EXPECTED_GROUP_COUNT[x] >= 2 && length_array(REGEX_COMPLEX_EXPECTED_GROUP2[x]) > 0) {
                if (!NAVAssertStringEqual('Group 2 text should be correct', REGEX_COMPLEX_EXPECTED_GROUP2[x], collection.matches[1].groups[2].text)) {
                    NAVLogTestFailed(x, REGEX_COMPLEX_EXPECTED_GROUP2[x], collection.matches[1].groups[2].text)
                    NAVLog("'  Pattern:  ', REGEX_COMPLEX_PATTERN[x]")
                    NAVLog("'  Input:    ', REGEX_COMPLEX_INPUT[x]")
                    NAVStopwatchStop()
                    continue
                }
            }

            // Verify group 3 if expected
            if (REGEX_COMPLEX_EXPECTED_GROUP_COUNT[x] >= 3 && length_array(REGEX_COMPLEX_EXPECTED_GROUP3[x]) > 0) {
                if (!NAVAssertStringEqual('Group 3 text should be correct', REGEX_COMPLEX_EXPECTED_GROUP3[x], collection.matches[1].groups[3].text)) {
                    NAVLogTestFailed(x, REGEX_COMPLEX_EXPECTED_GROUP3[x], collection.matches[1].groups[3].text)
                    NAVLog("'  Pattern:  ', REGEX_COMPLEX_PATTERN[x]")
                    NAVLog("'  Input:    ', REGEX_COMPLEX_INPUT[x]")
                    NAVStopwatchStop()
                    continue
                }
            }
        }

        NAVLogTestPassed(x)

        NAVLog("'Test ', itoa(x), ' completed in ', itoa(NAVStopwatchStop()), 'ms'")
    }
}

