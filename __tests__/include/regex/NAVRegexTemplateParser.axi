PROGRAM_NAME='NAVRegexTemplateParser'

#include 'NAVFoundation.Core.axi'
#include 'NAVFoundation.Regex.axi'
#include 'NAVFoundation.Assert.axi'
#include 'NAVFoundation.Testing.axi'

DEFINE_CONSTANT

// Test template strings
constant char REGEX_TEMPLATE_PARSER_INPUT[][255] = {
    'Hello World',                          // 1: Literal only
    '$1',                                   // 2: Single capture ref
    '$0',                                   // 3: Full match ($0)
    '$&',                                   // 4: Full match ($&)
    '$$',                                   // 5: Escaped dollar
    'Result: $1',                           // 6: Literal + capture
    '$1 and $2',                            // 7: Multiple captures
    'Price: $$$1.00',                       // 8: Literal dollar + capture
    '${name}',                              // 9: Named group (braces)
    '$<name>',                              // 10: Named group (angle)
    'Hello ${first} ${last}',               // 11: Multiple named groups
    '$1-$2-$3',                             // 12: Multiple captures with separators
    'Before $& After',                      // 13: Full match with literals
    '${year}/${month}/${day}',              // 14: Date-style template
    'User: $<username> (ID: $1)',           // 15: Mixed named and numbered
    'Text $99 more',                        // 16: High capture number
    '$$$$$1',                               // 17: Multiple dollar signs
    '${a}${b}${c}',                         // 18: Consecutive named groups
    '$1$2$3',                               // 19: Consecutive numbered groups
    'No substitutions here',                // 20: Pure literal
    '$',                                    // 21: Lone dollar (literal)
    '${',                                   // 22: Incomplete named group
    '$<',                                   // 23: Incomplete named group
    '${unclosed',                           // 24: Unclosed brace
    '$<unclosed',                           // 25: Unclosed angle
    '${name} - $1 - $& - $$',               // 26: All types mixed
    '',                                     // 27: Empty template
    '$10',                                  // 28: Two-digit capture number
    '$0 = $&',                              // 29: Both full match syntaxes
    'A$1B$2C$3D',                           // 30: Captures with single-char literals
    '$_invalid',                            // 31: Invalid after dollar (literal)
    '${valid_name}',                        // 32: Valid name with underscore
    '${name123}',                           // 33: Valid name with numbers
    '${123invalid}',                        // 34: Invalid name (starts with digit)
    '${ }',                                 // 35: Invalid name (whitespace)
    '$$$$',                                 // 36: Four dollar signs
    'Test $1 Test $2 Test',                 // 37: Alternating literal/capture
    '$&$&$&',                               // 38: Repeated full match
    '${a}literal${b}',                      // 39: Named groups with literal between
    'Prefix $1 Middle $2 Suffix'            // 40: Complex mixed
}

// Expected part counts
constant integer REGEX_TEMPLATE_PARSER_EXPECTED_PART_COUNT[] = {
    1,      // 1: Single literal
    1,      // 2: Single capture ref
    1,      // 3: Single full match
    1,      // 4: Single full match
    1,      // 5: Single dollar
    2,      // 6: Literal + capture
    3,      // 7: Capture + literal + capture
    4,      // 8: Literal + dollar + capture + literal
    1,      // 9: Single named ref
    1,      // 10: Single named ref
    4,      // 11: Literal + named + literal + named
    5,      // 12: Capture + lit + capture + lit + capture
    3,      // 13: Literal + full match + literal
    5,      // 14: Named + lit + named + lit + named
    5,      // 15: Literal + named + literal + capture + literal
    3,      // 16: Literal + capture + literal
    3,      // 17: Dollar + dollar + capture
    3,      // 18: Named + named + named
    3,      // 19: Capture + capture + capture
    1,      // 20: Single literal
    1,      // 21: Single literal ($)
    1,      // 22: Single literal (${)
    1,      // 23: Single literal ($<)
    1,      // 24: Single literal (${unclosed)
    1,      // 25: Single literal ($<unclosed)
    7,      // 26: Named + lit + capture + lit + full + lit + dollar
    0,      // 27: Empty (no parts)
    1,      // 28: Single capture ($10)
    3,      // 29: Full + lit + full
    7,      // 30: Lit + cap + lit + cap + lit + cap + lit
    1,      // 31: Single literal
    1,      // 32: Single named ref
    1,      // 33: Single named ref
    1,      // 34: Single literal (invalid name)
    1,      // 35: Single literal (invalid name)
    2,      // 36: Dollar + dollar
    5,      // 37: Literal + cap + lit + cap + literal
    3,      // 38: Full + full + full
    3,      // 39: Named + literal + named
    5       // 40: Literal + cap + lit + cap + literal
}

// Expected first part type for validation
constant integer REGEX_TEMPLATE_PARSER_EXPECTED_FIRST_TYPE[] = {
    REGEX_TEMPLATE_LITERAL,         // 1
    REGEX_TEMPLATE_CAPTURE_REF,     // 2
    REGEX_TEMPLATE_FULL_MATCH,      // 3
    REGEX_TEMPLATE_FULL_MATCH,      // 4
    REGEX_TEMPLATE_DOLLAR,          // 5
    REGEX_TEMPLATE_LITERAL,         // 6
    REGEX_TEMPLATE_CAPTURE_REF,     // 7
    REGEX_TEMPLATE_LITERAL,         // 8
    REGEX_TEMPLATE_NAMED_REF,       // 9
    REGEX_TEMPLATE_NAMED_REF,       // 10
    REGEX_TEMPLATE_LITERAL,         // 11
    REGEX_TEMPLATE_CAPTURE_REF,     // 12
    REGEX_TEMPLATE_LITERAL,         // 13
    REGEX_TEMPLATE_NAMED_REF,       // 14
    REGEX_TEMPLATE_LITERAL,         // 15
    REGEX_TEMPLATE_LITERAL,         // 16
    REGEX_TEMPLATE_DOLLAR,          // 17
    REGEX_TEMPLATE_NAMED_REF,       // 18
    REGEX_TEMPLATE_CAPTURE_REF,     // 19
    REGEX_TEMPLATE_LITERAL,         // 20
    REGEX_TEMPLATE_LITERAL,         // 21
    REGEX_TEMPLATE_LITERAL,         // 22
    REGEX_TEMPLATE_LITERAL,         // 23
    REGEX_TEMPLATE_LITERAL,         // 24
    REGEX_TEMPLATE_LITERAL,         // 25
    REGEX_TEMPLATE_NAMED_REF,       // 26
    REGEX_TEMPLATE_NONE,            // 27 (no parts)
    REGEX_TEMPLATE_CAPTURE_REF,     // 28
    REGEX_TEMPLATE_FULL_MATCH,      // 29
    REGEX_TEMPLATE_LITERAL,         // 30
    REGEX_TEMPLATE_LITERAL,         // 31
    REGEX_TEMPLATE_NAMED_REF,       // 32
    REGEX_TEMPLATE_NAMED_REF,       // 33
    REGEX_TEMPLATE_LITERAL,         // 34
    REGEX_TEMPLATE_LITERAL,         // 35
    REGEX_TEMPLATE_DOLLAR,          // 36
    REGEX_TEMPLATE_LITERAL,         // 37
    REGEX_TEMPLATE_FULL_MATCH,      // 38
    REGEX_TEMPLATE_NAMED_REF,       // 39
    REGEX_TEMPLATE_LITERAL          // 40
}


define_function TestNAVRegexTemplateParser() {
    stack_var integer x

    NAVLog("'***************** NAVRegexTemplate - Parser *****************'")

    for (x = 1; x <= length_array(REGEX_TEMPLATE_PARSER_INPUT); x++) {
        stack_var _NAVRegexTemplate template

        // Test parsing success
        if (!NAVAssertTrue('Should parse template successfully', NAVRegexTemplateParse(REGEX_TEMPLATE_PARSER_INPUT[x], template))) {
            NAVLogTestFailed(x, 'true', 'false')
            continue
        }

        // Verify part count
        if (!NAVAssertIntegerEqual('Should have correct part count',
                                    REGEX_TEMPLATE_PARSER_EXPECTED_PART_COUNT[x],
                                    template.partCount)) {
            NAVLogTestFailed(x,
                           itoa(REGEX_TEMPLATE_PARSER_EXPECTED_PART_COUNT[x]),
                           itoa(template.partCount))
            continue
        }

        // Verify first part type (if parts exist)
        if (template.partCount > 0) {
            if (!NAVAssertIntegerEqual('Should have correct first part type',
                                        REGEX_TEMPLATE_PARSER_EXPECTED_FIRST_TYPE[x],
                                        template.parts[1].type)) {
                NAVLogTestFailed(x,
                               itoa(REGEX_TEMPLATE_PARSER_EXPECTED_FIRST_TYPE[x]),
                               itoa(template.parts[1].type))
                continue
            }
        }

        NAVLogTestPassed(x)
    }
}


define_function TestNAVRegexTemplateParserDetails() {
    stack_var integer x

    NAVLog("'***************** NAVRegexTemplate - Parser Details *****************'")

    // Test 2: $1 - Should have captureIndex = 1
    {
        stack_var _NAVRegexTemplate template

        if (NAVRegexTemplateParse('$1', template)) {
            if (!NAVAssertIntegerEqual('$1 should have captureIndex=1', 1, template.parts[1].captureIndex)) {
                NAVLogTestFailed(1, '1', itoa(template.parts[1].captureIndex))
            }
            else {
                NAVLogTestPassed(1)
            }
        }
    }

    // Test 2: $10 - Should parse as capture group 10
    {
        stack_var _NAVRegexTemplate template

        if (NAVRegexTemplateParse('$10', template)) {
            if (!NAVAssertIntegerEqual('$10 should have captureIndex=10', 10, template.parts[1].captureIndex)) {
                NAVLogTestFailed(2, '10', itoa(template.parts[1].captureIndex))
            }
            else {
                NAVLogTestPassed(2)
            }
        }
    }

    // Test 3: ${name} - Should have name='name'
    {
        stack_var _NAVRegexTemplate template

        if (NAVRegexTemplateParse('${name}', template)) {
            if (!NAVAssertStringEqual('${name} should have name="name"', 'name', template.parts[1].name)) {
                NAVLogTestFailed(3, 'name', template.parts[1].name)
            }
            else {
                NAVLogTestPassed(3)
            }
        }
    }

    // Test 4: $<username> - Should have name='username'
    {
        stack_var _NAVRegexTemplate template

        if (NAVRegexTemplateParse('$<username>', template)) {
            if (!NAVAssertStringEqual('$<username> should have name="username"', 'username', template.parts[1].name)) {
                NAVLogTestFailed(4, 'username', template.parts[1].name)
            }
            else {
                NAVLogTestPassed(4)
            }
        }
    }

    // Test 5: $$ - Should have type DOLLAR and value '$'
    {
        stack_var _NAVRegexTemplate template

        if (NAVRegexTemplateParse('$$', template)) {
            if (!NAVAssertStringEqual('$$ should have value="$"', '$', template.parts[1].value)) {
                NAVLogTestFailed(5, '$', template.parts[1].value)
            }
            else {
                NAVLogTestPassed(5)
            }
        }
    }

    // Test 6: 'Hello World' - Should have type LITERAL and value 'Hello World'
    {
        stack_var _NAVRegexTemplate template

        if (NAVRegexTemplateParse('Hello World', template)) {
            if (!NAVAssertStringEqual('Literal should preserve text', 'Hello World', template.parts[1].value)) {
                NAVLogTestFailed(6, 'Hello World', template.parts[1].value)
            }
            else {
                NAVLogTestPassed(6)
            }
        }
    }

    // Test 7: Complex template '$1-$2-$3' - Verify all parts
    {
        stack_var _NAVRegexTemplate template

        if (NAVRegexTemplateParse('$1-$2-$3', template)) {
            stack_var char passed
            passed = true

            // Part 1: $1 (CAPTURE_REF, index=1)
            if (template.parts[1].type != REGEX_TEMPLATE_CAPTURE_REF || template.parts[1].captureIndex != 1) {
                passed = false
            }
            // Part 2: - (LITERAL)
            else if (template.parts[2].type != REGEX_TEMPLATE_LITERAL || template.parts[2].value != '-') {
                passed = false
            }
            // Part 3: $2 (CAPTURE_REF, index=2)
            else if (template.parts[3].type != REGEX_TEMPLATE_CAPTURE_REF || template.parts[3].captureIndex != 2) {
                passed = false
            }
            // Part 4: - (LITERAL)
            else if (template.parts[4].type != REGEX_TEMPLATE_LITERAL || template.parts[4].value != '-') {
                passed = false
            }
            // Part 5: $3 (CAPTURE_REF, index=3)
            else if (template.parts[5].type != REGEX_TEMPLATE_CAPTURE_REF || template.parts[5].captureIndex != 3) {
                passed = false
            }

            if (!passed) {
                NAVLogTestFailed(7, 'All parts correct', 'Part validation failed')
            }
            else {
                NAVLogTestPassed(7)
            }
        }
    }

    // Test 8: Empty string - Should have 0 parts
    {
        stack_var _NAVRegexTemplate template

        if (NAVRegexTemplateParse('', template)) {
            if (!NAVAssertIntegerEqual('Empty template should have 0 parts', 0, template.partCount)) {
                NAVLogTestFailed(8, '0', itoa(template.partCount))
            }
            else {
                NAVLogTestPassed(8)
            }
        }
    }
}