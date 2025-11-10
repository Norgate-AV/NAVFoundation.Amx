PROGRAM_NAME='NAVRegexLexerCharClassEdgeCases'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexLexerTestHelpers.axi'

DEFINE_CONSTANT

/**
 * Character Class Edge Case Test Patterns
 *
 * This test suite focuses on edge cases and corner cases in character class
 * parsing, particularly those involving special characters in ranges.
 *
 * Known issues being tested:
 * - Dash at different positions in character classes
 * - Special ASCII characters like !, ~, @, etc. in ranges
 * - Character class ranges with non-alphanumeric boundaries
 * - Escaped characters within character classes
 */

constant char REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[][255] = {
    // Dash positioning tests
    '/[-abc]/',             // 1: Dash at start of character class
    '/[abc-]/',             // 2: Dash at end of character class
    '/[a-c-f]/',            // 3: Multiple ranges with literal dash
    '/[---]/',              // 4: Multiple dashes (dash range to dash)
    '/[-]/',                // 5: Single dash (literal)

    // Special ASCII character ranges
    '/[!-~]/',              // 6: Printable ASCII range (! to ~) - KNOWN ISSUE
    '/[!-/]/',              // 7: Range from ! to /
    '/[@-Z]/',              // 8: Range from @ to Z
    '/[0-9a-z]/',           // 9: Multiple ranges (normal case for comparison)
    '/[ -~]/',              // 10: Space to tilde (all printable)

    // Dash in ranges with special chars
    '/[--/]/',              // 11: Dash to slash range - KNOWN ISSUE
    '/[+-/]/',              // 12: Plus to slash range
    '/[*-.]/',              // 13: Asterisk to period range

    // Escaped characters in character classes
    '/[\-]/',               // 14: Escaped dash
    '/[\^]/',               // 15: Escaped caret
    '/[\]]/',               // 16: Escaped closing bracket
    '/[\\]/',               // 17: Escaped backslash
    '/[\n\r\t]/',           // 18: Common escape sequences

    // Negated versions of edge cases
    '/[^!-~]/',             // 19: Negated printable ASCII
    '/[^-abc]/',            // 20: Negated with dash at start
    '/[^abc-]/',            // 21: Negated with dash at end

    // Character class with all special positions
    '/[-a-z]/',             // 22: Dash at start, then range
    '/[a-z-]/',             // 23: Range, then dash at end
    '/[-a-z-]/',            // 24: Dash at both ends with range

    // Hex escapes in character classes
    '/[\x00-\x1F]/',        // 25: Control character range
    '/[\x20-\x7E]/',        // 26: Printable ASCII via hex
    '/[\x41-\x5A]/',        // 27: A-Z via hex escapes

    // Octal escapes in character classes
    '/[\101]/',             // 28: Single octal (101 octal = 65 decimal = 'A')
    '/[\101-\132]/',        // 29: Octal range (101-132 octal = A-Z)
    '/[\0-\37]/',           // 30: Control chars via octal (0-37 octal = 0-31 decimal)
    '/[\60-\71]/',          // 31: Digits via octal (60-71 octal = 48-57 decimal = 0-9)
    '/[\141-\172]/',        // 32: Lowercase via octal (141-172 octal = a-z)

    // Edge case: single character ranges
    '/[a-a]/',              // 33: Single char range (a to a)
    '/[0-0]/',              // 34: Single digit range
    '/[!-!]/',              // 35: Single special char range

    // Mixed predefined classes with ranges
    '/[\d!-~]/',            // 36: Predefined class + special range
    '/[\w!-/]/',            // 37: Word chars + special range
    '/[\s -~]/',            // 38: Whitespace + printable range

    // Boundary special characters
    '/[`-{]/',              // 39: Backtick to left brace
    '/[{-~]/',              // 40: Left brace to tilde
    '/[ -!]/',              // 41: Space to exclamation
    '/[~-~]/',              // 42: Tilde to tilde (single char)

    // Complex nested scenarios
    '/[a-z\-0-9]/',         // 43: Range, escaped dash, range
    '/[!-/:-@[-`{-~]/',     // 44: All special ASCII ranges (comprehensive)

    // Additional bracket edge cases
    '/[[]/',                // 45: Literal opening bracket
    '/[]]/',                // 46: Literal closing bracket (first char)
    '/[\[]/',               // 47: Escaped opening bracket
    '/[a[b]/',              // 48: Bracket in middle of class
    '/[[a-z]]/',            // 49: Brackets around range

    // Empty and minimal cases
    '/[a]/',                // 50: Single character class
    '/[\d]/',               // 51: Single predefined class
    '/[^a]/',               // 52: Negated single char

    // Multiple consecutive ranges
    '/[a-zA-Z0-9]/',        // 53: Three consecutive ranges
    '/[!-/0-9A-Z_a-z]/',    // 54: Many ranges with special chars
    '/[0-9A-F]/',           // 55: Hex digit character class

    // Dash with predefined classes
    '/[\d-\w]/',            // 56: Predefined classes with dash between
    '/[\w-]/',              // 57: Predefined class with trailing dash
    '/[-\s]/',              // 58: Leading dash with predefined class

    // Special character literals
    '/[.$^(){}|?*+]/',      // 59: Regex metacharacters as literals
    '/[\.\$\^]/',           // 60: Escaped regex metacharacters
    '/[(){}]/',             // 61: Grouping characters

    // Unicode-adjacent ranges
    '/[A-z]/',              // 62: A-z includes some special chars ([\]^_`)
    '/[0-:]/',              // 63: 0-9 plus colon
    '/[@-[]/',              // 64: @ to [

    // Edge case: range at very end with /
    '/[/-a]/',              // 65: Range starting with slash (changed from a-/ which is invalid)
    '/[/-z]/',              // 66: Range starting with slash
    '/[/-/]/',              // 67: Slash to slash (should be literal)

    // Double-escaped scenarios
    '/[\\-\\]/',            // 68: Escaped backslash to escaped backslash
    '/[\n-\r]/',            // 69: Newline to carriage return range
    '/[\x00-\xFF]/',        // 70: Full byte range (00 to FF)

    // Negated complex cases
    '/[^a-zA-Z0-9_]/',      // 71: Negated word-like class
    '/[^\x00-\x1F\x7F]/',   // 72: Negated control chars
    '/[^!-/:-@[-`{-~]/',    // 73: Negated special chars

    // Whitespace in character classes (should be literal)
    '/[ \t\n]/',            // 74: Literal space, tab, newline
    '/[a b]/',              // 75: Space between characters
    '/[ -~]/'               // 76: Space as range start (duplicate of 10, but important)
}

constant integer REGEX_LEXER_CHARCLASS_EDGE_EXPECTED_TOKENS[][] = {
    // 1: /[-abc]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 2: /[abc-]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 3: /[a-c-f]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 4: /[---]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 5: /[-]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 6: /[!-~]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 7: /[!-/]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 8: /[@-Z]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 9: /[0-9a-z]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 10: /[ -~]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 11: /[--/]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 12: /[+-/]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 13: /[*-.]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 14: /[\-]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 15: /[\^]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 16: /[\]]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 17: /[\\]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 18: /[\n\r\t]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 19: /[^!-~]/
    {
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 20: /[^-abc]/
    {
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 21: /[^abc-]/
    {
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 22: /[-a-z]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 23: /[a-z-]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 24: /[-a-z-]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 25: /[\x00-\x1F]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 26: /[\x20-\x7E]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 27: /[\x41-\x5A]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 28: /[\101]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 29: /[\101-\132]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 30: /[\0-\37]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 31: /[\60-\71]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 32: /[\141-\172]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 33: /[a-a]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 34: /[0-0]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 35: /[!-!]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 36: /[\d!-~]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 37: /[\w!-/]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 38: /[\s -~]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 39: /[`-{]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 40: /[{-~]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 41: /[ -!]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 42: /[~-~]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 43: /[a-z\-0-9]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 44: /[!-/:-@[-`{-~]/
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 45: /[[]/ - Literal opening bracket
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 46: /[]]/ - Literal closing bracket (first char)
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 47: /[\[]/ - Escaped opening bracket
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 48: /[a[b]/ - Bracket in middle
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 49: /[[a-z]]/ - Brackets around range (class contains [a-z], then literal ] after)
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_CHAR,
        REGEX_TOKEN_EOF
    },
    // 50: /[a]/ - Single character
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 51: /[\d]/ - Single predefined
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 52: /[^a]/ - Negated single
    {
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 53: /[a-zA-Z0-9]/ - Three ranges
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 54: /[!-/0-9A-Z_a-z]/ - Many ranges
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 55: /[0-9A-F]/ - Hex digits
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 56: /[\d-\w]/ - Predefined with dash
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 57: /[\w-]/ - Predefined with trailing dash
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 58: /[-\s]/ - Leading dash with predefined
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 59: /[.$^(){}|?*+]/ - Metacharacters
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 60: /[\.\$\^]/ - Escaped metacharacters
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 61: /[(){}]/ - Grouping chars
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 62: /[A-z]/ - A-z with specials
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 63: /[0-:]/ - 0-9 plus colon
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 64: /[@-[]/ - @ to [
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 65: /[/-a]/ - Range starting with slash
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 66: /[/-z]/ - Range starting with slash
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 67: /[/-/]/ - Slash to slash
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 68: /[\\-\\]/ - Backslash to backslash
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 69: /[\n-\r]/ - Newline to CR range
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 70: /[\x00-\xFF]/ - Full byte range
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 71: /[^a-zA-Z0-9_]/ - Negated word-like
    {
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 72: /[^\x00-\x1F\x7F]/ - Negated control
    {
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 73: /[^!-/:-@[-`{-~]/ - Negated specials
    {
        REGEX_TOKEN_INV_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 74: /[ \t\n]/ - Whitespace literals
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 75: /[a b]/ - Space between chars
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    },
    // 76: /[ -~]/ - Space as range start
    {
        REGEX_TOKEN_CHAR_CLASS,
        REGEX_TOKEN_EOF
    }
}


/**
 * @function TestNAVRegexLexerCharClassEdgeCases
 * @public
 * @description Tests edge cases in character class tokenization.
 *
 * Focuses on problematic patterns that have caused lexer failures:
 * - /[!-~]/ - Printable ASCII range (cursor out of bounds issue)
 * - /[--/]/ - Dash at start of range
 * - Special character boundaries in ranges
 *
 * These tests help identify and fix cursor management issues in the
 * NAVRegexLexerConsumeCharacterClass function.
 */
define_function TestNAVRegexLexerCharClassEdgeCases() {
    stack_var integer x

    NAVLog("'***************** NAVRegexLexer - Character Class Edge Cases *****************'")

    for (x = 1; x <= length_array(REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST); x++) {
        stack_var _NAVRegexLexer lexer
        stack_var integer expectedTokenCount

        if (!NAVAssertTrue('Should tokenize successfully', NAVRegexLexerTokenize(REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], lexer))) {
            NAVLogTestFailed(x, "'Pattern: ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ' - Expected: tokenize success'", "'Got: tokenize failed'")
            continue
        }

        // Verify the correct number of tokens were generated
        expectedTokenCount = length_array(REGEX_LEXER_CHARCLASS_EDGE_EXPECTED_TOKENS[x])
        if (!NAVAssertIntegerEqual('Should tokenize to correct amount of tokens', expectedTokenCount, lexer.tokenCount)) {
            NAVLogTestFailed(x, "'Pattern: ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ' - Expected token count: ', itoa(expectedTokenCount)", "'Got: ', itoa(lexer.tokenCount)")
            continue
        }

        {
            // Now loop through the tokens and verify each one is correct
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (!NAVAssertIntegerEqual("'Token ', itoa(y), ' should be correct'", REGEX_LEXER_CHARCLASS_EDGE_EXPECTED_TOKENS[x][y], lexer.tokens[y].type)) {
                    NAVLogTestFailed(x, "'Pattern: ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ' - Expected token ', itoa(y), ': ', NAVRegexLexerGetTokenType(REGEX_LEXER_CHARCLASS_EDGE_EXPECTED_TOKENS[x][y])", "'Got: ', NAVRegexLexerGetTokenType(lexer.tokens[y].type)")
                    failed = true
                    break
                }
            }

            if (failed) {
                continue
            }
        }

        // Additional validation: For CHAR_CLASS tokens, verify the character class was parsed
        {
            stack_var integer y
            stack_var char failed

            for (y = 1; y <= lexer.tokenCount; y++) {
                if (lexer.tokens[y].type == REGEX_TOKEN_CHAR_CLASS || lexer.tokens[y].type == REGEX_TOKEN_INV_CHAR_CLASS) {
                    // Verify that the character class has at least some content
                    // (rangeCount > 0 OR has predefined classes)
                    stack_var integer rangeCount
                    rangeCount = lexer.tokens[y].charclass.rangeCount

                    if (rangeCount == 0 &&
                        !lexer.tokens[y].charclass.hasDigits &&
                        !lexer.tokens[y].charclass.hasNonDigits &&
                        !lexer.tokens[y].charclass.hasWordChars &&
                        !lexer.tokens[y].charclass.hasNonWordChars &&
                        !lexer.tokens[y].charclass.hasWhitespace &&
                        !lexer.tokens[y].charclass.hasNonWhitespace) {

                        NAVLogTestFailed(x, "'Pattern: ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ' - Expected: non-empty character class'", "'Got: empty character class (no ranges or predefined classes)'")
                        failed = true
                        break
                    }
                }
            }

            if (failed) {
                continue
            }
        }

        // Additional validation for specific test patterns with hex/octal escapes
        select {
            // Test 25: /[\x00-\x1F]/ - Control character range via hex
            active (x == 25): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $00, $1F)) {
                    NAVLogTestFailed(x, "'Range: $00-$1F'", "'incorrect range'")
                    continue
                }
            }

            // Test 26: /[\x20-\x7E]/ - Printable ASCII via hex
            active (x == 26): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $20, $7E)) {
                    NAVLogTestFailed(x, "'Range: $20-$7E'", "'incorrect range'")
                    continue
                }
            }

            // Test 27: /[\x41-\x5A]/ - A-Z via hex escapes
            active (x == 27): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $41, $5A)) {
                    NAVLogTestFailed(x, "'Range: $41-$5A (A-Z)'", "'incorrect range'")
                    continue
                }
            }

            // Test 28: /[\101]/ - Single octal (101 octal = 65 decimal = 'A')
            active (x == 28): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $41, $41)) {
                    NAVLogTestFailed(x, "'Octal \\101 should be $41 (A)'", "'incorrect value'")
                    continue
                }
            }

            // Test 29: /[\101-\132]/ - Octal range (101-132 octal = A-Z)
            active (x == 29): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $41, $5A)) {
                    NAVLogTestFailed(x, "'Octal \\101-\\132 = $41-$5A (A-Z)'", "'incorrect range'")
                    continue
                }
            }

            // Test 30: /[\0-\37]/ - Control chars via octal (0-37 octal = 0-31 decimal)
            active (x == 30): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $00, $1F)) {
                    NAVLogTestFailed(x, "'Octal \\0-\\37 = $00-$1F (control chars)'", "'incorrect range'")
                    continue
                }
            }

            // Test 31: /[\60-\71]/ - Digits via octal (60-71 octal = 48-57 decimal = 0-9)
            active (x == 31): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $30, $39)) {
                    NAVLogTestFailed(x, "'Octal \\60-\\71 = $30-$39 (0-9)'", "'incorrect range'")
                    continue
                }
            }

            // Test 32: /[\141-\172]/ - Lowercase via octal (141-172 octal = a-z)
            active (x == 32): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $61, $7A)) {
                    NAVLogTestFailed(x, "'Octal \\141-\\172 = $61-$7A (a-z)'", "'incorrect range'")
                    continue
                }
            }

            // Test 64: /[@-[]/ - @ to [ range
            active (x == 64): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $40, $5B)) {
                    NAVLogTestFailed(x, "'Range: $40-$5B (@-[)'", "'incorrect range'")
                    continue
                }
            }

            // Test 65: /[/-a]/ - / to a range
            active (x == 65): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $2F, $61)) {
                    NAVLogTestFailed(x, "'Range: $2F-$61 (/-a)'", "'incorrect range'")
                    continue
                }
            }

            // Test 67: /[/-/]/ - / to / (single char literal)
            active (x == 67): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $2F, $2F)) {
                    NAVLogTestFailed(x, "'Range: $2F-$2F (/ to /)'", "'incorrect range'")
                    continue
                }
            }

            // Test 69: /[\n-\r]/ - Newline to CR range
            active (x == 69): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $0A, $0D)) {
                    NAVLogTestFailed(x, "'Range: $0A-$0D (newline-CR)'", "'incorrect range'")
                    continue
                }
            }

            // Test 70: /[\x00-\xFF]/ - Full byte range
            active (x == 70): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 1)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 1 range'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $00, $FF)) {
                    NAVLogTestFailed(x, "'Range: $00-$FF (full byte)'", "'incorrect range'")
                    continue
                }
            }

            // Test 72: /[^\x00-\x1F\x7F]/ - Negated control chars
            active (x == 72): {
                stack_var integer tokenIdx
                tokenIdx = NAVGetCharClassTokenIndex(lexer)

                if (!NAVAssertTokenIsNegated(lexer.tokens[tokenIdx], true)) {
                    NAVLogTestFailed(x, "'Should be negated'", "'not negated'")
                    continue
                }

                if (!NAVAssertCharClassRangeCount(lexer.tokens[tokenIdx].charclass, 2)) {
                    NAVLogTestFailed(x, "'Pattern ', REGEX_LEXER_CHARCLASS_EDGE_PATTERN_TEST[x], ': 2 ranges'", "itoa(lexer.tokens[tokenIdx].charclass.rangeCount)")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 1, $00, $1F)) {
                    NAVLogTestFailed(x, "'Range 1: $00-$1F'", "'incorrect range'")
                    continue
                }

                if (!NAVAssertCharClassRange(lexer.tokens[tokenIdx].charclass, 2, $7F, $7F)) {
                    NAVLogTestFailed(x, "'Range 2: $7F (DEL)'", "'incorrect range'")
                    continue
                }
            }
        }

        NAVLogTestPassed(x)
    }
}
