PROGRAM_NAME='NAVYamlDirectives'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_DIRECTIVE_TEST[10][1024]


DEFINE_CONSTANT

constant char YAML_DIRECTIVE_EXPECTED_PARSE_SUCCESS[10] = {
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

constant char YAML_DIRECTIVE_TEST_QUERY[10][64] = {
    '.name',        // Test 1
    '.version',     // Test 2 (numeric)
    '.items[1]',    // Test 3
    '.key',         // Test 4
    '.value',       // Test 5 (numeric)
    '.data',        // Test 6
    '.simple',      // Test 7
    '.field',       // Test 8
    '.node',        // Test 9
    '.item'         // Test 10
}


define_function InitializeYamlDirectiveTestData() {
    // Test 1: YAML version directive
    YAML_DIRECTIVE_TEST[1] = "'%YAML 1.2', 13, 10, 'name: test'"

    // Test 2: TAG directive
    YAML_DIRECTIVE_TEST[2] = "'%TAG ! tag:example.com,2000:', 13, 10, 'version: 1.0'"

    // Test 3: Multiple directives
    YAML_DIRECTIVE_TEST[3] = "'%YAML 1.2', 13, 10, '%TAG ! tag:yaml.org,2002:', 13, 10, 'items:', 13, 10, '  - first', 13, 10, '  - second'"

    // Test 4: Directive with document content
    YAML_DIRECTIVE_TEST[4] = "'%YAML 1.2', 13, 10, '%TAG !! tag:example.com,2000:', 13, 10, 'key: value'"

    // Test 5: Directive before document marker
    YAML_DIRECTIVE_TEST[5] = "'%YAML 1.2', 13, 10, '---', 13, 10, 'value: 42'"

    // Test 6: Multiple TAG directives
    YAML_DIRECTIVE_TEST[6] = "'%TAG ! tag:example.com,2000:', 13, 10, '%TAG !e! tag:example.com,2000:', 13, 10, 'data: content'"

    // Test 7: Document without directives (should still work)
    YAML_DIRECTIVE_TEST[7] = "'simple: value'"

    // Test 8: Directives with comments
    YAML_DIRECTIVE_TEST[8] = "'%YAML 1.2', 13, 10, '# This is a comment', 13, 10, 'field: data'"

    // Test 9: YAML 1.1 directive (for compatibility)
    YAML_DIRECTIVE_TEST[9] = "'%YAML 1.1', 13, 10, 'node: legacy'"

    // Test 10: Directive before empty document
    YAML_DIRECTIVE_TEST[10] = "'%YAML 1.2', 13, 10, '---', 13, 10, 'item: test'"

    set_length_array(YAML_DIRECTIVE_TEST, 10)
}


define_function TestNAVYamlDirectives() {
    stack_var integer x

    InitializeYamlDirectiveTestData()

    NAVLogTestSuiteStart("'NAVYamlDirectives'")

    for (x = 1; x <= length_array(YAML_DIRECTIVE_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var char result[512]
        stack_var integer intResult
        stack_var char parseSuccess
        stack_var char querySuccess

        parseSuccess = NAVYamlParse(YAML_DIRECTIVE_TEST[x], yaml)

        if (!NAVAssertBooleanEqual('Parse success',
                                  YAML_DIRECTIVE_EXPECTED_PARSE_SUCCESS[x],
                                  parseSuccess)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // If parse was expected to fail and did fail, test passes
        if (!YAML_DIRECTIVE_EXPECTED_PARSE_SUCCESS[x]) {
            NAVLogTestPassed(x)
            continue
        }

        // Query the value to verify the document was parsed correctly
        // Tests 2 and 5 query numeric values
        if (x == 2 || x == 5) {
            querySuccess = NAVYamlQueryInteger(yaml, YAML_DIRECTIVE_TEST_QUERY[x], intResult)
        } else {
            querySuccess = NAVYamlQueryString(yaml, YAML_DIRECTIVE_TEST_QUERY[x], result)
        }

        if (!querySuccess) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Verify we got a result
        if (x == 2 || x == 5) {
            if (!NAVAssertIntegerGreaterThan('Result value', 0, intResult)) {
                NAVLogTestFailed(x, 'Non-zero result', 'Zero result')
                continue
            }
        } else {
            if (!NAVAssertIntegerGreaterThan('Result length', 0, length_array(result))) {
                NAVLogTestFailed(x, 'Non-empty result', 'Empty result')
                continue
            }
        }

        NAVLogTestPassed(x)
    }

    NAVLogTestSuiteEnd("'NAVYamlDirectives'")
}

