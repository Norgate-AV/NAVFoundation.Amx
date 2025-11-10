PROGRAM_NAME='NAVRegexReplace'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test patterns for Replace
constant char REGEX_REPLACE_PATTERN[][255] = {
    '/\d+/',                                        // 1: Digits (no /g)
    '/\d+/g',                                       // 2: Digits (with /g)
    '/(\d+)/',                                      // 3: Capture digits
    '/(\d+)-(\d+)/',                                // 4: Two captures
    '/(?<year>\d{4})-(?<month>\d{2})/',            // 5: Named groups
    '/hello/i',                                     // 6: Case insensitive
    '/\s+/',                                        // 7: Whitespace (no /g)
    '/\s+/g',                                       // 8: Whitespace (with /g)
    '/(\w+)@(\w+)\.(\w+)/',                        // 9: Email pattern
    '/a/',                                          // 10: Simple char (no /g)
    '/a/g',                                         // 11: Simple char (with /g)
    '/x/',                                          // 12: Non-matching pattern
    '/^(\w+)/',                                     // 13: Anchor at start
    '/(\w+)$/',                                     // 14: Anchor at end
    '/(?<tag><\w+>)/',                             // 15: HTML tag
    '/(\d+)/',                                      // 16: For $& test
    '/(\w)(\w)(\w)/',                               // 17: Three captures
    '/(?<a>\w)(?<b>\w)/',                          // 18: Two named groups
    '/(test)/',                                     // 19: Optional group test
    '/\b(\w+)\b/g'                                  // 20: Word boundaries global
}

constant char REGEX_REPLACE_INPUT[][255] = {
    'abc123def',                                    // 1
    'a1b2c3',                                       // 2
    'Price: 100',                                   // 3
    '2025-11-05',                                   // 4
    '2025-11',                                      // 5
    'Hello World',                                  // 6
    'hello   world',                                // 7
    'a  b  c',                                      // 8
    'user@domain.com',                              // 9
    'banana',                                       // 10
    'banana',                                       // 11
    'no match here',                                // 12
    'test string',                                  // 13
    'test string',                                  // 14
    '<div>',                                        // 15
    'test 123',                                     // 16
    'abc',                                          // 17
    'xy',                                           // 18
    'test',                                         // 19
    'hello world test'                              // 20
}

constant char REGEX_REPLACE_REPLACEMENT[][255] = {
    'X',                                            // 1: Simple literal
    'X',                                            // 2: Simple literal
    '[$1]',                                         // 3: Bracket capture
    '$2/$1',                                        // 4: Swap captures
    '${month}/${year}',                             // 5: Swap named groups
    'HELLO',                                        // 6: Literal
    ' ',                                            // 7: Single space
    ' ',                                            // 8: Single space
    '$1 at $2 dot $3',                              // 9: Multiple captures
    'X',                                            // 10: First only
    'X',                                            // 11: All
    'Y',                                            // 12: No effect
    'Start: $1',                                    // 13: With prefix
    'End: $1',                                      // 14: With suffix
    'TAG[$1]',                                      // 15: Named in brackets
    '[$&]',                                         // 16: Full match reference
    '$3$2$1',                                       // 17: Reverse captures
    '${b}${a}',                                     // 18: Reverse named
    'TEST',                                         // 19: Uppercase
    '[$&]'                                          // 20: Bracket each word
}

constant char REGEX_REPLACE_EXPECTED[][255] = {
    'abcXdef',                                      // 1: First match only
    'aXbXcX',                                       // 2: All matches
    'Price: [100]',                                 // 3: Bracketed
    '11/2025-05',                                   // 4: Date swapped (first match)
    '11/2025',                                      // 5: Named groups swapped
    'HELLO World',                                  // 6: Case insensitive replace
    'hello world',                                  // 7: First whitespace only
    'a b c',                                        // 8: All whitespace
    'user at domain dot com',                       // 9: Email parsed
    'bXnana',                                       // 10: First 'a' only
    'bXnXnX',                                       // 11: All 'a's
    'no match here',                                // 12: Unchanged
    'Start: test string',                           // 13: Anchored start
    'test End: string',                             // 14: Anchored end
    'TAG[<div>]',                                   // 15: HTML tag
    'test [123]',                                   // 16: Full match in brackets
    'cba',                                          // 17: Reversed
    'yx',                                           // 18: Named reversed
    'TEST',                                         // 19: Replaced
    '[hello] [world] [test]'                        // 20: Each word bracketed
}


define_function TestNAVRegexReplace() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - Replace *****************'")

    for (x = 1; x <= length_array(REGEX_REPLACE_PATTERN); x++) {
        stack_var char output[1000]

        // Test replace
        if (!NAVAssertTrue('Should replace successfully',
                           NAVRegexReplace(REGEX_REPLACE_PATTERN[x],
                                         REGEX_REPLACE_INPUT[x],
                                         REGEX_REPLACE_REPLACEMENT[x],
                                         output))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify output
        if (!NAVAssertStringEqual('Should produce correct output',
                                  REGEX_REPLACE_EXPECTED[x],
                                  output)) {
            NAVLogTestFailed(x, REGEX_REPLACE_EXPECTED[x], output)
            continue
        }

        NAVLogTestPassed(x)
    }
}


// Test ReplaceAll function (always global)
define_function TestNAVRegexReplaceAll() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - ReplaceAll *****************'")

    // Test 1: ReplaceAll without /g flag should still replace all
    {
        stack_var char output[1000]

        if (NAVRegexReplaceAll('/\d+/', 'a1b2c3', 'X', output)) {
            if (!NAVAssertStringEqual('Should replace all without /g', 'aXbXcX', output)) {
                NAVLogTestFailed(1, 'aXbXcX', output)
            }
            else {
                NAVLogTestPassed(1)
            }
        }
        else {
            NAVLogTestFailed(1, 'true', 'false')
        }
    }

    // Test 2: ReplaceAll with /g flag should also replace all
    {
        stack_var char output[1000]

        if (NAVRegexReplaceAll('/\d+/g', 'a1b2c3', 'X', output)) {
            if (!NAVAssertStringEqual('Should replace all with /g', 'aXbXcX', output)) {
                NAVLogTestFailed(2, 'aXbXcX', output)
            }
            else {
                NAVLogTestPassed(2)
            }
        }
        else {
            NAVLogTestFailed(2, 'true', 'false')
        }
    }

    // Test 3: ReplaceAll with captures
    {
        stack_var char output[1000]

        if (NAVRegexReplaceAll('/(\d+)/', 'a1b22c333', '[$1]', output)) {
            if (!NAVAssertStringEqual('Should bracket all numbers', 'a[1]b[22]c[333]', output)) {
                NAVLogTestFailed(3, 'a[1]b[22]c[333]', output)
            }
            else {
                NAVLogTestPassed(3)
            }
        }
        else {
            NAVLogTestFailed(3, 'true', 'false')
        }
    }

    // Test 4: ReplaceAll with no matches
    {
        stack_var char output[1000]

        if (NAVRegexReplaceAll('/x/', 'no match', 'Y', output)) {
            if (!NAVAssertStringEqual('Should return unchanged', 'no match', output)) {
                NAVLogTestFailed(4, 'no match', output)
            }
            else {
                NAVLogTestPassed(4)
            }
        }
        else {
            NAVLogTestFailed(4, 'true', 'false')
        }
    }
}


// Test edge cases and special scenarios
define_function TestNAVRegexReplaceEdgeCases() {
    stack_var integer x

    NAVLog("'***************** NAVRegex - Replace Edge Cases *****************'")

    // Test 1: Empty replacement
    {
        stack_var char output[1000]

        if (NAVRegexReplace('/\d+/g', 'a1b2c3', '', output)) {
            if (!NAVAssertStringEqual('Should remove all digits', 'abc', output)) {
                NAVLogTestFailed(1, 'abc', output)
            }
            else {
                NAVLogTestPassed(1)
            }
        }
        else {
            NAVLogTestFailed(1, 'true', 'false')
        }
    }

    // Test 2: Empty input
    {
        stack_var char output[1000]

        if (NAVRegexReplace('/\d+/', '', 'X', output)) {
            if (!NAVAssertStringEqual('Should return empty', '', output)) {
                NAVLogTestFailed(2, '', output)
            }
            else {
                NAVLogTestPassed(2)
            }
        }
        else {
            NAVLogTestFailed(2, 'true', 'false')
        }
    }

    // Test 3: Multiple dollar signs
    {
        stack_var char output[1000]

        if (NAVRegexReplace('/(\d+)/', 'Price: 100', 'Price: $$$1', output)) {
            if (!NAVAssertStringEqual('Should handle $$', 'Price: Price: $100', output)) {
                NAVLogTestFailed(3, 'Price: Price: $100', output)
            }
            else {
                NAVLogTestPassed(3)
            }
        }
        else {
            NAVLogTestFailed(3, 'true', 'false')
        }
    }

    // Test 4: Invalid capture group reference (should be empty)
    {
        stack_var char output[1000]

        if (NAVRegexReplace('/(\d+)/', 'test 123', 'Result: $2', output)) {
            if (!NAVAssertStringEqual('Should treat $2 as empty', 'test Result: ', output)) {
                NAVLogTestFailed(4, 'test Result: ', output)
            }
            else {
                NAVLogTestPassed(4)
            }
        }
        else {
            NAVLogTestFailed(4, 'true', 'false')
        }
    }

    // Test 5: Invalid named group reference (should be empty)
    {
        stack_var char output[1000]

        if (NAVRegexReplace('/(?<num>\d+)/', 'test 123', 'Result: ${unknown}', output)) {
            if (!NAVAssertStringEqual('Should treat ${unknown} as empty', 'test Result: ', output)) {
                NAVLogTestFailed(5, 'test Result: ', output)
            }
            else {
                NAVLogTestPassed(5)
            }
        }
        else {
            NAVLogTestFailed(5, 'true', 'false')
        }
    }

    // Test 6: Both $0 and $& in same template
    {
        stack_var char output[1000]

        if (NAVRegexReplace('/test/', 'this is test', '$0 = $&', output)) {
            if (!NAVAssertStringEqual('Should handle both full match refs', 'this is test = test', output)) {
                NAVLogTestFailed(6, 'this is test = test', output)
            }
            else {
                NAVLogTestPassed(6)
            }
        }
        else {
            NAVLogTestFailed(6, 'true', 'false')
        }
    }

    // Test 7: Consecutive replacements
    {
        stack_var char output[1000]

        if (NAVRegexReplace('/(\w)(\w)(\w)/g', 'abcdefghi', '$1-$2-$3 ', output)) {
            if (!NAVAssertStringEqual('Should handle consecutive matches', 'a-b-c d-e-f g-h-i ', output)) {
                NAVLogTestFailed(7, 'a-b-c d-e-f g-h-i ', output)
            }
            else {
                NAVLogTestPassed(7)
            }
        }
        else {
            NAVLogTestFailed(7, 'true', 'false')
        }
    }

    // Test 8: Replace at start of string
    {
        stack_var char output[1000]

        if (NAVRegexReplace('/^test/', 'test string', 'TEST', output)) {
            if (!NAVAssertStringEqual('Should replace at start', 'TEST string', output)) {
                NAVLogTestFailed(8, 'TEST string', output)
            }
            else {
                NAVLogTestPassed(8)
            }
        }
        else {
            NAVLogTestFailed(8, 'true', 'false')
        }
    }

    // Test 9: Replace at end of string
    {
        stack_var char output[1000]

        if (NAVRegexReplace('/test$/', 'string test', 'TEST', output)) {
            if (!NAVAssertStringEqual('Should replace at end', 'string TEST', output)) {
                NAVLogTestFailed(9, 'string TEST', output)
            }
            else {
                NAVLogTestPassed(9)
            }
        }
        else {
            NAVLogTestFailed(9, 'true', 'false')
        }
    }

    // Test 10: Full string replacement
    {
        stack_var char output[1000]

        if (NAVRegexReplace('/^.*$/', 'entire string', 'replaced', output)) {
            if (!NAVAssertStringEqual('Should replace entire string', 'replaced', output)) {
                NAVLogTestFailed(10, 'replaced', output)
            }
            else {
                NAVLogTestPassed(10)
            }
        }
        else {
            NAVLogTestFailed(10, 'true', 'false')
        }
    }
}