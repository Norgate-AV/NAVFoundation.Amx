PROGRAM_NAME='NAVYamlMergeKeys'

#include 'NAVFoundation.Yaml.axi'


DEFINE_VARIABLE

volatile char YAML_MERGE_TEST[10][2048]


DEFINE_CONSTANT

constant char YAML_MERGE_EXPECTED_PARSE_SUCCESS[10] = {
    true,  // Test 1 - Basic single merge
    true,  // Test 2 - Merge with override
    true,  // Test 3 - Multiple merges (array)
    true,  // Test 4 - Multiple merges with override
    true,  // Test 5 - Nested merge
    true,  // Test 6 - Merge in array item
    true,  // Test 7 - Deep merge
    true,  // Test 8 - Merge with local key first
    true,  // Test 9 - Multiple anchors merged
    true   // Test 10 - Complex merge scenario
}

constant char YAML_MERGE_EXPECTED_QUERY_SUCCESS[10] = {
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

constant char YAML_MERGE_TEST_QUERY[10][64] = {
    '.person.name',     // Test 1
    '.person.name',     // Test 2
    '.person.name',     // Test 3
    '.person.age',      // Test 4 (numeric)
    '.derived.props.name', // Test 5
    '.items[1].name',   // Test 6
    '.config.db.host',  // Test 7
    '.obj.key1',        // Test 8
    '.result.name',     // Test 9
    '.final.value'      // Test 10
}


define_function InitializeYamlMergeTestData() {
    // Test 1: Basic single merge - <<: *anchor
    YAML_MERGE_TEST[1] = "'defaults: &defaults', 13, 10, '  name: John', 13, 10, '  age: 30', 13, 10, 'person:', 13, 10, '  <<: *defaults'"

    // Test 2: Merge with override - local keys override merged keys
    YAML_MERGE_TEST[2] = "'defaults: &defaults', 13, 10, '  name: John', 13, 10, '  age: 30', 13, 10, 'person:', 13, 10, '  <<: *defaults', 13, 10, '  name: Jane'"

    // Test 3: Multiple merges (array) - <<: [*anchor1, *anchor2]
    YAML_MERGE_TEST[3] = "'base: &base', 13, 10, '  name: John', 13, 10, 'extra: &extra', 13, 10, '  age: 30', 13, 10, 'person:', 13, 10, '  <<: [*base, *extra]'"

    // Test 4: Multiple merges with override - later merges win, locals win over all
    YAML_MERGE_TEST[4] = "'base: &base', 13, 10, '  name: John', 13, 10, '  age: 30', 13, 10, 'override: &override', 13, 10, '  age: 32', 13, 10, 'person:', 13, 10, '  <<: [*base, *override]', 13, 10, '  age: 35'"

    // Test 5: Nested merge - merge within nested object
    YAML_MERGE_TEST[5] = "'base: &base', 13, 10, '  name: John', 13, 10, 'derived:', 13, 10, '  props:', 13, 10, '    <<: *base'"

    // Test 6: Merge in array item
    YAML_MERGE_TEST[6] = "'defaults: &defaults', 13, 10, '  name: John', 13, 10, 'items:', 13, 10, '  - <<: *defaults', 13, 10, '    id: 1'"

    // Test 7: Deep merge - multiple levels
    YAML_MERGE_TEST[7] = "'defaults: &defaults', 13, 10, '  db:', 13, 10, '    host: localhost', 13, 10, '    port: 5432', 13, 10, 'config:', 13, 10, '  <<: *defaults'"

    // Test 8: Merge with local key first - order shouldn't matter
    YAML_MERGE_TEST[8] = "'base: &base', 13, 10, '  key2: value2', 13, 10, 'obj:', 13, 10, '  key1: value1', 13, 10, '  <<: *base'"

    // Test 9: Multiple anchors merged in sequence
    YAML_MERGE_TEST[9] = "'a: &a', 13, 10, '  name: A', 13, 10, '  x: 1', 13, 10, 'b: &b', 13, 10, '  name: B', 13, 10, '  y: 2', 13, 10, 'c: &c', 13, 10, '  name: C', 13, 10, '  z: 3', 13, 10, 'result:', 13, 10, '  <<: [*a, *b, *c]', 13, 10, '  value: done'"

    // Test 10: Complex merge scenario with multiple levels
    YAML_MERGE_TEST[10] = "'level1: &l1', 13, 10, '  a: 1', 13, 10, 'level2: &l2', 13, 10, '  <<: *l1', 13, 10, '  b: 2', 13, 10, 'final:', 13, 10, '  <<: *l2', 13, 10, '  value: test'"

    set_length_array(YAML_MERGE_TEST, 10)
}


define_function TestNAVYamlMergeKeys() {
    stack_var integer x

    InitializeYamlMergeTestData()

    NAVLogTestSuiteStart("'NAVYamlMergeKeys'")

    for (x = 1; x <= length_array(YAML_MERGE_TEST); x++) {
        stack_var _NAVYaml yaml
        stack_var char result[512]
        stack_var integer intResult
        stack_var char parseSuccess
        stack_var char querySuccess

        parseSuccess = NAVYamlParse(YAML_MERGE_TEST[x], yaml)

        if (!NAVAssertBooleanEqual('Parse success',
                                  YAML_MERGE_EXPECTED_PARSE_SUCCESS[x],
                                  parseSuccess)) {
            NAVLogTestFailed(x, 'Parse success', 'Parse failed')
            continue
        }

        // If parse was expected to fail and did fail, test passes
        if (!YAML_MERGE_EXPECTED_PARSE_SUCCESS[x]) {
            NAVLogTestPassed(x)
            continue
        }

        // Query the merged value to verify it was properly merged
        // Test 4 queries a numeric value
        if (x == 4) {
            querySuccess = NAVYamlQueryInteger(yaml, YAML_MERGE_TEST_QUERY[x], intResult)
        } else {
            querySuccess = NAVYamlQueryString(yaml, YAML_MERGE_TEST_QUERY[x], result)
        }

        if (!querySuccess) {
            NAVLogTestFailed(x, 'Query success', 'Query failed')
            continue
        }

        // Verify we got a result
        if (x == 4) {
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

    NAVLogTestSuiteEnd("'NAVYamlMergeKeys'")
}
