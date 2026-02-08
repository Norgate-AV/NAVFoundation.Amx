PROGRAM_NAME='NAVYamlBlockScalarChomping'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_CHOMPING_TEST[12][1024]


DEFINE_CONSTANT

// All tests enabled - lexer tokenizes blank lines, parser handles empty blocks correctly.

constant char YAML_CHOMPING_EXPECTED_PARSE_SUCCESS[12] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9
    true,  // Test 10 - Empty block with strip
    true,  // Test 11 - Empty block with keep
    true   // Test 12 - Empty block with clip
}

constant char YAML_CHOMPING_EXPECTED_QUERY_SUCCESS[12] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9
    true,  // Test 10
    true,  // Test 11
    true   // Test 12
}

constant char YAML_CHOMPING_TEST_QUERY[12][64] = {
    '.text',  // Test 1
    '.text',  // Test 2
    '.text',  // Test 3
    '.text',  // Test 4
    '.text',  // Test 5
    '.text',  // Test 6
    '.text',  // Test 7
    '.text',  // Test 8
    '.text',  // Test 9
    '.text',  // Test 10
    '.text',  // Test 11
    '.text'   // Test 12
}


define_function InitializeYamlChompingTestData() {
    // Test 1: Literal strip (|-) - removes all trailing newlines
    // Expected: "Line 1\r\nLine 2\r\nLine 3" (no trailing newlines)
    YAML_CHOMPING_TEST[1] = "'text: |-', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3', 13, 10"

    // Test 2: Literal keep (|+) - keeps all trailing newlines
    // Expected: "Line 1\r\nLine 2\r\nLine 3\r\n\r\n" (keeps trailing newlines)
    YAML_CHOMPING_TEST[2] = "'text: |+', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3', 13, 10, 13, 10"

    // Test 3: Literal clip (|) - keeps exactly one trailing newline
    // Expected: "Line 1\r\nLine 2\r\nLine 3\r\n" (one trailing newline)
    YAML_CHOMPING_TEST[3] = "'text: |', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3', 13, 10, 13, 10"

    // Test 4: Folded strip (>-) - removes all trailing newlines
    YAML_CHOMPING_TEST[4] = "'text: >-', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3', 13, 10"

    // Test 5: Folded keep (>+) - keeps all trailing newlines
    YAML_CHOMPING_TEST[5] = "'text: >+', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3', 13, 10, 13, 10"

    // Test 6: Folded clip (>) - keeps exactly one trailing newline
    YAML_CHOMPING_TEST[6] = "'text: >', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3', 13, 10, 13, 10"

    // Test 7: Literal strip with 3 trailing newlines - should strip all
    YAML_CHOMPING_TEST[7] = "'text: |-', 13, 10, '  Content', 13, 10, 13, 10, 13, 10"

    // Test 8: Literal keep with 3 trailing newlines - should keep all
    YAML_CHOMPING_TEST[8] = "'text: |+', 13, 10, '  Content', 13, 10, 13, 10, 13, 10"

    // Test 9: Literal clip with 3 trailing newlines - should keep exactly 1
    YAML_CHOMPING_TEST[9] = "'text: |', 13, 10, '  Content', 13, 10, 13, 10, 13, 10"

    // Test 10: Empty block with strip
    YAML_CHOMPING_TEST[10] = "'text: |-', 13, 10"

    // Test 11: Empty block with keep
    YAML_CHOMPING_TEST[11] = "'text: |+', 13, 10"

    // Test 12: Empty block with clip
    YAML_CHOMPING_TEST[12] = "'text: |', 13, 10"

    set_length_array(YAML_CHOMPING_TEST, 12)
}


define_function TestNAVYamlBlockScalarChomping() {
    stack_var integer x

    InitializeYamlChompingTestData()

    NAVLogTestSuiteStart("'NAVYamlBlockScalarChomping'")

    for (x = 1; x <= length_array(YAML_CHOMPING_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode node
        stack_var char str[1024]
        stack_var char result
        stack_var integer len
        stack_var integer trailingCRLFs

        // Skip disabled tests (currently only test 10)
        if (YAML_CHOMPING_EXPECTED_PARSE_SUCCESS[x] == 0) {
            NAVLogTestPassed(x)  // Marked as passed (disabled/skipped)
            continue
        }

        result = NAVYamlParse(YAML_CHOMPING_TEST[x], yaml)

        if (!result) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        result = NAVYamlQuery(yaml, YAML_CHOMPING_TEST_QUERY[x], node)

        if (!result) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Get the value
        if (!NAVYamlQueryString(yaml, YAML_CHOMPING_TEST_QUERY[x], str)) {
            NAVLogTestFailed(x, 'Query string value', 'Query failed')
            continue
        }

        len = length_array(str)

        // Count trailing CRLF pairs (avoid index out of bounds on empty strings)
        trailingCRLFs = 0
        if (len >= 2) {
            // Only check array elements if length is sufficient
            while (len >= 2) {
                if (str[len - 1] == 13 && str[len] == 10) {
                    trailingCRLFs++
                    len = len - 2
                }
                else {
                    break  // Stop if we don't find a CRLF pair
                }
            }
        }

        // Verify chomping behavior
        select {
            active (x == 1 || x == 4 || x == 7): {
                // Strip: should have 0 trailing CRLFs
                if (!NAVAssertIntegerEqual('Strip chomping (0 trailing newlines)', 0, trailingCRLFs)) {
                    NAVLogTestFailed(x, 'Strip chomping', "'Expected 0 trailing CRLFs, got ', itoa(trailingCRLFs)")
                    continue
                }
            }
            active (x == 2 || x == 5 || x == 8 || x == 11): {
                // Keep: should have 2+ trailing CRLFs (kept all)
                if (!NAVAssertIntegerGreaterThanOrEqual('Keep chomping (2+ trailing newlines)', 2, trailingCRLFs)) {
                    NAVLogTestFailed(x, 'Keep chomping', "'Expected 2+ trailing CRLFs, got ', itoa(trailingCRLFs)")
                    continue
                }
            }
            active (x == 3 || x == 6 || x == 9 || x == 12): {
                // Clip: should have exactly 1 trailing CRLF
                if (!NAVAssertIntegerEqual('Clip chomping (1 trailing newline)', 1, trailingCRLFs)) {
                    NAVLogTestFailed(x, 'Clip chomping', "'Expected 1 trailing CRLF, got ', itoa(trailingCRLFs)")
                    continue
                }
            }
        }

        // Verify content is present (only for non-empty block tests)
        if (x < 10) {
            stack_var integer contentLen
            contentLen = length_array(str) - (trailingCRLFs * 2)  // Subtract trailing CRLFs

            if (!NAVAssertIntegerGreaterThan('Has content', 0, contentLen)) {
                NAVLogTestFailed(x, 'Content check', 'No content found')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlBlockScalarChomping'")
}
