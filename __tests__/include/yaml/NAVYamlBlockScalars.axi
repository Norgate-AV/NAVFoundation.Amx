PROGRAM_NAME='NAVYamlBlockScalars'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_BLOCK_SCALAR_TEST[10][1024]


DEFINE_CONSTANT

constant char YAML_BLOCK_SCALAR_EXPECTED_PARSE_SUCCESS[10] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9
    true   // Test 10
}

constant char YAML_BLOCK_SCALAR_EXPECTED_QUERY_SUCCESS[10] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5
    true,  // Test 6
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9
    true   // Test 10
}

constant char YAML_BLOCK_SCALAR_EXPECTED_HAS_VALUE[10] = {
    true,  // Test 1
    true,  // Test 2
    true,  // Test 3
    true,  // Test 4
    true,  // Test 5 - data.content
    true,  // Test 6 - data.content
    true,  // Test 7
    true,  // Test 8
    true,  // Test 9 - sequence elements
    true   // Test 10
}

constant char YAML_BLOCK_SCALAR_TEST_QUERY[10][64] = {
    '.text',          // Test 1
    '.text',          // Test 2
    '.description',   // Test 3
    '.description',   // Test 4
    '.data.content',  // Test 5
    '.data.content',  // Test 6
    '.code',          // Test 7
    '.paragraph',     // Test 8
    '.[1]',           // Test 9 - first element
    '.text'           // Test 10
}


define_function InitializeYamlBlockScalarTestData() {
    // Test 1: Simple literal scalar (|)
    YAML_BLOCK_SCALAR_TEST[1] = "'text: |', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3'"

    // Test 2: Simple folded scalar (>)
    YAML_BLOCK_SCALAR_TEST[2] = "'text: >', 13, 10, '  Line 1', 13, 10, '  Line 2', 13, 10, '  Line 3'"

    // Test 3: Literal scalar with newlines preserved
    YAML_BLOCK_SCALAR_TEST[3] = "'description: |', 13, 10, '  This is a', 13, 10, '  multi-line', 13, 10, '  description'"

    // Test 4: Folded scalar with lines folded
    YAML_BLOCK_SCALAR_TEST[4] = "'description: >', 13, 10, '  This is a', 13, 10, '  multi-line', 13, 10, '  description'"

    // Test 5: Literal scalar in mapping
    YAML_BLOCK_SCALAR_TEST[5] = "'data:', 13, 10, '  content: |', 13, 10, '    Text here', 13, 10, '  name: test'"

    // Test 6: Folded scalar in mapping
    YAML_BLOCK_SCALAR_TEST[6] = "'data:', 13, 10, '  content: >', 13, 10, '    Text here', 13, 10, '  name: test'"

    // Test 7: Literal scalar with indentation
    YAML_BLOCK_SCALAR_TEST[7] = "'code: |', 13, 10, '  def function():', 13, 10, '    return true'"

    // Test 8: Folded scalar with indentation
    YAML_BLOCK_SCALAR_TEST[8] = "'paragraph: >', 13, 10, '  This is a long', 13, 10, '  paragraph that', 13, 10, '  spans lines'"

    // Test 9: Multiple literal scalars in sequence
    YAML_BLOCK_SCALAR_TEST[9] = "'- |', 13, 10, '  First', 13, 10, '- |', 13, 10, '  Second'"

    // Test 10: Literal scalar with empty lines
    YAML_BLOCK_SCALAR_TEST[10] = "'text: |', 13, 10, '  Line 1', 13, 10, '', 13, 10, '  Line 3'"

    set_length_array(YAML_BLOCK_SCALAR_TEST, 10)
}


define_function TestNAVYamlBlockScalars() {
    stack_var integer x

    InitializeYamlBlockScalarTestData()

    NAVLogTestSuiteStart("'NAVYamlBlockScalars'")

    for (x = 1; x <= length_array(YAML_BLOCK_SCALAR_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var _NAVYamlNode node
        stack_var char str[1024]
        stack_var char result

        result = NAVYamlParse(YAML_BLOCK_SCALAR_TEST[x], yaml)

        if (!NAVAssertBooleanEqual('Parse success', YAML_BLOCK_SCALAR_EXPECTED_PARSE_SUCCESS[x], result)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        result = NAVYamlQuery(yaml, YAML_BLOCK_SCALAR_TEST_QUERY[x], node)

        // Test query to block scalar
        if (!NAVAssertBooleanEqual('Query success', YAML_BLOCK_SCALAR_EXPECTED_QUERY_SUCCESS[x], result)) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Test that value can be retrieved
        if (YAML_BLOCK_SCALAR_EXPECTED_HAS_VALUE[x]) {
            if (!NAVAssertBooleanEqual('Query string value', true, NAVYamlQueryString(yaml, YAML_BLOCK_SCALAR_TEST_QUERY[x], str))) {
                NAVLogTestFailed(x, 'Query string value', 'Query failed')
                continue
            }

            // Verify we got a non-empty string
            if (!NAVAssertIntegerGreaterThan('Non-empty block scalar', 0, length_array(str))) {
                NAVLogTestFailed(x, 'Non-empty block scalar', 'Empty value')
                continue
            }

            // For literal scalars (tests 1, 3, 5, 7, 9, 10), newlines should be preserved
            // For folded scalars (tests 2, 4, 6, 8), lines should be joined
            // We test that at least some content was captured
            select {
                active (x == 1 || x == 7 || x == 10): {
                    stack_var char hasContent
                    // Literal scalar - should contain newlines or line content
                    hasContent = (NAVContains(str, 'Line') ||
                                  NAVContains(str, 'Text') ||
                                  NAVContains(str, 'def'))
                    if (!NAVAssertBooleanEqual('Has expected content', true, hasContent)) {
                        NAVLogTestFailed(x, 'Block scalar content', 'Content not found')
                        continue
                    }
                }
                active (x == 3): {
                    stack_var char hasContent
                    // Literal scalar - test 3 specific content
                    hasContent = (NAVContains(str, 'This') ||
                                  NAVContains(str, 'multi') ||
                                  NAVContains(str, 'description'))
                    if (!NAVAssertBooleanEqual('Has expected content', true, hasContent)) {
                        NAVLogTestFailed(x, 'Block scalar content', 'Content not found')
                        continue
                    }
                }
                active (x == 2 || x == 4 || x == 6 || x == 8): {
                    stack_var char hasContent
                    // Folded scalar - should contain content
                    hasContent = (NAVContains(str, 'Line') ||
                                  NAVContains(str, 'Text') ||
                                  NAVContains(str, 'This'))
                    if (!NAVAssertBooleanEqual('Has expected content', true, hasContent)) {
                        NAVLogTestFailed(x, 'Block scalar content', 'Content not found')
                        continue
                    }
                }
                active (x == 5): {
                    // Test 5 - nested literal scalar
                    if (!NAVAssertBooleanEqual('Has Text content', true, NAVContains(str, 'Text'))) {
                        NAVLogTestFailed(x, 'Block scalar content', 'Content not found')
                        continue
                    }
                }
                active (x == 9): {
                    // Test 9 - sequence of literal scalars
                    if (!NAVAssertBooleanEqual('Has First content', true, NAVContains(str, 'First'))) {
                        NAVLogTestFailed(x, 'Block scalar content', 'Content not found')
                        continue
                    }
                }
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlBlockScalars'")
}
