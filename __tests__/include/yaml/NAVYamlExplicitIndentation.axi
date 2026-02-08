PROGRAM_NAME='NAVYamlExplicitIndentation'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_EXPLICIT_INDENT_TEST[8][1024]


DEFINE_CONSTANT

constant char YAML_EXPLICIT_INDENT_EXPECTED_PARSE_SUCCESS[8] = {
    true,  // Test 1: Literal |2 (2-space explicit indent)
    true,  // Test 2: Literal |4 (4-space explicit indent)
    true,  // Test 3: Folded >2 (2-space explicit indent)
    true,  // Test 4: Folded >4 (4-space explicit indent)
    true,  // Test 5: Literal |2+ (explicit indent + keep)
    true,  // Test 6: Literal |4- (explicit indent + strip)
    true,  // Test 7: Folded >2- (explicit indent + strip)
    true   // Test 8: Folded >6 (6-space explicit indent)
}

constant char YAML_EXPLICIT_INDENT_EXPECTED_QUERY_SUCCESS[8] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true   // Test 8
}

constant char YAML_EXPLICIT_INDENT_TEST_QUERY[8][64] = {
    '.text',  // Test 1
    '.text',  // Test 2
    '.text',  // Test 3
    '.text',  // Test 4
    '.text',  // Test 5
    '.text',  // Test 6
    '.text',  // Test 7
    '.text'   // Test 8
}


define_function InitializeYamlExplicitIndentTestData() {
    // Test 1: Literal |2 - explicit 2-space indent
    // The indicator is at column 6 ("text: |2"), so content at column 8 (6+2)
    // Expected: "Line 1\r\nLine 2\r\nLine 3\r\n"
    YAML_EXPLICIT_INDENT_TEST[1] = "'text: |2', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3', 13, 10"

    // Test 2: Literal |4 - explicit 4-space indent
    // Expected: "Line 1\r\nLine 2\r\n"
    YAML_EXPLICIT_INDENT_TEST[2] = "'text: |4', 13, 10, '    Line 1', 13, 10, '    Line 2', 13, 10"

    // Test 3: Folded >2 - explicit 2-space indent
    // Expected: "Line 1 Line 2 Line 3\r\n" (folded into single line)
    YAML_EXPLICIT_INDENT_TEST[3] = "'text: >2', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3', 13, 10"

    // Test 4: Folded >4 - explicit 4-space indent
    // Expected: "Line 1 Line 2\r\n" (folded into single line)
    YAML_EXPLICIT_INDENT_TEST[4] = "'text: >4', 13, 10, '    Line 1', 13, 10, '    Line 2', 13, 10"

    // Test 5: Literal |2+ - explicit indent with keep chomping
    // Expected: "Line 1\r\nLine 2\r\nLine 3\r\n" (keeps trailing newline)
    YAML_EXPLICIT_INDENT_TEST[5] = "'text: |2+', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3', 13, 10"

    // Test 6: Literal |4- - explicit indent with strip chomping
    // Expected: "Line 1\r\nLine 2" (strips trailing newlines)
    YAML_EXPLICIT_INDENT_TEST[6] = "'text: |4-', 13, 10, '    Line 1', 13, 10, '    Line 2', 13, 10"

    // Test 7: Folded >2- - explicit indent with strip chomping
    // Expected: "Line 1 Line 2 Line 3" (folded, no trailing newline)
    YAML_EXPLICIT_INDENT_TEST[7] = "'text: >2-', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3', 13, 10"

    // Test 8: Folded >6 - explicit 6-space indent
    // Expected: "Line 1 Line 2\r\n" (folded into single line)
    YAML_EXPLICIT_INDENT_TEST[8] = "'text: >6', 13, 10, '      Line 1', 13, 10, '      Line 2', 13, 10"

    set_length_array(YAML_EXPLICIT_INDENT_TEST, 8)
}


define_function TestNAVYamlExplicitIndentation() {
    stack_var integer i

    InitializeYamlExplicitIndentTestData()

    NAVLogTestSuiteStart("'NAVYamlExplicitIndentation'")

    for (i = 1; i <= length_array(YAML_EXPLICIT_INDENT_TEST); i++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode node
        stack_var char str[1024]
        stack_var char parseResult
        stack_var char queryResult

        // Parse Test
        parseResult = NAVYamlParse(YAML_EXPLICIT_INDENT_TEST[i], yaml)

        if (YAML_EXPLICIT_INDENT_EXPECTED_PARSE_SUCCESS[i]) {
            if (!NAVAssertBooleanEqual('Explicit Indent Parse Test', parseResult, true)) {
                NAVLogTestFailed(i, 'Parse success', 'Parse failed')
                continue
            }
        }
        else {
            if (!NAVAssertBooleanEqual('Explicit Indent Parse Test (Expected Failure)', parseResult, false)) {
                NAVLogTestFailed(i, 'Parse failure', 'Expected to fail but succeeded')
                continue
            }
        }

        // Query Test
        if (parseResult) {
            queryResult = NAVYamlQuery(yaml, YAML_EXPLICIT_INDENT_TEST_QUERY[i], node)

            if (YAML_EXPLICIT_INDENT_EXPECTED_QUERY_SUCCESS[i]) {
                if (!NAVAssertBooleanEqual('Explicit Indent Query Test', queryResult, true)) {
                    NAVLogTestFailed(i, 'Query success', 'Query failed')
                    continue
                }

                // Test string value retrieval
                queryResult = NAVYamlQueryString(yaml, YAML_EXPLICIT_INDENT_TEST_QUERY[i], str)

                if (!NAVAssertBooleanEqual('Explicit Indent Query String Test', queryResult, true)) {
                    NAVLogTestFailed(i, 'Query string', 'Failed to get string value')
                    continue
                }

                // Verify we got non-empty content
                if (!NAVAssertIntegerGreaterThan('Non-empty explicit indent scalar', 0, length_array(str))) {
                    NAVLogTestFailed(i, 'Non-empty', 'Empty value')
                    continue
                }
            }
            else {
                if (!NAVAssertBooleanEqual('Explicit Indent Query Test (Expected Failure)', queryResult, false)) {
                    NAVLogTestFailed(i, 'Query failure', 'Expected to fail but succeeded')
                    continue
                }
            }
        }

        NAVLogTestPassed(i)
    }

    NAVLogTestSuiteEnd("'NAVYamlExplicitIndentation'")
}
