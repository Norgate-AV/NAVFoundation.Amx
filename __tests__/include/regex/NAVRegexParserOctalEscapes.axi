PROGRAM_NAME='NAVRegexParserOctalEscapes'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'
#include 'NAVRegexParserTestHelpers.axi'

DEFINE_CONSTANT

// Test type constants for octal escape validation
constant integer OCTAL_TEST_SINGLE_DIGIT        = 1
constant integer OCTAL_TEST_DOUBLE_DIGIT        = 2
constant integer OCTAL_TEST_TRIPLE_DIGIT        = 3
constant integer OCTAL_TEST_DISAMBIGUATION      = 4
constant integer OCTAL_TEST_IN_PATTERN          = 5

// Test patterns for octal escape validation
constant char REGEX_PARSER_OCTAL_PATTERN[][255] = {
    // Single octal digit escapes (\0-\7)
    '/\7/',                         // 1: Single digit octal (\7 = BEL, 0x07)
    '/\0/',                         // 2: Null character (\0 = NUL, 0x00)
    '/\1/',                         // 3: Single digit octal (\1 = SOH, 0x01)
    '/\5/',                         // 4: Single digit octal (\5 = ENQ, 0x05)

    // Double digit octal escapes (\10-\77)
    '/\10/',                        // 5: Double digit octal (\10 = BS, 0x08)
    '/\11/',                        // 6: Tab character (\11 = TAB, 0x09)
    '/\12/',                        // 7: Newline (\12 = LF, 0x0A)
    '/\40/',                        // 8: Space character (\40 = SPACE, 0x20)
    '/\77/',                        // 9: Question mark (\77 = ?, 0x3F)

    // Triple digit octal escapes (\100-\377)
    '/\100/',                       // 10: Triple digit octal (\100 = @, 0x40)
    '/\101/',                       // 11: Letter A (\101 = A, 0x41)
    '/\141/',                       // 12: Letter a (\141 = a, 0x61)
    '/\200/',                       // 13: Extended ASCII (\200 = 0x80)
    '/\377/',                       // 14: Max octal value (\377 = 0xFF)

    // Disambiguation tests - octal vs backreference
    '/(a)\10/',                     // 15: \10 with 1 group → \1 (backref) + 0 (literal)
    '/(a)\100/',                    // 16: \100 with 1 group → always octal (0x40)
    '/(a)(b)\10/',                  // 17: \10 with 2 groups → \1 (backref) + 0 (literal)
    '/(a)(b)(c)(d)(e)(f)(g)(h)(i)(j)\77/',  // 18: \77 with 10 groups → \7 (backref) + 7 (literal)

    // Partial interpretation tests - backreference + literal
    '/(a)\17/',                     // 19: \17 with 1 group → \1 (backref) + 7 (literal)
    '/(a)(b)\27/',                  // 20: \27 with 2 groups → \2 (backref) + 7 (literal)
    '/(a)\12/',                     // 21: \12 with 1 group → \1 (backref) + 2 (literal)

    // Octal escapes in patterns
    '/\101\102\103/',               // 22: ABC in octal (\101\102\103)
    '/[\40-\176]/',                 // 23: Printable ASCII range in char class
    '/\n\11\r/',                    // 24: Mixed escape types (normal + octal + normal)
    '/a\10b/',                      // 25: Octal in middle of pattern
    '/^\40+$/',                     // 26: Spaces using octal with anchors
    '/\0\1\2\3\4\5\6\7/',           // 27: All single digit octals
    '/\10\11\12\13\14\15\16\17/',   // 28: Sequential double digit octals
    '/test\40string/',              // 29: Octal space in literal text
    '/\141\142\143/'                // 30: 'abc' in octal
}

constant integer REGEX_PARSER_OCTAL_TYPE[] = {
    OCTAL_TEST_SINGLE_DIGIT,        // 1
    OCTAL_TEST_SINGLE_DIGIT,        // 2
    OCTAL_TEST_SINGLE_DIGIT,        // 3
    OCTAL_TEST_SINGLE_DIGIT,        // 4
    OCTAL_TEST_DOUBLE_DIGIT,        // 5: \10 with 0 groups → octal 0x08 (fewer groups than number)
    OCTAL_TEST_DOUBLE_DIGIT,        // 6: \11 with 0 groups → octal 0x09 (fewer groups than number)
    OCTAL_TEST_DOUBLE_DIGIT,        // 7: \12 with 0 groups → octal 0x0A (fewer groups than number)
    OCTAL_TEST_DOUBLE_DIGIT,        // 8: \40 with 0 groups → octal 0x20 (fewer groups than number)
    OCTAL_TEST_DOUBLE_DIGIT,        // 9: \77 with 0 groups → octal 0x3F (fewer groups than number)
    OCTAL_TEST_TRIPLE_DIGIT,        // 10
    OCTAL_TEST_TRIPLE_DIGIT,        // 11
    OCTAL_TEST_TRIPLE_DIGIT,        // 12
    OCTAL_TEST_TRIPLE_DIGIT,        // 13
    OCTAL_TEST_TRIPLE_DIGIT,        // 14
    OCTAL_TEST_DISAMBIGUATION,      // 15
    OCTAL_TEST_DISAMBIGUATION,      // 16
    OCTAL_TEST_DISAMBIGUATION,      // 17
    OCTAL_TEST_DISAMBIGUATION,      // 18
    OCTAL_TEST_DISAMBIGUATION,      // 19
    OCTAL_TEST_DISAMBIGUATION,      // 20
    OCTAL_TEST_DISAMBIGUATION,      // 21
    OCTAL_TEST_IN_PATTERN,          // 22
    OCTAL_TEST_IN_PATTERN,          // 23
    OCTAL_TEST_IN_PATTERN,          // 24
    OCTAL_TEST_IN_PATTERN,          // 25
    OCTAL_TEST_IN_PATTERN,          // 26
    OCTAL_TEST_IN_PATTERN,          // 27
    OCTAL_TEST_IN_PATTERN,          // 28
    OCTAL_TEST_IN_PATTERN,          // 29
    OCTAL_TEST_IN_PATTERN           // 30
}

// Expected character values for octal escapes
// Format: [test_index, expected_char_value]
constant integer REGEX_PARSER_OCTAL_EXPECTED_VALUE[][2] = {
    { 1, $07 },         // \7 = BEL (0x07)
    { 2, $00 },         // \0 = NUL (0x00)
    { 3, $01 },         // \1 = SOH (0x01)
    { 4, $05 },         // \5 = ENQ (0x05)
    { 5, $08 },         // \10 = BS (0x08) - octal when 0 groups
    { 6, $09 },         // \11 = TAB (0x09) - octal when 0 groups
    { 7, $0A },         // \12 = LF (0x0A) - octal when 0 groups
    { 8, $20 },         // \40 = SPACE (0x20) - octal when 0 groups
    { 9, $3F },         // \77 = ? (0x3F) - octal when 0 groups
    { 10, $40 },        // \100 = @ (0x40)
    { 11, $41 },        // \101 = A (0x41)
    { 12, $61 },        // \141 = a (0x61)
    { 13, $80 },        // \200 = 0x80
    { 14, $FF },        // \377 = 0xFF (max)
    { 16, $40 }         // \100 with 1 group = always octal 0x40 (test 16 only)
}

// Expected backreference/literal + literal combinations
// Format: [test_index, first_value, second_literal_char, is_first_backref]
// is_first_backref: '1' = backref, '0' = literal (octal)
constant char REGEX_PARSER_OCTAL_PARTIAL_BACKREF[][][4] = {
    { '5', '1', '0', '0' },      // \10 with 0 groups → \1 (octal 0x01) + '0'
    { '6', '1', '1', '0' },      // \11 with 0 groups → \1 (octal 0x01) + '1'
    { '7', '1', '2', '0' },      // \12 with 0 groups → \1 (octal 0x01) + '2'
    { '8', '4', '0', '0' },      // \40 with 0 groups → \4 (octal 0x04) + '0'
    { '9', '7', '7', '0' },      // \77 with 0 groups → \7 (octal 0x07) + '7'
    { '15', '1', '0', '1' },     // \10 with 1 group → \1 (backref) + '0'
    { '17', '1', '0', '1' },     // \10 with 2 groups → \1 (backref) + '0'
    { '18', '7', '7', '1' },     // \77 with 10 groups → \7 (backref) + '7'
    { '19', '1', '7', '1' },     // \17 with 1 group → \1 (backref) + '7'
    { '20', '2', '7', '1' },     // \27 with 2 groups → \2 (backref) + '7'
    { '21', '1', '2', '1' }      // \12 with 1 group → \1 (backref) + '2'
}


/**
 * @function TestNAVRegexParserOctalEscapes
 * @description Test octal escape parsing and NFA construction.
 *
 * Tests various octal escape sequences:
 * - Single digit octals (\0-\7)
 * - Double digit octals (\10-\77)
 * - Triple digit octals (\100-\377)
 * - Disambiguation from backreferences
 * - Partial interpretation (backref + literal)
 * - Octal escapes in patterns
 *
 * Validates that:
 * - Octal escapes are correctly converted to literal characters
 * - Disambiguation logic works correctly
 * - NFA states have correct character values
 */
define_function TestNAVRegexParserOctalEscapes() {
    stack_var _NAVRegexLexer lexer
    stack_var integer x

    NAVLog("'***************** NAVRegexParserOctalEscapes *****************'")

    for (x = 1; x <= length_array(REGEX_PARSER_OCTAL_PATTERN); x++) {
        stack_var _NAVRegexNFA nfa
        stack_var integer testType
        stack_var char testDescription[255]

        testType = REGEX_PARSER_OCTAL_TYPE[x]
        testDescription = REGEX_PARSER_OCTAL_PATTERN[x]

        // Tokenize and parse the pattern
        if (!NAVAssertTrue('Should tokenize pattern', NAVRegexLexerTokenize(REGEX_PARSER_OCTAL_PATTERN[x], lexer))) {
            NAVLogTestFailed(x, 'tokenize success', 'tokenize failed')
            continue
        }

        if (!NAVAssertTrue('Should parse tokens into NFA', NAVRegexParse(lexer, nfa))) {
            NAVLogTestFailed(x, 'parse success', 'parse failed')
            continue
        }

        // Test 1-3: Validate octal escapes (single, double, triple digit)
        if (testType == OCTAL_TEST_SINGLE_DIGIT ||
            testType == OCTAL_TEST_DOUBLE_DIGIT ||
            testType == OCTAL_TEST_TRIPLE_DIGIT) {
            stack_var integer i
            stack_var char foundExpected
            stack_var integer literalStateId

            foundExpected = false

            for (i = 1; i <= length_array(REGEX_PARSER_OCTAL_EXPECTED_VALUE); i++) {
                if (REGEX_PARSER_OCTAL_EXPECTED_VALUE[i][1] == x) {
                    stack_var char expectedChar
                    expectedChar = type_cast(REGEX_PARSER_OCTAL_EXPECTED_VALUE[i][2])

                    if (!NAVAssertTrue("'Should have literal state with value ', itoa(expectedChar)",
                                       FindLiteralState(nfa, expectedChar, literalStateId))) {
                        NAVLogTestFailed(x, "'literal state with value ', itoa(expectedChar)", 'no matching literal state')
                        continue  // Skip to next test
                    }

                    if (!NAVAssertTrue('Should have literal state with correct value',
                                       nfa.states[literalStateId].matchChar == expectedChar)) {
                        NAVLogTestFailed(x, "'literal value ', itoa(expectedChar)", "'literal value ', itoa(nfa.states[literalStateId].matchChar)")
                        continue  // Skip to next test
                    }

                    foundExpected = true
                    break
                }
            }

            if (!foundExpected) {
                NAVLogTestFailed(x, 'expected value found', 'no expected value defined')
                continue
            }
        }

        // Test 4: Validate disambiguation (octal when \100+ or no matching group)
        if (testType == OCTAL_TEST_DISAMBIGUATION) {
            stack_var integer i
            stack_var char foundExpected
            stack_var char isPartialBackref

            foundExpected = false
            isPartialBackref = false

            // Check if this is a partial backreference test
            for (i = 1; i <= length_array(REGEX_PARSER_OCTAL_PARTIAL_BACKREF); i++) {
                if (atoi(REGEX_PARSER_OCTAL_PARTIAL_BACKREF[i][1]) == x) {
                    // This should have both a backreference/literal and a literal
                    stack_var integer firstValue
                    stack_var char secondLiteralChar
                    stack_var char isFirstBackref
                    stack_var integer firstStateId
                    stack_var integer literalStateId

                    firstValue = atoi(REGEX_PARSER_OCTAL_PARTIAL_BACKREF[i][2])
                    secondLiteralChar = NAVCharCodeAt(REGEX_PARSER_OCTAL_PARTIAL_BACKREF[i][3], 1)
                    isFirstBackref = (REGEX_PARSER_OCTAL_PARTIAL_BACKREF[i][4] == '1')

                    // Verify first part exists (either backreference or literal)
                    if (isFirstBackref) {
                        // Should be a backreference
                        if (!NAVAssertTrue("'Should have backreference to group ', itoa(firstValue)",
                                           FindBackrefStateByGroup(nfa, firstValue, firstStateId))) {
                            NAVLogTestFailed(x, "'backreference to group ', itoa(firstValue)", 'no backreference state')
                            continue  // Skip to next test
                        }
                    } else {
                        // Should be a literal (octal value)
                        stack_var char firstLiteralChar
                        firstLiteralChar = type_cast(firstValue)
                        if (!NAVAssertTrue("'Should have literal char with value ', itoa(firstValue)",
                                           FindLiteralState(nfa, firstLiteralChar, firstStateId))) {
                            NAVLogTestFailed(x, "'literal char with value ', itoa(firstValue)", 'no literal state')
                            continue  // Skip to next test
                        }
                    }

                    // Verify second literal exists
                    if (!NAVAssertTrue("'Should have second literal char ', secondLiteralChar",
                                       FindLiteralState(nfa, secondLiteralChar, literalStateId))) {
                        NAVLogTestFailed(x, "'literal char ', secondLiteralChar", 'no literal state')
                        continue  // Skip to next test
                    }

                    isPartialBackref = true
                    foundExpected = true
                    break
                }
            }

            // If not a partial backreference, check for pure octal
            if (!isPartialBackref) {
                for (i = 1; i <= length_array(REGEX_PARSER_OCTAL_EXPECTED_VALUE); i++) {
                    if (REGEX_PARSER_OCTAL_EXPECTED_VALUE[i][1] == x) {
                        stack_var char expectedChar
                        stack_var integer literalStateId

                        expectedChar = type_cast(REGEX_PARSER_OCTAL_EXPECTED_VALUE[i][2])

                        if (!NAVAssertTrue("'Should have literal state with octal value ', itoa(expectedChar)",
                                           FindLiteralState(nfa, expectedChar, literalStateId))) {
                            NAVLogTestFailed(x, "'literal state with octal value ', itoa(expectedChar)", 'no matching literal state')
                            continue  // Skip to next test
                        }

                        foundExpected = true
                        break
                    }
                }
            }

            if (!foundExpected) {
                NAVLogTestFailed(x, 'expected disambiguation result', 'no expected result defined')
                continue
            }
        }

        // Test 5: Validate octal escapes in patterns (should parse successfully)
        if (testType == OCTAL_TEST_IN_PATTERN) {
            // Just verify it parsed successfully
            if (!NAVAssertTrue('Pattern with octal escapes should parse', nfa.stateCount > 0)) {
                NAVLogTestFailed(x, 'nfa.stateCount > 0', "'nfa.stateCount = ', itoa(nfa.stateCount)")
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}
